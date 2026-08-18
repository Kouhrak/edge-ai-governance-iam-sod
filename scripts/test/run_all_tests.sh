#!/bin/bash
# Unified Testing Script - Edge AI Governance IAM SoD

set -e  # Exit on any error

echo "=== Complete Testing Suite ==="
echo "Date: $(date)"
echo "Project: Edge AI Governance IAM SoD"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
        FAILED_TESTS+=("$2")
    fi
}

# Array to track failed tests
FAILED_TESTS=()

# Function to run section
run_section() {
    local section_name=$1
    local script_path=$2
    
    echo -e "${BLUE}=== $section_name ===${NC}"
    
    if [ -f "$script_path" ]; then
        chmod +x "$script_path"
        if "$script_path"; then
            print_status 0 "$section_name completed successfully"
        else
            print_status 1 "$section_name failed"
        fi
    else
        echo -e "${YELLOW}Script not found: $script_path${NC}"
        print_status 1 "$section_name script not found"
    fi
    echo ""
}

# 1. Flutter Tests
run_section "Flutter Tests" "./scripts/test/run_flutter_tests.sh"

# 2. Python Tests
run_section "Python Tests" "./scripts/test/run_python_tests.sh"

# 3. Docker Services Check
echo -e "${BLUE}=== Docker Services Check ===${NC}"
if command -v docker &> /dev/null; then
    echo "Docker version: $(docker --version)"
    
    # Check if containers are running
    if docker compose ps | grep -q "running"; then
        echo "Docker containers are running:"
        docker compose ps
    else
        echo "No Docker containers are currently running"
    fi
else
    echo -e "${YELLOW}Docker is not installed${NC}"
fi
echo ""

# 4. Summary
echo -e "${BLUE}=== Test Summary ===${NC}"
if [ ${#FAILED_TESTS[@]} -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Review coverage reports"
    echo "2. Check for any warnings in the output"
    echo "3. Run integration tests if not already done"
    echo "4. Commit changes with test results"
else
    echo -e "${RED}${#FAILED_TESTS[@]} test(s) failed:${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "${RED}  - $test${NC}"
    done
    echo ""
    echo "Please fix the failing tests before committing."
    exit 1
fi

echo ""
echo "=== Testing Complete ==="
echo "Coverage reports available in:"
echo "  - Flutter: coverage/html/index.html"
echo "  - Python: coverage/html/index.html"