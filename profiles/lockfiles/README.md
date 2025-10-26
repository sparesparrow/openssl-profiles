# OpenSSL Lockfiles

This directory contains Conan lockfiles for all supported OpenSSL build configurations.

## Usage

Use these lockfiles to ensure reproducible builds:

```bash
conan install openssl --lockfile=openssl-profiles/profiles/lockfiles/linux-gcc-shared.lock
```

## Configurations

- **linux-gcc-shared**: Profile `linux-gcc11`, Shared=True, FIPS=False
- **linux-gcc-static**: Profile `linux-gcc11`, Shared=False, FIPS=False
- **linux-gcc-fips**: Profile `linux-gcc11`, Shared=False, FIPS=True
- **linux-clang-shared**: Profile `linux-clang15`, Shared=True, FIPS=False
- **linux-clang-static**: Profile `linux-clang15`, Shared=False, FIPS=False
- **linux-clang-fips**: Profile `linux-clang15`, Shared=False, FIPS=True

## Metadata

- **Generated**: 2025-10-24T05:37:14Z
- **OpenSSL Version**: 4.0.0-dev
- **Total Configurations**: 6
