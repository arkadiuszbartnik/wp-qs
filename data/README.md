# Data

This directory contains all WordPress application data.

## Structure

### backups/
Database backups:
- Automatic backups via `make backup`
- SQL files with date-based names (ignored by Git)
- Used by `make restore`
- Only `.gitkeep` is tracked in Git

### mysql_data/
MySQL database data:
- Persistent data storage (ignored by Git)
- Automatically created by MySQL
- Should not be modified manually

### logs/
Application logs:
- `apache/` - Apache server logs (ignored by Git)
- `mysql/` - MySQL database logs (ignored by Git)
- Automatically rotated
- Only `.gitkeep` files are tracked

## Management

```bash
# Backup
make backup

# Restore
make restore file=backup_20240101.sql

# Logs
make logs
```

## Security

⚠️ **Important**: 
- `mysql_data/` directory is not versioned (ignored by Git)
- `*.sql` backup files are not versioned (ignored by Git)
- `*.log` files are not versioned (ignored by Git)
- Only directory structure and `.gitkeep` files are tracked

## Uprawnienia

Make sure the container has write permissions:
```bash
sudo chown -R www-data:www-data data/uploads/
sudo chmod -R 755 data/uploads/
```
