from blue_objects.objects import unique_object

from abcli.plugins.tags.functions import get, set_


def test_abcli_tags():
    object_name = unique_object()

    assert set_(object_name, "this,that")

    tags_as_read = get(object_name)
    assert "this" in tags_as_read
    assert "that" in tags_as_read
