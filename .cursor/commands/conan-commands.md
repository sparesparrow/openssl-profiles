---
description: Conan package manager commands for creating, building, and managing packages
globs: ["**/conanfile.py", "**/test_package/**", "**/*.profile", "conan/**"]
alwaysApply: true
category: "Conan Commands"
version: "1.0.0"
---

# Conan Commands

Conan package manager operations for creating, building, testing, and managing packages.

## Package Creation Commands

### 📦 Create Basic Package
- **ID**: `conan.create-basic`
- **Description**: Creates a basic conanfile.py template with essential structure
- **Command**: Creates a complete CMake-based Conan package template
- **Category**: Conan
- **Group**: conan

### 📄 Create Header-Only Package
- **ID**: `conan.create-header-only`
- **Description**: Creates a header-only library conanfile.py
- **Command**: Creates a header-only library template with proper package_id clearing
- **Category**: Conan
- **Group**: conan

### 🧪 Create Basic Test Package
- **ID**: `conan.test-basic`
- **Description**: Creates a basic test_package structure
- **Command**: Creates test_package directory with conanfile.py for testing
- **Category**: Conan
- **Group**: conan

## Profile Management Commands

### 🐧 Create Linux GCC Profile
- **ID**: `conan.profile-linux-gcc`
- **Description**: Creates a Linux GCC profile
- **Command**: Creates linux-gcc.profile with GCC 11, Ninja generator, and system package manager
- **Category**: Conan
- **Group**: conan

### 🪟 Create Windows MSVC Profile
- **ID**: `conan.profile-windows-msvc`
- **Description**: Creates a Windows MSVC profile
- **Command**: Creates windows-msvc.profile with MSVC 2022 and Visual Studio generator
- **Category**: Conan
- **Group**: conan

## Build Commands

### 🐛 Build Debug
- **ID**: `conan.build-debug`
- **Description**: Creates debug build configuration
- **Command**: `conan create . --profile=debug --build=missing`
- **Category**: Conan
- **Group**: conan

### 🚀 Build Release
- **ID**: `conan.build-release`
- **Description**: Creates release build configuration
- **Command**: `conan create . --profile=release --build=missing`
- **Category**: Conan
- **Group**: conan

## CI/CD Commands

### ⚙️ CI Setup
- **ID**: `conan.ci-setup`
- **Description**: Sets up CI/CD environment
- **Command**: `pip install conan && conan profile detect --force && conan install . --build=missing && conan create . --build=missing`
- **Category**: Conan
- **Group**: conan

### 🏗️ CI Build Matrix
- **ID**: `conan.ci-build-matrix`
- **Description**: Build package for multiple configurations
- **Command**: `conan create . --build=missing -s build_type=Debug && conan create . --build=missing -s build_type=Release`
- **Category**: Conan
- **Group**: conan

## OpenSSL Extension Commands

### 🔧 OpenSSL Configure
- **ID**: `conan.openssl-configure`
- **Description**: Configure OpenSSL build environment with platform detection
- **Command**: `conan openssl configure --profile=ci-linux-gcc --build-type=Release --verbose`
- **Category**: Conan
- **Group**: openssl

### 🏗️ OpenSSL Build
- **ID**: `conan.openssl-build`
- **Description**: Build OpenSSL with Conan integration and database tracking
- **Command**: `conan openssl build --profile=ci-linux-gcc --test --verbose`
- **Category**: Conan
- **Group**: openssl

### 📦 OpenSSL Package
- **ID**: `conan.openssl-package`
- **Description**: Package OpenSSL with SBOM generation and metadata
- **Command**: `conan openssl package --sbom --sbom-format=cyclonedx --verbose`
- **Category**: Conan
- **Group**: openssl

### 📚 OpenSSL Docs
- **ID**: `conan.openssl-docs`
- **Description**: Generate and format OpenSSL documentation from sources
- **Command**: `conan openssl docs --format=html --sections=all --verbose`
- **Category**: Conan
- **Group**: openssl

### 🏃 OpenSSL Benchmark
- **ID**: `conan.openssl-benchmark`
- **Description**: Run performance benchmarks and generate reports
- **Command**: `conan openssl benchmark --benchmarks=all --iterations=1000 --format=json --verbose`
- **Category**: Conan
- **Group**: openssl

### 🔍 OpenSSL Scan
- **ID**: `conan.openssl-scan`
- **Description**: Execute comprehensive security scans (SAST/DAST)
- **Command**: `conan openssl scan --scan-types=all --tools=all --severity=medium --verbose`
- **Category**: Conan
- **Group**: openssl

## Package Management Commands

### 📤 Upload Package
- **ID**: `conan.upload`
- **Description**: Uploads package to remote
- **Command**: `conan upload mypackage/1.0.0@user/channel -r=myremote --all`
- **Category**: Conan
- **Group**: conan

### 🔄 Create Package
- **ID**: `conan.create`
- **Description**: Create and test package in one command
- **Command**: `conan create . --build=missing`
- **Category**: Conan
- **Group**: conan

### 📝 Export Package
- **ID**: `conan.export`
- **Description**: Export package to local cache
- **Command**: `conan export .`
- **Category**: Conan
- **Group**: conan

### 🔧 Configure Remote
- **ID**: `conan.remote-add`
- **Description**: Add Conan remote repository
- **Command**: `conan remote add myremote https://api.bintray.com/conan/myuser/myrepo`
- **Category**: Conan
- **Group**: conan

### 🔐 Login Remote
- **ID**: `conan.login`
- **Description**: Authenticate with remote
- **Command**: `conan remote login myremote username`
- **Category**: Conan
- **Group**: conan

### 🧹 Clean Cache
- **ID**: `conan.clean`
- **Description**: Cleans Conan cache
- **Command**: `conan cache clean "*" --force`
- **Category**: Conan
- **Group**: conan

### 🔍 Search Packages
- **ID**: `conan.search`
- **Description**: Search for packages in remotes
- **Command**: `conan search "*" -r=all`
- **Category**: Conan
- **Group**: conan

### 📋 List Installed
- **ID**: `conan.list`
- **Description**: List installed packages
- **Command**: `conan list "*"`
- **Category**: Conan
- **Group**: conan

### 📊 Package Info
- **ID**: `conan.info`
- **Description**: Show package information and dependencies
- **Command**: `conan info . --graph=graph.html`
- **Category**: Conan
- **Group**: conan

### 🔧 Profile Detect
- **ID**: `conan.profile-detect`
- **Description**: Auto-detect system profile
- **Command**: `conan profile detect --force`
- **Category**: Conan
- **Group**: conan

### 📦 Install Dependencies
- **ID**: `conan.install`
- **Description**: Install package dependencies
- **Command**: `conan install . --build=missing`
- **Category**: Conan
- **Group**: conan

### 🏗️ Build Package
- **ID**: `conan.build`
- **Description**: Build package from source
- **Command**: `conan build .`
- **Category**: Conan
- **Group**: conan

### 🧪 Test Package
- **ID**: `conan.test`
- **Description**: Run package tests
- **Command**: `conan test test_package openssl-profiles/2.0.1@sparesparrow/stable`
- **Category**: Conan
- **Group**: conan

## Python-Require Commands

### 🐍 Create Python-Require
- **ID**: `conan.create-python-require`
- **Description**: Creates a python-require package template
- **Command**: Creates conanfile.py with package_type = "python-require"
- **Category**: Conan
- **Group**: python-require

### 📦 Install Python-Require
- **ID**: `conan.install-python-require`
- **Description**: Install python-require package
- **Command**: `conan install openssl-profiles/2.0.1@sparesparrow/stable`
- **Category**: Conan
- **Group**: python-require

### 🔧 Deploy Profiles
- **ID**: `conan.deploy-profiles`
- **Description**: Deploy OpenSSL profiles to user directory
- **Command**: `python -c "from openssl_profiles import deploy_openssl_profiles; deploy_openssl_profiles()"`
- **Category**: Conan
- **Group**: python-require

## FIPS Compliance Commands

### 🔒 Generate FIPS SBOM
- **ID**: `conan.fips-sbom`
- **Description**: Generate FIPS-compliant SBOM
- **Command**: `python -c "from openssl_profiles import generate_openssl_sbom; generate_openssl_sbom('openssl', '3.4.1', True, '4985')"`
- **Category**: Conan
- **Group**: fips

### 📋 Validate FIPS Certificate
- **ID**: `conan.validate-fips`
- **Description**: Validate FIPS 140-3 certificate data
- **Command**: `python -c "import json; print(json.load(open('fips/certificates/certificate-4985.json'))['expiry_date'])"`
- **Category**: Conan
- **Group**: fips

### 🏛️ Government Deployment
- **ID**: `conan.gov-deployment`
- **Description**: Create government-grade FIPS deployment
- **Command**: `conan create . --build=missing -o deployment_target=fips-government`
- **Category**: Conan
- **Group**: fips

## Usage

### In Cursor IDE
1. Open Command Palette (`Ctrl+Shift+P`)
2. Type command ID (e.g., `conan.create-basic`)
3. Execute with Enter

### Package Development Workflow
1. **Create Package**: Use `conan.create-basic` or `conan.create-header-only`
2. **Create Test**: Use `conan.test-basic` to add testing
3. **Create Profiles**: Use profile commands for different platforms
4. **Build**: Use `conan.build-debug` or `conan.build-release`
5. **Upload**: Use `conan.upload` to distribute

### Profile Management
- **Linux Development**: Use `conan.profile-linux-gcc`
- **Windows Development**: Use `conan.profile-windows-msvc`
- **CI/CD**: Use `conan.ci-setup` for automated environments

## Template Details

### Basic Package Template
Creates a complete CMake-based package with:
- Standard Conan 2.x structure
- CMake integration
- Shared/static library options
- Proper requirements handling

### Header-Only Template
Creates a header-only library with:
- No build system required
- Proper package_id clearing
- Include directory structure
- No binary directories

### Test Package Template
Creates a test package with:
- CMake-based testing
- Explicit requirements
- Proper test execution

## Environment Requirements
- Conan 2.x installed
- CMake (for CMake-based packages)
- Appropriate compiler toolchain
- Git (for version control)

## Troubleshooting

### Profile Issues
- Ensure profiles are in correct location (`~/.conan2/profiles/`)
- Check compiler versions are available
- Verify generator compatibility
- Use `conan profile detect --force` to regenerate

### Build Failures
- Check dependencies are available with `conan search "*"`
- Verify profile settings with `conan profile show <profile>`
- Use `conan cache clean "*"` for fresh start
- Check for missing system packages

### Upload Issues
- Verify remote configuration with `conan remote list`
- Check authentication with `conan remote login`
- Ensure package is built successfully
- Verify package exists with `conan list "*"`

### Python-Require Issues
- Ensure package is installed: `conan install <package>`
- Check Python path configuration
- Verify module imports work correctly
- Use `conan info .` to check dependencies

### FIPS Compliance Issues
- Verify certificate data is present
- Check FIPS mode is enabled
- Ensure proper deployment target
- Validate SBOM generation

## OpenSSL-Profiles Specific Commands

### 🚀 Quick Start
- **ID**: `openssl-profiles.quick-start`
- **Description**: Quick setup for openssl-profiles
- **Command**: `conan create . --build=missing && python -c "from openssl_profiles import deploy_openssl_profiles; deploy_openssl_profiles()"`
- **Category**: OpenSSL
- **Group**: openssl-profiles

### 📊 Generate Compliance Report
- **ID**: `openssl-profiles.compliance-report`
- **Description**: Generate FIPS compliance report
- **Command**: `python fips_compliance_demo.py`
- **Category**: OpenSSL
- **Group**: openssl-profiles

### 🔧 Integration Test
- **ID**: `openssl-profiles.integration-test`
- **Description**: Run integration tests
- **Command**: `./integration_test.sh`
- **Category**: OpenSSL
- **Group**: openssl-profiles
