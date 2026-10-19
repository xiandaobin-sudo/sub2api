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
