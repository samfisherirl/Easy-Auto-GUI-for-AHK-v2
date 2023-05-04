add_menuHandler(FNOut := "path", script := "code") ;outscript_path
{
    menuHandle := 0 ; => these denote true[1]/false[0]
    GuiEsc := 0 ; => for various bad output code, such as
    FindMenu := 0 ; => once MenuBar := Menubar() is found FindMenu:= 1;
    FindMenuBar := 0 ; =>
    MenuHandleCount := 0
    brackets := 0
    RemoveFunction := 0 ; RemoveFunction==1 loops to find `}` while `{` not found in line
    new_outscript := ""
    buttonFound := 0
    editFound := 0
    editCount := 0
    Edit_Storage := []
    if FileExist(FNOut) {
        FileMove(FNOut, A_ScriptDir "\complete_application\convert\temp.txt", 1)
    }
    Loop Parse, script, "`n", "`r" {
        if (A_Index == 1) {
            new_outscript := "`n" ";AutoGUI 2.5.8 " "`n" ";Auto-GUI-v2 credit to Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901`n;AHKv2converter credit to github.com/mmikeww/AHK-v2-script-converter`n`n"
        }
        if (RemoveFunction == 1) {
            if InStr(Trim(A_LoopField), "{") && not InStr(Trim(A_LoopField), "{") {
                brackets += 1 ; for every opening bracket, remove until equal number of closed brackets found
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
        if (menuHandle == 0) && (MenuHandleCount < 1) && InStr(A_LoopField, "MenuHandler") {
            menuHandle := 1
            new_outscript .= A_LoopField . "`n"
        }
        if InStr(A_LoopField, "MenuHandler(") {
            MenuHandleCount += 1
            RemoveFunction := 1
        }
        else if InStr(A_LoopField, ".Add(`"Edit`"") {
            editFound := 1
            editCount += 1
            Edit_Storage.Push("Edit_Storage" . editCount)
            new_outscript .= "Edit_Storage" editCount " := " A_LoopField "`n"
            ;ogcButtonOK.OnEvent("Click", GuiClose)
        }
        else if InStr(A_LoopField, ".Add(`"Button`"") {
            buttonFound := 1
            new_outscript .= A_LoopField "`n"
            variableName := Trim(StrSplit(A_LoopField, ":=")[1])
            ;ogcButtonOK.OnEvent("Click", GuiClose)
            val := variableName ".OnEvent(`"Click`", ButtonHandler)`n"
            new_outscript .= val
        }
        else if InStr(A_LoopField, "GuiEscape(*)") {
            ;if END OF SCRIPT found, attempt to append functions
            if (menuHandle == 1) && (MenuHandleCount < 2) {
                new_outscript .= "`nMenuHandler(*)`n" tooltip_()
                GuiEsc := 1
            }
            if (buttonFound == 1) && (editFound == 0) {
                new_outscript .= "`nButtonHandler(*)`n" tooltip_()
            }
            else if (editFound == 1) {
                if (buttonFound == 0) && (editFound == 1) {
                    func := "`nEditHandler(*)`n"
                    string := ""
                    ; for i in Edit_Storage {
                    ;     string .= Format(" `"``n // {1}.Value ==> `" {1}.Value", i)
                    ;     ;string .= " `"``n //%i% " A_Index "// `" " i ".Value"
                    ; }
                }
                else if (buttonFound == 1) && (editFound == 1) {
                    func .= "`nButtonHandler(*)`n"
                }
                string := ""
                for i in Edit_Storage {
                    string .= Format(" `"``n // {1}.Value ==> `" {1}.Value", i)
                }
                new_outscript .= func . tooltip_(string)

            }

            new_outscript .= A_LoopField "`n"
            ;if ()    GuiEsc := 1
        }
        else if (menuHandle == 1) && (MenuHandleCount >= 1) && InStr(A_LoopField, "MenuHandler(") {
            RemoveFunction := 1
            continue
        }
        else if InStr(A_LoopField, "myGui.OnEvent(`"Close`", GuiEscape)") || InStr(A_LoopField, "myGui.OnEvent(`"Escape`", GuiEscape)") || InStr(A_LoopField, "Bind(`"Normal`")") || (A_LoopField == "") {
            continue
        }
        ; else if InStr(LTrim(A_LoopField), "MenuBar.Add(") && a == 1 {
        ;     if StrSplit(LTrim(A_LoopField), "(")[1] == "MenuBar.Add" {
        ;         new_outscript .= StrReplace(A_LoopField, "MenuBar.Add(", "MenBar.Add(")
        ;         new_outscript .= "`n"
        ;     }
        ; ; }
        else if (Trim(A_LoopField) == "Menu := Menu()") {
            new_outscript .= StrReplace(A_LoopField, "Menu := Menu()", "Menu_Storage := Menu()")
            new_outscript .= "`n"
            FindMenu := 1
        }
        else if (FindMenu == 1) && (InStr(Trim(A_LoopField), "Menu.Add(")) {
            if (StrSplit(Trim(A_LoopField), "(")[1] == "Menu.Add") {
                new_outscript .= StrReplace(A_LoopField, "Menu.Add(", "Menu_Storage.Add(")
                new_outscript .= "`n"
            }
        }
        else if (Trim(A_LoopField) == "MenuBar := Menu()") {
            new_outscript .= StrReplace(A_LoopField, "MenuBar := Menu()", "MenuBar_Storage := MenuBar()")
            new_outscript .= "`n"
            FindMenuBar := 1
        }
        else if (FindMenuBar == 1) && InStr(Trim(A_LoopField), "MenuBar.Add(") {
            if (StrSplit(Trim(A_LoopField), "(")[1] == "MenuBar.Add") {
                new_outscript .= StrReplace(A_LoopField, "MenuBar.Add(", "MenuBar_Storage.Add(")
                new_outscript .= "`n"
            }
        }
        else if InStr(A_LoopField, ".MenuToolbar := MenuBar") {
            new_outscript .= StrReplace(A_LoopField, "MenuToolbar := MenuBar", "MenuBar := MenuBar_Storage")
            new_outscript .= "`n"
        }
        else if InStr(A_LoopField, ".Show(`"") && (buttonFound == 0) && (editFound == 1) {
            for i in Edit_Storage {
                new_outscript .= i ".OnEvent(`"Change`", EditHandler)`n"
            }
            new_outscript .= A_LoopField . "`n"

        }
        else {
            new_outscript .= A_LoopField . "`n"
        }
    }
    return new_outscript
}

tooltip_(string := "") {
    if (string != "") {
        string := "The edit values include:`" " . string
    }
    return "{`n`tToolTip `"Click! This is a sample action. ``n" string ", 20, 20`n`tSetTimer () => ToolTip(), -3000 `; timer expires in 2 seconds and tooltip disappears`n}`n"
}