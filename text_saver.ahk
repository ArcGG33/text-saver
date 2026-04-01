; Text Saver - Windows AutoHotkey v1 腳本
; 按 Ctrl+Shift+S 儲存選取的文字

#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%

Menu, Tray, Tip, Text Saver (Ctrl+Shift+S)
Menu, Tray, Add, 收集箱模式 (inbox), SetModeInbox
Menu, Tray, Add, 桌面模式 (desktop), SetModeDesktop
Menu, Tray, Add, 每日筆記模式 (daily), SetModeDaily
Menu, Tray, Add
Menu, Tray, Add, 開啟設定檔, OpenConfig
Menu, Tray, Add, 結束, MenuExit

Return

; === 主要熱鍵：Ctrl+Shift+S ===
^+s::
    SavedClip := ClipboardAll
    Clipboard := ""
    Send, ^c
    ClipWait, 1.5
    if (Clipboard = "") {
        ToolTip, Text Saver: 未選取任何文字
        SetTimer, ClearTip, -2000
        Clipboard := SavedClip
        SavedClip := ""
        Return
    }
    TempIn  := A_Temp . "\ts_in.txt"
    TempOut := A_Temp . "\ts_out.txt"
    FileDelete, %TempIn%
    FileDelete, %TempOut%
    FileAppend, %Clipboard%, %TempIn%, UTF-8-RAW
    Clipboard := SavedClip
    SavedClip := ""
    PY := A_ScriptDir . "\text_saver.py"
    RunWait, cmd /c python "%PY%" --file "%TempIn%" > "%TempOut%" 2>&1,, Hide
    FileRead, Result, %TempOut%
    Result := Trim(Result)
    ToolTip, %Result%
    SetTimer, ClearTip, -3000
    FileDelete, %TempIn%
    FileDelete, %TempOut%
    Return

ClearTip:
    ToolTip
    Return

; === 系統匣選單 ===
SetModeInbox:
    GoSub, DoSetMode
    Return
SetModeDesktop:
    GoSub, DoSetMode
    Return
SetModeDaily:
    GoSub, DoSetMode
    Return

DoSetMode:
    if (A_ThisLabel = "SetModeInbox")
        NewMode := "inbox"
    else if (A_ThisLabel = "SetModeDesktop")
        NewMode := "desktop"
    else
        NewMode := "daily"
    ConfigFile := A_ScriptDir . "\config.json"
    FileRead, Cfg, %ConfigFile%
    Cfg := RegExReplace(Cfg, """mode""\s*:\s*""[^""]*""", """mode"": """ . NewMode . """")
    FileDelete, %ConfigFile%
    FileAppend, %Cfg%, %ConfigFile%, UTF-8
    ToolTip, 已切換為：%NewMode% 模式
    SetTimer, ClearTip, -2000
    Return

OpenConfig:
    Run, notepad.exe "%A_ScriptDir%\config.json"
    Return

MenuExit:
    ExitApp
    Return
