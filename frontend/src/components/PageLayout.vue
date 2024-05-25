<script setup lang="ts">
import { RouterView } from 'vue-router';
import PageHeader from './PageHeader.vue';
</script>

<template>
  <div class="page">
    <div class="header">
      <PageHeader />
    </div>
    <div class="content">
      <RouterView />
    </div>
  </div>
</template>

<style scoped>
.page {
  display: flex;
  flex-direction: column;
  width: 100%;
  height: 100%;
}

.header {
  padding: 10px;
}

.content {
  padding-top: 10px;
}
</style>
