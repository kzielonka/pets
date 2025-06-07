<script setup lang="ts">
import { ref, inject, onMounted } from 'vue';

import AnnouncementItem from '@/components/AnnouncementItem.vue';
import type { AnnouncementSearchItem, SearchAnnouncementsApi } from './ApiProvider';

export interface Api {
  searchAnnouncements: SearchAnnouncementsApi;
}

const api = inject<Api>('api');

const items = ref<AnnouncementSearchItem[]>([]);

onMounted(async () => {
  const announcements = await api.searchAnnouncements(0, 0);
  items.value = announcements;
})

</script>

<template>
  <div class="announcements">
    <div v-for="item in items" :key="item.id">
      <AnnouncementItem :name="item.title" :description="item.content" />
    </div>
  </div>
</template>

<style scoped>
.announcements {
  display: flex;
  flex-direction: column;
  gap: 20px;
  overflow: scroll;
  max-height: 100%;
}
</style>
