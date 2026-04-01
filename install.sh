#!/bin/bash
# install.sh - Linux 安裝腳本

set -euo pipefail

echo "============================================"
echo " Text Saver - Linux 安裝程式"
echo "============================================"
echo

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---- 檢查並安裝依賴 ----
echo "[*] 檢查依賴套件..."

MISSING=()
for cmd in python3 xdotool xclip xbindkeys; do
    if ! command -v "$cmd" &>/dev/null; then
        MISSING+=("$cmd")
        echo "  [MISS] $cmd"
    else
        echo "  [OK]   $cmd"
    fi
done

# notify-send 的套件名稱可能不同
if ! command -v notify-send &>/dev/null; then
    MISSING+=("libnotify-bin")
    echo "  [MISS] notify-send (libnotify-bin)"
else
    echo "  [OK]   notify-send"
fi

if [ ${#MISSING[@]} -gt 0 ]; then
    echo
    echo "缺少套件: ${MISSING[*]}"
    read -r -p "是否自動安裝？(需要 sudo) (y/n): " DO_INSTALL
    if [[ "$DO_INSTALL" =~ ^[Yy]$ ]]; then
        if command -v apt &>/dev/null; then
            sudo apt update -qq && sudo apt install -y "${MISSING[@]}"
        elif command -v dnf &>/dev/null; then
            # Fedora/RHEL 套件名稱不同
            sudo dnf install -y python3 xdotool xclip xbindkeys libnotify 2>/dev/null || true
        elif command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm python xdotool xclip xbindkeys libnotify 2>/dev/null || true
        else
            echo "[ERROR] 無法自動安裝，請手動安裝以上套件"
            exit 1
        fi
    else
        echo "請手動安裝後重新執行此腳本"
        exit 1
    fi
fi

# ---- 設定執行權限 ----
echo
echo "[*] 設定執行權限..."
chmod +x "$SCRIPT_DIR/linux_hotkey.sh"
echo "  [OK] linux_hotkey.sh"

# ---- 建立儲存資料夾 ----
echo
echo "[*] 建立儲存資料夾..."
python3 -c "
import json, os
with open('$SCRIPT_DIR/config.json', 'r', encoding='utf-8') as f:
    config = json.load(f)
for key in ['inbox_folder', 'daily_folder']:
    if key in config:
        folder = os.path.expanduser(config[key])
        os.makedirs(folder, exist_ok=True)
        print(f'  建立: {folder}')
"

# ---- 設定 xbindkeys ----
echo
echo "[*] 設定 xbindkeys 快捷鍵..."

XBINDKEYS_CONF="$HOME/.xbindkeysrc"
BINDING_MARKER="# text-saver-hotkey"

# 如果已有設定，先移除舊的
if [ -f "$XBINDKEYS_CONF" ]; then
    # 移除舊的 text-saver 設定（兩行）
    grep -v "$BINDING_MARKER" "$XBINDKEYS_CONF" | \
    grep -v "linux_hotkey.sh" > /tmp/xbindkeysrc_tmp 2>/dev/null || true
    mv /tmp/xbindkeysrc_tmp "$XBINDKEYS_CONF"
fi

# 加入新設定
cat >> "$XBINDKEYS_CONF" << EOF

$BINDING_MARKER
"$SCRIPT_DIR/linux_hotkey.sh"
  Control+Shift+s
EOF

echo "  [OK] 已寫入 $XBINDKEYS_CONF"

# ---- 設定開機自動啟動 xbindkeys ----
echo
echo "[*] 設定 xbindkeys 開機自動啟動..."

AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

cat > "$AUTOSTART_DIR/xbindkeys.desktop" << EOF
[Desktop Entry]
Type=Application
Name=xbindkeys
Exec=xbindkeys -f $HOME/.xbindkeysrc
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

echo "  [OK] 已建立 $AUTOSTART_DIR/xbindkeys.desktop"

# ---- 重新啟動 xbindkeys ----
echo
echo "[*] 啟動 xbindkeys..."
pkill xbindkeys 2>/dev/null || true
sleep 0.3
xbindkeys -f "$HOME/.xbindkeysrc" &
echo "  [OK] xbindkeys 已啟動 (PID: $!)"

echo
echo "============================================"
echo " 安裝完成！"
echo " 使用方式：選取文字後按 Ctrl+Shift+S 儲存"
echo " 模式設定：編輯 $SCRIPT_DIR/config.json"
echo "============================================"
echo
