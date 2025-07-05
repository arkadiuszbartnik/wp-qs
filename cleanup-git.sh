#!/bin/bash
# Script to clean Git cache and prepare new structure

echo "🧹 Cleaning Git cache..."

# Remove all files from index
git rm -r --cached . 2>/dev/null || true

# Add files according to new structure
echo "📂 Adding files according to new structure..."

# Basic project files
git add README.md
git add Makefile
git add .gitignore

# Configuration
git add config/
git add docker/
git add scripts/

# Documentation
git add docs/

# Directory structure (only README and .gitkeep)
git add wp-content/index.php
git add wp-content/plugins/README.md
git add wp-content/plugins/.gitkeep
git add wp-content/themes/README.md
git add wp-content/themes/.gitkeep
git add wp-content/uploads/.gitkeep

# Data structure
git add data/backups/.gitkeep
git add data/logs/apache/.gitkeep
git add data/logs/mysql/.gitkeep
git add data/README.md

echo "✅ Structure prepared!"
echo ""
echo "📋 Next steps:"
echo "1. Add plugins as submodules:"
echo "   make plugin-add name=my-plugin url=https://github.com/user/plugin.git"
echo ""
echo "2. Add themes as submodules:"
echo "   make theme-add name=my-theme url=https://github.com/user/theme.git"
echo ""
echo "3. Commit new structure:"
echo "   git commit -m 'feat: reorganized project structure with proper submodules support'"
