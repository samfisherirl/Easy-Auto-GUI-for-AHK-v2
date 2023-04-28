a := A_ScriptDir
T := "`""
SZpath := T . a . "\7za.exe" . T 
archive := T . a . "\Auto-GUI-v2.7z" . T 
out := T . a . "\AutoGUIv2" . T
comline := SZpath . " x " . archive . " -y " . " -o" . out
Run(comline)

Sleep(5000)
try {
    Run(out "\Launch_AutoGUI.exe")
}
catch {
    msgbox("timeout, find exe in folder")
}

class files 
{
    __New() {
        this.path := ""
        this.size := 0
        this.total_files := 0
    }
    
    process(){
        this.looper()
        if this.total_files {

        }
    }
    looper() {
        Loop Files A_ScriptDir . "\out"
        {
            if A_LoopFileExt == ".exe" {
                if this.path == "" {
                    this.path := A_LoopFilePath
                    this.size := A_LoopFileSize
                }
        } 
        
        this.total_files += 1
} } }   