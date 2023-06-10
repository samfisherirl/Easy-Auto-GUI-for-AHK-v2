;credit: https://github.com/TheArkive/JXON_ahk2
;credit: https://github.com/thqby/ahk2_lib

class Github
{
    repo_storage := []
    /**
     * with this url as an example:
     * https://github.com/TheArkive/JXON_ahk2
     * @param Github_Username:="TheArkive"
     * @param Repository_Name:="JXON_ahk2"
     * @param Download (path_to_save, url := "optional") using DownloadAsync.ahk
     * @param this.getReleases() returns Map() of all releases, accessed @ this.repo_storage
     * @param this.repo_storage for i in repo_storage returns => i.downloadURL: "", i.version: "", i.change_notes: "", i.date: "",  i.name: ""
     * @param this.searchReleases ("keyword") search through all release names for keyword first, falling back to searching all urls. Returns URL to download for reuse in Download method
     * @param this.details() notes or body for the release with changes. 
     * @param this.LatestReleaseMap for releaseName, releaseURL in this.LatestReleaseMap
     * @param this.Version returns "v2.0.1" for example
     */
    __New(Username, Repository_Name) {
        temp := A_ScriptDir "\temp.json"
        this.usernamePlusRepo := Trim(Username) "/" Trim(Repository_Name)
        url := "https://api.github.com/repos/" this.usernamePlusRepo "/releases/latest"
        this.source_zip := "https://github.com/" this.usernamePlusRepo "/archive/refs/heads/main.zip"
        data := this.jsonDownload(url)
        data := JXON_Load(&data)
        this.data := data
        this.fileType := ""
        ;filedelete, "1.json"
        this.FirstAssetDL := data["assets"][1]["browser_download_url"]
        this.AssetJ := data["assets"]
        this.FirstAsset := data["assets"][1]["name"]
        this.ReleaseVersion := data["html_url"]
        this.Version := data["tag_name"]
        this.body := data["body"]
        this.repo_string := StrSplit(this.usernamePlusRepo, "/")[2]
        this.LatestReleaseMap := Map()
        this.AssetList := []
        this.DownloadExtension := ""
        this.olderReleases := Map()
        this.assetProps()
        ;this.Filetype := data["assets"][1]["browser_download_url"]
    }
    jsonDownload(URL) {
        Http := WinHttpRequest()
        Http.Open("GET", URL)
        Http.Send()
        Http.WaitForResponse()
        storage := Http.ResponseText
        return storage ;Set the "text" variable to the response
    }
    Source(Pathlocal){
        this.Download(PathLocal, URL := this.source_zip)
    }
    Download(PathLocal, URL := this.FirstAssetDL) {
        releaseExtension := this.downloadExtensionSplit(URL)
        pathWithExtension := this.handleUserPath(PathLocal, releaseExtension)
        Download(URL, pathWithExtension)
    }
    release() {
        return this.FirstAssetDL
    }
    name() {
        return this.FirstAssetName
    }
    details() {
        return this.body
    }
    assetProps() {
        for k, v in this.AssetJ {
            this.LatestReleaseMap.Set(v["name"], v["browser_download_url"])
        }
        return this.LatestReleaseMap
    }
    emptyRepoMap() {
        repo := {
            downloadURL: "",
            version: "",
            change_notes: "",
            date: "",
            name: ""
        }
        return repo
    }
    getReleases() {
        url := "https://api.github.com/repos/" this.usernamePlusRepo "/releases"
        data := this.jsonDownload(url)
        data := JXON_Load(&data)
        for igloo in data {
            for alpha in igloo["assets"] {
                repo := this.emptyRepoMap()
                repo.version := igloo["tag_name"]
                repo.change_notes := igloo["body"]
                repo.name := alpha["name"]
                repo.date := alpha["created_at"]
                repo.downloadURL := alpha["browser_download_url"]
                this.repo_storage.Push(repo)
            }
        }
        return this.repo_storage
    }
    downloadExtensionSplit(DL) {
        Arrays := StrSplit(DL, ".")
        this.filetype := Trim(Arrays[Arrays.Length])
        return this.filetype
    }
    getVersion() {
        url := StrSplit(this.ReleaseVersion, "/")
        version := url[8]
        return version
        ; msgbox % this.j[1].assets.name
        ; return this.j[1].assets.name
    }
    searchReleases(providedSearch) {
        for assetName, DLURL in this.LatestReleaseMap {
            if InStr(assetName, providedSearch) {
                return DLURL
            }
            else if InStr(DLURL, providedSearch) {
                return DLURL
            }
        }
    }

    handleUserPath(PathLocal, releaseExtension) {
        if InStr(PathLocal, "\") {
            pathParts := StrSplit(PathLocal, "\")
            FileName := pathParts[pathParts.Length]
        }
        else {
            FileName := PathLocal
            PathLocal := A_ScriptDir "\" FileName
            pathParts := StrSplit(PathLocal, "\")
        }
        if InStr(FileName, ".") {
            FileNameParts := StrSplit(FileName, ".")
            UserExtension := FileNameParts[FileNameParts.Length]
            if (releaseExtension != userExtension) {
                newName := ""
                for key, val in FileNameParts {
                    if (A_Index == FileNameParts.Length) {
                        break
                    }
                    newName .= val
                }
                newPath := ""
                for key, val in pathParts {
                    if (A_Index == pathParts.Length) {
                        break
                    }
                    newPath .= val
                }
                pathWithExtension := newPath newName "." releaseExtension
            }
            else {
                pathWithExtension := PathLocal
            }
        }
        else {
            pathWithExtension := PathLocal "." releaseExtension
        }
        return pathWithExtension
    }
}