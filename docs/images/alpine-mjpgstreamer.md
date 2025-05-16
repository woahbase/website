---
description: MultiArch Alpine Linux + S6 + mJPG_streamer
svcname: mjpgstreamer
has_services:
  - systemd
tags:
  - github
  - service
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] provides [mJPG_Streamer][1] to stream/snapshot
and optionally, control (limited) a webcam/camera over the
network.

{{ m.srcimage('alpine-s6') }} with the `mjpg_streamer` binary
(compiled from [ArduCAM's fork][2], previously [jacksonliam's
repo][1]) included in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_mjpgstreamer \
  -p 8080:8080 \
  --device /dev/video0 \
woahbase/alpine-mjpgstreamer
```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars             | Default                            | Description
| :---                 | :---                               | :---
| GID_VIDEO            | unset                              | Group-id of `video` group on the host. If set, updates group-id of the group `video` inside container, and adds `S6_USER` to the group.
| MJPGST_VIDEO_DEV     | /dev/video0                        | Default video device to use (**must exist**). Added to input arguments.
| MJPGST_INPUT_MODULE  | input_uvc.so                       | Default input module.
| MJPGST_INPUT_OPTS    | -n -r 640x480                      | Input module arguments.
| MJPGST_HOST          | 0.0.0.0                            | Binds to all interfaces by default.
| MJPGST_PORT          | 8080                               | Default port for service.
| MJPGST_OUTPUT_MODULE | output_http.so                     | Default output module.
| MJPGST_OUTPUT_OPTS   | -l $MJPGST_HOST -p $MJPGST_PORT    | Output module arguments.
| MJPGST_CREDENTIALS   | unset                              | Access credentials in format `user:pass`. If set, added to the `MJPGST_OUTPUT_OPTS`.
| MJPGST_WWW_ROOT      | /usr/local/share/mjpg-streamer/www | Path where default UI/Control files are. If unset, will only serve snapshot/stream. Can be customized to point at your own html/css/js if needed.
| MJPGST_ARGS          | unset                              | Customizable arguments passed to `mjpg_streamer` service.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* Default configuration listens to port `8080`, make sure the
  port is accessible in the firewall configurations.

* Make sure to mount the proper camera device (e.g.
  `/dev/video0`) in the container, and optionally set `GID_VIDEO`
  so that `mjpg_streamer` (running under user `alpine`) is allowed
  access to the camera.

* `mjpg_streamer` feature status printed during build.
  ```
   -- The following features have been enabled:

    * WXP_COMPAT, Enable compatibility with WebcamXP
    * PLUGIN_INPUT_FILE, File input plugin
    * PLUGIN_INPUT_HTTP, HTTP input proxy plugin
    * PLUGIN_INPUT_RASPICAM, Raspberry Pi input camera plugin **(only for ARM)**
    * PLUGIN_INPUT_PTP2, PTP2 input plugin
    * PLUGIN_INPUT_UVC, Video 4 Linux input plugin
    * PLUGIN_INPUT_LIBCAMERA, Libcamera input plugin
    * PLUGIN_OUTPUT_FILE, File output plugin
    * ENABLE_HTTP_MANAGEMENT, Enable experimental HTTP management option
    * PLUGIN_OUTPUT_HTTP, HTTP server output plugin
    * PLUGIN_OUTPUT_RTSP, RTSP output plugin
    * PLUGIN_OUTPUT_UDP, UDP output stream plugin
    * PLUGIN_OUTPUT_VIEWER, SDL output viewer plugin
    * PLUGIN_OUTPUT_ZMQSERVER, ZMQ Server output plugin

   -- The following features have been disabled:

    * PLUGIN_INPUT_OPENCV, OpenCV input plugin (unmet dependencies)
  ```

* If running with SystemD (see below), the service can be
  auto-activated whenever the camera is plugged in via
  a [Path][3]-test for the service, e.g.
  ```
  # assuming the service file is at
  # ~/.config/systemd/user/mjpgstreamer.service
  # the path file should be
  # ~/.config/systemd/user/mjpgstreamer.path

  [Unit]
  Description=Monitor /dev/video0 and activate mjpgstreamer.service

  [Path]
  PathExists=/dev/video0

  # name of service to activate, if different from path name
  # Unit=mjpgstreamer

  [Install]
  WantedBy=default.target
  ```

[1]: https://github.com/jacksonliam/mjpg-streamer
[2]: https://github.com/ArduCAM/mjpg-streamer
[3]: https://www.freedesktop.org/software/systemd/man/latest/systemd.path.html

{% include "all-include.md" %}
