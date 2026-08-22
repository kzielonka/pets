<script setup lang="ts">
import { useRoute } from 'vue-router';
import AnnouncementEdit from '../components/AnnouncementEdit.vue';

const route = useRoute()

const announcementId = route.params.id;
console.log(route.params);
</script>

<template>
  <main>
    <h2>Pet Report Details</h2>
    <AnnouncementEdit :id="announcementId" />
  </main>
</template>
