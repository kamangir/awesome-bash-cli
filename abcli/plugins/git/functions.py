import re
import glob
import os
from abcli import file
from abcli.plugins.git import NAME
from abcli.logger import logger


def increment_version(repo_path: str) -> bool:
    logger.info(f"{NAME}.increment_version({repo_path})")

    filename = sorted(
        glob.glob(
            os.path.join(repo_path, "**", "__init__.py"),
            recursive=True,
        )
    )
    if not filename:
        logger.error("cannot find __init__.py, quitting.")
        return False

    filename = filename[0]
    success, source_code = file.load_text(filename, log=True)
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

    return file.save_text(filename, updated_source_code)
