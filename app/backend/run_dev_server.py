#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Flask開発サーバー実行スクリプト

自動ポート検出機能付きでFlaskサーバーを起動します。
既に使用中のポートを検出し、空きポートを自動的に選択します。
"""
import os
import sys
import argparse
import subprocess
import json
from pathlib import Path

# アプリケーションのパスを追加
app_path = Path(__file__).parent
sys.path.insert(0, str(app_path))

# 必要なモジュールのインポート - 同一ディレクトリの直接インポート
from port_finder import find_available_port

DEFAULT_PORT = 5000
DEFAULT_HOST = "0.0.0.0"


def parse_arguments():
    """
    コマンドライン引数のパース
    """
    parser = argparse.ArgumentParser(description="Flask開発サーバー自動起動スクリプト")
    parser.add_argument(
        "--port",
        type=int,
        default=DEFAULT_PORT,
        help=f"起動を試みる優先ポート (デフォルト: {DEFAULT_PORT})",
    )
    parser.add_argument(
        "--host",
        type=str,
        default=DEFAULT_HOST,
        help=f"Flaskサーバーのホスト (デフォルト: {DEFAULT_HOST})",
    )
    parser.add_argument(
        "--debug",
        action="store_true",
        help="デバッグモードを有効化",
    )

    return parser.parse_args()


def main():
    """
    メイン関数
    """
    args = parse_arguments()

    # 利用可能なポートを見つける
    port = find_available_port(args.port)
    if port is None:
        print(f"エラー: {args.port}～{args.port + 9}の間で利用可能なポートが見つかりません。")
        sys.exit(1)

    # 環境変数の設定
    os.environ["FLASK_APP"] = "app.py"  # app.pyファイル自体の名前は変更なし
    if args.debug:
        os.environ["FLASK_DEBUG"] = "1"

    # ポートをセット
    os.environ["FLASK_RUN_PORT"] = str(port)
    os.environ["FLASK_RUN_HOST"] = args.host

    print(f"Flaskサーバーを起動しています: {args.host}:{port}")
    if port != args.port:
        print(f"注意: 指定されたポート {args.port} は使用中のため、ポート {port} を使用します")

    # 使用するポート情報をファイルに保存（start_dev_servers.shでの表示に利用）
    server_info = {
        "host": args.host,
        "port": port,
        "original_port": args.port,
        "pid": os.getpid(),
        "app": "Flask",
        "timestamp": subprocess.check_output(["date"], universal_newlines=True).strip(),
    }

    # JSONファイルに保存
    project_root = os.environ.get("PROJECT_ROOT", "/workspace")
    info_file = os.path.join(project_root, ".backend_server_info.json")
    with open(info_file, "w") as f:
        json.dump(server_info, f)

    # Flask runコマンドを実行
    print("Flaskサーバーを起動するためのコマンドを実行します")
    os.system(f"flask run --host={args.host} --port={port}")


if __name__ == "__main__":
    main()
