"""file interface"""

NAME = "abcli.file"

# pylint: disable=wrong-import-position
from .functions import (
    absolute,
    add_postfix,
    add_prefix,
    auxiliary,
    copy,
    create,
    delete,
    download,
    exist,
    extension,
    list_of,
    move,
    name_and_extension,
    name,
    path,
    relative,
    set_extension,
    size,
)
from .load import (
    load_geodataframe,
    load_geojson,
    load_image,
    load_json,
    load_text,
    load_yaml,
    load,
)
from .save import (
    prepare_for_saving,
    save_csv,
    save_fig,
    save_geojson,
    save_image,
    save_json,
    save_tensor,
    save_text,
    save_yaml,
    save,
)
