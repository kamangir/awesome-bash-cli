from copy import deepcopy
import fnmatch
from functools import reduce
import json
import os
import shutil
from abcli.file import NAME
from abcli.file.classes import JsonEncoder
from abcli import string
from abcli.logging import crash_report
from abcli import logging
import logging

logger = logging.getLogger(__name__)


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
    filename = os.path.join(
        os.getenv("abcli_object_path"),
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


def copy(source, destination, log=True):
    """copy source to destination.

    Args:
        source (str): source filename.
        destination (str): description filename.
        log (bool, optional): log. Defaults to True.

    Returns:
        _type_: _description_
    """
    if not prepare_for_saving(destination):
        return False

    try:
        # https://stackoverflow.com/a/8858026
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
        _type_: _description_
    """
    if not overwrite and exist(filename):
        return True

    success = True
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
        logger.info(f"downloaded {url} -> {filename}")

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


def load(filename, civilized=False, default={}):
    """load data from filename.

    Args:
        filename (str): filename.
        civilized (bool, optional): if failed, do not print error message. Defaults to False.
        default (dict, optional): default. Defaults to {}.

    Returns:
        bool: success.
        data: Any.
    """
    # https://wiki.python.org/moin/UsingPickle
    data = deepcopy(default)

    try:
        import dill

        with open(filename, "rb") as fp:
            data = dill.load(fp)

        return True, data
    except:
        if not civilized:
            crash_report(f"-{NAME}: load({filename}): failed.")

        return False, data


def load_image(filename, civilized=False):
    """load image from filename

    Args:
        filename (_type_): _description_
        civilized (bool, optional): if failed, do not print error message. Defaults to False.

    Returns:
        bool: success.
        image: np.ndarray.
    """
    import cv2
    import numpy as np

    success = True
    image = np.empty((0,))

    try:
        image = cv2.imread(filename)

        if len(image.shape) == 3:
            if image.shape[2] == 4:
                image = image[:, :, :3]

            image = np.flip(image, axis=2)

    except:
        if not civilized:
            crash_report(f"-{NAME}: load_image({filename}): failed.")
        success = False

    return success, image


def load_json(filename, civilized=False, default={}):
    """load json from filename.

    Args:
        filename (str): filename.
        civilized (bool, optional): if failed, do not print error message. Defaults to False.
        default (dict, optional): default. Defaults to {}.

    Returns:
        bool: success.
        data: Any.
    """
    success = False
    data = {}

    try:
        with open(filename, "r") as fh:
            data = json.load(fh)

        success = True
    except:
        if not civilized:
            crash_report(f"-{NAME}: load_json({filename}): failed.")

    return success, data


def load_text(filename, civilized=False, count=-1):
    """load text from filename.

    Args:
        filename (str): filename
        civilized (bool, optional): if failed, do not print error message. Defaults to False.
        count (int, optional): number of lins to read. Defaults to -1 (all).

    Returns:
        bool: success.
        text: List[str].
    """
    success = True
    text = []

    try:
        if count == -1:
            with open(filename, "r") as fp:
                text = fp.read()
            text = text.split("\n")
        else:
            # https://stackoverflow.com/a/1767589/10917551
            with open(filename) as fp:
                text = [next(fp) for _ in range(count)]
    except:
        if not civilized:
            crash_report(f"-{NAME}: load_text({filename}): failed.")

    return success, text


def move(source, destination):
    """move source to destination.

    Args:
        source (str): source.
        destination (str): destination.

    Returns:
        bool: success.
    """
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


def prepare_for_saving(filename):
    """prepare for saving filename.

    Args:
        filename (str): filename.

    Returns:
        bool: success.
    """
    from abcli.path import create as path_create

    return path_create(path(filename))


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


def save(filename, data):
    """save data.

    Args:
        filename (str): filename.
        data (Any): data.

    Returns:
        bool: success.
    """
    if not prepare_for_saving(filename):
        return False

    try:
        import dill

        with open(filename, "wb") as fp:
            dill.dump(data, fp)
    except:
        crash_report(f"-{NAME}: save({filename}): failed.")
        return False

    return True


def save_csv(filename, data):
    """save data to filename as csv.

    Args:
        filename (str): filename.
        data (Any): data.

    Returns:
        bool: success.
    """
    if not prepare_for_saving(filename):
        return False

    if success:
        # https://stackoverflow.com/a/10250924/10917551
        try:
            with open(filename, "w") as fh:
                for row in data:
                    fh.write("%s\n" % str(row))

        except:
            crash_report(f"-{NAME}: save_csv({filename}): failed.")
            success = False

    return success


def save_image(filename, image):
    """save image to filename.

    Args:
        filename (str): filename.
        image (np.ndarray): image.

    Returns:
        bool: success.
    """
    import cv2
    import numpy as np

    if image is None:
        logger.info(f"-{NAME}: save_image(None) ignored.")
        return True

    if not prepare_for_saving(filename):
        return False

    try:
        data = image.copy()

        if len(data.shape) == 3:
            data = np.flip(data, axis=2)

        cv2.imwrite(filename, data)

        return True
    except:
        crash_report(
            f"-{NAME}: save_image({string.pretty_shape_of_matrix(image)},{filename}): failed."
        )
        return False


def save_json(filename, data):
    """save data to filename as json.

    Args:
        filename (str): filename.
        data (Any): data.

    Returns:
        bool: success.
    """
    if not prepare_for_saving(filename):
        return False

    if hasattr(data, "to_json"):
        data = data.to_json()

    try:
        with open(filename, "w") as fh:
            json.dump(
                data,
                fh,
                sort_keys=True,
                cls=JsonEncoder,
                indent=4,
                ensure_ascii=False,
            )

        return True
    except:
        crash_report(f"-{NAME}: save_json({filename}): failed.")
        return False


def save_tensor(filename, tensor, log=True):
    """save tensor to filename.

    Args:
        filename (str): filename.
        tensor (np.ndarray): tensor.
        log (bool, optional): log. Defaults to True.

    Returns:
        bool: success.
    """
    success = save(set_extension(filename, "pyndarray"), tensor)

    if success and log:
        logger.info(f"-{NAME}: {string.pretty_shape_of_matrix(tensor)} -> {filename}")

    return success


def save_text(
    filename,
    text,
    if_different=False,
    log=False,
    remove_empty_lines=False,
):
    """save text to filename.

    Args:
        filename (str): filename.
        text (List[str]): text.
        log (bool, optional): log. Defaults to False.
        if_different (bool, optional): save if text is different from current filename content. Defaults to False.
        remove_empty_lines (bool, optional): remove empty lines. Defaults to False.

    Returns:
        bool: success.
    """

    if remove_empty_lines:
        text = [
            line
            for line, next_line in zip(text, text[1:] + ["x"])
            if line.strip() or next_line.strip()
        ]

    if if_different:
        _, content = load_text(filename, civilized=True)

        if "|".join([line for line in content if line]) == "|".join(
            [line for line in text if line]
        ):
            return True

    if not prepare_for_saving(filename):
        return False

    try:
        with open(filename, "w") as fp:
            fp.writelines([string + "\n" for string in text])
    except:
        crash_report(f"-{NAME}: save_text({filename}): failed.")
        return False

    if log:
        logger.info(f"{NAME}.save_text({filename}): {len(text)} lines.")
    return True


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
