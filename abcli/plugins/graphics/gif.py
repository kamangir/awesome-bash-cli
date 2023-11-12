from PIL import Image
from tqdm import tqdm
from typing import List
from abcli import logging
import logging

logger = logging.getLogger(__name__)

NAME = "abcli.plugins.gif"


def generate_animated_gif(
    list_of_images: List[str],
    output_filename: str,
    frame_duration: int = 150,
):
    if not list_of_images:
        return

    logger.info(
        "{}.generate_animated_gif({} frames) -> {} @ {:.2f}ms".format(
            NAME,
            len(list_of_images),
            output_filename,
            frame_duration,
        )
    )

    frames = []
    for filename in tqdm(list_of_images):
        frames.append(Image.open(filename))

    frames[0].save(
        output_filename,
        save_all=True,
        append_images=frames[1:],
        duration=frame_duration,
        loop=0,  # 0 means infinite loop
    )
