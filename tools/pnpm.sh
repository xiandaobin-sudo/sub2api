#!/bin/sh
# Invoke with: sh tools/pnpm.sh <command>. Nested pnpm calls use project-local shims.
SUB2API_TOOLS_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
SUB2API_PNPM_BIN="$SUB2API_TOOLS_DIR/../.dev/pnpm-bin"
mkdir -p "$SUB2API_PNPM_BIN" || exit 1
corepack enable pnpm --install-directory "$SUB2API_PNPM_BIN" || exit 1
PATH="$SUB2API_PNPM_BIN:$PATH"
export PATH
export COREPACK_ENABLE_PROJECT_SPEC=1
export COREPACK_ENABLE_STRICT=1
export COREPACK_ENABLE_AUTO_PIN=0
cd "$SUB2API_TOOLS_DIR/../frontend" || exit 1
exec corepack pnpm "$@"
