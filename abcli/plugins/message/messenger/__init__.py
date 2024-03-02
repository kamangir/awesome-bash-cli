from abcli import env
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
            + [thing for thing in env.abcli_messenger_recipients.split(",") if thing]
        )
    )
)
