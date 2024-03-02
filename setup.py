from setuptools import setup

from abcli import NAME, VERSION, DESCRIPTION

setup(
    name=NAME,
    author="kamangir",
    version=VERSION,
    description=DESCRIPTION,
    packages=[
        "abcli",
        "abcli.env",
        "abcli.file",
        "abcli.path",
        "abcli.modules",
        "abcli.modules.host",
        "abcli.plugins",
        "abcli.plugins.cache",
        "abcli.plugins.graphics",
        "abcli.plugins.metadata",
        "abcli.plugins.storage",
        "abcli.string",
        "abcli.table",
    ],
)
