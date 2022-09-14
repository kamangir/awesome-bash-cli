import isodate
import json
import os
import os.path
import urllib.request
from abcli import file
from abcli import string
from abcli.modules.cookie import cookie
import abcli.logging
import logging

# https://github.com/googleapis/google-api-python-client/issues/299#issuecomment-255793971
logging.getLogger("googleapicliet.discovery_cache").setLevel(logging.ERROR)

logger = logging.getLogger(__name__)

# https://medium.com/daily-python/python-script-to-search-content-using-youtube-data-api-daily-python-8-1084776a6578
api_key = cookie.get("youtube.api_key", "")


def download(video_id, filename=""):
    # https://pytube.io/en/latest/
    from pytube import YouTube

    if not filename:
        filename = os.path.join(os.getenv("abcli_asset_folder", ""), "video.mp4")

    try:
        yt = YouTube(f"https://www.youtube.com/watch?v={video_id}")

        logger.info(
            'youtube.download({}->{}): "{}"'.format(
                video_id,
                os.getenv("abcli_asset_name", ""),
                yt.title,
            )
        )
        yt.streams.filter(progressive=True, file_extension="mp4").order_by(
            "resolution"
        ).desc().first().download(filename=filename)
    except:
        from abcli.logging import crash_report

        crash_report(f"youtube.download({video_id}) failed.")
        return False

    duration_ = duration(video_id)

    logger.info(
        "youtube.download({}): {} - {} s = {}".format(
            video_id,
            string.pretty_bytes(file.size(filename)),
            duration_,
            string.pretty_time(duration_, short=True),
        )
    )

    return file.save_json(
        file.set_extension(filename, "json"),
        {"duration": duration_, "video_id": video_id, "title": yt.title},
        "~archive",
    )


# https://stackoverflow.com/a/33708632/17619982
def duration(video_id):
    searchUrl = (
        "https://www.googleapis.com/youtube/v3/videos?id="
        + video_id
        + "&key="
        + api_key
        + "&part=contentDetails"
    )
    response = urllib.request.urlopen(searchUrl).read()
    return isodate.parse_duration(
        json.loads(response)["items"][0]["contentDetails"]["duration"]
    ).total_seconds()


def search(keyword, what="keyword"):
    from apiclient.discovery import build

    youtube = build("youtube", "v3", developerKey=api_key)
    if what == "keyword":
        request = youtube.search().list(
            q=keyword,
            part="snippet",
            type="video",
            maxResults=10,
            videoLicense="creativeCommon",
        )
    elif what == "channelId":
        request = youtube.search().list(
            channelId=keyword,
            part="snippet",
            type="video",
            maxResults=10,
            videoLicense="creativeCommon",
        )
    else:
        return False, []

    res = request.execute()

    return True, [item["id"]["videoId"] for item in res["items"]]


# https://stackoverflow.com/a/56714010/17619982
def info(video_id, part="contentDetails"):
    response = urllib.request.urlopen(
        (
            "https://www.googleapis.com/youtube/v3/videos?id={}&key={}&part={}".format(
                video_id, api_key, part
            )
        )
    ).read()
    return json.loads(response)


def is_CC(video_id):
    items = info(video_id, "status").get("items", [])
    if not items:
        logger.error(f"youtube.is_CC({video_id}) failed, no items.")
        return False

    if len(items) > 1:
        logger.info(
            "warning! youtube.is_CC({}): {} status item(s).".format(
                video_id, len(items)
            )
        )

    return items[0].get("status", {}).get("license", "") == "creativeCommon"


def validate():
    from apiclient.discovery import build

    youtube = build("youtube", "v3", developerKey=api_key)
    logger.info(f"youtube.validate(): {type(youtube)}")
    return True
