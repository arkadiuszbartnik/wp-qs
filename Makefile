# WordPress Development Monorepo Makefile
.PHONY: help setup start stop restart status logs shell clean test

# Default target
help: ## Show help
	@echo "WordPress Development Monorepo"
	@echo "=============================="
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Environment management
setup: ## Initialize environment
	@echo "🚀 Initializing environment..."
	@./scripts/setup.sh

start: ## Start WordPress
	@echo "▶️  Starting WordPress..."
	@./scripts/manage.sh start

stop: ## Stop WordPress
	@echo "⏹️  Stopping WordPress..."
	@./scripts/manage.sh stop

restart: ## Restart WordPress
	@echo "🔄 Restarting WordPress..."
	@./scripts/manage.sh restart

status: ## Container status
	@echo "📊 Container status..."
	@./scripts/manage.sh status

logs: ## Show logs
	@echo "📋 Showing logs..."
	@./scripts/manage.sh logs

shell: ## Enter WordPress container
	@echo "🐚 Entering container..."
	@./scripts/manage.sh shell

clean: ## Clean environment
	@echo "🧹 Cleaning environment..."
	@./scripts/manage.sh clean

full-clean: ## Remove EVERYTHING (containers, WordPress core, all data)
	@echo "🗑️  Full cleanup..."
	@./scripts/manage.sh full-clean

test: ## Test environment
	@echo "🧪 Testing environment..."
	@./scripts/test-environment.sh

# Database management
backup: ## Database backup
	@echo "💾 Creating backup..."
	@./scripts/manage.sh backup

restore: ## Database restore (make restore file=backup.sql)
	@echo "🔄 Restoring backup..."
	@./scripts/manage.sh restore $(file)

# Plugin management
plugin-create: ## Create new plugin (make plugin-create name=my-plugin)
	@echo "🧩 Creating plugin: $(name)"
	@./scripts/git-submodules.sh create-plugin $(name)

plugin-add: ## Add plugin as submodule (make plugin-add name=my-plugin url=https://github.com/user/plugin.git)
	@echo "➕ Adding plugin: $(name)"
	@./scripts/git-submodules.sh add-plugin $(name) $(url)

plugin-update: ## Update plugin (make plugin-update name=my-plugin)
	@echo "🔄 Updating plugin: $(name)"
	@./scripts/git-submodules.sh update-plugin $(name)

plugin-remove: ## Remove plugin (make plugin-remove name=my-plugin)
	@echo "🗑️  Removing plugin: $(name)"
	@./scripts/git-submodules.sh remove-plugin $(name)

# Theme management
theme-create: ## Create new theme (make theme-create name=my-theme)
	@echo "🎨 Creating theme: $(name)"
	@./scripts/git-submodules.sh create-theme $(name)

theme-add: ## Add theme as submodule (make theme-add name=my-theme url=https://github.com/user/theme.git)
	@echo "➕ Adding theme: $(name)"
	@./scripts/git-submodules.sh add-theme $(name) $(url)

theme-update: ## Update theme (make theme-update name=my-theme)
	@echo "🔄 Updating theme: $(name)"
	@./scripts/git-submodules.sh update-theme $(name)

theme-remove: ## Remove theme (make theme-remove name=my-theme)
	@echo "🗑️  Removing theme: $(name)"
	@./scripts/git-submodules.sh remove-theme $(name)

# Submodules management
submodules-init: ## Initialize submodules
	@echo "🔗 Initializing submodules..."
	@./scripts/git-submodules.sh init

submodules-update: ## Update all submodules
	@echo "🔄 Updating submodules..."
	@./scripts/git-submodules.sh update

submodules-status: ## Submodules status
	@echo "📊 Submodules status..."
	@./scripts/git-submodules.sh status

submodules-list: ## List submodules
	@echo "📋 Listing submodules..."
	@./scripts/git-submodules.sh list

# WP-CLI shortcuts
wp: ## Run WP-CLI command (make wp cmd="core version")
	@echo "🔧 Running WP-CLI: $(cmd)"
	@./scripts/manage.sh wp '$(cmd)'

wp-install-plugin: ## Install plugin via WP-CLI (make wp-install-plugin name=akismet)
	@echo "📦 Installing plugin: $(name)"
	@./scripts/manage.sh wp 'plugin install $(name) --activate'

wp-user-create: ## Create user (make wp-user-create user=admin email=admin@example.com)
	@echo "👤 Creating user: $(user)"
	@./scripts/manage.sh wp 'user create $(user) $(email) --role=administrator'

# Development shortcuts
dev-start: setup start ## Full development environment start
	@echo "🚀 Development environment started!"
	@echo "🌐 WordPress: http://localhost:8080"
	@echo "🗄️  phpMyAdmin: http://localhost:8081"

dev-logs: ## Show logs in follow mode
	@echo "📋 Logs in follow mode..."
	@./scripts/manage.sh logs -f

dev-reset: clean setup start ## Reset entire environment
	@echo "🔄 Environment reset!"

# Info commands
info: ## Show environment information
	@echo "ℹ️  Environment information:"
	@echo "  WordPress: http://localhost:8080"
	@echo "  phpMyAdmin: http://localhost:8081"
	@echo "  Logs: make logs"
	@echo "  Shell: make shell"
	@echo "  Status: make status"

structure: ## Show project structure
	@echo "📁 Project structure:"
	@if command -v tree >/dev/null 2>&1; then \
		tree -I 'node_modules|.git|wordpress-core|wp-admin|wp-includes|mysql_data|dist' -L 2; \
	else \
		echo ""; \
		echo "├── config/           - WordPress configuration files"; \
		echo "├── data/             - Persistent data (ignored in git)"; \
		echo "│   ├── backups/      - Database backups"; \
		echo "│   └── logs/         - Application logs"; \
		echo "├── dist/             - Distribution packages (auto-generated)"; \
		echo "├── docker/           - Docker configuration"; \
		echo "├── docs/             - Documentation"; \
		echo "├── scripts/          - Management scripts"; \
		echo "├── wp-content/       - Custom plugins and themes"; \
		echo "│   ├── plugins/      - WordPress plugins"; \
		echo "│   └── themes/       - WordPress themes"; \
		echo "└── wp-*              - WordPress core symlinks"; \
		echo ""; \
		echo "Current plugins:"; \
		ls -1 wp-content/plugins/ 2>/dev/null | grep -v "^README" | grep -v "^\.gitkeep" | sed 's/^/  - /' || echo "  (none)"; \
		echo ""; \
		echo "Current themes:"; \
		ls -1 wp-content/themes/ 2>/dev/null | grep -v "^README" | grep -v "^\.gitkeep" | sed 's/^/  - /' || echo "  (none)"; \
	fi

# Build and distribution
build-plugin: ## Build plugin distribution (make build-plugin name=my-plugin)
	@echo "📦 Building plugin: $(name)"
	@./scripts/manage.sh build-dist plugin $(name)

build-theme: ## Build theme distribution (make build-theme name=my-theme)
	@echo "🎨 Building theme: $(name)"
	@./scripts/manage.sh build-dist theme $(name)

build-all: ## Build all plugins and themes
	@echo "📦 Building all distributions..."
	@./scripts/manage.sh build-dist all

list-dist: ## List available items and existing distributions
	@echo "📋 Available for distribution..."
	@./scripts/manage.sh list-dist
