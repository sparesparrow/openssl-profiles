# ARCHIVED: openssl-profiles

**This repository has been merged into [openssl-conan-base](https://github.com/sparesparrow/openssl-conan-base).**

All profiles, FIPS data, and scripts are now maintained in the unified foundation package.

## Migration

```python
# Old
python_requires = "openssl-profiles/1.0.0"

# New (use this)
python_requires = "openssl-conan-base/1.1.0"
```

## What Was Merged

- **profiles/** → openssl-conan-base/profiles/
- **fips/** → openssl-conan-base/fips/
- **scripts/** → openssl-conan-base/scripts/

## Benefits of Consolidation

- Single source of truth for foundation utilities
- 40% fewer repositories to maintain
- Clearer 3-layer architecture
- Unified FIPS 140-3 support

See [openssl-conan-base](https://github.com/sparesparrow/openssl-conan-base) for current documentation and usage.

---

**Archived on**: October 27, 2024
**Merged into**: openssl-conan-base v1.1.0
**Tag**: `archived/merged-into-conan-base-v1.1.0`
