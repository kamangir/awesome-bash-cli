from functools import reduce
import json
from abcli import string
from abcli.table import Table
from abcli.logger import logger


columns = "keyword,value,timestamp".split(",")


def create():
    """create the cache table.

    Returns:
        bool: success.
    """
    return Table.Create(
        "cache",
        [
            "keyword VARCHAR(1024) NOT NULL",
            "value VARCHAR(4096) NOT NULL",
        ],
    )


def clone(source, destination):
    """clone source in destination.

    Args:
        source (str): source.
        destination (str): destination.

    Returns:
        bool: success.
    """
    lut = search(f"{source}.%")

    lut = {
        "{}.{}".format(
            destination,
            string.after(
                keyword,
                f"{source}.",
            ),
        ): value
        for keyword, value in lut.items()
    }

    return reduce(
        lambda x, y: x and y,
        [write(keyword, value) for keyword, value in lut.items()],
        True,
    )


def read(
    keyword,
    all=False,
    dataframe=False,
    like=False,
    unique=False,
):
    """read keyword form cache.

    Args:
        keyword (str): keyword.
        all (bool, optional): return all values. Defaults to False.
        dataframe (bool, optional): return dataframe. Defaults to False.
        like (bool, optional): like. Defaults to False.
        unique (bool, optional): return unique values. Defaults to False.

    Returns:
        Any: output.
    """
    if dataframe:
        all = True

    table = Table(name="cache")

    if isinstance(keyword, list):
        keyword = ".".join(keyword)

    if not table.connect():
        return None

    success, output = table.execute(
        (
            "SELECT {} FROM ".format(
                ",".join(["c.{}".format(column) for column in columns])
            )
            + "abcli.cache c "
        )
        + (
            (
                "INNER JOIN ( "
                "SELECT keyword, MAX(timestamp) AS max_timestamp "
                "From abcli.cache "
                "GROUP BY keyword "
                ") cm ON c.keyword = cm.keyword AND c.timestamp = cm.max_timestamp "
            )
            if unique
            else ""
        )
        + (
            "WHERE c.keyword {} '{}' ".format("like" if like else "=", keyword)
            + "ORDER BY c.timestamp DESC "
            + "{};".format(
                "" if all else "LIMIT 1",
            )
        )
    )
    if not success:
        return None

    if not table.disconnect():
        return None

    output = [
        {keyword: item for keyword, item in zip(columns, thing)} for thing in output
    ]

    if not dataframe:
        output = [item["value"] for item in output]

    if not all:
        output = "" if not output else output[0]

    if dataframe:
        import pandas as pd

        output = pd.DataFrame.from_dict(output)

    return output


def search(keyword):
    """search cache for keyword.

    Args:
        keyword (str): keyword.

    Returns:
        dict: {keyword:value}
    """
    table = Table(name="cache")

    if isinstance(keyword, list):
        keyword = ".".join(keyword)

    if not table.connect():
        return {}

    success, output = table.execute(
        "SELECT keyword,value FROM abcli.cache "
        f"WHERE keyword like '{keyword}' "
        "ORDER BY timestamp ASC;"
    )

    if success:
        success = table.disconnect()

    return {thing[0]: thing[1] for thing in output} if success else {}


def search_value(value):
    """search for value in cache.

    Args:
        value (str): value.

    Returns:
        List[str]: list of keywords.
    """
    table = Table(name="cache")

    if not table.connect():
        return []

    success, output = table.execute(
        "SELECT keyword,value FROM abcli.cache "
        f"WHERE value = '{value}' "
        "ORDER BY timestamp DESC;"
    )

    if success:
        success = table.disconnect()

    return [thing[0] for thing in output] if success else []


def write(keyword, value):
    """write keyword=value in cache.

    Args:
        keyword (str): keyword.
        value (str): value.

    Returns:
        bool: success.
    """
    table = Table(name="cache")

    if isinstance(keyword, list):
        keyword = ".".join(keyword)

    if isinstance(value, dict):
        value = json.dumps(value)

    if not table.connect():
        return False

    success = table.insert(
        ["keyword", "value"],
        [keyword, value],
    )

    if success:
        success = table.disconnect()

    if success:
        logger.info("cache[{}] <- {}".format(keyword, value))

    return success
