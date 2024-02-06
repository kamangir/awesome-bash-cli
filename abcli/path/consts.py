import os

abcli_path_storage = os.getenv(
    "abcli_path_storage",
    os.path.join(os.getenv("HOME"), "storage"),
)
abcli_object_root = os.getenv(
    "abcli_object_root",
    os.path.join(abcli_path_storage, "abcli"),
)
