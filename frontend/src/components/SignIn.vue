<script setup lang="ts">
import { ref, inject } from 'vue';
import type { Ref } from 'vue';
import type { SignInApi, SetAccessToken } from './ApiProvider.vue';
import Button from 'primevue/button';
import InputText from 'primevue/inputtext';

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
    <div class="form-input">
      <label for="email">Email</label>
      <InputText id="email" v-model.trim="email" data-testid="email-input" />
    </div>
    <div class="form-input">
      <label for="password">Password</label>
      <InputText id="password" v-model.trim="password" data-testid="password-input" />
    </div>
    <div>
      <Button @click="submit" data-testid="submit">Submit</Button>
    </div>
  </div>
</template>

<style scoped>
.form-input {
  display: flex;
  flex-direction: column;
  margin-bottom: 20px;
}
</style>
