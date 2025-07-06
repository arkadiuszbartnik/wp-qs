# WordPress Development Environment - Test Suite

## Quick Start

### Run All Tests
```bash
make test-all
```

This script will execute all tests in sequence:
1. **Environment Structure Test** - checks basic configuration
2. **Comprehensive Functionality Test** - tests all components
3. **Additional Validation Tests** - checks integration and details
4. **WordPress Integration Tests** - WP-CLI functionality
5. **Documentation Tests** - verifies documentation completeness

### Available Test Commands

| Command | Duration | Description |
|---------|----------|-------------|
| `make test` | ~30s | Quick structure test |
| `make test-suite` | ~5-10min | Full functionality test |
| `make test-all` | ~10-15min | All tests in sequence |

## What the Script Tests

### 1. Environment Structure Test
- ✅ Checks if WordPress core is available
- ✅ Verifies .gitignore configuration
- ✅ Checks plugins and themes directories
- ✅ Tests Docker configuration

### 2. Comprehensive Functionality Test
- ✅ Sets up complete environment from scratch
- ✅ Creates sample plugins and themes
- ✅ Tests database operations
- ✅ Checks build and distribution system
- ✅ Tests Git submodule management

### 3. Integration Tests
- ✅ Checks WordPress connection via WP-CLI
- ✅ Tests plugin installation and activation
- ✅ Verifies theme functionality
- ✅ Checks database status

### 4. Additional Tests
- ✅ Checks file permissions
- ✅ Tests Git configuration
- ✅ Verifies documentation
- ✅ Checks help system

## Test Results

The script will show:
- ✅ **Success**: Functionality works correctly
- ❌ **Error**: Functionality needs fixing
- ⚠️ **Warning**: Functionality works but has minor issues

## Test Logs

All tests save logs in the `logs/` directory:
- `test-environment.log` - Basic test
- `test-structure.log` - Structure test
- `test-wp-*.log` - WordPress tests
- `test-*.log` - Other tests

## Troubleshooting

### Docker is not running
```bash
make start
```

### WordPress is not initialized
Wait 2-3 minutes after starting containers, then try again.

### Missing dependencies
```bash
make setup
```

### Permission issues
```bash
chmod +x scripts/*.sh
```

## Usage Examples

### Before starting work (first time)
```bash
# Full environment test
make test-all
```

### During development (daily)
```bash
# Quick test
make test
```

### Before release
```bash
# All tests
make test-all
```

## Automation

The `test-all.sh` script is designed to:
- Automatically run all tests
- Collect detailed logs
- Report results
- Clean up environment

## CI/CD Integration

The script is prepared for CI/CD systems:
- Returns appropriate exit codes
- Generates detailed logs
- Minimal external dependencies
- Dockerized environment

## More Information

Detailed documentation: `docs/testing.md`
