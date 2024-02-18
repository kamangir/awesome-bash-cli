from functools import reduce
from abcli import file


def sort(filename):
    """sort help file - used by "abcli help".

    Args:
        filename (str): filename.

    Returns:
        bool: success.
    """
    success, content = file.load_text(filename)
    if not success:
        return success

    info = {
        keyword.lstrip(): value for keyword, value in zip(content[::2], content[1::2])
    }

    return file.save_text(
        filename,
        reduce(
            lambda x, y: x + y,
            [[key, info[key]] for key in sorted(info.keys())],
            [],
        ),
    )
