# WordPress Development Monorepo

🚀 Modern WordPress development environment with plugin and theme separation.

## 📋 Quick Start

```bash
# Clone repository
git clone --recursive <repo-url> wordpress-project
cd wordpress-project

# Start environment
make setup
make start
```

## 🎯 Main Commands

| Command | Description |
|---------|-------------|
| `make help` | Show all available commands |
| `make start` | Start WordPress |
| `make stop` | Stop WordPress |
| `make restart` | Restart WordPress |
| `make status` | Container status |
| `make logs` | Show logs |
| `make shell` | Enter container |
| `make test` | Test environment |

## 🧩 Plugin Management

```bash
# Create new plugin
make plugin-create name=my-awesome-plugin

# Add existing plugin
make plugin-add name=existing-plugin url=https://github.com/user/plugin.git

# Update plugin
make plugin-update name=my-plugin

# Remove plugin
make plugin-remove name=my-plugin
```

## 🎨 Theme Management

```bash
# Create new theme
make theme-create name=my-theme

# Add existing theme
make theme-add name=existing-theme url=https://github.com/user/theme.git

# Update theme
make theme-update name=my-theme

# Remove theme
make theme-remove name=my-theme
```

## 🔗 Submodules

```bash
# Initialize submodules
make submodules-init

# Update all submodules
make submodules-update

# Submodules status
make submodules-status

# List submodules
make submodules-list
```

## 🗄️ Database

```bash
# Database backup
make backup

# Restore from backup
make restore file=backup_20240101.sql

# WP-CLI commands
make wp cmd="core version"
make wp cmd="user list"
make wp-install-plugin name=akismet
make wp-user-create user=admin email=admin@example.com
```

## 🌐 Access

- **WordPress**: http://localhost:8080
- **phpMyAdmin**: http://localhost:8081

## 📁 Project Structure

```
wordpress-monorepo/
├── docker/               # Docker configuration
│   ├── docker-compose.yml
│   ├── Dockerfile
│   └── mysql.Dockerfile
├── scripts/              # Management scripts
│   ├── manage.sh
│   ├── setup.sh
│   └── git-submodules.sh
├── config/               # WordPress configuration
│   ├── wp-config.php
│   └── .env.example
├── wp-content/           # WordPress content
│   ├── plugins/          # Custom plugins (submodules)
│   │   ├── README.md
│   │   └── .gitkeep
│   ├── themes/           # Custom themes (submodules)
│   │   ├── README.md
│   │   └── .gitkeep
│   └── uploads/          # Uploaded files (ignored)
│       └── .gitkeep
├── wordpress-core/       # WordPress core (ignored, for IDE)
├── data/                 # Application data (mostly ignored)
│   ├── backups/
│   │   └── .gitkeep
│   ├── mysql_data/       # (ignored)
│   └── logs/             # (ignored)
│       ├── apache/
│       └── mysql/
├── docs/                 # Documentation
├── Makefile              # Make commands
└── README.md             # This documentation
```

**Note**: Files marked as "(ignored)" are not tracked by Git but will be created automatically.

## 🚀 Development Workflow

### Starting work
```bash
make dev-start    # Full environment start
make dev-logs     # Logs in follow mode
```

### Working with plugins
```bash
# Create plugin
make plugin-create name=my-plugin

# Work in wp-content/plugins/my-plugin/
cd wp-content/plugins/my-plugin/
# ... plugin code ...
git add . && git commit -m "Feature: new functionality"
git push origin main

# Return to main repo and update submodule
cd ../..
git add wp-content/plugins/my-plugin
git commit -m "Update my-plugin submodule"
```

### Team collaboration
```bash
# New developer
git clone --recursive <repo-url>
make dev-start

# Update submodules
make submodules-update
```

## 🔧 Configuration

### Environment variables
```bash
# Copy template and customize (file will be ignored by Git)
cp config/.env.example .env
# Edit .env according to your needs
```

**Note**: The `.env` file is ignored by Git for security reasons.

### Default settings
- **DB Name**: wordpress
- **DB User**: wordpress  
- **DB Password**: wordpress_password
- **DB Host**: db

## 📊 Monitoring and Debugging

```bash
# Environment status
make status
make test

# Application logs
make logs
make dev-logs    # Follow mode

# Container access
make shell

# Environment information
make info
make structure
```

## 🤝 Collaboration

### For new developers
1. `git clone --recursive <repo-url>`
2. `make dev-start`
3. Open http://localhost:8080

### Adding new components
1. Create plugin/theme: `make plugin-create name=new-component`
2. Create repo on GitHub/GitLab
3. Add as submodule: `make plugin-add name=new-component url=<repo-url>`
4. Inform the team

## 📚 Documentation

- **Detailed documentation**: [docs/detailed-readme.md](docs/detailed-readme.md)
- **Docker configuration**: [docker/README.md](docker/README.md)
- **Scripts**: [scripts/README.md](scripts/README.md)
- **Distribution building**: [docs/DISTRIBUTION.md](docs/DISTRIBUTION.md)

## 📦 Distribution Building

Create production-ready ZIP packages for plugins and themes:

```bash
# List available plugins and themes
make list-dist

# Build specific plugin distribution
make build-plugin name=my-plugin

# Build specific theme distribution  
make build-theme name=my-theme

# Build all distributions
make build-all
```

**Features:**
- Automatically removes development files (`package.json`, `node_modules`, `.git`, etc.)
- Creates timestamped ZIP files in `dist/` directory
- Includes only production-ready files
- Perfect for WordPress.org submissions or client delivery

See [docs/DISTRIBUTION.md](docs/DISTRIBUTION.md) for detailed documentation.

## 🎯 Benefits

✅ **Separation**: WordPress core, plugins, themes in separate repositories  
✅ **Automation**: Scripts for environment management  
✅ **Workflow**: Streamlined development workflow  
✅ **Team**: Easy team collaboration  
✅ **CI/CD**: Each component can have its own pipeline  
✅ **IDE**: Full WordPress autocompletion support  

---

**Need help?** Run `make help` to see all available commands.
