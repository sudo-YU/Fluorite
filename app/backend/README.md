# NavStupro Project Backend

このディレクトリには、NavStuproプロジェクトのバックエンド（Flask API）関連ファイルが格納されています。

## 技術スタック

- Python 3.11
- Flask 2.2.3
- PostgreSQL
- SQLAlchemy

## 開発環境

Docker Composeを使用して開発環境を起動できます。

```bash
docker-compose up
```

Backend APIサーバーは http://localhost:5000 で実行されます。
Nginxリバースプロキシを介して http://localhost/api でアクセスすることもできます。

---

## ディレクトリ・ファイル構成

- `src/`  
  Flaskアプリ本体のコードを格納しています。
  - `__init__.py` … アプリケーションの初期化処理やエントリーポイント

- `docs/`  
  Sphinxで生成するドキュメント関連のファイルや設定をまとめています。
  - `conf.py` … Sphinxの設定ファイル
  - `index.rst` … ドキュメントのトップページ
  - `models.rst` … モデル定義のドキュメント
  - `make.bat`, `Makefile` … ドキュメントビルド用スクリプト

- `port_finder.py`  
  開発時に空いているポートを自動で探すユーティリティスクリプトです。

- `requirements.txt`  
  本番・開発共通のPython依存パッケージ一覧です。

- `requirements-dev.txt`  
  開発用の追加パッケージ一覧です（テストやLint用など）。

- `run_dev_server.py`  
  Flaskアプリの開発サーバーを起動するスクリプトです。

