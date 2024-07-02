???+ info "Multi-Arch Support"
    If you want to run images for other architectures on a x86_64 machine, you will need
    to have binfmt support configured for your machine **before** running the image.
    [**multiarch**][104], has made
    it easy for us containing that into a docker container,
    just run

    ``` sh
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    ```

    Now images built for other architectures will also be executable. This is
    optional though, without the above, you can still run the image that is made
    for your architecture.

