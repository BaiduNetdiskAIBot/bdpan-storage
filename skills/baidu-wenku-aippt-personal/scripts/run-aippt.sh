#!/bin/bash
# AI PPT 生成入口脚本
# 用法: bash run-aippt.sh "<query>" "<title>" "<page>" "<style>" "<scene>" "<color>"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

BDPAN="bdpan"

# 1. 检测渠道
channel=$(bash "$SCRIPT_DIR/detect-agent.sh")

# 2. 调用 bdpan aippt
"$BDPAN" aippt --channel="$channel" "$@"
ret=$?

# 3. 检查更新
bash "$SCRIPT_DIR/check-update.sh"

exit $ret
