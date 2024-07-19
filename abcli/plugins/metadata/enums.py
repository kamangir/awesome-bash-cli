import os
from enum import Enum, auto
from abcli import env


class MetadataSourceType(Enum):
    FILENAME = auto()
    OBJECT = auto()
    PATH = auto()

    def filename(self, source: str, filename="metadata.yaml"):
        if self == MetadataSourceType.FILENAME:
            return source

        if self == MetadataSourceType.OBJECT:
            from abcli.modules import objects

            return os.path.join(
                objects.object_path(source),
                filename,
            )

        if self == MetadataSourceType.PATH:
            return os.path.join(
                env.abcli_object_path if source == "." else source,
                filename,
            )

        return f"unknown-source-type:{self.name.lower()}"
