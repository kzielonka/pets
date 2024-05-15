<script setup lang="ts">
import { ref, watch, inject } from 'vue';
import type { SignInApi, SetAccessToken } from './ApiProvider.vue';

export interface Api {
  setAccessToken: SetAccessToken;
  callSignIn: SignInApi;
};

const api = inject<Api>('api');
if (!api) {
  throw new Error('Api must be provided');
}

</script>

<template>
  <div>
    Announcements
    <table>
      <tr>
        <td>Title</td>
        <td>Published</td>
      </tr>
      <tr>
        <td>
          Title1
        </td>
        <td>
          yes
        </td>
      </tr>
    </table>
    <div>
    </div>
  </div>
</template>

<style scoped>
</style>
