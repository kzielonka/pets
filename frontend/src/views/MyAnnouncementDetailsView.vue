<script setup lang="ts">
import { useRoute } from 'vue-router';
import AnnouncementEdit from '../components/AnnouncementEdit.vue';

const route = useRoute()

const announcementId = route.params.id;
console.log(route.params);
</script>

<template>
  <main>
    My announcement details view
    <AnnouncementEdit :id="announcementId" />
  </main>
</template>
