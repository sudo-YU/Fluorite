#!/bin/bash
# filepath: /workspace/scripts/build_sphinx_docs.sh

# ターミナルの色を定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# カレントディレクトリを取得
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DOCS_DIR="${PROJECT_ROOT}/app/backend/docs"

echo -e "${BLUE}Sphinxドキュメントをビルドします...${NC}"

# ドキュメントディレクトリに移動
cd "$DOCS_DIR" || {
    echo -e "${RED}エラー: ドキュメントディレクトリ ${DOCS_DIR} に移動できません${NC}"
    exit 1
}

# ビルドフォーマットの選択肢を表示
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}      Sphinxドキュメントビルダー       ${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${BLUE}ビルドフォーマットを選択:${NC}"
echo -e "1. HTML (標準ウェブページ)"
echo -e "2. PDF (LaTeXが必要)"
echo -e "3. ePub (電子書籍形式)"
echo -e "4. すべてのフォーマット"
echo -e "0. キャンセル"
echo ""

# フォーマット選択
read -p "ビルドしたいフォーマット番号を入力してください: " format_choice

case $format_choice in
    1)
        echo -e "${BLUE}HTMLドキュメントをビルドします...${NC}"
        python setup_make.py html
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}HTMLドキュメントのビルドが完了しました！${NC}"
            echo -e "結果は ${DOCS_DIR}/_build/html/ ディレクトリにあります"
        else
            echo -e "${RED}HTMLドキュメントのビルドに失敗しました${NC}"
            exit 1
        fi
        ;;
    2)
        echo -e "${BLUE}PDFドキュメントをビルドします...${NC}"
        python setup_make.py latexpdf
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}PDFドキュメントのビルドが完了しました！${NC}"
            echo -e "結果は ${DOCS_DIR}/_build/latex/ ディレクトリにあります"
        else
            echo -e "${RED}PDFドキュメントのビルドに失敗しました${NC}"
            echo -e "LaTeXがインストールされていることを確認してください"
            exit 1
        fi
        ;;
    3)
        echo -e "${BLUE}ePubドキュメントをビルドします...${NC}"
        python setup_make.py epub
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}ePubドキュメントのビルドが完了しました！${NC}"
            echo -e "結果は ${DOCS_DIR}/_build/epub/ ディレクトリにあります"
        else
            echo -e "${RED}ePubドキュメントのビルドに失敗しました${NC}"
            exit 1
        fi
        ;;
    4)
        echo -e "${BLUE}すべてのフォーマットでドキュメントをビルドします...${NC}"

        echo -e "${YELLOW}HTMLビルド中...${NC}"
        python setup_make.py html

        echo -e "${YELLOW}PDFビルド中...${NC}"
        python setup_make.py latexpdf

        echo -e "${YELLOW}ePubビルド中...${NC}"
        python setup_make.py epub

        echo -e "${GREEN}すべてのフォーマットのビルドが完了しました！${NC}"
        echo -e "結果は ${DOCS_DIR}/_build/ ディレクトリ内にあります"
        ;;
    0)
        echo -e "${YELLOW}ビルドをキャンセルしました${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}無効な選択です。もう一度試してください。${NC}"
        exit 1
        ;;
esac

# ライブプレビューの提案
if [ "$format_choice" == "1" ] || [ "$format_choice" == "4" ]; then
    echo ""
    read -p "HTMLドキュメントのライブプレビューを起動しますか？ (y/n): " preview_choice
    if [[ $preview_choice =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}ライブプレビューを開始します...${NC}"
        echo -e "${YELLOW}終了するには Ctrl+C を押してください${NC}"
        sphinx-autobuild . _build/html --host 0.0.0.0 --port 8000
    fi
fi

exit 0
