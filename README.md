# Text Saver - 文字選取儲存工具

選取任何文字後按 **Ctrl+Shift+S**，即可快速儲存。跨平台支援 Windows 與 Linux。

## 功能特色

- **一鍵儲存**：任何軟體中選取文字後按 Ctrl+Shift+S
- **三種儲存模式**：
  - `inbox` 收集箱：以時間戳記命名，存到指定資料夾
  - `desktop` 桌面：以文字前 20 字作為檔名，存到桌面
  - `daily` 每日筆記：同一天累積到同一個檔案，附時間戳記
- **跨平台**：Windows (AutoHotkey) + Linux (xbindkeys + xdotool)
- **設定簡單**：只需編輯一個 `config.json`

## 專案結構

```
text-saver/
├── text_saver.py       # Python 核心腳本（跨平台共用）
├── text_saver.ahk      # Windows AutoHotkey 腳本
├── linux_hotkey.sh     # Linux 快捷鍵觸發腳本
├── config.json         # 設定檔
├── install.bat         # Windows 安裝腳本
├── install.sh          # Linux 安裝腳本
└── README.md
```

---

## 安裝說明

### Windows

**前置需求：**
- [Python 3.x](https://www.python.org/downloads/)（安裝時勾選 "Add Python to PATH"）
- [AutoHotkey v1.1+](https://www.autohotkey.com/)

**安裝步驟：**

```bat
1. 下載或 clone 此專案
2. 雙擊執行 install.bat
3. 雙擊執行 text_saver.ahk 啟動（或讓安裝程式自動啟動）
```

安裝程式會自動：
- 建立儲存資料夾
- 詢問是否加入開機自動啟動
- 詢問是否立即啟動

---

### Linux

**前置需求：**
- `python3`
- `xdotool` - 模擬鍵盤操作
- `xclip` - 剪貼簿存取
- `xbindkeys` - 全域快捷鍵
- `libnotify-bin` - 桌面通知

**安裝步驟：**

```bash
git clone https://github.com/YOUR_USERNAME/text-saver.git
cd text-saver
bash install.sh
```

安裝程式會自動：
- 安裝缺少的依賴（需要 sudo）
- 建立儲存資料夾
- 設定 xbindkeys 快捷鍵
- 設定開機自動啟動

---

## 設定

編輯 `config.json` 調整儲存行為：

```json
{
  "mode": "inbox",
  "inbox_folder": "~/Documents/TextSaver/inbox",
  "daily_folder": "~/Documents/TextSaver/daily",
  "desktop_path": "~/Desktop",
  "file_extension": ".txt"
}
```

| 設定項目 | 說明 | 預設值 |
|---|---|---|
| `mode` | 儲存模式：`inbox` / `desktop` / `daily` | `inbox` |
| `inbox_folder` | 收集箱資料夾路徑 | `~/Documents/TextSaver/inbox` |
| `daily_folder` | 每日筆記資料夾路徑 | `~/Documents/TextSaver/daily` |
| `desktop_path` | 桌面路徑（desktop 模式使用） | `~/Desktop` |
| `file_extension` | 儲存檔案的副檔名 | `.txt` |

### Windows 快速切換模式

點擊系統匣（右下角）的 Text Saver 圖示，可快速切換模式。

---

## 儲存模式範例

### inbox 模式
```
~/Documents/TextSaver/inbox/
├── 20260401_143022.txt   ← 時間戳記命名
├── 20260401_143156.txt
└── 20260401_161033.txt
```

### desktop 模式
```
~/Desktop/
├── Python是一種直譯式.txt      ← 前20字為檔名
└── The_quick_brown_fox.txt
```

### daily 模式
```
~/Documents/TextSaver/daily/
├── 2026-04-01.txt   ← 同一天追加到同一檔案
└── 2026-04-02.txt

# 2026-04-01.txt 內容：
--- 14:30:22 ---
第一段選取的文字...

--- 16:10:33 ---
第二段選取的文字...
```

---

## 命令列直接使用

Python 腳本也可以獨立使用：

```bash
# 從 stdin 讀取
echo "Hello World" | python3 text_saver.py

# 從檔案讀取
python3 text_saver.py --file input.txt

# 直接傳入文字
python3 text_saver.py --text "要儲存的文字"
```

---

## 上傳到 GitHub

```bash
cd text-saver
git init
git add .
git commit -m "Initial commit: text saver tool"
git remote add origin https://github.com/YOUR_USERNAME/text-saver.git
git branch -M main
git push -u origin main
```

---

## 常見問題

**Q: Windows 按快捷鍵沒反應？**
- 確認 `text_saver.ahk` 正在執行（右下角系統匣應有圖示）
- 確認 AutoHotkey 已安裝

**Q: Linux 快捷鍵沒反應？**
- 確認 xbindkeys 正在執行：`pgrep xbindkeys`
- 手動啟動：`xbindkeys -f ~/.xbindkeysrc`
- 查看綁定設定：`cat ~/.xbindkeysrc`

**Q: 儲存的文字出現亂碼？**
- 確認系統使用 UTF-8 編碼
- Python 腳本使用 UTF-8 儲存，應支援中文等所有語言

**Q: 如何更改儲存位置？**
- 編輯 `config.json` 中的 `inbox_folder` 或 `daily_folder`
- 支援 `~` 家目錄縮寫

---

## 授權

MIT License
