<script setup lang="ts">
import { RouterView } from 'vue-router';
import PageHeader from './PageHeader.vue';
import PageFooter from './PageFooter.vue';
</script>

<template>
  <div class="page">
    <div class="header">
      <PageHeader />
    </div>
    <div class="content">
      <RouterView />
    </div>
    <div class="footer">
      <PageFooter />
    </div>
  </div>
</template>

<style scoped>
.page {
  display: grid;
  gap: 20px;
  grid-template-areas:
    "lside header rside"
    "lside content rside"
    "lside footer rside";
  width: 100%;
  height: 100%;
  min-height: 100vh;
  grid-template-rows: 150px 1fr 50px;
  grid-template-columns: 1fr 1024px 1fr;
}

.header {
  grid-area: header;
}

.content {
  grid-area: content;
}

.footer {
  grid-area: footer;
}
</style>
