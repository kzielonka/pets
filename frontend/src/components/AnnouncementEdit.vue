<script setup lang="ts">
import { ref, watch, inject, onMounted } from 'vue';
import type { Ref } from 'vue';
import type { LoadCurrentUserAnnouncementApi, PatchAnnouncementApi, PublishAnnouncementApi } from './ApiProvider';
import Button from 'primevue/button';
import InputText from 'primevue/inputtext';
import Textarea from 'primevue/textarea';
import MapInput from './MapInput.vue';

const props = defineProps(['id']);

export interface Api {
  loadCurrentUserAnnouncement: LoadCurrentUserAnnouncementApi;
  patchAnnouncement: PatchAnnouncementApi;
  publishAnnouncement: PublishAnnouncementApi;
  unpublishAnnouncement: PublishAnnouncementApi;
};

const api = inject<Api>('api');
if (!api) {
  throw new Error('Api must be provided');
}

const saveButtonClicked = ref(false);

const published = ref(false);

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

const saving = ref(false);

const fetchAnnouncement = async () => {
  const announcement = await api.loadCurrentUserAnnouncement(props.id);
  published.value = announcement.published;
  title.value = announcement.title;
  content.value = announcement.content;
  latitude.value = String(announcement.location.latitude);
  longitude.value = String(announcement.location.longitude);
}

onMounted(async () => {
  await fetchAnnouncement();
});

const isEverythingValid = (): boolean => {
  return !titleIsTooShort.value &&
    !titleIsTooLong.value &&
    !contentIsTooShort.value &&
    !contentIsTooLong.value &&
    !latitudeIsInvalid.value &&
    !longitudeIsInvalid.value;
}

const submit = async () => {
  saveButtonClicked.value = true;
  saving.value = true;
  if (!isEverythingValid()) {
    await new Promise((resolve) => setTimeout(resolve, 100));
    saving.value = false;
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
  await new Promise((resolve) => setTimeout(resolve, 1000));
  saving.value = false;
};

const publish = async () => {
  submit();
  saving.value = true;
  await new Promise((resolve) => setTimeout(resolve, 1000));
  await api.publishAnnouncement(props.id);
  await fetchAnnouncement();
  saving.value = false;
};

const unpublish = async () => {
  await api.unpublishAnnouncement(props.id);
  await new Promise((resolve) => setTimeout(resolve, 1000));
  await fetchAnnouncement();
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
  console.log(Number(value));
  latitudeIsInvalid.value = !(isNumber(value) && Number(value) >= -90 && Number(value) <= 90);
});

watch(longitude, (value: string) => {
  longitudeIsInvalid.value = !(isNumber(value) && Number(value) >= -180 && Number(value) <= 180);
});

const isNumber = (value: string): boolean => {
  return /^-?([1-9]\d*|0)(\.\d+)?$/.test(value);
}

const shouldShowTitleIsTooLongError = () => {
  return saveButtonClicked.value && titleIsTooLong.value;
}

const shouldShowTitleIsTooShortError = () => {
  return saveButtonClicked.value && titleIsTooShort.value;
}

const isTitleInputInvalid = () => {
  return shouldShowTitleIsTooShortError() || shouldShowTitleIsTooShortError();
}

const shouldShowContentIsTooLongError = () => {
  return saveButtonClicked.value && contentIsTooLong.value;
}

const shouldShowContentIsTooShortError = () => {
  return saveButtonClicked.value && contentIsTooShort.value;
}

const isContentInputInvalid = () => {
  return shouldShowContentIsTooShortError() || shouldShowContentIsTooShortError();
}

const shouldShowLatitudeIsInvalidError = () => {
  return saveButtonClicked.value && latitudeIsInvalid.value;
}

const isLatitudeInputInvalid = () => {
  return shouldShowLatitudeIsInvalidError();
}

const shouldShowLongitudeIsInvalidError = () => {
  return saveButtonClicked.value && longitudeIsInvalid.value;
}

const isLongitudeInputInvalid = () => {
  return shouldShowLongitudeIsInvalidError();
}

const isDisabled = () => {
  return saving.value || published.value;
}

</script>

<template>
  <div>
    Announcement
    <div class="form-input">
      <label for="title">Title</label>
      <InputText id="title" v-model.trim="title" :invalid="isTitleInputInvalid()" :disabled="isDisabled()" aria-describedby="title-help" data-testid="title-input" />
      <small id="title-help">Enter your username to reset your password.</small>
      <div class="error" v-if="shouldShowTitleIsTooLongError()">Title is too long</div>
      <div class="error" v-if="shouldShowTitleIsTooShortError()">Title is too short</div>
    </div>
    <div class="form-input">
      <label for="content">Content</label>
      <Textarea id="content" v-model="content" :invalid="isContentInputInvalid()" :disabled="isDisabled()" data-testid="password-input" />
      <small id="title-help">Enter your username to reset your password.</small>
      <div class="error" v-if="shouldShowContentIsTooLongError()">Content is too long</div>
      <div class="error" v-if="shouldShowContentIsTooShortError()">Content is too short</div>
    </div>
    <div class="location-form-input">
      <div class="form-input">
        <label for="latitude">Latitude</label>
        <InputText id="latitude" v-model.trim="latitude" :invalid="isLatitudeInputInvalid()" :disabled="isDisabled()" aria-describedby="latitude-help" data-testid="latitude-input" />
        <div class="error" v-if="shouldShowLatitudeIsInvalidError()">invalid</div>
      </div>
      <div class="form-input">
        <label for="longitude">Longitude</label>
        <InputText id="longitude" v-model.trim="longitude" :invalid="isLongitudeInputInvalid()" :disabled="isDisabled()" aria-describedby="longitude-help" data-testid="longitude-input" />
        <div class="error" v-if="shouldShowLongitudeIsInvalidError()">invalid</div>
      </div>
    </div>
    <div>
      <MapInput v-model:latitude="latitude" v-model:longitude="longitude" />
    </div>
    <div class="button-container" v-if="published">
      <Button @click="unpublish" :disabled="false" data-testid="unpublish">Unpublish</Button>
    </div>
    <div class="button-container" v-if="!published">
      <Button @click="submit" :disabled="isDisabled()" data-testid="submit">Save</Button>
      <Button @click="publish" :disabled="isDisabled()" data-testid="publish">Save & Publish</Button>
    </div>
  </div>
</template>

<style scoped>
.form-input {
  display: flex;
  flex-direction: column;
  margin-bottom: 20px;
}

.location-form-input {
  display: flex;
  flex-direction: row;
  justify-items: stretch;
  gap: 20px;
}

.location-form-input > .form-input {
  flex-grow: 1;
}

.button-container {
  display: flex;
  flex-direction: row-reverse;

}

.error {
  color: red;
}
</style>
