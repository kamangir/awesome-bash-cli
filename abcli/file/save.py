import json
from abcli.file import NAME
from abcli.file.classes import JsonEncoder
from abcli.file.functions import path, set_extension
from abcli.file.load import load_text
from abcli import string
from abcli.logging import crash_report
from abcli import logging
import logging

logger = logging.getLogger(__name__)


def prepare_for_saving(filename):
    """prepare for saving filename.

    Args:
        filename (str): filename.

    Returns:
        bool: success.
    """
    from abcli.path import create as path_create

    return path_create(path(filename))


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


def save_geojson(filename, gdf):
    """save GeoDataFrame to filename as geojson.

    Args:
        filename (str): filename.
        gdf (GeoDataFrame): geo data frame.

    Returns:
        bool: success.
    """
    if not prepare_for_saving(filename):
        return False

    try:
        gdf.to_file(filename, driver="GeoJSON")

        return True
    except:
        crash_report(f"-{NAME}: save_geojson({filename}): failed.")
        return False


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


def save_yaml(filename, data):
    """save data to filename as yaml(.

    Args:
        filename (str): filename.
        data (Any): data.

    Returns:
        bool: success.
    """
    if not prepare_for_saving(filename):
        return False

    try:
        import yaml

        with open(filename, "w") as f:
            yaml.dump(data, f)

        return True
    except:
        crash_report(f"-{NAME}: save_yaml({filename}): failed.")
        return False