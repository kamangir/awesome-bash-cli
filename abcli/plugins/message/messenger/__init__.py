from abcli.modules import host
from abcli.plugins.message.messenger.classes import Messenger


instance = Messenger(
    recipients=list(
        set(
            [
                "public",
                host.get_name(),
            ]
            + host.get_tags()
            + [
                thing
                for thing in host.COOKIE.get("messenger.recipients", "").split(",")
                if thing
            ]
        )
    )
)
