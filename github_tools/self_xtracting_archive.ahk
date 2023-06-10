#Requires Autohotkey v2.0
a := A_ScriptDir
S := "7za.exe"
FileInstall "7z.exe", "7za.exe", 1 
T := "`""
SZpath := addQuotes("7za.exe")
archive := addQuotes("Auto-GUI-v2.7z")
out := addQuotes("AutoGUIv2")
comline := SZpath . " x " . archive . " -y " . " -o" . out
Run(comline)

Sleep(5000)
loop 50
{
    try {
        Run(out "\Launch_AutoGUI.exe")
        break
    }
    catch {
        Sleep(150)
    }
}
addQuotes(string) {
    return T . a . "\" . string . T
}
