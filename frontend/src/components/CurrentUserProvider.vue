<script setup lang="ts">
  import { provide, ref, inject, watch} from 'vue';
  import type { Ref } from 'vue';

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

  const accessTokenSet = inject<Ref<boolean>>('accessTokenSet');
  if (accessTokenSet === undefined) {
    throw new Error('accessTokenSet not provided');
  }

  const currentUser = ref<CurrentUser>({
    signedIn: false,
    guest: true,
  });

  watch(accessTokenSet, (newAccessTokenSet) => {
    if (newAccessTokenSet) {
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

