#SingleInstance Force

GuiApp := Gui("AlwaysOnTop", "Auto Clicker")

; Click Options
GuiApp.AddGroupBox("x10 y10 w400 h60", "Click Options")
GuiApp.AddText("x30 y30", "Mouse button:")
CtrlMouseBtn := GuiApp.AddDropDownList("x110 y30 w70 Choose1", ["Left", "Right"])

GuiApp.AddText("x220 y30", "Click type:")
CtrlClickType := GuiApp.AddDropDownList("x310 y30 w70 Choose1", ["Single", "Double"])

; Interval Options
GuiApp.AddGroupBox("x10 y80 w400 h60", "Interval Options")
GuiApp.AddText("x30 y100", "Interval (ms):")
CtrlInterval := GuiApp.AddEdit("x110 y100 w70", 5000)

GuiApp.AddText("x220 y100", "Click times:")
GuiApp.AddText("x220 y115", "(0 = infinite)")
GuiApp.AddEdit("x310 y100 w70")
CtrlClickTimes := GuiApp.AddUpDown("Range0-1000",0) ; validate the input

; Cursor Position
GuiApp.AddGroupBox("x10 y150 w400 h80", "Cursor Position")
GuiApp.AddText("x30 y170", "Mouse position: ")
CtrlMousePos:= GuiApp.AddText("x110 y170", "4255 - 4265")

CtrlGetCursorPos := GuiApp.AddButton("x30 y195 w135", "Get cursor position")

GuiApp.AddText("x220 y170", "Process name: ")
CtrlProcessName := GuiApp.AddText("x310 y170", "Notepad.exe")

GuiApp.AddText("x220 y195", "Process ID: ")
CtrlPID := GuiApp.AddText("x310 y195", "16185")

; Control Buttons
GuiApp.AddButton("x30 y250 w100", "Start (Ctrl F1)").OnEvent("Click", (*) => ExitApp())
GuiApp.AddButton("x160 y250 w100", "Stop (Ctrl F2)").OnEvent("Click", (*) => ExitApp())
GuiApp.AddButton("x290 y250 w100", "Reset (Ctrl F3)").OnEvent("Click", (*) => ExitApp())
GuiApp.OnEvent("Escape", (*) => ExitApp())
GuiApp.Show("w420 h290 x1350 y80") ; position at the top right corner

; Handle events
MouseBtn := "",  ClickType := "", Interval := "", ClickTimes := ""
MousePos := "", ProcessName := "", PID := ""


CtrlMouseBtn.OnEvent("Change", (*) => Mouse := CtrlMouseBtn.Text)
