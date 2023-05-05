add_menuHandler(FNOut := "path", script := "code") ;outscript_path
{
    menuHandle := 0 ; => these denote true[1]/false[0]
    GuiEsc := 0 ; => for various bad output code, such as
    FindMenu := 0 ; => once Menu := Menubar() is found, replace with Menu_Storage;
    FindMenuBar := 0 ; => once MenuBar := Menubar() is found, replace with Menubar_Storage;
    MenuHandleCount := 0
    global GuiItemVars := ["Edit", "Radio", "CheckBox", "DropDownList", "ComboBox"]
    global GuiItemCounter := [1, 1, 1, 1, 1]
    brackets := 0
    RemoveFunction := 0 ; RemoveFunction==1 loops to find `}` while `{` not found in line
    new_outscript := ""
    buttonFound := 0
    itemFound := 0
    editCount := 0
    global GuiItem_Storage := []
    Edit_Storage := []
    if FileExist(FNOut) {
        FileMove(FNOut, A_ScriptDir "\complete_application\convert\temp.txt", 1)
    }
    Loop Parse, script, "`n", "`r" {
        if (A_Index == 1) {
            new_outscript := "`n" "#Requires Autohotkey v2.0`n;AutoGUI 2.5.8 " "`n" ";Auto-GUI-v2 credit to Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901`n;AHKv2converter credit to github.com/mmikeww/AHK-v2-script-converter`n`n"
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
            ; if MenuHandler is found, add a function at the bottom of the app to handle
            menuHandle := 1
            new_outscript .= A_LoopField . "`n"
        }
        if InStr(A_LoopField, "MenuHandler(") {
            MenuHandleCount += 1
            RemoveFunction := 1
        }
        ; =================== latest =======================
        ret := checkforGuiItems(A_LoopField)
        ; loop through and look for GuiItemVars[]
        if (ret != 0) {
            new_outscript .= ret " := " A_LoopField "`n"
            itemFound := 1
        }
        ; =================== latest =======================
        else if InStr(A_LoopField, ".Add(`"Button`"") {
            buttonFound := 1
            new_outscript .= A_LoopField "`n"
            variableName := Trim(StrSplit(A_LoopField, ":=")[1])
            ;ogcButtonOK.OnEvent("Click", GuiClose)
            val := variableName ".OnEvent(`"Click`", OnEventHandler)`n"
            new_outscript .= val
        }
        ; =================== latest =======================
        ; =================== latest =======================
        else if InStr(A_LoopField, "GuiEscape(*)") {
            ;if END OF SCRIPT found, attempt to append functions
            ;Function MenuHandler or OnEventHandler 
            ;provide tooltips when buttons are clicked or values are entered
            if (menuHandle == 1) && (MenuHandleCount < 2) {
                new_outscript .= "`nMenuHandler(*)`n" tooltip_()
                GuiEsc := 1
            }
            if (buttonFound == 1) && (itemFound == 0) {
                new_outscript .= "`nOnEventHandler(*)`n" tooltip_()
            }
            else if (itemFound == 1) {
                if (buttonFound == 0) && (itemFound == 1) {
                    func := "`nOnEventHandler(*)`n"
                    string := ""
                }
                else if (buttonFound == 1) && (itemFound == 1) {
                    func := "`nOnEventHandler(*)`n"
                }
                string := ""
                for i in GuiItem_Storage {
                    string .= Format(" `n`t. `"{1} => `" {1}.Value `"``n`"", i)
                }
                new_outscript .= func . tooltip_(string)

            }

            new_outscript .= A_LoopField "`n"
            ;if ()    GuiEsc := 1
        }
        else if (menuHandle == 1) && (MenuHandleCount >= 1) && InStr(A_LoopField, "MenuHandler(") {
            ;remove default menuhandler function
            RemoveFunction := 1
            continue
        }
        else if InStr(A_LoopField, "myGui.OnEvent(`"Close`", GuiEscape)") || InStr(A_LoopField, "myGui.OnEvent(`"Escape`", GuiEscape)") || InStr(A_LoopField, "Bind(`"Normal`")") || (A_LoopField == "") {
            ;remove all if cases
            continue
        }
        ; else if InStr(LTrim(A_LoopField), "MenuBar.Add(") && a == 1 {
        ;     if StrSplit(LTrim(A_LoopField), "(")[1] == "MenuBar.Add" {
        ;         new_outscript .= StrReplace(A_LoopField, "MenuBar.Add(", "MenBar.Add(")
        ;         new_outscript .= "`n"
        ;     }
        ; ; }
        else if (Trim(A_LoopField) == "Menu := Menu()") {
            ;fix naming convension of Menu
            new_outscript .= StrReplace(A_LoopField, "Menu := Menu()", "Menu_Storage := Menu()")
            new_outscript .= "`n"
            FindMenu := 1
        }
        else if (FindMenu == 1) && (InStr(Trim(A_LoopField), "Menu.Add(")) {
            ;fix naming convension of Menu
            if (StrSplit(Trim(A_LoopField), "(")[1] == "Menu.Add") {
                new_outscript .= StrReplace(A_LoopField, "Menu.Add(", "Menu_Storage.Add(")
                new_outscript .= "`n"
            }
        }
        else if (Trim(A_LoopField) == "MenuBar := Menu()") {
            ;fix naming convension of MenuBar
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
            ;fix naming convension of MenuToolbar
            new_outscript .= StrReplace(A_LoopField, "MenuToolbar := MenuBar", "MenuBar := MenuBar_Storage")
            new_outscript .= "`n"
        }
        else if InStr(A_LoopField, ".Show(`"") {
            ;look for line before `return` (GuiShow) 
            ;if found, and NO [submit] button is used
            ;user will get tooltips on value changes
            ;instead of submittion
            if ((buttonFound == 0) && (itemFound == 1))
            {
                for i in GuiItem_Storage {
                    new_outscript .= i ".OnEvent(`"Click`", OnEventHandler)`n"
                }
                new_outscript .= A_LoopField . "`n"
            }
        }
        else {
            new_outscript .= A_LoopField . "`n"
        }
    }
    return new_outscript
}

checkforGuiItems(LoopField) {
    global GuiItemVars, GuiItem_Storage, GuiItemCounter
    for i in GuiItemVars
    {
        if InStr(LoopField, Format(".Add(`"{1}`"", i))
        {
            var := i "_Storage" GuiItemCounter[A_Index]
            GuiItem_Storage.Push(var)
            GuiItemCounter[A_Index] += 1
            return var
        }
    }
    return 0
}

tooltip_(string := "") {
    if (string != "") {
        string := "`n`t. `"Active GUI element values include:``n`" " . string
    }
    return "{`n`tToolTip(`"Click! This is a sample action.``n`"" string ", 77, 277)`n`tSetTimer () => ToolTip(), -3000 `; timer expires in 3 seconds and tooltip disappears`n}`n"
}