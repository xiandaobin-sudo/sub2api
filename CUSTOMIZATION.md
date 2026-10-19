# Sub2API 定制维护记录

## 目标与边界

一套源码、一个 custom 分支、一个应用镜像，CN / Global 独立部署。保留官方业务、认证、计费与后台配置；main 保持官方原样。现有 pnpm 9.15.9 启动器与锁文件不改。未经人工授权不推送或上线。

## 阶段 1：品牌主题

新增 `frontend/src/custom/theme/palette.js` 集中维护蓝紫主色、渐变和光晕；`custom/styles/brand.css` 提供深浅表面变量、局部焦点和减少动态效果支持。

必要的官方接入点：`frontend/tailwind.config.js` 读取品牌色；`frontend/src/main.ts` 导入定制样式。`style.css`、状态色、支付和供应商颜色保留原样。没有修改任何页面结构或认证逻辑。

站点名称、Logo、副标题、文档、联系方式、首页内容和菜单继续使用后台设置；不创建正式品牌名称，不把实际域名或密钥写入前端。

## 验证与提交

每阶段通过项目启动器执行相关测试及构建；最终运行 lint:check、typecheck、test:run、build。验证日志保存在忽略目录 `.dev/custom-validation/`。静态检查不代表浏览器或完整服务验收。

升级冲突主要集中在 Tailwind 配置和 main.ts 两个接入点；合并时保留官方新增项，再恢复定制导入。维护文档随后续阶段追加。

## 阶段 2：首页

`custom/components/CustomHome.vue` 提供导航、产品介绍、请求格式示例、实际能力说明、快速开始及配置驱动的页脚。没有虚构模型清单或运营数据。只展示管理员实际开放的模型广场入口；注册按钮遵循注册开关，登录/管理员控制台地址复用 HomeView 的判断。

`HomeView.vue` 仅增加组件导入和一个条件分支；首页优先级保持为 home_content > compact_home_enabled > 定制首页 > 官方回退。`custom/presentation.ts` 可关闭定制首页，无需复制或删除官方默认模板。

新增文本在 `custom/i18n/en.ts` 和 `zh.ts` 集中管理，官方两个 locale index 只各增加 import 与 namespace。法律文档链接来自已有协议文档配置，没有内容则不生成虚构链接。联系方式按纯文本展示。

阶段验证：首页及配置优先级/国际化共 22 项测试通过，lint 和生产构建通过。已在本地模拟配置下目视检查桌面首页与窄屏深色首页，390px 设备模拟无横向溢出。此处不代表真实模型、付款或后端认证已验收。

## 阶段 3：共享认证布局

新增 `custom/components/BrandAuthPanel.vue`，修改官方 `components/layout/AuthLayout.vue` 的容器及品牌展示接入，保留原有默认/页脚插槽、设置加载和 Logo URL 校验。桌面双栏、900px 以下单列。CSS 仅通过专用 class 作用于认证布局；LoginView、RegisterView、API、store、表单验证、第三方登录、人机验证及协议流程均未修改。重置密码和其他使用同一布局的页面也继承视觉风格。

阶段验证：布局及原版登录注册 14 项测试通过，lint/构建通过。模拟配置浏览器检查覆盖英文桌面浅色、中文手机深色登录及注册页，确认表单存在、空表单校验失败、390px 无横向溢出。未提交真实登录/注册请求，OAuth、人机验证、支付等真实服务未运行。

## 阶段 4：同镜像双部署

新增 `deploy/custom/compose.yaml` 通过 extends 复用官方三个服务。保留官方 Dockerfile/Compose；清除固定容器名、仅发布各自 loopback 应用端口，三个卷和网络按项目名隔离。CN/Global 各有 `.env.example` 与只读 site.json，凭据必须独立填写，同一个不可变应用 digest。Nginx 示例及操作/备份/能力矩阵见 `deploy/custom/README.md`。

新增 `frontend/public/custom/site.json` 作为官方静态覆盖机制的已知资源；`custom/runtime/locale.ts` 读取其默认语言，官方 `i18n/index.ts` 仅增加 import 与初始化接入。手动偏好优先，无 IP 推断、无后端 API/数据库变化，默认镜像保留原浏览器语言行为。

`deploy/custom/Test-Configuration.ps1` 只解析配置并断言隔离性，不启动服务。已通过 Compose 双配置校验、运行时语言 9 项测试和组件回归、lint/构建；浏览器使用模拟 runtime JSON 验证 zh/en 默认及保存偏好优先。没有实际 Docker 嵌入资源挂载运行验证，原因是 Docker 引擎未启动。

已知业务边界：官方支持国内及 Stripe/Airwallex 支付适配、部分订单币种/换算；余额、计费与额度仍有 USD 语义，套餐币种标签为展示字段，不能宣称已实现完整人民币账本或多币种钱包。不修改计费后端，不进行真实交易。

## 阶段 5：升级工作流

`tools/custom/Update-Upstream.ps1` 默认 Inspect 只读；-Fetch 才获取远程。UpdateMain / Merge 必须显式选择审阅过的 Ref，拒绝脏工作区、验证官方主线祖先关系、先建恢复分支。main 仅允许快进并自动回到 custom；合并使用 --no-ff --no-commit 保留人工审查机会。没有自动解决冲突、重置、推送或部署。

`tools/custom/Validate-Custom.ps1` 依次运行完整前端检查和配置隔离断言；`tools/custom/UPGRADING.md` 说明版本选择、备份、冲突检查、数据库迁移审查、同镜像两站分别升级和恢复。已验证脚本语法、默认只读及两个写步骤拒绝脏工作区；未实际获取/合并任何官方更新，main 未改变。

## 官方文件改动清单（相对 main）

| 文件 | 必要原因 |
|---|---|
| frontend/package.json | 既有提交：精确声明 pnpm 9.15.9，仅一行 |
| frontend/tailwind.config.js | 读取独立品牌色，保留原业务颜色 |
| frontend/src/main.ts | 导入独立品牌 CSS |
| frontend/src/views/HomeView.vue | 条件接入首页展示组件，保留官方模板/优先级和状态逻辑 |
| frontend/src/components/layout/AuthLayout.vue | 共享双栏布局及品牌面板，保留所有表单插槽 |
| frontend/src/i18n/locales/en/index.ts | 加入独立英文 namespace |
| frontend/src/i18n/locales/zh/index.ts | 加入独立中文 namespace |
| frontend/src/i18n/index.ts | 启动时加载运行时默认语言 |

官方 Dockerfile、Compose、Makefile、CI、style.css、登录注册业务页面、后端和 migrations 均未改。原 pnpm 启动器未改，锁文件未改。

## 新增文件清单

```text
CUSTOMIZATION.md
frontend/src/custom/
  theme/palette.js
  styles/brand.css
  presentation.ts
  components/CustomHome.vue
  components/BrandAuthPanel.vue
  i18n/en.ts
  i18n/zh.ts
  runtime/locale.ts
  __tests__/CustomHome.spec.ts
  __tests__/AuthLayout.spec.ts
  __tests__/locale.spec.ts
frontend/public/custom/site.json
deploy/custom/
  compose.yaml
  README.md
  Test-Configuration.ps1
  nginx.conf.example
  cn/.env.example
  cn/site.json
  global/.env.example
  global/site.json
tools/custom/
  Update-Upstream.ps1
  Validate-Custom.ps1
  UPGRADING.md
```

此前已提交的 tools/pnpm.cmd、tools/pnpm.sh、tools/PNPM.md 继续使用，不属于本次新改动。

## 本地查看与验收清单

准备可用的开发后端后，仓库根目录执行 `./tools/pnpm.cmd run dev --host 127.0.0.1`，浏览器访问 http://localhost:3000/home（代理默认指向 localhost:8080，可用 VITE_DEV_PROXY_TARGET 指向独立开发后端）。只预览界面且没有后端时，默认品牌可显示但登录、注册、后台设置不能视为可用。

当前任务浏览器验收使用忽略目录的临时模拟 API（不是正式后台）：桌面/手机、中英文、深浅模式、表单存在与原生空表单校验、语言默认与手动偏好；首页配置和登录状态分支通过组件回归测试。生产必须补做真实账户、验证码/邮箱/OAuth、后台配置保存、模型/计费及支付沙箱、数据库迁移、备份恢复、Nginx/TLS 和同镜像双实例隔离。

上线步骤、域名/代理、品牌配置、同镜像构建、CN/Global 各自启动、备份与恢复见 deploy/custom/README.md；官方升级和单独授权推送见 tools/custom/UPGRADING.md。所有生产参数均为占位符，未部署、未推送、未执行交易。

## 最终验证记录

| 检查 | 结果 |
|---|---|
| pnpm lint:check | 通过 |
| pnpm typecheck | 通过 |
| pnpm test:run | 374 文件、2884 测试全部通过（原 2868 + 新增 16） |
| pnpm build | 通过，国际化完整性 3 测试通过 |
| Compose 双配置解析与隔离断言 | 通过，不依赖引擎，不启动服务 |
| PowerShell 脚本语法、默认只读、脏工作区拒绝 | 通过，HEAD/main/工作区状态未变 |
| 首页浏览器 | 中英/深浅主题、320/390/768/1440/1920px 无横向溢出（模拟配置） |
| 认证布局浏览器 | 桌面与手机、空表单原生校验；未执行真实账户请求 |
| Docker 镜像构建与真实双实例 | 未执行，Docker 引擎未运行 |
| Nginx/TLS、真实后端/模型/支付/备份恢复 | 未执行，需独立环境验收 |

浏览器默认语言验证使用模拟 runtime JSON，不等价于 Docker 内静态资源覆盖挂载验收。构建仍有官方已有的 Browserslist 数据过期、混合导入和大分包提示，没有为消除提示更改依赖或业务代码。任务结束后关闭临时回环地址预览服务；后续用上面的命令重新启动自己的开发后端和前端。
