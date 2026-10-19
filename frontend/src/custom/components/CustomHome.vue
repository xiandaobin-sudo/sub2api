<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useAppStore } from '@/stores'
import LocaleSwitcher from '@/components/common/LocaleSwitcher.vue'
import Icon from '@/components/icons/Icon.vue'

defineProps<{
  siteName: string; siteLogo: string; siteSubtitle: string; docUrl: string;
  authenticated: boolean; dashboardPath: string; showModels: boolean; dark: boolean
}>()
defineEmits<{ toggleTheme: [] }>()
const { t } = useI18n()
const appStore = useAppStore()
const registrationOpen = computed(() => appStore.cachedPublicSettings?.registration_enabled === true)
const contact = computed(() => appStore.cachedPublicSettings?.contact_info || '')
const legalDocuments = computed(() => appStore.cachedPublicSettings?.login_agreement_documents?.filter(doc => doc.id && doc.title) || [])
const endpoint = computed(() => {
  const base = (appStore.apiBaseUrl || window.location.origin).replace(/\/+$/, '')
  return `${base.endsWith('/v1') ? base : `${base}/v1`}/chat/completions`
})
const capabilities = [
  { icon: 'terminal', title: 'customBrand.capability1', body: 'customBrand.capability1Body' },
  { icon: 'key', title: 'customBrand.capability2', body: 'customBrand.capability2Body' },
  { icon: 'chart', title: 'customBrand.capability3', body: 'customBrand.capability3Body' }
] as const
const steps = [
  { title: 'customBrand.step1', body: 'customBrand.step1Body' },
  { title: 'customBrand.step2', body: 'customBrand.step2Body' },
  { title: 'customBrand.step3', body: 'customBrand.step3Body' },
  { title: 'customBrand.step4', body: 'customBrand.step4Body' }
]
</script>

<template>
  <div class="brand-scope brand-home" data-testid="brand-home">
    <a href="#brand-main" class="brand-skip">{{ t('customBrand.skip') }}</a>
    <header class="brand-nav-wrap">
      <nav class="brand-container brand-nav" :aria-label="t('customBrand.home')">
        <router-link to="/home" class="brand-wordmark">
          <img :src="siteLogo || '/logo.svg'" alt="" width="36" height="36" />
          <span>{{ siteName }}</span>
        </router-link>
        <div class="brand-nav-links">
          <a href="#brand-main">{{ t('customBrand.home') }}</a>
          <router-link v-if="showModels" to="/model-plaza">{{ t('customBrand.models') }}</router-link>
          <a v-if="docUrl" :href="docUrl" target="_blank" rel="noopener noreferrer">{{ t('customBrand.docs') }}</a>
        </div>
        <div class="brand-nav-actions">
          <LocaleSwitcher />
          <button type="button" class="brand-theme" :aria-label="t('customBrand.theme')" :aria-pressed="dark" @click="$emit('toggleTheme')">
            <Icon :name="dark ? 'sun' : 'moon'" size="md" />
          </button>
          <router-link :to="authenticated ? dashboardPath : '/login'" class="brand-button brand-button-small">
            {{ authenticated ? t('customBrand.console') : t('customBrand.login') }}
          </router-link>
        </div>
      </nav>
    </header>

    <main id="brand-main" tabindex="-1">
      <section class="brand-container brand-hero">
        <div class="brand-hero-copy">
          <p class="brand-eyebrow"><span></span>{{ t('customBrand.eyebrow') }}</p>
          <h1>{{ t('customBrand.title') }}</h1>
          <p class="brand-subtitle">{{ siteSubtitle }}</p>
          <p class="brand-description">{{ t('customBrand.description') }}</p>
          <div class="brand-cta">
            <router-link class="brand-button" :to="authenticated ? dashboardPath : registrationOpen ? '/register' : '/login'">
              {{ authenticated ? t('customBrand.console') : t('customBrand.start') }} <span aria-hidden="true">↗</span>
            </router-link>
            <a v-if="docUrl" class="brand-button brand-button-secondary" :href="docUrl" target="_blank" rel="noopener noreferrer">{{ t('customBrand.docs') }}</a>
            <a v-else class="brand-button brand-button-secondary" href="#brand-capabilities">{{ t('customBrand.explore') }}</a>
          </div>
          <router-link v-if="registrationOpen && !authenticated" to="/register" class="brand-registration">{{ t('customBrand.register') }} <span aria-hidden="true">→</span></router-link>
        </div>
        <div class="brand-code-card terminal-container">
          <div class="brand-code-header"><span aria-hidden="true">{ }</span><span>{{ t('customBrand.sample') }}</span><span class="brand-code-language">HTTP</span></div>
          <div class="brand-code-body">
            <p class="brand-code-method">POST <span>{{ endpoint }}</span></p>
            <pre><code>Authorization: Bearer &lt;API_KEY&gt;
Content-Type: application/json

{
  "model": "&lt;model-id&gt;",
  "messages": [
    { "role": "user", "content": "Hello" }
  ],
  "stream": true
}</code></pre>
          </div>
          <p class="brand-code-note">{{ t('customBrand.sampleNote') }}</p>
        </div>
      </section>

      <section id="brand-capabilities" class="brand-container brand-section">
        <div class="brand-section-heading"><div><p class="brand-eyebrow">{{ t('customBrand.eyebrow') }}</p><h2>{{ t('customBrand.capabilities') }}</h2></div>
          <router-link v-if="showModels" to="/model-plaza" class="brand-text-link">{{ t('customBrand.models') }} <span aria-hidden="true">→</span></router-link>
        </div>
        <p class="brand-section-intro">{{ t('customBrand.capabilitiesIntro') }}</p>
        <div class="brand-feature-grid">
          <article v-for="item in capabilities" :key="item.title" class="brand-feature">
            <span class="brand-feature-icon"><Icon :name="item.icon" size="lg" /></span>
            <h3>{{ t(item.title) }}</h3><p>{{ t(item.body) }}</p>
          </article>
        </div>
      </section>

      <section class="brand-container brand-section">
        <h2>{{ t('customBrand.quick') }}</h2><p class="brand-section-intro">{{ t('customBrand.quickIntro') }}</p>
        <ol class="brand-steps">
          <li v-for="(step, index) in steps" :key="step.title"><span class="brand-step-number">0{{ index + 1 }}</span><h3>{{ t(step.title) }}</h3><p>{{ t(step.body) }}</p></li>
        </ol>
      </section>

      <section class="brand-container brand-closing">
        <div><p class="brand-eyebrow">{{ siteName }}</p><h2>{{ t('customBrand.closing') }}</h2></div>
        <router-link :to="authenticated ? dashboardPath : registrationOpen ? '/register' : '/login'" class="brand-button">{{ t('customBrand.start') }} <span aria-hidden="true">→</span></router-link>
      </section>
    </main>
    <footer class="brand-container brand-footer">
      <div><strong>{{ siteName }}</strong><p>© {{ new Date().getFullYear() }} {{ siteName }}. {{ t('customBrand.rights') }}</p></div>
      <div class="brand-footer-links">
        <a v-if="docUrl" :href="docUrl" target="_blank" rel="noopener noreferrer">{{ t('customBrand.docs') }}</a>
        <router-link v-for="doc in legalDocuments" :key="doc.id" :to="`/legal/${encodeURIComponent(doc.id)}`">{{ doc.title }}</router-link>
        <span v-if="contact">{{ t('customBrand.contact') }}: {{ contact }}</span>
      </div>
    </footer>
  </div>
</template>

<style scoped>
.brand-home { min-height: 100vh; }
.brand-container { width: min(1160px, calc(100% - 48px)); margin-inline: auto; }
.brand-nav-wrap { border-bottom: 1px solid var(--brand-line); background: var(--brand-surface); }
.brand-nav { display: flex; align-items: center; justify-content: space-between; gap: 24px; min-height: 80px; }
.brand-wordmark { display: flex; align-items: center; gap: 10px; font-weight: 750; font-size: 18px; min-width: 0; }
.brand-wordmark img { object-fit: contain; border-radius: 9px; flex-shrink: 0; }
.brand-wordmark span { max-width: 220px; overflow-wrap: anywhere; }
.brand-nav-links, .brand-nav-actions { display: flex; align-items: center; gap: 22px; }
.brand-nav-links { font-size: 14px; color: var(--brand-muted); }
.brand-nav-actions { gap: 10px; }
.brand-theme { padding: 9px; border-radius: 10px; }
.brand-theme:hover { background: var(--brand-canvas); }
.brand-button { display: inline-flex; align-items: center; justify-content: center; gap: 16px; padding: 14px 23px; min-height: 48px; border-radius: 10px; background: #4f46e5; color: white; font-size: 14px; font-weight: 650; border: 1px solid transparent; }
.brand-button:hover { background: #4338ca; }
.brand-button-small { min-height: 40px; padding: 9px 16px; }
.brand-button-secondary { background: var(--brand-surface); color: var(--brand-ink); border-color: var(--brand-line); }
.brand-button-secondary:hover { background: var(--brand-canvas); }
.brand-hero { display: grid; grid-template-columns: 1.05fr 1fr; gap: 72px; align-items: center; padding-block: 100px 94px; }
.brand-hero-copy { min-width: 0; }
.brand-eyebrow { display: flex; align-items: center; gap: 8px; font-size: 11px; font-weight: 750; letter-spacing: .14em; color: var(--brand-accent); text-transform: uppercase; }
.brand-eyebrow span { width: 7px; height: 7px; border-radius: 50%; background: #818cf8; }
h1 { font-size: clamp(38px, 4.5vw, 62px); line-height: 1.12; letter-spacing: -.045em; font-weight: 750; margin-block: 24px; text-wrap: balance; }
.brand-subtitle { font-size: 20px; font-weight: 550; margin-bottom: 16px; overflow-wrap: anywhere; }
.brand-description, .brand-section-intro { color: var(--brand-muted); font-size: 15px; line-height: 1.85; max-width: 560px; }
.brand-cta { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 30px; }
.brand-registration { display: inline-block; color: var(--brand-muted); font-size: 13px; margin-top: 20px; }
.brand-code-card { min-width: 0; border: 1px solid #303a59; background: #111b30; border-radius: 18px; box-shadow: 0 24px 65px -25px rgba(49,46,129,.35); overflow: hidden; color: #d6def3; }
.brand-code-header { display: flex; align-items: center; gap: 12px; padding: 18px 22px; border-bottom: 1px solid #303a59; font-size: 12px; }
.brand-code-header > span:first-child { color: #a5b4fc; font: 17px monospace; }
.brand-code-language { margin-left: auto; font-size: 10px; color: #aab7cf; }
.brand-code-body { padding: 24px; font: 12px/1.95 ui-monospace, monospace; }
.brand-code-method { color: #a5b4fc; margin-bottom: 20px; overflow-wrap: anywhere; }
.brand-code-method span { color: #bac7e0; }
pre { white-space: pre-wrap; overflow-wrap: anywhere; }
.brand-code-note { padding: 16px 24px; font-size: 11px; line-height: 1.7; background: #17223b; color: #b4c0d8; }
.brand-section { padding-block: 50px; }
.brand-section-heading { display: flex; align-items: end; justify-content: space-between; gap: 24px; }
h2 { font-size: clamp(25px, 3vw, 34px); font-weight: 700; letter-spacing: -.025em; line-height: 1.3; margin-block: 12px; }
.brand-text-link { color: var(--brand-accent); font-size: 14px; white-space: nowrap; padding-block: 8px; }
.brand-feature-grid { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 20px; margin-top: 32px; }
.brand-feature { padding: 30px; border: 1px solid var(--brand-line); border-radius: 14px; background: var(--brand-surface); }
.brand-feature-icon { display: inline-flex; color: #818cf8; margin-bottom: 24px; }
h3 { font-size: 17px; font-weight: 650; margin-bottom: 12px; }
.brand-feature p, .brand-steps p { color: var(--brand-muted); font-size: 14px; line-height: 1.8; }
.brand-steps { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 30px; margin-top: 34px; }
.brand-step-number { display: block; font: 13px ui-monospace, monospace; color: var(--brand-accent); border-top: 1px solid var(--brand-line); padding-block: 18px; }
.brand-closing { border: 1px solid var(--brand-line); border-radius: 16px; padding: 40px; margin-block: 36px 70px; display: flex; align-items: center; justify-content: space-between; gap: 24px; background: var(--brand-surface); }
.brand-closing h2 { font-size: 26px; }
.brand-footer { padding-block: 30px; border-top: 1px solid var(--brand-line); display: flex; justify-content: space-between; gap: 24px; }
.brand-footer p { color: var(--brand-muted); font-size: 12px; margin-top: 9px; }
.brand-footer-links { display: flex; flex-wrap: wrap; align-items: center; gap: 18px; font-size: 12px; color: var(--brand-muted); overflow-wrap: anywhere; }
.brand-skip { position: absolute; top: 0; left: 16px; transform: translateY(-150%); padding: 12px; z-index: 60; background: var(--brand-surface); }
.brand-skip:focus { transform: translateY(8px); }
@media (max-width: 960px) {
  .brand-nav-links { gap: 14px; }
  .brand-nav-links > a:first-child { display: none; }
  .brand-hero { gap: 32px; padding-block: 64px; }
  .brand-feature { padding: 24px; }
  .brand-wordmark span { max-width: 150px; }
}
@media (max-width: 720px) {
  .brand-container { width: calc(100% - 32px); }
  .brand-nav { flex-wrap: wrap; gap: 12px; padding-block: 16px; }
  .brand-wordmark { flex: 1; }
  .brand-wordmark span { max-width: none; }
  .brand-nav-links { order: 3; width: 100%; flex-wrap: wrap; gap: 24px; padding-top: 8px; }
  .brand-hero { grid-template-columns: minmax(0, 1fr); gap: 38px; padding-block: 48px 24px; }
  .brand-feature-grid { grid-template-columns: minmax(0, 1fr); }
  .brand-steps { grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 24px; }
  .brand-closing, .brand-footer { flex-direction: column; align-items: flex-start; }
  .brand-closing { padding: 28px; margin-block: 16px 40px; }
  .brand-section { padding-block: 32px; }
  .brand-code-body { padding: 20px; font-size: 11px; }
}
@media (max-width: 380px) {
  .brand-wordmark span { max-width: 120px; }
  .brand-nav-actions { gap: 2px; }
  .brand-button-small { padding-inline: 10px; }
  .brand-steps { grid-template-columns: minmax(0, 1fr); }
}
</style>
