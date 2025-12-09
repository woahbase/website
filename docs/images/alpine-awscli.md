---
description: MultiArch Alpine Linux + S6 + Python3 + AWS-CLI
alpine_branch: v3.22
arches: [aarch64, armhf, armv7l, x86_64]
tags:
  - dev
  - usershell
---

{% import "macros.md" as m with context %}
{% include "shields.md" %}

This [image][155] serves as the base container for applications
/ services that require [aws-cli][4](**v1.x.x**) from the terminal or use
[boto3][7] programmatically using [python][5], includes {{
m.pypipkg('pip') }} and a few tools like [eb-cli][8], for
managing Elastic Beanstalk, and [cfn-lint][9], [cfn-flip][10],
and [sceptre][11] for cloudformation.

{{ m.srcimage('alpine-python3') }} with the {{ m.pypipkg('awscli')
}} and {{ m.pypipkg('awsebcli') }} packages installed in it.

???+ warning "ElasticBeanstalk-CLI in VirtualENV"

    Since April'24, `awsebcli` has been pulling in
    a few dependencies (e.g. Botocore) that are conflicting with
    AWS CLI. Installing them together is causing PIP to be
    `looking at multiple versions of awsebcli to determine which
    version is compatible with other requirements. This could take
    a while.` and then eventually fail. Currently the fix is to
    put `awsebcli` inside a virtualenv and add a wrapper script in
    `/usr/local/bin`. (See {{ m.ghfilelink('Dockerfile') }})

{% include "pull-image.md" %}

---
Run
---

We can call `aws` or `eb` commands directly on the container, or run
`bash` in the container to get a [user-scoped][114] shell,

=== "command"
    ``` sh
    docker run --rm -it \
      --name docker_awscli \
      --workdir /home/alpine \
      -v $PWD:/home/alpine \
    woahbase/alpine-awscli \
      aws --version
    ```
=== "shell"
    ``` sh
    docker run --rm -it \
      --name docker_awscli \
      --workdir /home/alpine \
      -v $PWD:/home/alpine \
    woahbase/alpine-awscli \
      /bin/bash
    ```

--8<-- "multiarch.md"

---
##### Configuration
---

We can customize the runtime behaviour of the container with the
following environment variables.

| ENV Vars                 | Default      | Description
| :---                     | :---         | :---
{% include "envvars/alpine-python3.md" %}
{% include "envvars/alpine-s6.md" %}

--8<-- "check-id.md"

Also, by default, the image expects

* The AWS configuration files live under `/home/alpine/.aws`.

* SSH configurations go under `/home/alpine/.ssh`

[4]: https://aws.amazon.com/cli/
[5]: https://www.python.org/
[7]: https://boto3.readthedocs.io/
[8]: https://github.com/aws/aws-elastic-beanstalk-cli
[9]: https://github.com/aws-cloudformation/cfn-python-lint
[10]: https://github.com/awslabs/aws-cfn-template-flip
[11]: https://github.com/Sceptre/sceptre
[12]: https://github.com/donnemartin/awesome-aws

{% include "all-include.md" %}
