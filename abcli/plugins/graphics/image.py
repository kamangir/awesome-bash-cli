import numpy as np


def add_frame(image, width):
    """add frame to image.

    Args:
        image (np.ndarray): image.
        width (int): frame width.

    Returns:
        np.ndarray: updated image.
    """
    output = np.zeros(
        (image.shape[0] + 2 * width, image.shape[1] + 2 * width, image.shape[2]),
        dtype=image.dtype,
    )

    output[width:-width, width:-width, :] = image[:, :, :]

    return output
