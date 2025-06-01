#!/bin/bash
# filepath: /home/coydog16/flask/navStupro/scripts/format_code.sh
# format_code.sh
# プロジェクト全体のPythonコードをフォーマットするスクリプト

# スクリプトのディレクトリパスを取得
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# プロジェクトのルートディレクトリを取得（scriptsの親ディレクトリ）
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🔍 Pythonファイルをフォーマットしています..."
black "${PROJECT_ROOT}/app/backend"

echo "✅ フォーマットが完了しました！"
