# NavStupro Project Template

---

## 技術スタック・主要パッケージ一覧

### バックエンド（Python / Flask）
- **Python 3.11**
- **Flask 2.2.3**
- **主なパッケージ**（requirements.txt, requirements-dev.txtより抜粋）
  - flask-cors, flask-sqlalchemy, flask-migrate, flask-jwt-extended, flask-login
  - psycopg2-binary, python-dotenv, gunicorn, celery, redis, email-validator
  - Werkzeug, Jinja2, itsdangerous, Flask-RESTx, pydantic, flask-caching, flask-compress, structlog, Faker
  - 開発用: black, isort, flake8, mypy, pytest, sphinx, sphinx-rtd-theme, sphinx-autodoc-typehints, sphinx-autobuild, pexpect

### フロントエンド（React / TypeScript / Vite）
- **Node.js 24系（Dockerfileでインストール）**
- **React 19, React DOM 19, React Router DOM 7**
- **TypeScript 5系**
- **Vite 5系**
- **主なパッケージ**（package.jsonより抜粋）
  - @tanstack/react-query, zustand, react-hook-form, @headlessui/react, axios
  - @tailwindcss/forms, @tailwindcss/typography, @tailwindcss/vite, tailwindcss, autoprefixer
  - @types/react, @types/react-dom, @types/node, @typescript-eslint/*, eslint, eslint-plugin-react-hooks, eslint-plugin-react-refresh

### インフラ・開発環境
- **Docker / Docker Compose**
  - Ubuntu 22.04ベースの開発用イメージ（Dockerfile）
  - PostgreSQL 17（公式イメージ）
  - pgAdmin 4（DB管理ツール）
  - Volume Trickによるnode_modulesキャッシュ
  - VSCode DevContainer対応

---

## 使い方（自分のgithubアカウントで管理する場合のセットアップ手順）

このテンプレートリポジトリを使って新しいプロジェクトを始める方法は2パターンあります。

### パターン1：GitHubの「Use this template」機能を使う（おすすめ！）

1. **GitHub上でテンプレートリポジトリを開く**
2. 画面右上の「Use this template」ボタンをクリック
3. 新しいリポジトリ名や説明を入力し、「Create repository from template」を押す
4. 自分のアカウントや組織に新しいリポジトリが作成される
5. あとは自分のリポジトリをcloneして、通常通り開発を始めるだけ！

---

### パターン2：git cloneして自分のリポジトリにpushする

1. **テンプレートリポジトリをclone**
   ```bash
   git clone <テンプレートリポジトリのURL> <任意のプロジェクト名>
   cd <任意のプロジェクト名>
   ```
2. **新しいリポジトリをGitHub上で作成**
3. **リモートリポジトリを自分のものに変更**
   ```bash
   git remote set-url origin <自分の新しいリポジトリのURL>
   git push -u origin main
   ```
4. 以降は自分のリポジトリで管理・開発できます

---

どちらの方法でも「自分のアカウントで管理」できるので、好きな方を選んでね！

（この後は、docker-compose.ymlのサービス名やネットワーク名を必要に応じて編集するステップに進んでください）

1. **リポジトリをクローン**
   ```bash
   git clone <このリポジトリのURL> <任意のプロジェクト名>
   cd <任意のプロジェクト名>
   ```
   ※ プロジェクト名（ディレクトリ名）は自由に変更できます。自分の好きな名前でクローンしてOKです！

2. **docker-compose.ymlのサービス名やネットワーク名を編集（必要に応じて）**
   - プロジェクト名や用途に合わせて、`docker-compose.yml` のサービス名（app, db, pgadmin など）やネットワーク名・ボリューム名（appnet, db_data など）を自由に変更できます。
   - 例: `app` → `backend` や `myapp` など、分かりやすい名前にしてOK！
   - 変更した場合は、他の設定ファイル（.envやdevcontainer.jsonなど）も合わせて修正してください。
   - 詳しくはREADMEやdocker/README.mdの補足も参考にしてください。

3. **.envファイルの作成と編集**
   - プロジェクトルートにある`.env-example`をコピーして`.env`ファイルを作成します。
     ```bash
     cp .env-example .env
     ```
   - `.env`ファイルを開いて、データベース名やユーザー名、パスワードなど必要な値を自分のプロジェクト用に入力してください。
   - 例：
     ```env
     //プロジェクトに合わせて好きな名前を設定してください
     POSTGRES_USER=youruser 
     POSTGRES_PASSWORD=yourpassword
     POSTGRES_DB=yourdb
     PGADMIN_DEFAULT_EMAIL=admin@example.com
     PGADMIN_DEFAULT_PASSWORD=adminpassword
     DATABASE_URL=postgresql://youruser:yourpassword@db:5432/yourdb
     ```
   - これらの値はdocker-composeやアプリの起動に必要です。

   

4. **開発コンテナ（DevContainer）を開く**
   - VS Codeで「Remote - Containers」拡張機能を使い、プロジェクトルートで「開発コンテナで再度開く（Reopen in Container）」を選択してください。
   - これにより、必要な依存パッケージやツールが揃った状態で快適に開発できます。
   - ※ 開発コンテナを開くと、Dockerイメージのビルドや必要なサービスのセットアップは自動で行われます。
   - **docker-compose.ymlのサービス名を変更した場合は、.devcontainer/devcontainer.json の "service" の値も同じサービス名に修正してください。**

5. **Docker環境の起動（任意・手動で起動したい場合のみ）**
   ```bash
   docker-compose up --build
   ```
   - バックエンド（Flask API）、フロントエンド（React）、DB（PostgreSQL）がまとめて起動します。
   - 通常は開発コンテナを開くだけでOKですが、手動でDocker Composeを使いたい場合はこちらを実行してください。
   - ※ 開発コンテナ（DevContainer）内では `docker` コマンドは利用できません。ホストOS側のターミナルで実行してください。

6. **開発用サーバーの一括起動（おすすめ！）**
   ```bash
   ./run_script.sh
   ```
   - このスクリプトを実行すると、フロントエンド（React）とバックエンド（Flask）の開発サーバーがまとめて起動します。
   - それぞれ個別に起動する手間が省けて便利です。

7. **フロントエンド開発サーバーの起動（個別で動かしたい場合）**
   ```bash
   cd app/frontend
   npm install
   npm run dev
   ```
   - ホットリロードでフロントエンド開発ができます。

8. **バックエンド開発サーバーの起動（個別で動かしたい場合）**
   ```bash
   cd app/backend
   pip install -r requirements-dev.txt
   python run_dev_server.py
   ```
   - Flaskの開発サーバーが起動します。

---

## ルート直下のフォルダ・ファイル解説

- `app/`  
  バックエンド（Flask）・フロントエンド（React）アプリの本体が入っています。
  - `backend/` … Flask APIサーバー関連のコード・設定
  - `frontend/` … Reactアプリのコード・設定

- `db/`  
  PostgreSQLのデータ永続化や初期化用のファイルを格納します。

- `docker/`  
  Dockerイメージビルドやサービス起動用の各種設定ファイル（Dockerfile等）をまとめています。

- `docs/`  
  設計資料やメモなど、自由にドキュメントを保存するためのフォルダです。

- `scripts/`  
  開発・運用をサポートするシェルスクリプト群です。READMEで各スクリプトの役割も確認できます。

- `docker-compose.yml`  
  開発環境全体を一括で起動・管理するためのDocker Compose設定ファイルです。

- `README.md`  
  このリポジトリの概要・使い方・構成説明などをまとめています。

- `run_script.sh`  
  よく使うコマンドやスクリプトをまとめて実行できるランチャースクリプトです。

---

## 補足：docker-compose.ymlのサービス名・ネットワーク名・ボリューム名について

- サービス名（app, db, pgadmin など）やネットワーク名・ボリューム名（appnet, db_data など）は、
  プロジェクトごとに自由に変更してOKです！
- テンプレートとして使う場合は、プロジェクト名や用途に合わせて分かりやすい名前に変えてください。

---

分からないことや困ったことがあれば、各ディレクトリのREADMEやコメントも参考にしてください！
