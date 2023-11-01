#Requires Autohotkey v2.0
#SingleInstance Force
cwd := A_ScriptDir "\required\"

#Include "*i %A_ScriptDir%\required\convert\ConvertFuncs.ahk"
#Include "*i %A_ScriptDir%\required\convert\converterMod.ahk"
#Include "*i %A_ScriptDir%\required\Include\splash.ahk"
#Include "*i %A_ScriptDir%\required\convert\_vars.ahk"
#Include "*i %A_ScriptDir%\required\convert\github.ahk"
   
; --- Readme ---
; Easy AutoGUI for AHK-v2 is a GUI designer for creating AHK-v2 scripts with a focus on ease of use.
; It is built on AHKv1 but handles real-time conversion to AHKv2, making it user-friendly for both beginners and advanced users.
; This script acts as a launcher for Easy AutoGUI, handling the conversion process.
; Credits:
; - Easy AutoGUI was originally created by Alguimist  https://sourceforge.net/projects/autogui/.
; - The AHKv2 converter by contributors like https://github.com/mmikeww and https://github.com/dmtr99.
; - The Autohotkey.com forum user "Boiler" provided the MessageBox Creator within the tools menu.
; These individuals' hard work laid the foundation for this project. I played a small part in bringing Easy AutoGUI to AHKv2 by weaving these two solutions together.
; ------------------------------

; Prompt user if required files are missing
missingFilesPrompt()

; Display a splash screen
showSplashScreen()

; Set the design mode
setDesignMode()

; Clean temporary files
cleanFiles(FileList)

; Run the AutoGUI command
Run(launch_autogui_cmd, , , &PID)
Sleep(1000)

; Find and wait for Easy AutoGUI to launch
findEasyAutoGUI(PID)


; Continuously check for conversion status
While ProcessExist(PID)
{
    ; Check if the log file exists
    if FileExist(logsPath)
    {
        status := tryRead(logsPath)
        if (status != "")
        {
            inscript := tryRead(ahkv1CodePath)
            if (inscript != "")
            {
                writer("", logsPath) ; Clear the log file
                try {
                    Converter(inscript, ahkv2CodePath)
                }
                catch as e {
                    errorLogHandler(e.Message)
                    sleep(10)
                    continue
                }
            }
        }
    }
    else
    {
        Sleep(15)
        continue
    }
}
ExitApp()



; Prompt user about missing files
missingFilesPrompt() {
    msg := { text: "", title: "Missing Files", show: false }
    if not DirExist(cwd) {
        msg.show := true
        msg.text := 'The `'/required/`' directory included with this app is missing. Would you like to download the required files?`nOtherwise, this app will exit.'
    }
    else if not FileExist(ahkv1_exe) {
        msg.text := 'The `'\required\AutoHotKey Exe\AutoHotkeyV1.exe`' file included with this app is missing. `n`nIf you downloaded from the Github code page, you`'ll need the release to run this application.`nOr edit the _vars.ahk file with your ahkv1 64bit exe. `n`nWould you like to download the required files?`nOtherwise, this app will exit.'
        msg.show := true
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

; Convert script from AHK v1 to v2
Converter(inscript, ahkv2CodePath) {
    script := Convert(inscript)
    final_code := modifyAhkv2ConverterOutput(ahkv1CodePath, script)
    writer(final_code, ahkv2CodePath)
    writer("1", returnStatusPath)
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
