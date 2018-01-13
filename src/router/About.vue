<template>
    <div class="">
        <navigation-component/>
        <div class="columns is-tablet">
            <sidebar-component class="column is-2 "/>
            <div class="column is-8">
                <section class="smallpad">
                    <div class="">
                        <div class="content">
                            <h1 class="is-size-1">
                                Hello World!
                            </h1>
                            <h2>
                                It's WOAHBase - a "thing" born of repetitive frustration.
                            </h2>
                            <p>
                                We're all familiar with the woes of trying to set up
                                our machine <strong>just</strong> as we like it.
                                But installing / configuring
                                / updating and cleaning up seems
                                to entail too much work sometimes.
                                Even with automation, you still
                                have to monitor it, and react to
                                its hiccups.
                            </p>
                            <blockquote>
                                Enter <span class="is-size-4 has-text-info">
                                    Docker
                                </span>
                                .
                            </blockquote>
                            <p>
                                Docker containerizes all important
                                processes neatly into separate
                                layered images. Is quite well
                                portable as we're moving whole OS
                                images. Running is a breeze as
                                long as its configured properly at
                                runtime. Still, image size becomes
                                an issue sometimes.
                            </p>
                            <blockquote>
                                Enter <span class="is-size-4 has-text-info">
                                    Alpine Linux
                                </span>
                                .
                            </blockquote>
                            <p>
                                Now we have smaller images, the
                                mini-rootfs is about 5mb, its
                                blazing fast and pretty secure,
                                deploying and going live in
                                seconds.  So, what seems to be the
                                issue now?
                            </p>
                            <p>
                                After a while, you end up with
                                <span class="is-size-4">
                                    a
                                    bunch
                                </span>
                                of those images.
                                To the point it becomes tedious
                                for one person to build/maintain
                                them.
                            </p>
                            <blockquote>
                                Here came in <span class="is-size-4 has-text-info">
                                    Travis.CI
                                </span>
                                .
                            </blockquote>
                            <p>
                                They allow building Open-Source
                                Projects with their spare
                                buildpower. How cool is that?  Now
                                all our base images can build
                                there, only the special sauce
                                needed, we can add it on the fly
                                or customize it before running.
                                <br/>
                                Thank you <strong class="has-text-success">
                                    Mr. Travis
                                </strong>
                                .
                            </p>
                            <p>  Thus, from the locally hosted repositories,
                            </p>

                            <blockquote>
                                The code went to live at <span class="is-size-4 has-text-info">
                                    Github
                                </span>
                                .
                            </blockquote>
                            <p>
                                And, <span class="is-size-4">
                                    WOAHBase
                                </span>
                                was assimilated.
                                <br/>
                                More to come soon.
                            </p>
                        </div>
                    </div>
                </section>
            </div>
            <div class="column is-2">
                <section class="smallpad">
                    <div>
                        <div class="content">
                        </div>
                    </div>
                </section>
            </div>
        </div>
        <footer-component class="footer"/>
    </div>
</template>
<script>
    import NavigationComponent from '@/components/Navigation.vue';
import SidebarComponent from '@/components/Sidebar.vue';
import FooterComponent from '@/components/Footer.vue';
export default {
    name: 'AboutRoute',
    components : {
        NavigationComponent,
        SidebarComponent,
        FooterComponent
    },
    data () {
        return { }
    },
}
</script>
<style scoped>
    .smallpad { padding: 0 5vw; padding-top : 0.7em; }
    blockquote { text-align : center; }
</style>
