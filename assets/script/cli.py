import argparse

import abcli.logging
import logging

logger = logging.getLogger(__name__)

NAME = "cli"


def task_1(bool_arg, int_arg, str_arg):
    logger.info("cli.task_1({bool_arg},{int_arg},{str_arg}): Hello World!")
    return True


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "task",
        type=str,
        default="",
        help="task_1",
    )
    parser.add_argument(
        "--int_arg",
        type=int,
        default=-1,
    )
    parser.add_argument(
        "--bool_arg",
        default=0,
        type=int,
        help="0|1",
    )
    parser.add_argument(
        "--str_arg",
        type=str,
        default="",
    )
    args = parser.parse_args()

    success = False
    if args.task == "task_1":
        success = task_1(args.bool_arg, args.int_arg, args.str_arg)
    else:
        logger.error(f"-{NAME}: {args.task}: command not found.")

    if not success:
        logger.error(f"-{NAME}: {args.task}: failed.")
