/*
	MsgBox Creator for AHK v2
	
	based on Thalon's original "Messagebox-Creator" script
	thanks to fincs for the icon from SciTE4AutoHotkey

	modified for v2 output and translated into v2 code by boiler, updated by AHK_user

	v1.0	- initial release
	v1.1	- added option for single quotes vs. double quotes as suggested by Helgef
			- automatically saves user preferences of the function format options:
				(parenthesis, numeric/string options, single/double quotes)
			- remembers last window position for next time it is run
	v1.2    - updated for AHK v2.0-beta.1 by AHK_user
*/
#Requires AutoHotKey v2
#SingleInstance Force


splashGUI := Gui()
showSplashScreen()

Paren := IniRead("MsgBox Creator settings.ini", "Main", "Paren", 1)
NumOpt := IniRead("MsgBox Creator settings.ini", "Main", "NumOpt", 1)
DoubleQu := IniRead("MsgBox Creator settings.ini", "Main", "DoubleQu", 1)
WinPosX := IniRead("MsgBox Creator settings.ini", "Main", "WinPosX", "NONE")
WinPosY := IniRead("MsgBox Creator settings.ini", "Main", "WinPosY", "NONE")

global TestMode := 0

MainGui := Gui(, "MsgBox Creator for AHK v2")
MainGui.Add("Text", "x10 y10 Section", "Title:")
MainGui.Add("Edit", "xs+0 ys+15 section w400 vTitle").OnEvent("Change", CreateMsgBoxFunction)
MainGui.Add("Text", "xs+0 ys+25 section", "Text:")
MainGui.Add("Edit", "xs+0 ys+15 section r3 w400 vText WantTab").OnEvent("Change", CreateMsgBoxFunction)

MainGui.Add("Groupbox", "x10 y120 h215 w190 section", "Buttons")
MainGui.Add("Radio", "xs+10 ys+20 section vButtonSelection1 Checked", "OK").OnEvent("Click", CreateMsgBoxFunction)
MainGui.Add("Radio", "xs+0 ys+25 section vButtonSelection2", "OK/Cancel").OnEvent("Click", CreateMsgBoxFunction)
MainGui.Add("Radio", "xs+0 ys+25 section vButtonSelection3", "Abort/Retry/Ignore").OnEvent("Click", CreateMsgBoxFunction)
MainGui.Add("Radio", "xs+0 ys+25 section vButtonSelection4", "Yes/No/Cancel").OnEvent("Click", CreateMsgBoxFunction)
MainGui.Add("Radio", "xs+0 ys+25 section vButtonSelection5", "Yes/No").OnEvent("Click", CreateMsgBoxFunction)
MainGui.Add("Radio", "xs+0 ys+25 section vButtonSelection6", "Retry/Cancel").OnEvent("Click", CreateMsgBoxFunction)
MainGui.Add("Radio", "xs+0 ys+25 section vButtonSelection7", "Cancel/Try Again/Continue").OnEvent("Click", CreateMsgBoxFunction)
MainGui.Add("Checkbox", "xs+0 ys+25 vButtonSelectionHelp", "Help button").OnEvent("Click", CreateMsgBoxFunction)

MainGui.Add("Groupbox", "x220 y120 h215 w190 section", "Icons")
Icon1Ctrl := MainGui.Add("Radio", "xs+10 ys+25 section vIcon1 Checked", "No Icon")
Icon1Ctrl.OnEvent("Click", SelectIcon)
Icon2Ctrl := MainGui.Add("Radio", "xs+0 ys+40 vIcon2", "Stop/Error")
Icon2Ctrl.OnEvent("Click", SelectIcon)
Icon3Ctrl := MainGui.Add("Radio", "xs+0 ys+80 vIcon3", "Question")
Icon3Ctrl.OnEvent("Click", SelectIcon)
Icon4Ctrl := MainGui.Add("Radio", "xs+0 ys+120 vIcon4", "Exclamation")
Icon4Ctrl.OnEvent("Click", SelectIcon)
Icon5Ctrl := MainGui.Add("Radio", "xs+0 ys+160 vIcon5", "Info")
Icon5Ctrl.OnEvent("Click", SelectIcon)

MainGui.Add("Picture", "xs+90 ys-10 h30 w20").OnEvent("Click", (*) => SelectIcon(Icon1Ctrl))
MainGui.Add("Picture", "xs+90 ys+30 icon4 w32 h32", A_WinDir "\system32\user32.dll").OnEvent("Click", (*) => SelectIcon(Icon2Ctrl))
MainGui.Add("Picture", "xs+90 ys+70 icon3 w32 h32", A_WinDir "\system32\user32.dll").OnEvent("Click", (*) => SelectIcon(Icon3Ctrl))
MainGui.Add("Picture", "xs+90 ys+110 icon2 w32 h32", A_WinDir "\system32\user32.dll").OnEvent("Click", (*) => SelectIcon(Icon4Ctrl))
MainGui.Add("Picture", "xs+90 ys+150 icon5 w32 h32", A_WinDir "\system32\user32.dll").OnEvent("Click", (*) => SelectIcon(Icon5Ctrl))

MainGui.Add("Groupbox", "x430 y20 h120 w190 section", "Modality")
MainGui.Add("Radio", "xs+10 ys+20 section Checked vModality1", "Normal").OnEvent("Click", CreateMsgBoxFunction)
MainGui.Add("Radio", "xs+0 ys+25 section vModality2", "Task Modal").OnEvent("Click", CreateMsgBoxFunction)
MainGui.Add("Radio", "xs+0 ys+25 section vModality3", "System Modal (always on top)").OnEvent("Click", CreateMsgBoxFunction)
MainGui.Add("Radio", "xs+0 ys+25 section vModality4", "Always on top").OnEvent("Click", CreateMsgBoxFunction)

MainGui.Add("Groupbox", "x430 y160 h45 w190 section", "Default Button")
MainGui.Add("Radio", "xs+10 ys+20 section Checked vDefault1", "1st").OnEvent("Click", CreateMsgBoxFunction)
MainGui.Add("Radio", "xs+65 ys+0 section vDefault2", "2nd").OnEvent("Click", CreateMsgBoxFunction)
MainGui.Add("Radio", "xs+65 ys+0 section vDefault3", "3rd").OnEvent("Click", CreateMsgBoxFunction)

MainGui.Add("Groupbox", "x430 y220 h45 w190 section", "Alignment")
MainGui.Add("Checkbox", "xs+10 ys+20 vAlignment1 section", "Right-justified").OnEvent("Click", CreateMsgBoxFunction)
MainGui.Add("Checkbox", "xs+100 ys+0 vAlignment2", "Right-to-left").OnEvent("Click", CreateMsgBoxFunction)

MainGui.Add("Groupbox", "x430 y280 h45 w100 section", "Timeout")
MainGui.Add("Edit", "xs+10 ys+17 w80 vTimeout").OnEvent("Change", CreateMsgBoxFunction)
MainGui.Add("UpDown", "Range-1-2147483", "-1")

MainGui.Add("Button", "x540 y285 h40 w80 vTest", "&Test").OnEvent("Click", Test)
MainGui.Add("Button", "x430 y345 h45 w100 Default", "&Copy result to clipboard").OnEvent("Click", CopyCode)
MainGui.Add("Button", "x540 y345 h45 w80", "&Reset").OnEvent("Click", (*) => Reset(MainGui))

MainGui.Add("Groupbox", "x10 y340 w105 h50 section", "Function Format")
ParenOptCtrl := MainGui.Add("Checkbox", "xs+10 ys+22 w90 vParen", "Parentheses")
ParenOptCtrl.OnEvent("Click", (*) => SaveOptions(MainGui))

MainGui.Add("Groupbox", "x125 ys w140 h50 section", "Options Format")
NumOptCtrl := MainGui.Add("Radio", "xs+10 ys+22 w60 vNumOpt", "Numeric")
NumOptCtrl.OnEvent("Click", (*) => SaveOptions(MainGui))
StrOptCtrl := MainGui.Add("Radio", "x+10 yp w50 vStrOpt", "String")
StrOptCtrl.OnEvent("Click", (*) => SaveOptions(MainGui))

MainGui.Add("Groupbox", "x275 ys w135 h50 section", "Quotation Marks")
DoubleQuOptCtrl := MainGui.Add("Radio", "xs+10 ys+22 w60 vDoubleQu", "Double")
DoubleQuOptCtrl.OnEvent("Click", (*) => SaveOptions(MainGui))
SingleQuOptCtrl := MainGui.Add("Radio", "x+5 yp w50 vSingleQu", "Single")
SingleQuOptCtrl.OnEvent("Click", (*) => SaveOptions(MainGui))

MainGui.Add("Groupbox", "x10 y395 w610 h75 section", "Result")
MainGui.SetFont(, "Courier New")
MainGui.SetFont(, "Lucida Sans Typewriter") ; preferred
MainGui.Add("Edit", "xs+10 ys+20 w590 r3 vFunctionText")

ParenOptCtrl.Value := Paren
if NumOpt
	NumOptCtrl.Value := 1
else
	StrOptCtrl.Value := 1
if DoubleQu
	DoubleQuOptCtrl.Value := 1
else
	SingleQuOptCtrl.Value := 1

MainGui.OnEvent("Close", (*) => ExitApp())
if (WinPosX = "NONE") || (WinPosY = "NONE")
	MainGui.Show()
else
	MainGui.Show("x" WinPosX " y" WinPosY)
CreateMsgBoxFunction(MainGui) ; initialize function string
OnMessage(0x232, WM_EXITSIZEMOVE)
return

CreateMsgBoxFunction(this, *) {
	Try
		saved := this.Submit(0)
	Catch {
		this := this.Gui
		saved := this.Submit(0)
	}
	loop 7 {
		if (saved.ButtonSelection%A_Index% = 1) {
			buttonSelection := A_Index - 1
			break
		}
	}
	help := (saved.ButtonSelectionHelp ? 16384 : 0)
	loop 5 {
		if (saved.Icon%A_Index% = 1) {
			icon := [0, 16, 32, 48, 64][A_Index]
			break
		}
	}
	loop 4 {
		if (saved.Modality%A_Index% = 1) {
			modality := [0, 8192, 4096, 262144][A_Index]
			break
		}
	}
	loop 3 {
		if (saved.Default%A_Index% = 1) {
			default := [0, 256, 512][A_Index]
			break
		}
	}
	title := EscapeCharacters(saved.Title, saved.DoubleQu)
	text := EscapeCharacters(saved.Text, saved.DoubleQu)
	timeout := saved.Timeout
	alignment := (saved.Alignment1 = 1) * 524288 + (saved.Alignment2 = 1) * 1048576
	if saved.StrOpt
		options :=	StrReplace(RTrim(["O", "OC", "ARI", "YNC", "YN", "RC", "CTC"][buttonSelection + 1] . " "
						. Map(0, "", 16, "IconX", 32, "Icon?", 48, "Icon!", 64, "Iconi")[icon] . " "
						. Map(0, "", 256, "Default2", 512, "Default3", 768, "Default4")[default] . " "
						. (modality + alignment + help ? modality + alignment + help : "")), "  ", " ")
	else
		options := buttonSelection + icon + modality + default + alignment + help
	
	if TestMode
		return {Options: options, Title: title, Text: text, Timeout: timeout}

	if (timeout = -1) || (timeout = "")
		timeout := ""
	else 
		timeout := "T" StrReplace(timeout, ",", ".") ; allows "," as decimal point

	Qu := saved.DoubleQu ? Chr(34) : "'"
	functionText :=	"MsgBox" . (saved.Paren ? "(" : " ") ; insert paren if selected
						. (text ? Qu . text . Qu : "") "," ; insert quotes around text if it exists
						. (title ? " " . Qu . title . Qu : "") . "," ; insert space and insert quotes around title if it exists
						. ((options . timeout) ? " " . Qu : "") ; insert space and open quote if there are options or timeout
						. (options ? options : "") ; if sum of options is 0, leave it blank, otherwise put in options
						. (options && timeout ? " " : "") ; if there is both an option number and a timeout, insert a space
						. timeout . ((options . timeout) ? Qu : "") ; add timeout if it exists and close quote if necessary
	functionText := RTrim(functionText, ",") ; remove unnecessary commas on the right
						. (saved.Paren ? ")" : "") ; add closing paren if selected
	this.__Item["FunctionText"].Value := functionText
}

SelectIcon(thisCtrl, *) {
	thisCtrl.Value := 1
	CreateMsgBoxFunction(thisCtrl.Gui)
}

EscapeCharacters(str, doubleQu) {
	if doubleQu
		str := StrReplace(str, Chr(34), "``" Chr(34))
	else
		str := StrReplace(str, "'", "``" "'")
	return StrReplace(str, "`n", "``n")
}

Test(thisCtrl, *) {
	global
	TestMode := 1
	info := CreateMsgBoxFunction(thisCtrl)
	TestMode := 0
	thisCtrl.Gui.Opt("+OwnDialogs")
	title := info.Title ? info.Title : "(Name of script)"
	text := StrReplace(info.Text, "``n", "`n")
	if (thisCtrl.Gui.__Item["DoubleQu"].Value = 1)
		text := StrReplace(text, "```"", "`"")
	else
		text := StrReplace(text, "``'", "`'")
	MsgBox text, title, info.Options . (info.Timeout = -1 ? "" : " T" info.Timeout)
}

CopyCode(thisCtrl, *) {
	saved := thisCtrl.Gui.Submit(0)
	A_Clipboard := saved.FunctionText
	MsgBox "The MsgBox code has been copied to the clipboard.`n`nIt is ready to be pasted into your editor.", "MsgBox Code Copied", "4160 T3"
}

Reset(thisGui, *) {
	thisGui.__Item["Title"].Value := ""
	thisGui.__Item["Text"].Value := ""
	thisGui.__Item["ButtonSelection1"].Value := 1
	thisGui.__Item["ButtonSelectionHelp"].Value := 0
	thisGui.__Item["ButtonSelectionHelp"].Value := 0
	thisGui.__Item["Icon1"].Value := 1
	thisGui.__Item["Modality1"].Value := 1
	thisGui.__Item["Default1"].Value := 1
	thisGui.__Item["Alignment1"].Value := 0
	thisGui.__Item["Alignment2"].Value := 0
	thisGui.__Item["Timeout"].Value := -1
	thisGui.__Item["NumOpt"].Value := 1
	thisGui.__Item["Paren"].Value := 1
	CreateMsgBoxFunction(thisGui)
}

SaveOptions(thisGui, *) {
	saved := thisGui.Submit(0)
	IniWrite saved.Paren, "MsgBox Creator settings.ini", "Main", "Paren"
	IniWrite saved.NumOpt, "MsgBox Creator settings.ini", "Main", "NumOpt"
	IniWrite saved.DoubleQu, "MsgBox Creator settings.ini", "Main", "DoubleQu"
	CreateMsgBoxFunction(thisGui)
}

WM_EXITSIZEMOVE(*) {
	global MainGui
	MainGui.GetPos(&x, &y)
	IniWrite x, "MsgBox Creator settings.ini", "Main", "WinPosX"
	IniWrite y, "MsgBox Creator settings.ini", "Main", "WinPosY"
}


showSplashScreen() {
    splashGUI.Opt("-MinimizeBox -MaximizeBox -SysMenu +AlwaysOnTop +ToolWindow -Caption +Owner")
    splashGUI.SetFont("s11 Italic", "Verdana")
    splashGUI.BackColor := "0x484848"
    splashGUI.Add("Text", "cWhite x16 y8 w538 h46", "MsgBox creator was implemented on AHKv2 by [^1]Boiler a prominent autohotkey.com contributor, and moderator. [^2]Thalon was the original creator, linked below. `n")
    splashGUI.SetFont() ; 
    splashGUI.SetFont("s15")
    splashGUI.Add("Link",, "<a href=`"https://www.autohotkey.com/boards/viewtopic.php?f=83&t=78253`">[^1] @Boiler - AHKforum</a>")
    splashGUI.SetFont("s15")
    splashGUI.Add("Link",, "<a href=`"https://www.autohotkey.com/board/topic/10623-messagebox-creator/`">[^2] @Thalon - AHKforum</a>")
    splashGUI.Title := "Window"
    splashGUI.OnEvent('Close', (*) => ExitApp())
    splashGUI.Show("")
    Settimer () => splashGUI.Destroy(), -3000
}
