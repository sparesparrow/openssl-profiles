from conan import ConanFile
from conan.tools.files import copy
import os

class OpenSSLProfilesConan(ConanFile):
    name = "openssl-profiles"
    version = "2.0.1"
    package_type = "python-require"
    description = "Conan 2.x python_requires package providing OpenSSL build profiles and FIPS 140-3 policy integration"
    license = "MIT"
    url = "https://github.com/sparesparrow/openssl-profiles"
    homepage = "https://github.com/sparesparrow/openssl-profiles"
    topics = ("openssl", "conan", "profiles", "fips", "cryptography")
    exports_sources = "profiles/*", "fips/*", "config/*", "openssl_profiles/*"

    def layout(self):
        """Define the package layout for Conan 2.x"""
        # For python-require packages, we typically don't need complex layouts
        # but we can define the source and build folders
        pass

    def package(self):
        """Package all necessary files for profiles and FIPS data"""
        # Copy profiles directory
        copy(self, "**", src=os.path.join(self.source_folder, "profiles"),
             dst=os.path.join(self.package_folder, "profiles"))

        # Copy FIPS data
        copy(self, "**", src=os.path.join(self.source_folder, "fips"),
             dst=os.path.join(self.package_folder, "fips"))

        # Copy config directory
        copy(self, "**", src=os.path.join(self.source_folder, "config"),
             dst=os.path.join(self.package_folder, "config"))

        # Copy Python modules
        copy(self, "**", src=os.path.join(self.source_folder, "openssl_profiles"),
             dst=os.path.join(self.package_folder, "openssl_profiles"))

    def package_info(self):
        """Package information for consumers"""
        # This is a python-require package, no C++ components
        self.cpp_info.bindirs = []
        self.cpp_info.libdirs = []
        
        # Set Python path for the openssl_profiles module
        self.env_info.PYTHONPATH.append(os.path.join(self.package_folder, "openssl_profiles"))
        
        # Provide information about available profiles
        profiles_path = os.path.join(self.package_folder, "profiles")
        if os.path.exists(profiles_path):
            self.output.info(f"OpenSSL profiles available at: {profiles_path}")
            
        # Provide information about FIPS data
        fips_path = os.path.join(self.package_folder, "fips")
        if os.path.exists(fips_path):
            self.output.info(f"FIPS 140-3 data available at: {fips_path}")
