<script setup lang="ts">
import { ref, watch, inject } from 'vue';
import type { Ref } from 'vue';
import type { SignInApi, SetAccessToken } from './ApiProvider.vue';

export interface Api {
  setAccessToken: SetAccessToken;
  callSignIn: SignInApi;
};

const emit = defineEmits(['signedIn']);

const api = inject<Api>('api');
if (!api) {
  throw new Error('Api must be provided');
}
const email: Ref<string> = ref('');
const password = ref('');

const showError = ref(false);

const submit = async () => {
  const result = await api.callSignIn(email.value, password.value);
  if (result.success) {
    showError.value = false;
    api.setAccessToken(result.accessToken);
    emit('signedIn');
  } else {
    showError.value = true;
  }
};
</script>

<template>
  <div>
    Sign in 
    <div v-if="showError" data-testid="error">
      Email or password are incorrect
    </div>
    <div>
      <input v-model.trim="email" type="text" data-testid="email-input" />
    </div>
    <div>
      <input v-model="password" type="password" data-testid="password-input" />
    </div>
    <div>
      <button @click="submit" data-testid="submit">Submit</button>
    </div>
  </div>
</template>

<style scoped>
</style>
