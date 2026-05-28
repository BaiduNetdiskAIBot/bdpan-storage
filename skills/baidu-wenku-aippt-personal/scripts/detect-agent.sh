#!/bin/bash
# 检测当前运行环境的 Agent 渠道，输出枚举值到 stdout
# 用法: channel=$(bash detect-agent.sh)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "${CLIENT_INFO_IDE_TYPE:-}" = "WorkBuddy" ] || \
   [ "${CLIENT_INFO_PLATFORM:-}" = "WorkBuddy" ] || \
   [ "${CLIENT_INFO_PRODUCT_NAME:-}" = "WorkBuddy" ]; then
  echo "workbuddy"
  exit 0
fi
if [[ "${CODEBUDDY_HOST:-}" == workbuddy* ]] || \
   [[ "${CODEBUDDY_CONFIG_DIR:-}" == *".workbuddy"* ]]; then
  echo "workbuddy"
  exit 0
fi

if [[ "$SCRIPT_DIR" == *".openclaw-autoclaw"* ]]; then
  echo "autoclaw"
  exit 0
fi

if [[ "$SCRIPT_DIR" == *"qianfan/workspace"* ]] || \
   [[ "$SCRIPT_DIR" == *"qianfan_desk_xdg"* ]]; then
  echo "dumate"
  exit 0
fi

_path_lower="$(echo "$SCRIPT_DIR" | tr '[:upper:]' '[:lower:]')"
if [[ "$_path_lower" =~ (^|/)(\.qclaw|qclaw)(/|$) ]]; then
  echo "qclaw"
  exit 0
fi

if [[ "$SCRIPT_DIR" == *".openclaw"* ]] && { [ -d "/root/.kimi/kimi-claw" ] || [ -d "$HOME/.kimi/kimi-claw" ]; }; then
  echo "kimiclaw"
  exit 0
fi

if [[ "$SCRIPT_DIR" == /workspace/* ]] && { [ -d "/root/.maxclaw" ] || [ -d "$HOME/.maxclaw" ]; }; then
  echo "maxclaw"
  exit 0
fi

if [ "${CLAUDECODE:-}" = "1" ] || \
   [[ "${AI_AGENT:-}" == *"claude-code"* ]] || \
   [ -n "${CLAUDE_CODE_SESSION_ID:-}" ] || \
   [ -n "${CLAUDE_CODE_ENTRY_POINT:-}" ]; then
  echo "claudecode"
  exit 0
fi

if [ "${CODEX_ENV:-}" = "1" ] || \
   [ "${CODEX_SHELL:-}" = "1" ] || \
   [ -n "${CODEX_THREAD_ID:-}" ] || \
   [ "${CODEX_CI:-}" = "1" ] || \
   [ -n "${CODEX_INTERNAL_ORIGINATOR_OVERRIDE:-}" ] || \
   [[ "${AI_AGENT:-}" == *"codex"* ]]; then
  echo "codex"
  exit 0
fi

if [ -n "${EASYCLAW_REGION:-}" ] || \
   [ -n "${EASYCLAW_APP_LANGUAGE:-}" ] || \
   [[ "${OPENCLAW_HOME:-}" == *"/.easyclaw" ]] || \
   [ -n "${EASYCLAW_RPC_PORT:-}" ]; then
  echo "easyclaw"
  exit 0
fi

if [[ "$_path_lower" =~ (^|/)(\.openclaw|openclaw)(/|$) ]] && [ "${OPENCLAW_CLI:-}" = "1" ]; then
  echo "openclaw"
  exit 0
fi

# fallback: 路径含 .openclaw 但未匹配到具体子渠道（kimiclaw/autoclaw 等）
if [[ "$_path_lower" =~ (^|/)(\.openclaw|openclaw)(/|$) ]]; then
  echo "openclaw"
  exit 0
fi

echo "unknown"
