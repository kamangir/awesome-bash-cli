import json
from abcli.file.classes import JsonEncoder
from abcli import string
from abcli.logger import logger, crash_report


def prepare_for_saving(filename):
    """prepare for saving filename.

    Args:
        filename (str): filename.

    Returns:
        bool: success.
    """
    from abcli.path import create as path_create
    from abcli.file.functions import path

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
        crash_report(f"save({filename}) failed.")
        return False

    return True


def save_csv(
    filename,
    df,
    log=False,
):
    """save data to filename as csv.

    Args:
        filename (str): filename.
        df (pd.DataFrame): dataframe.
        log (bool, optional): log. Defaults to False.

    Returns:
        bool: success.
    """
    if not prepare_for_saving(filename):
        return False

    # https://stackoverflow.com/a/10250924/10917551
    try:
        df.to_csv(filename)
    except:
        crash_report(f"save_csv({filename}) failed.")
        return False

    if log:
        logger.info(
            "save_csv: {}X[{}] -> {}".format(
                len(df),
                ",".join(list(df.columns)),
                filename,
            )
        )

    return True


def save_fig(
    filename,
    log=False,
):
    """save plt figure to filename.

    Args:
        filename (str): filename.
        log (bool, optional): log. Defaults to False.

    Returns:
        bool: success.
    """
    from abcli.modules.host import is_jupyter

    if not prepare_for_saving(filename):
        return False

    # https://stackoverflow.com/a/10250924/10917551
    try:
        import matplotlib.pyplot as plt

        if is_jupyter():
            plt.show()
        plt.savefig(filename, bbox_inches="tight")
        plt.close()
    except:
        crash_report(f"save_fig({filename}) failed.")
        return False

    if log:
        logger.info(f"figure -> {filename}")

    return True


def save_geojson(
    filename,
    gdf,
    log=False,
):
    """save GeoDataFrame to filename as geojson.

    Args:
        filename (str): filename.
        gdf (GeoDataFrame): geo data frame.
        log (bool, optional): log. Defaults to False.

    Returns:
        bool: success.
    """
    if not prepare_for_saving(filename):
        return False

    try:
        gdf.to_file(filename, driver="GeoJSON")
    except:
        crash_report(f"save_geojson({filename}) failed.")
        return False

    if log:
        logger.info(f"save_geojson: {len(gdf)} -> {filename}")

    return True


def save_image(
    filename,
    image,
    log=False,
):
    """save image to filename.

    Args:
        filename (str): filename.
        image (np.ndarray): image.
        log (bool, optional): log. Defaults to False.

    Returns:
        bool: success.
    """
    import cv2
    import numpy as np

    if image is None:
        logger.info("save_image(None) ignored.")
        return True

    if not prepare_for_saving(filename):
        return False

    try:
        data = image.copy()

        if len(data.shape) == 3:
            data = np.flip(data, axis=2)

        cv2.imwrite(filename, data)
    except:
        crash_report(
            "save_image({},{}) failed.".format(
                string.pretty_shape_of_matrix(image),
                filename,
            )
        )
        return False

    if log:
        logger.info(
            "save_image: {} -> {}".format(
                string.pretty_shape_of_matrix(image),
                filename,
            )
        )

    return True


def save_json(
    filename,
    data,
    log=False,
):
    """save data to filename as json.

    Args:
        filename (str): filename.
        data (Any): data.
        log (bool, optional): log. Defaults to False.

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
    except:
        crash_report(f"save_json({filename}) failed.")
        return False

    if log:
        logger.info(f"save_json -> {filename}")

    return True


def save_tensor(
    filename,
    tensor,
    log=True,
):
    """save tensor to filename.

    Args:
        filename (str): filename.
        tensor (np.ndarray): tensor.
        log (bool, optional): log. Defaults to True.

    Returns:
        bool: success.
    """
    from abcli.file.functions import set_extension

    success = save(set_extension(filename, "pyndarray"), tensor)

    if success and log:
        logger.info(
            "save_tensor: {} -> {}".format(
                string.pretty_shape_of_matrix(tensor),
                filename,
            )
        )

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
        if_different (bool, optional): save if text is different
        from current filename content. Defaults to False.
        remove_empty_lines (bool, optional): remove empty lines. Defaults to False.

    Returns:
        bool: success.
    """
    from abcli.file.load import load_text

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
        crash_report(f"save_text({filename}) failed.")
        return False

    if log:
        logger.info(f"save_text: {len(text)} line(s) -> {filename}")
    return True


def save_yaml(
    filename,
    data,
    log=True,
):
    """save data to filename as yaml(.

    Args:
        filename (str): filename.
        data (Any): data.
        log (bool, optional): log. Defaults to True.

    Returns:
        bool: success.
    """
    if not prepare_for_saving(filename):
        return False

    try:
        import yaml

        with open(filename, "w") as f:
            yaml.dump(data, f)
    except:
        crash_report(f"save_yaml({filename}) failed.")
        return False

    if log:
        logger.info(f"save_yaml: {', '.join(data.keys())} -> {filename}.")

    return True
