add_menuHandler(FNOut := "path", script := "code") ;outscript_path
{
    ; => these denote true[1]/false[0]
     ; => for various bad output code, such as
     ; => once Menu := Menubar() is found, replace with Menu_Storage;
     ; => once MenuBar := Menubar() is found, replace with Menubar_Storage;
    
     global GuiItemVars := Map("Button", "Click", "DropDownList", "Change", "Edit", "Change", "DateTime", "Change", "MonthCal", "Change", "Radio", "Click", "CheckBox", "Click", "ComboBox", "Change")
     global eventList := []
     global GuiItemCounter := [1, 1, 1, 1, 1, 1, 1, 1]
     brackets := 0
     ; RemoveFunction==1 loops to find `}` while `{` not found in line
    new_outscript := ""
    buttonFound := 0, itemFound := 0, editCount := 0, menuHandler:=0, guiShow:=0, RemoveFunction := 0, menuHandle := 0, GuiEsc := 0, FindMenu := 0, FindMenuBar := 0, MenuHandleCount := 0
    guiname := ""
    global GuiItem_Storage := []
    Edit_Storage := []
    if FileExist(FNOut) {
        FileMove(FNOut, A_ScriptDir "\required\convert\temp.txt", 1)
    }
    Loop Parse, script, "`n", "`r" {
        if (A_Index = 1) && not InStr(A_LoopField, "#Requires Autohotkey v2") {
            new_outscript := "`n" "#Requires Autohotkey v2`n;AutoGUI 2.5.8 " "`n" ";Auto-GUI-v2 credit to Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901`n;AHKv2converter credit to github.com/mmikeww/AHK-v2-script-converter`n`n"
        }
        if (RemoveFunction = 1) {
            if InStr(Trim(A_LoopField), "{") && not InStr(Trim(A_LoopField), "}") {
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
        if (guiname = "") && InStr(A_LoopField, " := Gui()") {
            guiname := StrSplit(A_LoopField, " := Gui()")[1]
            new_outscript .= A_LoopField "`n"
            continue
        }
        ; =================== check for gui items =======================
        ret := checkforGuiItems(A_LoopField)
        ; loop through and look for GuiItemVars[]
        if (ret != 0) {
            if (ret = 1) {
                itemFound := 1
                new_outscript .= A_LoopField "`n"
            }
            else {
                new_outscript .= ret " := " A_LoopField "`n"
                itemFound := 1
            }
        }
        ; =================== check for gui items =======================
        else if (menuHandle = 0) && (MenuHandleCount < 1) && InStr(A_LoopField, "MenuHandler") {
            ; if MenuHandler is found, add a function at the bottom of the app to handle
            menuHandle := 1
            new_outscript .= A_LoopField . "`n"
        }
        else if InStr(A_LoopField, "MenuHandler(") {
            MenuHandleCount += 1
            RemoveFunction := 1
        }
        ; else if InStr(A_LoopField, ".Add(`"Button`"") {
        ;     buttonFound := 1
        ;     new_outscript .= A_LoopField "`n"
        ;     variableName := Trim(StrSplit(A_LoopField, ":=")[1])
        ;     ;ogcButtonOK.OnEvent("Click", GuiClose)
        ;     val := variableName ".OnEvent(`"Click`", OnEventHandler)`n"
        ;     new_outscript .= val
        ; }
        else if InStr(A_LoopField, "GuiEscape(*)") && (menuHandler = 0) {
            menuHandler:=1
            ;if END OF SCRIPT found, attempt to append functions
            ;Function MenuHandler or OnEventHandler 
            ;provide tooltips when buttons are clicked or values are entered
            if (menuHandle = 1) && (MenuHandleCount < 2) {
                new_outscript .= "`nMenuHandler(*)`n" tooltip_()
                GuiEsc := 1
            }
            else if (itemFound = 1) {
                func := "`nOnEventHandler(*)`n"
                string := ""
                event_control_tooltips := ""
                for variable_name in GuiItem_Storage {
                    if not InStr(variable_name, "Button") {
                        event_control_tooltips .= Format(" `n`t. `"{1} => `" {1}.Value `"``n`"", variable_name)
                    }
                }
                if (event_control_tooltips != "") {
                    new_outscript .= func . tooltip_(event_control_tooltips)
                }
            }

            break
            ;if ()    GuiEsc := 1
        }
        else if (menuHandle = 1) && (MenuHandleCount >= 1) && InStr(A_LoopField, "MenuHandler(") {
            ;remove default menuhandler function
            RemoveFunction := 1
            continue
        }
        else if InStr(A_LoopField, "OnEvent(`"Close`", GuiEscape)") || InStr(A_LoopField, "OnEvent(`"Escape`", GuiEscape)") || InStr(A_LoopField, "Bind(`"Normal`")") || (A_LoopField = "") {
            ;remove all if cases
            continue
        } 
        else if (Trim(A_LoopField) = "Menu := Menu()") {
            ;fix naming convension of Menu
            new_outscript .= StrReplace(A_LoopField, "Menu := Menu()", "Menu_Storage := Menu()")
            new_outscript .= "`n"
            FindMenu := 1
        }
        else if (FindMenu = 1) && (InStr(Trim(A_LoopField), "Menu.Add(")) {
            ;fix naming convension of Menu
            if (StrSplit(Trim(A_LoopField), "(")[1] = "Menu.Add") {
                new_outscript .= StrReplace(A_LoopField, "Menu.Add(", "Menu_Storage.Add(")
                new_outscript .= "`n"
            }
        }
        else if (Trim(A_LoopField) = "MenuBar := Menu()") {
            ;fix naming convension of MenuBar
            new_outscript .= StrReplace(A_LoopField, "MenuBar := Menu()", "MenuBar_Storage := MenuBar()")
            new_outscript .= "`n"
            FindMenuBar := 1
        }
        else if (FindMenuBar = 1) && InStr(Trim(A_LoopField), "MenuBar.Add(") {
            if (StrSplit(Trim(A_LoopField), "(")[1] = "MenuBar.Add") {
                new_outscript .= StrReplace(A_LoopField, "MenuBar.Add(", "MenuBar_Storage.Add(")
                new_outscript .= "`n"
            }
        }
        else if InStr(A_LoopField, ".MenuToolbar := MenuBar") {
            ;fix naming convension of MenuToolbar
            new_outscript .= StrReplace(A_LoopField, "MenuToolbar := MenuBar", "MenuBar := MenuBar_Storage")
            new_outscript .= "`n"
        }
        else if InStr(A_LoopField, ".Show(`"") && (guiShow = 0) {
            guiShow:=1
            ;look for line before `return` (GuiShow) 
            ;if found, and NO [submit] button is used
            ;user will get tooltips on value changes
            ;instead of submittion
            if (itemFound = 1)
            {
                for variable_name in GuiItem_Storage {
                    event := eventList[A_Index]
                    new_outscript .= variable_name ".OnEvent(`"" event "`", OnEventHandler)`n"
                }
            } 
            new_outscript .= guiname ".OnEvent('Close', (*) => ExitApp())`n"
            new_outscript .= A_LoopField . "`n" 
            
        }
        else {
            new_outscript .= A_LoopField . "`n"
        }
    }
    return new_outscript
}
;.OnEvent('Close', (*) => ExitApp())
checkforGuiItems(LoopField) {
    global GuiItemVars, GuiItem_Storage, GuiItemCounter, eventList
    for guicontrol, event in GuiItemVars
    {
        if InStr(LoopField, Format(".Add(`"{1}`"", guicontrol))
        {
            if InStr(LoopField, ":=") {
                var := Trim(StrSplit(LoopField, ":=")[1])
                GuiItem_Storage.Push(Trim(var))
                eventList.Push(event)
                GuiItemCounter[A_Index] += 1
                return 1
            }
            else {
                var := guicontrol "_" GuiItemCounter[A_Index]
                GuiItem_Storage.Push(Trim(var))
                eventList.Push(event)
                GuiItemCounter[A_Index] += 1
                return var
            }
        }
    }
    return 0
}

tooltip_(string := "") {
    if (string != "") {
        string := "`n`t. `"Active GUI element values include:``n`" " . string
    }
    return "{`n`tToolTip(`"Click! This is a sample action.``n`"" string ", 77, 277)`n`tSetTimer () => ToolTip(), -3000 `; tooltip timer`n}`n"
}
