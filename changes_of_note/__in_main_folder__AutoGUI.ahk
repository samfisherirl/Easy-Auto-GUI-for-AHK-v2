;line 1545
run_listener(SelectedFile)
;line 2834
run_listener(FileToBeConverted){
    q := """"
    exe := q . A_ScriptDIr . "\AutoHotKey Exe\AutoHotkeyV2.exe" . q . " "
    script := q . A_ScriptDIr . "\listener.ahk" . q 
    com := exe . script
    Log := A_ScriptDir "\log.txt"
    if FileExist(Log){
        FileDelete %Log%
    }
    FileAppend %FileToBeConverted%, %Log%, %Encoding%
    Run, %com%, %A_ScriptDir%
}
