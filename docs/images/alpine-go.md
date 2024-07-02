---
description: MultiArch Alpine Linux + S6 + Golang
svcname: go
tags:
  - dev
  - s6
  - package
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as the base image for applications
/ services that use or require [Go][1] to function or to compile
packages.

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('go') }}
package installed in it.

{% include "pull-image.md" %}

---
Run
---

We can call `go` commands directly on the container, or run `bash`
in the container to get a [user-scoped][114] shell,

=== "command"
    ``` sh
    docker run --rm -it --name docker_go woahbase/alpine-go go version
    ```
=== "shell"
    ``` sh
    docker run --rm -it --name docker_go woahbase/alpine-go /bin/bash
    ```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars           | Default        | Description
| :---               | :---           | :---
| GOARCH             | amd64          | (Preset) As per image platform, could be one of `amd64`, `arm64`, `arm`.
| GOARM              | 7              | (Preset) As per arm-image platform, could be one of `6`, `7`.
| GOOS               | linux          | (Preset) Go OS type
| GOPATH             | /go            | Default go project path (non-module-style projects)
| GO_PROJECTDIR      | empty string   | Custom go project path for module-style projects. Should be outside of `GOPATH`. If set, dependecies from `go.mod` file in this directory are automatically set-up using `go get ./...`
| S6_GO_PACKAGES     | empty string   | Space separated list of packages to install at runtime.
| S6_GO_SKIP_GET     | unset          | If set, skip fetching dependecies from `go.mod` in `GO_PROJECTDIR`.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

[1]: https://golang.org/

{% include "all-include.md" %}
