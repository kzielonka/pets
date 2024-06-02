<script setup lang="ts">
import AnnouncementsList from '@/components/AnnouncementsList.vue';
import MainMap from '@/components/MainMap.vue';
</script>

<template>
  <main>
    <div class="announcements">
      <div class="wrapper">
        <AnnouncementsList />
      </div>
    </div>
    <div class="map">
      <MainMap />
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
