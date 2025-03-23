from typing import List

from blue_options.terminal import show_usage, xtra


def help_clone(
    tokens: List[str],
    mono: bool,
) -> str:
    # @cp - object object
    options = "".join(
        [
            xtra("~content,cp,~download,", mono=mono),
            "~relate",
            xtra(",~tags,", mono=mono),
            "upload",
        ]
    )

    usage_1 = show_usage(
        [
            "@cp",
            f"[{options}]",
            "[..|<object-1>]",
            "[.|<object-2>]",
        ],
        "copy <object-1> -> <object-2>.",
        mono=mono,
    )

    # @cp - s3 object
    options = "~relate,s3,upload"

    usage_2 = show_usage(
        [
            "@cp",
            f"[{options}]",
            "s3://uri",
            "[.|<object-name>]",
        ],
        "copy s3://uri -> <object-name>.",
        mono=mono,
    )

    return "\n".join(
        [
            usage_1,
            usage_2,
        ]
    )
