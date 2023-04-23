add_menuhandler(FNOut) ;outscript_path
{
    menuhandle := 0 ; => these denote true[1]/false[0]
    GuiEsc := 0 ; => for various bad output code, such as
    FindMenu := 0 ; => once MenuBar := Menubar() is found FindMenu:= 1;
    FindMenuBar := 0 ; => Remove Function and continue loop until `}` is found
    MenuHanldeCount := 0
    brackets := 0
    RemoveFunction := 0
    ; this will all get removed with methods
    ; && for loops
    newoutscript := ""
    intxt := FileRead(FNOut)
    FileMove(FNOut, A_ScriptDir "\complete_application\temp.txt", 1)
    Loop Parse, intxt, "`n", "`r" {
        if (A_Index == 1) {
            newoutscript := "`n" ";AutoGUI 2.5.8 " "`n" ";Auto-GUI-v2 credit to autohotkey.com/boards/viewtopic.php?f=64&t=89901`n;AHKv2converter credit to github.com/mmikeww/AHK-v2-script-converter`n`n"
        }
        if (RemoveFunction == 1) {
            if InStr(Trim(A_LoopField), "{") && not InStr(Trim(A_LoopField), "{") {
                brackets += 1
                continue
            }
            else if InStr(A_LoopField, "}") && not InStr(Trim(A_LoopField), "{") {
                if (brackets <= 1) {
                    RemoveFunction := 0
                    brackets := 0
                    continue
                }
                else if (brackets > 1) {
                    brackets := brackets - 1
                    continue
                }
            }
            else {
                continue
            }
        }
        if (menuhandle == 0) && MenuHanldeCount < 1 && InStr(A_LoopField, "MenuHandler") {
            menuhandle := 1
            newoutscript .= A_LoopField . "`n"
        }
        if InStr(A_LoopField, "MenuHandler(") {
            MenuHanldeCount += 1
            RemoveFunction := 1
        }
        else if (menuhandle == 1) && MenuHanldeCount < 2 && InStr(A_LoopField, "GuiEscape(*)") {
            newoutscript .= "MenuHandler(*) {`n`tToolTip `"Click!`", 100, 150`n}`n" A_LoopField
            GuiEsc := 1
        }
        else if (menuhandle == 1) && (MenuHanldeCount >= 1) && InStr(A_LoopField, "MenuHandler(") {
            RemoveFunction := 1
            continue
        }
        else if InStr(A_LoopField, "myGui.OnEvent(`"Close`", GuiEscape)") || InStr(A_LoopField, "myGui.OnEvent(`"Escape`", GuiEscape)") || InStr(A_LoopField, "Bind(`"Normal`")") || (A_LoopField == "") {
            continue
        }
        ; else if InStr(LTrim(A_LoopField), "MenuBar.Add(") && a == 1 {
        ;     if StrSplit(LTrim(A_LoopField), "(")[1] == "MenuBar.Add" {
        ;         newoutscript .= StrReplace(A_LoopField, "MenuBar.Add(", "MenBar.Add(")
        ;         newoutscript .= "`n"
        ;     }
        ; ; }
        else if (LTrim(A_LoopField) == "Menu := Menu()") {
            newoutscript .= StrReplace(A_LoopField, "Menu := Menu()", "Menu_Storage := Menu()")
            newoutscript .= "`n"
            FindMenu := 1
        }
        else if (FindMenu == 1 && InStr(LTrim(A_LoopField), "Menu.Add(")) {
            if (StrSplit(LTrim(A_LoopField), "(")[1] == "Menu.Add") {
                newoutscript .= StrReplace(A_LoopField, "Menu.Add(", "Menu_Storage.Add(")
                newoutscript .= "`n"
            }
        }
        else if (LTrim(A_LoopField) == "MenuBar := Menu()") {
            newoutscript .= StrReplace(A_LoopField, "MenuBar := Menu()", "MenuBar_Storage := MenuBar()")
            newoutscript .= "`n"
            FindMenuBar := 1
        }
        else if (FindMenuBar == 1) && InStr(LTrim(A_LoopField), "MenuBar.Add(") {
            if (StrSplit(LTrim(A_LoopField), "(")[1] == "MenuBar.Add") {
                newoutscript .= StrReplace(A_LoopField, "MenuBar.Add(", "MenuBar_Storage.Add(")
                newoutscript .= "`n"
            }
        }
        else if InStr(A_LoopField, ".MenuToolbar := MenuBar") {
            newoutscript .= StrReplace(A_LoopField, "MenuToolbar := MenuBar", "MenuBar := MenuBar_Storage")
            newoutscript .= "`n"
        }
        else {
            newoutscript .= A_LoopField . "`n"
        }
    }
    FileAppend(newoutscript, FNOut)
}