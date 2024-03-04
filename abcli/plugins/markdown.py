import math
from abcli.logger import logger


def generate_table(items, cols=3):
    """generate markdown table.

    Args:
        items (List[str]): list of items.
        cols (int, optional): number of columns. Defaults to 3.

    Returns:
        List[str]: markdown table.
    """
    if not items:
        return []

    items = {index: item for index, item in enumerate(items)}

    cols = min(cols, len(items))

    row_count = int(math.ceil(len(items) / cols))
    logger.info(
        "markdown.generate_table(): {} item(s), {} row(s)".format(len(items), row_count)
    )

    return [
        "| {} |".format(" | ".join([items.get(index, "") for index in range(cols)])),
        "| {} |".format(" | ".join(cols * ["---"])),
    ] + [
        "| {} |".format(
            " | ".join(
                [items.get(cols * row_index + index, "") for index in range(cols)]
            )
        )
        for row_index in range(1, row_count)
    ]
