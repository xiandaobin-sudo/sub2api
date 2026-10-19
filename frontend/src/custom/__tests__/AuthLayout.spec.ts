import { mount, RouterLinkStub } from '@vue/test-utils'
import { describe, expect, it, vi } from 'vitest'
import AuthLayout from '@/components/layout/AuthLayout.vue'

const { appStore } = vi.hoisted(() => ({ appStore: {
  siteName: 'Configured brand', siteLogo: 'javascript:alert(1)', cachedPublicSettings: { site_subtitle: 'Configured subtitle' },
  publicSettingsLoaded: true, fetchPublicSettings: vi.fn()
} }))
vi.mock('@/stores', () => ({ useAppStore: () => appStore }))
vi.mock('vue-i18n', () => ({ useI18n: () => ({ t: (key: string) => key }) }))
vi.mock('@/components/common/LocaleSwitcher.vue', () => ({ default: { template: '<span />' } }))

describe('shared custom authentication layout', () => {
  it('retains the original form and footer slots including keyboard-accessible controls', () => {
    const wrapper = mount(AuthLayout, {
      slots: { default: '<form><label for="email">Email</label><input id="email" type="email" /><button>Submit</button></form>', footer: '<a href="/forgot-password">Reset password</a>' },
      global: { stubs: { RouterLink: RouterLinkStub, LocaleSwitcher: true } }
    })
    expect(wrapper.get('form input').attributes('type')).toBe('email')
    expect(wrapper.get('form button').text()).toBe('Submit')
    expect(wrapper.find('a[href="/forgot-password"]').exists()).toBe(true)
    expect(wrapper.text()).toContain('Configured brand')
    expect(wrapper.text()).toContain('Configured subtitle')
    expect(wrapper.get('img').attributes('src')).toBe('/logo.svg')
    expect(wrapper.findComponent(RouterLinkStub).props('to')).toBe('/home')
  })
})
