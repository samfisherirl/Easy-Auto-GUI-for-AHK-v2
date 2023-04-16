# AutoGUI GUI-Designer GUI-Builder for ahk-v2

I'll be adding more details here soon. Example, cloning notepad++ to ahkv2
![image](https://user-images.githubusercontent.com/98753696/232308834-5af87bbe-f920-4751-9019-44f834910c0b.jpg)

Auto-GUI-v2 credit to Alguimist who built the entire app - https://www.autohotkey.com/boards/viewtopic.php?f=64&t=89901 

AHKv2converter credit to https://github.com/mmikeww/AHK-v2-script-converter

Welcome to the AutoGUI GUI-Designer GUI-Builder for ahk-v2! If you're someone who spends a lot of time writing scripts in AutoHotkey, then you know how important it is to have the right tools at your disposal. AutoGUI GUI-Designer GUI-Builder for ahk-v2 is a powerful tool that can help you create intuitive, user-friendly interfaces for your AutoHotkey scripts.

What's more, this tool is incredibly easy to use. All you have to do is run your standard Easy AutoGUI's v1 script, and then select "Save" or "Save as..." in order to initiate the conversion process. With the help of AHKv2converter, your script will be automatically converted to AHKv2, giving you access to all of the latest features and functions of this powerful scripting language.

One of the coolest things about AutoGUI GUI-Designer GUI-Builder for ahk-v2 is that it allows you to copy an entire notepad++ window and autoconvert it to ahkv2. This feature is incredibly useful if you're working on a complex project and need to transfer a lot of information quickly and easily.

Of course, none of this would be possible without the hard work of the creators who built the Auto-GUI-v2 and AHKv2converter tools. I did very little work on this project - I simply wove the two solutions together. All credit goes to Alguimist for building the entire app and to mmikeww for creating the AHKv2converter.

So if you're looking for a powerful, easy-to-use tool that can help you create intuitive, user-friendly interfaces for your AutoHotkey scripts, look no further than AutoGUI GUI-Designer GUI-Builder for ahk-v2. With its powerful features and easy-to-use interface, it's the perfect tool for anyone who wants to take their AutoHotkey scripting to the next level.





Code added, listener.ahk:

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

code changed, autogui:


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

