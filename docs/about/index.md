# Hello World!

#### What is it?

It's **WOAHBase**,  a "thing" born of repetitive frustration.
Stands for both

* <b>W</b>here <b>O</b>nly <b>A</b>wesome <b>H</b>appens ~ Base

* <b>W</b>orks <b>O</b>nly <b>A</b>t <b>H</b>ome ~ Base


#### Cool, but like, Why is it?

In short, I'm always interested in the open-source and
self-hosting my own services, and been containerizing dev-envs and
workflows into docker images for a few years now. About time it is
FOSS-ed out so everybody can benefit from them.

Feel free to use/tinker/break/fix any of the images, get in touch
if you're looking to contribute time, if you're building something
awesome and the images (or code) have saved your time, consider
giving a shoutout.

??? info "The Long Story"
    Oh boy! I do hope you got time to read this wall of text.

    ##### The Problem

    We're all familiar with the woes of trying to set up our
    machine just as we like it. But installing / configuring
    / updating and cleaning up seems to entail too much work
    sometimes. Even with automation, you still have to monitor it,
    and react to its hiccups. And when you get on to my level
    *(please don't, as of 2022, homebase is running 50+ containers
    on multiple and multi-arch devices)*, sometimes it does seem
    too big to sink a tooth in. So circa June'17 I went looking
    for reproducibility, semi-permeable mutability but most of
    all, redundancy and reliability.

    ##### Enter Docker.

    Docker containerizes all important processes neatly into
    separate layered images. Is quite well portable as we're
    moving whole OS images. Running is a breeze as long as its
    configured properly at runtime. Still, image size becomes an
    issue sometimes.

    ##### Enter Alpine Linux.

    Now we have smaller images, the mini-rootfs is about 5mb, its
    blazing fast and pretty secure, deploying and going live in
    seconds. So, what seems to be the issue now?

    After a while, you end up with a bunch of those images. To the
    point it becomes tedious for one person to build/maintain
    them.

    ##### There was Travis.CI(.org)

    They allow building Open-Source Projects with their spare
    buildpower. How cool is that? Now all our base images can
    build there, only the special sauce needed, we can add it on
    the fly or customize it before running.

    *Thank you Mr. Travis. :)*

    Thus, from the locally hosted repositories, The code went to
    live at Github. And,

    ##### WOAHBase was assimilated.

    And it was all fine and dandy at my homebase. Things seemed to
    work good for a while, no issues too hard to handle. But then,
    the **dark** times started around Dec'19. Travis announced the
    end of builds for free on April 1, 2020. It's cool though, it
    was too good to last anyway, and pretty fun while it did.

    ##### Going Dark

    By the time the builds stopped, I already had a somewhat
    convoluted-but-works-well buildbot setup going for me, mainly
    used for small tasks, daily backup or other periodic jobs. So
    I moved all the builds right there, running on a i5/32G Intel
    NUC. Keep in mind though, I'm just one guy, no close to
    Travis.CI, so as I got busy with other stuff in my life, the
    update frequency soon fell to zero, and after Docker Hub
    announced they were going to put a limit to their pulls,
    setting up my private registry seemed the best way to go.
    I already had my own private git repository that goes back to
    2012. So eventually, this tiny part of Github/DockerHub called
    WOAHBase kind of became deserted.

    ##### Back to the Light

    So that's how it was for a few years, all-the-while I was
    feeling kind of an itch inside that I'm only building these
    images for myself, but running maintenance for the whole site
    along with 80+ images seemed like a mountain-size chore. Since
    about Q1/Q2-2024, I success(?)fully guilt-tripped myself into
    deciding that a change was due. And now that I'm considering
    job-hunting again, I could finally allocate the time to
    freshen up the the whole project. In the end,

    Everything that follows, is a result of what you see here.
    Thank you for your attention.

#### Why not use Service-X for free automated builds?

Took a lesson from Travis.CI, and stopped mooching off of others'
spare CPU power. My buildbot works fine, and albeit slow, I'd
rather have something dependable that I can configure once, then
just pay for to upgrade and handle heavier loads in future,
compared to dealing with the headache of moving ~100 builds onto
different platforms every few months just because it *was* free
(only in monetary value) before, and is not anymore.

I keep dreaming about having enough spare cash someday to run
a semi-public-yet-isolated build cluster that can handle *all
these jobs*, but until then, there is nothing stopping anybody
from forking an image-builder and setting it up to build under
their own responsibility. And if you *do* end up doing that, let
me know, I *might* link it in the docs. ;)
