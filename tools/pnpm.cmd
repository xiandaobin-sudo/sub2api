@echo off
setlocal
rem Install shims inside the ignored project directory, never beside global Node.
set "SUB2API_PNPM_BIN=%~dp0..\.dev\pnpm-bin"
if not exist "%SUB2API_PNPM_BIN%" mkdir "%SUB2API_PNPM_BIN%"
if errorlevel 1 exit /b 1
call corepack enable pnpm --install-directory "%SUB2API_PNPM_BIN%"
if errorlevel 1 exit /b 1
set "PATH=%SUB2API_PNPM_BIN%;%PATH%"
set "COREPACK_ENABLE_PROJECT_SPEC=1"
set "COREPACK_ENABLE_STRICT=1"
set "COREPACK_ENABLE_AUTO_PIN=0"
pushd "%~dp0..\frontend"
if errorlevel 1 exit /b 1
call corepack pnpm %*
set "SUB2API_PNPM_EXIT_CODE=%ERRORLEVEL%"
popd
exit /b %SUB2API_PNPM_EXIT_CODE%
