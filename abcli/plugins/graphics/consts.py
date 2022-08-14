import os
from ...tasks import host
from ... import logging
import logging

logger = logging.getLogger(__name__)

screen_width = None
screen_height = None

try:
    if host.is_rpi():
        if not host.is_headless():
            # https://stackoverflow.com/a/14124257
            screen = os.popen("xrandr -q -d :0").readlines()[0]
            screen_width = int(screen.split()[7])
            screen_height = int(screen.split()[9][:-1])
    elif host.is_mac():
        success_, output = host.shell(
            "system_profiler SPDisplaysDataType |grep Resolution",
            Options("~blank,clean,output,strip"),
        )
        if success_:
            output = [
                thing
                for thing in [
                    [int(item) for item in thing.split(" ") if item.isnumeric()]
                    for thing in output
                ]
                if len(thing) == 2
            ]
            if output:
                screen_width = output[0][0]
                screen_height = output[0][1]
    else:
        from gi.repository import Gdk

        screen = Gdk.Screen.get_default()
        geo = screen.get_monitor_geometry(screen.get_primary_monitor())
        screen_width = geo.width
        screen_height = geo.height
except:
    logger.debug("graphics.initialize(): Failed.")

if screen_height is None or screen_width is None:
    logger.debug("unknown screen size - will use default.")
    screen_height = 480
    screen_width = 640

logger.debug(f"graphics.screen: {screen_height}x{screen_width}")
