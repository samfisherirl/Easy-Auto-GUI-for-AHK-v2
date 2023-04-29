


;=====================================
;starting line number: 1392
;=====================================
            TabEx.SetText(n, FileName)

            If (FileExt = "ahk") {
                TabEx.SetIcon(n, 2)
            } Else {
                Sci[n].SetLexer(0)
            }
                        /*
            add CUSTOM CODE HERE
            */
            Runtime := A_ScriptDir "\convert\runtime.txt"
            Temp := A_ScriptDir "\convert\temp.txt"
            Logs := A_ScriptDir "\convert\log.txt"
            if FileExist(Runtime){
                FileMove, %Runtime%, %Temp%, 1
            }
            if FileExist(Logs){
                FileMove, %Logs%, %Temp%, 1
            }
            FileAppend,  %fRead%, %Runtime%, %Encoding%
            FileAppend %Runtime%, %Logs%, %Encoding%
            Loop 50 
            {
                if FileExist(Runtime)
                {
                    FileRead, fRead, %Runtime%
                }
                else {
                    Sleep, 50
                }

            }


            Sci[n].FullName := File
            Sci[n].FileName := FileName
            Sci[n].SetText("", fRead, 1)
            Sci[n].SetSavePoint()
            ;Sci[n].Encoding := fEncoding

            If (Flag == 0) {
                Sci[n].EmptyUndoBuffer()
            }

            FileGetTime Timestamp, %File%
            Sci[n].LastWriteTime := Timestamp
        }

        fRead := ""

        AddToRecentFiles(File)
    }

    Return n
}

SaveAs:
    SaveAs(TabEx.GetSel())
Return

SaveAs(n) {
    TabEx.SetSel(n)

    StartPath := (Sci[n].FileName != "") ? Sci[n].FullName : g_SaveDir
    Gui Auto: +OwnDialogs
    FileSelectFile SelectedFile, S16, %StartPath%, Save, AutoHotkey Scripts (*.ahk)
    If (ErrorLevel) {
        Return
