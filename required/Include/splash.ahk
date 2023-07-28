;AutoGUI 2.5.8
;Auto-GUI-v2 credit to Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter credit to github.com/mmikeww/AHK-v2-script-converter
splashGUI := Gui()
showSplashScreen() {
    splashGUI.Opt("-MinimizeBox -MaximizeBox -SysMenu +AlwaysOnTop +ToolWindow -Caption +Owner")
    splashGUI.SetFont("s9 Italic", "Verdana")
    splashGUI.BackColor := "0x484848"
    splashGUI.Add("Text", "cWhite x16 y8 w538 h146", "Easy AutoGUI was created by Alguimist, the founder of the Adventure IDE [^1]`n`nAHKv2converter was developed by https://github.com/mmikeww [^2] and https://github.com/dmtr99 [^3] among others.`n`nTheir work served as the foundation for this project, I [^4] did very little work, just weaving the two solutions together. All the work was done by the creators just mentioned.`n")
    splashGUI.SetFont()
    splashGUI.SetFont("s15")
    splashGUI.Add("Link", "x16 y176 w301 h23", "<a href=`"https://sourceforge.net/projects/autogui/`">[^1] Alguimist - Adventure IDE</a>")
    splashGUI.SetFont()
    splashGUI.SetFont("s15")
    splashGUI.Add("Link", "x16 y208 w301 h23", "<a href=`"https://github.com/mmikeww`">[^2] mmikeww - AHKv2 Converter</a>")
    splashGUI.SetFont()
    splashGUI.SetFont("s15")
    splashGUI.Add("Link", "x16 y240 w301 h23", "<a href=`"https://github.com/dmtr99`">[^3] dmtr99 - AHKv2 Converter</a>")
    splashGUI.SetFont()
    splashGUI.SetFont("s15")
    splashGUI.Add("Link", "x16 y272 w301 h23", "<a href=`"https://github.com/samfisherirl`">[^4] samfisherirl - </a>")
    splashGUI.SetFont()
    splashGUI.Title := "Window"
    splashGUI.OnEvent('Close', (*) => ExitApp())
    splashGUI.Show("w574 h310")
    Settimer () => splashGUI.Destroy(), -3000
}
