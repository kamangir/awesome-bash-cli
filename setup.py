from setuptools import setup

from abcli import NAME, VERSION, DESCRIPTION

setup(
    name=NAME,
    author="kamangir",
    version=VERSION,
    description=DESCRIPTION,
    packages=[
        "abcli",
        "abcli.file",
        "abcli.path",
        "abcli.modules",
        "abcli.plugins",
        "abcli.string",
        "abcli.table",
    ],
)
