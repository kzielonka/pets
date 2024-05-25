<script setup lang="ts">
import { inject } from 'vue';
import { useRouter, RouterLink } from 'vue-router';
import type { CurrentUser } from './CurrentUserProvider';
import type { Api } from './Api';

const currentUser = inject<CurrentUser>('currentUser');
const api = inject<Api>('api');

const router = useRouter();

const signOut = () => {
  console.log('RESET access token');
  api.resetAccessToken();
  router.push('/');
}

</script>

<template>
  <div class="header">
    <!-- <img alt="Vue logo" class="logo" src="@/assets/logo.svg" width="125" height="125" /> -->
    <RouterLink to="/">Home</RouterLink>
    <RouterLink to="/about">About</RouterLink>
    <RouterLink to="/sign-up" v-if="currentUser.guest">Sign up</RouterLink>
    <RouterLink to="/sign-in" v-if="currentUser.guest">Sign in</RouterLink>
    <a href="#" v-if="currentUser.signedIn" @click="signOut">Sign out</a>

    <RouterLink to="/my-announcements" v-if="currentUser.signedIn">My announcements</RouterLink>
  </div>
</template>

<style scoped>
.page {
  display: flex;
  flex-direction: column;
  width: 100%;
  height: 100%;
}

.header {
  padding: 10px;
}

.content {
  padding-top: 10px;
}
</style>
