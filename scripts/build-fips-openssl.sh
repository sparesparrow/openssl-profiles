#!/bin/bash
set -euo pipefail

# Build FIPS-enabled OpenSSL using Conan
# Usage: ./scripts/build-fips-openssl.sh [version] [profile]

OPENSSL_VERSION=${1:-"3.0.8"}
PROFILE=${2:-"linux-gcc11"}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

echo "Building FIPS-enabled OpenSSL version $OPENSSL_VERSION with profile $PROFILE"

# Create temporary directory for build
BUILD_DIR=$(mktemp -d)
trap 'rm -rf "$BUILD_DIR"' EXIT

cd "$BUILD_DIR"

# Initialize Conan if needed
if ! conan profile list | grep -q "$PROFILE"; then
    echo "Profile $PROFILE not found. Creating default profile."
    conan profile detect
fi

# Build FIPS-enabled OpenSSL
echo "Running: conan create . --name=openssl-fips --version=$OPENSSL_VERSION --profile=$PROFILE -o fips=True"
conan create "$WORKSPACE_DIR" \
    --name=openssl-fips \
    --version="$OPENSSL_VERSION" \
    --profile="$PROFILE" \
    -o fips=True

# Locate FIPS module
echo "Locating FIPS module..."
FIPS_MODULE_PATH=$(conan cache path openssl-fips/"$OPENSSL_VERSION"@ \
    | xargs -I {} find {} -name "fips.so" 2>/dev/null | head -1)

if [ -z "$FIPS_MODULE_PATH" ]; then
    echo "Error: Could not locate fips.so module"
    exit 1
fi

echo "FIPS module found at: $FIPS_MODULE_PATH"
echo "Set OPENSSL_MODULES=$FIPS_MODULE_PATH"

# Export environment variable for subsequent scripts
export OPENSSL_MODULES="$FIPS_MODULE_PATH"
echo "OPENSSL_MODULES=$OPENSSL_MODULES" > "$WORKSPACE_DIR/.fips-env"

echo "FIPS-enabled OpenSSL build completed successfully"