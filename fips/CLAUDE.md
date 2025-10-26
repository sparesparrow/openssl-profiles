# OpenSSL FIPS Policy - Compliance Data Package

## 📦 Package Overview
- **Name**: `openssl-fips-data`
- **Version**: `140-3.2` (current)
- **Channel**: `stable`
- **User**: `sparesparrow`
- **Purpose**: FIPS 140-3 certificates and compliance data for OpenSSL

## 🔄 Version Management Rules

### Before Making Changes
1. **ALWAYS update version first** in `conanfile.py`
2. **NEVER modify conanfile.py** without version bump
3. **Commit version change** before calling `conan create`

### Version Update Workflow
```bash
# 1. Update version in conanfile.py
version = "140-3.3"  # Increment appropriately

# 2. Commit the change
git add conanfile.py
git commit -m "bump: openssl-fips-data to 140-3.3"

# 3. Build and upload
conan create . --build=missing
conan upload openssl-fips-data/140-3.3@sparesparrow/stable -r=sparesparrow-conan
```

## 📋 Package Contents

### Exported Sources
- `fips-140-3/*` - FIPS 140-3 certificate data and schemas

### Package Artifacts
- **Certificate Data**: `fips-140-3/` directory with JSON certificate files
- **Validation Files**: `fips/` directory with text validation files
- **Scripts**: `scripts/` directory with shell validation scripts

### Environment Variables
- `FIPS_DATA_ROOT` - Root path to FIPS data
- `FIPS_CERTIFICATE_ID` - Certificate ID (4985)

### Properties
- `fips_certificate` - Set to "4985" for CMake integration

## 🏗️ Build Process

### Dependencies
- **None** - This is a foundation data package

### Build Commands
```bash
# Install dependencies
conan install . --build=missing

# Create package
conan create . --build=missing

# Upload to remote
conan upload openssl-fips-data/140-3.2@sparesparrow/stable -r=sparesparrow-conan
```

## 🧪 Validation

### Package Validation
```bash
# Check package contents
conan cache path openssl-fips-data/140-3.2@sparesparrow/stable

# Validate with script
python ../scripts/validate-conan-packages.py openssl-fips-data/140-3.2
```

### Expected Contents
- ✅ `fips-140-3/` directory with certificate JSON files
- ✅ `fips/` directory with validation text files
- ✅ `scripts/` directory with validation shell scripts
- ✅ Environment variables properly set
- ✅ FIPS certificate property set

## 🔗 Dependencies

### Consumed By
- `openssl` - Requires this package for FIPS compliance
- `openssl-tools` - May require this package for validation

### Version Compatibility
- **FIPS versions** follow FIPS standard numbering
- **Certificate updates** require version bump
- **Compliance changes** may require major version updates

## 🚨 Critical Notes

1. **Compliance Package**: Contains official FIPS 140-3 certificate data
2. **Certificate #4985**: OpenSSL FIPS 140-3 certificate
3. **Stable Channel**: Always use stable channel for compliance
4. **Data Package**: No compilation, just data files
5. **Government Ready**: Suitable for government and regulated environments

## 📝 Change Log

### Version 140-3.2
- Fixed package() method to properly copy all FIPS data
- Added proper package_info() with environment variables
- Removed dependency on non-existent base_conanfile

### Version 140-3.1
- Initial release with FIPS 140-3 certificate data
- Certificate #4985 data and validation files