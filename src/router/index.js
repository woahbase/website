import Vue from 'vue'
import Router from 'vue-router'
import LandingRoute from '@/router/Landing'
import ImagesRoute from '@/router/Images'
import AboutRoute from '@/router/About'
import ContactRoute from '@/router/Contact'

Vue.use(Router)

export default new Router({
    routes: [
        {
            path: '/',
            name: 'Landing',
            component: LandingRoute
        },
        {
            path: '/about',
            name: 'About',
            component: AboutRoute,
            meta : { scrollToTop : true }
        },
        {
            path: '/contact',
            name: 'Contact',
            component: ContactRoute,
            meta : { scrollToTop : true }
        },
        {
            path: '/images/:repository?',
            name: 'Images',
            component: ImagesRoute,
            props : true,
            meta : { scrollToTop : true }
        }
    ],
    // mode: 'hash',
    // fallback : false,
    base: __dirname,
    scrollBehavior (to, from, savedPosition) {
        // if (savedPosition) {
        //     // savedPosition is only available for popstate navigations.
        //     return savedPosition
        // } else {
            const position = {}
            // new navigation.
            // scroll to anchor by returning the selector
            if (to.hash) {
                position.selector = to.hash

                // specify offset of the element
                if (to.hash === '#anchor2') {
                    position.offset = { y: 100 }
                }
            }
            // check if any matched route config has meta that requires scrolling to top
            if (to.matched.some(m => m.meta.scrollToTop)) {
                // cords will be used if no selector is provided,
                // or if the selector didn't match any element.
                position.x = 0
                position.y = 0
            }
            // if the returned position is falsy or an empty object,
            // will retain current scroll position.
            return position
        // }
    },
})
