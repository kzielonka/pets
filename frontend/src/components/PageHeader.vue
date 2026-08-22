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

const signOut = (e: Event) => {
  e.preventDefault();
  resetSession();
  router.push('/');
};
</script>

<template>
  <header class="header">
    <RouterLink to="/" class="brand">
      <div class="logo-icon">🐾</div>
      <div class="brand-text">
        <span class="brand-name">Lost & Found Pets</span>
        <span class="brand-subtitle">Community Map</span>
      </div>
    </RouterLink>

    <nav class="nav-menu">
      <RouterLink to="/" class="nav-link" active-class="active">Explore Map</RouterLink>

      <template v-if="currentUser.guest">
        <RouterLink to="/sign-in" class="nav-link">Sign In</RouterLink>
        <RouterLink to="/sign-up" class="btn btn-primary">Sign Up</RouterLink>
      </template>

      <template v-if="currentUser.signedIn">
        <RouterLink to="/my-announcements" class="nav-link" active-class="active">
          My Reports
        </RouterLink>
        <button @click="signOut" class="btn btn-secondary">Sign Out</button>
      </template>
    </nav>
  </header>
</template>

<style scoped>
.header {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  height: 64px;
  padding: 0 28px;
  box-sizing: border-box;
  background: #ffffff;
  border-bottom: 1px solid #f0f0f0;
}

.brand {
  display: flex;
  align-items: center;
  gap: 12px;
  text-decoration: none;
  color: inherit;
}

.logo-icon {
  font-size: 26px;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 10px;
}

.brand-text {
  display: flex;
  flex-direction: column;
}

.brand-name {
  font-size: 16px;
  font-weight: 700;
  color: #0f172a;
  letter-spacing: -0.3px;
  line-height: 1.2;
}

.brand-subtitle {
  font-size: 11px;
  font-weight: 500;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.nav-menu {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 16px;
}

.nav-link {
  font-size: 14px;
  font-weight: 500;
  color: #475569;
  text-decoration: none;
  padding: 8px 12px;
  border-radius: 8px;
  transition: all 0.15s ease;
}

.nav-link:hover {
  color: #0f172a;
  background: #f1f5f9;
}

.nav-link.active {
  color: #0f172a;
  font-weight: 600;
}

.btn {
  font-size: 14px;
  font-weight: 600;
  padding: 8px 16px;
  border-radius: 8px;
  cursor: pointer;
  text-decoration: none;
  transition: all 0.15s ease;
  border: none;
}

.btn-primary {
  background: #0f172a;
  color: #ffffff;
}

.btn-primary:hover {
  background: #334155;
}

.btn-secondary {
  background: #f1f5f9;
  color: #334155;
  border: 1px solid #e2e8f0;
}

.btn-secondary:hover {
  background: #e2e8f0;
}
</style>
