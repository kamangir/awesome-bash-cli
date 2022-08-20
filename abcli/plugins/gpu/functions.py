from bolt import logging
import logging

logger = logging.getLogger(__name__)


def validate():
    import tensorflow as tf

    logger.info(f"TensorFlow: {tf.__version__}")

    devices = tf.config.list_physical_devices("GPU")
    logger.info(f"{len(devices)} GPU(s) available: {devices}.")

    return True
