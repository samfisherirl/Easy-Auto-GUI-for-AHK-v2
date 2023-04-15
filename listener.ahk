/*
;comm line
AutoHotkeyV2.exe "C:\Users\dower\Downloads\AHK-v2-script-converter-master\v2converter.ahk" to_be_converted.ahk
*/
path := FileRead(A_ScriptDir "\log.txt")
converter(path)
converter(selected) {
    exe := "`"" A_ScriptDIr "\AutoHotKey Exe\AutoHotkeyV2.exe`""
    convertahk := exe " `"" A_ScriptDIr "\v2converter.ahk`" "
    command := convertahk . "`"" selected "`""
    MsgBox(command)
    Run(command)
}
;The script defines a class named "MyGui_Create" that creates a GUI and adds buttons to it. Each button is assigned an "OnEvent" method that is triggered when the user clicks on it. These methods contain commands to launch virtual environments and run the different packaging tools.


/*
    v2 := A_ScriptDir "\AutoHotKey Exe\AutoHotkeyV2.exe"
    converter := "\v2converter.ahk"
}
