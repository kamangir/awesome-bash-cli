import os
import pathlib
import shutil
from .. import string
from .. import logging
from ..logging import crash_report
import logging

logger = logging.getLogger(__name__)


def absolute(path, reference=None, options=""):
    """
    Return absolute path.
    :param path: Input path
    :param reference: Reference path
    :param options:
        . prepare()
    :return: Absolute path
    """
    if reference is None:
        reference = current()
    path = path.replace("/", os.sep)
    reference = reference.replace("/", os.sep)

    if path == "":
        return reference
    if path[0] != ".":
        return prepare(path)

    return prepare(str(pathlib.Path(os.path.join(reference, path)).resolve()), options)


def auxiliary(nickname, add_timestamp=True):
    """generate auxiliary path.

    Args:
        nickname (str): nickname
        add_timestamp (bool, optional): add timestamp. Defaults to True.

    Returns:
        str: auxiliary path.
    """
    path = os.path.join(
        os.getenv("abcli_object_folder", "."),
        "auxiliary",
        "-".join(
            [nickname]
            + (
                [string.pretty_date(as_filename=True, squeeze=True, unique=True)]
                if add_timestamp
                else []
            )
        ),
    )

    create(path)

    return path


def copy(source, destination):
    """copy source to destination.

    Args:
        source (str): source.
        destination (str): destination.

    Returns:
        bool: success.
    """
    if not create(parent(destination)):
        return False

    try:
        shutil.copytree(source, destination)
        return True
    except:
        crash_report(f"-{name}: copy({source},{destination}) failed.")
        return False


def create(path):
    """create path.

    Args:
        path (path): path.

    Returns:
        bool: success.
    """
    if not path or exist(path):
        return True

    try:
        os.makedirs(path)
        return True
    except:
        crash_report(f"-{name}: create({path}) failed.")
        return False


def current():
    """return current path.

    Returns:
        str: current path.
    """
    return os.getcwd()


def delete(path):
    """delete path.

    Args:
        path (str): path.

    Returns:
        bool: success.
    """
    try:
        # https://docs.python.org/3/library/shutil.html#shutil.rmtree
        shutil.rmtree(path)
        return True
    except:
        crash_report(f"-{name}: delete({path}) failed.")
        return False


def exist(path):
    """does path exist?

    Args:
        path (str): path.

    Returns:
        bool: does path exist?
    """
    return (
        False
        if not os.path.isdir(path)
        else False
        if not os.path.exists(path)
        else True
    )


def list_of(path, recursive=False):
    """return list of folders in path.

    Args:
        path (_type_): path.
        recursive (bool, optional): look in all sub-folders as well. Defaults to False.

    Returns:
        list: list of paths.
    """
    if not exist(path):
        return []

    # http://stackabuse.com/python-list-files-in-a-directory/
    output = []
    try:
        for entry in os.scandir(path):
            if entry.is_file():
                continue

            path_name = os.path.join(path, entry.name)

            output.append(path_name)

            if recursive:
                output += list_of(path_name, recursive=recursive)
    except:
        crash_report(f"-{name}: list_of({path}) failed.")

    return output


def move(source, destination):
    """move source to destination.

    Args:
        source (str): source.
        destination (str): destination.

    Returns:
        bool: success.
    """
    if not create(parent(destination)):
        return False

    try:
        shutil.move(source, destination)
        return True
    except:
        crash_report(f"-{name}: move({source},{destination}) failed.")
        return False


def name(path):
    """return name of path.

    Args:
        path (str): path.

    Returns:
        str: path name.
    """
    if not path:
        return path

    if path[-1] == os.sep:
        path = path[:-1]

    path_components = path.split(os.sep)
    return "" if not path_components else path_components[-1]


def parent(path, depth=1):
    """return parent for path.

    Args:
        path (str): path.
        depth (int, optional): parent index. Defaults to 1.

    Returns:
        str: parent name.
    """
    # Add os.sep at the end, if it already does not exist.
    if path != "":
        if path[-1] != os.sep:
            path = path + os.sep

    return os.sep.join(path.split(os.sep)[: -depth - 1]) + os.sep


def relative(path, reference=None):
    """return relative path.

    Args:
        path (str): path
        reference (_type_, optional): reference path. Defaults to None.

    Returns:
        str: relative path.
    """
    # https://stackoverflow.com/a/918174
    return os.path.relpath(path, current() if reference is None else reference)
