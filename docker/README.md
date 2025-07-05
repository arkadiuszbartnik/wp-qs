# Docker Configuration

This directory contains all Docker configuration files for the WordPress environment.

## Files

- `docker-compose.yml` - Main Docker Compose configuration
- `Dockerfile` - WordPress image with additional extensions
- `mysql.Dockerfile` - MySQL image with custom configuration

## Usage

```bash
# From main directory
make start

# Directly from this directory
docker-compose up -d

# Build images
docker-compose build --no-cache
```

## Ports

- **WordPress**: 8080
- **phpMyAdmin**: 8081
- **MySQL**: 3306 (internal only)

## Volumes

- `../wp-content` → `/var/www/html/wp-content` (entire wp-content directory)
- `../data/mysql_data` → `/var/lib/mysql` (ignored by Git)
- `../data/logs/apache` → `/var/log/apache2` (ignored by Git)
