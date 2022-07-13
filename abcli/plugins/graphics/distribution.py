from ... import string
from ... import logging
import logging

logger = logging.getLogger(__name__)


def render_distribution(distribution, class_names, filename, options=""):
    """
    render distribution
    :param distribution: distribution
    :param class_names: class_names
    :param filename: filename
    :param options:
        . footer : footer.
                   default: []
        . header : header.
                   default: []
        . size   : size.
                   default: 8
        . title : title.
                   default: ""
        . file.save_image()
    :return: success
    """

    options = (
        Options(options)
        .default("header", [])
        .default("footer", [])
        .default("size", 8)
        .default("title", "")
    )

    class_names_shorten = string.shorten(class_names)

    logger.info(
        "graphics.render_distribution({}:{}) -> {}".format(
            len(class_names),
            string.pretty_shape_of_matrix(distribution),
            filename,
        )
    )

    if len(class_names) != distribution.shape[0]:
        logger.error("graphics.render_distribution(): shape mismatch.")
        return False

    plt.figure(figsize=(options["size"], options["size"]))

    plt.bar(range(len(distribution)), distribution, color="#777777")

    plt.xticks(
        np.arange(len(class_names)),
        class_names_shorten,
        rotation="vertical",
    )

    if not file.prepare_for_saving(filename):
        return success

    if options["title"]:
        plt.title(options["title"])
    plt.grid(True)

    plt.savefig(filename)
    plt.close()

    if options["header"] or options["footer"]:
        success, image = file.load_image(filename)
        if not success:
            return success

        image = add_signature(image, options["header"], options["footer"])

        if not file.save_image(filename, image, options):
            return False

    return success
