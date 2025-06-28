import React from "react";

// 仮のページコンポーネント（実装時は各画面用に作り直してね）
const Dashboard = () => <div>ダッシュボード</div>;
const TaskList = () => <div>タスク一覧</div>;
const TaskDetail = () => <div>タスク詳細</div>;
const TaskEdit = () => <div>タスク作成・編集</div>;
const Category = () => <div>カテゴリ管理</div>;
const Tag = () => <div>タグ管理</div>;

interface LabeledRoute {
    path: string;
    element: React.ReactElement;
    label: string;
}

// ルート定義
const routes: LabeledRoute[] = [
    {
        path: "/",
        element: <Dashboard />, // トップページ（ダッシュボード）
        label: "ダッシュボード",
    },
    {
        path: "/tasks",
        element: <TaskList />, // タスク一覧
        label: "タスク一覧",
    },
    {
        path: "/tasks/new",
        element: <TaskEdit />, // タスク新規作成
        label: "タスク作成",
    },
    {
        path: "/tasks/:id",
        element: <TaskDetail />, // タスク詳細
        label: "タスク詳細",
    },
    {
        path: "/tasks/:id/edit",
        element: <TaskEdit />, // タスク編集
        label: "タスク編集",
    },
    {
        path: "/categories",
        element: <Category />, // カテゴリ管理
        label: "カテゴリ管理",
    },
    {
        path: "/tags",
        element: <Tag />, // タグ管理
        label: "タグ管理",
    },
];

export default routes;
