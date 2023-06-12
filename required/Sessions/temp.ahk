
#Requires Autohotkey v2
;AutoGUI 2.5.8 
;Auto-GUI-v2 credit to Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter credit to github.com/mmikeww/AHK-v2-script-converter

myGui := Gui()
myGui.SetFont("s9 Italic", "Verdana")
myGui.Add("Text", "x16 y8 w538 h146", "Easy AutoGUI was created by Alguimist, the founder of the Adventure IDE [^1]`n`nAHKv2converter was developed by https://github.com/mmikeww [^2] and https://github.com/dmtr99 [^3] among others.`n`nTheir work served as the foundation for this project, I [^4] did very little work, just weaving the two solutions together. All the work was done by the creators just mentioned.`n")
myGui.SetFont()
myGui.SetFont("s13")
myGui.Add("Link", "x16 y176 w301 h23", "<a href=`"https://sourceforge.net/projects/autogui/`">[^1] Alguimist - Adventure IDE</a>")
myGui.SetFont()
myGui.SetFont("s13")
myGui.Add("Link", "x16 y208 w301 h23", "<a href=`"https://github.com/mmikeww`">[^2] mmikeww - AHKv2 Converter</a>")
myGui.SetFont()
myGui.SetFont("s13")
myGui.Add("Link", "x16 y240 w301 h23", "<a href=`"https://github.com/dmtr99`">[^3] dmtr99 - AHKv2 Converter</a>")
myGui.SetFont()
myGui.SetFont("s13")
myGui.Add("Link", "x16 y272 w301 h23", "<a href=`"https://github.com/samfisherirl`">[^4] samfisherirl - </a>")
myGui.SetFont()
myGui.Title := "Window"
myGui.OnEvent('Close', (*) => ExitApp())
myGui.Show("w574 h310")
Return
