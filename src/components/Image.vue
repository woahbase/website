<template>
    <div class="card" >
        <header class="card-header">
            <a :href="nameToLink('image', orgName, repo.github.name)" class="card-header-title is-uppercase is-size-5">
                {{ repo.name.replace('alpine-', '') }}
            </a>
            <a :href="nameToLink('travis', orgName, repo.github.name)" class="card-header-icon" target="_blank">
                <img :src="nameToLink('travis.svg', orgName, repo.github.name)" alt="Build Status">
            </a>
        </header>
        <div class="card-content">
            <div class="content is-size-6">
                {{ repo.github.description }}
            </div>
            <div class="level is-mobile">
                <div class="has-text-center" :class="index %2 == 0 ? 'level-left' : 'level-right'" v-for="(tag, index) in repo.tags" :key="tag.tag" :index="index" v-if="tag.tag != 'latest'">
                    <div class="" v-if="index < 3">
                        <p class="title is-size-6 has-text-grey-dark">
                            <icon name="tag" scale="1" style="vertical-align : middle" class="has-text-grey-light"/>
                            <span>
                                {{ tag.tag.toUpperCase() }}
                            </span>
                        </p>
                        <p class="heading">
                            &nbsp;
                            &nbsp;
                            {{ tag.LayerCount }} layers
                        </p>
                        <p class="heading">
                            &nbsp;
                            &nbsp;
                            <span v-if="tag.DownloadSize">
                                {{ (tag.DownloadSize / (1024*1024)).toFixed(2) }} MB
                            </span>
                            <span v-if="!tag.DownloadSize">
                                &nbsp;
                            </span>

                        </p>
                    </div>
                </div>
            </div>

        </div>
        <footer class="card-footer">
            <a :href="nameToLink('image', orgName, repo.github.name)"  class="card-footer-item ">
                <icon name="file-text-o" scale="1"/> &nbsp; View README
            </a>
            <div class="dropdown is-right">
                <div class="dropdown-trigger">
                    <a class="card-footer-item has-text-grey" aria-haspopup="true" aria-controls="dropdown-menu" @click.stop="toggleDropdown('#dropdown-menu-' + repo.github.id + '-' + repo.name)">
                        <!-- <span>Links</span> -->
                        <icon name="ellipsis-v" scale="1.1"/>
                    </a>
                </div>
                <div class="dropdown-menu has-text-centered" :id="'dropdown-menu-' + repo.github.id + '-' + repo.name" role="menu">
                    <div class="dropdown-content">

                        <a :href="nameToLink('docker', orgName, repo.name)" class="dropdown-item" target="_blank">
                            <i class="fa fa-docker" style="font-size: 2em; line-height: 0em;vertical-align: middle;"/>
                            Image
                            <span class="block has-text-right" v-if="repo.dockerhub" style="font-size: 0.8em;">
                                (
                                <icon name="star" scale="0.8" style="vertical-align: middle;"/>
                                {{ repo.dockerhub.star_count }}
                                /
                                <icon name="cloud-download" scale="0.8" style="vertical-align: middle;"/>
                                {{ repo.dockerhub.pull_count }}
                                )
                                <br/>
                                , Pushed <timeago :since="repo.dockerhub.last_updated"/>
                            </span>

                        </a>

                        <a :href="nameToLink('github', orgName, repo.github.name)" class="dropdown-item" target="_blank">
                            <icon name="github" scale="1.5" style="vertical-align: middle;"/>
                            &nbsp;&nbsp;&nbsp; Code
                            <span class="block has-text-right" v-if="repo.github" style="font-size: 0.8em;">
                                (
                                <icon name="star" scale="0.8" style="vertical-align: middle;"/>
                                {{ repo.github.stargazers_count }}
                                /
                                <icon name="eye" scale="0.8" style="vertical-align: middle;"/>
                                {{ repo.github.watchers_count }}
                                )
                                <br/>
                                , Updated <timeago :since="repo.github.updated_at"/>
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
</template>

<script>
    export default  {
        name : "ImageComponent",
        data () {
            return {
                orgName : this.$store.state.orgName,
                openDropdown : "",
            }
        },
        methods : {
            nameToLink () {
                return this.$api.util.nameToLink(...arguments);
            },
            toggleDropdown (id) {
                this.openDropdown = id;
                let o = document.querySelectorAll(".dropdown-menu.is-active");
                o.length && o.forEach(v => v.classList.remove("is-active"));
                let s = document.querySelector(id);
                s && s.classList.toggle('is-active');
            },
            sortTags(tags) {
                tags.sort((a,b) => a.tag < b.tag);
            }
        },
        props : [
            "repo"
        ],
        mounted () {
            this.sortTags(this.repo.tags);
            document.querySelector('body').addEventListener('click', () => {
                if(this.openDropdown) {
                    let s = document.querySelector(this.openDropdown);
                    s && s.classList.remove('is-active');
                }
            })
        },
    }

</script>

<style scoped>
    .card {
        display: inline-block;
        margin: 0.25rem;
        padding: 1rem;
        margin-bottom: 1.5rem;
        width: 100%;
    }

    .card-content .content { min-height: 3em; }
    .card-content .content { margin-bottom: 0.8rem; }

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

    .title {
        font-size: 0.9rem;
        margin-bottom : 0;
        font-weight : 400;
        font-family : "Source Sans Pro", sans-serif;
    }
    .heading { font-size: 0.6rem; margin-bottom: 0; }


    .card-footer-item {
        font-family : "Source Sans Pro", sans-serif;
    }
</style>

