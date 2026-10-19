import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { readDeploymentLocale } from '../runtime/locale'

describe('deployment default language', () => {
  beforeEach(() => localStorage.clear())
  afterEach(() => vi.unstubAllGlobals())
  it.each(['en', 'zh'])('respects a saved %s preference without fetching a site default', async (locale) => {
    localStorage.setItem('sub2api_locale', locale)
    const fetchMock = vi.fn()
    vi.stubGlobal('fetch', fetchMock)
    expect(await readDeploymentLocale()).toBeNull()
    expect(fetchMock).not.toHaveBeenCalled()
  })
  it.each(['en', 'zh'])('loads %s at runtime for a new visitor', async (locale) => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue({ ok: true, json: async () => ({ default_locale: locale }) }))
    expect(await readDeploymentLocale()).toBe(locale)
    expect(localStorage.getItem('sub2api_locale')).toBeNull()
  })
  it.each([null, {}, { default_locale: 'invalid' }])('ignores malformed or unconfigured data %j', async (config) => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue({ ok: true, json: async () => config }))
    expect(await readDeploymentLocale()).toBeNull()
  })
  it('falls back on a missing file', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue({ ok: false }))
    expect(await readDeploymentLocale()).toBeNull()
  })
  it('falls back on network failure or timeout', async () => {
    vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new Error('offline')))
    expect(await readDeploymentLocale()).toBeNull()
  })
})
