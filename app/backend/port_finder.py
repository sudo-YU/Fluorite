#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ポート関連のユーティリティ関数

ポートの空き状況をチェックしたり、利用可能なポートを見つけたりするための機能を提供します。
また、システム上のプロセス情報を取得する機能も備えています。
"""
import socket
import logging
import subprocess
import json
import os
import sys
from typing import List, Optional, Dict, Tuple, Union, Any

# ロガーの設定
logger = logging.getLogger(__name__)


def is_port_in_use(port: int) -> bool:
    """
    指定されたポートが使用中かどうかを確認します。

    Args:
        port: チェックするポート番号

    Returns:
        bool: ポートが使用中の場合はTrue、そうでなければFalse
    """
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        try:
            s.bind(("localhost", port))
            return False  # バインドできたので使用されていない
        except socket.error:
            return True  # 既に使用中


def find_available_port(
    start_port: int = 5000, max_attempts: int = 10
) -> Optional[int]:
    """
    利用可能なポートを見つけます。指定されたポートから順番にチェックします。

    Args:
        start_port: チェックを開始するポート番号
        max_attempts: チェックする最大の試行回数

    Returns:
        int or None: 利用可能なポート番号。見つからない場合はNone
    """
    for port_offset in range(max_attempts):
        port = start_port + port_offset
        if not is_port_in_use(port):
            return port

    logger.warning(
        f"利用可能なポートが見つかりません (試行範囲: {start_port}-{start_port + max_attempts - 1})"
    )
    return None


def get_port_suggestions(preferred_port: int = 5000) -> List[int]:
    """
    推奨ポートのリストを取得します。優先ポートが使用できない場合の代替案を提供します。

    Args:
        preferred_port: 優先的に使用したいポート番号

    Returns:
        List[int]: 推奨ポートのリスト
    """
    suggestions = []

    # 優先ポートが利用可能ならそれを追加
    if not is_port_in_use(preferred_port):
        suggestions.append(preferred_port)

    # 他の一般的なポートも候補として追加
    other_ports = [5001, 8000, 8080, 3000, 3001]
    for port in other_ports:
        if port != preferred_port and not is_port_in_use(port):
            suggestions.append(port)

    return suggestions


def get_process_info(pid: int) -> Dict[str, Any]:
    """
    PIDに対応するプロセス情報を取得します。

    Args:
        pid: プロセスID

    Returns:
        Dict[str, Any]: プロセス情報の辞書
    """
    process_info = {
        "pid": pid,
        "exists": False,
        "command": "",
        "user": "",
        "start_time": "",
    }

    try:
        # PS コマンドで詳細なプロセス情報を取得
        ps_output = subprocess.check_output(
            ["ps", "-p", str(pid), "-o", "pid,user,lstart,cmd", "--no-headers"],
            universal_newlines=True,
            stderr=subprocess.DEVNULL,
        ).strip()

        if ps_output:
            process_info["exists"] = True
            parts = ps_output.split(None, 3)
            if len(parts) >= 4:
                process_info["user"] = parts[1]
                process_info["start_time"] = " ".join(parts[2 : len(parts) - 1])
                process_info["command"] = parts[-1]
    except subprocess.SubprocessError:
        pass

    return process_info


def get_ports_used_by_process(pid: int) -> List[int]:
    """
    指定されたプロセスIDが使用しているポート番号のリストを取得します。

    Args:
        pid: プロセスID

    Returns:
        List[int]: プロセスが使用しているポートのリスト
    """
    ports = []
    try:
        # lsofコマンドを使って、指定されたPIDが使用しているポートを取得
        lsof_output = subprocess.check_output(
            ["lsof", "-i", "-P", "-n", "-a", "-p", str(pid)],
            universal_newlines=True,
            stderr=subprocess.DEVNULL,
        )

        for line in lsof_output.splitlines()[1:]:  # ヘッダーをスキップ
            parts = line.split()
            if len(parts) >= 9:
                addr_port = parts[8].split(":")
                if len(addr_port) >= 2 and addr_port[-1].isdigit():
                    port = int(addr_port[-1])
                    if port not in ports:
                        ports.append(port)
    except (subprocess.SubprocessError, FileNotFoundError, ValueError):
        pass

    return ports


def get_process_using_port(port: int) -> Dict[str, Any]:
    """
    指定されたポートを使用しているプロセスの情報を取得します。

    Args:
        port: 検索するポート番号

    Returns:
        Dict[str, Any]: プロセス情報の辞書。ポートが使用されていない場合は空の辞書を返します。
    """
    try:
        # lsofコマンドでポートを使用しているプロセスを検索
        lsof_output = subprocess.check_output(
            ["lsof", "-i", f":{port}", "-P", "-n", "-sTCP:LISTEN"],
            universal_newlines=True,
            stderr=subprocess.DEVNULL,
        )

        if lsof_output:
            lines = lsof_output.strip().splitlines()
            if len(lines) > 1:  # ヘッダー行を除外
                parts = lines[1].split()
                if len(parts) >= 2:
                    pid = int(parts[1])
                    return get_process_info(pid)
    except (subprocess.SubprocessError, FileNotFoundError, ValueError):
        pass

    return {}


def format_port_usage_info(
    port: int, json_output: bool = False
) -> Union[str, Dict[str, Any]]:
    """
    特定のポートの使用状況を人間が読みやすい形式で出力します。

    Args:
        port: 検索するポート番号
        json_output: JSON形式で出力するか（シェルスクリプトとの連携用）

    Returns:
        str または Dict: ポート使用状況の文字列表現またはJSON形式の辞書
    """
    is_used = is_port_in_use(port)
    result = {
        "port": port,
        "is_used": is_used,
        "process": None,
    }

    if is_used:
        process_info = get_process_using_port(port)
        result["process"] = process_info

    if json_output:
        return result
    else:
        if is_used:
            if result["process"]:
                pid = result["process"].get("pid")
                cmd = result["process"].get("command", "不明")
                user = result["process"].get("user", "不明")
                return f"ポート {port} は PID {pid} ({user}) によって使用中: {cmd}"
            else:
                return f"ポート {port} は使用中ですが、プロセス情報を取得できません"
        else:
            return f"ポート {port} は利用可能です"


def scan_ports(
    start_port: int = 5000, count: int = 5, json_output: bool = False
) -> Union[str, Dict[str, Any]]:
    """
    複数のポートの使用状況をスキャンします。

    Args:
        start_port: スキャンを開始するポート番号
        count: スキャンするポート数
        json_output: JSON形式で出力するか（シェルスクリプトとの連携用）

    Returns:
        str または Dict: ポート使用状況の文字列表現またはJSON形式の辞書
    """
    port_infos = []
    for port_offset in range(count):
        port = start_port + port_offset
        info = format_port_usage_info(port, json_output=True)
        port_infos.append(info)

    if json_output:
        return {
            "ports": port_infos,
            "timestamp": subprocess.check_output(
                ["date"], universal_newlines=True
            ).strip(),
        }
    else:
        output = []
        for info in port_infos:
            port = info["port"]
            if info["is_used"]:
                process = info["process"]
                if process:
                    pid = process.get("pid")
                    cmd = process.get("command", "不明")
                    output.append(f"ポート {port}: 使用中 (PID {pid}) - {cmd}")
                else:
                    output.append(f"ポート {port}: 使用中")
            else:
                output.append(f"ポート {port}: 利用可能")

        return "\n".join(output)


# コマンドライン実行のためのエントリポイント
if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="ポートとプロセス情報ユーティリティ")
    subparsers = parser.add_subparsers(dest="command", help="実行するコマンド")

    # is-port-used コマンド
    port_parser = subparsers.add_parser("is-port-used", help="ポートが使用中かを確認")
    port_parser.add_argument("port", type=int, help="チェックするポート番号")

    # find-port コマンド
    find_parser = subparsers.add_parser("find-port", help="利用可能なポートを検索")
    find_parser.add_argument("--start", type=int, default=5000, help="検索を開始するポート番号")
    find_parser.add_argument("--max-attempts", type=int, default=10, help="試行する最大回数")

    # scan-ports コマンド
    scan_parser = subparsers.add_parser("scan-ports", help="複数のポートをスキャン")
    scan_parser.add_argument("--start", type=int, default=5000, help="スキャンを開始するポート番号")
    scan_parser.add_argument("--count", type=int, default=5, help="スキャンするポート数")

    # process-info コマンド
    process_parser = subparsers.add_parser("process-info", help="プロセス情報を取得")
    process_parser.add_argument("pid", type=int, help="プロセスID")

    # 共通オプション
    parser.add_argument("--json", action="store_true", help="JSON形式で出力（シェルスクリプトとの連携用）")

    args = parser.parse_args()

    # JSON形式での出力
    if args.command == "is-port-used":
        result = is_port_in_use(args.port)
        if args.json:
            print(json.dumps({"port": args.port, "is_used": result}))
        else:
            print(f"ポート {args.port} は{'使用中' if result else '利用可能'}です")

    elif args.command == "find-port":
        port = find_available_port(args.start, args.max_attempts)
        if args.json:
            print(json.dumps({"available_port": port}))
        else:
            if port:
                print(f"利用可能なポート: {port}")
            else:
                print(
                    f"ポート {args.start} から {args.start + args.max_attempts - 1} の間に利用可能なポートがありません"
                )
                sys.exit(1)

    elif args.command == "scan-ports":
        result = scan_ports(args.start, args.count, args.json)
        if args.json:
            print(json.dumps(result))
        else:
            print(result)

    elif args.command == "process-info":
        info = get_process_info(args.pid)
        if args.json:
            print(json.dumps(info))
        else:
            if info["exists"]:
                print(f"PID: {info['pid']}")
                print(f"ユーザー: {info['user']}")
                print(f"開始時刻: {info['start_time']}")
                print(f"コマンド: {info['command']}")
                ports = get_ports_used_by_process(args.pid)
                if ports:
                    print(f"使用ポート: {', '.join(map(str, ports))}")
                else:
                    print("使用ポート: なし")
            else:
                print(f"PID {args.pid} のプロセスは存在しません")
                sys.exit(1)
    else:
        parser.print_help()
        sys.exit(1)
