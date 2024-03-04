import cv2
from functools import reduce
import numpy as np
from . import NAME
from abcli.logger import logger


def add_label(
    image,
    x,
    y,
    label,
    background=0,
    font_color=3 * (127,),
    font_face=cv2.FONT_HERSHEY_SIMPLEX,
    font_scale=0.5,
    line_type=cv2.LINE_AA,
    thickness=1,
):
    """add label to image.

    Args:
        image (np.ndarray): image.
        x (int): x.
        y (int): y,
        label (str): label
        background (int, optional): background color. Defaults to 0.
        font_color (tuple, optional): font color. Defaults to 3*(127,).
        font_face (int, optional): font face. Defaults to cv2.FONT_HERSHEY_SIMPLEX.
        font_scale (float, optional): font scale. Defaults to 0.5.
        line_type (int, optional): line type. Defaults to cv2.LINE_AA.
        thickness (int, optional): _description_. Defaults to 1.

    Returns:
        np.ndarray: image.
    """

    text_size = cv2.getTextSize(
        text=label,
        fontFace=font_face,
        fontScale=font_scale,
        thickness=thickness,
    )
    text_height = text_size[0][1] + text_size[1] + 2
    text_width = text_size[0][0]

    try:
        image[y - text_height : y, x : x + text_width] = background
    except:
        pass

    cv2.putText(
        image,
        text=label,
        org=[x - 1, y - text_size[1]],
        fontFace=font_face,
        fontScale=font_scale,
        lineType=line_type,
        color=font_color,
        thickness=thickness,
    )

    return image


def render_text(
    text,
    box=False,
    centered=False,
    color_depth=3,
    font_color=3 * (127,),
    font_face=cv2.FONT_HERSHEY_SIMPLEX,
    font_size=2,
    height=1.0,
    image=None,
    image_width=None,
    left=0.0,
    line_type=cv2.LINE_AA,
    thickness=1,
    top=0.0,
    width=1.0,
):
    """render text

    Args:
        text (List(str)): text.
        box (bool, optional): draw a box around text. Defaults to False.
        centered (bool, optional): centered. Defaults to False.
        color_depth (int, optional): color depth. Defaults to 3.
        font_color (_type_, optional): font color. Defaults to 3*(127,).
        font_face (_type_, optional): font face. Defaults to cv2.FONT_HERSHEY_SIMPLEX.
        font_size (int, optional): font size. Defaults to 2.
        height (float, optional): height. normalized to image size.. Defaults to 1.0.
        image (Any, optional): image. Default to None.
        image_width (Any, optional): image width - applicable if image is None. Default to None.
        left (float, optional): left. normalized to image size.. Defaults to 0.0.
        line_type (_type_, optional): line type. Defaults to cv2.LINE_AA.
        thickness (int, optional): thickness. Defaults to 1.
        top (float, optional): top. normalized to image size. Defaults to 0.0.
        width (float, optional): width. normalized to image size.. Defaults to 1.0.

    Returns:
        np.ndarray: image.
    """
    if image is None:
        if image_width is None:
            logger.error(f"-{NAME}: render_text(None): image_width is missing.")
            return image
    else:
        if not image.shape or len(image.shape) < 2:
            return image

    if not isinstance(font_color, list) and not isinstance(font_color, tuple):
        font_color = 3 * (font_color,)

    if not isinstance(text, list):
        text = [text]

    # https://stackoverflow.com/a/51285918/10917551
    # (label_width, label_height), baseline
    text_line_size = [
        cv2.getTextSize(
            text=text_line,
            fontFace=font_face,
            fontScale=font_size,
            thickness=thickness,
        )
        for text_line in text
    ]

    required_text_height = reduce(
        lambda x, y: x + y,
        [
            text_line_size_[0][1] + text_line_size_[1] + 2
            for text_line_size_ in text_line_size
        ],
        0,
    )
    required_text_width = max(
        [text_line_size_[0][0] for text_line_size_ in text_line_size]
    )

    if image is None:
        text_width = int(image_width * width)

        font_size *= text_width / required_text_width
    else:
        text_height = int(image.shape[0] * height)
        text_width = int(image.shape[1] * width)

        font_size *= min(
            [text_width / required_text_width, text_height / required_text_height]
        )

    # (label_width, label_height), baseline
    text_line_size = [
        cv2.getTextSize(
            text=text_line,
            fontFace=font_face,
            fontScale=font_size,
            thickness=thickness,
        )
        for text_line in text
    ]

    required_text_height = reduce(
        lambda x, y: x + y,
        [
            text_line_size_[0][1] + text_line_size_[1] + 2
            for text_line_size_ in text_line_size
        ],
        0,
    )

    if image is None:
        image = np.zeros(
            (required_text_height, image_width, color_depth),
            dtype=np.uint8,
        )

    text_height = int(image.shape[0] * height)
    text_width = int(image.shape[1] * width)

    line_spacing = (text_height - required_text_height) / (1 + len(text))

    text_left = int(image.shape[1] * left)
    text_top = int(image.shape[0] * top)

    x = text_left
    y = text_top + line_spacing
    for index, text_line in enumerate(text):
        y += text_line_size[index][0][1] + 2

        actual_x = int(
            x + text_width / 2 - text_line_size[index][0][0] / 2 if centered else x
        )

        cv2.putText(
            image,
            text=text_line,
            org=(
                actual_x,
                int(y),
            ),
            fontFace=font_face,
            fontScale=font_size,
            color=font_color,
            lineType=line_type,
            thickness=thickness,
        )
        if box:
            cv2.rectangle(
                image,
                (
                    int(actual_x),
                    int(y - text_line_size[index][0][1]),
                ),
                (
                    int(actual_x + text_line_size[index][0][0]),
                    int(y + text_line_size[index][1]),
                ),
                color=font_color,
                thickness=thickness // 2,
                lineType=line_type,
            )

        y += line_spacing

    if box:
        cv2.rectangle(
            image,
            (text_left, text_top),
            (text_left + text_width, text_top + text_height),
            color=font_color,
            thickness=thickness,
            lineType=line_type,
        )

    return image
