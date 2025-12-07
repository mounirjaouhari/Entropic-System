#!/bin/bash

################################################################################
# SHARED UTILITIES MODULE FOR ENTROPIC-SYSTEM VALIDATORS
# Provides common logging, error handling, and utility functions
# Date: 2025-12-07
################################################################################

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOG_DIR="${PROJECT_ROOT}/.validation-logs"
BACKUP_DIR="${PROJECT_ROOT}/.validation-backups"
ROLLBACK_LOG="${LOG_DIR}/rollback.log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CURRENT_LOG="${LOG_DIR}/validation_${TIMESTAMP}.log"

################################################################################
# INITIALIZATION FUNCTIONS
################################################################################

init_logging() {
    mkdir -p "${LOG_DIR}" "${BACKUP_DIR}"
    touch "${CURRENT_LOG}"
    echo "=== Validation Session Started: $(date '+%Y-%m-%d %H:%M:%S') ===" > "${CURRENT_LOG}"
}

################################################################################
# LOGGING FUNCTIONS
################################################################################

log_info() {
    local message="$1"
    echo -e "${BLUE}[INFO]${NC} ${message}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] ${message}" >> "${CURRENT_LOG}"
}

log_success() {
    local message="$1"
    echo -e "${GREEN}[SUCCESS]${NC} ${message}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] ${message}" >> "${CURRENT_LOG}"
}

log_warning() {
    local message="$1"
    echo -e "${YELLOW}[WARNING]${NC} ${message}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARNING] ${message}" >> "${CURRENT_LOG}"
}

log_error() {
    local message="$1"
    echo -e "${RED}[ERROR]${NC} ${message}" >&2
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] ${message}" >> "${CURRENT_LOG}"
}

log_debug() {
    local message="$1"
    if [[ "${DEBUG_MODE:-false}" == "true" ]]; then
        echo -e "${CYAN}[DEBUG]${NC} ${message}"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DEBUG] ${message}" >> "${CURRENT_LOG}"
    fi
}

################################################################################
# VALIDATION FUNCTIONS
################################################################################

check_command_exists() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        log_error "Command not found: $cmd"
        return 1
    fi
    log_debug "Command found: $cmd"
    return 0
}

check_file_exists() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        log_error "File not found: $file"
        return 1
    fi
    log_debug "File exists: $file"
    return 0
}

check_directory_exists() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        log_error "Directory not found: $dir"
        return 1
    fi
    log_debug "Directory exists: $dir"
    return 0
}

check_port_open() {
    local port="$1"
    local host="${2:-localhost}"
    
    if nc -z "$host" "$port" 2>/dev/null; then
        log_debug "Port $port is open on $host"
        return 0
    else
        log_error "Port $port is not open on $host"
        return 1
    fi
}

check_service_running() {
    local service="$1"
    
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        log_debug "Service $service is running"
        return 0
    else
        log_error "Service $service is not running"
        return 1
    fi
}

################################################################################
# FILE BACKUP AND RESTORE FUNCTIONS
################################################################################

backup_file() {
    local file="$1"
    local backup_name="${2:-$(basename "$file")}"
    
    if [[ ! -f "$file" ]]; then
        log_warning "File to backup does not exist: $file"
        return 1
    fi
    
    local backup_path="${BACKUP_DIR}/${TIMESTAMP}_${backup_name}"
    cp -p "$file" "$backup_path"
    log_info "Backed up: $file -> $backup_path"
    echo "$backup_path"
}

restore_file() {
    local backup_path="$1"
    local original_path="$2"
    
    if [[ ! -f "$backup_path" ]]; then
        log_error "Backup file not found: $backup_path"
        return 1
    fi
    
    cp -p "$backup_path" "$original_path"
    log_success "Restored: $original_path from $backup_path"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] RESTORED: $original_path from $backup_path" >> "${ROLLBACK_LOG}"
}

################################################################################
# DOCKER FUNCTIONS
################################################################################

check_docker_running() {
    if ! docker info &>/dev/null; then
        log_error "Docker daemon is not running"
        return 1
    fi
    log_debug "Docker daemon is running"
    return 0
}

check_container_exists() {
    local container="$1"
    if docker ps -a --format '{{.Names}}' | grep -q "^${container}$"; then
        log_debug "Container exists: $container"
        return 0
    else
        log_error "Container not found: $container"
        return 1
    fi
}

check_container_running() {
    local container="$1"
    if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        log_debug "Container is running: $container"
        return 0
    else
        log_error "Container is not running: $container"
        return 1
    fi
}

restart_container() {
    local container="$1"
    log_info "Restarting container: $container"
    docker restart "$container"
    sleep 2
    if check_container_running "$container"; then
        log_success "Container restarted successfully: $container"
        return 0
    else
        log_error "Failed to restart container: $container"
        return 1
    fi
}

get_container_logs() {
    local container="$1"
    local lines="${2:-50}"
    docker logs --tail "$lines" "$container" 2>&1
}

################################################################################
# MYSQL FUNCTIONS
################################################################################

mysql_connect() {
    local host="$1"
    local user="$2"
    local password="$3"
    local database="${4:-mysql}"
    
    if mysql -h "$host" -u "$user" -p"$password" "$database" -e "SELECT 1" &>/dev/null; then
        log_debug "MySQL connection successful: $host"
        return 0
    else
        log_error "MySQL connection failed: $host"
        return 1
    fi
}

mysql_execute_query() {
    local host="$1"
    local user="$2"
    local password="$3"
    local query="$4"
    local database="${5:-mysql}"
    
    mysql -h "$host" -u "$user" -p"$password" "$database" -e "$query"
}

check_mysql_binlog() {
    local host="$1"
    local user="$2"
    local password="$3"
    
    local result=$(mysql_execute_query "$host" "$user" "$password" "SHOW VARIABLES LIKE 'log_bin';" | grep -i on)
    if [[ -n "$result" ]]; then
        log_debug "MySQL binary logging is enabled"
        return 0
    else
        log_error "MySQL binary logging is disabled"
        return 1
    fi
}

################################################################################
# KAFKA FUNCTIONS
################################################################################

check_kafka_broker() {
    local broker="$1"
    if kafka-broker-api-versions.sh --bootstrap-server "$broker" &>/dev/null; then
        log_debug "Kafka broker is accessible: $broker"
        return 0
    else
        log_error "Kafka broker is not accessible: $broker"
        return 1
    fi
}

list_kafka_topics() {
    local broker="$1"
    kafka-topics.sh --bootstrap-server "$broker" --list
}

create_kafka_topic() {
    local broker="$1"
    local topic="$2"
    local partitions="${3:-3}"
    local replication="${4:-1}"
    
    log_info "Creating Kafka topic: $topic"
    kafka-topics.sh --bootstrap-server "$broker" --create \
        --topic "$topic" \
        --partitions "$partitions" \
        --replication-factor "$replication" \
        --if-not-exists
    log_success "Topic created: $topic"
}

################################################################################
# HTTP REQUEST FUNCTIONS
################################################################################

check_http_endpoint() {
    local url="$1"
    local expected_code="${2:-200}"
    
    local response_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    
    if [[ "$response_code" == "$expected_code" ]]; then
        log_debug "HTTP endpoint healthy: $url ($response_code)"
        return 0
    else
        log_error "HTTP endpoint unhealthy: $url (expected: $expected_code, got: $response_code)"
        return 1
    fi
}

################################################################################
# CONFIGURATION FUNCTIONS
################################################################################

read_env_file() {
    local env_file="$1"
    
    if [[ ! -f "$env_file" ]]; then
        log_error "Environment file not found: $env_file"
        return 1
    fi
    
    set -a
    source "$env_file"
    set +a
    log_debug "Loaded environment from: $env_file"
}

validate_config_value() {
    local key="$1"
    local value="$2"
    
    if [[ -z "$value" ]]; then
        log_error "Configuration value missing for: $key"
        return 1
    fi
    log_debug "Configuration valid: $key"
    return 0
}

################################################################################
# EXECUTION TRACKING
################################################################################

EXECUTED_FIXES=()
add_executed_fix() {
    local fix="$1"
    EXECUTED_FIXES+=("$fix")
    log_info "Executed fix: $fix"
}

print_summary() {
    local phase="$1"
    local total_errors="${2:-0}"
    local fixed_errors="${3:-0}"
    
    echo ""
    echo -e "${CYAN}======================================${NC}"
    echo -e "${CYAN}  VALIDATION SUMMARY - PHASE: $phase${NC}"
    echo -e "${CYAN}======================================${NC}"
    echo -e "Total Errors Found: ${RED}$total_errors${NC}"
    echo -e "Errors Fixed: ${GREEN}$fixed_errors${NC}"
    echo -e "Success Rate: $(( fixed_errors * 100 / (total_errors > 0 ? total_errors : 1) ))%"
    echo ""
    
    if [[ ${#EXECUTED_FIXES[@]} -gt 0 ]]; then
        echo -e "${CYAN}Fixes Applied:${NC}"
        for fix in "${EXECUTED_FIXES[@]}"; do
            echo -e "  ${GREEN}✓${NC} $fix"
        done
    fi
    echo ""
}

################################################################################
# CLEANUP AND FINALIZATION
################################################################################

cleanup() {
    log_info "Cleaning up temporary files..."
    # Add cleanup logic as needed
}

trap cleanup EXIT

print_summary "$@"
