#Requires Autohotkey v2.0
;AutoGUI 2.5.8 
;Auto-GUI-v2 credit to autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter credit to github.com/mmikeww/AHK-v2-script-converter 
exe := "`"" A_ScriptDIr "\AutoHotKey Exe\AutoHotkeyV1.exe`" "
autogui := "`"" A_ScriptDIr "\AutoGUI.ahk`""
com := exe autogui
Run(com)
