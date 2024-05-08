<script setup lang="ts">
  import { provide } from 'vue';
  import { isObject, isString } from 'lodash';

  export type SignUpApi = (email: string, password: string) => Promise<'success' | 'duplicated-email-error' | 'error'>;

  export interface Api {
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

  const api: Api = {
    callSignUp,
  };

  provide('api', api);
</script>

<template>
  <div>
    <slot></slot>
  </div>
</template>

