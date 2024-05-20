<script setup lang="ts">
import { ref, watch, inject, onMounted } from 'vue';
import type { Ref } from 'vue';
import type { LoadCurrentUserAnnouncementApi, PatchAnnouncementApi } from './ApiProvider.vue';

const props = defineProps(['id']);

export interface Api {
  loadCurrentUserAnnouncement: LoadCurrentUserAnnouncementApi;
  patchAnnouncement: PatchAnnouncementApi;
};

const emit = defineEmits(['signedUp']);

const api = inject<Api>('api');
if (!api) {
  throw new Error('Api must be provided');
}

const saveButtonClicked = ref(false);

const title: Ref<string> = ref('');
const titleIsTooShort = ref(false);
const titleIsTooLong = ref(false);

const content = ref('');
const contentIsTooShort = ref(false);
const contentIsTooLong = ref(false);

const latitude = ref('');
const latitudeIsInvalid = ref(false);

const longitude = ref('');
const longitudeIsInvalid = ref(false);

onMounted(async () => {
  const announcement = await api.loadCurrentUserAnnouncement(props.id);
  title.value = announcement.title;
  content.value = announcement.content;
  latitude.value = String(announcement.location.latitude);
  longitude.value = String(announcement.location.latitude);
});

const submit = async () => {
  saveButtonClicked.value = true;
  if (titleIsTooLong.value || titleIsTooShort.value) {
    return;
  }
  await api.patchAnnouncement(props.id, {
    title: title.value,
    content: content.value,
    location: {
      latitude: Number(latitude.value),
      longitude: Number(longitude.value),
    }
  });
};

watch(title, (value: string) => {
  titleIsTooLong.value = value.length > 100;
  titleIsTooShort.value = value.length < 3;
});

watch(content, (value: string) => {
  contentIsTooLong.value = value.length > 1000000;
  contentIsTooShort.value = value.length < 3;
});

watch(latitude, (value: string) => {
  latitudeIsInvalid.value = !(isNumber(value) && Number(value) >= -90 && Number(value) <= 90);
});

watch(longitude, (value: string) => {
  longitudeIsInvalid.value = !(isNumber(value) && Number(value) >= -180 && Number(value) <= 180);
});

const isNumber = (value: string): boolean => {
  return /^([1-9]\d*|0)(\.\d+)?$/.test(value);
}

const shouldShowTitleIsTooLongError = () => {
  return saveButtonClicked.value && titleIsTooLong.value;
}

const shouldShowTitleIsTooShortError = () => {
  return saveButtonClicked.value && titleIsTooShort.value;
}

const shouldShowContentIsTooLongError = () => {
  return saveButtonClicked.value && contentIsTooLong.value;
}

const shouldShowContentIsTooShortError = () => {
  return saveButtonClicked.value && contentIsTooShort.value;
}

const shouldShowLatitudeIsInvalidError = () => {
  return saveButtonClicked.value && latitudeIsInvalid.value;
}

const shouldShowLongitudeIsInvalidError = () => {
  return saveButtonClicked.value && longitudeIsInvalid.value;
}

</script>

<template>
  <div>
    Announcement
    <div>
      Tile:
      <input v-model.trim="title" type="text" data-testid="email-input" />
      <div v-if="shouldShowTitleIsTooLongError()">Title is too long</div>
      <div v-if="shouldShowTitleIsTooShortError()">Title is too short</div>
    </div>
    <div>
      Content
      <textarea v-model="content" data-testid="password-input" />
      <div v-if="shouldShowContentIsTooLongError()">Content is too long</div>
      <div v-if="shouldShowContentIsTooShortError()">Content is too short</div>
    </div>
    <div>
      Latitude:
      <input v-model.trim="latitude" type="text" data-testid="latitude-input" />
      <div v-if="shouldShowLatitudeIsInvalidError()">invalid</div>
    </div>
    <div>
      Longitude:
      <input v-model.trim="longitude" type="text" data-testid="longitude-input" />
      <div v-if="shouldShowLongitudeIsInvalidError()">invalid</div>
    </div>
    <div>
      <button @click="submit" data-testid="submit">Submit</button>
    </div>
  </div>
</template>

<style scoped>
</style>
