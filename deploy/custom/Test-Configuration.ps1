# Resolves configuration only. Does not contact the Docker engine or start services.
$ErrorActionPreference = 'Stop'
$compose = Join-Path $PSScriptRoot 'compose.yaml'
$keys = @('COMPOSE_PROJECT_NAME','APP_PORT','APP_IMAGE','SITE_CONFIG','TZ','POSTGRES_USER','POSTGRES_DB','POSTGRES_PASSWORD','REDIS_PASSWORD','JWT_SECRET','TOTP_ENCRYPTION_KEY','ADMIN_EMAIL','ADMIN_PASSWORD','SERVER_TRUSTED_PROXIES')
$saved = @{}
foreach ($key in $keys) { $saved[$key] = [Environment]::GetEnvironmentVariable($key, 'Process') }
try {
    $configs = @{}
    foreach ($region in @('cn','global')) {
        $values = @{
            COMPOSE_PROJECT_NAME = "sub2api-$region"
            APP_PORT = $(if ($region -eq 'cn') { '18080' } else { '28080' })
            APP_IMAGE = 'example.invalid/sub2api@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
            SITE_CONFIG = "./$region/site.json"
            TZ = $(if ($region -eq 'cn') { 'Asia/Shanghai' } else { 'UTC' })
            POSTGRES_USER = 'sub2api'; POSTGRES_DB = 'sub2api'
            POSTGRES_PASSWORD = "validation-only-db-$region"
            REDIS_PASSWORD = "validation-only-redis-$region"
            JWT_SECRET = "validation-only-jwt-$region-not-for-deployment"
            TOTP_ENCRYPTION_KEY = $(if ($region -eq 'cn') { 'a' * 64 } else { 'b' * 64 })
            ADMIN_EMAIL = "admin-$region@example.invalid"
            ADMIN_PASSWORD = "validation-only-admin-$region"
            SERVER_TRUSTED_PROXIES = '127.0.0.1/32'
        }
        foreach ($key in $keys) { [Environment]::SetEnvironmentVariable($key, $values[$key], 'Process') }
        $raw = & docker compose --env-file (Join-Path $PSScriptRoot "$region/.env.example") -f $compose config --format json
        if ($LASTEXITCODE -ne 0) { throw "Compose validation failed: $region" }
        $config = ($raw -join "`n") | ConvertFrom-Json
        foreach ($service in @('sub2api','postgres','redis')) {
            if ($config.services.$service.container_name) { throw "Fixed container name: $region/$service" }
            $logging = $config.services.$service.logging
            if ($logging.driver -ne 'json-file' -or $logging.options.'max-size' -ne '20m' -or $logging.options.'max-file' -ne '5') { throw "Missing bounded logs: $region/$service" }
        }
        if ($config.services.postgres.ports -or $config.services.redis.ports) { throw "Database/cache port exposed: $region" }
        if (@($config.services.sub2api.ports).Count -ne 1 -or $config.services.sub2api.ports[0].host_ip -ne '127.0.0.1') { throw "Unexpected application ports: $region" }
        if ($config.services.sub2api.environment.DATABASE_HOST -ne 'postgres' -or $config.services.sub2api.environment.REDIS_HOST -ne 'redis') { throw "External data source: $region" }
        foreach ($volume in @('sub2api_data','postgres_data','redis_data')) {
            if ($config.volumes.$volume.name -ne "sub2api-${region}_$volume") { throw "Unexpected volume: $region/$volume" }
        }
        $mount = $config.services.sub2api.volumes | Where-Object target -eq '/app/data/public/custom/site.json'
        if (-not $mount.read_only -or $mount.type -ne 'bind') { throw "Missing read-only runtime configuration: $region" }
        $site = Get-Content (Join-Path $PSScriptRoot "$region/site.json") -Raw | ConvertFrom-Json
        if ($site.default_locale -ne $(if ($region -eq 'cn') { 'zh' } else { 'en' })) { throw "Unexpected default language: $region" }
        $configs[$region] = $config
    }
    if ($configs.cn.services.sub2api.image -ne $configs.global.services.sub2api.image) { throw 'Sites use different images' }
    if ($configs.cn.networks.'sub2api-network'.name -eq $configs.global.networks.'sub2api-network'.name) { throw 'Shared network' }
    if ($configs.cn.services.sub2api.environment.JWT_SECRET -eq $configs.global.services.sub2api.environment.JWT_SECRET) { throw 'Shared JWT secret' }
    if ($configs.cn.services.sub2api.environment.DATABASE_PASSWORD -eq $configs.global.services.sub2api.environment.DATABASE_PASSWORD) { throw 'Shared database password' }
    if ($configs.cn.services.sub2api.environment.REDIS_PASSWORD -eq $configs.global.services.sub2api.environment.REDIS_PASSWORD) { throw 'Shared Redis password' }
    if ($configs.cn.services.sub2api.environment.TOTP_ENCRYPTION_KEY -eq $configs.global.services.sub2api.environment.TOTP_ENCRYPTION_KEY) { throw 'Shared TOTP key' }
    Write-Output 'PASS: same image; distinct projects, volumes, networks, ports, secrets and runtime languages. No services started.'
} finally {
    foreach ($key in $keys) { [Environment]::SetEnvironmentVariable($key, $saved[$key], 'Process') }
}
