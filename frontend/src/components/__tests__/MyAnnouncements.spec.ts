import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import MyAnnouncements from '../MyAnnouncements.vue'
import type { Api } from '../MyAnnouncements.vue'
import type { CurrentUserAnnouncement } from '../ApiProvider.vue';

describe('MyAnnouncements', () => {
  const loadingSelector = '[data-testid=loading]';
  let resolveLoadPromise: (announcements: CurrentUserAnnouncement[]) => void;
  let api: Api;

  beforeEach(() => {
    api = {
      loadCurrentUserAnnouncements: (): Promise<CurrentUserAnnouncement[]> => {
        return new Promise((resolve) => {
          resolveLoadPromise = resolve;
        });
      }
    };
  });

  it('renders properly', () => {
    const wrapper = mount(MyAnnouncements, { global: { provide: { api }}});
    expect(wrapper.text()).toContain('Announcements');
  });

  it('shows loading while request to fetch announcements is in progress', async () => {
    const wrapper = mount(MyAnnouncements, { global: { provide: { api } }});
    expect(wrapper.find(loadingSelector).exists()).toBe(true);
    resolveLoadPromise([]);
    await flushPromises();
    expect(wrapper.find(loadingSelector).exists()).toBe(false);
  });

  it('shows loaded announcement', async () => {
    const title = `title-${Math.random()}`;
    const wrapper = mount(MyAnnouncements, { global: { provide: { api } }});
    resolveLoadPromise([{ id: '1234', title, published: true }]);
    await flushPromises();
    expect(wrapper.text()).toMatch(title);
  });
});
