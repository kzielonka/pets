<script setup lang="ts">
import { ref, inject, onMounted } from 'vue';

import AnnouncementItem from '@/components/AnnouncementItem.vue';
import type { AnnouncementSearchItem, SearchAnnouncementsApi } from './ApiProvider';

const props = defineProps<{
  items?: AnnouncementSearchItem[];
}>();

export interface Api {
  searchAnnouncements: SearchAnnouncementsApi;
}

const api = inject<Api>('api');
const internalItems = ref<AnnouncementSearchItem[]>([]);

onMounted(async () => {
  if (props.items && props.items.length > 0) {
    return;
  }
  if (api) {
    try {
      const announcements = await api.searchAnnouncements(52.23, 21.01);
      internalItems.value = announcements;
    } catch {
      // Ignored
    }
  }
});
</script>

<template>
  <div class="announcements">
    <div v-for="item in (props.items ?? internalItems)" :key="item.id">
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
