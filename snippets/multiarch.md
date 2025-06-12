??? info "Multi-Arch Support"

    If you want to run images for other architectures on a x86_64
    machine, you will need to have the specific binary format
    support configured on your host machine **before** running the
    image (otherwise you get an `exec format error`). Here's how,

    === "binfmt"

        For recent images, we can use [**tonistiigi**][108]'s
        `binfmt` [image][109] to register binary execution support
        for the target architecture, like the following,

        ``` sh
        docker run --rm --privileged tonistiigi/binfmt --install <architecture>
        ```

        Architecture is that of the image we're trying to run, can
        be `arm64` for `aarch64`, `arm` for both `armv7l` and
        `armhf`, or `amd64` for `x86_64`.

    === "qemu-user-static"

        Previously, [**multiarch**][105], had made it easy for us
        containing `qemu` into an [image][104], so we could just
        run

        ``` sh
        docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
        ```

        However, that images seems to have fallen behind in
        updates, and with newer images the `binfmt` method is
        preferable.

    Now images built for other architectures will also be executable. This is
    optional though, without the above, you can still run the image that is made
    for your architecture.

