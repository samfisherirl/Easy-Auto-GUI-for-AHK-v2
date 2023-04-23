add_menuhandler(FNOut) ;outscript_path
{
    menuhandle := 0 ; => these denote true[1]/false[0]
    GuiEsc:= 0 ; => for various bad output code, such as 
    FindMenu := 0 ; => once MenuBar := Menubar() is found FindMenu:= 1; 
    FindMenuBar := 0 ; => 
    ; this will all get removed with methods
    ; && for loops
    newoutscript := ""
    intxt := FileRead(FNOut)
    FileMove(FNOut, A_ScriptDir "\complete_application\temp.txt", 1)
    Loop Parse, intxt, "`n", "`r" {
        if (menuhandle == 0) && InStr(A_LoopField, "MenuHandler"){
            menuhandle := 1
            newoutscript .= A_LoopField . "`n"
        }
        else if (menuhandle == 1) && InStr(A_LoopField, "GuiEscape(*)") {
            newoutscript .= "MenuHandler(*) {`n`tToolTip `"Click!`", 100, 150`n}`n" A_LoopField
            GuiEsc:= 1
        }
        else if InStr(A_LoopField, "myGui.OnEvent(`"Close`", GuiEscape)") || InStr(A_LoopField, "myGui.OnEvent(`"Escape`", GuiEscape)") || InStr(A_LoopField, "Bind(`"Normal`")") || (A_LoopField == "")  {
            continue
        }
        ; else if InStr(LTrim(A_LoopField), "MenuBar.Add(") && a == 1 {
        ;     if StrSplit(LTrim(A_LoopField), "(")[1] == "MenuBar.Add" {
        ;         newoutscript .= StrReplace(A_LoopField, "MenuBar.Add(", "MenBar.Add(")
        ;         newoutscript .= "`n"
        ;     }
        ; ; }
        else if (LTrim(A_LoopField) == "Menu := Menu()") {
            newoutscript .= StrReplace(A_LoopField, "Menu := Menu()", "Men := Menu()")
            newoutscript .= "`n"
            FindMenu := 1
        }
        else if (FindMenu == 1 && InStr(LTrim(A_LoopField), "Menu.Add(")) {
            if (StrSplit(LTrim(A_LoopField), "(")[1] == "Menu.Add") {
                newoutscript .= StrReplace(A_LoopField, "Menu.Add(", "Men.Add(")
                newoutscript .= "`n"
            }
        }
        else if (LTrim(A_LoopField) == "MenuBar := Menu()") {
            newoutscript .= StrReplace(A_LoopField, "MenuBar := Menu()", "MenBars := MenuBar()")
            newoutscript .= "`n"
            FindMenuBar := 1
        }
        else if (FindMenuBar == 1) && InStr(LTrim(A_LoopField), "MenuBar.Add(") {
            if (StrSplit(LTrim(A_LoopField), "(")[1] == "MenuBar.Add") {
                newoutscript .= StrReplace(A_LoopField, "MenuBar.Add(", "MenBars.Add(")
                newoutscript .= "`n"
            }
        }
        else if (A_Index == 2) {
            newoutscript := "`n" ";AutoGUI 2.5.8 " "`n" ";Auto-GUI-v2 credit to autohotkey.com/boards/viewtopic.php?f=64&t=89901`n;AHKv2converter credit to github.com/mmikeww/AHK-v2-script-converter`n`n"
        }
        else if InStr(A_LoopField, ".MenuToolbar := MenuBar") {
            newoutscript .= StrReplace(A_LoopField, "MenuToolbar := MenuBar", "MenuBar := MenBars")
            newoutscript .= "`n"
        }
        else {
            newoutscript .= A_LoopField . "`n"
        }
    }
    FileAppend(newoutscript, FNOut)
}