<script setup lang="ts">
import MainMap from '@/components/MainMap.vue';
import AnnouncementItem from '@/components/AnnouncementItem.vue'; 
</script>

<template>
  <div class="announcements">
    <AnnouncementItem />
    <AnnouncementItem />
    <AnnouncementItem />
    <AnnouncementItem />
    <AnnouncementItem />
    <AnnouncementItem />
    <AnnouncementItem />
    <AnnouncementItem />
    <AnnouncementItem />
    <AnnouncementItem />
    <AnnouncementItem />
    <AnnouncementItem />
    <AnnouncementItem />
    <AnnouncementItem />
    <AnnouncementItem />
    <AnnouncementItem />
    <AnnouncementItem />
    <AnnouncementItem />
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
