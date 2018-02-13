// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'

Vue.config.productionTip = process.env.NODE_ENV === 'production'

import '@/assets/css/main.css'; // common css
import '@/assets/css/font-awesome-docker.css'; //

import Icon from 'vue-awesome/components/Icon'
Vue.component('icon', Icon)

import 'vue-awesome/icons/circle-o-notch'
import 'vue-awesome/icons/cloud-download'
import 'vue-awesome/icons/cogs'
import 'vue-awesome/icons/warning'
import 'vue-awesome/icons/comments-o'
import 'vue-awesome/icons/cubes'
import 'vue-awesome/icons/ellipsis-v'
import 'vue-awesome/icons/envelope-o'
import 'vue-awesome/icons/eye'
import 'vue-awesome/icons/file-text-o'
import 'vue-awesome/icons/flag-checkered'
import 'vue-awesome/icons/github'
import 'vue-awesome/icons/heart'
import 'vue-awesome/icons/info-circle'
import 'vue-awesome/icons/pencil'
import 'vue-awesome/icons/search'
import 'vue-awesome/icons/long-arrow-up'
import 'vue-awesome/icons/long-arrow-down'
import 'vue-awesome/icons/question-circle-o'
import 'vue-awesome/icons/star'
import 'vue-awesome/icons/tag'
// import 'vue-awesome/icons/times'
import 'vue-awesome/icons/twitter'

// import VueHead from 'vue-head'
// Vue.use(VueHead)

import axios from 'axios'
import VueAxios from 'vue-axios'

Vue.use(VueAxios, axios)

import store from './store';

import api from './api'
Vue.use(api)

import App from './App'
import router from './router'

import VueAnalytics from 'vue-analytics';

Vue.use(VueAnalytics, {
    id: 'UA-112406764-1',
    checkDuplicatedScript: true,
    router,
    autoTracking: {
        skipSamePath: true,
        exception: true,
    },
})

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  store,
  template: '<App/>',
  components: { App }
})
