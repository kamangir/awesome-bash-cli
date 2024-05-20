import re
import glob
import os
from abcli import file
from abcli.plugins.git import NAME
from abcli.logger import logger

NAME = f"{NAME}.version"


def increment(
    repo_path: str,
    verbose: bool = False,
) -> bool:
    logger.info(f"{NAME}.increment({repo_path})")

    list_of_paths = sorted(
        [
            file.path(filename)
            for filename in glob.glob(
                os.path.join(repo_path, "**", "__init__.py"),
                recursive=True,
            )
        ]
    )
    if verbose:
        logger.info(
            "{} options: {}".format(
                len(list_of_paths),
                ", ".join(list_of_paths),
            )
        )

    if not list_of_paths:
        logger.error("cannot find __init__.py, quitting.")
        return False

    filename = os.path.join(list_of_paths[0], "__init__.py")
    success, source_code = file.load_text(filename)
    if not success:
        return success

    version_pattern = r'^(VERSION\s*=\s*")(\d+\.\d+\.\d+)(")$'
    updated_source_code = []
    for line in source_code:
        match = re.match(version_pattern, line)
        if match:
            version_parts = match.group(2).split(".")
            version_parts[1] = str(int(version_parts[1]) + 1)
            updated_line = match.group(1) + ".".join(version_parts) + match.group(3)

            logger.info(f"{line} -> {updated_line}")

            updated_source_code.append(updated_line)
        else:
            updated_source_code.append(line)

    while updated_source_code and not updated_source_code[len(updated_source_code) - 1]:
        updated_source_code = updated_source_code[:-1]

    return file.save_text(filename, updated_source_code, log=True)
