#!/bin/bash
set -euo pipefail

# Test Deprecated API Rejection
# Verifies that deprecated OpenSSL APIs fail to compile with proper warnings

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

# Load environment variables
if [ -f "$WORKSPACE_DIR/.fips-env" ]; then
    source "$WORKSPACE_DIR/.fips-env"
fi

echo "Testing deprecated API rejection..."

# Find OpenSSL includes and libraries
OPENSSL_PREFIX=$(dirname "$(dirname "$(which openssl)")")
OPENSSL_INCLUDES="$OPENSSL_PREFIX/include"
OPENSSL_LIBS="$OPENSSL_PREFIX/lib"

# Test compilation with deprecated declarations as errors
echo "Compiling test_deprecated.c with -Werror=deprecated-declarations..."

# This should fail if deprecated APIs are properly marked
if gcc -I"$OPENSSL_INCLUDES" -L"$OPENSSL_LIBS" \
       -Werror=deprecated-declarations \
       -lcrypto -lssl \
       "$SCRIPT_DIR/test_deprecated.c" \
       -o /tmp/test_deprecated 2>/dev/null; then
    echo "✗ Compilation succeeded (deprecated APIs not properly marked)"
    exit 1
else
    echo "✓ Compilation failed as expected (deprecated APIs properly rejected)"
fi

# Test individual deprecated functions
echo "Testing individual deprecated functions..."

# Test EVP_MD_CTX_new (deprecated in OpenSSL 3.0)
cat > /tmp/test_evp_md_ctx.c << 'EOF'
#include <openssl/evp.h>
#include <stdio.h>

int main() {
    EVP_MD_CTX *ctx = EVP_MD_CTX_new();
    if (ctx) {
        EVP_MD_CTX_free(ctx);
    }
    return 0;
}
EOF

if gcc -I"$OPENSSL_INCLUDES" -L"$OPENSSL_LIBS" \
       -Werror=deprecated-declarations \
       -lcrypto \
       /tmp/test_evp_md_ctx.c \
       -o /tmp/test_evp_md_ctx 2>/dev/null; then
    echo "✗ EVP_MD_CTX_new compilation succeeded (should fail)"
    exit 1
else
    echo "✓ EVP_MD_CTX_new correctly rejected"
fi

# Test RSA_sign (deprecated)
cat > /tmp/test_rsa_sign.c << 'EOF'
#include <openssl/rsa.h>
#include <openssl/evp.h>

int main() {
    RSA *rsa = RSA_new();
    unsigned char sig[256];
    unsigned int siglen;
    unsigned char digest[32] = {0};

    if (rsa) {
        RSA_sign(NID_sha256, digest, 32, sig, &siglen, rsa);
        RSA_free(rsa);
    }
    return 0;
}
EOF

if gcc -I"$OPENSSL_INCLUDES" -L"$OPENSSL_LIBS" \
       -Werror=deprecated-declarations \
       -lcrypto \
       /tmp/test_rsa_sign.c \
       -o /tmp/test_rsa_sign 2>/dev/null; then
    echo "✗ RSA_sign compilation succeeded (should fail)"
    exit 1
else
    echo "✓ RSA_sign correctly rejected"
fi

# Test ENGINE functions (deprecated)
cat > /tmp/test_engine.c << 'EOF'
#include <openssl/engine.h>

int main() {
    ENGINE *engine = ENGINE_new();
    if (engine) {
        ENGINE_free(engine);
    }
    return 0;
}
EOF

if gcc -I"$OPENSSL_INCLUDES" -L"$OPENSSL_LIBS" \
       -Werror=deprecated-declarations \
       -lcrypto \
       /tmp/test_engine.c \
       -o /tmp/test_engine 2>/dev/null; then
    echo "✗ ENGINE_new compilation succeeded (should fail)"
    exit 1
else
    echo "✓ ENGINE_new correctly rejected"
fi

# Clean up
rm -f /tmp/test_*

echo "Deprecated API rejection tests completed successfully"