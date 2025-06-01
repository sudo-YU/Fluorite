import os
import subprocess
import sys
import pexpect

# Sphinxの設定情報
project_name = "navStupro"
author_name = "nav"
release_version = ""

print(f"以下の設定でSphinxを自動設定します：")
print(f"プロジェクト名: {project_name}")
print(f"著者名: {author_name}")
print(f"リリースバージョン: {release_version or '(空)'}")

# pexpectを使って対話的なプロセスを自動化
try:
    # sphinx-quickstartプロセスを開始（タイムアウトを長めに設定）
    child = pexpect.spawn('sphinx-quickstart', timeout=60)

    # 標準出力にも表示するとデバッグしやすい
    child.logfile = sys.stdout.buffer

    # 各プロンプトに自動回答（正規表現を緩めに設定）
    child.expect(['eparate source', 'eparate source and build'])
    child.sendline('n')  # ソースとビルドディレクトリを分けない

    child.expect(['roject name', 'Project name'])
    child.sendline(project_name)

    child.expect(['uthor name', 'Author name'])
    child.sendline(author_name)

    child.expect(['elease', 'Project release'])
    child.sendline(release_version)

    child.expect(['anguage', 'Project language'])
    child.sendline('ja')  # 日本語を選択

    # プロセスが終了するのを待つ
    child.expect(pexpect.EOF)
    print("Sphinx初期化が完了しました！")

except pexpect.TIMEOUT as e:
    print(f"タイムアウトが発生しました。以下の出力を確認してください:")
    print(f"最後に受け取ったバッファ: {child.before.decode('utf-8', errors='ignore')}")
    sys.exit(1)
except Exception as e:
    print(f"エラーが発生しました: {e}")
    sys.exit(1)
