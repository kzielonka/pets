<script setup lang="ts">
import { computed } from 'vue';

const props = defineProps<{
  name: string;
  description: string;
}>();

const isLost = computed(() => {
  const text = `${props.name} ${props.description}`.toLowerCase();
  return text.includes('lost') || text.includes('missing');
});

const isFound = computed(() => {
  const text = `${props.name} ${props.description}`.toLowerCase();
  return text.includes('found');
});
</script>

<template>
  <article class="announcement-card">
    <div class="thumbnail-wrapper">
      <img src="@/assets/dog.jpg" alt="Pet thumbnail" class="pet-photo" />
      <span v-if="isLost" class="badge badge-lost">Lost</span>
      <span v-else-if="isFound" class="badge badge-found">Found</span>
      <span v-else class="badge badge-default">Pet</span>
    </div>

    <div class="card-body">
      <h3 class="pet-name">{{ props.name }}</h3>
      <p class="pet-description">{{ props.description }}</p>
      <div class="card-meta">
        <span class="meta-location">📍 Active report</span>
      </div>
    </div>
  </article>
</template>

<style scoped>
.announcement-card {
  display: flex;
  flex-direction: row;
  gap: 16px;
  padding: 16px;
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 14px;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
  box-sizing: border-box;
}

.announcement-card:hover {
  border-color: #cbd5e1;
  box-shadow: 0 8px 20px -4px rgba(15, 23, 42, 0.08);
  transform: translateY(-2px);
}

.thumbnail-wrapper {
  position: relative;
  width: 90px;
  height: 90px;
  flex-shrink: 0;
}

.pet-photo {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 10px;
  background: #f1f5f9;
}

.badge {
  position: absolute;
  bottom: -4px;
  left: 50%;
  transform: translateX(-50%);
  font-size: 10px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.4px;
  padding: 2px 8px;
  border-radius: 9999px;
  white-space: nowrap;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.08);
}

.badge-lost {
  background: #fef2f2;
  color: #b91c1c;
  border: 1px solid #fecaca;
}

.badge-found {
  background: #f0fdf4;
  color: #15803d;
  border: 1px solid #bbf7d0;
}

.badge-default {
  background: #f8fafc;
  color: #475569;
  border: 1px solid #e2e8f0;
}

.card-body {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  flex: 1;
  min-width: 0;
}

.pet-name {
  font-size: 15px;
  font-weight: 700;
  color: #0f172a;
  margin: 0 0 6px 0;
  line-height: 1.3;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.pet-description {
  font-size: 13px;
  color: #64748b;
  margin: 0 0 8px 0;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-meta {
  display: flex;
  align-items: center;
  gap: 8px;
}

.meta-location {
  font-size: 11px;
  font-weight: 500;
  color: #94a3b8;
}
</style>
