# FIPS 140-3 Module Validation and Compliance Automation

This directory contains automated scripts for comprehensive FIPS 140-3 module validation and compliance testing.

## Overview

The FIPS validation automation performs the following key functions:

1. **FIPS-Enabled OpenSSL Build**: Builds OpenSSL with FIPS support using Conan
2. **Module Verification**: Locates and verifies FIPS module integrity
3. **Self-Test Validation**: Runs and validates FIPS self-tests
4. **Configuration Generation**: Creates per-platform fipsmodule.cnf files
5. **Cross-Platform Testing**: Tests across multiple platforms using isolated environments
6. **Algorithm Validation**: Ensures approved algorithms work and restricted ones fail
7. **Deprecated API Detection**: Tests compilation with deprecated APIs and runs CodeQL scans
8. **SBOM Generation**: Creates software bill of materials with syft
9. **Security Scanning**: Runs vulnerability scans with trivy

## Files

- `fips-compliance-validation.sh` - Main validation orchestration script
- `run-platform-tests.sh` - Platform-specific test runner
- `README.md` - This documentation

## Usage

### Automated GitHub Actions

The validation runs automatically via GitHub Actions on:
- Push to main branch affecting validation scripts
- Pull requests affecting validation scripts
- Manual workflow dispatch

### Local Execution

```bash
# Make scripts executable
chmod +x scripts/fips-validation/*.sh

# Run full validation
./scripts/fips-validation/fips-compliance-validation.sh
```

### Manual Platform Testing

```bash
# Test specific platform
./scripts/fips-validation/run-platform-tests.sh ubuntu-22.04
```

## Requirements

### System Dependencies

- **OpenSSL**: For FIPS operations
- **Conan**: Package management
- **Docker**: Cross-platform testing (optional)
- **GCC**: Compilation testing

### Optional Tools (for enhanced validation)

- **CodeQL CLI**: Static analysis for deprecated API detection
- **Syft**: SBOM generation
- **Trivy**: Security vulnerability scanning

## Validation Phases

### 1. FIPS Build & Module Location
```bash
conan create . --name=openssl-fips --version=3.0.8 --profile=linux-gcc11 -o fips=True
```
Locates `fips.so` module and sets `OPENSSL_MODULES` environment variable.

### 2. Self-Test Verification
```bash
openssl fipsinstall -verify -module /path/to/fips.so
```
Parses output for `INSTALL_SELF_TEST_KATS_RUN` confirmation.

### 3. Configuration Generation
```bash
openssl fipsinstall -out fipsmodule.cnf -module /path/to/fips.so
```
Validates HMAC-SHA256 checksum in generated configuration.

### 4. Cross-Platform Matrix Testing
Uses Docker containers for isolated testing across:
- ubuntu-22.04
- ubuntu-24.04
- windows-2022
- macos-14

Ensures no `fipsmodule.cnf` file reuse between runners.

### 5. Algorithm Restrictions Testing
```bash
export OPENSSL_CONF=fipsmodule.cnf
openssl sha256 -provider fips -in testfile.txt  # Should succeed
openssl md5 -in testfile.txt                    # Should fail
```

### 6. Approved Algorithms Validation
Validates availability of:
- AES-256-GCM
- SHA-256, SHA-384
- RSA-2048
- ECDSA-P256

### 7. Deprecated API Rejection
```bash
gcc test_deprecated.c -lcrypto -Werror=deprecated-declarations
```
Should fail compilation with deprecated APIs like `EVP_MD_CTX_new()`, `ENGINE_*`.

### 8. CodeQL Security Scan
```bash
codeql database analyze openssl-fips-db .github/codeql/fips-deprecation-check.ql
```
Detects zero deprecated API usages.

### 9. SBOM Generation
```bash
syft packages . -o spdx-json > openssl-fips-sbom.spdx.json
jq '.packages[] | select(.name | contains("openssl")) | .version'
```

### 10. Security Scanning
```bash
trivy config . --policy .trivyignore --severity CRITICAL
```

## Performance Requirements

- **Runtime**: < 8 minutes total
- **Self-tests**: Must pass on all platforms
- **Isolation**: No configuration file reuse between runners
- **Algorithms**: MD5/RC4/DES unavailable in FIPS mode

## Certificate Compliance

Validated against **FIPS 140-3 Certificate #4985** with:
- Security Level 1
- OpenSSL 3.1.2 FIPS Provider
- Platforms: Linux x86_64 (RHEL 8, 9), Windows x86_64 (Server 2019+)

## Troubleshooting

### Common Issues

1. **FIPS module not found**
   - Ensure Conan cache contains FIPS-enabled OpenSSL
   - Check `~/.conan2` directory structure

2. **Self-tests failing**
   - Verify FIPS module integrity
   - Check system OpenSSL installation

3. **Algorithm restrictions not working**
   - Confirm `OPENSSL_CONF` environment variable
   - Verify FIPS mode activation

4. **Compilation succeeds with deprecated APIs**
   - Check GCC version and warning flags
   - Verify OpenSSL development headers

### Debug Mode

Run with verbose output:
```bash
bash -x ./scripts/fips-validation/fips-compliance-validation.sh
```

## Integration

This validation suite integrates with:
- **openssl-fips-policy**: Provides certificate data
- **openssl-tools**: Orchestrates builds
- **openssl**: Core cryptographic library
- **GitHub Actions**: Automated CI/CD validation

## Security Considerations

- Runs in isolated environments
- Validates cryptographic module integrity
- Checks for deprecated API usage
- Generates SBOM for supply chain verification
- Scans for critical security vulnerabilities

## Contributing

When modifying validation logic:
1. Update corresponding test phases
2. Maintain performance requirements
3. Ensure cross-platform compatibility
4. Update documentation