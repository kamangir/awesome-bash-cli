from setuptools import setup
import os

from abcli import NAME, VERSION, DESCRIPTION

with open(os.path.join(os.path.dirname(__file__), "README.md")) as f:
    long_description = f.read().replace(
        "./",
        "https://github.com/kamangir/awesome-bash-cli/raw/current/",
    )


setup(
    name=NAME,
    author="kamangir",
    version=VERSION,
    description=DESCRIPTION,
    long_description=long_description,
    long_description_content_type="text/markdown",
    packages=[
        NAME,
        f"{NAME}.bash",
        f"{NAME}.file",
        f"{NAME}.keywords",
        f"{NAME}.options",
        f"{NAME}.path",
        f"{NAME}.modules",
        f"{NAME}.modules.host",
        f"{NAME}.plugins",
        f"{NAME}.plugins.cache",
        f"{NAME}.plugins.graphics",
        f"{NAME}.plugins.git",
        f"{NAME}.plugins.gpu",
        f"{NAME}.plugins.metadata",
        f"{NAME}.plugins.relations",
        f"{NAME}.plugins.storage",
        f"{NAME}.plugins.tags",
        f"{NAME}.string",
        f"{NAME}.table",
        f"{NAME}.tests",
    ],
    package_data={
        NAME: ["config.env"],
    },
)
