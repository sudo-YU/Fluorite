############################################################
# 開発環境ステージ - 依存関係のインストールと環境設定
############################################################
FROM ubuntu:22.04 AS devenv

# ビルド時の引数
ARG USER_ID=1000
ARG GROUP_ID=1000

# Hadolint指摘対策: DL3008
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

# 必要なパッケージのインストール
RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates=* \
    curl=* \
    gnupg=* \
    git=* \
    openssh-client=* \
    vim=* \
    less=* \
    lsb-release=* \
    software-properties-common=* \
    # Python 3.11のセットアップ
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
    python3.11=* \
    python3.11-venv=* \
    python3.11-dev=* \
    python3-pip=* \
    build-essential=* \
    libpq-dev=* \
    # Node.js 24のセットアップ
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install --no-install-recommends -y nodejs=* \
    && npm install -g npm@latest \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    # Pythonの代替設定
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# ユーザー作成
RUN groupadd -g ${GROUP_ID} nav && \
    useradd -l -u ${USER_ID} -g nav -s /bin/bash -m nav

# 環境変数の設定
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV NPM_CONFIG_PREFIX=/home/nav/.npm-global
ENV PATH="/home/nav/.npm-global/bin:$PATH"

# Python仮想環境をセットアップ
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# グローバルのnode開発ツール
RUN npm install -g \
    eslint \
    prettier \
    typescript

# pipをアップグレード（バージョン指定なしで最新へ）
RUN python -m pip install --upgrade pip

# Pythonの開発ツール（requirements-dev.txtで一元管理）
COPY ./app/backend/requirements-dev.txt /tmp/backend/requirements-dev.txt
RUN pip install --no-cache-dir -r /tmp/backend/requirements-dev.txt

# バックエンド依存関係のインストール (requirements.txtがある場合)
WORKDIR /tmp/backend
COPY ./app/backend/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt && \
    chown -R nav:nav /opt/venv

# フロントエンド依存関係のインストール (package.jsonがある場合)
WORKDIR /tmp/frontend
COPY ./app/frontend/package*.json ./

RUN npm install

# ディレクトリ作成と権限設定
RUN mkdir -p /workspace/app/frontend /workspace/app/backend && \
    chown -R nav:nav /workspace

# node_modulesをワークスペースにコピー
RUN cp -r /tmp/frontend/node_modules /workspace/app/frontend/ && \
    chown -R nav:nav /workspace/app/frontend/node_modules

# エントリーポイントスクリプト (権限調整のみ)
COPY ./docker/builder/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 作業ディレクトリ
WORKDIR /workspace

# ユーザー切り替え
USER nav

# エントリーポイント設定
ENTRYPOINT ["/entrypoint.sh"]

# デフォルトのコマンド
CMD ["tail", "-f", "/dev/null"]

############################################################
# DevContainerステージ - VSCodeのDevContainer用
############################################################
FROM devenv AS devcontainer

USER root

# DevContainer用の追加ツールインストール
RUN apt-get update && apt-get install --no-install-recommends -y \
    # 開発に役立つツール
    bash-completion=* \
    jq=* \
    lsof=* \
    htop=* \
    zsh=* \
    bat=* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# VSCode Python拡張機能の依存関係をpipでインストール
RUN pip install --no-cache-dir debugpy

# Oh My Zshのインストール(開発環境を快適に)
RUN chsh -s /usr/bin/zsh nav && \
    su - nav -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

# ユーザー用のbashrc設定を追加
RUN echo 'alias ll="ls -la"' >> /home/nav/.bashrc && \
    echo 'export PS1="\[\033[01;32m\]\u@devcontainer\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> /home/nav/.bashrc

# VSCode用の設定ファイルディレクトリ
RUN mkdir -p /home/nav/.vscode-server/extensions /home/nav/.vscode-server-insiders/extensions && \
    chown -R nav:nav /home/nav/.vscode-server /home/nav/.vscode-server-insiders

# ユーザー切り替え
USER nav

# カスタムZsh設定を追加
RUN echo 'export PATH="/opt/venv/bin:$PATH"' >> /home/nav/.zshrc && \
    echo 'export PYTHONDONTWRITEBYTECODE=1' >> /home/nav/.zshrc && \
    echo 'export PYTHONUNBUFFERED=1' >> /home/nav/.zshrc

# エントリーポイント設定
ENTRYPOINT ["/entrypoint.sh"]

# デフォルトのコマンド
CMD ["tail", "-f", "/dev/null"]
