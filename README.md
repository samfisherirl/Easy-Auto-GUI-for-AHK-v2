# Auto-GUI-for-AHK-v2

I'll be adding more details here soon. 

Auto-GUI-v2 credit to https://www.autohotkey.com/boards/viewtopic.php?f=64&t=89901 
AHKv2converter credit to https://github.com/mmikeww/AHK-v2-script-converter

I did very little work, just weaving the two solutions together. 

A simple script that integrates these two solutions. Modifications to Auto-GUI happen upon saving, when selecting "Save" or "Save as", command line parameters launch, read log, and convert side-by-side with the new scripts. 

Full Solution. 

Code changes:

```autohotkey
path := FileRead(A_ScriptDir "\log.txt")
converter(path)
converter(path) {
    exe := "`"" A_ScriptDIr "\AutoHotKey Exe\AutoHotkeyV2.exe`""
    convertahk := " `"" A_ScriptDIr "\convert\v2converter.ahk`" "
    command := exe convertahk "`"" path "`""
    Run(command)
}

```

code changed in autogui:


```autohotkey
    
run_listener(SelectedFile){
    q := """"
    exe := q . A_ScriptDIr . "\AutoHotKey Exe\AutoHotkeyV2.exe" . q . " "
    script := q . A_ScriptDIr . "\listener.ahk" . q 
    com := exe . script
    Log := A_ScriptDir "\log.txt"
    if FileExist(Log){
        FileDelete %Log%
    }
    FileAppend %SelectedFile%, %Log%, %Encoding%
    Run, %com%, %A_ScriptDir%
}
```

