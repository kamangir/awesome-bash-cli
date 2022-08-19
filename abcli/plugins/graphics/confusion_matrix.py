import matplotlib.pyplot as plt
import numpy as np
from abcli.plugins.graphics import NAME
from abcli.plugins.graphics.signature import add_signature
from abcli import file
from abcli import string
from abcli import logging
import logging

logger = logging.getLogger(__name__)


def render_confusion_matrix(cm, class_names, filename, footer=[], header=[], size=8):
    import seaborn as sns

    class_names_short = string.shorten(class_names)

    logger.info(
        "{}.render_confusion_matrix({}:{}) -> {}".format(
            NAME,
            len(class_names),
            string.pretty_shape_of_matrix(cm),
            filename,
        )
    )

    if len(class_names) != cm.shape[0] or len(class_names) != cm.shape[1]:
        logger.error(f"-{NAME}: render_confusion_matrix: shape mismatch.")
        return False

    plt.figure(figsize=(size, size))

    sns.heatmap(cm, annot=True, fmt=".1%", cmap="mako", vmin=0, vmax=1)

    plt.xticks(
        np.arange(len(class_names)) + 0.5,
        class_names_short,
        rotation="vertical",
    )

    plt.yticks(
        np.arange(len(class_names)) + 0.5,
        class_names_short,
        rotation="horizontal",
    )

    if not file.prepare_for_saving(filename):
        return success

    plt.savefig(filename)
    plt.close()

    if header or footer:
        success, image = file.load_image(filename)
        if success:
            success = file.save_image(
                filename,
                add_signature(
                    image=image,
                    header=header,
                    footer=footer,
                ),
            )

    return success
