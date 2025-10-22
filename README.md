# openssl-profiles

Conan 2.x python_requires package providing:
- Cross-platform build profiles (linux-gcc11, windows-msvc193, macos-arm64)
- FIPS 140-3 policy integration (certificates, test vectors, constraints)
- Conan configuration and hooks

## Usage

```python
# In your conanfile.py
python_requires = "openssl-profiles/2.0.0"
```

## Structure

- `profiles/` - Platform-specific Conan profiles
- `fips/` - FIPS 140-3 validation data (merged from openssl-fips-policy)
- `config/` - Conan hooks and global config
- `openssl_profiles/` - Python utilities and helpers

## Migration from openssl-conan-base

This package replaces `openssl-conan-base` and merges content from `openssl-fips-policy`:

```python
# Old
python_requires = "openssl-conan-base/1.0.1"

# New
python_requires = "openssl-profiles/2.0.0"
```

## Version History

- **v2.0.0**: Initial release merging openssl-conan-base + openssl-fips-policy
- **v1.x**: Legacy openssl-conan-base versions (deprecated)