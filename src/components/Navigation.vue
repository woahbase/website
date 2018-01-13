<template>

    <nav class="navbar is-transparent">
        <div class="navbar-brand">
            <a class="navbar-item" href="/">
                <h1 class="logo is-size-2"> <span class="has-text-success">WOAH</span>BASE </h1>
            </a>
            <div class="navbar-burger burger is-hidden-tablet" data-target="burger" @click="toggleSidebar()" :class="{'is-active' : showSidebar}">
                <span></span>
                <span></span>
                <span></span>
            </div>
        </div>

        <div id="burger" class="navbar-menu">
            <!-- <div class="navbar&#45;start"> -->
            <!--     <a class="navbar&#45;item" href="https://bulma.io/"> -->
            <!--         Home -->
            <!--     </a> -->
            <!--     <div class="navbar&#45;item has&#45;dropdown is&#45;hoverable"> -->
            <!--         <a class="navbar&#45;link" href="/documentation/overview/start/"> -->
            <!--             Docs -->
            <!--         </a> -->
            <!--         <div class="navbar&#45;dropdown is&#45;boxed"> -->
            <!--             <a class="navbar&#45;item" href="/documentation/overview/start/"> -->
            <!--                 Overview -->
            <!--             </a> -->
            <!--             <a class="navbar&#45;item" href="https://bulma.io/documentation/modifiers/syntax/"> -->
            <!--                 Modifiers -->
            <!--             </a> -->
            <!--             <a class="navbar&#45;item" href="https://bulma.io/documentation/columns/basics/"> -->
            <!--                 Columns -->
            <!--             </a> -->
            <!--             <a class="navbar&#45;item" href="https://bulma.io/documentation/layout/container/"> -->
            <!--                 Layout -->
            <!--             </a> -->
            <!--             <a class="navbar&#45;item" href="https://bulma.io/documentation/form/general/"> -->
            <!--                 Form -->
            <!--             </a> -->
            <!--             <hr class="navbar&#45;divider"> -->
            <!--             <a class="navbar&#45;item" href="https://bulma.io/documentation/elements/box/"> -->
            <!--                 Elements -->
            <!--             </a> -->
            <!--             <a class="navbar&#45;item is&#45;active" href="https://bulma.io/documentation/components/breadcrumb/"> -->
            <!--                 Components -->
            <!--             </a> -->
            <!--         </div> -->
            <!--     </div> -->
            <!-- </div> -->

            <div class="navbar-end">
                <div class="navbar-item">
                    <div class="field is-grouped">
                        <!-- <p class="control"> -->
                        <!--     <a class="inverted button" href="mailto://write@woahbase.online" title="Get in touch"> -->
                        <!--         <span class="icon"> -->
                        <!--             <icon scale="1.2" name="envelope&#45;o"/> -->
                        <!--         </span> -->
                        <!--         <!&#45;&#45; <span> &#45;&#45;> -->
                        <!--         <!&#45;&#45;     Email &#45;&#45;> -->
                        <!--         <!&#45;&#45; </span> &#45;&#45;> -->
                        <!--     </a> -->
                        <!-- </p> -->
                        <p class="control">
                            <a class="inverted button" target="_blank" href="https://github.com/woahbase" title="Check out our codes">
                                <span class="icon">
                                    <icon scale="1.4" name="github"/>
                                </span>
                                <!-- <span> -->
                                <!--     Github -->
                                <!-- </span> -->
                            </a>
                        </p>
                        <p class="control">
                            <a class="inverted button" target="_blank" href="https://hub.docker.com/u/woahbase/" title="Check out our images">
                                <span class="icon">
                                    <i class="fa fa-docker"/>
                                </span>
                                <!-- <span> -->
                                <!--     Docker -->
                                <!-- </span> -->
                            </a>
                        </p>
                        <p class="control">
                            <a class="inverted is-info button" target="_blank" href="https://twitter.com/woahbase" title="Follow Us!">
                                <span class="icon">
                                    <icon scale="1.3" name="twitter"/>
                                </span>
                                <!-- <span> -->
                                <!--     Twitter -->
                                <!-- </span> -->
                            </a>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </nav>

</template>

<script>

    export default {
        name: 'NavigationComponent',
        computed : {
            showSidebar () {
                return this.$store.state.showSidebar;
            }
        },
        data () {
            return { }
        },
        methods : {
            toggleSidebar () {
                this.$store.commit('toggleSidebar');
            },
        },
        props : { }
    }

</script>

<style scoped>
    a.button {
        border-radius : 30px;
        font-size: 1.7rem;
        height: 1.6em;
        padding: 0 0.45em;
    }
</style>

