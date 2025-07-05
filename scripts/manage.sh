#!/bin/bash

# Script for easy WordPress Docker management

set -e

COMPOSE_FILE="../docker/docker-compose.yml"
PROJECT_NAME="wordpress"

# Helper function to run docker-compose from the correct directory
run_docker_compose() {
    local script_dir="$(cd "$(dirname "$0")" && pwd)"
    local project_dir="$(dirname "$script_dir")"
    (cd "$project_dir/docker" && docker-compose "$@")
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed!"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed!"
        exit 1
    fi
}

# Start WordPress
start() {
    print_info "Starting WordPress..."
    
    # Prepare MySQL directory if it doesn't exist
    prepare_mysql_directory
    
    run_docker_compose up -d
    
    print_info "Waiting for services to start..."
    sleep 10
    
    print_success "WordPress started!"
    print_info "WordPress: http://localhost:8080"
    print_info "phpMyAdmin: http://localhost:8081"
}

# Stop WordPress
stop() {
    print_info "Stopping WordPress..."
    run_docker_compose down
    print_success "WordPress stopped!"
}

# Restart WordPress
restart() {
    print_info "Restarting WordPress..."
    run_docker_compose restart
    print_success "WordPress restarted!"
}

# Show logs
logs() {
    local service="$1"
    
    case "$service" in
        "apache")
            print_info "Apache logs (access.log):"
            if [ -f "./logs/apache/access.log" ]; then
                tail -f ./logs/apache/access.log
            else
                print_warning "File ./logs/apache/access.log does not exist"
            fi
            ;;
        "apache-error")
            print_info "Apache error logs (error.log):"
            if [ -f "./logs/apache/error.log" ]; then
                tail -f ./logs/apache/error.log
            else
                print_warning "File ./logs/apache/error.log does not exist"
            fi
            ;;
        "mysql")
            print_info "Copying MySQL logs from container..."
            ./mysql-logs.sh copy-mysql-logs > /dev/null 2>&1
            print_info "MySQL logs (error.log):"
            if [ -f "../data/logs/mysql/error.log" ]; then
                tail -f ../data/logs/mysql/error.log
            else
                print_warning "File ../data/logs/mysql/error.log does not exist"
            fi
            ;;
        "mysql-general")
            print_info "Copying MySQL logs from container..."
            ./mysql-logs.sh copy-mysql-logs > /dev/null 2>&1
            print_info "MySQL query logs (general.log):"
            if [ -f "./logs/mysql/general.log" ]; then
                tail -f ./logs/mysql/general.log
            else
                print_warning "File ./logs/mysql/general.log does not exist"
            fi
            ;;
        "mysql-slow")
            print_info "Copying MySQL logs from container..."
            ./mysql-logs.sh copy-mysql-logs > /dev/null 2>&1
            print_info "MySQL slow query logs (slow.log):"
            if [ -f "./logs/mysql/slow.log" ]; then
                tail -f ./logs/mysql/slow.log
            else
                print_warning "File ./logs/mysql/slow.log does not exist"
            fi
            ;;
        "docker"|"")
            print_info "Docker container logs:"
            run_docker_compose logs -f
            ;;
        *)
            print_error "Unknown log type: $service"
            echo ""
            print_info "Available options:"
            echo "  logs                  - Docker container logs"
            echo "  logs apache           - Apache access logs"
            echo "  logs apache-error     - Apache error logs"
            echo "  logs mysql            - MySQL error logs"
            echo "  logs mysql-general    - MySQL general query logs"
            echo "  logs mysql-slow       - MySQL slow query logs"
            exit 1
            ;;
    esac
}

# Show status
status() {
    run_docker_compose ps
}

# Database backup
backup() {
    BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="data/backups/backup_${BACKUP_DATE}.sql"
    
    # Create backups directory if it doesn't exist
    mkdir -p backups
    
    print_info "Creating database backup..."
    run_docker_compose exec -T db mysqldump -u wordpress -pwordpress_password wordpress > "$BACKUP_FILE"
    print_success "Backup created: $BACKUP_FILE"
}

# Export database to SQL file
export_db() {
    if [ -n "$1" ]; then
        EXPORT_FILE="$1"
    else
        EXPORT_FILE="data/backups/export_$(date +%Y%m%d_%H%M%S).sql"
    fi
    
    # Create backups directory if it doesn't exist
    mkdir -p backups
    
    print_info "Exporting database to $EXPORT_FILE..."
    
    if run_docker_compose ps db | grep -q "Up"; then
        run_docker_compose exec -T db mysqldump -u wordpress -pwordpress_password wordpress > "$EXPORT_FILE"
        print_success "Database exported to: $EXPORT_FILE"
    else
        print_error "Database container is not running!"
        print_info "Start WordPress: ./manage.sh start"
        exit 1
    fi
}

# Import database from SQL file
import_db() {
    if [ -z "$1" ]; then
        print_error "Provide SQL file name to import!"
        print_info "Usage: ./manage.sh import-db backup_file.sql"
        exit 1
    fi
    
    if [ ! -f "$1" ]; then
        print_error "SQL file does not exist: $1"
        exit 1
    fi
    
    print_warning "This will overwrite the current database!"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Importing database from $1..."
        if run_docker_compose ps db | grep -q "Up"; then
            run_docker_compose exec -T db mysql -u wordpress -pwordpress_password wordpress < "$1"
            print_success "Database imported!"
        else
            print_error "Database container is not running!"
            print_info "Start WordPress: ./manage.sh start"
            exit 1
        fi
    else
        print_info "Cancelled."
    fi
}

# Restore database
restore() {
    if [ -z "$1" ]; then
        print_error "Provide backup file name to restore!"
        print_info "Usage: ./manage.sh restore backup_file.sql"
        exit 1
    fi
    
    if [ ! -f "$1" ]; then
        print_error "Backup file does not exist: $1"
        exit 1
    fi
    
    print_warning "This will overwrite the current database!"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Restoring database from $1..."
        run_docker_compose exec -T db mysql -u wordpress -pwordpress_password wordpress < "$1"
        print_success "Database restored!"
    else
        print_info "Cancelled."
    fi
}

# Rebuild containers
rebuild() {
    print_info "Rebuilding containers..."
    run_docker_compose build --no-cache
    print_success "Containers rebuilt!"
}

# Clean everything
clean() {
    print_warning "This will remove all containers, volumes and data!"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Cleaning..."
        run_docker_compose down -v --rmi all --remove-orphans
        print_success "Everything cleaned!"
    else
        print_info "Cancelled."
    fi
}

# Full clean - remove everything including WordPress core and all data
full_clean() {
    print_warning "This will remove EVERYTHING:"
    print_warning "- All Docker containers, volumes, images and networks"
    print_warning "- WordPress core files (wordpress-core/ directory)"
    print_warning "- All MySQL data (data/mysql_data/)"
    print_warning "- All log files (data/logs/)"
    print_warning "- All backup files (data/backups/)"
    print_warning "- .env file"
    print_warning "- All generated files and data"
    print_warning ""
    print_info "NOTE: Git-tracked files (symlinks, configs) will be preserved"
    print_warning ""
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Starting full cleanup..."
        
        # Stop and remove all Docker resources
        print_info "Stopping and removing all Docker containers..."
        run_docker_compose down -v --remove-orphans 2>/dev/null || true
        
        print_info "Removing all Docker images, volumes and networks..."
        docker system prune -a --volumes -f 2>/dev/null || true
        
        # Remove WordPress core directory
        if [ -d "wordpress-core" ]; then
            print_info "Removing WordPress core directory..."
            rm -rf wordpress-core
        fi
        
        # Remove WordPress links to core files
        # find . -type l -name "wp-*" -exec rm -f {} \;
        if [ -L "wp-load.php" ]; then
            print_info "Removing WordPress symlinks to core files..."
            find . -type l -name "wp-*" -exec rm -f {} \; 2>/dev/null || true
            rm -f index.php 2>/dev/null || true
            rm -f wp-config.php 2>/dev/null || true
            rm -f readme.html 2>/dev/null || true
            rm -f license.txt 2>/dev/null || true
            rm -f xmlrpc.php 2>/dev/null || true
        fi

        # Remove MySQL data
        if [ -d "data/mysql_data" ]; then
            print_info "Removing MySQL data..."
            rm -rf data/mysql_data
        fi
        
        # Remove log files
        if [ -d "data/logs" ]; then
            print_info "Removing log files..."
            find data/logs -name "*.log" -delete 2>/dev/null || true
        fi
        
        # Remove backup files
        if [ -d "data/backups" ]; then
            print_info "Removing backup files..."
            find data/backups -name "*.sql" -delete 2>/dev/null || true
        fi
        
        # Remove .env file
        if [ -f ".env" ]; then
            print_info "Removing .env file..."
            rm -f .env
        fi
        
        # Remove any temporary files
        print_info "Removing temporary files..."
        rm -f latest.tar.gz 2>/dev/null || true
        rm -rf wordpress 2>/dev/null || true
        
        print_success "Full cleanup completed!"
        print_info "Environment is now in a clean state"
        print_info "Run 'make setup' to initialize a fresh environment"
    else
        print_info "Cancelled."
    fi
}

# Enter WordPress container
shell() {
    print_info "Entering WordPress container..."
    run_docker_compose exec wordpress bash
}

# Run WP-CLI in WordPress container
wp_cli() {
    if [ -z "$1" ]; then
        print_error "Provide WP-CLI command!"
        print_info "Usage: ./manage.sh wp 'core version'"
        print_info "Example: ./manage.sh wp 'user list'"
        exit 1
    fi
    
    print_info "Running WP-CLI: $1"
    run_docker_compose exec wordpress wp $1 --allow-root
}

# Update WordPress core for IDE
update_wordpress_core() {
    print_info "Updating WordPress core for IDE..."
    
    # Check if WordPress files exist
    if [ ! -f "wp-load.php" ]; then
        print_warning "WordPress core is not downloaded locally."
        print_info "Do you want to download it? (y/n)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_info "Cancelled."
            return
        fi
    fi
    
    # Backup wp-config.php if it exists
    if [ -f "wp-config.php" ]; then
        print_info "Creating backup of wp-config.php..."
        cp wp-config.php wp-config.backup.php
    fi
    
    # Download latest version
    print_info "Downloading latest WordPress version..."
    mkdir -p wordpress-latest-tmp && cd wordpress-latest-tmp
    if command -v curl &> /dev/null; then
        curl -O https://wordpress.org/latest.tar.gz
    elif command -v wget &> /dev/null; then
        wget https://wordpress.org/latest.tar.gz
    else
        print_error "Missing curl or wget!"
        return 1
    fi
    
    # Extract and replace core files
    print_info "Extracting and updating..."
    tar -xzf latest.tar.gz
    
    # Preserve wp-config.php and custom folders
    if [ -f "wp-config.backup.php" ]; then
        mv wp-config.backup.php wordpress/wp-config.php
    fi
    
    # Move all core files
    rsync -av --exclude='wp-config.php' --exclude='wp-content/plugins/' --exclude='wp-content/themes/' --exclude='wp-content/uploads/' wordpress/ ./
    
    # Cleanup
    rm -rf wordpress/
    rm latest.tar.gz
    
    print_success "WordPress core updated for IDE"
    print_info "Autocompletion and IntelliSense available for latest WordPress version"
}

# Show database files location
database_location() {
    print_info "Database files location:"
    
    # Check if using local directory
    if [ -d "./mysql_data" ] && [ ! -z "$(ls -A ./mysql_data 2>/dev/null)" ]; then
        print_success "Location: ./mysql_data (local directory)"
        SIZE=$(du -sh "./mysql_data" 2>/dev/null | cut -f1)
        print_info "Size: $SIZE"
        
        print_info "Database files:"
        if run_docker_compose ps db | grep -q "Up"; then
            run_docker_compose exec -T db ls -la /var/lib/mysql/
        else
            print_warning "Database container is not running"
            print_info "Start WordPress: ./manage.sh start"
        fi
    # Check if Docker volume exists
    elif docker volume inspect wordpress_mysql_data &> /dev/null; then
        VOLUME_PATH=$(docker volume inspect wordpress_mysql_data | grep -o '"Mountpoint": "[^"]*' | cut -d'"' -f4)
        print_success "Docker volume: wordpress_mysql_data"
        print_info "Physical path: $VOLUME_PATH"
        
        # Check size
        if [ -d "$VOLUME_PATH" ]; then
            SIZE=$(du -sh "$VOLUME_PATH" 2>/dev/null | cut -f1)
            print_info "Size: $SIZE"
        fi
        
        # Show database files
        print_info "Database files:"
        if run_docker_compose ps db | grep -q "Up"; then
            run_docker_compose exec -T db ls -la /var/lib/mysql/
        else
            print_warning "Database container is not running"
            print_info "Start WordPress: ./manage.sh start"
        fi
    else
        print_error "Database does not exist!"
        print_info "Start WordPress first: ./manage.sh start"
    fi
}

# Migrate data from Docker volume to local directory
migrate_to_local() {
    print_info "Migrating MySQL data from Docker volume to local directory..."
    
    # Check if volume exists
    if ! docker volume inspect wordpress_mysql_data &> /dev/null; then
        print_error "Volume wordpress_mysql_data does not exist!"
        print_info "First start WordPress with old configuration"
        return 1
    fi
    
    # Check if local directory already exists
    if [ -d "./mysql_data" ]; then
        print_warning "Directory ./mysql_data already exists!"
        read -p "Do you want to remove it and replace with volume data? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "./mysql_data"
        else
            print_info "Migration cancelled."
            return 1
        fi
    fi
    
    # Stop containers
    print_info "Stopping containers..."
    run_docker_compose down
    
    # Create temporary container to copy data
    print_info "Copying data from Docker volume..."
    docker run --rm \
        -v wordpress_mysql_data:/source \
        -v "$(pwd):/dest" \
        busybox \
        cp -a /source/. /dest/mysql_data/
    
    # Fix permissions
    print_info "Fixing permissions..."
    sudo chown -R 999:999 "./mysql_data" 2>/dev/null || {
        print_warning "Failed to change permissions. Sudo may be required."
        print_info "Run: sudo chown -R 999:999 ./mysql_data"
    }
    
    print_success "Migration completed!"
    print_info "MySQL data is now in directory: ./mysql_data"
    print_info "Old volume can be removed: docker volume rm wordpress_mysql_data"
}

# Prepare local MySQL directory with proper permissions
prepare_mysql_directory() {
    print_info "Preparing local MySQL directory..."
    
    if [ -d "./mysql_data" ]; then
        print_info "Directory ./mysql_data already exists"
        return 0
    fi
    
    # Create directory
    mkdir -p "./mysql_data"
    
    # Set permissions - MySQL needs UID/GID 999
    if command -v sudo &> /dev/null; then
        sudo chown 999:999 "./mysql_data" 2>/dev/null || {
            print_warning "Failed to set permissions for ./mysql_data"
            print_info "Permissions will be set automatically on first run"
        }
    else
        print_warning "sudo not available - permissions will be set automatically"
    fi
    
    print_success "Directory ./mysql_data ready"
}

# Build distribution packages
build_dist() {
    local type="$1"
    local name="$2"
    
    if [ -z "$type" ]; then
        print_error "Please specify type: plugin or theme"
        print_info "Usage: ./manage.sh build-dist plugin [plugin-name]"
        print_info "       ./manage.sh build-dist theme [theme-name]"
        print_info "       ./manage.sh build-dist all"
        return 1
    fi
    
    # Create dist directory if it doesn't exist
    mkdir -p dist
    
    case "$type" in
        "plugin"|"plugins")
            if [ -n "$name" ]; then
                build_plugin_dist "$name"
            else
                build_all_plugins_dist
            fi
            ;;
        "theme"|"themes")
            if [ -n "$name" ]; then
                build_theme_dist "$name"
            else
                build_all_themes_dist
            fi
            ;;
        "all")
            build_all_plugins_dist
            build_all_themes_dist
            ;;
        *)
            print_error "Unknown type: $type"
            print_info "Available types: plugin, theme, all"
            return 1
            ;;
    esac
}

# Build single plugin distribution
build_plugin_dist() {
    local plugin_name="$1"
    local plugin_path="wp-content/plugins/$plugin_name"
    
    if [ ! -d "$plugin_path" ]; then
        print_error "Plugin '$plugin_name' not found in $plugin_path"
        return 1
    fi
    
    print_info "Building distribution for plugin: $plugin_name"
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    local dist_name="${plugin_name}_$(date +%Y%m%d_%H%M%S)"
    local current_dir=$(pwd)
    
    # Copy plugin files to temp directory
    cp -r "$plugin_path" "$temp_dir/$plugin_name"
    
    # Remove development files
    find "$temp_dir/$plugin_name" -name ".git*" -delete 2>/dev/null || true
    find "$temp_dir/$plugin_name" -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
    find "$temp_dir/$plugin_name" -name ".DS_Store" -delete 2>/dev/null || true
    find "$temp_dir/$plugin_name" -name "*.log" -delete 2>/dev/null || true
    find "$temp_dir/$plugin_name" -name "*.tmp" -delete 2>/dev/null || true
    find "$temp_dir/$plugin_name" -name "package.json" -delete 2>/dev/null || true
    find "$temp_dir/$plugin_name" -name "package-lock.json" -delete 2>/dev/null || true
    find "$temp_dir/$plugin_name" -name "yarn.lock" -delete 2>/dev/null || true
    find "$temp_dir/$plugin_name" -name "composer.json" -delete 2>/dev/null || true
    find "$temp_dir/$plugin_name" -name "composer.lock" -delete 2>/dev/null || true
    
    # Create ZIP file
    local zip_file="$current_dir/dist/${dist_name}.zip"
    cd "$temp_dir"
    zip -r "$zip_file" "$plugin_name" > /dev/null
    cd "$current_dir"
    
    # Clean up
    rm -rf "$temp_dir"
    
    print_success "Plugin distribution created: dist/${dist_name}.zip"
}

# Build single theme distribution
build_theme_dist() {
    local theme_name="$1"
    local theme_path="wp-content/themes/$theme_name"
    
    if [ ! -d "$theme_path" ]; then
        print_error "Theme '$theme_name' not found in $theme_path"
        return 1
    fi
    
    print_info "Building distribution for theme: $theme_name"
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    local dist_name="${theme_name}_$(date +%Y%m%d_%H%M%S)"
    local current_dir=$(pwd)
    
    # Copy theme files to temp directory
    cp -r "$theme_path" "$temp_dir/$theme_name"
    
    # Remove development files
    find "$temp_dir/$theme_name" -name ".git*" -delete 2>/dev/null || true
    find "$temp_dir/$theme_name" -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
    find "$temp_dir/$theme_name" -name ".DS_Store" -delete 2>/dev/null || true
    find "$temp_dir/$theme_name" -name "*.log" -delete 2>/dev/null || true
    find "$temp_dir/$theme_name" -name "*.tmp" -delete 2>/dev/null || true
    find "$temp_dir/$theme_name" -name "src" -type d -exec rm -rf {} + 2>/dev/null || true
    find "$temp_dir/$theme_name" -name "*.scss" -delete 2>/dev/null || true
    find "$temp_dir/$theme_name" -name "*.less" -delete 2>/dev/null || true
    find "$temp_dir/$theme_name" -name "gulpfile.js" -delete 2>/dev/null || true
    find "$temp_dir/$theme_name" -name "webpack.config.js" -delete 2>/dev/null || true
    find "$temp_dir/$theme_name" -name "package.json" -delete 2>/dev/null || true
    find "$temp_dir/$theme_name" -name "package-lock.json" -delete 2>/dev/null || true
    find "$temp_dir/$theme_name" -name "yarn.lock" -delete 2>/dev/null || true
    find "$temp_dir/$theme_name" -name "composer.json" -delete 2>/dev/null || true
    find "$temp_dir/$theme_name" -name "composer.lock" -delete 2>/dev/null || true
    
    # Create ZIP file
    local zip_file="$current_dir/dist/${dist_name}.zip"
    cd "$temp_dir"
    zip -r "$zip_file" "$theme_name" > /dev/null
    cd "$current_dir"
    
    # Clean up
    rm -rf "$temp_dir"
    
    print_success "Theme distribution created: dist/${dist_name}.zip"
}

# Build all plugins distributions
build_all_plugins_dist() {
    print_info "Building distributions for all plugins..."
    
    if [ ! -d "wp-content/plugins" ]; then
        print_warning "No plugins directory found"
        return 0
    fi
    
    local count=0
    for plugin_dir in wp-content/plugins/*/; do
        if [ -d "$plugin_dir" ]; then
            local plugin_name=$(basename "$plugin_dir")
            # Skip sample plugins and hidden directories
            if [[ "$plugin_name" != "."* ]]; then
                build_plugin_dist "$plugin_name"
                ((count++))
            fi
        fi
    done
    
    if [ $count -eq 0 ]; then
        print_warning "No plugins found to build"
    else
        print_success "Built distributions for $count plugin(s)"
    fi
}

# Build all themes distributions
build_all_themes_dist() {
    print_info "Building distributions for all themes..."
    
    if [ ! -d "wp-content/themes" ]; then
        print_warning "No themes directory found"
        return 0
    fi
    
    local count=0
    for theme_dir in wp-content/themes/*/; do
        if [ -d "$theme_dir" ]; then
            local theme_name=$(basename "$theme_dir")
            # Skip sample themes and hidden directories
            if [[ "$theme_name" != "."* ]]; then
                build_theme_dist "$theme_name"
                ((count++))
            fi
        fi
    done
    
    if [ $count -eq 0 ]; then
        print_warning "No themes found to build"
    else
        print_success "Built distributions for $count theme(s)"
    fi
}

# List available plugins and themes for distribution
list_dist_available() {
    print_info "Available for distribution:"
    
    echo ""
    echo "Plugins:"
    if [ -d "wp-content/plugins" ]; then
        for plugin_dir in wp-content/plugins/*/; do
            if [ -d "$plugin_dir" ]; then
                local plugin_name=$(basename "$plugin_dir")
                if [[ "$plugin_name" != "."* ]]; then
                    echo "  - $plugin_name"
                fi
            fi
        done
    else
        echo "  (no plugins directory found)"
    fi
    
    echo ""
    echo "Themes:"
    if [ -d "wp-content/themes" ]; then
        for theme_dir in wp-content/themes/*/; do
            if [ -d "$theme_dir" ]; then
                local theme_name=$(basename "$theme_dir")
                if [[ "$theme_name" != "."* ]]; then
                    echo "  - $theme_name"
                fi
            fi
        done
    else
        echo "  (no themes directory found)"
    fi
    
    echo ""
    if [ -d "dist" ] && [ "$(ls -A dist)" ]; then
        echo "Existing distributions:"
        ls -la dist/*.zip 2>/dev/null | awk '{print "  " $9 " (" $5 " bytes, " $6 " " $7 " " $8 ")"}'
    else
        echo "No distributions built yet."
    fi
}

# Help
help() {
    echo "WordPress Docker Manager"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start     - Start WordPress"
    echo "  stop      - Stop WordPress"
    echo "  restart   - Restart WordPress"
    echo "  logs [type] - Show logs (apache, mysql, docker)"
    echo "  status    - Show container status"
    echo "  backup    - Create database backup"
    echo "  restore   - Restore database backup"
    echo "  export-db - Export database to SQL file"
    echo "  import-db - Import database from SQL file"
    echo "  rebuild   - Rebuild containers"
    echo "  clean     - Remove all containers and data"
    echo "  full-clean - Remove EVERYTHING (containers, WordPress core, all data)"
    echo "  shell     - Enter WordPress container"
    echo "  wp        - Run WP-CLI in WordPress container"
    echo "  update-wp-core - Update WordPress core for IDE (autocompletion)"
    echo "  db-location - Show database files location"
    echo "  migrate-to-local - Migrate MySQL data from Docker volume to local directory"
    echo "  prepare-mysql - Prepare local MySQL directory with proper permissions"
    echo "  build-dist - Build distribution packages (plugin/theme/all)"
    echo "  list-dist - List available items and existing distributions"
    echo "  help      - Show this help"
    echo ""
}

# Main
main() {
    check_docker
    
    case "${1:-help}" in
        start)
            start
            ;;
        stop)
            stop
            ;;
        restart)
            restart
            ;;
        logs)
            logs "$2"
            ;;
        status)
            status
            ;;
        backup)
            backup
            ;;
        restore)
            restore "$2"
            ;;
        export-db)
            export_db "$2"
            ;;
        import-db)
            import_db "$2"
            ;;
        rebuild)
            rebuild
            ;;
        clean)
            clean
            ;;
        full-clean)
            full_clean
            ;;
        shell)
            shell
            ;;
        wp)
            wp_cli "$2"
            ;;
        db-location)
            database_location
            ;;
        migrate-to-local)
            migrate_to_local
            ;;
        prepare-mysql)
            prepare_mysql_directory
            ;;
        build-dist)
            build_dist "$2" "$3"
            ;;
        list-dist)
            list_dist_available
            ;;
        help|*)
            help
            ;;
    esac
}

main "$@"
