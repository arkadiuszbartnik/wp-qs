# Configuration

This directory contains WordPress configuration files.

## Files

### wp-config.php
Main WordPress configuration file with settings:
- Database connection
- Security keys
- Debug settings
- Additional configurations

### .env.example
Example environment variables file. Copy and customize for your environment:
```bash
# Copy to project root (file will be ignored by Git)
cp config/.env.example .env
```

**Note**: The `.env` file is ignored by Git for security reasons.

## Security

⚠️ **Important**: Before production:
1. Change default database passwords
2. Generate new WordPress keys
3. Disable debug mode
4. Set appropriate file permissions

## Usage

Configuration files are used as follows:
- `wp-config.php` - Tracked in Git, contains WordPress configuration
- `.env` - Created from `.env.example`, ignored by Git for security
