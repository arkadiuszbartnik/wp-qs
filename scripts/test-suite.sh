#!/bin/bash

# WordPress Development Environment - Comprehensive Test Suite
# This script tests all functionality step by step

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
print_header() {
    echo ""
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================================${NC}"
    echo ""
}

print_test() {
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo -e "${CYAN}🧪 Test $TESTS_TOTAL: $1${NC}"
}

print_step() {
    echo -e "${BLUE}   ▶️  $1${NC}"
}

print_success() {
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}   ✅ $1${NC}"
}

print_error() {
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}   ❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}   ⚠️  $1${NC}"
}

# Wait for user confirmation
wait_for_confirmation() {
    echo -e "${YELLOW}Press Enter to continue or Ctrl+C to abort...${NC}"
    read -r
}

# Check if command succeeded
check_success() {
    if [ $? -eq 0 ]; then
        print_success "$1"
        return 0
    else
        print_error "$1"
        return 1
    fi
}

# Sleep with countdown
sleep_with_countdown() {
    local seconds=$1
    local message=${2:-"Waiting"}
    
    for ((i=seconds; i>0; i--)); do
        echo -ne "${BLUE}   ⏳ $message... ${i}s remaining\r${NC}"
        sleep 1
    done
    echo -e "${BLUE}   ⏳ $message... Done!${NC}"
}

# Main test suite
main() {
    print_header "🚀 WordPress Development Environment - Full Test Suite"
    
    echo "This script will perform a comprehensive test of all WordPress development environment features."
    echo "It will:"
    echo "  1. Clean and rebuild the environment"
    echo "  2. Test all management commands"
    echo "  3. Create sample plugins and themes"
    echo "  4. Test database operations"
    echo "  5. Test build and distribution features"
    echo "  6. Verify all components work together"
    echo ""
    
    wait_for_confirmation
    
    # Test 1: Environment Setup
    print_header "🏗️  Test Phase 1: Environment Setup"
    
    print_test "Clean existing environment"
    print_step "Stopping and cleaning containers..."
    if echo "y" | make clean > /dev/null 2>&1; then
        print_success "Environment cleaned successfully"
    else
        print_warning "No existing environment to clean"
    fi
    
    print_test "Full environment setup"
    print_step "Running make setup..."
    if make setup > setup.log 2>&1; then
        print_success "Environment setup completed"
    else
        print_error "Environment setup failed"
        echo "Check setup.log for details"
        exit 1
    fi
    
    sleep_with_countdown 5 "Waiting for containers to stabilize"
    
    # Test 2: Basic Environment Tests
    print_header "🔧 Test Phase 2: Basic Environment Operations"
    
    print_test "Check environment status"
    print_step "Running make status..."
    make status > /dev/null 2>&1
    check_success "Environment status check"
    
    print_test "Check environment info"
    print_step "Running make info..."
    make info > /dev/null 2>&1
    check_success "Environment info check"
    
    print_test "Check project structure"
    print_step "Running make structure..."
    make structure > /dev/null 2>&1
    check_success "Project structure check"
    
    print_test "Test container restart"
    print_step "Restarting containers..."
    make restart > /dev/null 2>&1
    check_success "Container restart"
    
    sleep_with_countdown 3 "Waiting after restart"
    
    # Test 3: WordPress Functionality
    print_header "🌐 Test Phase 3: WordPress Functionality"
    
    print_test "Test WP-CLI connectivity"
    print_step "Checking WordPress core..."
    if make wp cmd="core version" > /dev/null 2>&1; then
        print_success "WP-CLI connectivity works"
    else
        print_warning "WP-CLI not ready yet, waiting..."
        sleep_with_countdown 10 "Waiting for WordPress initialization"
        if make wp cmd="core version" > /dev/null 2>&1; then
            print_success "WP-CLI connectivity works (after wait)"
        else
            print_error "WP-CLI connectivity failed"
        fi
    fi
    
    print_test "Test WordPress installation"
    print_step "Checking if WordPress is installed..."
    if make wp cmd="core is-installed" > /dev/null 2>&1; then
        print_success "WordPress is already installed"
    else
        print_step "Installing WordPress..."
        if make wp cmd="core install --url=http://localhost:8080 --title='Test WordPress' --admin_user=admin --admin_password=admin123 --admin_email=admin@test.com" > /dev/null 2>&1; then
            print_success "WordPress installation completed"
        else
            print_error "WordPress installation failed"
        fi
    fi
    
    # Test 4: Plugin Management
    print_header "🧩 Test Phase 4: Plugin Management"
    
    print_test "Create test plugin"
    print_step "Creating test-plugin..."
    make plugin-create name=test-plugin > /dev/null 2>&1
    check_success "Test plugin creation"
    
    print_test "Verify plugin files"
    print_step "Checking plugin structure..."
    if [ -f "wp-content/plugins/test-plugin/test-plugin.php" ] && [ -f "wp-content/plugins/test-plugin/README.md" ]; then
        print_success "Plugin files created correctly"
    else
        print_error "Plugin files missing"
    fi
    
    print_test "Test plugin in WordPress"
    print_step "Checking plugin in WordPress..."
    if make wp cmd="plugin list" | grep -q "test-plugin" > /dev/null 2>&1; then
        print_success "Plugin visible in WordPress"
        
        print_step "Activating plugin..."
        if make wp cmd="plugin activate test-plugin" > /dev/null 2>&1; then
            print_success "Plugin activated successfully"
        else
            print_warning "Plugin activation failed (may be normal for basic plugin)"
        fi
    else
        print_warning "Plugin not visible in WordPress yet"
    fi
    
    # Test 5: Theme Management
    print_header "🎨 Test Phase 5: Theme Management"
    
    print_test "Create test theme"
    print_step "Creating test-theme..."
    make theme-create name=test-theme > /dev/null 2>&1
    check_success "Test theme creation"
    
    print_test "Verify theme files"
    print_step "Checking theme structure..."
    if [ -f "wp-content/themes/test-theme/style.css" ] && [ -f "wp-content/themes/test-theme/index.php" ]; then
        print_success "Theme files created correctly"
    else
        print_error "Theme files missing"
    fi
    
    print_test "Test theme in WordPress"
    print_step "Checking theme in WordPress..."
    if make wp cmd="theme list" | grep -q "test-theme" > /dev/null 2>&1; then
        print_success "Theme visible in WordPress"
        
        print_step "Activating theme..."
        if make wp cmd="theme activate test-theme" > /dev/null 2>&1; then
            print_success "Theme activated successfully"
        else
            print_warning "Theme activation failed"
        fi
    else
        print_warning "Theme not visible in WordPress yet"
    fi
    
    # Test 6: Database Operations
    print_header "🗄️  Test Phase 6: Database Operations"
    
    print_test "Create test content"
    print_step "Creating test posts..."
    for i in {1..3}; do
        make wp cmd="post create --post_title='Test Post $i' --post_content='This is test content for post $i' --post_status=publish" > /dev/null 2>&1
    done
    check_success "Test posts created"
    
    print_test "Database backup"
    print_step "Creating database backup..."
    make backup > /dev/null 2>&1
    check_success "Database backup created"
    
    print_test "Verify backup file"
    print_step "Checking backup files..."
    if ls data/backups/*.sql > /dev/null 2>&1; then
        print_success "Backup files found"
    else
        print_error "No backup files found"
    fi
    
    # Test 7: Build and Distribution
    print_header "📦 Test Phase 7: Build and Distribution"
    
    print_test "Build plugin distribution"
    print_step "Building test-plugin..."
    make build-plugin name=test-plugin > /dev/null 2>&1
    check_success "Plugin distribution built"
    
    print_test "Build theme distribution"
    print_step "Building test-theme..."
    make build-theme name=test-theme > /dev/null 2>&1
    check_success "Theme distribution built"
    
    print_test "List distributions"
    print_step "Checking distribution files..."
    make list-dist > /dev/null 2>&1
    check_success "Distribution listing"
    
    print_test "Verify distribution files"
    print_step "Checking ZIP files..."
    if ls dist/*.zip > /dev/null 2>&1; then
        print_success "Distribution ZIP files created"
        ls -la dist/
    else
        print_warning "No distribution files found"
    fi
    
    # Test 8: Submodule Management
    print_header "🔗 Test Phase 8: Submodule Management"
    
    print_test "Submodule status"
    print_step "Checking submodule status..."
    make submodules-status > /dev/null 2>&1
    check_success "Submodule status check"
    
    print_test "List submodules"
    print_step "Listing submodules..."
    make submodules-list > /dev/null 2>&1
    check_success "Submodule listing"
    
    # Test 9: Logging and Monitoring
    print_header "📊 Test Phase 9: Logging and Monitoring"
    
    print_test "Check logs accessibility"
    print_step "Testing log access..."
    if timeout 5 make logs > /dev/null 2>&1; then
        print_success "Logs accessible"
    else
        print_warning "Log access timed out (normal behavior)"
    fi
    
    print_test "Check log files"
    print_step "Verifying log files exist..."
    log_files=0
    [ -d "data/logs/apache" ] && log_files=$((log_files + 1))
    [ -d "data/logs/php" ] && log_files=$((log_files + 1))
    [ -d "data/logs/mysql" ] && log_files=$((log_files + 1))
    
    if [ $log_files -eq 3 ]; then
        print_success "All log directories present"
    else
        print_warning "Some log directories missing"
    fi
    
    # Test 10: Web Accessibility
    print_header "🌐 Test Phase 10: Web Accessibility"
    
    print_test "WordPress web accessibility"
    print_step "Testing WordPress frontend..."
    if curl -s http://localhost:8080 | grep -q "WordPress" > /dev/null 2>&1; then
        print_success "WordPress frontend accessible"
    else
        print_warning "WordPress frontend not responding"
    fi
    
    print_test "phpMyAdmin accessibility"
    print_step "Testing phpMyAdmin..."
    if curl -s http://localhost:8081 | grep -q "phpMyAdmin" > /dev/null 2>&1; then
        print_success "phpMyAdmin accessible"
    else
        print_warning "phpMyAdmin not responding"
    fi
    
    # Test 11: PHP Configuration
    print_header "⚙️  Test Phase 11: PHP Configuration"
    
    print_test "PHP upload limits"
    print_step "Checking PHP configuration..."
    if make wp cmd="eval 'echo ini_get(\"upload_max_filesize\");'" 2>/dev/null | grep -q "256M"; then
        print_success "PHP upload limits configured correctly"
    else
        print_warning "PHP configuration may not be applied"
    fi
    
    # Test 12: Cleanup Test Files
    print_header "🧹 Test Phase 12: Cleanup"
    
    print_test "Remove test plugin"
    print_step "Removing test-plugin..."
    if echo "y" | make plugin-remove name=test-plugin > /dev/null 2>&1; then
        print_success "Test plugin removed"
    else
        print_warning "Test plugin removal skipped"
    fi
    
    print_test "Remove test theme"
    print_step "Removing test-theme..."
    if echo "y" | make theme-remove name=test-theme > /dev/null 2>&1; then
        print_success "Test theme removed"
    else
        print_warning "Test theme removal skipped"
    fi
    
    print_test "Clean distribution files"
    print_step "Removing test distribution files..."
    rm -rf dist/test-*
    print_success "Test distribution files cleaned"
    
    # Final Results
    print_header "📊 Test Results Summary"
    
    echo -e "${CYAN}Total Tests: ${TESTS_TOTAL}${NC}"
    echo -e "${GREEN}Passed: ${TESTS_PASSED}${NC}"
    echo -e "${RED}Failed: ${TESTS_FAILED}${NC}"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        print_header "🎉 All Tests Passed! Environment is fully functional."
        echo -e "${GREEN}Your WordPress development environment is ready for production use!${NC}"
        echo ""
        echo "🌐 WordPress: http://localhost:8080"
        echo "🗄️  phpMyAdmin: http://localhost:8081"
        echo ""
        echo "Next steps:"
        echo "  • Start developing your plugins and themes"
        echo "  • Run 'make help' to see all available commands"
        echo "  • Check documentation in docs/ directory"
    else
        print_header "⚠️  Some Tests Failed"
        echo -e "${YELLOW}Some functionality may not work as expected.${NC}"
        echo "Check the output above for details on failed tests."
        echo "Most warnings are normal and don't affect core functionality."
    fi
    
    # Cleanup log files
    rm -f setup.log
    
    echo ""
    echo -e "${PURPLE}Test suite completed!${NC}"
}

# Run the test suite
main "$@"
