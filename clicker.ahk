#SingleInstance Force
SetControlDelay -1
DetectHiddenWindows true

TraySetIcon("resources/icon.ico")
MyGui := Gui("+AlwaysOnTop", "Auto Clicker")

; Init settings
Running := false
ButtonOptions := ["Left", "Right"]
ClickOptions := ["Single", "Double"]
DefaultInterval := 500
DefaultClicks := 0
CurrentClicks := 0
xCursor := yCursor := ahkID := -1

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
MyGui.AddText("x210 y100", "Click (times):`n(0: infinite)")
ClickTimes := MyGui.AddEdit("Number x300 y100 w80")
MyGui.AddUpDown("Range0-10000", DefaultClicks)

; Cursor position
MyGui.AddGroupBox("x10 y150 w400 h85", "Clicking Infomation")
MyGui.AddText("x30 y170", "Coordinates: ")
Coordinates:= MyGui.AddText("x110 y170 w80", "")
GetCursorPos := MyGui.AddButton("x30 y195 w140", "Get Cursor Position")
MyGui.AddText("x190 y170", "Process name: ")
ProcessName := MyGui.AddText("x290 y170 w110", "")
MyGui.AddText("x190 y190", "Process ID: ")
PID := MyGui.AddText("x290 y190 w110", "")
MyGui.AddText("x190 y210", "Remaining clicks: ")
RemainingClicks := MyGui.AddText("x290 y210 w110", "")

; Control buttons
Start := MyGui.AddButton("x30 y250 w80", "Start (F3)")
Stop := MyGui.AddButton("x125 y250 w80 +Disabled", "Stop (F4)")
Reset := MyGui.AddButton("x220 y250 w80", "Reset (F5)")
Help := MyGui.AddButton("x315 y250 w80", "Help")

; Display main window in the top right corner
wdWidth := 420
wdHeight := 290
marginRight := 170
xWindow := A_ScreenWidth - wdWidth - marginRight
yWindow := 90

MyGui.Show("w" wdWidth " h" wdHeight " x" xWindow " y" yWindow)
; MyGui.Show("w420 h290 x1330 y90")

; Handle events
; MyGui.OnEvent("Escape", (*) => ExitApp())
MyGui.OnEvent("Close", (*) => ExitApp())

Interval.OnEvent("Focus", (*) => Send("^a"))
ClickTimes.OnEvent("Focus", (*) => Send("^a"))

GetCursorPos.OnEvent("Click", GetCursorPos_Click)
GetCursorPos_Click(*) {
    if(Running)
        return
    MyGui.Hide()
    SetTimer PickPosition, 20
}

PickPosition() {
    global xCursor, yCursor, ahkID, Running
    
    MouseGetPos &xCursor, &yCursor, &ahkID
    WinActivate("ahk_id " ahkID)
    ToolTip(
        "Press 'F2' to get current position:`n"
        "- Coordinates: " xCursor ", " yCursor "`n"
        "- Process: " WinGetProcessName(ahkID) "`n"
        "- Process ID: " WinGetPID(ahkID) "`n"
    )
    if(GetKeyState("F2", "P")) {
        Coordinates.Value := xCursor ", " yCursor
        ProcessName.Value := WinGetProcessName(ahkID)
        PID.Value := WinGetPID(ahkID)
        BackFromPickingPositionToMainWindow()
        return
    }
    if (GetKeyState("Escape", "P")) {
        BackFromPickingPositionToMainWindow()
    }
}

BackFromPickingPositionToMainWindow() {
    ToolTip()
    MyGui.Show()
    SetTimer PickPosition, 0 
}

Start.OnEvent("Click", Start_Click)
Start_Click(*) {
    global Running, CurrentClicks, xCursor, yCursor, ahkID
    
    if(Running)
        return
    if(not IsExistedWindow(ahkID)) {
        MsgBox "The window is not existed anymore!"
        return
    }
    if(xCursor = -1 or yCursor = -1 or ahkID = -1) {
        MsgBox "Please pick cursor position first!"
        return
    }

    Running := true
    ToggleStartOrStopBtn(Running)
    ; WinActivate "ahk_id " ahkID
    pos := "x" xCursor " y" yCursor
    winTitle := "ahk_id " ahkID
    whichBtn := ButtonType.Text
    clickCount := ClickType.Value
    period := Interval.Value
    
    if(ClickTimes.Value = 0) {
        CurrentClicks := -1
        RemainingClicks.Value := "Infinite"
    } else if(CurrentClicks <= 0){
        CurrentClicks := ClickTimes.Value
        RemainingClicks.Value := CurrentClicks
    }

    while(CurrentClicks != 0) {
        if(not Running)
            return
        if(not IsExistedWindow(ahkID)) {
            Running := false
            ToggleStartOrStopBtn(Running)
            MsgBox "The window is not existed anymore!"
            return
        }

        ControlClick pos, winTitle, , whichBtn, clickCount, "NA"
        CurrentClicks--
        if(RemainingClicks.Value != "Infinite")
            RemainingClicks.Value := CurrentClicks
        ; Sleep period
        Delay(period, Running)
    }
    Running := false
}

Delay(duration, signal) {
    startTime := A_TickCount
    while(A_TickCount - startTime < duration) {
        if(not signal)
            return
        Sleep 10
    }
}

Stop.OnEvent("Click", Stop_Click)
Stop_Click(*) {
    global Running := false
    ToggleStartOrStopBtn(Running)
}

Reset.OnEvent("Click", Reset_Click)
Reset_Click(*) {
    global
    Running := false
    ToggleStartOrStopBtn(Running)
    ButtonType.Choose(1)
    ClickType.Choose(1)
    Interval.Value := DefaultInterval
    ClickTimes.Value := DefaultClicks
    Coordinates.Value := ProcessName.Value := PID.Value := RemainingClicks.Value := ""
    xCursor := yCursor := ahkID := -1
}

Help.OnEvent("Click", Help_Click)
Help_Click(*) {
    MsgBox(
        "- Select the mouse button type and click type.`n"
        "- Set the interval (in millisecond) and the number of clicks (0 for infinite clicking).`n"
        "- Use the 'Get cursor postion' button to display the infomation of current cursor position.`n"
        "  Then press F2 to add this to main window or press 'Esc' to return to main window.`n"
        "- Click 'Start' or F3 to start auto-clicking.`n"
        "- Click 'Stop' or F4 to stop auto-clicking.`n"
        "- Click 'Reset' or F5 to clean all clicking settings.",
        "Instructions"
    )
}

ToggleStartOrStopBtn(running) {
    Start.Enabled := running ? false : true
    Stop.Enabled := !Start.Enabled
}

IsExistedWindow(id) {
    return WinExist("ahk_id " id) ? true : false
}

; Hotkey settings
F3::Start_Click
F4::Stop_Click
F5::Reset_Click

; TODO: 
; hidden window doesn't work
; test on VQTK failed
; build to .exe file and upload to github