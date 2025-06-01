#!/bin/bash
set -e

# UID/GID自動調整処理
# 方法1: 明示的に環境変数が指定されている場合
if [ -n "$HOST_UID" ] && [ -n "$HOST_GID" ]; then
    echo "🔄 Setting up user permissions with specified UID: $HOST_UID, GID: $HOST_GID"
    if [ "$HOST_UID" != "1000" ] || [ "$HOST_GID" != "1000" ]; then
        groupmod -g "$HOST_GID" nav
        usermod -u "$HOST_UID" nav

        # 所有権を修正
        find /workspace -user 1000 -exec chown -h $HOST_UID:$HOST_GID {} \; 2>/dev/null || true
        chown -R $HOST_UID:$HOST_GID /home/nav
    fi
# 方法2: 環境変数が指定されていない場合、/workspaceディレクトリの所有権から自動判定
else
    # /workspaceディレクトリのUID/GIDを取得
    WORKSPACE_UID=$(stat -c '%u' /workspace)
    WORKSPACE_GID=$(stat -c '%g' /workspace)

    # デフォルト値と異なる場合のみ調整
    if [ "$WORKSPACE_UID" != "1000" ] || [ "$WORKSPACE_GID" != "1000" ]; then
        echo "🔍 Auto-detected workspace permissions - UID: $WORKSPACE_UID, GID: $WORKSPACE_GID"
        echo "🔄 Automatically adjusting container user permissions..."

        groupmod -g "$WORKSPACE_GID" nav
        usermod -u "$WORKSPACE_UID" nav

        # 所有権を修正
        find /workspace -user 1000 -exec chown -h $WORKSPACE_UID:$WORKSPACE_GID {} \; 2>/dev/null || true
        chown -R $WORKSPACE_UID:$WORKSPACE_GID /home/nav

        echo "✅ User permissions successfully adjusted to match host"
    else
        echo "✅ User permissions already match (UID:1000, GID:1000)"
    fi
fi

echo "🚀 Executing command: $@"
exec "$@"
