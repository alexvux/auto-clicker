#SingleInstance Force

MyGui := Gui("AlwaysOnTop", "Auto Clicker")

; Click Options
MyGui.AddGroupBox("x10 y10 w400 h60", "Click Options")
MyGui.AddText("x30 y30", "Mouse button:")
MyGui.AddDropDownList("x110 y30 w70 Choose1", ["Left", "Right"])

MyGui.AddText("x220 y30", "Click type:")
MyGui.AddDropDownList("x310 y30 w70 Choose1", ["Single", "Double"])

; Interval Options
MyGui.AddGroupBox("x10 y80 w400 h60", "Interval Options")
MyGui.AddText("x30 y100", "Interval (ms):")
MyGui.AddEdit("x110 y100 w70 vInterval", 5000)

MyGui.AddText("x220 y100", "Click times:")
MyGui.AddText("x220 y115", "(0 = infinite)")
MyGui.AddEdit("x310 y100 w70")
MyGui.AddUpDown("vClickTimes Range1-1000",0) ; validate the input

; Cursor Position
MyGui.AddGroupBox("x10 y150 w400 h80", "Cursor Position")
MyGui.AddText("x30 y170", "Mouse position: ")
MyGui.AddText("x110 y170 vMousePos", "4255 - 4265") ; placeholder
MyGui.AddText("x220 y170", "Process name: ")
MyGui.AddText("x310 y170 vProcessName", "Notepad.exe") ; placeholder

MyGui.AddButton("x30 y195 w135", "Get cursor position")
MyGui.AddText("x220 y195", "Process ID: ")
MyGui.AddText("x310 y195 vPid", "16185") ; placeholder

; Control Buttons
MyGui.AddButton("x30 y250 w100", "Start (Ctrl F1)")
MyGui.AddButton("x160 y250 w100", "Stop (Ctrl F2)")
MyGui.AddButton("x290 y250 w100", "Reset (Ctrl F3)")

MyGui.OnEvent("Escape", (*) => ExitApp())
MyGui.Show("w420 h290 x1350 y80") ; postion at the top left corner
