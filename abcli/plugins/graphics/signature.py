from .text import render_text
import numpy as np


def add_signature(image, header, footer=[]):
    """add signature to image.

    Args:
        image (np.ndarray): image.
        header (List[str]): header.
        footer (List[str], optional): footer. Defaults to [].

    Returns:
        bool: success
    """
    if not image.shape:
        return image

    return np.concatenate(
        [
            render_text(
                text=line,
                image_width=image.shape[1],
                color_depth=image.shape[2],
            )
            for line in header
        ]
        + [image]
        + [
            render_text(
                text=line,
                image_width=image.shape[1],
                color_depth=image.shape[2],
            )
            for line in footer
        ],
        axis=0,
    )
