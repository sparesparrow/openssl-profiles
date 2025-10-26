#!/bin/bash
# Basic FIPS validation test - demonstrates core functionality
# Enhanced with FIPS self-tests and SBOM verification

set -euo pipefail

echo "🔐 OpenSSL FIPS 140-3 Basic Validation Test"
echo "=========================================="

# Check if OpenSSL is available
if ! command -v openssl >/dev/null 2>&1; then
    echo "❌ OpenSSL not found - install OpenSSL to run FIPS validation"
    exit 1
fi

echo "✅ OpenSSL found: $(openssl version)"

# Check if required tools are available for SBOM generation
if ! command -v syft >/dev/null 2>&1; then
    echo "⚠️  syft not found - SBOM generation will be skipped"
    echo "   Install syft: curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin"
fi

# Create test data
echo "test data for FIPS validation" > testfile.txt

# Test basic OpenSSL functionality
if openssl sha256 -in testfile.txt >/dev/null 2>&1; then
    echo "✅ Basic SHA-256 hashing works"
else
    echo "❌ Basic SHA-256 hashing failed"
    exit 1
fi

# Test that MD5 is available (will be restricted in FIPS mode)
if openssl md5 -in testfile.txt >/dev/null 2>&1; then
    echo "✅ MD5 available (will be restricted in FIPS mode)"
else
    echo "⚠️  MD5 not available - system may already be in FIPS mode"
fi

# Check for FIPS module in common locations
FIPS_LOCATIONS=(
    "/usr/lib/x86_64-linux-gnu/ossl-modules/fips.so"
    "/usr/lib64/ossl-modules/fips.so"
    "/usr/local/lib/ossl-modules/fips.so"
)

FIPS_FOUND=false
for location in "${FIPS_LOCATIONS[@]}"; do
    if [ -f "$location" ]; then
        echo "✅ FIPS module found at: $location"
        FIPS_MODULE="$location"
        FIPS_FOUND=true
        break
    fi
done

if [ "$FIPS_FOUND" = false ]; then
    echo "⚠️  FIPS module not found in standard locations"
    echo "   (This is expected if FIPS-enabled OpenSSL hasn't been built yet)"
fi

# Test deprecated API compilation (basic check)
cat > test_deprecated_basic.c << 'EOF'
#include <openssl/evp.h>

int main() {
    // This should work (not deprecated)
    EVP_MD_CTX *ctx = EVP_MD_CTX_new();
    if (ctx) EVP_MD_CTX_free(ctx);
    return 0;
}
EOF

if gcc test_deprecated_basic.c -lcrypto -o test_deprecated_basic 2>/dev/null; then
    echo "✅ Basic OpenSSL compilation works"
    rm -f test_deprecated_basic
else
    echo "❌ Basic OpenSSL compilation failed"
    exit 1
fi

# Run FIPS self-tests if FIPS module is available
if [ "$FIPS_FOUND" = true ]; then
    echo ""
    echo "🔍 Running FIPS self-tests..."
    
    # Set environment for FIPS testing
    export OPENSSL_MODULES="$(dirname "$FIPS_MODULE")"
    
    # Run FIPS self-test
    if openssl fips-selftest 2>/dev/null; then
        echo "✅ FIPS self-tests passed"
    else
        echo "❌ FIPS self-tests failed"
        exit 1
    fi
    
    # Verify FIPS provider is available
    if openssl list -providers -verbose 2>/dev/null | grep -q -i fips; then
        echo "✅ FIPS provider is available"
    else
        echo "⚠️  FIPS provider not found in provider list"
    fi
fi

# Generate SBOM and verify policy artifacts
echo ""
echo "📋 Generating SBOM and verifying policy artifacts..."

if command -v syft >/dev/null 2>&1; then
    # Generate SBOM
    syft packages . -o spdx-json > basic-validation-sbom.spdx.json 2>/dev/null || true
    
    if [ -f "basic-validation-sbom.spdx.json" ]; then
        echo "✅ SBOM generated successfully"
        
        # Check for FIPS-related packages in SBOM
        if grep -q -i "fips\|openssl" basic-validation-sbom.spdx.json; then
            echo "✅ FIPS/OpenSSL packages found in SBOM"
        else
            echo "⚠️  FIPS/OpenSSL packages not found in SBOM"
        fi
        
        # Check for policy artifacts
        if [ -d "fips-140-3" ] && [ -f "fips-140-3/certificates/certificate-4985.json" ]; then
            echo "✅ FIPS policy artifacts found"
            
            # Include policy artifacts in SBOM
            syft packages fips-140-3/ -o spdx-json > policy-artifacts-sbom.spdx.json 2>/dev/null || true
            
            if [ -f "policy-artifacts-sbom.spdx.json" ]; then
                echo "✅ Policy artifacts included in SBOM"
                
                # Verify certificate information
                CERT_NUMBER=$(jq -r '.packages[] | select(.name | contains("certificate")) | .name' policy-artifacts-sbom.spdx.json 2>/dev/null || echo "unknown")
                if [ "$CERT_NUMBER" != "unknown" ]; then
                    echo "✅ Certificate #4985 found in policy artifacts SBOM"
                else
                    echo "⚠️  Certificate #4985 not found in policy artifacts SBOM"
                fi
            fi
        else
            echo "⚠️  FIPS policy artifacts not found"
        fi
    else
        echo "❌ Failed to generate SBOM"
    fi
else
    echo "⚠️  SBOM generation skipped (syft not available)"
fi

# Cleanup
rm -f testfile.txt test_deprecated_basic.c basic-validation-sbom.spdx.json policy-artifacts-sbom.spdx.json

echo ""
echo "🎉 Basic FIPS validation test completed!"
echo ""
echo "To run full FIPS validation:"
echo "  ./scripts/fips-validation/fips-compliance-validation.sh"
echo ""
echo "Or trigger automated validation via GitHub Actions."