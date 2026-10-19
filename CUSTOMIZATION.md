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
