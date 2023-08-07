
#Requires Autohotkey v2
;AutoGUI 2.5.8 creator: Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter creator: github.com/mmikeww/AHK-v2-script-converter
;Easy_AutoGUI_for_AHKv2 github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2

myGui := Gui()
myGui.SetFont("s8 Norm cMaroon", "Ms Shell Dlg")
CheckBox1 := myGui.Add("CheckBox", "x178 y113 w120 h23", "CheckBox")
myGui.Add("Hotkey", "x256 y224 w120 h21")
myGui.Add("Text", "x320 y281 w201 h65 +0x10")
myGui.Add("Slider", "x241 y48 w120 h32", "50")
myGui.Add("ListBox", "x80 y90 w120 h160", ["ListBox"])
ogcListViewListViewsa := myGui.Add("ListView", "x296 y104 w200 h150 +LV0x4000", ["ListViewsa"])
ogcListViewListView := myGui.Add("ListView", "x67 y291 w200 h150 +LV0x4000", ["ListView"])
CheckBox1.OnEvent("Click", OnEventHandler)
myGui.OnEvent('Close', (*) => ExitApp())
myGui.Title := "Window"
myGui.Show("w620 h418")

OnEventHandler(*)
{
	ToolTip("Click! This is a sample action.`n"
	. "Active GUI element values include:`n"  
	. "CheckBox1 => " CheckBox1.Value "`n", 77, 277)
	SetTimer () => ToolTip(), -3000 ; tooltip timer
}
