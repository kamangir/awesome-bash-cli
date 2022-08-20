import matplotlib.pyplot as plt
import numpy as np
from abcli import file
from abcli import string
from .signature import add_signature
from abcli import logging
import logging

logger = logging.getLogger(__name__)


def render_distribution(
    distribution, class_names, filename, footer=[], header=[], size=8, title=""
):
    class_names_short = string.shorten(class_names)

    logger.info(
        "graphics.render_distribution({}:{}) -> {}".format(
            len(class_names),
            string.pretty_shape_of_matrix(distribution),
            filename,
        )
    )

    if len(class_names) != distribution.shape[0]:
        logger.error("-abcli: graphics: render_distribution(): shape mismatch.")
        return False

    plt.figure(figsize=(size, size))

    plt.bar(range(len(distribution)), distribution, color="#777777")

    plt.xticks(
        np.arange(len(class_names)),
        class_names_short,
        rotation="vertical",
    )

    if not file.prepare_for_saving(filename):
        return False

    if title:
        plt.title(title)
    plt.grid(True)

    plt.savefig(filename)
    plt.close()

    if header or footer:
        success, image = file.load_image(filename)
        if not success:
            return success

        return file.save_image(
            filename,
            add_signature(
                image,
                header,
                footer,
            ),
        )

    return True
