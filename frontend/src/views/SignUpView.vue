<script setup lang="ts">
import SignUp from '../components/SignUp.vue'
import ApiProvider from '../components/ApiProvider.vue';
</script>

<template>
  <main>
    <ApiProvider>
      <SignUp />
    </ApiProvider>
  </main>
</template>
