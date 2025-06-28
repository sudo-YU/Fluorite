# タスク管理アプリ テーブル設計書

## 概要

このドキュメントは、タスク管理アプリの要件定義に基づくデータベーステーブル設計をまとめたものです。

---

## 1. users（ユーザー）

| カラム名   | 型           | 制約             | 説明                 |
| ---------- | ------------ | ---------------- | -------------------- |
| id         | SERIAL       | PRIMARY KEY      | ユーザー ID          |
| username   | VARCHAR(80)  | UNIQUE, NOT NULL | ユーザー名           |
| email      | VARCHAR(255) | UNIQUE, NOT NULL | メールアドレス       |
| password   | VARCHAR(255) | NOT NULL         | パスワード(ハッシュ) |
| created_at | TIMESTAMP    | DEFAULT now()    | 登録日時             |

---

## 2. tasks（タスク）

| カラム名    | 型           | 制約          | 説明                 |
| ----------- | ------------ | ------------- | -------------------- |
| id          | SERIAL       | PRIMARY KEY   | タスク ID            |
| user_id     | INTEGER      | FOREIGN KEY   | 所有ユーザー         |
| title       | VARCHAR(255) | NOT NULL      | タイトル             |
| description | TEXT         |               | 説明                 |
| due_date    | DATE         |               | 期限                 |
| priority    | INTEGER      |               | 優先度（1:低〜3:高） |
| color       | VARCHAR(20)  |               | 色（ラベル用）       |
| status      | VARCHAR(20)  | NOT NULL      | 進捗ステータス       |
| category_id | INTEGER      | FOREIGN KEY   | カテゴリ             |
| created_at  | TIMESTAMP    | DEFAULT now() | 作成日時             |
| updated_at  | TIMESTAMP    | DEFAULT now() | 更新日時             |

---

## 3. categories（カテゴリ）

| カラム名 | 型          | 制約        | 説明           |
| -------- | ----------- | ----------- | -------------- |
| id       | SERIAL      | PRIMARY KEY | カテゴリ ID    |
| user_id  | INTEGER     | FOREIGN KEY | 所有ユーザー   |
| name     | VARCHAR(80) | NOT NULL    | カテゴリ名     |
| color    | VARCHAR(20) |             | 色（ラベル用） |

---

## 4. tags（タグ）

| カラム名 | 型          | 制約        | 説明           |
| -------- | ----------- | ----------- | -------------- |
| id       | SERIAL      | PRIMARY KEY | タグ ID        |
| user_id  | INTEGER     | FOREIGN KEY | 所有ユーザー   |
| name     | VARCHAR(80) | NOT NULL    | タグ名         |
| color    | VARCHAR(20) |             | 色（ラベル用） |

---

## 5. task_tags（タスク-タグ中間テーブル）

| カラム名                     | 型      | 制約        | 説明      |
| ---------------------------- | ------- | ----------- | --------- |
| task_id                      | INTEGER | FOREIGN KEY | タスク ID |
| tag_id                       | INTEGER | FOREIGN KEY | タグ ID   |
| PRIMARY KEY(task_id, tag_id) |         | 複合主キー  |

---

## 6. subtasks（サブタスク/チェックリスト）

| カラム名 | 型           | 制約          | 説明          |
| -------- | ------------ | ------------- | ------------- |
| id       | SERIAL       | PRIMARY KEY   | サブタスク ID |
| task_id  | INTEGER      | FOREIGN KEY   | 親タスク ID   |
| title    | VARCHAR(255) | NOT NULL      | サブタスク名  |
| is_done  | BOOLEAN      | DEFAULT FALSE | 完了フラグ    |

---

## 備考

-   各テーブルの user_id でユーザーごとにデータを分離
-   タグは多対多のため中間テーブル（task_tags）を用意
-   サブタスクは親タスクに紐づく形で管理
-   拡張性を考慮し、カテゴリ・タグ・色は任意設定可能

---

この設計をもとに、SQLAlchemy モデルやマイグレーションを作成していくと良いよ！
