#Requires Autohotkey v2.0
#SingleInstance Force
#Warn all, off
cwd := A_ScriptDir "\required\"

#Include "*i %A_ScriptDir%\required\convert\ConvertFuncs.ahk"
#Include "*i %A_ScriptDir%\required\convert\_menu_handler_mod.ahk"
#Include "*i %A_ScriptDir%\required\Include\splash.ahk"
#Include "*i %A_ScriptDir%\required\github.ahk"
#Include "*i %A_ScriptDir%\required\convert\_vars.ahk"

missingFilesPrompt()
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
cleanFiles(FileList)
launch_autogui_cmd := ahkv1_exe autogui_path
Run(launch_autogui_cmd, , , &PID)
Sleep(1000)
find_easy_autogui_process(PID)
While ProcessExist(PID)
; while the AutoGUI process exists & waits for %logsPath% to have contents,
; AutoGui write to logspath anything but empty, notifying this process code needs to be converted.
; this loop will convert to v2 and notify AutoGUI via %returnStatusPath%
{
    if FileExist(logsPath)
    ; autogui write anything to logfile notified (this)parent process
    {
        status := tryRead(logsPath)
        if (status != "")
        {
            inscript := tryRead(ahkv1CodePath)
            if (inscript != "")
            {
                writer("", logsPath) ; clear
                try {
                    Converter(inscript, ahkv2CodePath)
                }
                catch as e {
                    errorLogHandler(e.Message)
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

missingFilesPrompt(){
    if not DirExist(cwd) {
        userResponse := MsgBox('The `'/required/`' directory included with this app is missing. Would you like to download the required files?`nOtherwise this app will exit.', 'Missing Files', '52')
        if (userResponse = "Yes"){
            Run("https://github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2/releases")
        }
        ExitApp()
    }
}

cleanFiles(FileList)
{
    for f in FileList {
        writer("", f)
    }
}
find_easy_autogui_process(PID){
    Loop 10 {
        if ProcessExist(PID) {
            break
        }
        else {
            Sleep(1000)
        }
    }
}

;try {out := FileRead(path)}
tryRead(path){
    try {
        F := FileOpen(path, "r", "utf-8")
        out := F.Read()
        F.Close()
        return out
    }
    catch as e {
        errorLogHandler(e.Message)
        Sleep(2)
        return ""
    }
}
writer(str_to_write := "", path := ""){
    F := FileOpen(path, "w", "utf-8")
    F.Write(str_to_write)
    F.Close()
}

Converter(inscript, ahkv2CodePath) {
    script := Convert(inscript)    ; convert the script from AHK v1 to AHK v2
    final_code := modifyAhkv2ConverterOutput(ahkv1CodePath, script)    ; add menu handlers to the script
    writer(final_code, ahkv2CodePath)
    writer("1", returnStatusPath)    ; append the return status to the return status file
}

setDesignMode(ini) {
    replaceSettings := ""
    enable := Map("DesignMode", 0, "SnapToGrid", 0, "DarkTheme", 0)
    disable := Map("AutoLoadLast", 0)
    Loop Parse, ini, "`n", "`r" {
        continueStatus:=0
        if (A_LoopField = "") {
            continue
        }
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

errorLogHandler(errorMsg){
    Msg :=  "error occured at: " FormatTime() " => " Msg
    F := FileOpen(errorLog, "a", "utf-8")
    F.Write(errorMsg)
    F.Close()
}
