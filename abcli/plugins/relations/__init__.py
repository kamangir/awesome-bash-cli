from functools import reduce
import os
from ... import *
from ... import file
from ...table import Table
from ... import logging
import logging

logger = logging.getLogger(__name__)

name = f"{shortname}.plugins.tags"

_, inverse_of = file.load_json(
    os.path.join(
        os.getenv("abcli_path_abcli"), "abcli/plugins/relations/relations.json"
    )
)
inverse_of.update({inverse_of[relation]: relation for relation in inverse_of})
inverse_of[""] = ""

list_of = sorted(list(set(list(inverse_of.keys()) + list(inverse_of.values()))))


columns = "object_1,object_2,relation,timestamp".split(",")


def create():
    """create the relations table.

    Returns:
        bool: success.
    """
    return Table.Create(
        "relations",
        [
            "object_1 VARCHAR(256) NOT NULL",
            "object_2 VARCHAR(256) NOT NULL",
            "relation VARCHAR(256) NOT NULL",
        ],
    )


def get(object_1, object_2):
    """get relation between object_1 and object_2.

    Args:
        object_1 (str): object 1.
        object_2 (str): object 2.

    Returns:
        str: relation.
    """

    if object_1 > object_2:
        return inverse_of[get(object_2, object_1)]

    table = Table(name="relations")

    if not table.connect():
        return ""

    success, output = table.execute(
        (
            "SELECT r.relation "
            "FROM abcli.relations r "
            "INNER JOIN ( "
            "SELECT MAX(timestamp) AS max_timestamp "
            "FROM abcli.relations "
            f'WHERE object_1="{object_1}" AND object_2="{object_2}" '
            ") rm "
            "ON r.timestamp=rm.max_timestamp "
            f'WHERE object_1="{object_1}" AND object_2="{object_2}";'
        ),
        returns_output=True,
    )
    if not success:
        return ""

    if not table.disconnect():
        return ""

    return "" if not output else output[-1][0]


def search(object, relation=""):
    """search for relations.

    Args:
        object (str): object
        relation (str, optional): only this relation. Defaults to "".

    Returns:
        Any: {"relation_1": ["object_1","object_2"], "relation_2": ["object_3" ,"object_4"]} or ["object_1", "object_2"] if relation is given.
    """
    table = Table(name="relations")

    if not table.connect():
        return {}

    success, output_right = table.execute(
        (
            "SELECT r.relation, r.object_2 "
            "FROM abcli.relations r "
            "INNER JOIN (  "
            "SELECT object_2, MAX(timestamp) AS max_timestamp "
            "FROM abcli.relations "
            f'WHERE object_1="{object}" GROUP BY object_2'
            ") rm  "
            "ON r.timestamp=rm.max_timestamp "
            f'WHERE object_1="{object}"; '
        ),
        returns_output=True,
    )
    if not success:
        return {}

    success, output_left = table.execute(
        (
            "SELECT r.relation, r.object_1 "
            "FROM abcli.relations r "
            "INNER JOIN (  "
            "SELECT object_1, MAX(timestamp) AS max_timestamp "
            "FROM abcli.relations "
            f'WHERE object_2="{object}" GROUP BY object_1'
            ") rm  "
            "ON r.timestamp=rm.max_timestamp "
            f'WHERE object_2="{object}"; '
        ),
        returns_output=True,
    )
    if not success:
        return {}

    if not table.disconnect():
        return {}

    raw_output = {thing[1]: thing[0] for thing in output_right}
    raw_output.update({thing[1]: inverse_of[thing[0]] for thing in output_left})

    raw_output = {thing: relation for thing, relation in raw_output.items() if relation}

    output = {}
    for object_, relation in raw_output.items():
        output[relation] = output.get(relation, []) + [object_]

    return output.get(relation, []) if relation else output


def set_(object_1, object_2, relation):
    """set relation between object_1 and object_2.

    Args:
        object_1 (str): object 1.
        object_2 (str): object 2.
        relation (str): relation.

    Returns:
        bool: success.
    """
    if relation not in list_of:
        logger.error(f"-relations: set: {relation}: relation not found.")
        return False

    if object_1 > object_2:
        return set_(object_2, object_1, inverse_of[relation])

    table = Table(name="relations")

    if not table.connect():
        return False

    if not table.execute(
        (
            "INSERT INTO abcli.relations "
            "(object_1, object_2, relation) "
            f"VALUES ('{object_1}', '{object_2}', '{relation}');"
        )
    ):
        return False

    if not table.disconnect():
        return False

    logger.info(
        "relation: {} -{}-> {}".format(
            object_1, relation if relation else "X", object_2
        )
    )

    return True