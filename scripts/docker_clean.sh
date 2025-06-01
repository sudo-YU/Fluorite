#!/bin/bash
# filepath: /home/coydog16/flask/navStupro/scripts/docker_clean.sh

# スクリプトのディレクトリパスを取得
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# プロジェクトのルートディレクトリを取得（scriptsの親ディレクトリ）
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# ターミナルの色を定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 実行前の確認
echo -e "${YELLOW}⚠️  警告: このスクリプトはすべてのDockerリソースを削除します${NC}"
echo -e "${YELLOW}   - すべてのコンテナ (実行中・停止中)"
echo -e "   - すべてのイメージ"
echo -e "   - すべてのボリューム (データベースなどのデータ含む)"
echo -e "   - すべてのネットワーク${NC}"
echo ""
read -p "本当に実行しますか？ (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
    echo -e "${BLUE}キャンセルしました${NC}"
    exit 0
fi

echo -e "${YELLOW}Dockerリソースをクリーンアップしています...${NC}"

# navStupro関連のコンテナを停止・削除
echo -e "${BLUE}1. navStupro関連のコンテナを停止・削除しています...${NC}"
cd "${PROJECT_ROOT}" && docker-compose down -v --remove-orphans || true
echo -e "${GREEN}   完了！${NC}"

# すべてのコンテナを停止
echo -e "${BLUE}2. すべてのコンテナを停止しています...${NC}"
docker stop $(docker ps -aq) 2>/dev/null || echo "   停止するコンテナはありませんでした"
echo -e "${GREEN}   完了！${NC}"

# すべてのコンテナを削除
echo -e "${BLUE}3. すべてのコンテナを削除しています...${NC}"
docker rm $(docker ps -aq) 2>/dev/null || echo "   削除するコンテナはありませんでした"
echo -e "${GREEN}   完了！${NC}"

# すべてのイメージを削除
echo -e "${BLUE}4. すべてのイメージを削除しています...${NC}"
docker rmi $(docker images -q) --force 2>/dev/null || echo "   削除するイメージはありませんでした"
echo -e "${GREEN}   完了！${NC}"

# すべてのボリュームを削除
echo -e "${BLUE}5. すべてのボリュームを削除しています...${NC}"
docker volume rm $(docker volume ls -q) 2>/dev/null || echo "   削除するボリュームはありませんでした"
echo -e "${GREEN}   完了！${NC}"

# すべてのネットワークを削除（デフォルトネットワークは削除できないので除外）
echo -e "${BLUE}6. カスタムネットワークを削除しています...${NC}"
docker network prune -f
echo -e "${GREEN}   完了！${NC}"

# Docker システム全体のクリーンアップ
echo -e "${BLUE}7. Docker システム全体をクリーンアップしています...${NC}"
docker system prune -a -f --volumes
echo -e "${GREEN}   完了！${NC}"

echo ""
echo -e "${GREEN}✅ すべてのDockerリソースがきれいに削除されました！${NC}"
echo -e "${BLUE}新しい環境を作成するには次のコマンドを実行してください：${NC}"
echo -e "${BLUE}cd \"${PROJECT_ROOT}\" && docker-compose up -d${NC}"
