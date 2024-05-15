<script setup lang="ts">
  import { provide, ref } from 'vue';
  import { isObject, isString } from 'lodash';

  const accessTokenSet = ref(false);
  const accessToken = ref('');

  export type SetAccessToken = (accessToken: string) => void;

  export interface SignInApiResultSuccess {
    success: true;
    accessToken: string;
  };

  export interface SignInApiResultFailure {
    success: false;
  };

  export type SignInApiResult = SignInApiResultSuccess | SignInApiResultFailure;

  export type SignInApi = (email: string, password: string) => Promise<SignInApiResult>;

  export type SignUpApi = (email: string, password: string) => Promise<'success' | 'duplicated-email-error' | 'error'>;

  export interface Api {
    setAccessToken: SetAccessToken;
    callSignIn: SignInApi;
    callSignUp: SignUpApi;
  };

  const errorType = (parsedBody: unknown): string => {
    if (!isObject(parsedBody)) {
      return 'unkown';
    } 
    if(!('error' in parsedBody)) {
      return 'unknown';
    }
    if (!isString(parsedBody.error)) {
      return 'unknown';
    }
    return parsedBody.error;
  }

  const extendHeadersWithAccessToken = (headers: Record<string, string>) => {
    if (!accessTokenSet.value) {
      return headers;
    }
    return { ...headers, 'Authorization': accessToken.value };
  }
  
  const callSignIn = async (email: string, password: string): Promise<SignInApiResult> => {
    const response = await fetch('http://localhost:3000/sign_in', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ email, password })
    });
    if (response.status !== 200) {
      return { success: false };
    }
    return { success: true, accessToken: '1234' };
  }

  const callSignUp = async (email: string, password: string): Promise<'success' | 'duplicated-email-error' | 'error'> => {
    const response = await fetch('http://localhost:3000/sign_up', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ email, password })
    });
    if (response.status === 200) {
      return 'success';
    }
    if (response.status === 400) {
      const parsedBody = await response.json(); 
      if (errorType(parsedBody) === 'duplicated-email') {
        return 'duplicated-email-error';
      }
      return 'error';
    }
    return 'error';
  }

  const setAccessToken = (newAccessToken: string) => {
    accessTokenSet.value = true;
    accessToken.value = newAccessToken;
  };

  const api: Api = {
    callSignIn,
    callSignUp,
    setAccessToken, 
  };

  provide('api', api);
</script>

<template>
  <div>
    <slot></slot>
  </div>
</template>

