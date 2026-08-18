#!/bin/bash
# Python Testing Script - Edge AI Governance IAM SoD

set -e  # Exit on any error

echo "=== Python Testing Suite ==="
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

# Check if Python is installed
if ! command -v python &> /dev/null; then
    echo -e "${RED}Python is not installed or not in PATH${NC}"
    exit 1
fi

echo "Python version:"
python --version
echo ""

# 1. Install test dependencies
echo "1. Installing test dependencies..."
if [ -f "requirements-test.txt" ]; then
    pip install -r requirements-test.txt
    print_status $? "Test dependencies installed"
else
    echo -e "${YELLOW}requirements-test.txt not found, using basic pytest${NC}"
    pip install pytest pytest-asyncio pytest-cov
fi
echo ""

# 2. Unit Tests
echo "2. Running Unit Tests..."
if [ -d "tests/unit" ]; then
    pytest tests/unit/ -v --cov=src --cov-report=html:coverage/html
    print_status $? "Unit tests completed"
else
    echo -e "${YELLOW}tests/unit directory not found${NC}"
    pytest tests/ -v --cov=src --cov-report=html:coverage/html
    print_status $? "Tests completed"
fi
echo ""

# 3. Integration Tests (with Docker)
echo "3. Running Integration Tests..."
if [ -f "docker-compose.test.yml" ]; then
    echo "Starting test containers..."
    docker compose -f docker-compose.test.yml up -d
    
    # Wait for services to be ready
    echo "Waiting for services to be ready..."
    sleep 10
    
    pytest tests/integration/ -v --tb=short
    INTEGRATION_RESULT=$?
    
    echo "Stopping test containers..."
    docker compose -f docker-compose.test.yml down
    
    print_status $INTEGRATION_RESULT "Integration tests completed"
else
    echo -e "${YELLOW}docker-compose.test.yml not found, skipping Docker integration tests${NC}"
    if [ -d "tests/integration" ]; then
        pytest tests/integration/ -v --tb=short
        print_status $? "Integration tests completed"
    else
        echo -e "${YELLOW}tests/integration directory not found${NC}"
    fi
fi
echo ""

# 4. Code Quality Checks
echo "4. Running Code Quality Checks..."
if command -v flake8 &> /dev/null; then
    flake8 src/ tests/
    print_status $? "Flake8 linting completed"
else
    echo -e "${YELLOW}flake8 not found, skipping linting${NC}"
fi

if command -v mypy &> /dev/null; then
    mypy src/
    print_status $? "MyPy type checking completed"
else
    echo -e "${YELLOW}mypy not found, skipping type checking${NC}"
fi
echo ""

echo "=== All Python Tests Passed ==="
echo "Coverage report: coverage/html/index.html"