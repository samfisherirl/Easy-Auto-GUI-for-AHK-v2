modifyAhkv2ConverterOutput(FNOut := "path", script := "code") ;outscript_path
{
    static lastScript := ""
    static lastReturned := ""
    if (lastScript = script) {
        return lastReturned
    } else {
        lastScript := script
    }
    GuiControlVars := [
        map("ctrl", "Button", "event", "Click", "function", "Text"),
        map("ctrl", "DropDownList", "event", "Change", "function", "Text"),
        map("ctrl", "Edit", "event", "Change", "function", "Value"),
        map("ctrl", "DateTime", "event", "Change", "function", "Value"),
        map("ctrl", "MonthCal", "event", "Change", "function", "Value"),
        map("ctrl", "Radio", "event", "Click", "function", "Value"),
        map("ctrl", "CheckBox", "event", "Click", "function", "Value"),
        map("ctrl", "ComboBox", "event", "Change", "function", "Text")
    ]
    LVFunc := "`nLV_DoubleClick(LV, RowNum)`n{`n`tif not RowNum`n`t`treturn`n`tToolTip(LV.GetText(RowNum), 77, 277)`n`tSetTimer () => ToolTip(), -3000`n}`n"
    eventList := []
    GuiItemCounter := [1, 1, 1, 1, 1, 1, 1, 1]
    brackets := 0
    new_outscript := ""
    buttonFound := 0
    itemFound := false
    editCount := 0
    menuHandler := 0
    guiShow := 0
    RemoveFunction := false
    menuHandle := 0
    GuiEsc := 0
    FindMenu := 0
    FindMenuBar := 0
    MenuHandleCount := 0
    ctrlcolor := 0
    guiname := ""
    title := ""
    GuiItem_Storage := []
    LVFound := 0
    Edit_Storage := []
    GuiCtrlStorage := []
    if FileExist(FNOut) {
        FileMove(FNOut, A_ScriptDir "\required\convert\temp.txt", 1)
    }
    Loop Parse, script, "`n", "`r"
    {
        if (A_Index = 1)
        {
            new_outscript := "`n" "#Requires Autohotkey v2`n;AutoGUI 2.5.8 creator: Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901`n" 
            . ";AHKv2converter creator: github.com/mmikeww/AHK-v2-script-converter`n" 
            . ";Easy_AutoGUI_for_AHKv2 github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2`n`n"
            . "myGui := Construct()`n`n"
            . "Construct() {`n"
        }
        trimField := Trim(A_LoopField)
        
        if RemoveFunction {
            if InStr(trimField, "{") && !InStr(trimField, "}") {
                brackets += 1 ; for every opening bracket, remove until equal number of closed brackets found
            }
            else if InStr(A_LoopField, "}") && !InStr(trimField, "{") {
                if (brackets <= 1) {
                    RemoveFunction := false
                    brackets := 0
                }
                else if (brackets > 1) {
                    brackets := brackets - 1
                }
            }
            continue
        }
        if (guiname = "")
        {
            if InStr(A_LoopField, " := Gui()") {
                guiname := StrSplit(A_LoopField, " := Gui()")[1]
                new_outscript .= A_LoopField "`n"
                continue
            }
        }
        ; =================== check for gui controls =======================
        if InStr(A_LoopField, 'Add("ListView"')
        {
            LVFound := StrSplit(TrimField, " := ")[1]
        }
        if InStr(A_LoopField, "Add(") {
            ret := checkforGuiItems(A_LoopField, &GuiControlVars, &GuiItemCounter, &GuiCtrlStorage)
            ; ; loop through and look for GuiControlVars[]
            if (ret[1] = 1) {
                ;button
                itemFound := true
                lastGuiControl := ret[2]
                oldvar := StrSplit(A_LoopField, " := ")[1]
                newline := StrReplace(A_LoopField, oldvar, ret[2])
                new_outscript .= newline "`n"
                continue
            }
            if (ret[1] = 2) {
                new_outscript .= ret[2] " := " A_LoopField "`n"
                lastGuiControl := ret[2]
                itemFound := true
                continue
            }
            else {
                lastGuiControl := StrSplit(A_LoopField, " := ")
            }
        }
        ; =================== check for gui controls end =======================
        if InStr(A_LoopField, ".Title :=") {
            title := A_LoopField
            continue
        }
        else if InStr(trimField, '.Icon("')
        {
            obj := StrSplit(trimField, '.Icon(')[1]
            commaSeparated := StrSplit(StrReplace(StrSplit(trimField,"(")[2], ")", ""), ",")
            commaSeparatedCln := []
            for str in commaSeparated
            {
                commaSeparatedCln.Push(StrReplace(StrReplace(StrReplace(str, '``"', ''), '"', ''), " ", ""))
            }
            if commaSeparatedCln.Length > 2
            {
                    new_outscript .= Format('{}.SetIcon("{}","{}", {})', obj, commaSeparatedCln[1], commaSeparatedCln[2], commaSeparatedCln[3]) "`n" 
            }
        }
        else if InStr(A_LoopField, "MenuHandler") {
            if (menuHandle = 0) && (MenuHandleCount < 1) 
            {
                menuHandle := 1
                new_outscript .= A_LoopField . "`n"
            }
            ; if MenuHandler is found, add a function at the bottom of the app to handle
        }
        else if InStr(A_LoopField, "MenuHandler(") {
            MenuHandleCount += 1
            RemoveFunction := true
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
            menuHandler := 1
            ;if END OF SCRIPT found, attempt to append functions
            ;Function MenuHandler or OnEventHandler
            ;provide tooltips when buttons are clicked or values are entered
            if (menuHandle = 1) && (MenuHandleCount < 2) {
                new_outscript .= "`nMenuHandler(*)`n" tooltip_()
                GuiEsc := 1
            }
            if itemFound {
                func := "`nOnEventHandler(*)`n"
                string := ""
                event_control_tooltips := ""
                for ctrl in GuiCtrlStorage {
                    event_control_tooltips .= Format(" `n`t. `"{1} => `" {1}.{2} `"``n`"", ctrl['name'], ctrl['function'])
                }
                if (event_control_tooltips != "") {
                    new_outscript .= func . tooltip_(event_control_tooltips)
                }
                else {
                    new_outscript .= func . tooltip_()
                }
            }
            break
            ;if ()    GuiEsc := 1
        }
        else if (menuHandle = 1) && (MenuHandleCount >= 1) && InStr(A_LoopField, "MenuHandler(") {
            ;remove default menuhandler function
            RemoveFunction := true
            continue
        }
        else if InStr(A_LoopField, "OnEvent(`"Close`", GuiEscape)") || (Trim(A_LoopField = "Return") || Trim(A_LoopField = "return")) || InStr(A_LoopField, "OnEvent(`"Escape`", GuiEscape)") || InStr(A_LoopField, "Bind(`"Normal`")") || (A_LoopField = "") || InStr(A_LoopField, ".SetFont()") || InStr(A_LoopField, ".hwnd") || InStr(A_LoopField, "+hWnd") {
            ;remove all if cases
            continue
        }
        else if InStr(A_LoopField, "ControlColor(") {
            ctrlcolor := 1
            RegExMatch(A_LoopField, "0x[a-fA-F0-9]{6}", &match)
            if IsObject(match) {
                hex := match[0]
                if InStr(hex, "0x") {
                    hex := StrReplace(hex, "0x", "")
                }
                new_outscript .= lastGuiControl ".Opt(`"Background" hex "`")"
                new_outscript .= "`n"
            }
        }
        else if (trimField = "Menu := Menu()") {
            ;fix naming convension of Menu
            new_outscript .= StrReplace(A_LoopField, "Menu := Menu()", "Menu_Storage := Menu()")
            new_outscript .= "`n"
            FindMenu := 1
        }
        else if InStr(trimField, ".New(") {
            ;fix naming convension of Menu
            new_outscript .= StrReplace(A_LoopField, ".New(", ".Opt(") "`n"
            Continue
        }
        else if (FindMenu = 1) && (InStr(trimField, "Menu.Add(")) {
            ;fix naming convension of Menu
            if (StrSplit(trimField, "(")[1] = "Menu.Add") {
                new_outscript .= StrReplace(A_LoopField, "Menu.Add(", "Menu_Storage.Add(") "`n"
            }
        }
        else if (trimField = "MenuBar := Menu()") {
            ;fix naming convension of MenuBar
            new_outscript .= StrReplace(A_LoopField, "MenuBar := Menu()", "MenuBar_Storage := MenuBar()")
            new_outscript .= "`n"
            FindMenuBar := 1
        }
        else if (FindMenuBar = 1) && InStr(trimField, "MenuBar.Add(") {
            if (StrSplit(trimField, "(")[1] = "MenuBar.Add") {
                new_outscript .= StrReplace(A_LoopField, "MenuBar.Add(", "MenuBar_Storage.Add(") "`n"
            }
        }
        else if InStr(A_LoopField, ".MenuToolbar := MenuBar") {
            ;fix naming convension of MenuToolbar
            new_outscript .= StrReplace(A_LoopField, "MenuToolbar := MenuBar", "MenuBar := MenuBar_Storage") "`n"
        }
        else if InStr(A_LoopField, ".Show(`"") && (guiShow = 0) {
            guiShow := 1
            
            ;look for line before `return` (GuiShow)
            ;if found, and NO [submit] button is used
            ;user will get tooltips on value changes
            ;instead of submittion
            if LVFound != 0 {
                new_outscript .= LVFound '.Add(,"Sample1")`n' LVFound '.OnEvent("DoubleClick", LV_DoubleClick)`n'
            }
            if itemFound
            {
                eventsStringified := []
                for ctrl in GuiCtrlStorage {
                    skip := false
                    ; ctrl.event := eventList[A_Index]
                    if eventsStringified.Length > 0 {
                        for eventstr in eventsStringified {
                            if ctrl['name'] = eventstr {
                                skip := true
                            }
                        }
                    }
                    if !skip {
                        eventsStringified.Push(ctrl['name'])
                        new_outscript .= ctrl['name'] ".OnEvent(`"" ctrl['event'] "`", OnEventHandler)`n"
                    }
                }
            }
            new_outscript .= guiname ".OnEvent('Close', (*) => ExitApp())`n" . title . "`n" A_LoopField . "`n"
            if LVFound {
                new_outscript .= LVFunc 
            }
        }
        else {
            new_outscript .= A_LoopField . "`n"
        }
    }
    new_outscript := InStr(new_outscript, "ListviewListview") ? StrReplace(new_outscript, "ListviewListview", "LV_") : new_outscript
    new_outscript := InStr(new_outscript, "ogc") ? StrReplace(new_outscript, "ogc", "") : new_outscript
    foundConstruct := false
    finalScript := ""
    loop parse, new_outscript, "`n" "`r"
    {
        if !foundConstruct
        {
            if A_LoopField = "Construct() {"
                foundConstruct := true
            finalScript .= A_LoopField "`n"
        }
        else
            finalScript .= "`t" A_LoopField "`n"
    }
    finalScript := finalScript "`treturn myGui`n}"
    lastReturned := finalScript
    return finalScript
}
checkforGuiItems(LoopField, &GuiControlVars, &GuiItemCounter, &GuiCtrlStorage) {
    for ctrl in GuiControlVars
    {
        if InStr(LoopField, Format(".Add(`"{1}`"", ctrl["ctrl"]))
        {
            if InStr(LoopField, " := ") {
                var := StrSplit(LoopField, " := ")[1]
                if not IsAlnum(var) {
                    var := cleanAlpha(var) GuiItemCounter[A_Index]
                }
                GuiCtrlStorage.Push(Map( 'name', var, 'event', ctrl['event'], 'function', ctrl['function'] ))
                return [1, var]
            }
            else {
                var := ctrl["ctrl"] GuiItemCounter[A_Index]
                GuiCtrlStorage.Push(Map('name', var, 'event', ctrl['event'], 'function', ctrl['function']))
                GuiItemCounter[A_Index] += 1
                return [2, var]
            }
        }
    }
    return [0]
}

tooltip_(str := "") {
    if (str != "") {
        str := "`n`t. `"Active GUI element values include:``n`" " . str
    }
    return "{`n`tToolTip(`"Click! This is a sample action.``n`"" str ", 77, 277)`n`tSetTimer () => ToolTip(), -3000 `; tooltip timer`n}`n"
}

cleanAlpha(StrIn) {
    len := StrLen(StrIn)
    newVar := ""
    loop len {
        char := SubStr(StrIn, A_Index, 1)
        if IsAlpha(char) {
            newVar .= char
        }
    }
    return newVar
}
