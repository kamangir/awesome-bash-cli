from typing import List, Dict
import math
from abcli.logger import logger


def generate_table(items: List[str], cols=3) -> List[str]:
    if not items:
        return []

    items_dict = {index: item for index, item in enumerate(items)}

    cols = min(cols, len(items))

    row_count = int(math.ceil(len(items) / cols))

    logger.info(
        "markdown.generate_table(): {} item(s), {} row(s)".format(
            len(items),
            row_count,
        )
    )

    return [
        "| {} |".format(" | ".join(cols * [" "])),
        "| {} |".format(" | ".join(cols * ["---"])),
    ] + [
        "| {} |".format(
            " | ".join(
                [items_dict.get(cols * row_index + index, "") for index in range(cols)]
            )
        )
        for row_index in range(row_count)
    ]
