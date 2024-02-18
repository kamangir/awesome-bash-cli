import datetime
from datetime import timezone
import json
import math
import random
import string
import time
from abcli.string import NAME
from abcli.string.constants import unit_of


def after(s, sub_string, n=1):
    """return what is after sub_string in s.

    Args:
        s (str): string.
        sub_string (str): sub string.
        n (int, optional): instance index. Defaults to 1.

    Returns:
        str: string after the n-th instance of sub_string in s.
    """
    if sub_string == "" or sub_string not in s:
        return ""

    return sub_string.join(s.split(sub_string)[n:])


def before(s, sub_string, n=1):
    """return what is before sub_string in s.

    Args:
        s (str): string.
        sub_string (str): sub string.
        n (int, optional): instance index. Defaults to 1.

    Returns:
        str: string before the n-th instance of sub_string in s.
    """
    if sub_string == "" or sub_string not in s:
        return ""

    return sub_string.join(s.split(sub_string)[:n])


def between(s, sub_string_1, sub_string_2):
    """return what is between sub_string_1 and sub_string2 in string.

    Args:
        s (str): string.
        sub_string_1 (str): sub string.
        sub_string_2 (str): sub string.

    Returns:
        str: what is between sub_string_1 and sub_string2 in string.
    """
    return before(after(s, sub_string_1), sub_string_2)


def pretty_bytes(byte_count):
    """describe byte_count as a string.

    Args:
        byte_count (int): number of bytes.

    Returns:
        str: description of byte_count.
    """
    if byte_count is None:
        return "Unknown"

    byte_count = round(byte_count)

    # Less than a kB
    if byte_count < 1024 / 10:
        return f"{byte_count:.0f} byte(s)"

    byte_count /= 1024

    if byte_count < 1024 / 10:
        return f"{byte_count:.2f} kB"

    byte_count /= 1024

    if byte_count < 1024:
        return f"{byte_count:.2f} MB"

    byte_count /= 1024

    if byte_count < 1024:
        return f"{byte_count:.2f} GB"

    byte_count /= 1024

    return f"{byte_count:.2f} TB"


def pretty_date(
    date=None,
    as_filename=False,
    delimiter=", ",
    explicit_format="",
    in_gmt=False,
    include_date=True,
    include_seconds=True,
    include_time=True,
    include_weekdays=False,
    include_zone=False,
    short=False,
    squeeze=False,
    unique=False,
):
    """return date as a string.

    Args:
        date (Any, optional): date. Defaults to None.
        as_filename (bool, optional): output is to be used as a filename.. Defaults to False.
        delimiter (str, optional): delimiter between date and time. Defaults to ", ".
        explicit_format (str, optional): explicit format, supersedes other settings. Defaults to "".
        in_gmt (bool, optional): in gmt timezone. Defaults to False.
        include_date (bool, optional): include date. Defaults to True.
        include_seconds (bool, optional): show seconds. Defaults to True.
        include_time (bool, optional): include time. Defaults to True.
        include_weekdays (bool, optional): include weekday name. Defaults to False.
        include_zone (bool, optional): show time zone. Defaults to False.
        short (bool, optional): short format. Defaults to False.
        squeeze (bool, optional): squeeze output. Defaults to False.
        unique (bool, optional): add unique postfix. Defaults to False.

    Returns:
        str: date as a string.
    """
    format = ""
    if include_date:
        if short or as_filename:
            format = "%Y %m %d"
        else:
            format = "%d %B %Y"

        if include_weekdays:
            format = "%A, " + format

        if include_time:
            format += delimiter
    if include_time:
        format += "%H:%M"
        if include_seconds:
            format += ":%S"
    if unique:
        format += f":{random.randrange(100000):05d}"
    if as_filename:
        format = (
            format.replace(" ", "-")
            .replace(":", "-")
            .replace(".", "-")
            .replace(",", "")
        )

    if explicit_format:
        format = explicit_format

    if date is None:
        date = time.time()
    if isinstance(date, datetime.datetime):
        output = date.strftime(format)
    else:
        if in_gmt:
            output = time.strftime(format, time.gmtime(date))

            if include_zone:
                output += " (GMT)"
        else:
            output = time.strftime(format, time.localtime(date))

            if include_zone:
                output += f" ({time.tzname[0] if time.tzname else '?'})"

    if squeeze:
        output = output.replace("-", "")

    return output


def pretty_frequency(frequency):
    """describe frequency as a string.

    Args:
        frequency (float): frequency

    Returns:
        str: description of frequency.
    """
    if frequency is None:
        return "Unknown"

    if frequency >= 0.5:
        if frequency < 10**3:
            return f"{frequency:.1f} Hz"

        if frequency < 10**6:
            return f"{frequency / 10**3:.1f} kHz"

        if frequency < 10**6:
            return f"{frequency / 10**6:.1f} MHz"

        return f"{frequency / 10**9:.1f} GHz"

    return "1/{}".format(
        pretty_duration(
            1 / frequency,
            largest=True,
            short=True,
        )
    )


def pretty_param(param, value=None) -> str:
    if isinstance(param, str):
        return unit_of.get(param.split(".")[0], "{}").format(value)

    if isinstance(param, dict):
        return [
            f"{param_}: {pretty_param(param_, value_)}"
            for param_, value_ in param.items()
        ]

    print(f"{NAME}.pretty_param({param.__class__.__name__}), class not found.")
    return ""


def pretty_shape(shape):
    """describe shape as a string.

    Args:
        shape (List[int]): shape.

    Returns:
        str: shape as string.
    """
    return "x".join([str(value) for value in list(shape)])


def pretty_shape_of_matrix(matrix):
    """describe size of matrix as a string.

    Args:
        matrix (Any): matrix.

    Returns:
        str: size of matrix.
    """
    import numpy as np

    return (
        f"{pretty_shape(matrix.shape)}:{matrix.dtype}"
        if isinstance(matrix, np.ndarray)
        else "-"
    )


def pretty_duration(
    duration,
    element_format="{}{}",
    include_ms=False,
    largest=False,
    past=False,
    short=False,
):
    """describe duration as a string.

    Args:
        duration (int): duration in seconds.
        element_format (str, optional): element format. Defaults to "{}{}".
        largest (bool, optional): show the largest element. Defaults to False.
        include_ms (bool, optional): include milliseconds. Defaults to False.
        past (bool, optional): past time, add "ago" to the string. Defaults to False.
        short (bool, optional): produce short description. Defaults to False.

    Returns:
        str: description of duration as a string.
    """
    if duration is None:
        return "None"

    negative_duration = duration < 0
    duration = abs(duration)

    duration_ = duration
    duration = math.floor(duration) if include_ms else round(duration)

    milliseconds = round(1000 * (duration_ - duration))

    seconds = duration % 60
    duration = math.floor(duration / 60)
    minutes = duration % 60
    duration = math.floor(duration / 60)
    hours = duration % 24
    duration = math.floor(duration / 24)
    days = duration % 30
    duration = math.floor(duration / 30)
    months = duration % 12
    years = math.floor(duration / 12)

    if short:
        year_name = " yr"
        month_name = " mth"
        day_name = " d"
        hour_name = " hr"
        minute_name = " min"
        second_name = " s"
        millisecond_name = " ms"
    else:
        year_name = " year(s)"
        month_name = " month(s)"
        day_name = " day(s)"
        hour_name = " hour(s)"
        minute_name = " minute(s)"
        second_name = " second(s)"
        millisecond_name = " millisecond(s)"

    output = []
    if years > 0:
        output.append(element_format.format(years, year_name))
    if months > 0:
        output.append(element_format.format(months, month_name))
    if days > 0:
        output.append(element_format.format(days, day_name))
    if hours > 0:
        output.append(element_format.format(hours, hour_name))
    if minutes > 0:
        output.append(element_format.format(minutes, minute_name))
    if seconds > 0:
        output.append(element_format.format(seconds, second_name))
    if include_ms:
        if milliseconds > 0:
            output.append("{:03d}{}".format(milliseconds, millisecond_name))

    if largest:
        output = output[:1]
    output = ", ".join(output)

    if past and output:
        output += " ago"

    if not output:
        output = "< 1{}".format(millisecond_name if include_ms else second_name)

    return ("-" if negative_duration else "") + output


def random_(
    length=16,
    alphabet=string.ascii_lowercase + string.digits + string.ascii_uppercase,
):
    """generate random string.

    Args:
        length (int, optional): length. Defaults to 16.
        alphabet (str, optional): alphabet. Defaults to
        string.ascii_lowercase+string.digits+string.ascii_uppercase.

    Returns:
        str: random string
    """
    return "".join(random.choice(alphabet) for _ in range(length))


def as_json(thing):
    """return thing as json.

    Args:
        thing (Any): thing.

    Returns:
        str: thing as json.
    """
    from abcli.file import JsonEncoder

    # https://docs.python.org/2/library/json.html
    return json.dumps(
        thing,
        sort_keys=True,
        cls=JsonEncoder,
        indent=0,
        ensure_ascii=False,
        separators=(",", ":"),
    ).replace("\n", "")


def shorten(thing, shorten_length=16):
    if isinstance(thing, list):
        return [shorten(item) for item in thing]
    return (
        thing
        if len(thing) < shorten_length
        else f"{thing[: shorten_length - 4]}..{thing[-2:]}"
    )


def timestamp():
    return pretty_date(
        as_filename=True,
        include_time=True,
        unique=True,
    )


def utc_timestamp(
    date=None,
    format="%Y-%m-%d-%H-%M-%S",
    timezone_="America/New_York",
):
    """generate utc timestamp.

    Args:
        date (Any, optional): date. Defaults to None.
        format (str, optional): format. Defaults to "%Y-%m-%d-%H-%M-%S".
        timezone_ (str, optional): time zone. Defaults to "America/New_York".

    Returns:
        str: utc timestamp.
    """

    if date is None:
        # https://www.geeksforgeeks.org/get-utc-timestamp-in-python/
        return (
            datetime.datetime.now(timezone.utc).replace(tzinfo=timezone.utc).timestamp()
        )

    try:
        # https://stackoverflow.com/a/79877/17619982
        import pytz

        local = pytz.timezone(timezone_)
        naive = datetime.datetime.strptime(date, format)
        local_dt = local.localize(naive, is_dst=None)
        return local_dt.astimezone(pytz.utc).timestamp()
    except:
        print(f"-{NAME}: utc_timestamp({date},{format}): failed.")
        return "unknown"
