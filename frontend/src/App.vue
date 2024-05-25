<script setup lang="ts">
import ApiProvider from './components/ApiProvider.vue';
import CurrentUserProvider from './components/CurrentUserProvider.vue';
import PageLayout from './components/PageLayout.vue';
</script>

<template>
  <ApiProvider>
    <CurrentUserProvider> 
      <PageLayout />
    </CurrentUserProvider>
  </ApiProvider>
</template>

<style scoped>
</style>
