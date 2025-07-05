#!/bin/bash

# WordPress Development Environment Setup Script
# This script initializes WordPress environment with monorepo

set -e

echo "🚀 WordPress Development Environment Setup"
echo "==========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Helper function to run docker-compose from the correct directory
run_docker_compose() {
    local script_dir="$(cd "$(dirname "$0")" && pwd)"
    local project_dir="$(dirname "$script_dir")"
    (cd "$project_dir/docker" && docker-compose "$@" && cd "$project_dir")
}

# Check requirements
check_requirements() {
    print_info "Checking requirements..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed!"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed!"
        exit 1
    fi
    
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed!"
        exit 1
    fi
    
    # Check optional requirements
    if ! command -v composer &> /dev/null; then
        print_warning "Composer is not installed (optional for IDE support)"
        print_info "To install Composer, visit: https://getcomposer.org/download/"
    fi
    
    print_success "All requirements satisfied"
}

# Initialize configuration
init_config() {
    print_info "Initializing configuration..."
    
    # Copy .env.example to .env if it doesn't exist
    if [ ! -f .env ]; then
        if [ -f .env.example ]; then
            cp .env.example .env
            print_success "Copied .env.example to .env"
        else
            print_warning ".env.example doesn't exist, creating basic .env"
            cat > .env << EOF
# MySQL Configuration
MYSQL_ROOT_PASSWORD=root_password_$(date +%s)
MYSQL_PASSWORD=wordpress_password_$(date +%s)

# WordPress Configuration
WORDPRESS_DEBUG=true
WORDPRESS_DEBUG_LOG=true
EOF
        fi
    else
        print_info ".env already exists, skipping"
    fi
}

# Initialize directory structure
init_directories() {
    print_info "Creating directory structure..."
    
    # Create basic directories
    mkdir -p wp-content/plugins
    mkdir -p wp-content/themes
    mkdir -p wp-content/uploads
    mkdir -p data/backups
    mkdir -p data/logs/apache
    mkdir -p data/logs/php
    mkdir -p data/logs/mysql
    mkdir -p config/php
    
    # Create .gitkeep in empty directories
    touch wp-content/plugins/.gitkeep
    touch wp-content/themes/.gitkeep
    touch wp-content/uploads/.gitkeep
    touch data/backups/.gitkeep
    touch data/logs/apache/.gitkeep
    touch data/logs/php/.gitkeep
    touch data/logs/mysql/.gitkeep
    
    print_success "Directory structure created"
}

# Download WordPress core for IDE (autocompletion, IntelliSense)
download_wordpress_for_ide() {
    print_info "Downloading WordPress core for IDE..."
    # Check if WordPress core already exists
    if [ -f "wordpress-core/wp-load.php" ] && [ -d "wordpress-core/wp-includes" ]; then
        print_warning "WordPress core already exists. Do you want to download it again? Wordpress core will be replaced with latest version (y/n)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_info "Skipped WordPress core download"
            return
        fi
    fi
    
    print_info "Creating wordpress-core temp directory..."
    mkdir -p wordpress-core-tmp && cd wordpress-core-tmp || {
        print_error "Failed to create wordpress-core-tmp directory"
        return 1
    }
    # Download latest WordPress version
    print_info "Downloading latest WordPress version..."
    if command -v curl &> /dev/null; then
        curl -O https://wordpress.org/latest.tar.gz
    elif command -v wget &> /dev/null; then
        wget https://wordpress.org/latest.tar.gz
    else
        print_error "Missing curl or wget! Install one of these tools."
        return 1
    fi
    
    # Extract WordPress
    print_info "Extracting WordPress..."
    tar -xzf latest.tar.gz 
    
    # Move files from wordpress/ directory to wordpress-core/
    print_info "Moving WordPress files to wordpress-core/..."
    if [ ! -d "../wordpress-core" ]; then
        rm -f ../wordpress-core
    fi
    mkdir -p ../wordpress-core
    mv -fn wordpress/* ../wordpress-core/
    cd ..
    print_info "Cleaning up wordpress core temporary files..."
    rm -fr wordpress-core-tmp
    
    # Create symlinks to main directory
    print_info "Creating symlinks to WordPress core..."
    ln -sf wordpress-core/* . 2>/dev/null || true
    
    # Copy wp-config-sample.php to config/wp-config.php if it doesn't exist
    if [ ! -f "config/wp-config.php" ] && [ -f "wordpress-core/wp-config-sample.php" ]; then
        cp wordpress-core/wp-config-sample.php config/wp-config.php
        print_info "Copied wp-config-sample.php to config/wp-config.php"
        print_warning "Remember to configure wp-config.php!"
    fi
    
    print_success "WordPress core downloaded for IDE (autocompletion available)"
    print_info "WordPress files are available locally for IDE but ignored by Git"
}

# Initialize Git structure for plugins/themes
init_git_structure() {
    print_info "Initializing Git structure..."
    
    # Check if this is a Git repo
    if [ ! -d .git ]; then
        print_warning "This is not a Git repository. Do you want to initialize it? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            git init
            print_success "Git repository initialized"
        fi
    fi
    
    # Create .gitignore if it doesn't exist
    if [ ! -f .gitignore ]; then
        print_info "Creating .gitignore..."
        cat > .gitignore << 'EOF'
# WordPress Core - downloaded automatically
wordpress/

# Exceptions - keep configuration
!wp-config.php

# Database backups (keep directory but exclude SQL files)
backups/*.sql

# Database data
mysql_data/

# Uploads - only example files
uploads/*
!uploads/.gitkeep

# Logs
*.log
error_log

# Environment files
.env
.env.local
.env.production

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Node modules (if using any build tools)
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Temporary files
*.tmp
*.temp
*.bak
*.backup
EOF
        print_success ".gitignore created"
    fi
}

# Create sample configuration files
create_sample_configs() {
    print_info "Creating sample configurations..."
    
    # Create sample plugin
    if [ ! -d "wp-content/plugins/sample-plugin" ]; then
        mkdir -p wp-content/plugins/sample-plugin
        cat > wp-content/plugins/sample-plugin/sample-plugin.php << 'EOF'
<?php
/**
 * Plugin Name: Sample Plugin
 * Description: Sample plugin for development environment
 * Version: 1.0.0
 * Author: Your Name
 */

if (!defined('ABSPATH')) {
    exit;
}

add_action('wp_head', function() {
    echo '<!-- Sample Plugin Active -->';
});

add_shortcode('sample_hello', function($atts) {
    $atts = shortcode_atts(array(
        'name' => 'World',
    ), $atts);
    
    return '<p>Hello, ' . esc_html($atts['name']) . '!</p>';
});
EOF
        print_success "Sample plugin created"
    fi
    
    # Create README for plugins
    if [ ! -f "wp-content/plugins/README.md" ]; then
        cat > wp-content/plugins/README.md << 'EOF'
# Custom Plugins

This directory contains custom WordPress plugins.

## Structure

Each plugin should have its own structure:

```
plugin-name/
├── plugin-name.php      # Main plugin file
├── assets/             # CSS, JS, images
├── includes/           # PHP classes
├── languages/          # Translations
├── README.md          # Documentation
└── .git/              # Separate repository (optional)
```

## Development

1. Create a new folder for the plugin
2. Add main PHP file with header information
3. Optionally: create separate Git repository for the plugin
4. Add as submodule to main repo
EOF
        print_success "README for plugins created"
    fi
    
    # Create README for themes
    if [ ! -f "wp-content/themes/README.md" ]; then
        cat > wp-content/themes/README.md << 'EOF'
# Custom Themes

This directory contains custom WordPress themes.

## Structure

Each theme should have its own structure:

```
theme-name/
├── style.css          # Main CSS file with header
├── index.php          # Main template
├── functions.php      # Theme functions
├── assets/           # CSS, JS, images
├── templates/        # Template files
├── README.md         # Documentation
└── .git/             # Separate repository (optional)
```

## Development

1. Create a new folder for the theme
2. Add style.css with header information
3. Add basic template files
4. Optionally: create separate Git repository for the theme
EOF
        print_success "README for themes created"
    fi
}

# Create sample files in wp-content directory
create_wp_content_examples() {
    print_info "Creating sample files in wp-content..."
    
    # Create sample plugin in wp-content/plugins
    if [ ! -d "wp-content/plugins/sample-wp-plugin" ]; then
        mkdir -p wp-content/plugins/sample-wp-plugin
        cat > wp-content/plugins/sample-wp-plugin/sample-wp-plugin.php << 'EOF'
<?php
/**
 * Plugin Name: Sample WP Plugin
 * Description: Example plugin in wp-content for development
 * Version: 1.0.0
 * Author: Developer
 */

if (!defined('ABSPATH')) {
    exit;
}

class SampleWPPlugin {
    
    public function __construct() {
        add_action('init', array($this, 'init'));
        add_action('wp_enqueue_scripts', array($this, 'enqueue_scripts'));
        add_shortcode('sample_wp', array($this, 'sample_shortcode'));
    }
    
    public function init() {
        // Plugin initialization
    }
    
    public function enqueue_scripts() {
        wp_enqueue_script('sample-wp-plugin-js', plugin_dir_url(__FILE__) . 'assets/script.js', array('jquery'), '1.0.0', true);
        wp_enqueue_style('sample-wp-plugin-css', plugin_dir_url(__FILE__) . 'assets/style.css', array(), '1.0.0');
    }
    
    public function sample_shortcode($atts) {
        $atts = shortcode_atts(array(
            'message' => 'Hello from WP-Content plugin!',
        ), $atts);
        
        return '<div class="sample-wp-plugin">' . esc_html($atts['message']) . '</div>';
    }
}

new SampleWPPlugin();
EOF

        # Create assets directory and files
        mkdir -p wp-content/plugins/sample-wp-plugin/assets
        
        cat > wp-content/plugins/sample-wp-plugin/assets/style.css << 'EOF'
/* Sample WP Plugin Styles */
.sample-wp-plugin {
    background: #f0f0f0;
    padding: 15px;
    border-radius: 5px;
    border-left: 4px solid #0073aa;
    margin: 10px 0;
}
EOF

        cat > wp-content/plugins/sample-wp-plugin/assets/script.js << 'EOF'
/* Sample WP Plugin Scripts */
jQuery(document).ready(function($) {
    $('.sample-wp-plugin').on('click', function() {
        $(this).fadeOut().fadeIn();
    });
});
EOF

        cat > wp-content/plugins/sample-wp-plugin/README.md << 'EOF'
# Sample WP Plugin

This is an example plugin located in wp-content/plugins directory.

## Features

- Sample shortcode: `[sample_wp message="Your message"]`
- CSS and JS assets
- WordPress hooks and filters examples

## Installation

This plugin is already in the wp-content directory and can be activated from WordPress admin.
EOF

        print_success "Sample plugin created in wp-content"
    fi
    
    # Create sample theme in wp-content/themes
    if [ ! -d "wp-content/themes/sample-theme" ]; then
        mkdir -p wp-content/themes/sample-theme
        
        cat > wp-content/themes/sample-theme/style.css << 'EOF'
/*
Theme Name: Sample Theme
Description: Example theme for development
Version: 1.0.0
Author: Developer
*/

/* Basic Theme Styles */
body {
    font-family: Arial, sans-serif;
    line-height: 1.6;
    color: #333;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
}

header {
    background: #0073aa;
    color: white;
    padding: 1rem 0;
}

.site-title {
    font-size: 2rem;
    margin: 0;
}

main {
    padding: 2rem 0;
}

footer {
    background: #333;
    color: white;
    text-align: center;
    padding: 1rem 0;
}
EOF

        cat > wp-content/themes/sample-theme/index.php << 'EOF'
<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?php wp_title('|', true, 'right'); ?></title>
    <?php wp_head(); ?>
</head>
<body <?php body_class(); ?>>
    <header>
        <div class="container">
            <h1 class="site-title">
                <a href="<?php echo home_url(); ?>"><?php bloginfo('name'); ?></a>
            </h1>
            <p><?php bloginfo('description'); ?></p>
        </div>
    </header>
    
    <main>
        <div class="container">
            <?php if (have_posts()) : ?>
                <?php while (have_posts()) : the_post(); ?>
                    <article>
                        <h2><a href="<?php the_permalink(); ?>"><?php the_title(); ?></a></h2>
                        <div class="content">
                            <?php the_content(); ?>
                        </div>
                    </article>
                <?php endwhile; ?>
            <?php else : ?>
                <p>No posts found.</p>
            <?php endif; ?>
        </div>
    </main>
    
    <footer>
        <div class="container">
            <p>&copy; <?php echo date('Y'); ?> <?php bloginfo('name'); ?></p>
        </div>
    </footer>
    
    <?php wp_footer(); ?>
</body>
</html>
EOF

        cat > wp-content/themes/sample-theme/functions.php << 'EOF'
<?php
if (!defined('ABSPATH')) {
    exit;
}

// Theme setup
function sample_theme_setup() {
    // Add theme support
    add_theme_support('title-tag');
    add_theme_support('post-thumbnails');
    add_theme_support('html5', array('search-form', 'comment-form', 'comment-list', 'gallery', 'caption'));
    
    // Register navigation menus
    register_nav_menus(array(
        'primary' => __('Primary Menu', 'sample-theme'),
    ));
}
add_action('after_setup_theme', 'sample_theme_setup');

// Enqueue styles and scripts
function sample_theme_scripts() {
    wp_enqueue_style('sample-theme-style', get_stylesheet_uri());
    wp_enqueue_script('sample-theme-js', get_template_directory_uri() . '/assets/script.js', array('jquery'), '1.0.0', true);
}
add_action('wp_enqueue_scripts', 'sample_theme_scripts');

// Custom function example
function sample_theme_custom_function() {
    return 'Hello from sample theme!';
}
EOF

        # Create assets directory and files
        mkdir -p wp-content/themes/sample-theme/assets
        
        cat > wp-content/themes/sample-theme/assets/script.js << 'EOF'
/* Sample Theme Scripts */
jQuery(document).ready(function($) {
    console.log('Sample theme loaded!');
    
    // Example: smooth scroll to top
    $('body').append('<button id="scroll-top" style="position:fixed; bottom:20px; right:20px; display:none;">Top</button>');
    
    $(window).scroll(function() {
        if ($(this).scrollTop() > 100) {
            $('#scroll-top').fadeIn();
        } else {
            $('#scroll-top').fadeOut();
        }
    });
    
    $('#scroll-top').click(function() {
        $('html, body').animate({scrollTop: 0}, 'slow');
    });
});
EOF

        cat > wp-content/themes/sample-theme/README.md << 'EOF'
# Sample Theme

This is an example theme located in wp-content/themes directory.

## Features

- Responsive design
- WordPress theme standards
- Custom functions
- CSS and JS assets

## Files

- `style.css` - Main stylesheet with theme header
- `index.php` - Main template file
- `functions.php` - Theme functions and hooks
- `assets/` - CSS and JS files

## Installation

This theme is already in the wp-content directory and can be activated from WordPress admin.
EOF

        print_success "Sample theme created in wp-content"
    fi
    
    # Create uploads directory structure
    if [ ! -d "wp-content/uploads" ]; then
        mkdir -p wp-content/uploads
        echo "# WordPress Uploads Directory" > wp-content/uploads/README.md
        echo "This directory will contain uploaded files like images, documents, etc." >> wp-content/uploads/README.md
        print_success "Uploads directory created in wp-content"
    fi
}

# Initialize Composer and WordPress stubs for IDE support
init_composer_and_stubs() {
    print_info "Initializing Composer and WordPress stubs for IDE support..."
    
    # Check if composer is installed
    if ! command -v composer &> /dev/null; then
        print_warning "Composer is not installed. Skipping WordPress stubs installation."
        print_info "To install Composer, visit: https://getcomposer.org/download/"
        return 0
    fi
    
    # Initialize composer.json if it doesn't exist
    if [ ! -f "composer.json" ]; then
        print_info "Creating composer.json..."
        composer init --name="wordpress/dev-environment" \
                     --description="WordPress development environment with stubs" \
                     --type="project" \
                     --no-interaction \
                     --quiet
        print_success "composer.json created"
    else
        print_info "composer.json already exists"
    fi
    
    # Install WordPress stubs for IDE support
    print_info "Installing WordPress stubs for IDE support..."
    if composer require --dev php-stubs/wordpress-stubs --quiet; then
        print_success "WordPress stubs installed successfully"
    else
        print_warning "Failed to install WordPress stubs. You can install them manually later:"
        print_info "  composer require --dev php-stubs/wordpress-stubs"
    fi
}

# Create VS Code settings for WordPress development
create_vscode_settings() {
    print_info "Creating VS Code settings for WordPress development..."
    
    # Create .vscode directory if it doesn't exist
    mkdir -p .vscode
    
    # Create settings.json
    cat > .vscode/settings.json << 'EOF'
{
    "php.validate.executablePath": "/usr/bin/php",
    "php.suggest.basic": false,
    "php.stubs": [
        "wordpress-stubs"
    ],
    "intelephense.stubs": [
        "bcmath",
        "bz2",
        "calendar",
        "Core",
        "curl",
        "date",
        "dba",
        "dom",
        "enchant",
        "exif",
        "fileinfo",
        "filter",
        "ftp",
        "gd",
        "gettext",
        "hash",
        "iconv",
        "imap",
        "intl",
        "json",
        "ldap",
        "libxml",
        "mbstring",
        "mcrypt",
        "mysql",
        "mysqli",
        "password",
        "pcntl",
        "pcre",
        "PDO",
        "pdo_mysql",
        "Phar",
        "readline",
        "recode",
        "Reflection",
        "regex",
        "session",
        "SimpleXML",
        "soap",
        "sockets",
        "sodium",
        "SPL",
        "standard",
        "superglobals",
        "sysvsem",
        "sysvshm",
        "tokenizer",
        "xml",
        "xdebug",
        "xmlreader",
        "xmlwriter",
        "yaml",
        "zip",
        "zlib",
        "wordpress"
    ],
    "intelephense.environment.includePaths": [
        "vendor/php-stubs/wordpress-stubs"
    ],
    "files.associations": {
        "*.php": "php"
    },
    "emmet.includeLanguages": {
        "php": "html"
    },
    "html.format.enable": true,
    "css.validate": true,
    "less.validate": true,
    "scss.validate": true,
    "javascript.validate.enable": true,
    "typescript.validate.enable": true,
    "git.ignoreLimitWarning": true,
    "explorer.excludeGitIgnore": false,
    "search.exclude": {
        "**/node_modules": true,
        "**/vendor": true,
        "**/wordpress-core": true,
        "**/wp-admin": true,
        "**/wp-includes": true,
        "**/*.log": true,
        "**/mysql_data": true,
        "**/data": true
    },
    "files.exclude": {
        "**/.git": true,
        "**/.DS_Store": true,
        "**/node_modules": true,
        "**/vendor": true,
        "**/wordpress-core": true,
        "**/wp-admin": true,
        "**/wp-includes": true,
        "**/*.log": true,
        "**/mysql_data": true
    },
    "php.executablePath": "/usr/bin/php",
    "phpcs.enable": true,
    "phpcs.standard": "WordPress",
    "phpcbf.enable": true,
    "phpcbf.standard": "WordPress",
    "wordpress.path": "./wordpress-core"
}
EOF
    
    print_success "VS Code settings created in .vscode/settings.json"
    print_info "VS Code will now provide better WordPress IntelliSense and autocompletion"
}

# Build environment
build_environment() {
    print_info "Building Docker environment..."
    
    # Stop existing containers
    run_docker_compose down 2>/dev/null || true
    
    # Build images
    run_docker_compose build --no-cache
    
    print_success "Docker environment built"
}

# Start environment
start_environment() {
    print_info "Starting environment..."
    
    run_docker_compose up -d
    
    # Wait for containers to start
    print_info "Waiting for containers to start..."
    sleep 10
    
    # Check status
    if run_docker_compose ps | grep -q "Up"; then
        print_success "Environment started!"
        echo ""
        print_info "Available services:"
        echo "  🌐 WordPress: http://localhost:8080"
        echo "  🗄️  phpMyAdmin: http://localhost:8081"
        echo ""
        print_info "Use ./manage.sh to manage the environment"
    else
        print_error "Error starting environment"
        run_docker_compose logs
        exit 1
    fi
}

# Download and install default theme
download_default_theme() {
    print_info "Downloading default theme (Twenty Twenty-Five)..."
    
    # Check if theme already exists
    if [ -d "wp-content/themes/twentytwentyfive" ]; then
        print_warning "Twenty Twenty-Five theme already exists in wp-content/themes/"
        print_info "If you want to re-download it, remove the directory first:"
        print_info "  rm -rf wp-content/themes/twentytwentyfive"
        return 0
    fi
    
    # Create temporary directory for download
    local temp_dir="temp_theme_download"
    mkdir -p "$temp_dir"
    
    print_info "Downloading Twenty Twenty-Five theme from WordPress.org..."
    
    # Download theme ZIP file
    if command -v curl &> /dev/null; then
        curl -L -o "$temp_dir/twentytwentyfive.zip" "https://downloads.wordpress.org/theme/twentytwentyfive.latest-stable.zip"
    elif command -v wget &> /dev/null; then
        wget -O "$temp_dir/twentytwentyfive.zip" "https://downloads.wordpress.org/theme/twentytwentyfive.latest-stable.zip"
    else
        print_error "Neither curl nor wget found. Please install one of these tools."
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Check if download was successful
    if [ ! -f "$temp_dir/twentytwentyfive.zip" ]; then
        print_error "Failed to download Twenty Twenty-Five theme"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Extract theme to wp-content/themes/
    print_info "Extracting theme to wp-content/themes/..."
    
    # Create themes directory if it doesn't exist
    mkdir -p wp-content/themes
    
    # Extract ZIP file
    if command -v unzip &> /dev/null; then
        unzip -q "$temp_dir/twentytwentyfive.zip" -d wp-content/themes/
    else
        print_error "unzip command not found. Please install unzip."
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Clean up temporary directory
    rm -rf "$temp_dir"
    
    # Verify extraction
    if [ -d "wp-content/themes/twentytwentyfive" ]; then
        print_success "Twenty Twenty-Five theme downloaded and extracted successfully"
        print_info "Theme is now available in wp-content/themes/twentytwentyfive/"
        print_info "You can activate it from WordPress admin after installation"
    else
        print_error "Theme extraction failed"
        return 1
    fi
}

# Main function
main() {
    echo ""
    print_info "Starting WordPress Development environment setup..."
    echo ""
    
    check_requirements
    init_config
    init_directories
    download_wordpress_for_ide
    init_git_structure
    init_composer_and_stubs
    create_vscode_settings
    create_sample_configs
    create_wp_content_examples
    download_default_theme
    build_environment
    start_environment
    init_composer_and_stubs
    create_vscode_settings
    
    echo ""
    print_success "🎉 WordPress Development environment is ready!"
    echo ""
    print_info "Next steps:"
    echo "  1. Go to http://localhost:8080 to complete WordPress installation"
    echo "  2. Activate Twenty Twenty-Five theme in WordPress admin (Appearance > Themes)"
    echo "  3. Install Composer for better IDE support (optional):"
    echo "     - Visit: https://getcomposer.org/download/"
    echo "     - Then run: composer require --dev php-stubs/wordpress-stubs"
    echo "  4. Create new plugins in wp-content/plugins/ directory"
    echo "  5. Create new themes in wp-content/themes/ directory"
    echo "  6. Use ./manage.sh to manage the environment"
    echo ""
    print_info "VS Code users: Settings configured for WordPress development in .vscode/settings.json"
    echo ""
}

# Run main function
main "$@"
