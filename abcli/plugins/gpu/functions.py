from abcli import logging
import logging

logger = logging.getLogger(__name__)


def get_status(verbose: bool = True):
    # https://pytorch.org/docs/stable/generated/torch.cuda.is_available.html
    try:
        import torch

        if torch.cuda.is_available():
            return True
    except Exception as e:
        if verbose:
            print(e)

    return False
