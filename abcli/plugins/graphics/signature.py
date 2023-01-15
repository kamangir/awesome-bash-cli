import cv2
import numpy as np
from .text import render_text
from . import NAME
from abcli import string
from abcli import logging
import logging

logger = logging.getLogger(__name__)


def add_sidebar(image, lines, images=[], line_length=28):
    logger.debug(
        "{}.add_sidebar({},{},{})".format(
            NAME,
            string.pretty_shape_of_matrix(image),
            "|".join(lines),
            len(images),
        )
    )

    if not image.shape or not lines:
        return image

    if line_length == -1:
        line_length = max([len(line) for line in lines])

    image_width = int(image.shape[1] / 7)

    sidebar = np.concatenate(
        [
            image_
            for _, image_ in sorted(
                zip(
                    lines,
                    [
                        render_text(
                            text=line.ljust(line_length),
                            color_depth=image.shape[2],
                            image_width=image_width,
                        )
                        for line in lines
                    ],
                )
            )
        ]
        + [
            cv2.resize(
                image_,
                (
                    image_width,
                    int(image_.shape[1] / image_.shape[0] * image_width),
                ),
            )
            for image_ in images
        ],
        axis=0,
    )

    if sidebar.shape[0] > image.shape[0]:
        sidebar = sidebar[: image.shape[0], :, :]
    elif sidebar.shape[0] < image.shape[0]:
        sidebar = np.concatenate(
            [
                np.zeros(
                    (
                        image.shape[0] - sidebar.shape[0],
                        sidebar.shape[1],
                        sidebar.shape[2],
                    ),
                    dtype=sidebar.dtype,
                ),
                sidebar,
            ],
            axis=0,
        )

    return np.concatenate([sidebar, image], axis=1)


def add_signature(image, header, footer=[]):
    """add signature to image.

    Args:
        image (np.ndarray): image.
        header (List[str]): header.
        footer (List[str], optional): footer. Defaults to [].

    Returns:
        bool: success
    """
    if image is None or not image.shape:
        return image

    adjust_length = (
        lambda line: line if len(line) >= 80 else line + (80 - len(line)) * " "
    )

    return np.concatenate(
        [
            render_text(
                text=adjust_length(line),
                image_width=image.shape[1],
                color_depth=image.shape[2],
            )
            for line in header
        ]
        + [image]
        + [
            render_text(
                text=adjust_length(line),
                image_width=image.shape[1],
                color_depth=image.shape[2],
            )
            for line in footer
        ],
        axis=0,
    )
