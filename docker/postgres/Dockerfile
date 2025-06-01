FROM postgres:17

# 環境変数は直接指定せず、ビルド時の引数やdocker-compose.ymlから注入する形に変更
ENV TZ=Asia/Tokyo

# PostgreSQLの設定ファイルをコピー
COPY ./postgresql.conf /etc/postgresql/postgresql.conf

# 起動コマンド（カスタム設定ファイルを使用）
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
