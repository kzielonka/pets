<script setup lang="ts">
  import { provide, ref, inject, watch } from 'vue';
  import type { Ref } from 'vue';
  import type { Session } from './SessionProvider.vue';

  interface SignedInUser {
    signedIn: true;
    guest: false;
    email: string;
  }

  interface GuestUser {
    signedIn: false;
    guest: true;
  }

  export type CurrentUser = SignedInUser | GuestUser;

  const currentUser = ref<CurrentUser>({
    signedIn: false,
    guest: true,
  });

  const session = inject<Ref<Session>>('session');
  if (!session) {
    throw new Error('session not provided');
  }
  console.log(session);

  watch(session, (session) => {
    if (session.signedIn) {
      currentUser.value = {
        signedIn: true,
        guest: false,
        email: 'test@example.com',
      };
    } else {
      currentUser.value = {
        signedIn: false,
        guest: true,
      };
    }
  });

  provide('currentUser', currentUser);
</script>

<template>
  <div>
    <slot></slot>
  </div>
</template>

