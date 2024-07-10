---
description: Container for Alpine Linux + S6 + Python2 + Youtube-DL
svcname: youtubedl
tags:
  - deprecated
  - github
  - python
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] containerizes the [command line client][3] for
[Youtube-dl][4] along with its [Python2][1] and [ffmpeg][2]
dependencies. Useful to download, extract and/or convert media
urls from a number of sites. Checkout their [options][5] to customize
downloads as needed.

{{ m.srcimage('alpine-python2') }} with the package
[youtube-dl][3] installed in it. {{ m.ghreleasestr('ytdl-org/youtube-dl') }}

{% include "pull-image.md" %}

---
Run
---

We can call `youtubedl` directly on the container, or run `bash`
in the container to get a user-scoped shell,

=== "command"
    ``` sh
    docker run --rm -it \
      --name docker_youtubedl \
      -v $(PWD)/downloads:/home/alpine/downloads \
    woahbase/alpine-youtubedl:x86_64 \
      --version
    ```
=== "shell"
    ``` sh
    docker run --rm -it \
      --entrypoint /bin/bash \
      --name docker_youtubedl \
      -v $(PWD)/downloads:/home/alpine/downloads \
    woahbase/alpine-youtubedl:x86_64
    ```

--8<-- "multiarch.md"

---
##### Configuration
---

* Mount the downloads directory (where the audio/video files and
  archive.txt will be) at `/home/alpine/downloads`. Mounts
  `PWD/downloads` by default.

* Youtube-dl runs under the user `alpine`.

* A default for downloading video and audio are provided as
  `VDLFLAGS` and `ADLFLAGS` in the `makefile`. Use those as
  reference and/or modify as needed, the default does quite a few
  things e.g add subs if available, add metadata, embed thumbs and
  attributes, keep track of previously downloaded media in
  textfiles etc.

=== "Audio"

    Extract just the audio file from the video at the best quality available
    ``` sh
    make adl URL=<youtube video/playlist link>
    ```
    or
    ``` sh
    docker run --rm -it \
      --name docker_youtubedl \
      -v $PWD/downloads:/home/alpine/downloads \
    woahbase/alpine-youtubedl \
      -v -i \
      --add-metadata \
      --audio-quality 0 \
      --audio-format 'mp3' \
      --all-subs \
      --convert-subs 'srt' \
      --download-archive '/home/alpine/downloads/ytdl.audio.archive.txt' \
      --embed-subs \
      --embed-thumbnail \
      --extract-audio \
      --format 'bestaudio[abr>=128]/bestaudio/best' \
      --geo-bypass \
      --hls-prefer-ffmpeg \
      --no-cache-dir \
      --no-continue \
      --no-overwrites \
      --output '/home/alpine/downloads/%(title)s_%(id)s_%(abr)sKbps_%(acodec)s.%(ext)s' \
      --proxy '' \
      --retries 3 \
      --xattrs \
      --yes-playlist \
    <youtube video/playlist link>
    ```

=== "Video"

    Download a video at the best a/v quality available
    ``` sh
    make vdl URL=<youtube video/playlist link>
    ```
    or
    ``` sh
    docker run --rm -it \
      --name docker_youtubedl \
      -v $PWD/downloads:/home/alpine/downloads \
    woahbase/alpine-youtubedl \
      -v -i \
      --add-metadata \
      --audio-quality 0 \
      --all-subs \
      --convert-subs 'srt' \
      --download-archive '/home/alpine/downloads/ytdl.video.archive.txt' \
      --embed-subs \
      --format 'bestvideo+bestaudio/best' \
      --geo-bypass \
      --hls-prefer-ffmpeg \
      --merge-output-format 'mkv' \
      --no-cache-dir \
      --no-continue \
      --no-overwrites \
      --output '/home/alpine/downloads/%(title)s_%(id)s_%(resolution)s_%(fps)sfps_%(vcodec)s_%(abr)sKbps_%(acodec)s.%(ext)s' \
      --proxy '' \
      --retries 3 \
      --xattrs \
      --yes-playlist \
    <youtube video/playlist link>
    ```

=== "Info"

    List video information, e.g. available formats with
    ``` sh
    make info URL=<youtube link>
    ```
    or
    ``` sh
    docker run --rm -it \
      --name docker_youtubedl \
    woahbase/alpine-youtubedl \
      -F \
    <youtube link>
    ```

[1]: https://www.python.org
[2]: https://www.ffmpeg.org/
[3]: https://github.com/ytdl-org/youtube-dl
[4]: https://ytdl-org.github.io/youtube-dl/
[5]: https://github.com/ytdl-org/youtube-dl#options

{% include "all-include.md" %}
