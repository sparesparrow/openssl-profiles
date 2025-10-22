from conan import ConanFile
from conan.tools.files import copy
import os

class OpenSSLProfilesConan(ConanFile):
    name = "openssl-profiles"
    version = "2.0.0"  # Major bump for breaking change
    package_type = "python-require"
    exports = "profiles/*", "fips/*", "config/*", "openssl_profiles/*"
    
    def package(self):
        copy(self, "*.profile", src="profiles", dst=os.path.join(self.package_folder, "profiles"))
        copy(self, "*.json", src="fips", dst=os.path.join(self.package_folder, "fips"))
        copy(self, "*", src="config", dst=os.path.join(self.package_folder, "config"))
        copy(self, "*", src="openssl_profiles", dst=os.path.join(self.package_folder, "openssl_profiles"))
    
    def package_info(self):
        self.cpp_info.bindirs = []
        self.cpp_info.libdirs = []
