#Requires Autohotkey v2.0
#SingleInstance Force
#Warn all, off
cwd := A_ScriptDir "\required\"

#Include "*i %A_ScriptDir%\required\convert\ConvertFuncs.ahk"
#Include "*i %A_ScriptDir%\required\convert\converterMod.ahk"
#Include "*i %A_ScriptDir%\required\Include\splash.ahk"
#Include "*i %A_ScriptDir%\required\convert\_vars.ahk"
#Include "*i %A_ScriptDir%\required\convert\github.ahk"

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

setDesignMode()
cleanFiles(FileList)

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

setDesignMode() {
    IniWrite "1", settings, "Options", "DesignMode"
    IniWrite "1", settings, "Options", "SnapToGrid"
    IniWrite "1", settings, "Editor", "DarkTheme"
    IniWrite "0", settings, "Sessions", "AutoLoadLast"
    IniWrite "0", settings, "Sessions", "SaveOnExit"
}

versionCheck(){
    if not FileExist(versionPath){
        try {
            Github.latest("samfisherirl", "Easy-Auto-GUI-for-AHK-v2")
        }
    }
}

errorLogHandler(errorMsg){
    logMsg :=  "error occured at: " FormatTime() " => " errorMsg "`n`n`n"
    writer(logMsg, errorLog)
}
