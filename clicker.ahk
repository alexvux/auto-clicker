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
CtrlMouse := GuiApp.AddDropDownList("x110 y30 w80 Choose1", MouseOptions)

GuiApp.AddText("x210 y30", "Click type:")
CtrlClickType := GuiApp.AddDropDownList("x290 y30 w80 Choose1", ClickTypeOptions)

; Interval Options
GuiApp.AddGroupBox("x10 y80 w400 h60", "Interval Options")
GuiApp.AddText("x30 y100", "Interval (ms):")
CtrlInterval := GuiApp.AddEdit("Number x110 y100 w80", DefaultInterval)

GuiApp.AddText("x210 y100", "Click times:")
GuiApp.AddText("x210 y115", "(0 = infinite)")
GuiApp.AddEdit("Number x290 y100 w80")
CtrlClickTimes := GuiApp.AddUpDown("Range0-10000", DefaultClickTimes)

; Cursor Position
GuiApp.AddGroupBox("x10 y150 w400 h80", "Cursor Position")
GuiApp.AddText("x30 y170", "Mouse position: ")
CtrlMousePos:= GuiApp.AddText("x110 y170 w80", "") ; add mouse pos later

CtrlGetCursorPos := GuiApp.AddButton("x30 y195 w135", "Get cursor position")

GuiApp.AddText("x210 y170", "Process name: ")
CtrlProcessName := GuiApp.AddText("x290 y170 w80", "") ; add process name later

GuiApp.AddText("x210 y195", "Process ID: ")
CtrlPID := GuiApp.AddText("x290 y195 w80", "") ; add process ID later

; Control Buttons
CtrlStart := GuiApp.AddButton("x30 y250 w100", "Start (Ctrl F1)")
CtrlStop := GuiApp.AddButton("x160 y250 w100", "Stop (Ctrl F2)")
CtrlReset := GuiApp.AddButton("x290 y250 w100", "Reset (Ctrl F3)")

GuiApp.Show("w420 h290 x1350 y80") ; position at the top right corner

; Handle events
GuiApp.OnEvent("Escape", (*) => ExitApp())
GuiApp.OnEvent("Close", (*) => ExitApp())

CtrlInterval.OnEvent("Focus", (*) => Send("^a"))

CtrlGetCursorPos.OnEvent("Click", GetCursorPos)

x := y := id := 0
GetCursorPos(Ctrl, Info)
{
    SetTimer () => WatchMouseMove(&x, &y, &id), 100
}

WatchMouseMove(&x, &y, &id)
{
    MouseGetPos &x, &y, &id
    ToolTip
    (
        "Mouse position: " x ", " y
        "`nProcess name: " WinGetProcessName(id)
        "`nProcess ID: " WinGetPID(id)
    ) 

    if (GetKeyState("LButton", "P"))
    {
        CtrlMousePos.Text := x ", " y
        CtrlProcessName.Text := WinGetProcessName(id)
        CtrlPID.Text := WinGetPID(id)
        SetTimer , 0
        ToolTip()
    }
}