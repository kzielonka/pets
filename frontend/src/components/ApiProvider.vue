<script setup lang="ts">
  import { provide, inject } from 'vue';
  import type { Ref } from 'vue';
  import type { Session } from './SessionProvider.vue';
  import buildApi from './ApiProvider/buildApi';

  const session = inject<Ref<Session>>('session');
  if (!session) {
    throw new Error('session not provided');
  }

  const isAccessTokenSet = (): boolean => {
    return session.value.signedIn;
  }

  const getAccessToken = (): string => {
    if (session.value.signedIn) {
      return session.value.accessToken;
    }
    return '';
  }

  const api = buildApi(isAccessTokenSet, getAccessToken);

  provide('api', api);
</script>

<template>
  <div>
    <slot></slot>
  </div>
</template>

