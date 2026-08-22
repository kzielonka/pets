<script setup lang="ts">
import AnnouncementsList from '@/components/AnnouncementsList.vue';
import MainMap from '@/components/MainMap.vue';
import { ref, inject } from 'vue';
import type { Api, AnnouncementSearchItem, MapPin } from '@/components/ApiProvider';

const api = inject<Api>('api');

const pins = ref<MapPin[]>([]);
const announcements = ref<AnnouncementSearchItem[]>([]);

const handlePositionChanged = async (p: {
  top: number;
  right: number;
  bottom: number;
  left: number;
  centerX: number;
  centerY: number;
}) => {
  if (!api) return;

  try {
    const [fetchedPins, fetchedAnnouncements] = await Promise.all([
      api.searchMapAnnouncements({
        top: p.top,
        right: p.right,
        bottom: p.bottom,
        left: p.left,
      }),
      api.searchAnnouncements(p.centerY, p.centerX),
    ]);

    pins.value = fetchedPins;
    announcements.value = fetchedAnnouncements;
  } catch (error) {
    console.error('Failed to fetch announcements/pins:', error);
  }
};
</script>

<template>
  <div class="home-split-view">
    <aside class="sidebar-panel">
      <AnnouncementsList :items="announcements" />
    </aside>
    <section class="map-panel">
      <MainMap :pins="pins" @positionChanged="handlePositionChanged"/>
    </section>
  </div>
</template>

<style scoped>
.home-split-view {
  display: flex;
  flex-direction: row;
  width: 100%;
  height: 100%;
  overflow: hidden;
}

.sidebar-panel {
  width: 420px;
  min-width: 340px;
  max-width: 480px;
  height: 100%;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
  z-index: 5;
}

.map-panel {
  flex: 1;
  height: 100%;
  position: relative;
  overflow: hidden;
}
</style>
