import Vue from 'vue'
import Vuex from 'vuex'
import createLogger from 'vuex/dist/logger'

Vue.use(Vuex)

const debug = process.env.NODE_ENV !== 'production'

export default new Vuex.Store({
    state : {
        showSidebar         : false,
        orgName             : atob('d29haGJhc2U='),
        email               : atob('d3JpdGVAd29haGJhc2Uub25saW5l'), // pls dont scrape
        ignoredRepositories : [ 'website' ],
        repositories        : [],
    },
    mutations : {
        setRepositories(state, repos) {
            state.repositories = repos;
        },
        setReadMe(state, data) {
            state.repositories.forEach((v, i) => {
                if (v.name == data.name) {
                    v.readMe = data.readMe;
                }
            });
        },
        setReadMeHtml(state, data) {
            state.repositories.forEach((v, i) => {
                if (v.name == data.name && v.readMe) {
                    v.readMe.html = data.html;
                }
            });
        },
        setDockerInfo(state, data) {
            data.results.forEach((v, i) => {
                state.repositories.forEach((w, k) => {
                    if(v.name == w.name) {
                        w.docker = v;
                    }
                })
            })
        },
        toggleSidebar(state) {
            state.showSidebar = !state.showSidebar;
        }
    },
  strict: debug,
  plugins: debug ? [createLogger()] : []
})

