"""
Backward compatibility module for openssl_profiles imports.
This module re-exports all functions from the scripts package to maintain
compatibility with existing consumers.
"""

# Re-export all functions from the scripts module
import sys
import os
# Add current directory to path to enable imports
sys.path.insert(0, os.path.dirname(__file__))

from version_manager import get_openssl_version, parse_openssl_version
from sbom_generator import generate_openssl_sbom
from profile_deployer import deploy_openssl_profiles

__all__ = [
    "get_openssl_version",
    "parse_openssl_version",
    "generate_openssl_sbom",
    "deploy_openssl_profiles",
]