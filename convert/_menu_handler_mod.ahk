add_menuhandler(FNOut) {
    x := 0
    y := 0
    z := 0
    a := 0
    newoutscript := ""
    intxt := FileRead(FNOut)
    Loop parse, intxt, "`n", "`r" {
        if InStr(A_LoopField, "MenuHandler") and x == 0 {
            x := 1
            newoutscript .= A_LoopField . "`n`r"
        }
        else if instr(A_LoopField, "GuiEscape(*)") and x == 1 and y == 0 {
            newoutscript .= "MenuHandler(*) {`n`tToolTip `"Click!`", 100, 150`n}`n" A_LoopField
            y := 1
        }
        else if instr(A_LoopField, "myGui.OnEvent(`"Close`", GuiEscape)") {
            continue
        }
        else if instr(A_LoopField, "myGui.OnEvent(`"Escape`", GuiEscape)") {
            continue
        }
        else if instr(A_LoopField, "Bind(`"Normal`")") {
            continue
        }
        else if (A_LoopField == ""){
            continue
        }
        ; else if instr(Ltrim(A_LoopField), "MenuBar.Add(") and a == 1 {
        ;     if StrSplit(Ltrim(A_LoopField), "(")[1] == "MenuBar.Add" {
        ;         newoutscript .= StrReplace(A_LoopField, "MenuBar.Add(", "MenBar.Add(")
        ;         newoutscript .= "`n`r"
        ;     }
        ; ; }
        else if (Ltrim(A_LoopField) == "Menu := Menu()") {
            newoutscript .= StrReplace(A_LoopField, "Menu := Menu()", "Men := Menu()")
            newoutscript .= "`n`r"
            z := 1
        }
        else if (instr(Ltrim(A_LoopField), "Menu.Add(") and z == 1) {
            if (StrSplit(Ltrim(A_LoopField), "(")[1] == "Menu.Add") {
                newoutscript .= StrReplace(A_LoopField, "Menu.Add(", "Men.Add(")
                newoutscript .= "`n`r"
            }
        }
        else if (Ltrim(A_LoopField) == "MenuBar := Menu()") {
            newoutscript .= StrReplace(A_LoopField, "MenuBar := Menu()", "MenBars := MenuBar()")
            newoutscript .= "`n`r"
            a := 1
        }
        else if (instr(Ltrim(A_LoopField), "MenuBar.Add(") and a == 1) {
            if (StrSplit(Ltrim(A_LoopField), "(")[1] == "MenuBar.Add") {
                newoutscript .= StrReplace(A_LoopField, "MenuBar.Add(", "MenBars.Add(")
                newoutscript .= "`n`r"
            }
        }
        else if instr(A_LoopField, "AutoGUI 2.5.8") {
            newoutscript .= "`;AutoGUI 2.5.8 `n`r `n`r"
        }
        else if instr(A_LoopField, ".MenuToolbar := MenuBar") {
            newoutscript .= StrReplace(A_LoopField, "MenuToolbar := MenuBar", "MenuBar := MenBars")
            newoutscript .= "`n`r"
        }
        else {
            newoutscript .= A_LoopField . "`n`r"
        }
    }
    FileDelete(FNOut)
    FileAppend(newoutscript, FNOut)
}