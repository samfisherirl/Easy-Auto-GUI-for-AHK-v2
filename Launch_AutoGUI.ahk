#Requires Autohotkey v2.0
exe := "`"" A_ScriptDIr "\AutoHotKey Exe\AutoHotkeyV1.exe`" "
autogui := "`"" A_ScriptDIr "\AutoGUI.ahk`""
com := exe autogui
Run(com)