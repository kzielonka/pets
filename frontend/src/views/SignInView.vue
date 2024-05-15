<script setup lang="ts">
import SignIn from '../components/SignIn.vue'
import ApiProvider from '../components/ApiProvider.vue';
</script>

<template>
  <main>
    <ApiProvider>
      <SignIn />
    </ApiProvider>
  </main>
</template>
