<script setup lang="ts">
import { ref, inject, onMounted } from 'vue';
import type { NewAnnouncementApi, LoadCurrentUserAnnouncementsApi, CurrentUserAnnouncement } from './ApiProvider.vue';
import { RouterLink } from 'vue-router';

export interface Api {
  callNewAnnouncement: NewAnnouncementApi,
  loadCurrentUserAnnouncements: LoadCurrentUserAnnouncementsApi,
};

const loading = ref(true);
const announcements = ref<CurrentUserAnnouncement[]>([]);

const api = inject<Api>('api');
if (!api) {
  throw new Error('Api must be provided');
}

const refresh = async () => {
  loading.value = true;
  announcements.value = [];
  announcements.value = await api.loadCurrentUserAnnouncements();
  loading.value = false;
}

onMounted(refresh);

const addNew = async () => {
  await api.callNewAnnouncement();
  await refresh();
};
</script>

<template>
  <div>
    <div v-if="loading" data-testid="loading">Loading...</div>
    Announcements
    <table>
      <tr>
        <td>Title</td>
        <td>Published</td>
        <td></td>
      </tr>
      <tr v-for="announcement in announcements" :key="announcement.id">
        <td>
          {{ announcement.title }}
        </td>
        <td>
          {{ announcement.published ? 'yes' : 'no' }}
        </td>
        <td>
          <RouterLink :to="'/my-announcements/' + announcement.id">details</RouterLink>
        </td>
      </tr>
    </table>
    <div>
    </div>
  </div>
  <button @click="addNew" data-testid="add-new">Add new</button>
</template>

<style scoped>
</style>
