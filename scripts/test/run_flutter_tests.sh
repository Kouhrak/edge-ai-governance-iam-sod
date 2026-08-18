#!/bin/bash
# Flutter Testing Script - Edge AI Governance IAM SoD

set -e  # Exit on any error

echo "=== Flutter Testing Suite ==="
echo "Date: $(date)"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
        exit 1
    fi
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Flutter is not installed or not in PATH${NC}"
    exit 1
fi

echo "Flutter version:"
flutter --version
echo ""

# 1. Unit Tests
echo "1. Running Unit Tests..."
flutter test --coverage
print_status $? "Unit tests completed"
echo ""

# 2. Widget Tests (if directory exists)
if [ -d "test/widget" ]; then
    echo "2. Running Widget Tests..."
    flutter test test/widget/
    print_status $? "Widget tests completed"
else
    echo -e "${YELLOW}2. Skipping Widget Tests (directory not found)${NC}"
fi
echo ""

# 3. Generate Coverage Report
echo "3. Generating Coverage Report..."
if command -v genhtml &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html
    print_status $? "Coverage report generated"
else
    echo -e "${YELLOW}genhtml not found, skipping HTML report${NC}"
    echo "Coverage data available at: coverage/lcov.info"
fi
echo ""

# 4. Static Analysis
echo "4. Running Static Analysis..."
flutter analyze
print_status $? "Static analysis completed"
echo ""

# 5. Format Check
echo "5. Checking Code Format..."
dart format --set-exit-if-changed .
print_status $? "Code format check completed"
echo ""

echo "=== All Flutter Tests Passed ==="
echo "Coverage report: coverage/html/index.html"