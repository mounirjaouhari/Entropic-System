#!/bin/bash

################################################################################
# Entropic System - Comprehensive Setup Script
# Version: 1.0.0
# Description: Complete system deployment setup including security, frontend,
#              monitoring, kubernetes, and CI/CD configuration
# Author: Mounir Jaouhari
# Date: 2025-12-07
################################################################################

set -euo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
readonly LOG_DIR="${PROJECT_ROOT}/.logs"
readonly CONFIG_DIR="${PROJECT_ROOT}/.config"
readonly TIMESTAMP=$(date +%Y%m%d_%H%M%S)
readonly LOG_FILE="${LOG_DIR}/setup_${TIMESTAMP}.log"

# Version requirements
readonly MIN_NODE_VERSION="16.0.0"
readonly MIN_PYTHON_VERSION="3.8.0"
readonly MIN_DOCKER_VERSION="20.10.0"
readonly MIN_KUBECTL_VERSION="1.20.0"

################################################################################
# Logging Functions
################################################################################

setup_logging() {
    mkdir -p "$LOG_DIR" "$CONFIG_DIR"
    touch "$LOG_FILE"
    echo "Setup started at $(date)" | tee -a "$LOG_FILE"
}

log_info() {
    local message="$1"
    echo -e "${BLUE}[INFO]${NC} $message" | tee -a "$LOG_FILE"
}

log_success() {
    local message="$1"
    echo -e "${GREEN}[SUCCESS]${NC} $message" | tee -a "$LOG_FILE"
}

log_warning() {
    local message="$1"
    echo -e "${YELLOW}[WARNING]${NC} $message" | tee -a "$LOG_FILE"
}

log_error() {
    local message="$1"
    echo -e "${RED}[ERROR]${NC} $message" | tee -a "$LOG_FILE"
}

log_section() {
    local title="$1"
    echo "" | tee -a "$LOG_FILE"
    echo -e "${CYAN}===============================================${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}  $title${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}===============================================${NC}" | tee -a "$LOG_FILE"
}

################################################################################
# System Check Functions
################################################################################

check_os() {
    log_info "Checking operating system..."
    local os_type
    os_type=$(uname -s)
    
    case "$os_type" in
        Linux)
            log_success "Running on Linux"
            return 0
            ;;
        Darwin)
            log_success "Running on macOS"
            return 0
            ;;
        *)
            log_error "Unsupported OS: $os_type"
            return 1
            ;;
    esac
}

check_command() {
    local cmd="$1"
    if command -v "$cmd" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

compare_versions() {
    local current="$1"
    local required="$2"
    printf '%s\n%s' "$required" "$current" | sort -V | head -n 1 | grep -q "^$required$"
}

check_node() {
    log_info "Checking Node.js..."
    if ! check_command node; then
        log_error "Node.js is not installed"
        return 1
    fi
    
    local node_version
    node_version=$(node -v | cut -d'v' -f2)
    
    if compare_versions "$node_version" "$MIN_NODE_VERSION"; then
        log_success "Node.js $node_version (required: $MIN_NODE_VERSION)"
        return 0
    else
        log_error "Node.js version $node_version is below required $MIN_NODE_VERSION"
        return 1
    fi
}

check_python() {
    log_info "Checking Python..."
    if ! check_command python3; then
        log_warning "Python 3 is not installed"
        return 1
    fi
    
    local python_version
    python_version=$(python3 --version | cut -d' ' -f2)
    
    if compare_versions "$python_version" "$MIN_PYTHON_VERSION"; then
        log_success "Python $python_version (required: $MIN_PYTHON_VERSION)"
        return 0
    else
        log_error "Python version $python_version is below required $MIN_PYTHON_VERSION"
        return 1
    fi
}

check_docker() {
    log_info "Checking Docker..."
    if ! check_command docker; then
        log_warning "Docker is not installed"
        return 1
    fi
    
    local docker_version
    docker_version=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
    
    if compare_versions "$docker_version" "$MIN_DOCKER_VERSION"; then
        log_success "Docker $docker_version (required: $MIN_DOCKER_VERSION)"
        return 0
    else
        log_error "Docker version $docker_version is below required $MIN_DOCKER_VERSION"
        return 1
    fi
}

check_kubectl() {
    log_info "Checking kubectl..."
    if ! check_command kubectl; then
        log_warning "kubectl is not installed"
        return 1
    fi
    
    local kubectl_version
    kubectl_version=$(kubectl version --client --short 2>/dev/null | grep -oP '(?<=v)\d+\.\d+\.\d+' | head -1)
    
    if compare_versions "$kubectl_version" "$MIN_KUBECTL_VERSION"; then
        log_success "kubectl $kubectl_version (required: $MIN_KUBECTL_VERSION)"
        return 0
    else
        log_error "kubectl version $kubectl_version is below required $MIN_KUBECTL_VERSION"
        return 1
    fi
}

system_checks() {
    log_section "System Checks"
    
    local checks_passed=true
    
    check_os || checks_passed=false
    check_node || checks_passed=false
    check_python || checks_passed=false
    check_docker || checks_passed=false
    check_kubectl || checks_passed=false
    
    if [ "$checks_passed" = false ]; then
        log_warning "Some system checks failed. Continuing with available tools."
    fi
}

################################################################################
# Security Setup
################################################################################

setup_security() {
    log_section "Security Setup"
    
    log_info "Creating security directories..."
    mkdir -p "${PROJECT_ROOT}/security/certificates"
    mkdir -p "${PROJECT_ROOT}/security/keys"
    mkdir -p "${PROJECT_ROOT}/security/policies"
    
    log_info "Setting restrictive file permissions..."
    chmod 700 "${PROJECT_ROOT}/security/keys"
    chmod 700 "${PROJECT_ROOT}/security/certificates"
    
    # Create .gitignore for sensitive files
    log_info "Creating security .gitignore..."
    cat > "${PROJECT_ROOT}/security/.gitignore" << 'EOF'
# Private Keys
*.key
*.pem
*.p12
*.pfx
private/
*.private.json

# Certificates and CSRs
*.crt
*.cert
*.csr
*.jks

# Environment Files
.env
.env.local
.env.*.local

# SSL/TLS Files
*.cert
*.key
*.csr
*.p7b

# Kubernetes Secrets
secrets.yaml
secrets.json
kubeconfig
EOF
    
    # Create security template files
    log_info "Creating security configuration templates..."
    
    # RBAC configuration
    cat > "${PROJECT_ROOT}/security/rbac-config.yaml" << 'EOF'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: entropic-system-sa
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: entropic-system-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "statefulsets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["batch"]
  resources: ["jobs", "cronjobs"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: entropic-system-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: entropic-system-role
subjects:
- kind: ServiceAccount
  name: entropic-system-sa
  namespace: default
EOF
    
    # Network Policy
    cat > "${PROJECT_ROOT}/security/network-policy.yaml" << 'EOF'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: entropic-system-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: entropic-system
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          role: backend
    ports:
    - protocol: TCP
      port: 5000
  - to:
    - podSelector:
        matchLabels:
          role: database
    ports:
    - protocol: TCP
      port: 5432
EOF
    
    # Pod Security Policy
    cat > "${PROJECT_ROOT}/security/pod-security-policy.yaml" << 'EOF'
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: entropic-system-psp
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'MustRunAs'
    seLinuxOptions:
      level: "s0:c123,c456"
  fsGroup:
    rule: 'MustRunAs'
    ranges:
      - min: 1000
        max: 65535
  readOnlyRootFilesystem: false
EOF
    
    log_success "Security setup completed"
}

################################################################################
# Frontend Setup
################################################################################

setup_frontend() {
    log_section "Frontend Setup"
    
    if ! check_command node; then
        log_warning "Node.js not found. Skipping frontend setup."
        return 1
    fi
    
    log_info "Creating frontend directory structure..."
    mkdir -p "${PROJECT_ROOT}/frontend/src"
    mkdir -p "${PROJECT_ROOT}/frontend/public"
    mkdir -p "${PROJECT_ROOT}/frontend/tests"
    mkdir -p "${PROJECT_ROOT}/frontend/config"
    
    # Create package.json
    log_info "Creating package.json..."
    cat > "${PROJECT_ROOT}/frontend/package.json" << 'EOF'
{
  "name": "entropic-system-frontend",
  "version": "1.0.0",
  "description": "Frontend application for Entropic System",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "axios": "^1.4.0",
    "react-router-dom": "^6.8.0",
    "zustand": "^4.3.7"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^3.1.0",
    "vite": "^4.2.0",
    "vitest": "^0.32.0",
    "@testing-library/react": "^14.0.0",
    "eslint": "^8.36.0",
    "prettier": "^2.8.0"
  },
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "lint": "eslint src",
    "format": "prettier --write src"
  }
}
EOF
    
    # Create Dockerfile for frontend
    log_info "Creating Dockerfile for frontend..."
    cat > "${PROJECT_ROOT}/frontend/Dockerfile" << 'EOF'
# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /app

RUN npm install -g serve

COPY --from=builder /app/dist ./dist

EXPOSE 3000

CMD ["serve", "-s", "dist", "-l", "3000"]
EOF
    
    # Create environment template
    log_info "Creating frontend environment template..."
    cat > "${PROJECT_ROOT}/frontend/.env.example" << 'EOF'
VITE_API_URL=http://localhost:8000
VITE_API_TIMEOUT=30000
VITE_ENVIRONMENT=development
VITE_LOG_LEVEL=debug
VITE_ENABLE_ANALYTICS=false
EOF
    
    # Create ESLint config
    log_info "Creating ESLint configuration..."
    cat > "${PROJECT_ROOT}/frontend/.eslintrc.json" << 'EOF'
{
  "env": {
    "browser": true,
    "es2021": true,
    "node": true
  },
  "extends": [
    "eslint:recommended",
    "plugin:react/recommended"
  ],
  "parserOptions": {
    "ecmaVersion": "latest",
    "sourceType": "module",
    "ecmaFeatures": {
      "jsx": true
    }
  },
  "rules": {
    "react/react-in-jsx-scope": "off",
    "no-unused-vars": ["warn", { "argsIgnorePattern": "^_" }],
    "no-console": ["warn", { "allow": ["warn", "error"] }]
  },
  "settings": {
    "react": {
      "version": "detect"
    }
  }
}
EOF
    
    log_success "Frontend setup completed"
}

################################################################################
# Monitoring Setup
################################################################################

setup_monitoring() {
    log_section "Monitoring Setup"
    
    log_info "Creating monitoring directory structure..."
    mkdir -p "${PROJECT_ROOT}/monitoring/prometheus"
    mkdir -p "${PROJECT_ROOT}/monitoring/grafana"
    mkdir -p "${PROJECT_ROOT}/monitoring/alerts"
    mkdir -p "${PROJECT_ROOT}/monitoring/logs"
    
    # Create Prometheus configuration
    log_info "Creating Prometheus configuration..."
    cat > "${PROJECT_ROOT}/monitoring/prometheus/prometheus.yml" << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'entropic-system'
    environment: 'production'

alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - localhost:9093

rule_files:
  - '/etc/prometheus/rules/*.yml'

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'entropic-system'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['localhost:8000']
    scrape_interval: 30s
    scrape_timeout: 10s

  - job_name: 'kubernetes-apiservers'
    kubernetes_sd_configs:
      - role: endpoints
    scheme: https
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    relabel_configs:
      - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
        action: keep
        regex: default;kubernetes;https

  - job_name: 'kubernetes-nodes'
    kubernetes_sd_configs:
      - role: node
    scheme: https
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token

  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: 'true'
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        target_label: __address__
EOF
    
    # Create alert rules
    log_info "Creating alert rules..."
    cat > "${PROJECT_ROOT}/monitoring/prometheus/alert-rules.yml" << 'EOF'
groups:
  - name: entropic_system_alerts
    interval: 30s
    rules:
      - alert: HighCPUUsage
        expr: 'process_cpu_seconds_total > 0.8'
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is above 80% for 5 minutes"

      - alert: HighMemoryUsage
        expr: 'process_resident_memory_bytes > 1073741824'
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage detected"
          description: "Memory usage is above 1GB"

      - alert: PodRestartingTooOften
        expr: 'rate(kube_pod_container_status_restarts_total[15m]) > 0'
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Pod restarting too frequently"
          description: "Pod {{ $labels.pod }} is restarting frequently"

      - alert: ServiceDown
        expr: 'up{job="entropic-system"} == 0'
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Entropic System service is down"
          description: "Service has been unavailable for 1 minute"
EOF
    
    # Create Grafana dashboard configuration
    log_info "Creating Grafana provisioning..."
    cat > "${PROJECT_ROOT}/monitoring/grafana/datasources.yml" << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
    jsonData:
      timeInterval: 15s

  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100
    editable: true
EOF
    
    # Create docker-compose for monitoring stack
    log_info "Creating monitoring docker-compose..."
    cat > "${PROJECT_ROOT}/monitoring/docker-compose.yml" << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - ./prometheus/alert-rules.yml:/etc/prometheus/rules/alert-rules.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=15d'
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_INSTALL_PLUGINS=grafana-piechart-panel
    volumes:
      - ./grafana/datasources.yml:/etc/grafana/provisioning/datasources/datasources.yml
      - grafana_data:/var/lib/grafana
    depends_on:
      - prometheus
    networks:
      - monitoring

  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml
      - alertmanager_data:/alertmanager
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/alertmanager'
    networks:
      - monitoring

volumes:
  prometheus_data:
  grafana_data:
  alertmanager_data:

networks:
  monitoring:
    driver: bridge
EOF
    
    log_success "Monitoring setup completed"
}

################################################################################
# Kubernetes Setup
################################################################################

setup_kubernetes() {
    log_section "Kubernetes Setup"
    
    if ! check_command kubectl; then
        log_warning "kubectl not found. Skipping Kubernetes setup."
        return 1
    fi
    
    log_info "Creating Kubernetes manifests directory..."
    mkdir -p "${PROJECT_ROOT}/k8s/manifests"
    mkdir -p "${PROJECT_ROOT}/k8s/helm"
    mkdir -p "${PROJECT_ROOT}/k8s/kustomize"
    
    # Create namespace
    log_info "Creating Kubernetes namespace manifest..."
    cat > "${PROJECT_ROOT}/k8s/manifests/namespace.yaml" << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: entropic-system
  labels:
    name: entropic-system
    managed-by: helm
EOF
    
    # Create deployment
    log_info "Creating deployment manifest..."
    cat > "${PROJECT_ROOT}/k8s/manifests/deployment.yaml" << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: entropic-system
  namespace: entropic-system
  labels:
    app: entropic-system
    version: v1
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: entropic-system
  template:
    metadata:
      labels:
        app: entropic-system
      annotations:
        prometheus.io/scrape: 'true'
        prometheus.io/port: '8000'
        prometheus.io/path: '/metrics'
    spec:
      serviceAccountName: entropic-system-sa
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 1000
      
      containers:
      - name: entropic-system
        image: entropic-system:latest
        imagePullPolicy: IfNotPresent
        
        ports:
        - name: http
          containerPort: 8000
          protocol: TCP
        
        env:
        - name: ENVIRONMENT
          valueFrom:
            configMapKeyRef:
              name: entropic-config
              key: environment
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              name: entropic-config
              key: log_level
        
        resources:
          requests:
            cpu: 250m
            memory: 256Mi
          limits:
            cpu: 1000m
            memory: 1Gi
        
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 2
        
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop:
              - ALL
        
        volumeMounts:
        - name: tmp
          mountPath: /tmp
        - name: config
          mountPath: /etc/config
          readOnly: true
      
      volumes:
      - name: tmp
        emptyDir: {}
      - name: config
        configMap:
          name: entropic-config
      
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - entropic-system
              topologyKey: kubernetes.io/hostname
EOF
    
    # Create service
    log_info "Creating service manifest..."
    cat > "${PROJECT_ROOT}/k8s/manifests/service.yaml" << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: entropic-system-service
  namespace: entropic-system
  labels:
    app: entropic-system
spec:
  type: ClusterIP
  selector:
    app: entropic-system
  ports:
  - name: http
    port: 80
    targetPort: 8000
    protocol: TCP
EOF
    
    # Create ConfigMap
    log_info "Creating ConfigMap..."
    cat > "${PROJECT_ROOT}/k8s/manifests/configmap.yaml" << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: entropic-config
  namespace: entropic-system
data:
  environment: "production"
  log_level: "info"
  app_name: "entropic-system"
  version: "1.0.0"
EOF
    
    # Create HPA
    log_info "Creating Horizontal Pod Autoscaler..."
    cat > "${PROJECT_ROOT}/k8s/manifests/hpa.yaml" << 'EOF'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: entropic-system-hpa
  namespace: entropic-system
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: entropic-system
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 30
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
EOF
    
    log_success "Kubernetes setup completed"
}

################################################################################
# CI/CD Setup
################################################################################

setup_cicd() {
    log_section "CI/CD Setup"
    
    log_info "Creating CI/CD directory structure..."
    mkdir -p "${PROJECT_ROOT}/.github/workflows"
    mkdir -p "${PROJECT_ROOT}/ci"
    mkdir -p "${PROJECT_ROOT}/ci/scripts"
    
    # Create GitHub Actions workflow for testing
    log_info "Creating GitHub Actions test workflow..."
    cat > "${PROJECT_ROOT}/.github/workflows/test.yml" << 'EOF'
name: Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16.x, 18.x]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run linter
      run: npm run lint
    
    - name: Run tests
      run: npm test
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        files: ./coverage/lcov.info
        flags: unittests
        fail_ci_if_error: true
EOF
    
    # Create GitHub Actions workflow for building
    log_info "Creating GitHub Actions build workflow..."
    cat > "${PROJECT_ROOT}/.github/workflows/build.yml" << 'EOF'
name: Build

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    permissions:
      contents: write
      packages: write
    
    steps:
    - uses: actions/checkout@v3
      with:
        fetch-depth: 0
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Build and push
      uses: docker/build-push-action@v4
      with:
        context: .
        push: false
        tags: entropic-system:latest
        outputs: type=docker,dest=/tmp/image.tar
    
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: 'entropic-system:latest'
        format: 'sarif'
        output: 'trivy-results.sarif'
    
    - name: Upload Trivy results to GitHub Security tab
      uses: github/codeql-action/upload-sarif@v2
      if: always()
      with:
        sarif_file: 'trivy-results.sarif'
EOF
    
    # Create GitHub Actions workflow for deployment
    log_info "Creating GitHub Actions deploy workflow..."
    cat > "${PROJECT_ROOT}/.github/workflows/deploy.yml" << 'EOF'
name: Deploy

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    permissions:
      contents: read
      packages: write
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Log in to Container Registry
      uses: docker/login-action@v2
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v4
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=semver,pattern={{version}}
          type=semver,pattern={{major}}.{{minor}}
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
    
    - name: Deploy to Kubernetes
      run: |
        echo "Deploying to Kubernetes..."
        kubectl apply -f k8s/manifests/
EOF
    
    # Create build script
    log_info "Creating build script..."
    cat > "${PROJECT_ROOT}/ci/scripts/build.sh" << 'EOF'
#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo "Building application..."
cd "$PROJECT_ROOT"

# Build frontend
if [ -d "frontend" ]; then
    echo "Building frontend..."
    cd frontend
    npm ci
    npm run build
    cd ..
fi

# Build Docker image
echo "Building Docker image..."
docker build -t entropic-system:latest -t entropic-system:"${CI_COMMIT_SHA:0:8}" .

echo "Build completed successfully"
EOF
    
    # Create test script
    log_info "Creating test script..."
    cat > "${PROJECT_ROOT}/ci/scripts/test.sh" << 'EOF'
#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo "Running tests..."
cd "$PROJECT_ROOT"

# Run frontend tests
if [ -d "frontend" ]; then
    echo "Running frontend tests..."
    cd frontend
    npm ci
    npm test
    cd ..
fi

# Run linting
if [ -d "frontend" ]; then
    echo "Running ESLint..."
    cd frontend
    npm run lint || true
    cd ..
fi

echo "Tests completed"
EOF
    
    # Create deploy script
    log_info "Creating deploy script..."
    cat > "${PROJECT_ROOT}/ci/scripts/deploy.sh" << 'EOF'
#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

ENVIRONMENT="${1:-production}"
NAMESPACE="${2:-entropic-system}"

echo "Deploying to $ENVIRONMENT..."
cd "$PROJECT_ROOT"

# Create namespace
kubectl create namespace "$NAMESPACE" || true

# Apply manifests
kubectl apply -f k8s/manifests/ -n "$NAMESPACE"

# Wait for deployment
echo "Waiting for deployment to be ready..."
kubectl rollout status deployment/entropic-system -n "$NAMESPACE" --timeout=5m

echo "Deployment completed successfully"
EOF
    
    # Make scripts executable
    chmod +x "${PROJECT_ROOT}/ci/scripts"/*.sh
    
    # Create GitLab CI configuration (optional)
    log_info "Creating GitLab CI configuration..."
    cat > "${PROJECT_ROOT}/.gitlab-ci.yml" << 'EOF'
stages:
  - test
  - build
  - deploy

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"

test:
  stage: test
  image: node:18-alpine
  script:
    - npm ci
    - npm run lint
    - npm test
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t entropic-system:$CI_COMMIT_SHA .
    - docker tag entropic-system:$CI_COMMIT_SHA entropic-system:latest
  only:
    - main

deploy:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl apply -f k8s/manifests/
    - kubectl rollout status deployment/entropic-system
  environment:
    name: production
  only:
    - main
  when: manual
EOF
    
    log_success "CI/CD setup completed"
}

################################################################################
# Docker Setup
################################################################################

setup_docker() {
    log_section "Docker Setup"
    
    log_info "Creating Dockerfile..."
    cat > "${PROJECT_ROOT}/Dockerfile" << 'EOF'
# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build || true

# Production stage
FROM node:18-alpine

WORKDIR /app

RUN apk add --no-cache dumb-init

RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

COPY --from=builder --chown=appuser:appuser /app/node_modules ./node_modules
COPY --chown=appuser:appuser . .

USER appuser

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:8000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

EXPOSE 8000

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]
EOF
    
    # Create docker-compose
    log_info "Creating docker-compose.yml..."
    cat > "${PROJECT_ROOT}/docker-compose.yml" << 'EOF'
version: '3.8'

services:
  entropic-system:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: entropic-system
    ports:
      - "8000:8000"
    environment:
      NODE_ENV: production
      LOG_LEVEL: info
    volumes:
      - ./config:/app/config:ro
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    restart: unless-stopped
    networks:
      - entropic-network

  redis:
    image: redis:7-alpine
    container_name: entropic-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped
    networks:
      - entropic-network

volumes:
  redis_data:

networks:
  entropic-network:
    driver: bridge
EOF
    
    # Create dockerignore
    log_info "Creating .dockerignore..."
    cat > "${PROJECT_ROOT}/.dockerignore" << 'EOF'
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.env.*
.DS_Store
dist
build
coverage
.logs
.config
k8s
ci
monitoring
security
.github
.gitlab-ci.yml
EOF
    
    log_success "Docker setup completed"
}

################################################################################
# Configuration Setup
################################################################################

setup_configuration() {
    log_section "Configuration Setup"
    
    log_info "Creating configuration files..."
    
    # Create main config template
    cat > "${CONFIG_DIR}/config.example.json" << 'EOF'
{
  "app": {
    "name": "Entropic System",
    "version": "1.0.0",
    "environment": "production",
    "port": 8000,
    "logLevel": "info"
  },
  "security": {
    "enableSSL": true,
    "enableCSRF": true,
    "enableCORS": true,
    "corsOrigins": ["http://localhost:3000"]
  },
  "database": {
    "host": "localhost",
    "port": 5432,
    "name": "entropic_db",
    "poolSize": 10,
    "timeout": 5000
  },
  "redis": {
    "host": "localhost",
    "port": 6379,
    "db": 0,
    "ttl": 3600
  },
  "monitoring": {
    "metricsEnabled": true,
    "tracingEnabled": true,
    "samplingRate": 0.1
  }
}
EOF
    
    # Create environment template
    cat > "${CONFIG_DIR}/.env.example" << 'EOF'
# Application
NODE_ENV=production
LOG_LEVEL=info
PORT=8000

# Security
API_KEY=your_api_key_here
JWT_SECRET=your_jwt_secret_here
SESSION_SECRET=your_session_secret_here

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/entropic_db

# Redis
REDIS_URL=redis://localhost:6379

# Monitoring
PROMETHEUS_ENABLED=true
GRAFANA_URL=http://localhost:3000

# External Services
SLACK_WEBHOOK_URL=
DATADOG_API_KEY=
EOF
    
    log_success "Configuration setup completed"
}

################################################################################
# Git Setup
################################################################################

setup_git() {
    log_section "Git Setup"
    
    if ! check_command git; then
        log_warning "Git not found. Skipping Git setup."
        return 1
    fi
    
    log_info "Setting up Git hooks..."
    mkdir -p "${PROJECT_ROOT}/.git/hooks"
    
    # Pre-commit hook
    cat > "${PROJECT_ROOT}/.git/hooks/pre-commit" << 'EOF'
#!/bin/bash

echo "Running pre-commit checks..."

# Run linting
if command -v npm &> /dev/null; then
    echo "Running ESLint..."
    npm run lint || exit 1
fi

echo "Pre-commit checks passed"
exit 0
EOF
    
    chmod +x "${PROJECT_ROOT}/.git/hooks/pre-commit"
    
    # Create .gitattributes
    log_info "Creating .gitattributes..."
    cat > "${PROJECT_ROOT}/.gitattributes" << 'EOF'
* text=auto
*.js text eol=lf
*.json text eol=lf
*.yaml text eol=lf
*.yml text eol=lf
*.sh text eol=lf
*.md text eol=lf
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
EOF
    
    log_success "Git setup completed"
}

################################################################################
# Documentation Setup
################################################################################

setup_documentation() {
    log_section "Documentation Setup"
    
    log_info "Creating documentation structure..."
    mkdir -p "${PROJECT_ROOT}/docs"
    mkdir -p "${PROJECT_ROOT}/docs/guides"
    mkdir -p "${PROJECT_ROOT}/docs/api"
    
    # Create main README
    cat > "${PROJECT_ROOT}/docs/README.md" << 'EOF'
# Entropic System Documentation

Welcome to the Entropic System documentation. This guide covers setup, deployment, and operation.

## Table of Contents

- [Getting Started](./getting-started.md)
- [Architecture](./architecture.md)
- [API Reference](./api/README.md)
- [Deployment Guide](./guides/deployment.md)
- [Monitoring](./guides/monitoring.md)
- [Security](./guides/security.md)
- [Troubleshooting](./guides/troubleshooting.md)

## Quick Start

1. Clone the repository
2. Run `./scripts/setup.sh`
3. Configure environment variables
4. Deploy using Kubernetes or Docker

## Support

For issues and questions, please create an issue on GitHub.
EOF
    
    log_success "Documentation setup completed"
}

################################################################################
# Post-Setup Validation
################################################################################

validate_setup() {
    log_section "Setup Validation"
    
    local validation_passed=true
    
    # Check if required directories exist
    local required_dirs=(
        "security"
        "frontend"
        "monitoring"
        "k8s"
        ".github/workflows"
        "docs"
    )
    
    log_info "Checking directory structure..."
    for dir in "${required_dirs[@]}"; do
        if [ -d "${PROJECT_ROOT}/$dir" ]; then
            log_success "✓ Directory $dir exists"
        else
            log_warning "✗ Directory $dir not found"
            validation_passed=false
        fi
    done
    
    # Check if key files exist
    local required_files=(
        "Dockerfile"
        "docker-compose.yml"
        ".github/workflows/test.yml"
        ".github/workflows/build.yml"
        "k8s/manifests/deployment.yaml"
        "monitoring/prometheus/prometheus.yml"
        "security/rbac-config.yaml"
    )
    
    log_info "Checking critical files..."
    for file in "${required_files[@]}"; do
        if [ -f "${PROJECT_ROOT}/$file" ]; then
            log_success "✓ File $file created"
        else
            log_warning "✗ File $file not found"
        fi
    done
    
    if [ "$validation_passed" = true ]; then
        log_success "Setup validation passed"
    else
        log_warning "Some checks failed but setup is mostly complete"
    fi
}

################################################################################
# Main Execution
################################################################################

main() {
    setup_logging
    
    echo -e "${CYAN}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║        Entropic System - Comprehensive Setup Script            ║
║                    Version 1.0.0                               ║
╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    log_info "Starting setup process..."
    log_info "Project root: $PROJECT_ROOT"
    log_info "Log file: $LOG_FILE"
    
    # Run setup sections
    system_checks
    setup_security
    setup_frontend
    setup_monitoring
    setup_kubernetes
    setup_docker
    setup_cicd
    setup_configuration
    setup_git
    setup_documentation
    validate_setup
    
    # Final summary
    log_section "Setup Complete"
    echo -e "${GREEN}" | tee -a "$LOG_FILE"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║              Setup Completed Successfully!                     ║
╚════════════════════════════════════════════════════════════════╝

Next Steps:
1. Review and update configuration files in .config/
2. Set up environment variables from .env.example files
3. Configure security credentials in security/ directory
4. Customize Kubernetes manifests for your environment
5. Run: docker-compose up -d (for local development)
6. Run: kubectl apply -f k8s/manifests/ (for Kubernetes)

Documentation:
- Full documentation: ./docs/
- API Reference: ./docs/api/
- Deployment Guide: ./docs/guides/deployment.md

For more information, visit the project wiki or documentation.
EOF
    echo -e "${NC}" | tee -a "$LOG_FILE"
    
    log_info "Setup log saved to: $LOG_FILE"
}

# Handle script interruption
trap 'log_error "Setup interrupted"; exit 130' INT TERM

# Execute main function
main "$@"
exit $?
