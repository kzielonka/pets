<script setup lang="ts">
import { inject, ref, type Ref } from 'vue';
import { useRouter } from 'vue-router';
import SignUp from '@/components/SignUp.vue'
import type { Session } from '@/components/SessionProvider.vue';
import { RouterLink } from 'vue-router';

const router = useRouter();
const session = inject<Ref<Session>>('session');
if (!session) {
  throw new Error('reset session not provided');
}
if (session.value.signedIn) {
  router.push('/');
}

const signedUpSuccessfully = ref(false);

const handleSignedUp = () => {
  signedUpSuccessfully.value = true;
}
</script>

<template>
  <main>
    <div v-if="!signedUpSuccessfully">
      <SignUp @signed-up="handleSignedUp()" />
    </div>
    <div v-if="signedUpSuccessfully" class="success-info"> 
      You are signed up successfully, you can sign in now.
      <br />
      <RouterLink to="/sign-in">Sign in</RouterLink>
    </div>
  </main>
</template>

<style scoped>
.success-info {
  text-align: center;
}
</style>
