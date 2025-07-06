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

test-all: ## Run all tests (comprehensive)
	@echo "🚀 Running all tests..."
	@./scripts/test-all.sh

test-suite: ## Run comprehensive test suite
	@echo "🧪 Running comprehensive test suite..."
	@./scripts/test-suite.sh

# Database management
backup: ## Database backup
	@echo "💾 Creating backup..."
	@./scripts/manage.sh backup

restore: ## Database restore (make restore file=backup.sql)
	@echo "🔄 Restoring backup..."
	@./scripts/manage.sh restore $(file)

db-create: ## Create WordPress database
	@echo "🗄️  Creating WordPress database..."
	@./scripts/manage.sh wp 'db create'

db-drop: ## Drop WordPress database (DANGEROUS)
	@echo "⚠️  Dropping WordPress database..."
	@echo "This will remove ALL database data. Press Ctrl+C to cancel, Enter to continue..."
	@read
	@./scripts/manage.sh wp 'db drop --yes'

db-reset: ## Reset WordPress database (DANGEROUS)
	@echo "⚠️  Resetting WordPress database..."
	@echo "This will remove ALL WordPress data. Press Ctrl+C to cancel, Enter to continue..."
	@read
	@./scripts/manage.sh wp 'db reset --yes'

db-check: ## Check database connection
	@echo "🔍 Checking database connection..."
	@./scripts/manage.sh wp 'db check' 2>/dev/null || { \
		echo "Note: mysqlcheck not available in container, trying alternative..."; \
		./scripts/manage.sh wp 'core is-installed' 2>/dev/null && echo "✅ Database connection OK (WordPress is installed)" || echo "❌ Database connection failed"; \
	}

db-info: ## Show database information
	@echo "ℹ️  Database information:"
	@./scripts/manage.sh wp 'db size --human-readable' 2>/dev/null || echo "❌ Cannot get database size"
	@./scripts/manage.sh wp 'db tables' 2>/dev/null || echo "❌ Cannot list tables"

db-status: ## Show detailed database status
	@echo "📊 Database status:"
	@./scripts/manage.sh wp 'db size --human-readable' 2>/dev/null && echo "✅ Database size retrieved" || echo "❌ Cannot get database size"
	@echo "📋 Database tables:"
	@./scripts/manage.sh wp 'db tables' 2>/dev/null || echo "❌ Cannot list tables"
	@echo "📊 WordPress tables status:"
	@./scripts/manage.sh wp 'core is-installed' 2>/dev/null && echo "✅ WordPress is installed" || echo "❌ WordPress is not installed"

db-test: ## Test database with simple queries
	@echo "🧪 Testing database with simple queries..."
	@./scripts/manage.sh wp 'db size' 2>/dev/null && echo "✅ Database size query OK" || echo "❌ Database size query failed"
	@./scripts/manage.sh wp 'db tables' 2>/dev/null && echo "✅ Database tables query OK" || echo "❌ Database tables query failed"
	@./scripts/manage.sh wp 'core is-installed' 2>/dev/null && echo "✅ WordPress database is installed" || echo "❌ WordPress database is not installed"

db-optimize: ## Optimize database
	@echo "🔧 Optimizing database..."
	@./scripts/manage.sh wp 'db optimize'

db-help: ## Show all database commands
	@echo "🗄️  Available database commands:"
	@echo "  make db-check     - Check database connection"
	@echo "  make db-create    - Create WordPress database"
	@echo "  make db-drop      - Drop WordPress database (DANGEROUS)"
	@echo "  make db-reset     - Reset WordPress database (DANGEROUS)"
	@echo "  make db-info      - Show database information"
	@echo "  make db-status    - Show detailed database status"
	@echo "  make db-test      - Test database with simple queries"
	@echo "  make db-optimize  - Optimize database"
	@echo "  make backup       - Create database backup"
	@echo "  make restore      - Restore database from backup"
	@echo ""
	@echo "🌐 WordPress installation commands:"
	@echo "  make wp-install-quick - Quick install with defaults"
	@echo "  make wp-install       - Custom install (specify parameters)"
	@echo "  make wp-status        - Check WordPress status"
	@echo "  make wp-info          - Show WordPress info"
	@echo "  make wp-reset         - Reset WordPress (DANGEROUS)"

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

wp-install: ## Install WordPress database (make wp-install url=localhost:8080 title=My-Site admin=admin pass=admin123 email=admin@example.com)
	@echo "🚀 Installing WordPress database..."
	@./scripts/manage.sh wp 'core install --url=$(or $(url),http://localhost:8080) --title=$(or $(title),WordPress-Dev-Site) --admin_user=$(or $(admin),admin) --admin_password=$(or $(pass),admin123) --admin_email=$(or $(email),admin@example.com) --skip-email'

wp-install-quick: ## Quick WordPress install with default settings
	@echo "🚀 Quick WordPress installation..."
	@./scripts/manage.sh wp 'core install --url=http://localhost:8080 --title=WordPress-Dev-Site --admin_user=admin --admin_password=admin123 --admin_email=admin@example.com --skip-email'

wp-reset: ## Reset WordPress database (DANGEROUS - removes all data)
	@echo "⚠️  Resetting WordPress database..."
	@echo "This will remove ALL WordPress data. Press Ctrl+C to cancel, Enter to continue..."
	@read
	@./scripts/manage.sh wp 'db reset --yes'

wp-status: ## Check WordPress installation status
	@echo "📊 WordPress status..."
	@./scripts/manage.sh wp 'core is-installed' && echo "✅ WordPress is installed" || echo "❌ WordPress is not installed"
	@./scripts/manage.sh wp 'core version' 2>/dev/null || echo "❌ WordPress core not accessible"

wp-info: ## Show WordPress installation info
	@echo "ℹ️  WordPress information:"
	@./scripts/manage.sh wp 'core version' 2>/dev/null || echo "❌ WordPress not accessible"
	@./scripts/manage.sh wp 'option get siteurl' 2>/dev/null || echo "❌ Site URL not set"
	@./scripts/manage.sh wp 'option get admin_email' 2>/dev/null || echo "❌ Admin email not set"
	@./scripts/manage.sh wp 'user list --role=administrator --format=table' 2>/dev/null || echo "❌ No admin users found"

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

dev-install: dev-start wp-install-quick ## Full development start with WordPress installation
	@echo "🚀 Development environment with WordPress installed!"
	@echo "🌐 WordPress: http://localhost:8080"
	@echo "🗄️  phpMyAdmin: http://localhost:8081"
	@echo "👤 Admin user: admin / admin123"

dev-logs: ## Show logs in follow mode
	@echo "📋 Logs in follow mode..."
	@./scripts/manage.sh logs -f

dev-reset: clean setup start ## Reset entire environment
	@echo "🔄 Environment reset!"

dev-reset-full: clean setup start wp-install-quick ## Reset environment with fresh WordPress installation
	@echo "🔄 Environment reset with fresh WordPress installation!"
	@echo "🌐 WordPress: http://localhost:8080"
	@echo "👤 Admin user: admin / admin123"

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
