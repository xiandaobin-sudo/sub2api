export type DeploymentLocale = 'zh' | 'en'

export function isDeploymentLocale(value: unknown): value is DeploymentLocale {
  return value === 'zh' || value === 'en'
}

// This public file contains presentation preferences only, never credentials.
export async function readDeploymentLocale(): Promise<DeploymentLocale | null> {
  if (isDeploymentLocale(localStorage.getItem('sub2api_locale'))) return null
  try {
    const response = await fetch('/custom/site.json', { cache: 'no-store', signal: AbortSignal.timeout(1500) })
    if (!response.ok) return null
    const config: unknown = await response.json()
    if (config && typeof config === 'object' && 'default_locale' in config && isDeploymentLocale(config.default_locale)) {
      return config.default_locale
    }
  } catch {
    // Unconfigured/offline deployments retain the upstream browser-language fallback.
  }
  return null
}
