from typing import List
import os
from blueness import module
from abcli import NAME as MY_NAME, ICON as MY_ICON
from abcli import fullname
from abcli import file
from abcli.plugins import markdown
from abcli.logger import logger

MY_NAME = module.name(__file__, MY_NAME)


def build(
    NAME: str,
    VERSION: str,
    REPO_NAME: str,
    items: List[str] = [],
    template_filename: str = "",
    filename: str = "",
    path: str = "",
    cols: int = 3,
    ICON: str = "",
) -> bool:
    if path:
        template_filename = os.path.join(path, "template.md")
        filename = os.path.join(path, "README.md")

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
        f'to use on [AWS SageMaker](https://aws.amazon.com/sagemaker/) replace `<plugin-name>` with "{NAME}" and follow [these instructions](https://github.com/kamangir/notebooks-and-scripts/blob/main/SageMaker.md).',
        "",
        " ".join(
            [
                f"[![pylint](https://github.com/kamangir/{REPO_NAME}/actions/workflows/pylint.yml/badge.svg)](https://github.com/kamangir/{REPO_NAME}/actions/workflows/pylint.yml)",
                f"[![pytest](https://github.com/kamangir/{REPO_NAME}/actions/workflows/pytest.yml/badge.svg)](https://github.com/kamangir/{REPO_NAME}/actions/workflows/pytest.yml)",
                f"[![bashtest](https://github.com/kamangir/{REPO_NAME}/actions/workflows/bashtest.yml/badge.svg)](https://github.com/kamangir/{REPO_NAME}/actions/workflows/bashtest.yml)",
                f"[![PyPI version](https://img.shields.io/pypi/v/{REPO_NAME}.svg)](https://pypi.org/project/{REPO_NAME}/)",
            ]
        ),
        "",
        "built by {} [`{}`]({}), based on {}[`{}-{}`]({}).".format(
            MY_ICON,
            fullname(),
            "https://github.com/kamangir/awesome-bash-cli",
            f"{ICON} " if ICON else "",
            NAME,
            VERSION,
            f"https://github.com/kamangir/{REPO_NAME}",
        ),
    ]

    success, template = file.load_text(template_filename)
    if not success:
        return success

    content: List[str] = []
    for template_line in template:
        content_section: List[str] = [template_line]

        if "--table--" in template_line:
            content_section = table
        elif "--signature" in template_line:
            content_section = signature
        elif "--include--" in template_line:
            include_filename_relative = template_line.split(" ")[1].strip()
            include_filename = file.absolute(
                include_filename_relative,
                file.path(template_filename),
            )

            success, content_section = file.load_text(include_filename)
            if not success:
                return success

            content_section = [
                line for line in content_section if not line.startswith("used by:")
            ]

            include_title = (template_line.split(" ", 2) + ["", "", ""])[2]
            if include_title:
                content_section = [f"## {include_title}"] + content_section[1:]

            content_section += [
                "using [{}]({}).".format(
                    file.name(include_filename),
                    include_filename_relative,
                )
            ]

            logger.info(f"{MY_NAME}.build: including {include_filename} ...")

        content += content_section

    return file.save_text(filename, content)
