; Text Saver - Windows AutoHotkey 腳本
; 按 Ctrl+Shift+S 儲存選取的文字
; 需要 AutoHotkey v1.1+ (https://www.autohotkey.com/)

#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%

; 系統匣圖示
Menu, Tray, Tip, Text Saver (Ctrl+Shift+S)
Menu, Tray, Add, 切換模式 - 收集箱 (inbox), SetModeInbox
Menu, Tray, Add, 切換模式 - 桌面 (desktop), SetModeDesktop
Menu, Tray, Add, 切換模式 - 每日筆記 (daily), SetModeDaily
Menu, Tray, Add, --- ; 分隔線
Menu, Tray, Add, 開啟設定檔, OpenConfig
Menu, Tray, Add, 結束, ExitApp

; =============================================
; 主要熱鍵：Ctrl+Shift+S
; =============================================
^+s::
    ; 備份剪貼簿
    SavedClip := ClipboardAll
    Clipboard := ""

    ; 複製選取的文字
    Send, ^c
    ClipWait, 1.5

    if (Clipboard = "") {
        ShowTip("Text Saver", "⚠ 未選取任何文字")
        Clipboard := SavedClip
        SavedClip := ""
        Return
    }

    ; 將剪貼簿內容寫入暫存檔（UTF-8-RAW 不含 BOM）
    TempInput  := A_Temp . "\text_saver_in.txt"
    TempOutput := A_Temp . "\text_saver_out.txt"

    FileDelete, %TempInput%
    FileDelete, %TempOutput%
    FileAppend, %Clipboard%, %TempInput%, UTF-8-RAW

    ; 還原剪貼簿
    Clipboard := SavedClip
    SavedClip := ""

    ; 呼叫 Python 腳本
    PythonScript := A_ScriptDir . "\text_saver.py"
    RunWait, cmd /c python "%PythonScript%" --file "%TempInput%" > "%TempOutput%" 2>&1,, Hide

    ; 讀取執行結果
    FileRead, Result, %TempOutput%
    Result := Trim(Result)

    ; 顯示提示訊息
    if (InStr(Result, "ERROR"))
        ShowTip("Text Saver 錯誤", Result, 4000)
    else
        ShowTip("Text Saver", Result)

    ; 清理暫存檔
    FileDelete, %TempInput%
    FileDelete, %TempOutput%
    Return

; =============================================
; 系統匣選單功能
; =============================================
SetModeInbox:
    SetMode("inbox")
    Return

SetModeDesktop:
    SetMode("desktop")
    Return

SetModeDaily:
    SetMode("daily")
    Return

SetMode(mode) {
    ConfigFile := A_ScriptDir . "\config.json"
    FileRead, ConfigContent, %ConfigFile%
    ConfigContent := RegExReplace(ConfigContent, """mode""\s*:\s*""[^""]*""", """mode"": """ . mode . """")
    FileDelete, %ConfigFile%
    FileAppend, %ConfigContent%, %ConfigFile%, UTF-8
    ModeNames := {inbox: "收集箱", desktop: "桌面", daily: "每日筆記"}
    ShowTip("Text Saver", "已切換模式為：" . ModeNames[mode])
}

OpenConfig:
    Run, notepad.exe "%A_ScriptDir%\config.json"
    Return

ExitApp:
    ExitApp
    Return

; =============================================
; 輔助函數：顯示工具提示
; =============================================
ShowTip(title, msg, duration := 3000) {
    ToolTip, %title%`n%msg%
    SetTimer, RemoveToolTip, -%duration%
}

RemoveToolTip:
    ToolTip
    Return
