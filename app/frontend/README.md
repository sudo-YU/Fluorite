# NavStupro Project Frontend

このディレクトリには、NavStuproプロジェクトのフロントエンド関連ファイルが格納されています。

## 技術スタック

- React
- TypeScript
- Tailwind CSS v4
- Vite

## 開発環境

Docker Composeを使用して開発環境を起動できます。

```bash
docker-compose up
```

Frontend開発サーバーは http://localhost:3000 で実行されます。

## ディレクトリ・ファイル構成

- `frontend/`  
  Reactアプリのフロントエンド用ディレクトリです。Vite + React + TypeScriptの初期構成を想定しています。
  - `public/` … 静的ファイル（画像やfaviconなど）を格納
  
  - `src/` … Reactアプリのソースコード
    - `main.tsx` … アプリのエントリーポイント
    - `App.tsx` … メインのReactコンポーネント
    - `index.css` … グローバルCSS
    - `App.css` … Appコンポーネント用のCSS
  - `index.html` … アプリのエントリーポイントとなるHTML
  - `index.css` … ルートCSS（Viteの仕様でsrc/index.cssと重複する場合あり）
  - `package.json` … 依存パッケージやスクリプトの管理（※中身は変更しません）
  - `tsconfig.json` … TypeScriptの設定
  - `tsconfig.node.json` … Node.js用TypeScript設定
  - `vite.config.ts` … Viteの設定
  - `README.md` … フォルダ説明

---