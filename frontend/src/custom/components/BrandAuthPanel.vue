<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import LocaleSwitcher from '@/components/common/LocaleSwitcher.vue'
defineProps<{ siteName: string }>()
const { t } = useI18n()
const features = ['customBrand.authFeature1', 'customBrand.authFeature2', 'customBrand.authFeature3']
</script>

<template>
  <aside class="brand-auth-panel">
    <nav class="auth-panel-nav" :aria-label="t('customBrand.secure')">
      <router-link to="/home"><span aria-hidden="true">←</span> {{ t('customBrand.back') }}</router-link>
      <LocaleSwitcher />
    </nav>
    <div class="auth-panel-intro">
      <p class="auth-panel-eyebrow">{{ siteName }}</p>
      <h2>{{ t('customBrand.authTitle') }}</h2>
      <p class="auth-panel-body">{{ t('customBrand.authBody') }}</p>
      <div class="auth-panel-visual" aria-hidden="true">
        <span class="auth-node">{ }</span><span class="auth-node-line"></span><span class="auth-node auth-node-primary">API</span><span class="auth-node-line"></span><span class="auth-node">✧</span>
      </div>
      <ul><li v-for="feature in features" :key="feature"><span aria-hidden="true">✓</span>{{ t(feature) }}</li></ul>
    </div>
  </aside>
</template>

<style scoped>
.brand-auth-panel { position: relative; z-index: 10; display: flex; flex-direction: column; justify-content: center; min-width: 0; align-self: stretch; }
.auth-panel-nav { display: flex; align-items: center; justify-content: space-between; gap: 12px; color: var(--brand-muted); font-size: 13px; }
.auth-panel-nav a { display: inline-flex; align-items: center; gap: 10px; padding-block: 10px; }
.auth-panel-intro { margin-block: auto; padding-block: 80px; max-width: 460px; }
.auth-panel-eyebrow { font-size: 13px; font-weight: 700; color: var(--brand-accent); margin-bottom: 22px; overflow-wrap: anywhere; }
h2 { font-size: clamp(32px, 3.6vw, 46px); font-weight: 750; line-height: 1.22; letter-spacing: -.035em; text-wrap: balance; }
.auth-panel-body { font-size: 16px; line-height: 1.85; color: var(--brand-muted); margin-top: 22px; }
.auth-panel-visual { display: flex; align-items: center; margin-block: 42px; max-width: 360px; }
.auth-node { width: 64px; height: 64px; flex-shrink: 0; display: grid; place-items: center; border: 1px solid var(--brand-line); border-radius: 16px; background: var(--brand-surface); color: var(--brand-accent); font: 20px ui-monospace, monospace; }
.auth-node-primary { color: white; background: #4f46e5; border-color: #4f46e5; box-shadow: 0 8px 28px rgba(79,70,229,.16); }
.auth-node-line { flex: 1; height: 1px; background: var(--brand-line); min-width: 16px; }
ul { display: grid; gap: 17px; color: var(--brand-muted); font-size: 14px; }
li { display: flex; gap: 12px; align-items: center; }
li span { color: var(--brand-accent); }
@media (max-width: 900px) {
  .auth-panel-intro { display: none; }
  .brand-auth-panel { width: 100%; }
}
</style>
