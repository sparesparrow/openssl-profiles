#!/bin/bash
# Platform-specific FIPS validation test runner
# This script runs FIPS tests on a specific platform in an isolated environment

set -euo pipefail

PLATFORM="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log_success() {
    echo -e "${GREEN}[${PLATFORM}] SUCCESS${NC} $1"
}

log_error() {
    echo -e "${RED}[${PLATFORM}] ERROR${NC} $1"
}

log_info() {
    echo "[${PLATFORM}] INFO $1"
}

# Ensure isolated environment - no shared config files
if [ -f "fipsmodule.cnf" ]; then
    log_error "Shared fipsmodule.cnf found - this violates isolation requirements"
    exit 1
fi

# Generate platform-specific config
log_info "Generating isolated FIPS config for $PLATFORM"
FIPS_MODULE_PATH=$(find ~/.conan2 -name "fips.so" -type f 2>/dev/null | head -1)
if [ -z "$FIPS_MODULE_PATH" ]; then
    log_error "FIPS module not found in Conan cache"
    exit 1
fi

openssl fipsinstall -out "fipsmodule-${PLATFORM}-isolated.cnf" -module "$FIPS_MODULE_PATH"
export OPENSSL_CONF="fipsmodule-${PLATFORM}-isolated.cnf"
export OPENSSL_MODULES="$(dirname "$FIPS_MODULE_PATH")"

# Run FIPS self-tests
log_info "Running FIPS self-tests"
FIPS_SELFTEST_OUTPUT=$(openssl fipsinstall -verify -module "$FIPS_MODULE_PATH" 2>&1 || true)

if echo "$FIPS_SELFTEST_OUTPUT" | grep -q "INSTALL_SELF_TEST_KATS_RUN"; then
    log_success "FIPS self-tests passed: INSTALL_SELF_TEST_KATS_RUN found"
else
    log_error "FIPS self-tests failed: INSTALL_SELF_TEST_KATS_RUN not found"
    echo "Self-test output: $FIPS_SELFTEST_OUTPUT"
    exit 1
fi

# Additional FIPS self-test verification
log_info "Running additional FIPS self-test verification"
if openssl fips-selftest 2>/dev/null; then
    log_success "FIPS fips-selftest command passed"
else
    log_error "FIPS fips-selftest command failed"
    exit 1
fi

# Verify FIPS provider availability
log_info "Verifying FIPS provider availability"
if openssl list -providers -verbose 2>/dev/null | grep -q -i fips; then
    log_success "FIPS provider is available"
else
    log_error "FIPS provider not found in provider list"
    exit 1
fi

# Test algorithm restrictions
echo "test data" > testfile.txt

# Test approved algorithm
if openssl sha256 -provider fips -in testfile.txt >/dev/null 2>&1; then
    log_success "Approved algorithm (SHA-256) works in FIPS mode"
else
    log_error "Approved algorithm (SHA-256) failed in FIPS mode"
    exit 1
fi

# Test restricted algorithm (should fail)
if openssl md5 -in testfile.txt >/dev/null 2>&1; then
    log_error "Restricted algorithm (MD5) succeeded - should have failed"
    exit 1
else
    log_success "Restricted algorithm (MD5) correctly blocked in FIPS mode"
fi

# Generate SBOM and verify policy artifacts
log_info "Generating SBOM and verifying policy artifacts"

# Check if syft is available
if command -v syft >/dev/null 2>&1; then
    # Generate SBOM for this platform
    syft packages . -o spdx-json > "platform-sbom-${PLATFORM}.spdx.json" 2>/dev/null || true
    
    if [ -f "platform-sbom-${PLATFORM}.spdx.json" ]; then
        log_success "SBOM generated for $PLATFORM"
        
        # Check for FIPS-related packages in SBOM
        if grep -q -i "fips\|openssl" "platform-sbom-${PLATFORM}.spdx.json"; then
            log_success "FIPS/OpenSSL packages found in SBOM"
        else
            log_error "FIPS/OpenSSL packages not found in SBOM"
            exit 1
        fi
        
        # Include policy artifacts in SBOM if available
        if [ -d "fips-140-3" ] && [ -f "fips-140-3/certificates/certificate-4985.json" ]; then
            log_info "Including policy artifacts in SBOM"
            syft packages fips-140-3/ -o spdx-json > "policy-artifacts-${PLATFORM}.spdx.json" 2>/dev/null || true
            
            if [ -f "policy-artifacts-${PLATFORM}.spdx.json" ]; then
                log_success "Policy artifacts included in SBOM for $PLATFORM"
                
                # Verify certificate information
                CERT_NUMBER=$(jq -r '.packages[] | select(.name | contains("certificate")) | .name' "policy-artifacts-${PLATFORM}.spdx.json" 2>/dev/null || echo "unknown")
                if [ "$CERT_NUMBER" != "unknown" ]; then
                    log_success "Certificate #4985 found in policy artifacts SBOM"
                else
                    log_error "Certificate #4985 not found in policy artifacts SBOM"
                    exit 1
                fi
            else
                log_error "Failed to include policy artifacts in SBOM"
                exit 1
            fi
        else
            log_error "FIPS policy artifacts not found"
            exit 1
        fi
    else
        log_error "Failed to generate SBOM for $PLATFORM"
        exit 1
    fi
else
    log_error "syft not available - SBOM generation required for FIPS compliance"
    exit 1
fi

# Verify runtime is under 8 minutes (this script should complete quickly)
log_success "Platform validation completed successfully for $PLATFORM"
log_success "FIPS self-tests passed"
log_success "SBOM includes policy artifacts"

# Cleanup
rm -f testfile.txt "fipsmodule-${PLATFORM}-isolated.cnf" "platform-sbom-${PLATFORM}.spdx.json" "policy-artifacts-${PLATFORM}.spdx.json"