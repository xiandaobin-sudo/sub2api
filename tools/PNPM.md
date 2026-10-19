# Sub2API 的项目级 pnpm

本地前端开发统一使用 **pnpm 9.15.9**。版本由 `frontend/package.json` 的 `packageManager` 声明，项目启动器通过 Corepack 按该声明运行。对已有官方文件仅增加这一行版本声明，不修改官方 `.npmrc`、Makefile、CI 或 Dockerfile。

本机全局 pnpm 不需要更改。需要 Node.js 和 Corepack；首次使用可能需要联网下载指定版本。不要执行 `corepack use`、全局 `corepack prepare --activate` 或全局安装 pnpm 来切换本项目版本。

Windows（在仓库根目录运行）：

```powershell
.\tools\pnpm.cmd --version
.\tools\pnpm.cmd install --frozen-lockfile
.\tools\pnpm.cmd run lint:check
.\tools\pnpm.cmd run typecheck
.\tools\pnpm.cmd run test:run
.\tools\pnpm.cmd run build
.\tools\pnpm.cmd run dev
```

Linux/macOS（在仓库根目录运行）：

```sh
sh tools/pnpm.sh --version
sh tools/pnpm.sh install --frozen-lockfile
sh tools/pnpm.sh run test:run
sh tools/pnpm.sh run build
```

启动器使用 `corepack enable pnpm --install-directory` 在 Git 已忽略的 `.dev/pnpm-bin/` 创建项目专用 shim，自动进入 `frontend/`，并仅为自身及子进程将该目录加入 PATH。这样 `build` 脚本中的 `pnpm run check:i18n` 也通过 Corepack 读取同一个版本声明，不会调用本机默认的 pnpm 11。

本地统一通过此启动器安装、测试、构建；不要使用裸 `pnpm` 或直接调用带浮动版本的 `corepack pnpm@9`。独立安装的 pnpm、环境覆盖或命令行参数可能绕过 Corepack，所以版本声明不能代替统一入口。

官方 Makefile 使用裸 `pnpm`，保留原样。本地请使用上面的项目启动器，避免直接从默认 pnpm 11 的环境执行前端 Make 目标。

官方 CI 已指定 pnpm 9，主 Dockerfile 已通过 Corepack 准备 pnpm 9，`deploy/Dockerfile` 原本就是 9.15.9。这些路径不会依赖本机默认 pnpm 11，保留官方配置可以减少升级冲突；其中浮动的 pnpm 9 不承诺永远解析到同一补丁版本。本地精确版本由启动器与 `packageManager` 保证。本次不更改 CI 或容器构建策略。

启动器不会修改全局配置、全局 PATH、依赖锁文件或页面源码。已有 `.dev/frontend-baseline/bin/` 启动器只是历史验证辅助文件，后续改用这里的正式入口。
