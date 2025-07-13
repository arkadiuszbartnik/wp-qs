#!/bin/bash

# WordPress Development Environment - Complete Test Runner
# This script runs all available tests in the proper order

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
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Helper functions
print_header() {
    echo ""
    echo -e "${PURPLE}==========================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}==========================================${NC}"
    echo ""
}

print_subheader() {
    echo ""
    echo -e "${CYAN}📋 $1${NC}"
    echo -e "${CYAN}$(echo "$1" | sed 's/./─/g')${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_step() {
    echo -e "${CYAN}   ▶️  $1${NC}"
}

# Execute test and track results
run_test() {
    local test_name="$1"
    local test_command="$2"
    local log_file="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    print_step "Running: $test_name"
    
    if eval "$test_command" > "$log_file" 2>&1; then
        print_success "$test_name passed"
        return 0
    else
        print_error "$test_name failed"
        echo -e "${RED}   📄 Log: $log_file${NC}"
        return 1
    fi
}

# Wait for user confirmation
wait_for_confirmation() {
    echo -e "${YELLOW}Press Enter to continue or Ctrl+C to abort...${NC}"
    read -r
}

# Check if we're in the right directory
check_environment() {
    if [[ ! -f "$PROJECT_DIR/Makefile" ]] || [[ ! -d "$PROJECT_DIR/scripts" ]]; then
        print_error "Not in WordPress project directory"
        exit 1
    fi
    
    if [[ ! -f "$PROJECT_DIR/scripts/test-environment.sh" ]]; then
        print_error "test-environment.sh not found"
        exit 1
    fi
    
    if [[ ! -f "$PROJECT_DIR/scripts/test-suite.sh" ]]; then
        print_error "test-suite.sh not found"
        exit 1
    fi
}

# Main function
main() {
    print_header "🚀 WordPress Development Environment - Complete Test Suite"
    
    echo "This script will run all available tests in the correct order:"
    echo ""
    echo "1. 📋 Environment Structure Test"
    echo "2. 🧪 Comprehensive Test Suite"
    echo "3. 🔍 Additional Validation Tests"
    echo ""
    echo "Note: This may take several minutes to complete."
    echo ""
    
    wait_for_confirmation
    
    # Change to project directory
    cd "$PROJECT_DIR"
    
    # Check environment
    check_environment
    
    # Create log directory
    mkdir -p "$PROJECT_DIR/logs"
    
    # Test 1: Environment Structure Test
    print_header "📋 Test 1: Environment Structure"
    
    run_test "Environment Structure Check" \
        "./scripts/test-environment.sh" \
        "$PROJECT_DIR/logs/test-environment.log"
    
    # Test 2: Comprehensive Test Suite
    print_header "🧪 Test 2: Comprehensive Test Suite"
    
    print_info "This test will set up the entire environment and run all functional tests."
    print_info "It may take several minutes and will require confirmation prompts."
    echo ""
    
    if ./scripts/test-suite.sh; then
        print_success "Comprehensive test suite completed successfully"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        print_error "Comprehensive test suite failed"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    # Test 3: Additional Validation Tests
    print_header "🔍 Test 3: Additional Validation Tests"
    
    print_subheader "Project Structure Validation"
    
    run_test "Makefile Structure" \
        "make structure" \
        "$PROJECT_DIR/logs/test-structure.log"
    
    run_test "Environment Information" \
        "make info" \
        "$PROJECT_DIR/logs/test-info.log"
    
    run_test "Help Documentation" \
        "make help" \
        "$PROJECT_DIR/logs/test-help.log"
    
    print_subheader "Docker Environment Tests"
    
    run_test "Docker Status Check" \
        "make status" \
        "$PROJECT_DIR/logs/test-status.log"
    
    # Test Git configuration
    print_subheader "Git Configuration Tests"
    
    run_test "Git Repository Status" \
        "git status --porcelain" \
        "$PROJECT_DIR/logs/test-git-status.log"
    
    run_test "Git Submodules Status" \
        "make submodules-status" \
        "$PROJECT_DIR/logs/test-submodules-status.log"
    
    # Test available distributions
    print_subheader "Build System Tests"
    
    run_test "Distribution System" \
        "make list-dist" \
        "$PROJECT_DIR/logs/test-list-dist.log"
    
    # Test file permissions
    print_subheader "File Permissions Tests"
    
    run_test "Script Permissions" \
        "find scripts -name '*.sh' -exec test -x {} \\;" \
        "$PROJECT_DIR/logs/test-permissions.log"
    
    # Test 4: Integration Tests
    print_header "🔗 Test 4: Integration Tests"
    
    print_subheader "WordPress Integration"
    
    # Only run if environment is up
    if docker compose -f docker/docker-compose.yml ps | grep -q "wordpress.*Up"; then
        run_test "WordPress Core Version" \
            "make wp cmd='core version'" \
            "$PROJECT_DIR/logs/test-wp-version.log"
        
        run_test "WordPress Database Check" \
            "make wp cmd='db check'" \
            "$PROJECT_DIR/logs/test-wp-db.log"
        
        run_test "WordPress Plugin List" \
            "make wp cmd='plugin list'" \
            "$PROJECT_DIR/logs/test-wp-plugins.log"
        
        run_test "WordPress Theme List" \
            "make wp cmd='theme list'" \
            "$PROJECT_DIR/logs/test-wp-themes.log"
    else
        print_warning "WordPress containers not running - skipping WordPress integration tests"
        print_info "Run 'make start' to enable WordPress integration tests"
    fi
    
    # Test 5: Documentation Tests
    print_header "📚 Test 5: Documentation Tests"
    
    run_test "README Files Exist" \
        "find . -name 'README.md' -type f | wc -l | grep -q '[1-9]'" \
        "$PROJECT_DIR/logs/test-readme.log"
    
    run_test "Documentation Structure" \
        "test -d docs || test -f README.md" \
        "$PROJECT_DIR/logs/test-docs.log"
    
    # Final Results
    print_header "📊 Final Test Results"
    
    echo -e "${CYAN}Total Tests Run: ${TOTAL_TESTS}${NC}"
    echo -e "${GREEN}Tests Passed: ${PASSED_TESTS}${NC}"
    echo -e "${RED}Tests Failed: ${FAILED_TESTS}${NC}"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo ""
        print_header "🎉 ALL TESTS PASSED!"
        echo -e "${GREEN}Your WordPress development environment is fully functional!${NC}"
        echo ""
        echo "🌐 WordPress: http://localhost:8080"
        echo "🗄️  phpMyAdmin: http://localhost:8081"
        echo ""
        echo "📁 Test logs saved in: logs/"
        echo "🔧 Run 'make help' to see all available commands"
        echo ""
        echo "✨ You're ready to start developing!"
    else
        echo ""
        print_header "⚠️  SOME TESTS FAILED"
        echo -e "${YELLOW}$FAILED_TESTS out of $TOTAL_TESTS tests failed.${NC}"
        echo ""
        echo "📁 Check test logs in: logs/"
        echo "🔧 Most common issues:"
        echo "  • Docker containers not running (run 'make start')"
        echo "  • WordPress not fully initialized (wait a few minutes)"
        echo "  • Missing dependencies (run 'make setup')"
        echo ""
        echo "💡 Run individual tests for more detailed output:"
        echo "  • make test           - Environment structure"
        echo "  • ./scripts/test-suite.sh - Comprehensive tests"
        echo ""
        exit 1
    fi
    
    # Cleanup
    echo ""
    print_info "Cleaning up temporary files..."
    
    # Keep important logs but remove temporary ones
    find "$PROJECT_DIR/logs" -name "*.log" -mtime +1 -delete 2>/dev/null || true
    
    print_header "🏁 Test Suite Complete!"
}

# Run the main function
main "$@"
