#Requires Autohotkey v2.0
FileCopy(A_ScriptDir "\Launch_AutoGUI.ahk", A_ScriptDir "\changes_of_note\__Launch_AutoGUI.ahk", 1)

FileCopy(A_ScriptDir "\complete_application\AutoGUI.ahk", A_ScriptDir "\changes_of_note\__AutoGUI.ahk", 1)

FileCopy(A_ScriptDir "\complete_application\convert\_menu_handler_mod.ahk", A_ScriptDir "\changes_of_note\_menu_handler_mod.ahk", 1)

convertFuncs := lineExtraction(A_ScriptDir "\complete_application\convert\ConvertFuncs.ahk", 392, 460)
AGUI := lineExtraction(A_ScriptDir "\complete_application\AutoGUI.ahk", 1392, 1460)

try {
    FileMove(A_ScriptDir "\changes_of_note\__ConvertFuncs.ahk", A_ScriptDir "\changes_of_note\__trash.ahk", 1)
}
catch {
    Sleep(1)
}
try {
    FileMove(A_ScriptDir "\changes_of_note\__AutoGUI.ahk", A_ScriptDir "\changes_of_note\__trash.ahk", 1)
}
catch {
    Sleep(1)
}

FileAppend(convertFuncs, A_ScriptDir "\changes_of_note\__ConvertFuncs.ahk")
FileAppend(AGUI, A_ScriptDir "\changes_of_note\__AutoGUI.ahk")

FileCopy(A_ScriptDir "\complete_application\convert\ConvertFuncs.ahk", A_ScriptDir "\changes_of_note\__ConvertFuncs.ahk", 1)


lineExtraction(filename, lineNumFROM, lineNumTO) {
    string := FileRead(filename)
    newString := ""
    rangeFound := 0
    Loop Parse string, "`n", "`r" {
        if (rangeFound == 1) {
            if (A_Index <= lineNumTO) {
                newString .= A_LoopField . "`n"
            }
            else {
                rangeFound := 0
            }
        }
        else if (A_Index == lineNumFROM) {
            rangeFound := 1
            newString .= "`n`n`n;=====================================`n;starting line number: " lineNumFROM A_LoopField . "`n;=====================================`n"
        }
    }
    return newString

}