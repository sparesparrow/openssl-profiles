#!/bin/bash
set -euo pipefail

# FIPS Module Validation Script
# Verifies self-tests, generates fipsmodule.cnf, and validates checksums

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

# Load environment variables
if [ -f "$WORKSPACE_DIR/.fips-env" ]; then
    source "$WORKSPACE_DIR/.fips-env"
fi

# Check required environment variables
if [ -z "${OPENSSL_MODULES:-}" ]; then
    echo "Error: OPENSSL_MODULES environment variable not set"
    echo "Run build-fips-openssl.sh first"
    exit 1
fi

FIPS_MODULE="${OPENSSL_MODULES}/fips.so"
if [ ! -f "$FIPS_MODULE" ]; then
    echo "Error: FIPS module not found at $FIPS_MODULE"
    exit 1
fi

echo "Validating FIPS module at: $FIPS_MODULE"

# Verify self-tests
echo "Running FIPS module self-tests..."
if openssl fipsinstall -verify -module "$FIPS_MODULE"; then
    echo "✓ FIPS module self-tests passed"
else
    echo "✗ FIPS module self-tests failed"
    exit 1
fi

# Generate platform-specific fipsmodule.cnf
PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
CONFIG_FILE="fipsmodule-${PLATFORM}-${ARCH}.cnf"

echo "Generating $CONFIG_FILE..."
if openssl fipsinstall -out "$CONFIG_FILE" -module "$FIPS_MODULE"; then
    echo "✓ Generated $CONFIG_FILE"
else
    echo "✗ Failed to generate $CONFIG_FILE"
    exit 1
fi

# Parse and validate install-status
echo "Validating install status and checksums..."
if grep -q "INSTALL_SELF_TEST_KATS_RUN" "$CONFIG_FILE"; then
    echo "✓ Self-test KATs run successfully"
else
    echo "✗ Self-test KATs not found in config"
    exit 1
fi

# Extract and validate HMAC-SHA256 checksum
if grep -q "HMAC-SHA256" "$CONFIG_FILE"; then
    echo "✓ HMAC-SHA256 checksum found in config"
else
    echo "✗ HMAC-SHA256 checksum not found in config"
    exit 1
fi

# Move config to workspace root for CI/CD
mv "$CONFIG_FILE" "$WORKSPACE_DIR/"

echo "FIPS module validation completed successfully"
echo "Config file: $WORKSPACE_DIR/$CONFIG_FILE"
echo "Set OPENSSL_CONF=$WORKSPACE_DIR/$CONFIG_FILE"