from typing import Tuple
from copy import deepcopy
import json
import numpy as np
from abcli.file import NAME
from abcli.logger import logger, crash_report


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


# https://stackoverflow.com/a/47792385/17619982
def load_geojson(filename, civilized=False):
    """load geojson from filename.

    Args:
        filename (str): filename.
        civilized (bool, optional): if failed, do not print error message. Defaults to False.

    Returns:
        bool: success.
        data: Any.
    """
    success = False
    data = {}

    try:
        import geojson

        with open(filename, "r") as fh:
            data = geojson.load(fh)

        success = True
    except:
        if not civilized:
            crash_report(f"-{NAME}: load_geojson({filename}): failed.")

    return success, data


def load_dataframe(
    filename,
    civilized=False,
    log=False,
):
    """load filename.csv as a DataFrame.

    Args:
        filename (str): filename.
        civilized (bool, optional): if failed, do not print error message. Defaults to False.
        log (bool, optional): log. Defaults to False.

    Returns:
        bool: success.
        data: DataFrame.
    """
    success = False
    df = None

    try:
        import pandas

        df = pandas.read_csv(filename)

        success = True
    except:
        if not civilized:
            crash_report(f"-{NAME}: load_dataframe({filename}): failed.")

    if success and log:
        logger.info(
            "loaded {} row(s) of {} from {}".format(
                len(df),
                ", ".join(df.columns),
                filename,
            )
        )

    return success, df


def load_geodataframe(filename, civilized=False):
    """load filename.geojson as a GeoDataFrame.

    Args:
        filename (str): filename.
        civilized (bool, optional): if failed, do not print error message. Defaults to False.

    Returns:
        bool: success.
        data: GeoDataFrame.
    """
    success = False
    gdf = None

    try:
        import geopandas

        gdf = geopandas.read_file(filename)

        success = True
    except:
        if not civilized:
            crash_report(f"-{NAME}: load_geodataframe({filename}): failed.")

    return success, gdf


def load_image(
    filename,
    civilized=False,
    log=False,
) -> Tuple[bool, np.ndarray]:
    """load image from filename

    Args:
        filename (str): filename.
        civilized (bool, optional): if failed, do not print error message. Defaults to False.
        log (bool, optional): log. Defaults to False.

    Returns:
        bool: success.
        image: np.ndarray.
    """
    import cv2
    from abcli import string

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

    if success and log:
        logger.info(
            "loaded {} from {}".format(
                string.pretty_shape_of_matrix(image),
                filename,
            )
        )

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
    data = default

    try:
        with open(filename, "r") as fh:
            data = json.load(fh)

        success = True
    except:
        if not civilized:
            crash_report(f"-{NAME}: load_json({filename}): failed.")

    return success, data


def load_text(
    filename,
    civilized=False,
    count=-1,
    log=False,
):
    """load text from filename.

    Args:
        filename (str): filename
        civilized (bool, optional): if failed, do not print error message. Defaults to False.
        count (int, optional): number of lins to read. Defaults to -1 (all).
        log (bool, optional): log. Defaults to False.

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
        success = False
        if not civilized:
            crash_report(f"-{NAME}: load_text({filename}): failed.")

    if success and log:
        logger.info("loaded {} line(s) from {}.".format(len(text), filename))

    return success, text


def load_yaml(filename, civilized=False, default={}):
    """load load_yaml from filename.

    Args:
        filename (str): filename.
        civilized (bool, optional): if failed, do not print error message. Defaults to False.
        default (dict, optional): default. Defaults to {}.

    Returns:
        bool: success.
        data: Any.
    """
    success = False
    data = default

    try:
        import yaml

        with open(filename, "r") as fh:
            data = yaml.safe_load(fh)

        success = True
    except:
        if not civilized:
            crash_report(f"-{NAME}: load_yaml({filename}): failed.")

    return success, data
