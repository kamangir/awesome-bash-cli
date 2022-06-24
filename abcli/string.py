import argparse
import datetime
from datetime import timezone
import hashlib
import math
import os
from random import randrange
import time
import urllib.parse

from abcli.options import Options

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


def between(var, sub_string1, sub_string2):
    """
    return what is between sub_string1 and sub_string2 in string.
    :param var: string
    :param sub_string1: sub string 1
    :param sub_string2: sub string 2
    :return: string
    """
    return before(after(var, sub_string1), sub_string2)


def pretty_bytes(byte_count):
    """
    Describe a number of bytes as a string.
    :param byte_count: Number of bytes.
    :return: Number of bytes as a string.
    """

    if byte_count is None:
        return "Unknown"

    byte_count = round(byte_count)

    # Less than a kB
    if byte_count < 1024 / 10:
        return "{:.0f} byte(s)".format(byte_count)

    byte_count = byte_count / 1024

    if byte_count < 1024 / 10:
        return "{:.2f} kB".format(byte_count)

    byte_count = byte_count / 1024

    if byte_count < 1024:
        return "{:.2f} MB".format(byte_count)

    byte_count = byte_count / 1024

    if byte_count < 1024:
        return "{:.2f} GB".format(byte_count)

    byte_count = byte_count / 1024

    return "{:.2f} TB".format(byte_count)


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
    """
    Describe a frequency as a string.
    :param frequency: frequency.
    :return: string
    """

    if frequency is None:
        return "Unknown"

    if frequency >= 0.5:
        if frequency < 10**3:
            return "{:.1f} Hz".format(frequency)
        elif frequency < 10**6:
            return "{:.1f} kHz".format(frequency / 10**3)
        elif frequency < 10**6:
            return "{:.1f} MHz".format(frequency / 10**6)
        else:
            return "{:.1f} GHz".format(frequency / 10**9)

    return "1/{}".format(pretty_time(1 / frequency, "largest,short"))


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


def pretty_logical(value):
    """
    return logical value in a pretty form.
    :param value: bool
    :return: string
    """
    return ["No", "Yes"][int(bool(value))]


def pretty_param(param, value=None):
    if isinstance(param, str):
        return unit_of.get(param.split(".")[0], "{}").format(value)
    elif isinstance(param, dict):
        return [
            "{}: {}".format(param_, pretty_param(param_, value_))
            for param_, value_ in param.items()
        ]
    else:
        print(
            "string.pretty_param({}) unknown, failed.".format(param.__class__.__name__)
        )


def pretty_sign(value):
    """
    return sign of value as a string.
    :param value: value
    :return: string
    """
    if value is None:
        return "Unknown"
    if value == 0:
        return "Zero"
    if value > 0:
        return "Positive"
    return "Negative"


def pretty_size(dimension):
    """
    Describe dimension, that is assumed to describe the size of another matrix, as a string.
    :param dimension: dimension
    :return: string
    """
    import numpy as np

    if isinstance(dimension, np.ndarray):
        dimension = dimension.astype(np.int)
    if not isinstance(dimension, list):
        dimension = list(dimension)

    if not dimension:
        return "Empty"

    return "x".join([str(value) for value in dimension])


def pretty_size_of_matrix(matrix):
    """
    return size of matrix as a string.
    :param matrix: matrix
    :return: string
    """
    import numpy as np

    if not isinstance(matrix, np.ndarray):
        return "-"
    return pretty_size(list(matrix.shape)) + ":{}".format(matrix.dtype)


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


def random(length=8, options=""):
    """
    Generate random string.
    :param length: string length. default: 8
    :param options:
          . binary : Use 0/1.
                     Default: False
          . digit  : Use digits.
                     Default: not binary.
          . lower  : Use lower case characters.
                     Default: not binary.
          . time   : Use time.
                     Default: digit
          . upper  : Use upper case characters.
                     Default: not binary.
    :return: Randomly generated string.
    """
    import string

    options = Options(options).default("binary", False)
    options = options.default("digit", not options["binary"])
    options = options.default("time", options["digit"])

    alphabet = ""
    if options["binary"]:
        alphabet += "01"
    if options["digit"]:
        alphabet += string.digits
    if options.get("lower", not options["binary"]):
        alphabet += string.ascii_lowercase
    if options.get("upper", not options["binary"]):
        alphabet += string.ascii_uppercase
    if alphabet == "":
        raise NameError("string.random() requires a non-empty alphabet.")

    if options["time"]:
        if length <= 2:
            options["time"] = False
        else:
            length -= 2

    import random

    output = "".join(random.choice(alphabet) for _ in range(length))

    if options["time"]:
        output += "{0:02d}".format(round(time.time() * 86400000) % 100)

    return output


def timestamp(options=""):
    """
    return timestamp.
    :param options:
        . ms   : Include milli-seconds.
                 default: False
        . timestamp_template().
    :return: string
    """
    options = Options(options).default("ms", False)

    current_time = time.time()
    output = time.strftime(timestamp_template(options), time.localtime(current_time))

    if options["ms"]:
        output += "-{:03.0f}".format((current_time % 1) * 1000)

    return output


def timestamp_template(options=""):
    """
    return template for a time stamp.
    :param options:
              . day : return day.
                       default: False
              . full : return full time stamp. When full is False, then a more compact time stamp is generated.
                       default: False
              . time : Include time. This options is only applicable if full is False.
                       default: True
    :return: Output
    """
    options = (
        Options(options)
        .default("day", False)
        .default("full", False)
        .default("time", True)
    )

    if options["day"]:
        return "%Y-%m-%d"

    if options["full"]:
        return "%d %B %Y, %H:%M:%S"

    if options["time"]:
        return "%Y-%m-%d-%H-%M-%S"

    return "%Y-%m-%d"


def utc_timestamp(
    date=None,
    format="%Y-%m-%d-%H-%M-%S",
    timezone_="America/New_York",
):
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

            crash_report("string.utc_timestamp({}) failed".format(date, format))
            return "unknown"


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "task",
        type=str,
        default="",
        help="argparse",
    )
    parser.add_argument(
        "--list_of_args",
        type=str,
        default="",
        help="",
    )
    parser.add_argument(
        "--arg",
        type=str,
        default=None,
        help="",
    )
    parser.add_argument(
        "--default",
        type=str,
        default="",
        help="",
    )
    args = parser.parse_args()

    success = False
    if args.task == "argparse":
        items = args.list_of_args.replace("  ", " ").split(" ")
        print(
            {name: value for name, value in zip(items[:-1:2], items[1::2])}.get(
                args.arg, args.default
            )
        )
        success = True
    else:
        print('string: unknown task "{}".'.format(args.task))

    if not success:
        print("string({}): failed.".format(args.task))
