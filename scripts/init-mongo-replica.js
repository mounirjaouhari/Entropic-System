#!/usr/bin/env node

/**
 * MongoDB Replica Set Initialization Script
 * Initializes a MongoDB replica set with enhanced error handling, logging, and security
 */

const { MongoClient } = require('mongodb');
const fs = require('fs');
const path = require('path');
const { EventEmitter } = require('events');

// Configuration constants
const CONFIG = {
  maxRetries: 5,
  retryDelay: 2000, // ms
  connectionTimeout: 30000, // ms
  serverSelectionTimeout: 10000, // ms
  socketTimeout: 45000, // ms
  maxPoolSize: 10,
  minPoolSize: 2,
  heartbeatFrequencyMS: 10000,
};

// Logger utility
class Logger extends EventEmitter {
  constructor(logFile = null) {
    super();
    this.logFile = logFile;
    this.startTime = new Date();
  }

  log(level, message, data = null) {
    const timestamp = new Date().toISOString();
    const logEntry = {
      timestamp,
      level,
      message,
      ...(data && { data }),
    };

    const logString = `[${timestamp}] [${level}] ${message}${
      data ? ` | ${JSON.stringify(data)}` : ''
    }`;

    // Console output
    switch (level) {
      case 'ERROR':
        console.error(logString);
        break;
      case 'WARN':
        console.warn(logString);
        break;
      case 'INFO':
        console.log(logString);
        break;
      case 'DEBUG':
        if (process.env.DEBUG) {
          console.log(logString);
        }
        break;
    }

    // File logging if configured
    if (this.logFile) {
      try {
        fs.appendFileSync(
          this.logFile,
          logString + '\n',
          { encoding: 'utf8' }
        );
      } catch (err) {
        console.error(`Failed to write to log file: ${err.message}`);
      }
    }

    this.emit('log', logEntry);
  }

  info(message, data) {
    this.log('INFO', message, data);
  }

  warn(message, data) {
    this.log('WARN', message, data);
  }

  error(message, data) {
    this.log('ERROR', message, data);
  }

  debug(message, data) {
    this.log('DEBUG', message, data);
  }
}

/**
 * MongoDB Replica Set Initializer
 */
class MongoReplicaInitializer {
  constructor(mongoUri, options = {}) {
    this.mongoUri = this.sanitizeUri(mongoUri);
    this.options = { ...CONFIG, ...options };
    this.logger = new Logger(options.logFile);
    this.client = null;
    this.admin = null;
  }

  /**
   * Sanitize MongoDB URI for logging (remove credentials)
   */
  sanitizeUri(uri) {
    return uri.replace(/mongodb\+srv:\/\/[^@]*@/, 'mongodb+srv://***:***@');
  }

  /**
   * Retry logic with exponential backoff
   */
  async retry(fn, context = null, retryCount = 0) {
    try {
      return await fn.call(context);
    } catch (err) {
      if (retryCount < this.options.maxRetries) {
        const delay = this.options.retryDelay * Math.pow(2, retryCount);
        this.logger.warn(
          `Attempt ${retryCount + 1} failed, retrying in ${delay}ms`,
          { error: err.message }
        );
        await new Promise((resolve) => setTimeout(resolve, delay));
        return this.retry(fn, context, retryCount + 1);
      }
      throw err;
    }
  }

  /**
   * Create MongoDB client with security and timeout configurations
   */
  createClient() {
    return new MongoClient(this.mongoUri, {
      connectTimeoutMS: this.options.connectionTimeout,
      serverSelectionTimeoutMS: this.options.serverSelectionTimeout,
      socketTimeoutMS: this.options.socketTimeout,
      maxPoolSize: this.options.maxPoolSize,
      minPoolSize: this.options.minPoolSize,
      heartbeatFrequencyMS: this.options.heartbeatFrequencyMS,
      // Security features
      tls: process.env.MONGO_TLS !== 'false',
      tlsAllowInvalidCertificates: process.env.MONGO_ALLOW_INVALID_CERTS === 'true',
      authSource: 'admin',
      // Connection pooling
      waitQueueTimeoutMS: 10000,
      // Monitoring
      monitorCommands: process.env.DEBUG === 'true',
    });
  }

  /**
   * Connect to MongoDB
   */
  async connect() {
    try {
      this.logger.info('Connecting to MongoDB...');

      const client = this.createClient();

      const connectedClient = await this.retry(
        async () => {
          const conn = this.createClient();
          await conn.connect();
          return conn;
        }
      );

      this.client = connectedClient;
      this.admin = this.client.admin();

      // Verify connection
      const serverStatus = await this.admin.serverStatus();
      this.logger.info('Successfully connected to MongoDB', {
        version: serverStatus.version,
        uptime: serverStatus.uptime,
      });

      return true;
    } catch (err) {
      this.logger.error('Failed to connect to MongoDB', {
        error: err.message,
        code: err.code,
      });
      throw err;
    }
  }

  /**
   * Initialize replica set
   */
  async initializeReplicaSet() {
    try {
      this.logger.info('Initializing replica set...');

      // Check if replica set is already initialized
      let replicaStatus;
      try {
        replicaStatus = await this.admin.replSetGetStatus();
        this.logger.info('Replica set already initialized', {
          name: replicaStatus.set,
          members: replicaStatus.members.length,
        });
        return replicaStatus;
      } catch (err) {
        if (err.code !== 94) {
          // 94 = NotYetInitialized
          throw err;
        }
        this.logger.debug('Replica set not yet initialized, proceeding with init');
      }

      // Get replica set configuration
      const config = this.getReplicaSetConfig();
      this.logger.debug('Replica set configuration', { config });

      // Initialize replica set
      await this.retry(
        async () => {
          await this.admin.replSetInitiate(config);
        },
        null
      );

      this.logger.info('Replica set initialization initiated');

      // Wait for replica set to be ready
      await this.waitForReplicaSetReady();

      return true;
    } catch (err) {
      this.logger.error('Failed to initialize replica set', {
        error: err.message,
        code: err.code,
      });
      throw err;
    }
  }

  /**
   * Get replica set configuration
   */
  getReplicaSetConfig() {
    const members = this.getReplicaMembers();
    
    return {
      _id: process.env.REPLICA_SET_NAME || 'rs0',
      members,
      settings: {
        chainingAllowed: true,
        electionTimeoutMillis: 10000,
        heartbeatIntervalMillis: 2000,
        heartbeatTimeoutSecs: 10,
        reelectionTimeoutMillis: 10000,
      },
    };
  }

  /**
   * Get replica set members from environment or default configuration
   */
  getReplicaMembers() {
    const membersEnv = process.env.REPLICA_MEMBERS;
    
    if (membersEnv) {
      try {
        return JSON.parse(membersEnv);
      } catch (err) {
        this.logger.warn('Failed to parse REPLICA_MEMBERS from environment', {
          error: err.message,
        });
      }
    }

    // Default configuration
    return [
      {
        _id: 0,
        host: process.env.MONGO_HOST || 'localhost:27017',
        priority: 1,
      },
      {
        _id: 1,
        host: process.env.MONGO_HOST_1 || 'localhost:27018',
        priority: 0.5,
      },
      {
        _id: 2,
        host: process.env.MONGO_HOST_2 || 'localhost:27019',
        priority: 0.5,
      },
    ];
  }

  /**
   * Wait for replica set to be ready
   */
  async waitForReplicaSetReady(timeout = 60000) {
    const startTime = Date.now();
    const checkInterval = 2000; // ms

    this.logger.info('Waiting for replica set to be ready...');

    while (Date.now() - startTime < timeout) {
      try {
        const status = await this.admin.replSetGetStatus();
        const allHealthy = status.members.every((m) => m.health === 1);
        const primaryExists = status.members.some((m) => m.state === 1);

        if (allHealthy && primaryExists) {
          this.logger.info('Replica set is ready', {
            members: status.members.length,
            primary: status.members.find((m) => m.state === 1)?.name,
          });
          return true;
        }

        this.logger.debug('Replica set not ready yet', {
          members: status.members.map((m) => ({
            name: m.name,
            state: m.state,
            health: m.health,
          })),
        });
      } catch (err) {
        this.logger.debug('Error checking replica set status', {
          error: err.message,
        });
      }

      await new Promise((resolve) => setTimeout(resolve, checkInterval));
    }

    throw new Error(`Replica set did not become ready within ${timeout}ms`);
  }

  /**
   * Create admin user if needed
   */
  async ensureAdminUser() {
    try {
      this.logger.info('Ensuring admin user exists...');

      if (
        !process.env.MONGO_INITDB_ROOT_USERNAME ||
        !process.env.MONGO_INITDB_ROOT_PASSWORD
      ) {
        this.logger.warn('Admin credentials not provided, skipping admin user creation');
        return;
      }

      const adminDb = this.client.db('admin');
      const username = process.env.MONGO_INITDB_ROOT_USERNAME;

      try {
        // Check if user exists
        const users = await adminDb.admin().listUsers();
        if (users.users.some((u) => u.user === username)) {
          this.logger.info('Admin user already exists');
          return;
        }
      } catch (err) {
        this.logger.debug('Error listing users', { error: err.message });
      }

      // Create admin user
      await adminDb.admin().addUser(username, process.env.MONGO_INITDB_ROOT_PASSWORD, {
        roles: ['root'],
      });

      this.logger.info('Admin user created successfully');
    } catch (err) {
      this.logger.warn('Failed to ensure admin user', {
        error: err.message,
      });
      // Don't throw - continue even if admin user creation fails
    }
  }

  /**
   * Get replica set status
   */
  async getStatus() {
    try {
      return await this.admin.replSetGetStatus();
    } catch (err) {
      this.logger.error('Failed to get replica set status', {
        error: err.message,
      });
      throw err;
    }
  }

  /**
   * Close the MongoDB connection
   */
  async disconnect() {
    try {
      if (this.client) {
        await this.client.close();
        this.logger.info('Disconnected from MongoDB');
      }
    } catch (err) {
      this.logger.error('Error disconnecting from MongoDB', {
        error: err.message,
      });
    }
  }

  /**
   * Initialize and return status
   */
  async init() {
    try {
      await this.connect();
      await this.ensureAdminUser();
      await this.initializeReplicaSet();
      const status = await this.getStatus();
      
      this.logger.info('Replica set initialization completed successfully');
      return {
        success: true,
        status,
      };
    } catch (err) {
      this.logger.error('Replica set initialization failed', {
        error: err.message,
      });
      throw err;
    } finally {
      await this.disconnect();
    }
  }
}

/**
 * Main execution
 */
async function main() {
  try {
    const mongoUri =
      process.env.MONGO_URI ||
      'mongodb://localhost:27017,localhost:27018,localhost:27019/?replicaSet=rs0';

    const logFile = process.env.LOG_FILE
      ? path.resolve(process.env.LOG_FILE)
      : null;

    const initializer = new MongoReplicaInitializer(mongoUri, {
      logFile,
      maxRetries: parseInt(process.env.MAX_RETRIES || '5', 10),
    });

    const result = await initializer.init();

    console.log('\n✓ MongoDB Replica Set Initialized Successfully');
    console.log(
      JSON.stringify(
        {
          replicaSet: result.status.set,
          members: result.status.members.length,
          primary: result.status.members.find((m) => m.state === 1)?.name || 'N/A',
        },
        null,
        2
      )
    );

    process.exit(0);
  } catch (err) {
    console.error('\n✗ Failed to initialize MongoDB Replica Set');
    console.error(`Error: ${err.message}`);
    console.error(`Stack: ${err.stack}`);

    process.exit(1);
  }
}

// Handle graceful shutdown
process.on('SIGINT', async () => {
  console.log('\nReceived SIGINT, shutting down gracefully...');
  process.exit(0);
});

process.on('SIGTERM', async () => {
  console.log('\nReceived SIGTERM, shutting down gracefully...');
  process.exit(0);
});

// Run if executed directly
if (require.main === module) {
  main();
}

module.exports = { MongoReplicaInitializer, Logger };
