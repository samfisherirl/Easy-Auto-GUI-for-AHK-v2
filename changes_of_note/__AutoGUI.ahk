; line 1545
run_listener(SelectedFile)
; line 2834
; Launch_AutoGUI listens for [Logs := A_ScriptDir "\log.txt"] to exist, [A_ScriptDir "\complete_application\log.txt"] in Launch_AutoGUI. 
run_listener(SelectedFile){
    /*
    
    q := """"
    exe := q . A_ScriptDIr . "\AutoHotKey Exe\AutoHotkeyV2.exe" . q . " "
    script := q . A_ScriptDIr . "\listener.ahk" . q 
    com := exe . script
    */
    Logs := A_ScriptDir "\log.txt"
    if FileExist(Logs){
        FileDelete, %Logs%
    }
    FileAppend, %SelectedFile%, %Logs%, %Encoding%
}

