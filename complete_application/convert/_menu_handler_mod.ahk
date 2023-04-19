add_menuhandler(FNOut) ;outscript_path
{
    x := 0 ; => these denote true[1]/false[0]
    y := 0 ; => for various bad output code, such as 
    z := 0 ; => once MenuBar := Menubar() is found z := 1; 
    a := 0 ; => if z==1 check for menubar.add()
    ; this will all get removed with methods
    ; && for loops
    newoutscript := ""
    intxt := FileRead(FNOut)
    Loop parse, intxt, "`n", "`r" {
        if InStr(A_LoopField, "MenuHandler") && x == 0 {
            x := 1
            newoutscript .= A_LoopField . "`n"
        }
        else if instr(A_LoopField, "GuiEscape(*)") && x == 1 && y == 0 {
            newoutscript .= "MenuHandler(*) {`n`tToolTip `"Click!`", 100, 150`n}`n" A_LoopField
            y := 1
        }
        else if instr(A_LoopField, "myGui.OnEvent(`"Close`", GuiEscape)") || instr(A_LoopField, "myGui.OnEvent(`"Escape`", GuiEscape)") || instr(A_LoopField, "Bind(`"Normal`")") || (A_LoopField == "")  {
            continue
        }
        ; else if instr(Ltrim(A_LoopField), "MenuBar.Add(") && a == 1 {
        ;     if StrSplit(Ltrim(A_LoopField), "(")[1] == "MenuBar.Add" {
        ;         newoutscript .= StrReplace(A_LoopField, "MenuBar.Add(", "MenBar.Add(")
        ;         newoutscript .= "`n"
        ;     }
        ; ; }
        else if (Ltrim(A_LoopField) == "Menu := Menu()") {
            newoutscript .= StrReplace(A_LoopField, "Menu := Menu()", "Men := Menu()")
            newoutscript .= "`n"
            z := 1
        }
        else if (z == 1 && instr(Ltrim(A_LoopField), "Menu.Add(")) {
            if (StrSplit(Ltrim(A_LoopField), "(")[1] == "Menu.Add") {
                newoutscript .= StrReplace(A_LoopField, "Menu.Add(", "Men.Add(")
                newoutscript .= "`n"
            }
        }
        else if (Ltrim(A_LoopField) == "MenuBar := Menu()") {
            newoutscript .= StrReplace(A_LoopField, "MenuBar := Menu()", "MenBars := MenuBar()")
            newoutscript .= "`n"
            a := 1
        }
        else if (a == 1 && instr(Ltrim(A_LoopField), "MenuBar.Add(")) {
            if (StrSplit(Ltrim(A_LoopField), "(")[1] == "MenuBar.Add") {
                newoutscript .= StrReplace(A_LoopField, "MenuBar.Add(", "MenBars.Add(")
                newoutscript .= "`n"
            }
        }
        else if (A_Index == 2) {
            newoutscript := "`;AutoGUI 2.5.8 `n`;Auto-GUI-v2 credit to autohotkey.com/boards/viewtopic.php?f=64&t=89901`n`;AHKv2converter credit to github.com/mmikeww/AHK-v2-script-converter`n"
        }
        else if instr(A_LoopField, ".MenuToolbar := MenuBar") {
            newoutscript .= StrReplace(A_LoopField, "MenuToolbar := MenuBar", "MenuBar := MenBars")
            newoutscript .= "`n"
        }
        else {
            newoutscript .= A_LoopField . "`n"
        }
    }
    FileDelete(FNOut)
    FileAppend(newoutscript, FNOut)
}