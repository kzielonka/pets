import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import MyAnnouncements, { Api } from '../MyAnnouncements.vue'
import type { LoadCurrentUserAnnouncementsApi, CurrentUserAnnouncement } from '../ApiProvider';

describe('MyAnnouncements', () => {
  const loadingSelector = '[data-testid=loading]';
  let resolveLoadPromise: (announcements: CurrentUserAnnouncement[]) => void;
  let api: Api;

  beforeEach(() => {
    api = {
      loadCurrentUserAnnouncements: (email: string, password: string) => {
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
    resolveLoadPromise([{ id: '1234', title, draft: false }]);
    await flushPromises();
    expect(wrapper.text()).toMatch(title);
  });
});
