UpdateCheck() {
    
    
    zipperPath := A_ScriptDir "\required\7za.exe"
    settings_path := A_ScriptDir "\required\settings.json"
    updater := A_ScriptDir "\required\updater.exe"
    command := "`"" zipperPath "`" x `"" A_ScriptDir "\required\req\required.7z" "`" -y -o`"" A_ScriptDir "\required\req`""

    
    if !FileExist(settings_path) {
        settings := Map("version", "v1.51", "disable_notifications", "0", "extracted_tools", 0)
        serialized := Jxon_Dump(settings)
        F := FileOpen(settings_path, "w")
        F.Write(serialized)
        F.Close()
    }

    settings := FileRead(settings_path)
    version_info := Jxon_Load(&settings)
    git := Github("samfisherirl", "Easy-Auto-GUI-for-AHK-v2")
    if (version_info["version"] != git.Version) {
        count := version_info["disable_notifications"]
        count := Integer(count)
        count := count + 1
        if count < 3 {
            answer := MsgBox("There's an update available. This will bring fixes and additions that will improve the current version you have. Would you like to update? (Automatic)", "Update Available", "68")
            if answer = "Yes" {
                count := 0
                FileMove(A_ScriptDir "\required\updater.exe", A_ScriptDir "\updater.exe", 1)
                RunWait(A_ScriptDir "\updater.exe")
                FileMove(A_ScriptDir "\updater.exe", A_ScriptDir "\required\updater.exe", 1)
                FileMove(A_ScriptDir "\release.zip", A_Temp "\release.temp", 1)
                settings := Map("version", git.Version, "disable_notifications", count)
                serialized := Jxon_Dump(settings)
                F := FileOpen(settings_path, "w")
                F.Write(serialized)
                F.Close()
            }
            else {
                version_info["disable_notifications"] := count
                serialized := Jxon_Dump(version_info)
                F := FileOpen(settings_path, "w")
                F.Write(serialized)
                F.Close()
            }
        }
    }
}