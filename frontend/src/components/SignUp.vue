<script setup lang="ts">
import { ref, watch, inject } from 'vue';
import type { Ref } from 'vue';
import type { SignUpApi } from './ApiProvider.vue';

export interface Api {
  callSignUp: SignUpApi;
};

const emit = defineEmits(['signedUp']);

const api = inject<Api>('api');
if (!api) {
  throw new Error('Api must be provided');
}

const email: Ref<string> = ref('');
const emailDuplicated = ref(false); 
const emailInvalid = ref(true);
const password = ref('');
const invalidPassword = ref(true);
const passwordConfirmation = ref('');
const invalidPasswordConfirmation = ref(true);
const formSubmitted = ref(false);

watch(email, (newEmail: string) => {
  emailDuplicated.value = false;
  emailInvalid.value = !(new RegExp('.+@.+')).test(newEmail);
});

watch(password, (newPassword: string) => {
  invalidPassword.value = !(new RegExp('.{4,1000}')).test(newPassword);
  invalidPasswordConfirmation.value = newPassword !== passwordConfirmation.value;
});

watch(passwordConfirmation, (newPasswordConfirmation: string) => {
  invalidPasswordConfirmation.value = password.value !== newPasswordConfirmation;
});

const isEmailAndPasswordValid = () => {
  return emailInvalid.value === false && invalidPassword.value === false && invalidPasswordConfirmation.value === false;
}

const submit = async () => {
  formSubmitted.value = true;
  if (!isEmailAndPasswordValid()) {
    return;
  }
  const result = await api.callSignUp(email.value, password.value);
  if (result === 'success') {
    emit('signedUp');
  } else if (result === 'duplicated-email-error') {
    emailDuplicated.value = true;
  } else {
    emailInvalid.value = true;
  }
};

const showDuplicatedEmailError = () => {
  return formSubmitted.value && emailDuplicated.value;  
}

const showInvalidEmailError = () => {
  return formSubmitted.value && emailInvalid.value;  
}

const showInvalidPasswordError = () => {
  return formSubmitted.value && invalidPassword.value;  
}

const showInvalidPasswordConfirmationError = () => {
  return formSubmitted.value && invalidPasswordConfirmation.value;  
}

</script>

<template>
  <div>
    Sign up
    <div>
      <input v-model.trim="email" type="text" data-testid="email-input" />
      <div v-if="showDuplicatedEmailError()" data-testid="duplicated-email-error">Duplicated email</div>
      <div v-if="showInvalidEmailError()" data-testid="invalid-email-error">Invalid email</div>
    </div>
    <div>
      <input v-model="password" type="password" data-testid="password-input" />
      <div v-if="showInvalidPasswordError()" data-testid="invalid-password-error">Invalid password</div>
    </div>
    <div>
      <input v-model="passwordConfirmation" type="password" data-testid="password-confirmation-input" />
      <div v-if="showInvalidPasswordConfirmationError()" data-testid="invalid-password-confirmation-error">Invalid password confirmation</div>
    </div>
    <div>
      <button @click="submit" data-testid="submit">Submit</button>
    </div>
  </div>
</template>

<style scoped>
</style>