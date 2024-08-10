from typing import List
from blueness import module
from abcli import NAME as MY_NAME
from abcli import fullname
from abcli import file
from abcli.plugins import markdown
from abcli.logger import logger

MY_NAME = module.name(__file__, MY_NAME)


def build(
    items: List[str],
    template_filename: str,
    filename: str,
    NAME: str,
    VERSION: str,
    REPO_NAME: str,
    cols: int = 3,
):
    logger.info(
        "{}.build: {} -{}-{}-@-{}-#{}-> {}".format(
            MY_NAME,
            template_filename,
            NAME,
            VERSION,
            REPO_NAME,
            cols,
            filename,
        )
    )

    table = markdown.generate_table(items, cols=cols)

    signature = [
        "---",
        "built by [`{}`]({}), based on [`{}-{}`]({}).".format(
            fullname(),
            "https://github.com/kamangir/awesome-bash-cli",
            NAME,
            VERSION,
            f"https://github.com/kamangir/{REPO_NAME}",
        ),
    ]

    return file.build_from_template(
        template_filename,
        {
            "--table--": table,
            "--signature": signature,
        },
        filename,
    )
