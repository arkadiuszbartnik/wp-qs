#!/bin/bash

# Git Submodules Management Script
# Script for managing submodules for plugins and themes

set -e

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

# Show help
show_help() {
    echo "WordPress Git Submodules Management"
    echo "=================================="
    echo ""
    echo "Usage: $0 <command> [arguments]"
    echo ""
    echo "Available commands:"
    echo "  add-plugin <name> <repo-url>     - Add plugin as submodule"
    echo "  add-theme <name> <repo-url>      - Add theme as submodule"
    echo "  remove-plugin <name>             - Remove plugin submodule"
    echo "  remove-theme <name>              - Remove theme submodule"
    echo "  list                             - List all submodules"
    echo "  update                           - Update all submodules"
    echo "  update-plugin <name>             - Update specific plugin"
    echo "  update-theme <name>              - Update specific theme"
    echo "  status                           - Submodules status"
    echo "  init                             - Initialize submodules after cloning"
    echo "  create-plugin <name>             - Create new plugin with repository"
    echo "  create-theme <name>              - Create new theme with repository"
    echo "  help                             - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 add-plugin my-plugin https://github.com/user/my-plugin.git"
    echo "  $0 add-theme my-theme https://github.com/user/my-theme.git"
    echo "  $0 create-plugin awesome-plugin"
    echo "  $0 update"
    echo ""
}

# Check if this is a Git repo
check_git_repo() {
    if [ ! -d .git ]; then
        print_error "This is not a Git repository!"
        print_info "Run: git init"
        exit 1
    fi
}

# Add plugin as submodule
add_plugin() {
    local name=$1
    local repo_url=$2
    
    if [ -z "$name" ] || [ -z "$repo_url" ]; then
        print_error "Usage: $0 add-plugin <name> <repo-url>"
        exit 1
    fi
    
    local plugin_path="wp-content/plugins/$name"
    
    if [ -d "$plugin_path" ]; then
        print_error "Plugin '$name' already exists!"
        exit 1
    fi
    
    print_info "Adding plugin '$name' as submodule..."
    
    git submodule add "$repo_url" "$plugin_path"
    git submodule init
    git submodule update
    
    print_success "Plugin '$name' added as submodule"
}

# Add theme as submodule
add_theme() {
    local name=$1
    local repo_url=$2
    
    if [ -z "$name" ] || [ -z "$repo_url" ]; then
        print_error "Usage: $0 add-theme <name> <repo-url>"
        exit 1
    fi
    
    local theme_path="wp-content/themes/$name"
    
    if [ -d "$theme_path" ]; then
        print_error "Theme '$name' already exists!"
        exit 1
    fi
    
    print_info "Adding theme '$name' as submodule..."
    
    git submodule add "$repo_url" "$theme_path"
    git submodule init
    git submodule update
    
    print_success "Theme '$name' added as submodule"
}

# Remove plugin submodule
remove_plugin() {
    local name=$1
    
    if [ -z "$name" ]; then
        print_error "Usage: $0 remove-plugin <name>"
        exit 1
    fi
    
    local plugin_path="wp-content/plugins/$name"
    
    if [ ! -d "$plugin_path" ]; then
        print_error "Plugin '$name' does not exist!"
        exit 1
    fi
    
    print_warning "Are you sure you want to remove plugin '$name'? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_info "Cancelled"
        exit 0
    fi
    
    print_info "Removing plugin '$name'..."
    
    git submodule deinit -f "$plugin_path"
    git rm -f "$plugin_path"
    rm -rf ".git/modules/$plugin_path"
    
    print_success "Plugin '$name' removed"
}

# Remove theme submodule
remove_theme() {
    local name=$1
    
    if [ -z "$name" ]; then
        print_error "Usage: $0 remove-theme <name>"
        exit 1
    fi
    
    local theme_path="wp-content/themes/$name"
    
    if [ ! -d "$theme_path" ]; then
        print_error "Theme '$name' does not exist!"
        exit 1
    fi
    
    print_warning "Are you sure you want to remove theme '$name'? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_info "Cancelled"
        exit 0
    fi
    
    print_info "Removing theme '$name'..."
    
    git submodule deinit -f "$theme_path"
    git rm -f "$theme_path"
    rm -rf ".git/modules/$theme_path"
    
    print_success "Theme '$name' removed"
}

# List submodules
list_submodules() {
    print_info "Submodules list:"
    
    if [ -f .gitmodules ]; then
        git submodule status
    else
        print_warning "No submodules"
    fi
}

# Update all submodules
update_all() {
    print_info "Updating all submodules..."
    
    git submodule update --recursive --remote
    
    print_success "Wszystkie submodules zaktualizowane"
}

# Aktualizuj konkretny plugin
update_plugin() {
    local name=$1
    
    if [ -z "$name" ]; then
        print_error "Usage: $0 update-plugin <name>"
        exit 1
    fi
    
    local plugin_path="wp-content/plugins/$name"
    
    if [ ! -d "$plugin_path" ]; then
        print_error "Plugin '$name' nie istnieje!"
        exit 1
    fi
    
    print_info "Aktualizowanie plugin '$name'..."
    
    git submodule update --remote "$plugin_path"
    
    print_success "Plugin '$name' zaktualizowany"
}

# Aktualizuj konkretny theme
update_theme() {
    local name=$1
    
    if [ -z "$name" ]; then
        print_error "Usage: $0 update-theme <name>"
        exit 1
    fi
    
    local theme_path="wp-content/themes/$name"
    
    if [ ! -d "$theme_path" ]; then
        print_error "Theme '$name' nie istnieje!"
        exit 1
    fi
    
    print_info "Aktualizowanie theme '$name'..."
    
    git submodule update --remote "$theme_path"
    
    print_success "Theme '$name' zaktualizowany"
}

# Status submodules
status_submodules() {
    print_info "Status submodules:"
    
    if [ -f .gitmodules ]; then
        git submodule status
        echo ""
        print_info "Details:"
        git submodule foreach 'echo "=== $name ===" && git status --porcelain'
    else
        print_warning "Brak submodules"
    fi
}

# Inicjalizuj submodules (po klonowaniu)
init_submodules() {
    print_info "Inicjalizowanie submodules..."
    
    git submodule init
    git submodule update --recursive
    
    print_success "Submodules zainicjalizowane"
}

# Create new plugin from repository
create_plugin() {
    local name=$1
    
    if [ -z "$name" ]; then
        print_error "Usage: $0 create-plugin <name>"
        exit 1
    fi
    
    local plugin_path="wp-content/plugins/$name"
    
    if [ -d "$plugin_path" ]; then
        print_error "Plugin '$name' already exists!"
        exit 1
    fi
    
    print_info "Creating new plugin '$name'..."
    
    # Create plugin directory
    mkdir -p "$plugin_path"
    
    # Create basic files
    cat > "$plugin_path/$name.php" << EOF
<?php
/**
 * Plugin Name: $name
 * Plugin URI: https://example.com/$name
 * Description: Description of the $name plugin
 * Version: 1.0.0
 * Author: Your Name
 * Author URI: https://example.com
 * License: GPL v2 or later
 * Text Domain: $name
 */

if (!defined('ABSPATH')) {
    exit;
}

// Your plugin code here
EOF
    
    # Create README
    cat > "$plugin_path/README.md" << EOF
# $name

Description of the $name plugin.

## Installation

1. Copy the plugin to the wp-content/plugins/ directory
2. Activate the plugin in the WordPress admin panel

## Usage

Plugin usage instructions.

## Changelog

### 1.0.0
- First version
EOF
    
    # Initialize Git in the plugin directory
    cd "$plugin_path"
    git init
    git add .
    git commit -m "Initial commit for $name plugin"
    cd ../..
    
    print_success "Plugin '$name' created"
    print_info "You can now:"
    print_info "  1. Add remote: cd $plugin_path && git remote add origin <repo-url>"
    print_info "  2. Add as submodule: git submodule add <repo-url> $plugin_path"
}

# Create new theme from repository
create_theme() {
    local name=$1
    
    if [ -z "$name" ]; then
        print_error "Usage: $0 create-theme <name>"
        exit 1
    fi
    
    local theme_path="wp-content/themes/$name"
    
    if [ -d "$theme_path" ]; then
        print_error "Theme '$name' already exists!"
        exit 1
    fi
    
    print_info "Creating new theme '$name'..."
    
    # Create theme directory
    mkdir -p "$theme_path"
    
    # Create style.css
    cat > "$theme_path/style.css" << EOF
/*
Theme Name: $name
Description: Description of the $name theme
Version: 1.0.0
Author: Your Name
Author URI: https://example.com
*/

/* Your CSS styles here */
EOF
    
    # Create index.php
    cat > "$theme_path/index.php" << EOF
<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <?php wp_head(); ?>
</head>
<body <?php body_class(); ?>>
    <header>
        <h1><?php bloginfo('name'); ?></h1>
        <p><?php bloginfo('description'); ?></p>
    </header>
    
    <main>
        <?php if (have_posts()) : ?>
            <?php while (have_posts()) : the_post(); ?>
                <article>
                    <h2><a href="<?php the_permalink(); ?>"><?php the_title(); ?></a></h2>
                    <?php the_content(); ?>
                </article>
            <?php endwhile; ?>
        <?php else : ?>
            <p>No posts found.</p>
        <?php endif; ?>
    </main>
    
    <footer>
        <p>&copy; <?php echo date('Y'); ?> <?php bloginfo('name'); ?></p>
    </footer>
    
    <?php wp_footer(); ?>
</body>
</html>
EOF
    
    # Create functions.php
    cat > "$theme_path/functions.php" << EOF
<?php
/**
 * Functions for $name theme
 */

// Enqueue styles
function ${name}_enqueue_styles() {
    wp_enqueue_style('${name}-style', get_stylesheet_uri());
}
add_action('wp_enqueue_scripts', '${name}_enqueue_styles');

// Theme support
add_theme_support('post-thumbnails');
add_theme_support('title-tag');
add_theme_support('custom-logo');
EOF
    
    # Create README
    cat > "$theme_path/README.md" << EOF
# $name Theme

Description of the $name theme.

## Installation

1. Copy the theme to the wp-content/themes/ directory
2. Activate the theme in the WordPress admin panel

## Features

List of theme features.

## Changelog

### 1.0.0
- First version
EOF
    
    # Initialize Git in the theme directory
    cd "$theme_path"
    git init
    git add .
    git commit -m "Initial commit for $name theme"
    cd ../..
    
    print_success "Theme '$name' created"
    print_info "You can now:"
    print_info "  1. Add remote: cd $theme_path && git remote add origin <repo-url>"
    print_info "  2. Add as submodule: git submodule add <repo-url> $theme_path"
}

# Main function
main() {
    case "$1" in
        "add-plugin")
            check_git_repo
            add_plugin "$2" "$3"
            ;;
        "add-theme")
            check_git_repo
            add_theme "$2" "$3"
            ;;
        "remove-plugin")
            check_git_repo
            remove_plugin "$2"
            ;;
        "remove-theme")
            check_git_repo
            remove_theme "$2"
            ;;
        "list")
            check_git_repo
            list_submodules
            ;;
        "update")
            check_git_repo
            update_all
            ;;
        "update-plugin")
            check_git_repo
            update_plugin "$2"
            ;;
        "update-theme")
            check_git_repo
            update_theme "$2"
            ;;
        "status")
            check_git_repo
            status_submodules
            ;;
        "init")
            check_git_repo
            init_submodules
            ;;
        "create-plugin")
            create_plugin "$2"
            ;;
        "create-theme")
            create_theme "$2"
            ;;
        "help"|"")
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
