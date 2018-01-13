<template>

    <section class="section smallpad">
        <div class="">
            <loading-component v-if="compState == 'loading'" msg="Loading ReadMe.."/>
            <loading-component v-if="compState == 'readme'" msg="Parsing HTML.."/>

            <div class="content markdown-html" v-html="readmeHtml" v-if="compState == 'html'">
            </div>
            <div class="content markdown-html" v-if="compState == 'Xreadme'">
                Error Loading ReadMe from Github.
            </div>
            <div class="content markdown-html" v-if="compState == 'Xhtml'">
                Error parsing ReadMe HTML.
            </div>
        </div>
    </section>

</template>

<script>

    // import '@/assets/css/markdown.css'; // markdown css
    import LoadingComponent from '@/components/Loader';

    export default {
        name: 'ImagesDetailComponent',
        components : {
            LoadingComponent
        },
        data () {
            return {
                orgName : this.$store.state.orgName,
                readmeHtml : "",
                compState : '',
            }
        },
        methods : {
            renderReadMe (org, repo) {
                this.compState = 'loading';
                if(!repo) return;

                // check if already cached, then load from cache
                let s = this.$store.state.repositories.filter(v => v.name == repo && v.readMe && v.readMe.html);
                if(s.length) {
                    this.compState = 'html';
                    this.readmeHtml = s[0].readMe.html;
                } else { // load and update cache
                    this.$api.github.getReadMe(org, repo).then((response1) => {
                        this.compState = 'readme';
                        this.$store.commit('setReadMe', { name : repo, readMe : response1.data });
                        this.$api.github.mdToHtml(atob(response1.data.content), 'gfm', org + "/" + repo).then((response2) => {
                            this.compState = 'html';
                            this.$store.commit('setReadMeHtml', { name : repo, html : response2.data });
                            this.readmeHtml = response2.data;
                        }).catch((err) => {
                            this.compState = 'Xhtml';
                            console.log( err );
                        })
                    }).catch((err) => {
                        this.compState = 'Xreadme';
                        console.log( err );
                    })
                }
            },
        },
        mounted () {
            // this.$api.travis.getRepositories(this.orgName).then((response) => {
            //     console.log( response );
            // });                                                                       ;
            // this.$api.microscaling.getRepositoryDetail(this.orgName, this.repository).then((response) => {
            //     console.log( response );
            // });
            if(this.repository) {
                this.renderReadMe(this.orgName, this.repository);
            } else {
                this.$router.push({ path: "/"});
            }
        },
        props : [
            'repository',
        ]
    }

</script>

<style >
    .smallpad { padding-top : 0.7em; }
    .markdown-html h2 {
        font-family : "Source Sans Pro", sans-serif;
        letter-spacing : 1px;
        font-size: 2.5rem !important;
        text-transform : uppercase !important;
        font-weight : 300 !important;
        margin : 0 !important;
        padding : 0 !important;
    }
    .markdown-html h4 { font-weight : 600 !important; }
    .markdown-html hr,pre { margin-right : 2vw !important; }

</style>


