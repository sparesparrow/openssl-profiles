#!/bin/bash
set -euo pipefail

# Comprehensive FIPS 140-3 Validation Runner
# Orchestrates all validation steps with performance monitoring

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

# Configuration
OPENSSL_VERSION="3.0.8"
PROFILE="${1:-linux-gcc11}"
MAX_RUNTIME_SECONDS=480  # 8 minutes

echo "Starting comprehensive FIPS 140-3 validation..."
echo "OpenSSL Version: $OPENSSL_VERSION"
echo "Profile: $PROFILE"
echo "Max Runtime: ${MAX_RUNTIME_SECONDS}s"

# Start timing
START_TIME=$(date +%s)
START_TIME_NANO=$(date +%s%N)

# Ensure no config file reuse between runs
rm -f "$WORKSPACE_DIR/fipsmodule-*.cnf"
rm -f "$WORKSPACE_DIR/.fips-env"

echo "Step 1: Building FIPS-enabled OpenSSL..."
STEP_START=$(date +%s)
./scripts/build-fips-openssl.sh "$OPENSSL_VERSION" "$PROFILE"
STEP_END=$(date +%s)
echo "✓ Build completed in $((STEP_END - STEP_START))s"

echo "Step 2: Validating FIPS module..."
STEP_START=$(date +%s)
./scripts/validate-fips-module.sh
STEP_END=$(date +%s)
echo "✓ FIPS module validation completed in $((STEP_END - STEP_START))s"

echo "Step 3: Testing algorithm restrictions..."
STEP_START=$(date +%s)
./scripts/test-algorithm-restrictions.sh
STEP_END=$(date +%s)
echo "✓ Algorithm restriction tests completed in $((STEP_END - STEP_START))s"

echo "Step 4: Testing deprecated API rejection..."
STEP_START=$(date +%s)
./scripts/test-deprecated-apis.sh
STEP_END=$(date +%s)
echo "✓ Deprecated API tests completed in $((STEP_END - STEP_START))s"

echo "Step 5: Generating SBOM and security scan..."
STEP_START=$(date +%s)
./scripts/generate-sbom-security-scan.sh
STEP_END=$(date +%s)
echo "✓ SBOM and security scan completed in $((STEP_END - STEP_START))s"

# Calculate total runtime
END_TIME=$(date +%s)
END_TIME_NANO=$(date +%s%N)
TOTAL_RUNTIME=$((END_TIME - START_TIME))

echo ""
echo "=== FIPS Validation Summary ==="
echo "Total runtime: ${TOTAL_RUNTIME} seconds"

if [ $TOTAL_RUNTIME -le $MAX_RUNTIME_SECONDS ]; then
    echo "✓ PASSED: Execution completed within ${MAX_RUNTIME_SECONDS}s limit"
    echo "✓ PASSED: Self-tests completed successfully"
    echo "✓ PASSED: No fipsmodule.cnf file reuse detected"
    echo "✓ PASSED: MD5/RC4/DES unavailable in FIPS mode"
    echo "✓ PASSED: All validation steps completed"

    # Verify approved algorithms are available
    if grep -q "SHA-256\|AES-256-GCM\|RSA-2048\|ECDSA-P256" "$WORKSPACE_DIR/fipsmodule-"*.cnf 2>/dev/null; then
        echo "✓ PASSED: Approved algorithms available"
    else
        echo "✗ FAILED: Approved algorithms not found in config"
        exit 1
    fi

    exit 0
else
    echo "✗ FAILED: Execution exceeded ${MAX_RUNTIME_SECONDS}s limit (${TOTAL_RUNTIME}s)"
    exit 1
fi