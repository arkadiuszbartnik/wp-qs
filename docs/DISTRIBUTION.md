# Distribution Building

This document describes how to create distribution packages for WordPress plugins and themes.

## Overview

The WordPress Development Monorepo includes tools to create production-ready ZIP files for plugins and themes, automatically removing development files and dependencies.

## Quick Start

```bash
# List available plugins and themes for distribution
./manage.sh list-dist

# Build distribution for a specific plugin
./manage.sh build-dist plugin my-plugin-name

# Build distribution for a specific theme
./manage.sh build-dist theme my-theme-name

# Build distributions for all plugins and themes
./manage.sh build-dist all
```

## Using Makefile

```bash
# List available items and existing distributions
make list-dist

# Build specific plugin
make build-plugin name=my-plugin-name

# Build specific theme
make build-theme name=my-theme-name

# Build all distributions
make build-all
```

## What Gets Removed

During the distribution build process, the following development files are automatically removed:

### Plugin Files Removed:
- `.git*` (Git files and directories)
- `node_modules/` (Node.js dependencies)
- `.DS_Store` (macOS system files)
- `*.log` (Log files)
- `*.tmp` (Temporary files)
- `package.json` (Node.js package file)
- `package-lock.json` (Node.js lock file)
- `yarn.lock` (Yarn lock file)
- `composer.json` (PHP Composer file)
- `composer.lock` (PHP Composer lock file)

### Theme Files Removed (additionally):
- `src/` (Source directories)
- `*.scss` (Sass files)
- `*.less` (Less files)
- `gulpfile.js` (Gulp build file)
- `webpack.config.js` (Webpack config)

## Distribution Structure

Distribution files are created in the `dist/` directory with the following naming convention:

```
dist/
├── plugin-name_YYYYMMDD_HHMMSS.zip
└── theme-name_YYYYMMDD_HHMMSS.zip
```

Example:
```
dist/
├── my-custom-plugin_20250705_230319.zip
└── awesome-theme_20250705_231205.zip
```

## Commands Reference

### manage.sh Commands

| Command | Description | Example |
|---------|-------------|---------|
| `build-dist plugin <name>` | Build distribution for specific plugin | `./manage.sh build-dist plugin my-plugin` |
| `build-dist theme <name>` | Build distribution for specific theme | `./manage.sh build-dist theme my-theme` |
| `build-dist all` | Build distributions for all plugins and themes | `./manage.sh build-dist all` |
| `list-dist` | List available items and existing distributions | `./manage.sh list-dist` |

### Makefile Commands

| Command | Description | Example |
|---------|-------------|---------|
| `make build-plugin name=<name>` | Build distribution for specific plugin | `make build-plugin name=my-plugin` |
| `make build-theme name=<name>` | Build distribution for specific theme | `make build-theme name=my-theme` |
| `make build-all` | Build distributions for all plugins and themes | `make build-all` |
| `make list-dist` | List available items and existing distributions | `make list-dist` |

## Best Practices

1. **Test Before Distribution**: Always test your plugin/theme thoroughly before creating a distribution.

2. **Version Management**: Consider updating version numbers in your plugin/theme files before building distribution.

3. **Clean Builds**: The system automatically removes development files, but ensure your production code doesn't rely on them.

4. **Documentation**: Keep README files as they are included in distributions and provide valuable information to users.

5. **Asset Optimization**: Consider optimizing CSS/JS files before building distribution.

## Plugin Structure Example

```
wp-content/plugins/my-plugin/
├── my-plugin.php           ✅ Included
├── README.md              ✅ Included
├── assets/
│   ├── style.css          ✅ Included
│   └── script.js          ✅ Included
├── package.json           ❌ Removed
├── node_modules/          ❌ Removed
└── .git/                  ❌ Removed
```

## Theme Structure Example

```
wp-content/themes/my-theme/
├── index.php              ✅ Included
├── style.css              ✅ Included
├── functions.php          ✅ Included
├── README.md              ✅ Included
├── src/                   ❌ Removed
├── *.scss                 ❌ Removed
├── package.json           ❌ Removed
├── webpack.config.js      ❌ Removed
└── node_modules/          ❌ Removed
```

## Troubleshooting

### ZIP Command Not Found
If you get an error about `zip` command not being found:
```bash
# On macOS (should be pre-installed)
xcode-select --install

# On Ubuntu/Debian
sudo apt-get install zip

# On CentOS/RHEL
sudo yum install zip
```

### Permission Issues
If you encounter permission issues:
```bash
# Ensure you have write permissions to the dist directory
chmod 755 dist/
```

### No Plugins/Themes Found
The system only packages plugins and themes that:
- Exist in `wp-content/plugins/` or `wp-content/themes/`
- Are not hidden directories (don't start with `.`)
- Are not sample directories (don't start with `sample-`)

## Integration with CI/CD

You can integrate distribution building into your CI/CD pipeline:

```yaml
# Example GitHub Actions workflow
- name: Build Distributions
  run: |
    cd wordpress-project
    ./manage.sh build-dist all
    
- name: Upload Distributions
  uses: actions/upload-artifact@v3
  with:
    name: distributions
    path: dist/*.zip
```

This allows for automated building and deployment of your WordPress plugins and themes.
