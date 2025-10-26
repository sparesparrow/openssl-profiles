#!/bin/bash
set -euo pipefail

# Test Algorithm Restrictions in FIPS Mode
# Validates approved algorithms work and deprecated ones fail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

# Load environment variables
if [ -f "$WORKSPACE_DIR/.fips-env" ]; then
    source "$WORKSPACE_DIR/.fips-env"
fi

# Find config file
CONFIG_FILE=$(find "$WORKSPACE_DIR" -name "fipsmodule-*.cnf" | head -1)
if [ -z "$CONFIG_FILE" ]; then
    echo "Error: No fipsmodule.cnf found. Run validate-fips-module.sh first"
    exit 1
fi

echo "Using FIPS config: $CONFIG_FILE"

# Set FIPS mode
export OPENSSL_CONF="$CONFIG_FILE"

# Create test file
TEST_FILE="$WORKSPACE_DIR/testfile.txt"
echo "This is a test file for FIPS validation" > "$TEST_FILE"

echo "Testing algorithm restrictions in FIPS mode..."

# Test approved algorithms (should succeed)
echo "Testing approved algorithms..."

# SHA-256 with FIPS provider
if openssl sha256 -provider fips -in "$TEST_FILE" > /dev/null 2>&1; then
    echo "✓ SHA-256 with FIPS provider: SUCCESS"
else
    echo "✗ SHA-256 with FIPS provider: FAILED"
    exit 1
fi

# SHA-384
if openssl sha384 -provider fips -in "$TEST_FILE" > /dev/null 2>&1; then
    echo "✓ SHA-384 with FIPS provider: SUCCESS"
else
    echo "✗ SHA-384 with FIPS provider: FAILED"
    exit 1
fi

# AES-256-GCM encryption/decryption
AES_KEY=$(openssl rand -hex 32)
AES_IV=$(openssl rand -hex 12)
if echo "test data" | openssl enc -aes-256-gcm -K "$AES_KEY" -iv "$AES_IV" -provider fips | \
   openssl enc -d -aes-256-gcm -K "$AES_KEY" -iv "$AES_IV" -provider fips > /dev/null 2>&1; then
    echo "✓ AES-256-GCM with FIPS provider: SUCCESS"
else
    echo "✗ AES-256-GCM with FIPS provider: FAILED"
    exit 1
fi

# Test deprecated/unapproved algorithms (should fail)
echo "Testing deprecated/unapproved algorithms (should fail)..."

# MD5 (deprecated, should fail in FIPS mode)
if openssl md5 -in "$TEST_FILE" > /dev/null 2>&1; then
    echo "✗ MD5: FAILED (should be rejected in FIPS mode)"
    exit 1
else
    echo "✓ MD5: correctly rejected in FIPS mode"
fi

# RC4 (deprecated, should fail)
if echo "test" | openssl enc -rc4 -k testkey > /dev/null 2>&1; then
    echo "✗ RC4: FAILED (should be rejected in FIPS mode)"
    exit 1
else
    echo "✓ RC4: correctly rejected in FIPS mode"
fi

# DES (deprecated, should fail)
if echo "test" | openssl enc -des -k testkey > /dev/null 2>&1; then
    echo "✗ DES: FAILED (should be rejected in FIPS mode)"
    exit 1
else
    echo "✓ DES: correctly rejected in FIPS mode"
fi

# Test RSA operations
echo "Testing RSA operations..."

# Generate RSA key
RSA_KEY="$WORKSPACE_DIR/test_rsa.pem"
openssl genrsa -out "$RSA_KEY" -provider fips 2048 > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ RSA-2048 key generation: SUCCESS"
else
    echo "✗ RSA-2048 key generation: FAILED"
    exit 1
fi

# Test ECDSA
echo "Testing ECDSA operations..."

# Generate ECDSA key
EC_KEY="$WORKSPACE_DIR/test_ec.pem"
openssl ecparam -name prime256v1 -genkey -noout -out "$EC_KEY" -provider fips > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ ECDSA-P256 key generation: SUCCESS"
else
    echo "✗ ECDSA-P256 key generation: FAILED"
    exit 1
fi

# Clean up test files
rm -f "$TEST_FILE" "$RSA_KEY" "$EC_KEY"

echo "Algorithm restriction tests completed successfully"
echo "All approved algorithms work, deprecated algorithms correctly rejected"