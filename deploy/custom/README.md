# 单镜像、国内 / 国际独立部署

本目录只提供部署模板，不会自动连接服务器或执行交易。需要 Docker 引擎和 Docker Compose >= 2.24.4（`!reset`、`!override`）。保留整个仓库相对目录，因为模板通过 `extends` 复用 `deploy/docker-compose.yml`。

## 运行时差异

同一个应用镜像包括固定的 `public/custom/site.json`，默认不覆盖官方浏览器语言。每站将自己的 `site.json` 只读挂载到 `/app/data/public/custom/site.json`。官方嵌入前端服务器会优先提供这个已存在静态资源的本地覆盖文件。前端启动时读取 `default_locale`：已有用户保存的语言 > 站点默认 > 官方浏览器语言。文件不可用或值不合法时回退官方行为；读取超时为 1.5 秒。文件是公开信息，不得放密钥。更改后刷新页面，新访客按默认语言显示；不清除已有用户偏好。

品牌名称、Logo、副标题、文档、联系方式、注册策略、模型渠道、套餐与支付仍在每站自己的管理后台设置，保存到各自数据库。`home_content` 优先于简洁/定制首页；恢复默认定制首页时清空 home_content 并关闭简洁首页。不要把 CN/Global 差异加入 Vite 构建参数。

## 能力矩阵（依据当前代码，未执行真实支付）

| 能力 | 分类 | 实际边界 |
|---|---|---|
| 名称、Logo、首页、文档、注册策略 | 官方已支持 | 后台设置，各数据库独立 |
| 模型渠道、密钥、余额、套餐价格 | 官方已支持 + 部署隔离 | 各站单独配置，不共享用户或渠道 |
| 国内支付 | 官方已支持 | EasyPay、支付宝、微信适配存在；需真实商户资质和独立密钥验收 |
| 国际支付 | 官方已支持 | Stripe、Airwallex 适配存在；不保证具体商户、地区、支付方式可用 |
| 支付订单 CNY / USD 等币种 | 官方部分支持 | Stripe/Airwallex 支持配置币种，订单有币种快照；同一支付方式下混合币种的启用实例会被拒绝 |
| 套餐币种标签 | 官方已支持 | `payment_config_plans.go` 明确为 display-only；不能用标签改变账本单位 |
| 余额与计费完整人民币化、多币种钱包 | 需要较大业务开发 | 仍存在 USD 余额/额度语义；充值倍率和订阅 USD→CNY 汇率是特定换算能力，不是多币种账本。CN 不宣称已完成全站人民币计价 |
| 站点默认中文/英文 | 本次轻量前端扩展 | 运行时只读文件，无后端 API、表结构变化，无 IP 定位 |
| 独立用户、Session、数据、日志与备份 | 部署配置可支持 | 不同项目、三个独立卷、网络和凭据；真实隔离运行仍需引擎验收 |

源码依据：`backend/internal/service/payment_currency.go`、`payment_config_limits.go`、`payment_config_plans.go`、`payment_amounts.go`、`payment_config_service.go`；`frontend/src/components/payment/PaymentQRDialog.vue` 将到账金额明确按 USD 显示。上线前分别确认支付金额、到账余额、套餐价格、费率、退款和回调，不通过 UI 换符号冒充结算能力。现有逻辑不足的人民币账本需求应另行批准、设计和测试，本任务不改计费后端。

## 构建一份镜像

在仓库根目录先执行 `tools/pnpm.cmd` 的 lint:check/typecheck/test:run/build，再用官方 Dockerfile：

```powershell
$revision = git rev-parse --short=12 HEAD
docker build --build-arg COMMIT=$revision -t "sub2api-custom:$revision" .
```

国内/国际均使用这一构建。经人工授权发布到自己的镜像仓库后，记录 RepoDigest，两个 `.env` 的 `APP_IMAGE` 填相同的 `registry/owner/sub2api@sha256:...`。不使用浮动 latest。迁往另一服务器时可经授权使用 `docker save` / `docker load` 分发同一镜像，并核对 image ID；不要重新按地区编译前端。本任务没有发布镜像。

## 首次准备（仓库根目录）

```powershell
if (Test-Path deploy/custom/cn/.env) { throw 'CN .env already exists' }
if (Test-Path deploy/custom/global/.env) { throw 'Global .env already exists' }
Copy-Item deploy/custom/cn/.env.example deploy/custom/cn/.env
Copy-Item deploy/custom/global/.env.example deploy/custom/global/.env
```

仅在文件不存在时复制，不覆盖已有部署配置。填入各站独立的数据库、Redis、JWT、TOTP 和管理员凭据；例如用密码管理器或 `openssl rand -hex 32` 分别生成 JWT/TOTP 密钥。TOTP 为 64 位十六进制。不要复用两站的密钥或密码；JWT/TOTP 固定持久保存，轮换前先评估会话和已有 2FA。`.env` 被 Git 忽略，备份到仓库外受保护位置。

模板空值会使 `docker compose config` 失败，这是为了在启动前补齐必要配置。不在示例提供可部署的默认密码。项目名固定分别为 sub2api-cn / sub2api-global，不要在已有数据环境随意改名（改名会指向另一组卷）。数据库和 Redis 不发布宿主端口，应用端口仅绑定 127.0.0.1:18080 / 28080。固定容器名已通过 `!reset` 移除，所有卷/网络由项目名隔离。

先做无引擎配置验证（只使用进程内验证占位值，不读取真实 .env，不启动服务）：

```powershell
./deploy/custom/Test-Configuration.ps1
docker compose --env-file deploy/custom/cn/.env -f deploy/custom/compose.yaml config --quiet
docker compose --env-file deploy/custom/global/.env -f deploy/custom/compose.yaml config --quiet
```

确认上述检查并经授权后，分别启动：

```powershell
docker compose --env-file deploy/custom/cn/.env -f deploy/custom/compose.yaml up -d
docker compose --env-file deploy/custom/global/.env -f deploy/custom/compose.yaml up -d
```

查看某站用对应 env 的 `ps` / `logs --tail 100 sub2api`；停止用 `stop`。不要执行 `down -v`，不要清理数据卷。数据库凭据在已有卷上改变不会自动更新数据库账号，轮换需单独处理。

## 域名、HTTPS、代理和 Cookie

`nginx.conf.example` 适用于同宿主机的 Nginx；替换占位域名、证书路径，部署前运行 `nginx -t`。两个域名分别代理 18080 / 28080。异地主机仅保留所属站点 server。若 Nginx 在容器中，127.0.0.1 指向 Nginx 自己，必须另行设计专用代理网络；不能直接照搬宿主机示例。

示例支持 SSE 和 WebSocket、不缓存 API、保留后端生成的 CSP nonce。它覆盖 X-Forwarded-For / X-Real-IP 并清除常见伪造头，不把用户提交的转发链直接透传。模板关闭 `security.trust_forwarded_ip_for_api_key_acl` 旧兼容模式；`SERVER_TRUSTED_PROXIES` 必须填应用容器实际看到的直接代理 IP/CIDR。宿主机经 Docker 转发时通常是该项目网络的网关，先用 `docker network inspect sub2api-cn_sub2api-network` / global 对应网络核实，不能盲填任意网段。未配置时仅信任 loopback，因此外部代理的真实客户 IP 不会自动被信任。若还有 CDN，需要在 Nginx 正确配置可信 CDN 的 real_ip，再让应用只信任直接代理。

正式双站必须使用两个不同站点域名；localStorage 按源（含端口）隔离，但 Cookie 不按端口隔离，因此只换端口不足以隔离 Cookie。OAuth、支付通知/返回 URL、API 地址和文档在各自后台填写对应域名。真实支付回调只在经授权的测试商户或沙箱中验收。

## 备份、升级与迁移

两站分别备份 PostgreSQL、应用卷、运行时 site.json、.env 及加密密钥；Redis 如保存重要会话/状态也需独立快照。日志与备份放在各站单独且受保护的目录。不要把备份、密钥或订单日志加入 Git。

数据库示例（CN，先维护窗口停止写入，Global 替换 env/备份路径）：

```powershell
docker compose --env-file deploy/custom/cn/.env -f deploy/custom/compose.yaml exec -T postgres sh -c 'pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc -f /tmp/sub2api.dump'
docker compose --env-file deploy/custom/cn/.env -f deploy/custom/compose.yaml cp postgres:/tmp/sub2api.dump ./backups/cn/sub2api.dump
docker compose --env-file deploy/custom/cn/.env -f deploy/custom/compose.yaml cp sub2api:/app/data ./backups/cn/app-data
```

使用不同日期目录，先创建备份目录并确保不覆盖旧备份；不用 PowerShell 文本重定向保存二进制 dump。备份后验证可恢复到**全新隔离数据库**。恢复时先只启动目标 postgres/redis，将 dump 拷入 postgres，使用 `pg_restore --no-owner --exit-on-error -U <user> -d <empty-db> /tmp/sub2api.dump`，在应用首次启动迁移前完成；先核对旧程序版本、迁移清单、密钥及文件权限。不要把旧 dump 直接覆盖运行中的正式数据库。

应用启动会执行官方数据库迁移。升级前审阅 `backend/migrations` 并验证兼容性；若迁移不向后兼容，回切旧镜像并不充分，需要维护窗口恢复配套数据库与应用数据。先在测试环境、再独立升级 CN 和 Global，每次保留旧镜像及已验证备份。迁移 Global 到新服务器时连同独立卷和密钥恢复，核对镜像 digest，停止旧实例写入后再切 DNS。

## 本次验证范围

2026-10-19 已完成本地统一镜像构建和双实例基础运行检查，具体通过项、阻塞项、镜像 ID 和未验证范围见 [本地验收记录](LOCAL_ACCEPTANCE.md)。该记录不代表正式服务器、实际模型调用、支付或备份恢复验收通过。
