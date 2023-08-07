 
    /*
    add CUSTOM CODE HERE
    */
    CurrentCode := ""
    Last_Code := ""
    CodeBack := ""
    if (Code == ""){
        Goto, Nvm
    }
    if (Code != ""){
        /* 
        if FileExist(last1){
            Code_to_Test := reader(last1)
            if (Code_to_Test == Code) && (Code_to_Test != ""){
                Goto, Nvm
            }
        } 
        */
        ;FileMove, %Runtime%, %Temp%, 1
        writer(Code, last1)
        writer("", ReturnStatus)
        writer(Code, Runtime)
        writer("", ahkv2Code)
        writer(Runtime, Logs)
        Loop 150
        {
            if (reader(ReturnStatus) != "")
            {
                CodeBack := reader(ahkv2Code)
                if (CodeBack == "") {
                    Sleep, 20
                    continue
                }
                else {
                    if FileExist(last2){
                        ToBeTested := reader(last2)
                        if (ToBeTested != "") && (ToBeTested == CodeBack) {
                            Goto, Nvm
                        }
                    }
                    writer("", Runtime)
                    writer("", ahkv2Code)
                    break
                }
            }
            else
            {
                Sleep, 25
            }
        }
    }
    if (CodeBack != "") {
        Code := CodeBack
    }
    else {
        Goto, Nvm
    }
    Last_Code := Code
    writer(Last_Code, last2)
    Header := Code
    g_Signature := Code
    sci[g_GuiTab].SetReadOnly(0)
    Sci[g_GuiTab].BeginUndoAction()
    Sci[g_GuiTab].ClearAll()
    Sci[g_GuiTab].SetText("", Code, 2)
    Sci[g_GuiTab].EndUndoAction()
    sci[g_GuiTab].SetReadOnly(1)

    If (!g_DesignMode) {
        GoSub SwitchToDesignMode
    }
    If (TabEx.GetSel() != g_GuiTab) {
        TabEx.SetSel(g_GuiTab)
    }

    Header := ""
    Code := ""
    SciText := ""

    Nvm:
}

reader(path){
    if FileExist(path) {
        loop 5
        {
            try {
                F := FileOpen(path, "r", "utf-8")
                str := F.Read()
                F.Close()
                return str
            }
            catch {
                continue
            }
        }
    }
    return ""
}


Writer(str, path){
    F := FileOpen(path, "w", "utf-8")
    F.Write(str)
    F.Close()
} 