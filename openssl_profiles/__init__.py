"""OpenSSL Base - Foundation utilities"""
__version__ = "1.0.0"

from .version_manager import get_openssl_version, parse_openssl_version
from .sbom_generator import generate_openssl_sbom
from .profile_deployer import deploy_openssl_profiles

__all__ = [
    "get_openssl_version",
    "parse_openssl_version",
    "generate_openssl_sbom",
    "deploy_openssl_profiles",
]
