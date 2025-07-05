# WordPress Development Monorepo

Monorepo for WordPress development environment with plugin and theme separation.

## 🏗️ Architecture

- **Monorepo** - Main repository for environment
- **WordPress Core** - Automatically downloaded in Docker
- **Plugins** - Separate repositories as Git submodules
- **Themes** - Separate repositories as Git submodules
- **Configuration** - Managed in monorepo

## 📁 Structure

```
wordpress-monorepo/
├── docker/               # Docker configuration
├── scripts/              # Helper scripts  
├── config/               # WordPress configuration
├── wp-content/           # WordPress content
│   ├── plugins/          # Custom plugins (submodules)
│   ├── themes/           # Custom themes (submodules)
│   └── uploads/          # User files (ignored)
├── wordpress-core/       # WordPress core (ignored, for IDE)
├── data/                 # Application data (mostly ignored)
│   ├── backups/          # Database backups
│   ├── mysql_data/       # MySQL data (ignored)
│   └── logs/             # Application logs (ignored)
├── docs/                 # Documentation
├── Makefile              # Make commands
└── README.md            # Main documentation
```

**Note**: Files marked as "(ignored)" are not tracked by Git but created automatically.

## 🚀 Quick Start

### First installation
```bash
# Clone monorepo
git clone <repo-url> wordpress-project
cd wordpress-project

# Initialize environment
make setup

# Start WordPress
make start
```

### Existing project
```bash
# Clone with submodules
git clone --recursive <repo-url> wordpress-project
cd wordpress-project

# Initialize submodules
make submodules-init

# Start WordPress
make start
```

## 🔧 Environment Management

### Basic commands
```bash
# Start WordPress
make start

# Stop WordPress
make stop

# Show status
make status

# Logs
make logs

# Restart
make restart
```

### Backup and restore
```bash
# Database backup
make backup

# Restore from backup
make restore file=backup_20240101_120000.sql

# WP-CLI commands
make wp cmd="core version"
```

# List users
./manage.sh wp 'user list'

# Install plugin
./manage.sh wp 'plugin install akismet --activate'

# WordPress shell
./manage.sh shell
```

## 🧩 Plugin Management

### Adding plugin
```bash
# Create new plugin
./git-submodules.sh create-plugin my-awesome-plugin

# Add existing plugin as submodule
./git-submodules.sh add-plugin existing-plugin https://github.com/user/plugin.git
```

### Plugin updates
```bash
# Update all plugins
./git-submodules.sh update

# Update specific plugin
./git-submodules.sh update-plugin my-plugin
```

### Removing plugin
```bash
# Remove plugin submodule
./git-submodules.sh remove-plugin my-plugin
```

## 🎨 Theme Management

### Adding theme
```bash
# Create new theme
./git-submodules.sh create-theme my-awesome-theme

# Add existing theme as submodule
./git-submodules.sh add-theme existing-theme https://github.com/user/theme.git
```

### Theme updates
```bash
# Update all themes
./git-submodules.sh update

# Update specific theme
./git-submodules.sh update-theme my-theme
```

## 📊 Status and Monitoring

```bash
# Submodule status
./git-submodules.sh status

# List submodules
./git-submodules.sh list

# Container status
./manage.sh status

# Application logs
./manage.sh logs
```

## 🌐 Application Access

- **WordPress**: http://localhost:8080
- **phpMyAdmin**: http://localhost:8081

## ⚙️ Configuration

### Environment variables
```bash
# Copy example file
cp .env.example .env

# Edit configuration
nano .env
```

### Default database settings
- **Database name**: wordpress
- **User**: wordpress
- **Password**: wordpress_password
- **Host**: db

### Security
⚠️ **Important**: Change default passwords before using in production environment!

## 📊 Logs and Debugging

### Available logs
```bash
# Docker container logs
./manage.sh logs

# Apache logs (access)
./manage.sh logs apache

# Apache error logs
./manage.sh logs apache-error

# MySQL error logs
./manage.sh logs mysql

# MySQL general query logs
./manage.sh logs mysql-general

# MySQL slow query logs
./manage.sh logs mysql-slow
```

### Log locations
- **Apache**: `logs/apache/` (access.log, error.log)
- **MySQL**: `logs/mysql/` (error.log, general.log, slow.log)

**Note**: MySQL logs are copied from the container with each `logs mysql*` command call.

### Manual MySQL log copying
```bash
# Copy current logs from MySQL container
./mysql-logs.sh copy-mysql-logs
```

## 🔄 Development Workflow

### New plugin
1. Create new plugin: `./git-submodules.sh create-plugin my-plugin`
2. Add code to `plugins/my-plugin/`
3. Create Git repo: `cd plugins/my-plugin && git remote add origin <repo-url>`
4. Add as submodule: `./git-submodules.sh add-plugin my-plugin <repo-url>`

### New theme
1. Create new theme: `./git-submodules.sh create-theme my-theme`
2. Add code to `themes/my-theme/`
3. Create Git repo: `cd themes/my-theme && git remote add origin <repo-url>`
4. Add as submodule: `./git-submodules.sh add-theme my-theme <repo-url>`

### Team collaboration
1. Clone with submodules: `git clone --recursive <repo-url>`
2. Update submodules: `./git-submodules.sh update`
3. Work on plugins/themes in their directories
4. Commit changes to respective repositories

## 🚀 Benefits of This Architecture

### Code separation
- **WordPress Core** - Doesn't clutter the repo
- **Plugins** - Separate repositories, independent versioning
- **Themes** - Separate repositories, independent versioning
- **Configuration** - Centralized in monorepo

### Workflow
- **Hot reload** - Changes immediately visible
- **Independence** - Each plugin/theme has its own repo
- **Easy management** - Automation scripts
- **Team collaboration** - Different teams can work on different plugins

### Deployment
- **Dev environment** - Full environment in Docker
- **CI/CD** - Each plugin/theme can have its own pipeline
- **Testing** - Isolated component testing

## 📋 All Available Commands

### manage.sh
```bash
./manage.sh help
```

### git-submodules.sh
```bash
./git-submodules.sh help
```

### setup.sh
```bash
./setup.sh  # Environment initialization
```

## 🐛 Debugging

```bash
# Container logs
./manage.sh logs

# Submodule status
./git-submodules.sh status

# Enter container
./manage.sh shell

# Check WordPress status
./manage.sh wp 'core version'
```

## 📁 File Structure for Versioning

### In main repo (monorepo)
```
├── docker-compose.yml    ✅ Versioned
├── Dockerfile           ✅ Versioned
├── wp-config.php        ✅ Versioned
├── manage.sh            ✅ Versioned
├── setup.sh             ✅ Versioned
├── git-submodules.sh    ✅ Versioned
├── .gitmodules          ✅ Versioned (submodules)
├── plugins/             ✅ Versioned (submodules)
├── themes/              ✅ Versioned (submodules)
├── uploads/             ❌ Not versioned (user data)
├── backups/             ❌ Not versioned (backups)
└── mysql_data/          ❌ Not versioned (database)
```

### In plugin/theme repositories
```
plugin-name/
├── plugin-name.php      ✅ Versioned
├── assets/              ✅ Versioned
├── includes/            ✅ Versioned
├── languages/           ✅ Versioned
├── README.md           ✅ Versioned
└── .git/               ✅ Separate repo
```

## 🤝 Collaboration

### For new developers
1. Clone repo: `git clone --recursive <repo-url>`
2. Run setup: `./setup.sh`
3. Start work: `./manage.sh start`

### Adding new plugin to team
1. Create plugin: `./git-submodules.sh create-plugin team-plugin`
2. Create repo on GitHub/GitLab
3. Add as submodule: `./git-submodules.sh add-plugin team-plugin <repo-url>`
4. Inform team about new submodule

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [WordPress Codex](https://codex.wordpress.org/)
- [WP-CLI Documentation](https://wp-cli.org/)
- [Git Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

## WordPress Core for IDE

### Why do we need WordPress core locally?

**WordPress core is ESSENTIAL for plugin development!** Without it, your IDE won't have:
- ✅ WordPress function autocompletion (`add_action`, `get_post_meta`, `wp_enqueue_script`)
- ✅ IntelliSense for WordPress classes and methods
- ✅ Syntax and type validation
- ✅ Navigation to function definitions
- ✅ Function documentation (phpdoc)

### How does it work in our monorepo?

1. **WordPress core is available locally** - all files (`wp-includes/`, `wp-admin/`, etc.) are present in the working directory
2. **But not tracked by Git** - core files are ignored by `.gitignore`
3. **Downloaded automatically** - during environment setup or in Docker container

### Downloading WordPress core

```bash
# Automatically during setup
./setup.sh

# Or manually
curl -O https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
mv wordpress/* ./
rm -rf wordpress latest.tar.gz
```

### Updating WordPress core

```bash
# Update WordPress version for IDE
./manage.sh update_wordpress_core
```

### Testing autocompletion

Check the file `plugins/ide-test-plugin/ide-test-plugin.php` - it contains WordPress function examples:
- `add_action()`, `add_filter()`, `add_shortcode()`
- `get_post_meta()`, `wp_enqueue_script()`, `wp_create_nonce()`
- `esc_html()`, `esc_attr()`, `wp_kses_post()`
- `current_user_can()`, `wp_get_current_user()`

In VS Code or PhpStorm you should have full autocompletion for these functions.
