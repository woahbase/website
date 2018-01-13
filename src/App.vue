<template>
    <div id="app">
        <!-- <transition name="slide&#45;fade" appear mode="out&#45;in"> -->
            <router-view/>
        <!-- </transition> -->
    </div>
</template>

<script>
    export default {
        name: 'app'
    }
</script>

<style>
    .slide-fade-enter-active {
        transition: all .4s ease;
    }
    .slide-fade-leave-active {
        transition: all .4s ease;
    }
    .slide-fade-enter, .slide-fade-leave-to
    /* .slide-fade-leave-active below version 2.1.8 */ {
    /* transform: translateX(10px); */
    opacity: 0;
}
</style>
