# Test Suite Documentation

## Overview
This WordPress development environment includes a comprehensive test suite to verify all functionality.

## Available Test Commands

### 1. `make test` - Basic Environment Test
- Quick check of project structure
- Verifies WordPress core and directories exist
- Tests Docker configuration files
- ~30 seconds execution time

### 2. `make test-suite` - Comprehensive Test Suite
- Full environment setup and teardown
- Tests all major functionality
- Creates sample plugins and themes
- Tests database operations
- Tests build and distribution features
- ~5-10 minutes execution time
- **Interactive** - requires user confirmation

### 3. `make test-all` - Complete Test Runner
- Runs all available tests in sequence
- Includes basic, comprehensive, and additional validation tests
- Tests integration with WordPress
- Validates documentation and permissions
- ~10-15 minutes execution time
- **Interactive** - requires user confirmation

## Test Order and Dependencies

The tests are designed to run in this order:

1. **Environment Structure Test** - Verifies basic project setup
2. **Comprehensive Test Suite** - Full functionality testing
3. **Additional Validation Tests** - Edge cases and integrations
4. **Integration Tests** - WordPress-specific functionality
5. **Documentation Tests** - Verifies documentation completeness

## Running Tests

### Quick Test (Development)
```bash
make test
```

### Full Test Suite (Before Release)
```bash
make test-all
```

### Individual Test Suite
```bash
make test-suite
```

## Test Logs

All tests generate logs in the `logs/` directory:
- `test-environment.log` - Basic environment check
- `test-structure.log` - Project structure validation
- `test-info.log` - Environment information
- `test-status.log` - Docker status
- `test-*.log` - Various component tests

## Test Results

Tests will report:
- ✅ **Pass**: Feature works correctly
- ❌ **Fail**: Feature has issues (needs fixing)
- ⚠️ **Warning**: Feature works but has minor issues (often normal)

## Common Test Failures

### Docker Not Running
```bash
make start
```

### WordPress Not Initialized
Wait 2-3 minutes after starting containers, then retry.

### Missing Dependencies
```bash
make setup
```

### Permission Issues
```bash
chmod +x scripts/*.sh
```

## Continuous Integration

The test suite is designed to be CI-friendly:
- Exit codes indicate success/failure
- Comprehensive logging
- Minimal external dependencies
- Dockerized environment

## Test Coverage

The test suite covers:
- ✅ Environment setup and teardown
- ✅ Docker container management
- ✅ WordPress installation and configuration
- ✅ Plugin creation and management
- ✅ Theme creation and management
- ✅ Database operations
- ✅ Build and distribution system
- ✅ Git submodule management
- ✅ WP-CLI integration
- ✅ File permissions and structure
- ✅ Documentation completeness

## Best Practices

1. **Run tests before commits**: `make test`
2. **Run full suite before releases**: `make test-all`
3. **Check logs on failures**: `ls -la logs/`
4. **Clean environment between tests**: `make clean`
5. **Keep WordPress running during development**: `make start`

## Troubleshooting

### Tests Hang
- Check if Docker is running
- Verify port 8080 and 8081 are free
- Restart Docker: `docker restart`

### Permission Denied
```bash
chmod +x scripts/*.sh
```

### Network Issues
- Check Docker network: `docker network ls`
- Restart containers: `make restart`

### Database Issues
- Reset database: `make clean && make setup`
- Check MySQL logs: `make logs`

## Extending Tests

To add new tests:
1. Add test functions to `scripts/test-all.sh`
2. Update documentation
3. Test the new tests: `make test-all`

## Performance

| Test Type | Duration | Purpose |
|-----------|----------|---------|
| Basic Test | ~30s | Quick validation |
| Test Suite | ~5-10m | Full functionality |
| Complete Test | ~10-15m | Everything |

The test suite is optimized for both speed and completeness.
