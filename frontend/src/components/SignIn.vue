<script setup lang="ts">
import { ref, inject } from 'vue';
import type { Ref } from 'vue';
import type { SignInApi } from './ApiProvider';
import type { SessionSignIn } from './SessionProvider.vue';
import Button from 'primevue/button';
import InputText from 'primevue/inputtext';

export interface Api {
  callSignIn: SignInApi;
};

const emit = defineEmits(['signedIn']);

const api = inject<Api>('api');
if (!api) {
  throw new Error('Api must be provided');
}

const sessionSignIn = inject<SessionSignIn>('sessionSignIn');
if (!sessionSignIn) {
  throw new Error('sessionSignIn must be provided');
}

const email: Ref<string> = ref('');
const password = ref('');

const showError = ref(false);

const submit = async () => {
  const result = await api.callSignIn(email.value, password.value);
  if (result.success) {
    showError.value = false;
    sessionSignIn(result.accessToken);
    emit('signedIn');
  } else {
    showError.value = true;
  }
};
</script>

<template>
  <div class="main">
    <h1 class="title">Sign in</h1>
    <div v-if="showError" data-testid="error">
      Email or password are incorrect
    </div>
    <div class="form-input">
      <label for="email">Email</label>
      <InputText id="email" v-model.trim="email" data-testid="email-input" />
    </div>
    <div class="form-input">
      <label for="password">Password</label>
      <InputText id="password" v-model.trim="password" data-testid="password-input" type="password" />
    </div>
    <div class="button">
      <Button @click="submit" data-testid="submit">Sign in</Button>
    </div>
  </div>
</template>

<style scoped>
.main {
  display: flex;
  flex-direction: column;
  gap: 20px;
  width: 300px;
  margin: 0 auto;
}

.title {
  margin: 0;
  padding: 0;
}

.form-input {
  display: flex;
  flex-direction: column;
}

.button {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}
</style>
