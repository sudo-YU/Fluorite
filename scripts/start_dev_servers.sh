#!/bin/bash
# filepath: /home/coydog16/flask/navStupro/scripts/start_dev_servers.sh

# ProjectStupro 開発サーバー起動スクリプト
# 使用法: ./start_dev_servers.sh

# スクリプトのディレクトリパスを取得
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# プロジェクトのルートディレクトリを取得（scriptsの親ディレクトリ）
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 色の定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# プロセス終了関数
cleanup_existing_servers() {
    local pid_file=$1
    local process_name=$2

    if [ -f "$pid_file" ]; then
        local old_pid=$(cat "$pid_file")
        if ps -p $old_pid > /dev/null 2>&1; then
            echo -e "${YELLOW}注意: 既存の${process_name}プロセス(PID: $old_pid)を終了します${NC}"
            kill $old_pid 2>/dev/null || kill -9 $old_pid 2>/dev/null
            sleep 1
        else
            echo -e "${BLUE}情報: 古い${process_name}のPIDファイルを削除します (PID: $old_pid - 既に実行されていません)${NC}"
        fi
        rm -f "$pid_file"
    fi
}

# 使用中のポートをチェックする関数
check_used_ports() {
    local port=$1
    local service_name=$2

    # lsofコマンドでポートが使用中か確認
    if command -v lsof >/dev/null 2>&1; then
        local pid=$(lsof -ti:$port -sTCP:LISTEN)
        if [ ! -z "$pid" ]; then
            echo -e "${YELLOW}警告: ポート $port は既にプロセス $pid によって使用されています${NC}"
            echo -e "${YELLOW}このプロセスを終了してよろしいですか？ [Y/n] ${NC}"
            read -r response
            if [[ "$response" =~ ^([yY]|[yY][eE][sS]|)$ ]]; then
                echo -e "${BLUE}プロセス $pid を終了しています...${NC}"
                kill $pid 2>/dev/null || kill -9 $pid 2>/dev/null
                sleep 1
            else
                echo -e "${YELLOW}${service_name}は別のポートで起動されます${NC}"
            fi
        fi
    fi
}

# メイン処理開始

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}     ProjectStupro 開発サーバー起動     ${NC}"
echo -e "${GREEN}========================================${NC}"

# 必要なディレクトリの存在確認
if [ ! -d "${PROJECT_ROOT}/app/backend" ] || [ ! -d "${PROJECT_ROOT}/app/frontend" ]; then
    echo -e "${YELLOW}エラー: ProjectStuproのルートディレクトリで実行されていないようです${NC}"
    echo -e "現在のディレクトリ: $(pwd)"
    echo -e "検出されたプロジェクトルート: ${PROJECT_ROOT}"
    exit 1
fi

echo -e "${BLUE}プロジェクトルート: ${PROJECT_ROOT}${NC}"

# 既存のサーバープロセスをクリーンアップ

echo -e "\n${BLUE}既存のサーバーがあれば終了しています...${NC}"
cleanup_existing_servers "$PROJECT_ROOT/.frontend.pid" "フロントエンド"
cleanup_existing_servers "$PROJECT_ROOT/.backend.pid" "バックエンド"

# 使用中のポートをチェック
check_used_ports 3000 "フロントエンド"
check_used_ports 5000 "バックエンド"

# フロントエンドサーバーをバックグラウンドで起動

echo -e "\n${BLUE}フロントエンドの開発サーバーを起動しています...${NC}"
cd $PROJECT_ROOT/app/frontend
npm run dev &
FRONTEND_PID=$!

# バックエンドサーバーをバックグラウンドで起動（自動ポート選択機能付き）

echo -e "\n${BLUE}バックエンドの開発サーバーを起動しています...${NC}"
cd $PROJECT_ROOT/app/backend
python run_dev_server.py --debug &
BACKEND_PID=$!

# PIDを記録

echo $FRONTEND_PID > $PROJECT_ROOT/.frontend.pid
echo $BACKEND_PID > $PROJECT_ROOT/.backend.pid

# サーバー情報を表示する関数
display_server_info() {
    local info_file="$PROJECT_ROOT/.backend_server_info.json"

    echo -e "\n${GREEN}開発サーバーが起動しました！${NC}"

    # フロントエンドのURL表示（Viteは自動でポートを選択）
    echo -e "${BLUE}フロントエンド:${NC} http://localhost:3000"

    # バックエンドの情報がJSONファイルにある場合はそこから取得
    if [ -f "$info_file" ]; then
        # jqが使える場合はJSONからポート情報を抽出
        if command -v jq >/dev/null 2>&1; then
            BACKEND_PORT=$(jq -r '.port' < "$info_file")
            BACKEND_HOST=$(jq -r '.host' < "$info_file")
            ORIGINAL_PORT=$(jq -r '.original_port' < "$info_file")

            # ポートが変更された場合のメッセージ表示
            if [ "$BACKEND_PORT" != "$ORIGINAL_PORT" ]; then
                echo -e "${BLUE}バックエンド  :${NC} http://${BACKEND_HOST}:${BACKEND_PORT} " \
                    "${YELLOW}(元のポート ${ORIGINAL_PORT} は使用中のため変更されました)${NC}"
            else
                echo -e "${BLUE}バックエンド  :${NC} http://${BACKEND_HOST}:${BACKEND_PORT}"
            fi
        else
            # jqがない場合はデフォルトの5000ポートとして表示
            echo -e "${BLUE}バックエンド  :${NC} http://localhost:5000"
        fi

        # port_finder.pyでポート状況を表示
        if [ -f "$PROJECT_ROOT/app/backend/port_finder.py" ]; then
            echo -e "\n${BLUE}現在のポート使用状況:${NC}"
            cd $PROJECT_ROOT/app/backend \
                && python port_finder.py scan-ports --start 3000 --count 6
        fi
    else
        # 情報ファイルがない場合はデフォルトのポートとして表示
        echo -e "${BLUE}バックエンド  :${NC} http://localhost:5000"
    fi

    echo -e "\n${YELLOW}サーバーを停止するには stop_dev_servers.sh を実行するか、Ctrl+C を押してください${NC}"
}

# サーバー情報を表示
display_server_info

# トラップを設定してプロセスをクリーンアップ
trap "kill $FRONTEND_PID $BACKEND_PID; rm -f $PROJECT_ROOT/.frontend.pid $PROJECT_ROOT/.backend.pid; echo -e '\n${GREEN}開発サーバーを停止しました${NC}'" EXIT

# スクリプトを終了させないようにする
wait
