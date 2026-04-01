#!/usr/bin/env python3
"""
text_saver.py - 文字選取儲存工具核心腳本（跨平台共用）

用法:
  echo "text" | python text_saver.py
  python text_saver.py --file input.txt
  python text_saver.py --text "要儲存的文字"
"""

import sys
import json
import os
import datetime
import subprocess
import platform


def load_config():
    config_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'config.json')
    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"ERROR: 找不到設定檔 {config_path}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"ERROR: 設定檔格式錯誤 - {e}", file=sys.stderr)
        sys.exit(1)


def expand_path(path):
    return os.path.expanduser(path)


def sanitize_filename(text, max_len=20):
    """將文字轉換為安全的檔名前綴"""
    text = text.replace('\n', ' ').replace('\r', '').strip()
    # 保留英數字、中文、常見符號
    safe_chars = []
    for c in text[:max_len * 2]:
        if c.isalnum() or '\u4e00' <= c <= '\u9fff' or c in ' -_.,':
            safe_chars.append(c)
    safe = ''.join(safe_chars).strip()
    # 空格換底線，限制長度
    safe = safe.replace(' ', '_')[:max_len]
    return safe or datetime.datetime.now().strftime('%Y%m%d_%H%M%S')


def save_text(text, config):
    now = datetime.datetime.now()
    mode = config.get('mode', 'inbox')
    ext = config.get('file_extension', '.txt')

    if mode == 'inbox':
        folder = expand_path(config['inbox_folder'])
        os.makedirs(folder, exist_ok=True)
        timestamp = now.strftime('%Y%m%d_%H%M%S')
        filepath = os.path.join(folder, f"{timestamp}{ext}")
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(text)
        return filepath

    elif mode == 'desktop':
        desktop = expand_path(config['desktop_path'])
        os.makedirs(desktop, exist_ok=True)
        prefix = sanitize_filename(text)
        filepath = os.path.join(desktop, f"{prefix}{ext}")
        # 避免覆蓋同名檔案
        counter = 1
        while os.path.exists(filepath):
            filepath = os.path.join(desktop, f"{prefix}_{counter}{ext}")
            counter += 1
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(text)
        return filepath

    elif mode == 'daily':
        folder = expand_path(config['daily_folder'])
        os.makedirs(folder, exist_ok=True)
        date_str = now.strftime('%Y-%m-%d')
        filepath = os.path.join(folder, f"{date_str}{ext}")
        time_str = now.strftime('%H:%M:%S')
        with open(filepath, 'a', encoding='utf-8') as f:
            f.write(f"\n--- {time_str} ---\n{text}\n")
        return filepath

    else:
        raise ValueError(f"未知的儲存模式: {mode}（可用: inbox, desktop, daily）")


def show_notification(title, message):
    """Linux 通知（Windows 由 AHK 負責顯示）"""
    if platform.system() == 'Linux':
        try:
            subprocess.run(
                ['notify-send', '-t', '3000', '-i', 'document-save', title, message],
                check=False, capture_output=True
            )
        except Exception:
            pass


def get_input_text():
    """從命令列參數或 stdin 取得輸入文字"""
    if len(sys.argv) >= 3 and sys.argv[1] == '--file':
        fpath = sys.argv[2]
        try:
            with open(fpath, 'r', encoding='utf-8-sig') as f:  # utf-8-sig 自動處理 BOM
                return f.read()
        except Exception as e:
            print(f"ERROR: 無法讀取檔案 {fpath} - {e}", file=sys.stderr)
            sys.exit(1)
    elif len(sys.argv) >= 3 and sys.argv[1] == '--text':
        return ' '.join(sys.argv[2:])
    else:
        return sys.stdin.read()


def main():
    config = load_config()
    text = get_input_text().strip()

    if not text:
        print("ERROR: 未取得任何文字", file=sys.stderr)
        sys.exit(1)

    try:
        filepath = save_text(text, config)
        mode = config.get('mode', 'inbox')
        mode_names = {'inbox': '收集箱', 'desktop': '桌面', 'daily': '每日筆記'}
        mode_label = mode_names.get(mode, mode)
        result = f"已儲存到{mode_label}: {filepath}"
        print(result)
        show_notification("Text Saver", result)
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
