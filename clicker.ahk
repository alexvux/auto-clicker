#SingleInstance Force
SetControlDelay -1

MyGui := Gui("AlwaysOnTop", "Auto Clicker")

; Init settings
isRunning := false
ButtonOptions := ["Left", "Right"]
ClickOptions := ["Single", "Double"]
DefaultInterval := 500
DefaultRepeat := 0
xPos := yPos := ahkID := -1

; Mouse options
MyGui.AddGroupBox("x10 y10 w400 h60", "Mouse Options")
MyGui.AddText("x30 y30", "Button type:")
ButtonType := MyGui.AddDropDownList("x110 y30 w80 Choose1", ButtonOptions)
MyGui.AddText("x210 y30", "Click type:")
ClickType := MyGui.AddDropDownList("x300 y30 w80 Choose1", ClickOptions)

; Time options
MyGui.AddGroupBox("x10 y80 w400 h60", "Time Options")
MyGui.AddText("x30 y100", "Interval (ms):")
Interval := MyGui.AddEdit("Number x110 y100 w80", DefaultInterval)
MyGui.AddText("x210 y100", "Repeat (times):`n(0 = infinite)")
Repeat := MyGui.AddEdit("Number x300 y100 w80")
MyGui.AddUpDown("Range0-10000", DefaultRepeat)

; Cursor position
MyGui.AddGroupBox("x10 y150 w400 h80", "Cursor Position")
MyGui.AddText("x30 y170", "Coordinates: ")
Coordinates:= MyGui.AddText("x110 y170 w80", "")
GetCursorPos := MyGui.AddButton("x30 y195 w140", "Get cursor position")
MyGui.AddText("x210 y170", "Process name: ")
ProcessName := MyGui.AddText("x290 y170 w110", "")
MyGui.AddText("x210 y200", "Process ID: ")
PID := MyGui.AddText("x290 y200 w110", "")

; Control buttons
Start := MyGui.AddButton("x30 y250 w100", "Start (F3)")
Stop := MyGui.AddButton("x160 y250 w100", "Stop (F4)")
Reset := MyGui.AddButton("x290 y250 w100", "Reset (F5)")

TraySetIcon("resources/icon.ico")
MyGui.Show("w420 h290 x1350 y80")

; Handle events
; MyGui.OnEvent("Escape", (*) => ExitApp())
MyGui.OnEvent("Close", (*) => ExitApp())

Interval.OnEvent("Focus", (*) => Send("^a"))
Repeat.OnEvent("Focus", (*) => Send("^a"))

GetCursorPos.OnEvent("Click", GetCursorPos_Click)
GetCursorPos_Click(*) {
    if(isRunning)
        return

    picked := false
    MyGui.Hide()
    while (not picked) {
        PickPosition(&picked)
        Sleep 10
    }
}

PickPosition(&picked) {
    global xPos, yPos, ahkID, isRunning

    MouseGetPos &xPos, &yPos, &ahkID
    ToolTip(
        "Press 'F2' to get current position:`n"
        "- Coordinates: " xPos ", " yPos "`n"
        "- Process: " WinGetProcessName(ahkID) "`n"
        "- Process ID: " WinGetPID(ahkID)
    )

    if(GetKeyState("F2", "P")) {
        Coordinates.Value := "" xPos ", " yPos ""
        ProcessName.Value := WinGetProcessName(ahkID)
        PID.Value := WinGetPID(ahkID)
        ToolTip()
        picked := not picked
        MyGui.Show()
    }
}

Start.OnEvent("Click", Start_Click)
Start_Click(*) {
    global isRunning
    if(isRunning)
        return

    global xPos, yPos, ahkID
    if(xPos = -1 or yPos = -1 or ahkID = -1) {
        MsgBox "Please pick cursor position first!"
        return
    }
    

    isRunning := true
    pos := "x" xPos " y" yPos
    winTitle := "ahk_id " ahkID
    whichBtn := ButtonType.Text
    clickCount := ClickType.Value
    period := Interval.Value
    clickTimes := Repeat.Value

    if(clickTimes = 0)
        clickTimes := -1

    while(clickTimes != 0) {
        if(not isRunning)
            return

        ControlClick pos, winTitle, , whichBtn, clickCount, "Pos"
        clickTimes--
        Sleep period
    }
}

Stop.OnEvent("Click", Stop_Click)
Stop_Click(*) {
    global isRunning := false
}

Reset.OnEvent("Click", Reset_Click)
Reset_Click(*) {
    global
    isRunning := false
    ButtonType.Choose(1)
    ClickType.Choose(1)
    Interval.Value := DefaultInterval
    Repeat.Value := DefaultRepeat
    Coordinates.Value := ProcessName.Value := PID.Value := ""
    xPos := yPos := ahkID := -1
}

; Hotkey settings
F3::Start_Click
F4::Stop_Click
F5::Reset_Click