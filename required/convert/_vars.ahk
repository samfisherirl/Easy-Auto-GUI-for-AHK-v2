
ahkv1_exe := "`"" cwd "\AutoHotKey Exe\AutoHotkeyV1.exe`" "
ahkv2_exe := "`"" cwd "\AutoHotKey Exe\AutoHotkeyV2.exe`" "     ; specify the path to the AutoHotkey V1 executable
autogui_path := "`"" cwd "\AutoGUI.ahk`""   ; specify the path to the AutoGUI script
launch_autogui_cmd := ahkv1_exe autogui_path
logsPath := cwd "\convert\log.txt"    ; set the path to the log file
empty := cwd "\convert\empty.txt"    ; set the path to an empty file
temps := cwd "\convert\temp.txt"    ; set the path to a temporary file
returnStatusPath := cwd "\convert\returnstatus.txt"    ; set the path to the return status file
ahkv2CodePath := cwd "\convert\returncode.txt"    ; set the path to the return status file
ahkv1CodePath := cwd "\convert\runtime.txt"    ; set the path to the return status file
settings := cwd "\AutoGUI.ini"
runscript := cwd "\runscript.ahk"
errorLog := cwd "\errorLog.txt"
versionPath := cwd "\version.json"

FileList := [logsPath, empty, temps, returnStatusPath, ahkv2CodePath, ahkv1CodePath]
