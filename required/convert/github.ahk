;credit: https://github.com/TheArkive/JXON_ahk2
;credit: https://github.com/thqby/ahk2_lib

/*
    @source https://github.com/samfisherirl/Github.ahk-API-for-AHKv2
    @method Github.latest(Username,Repository_Name)

    return {
        downloadURLs: [
            "http://github.com/release.zip",
            "http://github.com/release.rar"
                    ],
        version: "",
        change_notes: "",
        date: "",
        }
        
    @method Github.historicReleases(Username,Repository_Name)
        array of objects => [{
            downloadURL: "",
            version: "",
            change_notes: "",
            date: ""
        }]
    @func this.Download(url,path)
        improves on download(): 
        - if user provides wrong extension, function will apply proper extension
        - allows user to provide directory 
        example:    Providing A_ScriptDir to Download will throw error
                    Providing A_ScriptDir to Github.Download() will supply Download() with release name 
*/
class Github
{
    static source_zip := ""
    static url := false
    static usernamePlusRepo := false
    static storage := {
        repo: "",
        source_zip: ""
    }
    static data := false

    static build(Username, Repository_Name) {
        Github.usernamePlusRepo := Trim(Username) "/" Trim(Repository_Name)
        Github.source_zip := "https://github.com/" Github.usernamePlusRepo "/archive/refs/heads/main.zip"
        return "https://api.github.com/repos/" Github.usernamePlusRepo "/releases"
        ;filedelete, "1.json"
        ;this.Filetype := data["assets"][1]["browser_download_url"]
    }
    /*
    return {
        downloadURLs: [
            "http://github.com/release.zip",
            "http://github.com/release.rar"
                    ],
        version: "",
        change_notes: "",
        date: "",
        }
    */
    static latest(Username := "", Repository_Name := "") {
        if (Username != "") & (Repository_Name != "") {
            url := Github.build(Username, Repository_Name)
            data := Github.processRepo(url)
            return Github.latestProp(data)
        }
    }
    /*
    static processRepo(url) {
        Github.source_zip := "https://github.com/" Github.usernamePlusRepo "/archive/refs/heads/main.zip"
        Github.data := Github.jsonDownload(url)
        data := Github.data
        return Jsons.Load(&data)
    }
    */
    static processRepo(url) {
        Github.source_zip := "https://github.com/" Github.usernamePlusRepo "/archive/refs/heads/main.zip"
        data := Github.jsonDownload(url)
        return Jsons.Load(&data)
    }
    /*
    @example
    repoArray := Github.historicReleases()
        repoArray[1].downloadURL => string | link
        repoArray[1].version => string | version data
        repoArray[1].change_notes => string | change notes
        repoArray[1].date => string | date of release
    
    @returns (array of release objects) => [{
        downloadURL: "",
        version: "",
        change_notes: "",
        date: ""
        }]
    */
    static historicReleases(Username, Repository_Name) {
        url := Github.build(Username, Repository_Name)
        data := Github.processRepo(url)
        repo_storage := []
        url := "https://api.github.com/repos/" Github.usernamePlusRepo "/releases"
        data := Github.jsonDownload(url)
        data := Jsons.Load(&data)
        for release in data {
            for asset in release["assets"] {
                repo_storage.Push(Github.repoDistribution(release, asset))
            }
        }
        return repo_storage
    }
    static latestProp(data) {
        for i in data {
            baseData := i
            assetMap := i["assets"]
            date := i["created_at"]
            if i["assets"].Length > 0 {
                length := i["assets"].Length
                releaseArray := Github.distributeReleaseArray(length, assetMap)
                break
            }
            else {
                releaseArray := ["https://github.com/" Github.usernamePlusRepo "/archive/" i["tag_name"] ".zip"]
                ;source url = f"https://github.com/{repo_owner}/{repo_name}/archive/{release_tag}.zip"
                break
            }
        }
        ;move release array to first if
        ;then add source
        return {
            downloadURLs: releaseArray,
            version: baseData["tag_name"],
            change_notes: baseData["body"],
            date: date
        }
    }
    /*
    loop releaseURLCount {
        assetArray.Push(JsonData[A_Index]["browser_download_url"])
    }
    return => assetArray[]
    */
    /*
    loop releaseURLCount {
        assetMap.Set(jsonData[A_Index]["name"], jsonData[A_Index]["browser_download_url"])
    }
    return => assetMap()
    */
    static jsonDownload(URL) {
        Http := WinHttpRequest()
        Http.Open("GET", URL)
        Http.Send()
        Http.WaitForResponse()
        storage := Http.ResponseText
        return storage ;Set the "text" variable to the response
    }
    static distributeReleaseArray(releaseURLCount, Jdata) {
        assetArray := []
        if releaseURLCount {
            if (releaseURLCount > 1) {
                loop releaseURLCount {
                    assetArray.Push(Jdata[A_Index]["browser_download_url"])
                }
            }
            else {
                assetArray.Push(Jdata[1]["browser_download_url"])
            }
            return assetArray
        }
    }
    /*
    download the latest main.zip source zip
    */
    static Source(Username, Repository_Name, Pathlocal := A_ScriptDir) {
        url := Github.build(Username, Repository_Name)
        data := Github.processRepo(url)

        Github.Download(URL := Github.source_zip, PathLocal)
    }
    /*
    benefit over download() => handles users path, and applies appropriate extension. 
    IE: If user provides (Path:=A_ScriptDir "\download.zip") but extension is .7z, extension is modified for the user. 
    If user provides directory, name for file is applied from the path (download() will not).
    Download (
        @param URL to download
        @param Path where to save locally
    )
    */
    static Download(URL, PathLocal := A_ScriptDir) {
        releaseExtension := Github.downloadExtensionSplit(URL)
        pathWithExtension := Github.handleUserPath(PathLocal, releaseExtension)
        try {
            Download(URL, pathWithExtension)
        } catch as e {
            MsgBox(e.Message . "`nURL:`n" URL)
        }
    }
    static emptyRepoMap() {
        repo := {
            downloadURL: "",
            version: "",
            change_notes: "",
            date: "",
            name: ""
        }
        return repo
    }

    static repoDistribution(release, asset) {
        return {
            downloadURL: asset["browser_download_url"],
            version: release["tag_name"],
            change_notes: release["body"],
            date: asset["created_at"],
            name: asset["name"]
        }
    }
    static downloadExtensionSplit(DL) {
        Arrays := StrSplit(DL, ".")
        filetype := Trim(Arrays[Arrays.Length])
        return filetype
    }

    static handleUserPath(PathLocal, releaseExtension) {
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
;;;; AHK v2 - https://github.com/TheArkive/JXON_ahk2
;MIT License
;Copyright (c) 2021 TheArkive
;Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
;The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
;THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;
; originally posted by user coco on AutoHotkey.com
; https://github.com/cocobelgica/AutoHotkey-JSON

; https://github.com/cocobelgica/AutoHotkey-JSON
class Jsons {

    static Load(&src, args*) {
        key := "", is_key := false
        stack := [tree := []]
        next := '"{[01234567890-tfn'
        pos := 0

        while ((ch := SubStr(src, ++pos, 1)) != "") {
            if InStr(" `t`n`r", ch)
                continue
            if !InStr(next, ch, true) {
                testArr := StrSplit(SubStr(src, 1, pos), "`n")

                ln := testArr.Length
                col := pos - InStr(src, "`n", , -(StrLen(src) - pos + 1))

                msg := Format("{}: line {} col {} (char {})"
                    , (next == "") ? ["Extra data", ch := SubStr(src, pos)][1]
                    : (next == "'") ? "Unterminated string starting at"
                        : (next == "\") ? "Invalid \escape"
                            : (next == ":") ? "Expecting ':' delimiter"
                                : (next == '"') ? "Expecting object key enclosed in double quotes"
                                    : (next == '"}') ? "Expecting object key enclosed in double quotes or object closing '}'"
                                        : (next == ",}") ? "Expecting ',' delimiter or object closing '}'"
                                            : (next == ",]") ? "Expecting ',' delimiter or array closing ']'"
                                                : ["Expecting JSON value(string, number, [true, false, null], object or array)"
                                                , ch := SubStr(src, pos, (SubStr(src, pos) ~= "[\]\},\s]|$") - 1)][1]
                                                , ln, col, pos)

                throw Error(msg, -1, ch)
            }

            obj := stack[1]
            is_array := (obj is Array)

            if i := InStr("{[", ch) { ; start new object / map?
                val := (i = 1) ? Map() : Array()	; ahk v2

                is_array ? obj.Push(val) : obj[key] := val
                stack.InsertAt(1, val)

                next := '"' ((is_key := (ch == "{")) ? "}" : "{[]0123456789-tfn")
            } else if InStr("}]", ch) {
                stack.RemoveAt(1)
                next := (stack[1] == tree) ? "" : (stack[1] is Array) ? ",]" : ",}"
            } else if InStr(",:", ch) {
                is_key := (!is_array && ch == ",")
                next := is_key ? '"' : '"{[0123456789-tfn'
            } else { ; string | number | true | false | null
                if (ch == '"') { ; string
                    i := pos
                    while i := InStr(src, '"', , i + 1) {
                        val := StrReplace(SubStr(src, pos + 1, i - pos - 1), "\\", "\u005C")
                        if (SubStr(val, -1) != "\")
                            break
                    }
                    if !i ? (pos--, next := "'") : 0
                        continue

                    pos := i ; update pos

                    val := StrReplace(val, "\/", "/")
                    val := StrReplace(val, '\"', '"')
                        , val := StrReplace(val, "\b", "`b")
                        , val := StrReplace(val, "\f", "`f")
                        , val := StrReplace(val, "\n", "`n")
                        , val := StrReplace(val, "\r", "`r")
                        , val := StrReplace(val, "\t", "`t")

                    i := 0
                    while i := InStr(val, "\", , i + 1) {
                        if (SubStr(val, i + 1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
                            continue 2

                        xxxx := Abs("0x" . SubStr(val, i + 2, 4)) ; \uXXXX - JSON unicode escape sequence
                        if (xxxx < 0x100)
                            val := SubStr(val, 1, i - 1) . Chr(xxxx) . SubStr(val, i + 6)
                    }

                    if is_key {
                        key := val, next := ":"
                        continue
                    }
                } else { ; number | true | false | null
                    val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$", , pos) - pos)

                    if IsInteger(val)
                        val += 0
                    else if IsFloat(val)
                        val += 0
                    else if (val == "true" || val == "false")
                        val := (val == "true")
                    else if (val == "null")
                        val := ""
                    else if is_key {
                        pos--, next := "#"
                        continue
                    }

                    pos += i - 1
                }

                is_array ? obj.Push(val) : obj[key] := val
                next := obj == tree ? "" : is_array ? ",]" : ",}"
            }
        }

        return tree[1]
    }
    static Dump(obj, indent := "", lvl := 1) {
        if IsObject(obj) {
            if obj.__Class = "Object" {
                obj := Jsons.convertObj(obj)
            } else if not (obj is Array || obj is Map || obj is String || obj is Number) && obj.base.__New {
                obj := Jsons.convertObj(obj)
            }
            If !(obj is Array || obj is Map || obj is String || obj is Number)
                throw Error("Object type not supported.", -1, Format("<Object at 0x{:p}>", ObjPtr(obj)))
            if IsInteger(indent)
            {
                if (indent < 0)
                    throw Error("Indent parameter must be a postive integer.", -1, indent)
                spaces := indent, indent := ""

                Loop spaces ; ===> changed
                    indent .= " "
            }
            indt := ""

            Loop indent ? lvl : 0
                indt .= indent

            is_array := (obj is Array)

            lvl += 1, out := "" ; Make #Warn happy
            for k, v in obj {
                ; if IsObject(k) || (k == "")
                    ;  throw Error("Invalid object key.", -1, k ? Format("<Object at 0x{:p}>", ObjPtr(obj)) : "<blank>")

                if !is_array ;// key ; ObjGetCapacity([k], 1)
                    out .= (ObjGetCapacity([k]) ? Jsons.Dump(k) : escape_str(k)) (indent ? ": " : ":") ; token + padding

                out .= Jsons.Dump(v, indent, lvl) ; value
                    . (indent ? ",`n" . indt : ",") ; token + indent
            }

            if (out != "") {
                out := Trim(out, ",`n" . indent)
                if (indent != "")
                    out := "`n" . indt . out . "`n" . SubStr(indt, StrLen(indent) + 1)
            }

            return is_array ? "[" . out . "]" : "{" . out . "}"

        } Else If (obj is Number)
            return obj
        Else ; String
            return escape_str(obj)

        escape_str(obj) {
            obj := StrReplace(obj, "\", "\\")
            obj := StrReplace(obj, "`t", "\t")
            obj := StrReplace(obj, "`r", "\r")
            obj := StrReplace(obj, "`n", "\n")
            obj := StrReplace(obj, "`b", "\b")
            obj := StrReplace(obj, "`f", "\f")
            obj := StrReplace(obj, "/", "\/")
            obj := StrReplace(obj, '"', '\"')

            return '"' obj '"'
        }
    }
    static ConvertObjectToMap(InputObject) {
        if IsObject(InputObject) {
            if InputObject.__Class = "Map" {
                return InputObject
            }
            else {
                return Jsons.convertObj(InputObject)
            }
        }
        else {
            return InputObject
        }
    }
    static convertObj(obj) {
        convertedObject := Map()
        for k, v in obj.OwnProps() {
            convertedObject.Set(k, v)
        }
        return convertedObject
    }
}
/************************************************************************
 * @file: WinHttpRequest.ahk
 * @description: 网络请求库
 * @author thqby
 * @date 2021/08/01
 * @version 0.0.18
 ***********************************************************************/

class WinHttpRequest {
    static AutoLogonPolicy := { Always: 0, OnlyIfBypassProxy: 1, Never: 2 }
    static Option := { UserAgentString: 0, URL: 1, URLCodePage: 2, EscapePercentInURL: 3, SslErrorIgnoreFlags: 4, SelectCertificate: 5, EnableRedirects: 6, UrlEscapeDisable: 7, UrlEscapeDisableQuery: 8, SecureProtocols: 9, EnableTracing: 10, RevertImpersonationOverSsl: 11, EnableHttpsToHttpRedirects: 12, EnablePassportAuthentication: 13, MaxAutomaticRedirects: 14, MaxResponseHeaderSize: 15, MaxResponseDrainSize: 16, EnableHttp1_1: 17, EnableCertificateRevocationCheck: 18, RejectUserpwd: 19
    }
    static PROXYSETTING := { PRECONFIG: 0, DIRECT: 1, PROXY: 2
    }
    static SETCREDENTIALSFLAG := { SERVER: 0, PROXY: 1
    }
    static SecureProtocol := { SSL2: 0x08, SSL3: 0x20, TLS1: 0x80, TLS1_1: 0x200, TLS1_2: 0x800, All: 0xA8
    }
    static SslErrorFlag := { UnknownCA: 0x0100, CertWrongUsage: 0x0200, CertCNInvalid: 0x1000, CertDateInvalid: 0x2000, Ignore_All: 0x3300
    }

    __New(UserAgent := unset) {
        this.whr := whr := ComObject('WinHttp.WinHttpRequest.5.1')
        whr.Option[0] := IsSet(UserAgent) ? UserAgent : 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36 Edg/89.0.774.68'
        this.IEvents := WinHttpRequest.RequestEvents.Call(ComObjValue(whr), this.id := ObjPtr(this))
    }
    __Delete() => (this.whr := this.IEvents := this.OnError := this.OnResponseDataAvailable := this.OnResponseFinished := this.OnResponseStart := 0)

    request(url, method := 'GET', data := '', headers := '') {
        this.Open(method, url)
        for k, v in (headers || {}).OwnProps()
            this.SetRequestHeader(k, v)
        this.Send(data)
        return this.ResponseText
    }

    ;#region IWinHttpRequest
    SetProxy(ProxySetting, ProxyServer, BypassList) => this.whr.SetProxy(ProxySetting, ProxyServer, BypassList)
    SetCredentials(UserName, Password, Flags) => this.whr.SetCredentials(UserName, Password, Flags)
    SetRequestHeader(Header, Value) => this.whr.SetRequestHeader(Header, Value)
    GetResponseHeader(Header) => this.whr.GetResponseHeader(Header)
    GetAllResponseHeaders() => this.whr.GetAllResponseHeaders()
    Send(Body := '') => this.whr.Send(Body)
    Open(verb, url, async := false) {
        this.readyState := 0
        this.whr.Open(verb, url, this.async := !!async)
        this.readyState := 1
    }
    WaitForResponse(Timeout := -1) => this.whr.WaitForResponse(Timeout)
    Abort() => this.whr.Abort()
    SetTimeouts(ResolveTimeout := 0, ConnectTimeout := 60000, SendTimeout := 30000, ReceiveTimeout := 30000) => this.whr.SetTimeouts(ResolveTimeout, ConnectTimeout, SendTimeout, ReceiveTimeout)
    SetClientCertificate(ClientCertificate) => this.whr.SetClientCertificate(ClientCertificate)
    SetAutoLogonPolicy(AutoLogonPolicy) => this.whr.SetAutoLogonPolicy(AutoLogonPolicy)
    whr := 0, readyState := 0, IEvents := 0, id := 0, async := 0
    OnResponseStart := 0, OnResponseFinished := 0
    OnResponseDataAvailable := 0, OnError := 0
    Status => this.whr.Status
    StatusText => this.whr.StatusText
    ResponseText => this.whr.ResponseText
    ResponseBody {
        get {
            pSafeArray := ComObjValue(t := this.whr.ResponseBody)
            pvData := NumGet(pSafeArray + 8 + A_PtrSize, 'ptr')
            cbElements := NumGet(pSafeArray + 8 + A_PtrSize * 2, 'uint')
            return ClipboardAll(pvData, cbElements)
        }
    }
    ResponseStream => this.whr.responseStream
    Option[Opt] {
        get => this.whr.Option[Opt]
        set => (this.whr.Option[Opt] := Value)
    }
    Headers {
        get {
            m := Map(), m.Default := ''
            loop parse this.GetAllResponseHeaders(), '`r`n'
                if (p := InStr(A_LoopField, ':'))
                    m[SubStr(A_LoopField, 1, p - 1)] .= LTrim(SubStr(A_LoopField, p + 1))
            return m
        }
    }
    ;#endregion
    ;#region IWinHttpRequestEvents
    class RequestEvents {
        dwCookie := 0, pCPC := 0, UnkSink := 0
        __New(pwhr, pparent) {
            IConnectionPointContainer := ComObjQuery(pwhr, IID_IConnectionPointContainer := '{B196B284-BAB4-101A-B69C-00AA00341D07}')
            DllCall("ole32\CLSIDFromString", "Str", IID_IWinHttpRequestEvents := '{F97F4E15-B787-4212-80D1-D380CBBF982E}', "Ptr", pCLSID := Buffer(16))
            ComCall(4, IConnectionPointContainer, 'ptr', pCLSID, 'ptr*', &pCPC := 0)    ; IConnectionPointContainer->FindConnectionPoint
            IWinHttpRequestEvents := Buffer(11 * A_PtrSize), offset := IWinHttpRequestEvents.Ptr + 4 * A_PtrSize
            NumPut('ptr', offset, 'ptr', pwhr, 'ptr', pCPC, IWinHttpRequestEvents)
            for nParam in StrSplit('3113213')
                offset := NumPut('ptr', CallbackCreate(EventHandler.Bind(A_Index), , Integer(nParam)), offset)
            ComCall(5, pCPC, 'ptr', IWinHttpRequestEvents, 'uint*', &dwCookie := 0) ; IConnectionPoint->Advise
            NumPut('ptr', dwCookie, IWinHttpRequestEvents, 3 * A_PtrSize)
            this.dwCookie := dwCookie, this.pCPC := pCPC, this.UnkSink := IWinHttpRequestEvents
            this.pwhr := pwhr

            EventHandler(index, pEvent, arg1 := 0, arg2 := 0) {
                req := ObjFromPtrAddRef(pparent)
                if (!req.async && index > 3 && index < 7) {
                    req.readyState := index - 2
                    return 0
                }
                ; critical('On')
                switch index {
                    case 1: ; QueryInterface
                        NumPut('ptr', pEvent, arg2)
                    case 2, 3:  ; AddRef, Release
                    case 4: ; OnResponseStart
                        req.readyState := 2
                        if (req.OnResponseStart)
                            req.OnResponseStart(arg1, StrGet(arg2, 'utf-16'))
                    case 5: ; OnResponseDataAvailable
                        req.readyState := 3
                        if (req.OnResponseDataAvailable) {
                            pSafeArray := NumGet(arg1, 'ptr')
                            pvData := NumGet(pSafeArray + 8 + A_PtrSize, 'ptr')
                            cbElements := NumGet(pSafeArray + 8 + A_PtrSize * 2, 'uint')
                            req.OnResponseDataAvailable(pvData, cbElements)
                        }
                    case 6: ; OnResponseFinished
                        req.readyState := 4
                        if (req.OnResponseFinished)
                            req.OnResponseFinished()
                    case 7: ; OnError
                        if (req.OnError)
                            req.OnError(arg1, StrGet(arg2, 'utf-16'))
                }
            }
        }
        __Delete() {
            try ComCall(6, this.pCPC, 'uint', this.dwCookie)
            loop 7
                CallbackFree(NumGet(this.UnkSink, (A_Index + 3) * A_PtrSize, 'ptr'))
            ObjRelease(this.pCPC), this.UnkSink := 0
        }
    }
    ;#endregion
}
