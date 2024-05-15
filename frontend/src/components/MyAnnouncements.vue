<script setup lang="ts">
import { ref, inject, onMounted } from 'vue';
import type { LoadCurrentUserAnnouncementsApi, CurrentUserAnnouncement } from './ApiProvider.vue';

export interface Api {
  loadCurrentUserAnnouncements: LoadCurrentUserAnnouncementsApi,
};

const loading = ref(true);
const announcements = ref<CurrentUserAnnouncement[]>([]);

const api = inject<Api>('api');
if (!api) {
  throw new Error('Api must be provided');
}

onMounted(async () => {
  announcements.value = await api.loadCurrentUserAnnouncements();
  loading.value = false;
});
</script>

<template>
  <div>
    <div v-if="loading" data-testid="loading">Loading...</div>
    Announcements
    <table>
      <tr>
        <td>Title</td>
        <td>Published</td>
      </tr>
      <tr v-for="announcement in announcements" :key="announcement.id">
        <td>
          {{ announcement.title }}
        </td>
        <td>
          {{ announcement.published ? 'yes' : 'no' }}
        </td>
      </tr>
    </table>
    <div>
    </div>
  </div>
</template>

<style scoped>
</style>
