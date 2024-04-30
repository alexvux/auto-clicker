#SingleInstance Force
SetControlDelay -1

GuiApp := Gui("AlwaysOnTop", "Auto Clicker")

; Init settings
ButtonOptions := ["Left", "Right"]
ClickOptions := ["Single", "Double"]
DefaultInterval := 500
DefaultRepeat := 0

; Mouse options
GuiApp.AddGroupBox("x10 y10 w400 h60", "Mouse Options")

GuiApp.AddText("x30 y30", "Button type:")
CtrlButtonType := GuiApp.AddDropDownList("x110 y30 w80 Choose1", ButtonOptions)

GuiApp.AddText("x210 y30", "Click type:")
CtrlClickType := GuiApp.AddDropDownList("x300 y30 w80 Choose1", ClickOptions)

; Timer options
GuiApp.AddGroupBox("x10 y80 w400 h60", "Timer Options")

GuiApp.AddText("x30 y100", "Interval (ms):")
CtrlInterval := GuiApp.AddEdit("Number x110 y100 w80", DefaultInterval)

GuiApp.AddText("x210 y100", "Repeat (times):`n(0 = infinite)")
CtrlRepeat := GuiApp.AddEdit("Number x300 y100 w80")
GuiApp.AddUpDown("Range0-10000", DefaultRepeat)

; Cursor information
GuiApp.AddGroupBox("x10 y150 w400 h80", "Cursor Infomation")

GuiApp.AddText("x30 y170", "Coordinates: ")
CtrlCursor:= GuiApp.AddText("x110 y170 w80", "")

CtrlGetCursorPos := GuiApp.AddButton("x30 y195 w130", "Get cursor position")

GuiApp.AddText("x210 y170", "Process name: ")
CtrlProcName := GuiApp.AddText("x290 y170 w110", "")

GuiApp.AddText("x210 y195", "Process ID: ")
CtrlPID := GuiApp.AddText("x290 y200 w110", "")

; Control buttons
CtrlStart := GuiApp.AddButton("x30 y250 w100", "Start")
CtrlStop := GuiApp.AddButton("x160 y250 w100", "Stop")
CtrlReset := GuiApp.AddButton("x290 y250 w100", "Reset")

TraySetIcon("resources\icon.ico")
GuiApp.Show("w420 h290 x1350 y80")

; Handle events
GuiApp.OnEvent("Escape", (*) => ExitApp())
GuiApp.OnEvent("Close", (*) => ExitApp())

CtrlInterval.OnEvent("Focus", (*) => Send("^a"))

CtrlRepeat.OnEvent("Focus", (*) => Send("^a"))

CtrlGetCursorPos.OnEvent("Click", GetCursorPos)

Toggle := false
xPos := yPos := ahkId := -1

GetCursorPos(*) {
    global
    SetTimer () => WatchMouseMove(&xPos, &yPos, &ahkId), 100
}

WatchMouseMove(&xPos, &yPos, &ahkId) {
    MouseGetPos &xPos, &yPos, &ahkId
    ToolTip
    (
        "Mouse position: " xPos ", " yPos
        "`nProcess name: " WinGetProcessName(ahkId)
        "`nProcess ID: " WinGetPID(ahkId)
    ) 

    if(GetKeyState("LButton", "P")) {
        CtrlCursor.Text := xPos ", " yPos
        CtrlProcName.Text := WinGetProcessName(ahkId)
        CtrlPID.Text := WinGetPID(ahkId)
        SetTimer , 0
        ToolTip()
    }
}

mousePos := winTitle := whichBtn := ""
clickCnt := interval := clickTimes := 0

CtrlStart.OnEvent("Click", StartClicker)

StartClicker(*) {
    global
    if(xPos = -1 or yPos = -1 or ahkId = -1) {
        MsgBox("Please get the cursor position first.")
        return
    }

    ; get current settings then call ControlClick
    mousePos := "x" . xPos . " y" . yPos
    winTitle := "ahk_id " . ahkId
    whichBtn := CtrlButtonType.Text
    clickCnt := CtrlClickType.Value
    interval := CtrlInterval.Value
    clickTimes := CtrlRepeat.Value

    if(clickTimes = 0) {
        SetTimer InfiniteClick, interval
    } else {
        SetTimer FiniteClick, interval
    }
}

InfiniteClick() {
    ControlClick(mousePos, winTitle,, whichBtn, clickCnt, "NA")
}

FiniteClick() {
    global
    if(clickTimes = 0) {
        SetTimer , 0
        return
    }

    ControlClick(mousePos, winTitle,, whichBtn, clickCnt, "NA")
    clickTimes--
}

CtrlStop.OnEvent("Click", StopClicker)

StopClicker(*) {
    global
    clickTimes := CtrlRepeat.Value

    if(clickTimes = 0) {
        SetTimer InfiniteClick, 0
    } else {
        SetTimer FiniteClick, 0
    }
}