#!/bin/bash
# filepath: /home/coydog16/flask/navStupro/scripts/stop_dev_servers.sh

# ProjectStupro開発サーバー停止スクリプト
# 使用法: ./stop_dev_servers.sh

# スクリプトのディレクトリパスを取得
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# プロジェクトのルートディレクトリを取得（scriptsの親ディレクトリ）
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 色の定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}開発サーバーを停止しています...${NC}"

# プロジェクトルートの確認
if [ ! -d "${PROJECT_ROOT}/app/backend" ]; then
    echo -e "${YELLOW}エラー: ProjectStuproのルートディレクトリが見つかりません${NC}"
    echo -e "検出されたプロジェクトルート: ${PROJECT_ROOT}"
    exit 1
fi

# PIDファイルのパスを定義
FRONTEND_PID_FILE="$PROJECT_ROOT/.frontend.pid"
BACKEND_PID_FILE="$PROJECT_ROOT/.backend.pid"

# フロントエンドプロセスの停止処理
if [ -f "$FRONTEND_PID_FILE" ]; then
    FRONTEND_PID=$(cat "$FRONTEND_PID_FILE")
    if ps -p $FRONTEND_PID > /dev/null; then
        kill $FRONTEND_PID
        echo "フロントエンド開発サーバーを停止しました (PID: $FRONTEND_PID)"
    else
        echo "フロントエンド開発サーバーは既に停止しています"
    fi
    rm -f "$FRONTEND_PID_FILE"
else
    echo "フロントエンドPIDファイルが見つかりません"
fi

# バックエンドプロセスの停止処理
if [ -f "$BACKEND_PID_FILE" ]; then
    BACKEND_PID=$(cat "$BACKEND_PID_FILE")
    if ps -p $BACKEND_PID > /dev/null; then
        kill $BACKEND_PID
        echo "バックエンド開発サーバーを停止しました (PID: $BACKEND_PID)"
    else
        echo "バックエンド開発サーバーは既に停止しています"
    fi
    rm -f "$BACKEND_PID_FILE"
else
    echo "バックエンドPIDファイルが見つかりません"
fi

echo -e "${GREEN}すべての開発サーバーが停止しました${NC}"
