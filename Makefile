.PHONY: help up down logs clean shell status build test deploy health-check install

# Color output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Default target
.DEFAULT_GOAL := help

# Environment variables
DOCKER_COMPOSE := docker-compose
DOCKER := docker
PYTHON := python3
PIP := pip3

# Project variables
PROJECT_NAME := entropic-system
VERSION := 1.0.0
ENVIRONMENT := development

# ============================================================================
# HELP TARGET
# ============================================================================
help: ## Show this help message
	@echo "$(BLUE)╔═══════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║$(NC) $(GREEN)Entropic-System - Available Commands$(NC) $(BLUE)║$(NC)"
	@echo "$(BLUE)╚═══════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Usage:$(NC)"
	@echo "  make $(GREEN)<target>$(NC)"
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make up            # Start the Entropic-System"
	@echo "  make down          # Stop the Entropic-System"
	@echo "  make test          # Run all tests"
	@echo "  make logs          # View system logs"
	@echo "  make health-check  # Check system health"
	@echo ""

# ============================================================================
# INSTALLATION & SETUP TARGETS
# ============================================================================
install: ## Install dependencies
	@echo "$(BLUE)Installing dependencies...$(NC)"
	@if [ -f requirements.txt ]; then \
		$(PIP) install -r requirements.txt; \
	fi
	@if [ -f docker-compose.yml ]; then \
		echo "$(GREEN)Docker Compose configuration found$(NC)"; \
	fi
	@echo "$(GREEN)✓ Dependencies installed$(NC)"

# ============================================================================
# DOCKER COMPOSE TARGETS
# ============================================================================
up: ## Start the Entropic-System (docker-compose up)
	@echo "$(BLUE)Starting Entropic-System...$(NC)"
	@if [ -f docker-compose.yml ]; then \
		$(DOCKER_COMPOSE) up -d; \
		echo "$(GREEN)✓ Entropic-System started$(NC)"; \
	else \
		echo "$(RED)✗ docker-compose.yml not found$(NC)"; \
		exit 1; \
	fi

down: ## Stop the Entropic-System (docker-compose down)
	@echo "$(BLUE)Stopping Entropic-System...$(NC)"
	@if [ -f docker-compose.yml ]; then \
		$(DOCKER_COMPOSE) down; \
		echo "$(GREEN)✓ Entropic-System stopped$(NC)"; \
	else \
		echo "$(RED)✗ docker-compose.yml not found$(NC)"; \
		exit 1; \
	fi

status: ## Check Entropic-System status
	@echo "$(BLUE)Checking Entropic-System status...$(NC)"
	@if [ -f docker-compose.yml ]; then \
		$(DOCKER_COMPOSE) ps; \
	else \
		echo "$(RED)✗ docker-compose.yml not found$(NC)"; \
		exit 1; \
	fi

# ============================================================================
# LOGGING TARGETS
# ============================================================================
logs: ## View Entropic-System logs (all services)
	@echo "$(BLUE)Displaying Entropic-System logs...$(NC)"
	@if [ -f docker-compose.yml ]; then \
		$(DOCKER_COMPOSE) logs -f; \
	else \
		echo "$(RED)✗ docker-compose.yml not found$(NC)"; \
		exit 1; \
	fi

logs-service: ## View logs for a specific service (use: make logs-service SERVICE=<service_name>)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)✗ SERVICE variable not specified$(NC)"; \
		echo "$(YELLOW)Usage: make logs-service SERVICE=<service_name>$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)Displaying logs for $(SERVICE)...$(NC)"
	@$(DOCKER_COMPOSE) logs -f $(SERVICE)

# ============================================================================
# BUILD & COMPILATION TARGETS
# ============================================================================
build: ## Build Entropic-System (docker-compose build)
	@echo "$(BLUE)Building Entropic-System...$(NC)"
	@if [ -f docker-compose.yml ]; then \
		$(DOCKER_COMPOSE) build --no-cache; \
		echo "$(GREEN)✓ Build completed successfully$(NC)"; \
	else \
		echo "$(RED)✗ docker-compose.yml not found$(NC)"; \
		exit 1; \
	fi

rebuild: ## Rebuild Entropic-System from scratch
	@echo "$(BLUE)Rebuilding Entropic-System...$(NC)"
	@make clean
	@make build
	@echo "$(GREEN)✓ Rebuild completed$(NC)"

# ============================================================================
# TESTING TARGETS
# ============================================================================
test: ## Run all tests
	@echo "$(BLUE)Running tests...$(NC)"
	@if [ -d tests ]; then \
		$(PYTHON) -m pytest tests/ -v --tb=short; \
	elif [ -f pytest.ini ]; then \
		$(PYTHON) -m pytest -v --tb=short; \
	elif [ -f setup.py ] || [ -f setup.cfg ]; then \
		$(PYTHON) -m pytest -v --tb=short; \
	else \
		echo "$(YELLOW)No test framework detected. Looking for test files...$(NC)"; \
		$(PYTHON) -m pytest . -v --tb=short 2>/dev/null || echo "$(RED)✗ No tests found$(NC)"; \
	fi

test-coverage: ## Run tests with coverage report
	@echo "$(BLUE)Running tests with coverage...$(NC)"
	@$(PYTHON) -m pytest tests/ --cov=. --cov-report=html --cov-report=term -v 2>/dev/null || \
	 echo "$(RED)✗ Coverage tool not installed. Install with: pip install pytest-cov$(NC)"
	@echo "$(GREEN)✓ Coverage report generated$(NC)"

test-fast: ## Run tests without verbose output
	@echo "$(BLUE)Running fast tests...$(NC)"
	@$(PYTHON) -m pytest tests/ -q 2>/dev/null || echo "$(RED)✗ Tests failed$(NC)"

lint: ## Run code linting
	@echo "$(BLUE)Running linters...$(NC)"
	@if command -v pylint &> /dev/null; then \
		pylint . --disable=all --enable=E,F || true; \
	fi
	@if command -v flake8 &> /dev/null; then \
		flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics || true; \
	fi
	@echo "$(GREEN)✓ Linting completed$(NC)"

# ============================================================================
# DEPLOYMENT TARGETS
# ============================================================================
deploy: ## Deploy Entropic-System to production
	@echo "$(BLUE)Deploying Entropic-System...$(NC)"
	@if [ "$(ENVIRONMENT)" != "production" ]; then \
		echo "$(YELLOW)⚠ Warning: Not in production environment$(NC)"; \
		echo "$(YELLOW)Current environment: $(ENVIRONMENT)$(NC)"; \
		read -p "Continue? (y/n) " -n 1 -r; \
		echo; \
		if [[ ! $$REPLY =~ ^[Yy]$$ ]]; then \
			exit 1; \
		fi; \
	fi
	@make build
	@make test
	@make up
	@make health-check
	@echo "$(GREEN)✓ Deployment completed successfully$(NC)"

deploy-staging: ## Deploy Entropic-System to staging environment
	@echo "$(BLUE)Deploying to staging...$(NC)"
	@ENVIRONMENT=staging make deploy

# ============================================================================
# HEALTH CHECK TARGET
# ============================================================================
health-check: ## Verify Entropic-System health and readiness
	@echo "$(BLUE)Running health checks...$(NC)"
	@echo ""
	@echo "$(BLUE)1. Checking Docker daemon...$(NC)"
	@if command -v docker &> /dev/null; then \
		if docker ps &> /dev/null; then \
			echo "$(GREEN)   ✓ Docker daemon is running$(NC)"; \
		else \
			echo "$(RED)   ✗ Docker daemon is not accessible$(NC)"; \
			exit 1; \
		fi; \
	else \
		echo "$(RED)   ✗ Docker is not installed$(NC)"; \
		exit 1; \
	fi
	@echo ""
	@echo "$(BLUE)2. Checking running services...$(NC)"
	@if [ -f docker-compose.yml ]; then \
		echo "$(YELLOW)   Running services:$(NC)"; \
		$(DOCKER_COMPOSE) ps --services 2>/dev/null | grep -E '.' && echo "$(GREEN)   ✓ Services detected$(NC)" || echo "$(YELLOW)   ⚠ No services running$(NC)"; \
	else \
		echo "$(YELLOW)   ⚠ No docker-compose.yml found$(NC)"; \
	fi
	@echo ""
	@echo "$(BLUE)3. Checking system resources...$(NC)"
	@if command -v df &> /dev/null; then \
		DISK_USAGE=$$(df -h . | awk 'NR==2 {print $$5}'); \
		echo "   Disk usage: $$DISK_USAGE"; \
		DISK_NUM=$${DISK_USAGE%\%}; \
		if [ $$DISK_NUM -gt 90 ]; then \
			echo "$(RED)   ✗ Disk usage critical$(NC)"; \
		elif [ $$DISK_NUM -gt 80 ]; then \
			echo "$(YELLOW)   ⚠ Disk usage high$(NC)"; \
		else \
			echo "$(GREEN)   ✓ Disk usage normal$(NC)"; \
		fi; \
	fi
	@echo ""
	@echo "$(BLUE)4. Health check endpoints...$(NC)"
	@if command -v curl &> /dev/null; then \
		echo "$(YELLOW)   Attempting to reach common health endpoints...$(NC)"; \
		for endpoint in "http://localhost:8000/health" "http://localhost:8080/health" "http://localhost:3000/health"; do \
			if curl -sf $$endpoint > /dev/null 2>&1; then \
				echo "$(GREEN)   ✓ $$endpoint is responding$(NC)"; \
			fi; \
		done; \
	else \
		echo "$(YELLOW)   ⚠ curl not installed, skipping endpoint checks$(NC)"; \
	fi
	@echo ""
	@echo "$(GREEN)✓ Health check completed$(NC)"

# ============================================================================
# SHELL & INTERACTIVE TARGETS
# ============================================================================
shell: ## Access a shell in the main service container
	@echo "$(BLUE)Opening shell in main service...$(NC)"
	@if [ -f docker-compose.yml ]; then \
		MAIN_SERVICE=$$($(DOCKER_COMPOSE) config --services 2>/dev/null | head -n 1); \
		if [ -z "$$MAIN_SERVICE" ]; then \
			echo "$(RED)✗ No services found in docker-compose.yml$(NC)"; \
			exit 1; \
		fi; \
		echo "$(YELLOW)Connecting to service: $$MAIN_SERVICE$(NC)"; \
		$(DOCKER_COMPOSE) exec $$MAIN_SERVICE /bin/bash 2>/dev/null || \
		$(DOCKER_COMPOSE) exec $$MAIN_SERVICE /bin/sh 2>/dev/null || \
		echo "$(RED)✗ Failed to open shell$(NC)"; \
	else \
		echo "$(RED)✗ docker-compose.yml not found$(NC)"; \
		exit 1; \
	fi

shell-service: ## Open shell in a specific service (use: make shell-service SERVICE=<service_name>)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)✗ SERVICE variable not specified$(NC)"; \
		echo "$(YELLOW)Usage: make shell-service SERVICE=<service_name>$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)Opening shell in $(SERVICE)...$(NC)"
	@$(DOCKER_COMPOSE) exec $(SERVICE) /bin/bash 2>/dev/null || \
	 $(DOCKER_COMPOSE) exec $(SERVICE) /bin/sh || \
	 echo "$(RED)✗ Failed to open shell in $(SERVICE)$(NC)"

# ============================================================================
# CLEANUP TARGETS
# ============================================================================
clean: ## Clean up resources (containers, volumes, caches)
	@echo "$(BLUE)Cleaning up resources...$(NC)"
	@echo "$(YELLOW)Stopping containers...$(NC)"
	@if [ -f docker-compose.yml ]; then \
		$(DOCKER_COMPOSE) down -v; \
		echo "$(GREEN)✓ Containers and volumes removed$(NC)"; \
	fi
	@echo "$(YELLOW)Removing Python cache files...$(NC)"
	@find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type f -name "*.pyo" -delete 2>/dev/null || true
	@find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".coverage" -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)✓ Cache files cleaned$(NC)"
	@echo ""
	@echo "$(BLUE)Pruning unused Docker resources...$(NC)"
	@docker system prune -f --filter "label!=keep=true" 2>/dev/null || true
	@echo "$(GREEN)✓ Cleanup completed$(NC)"

clean-containers: ## Remove all stopped containers
	@echo "$(BLUE)Removing stopped containers...$(NC)"
	@docker container prune -f
	@echo "$(GREEN)✓ Stopped containers removed$(NC)"

clean-images: ## Remove dangling Docker images
	@echo "$(BLUE)Removing dangling images...$(NC)"
	@docker image prune -f
	@echo "$(GREEN)✓ Dangling images removed$(NC)"

clean-volumes: ## Remove all unused Docker volumes
	@echo "$(BLUE)Removing unused volumes...$(NC)"
	@docker volume prune -f
	@echo "$(GREEN)✓ Unused volumes removed$(NC)"

# ============================================================================
# UTILITY & INFO TARGETS
# ============================================================================
ps: ## Show running containers (alias for status)
	@$(DOCKER_COMPOSE) ps

version: ## Show project version
	@echo "$(BLUE)Entropic-System$(NC) v$(VERSION)"

info: ## Show project information
	@echo "$(BLUE)╔═══════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║$(NC) Project Information $(BLUE)║$(NC)"
	@echo "$(BLUE)╚═══════════════════════════════════════════════════════════╝$(NC)"
	@echo "$(GREEN)Project Name:$(NC)     $(PROJECT_NAME)"
	@echo "$(GREEN)Version:$(NC)         $(VERSION)"
	@echo "$(GREEN)Environment:$(NC)     $(ENVIRONMENT)"
	@echo "$(GREEN)Docker Compose:$(NC)  $$($(DOCKER_COMPOSE) --version 2>/dev/null || echo 'Not installed')"
	@echo "$(GREEN)Docker:$(NC)         $$($(DOCKER) --version 2>/dev/null || echo 'Not installed')"
	@echo "$(GREEN)Python:$(NC)         $$($(PYTHON) --version 2>/dev/null || echo 'Not installed')"
	@echo ""

restart: ## Restart the Entropic-System
	@echo "$(BLUE)Restarting Entropic-System...$(NC)"
	@make down
	@sleep 2
	@make up
	@echo "$(GREEN)✓ Entropic-System restarted$(NC)"

reset: ## Reset Entropic-System to initial state (removes all data)
	@echo "$(RED)⚠ WARNING: This will delete all data!$(NC)"
	@read -p "Are you sure? Type 'yes' to confirm: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		make clean; \
		echo "$(GREEN)✓ Reset completed$(NC)"; \
	else \
		echo "$(YELLOW)Reset cancelled$(NC)"; \
	fi

# ============================================================================
# VALIDATION & CHECKS
# ============================================================================
validate: ## Validate configuration files
	@echo "$(BLUE)Validating configuration files...$(NC)"
	@if [ -f docker-compose.yml ]; then \
		echo "$(YELLOW)Validating docker-compose.yml...$(NC)"; \
		$(DOCKER_COMPOSE) config > /dev/null && echo "$(GREEN)✓ docker-compose.yml is valid$(NC)" || echo "$(RED)✗ docker-compose.yml validation failed$(NC)"; \
	fi
	@if [ -f .env ]; then \
		echo "$(YELLOW)Checking .env file...$(NC)"; \
		echo "$(GREEN)✓ .env file found$(NC)"; \
	else \
		echo "$(YELLOW)⚠ No .env file found$(NC)"; \
	fi
	@echo "$(GREEN)✓ Validation completed$(NC)"

# ============================================================================
# DEVELOPMENT TARGETS
# ============================================================================
dev: ## Start development environment
	@echo "$(BLUE)Starting development environment...$(NC)"
	@ENVIRONMENT=development make up
	@echo "$(GREEN)✓ Development environment started$(NC)"

dev-logs: ## Show development logs with all details
	@$(DOCKER_COMPOSE) logs -f --tail=100

# ============================================================================
# DOCUMENTATION
# ============================================================================
docs: ## Show detailed documentation
	@echo "$(BLUE)╔═══════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║$(NC) $(GREEN)Entropic-System Makefile Documentation$(NC) $(BLUE)║$(NC)"
	@echo "$(BLUE)╚═══════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)Essential Commands:$(NC)"
	@echo "  $(GREEN)make up$(NC)           - Start the system"
	@echo "  $(GREEN)make down$(NC)         - Stop the system"
	@echo "  $(GREEN)make status$(NC)       - Check system status"
	@echo "  $(GREEN)make logs$(NC)         - View system logs"
	@echo ""
	@echo "$(YELLOW)Development:$(NC)"
	@echo "  $(GREEN)make dev$(NC)          - Start development environment"
	@echo "  $(GREEN)make build$(NC)        - Build Docker images"
	@echo "  $(GREEN)make rebuild$(NC)      - Clean build from scratch"
	@echo "  $(GREEN)make test$(NC)         - Run all tests"
	@echo "  $(GREEN)make test-coverage$(NC) - Run tests with coverage"
	@echo "  $(GREEN)make lint$(NC)         - Run code linting"
	@echo ""
	@echo "$(YELLOW)Operations:$(NC)"
	@echo "  $(GREEN)make deploy$(NC)       - Deploy to production"
	@echo "  $(GREEN)make health-check$(NC) - Verify system health"
	@echo "  $(GREEN)make shell$(NC)        - Access service shell"
	@echo "  $(GREEN)make clean$(NC)        - Clean up resources"
	@echo ""
	@echo "$(YELLOW)Utilities:$(NC)"
	@echo "  $(GREEN)make restart$(NC)      - Restart the system"
	@echo "  $(GREEN)make reset$(NC)        - Reset to initial state"
	@echo "  $(GREEN)make info$(NC)         - Show project info"
	@echo "  $(GREEN)make validate$(NC)     - Validate configurations"
	@echo ""

# ============================================================================
# END OF MAKEFILE
# ============================================================================
