# Make coding more python3-ish
from __future__ import absolute_import, division, print_function

__metaclass__ = type


def normalize_distinguished_name(distinguished_name: str) -> str:
    """Normalizes distinguished name LDAP path
    Args:    distinguished_name: ldap path to normalize.
    Returns: ldap path to normalized
    """
    split_distinguished_name = [
        container.split("=") for container in distinguished_name.split(",")
    ]
    normalized_distinguished_name = ",".join(
        [
            "=".join([label.upper(), container])
            for label, container in split_distinguished_name
        ]
    )
    return normalized_distinguished_name


class FilterModule(object):
    """Ansible win_domain_ous filters."""

    def filters(self):
        return {
            "normalize_distinguished_name": normalize_distinguished_name,
        }
