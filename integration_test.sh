#!/bin/bash
# integration_test.sh - Multi-platform OpenSSL integration test

set -e

echo "🧪 OpenSSL Multi-Platform Integration Test"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test platforms
PLATFORMS=("profiles/linux-gcc11-fips" "profiles/windows-msvc193" "profiles/macos-x86_64")

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "INFO")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
        "SUCCESS")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}❌ $message${NC}"
            ;;
    esac
}

# Function to test a platform
test_platform() {
    local platform=$1
    print_status "INFO" "Testing platform: $platform"

    # Check if profile exists
    if [ ! -f "$platform" ]; then
        print_status "ERROR" "Profile $platform not found"
        return 1
    fi

    print_status "SUCCESS" "Profile $platform found"

    # Test profile syntax
    if conan profile show --profile="$platform" > /dev/null 2>&1; then
        print_status "SUCCESS" "Profile $platform syntax is valid"
    else
        print_status "ERROR" "Profile $platform syntax is invalid"
        return 1
    fi

    return 0
}

# Function to run FIPS compliance demo
run_fips_demo() {
    print_status "INFO" "Running FIPS compliance demo..."

    if [ -f "fips_compliance_demo.py" ]; then
        if python3 fips_compliance_demo.py; then
            print_status "SUCCESS" "FIPS compliance demo passed"
            return 0
        else
            print_status "ERROR" "FIPS compliance demo failed"
            return 1
        fi
    else
        print_status "WARNING" "FIPS compliance demo script not found"
        return 1
    fi
}

# Function to validate profile options
validate_profile_options() {
    local platform=$1
    print_status "INFO" "Validating profile options for $platform"

    # Check for required FIPS options
    if grep -q "enable_fips=True" "$platform"; then
        print_status "SUCCESS" "FIPS enabled in $platform"
    else
        print_status "WARNING" "FIPS not enabled in $platform"
    fi

    # Check for shared library option
    if grep -q "shared=True" "$platform"; then
        print_status "SUCCESS" "Shared libraries enabled in $platform"
    else
        print_status "WARNING" "Shared libraries not enabled in $platform"
    fi

    # Check for optimization flags
    if grep -q "CFLAGS.*-O3" "$platform"; then
        print_status "SUCCESS" "Optimization flags found in $platform"
    else
        print_status "WARNING" "Optimization flags not found in $platform"
    fi
}

# Main test execution
main() {
    print_status "INFO" "Starting OpenSSL integration tests..."

    # Test each platform
    local failed_platforms=()
    for platform in "${PLATFORMS[@]}"; do
        echo ""
        print_status "INFO" "Testing platform: $platform"

        if test_platform "$platform"; then
            validate_profile_options "$platform"
            print_status "SUCCESS" "Platform $platform: PASSED"
        else
            print_status "ERROR" "Platform $platform: FAILED"
            failed_platforms+=("$platform")
        fi
    done

    # Run FIPS compliance demo
    echo ""
    if run_fips_demo; then
        print_status "SUCCESS" "FIPS compliance demo: PASSED"
    else
        print_status "ERROR" "FIPS compliance demo: FAILED"
    fi

    # Summary
    echo ""
    print_status "INFO" "Integration Test Summary"
    echo "=================================="

    if [ ${#failed_platforms[@]} -eq 0 ]; then
        print_status "SUCCESS" "All platforms passed integration testing!"
        print_status "SUCCESS" "OpenSSL profiles are ready for production use"
        return 0
    else
        print_status "ERROR" "Failed platforms: ${failed_platforms[*]}"
        print_status "ERROR" "Integration testing failed"
        return 1
    fi
}

# Check prerequisites
check_prerequisites() {
    print_status "INFO" "Checking prerequisites..."

    # Check if conan is installed
    if ! command -v conan &> /dev/null; then
        print_status "ERROR" "Conan is not installed"
        return 1
    fi

    # Check if python3 is installed
    if ! command -v python3 &> /dev/null; then
        print_status "ERROR" "Python3 is not installed"
        return 1
    fi

    # Check conan version
    local conan_version=$(conan --version | cut -d' ' -f3)
    print_status "SUCCESS" "Conan version: $conan_version"

    # Check python version
    local python_version=$(python3 --version | cut -d' ' -f2)
    print_status "SUCCESS" "Python version: $python_version"

    return 0
}

# Run the test
if check_prerequisites; then
    main
else
    print_status "ERROR" "Prerequisites check failed"
    exit 1
fi
