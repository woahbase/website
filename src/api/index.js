import Vue from 'vue'

import axios from 'axios'
import VueAxios from 'vue-axios'

Vue.use(VueAxios, axios)

export default {
    name : "api",
    install (Vue, options) {
        const api = Vue.api = Vue.prototype.$api = {
            // docker : {
            //     getRepositories (org) {
            //         const orgReposUrl = api.util.nameToLink('-.docker.org', org);
            //         return Vue.axios.get(orgReposUrl);
            //     }
            // },
            formspree : {
                send (receiverEmail, senderEmail, subject, message) {
                    const fsUrl = api.util.nameToLink('formspree', receiverEmail);
	                return Vue.axios.post(fsUrl, {
                        _message : message,
                        _replyTo : senderEmail,
                        _subject : subject,
	                }, {
	                    headers: {
	                        "Accept" : "application/json"
	                    }
	                });
                }
            },
            github : {
                // getOrgRepos(org) {
                //     const orgReposUrl = api.util.nameToLink('-.github.org.repos', org);
                //     return Vue.axios.get(orgReposUrl);
                // },
                getReadMe (org, repo) {
                    const readmeUrl = api.util.nameToLink('github.readme', org, repo);
                    return Vue.axios.get(readmeUrl);
                },
                mdToHtml (text, mode, context) {
                    const markdownPreviewUrl = api.util.nameToLink('github.mdpreview');
                    return Vue.axios.post(markdownPreviewUrl, {
                        text    : text,
                        mode    : mode || 'gfm',
                        context : context
                    }, {
                        headers            : {
                            'Accept'       : 'text/html',
                            'Content-Type' : 'text/html',
                        }
                    });
                }
            },
            // microscaling : {
            //     getRepositoryDetail (org, name) {
            //         const orgReposUrl = api.util.nameToLink('microscaling', org, name);
            //         return Vue.axios.get(orgReposUrl, {
            //             headers                  : {
            //                 "Accept"                        : "application/json",
            //                 "Access-Control-Allow-Headers"  : "true",
            //                 "Access-Control-Allow-Origin"   : "*",
            //                 "Content-Type"                  : "application/json",
            //                 'X-Requested-With'              : 'XMLHttpRequest',
            //             },
            //             withCredentials : true,
            //         });
            //     }
            // },
            scraped : {
                getSiteJson () {
                    const orgReposUrl = api.util.nameToLink('-.scraped.site');
                    return Vue.axios.get(orgReposUrl);
                }
            },
            // travis : {
            //     getRepositories (org) {
            //         const orgReposUrl = api.util.nameToLink('travis.repo', org);
            //         return Vue.axios.get(orgReposUrl, {
            //             headers                  : {
            //                 "Accept"                       : "application/json",
            //                 "Access-Control-Allow-Headers" : "true",
            //                 "Access-Control-Allow-Origin"  : "*",
            //                 "Content-Type"                 : "application/json",
            //                 // 'Origin'                       : "https://travis-ci.org",
            //                 // 'Referer'                      : "https://travis-ci.org/woahbase",
            //                 "Travis-API-Version"           : "3",
            //                 'X-Requested-With'             : 'XMLHttpRequest',
            //             }
            //         });
            //     }
            // },
            util : {
                // nameToLink (bank) { // makes urls from args
                //     return (utype, org, name) => {
                //         return (bank[utype] || "").replace('${org}', org).replace('${name}', name);
                //     }
                // }
                nameToLink (utype, org, name) { // makes urls from args
                    return ({
                        "-.docker.org"        : "/static/json/docker.json", // static json
                        "-.github.org.repos"  : "/static/json/github.json", // static json
                        "-.scraped.site"      : "/static/scraped/site.json", // static json
                        "docker"              : "https://hub.docker.com/r/${org}/${name}/", // got cors
                        "formspree"           : "https://formspree.io/${org}",
                        "github"              : "https://github.com/${org}/${name}",
                        "github.mdpreview"    : "https://api.github.com/markdown",
                        "github.org.repos"    : "https://api.github.com/orgs/${org}/repos",
                        "github.readme"       : "https://api.github.com/repos/${org}/${name}/readme",
                        "image"               : "#/images/${name}",
                        "microscaling"        : "https://microbadger.com/images/${org}/${name}/",
                        "microscaling.api"    : "https://api.microbadger.com/v1/images/${org}/${name}/", // got cors
                        "travis"              : "https://travis-ci.org/${org}/${name}", // got auth protection
                        "travis.repo"         : "https://api.travis-ci.org/owner/${org}?include=owner.repositories,repository.default_branch,build.commit,repository.current_build",
                        "travis.svg"          : "https://travis-ci.org/${org}/${name}.svg?branch=master",
                    }[utype] || "").replace('${org}', org).replace('${name}', name);
                }
            }
        }
    }
}

