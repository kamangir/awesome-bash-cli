from PIL import Image
from tqdm import tqdm
from typing import List
from abcli.logger import logger, crash_report


NAME = "abcli.plugins.gif"


def generate_animated_gif(
    list_of_images: List[str],
    output_filename: str,
    frame_duration: int = 150,
):
    if not list_of_images:
        return True

    logger.info(
        "{}.generate_animated_gif({} frames) -> {} @ {:.2f}ms".format(
            NAME,
            len(list_of_images),
            output_filename,
            frame_duration,
        )
    )

    max_width = 0
    max_height = 0
    frames = []
    for filename in tqdm(list_of_images):
        image = Image.open(filename)

        frames.append(image)

        width, height = image.size
        max_width = max(max_width, width)
        max_height = max(max_height, height)

    padded_frames = []
    for image in frames:
        width, height = image.size
        left_pad = (max_width - width) // 2
        top_pad = (max_height - height) // 2
        padded_image = Image.new(
            "RGB",
            (max_width, max_height),
            (255, 255, 255),
        )
        padded_image.paste(image, (left_pad, top_pad))
        padded_frames.append(padded_image)

    try:
        padded_frames[0].save(
            output_filename,
            save_all=True,
            append_images=padded_frames[1:],
            duration=frame_duration,
            loop=0,  # 0 means infinite loop
        )
    except Exception:
        crash_report("generate_animated_gif")
        return False

    logger.info(
        "generate_animated_gif: {}x{}x{} -> {}".format(
            len(list_of_images),
            height,
            width,
            output_filename,
        )
    )

    return True
