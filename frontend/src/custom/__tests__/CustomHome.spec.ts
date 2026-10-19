import { mount, RouterLinkStub } from '@vue/test-utils'
import { createI18n } from 'vue-i18n'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import CustomHome from '../components/CustomHome.vue'
import en from '../i18n/en'
import zh from '../i18n/zh'

// The upstream Vitest alias is runtime-only. Precompile messages for this test.
const messages = (values: Record<string, string>) => Object.fromEntries(
  Object.entries(values).map(([key, value]) => [key, () => value])
)

const { appStore } = vi.hoisted(() => ({ appStore: { cachedPublicSettings: {} as Record<string, unknown>, apiBaseUrl: '' } }))
vi.mock('@/stores', () => ({ useAppStore: () => appStore }))

function render(props = {}, locale = 'en') {
  return mount(CustomHome, {
    props: { siteName: 'Configured name', siteLogo: '/logo.svg', siteSubtitle: 'Configured subtitle', docUrl: '', authenticated: false, dashboardPath: '/dashboard', showModels: false, dark: false, ...props },
    global: {
      plugins: [createI18n({ legacy: false, locale, messages: { en: { customBrand: messages(en) }, zh: { customBrand: messages(zh) } } })],
      stubs: { RouterLink: RouterLinkStub, LocaleSwitcher: true }
    }
  })
}
function destinations(wrapper: ReturnType<typeof render>) {
  return wrapper.findAllComponents(RouterLinkStub).map(link => link.props('to'))
}

describe('custom home', () => {
  beforeEach(() => { appStore.cachedPublicSettings = {}; appStore.apiBaseUrl = '' })
  it('uses configured branding and renders both languages with identical message keys', () => {
    expect(render().text()).toContain('Configured name')
    expect(render().text()).toContain(en.title)
    expect(render({}, 'zh').text()).toContain(zh.title)
    expect(Object.keys(en).sort()).toEqual(Object.keys(zh).sort())
  })
  it('hides registration and model catalog unless enabled', () => {
    expect(destinations(render())).not.toContain('/register')
    expect(destinations(render())).not.toContain('/model-plaza')
    appStore.cachedPublicSettings = { registration_enabled: true }
    expect(destinations(render({ showModels: true }))).toContain('/register')
    expect(destinations(render({ showModels: true }))).toContain('/model-plaza')
  })
  it('uses the supplied administrator dashboard without showing registration to a logged-in user', () => {
    appStore.cachedPublicSettings = { registration_enabled: true }
    const links = destinations(render({ authenticated: true, dashboardPath: '/admin/dashboard' }))
    expect(links).toContain('/admin/dashboard')
    expect(links).not.toContain('/register')
  })
  it('only renders configured documentation and legal links', () => {
    expect(render().find('a[target="_blank"]').exists()).toBe(false)
    appStore.cachedPublicSettings = { login_agreement_documents: [{ id: 'privacy', title: 'Privacy', content_md: 'Policy' }] }
    const wrapper = render({ docUrl: 'https://example.test/docs' })
    expect(wrapper.find('a[target="_blank"]').attributes('rel')).toBe('noopener noreferrer')
    expect(destinations(wrapper)).toContain('/legal/privacy')
  })
  it('emits a theme request rather than changing the upstream theme implementation', async () => {
    const wrapper = render()
    await wrapper.get('button[aria-pressed]').trigger('click')
    expect(wrapper.emitted('toggleTheme')).toHaveLength(1)
  })
  it('uses the configured API base without duplicating the v1 prefix', () => {
    appStore.apiBaseUrl = 'https://api.example.test/v1/'
    expect(render().text()).toContain('https://api.example.test/v1/chat/completions')
  })
})
