#SingleInstance Force
SetControlDelay -1

GuiApp := Gui("AlwaysOnTop", "Auto Clicker")

; Init settings
MouseOptions := ["Left", "Right"]
ClickTypeOptions := ["Single", "Double"]
DefaultInterval := 1000
DefaultClickTimes := 0

; Click options
GuiApp.AddGroupBox("x10 y10 w400 h60", "Click Options")
GuiApp.AddText("x30 y30", "Mouse button:")
CtrlMouse := GuiApp.AddDropDownList("x110 y30 w80 Choose1", MouseOptions)

GuiApp.AddText("x210 y30", "Click type:")
CtrlClickType := GuiApp.AddDropDownList("x290 y30 w80 Choose1", ClickTypeOptions)

; Interval options
GuiApp.AddGroupBox("x10 y80 w400 h60", "Interval Options")
GuiApp.AddText("x30 y100", "Interval (ms):")
CtrlInterval := GuiApp.AddEdit("Number x110 y100 w80", DefaultInterval)

GuiApp.AddText("x210 y100", "Click times:")
GuiApp.AddText("x210 y115", "(0 = infinite)")
CtrlClickTimes := GuiApp.AddEdit("Number x290 y100 w80")
GuiApp.AddUpDown("Range0-10000", DefaultClickTimes)

; Cursor position
GuiApp.AddGroupBox("x10 y150 w400 h80", "Cursor Position")
GuiApp.AddText("x30 y170", "Mouse position: ")
CtrlMousePos:= GuiApp.AddText("x110 y170 w80", "") ; add mouse pos later

CtrlGetCursorPos := GuiApp.AddButton("x30 y195 w135", "Get cursor position")

GuiApp.AddText("x210 y170", "Process name: ")
CtrlProcessName := GuiApp.AddText("x290 y170 w80", "") ; add process name later

GuiApp.AddText("x210 y195", "Process ID: ")
CtrlPID := GuiApp.AddText("x290 y195 w100", "") ; add process ID later

; Control buttons
CtrlStart := GuiApp.AddButton("x30 y250 w100", "Start (Ctrl F1)")
CtrlStop := GuiApp.AddButton("x160 y250 w100", "Stop (Ctrl F2)")
CtrlReset := GuiApp.AddButton("x290 y250 w100", "Reset (Ctrl F3)")

GuiApp.Show("w420 h290 x1350 y80") ; position at the top right corner

; Handle events
GuiApp.OnEvent("Escape", (*) => ExitApp())
GuiApp.OnEvent("Close", (*) => ExitApp())

CtrlInterval.OnEvent("Focus", (*) => Send("^a"))

CtrlClickTimes.OnEvent("Focus", (*) => Send("^a"))

CtrlGetCursorPos.OnEvent("Click", GetCursorPos)

; Init settings
toggle := false
xPos := yPos := ahkId := -1

GetCursorPos(*)
{
    global
    SetTimer () => WatchMouseMove(&xPos, &yPos, &ahkId), 100
}

WatchMouseMove(&xPos, &yPos, &ahkId)
{
    MouseGetPos &xPos, &yPos, &ahkId
    ToolTip
    (
        "Mouse position: " xPos ", " yPos
        "`nProcess name: " WinGetProcessName(ahkId)
        "`nProcess ID: " WinGetPID(ahkId)
    ) 
    
    if (GetKeyState("LButton", "P"))
    {
        CtrlMousePos.Text := xPos ", " yPos
        CtrlProcessName.Text := WinGetProcessName(ahkId)
        CtrlPID.Text := WinGetPID(ahkId)
        SetTimer , 0
        ToolTip()
    }
}

CtrlStart.OnEvent("Click", StartClicker)

StartClicker(*)
{
    if (xPos = -1 or yPos = -1 or ahkId = -1)
    {
        MsgBox("Please get the cursor position first.")
        return
    }

    ; get current settings then call ControlClick, if it's not infinite, set a loop for stopping
    mousePos := "x" . xPos . " y" . yPos
    winTitle := "ahk_id " . ahkId
    whichBtn := CtrlMouse.Text
    clickCnt := CtrlClickType.Value
    interval := CtrlInterval.Value
    clkTimes := CtrlClickTimes.Value

    if (clkTimes = 0)
    {
        SetTimer () => ControlClick(mousePos, winTitle,, whichBtn, clickCnt, "NA"), interval
    } else
    {
        loop {
            ControlClick(mousePos, winTitle,, whichBtn, clickCnt, "NA")
            Sleep interval
        } until (A_Index = clkTimes)
    }
}