<template>
    <div class="loader-wrapper">
        <div class="loading">
            <icon name="circle-o-notch" scale="4" spin class="has-text-grey-light"/>
            <br/>
            {{ msg }}
        </div>
    </div>
</template>

<script>
    export default {
        name: 'LoadingComponent',
        computed : { },
        data () {
            return { }
        },
        methods : { },
        props : [ "msg" ]
    }
</script>

<style scoped>
    .loading {
        margin:25% auto;
        min-width: 15em;
        text-align: center;
    }
</style>
