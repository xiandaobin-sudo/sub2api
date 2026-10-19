# 官方版本升级（Windows / PowerShell）

始终维护一个 custom，main 只跟踪官方。CN/Global 不建长期代码分支；两站只换同一镜像的部署参数。脚本没有 push、reset、rebase、生产部署或数据删除操作，也不会调用强制冲突策略。

## 1. 检查与选版本

在仓库根目录运行默认只读检查：

```powershell
./tools/custom/Update-Upstream.ps1
# 准备查看新的官方更新时显式获取（只更新远程引用和标签）：
./tools/custom/Update-Upstream.ps1 -Fetch
```

检查工作区、远程地址、官方提交、依赖与迁移差异。阅读选定官方 Release 的 Breaking Changes；建议选择稳定发布 tag 或完整 SHA。没有 fetch 的检查只能代表本地缓存。脚本不自动选择“最新”版本。

所有会变更分支的步骤都要求当前 custom 且工作区/暂存区干净。未提交修改必须先自行保存和确认，脚本不会 stash 或覆盖。先备份两套站点数据库、应用数据、密钥和配置并做恢复演练，记录当前应用 digest、Git SHA 及各库 schema_migrations 状态。

## 2. 更新本地 main

以下 `<reviewed-tag-or-sha>` 必须替换为实际审查过的版本，不要直接执行占位符：

```powershell
./tools/custom/Update-Upstream.ps1 -Step UpdateMain -Ref '<reviewed-tag-or-sha>'
```

脚本核实目标属于 upstream/main 历史，仅允许 main 快进，建立 custom 恢复分支，再切 main 快进并返回 custom。不改变 origin/main 的跟踪关系，不自动推送 Fork。若 main 已在选定旧版本之后或分叉，立即停止，不重置。

不使用脚本时可审查后手动执行 `git switch main`、`git merge --ff-only <reviewed-ref>`、`git switch custom`。如果需要让 Fork 的 main 同步，必须经人工授权后单独 `git push origin main`；此动作与 custom 发布分开。

## 3. 合入 custom（留下审查机会）

```powershell
./tools/custom/Update-Upstream.ps1 -Step Merge -Ref '<same-reviewed-tag-or-sha>'
```

脚本先创建带时间戳的恢复分支，再执行 `git merge --no-ff --no-commit <resolved-SHA>`。没有自动提交。若没有实际新提交，Git 可能报告 already up to date。

冲突处理：`git status`、`git diff --name-only --diff-filter=U`；逐处保留官方新增功能及必要定制入口，不整文件无条件选 ours/theirs。暂不合并时用 `git merge --abort` 返回合并前状态，恢复分支保留。脚本不会修改冲突内容。

重点审查：

- `frontend/tailwind.config.js` 的品牌色接入，保留官方其余 theme 项。
- `frontend/src/main.ts` 的样式导入。
- `frontend/src/views/HomeView.vue` 的条件分支，确保 home_content、compact_home_enabled 仍优先，登录状态/权限判断不丢失。
- `frontend/src/components/layout/AuthLayout.vue` 的布局与插槽，保留官方认证表单。
- `frontend/src/i18n/index.ts` 的运行时语言初始化，以及 en/zh locale index 的 customBrand namespace。
- `frontend/package.json` 的 packageManager 一行，保留官方新增 scripts/dependencies。
- 官方 Compose 服务字段、固定容器名、端口、挂载与数据卷变更；本地 extends 模板必须重新验证。
- 官方静态覆盖机制若改动，核对 `/custom/site.json` 挂载是否仍生效。

## 4. 验证、提交与发布准备

冲突解决并暂存后，先比较恢复分支与 custom/合并结果，检查定制目录及全部接入点。核对锁文件变化是否来自官方而非误用 pnpm。运行：

```powershell
./tools/pnpm.cmd install --frozen-lockfile
./tools/custom/Validate-Custom.ps1
```

验证脚本只执行前端 lint:check、typecheck、完整测试、build 与 Compose 配置断言，失败立即停止；不提交或部署。官方更新涉及后端时另跑官方 Go 测试及迁移回归；前端通过不代表后端通过。完成中英/深浅主题/移动端、首页优先级、登录注册及控制台浏览器验收后，人工审查并提交合并结果。

经授权后构建一份新镜像，先在隔离测试环境验证数据库迁移、支付沙箱和模型调用，记录镜像 digest。再分别升级 CN/Global，按对应 env 执行 pull/up，检查 `/health`、日志、静态资源、会话、用量及支付回调。不要自动同时切换两个生产站点。

数据库迁移可能不向后兼容。回滚必须评估旧代码能否读取新 schema；必要时在维护窗口从已验证备份恢复到全新隔离数据卷，再配套旧镜像及应用数据。完整备份与恢复步骤见 `deploy/custom/README.md`，不得直接覆写在线数据库或执行 down -v。

## 5. 单独授权推送

完成审查并得到授权后，可执行 `git push origin custom`。脚本永不推送，也不配置服务器。推送分支不等于允许部署或真实支付测试。
