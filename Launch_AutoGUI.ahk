#Requires Autohotkey v2.0
#SingleInstance Force
cwd := A_ScriptDir "\required"

#Include "*i %A_ScriptDir%\required\convert\ConvertFuncs.ahk"
#Include "*i %A_ScriptDir%\required\convert\converterMod.ahk"
#Include "*i %A_ScriptDir%\required\Include\splash.ahk"
#Include "*i %A_ScriptDir%\required\convert\_vars.ahk"
#Include "*i %A_ScriptDir%\required\convert\github.ahk"
   
; --- Readme ---
; Alguimist's Easy AutoGUI for AHK-v2 is a GUI designer for creating AHK-v2 scripts with a focus on ease of use.
; It is built on AHKv1 but handles real-time conversion to AHKv2, making it user-friendly for both beginners and advanced users.
; This script acts as a launcher for Easy AutoGUI, handling the conversion process.
; Credits:
; - Easy AutoGUI was created by -Alguimist-, creator of the Adventure IDE: https://sourceforge.net/projects/autogui/.
; - The AHKv2 converter by contributors like https://github.com/mmikeww and https://github.com/dmtr99.
; - The Autohotkey.com forum user "Boiler" provided the MessageBox Creator within the tools menu.
; These individuals' hard work laid the foundation for this project. I played a small part in bringing Easy AutoGUI to AHKv2 by weaving these two solutions together.
; ------------------------------
Main()


; Main function
Main() {
    global PID
    missingFilesPrompt() ; Prompt user if required files are missing
    ,showSplashScreen() ; Display a splash screen
    ,setDesignMode() ; Set the design mode
    ,cleanFiles(FileList) ; Clean temporary files
    ,Run(launch_autogui_cmd, , , &PID) ; Run the AutoGUI command
    ,Sleep(1000)
    hwnd := findEasyAutoGUI(PID) ; Find and wait for Easy AutoGUI to launch
    while ProcessExist(PID) {
        CheckConversionStatus()
    }
    ExitApp()
}
ExitApp()


CheckConversionStatus() {
    while ProcessExist(PID) {
        if FileExist(logsPath) {
            status := tryRead(logsPath)
            inscript := status != "" ? tryRead(ahkv1CodePath) : ""
            if (inscript != "") {
                writer("", logsPath) ; Clear log file
                try {
                    ConvertandCompile(inscript, ahkv2CodePath)
                }
                catch as e {
                    errorLogHandler(e.Message)
                    sleep(5)
                    continue
                }
            }
        } else {
            Sleep(5)
            continue
        }
    }
    ExitApp()
}

; Convert script from AHK v1 to v2
ConvertandCompile(inscript, ahkv2CodePath) {
    script := Convert(inscript)
    ,final_code := modifyAhkv2ConverterOutput(ahkv1CodePath, script)
    ,writer(final_code, ahkv2CodePath)
    ,writer("1", returnStatusPath)
}
; Prompt user about missing files
missingFilesPrompt() {
    msg := { text: "", title: "Missing Files", show: false }

    if not DirExist(cwd) {
        msg.show := true
        msg.text := 'The `'/required/`' directory included with this app is missing. Would you like to download the required files?`nOtherwise, this app will exit.'
    }
    else if not FileExist(cwd "\AutoHotKey Exe\AutoHotkeyV1.exe") {
        msg.text := 'The `'\required\AutoHotKey Exe\AutoHotkeyV1.exe`' file included with this app is missing. `n`nIf you downloaded from the Github code page, you`'ll need the release to run this application.`nOr edit the _vars.ahk file with your ahkv1 64bit exe. `n`nWould you like to download the required files?`nOtherwise, this app will exit.'
        msg.show := true
    }
    else 
    {
        return 
    }
    if msg.show = True
    {
        userResponse := MsgBox(msg.text, msg.title, '52')
        if (userResponse = "Yes") {
            Run("https://github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2/releases")
        }
        ExitApp()
    }
}

; Clean temporary files
cleanFiles(FileList)
{
    for f in FileList {
        writer("", f)
    }
}

; Find Easy AutoGUI process
findEasyAutoGUI(PID) {
    Loop 10 {
        if ProcessExist(PID) {
            break
        }
        else {
            Sleep(1000)
        }
    }
    try 
    {
        return WinGetID("ahk_pid " PID)
    }
}

; Try reading a file
tryRead(path) {
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

; Write to a file
writer(str_to_write := "", path := "") {
    F := FileOpen(path, "w", "utf-8")
    F.Write(str_to_write)
    F.Close()
}


; Set design mode options
setDesignMode() {
    IniWrite "1", settings, "Options", "DesignMode"
    IniWrite "1", settings, "Options", "SnapToGrid"
    IniWrite "1", settings, "Editor", "DarkTheme"
    IniWrite "0", settings, "Sessions", "AutoLoadLast"
    IniWrite "0", settings, "Sessions", "SaveOnExit"
}

; Check for the latest version
versionCheck() {
    if not FileExist(versionPath) {
        try {
            Github.latest("samfisherirl", "Easy-Auto-GUI-for-AHK-v2")
        }
    }
}
; Handle errors and write to the error log
errorLogHandler(errorMsg) {
    logMsg := "error occurred at: " FormatTime() " => " errorMsg "`n`n`n"
    writer(logMsg, errorLog)
}

/*
if __name__ = "__main__"
{*/
/*
}
*/

