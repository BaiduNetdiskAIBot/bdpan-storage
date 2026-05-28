#!/bin/bash
# Skill 更新检查脚本（静默模式）
# 用法: bash check-update.sh
#
# 输出: 有新版本且应提示时输出升级引导文案，否则无输出
# 提示过一次后同版本 7 天内不再提示
# 始终 exit 0，不阻塞 skill 执行

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSION_FILE="${SKILL_DIR}/VERSION"
STATE_DIR="$HOME/.config/bdpan/skill-update-state"
STATE_FILE="${STATE_DIR}/baidu-wenku-aippt-personal.json"
CONFIG_API="https://pan.baidu.com/act/v2/api/conf?conf_key=baidu_wenku_aippt_personal_skill"

TODAY=$(date +%Y-%m-%d)
NOW_TS=$(date +%s)
SEVEN_DAYS=604800

# --- 状态变量 ---
s_last_check_date=""
s_last_check_ts=0
s_last_remote_version=""
s_last_prompted_version=""
s_last_prompt_ts=0
s_last_ignore_version=""
s_last_ignore_ts=0

# --- 工具函数 ---

strip_v_prefix() {
    echo "$1" | sed 's/^v//'
}

version_compare() {
    if [ "$1" = "$2" ]; then return 1; fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do ver1[i]=0; done
    for ((i=0; i<${#ver1[@]}; i++)); do
        if [ -z "${ver2[i]}" ]; then ver2[i]=0; fi
        if ((10#${ver1[i]} > 10#${ver2[i]})); then return 0; fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then return 2; fi
    done
    return 1
}

query_get() {
    local qs="$1" key="$2"
    echo "$qs" | tr '&' '\n' | while IFS='=' read -r k v; do
        if [ "$k" = "$key" ]; then echo "$v"; return 0; fi
    done
}

get_local_version() {
    if [ -f "$VERSION_FILE" ]; then
        local raw=$(cat "$VERSION_FILE" | tr -d '[:space:]')
        strip_v_prefix "$raw"
    else
        echo "unknown"
    fi
}

fetch_remote_version() {
    local response=""
    if command -v curl &> /dev/null; then
        response=$(curl -fsSL --connect-timeout 5 --max-time 10 "$CONFIG_API" 2>/dev/null) || return 1
    elif command -v wget &> /dev/null; then
        response=$(wget -qO- --timeout=10 "$CONFIG_API" 2>/dev/null) || return 1
    else
        return 1
    fi

    local errno=$(echo "$response" | grep -o '"errno"[[:space:]]*:[[:space:]]*[0-9]*' | head -1 | grep -o '[0-9]*$')
    if [ "$errno" != "0" ]; then return 1; fi

    local skills_info=$(echo "$response" | sed 's/\\u0026/\&/g' | grep -o 'version=[^"]*' | head -1 | sed 's/\\//g')
    if [ -z "$skills_info" ]; then return 1; fi

    query_get "$skills_info" "version"
}

# --- 状态文件读写 ---

read_state() {
    if [ ! -f "$STATE_FILE" ]; then return; fi
    s_last_check_date=$(grep -o '"last_check_date"[[:space:]]*:[[:space:]]*"[^"]*"' "$STATE_FILE" 2>/dev/null | grep -o '"[^"]*"$' | tr -d '"')
    s_last_check_ts=$(grep -o '"last_check_ts"[[:space:]]*:[[:space:]]*[0-9]*' "$STATE_FILE" 2>/dev/null | grep -o '[0-9]*$')
    s_last_remote_version=$(grep -o '"last_remote_version"[[:space:]]*:[[:space:]]*"[^"]*"' "$STATE_FILE" 2>/dev/null | grep -o '"[^"]*"$' | tr -d '"')
    s_last_prompted_version=$(grep -o '"last_prompted_version"[[:space:]]*:[[:space:]]*"[^"]*"' "$STATE_FILE" 2>/dev/null | grep -o '"[^"]*"$' | tr -d '"')
    s_last_prompt_ts=$(grep -o '"last_prompt_ts"[[:space:]]*:[[:space:]]*[0-9]*' "$STATE_FILE" 2>/dev/null | grep -o '[0-9]*$')
    s_last_ignore_version=$(grep -o '"last_ignore_version"[[:space:]]*:[[:space:]]*"[^"]*"' "$STATE_FILE" 2>/dev/null | grep -o '"[^"]*"$' | tr -d '"')
    s_last_ignore_ts=$(grep -o '"last_ignore_ts"[[:space:]]*:[[:space:]]*[0-9]*' "$STATE_FILE" 2>/dev/null | grep -o '[0-9]*$')
    : "${s_last_check_ts:=0}"
    : "${s_last_prompt_ts:=0}"
    : "${s_last_ignore_ts:=0}"
}

write_state() {
    mkdir -p "$STATE_DIR"
    cat > "$STATE_FILE" << EOF
{
  "schema_version": 1,
  "skill_name": "baidu-wenku-aippt-personal",
  "last_check_date": "${s_last_check_date}",
  "last_check_ts": ${s_last_check_ts},
  "last_remote_version": "${s_last_remote_version}",
  "last_prompted_version": "${s_last_prompted_version}",
  "last_prompt_ts": ${s_last_prompt_ts},
  "last_ignore_version": "${s_last_ignore_version}",
  "last_ignore_ts": ${s_last_ignore_ts}
}
EOF
}

# --- 主逻辑 ---

main() {
    read_state

    local remote_version=""

    if [ "$s_last_check_date" = "$TODAY" ]; then
        remote_version="$s_last_remote_version"
    else
        remote_version=$(fetch_remote_version) || exit 0
        if [ -z "$remote_version" ]; then exit 0; fi
        s_last_check_date="$TODAY"
        s_last_check_ts=$NOW_TS
        s_last_remote_version="$remote_version"
        write_state
    fi

    if [ -z "$remote_version" ]; then exit 0; fi

    # 比较版本
    local local_version=$(get_local_version)
    if [ "$local_version" = "unknown" ]; then exit 0; fi

    local remote_clean=$(strip_v_prefix "$remote_version")
    set +e
    version_compare "$remote_clean" "$local_version"
    local cmp=$?
    set -e

    # cmp=0 表示远程 > 本地
    if [ $cmp -ne 0 ]; then exit 0; fi

    # 检查提示冷却期：同版本提示过一次后 7 天内不再提示
    local prompted_clean=$(strip_v_prefix "$s_last_prompted_version")
    if [ "$prompted_clean" = "$remote_clean" ] && [ $s_last_prompt_ts -gt 0 ]; then
        local elapsed=$(( NOW_TS - s_last_prompt_ts ))
        if [ $elapsed -lt $SEVEN_DAYS ]; then exit 0; fi
    fi

    # 输出提示并记录（自动开始 7 天冷却）
    s_last_prompted_version="$remote_version"
    s_last_prompt_ts=$NOW_TS
    write_state
    echo "[DISPLAY_VERBATIM_START]"
    echo "温馨提示：检测到新版本迭代，回复\"技能升级\"即可自动完成"
    echo "[DISPLAY_VERBATIM_END]"
}

main "$@"
