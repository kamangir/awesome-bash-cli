import argparse
import datetime
import fnmatch
import json
import os
import re
import shutil

from abcli.options import Options
from abcli import string

import abcli.logging
import logging

logger = logging.getLogger(__name__)

# https://gist.github.com/jsbueno/9b2ea63fb16b84658281ec29b375283e
class JsonEncoder(json.JSONEncoder):
    def default(self, obj):
        try:
            return super().default(obj)
        except TypeError:
            pass

        if obj.__class__.__name__ == "ndarray":
            return obj.tolist()

        if isinstance(obj, datetime.datetime):
            return "{}".format(obj)

        return (
            obj.__dict__
            if not hasattr(type(obj), "__json_encode__")
            else obj.__json_encode__
        )


def absolute(filename, reference_path=None):
    """return absolute path to filename.

    Args:
        filename (str): filename.
        reference_path (str, optional): reference path. Defaults to None.

    Returns:
        str: filename.
    """
    import abcli.path

    return os.path.join(
        abcli.path.absolute(
            path(filename),
            abcli.path.current() if reference_path is None else reference_path,
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
        str: filename
    """
    filename = os.path.join(
        os.getenv("abcli_object_folder"),
        "auxiliary",
        "-".join(
            [nickname]
            + (
                [string.pretty_date(as_filename=True, squeeze=True, unique=True)]
                if add_timestamp
                else []
            )
        )
        + f".{extension}",
    )

    prepare_for_saving(filename)

    return filename


def copy(source, destination, log=False):
    """copy source to destination.

    Args:
        source (str): source filename.
        destination (str): description filename.
        log (bool, optional): log. Defaults to False.

    Returns:
        _type_: _description_
    """
    if not prepare_for_saving(destination):
        return False

    try:
        # https://stackoverflow.com/a/8858026
        shutil.copyfile(source, destination)
    except:
        from abcli.logging import crash_report

        crash_report(f"-{name}: copy({source},{destination}) failed.")
        return False

    if log:
        logger.info("file: {} -> {}".format(source, destination))

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
    """
    Delete filename
    :param filename: filename
    :return: success
    """
    if not os.path.isfile(filename):
        return True

    try:
        os.remove(filename)

        return True
    except:
        from abcli.logging import crash_report

        crash_report(f"-{name}: delete({filename}) failed.")
        return False


def download(url, filename, options=""):
    """
    Download url ad filename.
    :param url: url
    :param filename: filename
        :param options:
            overwrite : overwrite
                        default : True
    :return: success
    """
    options = Options(options).default("overwrite", True)

    if not options["overwrite"] and exist(filename):
        return True

    try:
        import urllib3

        # https://stackoverflow.com/a/27406501
        with urllib3.PoolManager().request(
            "GET", url, preload_content=False
        ) as response, open(filename, "wb") as fp:
            shutil.copyfileobj(response, fp)

        response.release_conn()  # not 100% sure this is required though
        return True
    except:
        from abcli.logging import crash_report

        crash_report(f"-{name}: download({url},{filename}) failed.")
        return False


def exist(filename):
    """
    Check whether filename exists.
    :param filename: filename
    :return: success
    """
    return os.path.isfile(filename)


def extension(filename):
    """
    Return extension of filename.
    :param filename: Filename
    :return: Filename extension
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


def list_of(template, options=""):
    """
    Create a list of files which match template.
    :param template: Template.
    :param options:
        . archive   : Include archived files.
                      default: True
        . ignore    : List of files to ignore (comma-separated)
                      default: ""
        . recursive : Look for file in all sub-folders.
                     default: False
    :return: filenames
    """
    import abcli.path

    options = Options(options).default("archive", True).default("recursive", False)

    if isinstance(template, list):
        output = []
        for template_ in template:
            output += list_of(template_, options)
        return output

    if options["recursive"]:
        template_path = path(template)
        template_filename = name_and_extension(template)

        output = list_of(template, options.set("recursive", False))

        list_of_paths = abcli.path.list_of(
            template_path, options.set("recursive", False)
        )

        for pathname in list_of_paths:
            output += list_of(pathname + template_filename, options)

        return output

    if not options["archive"]:
        if abcli.path.name(path(template)) == "archive":
            return []

    # https://stackoverflow.com/a/40566802
    template_path = path(template)
    if template_path == "":
        template_path = abcli.path.current()
    template_filename = name_and_extension(template)
    try:
        output = [
            template_path + filename
            for filename in fnmatch.filter(os.listdir(template_path), template_filename)
        ]
    except:
        output = []

    ignore_list = options.get("ignore", "").split(",")
    output = [
        filename
        for filename in output
        if not name_and_extension(filename) in ignore_list
    ]

    return output


def load(filename, options=""):
    """
    Load data from filename.
    :param filename: filename
    :param options:
        . civilized : if failed, do not print error message.
                      default: false
        . default   : default.
                      default: {}
    :return: success, data
    """
    options = Options(options).default("civilized", False).default("default", {})

    # https://wiki.python.org/moin/UsingPickle
    data = options["default"]
    try:
        import dill

        with open(filename, "rb") as fp:
            data = dill.load(fp)

        return True, data
    except:
        if not options["civilized"]:
            from abcli.logging import crash_report

            crash_report(f"-{name}: load({filename}) failed.")
        return False, data


def load_csv(filename, options=""):
    """
    Load csv from filename.
    :param filename: filename
    :param options:
    :return: success, dataframe
    """
    import pandas as pd

    options = Options(options)

    success = False
    data = pd.DataFrame()
    try:
        data = pd.read_csv(filename)
        success = True
    except:
        from abcli.logging import crash_report

        crash_report(f"-{name}: load_csv({filename}) failed.")

    return success, data


def load_image(filename, options=""):
    """
    Load image from filename.
    :param filename: filename
    :param options:
        . civilized : if failed, do not print error message.
                      default: false
    :return: success, (ndarray|str)
    """
    import cv2
    import numpy as np

    options = Options(options).default("civilized", False)

    success = True
    data = np.empty((0,))

    try:
        data = cv2.imread(filename)

        if len(data.shape) == 3:
            if data.shape[2] == 4:
                data = data[:, :, :3]

            data = np.flip(data, axis=2)

    except:
        if not options["civilized"]:
            from abcli.logging import crash_report

            crash_report(f"-{name}: load_image({filename}) failed.")
        success = False

    return success, data


def load_json(filename, options=""):
    """
    Load data from filename.json
    :param filename: Filename
    :param options:
        . civilized : if failed, do not print error message.
                      default: false
        . default   : default to return if a failure hapenned.
                      default: {}
    :return: success, data
    """
    options = Options(options).default("civilized", False).default("default", {})

    filename = set_extension(filename, "json")

    success = False
    data = options["default"]
    try:
        with open(filename, "r") as fh:
            data = json.load(fh)

        success = True
    except:
        if not options["civilized"]:
            from abcli.logging import crash_report

            crash_report(f"-{name}: load_json({filename}) failed.")

    return success, data


def load_text(filename, options=""):
    """
    Load text from filename.
    :param filename: filename
    :param options:
        . civilized : if failed, do not print error message.
                      default: false
        count       : number of lines to read.
                      default: -1 (all)
    :return: success, text
    """
    options = Options(options).default("civilized", "false").default("count", -1)

    try:
        if options["count"] == -1:
            with open(filename, "r") as fp:
                text = fp.read()
            text = text.split("\n")
        else:
            # https://stackoverflow.com/a/1767589/10917551
            with open(filename) as fp:
                text = [next(fp) for _ in range(options["count"])]

        return True, text
    except:
        if not options["civilized"]:
            from abcli.logging import crash_report

            crash_report(f"-{name}: load_text({filename}) failed.")

        return False, []


def move(source, destination):
    """
    Move source to destination.
    :param source: source filename
    :param destination: destination filename
    :param options:
    :return: success
    """
    import abcli.path

    if not abcli.path.create(path(destination)):
        return False

    try:
        # https://stackoverflow.com/a/8858026
        shutil.move(source, destination)
    except:
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

    import abcli.path

    return abcli.path.create(path(filename))


def relative(filename, reference_path=None):
    """
    return relative path to filename.
    :param filename: filename
    :param reference_path: reference path
    :return: filename
    """
    from abcli.path import current, relative

    if reference_path is None:
        reference_path = current()

    return relative(path(filename), reference_path) + name_and_extension(filename)


def save(filename, data, options=""):
    """
    save data to json.
    :param filename: filename
    :param data: data
    :param options:
        . extension : file extension.
                      default : "" (disable)
        . prepare_for_saving()
    :return: success
    """
    options = Options(options).default("extension", extension(data))

    filename = set_extension(filename, options["extension"])

    success, filename = prepare_for_saving(filename, options)
    if not success:
        return False

    try:
        import dill

        with open(filename, "wb") as fp:
            dill.dump(data, fp)
    except:
        from abcli.logging import crash_report

        crash_report(f"-{name}: save({filename}) failed.")
        return False

    return True


def save_csv(filename, data, options=""):
    """
    Save data to csv.
    :param filename: filename
    :param data: list of items
    :param options:
        . prepare_for_saving()
    :return: success
    """
    success, filename = prepare_for_saving(filename, options)

    if success:
        # https://stackoverflow.com/a/10250924/10917551
        try:
            with open(filename, "w") as fh:
                for row in data:
                    fh.write("%s\n" % str(row))

        except:
            from abcli.logging import crash_report

            crash_report(f"-{name}: save_csv({filename}) failed.")
            success = False

    return success


def save_image(filename, image, options=""):
    """
    Save image to filename.
    :param filename: filename
    :param image: image
    :param options:
        . queue_name : message image to queue_name.
                       default: "" - disable
        . prepare_for_saving()
    :return: success
    """
    import cv2
    import numpy as np

    if image is None:
        logger.info("file.save_image(None) failed.")
        return False

    options = Options(options).default("queue_name", "")

    success, filename = prepare_for_saving(filename, options)

    if success:
        try:
            data = image.copy()

            if len(data.shape) == 3:
                data = np.flip(data, axis=2)

            cv2.imwrite(filename, data)
        except:
            from abcli.logging import crash_report

            crash_report(
                f"-{name}: save_image({string.pretty_size_of_matrix(image)}{filename}) failed."
            )

    if success and options["queue_name"]:
        import abcli.message as message

        success = message.mail(filename, options["queue_name"])

    return success


def save_json(filename, data, options=""):
    """
    Save data to json.
    :param filename: filename
    :param data: data
    :param options:
        . prepare_for_saving()
    :return: success
    """
    filename = set_extension(filename, "json")

    success, filename = prepare_for_saving(filename, options)

    if success:
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

        except:
            from abcli.logging import crash_report

            crash_report(f"-{name}: save_json({filename}) failed.")
            success = False

    return success


def save_tensor(filename, tensor, options=""):
    """
    save tensor to filename.
    :param filename: filename
    :param tensor: tensor
    :param options:
        . prepare_for_saving()
    :return: success
    """
    filename = set_extension(filename, "pyndarray")

    if save(filename, tensor):
        logger.info(
            "{} -> {}".format(
                string.pretty_size_of_matrix(tensor), name_and_extension(filename)
            )
        )
        return True

    return False


def save_text(filename, text, options=""):
    """
    Save text to filename.
    :param filename: filename
    :param text: list of string
    :param options:
        . if_different       : save if different.
                               default: False
        . remove_empty_lines : remove empty lines.
                               default : False
        . file.prepare_for_saving()
    :return: success
    """
    options = (
        Options(options)
        .default("if_different", False)
        .default("remove_empty_lines", False)
    )

    if options["remove_empty_lines"]:
        text = [
            line
            for line, next_line in zip(text, text[1:] + ["x"])
            if line.strip() or next_line.strip()
        ]

    if options["if_different"]:
        _, content = load_text(filename, "civilized")

        if "|".join(content) == "|".join(text):
            logger.debug("validated {}".format(filename))
            return True

    success, filename = prepare_for_saving(filename, options)
    if not success:
        return success

    try:
        with open(filename, "w") as fp:
            fp.writelines([string + "\n" for string in text])
    except:
        from abcli.logging import crash_report

        crash_report(f"-{name}: save_text({filename}) failed.")
        return False

    return True


def set_extension(filename, extension_, options=""):
    """
    Set extension of filename to extension.
    :param filename: Filename
    :param extension_: Extension
    :param options:
           . force: Force extension, even if filename already has an extension.
                    default: True
    :return: Updated filename.
    """
    options = Options(options).default("force", True)

    if not isinstance(extension_, str):
        extension_ = extension(extension_)

    filename, extension_as_is = os.path.splitext(filename)
    if extension_as_is != "":
        extension_as_is = extension_as_is[1:]

    if not options["force"] and extension_as_is == "":
        extension_ = extension_as_is

    return filename + "." + extension_


def size(filename, options=""):
    """
    Return size of file.
    :param filename: filename
    :param options:
        . None
    :return: size in bytes
    """
    try:
        return os.path.getsize(filename)
    except:
        return 0


def timestamp(thing, extension, options=""):
    """
    Generate timestamped filename for thing.
    :param thing: thing
    :param extension: extension
    :param options:
    :return: filename
    """
    filename = os.path.join(
        os.getenv("abcli_object_folder", "."),
        "-".join(
            [
                string.nickname(thing).lower(),
                string.pretty_date("filename,squeeze,unique"),
            ]
        )
        + "."
        + extension,
    )

    return filename


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "task",
        type=str,
        default="",
        help="load/replace",
    )
    parser.add_argument(
        "--filename",
        type=str,
        default="",
        help="",
    )
    parser.add_argument(
        "--that",
        type=str,
        default="",
        help="",
    )
    parser.add_argument(
        "--this",
        type=str,
        default="",
        help="",
    )
    args = parser.parse_args()

    success = False
    if args.task == "load":
        import numpy as np

        success, content = load(args.filename)
        if success:
            if isinstance(content, np.ndarray):
                print(string.pretty_size_of_matrix(content))
            print(content)
    elif args.task == "replace":
        success, content = load_text(args.filename)
        if success:
            success = save_text(
                args.filename,
                [line.replace(args.this, args.that) for line in content],
                "~archive",
            )
    else:
        logger.error('file: unknown task "{}".'.format(args.task))

    if not success:
        logger.error("file({}): failed.".format(args.task))
