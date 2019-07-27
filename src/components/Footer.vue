<template>
    <footer class="footer">
        <div class="has-text-centered footer-logo" @click.stop="scrollToTop()" title="To the Top!">
            <span>
                <img src="/static/images/logo.png" alt="">
            </span>
        </div>
        <br/>
        <br/>

        <div class="columns has-text-grey-dark">
            <div class="column">
                <div class="content has-text-left has-text-centered-tablet">
                    <small class="footer-head">
                        This Website
                    </small>
                    <p>
                        Uses <a href="https://github.com/">
                            Github.
                        </a>
                        <br/>
                        Build and Hosting by <a href="https://www.netlify.com/">
                            Netlify
                        </a>
                        .
                        <br/>
                        Delivery and SSL by <a href="https://www.cloudflare.com">
                            Clouldflare
                        </a>
                        .
                    </p>
                </div>
            </div>
            <div class="column">
                <div class="content has-text-centered">
                    <small class="footer-head">
                        How it's made
                    </small>
                    <p>
                        Crafted with <icon name="heart" class="has-text-danger"/>
                        using,
                        <a href="https://vuejs.org/">
                            VueJS
                        </a>
                        +
                        <a href="https://vuex.vuejs.org/en/">
                            Vuex
                        </a>
                        .
                        <br/>
                        Styled with
                        <a href="https://bulma.io/">
                            Bulma
                        </a>
                        .
                        <br/>
                        Font-icons by
                        <a href="http://fontawesome.io">
                            Font-Awesome
                        </a>
                        .
                    </p>
                </div>
            </div>
            <div class="column">
                <div class="content has-text-right">
                    <small class="footer-head">
                        Copyleft
                    </small>
                    <p>
                        <a href="https://twitter.com/woahbase">
                            <strong>
                                @WOAHBase
                            </strong>
                        </a>

                        ~ Where only awesome happens
                        <br/>
                        ~ Works only at Home
                        <!-- by <a href="">
                            -->
                            <!--
                        </a>
                        -->
                        <!-- . The source code is licensed -->
                        <!-- <a href="http://opensource.org/licenses/mit&#45;license.php">
                            -->
                            <!--     MIT -->
                            <!--
                        </a>
                        -->
                        <!-- . The website content -->
                        <!-- is licensed <a href="http://creativecommons.org/licenses/by&#45;nc&#45;sa/4.0/">
                            -->
                            <!--     CC BY NC SA 4.0 -->
                            <!--
                        </a>
                        -->
                        <br/>
                        &copy; 2018 — now.
                    </p>
                </div>
            </div>
        </div>
        <div class="columns is-hidden-desktop is-mobile has-text-centered has-bg-dark">
            <div class="column">
            </div>
            <div class="column">
                <div class="columns is-mobile">
                    <div class="column">
                        <a target="_blank" href="https://github.com/woahbase" title="Check out our codes">
                            <span class="icon">
                                <icon name="github" scale="3"/>
                            </span>
                            &nbsp;
                        </a>
                    </div>
                    <div class="column">
                        <a target="_blank" href="https://hub.docker.com/u/woahbase/" title="Check out our images">
                            <span class="icon">
                                <i class="fa fa-docker" style="font-size: 2em;"/>
                            </span>
                            &nbsp;
                        </a>
                    </div>
                    <div class="column">
                        <a target="_blank" href="https://twitter.com/woahbase" title="Follow Us!">
                            <span class="icon">
                                <icon name="twitter" scale="3"/>
                            </span>
                            &nbsp;
                        </a>
                    </div>
                </div>

            </div>
            <div class="column">
            </div>
        </div>

    </footer>
</template>
<script>
    export default {
        name: 'FooterComponent',
        data () {
            return { }
        },
        methods : {
            scrollToTop () {
                this.$ga.event('click', 'footer', 'scroll-to-top', 0);
                document.body.scrollTop = 0; // For Safari
                document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
            }
        },
    }
</script>
<style scoped>
    .footer { padding-bottom : 2rem;
        font-family: 'Source Sans Pro', sans-serif;
        font-weight: 400;
        margin-top: 40px;
    }

    .footer-logo { margin-top: -71px;}
    .footer-logo span { padding: 24px 12px; background: #fff; border-radius: 40px; box-shadow: 0px 10px 8px -7px rgba(0,0,0,0.2);}
    .footer-logo span img { height:45px; padding: 5px; vertical-align: middle; pointer-events: none;  }

    small {
        font-size : 0.7rem;
        text-transform: uppercase;
    }
</style>
