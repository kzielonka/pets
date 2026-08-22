<script setup lang="ts">
import { ref, inject, onMounted, computed } from 'vue';
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

const displayItems = computed(() => props.items ?? internalItems.value);

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
  <div class="announcements-container">
    <div class="list-header">
      <h2 class="list-title">Nearby Reports</h2>
      <span class="count-badge">{{ displayItems.length }} reported</span>
    </div>

    <div v-if="displayItems.length > 0" class="announcements-scroll">
      <AnnouncementItem
        v-for="item in displayItems"
        :key="item.id"
        :name="item.title"
        :description="item.content"
      />
    </div>

    <div v-else class="empty-state">
      <div class="empty-icon">🔍</div>
      <h3 class="empty-title">No reports in this area</h3>
      <p class="empty-subtitle">Move or zoom out the map to view reports in other regions.</p>
    </div>
  </div>
</template>

<style scoped>
.announcements-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  width: 100%;
  background: #f8fafc;
  border-right: 1px solid #e2e8f0;
  box-sizing: border-box;
}

.list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  background: #ffffff;
  border-bottom: 1px solid #e2e8f0;
}

.list-title {
  font-size: 16px;
  font-weight: 700;
  color: #0f172a;
  margin: 0;
  letter-spacing: -0.2px;
}

.count-badge {
  font-size: 12px;
  font-weight: 600;
  background: #f1f5f9;
  color: #475569;
  padding: 4px 10px;
  border-radius: 9999px;
  border: 1px solid #e2e8f0;
}

.announcements-scroll {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 16px 20px;
  overflow-y: auto;
  flex: 1;
}

.announcements-scroll::-webkit-scrollbar {
  width: 6px;
}

.announcements-scroll::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 3px;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  padding: 60px 28px;
  flex: 1;
}

.empty-icon {
  font-size: 40px;
  margin-bottom: 16px;
  opacity: 0.8;
}

.empty-title {
  font-size: 16px;
  font-weight: 600;
  color: #1e293b;
  margin: 0 0 8px 0;
}

.empty-subtitle {
  font-size: 13px;
  color: #64748b;
  line-height: 1.5;
  margin: 0;
  max-width: 260px;
}
</style>
