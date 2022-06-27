import datetime
from datetime import timezone
import math
import os
from random import randrange
import string
import time
from .. import *
from ..options import Options

name = f"{shortname}.string"


os.environ["TZ"] = "America/New_York"
time.tzset()

unit_of = {
    "ambient light": "{} lux",
    "humidity": "{} %RH",
    "iteration": "{:,}",
    "pitch": "{} deg",
    "pressure": "{} hPa",
    "roll": "{} deg",
    "temperature": "{} 'C",
    "yaw": "{} deg",
}


def after(s, sub_string, n=1):
    """return what is after sub_string in s.

    Args:
        s (str): string.
        sub_string (str): sub string.
        n (int, optional): instance index. Defaults to 1.

    Returns:
        str: string after the n-th instance of sub_string in s.
    """
    if sub_string == "":
        return ""
    elif sub_string not in s:
        return ""
    else:
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
    if sub_string == "":
        return ""
    elif sub_string not in s:
        return ""
    else:
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
    """describe byte_count.

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
        return "f{byte_count:.2f} kB"

    byte_count /= 1024

    if byte_count < 1024:
        return "f{byte_count:.2f} MB"

    byte_count /= 1024

    if byte_count < 1024:
        return "f{byte_count:.2f} GB"

    byte_count /= 1024

    return "f{byte_count:.2f} TB"


def pretty_date(options="", date=None):
    """
    return date as a string.
    :param options:
        . date      : include date.
                      default: True
        . delimiter : delimiter between date and time.
                      default : "|"
        . filename  : output is to be used as a filename.
                      default: False
        . format    : explicit format, replaces other options.
                      default: ""
        . gmt       : gmt timezone.
                      default: False
        . second    : show seconds.
                      default: True
        . short     : short format.
                      default: False
        . squeeze   : squeeze output.
                      default: False
        . time      : include time.
                      default: True
        . unique    : add unique postfix.
                      default : False
        . weekday   : include weekday name.
                      default : False
        . zone      : show time zone. only applicable to +gmt.
                      default: False
    :param date: Date
    :return: string
    """
    options = (
        Options(options)
        .default("date", True)
        .default("delimiter", ", ")
        .default("filename", False)
        .default("format", "")
        .default("gmt", False)
        .default("second", True)
        .default("short", False)
        .default("squeeze", False)
        .default("time", True)
        .default("unique", False)
        .default("weekday", False)
        .default("zone", False)
    )

    format = ""
    if options["date"]:
        if options["short"] or options["filename"]:
            format = "%Y %m %d"
        else:
            format = "%d %B %Y"

        if options["weekday"]:
            format = "%A, " + format

        if options["time"]:
            format += options["delimiter"]
    if options["time"]:
        format += "%H:%M"
        if options["second"]:
            format += ":%S"
    if options["unique"]:
        format += ":{:05d}".format(randrange(100000))
    if options["filename"]:
        format = (
            format.replace(" ", "-")
            .replace(":", "-")
            .replace(".", "-")
            .replace(",", "")
        )

    if options["format"]:
        format = options["format"]

    if date is None:
        date = time.time()
    if isinstance(date, datetime.datetime):
        output = date.strftime(format)
    else:
        if options["gmt"]:
            output = time.strftime(format, time.gmtime(date))

            if options["zone"]:
                output += " (GMT)"
        else:
            output = time.strftime(format, time.localtime(date))

            if options["zone"]:
                output += " (" + (time.tzname[0] if time.tzname else "?") + ")"

    if options["squeeze"]:
        output = output.replace("-", "")

    return output


def pretty_frequency(frequency):
    """describe a frequency as a string.

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
        elif frequency < 10**6:
            return f"{frequency / 10**3:.1f} kHz"
        elif frequency < 10**6:
            return f"{frequency / 10**6:.1f} MHz"
        else:
            return f"{frequency / 10**9:.1f} GHz"

    return f"1/{pretty_time(1 / frequency, largest=True, short=True)}"


def pretty_list(input, options=""):
    """
    return input list in a pretty form.
    :param input: list
    :param options
        . binned      : log binned data.
                        default: False
        . class_names : class names.
                        default: None (disable)
        . count       : number of items to show.
                        default: 10
        . filenames   : items are filenames.
                        default: False
        . items       : plural item name.
                        default: "item(s)"
    :return: string
    """
    import numpy as np
    from abcli.file import name_and_extension

    options = (
        Options(options)
        .default("binned", False)
        .default("class_names", None)
        .default("count", 10)
        .default("filenames", False)
    )
    options = options.default("items", "file(s)" if options["filenames"] else "item(s)")

    return "{} {}: {}".format(
        len(input),
        options["items"],
        ",".join(
            [
                "{}x{}".format(
                    count,
                    "#{}".format(index)
                    if options["class_names"] is None
                    else options["class_names"][index],
                )
                for index, count in enumerate(np.bincount(np.array(input)))
            ]
        )
        if options["binned"]
        else "{}{}".format(
            ",".join(
                [
                    name_and_extension(thing) if options["filenames"] else str(thing)
                    for thing in input[: options["count"]]
                ]
            ),
            ",..." if len(input) > options["count"] else "",
        ),
    )


def pretty_size_of_matrix(matrix):
    """return size of matrix as a string.

    Args:
        matrix (Any): matrix.

    Returns:
        str: size of matrix.
    """
    import numpy as np

    return (
        "x".join([str(value) for value in list(matrix.shape)]) + f":{matrix.dtype}"
        if isinstance(matrix, np.ndarray)
        else "-"
    )


def pretty_time(duration, options=""):
    """
    return time in a pretty form.
    duration: in seconds.
    :param options:
        . format  : element format
                    default: "{}{}"
        . largest : Only show the largest denominator.
                    default : False
        . ms      : Include milliseconds.
                    default : False
        . past    : Add "ago" to the string.
                    default : False
        . short   : Generate short string.
                    default : False
        . summary : Generate summary.
                    default : False
    :return: string
    """
    options = (
        Options(options)
        .default("format", "{}{}")
        .default("largest", False)
        .default("ms", False)
        .default("past", False)
        .default("short", False)
        .default("summary", False)
    )

    if duration is None:
        return "None"

    negative_duration = duration < 0
    duration = abs(duration)

    duration_ = duration
    duration = math.floor(duration) if options["ms"] else round(duration)

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

    if options["short"]:
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
        output.append(options["format"].format(years, year_name))
    if months > 0 and not (options["summary"] and output):
        output.append(options["format"].format(months, month_name))
    if days > 0 and not (options["summary"] and output):
        output.append(options["format"].format(days, day_name))
    if hours > 0 and not (options["summary"] and output):
        output.append(options["format"].format(hours, hour_name))
    if minutes > 0 and not (options["summary"] and output):
        output.append(options["format"].format(minutes, minute_name))
    if seconds > 0 and not (options["summary"] and output):
        output.append(options["format"].format(seconds, second_name))
    if options["ms"] and not (options["summary"] and output):
        if milliseconds > 0:
            output.append("{:03d}{}".format(milliseconds, millisecond_name))

    if options["largest"]:
        output = output[:1]
    output = ", ".join(output)

    if options["past"] and output:
        output += " ago"

    if not output:
        output = "None"

    return ("-" if negative_duration else "") + output


def timestamp(
    compact=True,
    include_ms=False,
    include_time=True,
):
    """return timestamp.

    Args:
        compact (bool, optional): compact form. Defaults to True.
        include_ms (bool, optional: include milliseconds. Default yo False.
        include_time (bool, optional): include time. Defaults to True.

    Returns:
        str: timestamp.
    """
    current_time = time.time()

    output = time.strftime(
        ("%Y-%m-%d-%H-%M-%S" if compact else "%d %B %Y, %H:%M:%S")
        if include_time
        else ("%Y-%m-%d" if compact else "%d %B %Y"),
        time.localtime(current_time),
    )

    if include_time and include_ms:
        output += f"{'-' if compact else ':'}{(current_time % 1) * 1000:03.0f}"

    return output


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
    else:
        try:
            # https://stackoverflow.com/a/79877/17619982
            import pytz

            local = pytz.timezone(timezone_)
            naive = datetime.datetime.strptime(date, format)
            local_dt = local.localize(naive, is_dst=None)
            return local_dt.astimezone(pytz.utc).timestamp()
        except:
            from abcli.logging import crash_report

            crash_report(f"-{name}: utc_timestamp({date},{format}) failed.")
            return "unknown"
