#Include %A_ScriptDir%\lib\github.ahk
#Include %A_ScriptDir%\lib\WinHttpRequest.ahk
#Include %A_ScriptDir%\lib\JXON.ahk

zipperPath := A_ScriptDir "\required\7za.exe"
command := "`"" zipperPath "`" x `"" A_ScriptDir "\release.zip" "`" -y -o`"" A_ScriptDir "`""

git := Github("samfisherirl", "Easy-Auto-GUI-for-AHK-v2")
release := A_ScriptDir "\release.zip"

git.Download(release)

Sleep(1000) 
loop 2 {
    if FileExist(release) {
        RunWait(command)
        break
    }
    else {
        Sleep(1500)
    }
    
}