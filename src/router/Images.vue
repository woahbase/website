<template>

    <div class="">
        <navigation-component/>
        <div class="columns is-tablet">
            <sidebar-component class="column is-2 "/>
            <images-detail-component :repository="repository" class="column is-9"/>
        </div>
        <footer-component class="footer"/>
    </div>

</template>

<script>

    import NavigationComponent from '@/components/Navigation.vue';
    import SidebarComponent from '@/components/Sidebar.vue';
    import ImagesDetailComponent from '@/components/ImagesDetail.vue';
    import FooterComponent from '@/components/Footer.vue';

export default {
    name: 'ImagesRoute',
    components : {
        NavigationComponent,
        SidebarComponent,
        ImagesDetailComponent,
        FooterComponent
    },
    data () {
        return { }
    },
    props : [ 'repository' ]
}

</script>

<style scoped>

</style>
