import argparse

from . import *


from bolt import logging
import logging

logger = logging.getLogger(__name__)


parser = argparse.ArgumentParser(name, description="{}-{:.2f}".format(name, version))
parser.add_argument("task", type=str, help="TBD")
args = parser.parse_args()

success = False
if args.task == "TBD":
    success = True
else:
    logger.error('{}: unknown task "{}".'.format(name, args.task))

if not success:
    logger.error("{}.{} failed.".format(name, args.task))
