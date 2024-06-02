<script setup lang="ts">
import { inject } from 'vue';
import { useRouter } from 'vue-router';
import SignIn from '../components/SignIn.vue'
import type { Session } from './SessionProvider.vue';

const router = useRouter();

const session = inject<Session>('session');
if (!session) {
  throw new Error('reset session not provided');
}

const handleSignedIn = () => {
  router.push('/');
}

if (session.value.signedIn) {
  handleSignedIn();
}
</script>

<template>
  <main>
    <SignIn @signed-in="handleSignedIn" />
  </main>
</template>
