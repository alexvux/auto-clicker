#SingleInstance Force
SetControlDelay -1

MyGui := Gui("AlwaysOnTop", "Auto Clicker")

; Init settings
Running := false
ButtonOptions := ["Left", "Right"]
ClickOptions := ["Single", "Double"]
DefaultInterval := 500
DefaultClicks := 0
CurrentClicks := 0
xCur := yCur := ahkID := -1

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
GetCursorPos := MyGui.AddButton("x30 y195 w140", "Get cursor position")
MyGui.AddText("x190 y170", "Process name: ")
ProcessName := MyGui.AddText("x290 y170 w110", "")
MyGui.AddText("x190 y190", "Process ID: ")
PID := MyGui.AddText("x290 y190 w110", "")
MyGui.AddText("x190 y210", "Remaining clicks: ")
RemainingClicks := MyGui.AddText("x290 y210 w110", "")

; Control buttons
Start := MyGui.AddButton("x30 y250 w80", "Start (F3)")
Stop := MyGui.AddButton("x125 y250 w80", "Stop (F4)")
Reset := MyGui.AddButton("x220 y250 w80", "Reset (F5)")
Help := MyGui.AddButton("x315 y250 w80", "Help")

; Position a window at a specific location with a margin from the right and bottom edges of the screen 
ScreenWidth := A_ScreenWidth
ScreenHeight := A_ScreenHeight
windowWidth := 420
windowHeight := 290
marginRight := 170
marginBottom := 700
xWindow := ScreenWidth - windowWidth - marginRight
yWindow := ScreenHeight - windowHeight - marginBottom

MyGui.Show("w" windowWidth " h" windowHeight " x" xWindow " y" yWindow)
; MyGui.Show("w420 h290 x1330 y90")
TraySetIcon("resources/icon.ico")

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
    global xCur, yCur, ahkID, Running
    
    MouseGetPos &xCur, &yCur, &ahkID
    ToolTip(
        "Press 'F2' to get current position:`n"
        "- Coordinates: " xCur ", " yCur "`n"
        "- Process: " WinGetProcessName(ahkID) "`n"
        "- Process ID: " WinGetPID(ahkID) "`n"
    )
    if(GetKeyState("F2", "P")) {
        Coordinates.Value := xCur ", " yCur
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
    global Running, CurrentClicks, xCur, yCur, ahkID
    
    if(Running)
        return
    if(xCur = -1 or yCur = -1 or ahkID = -1) {
        MsgBox "Please pick cursor position first!"
        return
    }
    
    Running := true
    pos := "x" xCur " y" yCur
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
        ControlClick pos, winTitle, , whichBtn, clickCount, "NA"
        CurrentClicks--
        if(RemainingClicks.Value != "Infinite")
            RemainingClicks.Value := CurrentClicks
        Sleep period
    }
    Running := false
}

Stop.OnEvent("Click", Stop_Click)
Stop_Click(*) {
    global Running := false
}

Reset.OnEvent("Click", Reset_Click)
Reset_Click(*) {
    global
    Running := false
    ButtonType.Choose(1)
    ClickType.Choose(1)
    Interval.Value := DefaultInterval
    ClickTimes.Value := DefaultClicks
    Coordinates.Value := ProcessName.Value := PID.Value := RemainingClicks.Value := ""
    xCur := yCur := ahkID := -1
}

Help.OnEvent("Click", Help_Click)
Help_Click(*) {
    MsgBox(
        "- Choose button type and click type of mouse.`n"
        "- Input interval (in millisecond) and click times (0 means infinite click).`n"
        "- Click 'Get cursor postion' button to show current position of your cursor`n"
        "  then press F2 to add it to click settings or 'Esc' to back to main window.`n"
        "- Click 'Start' or F3 to start auto clicking.`n"
        "- Click 'Stop' or F4 to stop auto clicking.`n"
        "- Click 'Reset' or F5 to reset clicking settings.",
        "Instructions"
    )
}

; Hotkey settings
F3::Start_Click
F4::Stop_Click
F5::Reset_Click

; TODO: add function to change hotkey of start/stop/reset button (can save to .ini file)
; TODO: disabled button or change appearance text
; TODO: research change appearance of text in control