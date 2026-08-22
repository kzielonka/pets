<script setup lang="ts">
import PageHeader from './PageHeader.vue';
</script>

<template>
  <div class="page-container">
    <PageHeader />
    <main class="page-content">
      <slot />
    </main>
  </div>
</template>

<style scoped>
.page-container {
  display: flex;
  flex-direction: column;
  width: 100vw;
  height: 100vh;
  overflow: hidden;
  background: #ffffff;
  box-sizing: border-box;
}

.page-content {
  flex: 1;
  display: flex;
  width: 100%;
  height: calc(100vh - 64px);
  overflow: hidden;
}
</style>
