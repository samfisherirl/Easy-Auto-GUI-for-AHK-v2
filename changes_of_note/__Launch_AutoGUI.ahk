#Requires Autohotkey v2.0
#SingleInstance Force
#Include complete_application\convert\ConvertFuncs.ahk
#Include complete_application\convert\_menu_handler_mod.ahk
;AutoGUI 2.5.8
;Auto-GUI-v2 credit to autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter credit to github.com/mmikeww/AHK-v2-script-converter
exe := "`"" A_ScriptDir "\complete_application\AutoHotKey Exe\AutoHotkeyV1.exe`" "
autogui := "`"" A_ScriptDir "\complete_application\AutoGUI.ahk`""
com := exe autogui
Run(com, , , &PID)
Sleep(1000)
Loop 10 {
    if ProcessExist(PID) {
        break
    }
    else {
        Sleep(1000)
    }
}

logs := A_ScriptDir "\complete_application\log.txt"
temps := A_ScriptDir "\complete_application\temp.txt"
retstat := A_ScriptDir "\complete_application\returnstatus.txt"
if FileExist(logs) {
    FileMove(logs, temps, 1)
}

While ProcessExist(PID) {
    if FileExist(logs) {
        path_to_convert := tryRead(logs)
        if path_to_convert {
            if FileExist(path_to_convert) {
                inscript := tryRead(path_to_convert)
                if (inscript != "") {
                    FileMove(logs, temps, 1)
                    try {
                        outscript := Convert(inscript)
                        outfile := FileOpen(path_to_convert, "w", "utf-8")
                        outfile.Write(outscript)
                        outfile.Close()
                        add_menuhandler(path_to_convert)
                    }
                    catch {
                        sleep(200)
                    }
                    FileAppend(retstat, retstat)
                } } } }
    else {
        Sleep(50)
    }
}
ExitApp

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
