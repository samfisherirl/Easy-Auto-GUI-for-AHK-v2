add_menuHandler(FNOut := "path", script := "code") ;outscript_path
{
    global GuiItemVars := Map("Button", "Click", "DropDownList", "Change",
        "Edit", "Change", "DateTime", "Change",
        "MonthCal", "Change", "Radio", "Click",
        "CheckBox", "Click", "ComboBox", "Change")
    global eventList := []
    global GuiItemCounter := [1, 1, 1, 1, 1, 1, 1, 1]
    brackets := 0
    ; RemoveFunction==1 loops to find `{}` while `{}` not found in line
    new_outscript := ""
    buttonFound := 0, itemFound := 0, editCount := 0, menuHandler := 0, guiShow := 0, RemoveFunction := 0, menuHandle := 0, GuiEsc := 0, FindMenu := 0, FindMenuBar := 0, MenuHandleCount := 0, ctrlcolor := 0
    guiname := "", title := ""
    global GuiItem_Storage := []
    Edit_Storage := []
    if FileExist(FNOut) {
        FileMove(FNOut, A_ScriptDir "\required\convert\temp.txt", 1)
    }
    Loop Parse, script, "`n", "`r"
    {
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
        if InStr(A_LoopField, "Add(") {
            ret := checkforGuiItems(A_LoopField)
            ; ; loop through and look for GuiItemVars[]
            if (ret[1] = 1) {
                ;button
                itemFound := 1
                lastGuiControl := ret[2]
                oldvar := StrSplit(A_LoopField, " := ")[1]
                newline := StrReplace(A_LoopField, oldvar, ret[2])
                new_outscript .= newline "`n"
                continue
            }
            if (ret[1] = 2) {
                new_outscript .= ret[2] " := " A_LoopField "`n"
                lastGuiControl := ret[2]
                itemFound := 1
                continue
            }
            else {
                lastGuiControl := StrSplit(A_LoopField, " := ")
            }
        }
        ; =================== check for gui items =======================
        if InStr(A_LoopField, ".Title :=") {
            title := A_LoopField
            continue
        }
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
            menuHandler := 1
            ;if END OF SCRIPT found, attempt to append functions
            ;Function MenuHandler or OnEventHandler
            ;provide tooltips when buttons are clicked or values are entered
            if (menuHandle = 1) && (MenuHandleCount < 2) {
                new_outscript .= "`nMenuHandler(*)`n" tooltip_()
                GuiEsc := 1
            }
            if (itemFound = 1) {
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
                else {
                    new_outscript .= func . tooltip_()
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
        else if InStr(A_LoopField, "OnEvent(`"Close`", GuiEscape)") || InStr(A_LoopField, "OnEvent(`"Escape`", GuiEscape)") || InStr(A_LoopField, "Bind(`"Normal`")") || (A_LoopField = "") || InStr(A_LoopField, ".SetFont()") || InStr(A_LoopField, ".hwnd") || InStr(A_LoopField, "+hWnd") {
            ;remove all if cases
            continue
        }
        else if InStr(A_LoopField, "ControlColor(") {
            ctrlcolor := 1
            RegExMatch(A_LoopField, "0x[a-fA-F0-9]{6}", &match)
            if IsObject(match) {
                hex := match[0]
                new_outscript .= "ControlColor(" lastGuiControl ", " guiname ", " hex ")"
                new_outscript .= "`n"
            }
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
            guiShow := 1
            ;look for line before `return` (GuiShow)
            ;if found, and NO [submit] button is used
            ;user will get tooltips on value changes
            ;instead of submittion
            if (itemFound = 1)
            {
                eventsStringified := []
                for variable_name in GuiItem_Storage {
                    skip := false
                    event := eventList[A_Index]
                    if eventsStringified.Length > 0 {
                        for eventstr in eventsStringified {
                            if variable_name = eventstr {
                                skip := true
                            }
                        }
                    }
                    if skip = false {
                        eventsStringified.Push(variable_name)
                        new_outscript .= variable_name ".OnEvent(`"" event "`", OnEventHandler)`n"
                    }
                }
            }
            new_outscript .= guiname ".OnEvent('Close', (*) => ExitApp())`n"
            new_outscript .= title . "`n"
            new_outscript .= A_LoopField . "`n"
        }
        else {
            new_outscript .= A_LoopField . "`n"
        }
    }
    GuiItemVars := Map()
    eventList := []
    GuiItemCounter := []
    GuiItem_Storage := []
    return ctrlcolor = 1 ? new_outscript controlCol() : new_outscript
}
;.OnEvent('Close', (*) => ExitApp())

/*
removeBrokenFunctions(variable, equals) {
    returnValue := [0, variable, equals]
    if InStr(variable, " ") {
        variable := StrSplit(variable, " ")[StrSplit(variable, " ").Length]
        if InStr(variable, ".") {
            variable := StrSplit(variable, ".")[StrSplit(variable, ".").Length]
        }
    }
    returnValue[2] := variable
    if InStr(equals, " ") {
        if not InStr(equals, "`"") and not InStr(equals, "`'") {
            returnValue[1] := 1
        }
    }
    ; [1:=eraseline, ]
}
*/
checkforGuiItems(LoopField) {
    global GuiItemVars, GuiItem_Storage, GuiItemCounter, eventList
    for guicontrol, event in GuiItemVars
    {
        if InStr(LoopField, Format(".Add(`"{1}`"", guicontrol))
        {
            ;if button
            if InStr(LoopField, " := ") {
                ; var := Trim(StrSplit(LoopField, ":=")[1])
                ; GuiItem_Storage.Push(Trim(var))
                ; eventList.Push(event)
                var := StrSplit(LoopField, " := ")[1]
                if not IsAlnum(var) {
                    var := cleanAlpha(var) GuiItemCounter[A_Index]
                }
                GuiItem_Storage.Push(var)
                eventList.Push(event)
                return [1, var]
            }
            else {
                var := guicontrol GuiItemCounter[A_Index]
                GuiItem_Storage.Push(Trim(var))
                eventList.Push(event)
                GuiItemCounter[A_Index] += 1
                return [2, var]
            }
        }
    }
    return [0]
}

tooltip_(string := "") {
    if (string != "") {
        string := "`n`t. `"Active GUI element values include:``n`" " . string
    }
    return "{`n`tToolTip(`"Click! This is a sample action.``n`"" string ", 77, 277)`n`tSetTimer () => ToolTip(), -3000 `; tooltip timer`n}`n"
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

controlCol() {
    return
    (
        "
        ; original creator:
; http://www.autohotkey.com/board/topic/104539-controlcol-set-background-and-text-color-gui-controls/
; u/anonymous1184 for ahkv2 translation

/*
    @example
        btn := GuiObj.Add(`"Button`",,`"OK`")
        ControlColor(btn, g, 0xFF0000)
    @example
        btn := GuiObj.Add(`"Button`",,`"OK`")
        ControlColor(btn, g, `"red`")
        ; https://www.autohotkey.com/docs/v2/misc/Colors.htm
*/
class ControlColor {
    static Call(Control, Window, bc := `"`", tc := `"`", Redraw := true) 
    {
        Control := Control.hwnd, Window := Window.hwnd
        if IsAlpha(Trim(bc)) && not (bc = `"`") {
            bc := ControlColor.HColors(bc)
        }
        a := {
            c: Control,
            g: Window,
            bc: (bc = `"`") ? `"`" : (((bc & 255) << 16) + (((bc >> 8) & 255) << 8) + (bc >> 16)),
            tc: (tc = `"`") ? `"`" : (((tc & 255) << 16) + (((tc >> 8) & 255) << 8) + (tc >> 16))
        }
        this.CC_WindowProc(`"Set`", a, `"`", `"`")
        if (Redraw) {
            WinRedraw(, , `"ahk_id `" Control)
    } }
    static CC_WindowProc(hWnd, uMsg, wParam, lParam) 
    {
        static Win := Map()
        if (IsNumber(uMsg) && uMsg >= 306 && uMsg <= 312) { ; WM_CTLCOLOR(MSGBOX|EDIT|LISTBOX|BTN|DLG|SCROLLBAR|STATIC)
            if (Win[hWnd].Has(lParam)) {
                if (tc := Win[hWnd][lParam].tc) {
                    DllCall(`"gdi32\SetTextColor`", `"Ptr`", wParam, `"UInt`", tc)
                }
                if (bc := Win[hWnd][lParam].bc) {
                    DllCall(`"gdi32\SetBkColor`", `"Ptr`", wParam, `"UInt`", bc)
                }
                return Win[hWnd][lParam].Brush ; return the HBRUSH to notify the OS that we altered the HDC.
        } }
        if (hWnd = `"Set`") {
            a := uMsg
            Win[a.g] := Map(a.c, a)
            if ((Win[a.g][a.c].tc = `"`") && (Win[a.g][a.c].bc = `"`")) {
                Win[a.g].Remove(a.c, `"`")
            }
            if (!Win[a.g].Has(`"WindowProcOld`")) {
                method := ObjBindMethod(this, `"CC_WindowProc`")
                cb := CallbackCreate(method, , 4)
                retval := DllCall(`"SetWindowLong`" . (A_PtrSize = 8 ? `"Ptr`" : `"`"), `"Ptr`", a.g, `"Int`", -4, `"Ptr`", cb, `"Ptr`")
                Win[a.g][`"WindowProcOld`"] := retval
            }
            if (Win[a.g][a.c].bc != `"`") {
                Win[a.g][a.c].Brush := DllCall(`"gdi32\CreateSolidBrush`", `"UInt`", a.bc, `"Ptr`")
            }
            return
        }
        oldProc := IsSet(Win) && IsObject(Win) ? Win[hWnd][`"WindowProcOld`"] : 0
        return DllCall(`"CallWindowProc`", `"Ptr`", oldProc, `"Ptr`", hWnd, `"UInt`", uMsg, `"Ptr`", wParam, `"Ptr`", lParam, `"Ptr`")
    }
    static HColors(userColor)
    {
        Colors := Map(`"Black`", 0x000000, `"Silver`", 0xC0C0C0, `"Gray`", 0x808080, `"White`", 0xFFFFFF, `"Maroon`", 0x800000, `"Red`", 0xFF0000, 
                    `"Purple`", 0x800080, `"Fuchsia`", 0xFF00FF, `"Green`", 0x008000, `"Lime`", 0x00FF00, `"Olive`", 0x808000, `"Yellow`", 0xFFFF00, 
                    `"Navy`", 0x000080, `"Blue`", 0x0000FF, `"Teal`", 0x008080, `"Aqua`", 0x00FFFF)
        for color, code in Colors {
            if InStr(color, userColor) {
                return code
            }
        }
        return false
    }
}


        "
    )
}