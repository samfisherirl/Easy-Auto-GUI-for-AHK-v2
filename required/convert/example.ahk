;using this repo as an example: https://github.com/samfisherirl/Github.ahk-API-for-AHKv2
;credit: https://github.com/TheArkive/JXON_ahk2
;credit: https://github.com/thqby/ahk2_lib
usr := "samfisherirl"
repo := "Github.ahk-API-for-AHKv2"

#Include %A_ScriptDir%\lib\github.ahk

latestObj := Github.latest(usr, repo)

currentVersion := "v1"
if currentVersion != latestObj.version 
{
    MsgBox "Time for an update, latest version is " 
    . latestObj.version " updated on " latestObj.date "`nNotes:`n" 
    . latestObj.change_notes "`n`nLink: " latestObj.DownloadURLs[1]
}

userResponse := MsgBox(
    	 "Github.ahk-API-for-AHKv2's latest update is dated:`n"
    	latestObj.date "`nVersion: " latestObj.version 
    	"`nWould you like to download?",, '36')

if (userResponse = "Yes"){
	Github.Download(latestObj.downloadURLs[1], A_ScriptDir "\download")
	;latestObj.downloadURLs[] = array of release files - IE
	;latestObj.downloadURLs[1] = url to => "releasev1.1.zip" 
	;latestObj.downloadURLs[2] = url to => "releasev1.1.rar"
}

for url in latestObj.downloadURLs {
    if InStr(url, ".zip") {
        Github.download(url, A_ScriptDir) 
        break
    }
}
; object := Gitub(Username, Repository)


; just a name can be passed. extension will be handled.
; this will get saved to A_ScriptDir

Github.Source(usr, repo, A_ScriptDir "\main.zip")
; download main branch source code

; Multiple Assets use-case
; enumerate ==ALL Historic Releases==
repo_string := ""
for repo in Github.historicReleases(usr, repo) {
    /* 
        downloadURLs: [],
        version: "",
        change_notes: "",
        date: ""  
    */
    repo_string .= repo.name " version " repo.version " was released on " repo.date "`nUpdate notes: `n" 
    repo_string .= repo.change_notes "`nDownload Link: " repo.downloadURL "`n`n"
}
MsgBox(repo_string)

; InStr search through each Release name first, then falls back on URL.
; First match returns the url for Download, then use that below:

/*
Latest version, great for storing and checking for updates.
*/
