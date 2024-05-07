<script setup lang="ts">
import { ref, watch } from 'vue';
import type { Ref } from 'vue'
import { isObject, isString } from 'lodash';

const email: Ref<string> = ref('');
const emailDuplicated = ref(false); 
const emailInvalid = ref(true);
const password = ref('');
const invalidPassword = ref(true);
const passwordConfirmation = ref('');
const invalidPasswordConfirmation = ref(true);
const formSubmitted = ref(false);

watch(email, (newEmail) => {
  emailDuplicated.value = false;
  emailInvalid.value = !(new RegExp('.+@.+')).test(newEmail);
});

watch(password, (newPassword) => {
  invalidPassword.value = !(new RegExp('.{4,1000}')).test(newPassword);
  invalidPasswordConfirmation.value = newPassword !== passwordConfirmation.value;
});

watch(passwordConfirmation, (newPasswordConfirmation) => {
  invalidPasswordConfirmation.value = password.value !== newPasswordConfirmation;
});

defineProps<{
  msg: string
}>()

const errorType = (parsedBody: unknown): string => {
  if (!isObject(parsedBody) || !('error' in parsedBody) || !isString(parsedBody.error)) {
    return 'unkown';
  } 
  return parsedBody.error;
}

const isEmailAndPasswordValid = () => {
  return emailInvalid.value === false && invalidPassword.value === false && invalidPasswordConfirmation.value === false;
}

const callSignUp = async (email: string, password: string): 'success' | 'duplicated-email-error' | 'error' => {
  const response = await fetch('http://localhost:3000/sign_up', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ email, password })
  });
  if (response.status === 200) {
    return 'success';
  }
  if (response.status === 400) {
     const parsedBody = await response.json(); 
     if (errorType(parsedBody) === 'duplicated-email') {
       return 'duplicated-email-error';
     }
     return 'error';
  }
  return 'error';
}

const submit = async () => {
  formSubmitted.value = true;
  if (!isEmailAndPasswordValid()) {
    return;
  }
  const result = await callSignUp(email.value, password.value);
  console.log(result);
  if (result === 'success') {
    alert('Congratulations! You are signed up!');
  } else if (result === 'duplicated-email-error') {
    emailDuplicated.value = true;
  } else {
    alert('Some other error');
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
      <input v-model.trim="email" type="text" />
      <div v-if="showDuplicatedEmailError()">Duplicated email</div>
      <div v-if="showInvalidEmailError()">Invalid email</div>
    </div>
    <div>
      <input v-model="password" type="password" />
      <div v-if="showInvalidPasswordError()">Invalid password</div>
    </div>
    <div>
      <input v-model="passwordConfirmation" type="password" />
      <div v-if="showInvalidPasswordConfirmationError()">Invalid password confirmation</div>
    </div>
    <div>
      <button @click="submit">Submit</button>
    </div>
  </div>
</template>

<style scoped>
</style>
