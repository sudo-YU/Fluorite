import React from "react";
import App from "./App";

interface LabeledRoute {
    path: string;
    element: React.ReactElement;
    label: string;
}

// ルート定義
const routes: LabeledRoute[] = [
    {
        path: "/",
        element: <App />, // トップページはAppコンポーネントのみ表示
        label: "App",
    },
];

export default routes;
