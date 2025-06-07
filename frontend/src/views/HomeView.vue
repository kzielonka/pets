<script setup lang="ts">
import AnnouncementsList from '@/components/AnnouncementsList.vue';
import MainMap from '@/components/MainMap.vue';
import { ref, inject, watch } from 'vue';
import type { AnnouncementSearchItem, SearchAnnouncementsApi } from '@/components/ApiProvider';

export interface Api {
  searchAnnouncements: SearchAnnouncementsApi;
}

const mapCenter= ref<{ x: number, y: number }>({ x: 0, y: 0 });

const handlePositionChanged = (p: any) => {
  mapCenter.value = { x: p.centerX, y: p.centerY };
}

const api = inject<Api>('api');

watch(mapCenter, async (newPosition: { x: number, y: number }) => {
  if (!api) {
    throw new Error('api has not been set');
  }
  const announcements = await api.searchAnnouncements(newPosition.y, newPosition.x);
  console.log(announcements);
});
</script>

<template>
  <main>
    <div class="announcements">
      <div class="wrapper">
        <AnnouncementsList />
      </div>
    </div>
    <div class="map">
      <MainMap @positionChanged="handlePositionChanged"/>
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
