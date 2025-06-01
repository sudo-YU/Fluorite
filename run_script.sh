#!/bin/bash
# filepath: /home/coydog16/flask/navStupro/run_script.sh

# スクリプトが存在するディレクトリを基準にする
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# スクリプトランチャーに転送（相対パスではなく絶対パスを使用）
"${SCRIPT_DIR}/scripts/run_scripts.sh" "$@"
