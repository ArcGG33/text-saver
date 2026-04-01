#!/bin/bash
# linux_hotkey.sh - Linux 快捷鍵觸發腳本
# 由 xbindkeys 在 Ctrl+Shift+S 時呼叫
# 依賴: xdotool, xclip, python3, libnotify-bin

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/text_saver.py"

notify() {
    local title="$1"
    local msg="$2"
    if command -v notify-send &>/dev/null; then
        notify-send -t 3000 -i document-save "$title" "$msg" 2>/dev/null || true
    else
        echo "$title: $msg"
    fi
}

# ---- 檢查依賴 ----
for cmd in xdotool xclip python3; do
    if ! command -v "$cmd" &>/dev/null; then
        notify "Text Saver 錯誤" "缺少依賴: $cmd"
        exit 1
    fi
done

# ---- 取得目前焦點視窗 ----
ACTIVE_WIN=$(xdotool getactivewindow 2>/dev/null || echo "")

# ---- 備份剪貼簿 ----
OLD_CLIP=$(xclip -o -selection clipboard 2>/dev/null || true)

# ---- 模擬 Ctrl+C 複製選取文字 ----
if [ -n "$ACTIVE_WIN" ]; then
    xdotool key --window "$ACTIVE_WIN" --clearmodifiers ctrl+c
else
    xdotool key --clearmodifiers ctrl+c
fi
sleep 0.25

# ---- 讀取剪貼簿 ----
SELECTED=$(xclip -o -selection clipboard 2>/dev/null || true)

# ---- 還原舊剪貼簿 ----
if [ -n "$OLD_CLIP" ]; then
    echo -n "$OLD_CLIP" | xclip -i -selection clipboard 2>/dev/null || true
fi

# ---- 檢查是否有選取文字 ----
if [ -z "$SELECTED" ]; then
    notify "Text Saver" "⚠ 未選取任何文字"
    exit 0
fi

# ---- 呼叫 Python 腳本 ----
RESULT=$(echo "$SELECTED" | python3 "$PYTHON_SCRIPT" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    notify "Text Saver" "$RESULT"
else
    notify "Text Saver 錯誤" "$RESULT"
fi
