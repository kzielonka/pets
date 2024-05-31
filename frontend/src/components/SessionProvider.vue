<script setup lang="ts">
  import { provide, ref, onMounted } from 'vue';

  interface SignedInUserSession {
    signedIn: true;
    guest: false;
    accessToken: string;
  }

  interface GuestUserSession {
    signedIn: false;
    guest: true;
  }

  export type Session = SignedInUserSession | GuestUserSession;

  const session = ref<Session>({
    signedIn: false,
    guest: true,
  });

  export type SessionSignIn = (accessToken: string) => void;

  const signIn: SessionSignIn = (accessToken: string) => {
    session.value = {
      signedIn: true,
      guest: false,
      accessToken,
    };
    localStorage.setItem('signedIn', 'yes');
    localStorage.setItem('accessToken', accessToken);
  }

  export type ResetSession = VoidFunction;

  const resetSession: ResetSession = () => {
    session.value = {
      signedIn: false,
      guest: true,
    };
    localStorage.setItem('signedIn', 'no');
    localStorage.setItem('accessToken', '');
  }

  const accessToken = () => {
    if (session.value.signedIn) {
      return session.value.accessToken;
    }
    return null;
  }

  const accessTokenSet = () => {
    return session.value.signedIn;
  }

  const extractLocalStorageSession = (): Session => {
    if (localStorage.getItem('signedIn') === 'yes') {
      return {
        signedIn: true,
        guest: false,
        accessToken: String(localStorage.getItem('accessToken'))
      };
    }
    return {
      signedIn: false,
      guest: true
    };
  }

  onMounted(() => {
    session.value = extractLocalStorageSession();
  });

  provide('session', session);
  provide('sessionSignIn', signIn);
  provide('resetSession', resetSession);
</script>

<template>
  <div>
    <slot :accessTokenSet="accessTokenSet()" :accessToken="accessToken()"></slot>
  </div>
</template>

