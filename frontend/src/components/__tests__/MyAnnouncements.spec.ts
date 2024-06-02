import { describe, it, expect, beforeEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import MyAnnouncements from '../MyAnnouncements.vue'
import type { Api } from '../MyAnnouncements.vue'
import type { CurrentUserAnnouncement } from '../ApiProvider';

describe('MyAnnouncements', () => {
  const loadingSelector = '[data-testid=loading]';
  const addNewSelector = '[data-testid=add-new]';

  let resolveLoadPromise: (announcements: CurrentUserAnnouncement[]) => void;
  let api: Api;
  
  const resetApi = () => {
    api = {
      loadCurrentUserAnnouncements: (): Promise<CurrentUserAnnouncement[]> => {
        return new Promise((resolve) => {
          resolveLoadPromise = resolve;
        });
      },
      callNewAnnouncement: () => Promise.resolve()
    };
  };

  beforeEach(() => {
    resetApi();
  });

  const mountComponent = () => {
    return mount(MyAnnouncements, {
      global: {
        provide: { api },
        stubs: ['router-link']
      }
    });
  }

  it('renders properly', () => {
    const wrapper = mountComponent();
    expect(wrapper.text()).toContain('Announcements');
  });

  it('shows loading while request to fetch announcements is in progress', async () => {
    const wrapper = mountComponent();
    expect(wrapper.find(loadingSelector).exists()).toBe(true);
    resolveLoadPromise([]);
    await flushPromises();
    expect(wrapper.find(loadingSelector).exists()).toBe(false);
  });

  it('shows loaded announcement', async () => {
    const wrapper = mountComponent();
    const title = `title-${Math.random()}`;
    resolveLoadPromise([{ id: '1234', title, published: true }]);
    await flushPromises();
    expect(wrapper.text()).toMatch(title);
  });

  it('shows loading back when new announcement is beeing added', async () => {
    const wrapper = mountComponent();
    expect(wrapper.find(loadingSelector).exists()).toBe(true);
    resolveLoadPromise([]);
    await flushPromises();
    expect(wrapper.find(loadingSelector).exists()).toBe(false);
    wrapper.find(loadingSelector).exists()
    await wrapper.find(addNewSelector).trigger('click');
    expect(wrapper.find(loadingSelector).exists()).toBe(true);
    resolveLoadPromise([]);
    await flushPromises();
    expect(wrapper.find(loadingSelector).exists()).toBe(false);
  });
});
