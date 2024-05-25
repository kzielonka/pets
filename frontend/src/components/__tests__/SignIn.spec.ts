import { describe, it, expect, vi } from 'vitest';
import { nextTick } from 'vue';
import { mount, flushPromises } from '@vue/test-utils';
import SignIn from '../SignIn.vue';
import PrimeVue from 'primevue/config';
import type { Api } from '../SignIn.vue';
import type { SignInApi, SetAccessToken } from '../ApiProvider.vue';

describe('SignIn', () => {
  const emailInputSelector = '[data-testid=email-input]';
  const passwordInputSelector = '[data-testid=password-input]';
  const submitSelector = '[data-testid=submit]';
  const errorSelector = '[data-testid=error]';

  const validEmail = 'test@example.com';
  const validPassword = 'PAssword1234$';

  const callSignIn: SignInApi = (email: string, password: string) => {
    if (email === validEmail && password === validPassword) { 
      return Promise.resolve({ success: true, accessToken: 'access-token' });
    }
    return Promise.resolve({ success: false });
  };
  const setAccessToken: SetAccessToken = vi.fn(() => {});
  const api: Api = { callSignIn, setAccessToken };

  const mountSignIn = (api: Api) => {
    return mount(SignIn, {
      global: {
        provide: { api },
        plugins: [PrimeVue],
      }
    });
  }

  it('renders properly', () => {
    const wrapper = mountSignIn(api);
    expect(wrapper.text()).toContain('Sign in');
  });

  it('sends email and password to server and sets access token recieved in response', async () => {
    const accessToken = `access-token-${Math.random()}`;
    const callSignIn: SignInApi = vi.fn(() => Promise.resolve({ success: true, accessToken }));
    const setAccessToken: SetAccessToken = vi.fn(() => {});
    const api: Api = { callSignIn, setAccessToken  };
    const wrapper = mountSignIn(api);

    await wrapper.find(emailInputSelector).setValue(validEmail);
    await wrapper.find(passwordInputSelector).setValue(validPassword);
    await wrapper.find(submitSelector).trigger('click');
    await nextTick()

    expect(callSignIn).toHaveBeenCalledOnce();
    expect(callSignIn).toHaveBeenCalledWith(validEmail, validPassword);

    expect(setAccessToken).toHaveBeenCalledOnce();
    expect(setAccessToken).toHaveBeenCalledWith(accessToken);
  });

  it('emits user signed in event', async () => {
    const wrapper = mountSignIn(api);
    await wrapper.find(emailInputSelector).setValue(validEmail);
    await wrapper.find(passwordInputSelector).setValue(validPassword);
    await wrapper.find(submitSelector).trigger('click');
    await flushPromises();
    expect(wrapper.emitted()).toHaveProperty('signedIn')
  });

  it('shows error if password is invalid', async () => {
    const wrapper = mountSignIn(api);
    expect(wrapper.find(errorSelector).exists()).toBe(false);
    await wrapper.find(emailInputSelector).setValue(validEmail);
    await wrapper.find(passwordInputSelector).setValue('INVALID');
    await wrapper.find(submitSelector).trigger('click');
    expect(wrapper.find(errorSelector).exists()).toBe(true);
  });
});
