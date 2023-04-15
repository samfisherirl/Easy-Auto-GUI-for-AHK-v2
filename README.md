# Auto-GUI-for-AHK-v2

I'll be adding more details here soon. 

Auto-GUI-v2 credit to https://www.autohotkey.com/boards/viewtopic.php?f=64&t=89901 
AHKv2converter credit to https://github.com/mmikeww/AHK-v2-script-converter

I did very little work, just weaving the two solutions together. 

A simple script that integrates these two solutions. Modifications to Auto-GUI happen upon saving, when selecting "Save" or "Save as", command line parameters launch, read log, and convert side-by-side with the new scripts. 

Full Solution. 

Code changes:

[code]path := FileRead(A_ScriptDir "\log.txt")
converter(path)
converter(selected) {
    exe := "`"" A_ScriptDIr "\AutoHotKey Exe\AutoHotkeyV2.exe`""
    convertahk := exe " `"" A_ScriptDIr "\v2converter.ahk`" "
    command := convertahk . "`"" selected "`""
    MsgBox(command)
    Run(command)
}
[/code]

code changed in autogui:

[code]    

    Log := A_ScriptDir "\log.txt"
    if FileExist(Log){
        FileDelete %Log%
    }
    FileDelete %FullPath%
    FileAppend %SciText%, %FullPath%, %Encoding%
    FileDelete %Log%
    FileAppend %FullPath%, %Log%, %Encoding%
    Run, listener.exe, %A_ScriptDir%

[/code]

