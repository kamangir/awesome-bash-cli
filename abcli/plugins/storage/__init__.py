import os
from abcli.plugins import aws

NAME = "abcli.plugins.storage"

default_bucket_name = aws.get_from_json("s3").get("bucket_name", "kamangir")

object_prefix = aws.get_from_json("s3").get("prefix", "abcli")


from .classes import Storage

instance = Storage()
