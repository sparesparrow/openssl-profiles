from conan import ConanFile

class TestPackageConan(ConanFile):
    test_type = "explicit"

    def requirements(self):
        self.requires(self.tested_reference_str)

    def test(self):
        # Verify profiles are accessible
        import os
        profiles_path = os.path.join(self.dependencies[self.tested_reference_str].package_folder, "profiles")
        if os.path.exists(profiles_path):
            self.output.success(f"Profiles found at: {profiles_path}")
            # Count all .profile files recursively
            profile_count = 0
            for root, dirs, files in os.walk(profiles_path):
                profile_count += len([f for f in files if f.endswith('.profile')])
            self.output.info(f"Total profile count: {profile_count}")
        else:
            raise Exception("Profiles directory not found!")

        # Verify FIPS data is accessible
        fips_path = os.path.join(self.dependencies[self.tested_reference_str].package_folder, "fips")
        if os.path.exists(fips_path):
            self.output.success(f"FIPS data found at: {fips_path}")
            # Check for certificate #4985
            cert_path = os.path.join(fips_path, "certificates", "certificate-4985.json")
            if os.path.exists(cert_path):
                self.output.success("FIPS certificate #4985 found")
            else:
                self.output.info("FIPS certificate #4985 not found")
        else:
            self.output.info("FIPS directory not found")

        # Test Python module import (this will fail in test_package but that's expected)
        try:
            import openssl_profiles
            self.output.success("openssl_profiles module imported successfully")
        except ImportError as e:
            self.output.info(f"openssl_profiles import failed (expected in test_package): {e}")
