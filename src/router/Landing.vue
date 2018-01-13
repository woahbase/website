<template>

    <div class="">
        <navigation-component/>
        <div class="columns is-tablet">
            <sidebar-component class="column is-2 "/>
            <images-list-component class="column is-9"/>
            <!-- <div class="column is&#45;2"></div> -->
        </div>
        <footer-component class="footer"/>
    </div>

</template>

<script>

    import NavigationComponent from '@/components/Navigation.vue';
    import SidebarComponent from '@/components/Sidebar.vue';
    import ImagesListComponent from '@/components/ImagesList.vue';
    import FooterComponent from '@/components/Footer.vue';

export default {
    name: 'LandingRoute',
    components : {
        NavigationComponent,
        SidebarComponent,
        ImagesListComponent,
        FooterComponent
    },
    data () {
        return { }
    },
}

</script>

<style scoped>

</style>
