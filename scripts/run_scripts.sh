#!/bin/bash
# filepath: /home/coydog16/flask/navStupro/scripts/run_scripts.sh

# ターミナルの色を定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# カレントディレクトリを取得
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# スクリプト一覧を表示
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}     NavStupro スクリプトランチャー     ${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${BLUE}実行可能なスクリプト:${NC}"
echo -e "1. Docker環境をクリーンアップ (docker_clean.sh)"
echo -e "2. コードをフォーマット (format_code.sh)"
echo -e "3. 開発サーバーを起動 (start_dev_servers.sh)"
echo -e "4. 開発サーバーを停止 (stop_dev_servers.sh)"
echo -e "5. Sphinxドキュメントをビルド (build_sphinx_docs.sh)"
echo -e "0. 終了"
echo ""

# スクリプト選択
read -p "実行したいスクリプト番号を入力してください: " choice

# 選択されたスクリプトを実行
case $choice in
    1)
        echo -e "${BLUE}Docker環境をクリーンアップします...${NC}"
        $SCRIPT_DIR/docker_clean.sh
        ;;
    2)
        echo -e "${BLUE}コードをフォーマットします...${NC}"
        $SCRIPT_DIR/format_code.sh
        ;;
    3)
        echo -e "${BLUE}開発サーバーを起動します...${NC}"
        $SCRIPT_DIR/start_dev_servers.sh
        ;;
    4)
        echo -e "${BLUE}開発サーバーを停止します...${NC}"
        $SCRIPT_DIR/stop_dev_servers.sh
        ;;
    5)
        echo -e "${BLUE}Sphinxドキュメントのビルドを開始します...${NC}"
        $SCRIPT_DIR/build_sphinx_docs.sh
        ;;
    0)
        echo -e "${GREEN}スクリプトランチャーを終了します。${NC}"
        exit 0
        ;;
    *)
        echo -e "${YELLOW}無効な選択です。もう一度試してください。${NC}"
        ;;
esac
