from ... import *
from ... import logging
import logging

logger = logging.getLogger(__name__)

name = f"{shortname}.gpu"


def validate():
    import tensorflow as tf

    logger.info("TensorFlow: {}".format(tf.__version__))
    logger.info(
        "{} GPU(s) available".format(len(tf.config.list_physical_devices("GPU")))
    )

    return True
