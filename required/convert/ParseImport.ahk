^F9::Gosub, Parser
return
Parser:
    app := "C:\Users\dower\Documents\1.ahk"
    Run, %app%,,, hWnd
    Sleep, 1000
    WinGet hWnd, ID, 1.ahk
    WinGet hTargetWnd, ID, ahk_id %hWnd%
    WinActivate, ahk_id %hTargetWnd%
    Gosub NewGUI

    If (IncludeMenu) {
        If (hMenu := GetMenu(hTargetWnd)) {
            CloneMenuItems(hMenu, "", "")
            Gui %Child%: Menu, MenuBar
            m.Code .= "Gui Menu, MenuBar" . CRLF
        }
    }

    wi := GetWindowInfo(hTargetWnd)
    ncLeftWidth := wi.ClientX - wi.WindowX
    ncTopHeight := wi.ClientY - wi.WindowY

    WinGet WindowStyle, Style, ahk_id %hTargetWnd%
    if (WindowStyle & 0x40000) { ; WS_SIZEBOX
        g.Window.Options := "+Resize"
    }

;************************************************************************

    WinGet ControlList, ControlListHWnd, ahk_id %hTargetWnd%
    If (ControlList == "") {
        ; MozillaWindowClass, QWidget, etc.
        Gui Auto: +OwnDialogs
        Msgbox 0x30, Window Cloning Tool, % GetClassName(hTargetWnd) . ": unable to clone the window."
        ;Return
    }

    Try {
        Acc_Init()
    }

    hPrevCtrl := 0, PrevAhkName := ""
    Loop Parse, ControlList, `n
    {
        If !(IsWindowVisible(A_LoopField)) {
            Continue
        }

        ClassName := GetClassName(A_LoopField)
        If ((ClassName == "SysHeader32") || (ClassName == "Edit" && PrevAhkName == "ComboBox")) {
            Continue
        }

        ControlGetText ControlText,, ahk_id %A_LoopField%
        ControlGetPos x, y, w, h,, ahk_id %A_LoopField%
        x := x - ncLeftWidth
        y := y - ncTopHeight
        ControlGet ControlStyle, Style,,, ahk_id %A_LoopField%
        ControlGet ControlExStyle, ExStyle,,, ahk_id %A_LoopField%
        ControlType := ControlStyle & 0xF
        Options := ""

        AhkName := TranslateClassName(ClassName)
        If (AhkName == "") {
            Try {
                AhkName := WeHaveToGoDeeper(A_LoopField)
            }
            If (AhkName == "") {
                Continue
            }
        }

        If (ClassName = "Button") {
            ; 1: BS_DEFPUSHBUTTON
            ; 2: BS_CHECKBOX
            ; 3: BS_AUTOCHECK
            ; 4: BS_RADIOBUTTON
            ; 5: BS_3STATE
            ; 6: BS_AUTO3STATE
            ; 9: BS_AUTORADIOBUTTON
            If (ControlType == 1) {
                AhkName := "Button"
                Options .= " +Default"
            } Else If ControlType in 2,3,5,6
                AhkName := "CheckBox"
            Else If ControlType in 4,9
                AhkName := "Radio"
            Else If (ControlType == 7)
                AhkName := "GroupBox"
            Else
                AhkName := "Button"
            ControlGet Checked, Checked,,, ahk_id %A_LoopField%
            If (Checked) {
                Options .= " +Checked"
            }
        } Else If (ClassName == "ComboBox") {
            If (ControlType = 3) {
                AhkName := "DropDownList"
            } Else {
                AhkName := "ComboBox"
            }
        } Else If (ClassName == "Edit") {
            If (ControlType = 4) {
                Options .= " +Multi"
            }
            If ((ControlStyle & 0xF00) == 0x800) {
                Options .= " +ReadOnly"
            }
        } Else If (ClassName == "Static") {
            If (ControlType = 1) {
                Options .= " +Center"
            } Else If (ControlType == 2) {
                Options .= " +Right"
            } Else If (ControlType == 3 || ControlType == 14) {
                ; 3:  SS_ICON
                ; 14: SS_BITMAP
                AhkName := "Picture"
                Options .= " 0x6 +Border" ; SS_WHITERECT
            }
            If (ControlText == "" && h == 2) {
                Options .= " 0x10" ; Separator
            }
        } Else If (AhkName == "Slider") {
            SendMessage 0x400, 0, 0,, ahk_id %A_LoopField% ; TBM_GETPOS
            ControlText := ErrorLEvel
            SendMessage 0x401, 0, 0,, ahk_id %A_LoopField% ; TBM_GETRANGEMIN
            Options .= " Range" . ErrorLevel
            SendMessage 0x402, 0, 0,, ahk_id %A_LoopField% ; TBM_GETRANGEMAX
            Options .= "-" . ErrorLevel
            ; 2:  TBS_VERT
            ; 4:  TBS_TOP
            ; 8:  TBS_BOTH (blunt)
            ; 10: TBS_NOTICKS
            If (ControlType == 2) {
                Options .= " +Vertical"
            } Else If (ControlType == 4) {
                Options .= " +Left"
            } Else If (ControlType == 8) {
                Options .= " +Center"
            } Else If (ControlType == 10) {
                Options .= " +NoTicks"
            }
        } Else If (AhkName == "TreeView") {
            ControlText := ""
        } Else If (AhkName == "UpDown") {
            Options .= " -16"
        } Else If (AhkName == "Tab2") {
            TabLabels := ControlGetTabs(A_LoopField)
            nTabs := TabLabels.Length()
            Loop % nTabs {
                ControlText .= TabLabels[A_Index] . ((A_Index != nTabs) ? "|" : "")
            }
        } Else If (AhkName == "Progress") {
            SendMessage 0x408, 0, 0,, ahk_id %A_LoopField% ; PBM_GETPOS
            ControlText := ErrorLEvel
            Smooth := ControlStyle & 0x1
            If (!Smooth) {
                Options .= " -Smooth"
            }
            If (ControlType == 4) {
                Options .= " +Vertical"
            }
        } Else If (AhkName == "Link" && !InStr(ControlText, "<a")) {
            ControlText := "<a>" . ControlText . "</a>"
        }

        If (ClassName ~= "ComboBox|ListBox") {
            ControlGet Items, List,,, ahk_id %A_LoopField%
            StringReplace ControlText, Items, `n, |, All
        }

        ControlGet Enabled, Enabled,,, ahk_id %A_LoopField%
        If (!Enabled) {
            Options .= " +Disabled"
        }

        Styles := IncludeStyles ? ToHex(ControlStyle) : ""

        Gui %Child%: Add, %AhkName%, hWndhWnd x%x% y%y% w%w% h%h% %Options% %Styles%, %ControlText%

        If (AhkName == "TreeView") {
            Gui %Child%: Default
            Parent := TV_Add("TreeView")
            TV_Add("Child", Parent)
        }

        ;Register(hWnd, Type, ClassNN, Text,,,, Options, Extra, Styles, FontName, FontOptions, Anchor, TabPos)
        Register(hWnd, AhkName, GetClassNN(hWnd), EscapeChars(ControlText),,,, LTrim(Options),, Styles)
        g.ControlList.Push(hWnd)

        PrevAhkName := AhkName
        hPrevCtrl := hWnd
    }

;************************************************************************

    Properties_Reload()

    SysGet cxFrame, 32 ; Border width/height (8)
    WinGetPos wx, wy, ww, wh, ahk_id %hTargetWnd%
    If (ncLeftWidth != cxFrame) {
        ww := ww + ((cxFrame - ncLeftWidth) * 2)
        wh := wh + ((cxFrame - ncLeftWidth) * 2)
    }
    WinMove ahk_id %hChildWnd%,, %wX%, %wY%, %wW%, %wH%
    WinActivate ahk_id %hChildWnd%

    WinGetTitle WinTitle, ahk_id %hTargetWnd%
    g.Window.Title := WinTitle . " (Clone)"
    WinSetTitle ahk_id %hChildWnd%,, % g.Window.Title

    GenerateCode()