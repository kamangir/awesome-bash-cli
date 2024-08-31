from abcli.plugins.tags.functions import get, set_
from abcli.modules.objects import unique_object


def test_abcli_tags():
    object_name = unique_object()

    assert set_(object_name, "this,that")

    tags_as_read = get(object_name)
    assert "this" in tags_as_read
    assert "that" in tags_as_read

    assert set_(object_name, "~that,which")

    tags_as_read = get(object_name)
    assert "that" not in tags_as_read
    assert "which" in tags_as_read
