
#Requires Autohotkey v2
;AutoGUI 2.5.8 
;Auto-GUI-v2 credit to Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter credit to github.com/mmikeww/AHK-v2-script-converter

myGui := Gui()
Edit_1 := myGui.Add("Edit", "x88 y16 w120 h42")
myGui.Add("Edit", "x88 y16 w120 h42")
myGui.Title := "Window"
Edit_1.OnEvent("Change", OnEventHandler)
myGui.OnEvent('Close', (*) => ExitApp())
myGui.Show("w620 h420")
Return

OnEventHandler(*)
{
	ToolTip("Click! This is a sample action.`n"
	. "Active GUI element values include:`n"  
	. "Edit_1 => " Edit_1.Value "`n", 77, 277)
	SetTimer () => ToolTip(), -3000 ; tooltip timer
}
