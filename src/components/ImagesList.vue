<template>

    <section class="section smallpad">
        <loading-component v-if="compState == 'loading'" msg="Loading Repositories.."/>
        <loading-component v-if="compState == 'repositories'" msg="Loading Docker Hub Info.."/>

        <div v-if="(compState == 'docker') || (compState == 'Xdocker')">
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

                                    <option v-if="compState == 'docker'" disabled selected="true" class="has-text-dark">Docker Hub</option>
                                    <option v-if="compState == 'docker'" value="-repo.docker.last_updated"> &nbsp; &#x2193; Image Pushed</option>
                                    <option v-if="compState == 'docker'" value="+repo.docker.last_updated"> &nbsp; &#x2191; Image Pushed</option>
                                    <option v-if="compState == 'docker'" value="+repo.docker.pull_count"> &nbsp; &#x2193; Image Pulled</option>
                                    <option v-if="compState == 'docker'" value="-repo.docker.pull_count"> &nbsp; &#x2191; Image Pulled</option>
                                    <!-- <option value="&#45;repo.docker.star_count"> &#38;nbsp; &#38;#x2193; Stars</option> -->
                                    <!-- <option value="+repo.docker.star_count"> &#38;nbsp; &#38;#x2191; Stars</option> -->
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <masonry :cols="{default: 4, 1500: 3, 1000: 2, 600: 1}" :gutter="{default: '30px', 1000: '15px', 600 : '10px'}" v-if="repositories.length > 0">
                <div class="card" v-for="(repo, index) in repositories" :key="repo.id" :index="repo.id">
                    <header class="card-header">
                        <p class="card-header-title is-uppercase is-size-5">
                            {{ repo.name.replace('alpine-', '') }}
                        </p>
                        <a :href="nameToLink('travis', orgName, repo.name)" class="card-header-icon" target="_blank">
                            <img :src="nameToLink('travis.svg', orgName, repo.name)" alt="Build Status">
                        </a>
                    </header>
                    <div class="card-content">
                        <div class="content is-size-6">
                            {{ repo.description }}
                        </div>
                    </div>
                    <footer class="card-footer">
                        <a :href="nameToLink('image', orgName, repo.name)"  class="card-footer-item">
                            <icon name="file-text-o" scale="1"/> &nbsp; View ReadMe
                        </a>
                        <div class="dropdown is-right">
                            <div class="dropdown-trigger">
                                <a class="card-footer-item has-text-grey" aria-haspopup="true" aria-controls="dropdown-menu" @click.stop="toggleDropdown('#dropdown-menu-' + repo.id)">
                                    <!-- <span>Links</span> -->
                                    <icon name="ellipsis-v" scale="1.1"/>
                                </a>
                            </div>
                            <div class="dropdown-menu has-text-centered" :id="'dropdown-menu-' + repo.id" role="menu">
                                <div class="dropdown-content">

                                    <a :href="nameToLink('docker', orgName, repo.name)" class="dropdown-item" target="_blank">
                                        <i class="fa fa-docker" style="font-size: 2em; line-height: 0em;vertical-align: middle;"/>
                                        &nbsp; Tags
                                        <span class="block has-text-right" v-if="repo.docker" style="font-size: 0.8em;">
                                            (
                                            <icon name="star" scale="0.8" style="vertical-align: middle;"/>
                                            {{ repo.docker.star_count }}
                                            /
                                            <icon name="cloud-download" scale="0.8" style="vertical-align: middle;"/>
                                            {{ repo.docker.pull_count }}
                                            )
                                            <br/>
                                            , Pushed <timeago :since="repo.docker.last_updated"/>
                                        </span>

                                    </a>

                                    <a :href="nameToLink('github', orgName, repo.name)" class="dropdown-item" target="_blank">
                                        <icon name="github" scale="1.5" style="vertical-align: middle;"/>
                                        &nbsp; Code
                                        <span class="block has-text-right" v-if="repo.docker" style="font-size: 0.8em;">
                                            (
                                            <icon name="star" scale="0.8" style="vertical-align: middle;"/>
                                            {{ repo.stargazers_count }}
                                            /
                                            <icon name="eye" scale="0.8" style="vertical-align: middle;"/>
                                            {{ repo.watchers_count }}
                                            )
                                            <br/>
                                            , Updated <timeago :since="repo.updated_at"/>
                                        </span>
                                    </a>

                                    <!-- <a :href="nameToLink('travis', orgName, repo.name)" class="dropdown&#45;item" target="_blank"> -->
                                        <!--     <icon name="cogs" scale="1.5" style="vertical&#45;align: middle;"/> -->
                                        <!--     &#38;nbsp; Build -->
                                        <!-- </a> -->
                                    <!--  -->
                                    <!-- <a :href="nameToLink('microscaling', orgName, repo.name)" class="dropdown&#45;item" target="_blank"> -->
                                        <!--     <icon name="flag&#45;checkered" scale="1.5" style="vertical&#45;align: middle;"/> -->
                                        <!--     &#38;nbsp; Meta -->
                                        <!-- </a> -->
                                </div>
                            </div>
                        </div>
                    </footer>
                </div>
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

        <div class="content " v-if="compState == 'Xrepositories'">
            Error Loading Repositories.
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
                this.compState = 'docker';
            } else {
                this.compState = 'loading';
                this.$api.github.getOrgRepos(this.orgName).then((response) => {
                    // remove ignore repos straight away
                    let repos = response.data.filter(v => this.$store.state.ignoredRepositories.indexOf(v.name) == -1);

                    this.compState = 'repositories';

                    // update docker info
                    this.$api.docker.getRepositories(this.orgName).then((response) => {
                        // update info
                        response.data.results.forEach((v, i) => {
                            repos.forEach((w, k) => {
                                if(v.name == w.name) {
                                    w.docker = v;
                                }
                            })
                        })

                        // set state
                        this.$store.commit('setRepositories', repos);
                        // this.$store.commit('setDockerInfo', response.data); // not needed anymore

                        this.compState = 'docker';
                    }).catch((err) => {
                        this.$store.commit('setRepositories', repos);
                        this.compState = 'Xdocker';
                    })
                }).catch((err) => {
                    this.compState = 'Xrepositories';
                    console.log( err );
                })
            }
        },
        nameToLink () {
            return this.$api.util.nameToLink(...arguments);
        },
        toggleDropdown (id) {
            this.openDropdown = id;
            let o = document.querySelectorAll(".dropdown-menu.is-active");
            o.length && o.forEach(v => v.classList.remove("is-active"));
            let s = document.querySelector(id);
            s && s.classList.toggle('is-active');
        }
    },
    mounted () {
        this.getOrgRepos();
        document.querySelector('body').addEventListener('click', () => {
            if(this.openDropdown) {
                let s = document.querySelector(this.openDropdown);
                s && s.classList.remove('is-active');
            }
        })
    },
    computed : {
        repositories () {
            return this.$store.state.repositories.sort((a, b) => {
                    return {
                        // '+repo.id' : (a, b) => { return b.id - a.id }, // same as created at
                        // '-repo.id' : (a, b) => { return a.id - b.id },
                        '+repo.created_at' : (a, b) => { return new Date(a.created_at).getTime() - new Date(b.created_at).getTime() },
                        '-repo.created_at' : (a, b) => { return new Date(b.created_at).getTime() - new Date(a.created_at).getTime() },
                        '+repo.updated_at' : (a, b) => { return new Date(a.updated_at).getTime() - new Date(b.updated_at).getTime() },
                        '-repo.updated_at' : (a, b) => { return new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime() },
                        '+repo.pushed_at' : (a, b) => { return new Date(a.pushed_at).getTime() - new Date(b.pushed_at).getTime() },
                        '-repo.pushed_at' : (a, b) => { return new Date(b.pushed_at).getTime() - new Date(a.pushed_at).getTime() },
                        '+repo.stargazers_count' : (a, b) => { return b.stargazers_count - a.stargazers_count },
                        '-repo.stargazers_count' : (a, b) => { return a.stargazers_count - b.stargazers_count },
                        '+repo.watchers_count' : (a, b) => { return b.watchers_count - a.watchers_count },
                        '-repo.watchers_count' : (a, b) => { return a.watchers_count - b.watchers_count },

                        '+repo.docker.last_updated' : (a, b) => { return new Date(a.docker.last_updated).getTime() - new Date(b.docker.last_updated).getTime() },
                        '-repo.docker.last_updated' : (a, b) => { return new Date(b.docker.last_updated).getTime() - new Date(a.docker.last_updated).getTime() },
                        '+repo.docker.pull_count' : (a, b) => { return b.docker.pull_count - a.docker.pull_count },
                        '-repo.docker.pull_count' : (a, b) => { return a.docker.pull_count - b.docker.pull_count },
                        '+repo.docker.star_count' : (a, b) => { return b.docker.star_count - a.docker.star_count },
                        '-repo.docker.star_count' : (a, b) => { return a.docker.star_count - b.docker.star_count },

                    }[this.sort](a, b);
                }).filter(v=> v.name.includes(this.query) || v.description.includes(this.query))
            ;
        }
    },
    components : {
        LoadingComponent
    },
    props : { }
}

</script>

<style scoped>
    .smallpad { padding-top : 0.7em; }

    .card {
        display: inline-block;
        margin: 0.25rem;
        padding: 1rem;
        margin-bottom: 1.5rem;
        width: 100%;
    }

    /* .card-content .content { min-height: 6em; } */

    .card-header-title {
        font-family : "Source Sans Pro", sans-serif;
        letter-spacing : 1px;
    }

    .dropdown-menu.is-active {
        display: block;
        z-index: 9999;
        position:absolute;
    }

    .dropdown-item .fa,.icon {
        vertical-align : middle;
    }

    a.dropdown-item {display: block;}

</style>

