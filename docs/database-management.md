# WordPress Database Management Guide

## Overview
This guide covers all database management commands available in the WordPress development environment.

## Quick Start

### Install WordPress Database
```bash
# Quick install with default settings
make wp-install-quick

# Custom install with your settings
make wp-install url=localhost:8080 title="My WordPress Site" admin=myuser pass=mypass123 email=admin@example.com
```

### Check Database Status
```bash
make db-check      # Quick connection check
make db-status     # Detailed status
make db-test       # Run test queries
```

## Available Commands

### WordPress Installation Commands

| Command | Description | Parameters |
|---------|-------------|------------|
| `make wp-install-quick` | Quick install with defaults | None |
| `make wp-install` | Custom install | `url`, `title`, `admin`, `pass`, `email` |
| `make wp-status` | Check WordPress status | None |
| `make wp-info` | Show WordPress info | None |
| `make wp-reset` | Reset WordPress (DANGEROUS) | None |

### Database Management Commands

| Command | Description | Use Case |
|---------|-------------|----------|
| `make db-check` | Check database connection | Quick health check |
| `make db-create` | Create WordPress database | Initial setup |
| `make db-drop` | Drop database (DANGEROUS) | Complete reset |
| `make db-reset` | Reset database (DANGEROUS) | Clean slate |
| `make db-info` | Show database information | Size, tables |
| `make db-status` | Detailed database status | Full overview |
| `make db-test` | Test database queries | Troubleshooting |
| `make db-optimize` | Optimize database | Performance |
| `make backup` | Create database backup | Before changes |
| `make restore` | Restore from backup | Recovery |

### Helper Commands

| Command | Description |
|---------|-------------|
| `make db-help` | Show all database commands |
| `make help` | Show all available commands |

## Usage Examples

### Initial Setup
```bash
# Start environment
make start

# Install WordPress with custom settings
make wp-install url=localhost:8080 title="My Blog" admin=admin pass=secure123 email=admin@myblog.com

# Check installation
make wp-status
```

### Development Workflow
```bash
# Check database connection
make db-check

# View database status
make db-status

# Create backup before changes
make backup

# Make your changes...

# Restore if needed
make restore file=backup.sql
```

### Troubleshooting
```bash
# Test database connectivity
make db-test

# Check WordPress status
make wp-status

# View detailed database information
make db-info

# Reset if corrupted (DANGEROUS)
make wp-reset
```

## Parameters Reference

### wp-install Parameters
- `url` - WordPress site URL (default: localhost:8080)
- `title` - Site title (default: WordPress Development)
- `admin` - Admin username (default: admin)
- `pass` - Admin password (default: admin123)
- `email` - Admin email (default: admin@example.com)

### Examples
```bash
# Development site
make wp-install url=localhost:8080 title="Dev Site" admin=dev pass=dev123 email=dev@example.com

# Production-like setup
make wp-install url=mysite.local title="My Production Site" admin=administrator pass=strong_password_123 email=admin@mysite.com
```

## Database Connection Issues

### Common Problems and Solutions

#### MySQL Client Not Found
```bash
# This error is normal and handled automatically
/usr/bin/env: 'mysqlcheck': No such file or directory
```
The system automatically falls back to WordPress core checks.

#### Connection Refused
```bash
# Check if containers are running
make status

# Restart containers
make restart

# Check logs
make logs
```

#### WordPress Not Installed
```bash
# Check if WordPress is installed
make wp-status

# Install if needed
make wp-install-quick
```

## Security Notes

### Dangerous Commands
These commands will **permanently delete data**:
- `make db-drop` - Drops entire database
- `make db-reset` - Resets WordPress database
- `make wp-reset` - Resets WordPress installation

All dangerous commands require confirmation before execution.

### Default Credentials
The quick install uses these defaults:
- Username: `admin`
- Password: `admin123`
- Email: `admin@example.com`

**Always change these in production!**

## Backup and Recovery

### Create Backup
```bash
make backup
```
Creates timestamped backup in `data/backups/`

### Restore from Backup
```bash
make restore file=backup_20240706_123456.sql
```

### Automatic Backups
Add to your workflow:
```bash
# Before major changes
make backup

# Make changes
# ...

# If something goes wrong
make restore file=latest_backup.sql
```

## Integration with Development

### Before Plugin Development
```bash
make db-check      # Ensure database is working
make wp-status     # Check WordPress status
make backup        # Create safety backup
```

### After Plugin Changes
```bash
make db-test       # Test database queries
make db-optimize   # Optimize performance
```

### Before Release
```bash
make db-status     # Full database check
make backup        # Create release backup
```

## Monitoring and Maintenance

### Daily Checks
```bash
make db-check      # Quick health check
make status        # Container status
```

### Weekly Maintenance
```bash
make db-optimize   # Optimize database
make backup        # Create backup
make db-status     # Review status
```

### Monthly Cleanup
```bash
# Clean old backups
ls -la data/backups/

# Optimize database
make db-optimize

# Review logs
make logs
```

## Advanced Usage

### Custom Database Queries
```bash
# Using WP-CLI directly
make wp cmd="db query 'SELECT * FROM wp_options LIMIT 5'"

# Check specific table
make wp cmd="db query 'DESCRIBE wp_posts'"
```

### Database Size Monitoring
```bash
# Human readable size
make db-info

# Detailed status
make db-status
```

### Performance Optimization
```bash
# Optimize all tables
make db-optimize

# Check database size after optimization
make db-info
```

## Troubleshooting Guide

### Database Won't Start
1. Check Docker containers: `make status`
2. Check logs: `make logs`
3. Restart containers: `make restart`

### WordPress Installation Fails
1. Check database connection: `make db-check`
2. Check if database exists: `make db-create`
3. Try again: `make wp-install-quick`

### Connection Issues
1. Verify containers are running: `make status`
2. Check environment variables: `cat .env`
3. Restart environment: `make restart`

### Performance Issues
1. Optimize database: `make db-optimize`
2. Check database size: `make db-info`
3. Review logs: `make logs`

## Best Practices

1. **Always backup before major changes**
2. **Use wp-install-quick for development**
3. **Use custom parameters for production-like setups**
4. **Regularly check database status**
5. **Optimize database periodically**
6. **Monitor database size growth**
7. **Use meaningful backup names**
8. **Test connection after environment changes**

This guide provides comprehensive coverage of all database management features in the WordPress development environment.
