﻿
#Requires Autohotkey v2
;AutoGUI 2.5.8 
;Auto-GUI-v2 credit to Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter credit to github.com/mmikeww/AHK-v2-script-converter

myGui := Gui()
ogcButtonOK := myGui.Add("Button", "x8 y8 w80 h23", "&OK")
myGui.Title := "Window"
ogcButtonOK.OnEvent("Click", OnEventHandler)
myGui.OnEvent('Close', (*) => ExitApp())
myGui.Show("w620 h420")
Return

OnEventHandler(*)
{
	ToolTip("Click! This is a sample action.`n", 77, 277)
	SetTimer () => ToolTip(), -3000 ; tooltip timer
}
