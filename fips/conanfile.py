"""
OpenSSL FIPS Policy Package
Provides FIPS 140-3 certificates, compliance data, and validation artifacts
"""

import os
from conan import ConanFile
from conan.tools.files import copy
from conan.tools.layout import basic_layout


class OpenSSLFIPSDataConan(ConanFile):
    name = "openssl-fips-data"
    version = "140-3.2"
    description = "FIPS 140-3 certificates, compliance data, and validation artifacts"
    license = "Public-Domain"
    url = "https://github.com/sparesparrow/openssl-fips-policy"
    homepage = "https://github.com/sparesparrow/openssl-fips-policy"
    topics = ("openssl", "fips", "fips-140-3", "security", "compliance", "certificate")

    # Package settings
    settings = "os", "arch", "compiler", "build_type"
    package_type = "data"

    # Export sources
    exports_sources = (
        "fips-140-3/*",
        "fips/*",
        "scripts/*",
        "validation/*",
        "schemas/*",
        "*.md",
        "LICENSE*"
    )

    def init(self):
        """Initialize with stable channel for compliance"""
        if not os.getenv("CONAN_CHANNEL"):
            self.user = "sparesparrow"
            self.channel = "stable"  # FIPS data must be from stable channel

    def layout(self):
        """Define package layout for data package"""
        basic_layout(self)

    def requirements(self):
        """FIPS data package has no dependencies"""
        pass

    def package(self):
        """Package FIPS compliance data"""
        # Copy FIPS 140-3 certificates and data
        copy(self, "*.json", src=os.path.join(self.source_folder, "fips-140-3"),
             dst=os.path.join(self.package_folder, "fips-140-3"), keep_path=True)
        copy(self, "*.txt", src=os.path.join(self.source_folder, "fips-140-3"),
             dst=os.path.join(self.package_folder, "fips-140-3"), keep_path=True)
        copy(self, "*.pdf", src=os.path.join(self.source_folder, "fips-140-3"),
             dst=os.path.join(self.package_folder, "fips-140-3"), keep_path=True)

        # Copy FIPS validation scripts
        copy(self, "*.sh", src=os.path.join(self.source_folder, "scripts"),
             dst=os.path.join(self.package_folder, "scripts"), keep_path=True)
        copy(self, "*.py", src=os.path.join(self.source_folder, "scripts"),
             dst=os.path.join(self.package_folder, "scripts"), keep_path=True)

        # Copy validation data
        copy(self, "*", src=os.path.join(self.source_folder, "validation"),
             dst=os.path.join(self.package_folder, "validation"), keep_path=True)

        # Copy JSON schemas
        copy(self, "*.json", src=os.path.join(self.source_folder, "schemas"),
             dst=os.path.join(self.package_folder, "schemas"), keep_path=True)

        # Copy documentation and licenses
        copy(self, "*.md", src=self.source_folder,
             dst=os.path.join(self.package_folder, "licenses"))
        copy(self, "LICENSE*", src=self.source_folder,
             dst=os.path.join(self.package_folder, "licenses"))

    def package_info(self):
        """Define package information for FIPS compliance"""
        # No C++ components - this is a data package
        self.cpp_info.bindirs = []
        self.cpp_info.libdirs = []
        self.cpp_info.includedirs = []

        # FIPS compliance environment variables
        self.runenv_info.define("FIPS_DATA_ROOT", self.package_folder)
        self.runenv_info.define("FIPS_CERTIFICATE_ID", "4985")
        self.runenv_info.define("FIPS_CERTIFICATE_VERSION", "140-3.2")
        self.runenv_info.define("FIPS_CERTIFICATE_PATH",
                                os.path.join(self.package_folder, "fips-140-3"))

        # Validation paths
        self.runenv_info.define("FIPS_VALIDATION_PATH",
                                os.path.join(self.package_folder, "validation"))
        self.runenv_info.define("FIPS_SCHEMAS_PATH",
                                os.path.join(self.package_folder, "schemas"))

        # Security properties
        self.cpp_info.set_property("fips_certificate", "4985")
        self.cpp_info.set_property("fips_version", "140-3")
        self.cpp_info.set_property("fips_compliant", "true")

    def package_id(self):
        """Package ID mode for FIPS data packages"""
        # FIPS data should be deterministic and immutable
        self.info.clear()

    def validate(self):
        """Validate FIPS compliance data integrity"""
        # Ensure certificate data exists
        cert_path = os.path.join(self.package_folder, "fips-140-3", "certificate-4985.json")
        if not os.path.exists(cert_path):
            raise Exception("FIPS certificate data not found - compliance violation")
