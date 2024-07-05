??? info "Docker X.Org-Access"

    If docker is not allowed to access the local X-server running
    on the host, make sure `DISPLAY` is set to the **correct** monitor
    and exported, e.g.

    ``` sh
    export DISPLAY=:0
    ```

    Also, we might need to run [xhost](https://linux.die.net/man/1/xhost)

    ``` sh
    xhost +local:docker
    ```

    before starting the container to ensure the `docker` user can use
    the display.
