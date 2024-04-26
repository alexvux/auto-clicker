#SingleInstance Force

GuiApp := Gui("AlwaysOnTop", "Auto Clicker")

; Default settings
Toggle := false
MouseOptions := ["Left", "Right"]
ClickTypeOptions := ["Single", "Double"]
DefaultInterval := 1000
DefaultClickTimes := 0

; Click Options
GuiApp.AddGroupBox("x10 y10 w400 h60", "Click Options")
GuiApp.AddText("x30 y30", "Mouse button:")
CtrlMouse := GuiApp.AddDropDownList("x110 y30 w70 Choose1", MouseOptions)

GuiApp.AddText("x220 y30", "Click type:")
CtrlClickType := GuiApp.AddDropDownList("x310 y30 w70 Choose1", ClickTypeOptions)

; Interval Options
GuiApp.AddGroupBox("x10 y80 w400 h60", "Interval Options")
GuiApp.AddText("x30 y100", "Interval (ms):")
CtrlInterval := GuiApp.AddEdit("Number x110 y100 w70", DefaultInterval)

GuiApp.AddText("x220 y100", "Click times:")
GuiApp.AddText("x220 y115", "(0 = infinite)")
GuiApp.AddEdit("x310 y100 w70")
CtrlClickTimes := GuiApp.AddUpDown("Range0-10000", DefaultClickTimes) ; validate the input

; Cursor Position
GuiApp.AddGroupBox("x10 y150 w400 h80", "Cursor Position")
GuiApp.AddText("x30 y170", "Mouse position: ")
CtrlMousePos:= GuiApp.AddText("x110 y170", "")

CtrlGetCursorPos := GuiApp.AddButton("x30 y195 w135", "Get cursor position")

GuiApp.AddText("x220 y170", "Process name: ")
CtrlProcessName := GuiApp.AddText("x310 y170", "")

GuiApp.AddText("x220 y195", "Process ID: ")
CtrlPID := GuiApp.AddText("x310 y195", "")

; Control Buttons
CtrlStart := GuiApp.AddButton("x30 y250 w100", "Start (Ctrl F1)")
CtrlStop := GuiApp.AddButton("x160 y250 w100", "Stop (Ctrl F2)")
CtrlReset := GuiApp.AddButton("x290 y250 w100", "Reset (Ctrl F3)")

GuiApp.OnEvent("Escape", (*) => ExitApp())
GuiApp.OnEvent("Close", (*) => ExitApp())
GuiApp.Show("w420 h290 x1350 y80") ; position at the top right corner

; Handle events
CtrlInterval.OnEvent("Focus", (*) => Send("^a"))