from blue_options import host

from abcli import env
from abcli.plugins.message.messenger.classes import Messenger


instance = Messenger(
    recipients=list(
        set(
            [
                "public",
                host.get_name(),
            ]
            + [thing for thing in env.abcli_messenger_recipients.split(",") if thing]
        )
    )
)
