<script setup lang="ts">
const props = defineProps(['name', 'description']);
</script>

<template>
  <div class="grid">
    <img src="@/assets/dog.jpg" width="100" height="100" class="photo" /> 
    <div class="name">{{ props.name }} (dog)</div>
    <div class="description">{{ props.description }}</div>
    <div class="date1">Lost at: 2010-01-01</div>
    <div class="date2">Last seen at: Wroclaw, Poland</div>
  </div>
</template>

<style scoped>
.grid {
  display: grid;
  gap: 0px;
  grid-template-areas:
    "photo gap name"
    "photo gap description"
    "photo gap date1"
    "photo gap date2";
  grid-template-rows: auto auto auto auto;
  grid-template-columns: 100px 20px 1fr;
}

.photo {
  grid-area: photo;
}

.name {
  grid-area: name;
}

.description {
  grid-area: description;
}

.date1 {
  grid-area: date1;
}

.date2 {
  grid-area: date2;
}

main {
  display: grid;
  width: 100%;
  height: 100%;
  gap: 20px;
  grid-template-areas: "list map";
  grid-template-rows: 1fr;
  grid-template-columns: minmax(300px, 500px) 1fr;
}
</style>
