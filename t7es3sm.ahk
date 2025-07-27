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


; ─── global config variables. ────────────────────────────────────────────────────────────────────
baseDir         := A_ScriptDir
iniFile         := A_ScriptDir . "\t7es3.ini"
t7es3Exe        := A_ScriptDir  . "\TekkenGame-Win64-Shipping.exe"


; ─── save screen size. ────────────────────────────────────────────────────────────────────
IniRead, SavedSize, %iniFile%, SIZE_SETTINGS, SizeChoice, FullScreen
SizeChoice := SavedSize
selectedControl := sizeToControl[SavedSize]
for key, val in sizeToControl {
    label := (val = selectedControl) ? "[" . key . "]" : key
    GuiControl,, %val%, %label%
}
DefaultSize := "FullScreen"

; ─── load window settings from ini. ────────────────────────────────────────────────────────────────────
IniRead, SizeChoice, %iniFile%, SIZE_SETTINGS, SizeChoice, %DefaultSize%


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
Gui, Show, w400 h100, %title%
Gui, +LastFound +AlwaysOnTop
Gui, Font, s10 q5, Segoe UI
Gui, Margin, 15, 15
GuiHwnd := WinExist()


; ─── Screen manager. ────────────────────────────────────────────────────────────
Gui, Add, Button, gMoveToMonitor         x10 y10 w90 h51, SWITCH MONITOR 1/2
Gui, Add, Button, vSizeFull       gSetSizeChoice   x110 y10 w90 h51, FULLSCREEN

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
sizes := { "SizeFull": "FullScreen"}

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
        MsgBox, TekkenGame is not running.
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
    if (SizeChoice = "FullScreen") {
        WinRestore, %WinID%
        WinMaximize, %WinID%
    }

return


; ─── switch between monitors handler. ───────────────────────────────────────────────────────────────────
Run, TekkenGame-Win64-Shipping.exe,,, pid
WinWait, ahk_exe TekkenGame-Win64-Shipping.exe


; ─── monitor switch logic. ───────────────────────────────────────────────────────────────────
MoveToMonitor:
    MoveWindowToOtherMonitor("TekkenGame-Win64-Shipping.exe")
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

; ─── reset to defaults for window positions. ───────────────────────────────────────────────────────────────────
ResetScreen:
; Restore defaults
SizeChoice := DefaultSize

; Update size buttons
sizeToControl := { "FullScreen": "SizeFull"}

for key, val in sizeToControl {
    label := (key = SizeChoice) ? "[" . key . "]" : key
    GuiControl,, %val%, %label%
}
IniWrite, %SizeChoice%, %iniFile%, SIZE_SETTINGS, SizeChoice

return


; ─── Show GUI. ───────────────────────────────────────────────────────────────────
ShowGui:
    Gui, Show
    SB_SetText("T7ES3 Screen Manager 3 GUI Shown.", 1)
return

ExitScript:
    ExitApp
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

SetTimer, ForceShowCursor, 500

ForceShowCursor:
    Loop 10
        DllCall("ShowCursor", "Int", True)
return


GuiClose:
    ExitApp
return
