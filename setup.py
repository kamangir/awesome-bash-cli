from abcli import NAME, VERSION, DESCRIPTION, REPO_NAME
from blueness.pypi import setup

setup(
    filename=__file__,
    repo_name=REPO_NAME,
    name=NAME,
    version=VERSION,
    description=DESCRIPTION,
    packages=[
        NAME,
        f"{NAME}.bash",
        f"{NAME}.file",
        f"{NAME}.keywords",
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
        NAME: [
            "config.env",
            ".abcli/**/*.sh",
            "assets/**/*",
        ],
    },
)
