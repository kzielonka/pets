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
  <main>
    <div class="announcements">
      <div class="wrapper">
        <AnnouncementsList :items="announcements" />
      </div>
    </div>
    <div class="map">
      <MainMap :pins="pins" @positionChanged="handlePositionChanged"/>
    </div>
  </main>
</template>

<style scoped>
.wrapper {
  overflow: scroll;
}

main {
  display: grid;
  width: 100%;
  height: 100%;
  gap: 20px;
  grid-template-areas: "list map";
  grid-template-rows: 1fr;
  grid-template-columns: minmax(300px, 400px) 1fr;
}

.announcements {
  grid-area: list;
}

.map {
  grid-area: map;
}

.wrapper {
  position: absolute;
  top: 170px;
  bottom: 70px;
  overflow: scroll;
}
</style>
