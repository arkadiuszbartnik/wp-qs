# PHP Configuration

This directory contains custom PHP configuration for the WordPress development environment.

## Files

- `custom.ini` - Custom PHP settings that override defaults

## Configuration Details

### Upload Limits
- `upload_max_filesize = 256M` - Maximum file upload size
- `post_max_size = 256M` - Maximum POST data size
- `max_input_vars = 3000` - Maximum input variables

### Execution Limits
- `max_execution_time = 300` - Maximum script execution time (5 minutes)
- `memory_limit = 512M` - Maximum memory per script

### Error Reporting
- Enabled for development with detailed error reporting
- Logs stored in `data/logs/php/php_errors.log`

### Performance
- OPcache enabled for better PHP performance
- Optimized for WordPress development

## Modifying Configuration

1. Edit `config/php/custom.ini`
2. Restart containers: `make restart`
3. Verify changes: `make wp cmd="eval 'phpinfo();'"` or access phpinfo via WordPress

## Production Notes

For production environments, adjust:
- Disable `display_errors`
- Set appropriate `error_reporting` level
- Review security settings
- Adjust memory and execution limits based on needs
