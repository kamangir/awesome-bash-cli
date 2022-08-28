import os
from abcli import file
from abcli.modules import host
from abcli.logging import crash_report
from abcli import logging
import logging

logger = logging.getLogger(__name__)


def return_to_bash(status, content=[]):
    """return to bash with status.

    Args:
        status (str): exit/reboot/seed/shutdown/update
        content (list, optional): content of the status. Defaults to [].
    """
    logger.info(f"session.return_to_bash({status}).")
    file.create(
        os.path.join(
            os.getenv("abcli_path_cookie", ""),
            f"session_return_{status}",
        ),
        content,
    )


def session(Session, output=""):
    logger.info(f"{Session.__name__} started  -> {output}")

    try:
        session = Session(output)

        while session.step():
            pass

        logger.info(f"{Session.__name__} stopped")
    except KeyboardInterrupt:
        logger.info(f"Ctrl+C - {Session.__name__} stopped")
        return_to_bash("exit")
    except:
        crash_report(f"{Session.__name__} failed")

    try:
        session.close()
    except:
        crash_report(f"{Session.__name__}.close() failed")
