#SingleInstance Force
SetControlDelay -1

MyGui := Gui("AlwaysOnTop", "Auto Clicker")

; Init settings
ButtonOptions := ["Left", "Right"]
ClickOptions := ["Single", "Double"]
DefaultInterval := 500
DefaultRepeat := 0

; Mouse options
MyGui.AddGroupBox("x10 y10 w400 h60", "Mouse Options")
MyGui.AddText("x30 y30", "Button type:")
ButtonType := MyGui.AddDropDownList("x110 y30 w80 Choose1", ButtonOptions)
MyGui.AddText("x210 y30", "Click type:")
ClickType := MyGui.AddDropDownList("x300 y30 w80 Choose1", ClickOptions)

; Timer options
MyGui.AddGroupBox("x10 y80 w400 h60", "Timer Options")
MyGui.AddText("x30 y100", "Interval (ms):")
Interval := MyGui.AddEdit("Number x110 y100 w80", DefaultInterval)
MyGui.AddText("x210 y100", "Repeat (times):`n(0 = infinite)")
Repeat := MyGui.AddEdit("Number x300 y100 w80")
MyGui.AddUpDown("Range0-10000", DefaultRepeat)

; Cursor information
MyGui.AddGroupBox("x10 y150 w400 h80", "Cursor Infomation")
MyGui.AddText("x30 y170", "Coordinates: ")
Coordinates:= MyGui.AddText("x110 y170 w80", "")
GetCursorPos := MyGui.AddButton("x30 y195 w130", "Get cursor position")
MyGui.AddText("x210 y170", "Process name: ")
ProcessName := MyGui.AddText("x290 y170 w110", "")
MyGui.AddText("x210 y200", "Process ID: ")
PID := MyGui.AddText("x290 y200 w110", "")

; Control buttons
Start := MyGui.AddButton("x30 y250 w100", "Start")
Stop := MyGui.AddButton("x160 y250 w100", "Stop")
Reset := MyGui.AddButton("x290 y250 w100", "Reset")

TraySetIcon("resources/icon.ico")
MyGui.Show("w420 h290 x1350 y80")

; Handle events
MyGui.OnEvent("Escape", (*) => ExitApp())
MyGui.OnEvent("Close", (*) => ExitApp())

Interval.OnEvent("Focus", (*) => Send("^a"))
Repeat.OnEvent("Focus", (*) => Send("^a"))

toggle := false
x := y := ahkID := -1

GetCursorPos.OnEvent("Click", GetCursorPos_Click)
GetCursorPos_Click(*) {
    global
    SetTimer () => WatchMouseMove(&x, &y, &ahkID), 100
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
        Coordinates.Text := xPos ", " yPos
        ProcessName.Text := WinGetProcessName(ahkId)
        PID.Text := WinGetPID(ahkId)
        SetTimer , 0
        ToolTip()
    }
}

position := winTitle := whichBtn := ""
clickCount := period := repeatedTimes := 0

Start.OnEvent("Click", Start_Click)
Start_Click(*) {
    global
    if(x = -1 or y = -1 or ahkID = -1) {
        MsgBox("Please get the cursor position first.")
        return
    }
    ; get current settings then call ControlClick
    position := "x" . x . " y" . y
    winTitle := "ahk_id " . ahkID
    whichBtn := ButtonType.Text
    clickCount := ClickType.Value
    period := Interval.Value
    repeatedTimes := Repeat.Value

    if(repeatedTimes = 0) {
        SetTimer InfiniteClick, period
    } else {
        SetTimer FiniteClick, period
    }
}

InfiniteClick() {
    ControlClick(position, winTitle,, whichBtn, clickCount, "NA")
}
FiniteClick() {
    global
    if(repeatedTimes = 0) {
        SetTimer , 0
        return
    }

    ControlClick(position, winTitle,, whichBtn, clickCount, "NA")
    repeatedTimes--
}

Stop.OnEvent("Click", Stop_Click)
Stop_Click(*) {
    global
    repeatedTimes := Repeat.Value

    if(repeatedTimes = 0) {
        SetTimer InfiniteClick, 0
    } else {
        SetTimer FiniteClick, 0
    }
}