---
description: MultiArch Alpine Linux + S6 + NGINX + PHP-fpm.
tags:
  - dev
  - service

# pin php version
phpmajmin: "82"
wb_extra_args_build: PHPMAJMIN=82

---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as a standalone web host server, or as
the base image for applications / services that use [NGINX][1]
and [PHP][2].

{{ m.srcimage('alpine-nginx') }} with the {{ m.alpinepkg('php'~phpmajmin,
star=true) }} package(s) installed in it.

{% include "pull-image.md" %}

---
Run
---

Running the container starts the service.

``` sh
docker run --rm \
  --name docker_php \
  -p 80:80 \
  -p 443:443 \
  -v $PWD/config`#(1)`:/config \
woahbase/alpine-php
```

1. (Required) Path to your website configurations root directory.

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                 | Default                     | Description
| :---                     | :---                        | :---
{% include "envvars/alpine-nginx.md" %}
{% include "envvars/alpine-php.md" %}
| S6_COMPOSER_REQUIRED     | unset                       | Optional, set to `true` if any [Composer][3] task is required to run. (Will download and install composer for the task.)
| COMPOSER_VERSION         | unset                       | Specific version of `composer` to install.
| COMPOSER_INSTALL_DIR     | /usr/bin                    | Path to composer binary installation directory.
| COMPOSER_BIN_DIR         | /usr/local/bin              | Path to binaries directory for packages installed by `composer`.
| COMPOSER_VENDOR_DIR      | /usr/local/composer         | Path to vendor directory for packages installed by `composer`.
| S6_COMPOSER_PACKAGES     | empty string                | **Space**-separated list of packages to install globally with `composer`.
| S6_COMPOSER_PROJECTDIR   | unset                       | If specified, runs `composer install` (or `update` if lockfile does not exist) in this directory at runtime.
| COMPOSER_ARGS            | --no-cache --no-interaction | Arguments given to `composer install`.
| S6_COMPOSER_SKIP_INSTALL | unset                       | Skips running install/update task inside `S6_COMPOSER_PROJECTDIR`.
{% include "envvars/cron.md" %}
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also,

* PHP `(major)(minor)` version (e.g. `{{ phpmajmin }}`) is available in the
  image as the environment variable `PHPMAJMIN`, for any image
  built from this image, this can be used to install the correct
  packages for the specific PHP version installed.

* These packages below are installed by default into the image.

    * {{ m.alpinepkg('php'~phpmajmin~'-pecl-apcu') }}
    * {{ m.alpinepkg('php'~phpmajmin~'-common') }}
    * {{ m.alpinepkg('php'~phpmajmin~'-ctype') }}
    * {{ m.alpinepkg('php'~phpmajmin~'-curl') }}
    * {{ m.alpinepkg('php'~phpmajmin~'-dom') }}
    * {{ m.alpinepkg('php'~phpmajmin~'-fpm') }}
    * {{ m.alpinepkg('php'~phpmajmin~'-gd') }}
    * {{ m.alpinepkg('php'~phpmajmin~'-intl') }}
    * {{ m.alpinepkg('php'~phpmajmin~'-json') }}
    * {{ m.alpinepkg('php'~phpmajmin~'-mbstring') }}
    * {{ m.alpinepkg('php'~phpmajmin~'-opcache') }}
    * {{ m.alpinepkg('php'~phpmajmin~'-openssl') }}
    * {{ m.alpinepkg('php'~phpmajmin~'-pcntl') }}
    * {{ m.alpinepkg('php'~phpmajmin~'-pear') }}
    * {{ m.alpinepkg('php'~phpmajmin~'-pecl-mcrypt') }}
    * {{ m.alpinepkg('php'~phpmajmin~'-phar') }}
    * {{ m.alpinepkg('php'~phpmajmin~'-posix') }}
    * {{ m.alpinepkg('php'~phpmajmin~'-session') }}
    * {{ m.alpinepkg('php'~phpmajmin~'-sodium') }}
    * {{ m.alpinepkg('php'~phpmajmin~'-zip') }}

* If no `php.ini` is found inside  `/etc/php{{ phpmajmin }}/`,
  a default (from `/defaults/`, with a few options modified to suit
  this image) is provided.

* If no `php-fpm.conf` is found inside  `/etc/php{{ phpmajmin
  }}/`, a default (from `/defaults/`, with a few options modified to
  suit this image) is provided.

* If no `www.conf` is found inside  `/etc/php{{ phpmajmin
  }}/php-fpm.d/`, a default (from `/defaults/`, with a few options
  modified to suit this image) is provided.

* Cron is enabled by default to read `/etc/crontabs/`.

* Includes everything from the {{ m.myimage('alpine-nginx') }} image.

[1]: https://nginx.org
[2]: http://php.net/
[3]: https://getcomposer.org/

{% include "all-include.md" %}
