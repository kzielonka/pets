<script setup lang="ts">
import ApiProvider from './components/ApiProvider.vue';
import CurrentUserProvider from './components/CurrentUserProvider.vue';
import PageLayout from './components/PageLayout.vue';
</script>

<template>
  <ApiProvider class="full-size">
    <CurrentUserProvider class="full-size"> 
      <PageLayout />
    </CurrentUserProvider>
  </ApiProvider>
</template>

<style scoped>
.full-size {
  width: 100%;
  height: 100%;
}
</style>
