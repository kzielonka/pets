<script setup lang="ts">
import { inject, type Ref } from 'vue';
import { useRouter, RouterLink } from 'vue-router';
import type { CurrentUser } from './CurrentUserProvider.vue';
import type { ResetSession } from './SessionProvider.vue';

const currentUser = inject<Ref<CurrentUser>>('currentUser');
if (!currentUser) {
  throw new Error('no current user set');
}

const resetSession = inject<ResetSession>('resetSession');
if (!resetSession) {
  throw new Error('reset session not provided');
}

const router = useRouter();

const signOut = () => {
  resetSession();
  router.push('/');
}

</script>

<template>
  <div class="header">
    <div class="logo">
      <img alt="Lost & Found Pets database logo" class="logo" src="@/assets/logo.svg" width="125" height="125" />
    </div>
    <div class="menu">
      <RouterLink to="/" class="link">Home</RouterLink>
      <RouterLink to="/sign-up" v-if="currentUser.guest" class="link">Sign up</RouterLink>
      <RouterLink to="/sign-in" v-if="currentUser.guest" class="link">Sign in</RouterLink>
      <RouterLink to="/my-announcements" v-if="currentUser.signedIn" class="link">My announcements</RouterLink>
      <a href="#" v-if="currentUser.signedIn" @click="signOut" class="link">Sign out</a>
    </div>
  </div>
</template>

<style scoped>
.header {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  height: 100%;
}

.logo {
  display: flex;
}

.menu {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 20px;
}

.link {
  color: black;
}

.link:hover {
  text-decoration: underline;
}
</style>
