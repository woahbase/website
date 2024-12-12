---
description: MultiArch Alpine Linux + S6 + Ruby
svcname: ruby
tags:
  - dev
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as the base image for
applications/services that use or require [Ruby][1] or [Gem][2] or
tools like [Bundler][3], [Rake][4] to function.

{{ m.srcimage('alpine-s6') }} with the {{ m.alpinepkg('ruby') }}
packages installed in it.

{% include "pull-image.md" %}

---
Run
---

We can call `ruby` or `irb` directly on the container, or run
`bash` in the container to get a [user-scoped][114] shell,

=== "command"
    ``` sh
    docker run --rm -it --name docker_ruby woahbase/alpine-ruby ruby --version
    ```
=== "shell"
    ``` sh
    docker run --rm -it --name docker_ruby woahbase/alpine-ruby /bin/bash
    ```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars               | Default            | Description
| :---                   | :---               | :---
| GEM_HOME               | /usr/local/bundle  | Default path for GEM installation.
| BUNDLE_APP_CONFIG      | /usr/local/bundle  | Default path for GEM installations using `bundler`.
| S6_GEM_PACKAGES        | empty string       | **Space**-separated list of packages to install globally with `gem`.
| S6_BUNDLE_PROJECTDIR   | unset              | If specified, runs `bundle install` in this dir as a pre-task at runtime. (`Gemfile` or `Gemfile.lock` must exist in this directory.)
| S6_BUNDLE_ARGS         | --jobs=4 --retry=2 | Customizable arguments passed to `bundle install` inside the project directory.
| S6_BUNDLE_SKIP_INSTALL | unset              | If specified, skips `bundle install` pre-task at runtime.
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

[1]: https://www.ruby-lang.org
[2]: https://rubygems.org
[3]: https://bundler.io/
[4]: https://github.com/ruby/rake

{% include "all-include.md" %}
