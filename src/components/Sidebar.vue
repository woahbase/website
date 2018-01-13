<template>
    <aside class="menu app-sidebar animated is-hidden-mobile" :class="{ 'slideInLeft': show, 'slideOutLeft': !show  }">
        <p class="menu-label has-text-grey-dark">
            What does it mean?
        </p>
        <ul class="menu-list has-text-grey">
            <span>Both of the following,</span>
            <li>
                <ul>
                    <li>
                        <span>
                            (The Base) where only Awesome happens.
                        </span>
                    </li>
                    <li>
                        <span>
                            Works only at Home(Base).
                        </span>
                    </li>
                </ul>
            </li>
        </ul>
        <p class="menu-label has-text-grey-dark">
            Look Around
        </p>
        <ul class="menu-list">
            <li>
                <a href="#/" :class="{ 'route-active' : (currentRoute == 'Landing' || currentRoute == 'Images') }" @click="toggleSidebar()">
                    <span class="icon">
                        <icon name="cubes" scale="1.3"/>
                    </span>
                    &nbsp;
                    Images <sup style="font-size:0.6em" v-if="totalImages > 0">({{ totalImages }})</sup>
                </a>
            </li>
            <li>
                <a href="#/about" :class="{ 'route-active' : (currentRoute == 'About') }" @click="toggleSidebar()">
                    <span class="icon">
                        <icon name="info-circle" scale="1.3"/>
                    </span>
                    &nbsp;
                    About
                </a>
            </li>
            <li>
                <a href="#/contact" :class="{ 'route-active' : (currentRoute == 'Contact') }" @click="toggleSidebar()">
                    <span class="icon">
                        <icon name="comments-o" scale="1.3"/>
                    </span>
                    &nbsp;
                    Contact
                </a>
            </li>
        </ul>
        <p class="menu-label has-text-grey-dark">
            In short
        </p>
        <ul class="menu-list">
            <li>
                <span class="has-text-left has-text-grey">
                    Been containerizing dev-envs and workflows into docker images for a while now. About time its FOSS-ed out so everybody can benefit from them.
                    <br/>
                    <br/>
                    Feel free to use/tinker with them, give us a shoutout if you're building something cool with it.
                    <!-- <br/> -->
                    <!-- <br/> -->
                    <!-- If you enjoy containerizing/configuring software, come hang with us at #woahbase on Freenode. -->
                </span>
            </li>
        </ul>
    </aside>
</template>
<script>
    export default {
        name: 'SidebarComponent',
        components : { },
        data () {
            return { }
        },
        methods : {
            toggleSidebar () {
                this.$store.commit('toggleSidebar');
            },
        },
        computed : {
            currentRoute () {
                return this.$route.name;
            },
            show () {
                return this.$store.state.showSidebar;
            },
            totalImages () {
                return this.$store.state.repositories.length;
            },
        },
        props : {
        }
    }
</script>
<style scoped>
    .app-sidebar { padding-left: 1.5em; padding-right: 1.5em; min-width: 17em; }
    .menu-list span { padding-left : 0.5em; margin-bottom: 0.4em; display: inline-block }
    .menu-list a { font-size: 1.3em; }
    span.icon { margin-bottom: 0; height: auto; }
    .slideInLeft { display: block !important; }
    .route-active { border-right: 5px solid #23d160;}
</style>
