#!/bin/bash
# Test WordPress monorepo environment

# Check if we're in the scripts directory or main directory
if [ -f "../wp-content/plugins/README.md" ]; then
    # We're in the scripts directory
    PLUGINS_DIR="../wp-content/plugins"
    THEMES_DIR="../wp-content/themes"
    DATA_DIR="../data"
    DOCKER_DIR="../docker"
    WP_CORE_DIR="../wordpress-core"
    PREFIX="../"
elif [ -f "wp-content/plugins/README.md" ]; then
    # We're in the main directory
    PLUGINS_DIR="wp-content/plugins"
    THEMES_DIR="wp-content/themes"
    DATA_DIR="data"
    DOCKER_DIR="docker"
    WP_CORE_DIR="wordpress-core"
    PREFIX=""
else
    echo "❌ Cannot find project directories"
    exit 1
fi

echo "=== Test WordPress monorepo environment ==="
echo ""

# Check WordPress core
echo "1. Checking WordPress core..."
if [ -f "${WP_CORE_DIR}/wp-load.php" ] && [ -f "${WP_CORE_DIR}/wp-includes/functions.php" ]; then
    echo "✅ WordPress core available locally in ${WP_CORE_DIR}/"
else
    echo "❌ WordPress core unavailable - run ./setup.sh"
    exit 1
fi

# Check if WordPress core is ignored by Git
echo "2. Checking .gitignore..."
if git check-ignore ${WP_CORE_DIR}/wp-includes/functions.php >/dev/null 2>&1; then
    echo "✅ WordPress core ignored by Git"
else
    echo "❌ WordPress core not ignored by Git"
fi

# Check plugins
echo "3. Checking plugins..."
if [ -d "$PLUGINS_DIR" ] && [ -f "$PLUGINS_DIR/README.md" ]; then
    echo "✅ Plugins directory exists"
    plugin_count=$(find $PLUGINS_DIR -name "*.php" -type f | wc -l)
    echo "   Found $plugin_count PHP files in plugins"
else
    echo "❌ Plugins directory does not exist"
fi

# Check themes
echo "4. Checking themes..."
if [ -d "$THEMES_DIR" ] && [ -f "$THEMES_DIR/README.md" ]; then
    echo "✅ Themes directory exists"
else
    echo "❌ Themes directory does not exist"
fi

# Check logs
echo "5. Checking log directories..."
if [ -d "$DATA_DIR/logs/apache" ] && [ -d "$DATA_DIR/logs/mysql" ]; then
    echo "✅ Log directories exist"
else
    echo "❌ Log directories do not exist"
fi

# Check MySQL data
echo "6. Checking mysql_data directory..."
if [ -d "$DATA_DIR/mysql_data" ]; then
    echo "✅ mysql_data directory exists"
else
    echo "❌ mysql_data directory does not exist"
fi

# Check Docker
echo "7. Checking Docker..."
if [ -f "$DOCKER_DIR/docker-compose.yml" ] && [ -f "$DOCKER_DIR/Dockerfile" ]; then
    echo "✅ Docker files exist"
else
    echo "❌ Docker files do not exist"
fi

echo ""
echo "=== Summary ==="
echo "WordPress monorepo environment configured!"
echo ""
echo "Next steps:"
echo "1. Run Docker: docker-compose up -d"
echo "2. Open VS Code/PhpStorm and check autocompletion in plugins"
echo "3. Check logs: ./manage.sh logs"
echo ""
echo "Example files for testing IDE:"
echo "- ${PLUGINS_DIR}/ide-test-plugin/ide-test-plugin.php"
echo "- ${PLUGINS_DIR}/sample-plugin/sample-plugin.php"
