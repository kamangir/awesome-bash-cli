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
        f"{NAME}.keywords",
        f"{NAME}.modules",
        f"{NAME}.modules.terraform",
        f"{NAME}.plugins",
        f"{NAME}.plugins.git",
        f"{NAME}.plugins.gpu",
        f"{NAME}.plugins.ssm",
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
