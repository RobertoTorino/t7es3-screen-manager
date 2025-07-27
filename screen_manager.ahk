; YouTube: @game_play267
; Twitch: RR_357000
; X:@relliK_2048
; Discord:
; T7ES3 Screen Manager
#SingleInstance force
#Persistent
#NoEnv

SendMode Input
DetectHiddenWindows On
SetWorkingDir %A_ScriptDir%


; ─── needed for T7ES3 path. ────────────────────────────────────────────────────────────────────
TrimQuotesAndSpaces(str)
{
    str := Trim(str) ; trim spaces first

    ; Remove leading double quote
    while (SubStr(str, 1, 1) = """")
        str := SubStr(str, 2)

    ; Remove trailing double quote
    while (SubStr(str, 0) = """")
        str := SubStr(str, 1, StrLen(str) - 1)

    return str
}

; ─── global config variables. ────────────────────────────────────────────────────────────────────
baseDir         := A_ScriptDir
iniFile         := A_ScriptDir . "\t7es3.ini"
t7es3Exe        := A_ScriptDir  . "\TekkenGame-Win64-Shipping.exe"


; ─── save screen size. ────────────────────────────────────────────────────────────────────
IniRead, SavedSize, %iniFile%, SIZE_SETTINGS, SizeChoice, 1920x1080
SizeChoice := SavedSize
selectedControl := sizeToControl[SavedSize]
for key, val in sizeToControl {
    label := (val = selectedControl) ? "[" . key . "]" : key
    GuiControl,, %val%, %label%
}
DefaultSize := "1920x1080"
DefaultNudge := 20

; ─── load window settings from ini. ────────────────────────────────────────────────────────────────────
IniRead, SizeChoice, %iniFile%, SIZE_SETTINGS, SizeChoice, %DefaultSize%
IniRead, NudgeStep, %iniFile%, NUDGE_SETTINGS, NudgeStep, %DefaultNudge%


; ─── set nudge step field. ────────────────────────────────────────────────────────────────────
GuiControl,, NudgeStep, %NudgeStep%


; ─── highlight selected nudge button if visible. ────────────────────────────────────────────────────────────────────
Loop, 6 {
    step := 10 + (A_Index * 5)  ; 15, 20, 25, ...
    name := "Btn" . step
    label := (step = NudgeStep) ? "[" . step . "]" : step
    GuiControl,, %name%, %label%
}


; ─── set as admin. ────────────────────────────────────────────────────────────
if not A_IsAdmin
{
    try
    {
        Run *RunAs "%A_ScriptFullPath%"
    }
    catch
    {
        MsgBox, 0, Error, This script needs to be run as Administrator.
    }
    ExitApp
}


; ─── system info. ────────────────────────────────────────────────────────────
monitorIndex := 1  ; Change this to 2 for your second monitor

SysGet, MonitorCount, MonitorCount
if (monitorIndex > MonitorCount) {
    MsgBox, Invalid monitor index: %monitorIndex%
    ExitApp
}

SysGet, monLeft, Monitor, %monitorIndex%
SysGet, monTop, Monitor, %monitorIndex%
SysGet, monRight, Monitor, %monitorIndex%
SysGet, monBottom, Monitor, %monitorIndex%

; ─── Get real screen dimensions. ────────────────────────────────────────────────────────────
SysGet, Monitor, Monitor, %monitorIndex%
monLeft := MonitorLeft
monTop := MonitorTop
monRight := MonitorRight
monBottom := MonitorBottom

monWidth := monRight - monLeft
monHeight := monBottom - monTop

msg := "Monitor Count: " . MonitorCount . "`n`n"
    . "Monitor  " . monitorIndex    . ":" . "`n"
    . "Left:    " . monLeft         . "`n"
    . "Top:     " . monTop          . "`n"
    . "Right:   " . monRight        . "`n"
    . "Bottom:  " . monBottom       . "`n"
    . "Width:   " . monWidth        . "`n"
    . "Height:  " . monHeight


; ───────────────────────────────────────────────────────────────
;Unique window class name
#WinActivateForce
scriptTitle := "T7ES3 Screen Manager 3"
if WinExist("ahk_class AutoHotkey ahk_exe " A_ScriptName) && !A_IsCompiled {
    ;Re-run if script is not compiled
    ExitApp
}

;Try to send a message to existing instance
if A_Args[1] = "activate" {
    PostMessage, 0x5555,,,, ahk_class AutoHotkey
    ExitApp
}

OnMessage(0x5555, "BringToFront")
BringToFront(wParam, lParam, msg, hwnd) {
    Gui, Show
    WinActivate
}


; ─────────────────────────────────────────────────── START GUI. ───────────────────────────────────────────────────────
; ── 🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮🎮 ──
; ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
title := "T7ES3 Screen Manager 3 - " . Chr(169) . " " . A_YYYY . " - Philip"
Gui, Show, w510 h215, %title%
Gui, +LastFound +AlwaysOnTop
Gui, Font, s10 q5, Segoe UI
Gui, Margin, 15, 15
GuiHwnd := WinExist()

GuiControl,, NudgeStep, %lastNudge%
highlight := "Btn" . lastNudge

; ─── Screen manager. ────────────────────────────────────────────────────────────
Gui, Add, Button, gMoveToMonitor         x10 y10 w90 h51, SWITCH MONITOR 1/2
Gui, Add, Button, gNudgeUp              x110 y10 w50 h25, UP
Gui, Add, Button, gNudgeDown            x170 y10 w50 h25, DOWN
Gui, Add, Button, gNudgeLeft            x110 y35 w50 h25, LEFT
Gui, Add, Button, gNudgeRight           x170 y35 w50 h25, RIGHT

Gui, Add, Button, vBtn5 gSetNudge       x230 y10 w45 h25, 05
Gui, Add, Button, vBtn10 gSetNudge      x285 y10 w45 h25, 10
Gui, Add, Button, vBtn15 gSetNudge      x340 y10 w45 h25, 15
Gui, Add, Button, vBtn20 gSetNudge      x395 y10 w45 h25, 20
Gui, Add, Button, vBtn25 gSetNudge      x230 y35 w45 h25, 25
Gui, Add, Button, vBtn30 gSetNudge      x285 y35 w45 h25, 30
Gui, Add, Button, vBtn35 gSetNudge      x340 y35 w45 h25, 35
Gui, Add, Button, vBtn40 gSetNudge      x395 y35 w45 h25, 40

Gui, Add, Text,
Gui, Add, Edit, vNudgeStep              w44 h20 hidden, 20

IniRead, lastNudge, %iniFile%, NUDGE_SETTINGS, NudgeStep, 20

Gui, Add, Button, vSize800        gSetSizeChoice   x10 y70 w90 h51, 800 x 600
Gui, Add, Button, vSize1024       gSetSizeChoice  x110 y70 w90 h51, 1024 x 768
Gui, Add, Button, vSize1280       gSetSizeChoice  x210 y70 w90 h51, 1280 x 720
Gui, Add, Button, vSize1920       gSetSizeChoice  x310 y70 w90 h51, 1920 x 1080
Gui, Add, Button, vSize2560       gSetSizeChoice  x410 y70 w90 h51, 2560 x 1440
Gui, Add, Button, vSizeFull       gSetSizeChoice   x10 y131 w90 h51, FULLSCREEN
Gui, Add, Button, vSizeWindowed   gSetSizeChoice  x110 y131 w90 h51, WINDOWED
Gui, Add, Button, vSizeHidden     gSetSizeChoice  x210 y131 w90 h51, HIDDEN
Gui, Add, Button, gResetScreen                    x310 y131 w90 h51, RESET SCREEN


; ─── Bottom statusbar, 1 is reserved for process priority status, use 2. ──────────────────────────────────────────────
Gui, Add, StatusBar, vStatusBar1 hWndhStatusBar
SB_SetParts(510)
UpdateStatusBar(msg, segment := 1) {
    SB_SetText(msg, segment)
}

; ─── System tray. ────────────────────────────────────────────────────────────
Menu, Tray, Add, Show GUI, ShowGui                      ;Add a custom "Show GUI" option
Menu, Tray, Add                                         ;Add a separator line
Menu, Tray, Add, About T7ES3..., ShowAboutDialog
Menu, Tray, Default, Show GUI                           ;Make "Show GUI" the default double-click action
Menu, Tray, Tip, T7ES3 Screen Manager 3      ;Tooltip when hovering

; ─── this return ends all updates to the gui. ───────────────────────────────────
return
; ─── END GUI. ───────────────────────────────────────────────────────────────────


OpenScriptDir:
Run, %A_ScriptDir%
return


; ─── set window size handler. ───────────────────────────────────────────────────────────────────
SetSizeChoice:
global iniFile
clicked := A_GuiControl
global SizeChoice

; MAP CONTROL NAMES TO SIZE VALUES
sizes := { "Size800":       "800x600"
         , "Size1024":      "1024x768"L
         , "Size1280":      "1280x720"
         , "Size1920":      "1920x1080"
         , "Size2560":      "2560x1440"
         , "SizeFull":      "FullScreen"
         , "SizeWindowed":  "Windowed"
         , "SizeHidden":    "Hidden" }

; save selected size
SizeChoice := sizes[clicked]
IniWrite, %SizeChoice%, %iniFile%, SIZE_SETTINGS, SizeChoice

; update visuals (bracket the selected one)
for key, val in sizes {
    label := (key = clicked) ? "[" . val . "]" : val
    GuiControl,, %key%, %label%
}
; immediately apply the size
GoSub, ResizeWindow
return


ResizeWindow:
    Global iniFile
    Gui, Submit, NoHide
    SB_SetText("Current SizeChoice: " . SizeChoice, 1)

    ;-----------------------------------------------------------------
    ;  1. make sure T7ES3 is running, get HWND
    ;-----------------------------------------------------------------
    WinGet, hwnd, ID, ahk_exe TekkenGame-Win64-Shipping.exe
    if !hwnd {
        MsgBox, TekkenGame-Win64-Shipping.exe is not running.
        return
    }
    WinID := "ahk_id " hwnd

    ;-----------------------------------------------------------------
    ; 2. helper to turn any fixed-size choice into “fake-fullscreen”
    ;-----------------------------------------------------------------
    FakeFullscreen(width, height)
    {
        ; remove borders / title bar
        Global WinID
        WinSet, Style, -0xC00000, %WinID%  ; WS_CAPTION
        WinSet, Style, -0x800000, %WinID%  ; WS_BORDER
        WinSet, ExStyle, -0x00040000, %WinID%  ; WS_EX_DLGMODALFRAME
        WinShow, %WinID%

        ; which monitor is the window on?
        WinGetPos, winX, winY, , , %WinID%
        SysGet, MonitorCount, MonitorCount
        Loop, %MonitorCount% {
            SysGet, Mon, Monitor, %A_Index%
            if (winX >= MonLeft && winX < MonRight
             && winY >= MonTop  && winY < MonBottom) {
                monLeft   := MonLeft
                monTop    := MonTop
                monWidth  := MonRight  - MonLeft
                monHeight := MonBottom - MonTop
                break
            }
        }

        ; centre the custom-sized window
        newX := monLeft + (monWidth  - width)  // 2
        newY := monTop  + (monHeight - height) // 2
        WinMove, %WinID%, , %newX%, %newY%, %width%, %height%
    }

    ;-----------------------------------------------------------------
    ; 3. act on the user’s SizeChoice
    ;-----------------------------------------------------------------
    if (SizeChoice = "800x600")
        FakeFullscreen(800, 600)
    else if (SizeChoice = "1024x768")
        FakeFullscreen(1024, 768)
    else if (SizeChoice = "1280x720")
        FakeFullscreen(1280, 720)
    else if (SizeChoice = "1920x1080")
        FakeFullscreen(1920, 1080)
    else if (SizeChoice = "2560x1440")
        FakeFullscreen(2560, 1440)
    ; native maximised / true fullscreen
    else if (SizeChoice = "FullScreen") {
        WinRestore, %WinID%
        WinMaximize, %WinID%
    }
    ; windowed mode you already had (keeps borders, uses INI size)
    else if (SizeChoice = "Windowed") {
    ; Restore normal window styles
    WinSet, Style, +0xC00000, %WinID%       ; WS_CAPTION (title bar)
    WinSet, Style, +0x800000, %WinID%       ; WS_BORDER
    WinSet, Style, +0x20000,  %WinID%       ; WS_MINIMIZEBOX
    WinSet, Style, +0x10000,  %WinID%       ; WS_MAXIMIZEBOX
    WinSet, Style, +0x40000,  %WinID%       ; WS_SYSMENU (close button)
    WinSet, ExStyle, +0x00040000, %WinID%   ; WS_EX_DLGMODALFRAME

    WinShow, %WinID%
    WinRestore, %WinID%
    WinMaximize, %WinID%
    }
    else if (SizeChoice = "Hidden")
        WinHide, %WinID%
return


; ─── switch between monitors handler. ───────────────────────────────────────────────────────────────────
Run, TekkenGame-Win64-Shipping.exe,,, pid
WinWait, ahk_exe TekkenGame-Win64-Shipping.exe


; ─── monitor switch logic. ───────────────────────────────────────────────────────────────────
MoveToMonitor:
    MoveWindowToOtherMonitor("TekkenGame-Win64-Shipping.exe")
return


; ─── nudge button handler. ───────────────────────────────────────────────────────────────────
NudgeLeft:
    Gui, Submit, NoHide
    NudgeWindow("TekkenGame-Win64-Shipping.exe", -NudgeStep, 0)
return

NudgeRight:
    Gui, Submit, NoHide
    NudgeWindow("TekkenGame-Win64-Shipping.exe", NudgeStep, 0)
return

NudgeUp:
    Gui, Submit, NoHide
    NudgeWindow("TekkenGame-Win64-Shipping.exe", 0, -NudgeStep)
return

NudgeDown:
    Gui, Submit, NoHide
    NudgeWindow("TekkenGame-Win64-Shipping.exe", 0, NudgeStep)
return


; ─── window functions. ───────────────────────────────────────────────────────────────────
MoveWindowToOtherMonitor(exeName) {
    WinGet, hwnd, ID, ahk_exe %exeName%
    if !hwnd {
        MsgBox, %exeName% is not running.
        return
    }

    WinGetPos, winX, winY,,, ahk_id %hwnd%
    SysGet, Mon1, Monitor, 1
    SysGet, Mon2, Monitor, 2

    if (winX >= Mon1Left && winX < Mon1Right)
        currentMon := 1
    else
        currentMon := 2

    if (currentMon = 1) {
        targetLeft := Mon2Left
        targetTop := Mon2Top
        targetW := Mon2Right - Mon2Left
        targetH := Mon2Bottom - Mon2Top
    } else {
        targetLeft := Mon1Left
        targetTop := Mon1Top
        targetW := Mon1Right - Mon1Left
        targetH := Mon1Bottom - Mon1Top
    }

    WinRestore, ahk_id %hwnd%
    WinSet, Style, -0xC00000, ahk_id %hwnd%
    WinSet, Style, -0x800000, ahk_id %hwnd%
    WinMove, ahk_id %hwnd%, , targetLeft, targetTop, targetW, targetH
}

SetNudge:
Global iniFile
    clickedText := A_GuiControl
    value := SubStr(clickedText, 4)

    ; Set the Edit field
    GuiControl,, NudgeStep, %value%
    IniWrite, %value%, %iniFile%, NUDGE_SETTINGS, NudgeStep

    ; Update the visual labels
    for _, n in ["5", "10", "15", "20", "25", "30", "35", "40"] {
        label := (clickedText = "Btn" . n) ? "[" . n . "]" : n
        GuiControl,, Btn%n%, %label%
    }
return

NudgeWindow(exeName, dx, dy) {
    WinGet, hwnd, ID, ahk_exe %exeName%
    if !hwnd
        return
    WinGetPos, x, y, w, h, ahk_id %hwnd%
    WinMove, ahk_id %hwnd%, , x + dx, y + dy
}


; ─── reset to defaults for window positions. ───────────────────────────────────────────────────────────────────
ResetScreen:
Global SizeChoice, NudgeStep, DefaultSize, DefaultNudge, iniFile

; Restore defaults
SizeChoice := DefaultSize
NudgeStep := DefaultNudge

; Update GUI
GuiControl,, NudgeStep, %NudgeStep%
IniWrite, %NudgeStep%, %iniFile%, NUDGE_SETTINGS, NudgeStep

; Update size buttons
sizeToControl := { "800x600":       "Size800"
                 , "1024x768":      "Size1024"
                 , "1280x720":      "Size1280"
                 , "1920x1080":     "Size1920"
                 , "2560x1440":     "Size2560"
                 , "FullScreen":    "SizeFull"
                 , "Windowed":      "SizeWindowed"
                 , "Hidden": "SizeHidden" }

for key, val in sizeToControl {
    label := (key = SizeChoice) ? "[" . key . "]" : key
    GuiControl,, %val%, %label%
}
IniWrite, %SizeChoice%, %iniFile%, SIZE_SETTINGS, SizeChoice

; Update nudge buttons
Loop, 6 {
    step := 10 + (A_Index * 5)
    name := "Btn" . step
    label := (step = NudgeStep) ? "[" . step . "]" : step
    GuiControl,, %name%, %label%
}
return


; ─── Show GUI. ───────────────────────────────────────────────────────────────────
ShowGui:
    Gui, Show
    SB_SetText("T7ES3 Screen Manager 3 GUI Shown.", 1)
return

CreateGui:
    Gui, New
    Gui, Add, Text,, The GUI was Refreshed, Right Click in the Tray Bar to Reload.
    Gui, Show
Return

ExitScript:
    ExitApp
return

RefreshGui:
    Gui, Destroy
    Gosub, CreateGui
return


; ─── Show "about" dialog function. ────────────────────────────────────────────────────────────────────
ShowAboutDialog() {
    ; Extract embedded version.dat resource to temp file
    tempFile := A_Temp "\version.dat"
    hRes := DllCall("FindResource", "Ptr", 0, "VERSION_FILE", "Ptr", 10) ;RT_RCDATA = 10
    if (hRes) {
        hData := DllCall("LoadResource", "Ptr", 0, "Ptr", hRes)
        pData := DllCall("LockResource", "Ptr", hData)
        size := DllCall("SizeofResource", "Ptr", 0, "Ptr", hRes)
        if (pData && size) {
            File := FileOpen(tempFile, "w")
            if IsObject(File) {
                File.RawWrite(pData + 0, size)
                File.Close()
            }
        }
    }

    ; Read version string
    FileRead, verContent, %tempFile%
    version := "Unknown"
    if (verContent != "") {
        version := verContent
    }

aboutText := "T7ES3 Screen Manager 3 T7ES3`n"
           . "Realtime Process Priority Management for T7ES3`n"
           . "Version: " . version . "`n"
           . Chr(169) . " " . A_YYYY . " Philip" . "`n"
           . "YouTube: @game_play267" . "`n"
           . "Twitch: RR_357000" . "`n"
           . "X: @relliK_2048" . "`n"
           . "Discord:"

MsgBox, 64, About T7ES3, %aboutText%
}

; ─── Custom tray tip function ────────────────────────────────────────────────────────────────────
CustomTrayTip(Text, Icon := 1) {
    ; Parameters:
    ; Text  - Message to display
    ; Icon  - 0=None, 1=Info, 2=Warning, 3=Error (default=1)
    static Title := "T7ES3 Screen Manager"
    ; Validate icon input (clamp to 0-3 range)
    Icon := (Icon >= 0 && Icon <= 3) ? Icon : 1
    ; 16 = No sound (bitwise OR with icon value)
    TrayTip, %Title%, %Text%, , % Icon|16
}


; ─── custom msgbox. ────────────────────────────────────────────────────────────────────
ShowCustomMsgBox(title, text, x := "", y := "") {
    Gui, MsgBoxGui:New, +AlwaysOnTop +ToolWindow, %title%
    Gui, MsgBoxGui:Add, Text,, %text%
    Gui, MsgBoxGui:Add, Button, gCloseCustomMsgBox Default, OK

    ; Auto-position if x/y provided
    if (x != "" && y != "")
        Gui, MsgBoxGui:Show, x%x% y%y% AutoSize
    else
        Gui, MsgBoxGui:Show, AutoSize Center
}

CloseCustomMsgBox:
    Gui, MsgBoxGui:Destroy
return


; ─── raw ini valuer. ────────────────────────────────────────────────────────────────────
GetIniValueRaw(file, section, key) {
    sectionFound := false
    Loop, Read, %file%
    {
        line := A_LoopReadLine
        if (RegExMatch(line, "^\s*\[" . section . "\]\s*$")) {
            sectionFound := true
            continue
        }
        if (sectionFound && RegExMatch(line, "^\s*\[.*\]\s*$")) {
            break  ; Next section started, key not found
        }
        if (sectionFound && RegExMatch(line, "^\s*" . key . "\s*=\s*(.*)$", m)) {
            return m1
        }
    }
    return ""
}


GuiClose:
    ExitApp
return
