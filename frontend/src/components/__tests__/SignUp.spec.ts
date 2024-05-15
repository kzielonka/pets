import { describe, it, expect, vi } from 'vitest'
import { nextTick } from 'vue'
import { mount, flushPromises } from '@vue/test-utils'
import SignUp from '../SignUp.vue'
import type { Api, SignUpApi } from '../ApiProvider.vue'

describe('SignUp', () => {
  const emailInputSelector = '[data-testid=email-input]';
  const passwordInputSelector = '[data-testid=password-input]';
  const passwordConfirmationInputSelector = '[data-testid=password-confirmation-input]';
  const submitSelector = '[data-testid=submit]';
  const invalidEmailErrorSelector = '[data-testid=invalid-email-error]';
  const duplicatedEmailErrorSelector = '[data-testid=duplicated-email-error]';
  const invalidPasswordErrorSelector = '[data-testid=invalid-password-error]';
  const invalidPasswordConfirmationErrorSelector = '[data-testid=invalid-password-confirmation-error]';

  const callSignUp: SignUpApi = (email: string, password: string) => Promise.resolve('success');
  const api: Api = { callSignUp };

  it('renders properly', () => {
    const wrapper = mount(SignUp, { global: { provide: { api }}});
    expect(wrapper.text()).toContain('Sign up');
  });

  it('renders invalid email error after submit is clicked and email is invalid', async () => {
    const wrapper = mount(SignUp, { global: { provide: { api } }});

    expect(wrapper.find(invalidEmailErrorSelector).exists()).toBe(false);

    wrapper.find(submitSelector).trigger('click');
    await nextTick()
    expect(wrapper.find(invalidEmailErrorSelector).exists()).toBe(true);

    await wrapper.find(emailInputSelector).setValue('test@example.com');
    expect(wrapper.find(invalidEmailErrorSelector).exists()).toBe(false);

    await wrapper.find(emailInputSelector).setValue('test');
    expect(wrapper.find(invalidEmailErrorSelector).exists()).toBe(true);
  });

  it('renders duplicated email error after submit', async () => {
    const callSignUp: SignUpApi = (email: string, password: string) => Promise.resolve('duplicated-email-error');
    const api: Api = { callSignUp };
    const email = 'test@example.com';
    const password = 'PAssword1234$';

    const wrapper = mount(SignUp, { global: { provide: { api } }});

    await wrapper.find(emailInputSelector).setValue(email);
    await wrapper.find(passwordInputSelector).setValue(password);
    await wrapper.find(passwordConfirmationInputSelector).setValue(password);
    wrapper.find(submitSelector).trigger('click');
    await flushPromises();
    expect(wrapper.find(invalidEmailErrorSelector).exists()).toBe(false);
    expect(wrapper.find(duplicatedEmailErrorSelector).exists()).toBe(true);
    expect(wrapper.find(invalidPasswordErrorSelector).exists()).toBe(false);
    expect(wrapper.find(invalidPasswordConfirmationErrorSelector).exists()).toBe(false);
  });

  it('renders invalid password error after submit is clicked and password is too short', async () => {
    const wrapper = mount(SignUp, { global: { provide: { api } }});

    expect(wrapper.find(invalidPasswordErrorSelector).exists()).toBe(false);

    wrapper.find(submitSelector).trigger('click');
    await nextTick()
    expect(wrapper.find(invalidPasswordErrorSelector).exists()).toBe(true);

    await wrapper.find(passwordInputSelector).setValue('PAssword1234$');
    expect(wrapper.find(invalidPasswordErrorSelector).exists()).toBe(false);

    await wrapper.find(passwordInputSelector).setValue('aa');
    expect(wrapper.find(invalidPasswordErrorSelector).exists()).toBe(true);
  });

  it('renders invalid password confirmation error when is different than password', async () => {
    const wrapper = mount(SignUp, { global: { provide: { api } }});

    expect(wrapper.find(invalidPasswordConfirmationErrorSelector).exists()).toBe(false);

    await wrapper.find(passwordConfirmationInputSelector).setValue('p');
    expect(wrapper.find(invalidPasswordConfirmationErrorSelector).exists()).toBe(false);

    wrapper.find(submitSelector).trigger('click');
    await nextTick()
    expect(wrapper.find(invalidPasswordConfirmationErrorSelector).exists()).toBe(true);

    await wrapper.find(passwordInputSelector).setValue('p');
    expect(wrapper.find(invalidPasswordConfirmationErrorSelector).exists()).toBe(false);

    await wrapper.find(passwordInputSelector).setValue('pa');
    expect(wrapper.find(invalidPasswordConfirmationErrorSelector).exists()).toBe(true);

    await wrapper.find(passwordConfirmationInputSelector).setValue('pa');
    expect(wrapper.find(invalidPasswordConfirmationErrorSelector).exists()).toBe(false);

    await wrapper.find(passwordConfirmationInputSelector).setValue('pas');
    expect(wrapper.find(invalidPasswordConfirmationErrorSelector).exists()).toBe(true);
  });

  it('sends email and password to server', async () => {
    const callSignUp: SignUpApi = vi.fn((email: string, password: string) => Promise.resolve('success'));
    const api: Api = { callSignUp };
    const email = 'test@example.com';
    const password = 'PAssword1234$';

    const wrapper = mount(SignUp, { global: { provide: { api } }});

    await wrapper.find(emailInputSelector).setValue(email);
    await wrapper.find(passwordInputSelector).setValue(password);
    await wrapper.find(passwordConfirmationInputSelector).setValue(password);
    await wrapper.find(submitSelector).trigger('click');
    await nextTick()

    expect(callSignUp).toHaveBeenCalledOnce();
    expect(callSignUp).toHaveBeenCalledWith(email, password);
  });

  it('emits user signed up event', async () => {
    const callSignUp: SignUpApi = (email: string, password: string) => Promise.resolve('success');
    const api: Api = { callSignUp };
    const email = 'test@example.com';
    const password = 'PAssword1234$';

    const wrapper = mount(SignUp, { global: { provide: { api } }});

    await wrapper.find(emailInputSelector).setValue(email);
    await wrapper.find(passwordInputSelector).setValue(password);
    await wrapper.find(passwordConfirmationInputSelector).setValue(password);
    wrapper.find(submitSelector).trigger('click');
    await flushPromises();
    expect(wrapper.emitted()).toHaveProperty('signedUp')
  });
})
