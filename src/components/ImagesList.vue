<template>

    <section class="section smallpad">
        <loading-component v-if="compState == 'loading'" msg="Loading Repositories.."/>
        <!-- <loading&#45;component v&#45;if="compState == 'repositories'" msg="Loading Docker Hub Info.."/> -->

        <div v-if="(compState == 'repositories')">
            <div class="columns is-mobile">
                <div class="column is-four-fifths-tablet">
					<div class="search-box field">
						<!-- <label class="label">Search</label> -->
						<div class="control has-icons-left has-icons-right">
							<input class="input" type="text" placeholder="Type to filter images" v-model="query" onclick="this.select()">
							<span class="icon is-small is-left">
								<icon name="search"/>
							</span>
							<!-- <span class="icon is&#45;small is&#45;right" v&#45;if="query"> -->
							<!-- 	<icon name="times"/> -->
							<!-- </span> -->
						</div>
					</div>
                </div>
                <div class="column is-one-fifth-tablet is-one-third-mobile has-text-right">
                    <div class="field">
                        <!-- <label class="label">Sort</label> -->
                        <div class="">
                            <div class="select">
                                <select v-model="sort" class="has-text-grey">

                                    <option disabled selected="true" class="has-text-dark">Github</option>
                                    <option value="-repo.created_at"> &nbsp; &#x2193; Repo Created</option>
                                    <option value="+repo.created_at"> &nbsp; &#x2191; Repo Created</option>
                                    <!-- <option value="&#45;repo.updated_at"> &#38;nbsp; &#38;#x2193; Last Updated</option> -->
                                    <!-- <option value="+repo.updated_at"> &#38;nbsp; &#38;#x2191; Last Updated</option> -->
                                    <option value="-repo.pushed_at"> &nbsp; &#x2193; Last Pushed</option>
                                    <option value="+repo.pushed_at"> &nbsp; &#x2191; Last Pushed</option>
                                    <!-- <option value="&#45;repo.stargazers_count"> &#38;nbsp; &#38;#x2193; Stars</option> -->
                                    <!-- <option value="+repo.stargazers_count"> &#38;nbsp; &#38;#x2191; Stars</option> -->
                                    <!-- <option value="&#45;repo.watchers_count"> &#38;nbsp; &#38;#x2193; Watchers</option> -->
                                    <!-- <option value="+repo.watchers_count"> &#38;nbsp; &#38;#x2191; Watchers</option> -->

                                    <option disabled selected="true" class="has-text-dark">Docker Hub</option>
                                    <option value="-repo.docker.last_updated"> &nbsp; &#x2193; Image Pushed</option>
                                    <option value="+repo.docker.last_updated"> &nbsp; &#x2191; Image Pushed</option>
                                    <option value="+repo.docker.pull_count"> &nbsp; &#x2193; Image Pulled</option>
                                    <option value="-repo.docker.pull_count"> &nbsp; &#x2191; Image Pulled</option>
                                    <!-- <option value="&#45;repo.docker.star_count"> &#38;nbsp; &#38;#x2193; Stars</option> -->
                                    <!-- <option value="+repo.docker.star_count"> &#38;nbsp; &#38;#x2191; Stars</option> -->
                                    <option value="+repo.image.size"> &nbsp; &#x2193; Image Size</option>
                                    <option value="-repo.image.size"> &nbsp; &#x2191; Image Size</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <masonry :cols="{default: 4, 1500: 3, 1000: 2, 600: 1}" :gutter="{default: '30px', 1000: '15px', 600 : '10px'}" v-if="repositories.length > 0">
                <image-component class="card" v-for="(repo, index) in repositories" :key="repo.id" :index="repo.id" :repo="repo">
                </image-component>
            </masonry>

            <div class="content has-text-centered" v-if="repositories.length == 0">
				<br/>
				<h1 class="is-size-2">Something went wrong. <span class="has-text-danger">:(</span></h1>
				<br/>
				<p>
				</p>
				<br/>

				<p>
					Looks like there were no repositories to display.
				</p>

				<p>
					Try reverting the search or filter parameters above if you've changed any, <br/>
					or <span class="has-text-danger">reload the page</span>.
				</p>

            </div>

        </div>

        <div class="content has-text-centered" v-if="compState == 'Xrepositories'">
				<br/>
				<h1 class="is-size-2">Something went wrong. <span class="has-text-danger">:(</span></h1>
				<br/>
				<p>
				</p>
				<br/>

				<p>
					Looks like there were no repositories to display.
				</p>

				<p>
					Try reverting the search or filter parameters above if you've changed any, <br/>
					or <span class="has-text-danger">reload the page</span>.
				</p>
        </div>
    </section>

</template>

<script>

    import Vue from 'vue'
import VueMasonry from 'vue-masonry-css'
Vue.use(VueMasonry);

import VueTimeago from 'vue-timeago'

Vue.use(VueTimeago, {
    name: 'timeago', // component name, `timeago` by default
    locale: 'en-US',
    locales: {
        // you will need json-loader in webpack 1
        'en-US': require('vue-timeago/locales/en-US.json')
    }
})

import LoadingComponent from '@/components/Loader';
import ImageComponent from '@/components/Image';

export default {
    name: 'ImagesListComponent',
    data () {
        return {
            compState : '',
            openDropdown : '',
            orgName : this.$store.state.orgName,
            query : '',
            sort : '-repo.created_at'
        }
    },
    methods : {
        getOrgRepos () {
            if(this.repositories.length > 0)  { // load from cache if already fetched
                this.compState = 'repositories';
            } else {
                this.compState = 'loading';

                this.$api.scraped.getSiteJson().then((response) => {
                    console.log( response.data );

                    // remove ignore repos straight away // not actually needed but for consistency
                    let repos = response.data.filter(v => this.$store.state.ignoredRepositories.indexOf(v.name) == -1);

                    // set state
                    this.$store.commit('setRepositories', repos);
                    // this.$store.commit('setDockerInfo', response.data); // not needed anymore

                    this.compState = 'repositories';

                }).catch((err) => {
                    console.log( err );
                    this.compState = 'Xrepositories';
                });
            }
        },
    },
    mounted () {
        this.getOrgRepos();
    },
    computed : {
        repositories () {
            return this.$store.state.repositories.sort((a, b) => {
                    return {
                        // '+repo.id' : (a, b) => { return b.id - a.id }, // same as created at
                        // '-repo.id' : (a, b) => { return a.id - b.id },
                        '+repo.created_at' : (a, b) => { return new Date(a.github.created_at).getTime() - new Date(b.github.created_at).getTime() },
                        '-repo.created_at' : (a, b) => { return new Date(b.github.created_at).getTime() - new Date(a.github.created_at).getTime() },
                        '+repo.updated_at' : (a, b) => { return new Date(a.github.updated_at).getTime() - new Date(b.github.updated_at).getTime() },
                        '-repo.updated_at' : (a, b) => { return new Date(b.github.updated_at).getTime() - new Date(a.github.updated_at).getTime() },
                        '+repo.pushed_at' : (a, b) => { return new Date(a.github.pushed_at).getTime() - new Date(b.github.pushed_at).getTime() },
                        '-repo.pushed_at' : (a, b) => { return new Date(b.github.pushed_at).getTime() - new Date(a.github.pushed_at).getTime() },
                        '+repo.stargazers_count' : (a, b) => { return b.github.stargazers_count - a.github.stargazers_count },
                        '-repo.stargazers_count' : (a, b) => { return a.github.stargazers_count - b.github.stargazers_count },
                        '+repo.watchers_count' : (a, b) => { return b.github.watchers_count - a.github.watchers_count },
                        '-repo.watchers_count' : (a, b) => { return a.github.watchers_count - b.github.watchers_count },

                        '+repo.docker.last_updated' : (a, b) => { return new Date(a.dockerhub.last_updated).getTime() - new Date(b.dockerhub.last_updated).getTime() },
                        '-repo.docker.last_updated' : (a, b) => { return new Date(b.dockerhub.last_updated).getTime() - new Date(a.dockerhub.last_updated).getTime() },
                        '+repo.docker.pull_count' : (a, b) => { return b.dockerhub.pull_count - a.dockerhub.pull_count },
                        '-repo.docker.pull_count' : (a, b) => { return a.dockerhub.pull_count - b.dockerhub.pull_count },
                        '+repo.docker.star_count' : (a, b) => { return b.dockerhub.star_count - a.dockerhub.star_count },
                        '-repo.docker.star_count' : (a, b) => { return a.dockerhub.star_count - b.dockerhub.star_count },

                        '+repo.image.size' : (a, b) => { return b.microbadger.DownloadSize - a.microbadger.DownloadSize },
                        '-repo.image.size' : (a, b) => { return a.microbadger.DownloadSize - b.microbadger.DownloadSize },
                    }[this.sort](a, b);
            }).filter(v=>
                v.name.includes(this.query)
                ||
                v.github.description.includes(this.query)
                ||
                v.tags.filter(x => x.tag.includes(this.query)).length
            )
            ;
        }
    },
    components : {
        LoadingComponent,
        ImageComponent
    },
    props : { }
}

</script>

<style scoped>
    .smallpad { padding-top : 0.7em; }

</style>

