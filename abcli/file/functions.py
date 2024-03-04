import fnmatch
from functools import reduce
import os
import shutil
from abcli import env
from abcli import string
from abcli.file import NAME
from abcli.logger import logger, crash_report


def absolute(filename, reference_path=None):
    """return absolute path to filename.

    Args:
        filename (str): filename.
        reference_path (str, optional): reference path. Defaults to None.

    Returns:
        str: filename.
    """
    from abcli.path import absolute as path_absolute

    return os.path.join(
        path_absolute(
            path(filename),
            os.getcwd() if reference_path is None else reference_path,
        ),
        name_and_extension(filename),
    )


def add_postfix(filename, postfix):
    """add postfix to filename.

    Args:
        filename (str): filename.
        postfix (str): postfix.

    Returns:
        str: filename.
    """
    filename, extension = os.path.splitext(filename)
    return f"{filename}-{postfix}{extension}"


def add_prefix(filename, prefix):
    """add prefix to name of filename.

    Args:
        filename (str): filename.
        prefix (str): prefix.

    Returns:
        str: filename
    """
    pathname, filename = os.path.split(filename)
    return os.path.join(pathname, f"{prefix}-{filename}")


def auxiliary(nickname, extension, add_timestamp=True):
    """generate auxiliary filename.

    Args:
        nickname (str): nickname
        extension (str): extension
        add_timestamp (bool, optional): add timestamp. Defaults to True.

    Returns:
        str: auxiliary filename.
    """
    from abcli.file.save import prepare_for_saving

    filename = os.path.join(
        env.abcli_object_path,
        "auxiliary",
        "-".join(
            [nickname]
            + (
                [
                    string.pretty_date(
                        as_filename=True,
                        squeeze=True,
                        unique=True,
                    )
                ]
                if add_timestamp
                else []
            )
        )
        + f".{extension}",
    )

    prepare_for_saving(filename)

    return filename


def copy(
    source,
    destination,
    log=True,
    overwrite=True,
):
    """copy source to destination.

    Args:
        source (str): source filename.
        destination (str): destination filename.
        log (bool, optional): log. Defaults to True.
        overwrite (bool, optional): log. Defaults to True.

    Returns:
        bool: success
    """
    from abcli.file.save import prepare_for_saving

    if not overwrite and exist(destination):
        if log:
            logger.info(f"✅ {destination}")
        return True

    if not prepare_for_saving(destination):
        return False

    try:
        # https://stackoverflow.com/a/8858026
        # better choice: copy2
        shutil.copyfile(source, destination)
    except:
        crash_report(f"-{NAME}: copy({source},{destination}): failed.")
        return False

    if log:
        logger.info(f"{NAME}: {source} -> {destination}")

    return True


def create(filename, content=[]):
    """create filename.

    Args:
        filename (str): filename.
        content (list, optional): content. Defaults to [].

    Returns:
        bool: success
    """
    from abcli.file.save import save_text

    return save_text(filename, content)


def delete(filename):
    """delete filename.

    Args:
        filename (str): filename.

    Returns:
        bool: success.
    """
    if not os.path.isfile(filename):
        return True

    try:
        os.remove(filename)

        return True
    except:
        crash_report(f"-{NAME}: delete({filename}): failed.")
        return False


def download(
    url,
    filename,
    log=True,
    overwrite=True,
):
    """download url as filename.

    Args:
        url (str): url.
        filename (str): filename.
        log (bool, optional): log. Defaults to True.
        overwrite (bool, optional): overwrite. Defaults to True.

    Returns:
        bool: success
    """
    if not overwrite and exist(filename):
        return True

    try:
        import urllib3

        # https://stackoverflow.com/a/27406501
        with urllib3.PoolManager().request(
            "GET", url, preload_content=False
        ) as response, open(filename, "wb") as fp:
            shutil.copyfileobj(response, fp)

        response.release_conn()  # not 100% sure this is required though

    except:
        crash_report(f"-{NAME}: download({url},{filename}): failed.")
        return False

    if log:
        logger.info(f"{NAME}: {url} -> {filename}")

    return True


def exist(filename):
    """does filename exist?

    Args:
        filename (str): filename.

    Returns:
        bool: does filename exist?
    """
    return os.path.isfile(filename)


def extension(filename):
    """return extension of filename.

    Args:
        filename (str): filename.

    Returns:
        str: extension.
    """

    if isinstance(filename, str):
        _, extension = os.path.splitext(filename)
        if extension != "":
            if extension[0] == ".":
                extension = extension[1:]
        return extension

    if isinstance(filename, type):
        return "py" + filename.__name__.lower()

    return "py" + filename.__class__.__name__.lower()


def list_of(template, recursive=False):
    """return list of files that match template.

    Args:
        template (str): template.
        recursive (bool, optional): recursive. Defaults to False.

    Returns:
        List[str]: list of filenames.
    """
    from abcli import path as abcli_path

    if isinstance(template, list):
        return reduce(
            lambda x, y: x + y,
            [list_of(template_, recursive) for template_ in template],
            [],
        )

    if recursive:
        return reduce(
            lambda x, y: x + y,
            [
                list_of(
                    os.path.join(pathname, name_and_extension(template)),
                    recursive,
                )
                for pathname in abcli_path.list_of(path(template))
            ],
            list_of(template),
        )

    # https://stackoverflow.com/a/40566802
    template_path = path(template)
    if template_path == "":
        template_path = abcli_path.current()

    try:
        return [
            os.path.join(template_path, filename)
            for filename in fnmatch.filter(
                os.listdir(template_path),
                name_and_extension(template),
            )
        ]
    except:
        return []


def move(source, destination):
    """move source to destination.

    Args:
        source (str): source.
        destination (str): destination.

    Returns:
        bool: success.
    """
    from abcli.file.save import prepare_for_saving

    if not prepare_for_saving(destination):
        return False

    try:
        # https://stackoverflow.com/a/8858026
        shutil.move(source, destination)
    except:
        crash_report(f"-{NAME}: move({source},{destination}): failed.")
        return False

    return True


def name(filename):
    """return name of filename.

    Args:
        filename (str): filename.

    Returns:
        str: name of filename.
    """
    _, filename = os.path.split(filename)

    return filename if "." not in filename else ".".join(filename.split(".")[:-1])


def name_and_extension(filename):
    """return name and extension of filename.

    Args:
        filename (str): filename.

    Returns:
        str: name and extension of filename
    """
    return os.path.basename(filename)


def path(filename):
    """return path of filename.

    Args:
        filename (str): filename.

    Returns:
        str: path of filename.
    """
    return os.path.split(filename)[0]


def relative(filename, reference_path=None):
    """return relative filename.

    Args:
        filename (str): filename.
        reference_path (str, optional): reference path. Defaults to None.

    Returns:
        str: relative filename.
    """

    from abcli.path import relative as path_relative

    return path_relative(
        path(filename),
        os.getcwd() if reference_path is None else reference_path,
    ) + name_and_extension(filename)


def set_extension(filename, extension_, force=True):
    """set extension for filename.

    Args:
        filename (str): filename.
        extension_ (str): extension.
        force (bool, optional): force. Defaults to True.

    Returns:
        str: filename.
    """
    if not isinstance(extension_, str):
        extension_ = extension(extension_)

    filename, extension_as_is = os.path.splitext(filename)
    if extension_as_is != "":
        extension_as_is = extension_as_is[1:]

    if not force and extension_as_is == "":
        extension_ = extension_as_is

    return f"{filename}.{extension_}"


def size(filename):
    """return size of file.

    Args:
        filename (str): filename.

    Returns:
        int: size of filename in bytes.
    """
    try:
        return os.path.getsize(filename)
    except:
        return 0
