#!/usr/bin/env python3
"""
Producer script for Entropic System with enhanced error handling,
connection pooling, batch processing, metrics, and comprehensive logging.
"""

import logging
import logging.handlers
import os
import sys
import time
import json
from datetime import datetime
from typing import Any, Dict, List, Optional, Tuple
from dataclasses import dataclass, asdict
from collections import deque
from enum import Enum
import traceback
from contextlib import contextmanager

try:
    from kafka import KafkaProducer
    from kafka.errors import KafkaError, KafkaTimeoutError
except ImportError:
    print("Error: kafka-python is not installed. Install it with: pip install kafka-python")
    sys.exit(1)


# ============================================================================
# Configuration and Constants
# ============================================================================

class LogLevel(Enum):
    """Logging level enumeration"""
    DEBUG = logging.DEBUG
    INFO = logging.INFO
    WARNING = logging.WARNING
    ERROR = logging.ERROR
    CRITICAL = logging.CRITICAL


@dataclass
class ProducerConfig:
    """Configuration for the Kafka producer"""
    bootstrap_servers: List[str]
    topic: str
    batch_size: int = 100
    batch_timeout_ms: int = 5000
    max_retries: int = 3
    retry_backoff_ms: int = 100
    log_level: LogLevel = LogLevel.INFO
    log_file: Optional[str] = None
    connection_pool_size: int = 5
    acks: str = 'all'
    compression_type: str = 'snappy'


# ============================================================================
# Metrics Collection
# ============================================================================

@dataclass
class ProducerMetrics:
    """Metrics for producer performance"""
    total_messages: int = 0
    successful_messages: int = 0
    failed_messages: int = 0
    total_bytes: int = 0
    start_time: float = 0.0
    end_time: float = 0.0
    batch_count: int = 0
    error_count: int = 0
    retry_count: int = 0
    connection_errors: int = 0
    timeout_errors: int = 0

    @property
    def duration_seconds(self) -> float:
        """Calculate duration in seconds"""
        if self.start_time and self.end_time:
            return self.end_time - self.start_time
        return 0.0

    @property
    def messages_per_second(self) -> float:
        """Calculate messages per second"""
        duration = self.duration_seconds
        if duration > 0:
            return self.successful_messages / duration
        return 0.0

    @property
    def success_rate(self) -> float:
        """Calculate success rate percentage"""
        if self.total_messages > 0:
            return (self.successful_messages / self.total_messages) * 100
        return 0.0

    def to_dict(self) -> Dict[str, Any]:
        """Convert metrics to dictionary"""
        return {
            'total_messages': self.total_messages,
            'successful_messages': self.successful_messages,
            'failed_messages': self.failed_messages,
            'total_bytes': self.total_bytes,
            'duration_seconds': round(self.duration_seconds, 2),
            'messages_per_second': round(self.messages_per_second, 2),
            'success_rate_percent': round(self.success_rate, 2),
            'batch_count': self.batch_count,
            'error_count': self.error_count,
            'retry_count': self.retry_count,
            'connection_errors': self.connection_errors,
            'timeout_errors': self.timeout_errors,
        }


# ============================================================================
# Logging Setup
# ============================================================================

class LoggerSetup:
    """Centralized logging configuration"""

    @staticmethod
    def setup_logger(
        name: str,
        level: LogLevel = LogLevel.INFO,
        log_file: Optional[str] = None
    ) -> logging.Logger:
        """
        Setup and configure a logger with both console and file handlers.

        Args:
            name: Logger name
            level: Logging level
            log_file: Optional file path for logging

        Returns:
            Configured logger instance
        """
        logger = logging.getLogger(name)
        logger.setLevel(level.value)

        # Prevent duplicate handlers
        if logger.handlers:
            return logger

        # Console handler
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setLevel(level.value)
        console_formatter = logging.Formatter(
            '[%(asctime)s] [%(name)s] [%(levelname)s] %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        console_handler.setFormatter(console_formatter)
        logger.addHandler(console_handler)

        # File handler (if specified)
        if log_file:
            try:
                file_handler = logging.handlers.RotatingFileHandler(
                    log_file,
                    maxBytes=10 * 1024 * 1024,  # 10MB
                    backupCount=5
                )
                file_handler.setLevel(level.value)
                file_formatter = logging.Formatter(
                    '[%(asctime)s] [%(name)s] [%(levelname)s] %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S'
                )
                file_handler.setFormatter(file_formatter)
                logger.addHandler(file_handler)
            except (IOError, OSError) as e:
                logger.warning(f"Could not setup file logging to {log_file}: {e}")

        return logger


# ============================================================================
# Connection Pool
# ============================================================================

class KafkaProducerPool:
    """Connection pool for Kafka producers"""

    def __init__(
        self,
        bootstrap_servers: List[str],
        pool_size: int = 5,
        **producer_kwargs
    ):
        """
        Initialize producer pool.

        Args:
            bootstrap_servers: List of Kafka bootstrap servers
            pool_size: Size of the connection pool
            **producer_kwargs: Additional arguments for KafkaProducer
        """
        self.bootstrap_servers = bootstrap_servers
        self.pool_size = pool_size
        self.producer_kwargs = producer_kwargs
        self.pool: deque = deque()
        self.lock = None
        self.logger = logging.getLogger(__name__)

        self._initialize_pool()

    def _initialize_pool(self):
        """Initialize the connection pool"""
        try:
            for _ in range(self.pool_size):
                producer = KafkaProducer(
                    bootstrap_servers=self.bootstrap_servers,
                    **self.producer_kwargs
                )
                self.pool.append(producer)
            self.logger.info(f"Initialized producer pool with {self.pool_size} connections")
        except Exception as e:
            self.logger.error(f"Failed to initialize producer pool: {e}")
            raise

    @contextmanager
    def get_producer(self):
        """Context manager to get a producer from the pool"""
        producer = None
        try:
            if self.pool:
                producer = self.pool.popleft()
            else:
                producer = KafkaProducer(
                    bootstrap_servers=self.bootstrap_servers,
                    **self.producer_kwargs
                )
            yield producer
        except Exception as e:
            self.logger.error(f"Error getting producer from pool: {e}")
            raise
        finally:
            if producer:
                self.pool.append(producer)

    def close(self):
        """Close all producers in the pool"""
        while self.pool:
            producer = self.pool.popleft()
            try:
                producer.close()
            except Exception as e:
                self.logger.error(f"Error closing producer: {e}")


# ============================================================================
# Batch Processing
# ============================================================================

class MessageBatch:
    """Manages a batch of messages for efficient processing"""

    def __init__(self, max_size: int = 100, timeout_ms: int = 5000):
        """
        Initialize message batch.

        Args:
            max_size: Maximum batch size before forcing flush
            timeout_ms: Maximum time to wait before flushing (milliseconds)
        """
        self.max_size = max_size
        self.timeout_ms = timeout_ms
        self.messages: List[Tuple[str, bytes]] = []
        self.last_flush_time = time.time()

    def add(self, topic: str, message: bytes) -> bool:
        """
        Add message to batch.

        Args:
            topic: Kafka topic
            message: Message bytes

        Returns:
            True if batch should be flushed
        """
        self.messages.append((topic, message))
        return self.should_flush()

    def should_flush(self) -> bool:
        """Check if batch should be flushed"""
        if len(self.messages) >= self.max_size:
            return True

        elapsed_ms = (time.time() - self.last_flush_time) * 1000
        if elapsed_ms >= self.timeout_ms:
            return True

        return False

    def flush(self) -> List[Tuple[str, bytes]]:
        """Flush and return all messages in batch"""
        messages = self.messages[:]
        self.messages.clear()
        self.last_flush_time = time.time()
        return messages

    def size(self) -> int:
        """Get current batch size"""
        return len(self.messages)

    def clear(self):
        """Clear all messages from batch"""
        self.messages.clear()
        self.last_flush_time = time.time()


# ============================================================================
# Enhanced Producer
# ============================================================================

class EnhancedKafkaProducer:
    """Enhanced Kafka producer with error handling, pooling, batching, and metrics"""

    def __init__(self, config: ProducerConfig):
        """
        Initialize enhanced producer.

        Args:
            config: ProducerConfig instance
        """
        self.config = config
        self.logger = LoggerSetup.setup_logger(
            __name__,
            config.log_level,
            config.log_file
        )
        self.metrics = ProducerMetrics(start_time=time.time())

        # Initialize components
        self._init_producer_pool()
        self.batch = MessageBatch(config.batch_size, config.batch_timeout_ms)

        self.logger.info("Enhanced Kafka Producer initialized successfully")

    def _init_producer_pool(self):
        """Initialize the Kafka producer pool"""
        try:
            self.producer_pool = KafkaProducerPool(
                bootstrap_servers=self.config.bootstrap_servers,
                pool_size=self.config.connection_pool_size,
                value_serializer=lambda v: json.dumps(v).encode('utf-8') if isinstance(v, dict) else v,
                acks=self.config.acks,
                compression_type=self.config.compression_type,
                retries=self.config.max_retries,
                retry_backoff_ms=self.config.retry_backoff_ms,
                max_in_flight_requests_per_connection=1,
            )
            self.logger.info("Producer pool initialized")
        except Exception as e:
            self.logger.error(f"Failed to initialize producer pool: {e}")
            raise

    def send(
        self,
        message: Dict[str, Any],
        topic: Optional[str] = None,
        key: Optional[str] = None
    ) -> bool:
        """
        Send a message with error handling and retries.

        Args:
            message: Message dictionary
            topic: Kafka topic (uses config default if not provided)
            key: Message key for partitioning

        Returns:
            True if message was accepted for sending
        """
        topic = topic or self.config.topic
        self.metrics.total_messages += 1

        try:
            # Serialize message
            if isinstance(message, dict):
                message_bytes = json.dumps(message).encode('utf-8')
            else:
                message_bytes = str(message).encode('utf-8')

            self.metrics.total_bytes += len(message_bytes)

            # Add to batch
            should_flush = self.batch.add(topic, message_bytes)

            self.logger.debug(f"Message added to batch (size: {self.batch.size()})")

            if should_flush:
                self.flush()

            return True

        except Exception as e:
            self.metrics.failed_messages += 1
            self.metrics.error_count += 1
            self.logger.error(f"Error preparing message for sending: {e}", exc_info=True)
            return False

    def flush(self) -> int:
        """
        Flush all batched messages to Kafka.

        Returns:
            Number of messages flushed
        """
        messages = self.batch.flush()

        if not messages:
            return 0

        self.metrics.batch_count += 1
        flushed_count = 0

        for attempt in range(self.config.max_retries):
            try:
                with self.producer_pool.get_producer() as producer:
                    futures = []

                    for topic, message_bytes in messages:
                        future = producer.send(topic, value=message_bytes)
                        futures.append((topic, future))

                    # Wait for all sends to complete
                    for topic, future in futures:
                        try:
                            record_metadata = future.get(timeout=10)
                            self.metrics.successful_messages += 1
                            flushed_count += 1
                            self.logger.debug(
                                f"Message sent to {topic} "
                                f"[partition: {record_metadata.partition}, "
                                f"offset: {record_metadata.offset}]"
                            )
                        except KafkaTimeoutError:
                            self.metrics.timeout_errors += 1
                            self.metrics.failed_messages += 1
                            self.logger.error(f"Timeout sending message to {topic}")
                        except KafkaError as e:
                            self.metrics.failed_messages += 1
                            self.metrics.error_count += 1
                            self.logger.error(f"Kafka error sending to {topic}: {e}")

                    if flushed_count > 0:
                        self.logger.info(f"Flushed batch {self.metrics.batch_count}: {flushed_count} messages")
                    break

            except KafkaError as e:
                self.metrics.connection_errors += 1
                if attempt < self.config.max_retries - 1:
                    wait_time = self.config.retry_backoff_ms * (2 ** attempt) / 1000
                    self.logger.warning(
                        f"Kafka error on attempt {attempt + 1}, retrying in {wait_time}s: {e}"
                    )
                    time.sleep(wait_time)
                    self.metrics.retry_count += 1
                else:
                    self.logger.error(f"Failed to send batch after {self.config.max_retries} attempts: {e}")
            except Exception as e:
                self.metrics.error_count += 1
                self.logger.error(f"Unexpected error flushing batch: {e}", exc_info=True)
                break

        return flushed_count

    def get_metrics(self) -> ProducerMetrics:
        """Get current metrics"""
        return self.metrics

    def print_metrics(self):
        """Print formatted metrics"""
        self.metrics.end_time = time.time()
        metrics_dict = self.metrics.to_dict()

        self.logger.info("=" * 70)
        self.logger.info("PRODUCER METRICS")
        self.logger.info("=" * 70)

        for key, value in metrics_dict.items():
            self.logger.info(f"  {key}: {value}")

        self.logger.info("=" * 70)

    def close(self):
        """Close producer and cleanup resources"""
        try:
            # Flush any remaining messages
            self.flush()

            # Close producer pool
            if hasattr(self, 'producer_pool'):
                self.producer_pool.close()

            # Print final metrics
            self.print_metrics()

            self.logger.info("Producer closed successfully")
        except Exception as e:
            self.logger.error(f"Error closing producer: {e}", exc_info=True)

    def __enter__(self):
        """Context manager entry"""
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit"""
        self.close()
        if exc_type:
            self.logger.error(f"Exception in context: {exc_type.__name__}: {exc_val}")


# ============================================================================
# Main Application
# ============================================================================

def create_sample_message(message_id: int) -> Dict[str, Any]:
    """Create a sample message for testing"""
    return {
        'id': message_id,
        'timestamp': datetime.utcnow().isoformat(),
        'data': f'Sample message {message_id}',
        'value': message_id * 10
    }


def main():
    """Main application entry point"""
    # Configuration
    config = ProducerConfig(
        bootstrap_servers=os.environ.get('KAFKA_BOOTSTRAP_SERVERS', 'localhost:9092').split(','),
        topic=os.environ.get('KAFKA_TOPIC', 'entropic-topic'),
        batch_size=int(os.environ.get('BATCH_SIZE', '100')),
        batch_timeout_ms=int(os.environ.get('BATCH_TIMEOUT_MS', '5000')),
        max_retries=int(os.environ.get('MAX_RETRIES', '3')),
        log_level=LogLevel[os.environ.get('LOG_LEVEL', 'INFO').upper()],
        log_file=os.environ.get('LOG_FILE'),
        connection_pool_size=int(os.environ.get('CONNECTION_POOL_SIZE', '5')),
    )

    try:
        with EnhancedKafkaProducer(config) as producer:
            # Send sample messages
            num_messages = int(os.environ.get('NUM_MESSAGES', '1000'))

            for i in range(num_messages):
                message = create_sample_message(i)
                producer.send(message)

                if (i + 1) % 100 == 0:
                    producer.logger.info(f"Sent {i + 1} messages")

            # Final flush
            producer.flush()

    except Exception as e:
        logging.error(f"Fatal error in main: {e}", exc_info=True)
        sys.exit(1)


if __name__ == '__main__':
    main()
