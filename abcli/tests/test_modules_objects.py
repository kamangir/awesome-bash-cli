from abcli import path
from abcli.modules import objects


def test_object_path():
    object_name = objects.unique_object()
    object_path = objects.object_path(object_name, create=True)
    assert object_path
    assert path.exist(object_path)


def test_unique_object():
    prefix = "prefix"
    object_name = objects.unique_object(prefix)
    assert object_name
    assert object_name.startswith(prefix)
