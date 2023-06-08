#Requires Autohotkey v2.0
#SingleInstance Force
#Include complete_application\convert\ConvertFuncs.ahk
#Include complete_application\convert\_menu_handler_mod.ahk
;AutoGUI 2.5.8
;Auto-GUI-v2 credit to autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter credit to github.com/mmikeww/AHK-v2-script-converter
exe := "`"" A_ScriptDir "\complete_application\AutoHotKey Exe\AutoHotkeyV1.exe`" " 
exe2 := "`"" A_ScriptDir "\complete_application\AutoHotKey Exe\AutoHotkeyV2.exe`" "     ; specify the path to the AutoHotkey V1 executable
autogui := "`"" A_ScriptDir "\complete_application\AutoGUI.ahk`""   ; specify the path to the AutoGUI script
logs := A_ScriptDir "\complete_application\convert\log.txt"    ; set the path to the log file
empty := A_ScriptDir "\complete_application\convert\empty.txt"    ; set the path to an empty file
temps := A_ScriptDir "\complete_application\convert\temp.txt"    ; set the path to a temporary file
retstat := A_ScriptDir "\complete_application\convert\returnstatus.txt"    ; set the path to the return status file
sets := A_ScriptDir "\complete_application\AutoGUI.ini"
runscript := A_ScriptDir "\complete_application\runscript.ahk"

ini := FileRead(sets)
setDesignMode(ini)

com := exe autogui     ; concatenate the two paths
Run(com, , , &PID)     ; run the concatenated command, which launches AutoGUI
Sleep(1000)    ; wait for 1 second
findProcess(PID)

While ProcessExist(PID)    ; while the AutoGUI process exists
    ; wait for %logs% to exist, that means AutoGui is trying to generate code.
    ; this loop will convert to v2 and notify AutoGUI via %retstat%
{
    if FileExist(logs)    ; check if the log file exists
    {
        path_to_convert := tryRead(logs)    ; read the contents of the log file into a variable
        if path_to_convert && FileExist(path_to_convert)    ; check if the path to the file exists
        {
            inscript := tryRead(path_to_convert)    ; read the contents of the file into a variable
            if (inscript != "")    ; if the variable is not empty
            {
                FileMove(logs, temps, 1)    ; move the log file to the temporary file
                try {
                    Converter(inscript, path_to_convert)
                }
                catch {
                    sleep(10)
                } } }
    }
    else {
        Sleep(15)
        continue
    }
}
ExitApp


Converter(inscript, path_to_convert) {
    global retstat
    script := Convert(inscript)    ; convert the script from AHK v1 to AHK v2
    final_code := add_menuhandler(path_to_convert, script)    ; add menu handlers to the script
    outfile := FileOpen(path_to_convert, "w", "utf-8")    ; open the file for writing
    outfile.Write(final_code)    ; write the final code to the file
    outfile.Close()    ; close the file
    FileAppend(retstat, retstat)    ; append the return status to the return status file
}


setDesignMode(ini) {
    replaceSettings := ""
    x := 0
    Loop Parse, ini, "`n", "`r" {
        if (x == 0) && InStr(A_LoopField, "DesignMode") {
            replaceSettings .= "DesignMode=1`n"
        }
        else if (x == 0) && InStr(A_LoopField, "SnapToGrid") {
            replaceSettings .= "SnapToGrid=1`n"
        }
        else if (x == 0) && InStr(A_LoopField, "DarkTheme") {
            replaceSettings .= "DarkTheme=1`n"
        }
        else if (x == 0) && InStr(A_LoopField, "AutoLoadLast") {
            replaceSettings .= "AutoLoadLast=0`n"
        }
        else {
            replaceSettings .= A_LoopField "`n"
        }
    }
    f := FileOpen(sets, "w", "utf-8")
    f.Write(replaceSettings)
    f.Close()
}

findProcess(PID) {
    Loop 10 {     ; loop up to 10 times
        if ProcessExist(PID) {     ; check if the AutoGUI process exists
            break     ; if it does, break out of the loop
        }
        else {
            Sleep(1000)     ; if it doesn't, wait for 1 second and check again
        }
    }
}
;try {out := FileRead(path)}
tryRead(path) {
    try {
        out := FileRead(path)
        return out
    }
    catch {
        Sleep(10)
        return ""
    }
}
