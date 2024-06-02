<script setup lang="ts">
import ApiProvider from './components/ApiProvider.vue';
import CurrentUserProvider from './components/CurrentUserProvider.vue';
import SessionProvider from './components/SessionProvider.vue';
import PageLayout from './components/PageLayout.vue';
import { RouterView } from 'vue-router';
</script>

<template>
  <SessionProvider class="full-size">
    <ApiProvider class="full-size">
      <CurrentUserProvider class="full-size"> 
        <PageLayout>
          <RouterView />
        </PageLayout>
      </CurrentUserProvider>
    </ApiProvider>
  </SessionProvider>
</template>

<style scoped>
.full-size {
  width: 100%;
  height: 100%;
}
</style>
