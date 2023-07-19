#Requires Autohotkey v2.0
#SingleInstance Force
#Include %A_ScriptDir%\required\convert\ConvertFuncs.ahk
#Include %A_ScriptDir%\required\convert\_menu_handler_mod.ahk
#Include %A_ScriptDir%\required\Include\splash.ahk

cwd := A_ScriptDir "\required"

#Include %A_ScriptDir%\required\convert\_vars.ahk
/*
******************************************************
 *  update feature currently under testing
    #Include %A_ScriptDir%\required\versionCheck.ahk 
    UpdateCheck()
******************************************************
*/
showSplashScreen()

;AutoGUI 2.5.8
;Auto-GUI-v2 credit to autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter credit to github.com/mmikeww/AHK-v2-script-converter

ini := FileRead(sets) ; settings file, find and modify
setDesignMode(ini)

launch_autogui_command_line_param := ahkv1_exe autogui_path     
; concatenate the two paths; for ahkv1.exe and autogui.ahk
Run(launch_autogui_command_line_param, , , &PID)
; run the concatenated command, which launches AutoGUI
Sleep(1000)
findProcess(PID)    ;Loop up to 10 seconds, break when PID exists

While ProcessExist(PID)
; while the AutoGUI process exists
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
                tryRemove(logs)
                try {
                    Converter(inscript, path_to_convert)
                }
                catch {
                    sleep(10)
                    continue
                } } }
    }
    else 
    {
        Sleep(15)
        continue
    }
}
ExitApp()

findProcess(PID){
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
tryRead(path){
    try {
        out := FileRead(path)
        return out
    }
    catch {
        Sleep(10)
        return ""
    }
}
tryRemove(path){
    Loop 5 {
        Try {
            FileMove(path, temps, 1)
            break
        }
        catch {
            Sleep(2)
        }
    }
}

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
    enable := Map("DesignMode", 0, "SnapToGrid", 0, "DarkTheme", 0)
    disable := Map("AutoLoadLast", 0)
    Loop Parse, ini, "`n", "`r" {
        continueStatus:=0
        for searchItem, statusFound in enable {
            if InStr(A_LoopField, searchItem) {
                if (statusFound = 0) {
                    replaceSettings .= searchItem "=1`n"
                    enable.Set(searchItem, 1)
                    continueStatus := 1
                    continue
                }
                else {
                    continueStatus:=1
                    continue
                }
            }
        }
        for searchItem, statusFound in disable {
            if InStr(A_LoopField, searchItem) {
                if (statusFound = 0) {
                    replaceSettings .= searchItem "=0`n"
                    disable.Set(searchItem, 1)
                    continueStatus:=1
                    continue
                }
                else {
                    continueStatus:=1
                    continue
                }
            }
        }
        if (continueStatus = 0) {
            replaceSettings .= A_LoopField "`n"
        }
    }
    f := FileOpen(sets, "w", "utf-8")
    f.Write(replaceSettings)
    f.Close()
}
