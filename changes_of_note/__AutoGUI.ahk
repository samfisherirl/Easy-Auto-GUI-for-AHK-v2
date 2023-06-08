


;=====================================
;starting line number: 1392                TabEx.SetText(n, FileName)
;=====================================

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
                empty := A_ScriptDir "\convert\empty.txt"

                if FileExist(Runtime){
                    FileMove, %Runtime%, %Temp%, 1
                }
                FileAppend, %Runtime%, %Logs%, %Encoding%
                if FileExist(Logs){
                    FileMove, %Logs%, %temp%, 1
                }
                Loop 50
                {
                    if FileExist(Runtime)
                    {
                        FileRead, fRead, %Runtime%
                        if (fRead == "")
                        {
                            sleep, 50
                            continue
                        }
                        else
                        {
                            break
                        }
                    }
                    else {
                        Sleep, 50
                        continue
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
