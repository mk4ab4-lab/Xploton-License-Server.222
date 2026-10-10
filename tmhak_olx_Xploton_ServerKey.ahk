#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1
SetKeyDelay, -1
SetMouseDelay, -1
ListLines, Off

ScriptActive := false
CustomKey := "e"
SpeedDelay := 2      ; lower value = faster macro timing
KatmChance := 100    ; percent chance to execute the macro sequence

; Xploton online licensing. Replace this URL with your HTTPS license-server URL.
LicenseServerUrl := "https://YOUR-DOMAIN.example"
LicenseFile := A_AppData "\OLX_STORE\license.ini"
LicenseExpiry := ""
LicenseKey := ""
LicenseDevice := ""
lastServerCheckTick := 0
ServerFailures := 0
if (!EnsureLicense())
    ExitApp
lastLicenseDate := SubStr(A_Now, 1, 8)

Gui, Color, 0A0A0A, 0A0A0A
Gui, +AlwaysOnTop -Caption +Border +LastFound
WinSet, Region, 0-0 R12-12 W450 h510

; OLX STORE style
Gui, Font, s10 Italic cFF2020, Segoe UI
Gui, Add, Text, x20 y18 w410 Center BackgroundTrans, OLX STORE

LogoPath := A_ScriptDir "\olx_store_logo.png"
if FileExist(LogoPath) {
    Gui, Add, Picture, x175 y45 w100 h100 BackgroundTrans +0x40 +Disabled, %LogoPath%
} else {
    Gui, Font, s22 Bold cFFFFFF, Segoe UI
    Gui, Add, Text, x20 y67 w410 Center BackgroundTrans, OLX
    Gui, Font, s14 Bold cFF2020, Segoe UI
    Gui, Add, Text, x20 y102 w410 Center BackgroundTrans, STORE
}

Gui, Font, s10 Bold c00FF78, Segoe UI
Gui, Add, Text, x60 y153 w330 h22 Center BackgroundTrans vTimerText, TIME LEFT: checking license...

Gui, Font, s16 Bold Italic cFFFFFF, Segoe UI
Gui, Add, Text, x60 y187 w330 h30 gToggleActive vKatmText BackgroundTrans, [ ] katm

Gui, Font, s9 Bold cFFFF00, Segoe UI
Gui, Add, Text, x35 y220 w380 h22 Center BackgroundTrans, Press F5 / Joy7 ON/OFF | INS Menu

; Speed slider appears first: lower milliseconds = faster.
Gui, Font, s10 Bold cFFFFFF, Segoe UI
Gui, Add, Text, x50 y252 w350 h20 Center BackgroundTrans vSpeedLabel, السرعة: 2 ms
Gui, Add, Slider, x50 y274 w350 h28 Range1-20 ToolTip vSpeedSlider gUpdateSettings, 2

; Independent katm chance slider appears directly underneath.
Gui, Font, s10 Bold cFFFFFF, Segoe UI
Gui, Add, Text, x50 y313 w350 h20 Center BackgroundTrans vChanceLabel, % "احتمالية الكاتم: 100%"
Gui, Add, Slider, x50 y335 w350 h28 Range0-100 ToolTip vChanceSlider gUpdateSettings, 100

Gui, Font, s16 Bold Italic cFFFFFF, Segoe UI
Gui, Add, Text, x45 y405 w170 h40 BackgroundTrans, tmhak key

Gui, Font, s18 Bold Italic cFFFFFF, Segoe UI
Gui, Add, Text, x240 y395 w120 h45 gCaptureKey vKeyButton Center +0x200 BackgroundTrans, %CustomKey%

Gui, Add, Progress, x240 y395 w120 h2 BackgroundFF0018 vB1 +Disabled, 100
Gui, Add, Progress, x240 y438 w120 h2 BackgroundFF0018 vB2 +Disabled, 100
Gui, Add, Progress, x240 y395 w2 h45 BackgroundFF0018 vB3 +Disabled, 100
Gui, Add, Progress, x358 y395 w2 h45 BackgroundFF0018 vB4 +Disabled, 100

Gui, Font, s8 Bold cAAAAAA, Segoe UI
Gui, Add, Text, x20 y478 w410 Center BackgroundTrans, Owned by Xploton

Gui, Font, s22 Bold cFFFFFF, Arial
Gui, Add, Text, x385 y10 w25 h25 gMinimizeUI Center BackgroundTrans, -

Gui, Font, s14 Bold cFFFFFF, Segoe UI
Gui, Add, Text, x415 y18 w25 h25 gCloseUI Center BackgroundTrans, X

Gui, Show, x0 y50 w450 h510, OLX STORE
SetTimer, WatchJoystick, 10
SetTimer, UpdateLicenseTimer, 1000
GoSub, UpdateLicenseTimer
MenuVisible := true
OnMessage(0x201, "WM_LBUTTONDOWN")
return

UpdateSettings:
GuiControlGet, SpeedDelay,, SpeedSlider
GuiControlGet, KatmChance,, ChanceSlider
GuiControl,, SpeedLabel, % "السرعة: " . SpeedDelay . " ms"
GuiControl,, ChanceLabel, % "احتمالية الكاتم: " . KatmChance . "%"
return

WM_LBUTTONDOWN() {
    MouseGetPos,,,, ControlUnderMouse, 2
    ; Let sliders, labels and buttons receive their normal mouse clicks.
    if (ControlUnderMouse != "")
        return
    PostMessage, 0xA1, 2,,, A
}

ToggleActive:
ScriptActive := !ScriptActive
if (ScriptActive) {
    GuiControl,, KatmText, [X] katm
    SoundBeep, 1000, 100
} else {
    GuiControl,, KatmText, [ ] katm
    SoundBeep, 500, 100
}
return

CaptureKey:
GuiControl, +cFFFF00, B1
GuiControl, +cFFFF00, B2
GuiControl, +cFFFF00, B3
GuiControl, +cFFFF00, B4
GuiControl,, KeyButton, ...

Input, PressedKey, L1 M T5, {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Enter}{Escape}

GuiControl, +cFF0000, B1
GuiControl, +cFF0000, B2
GuiControl, +cFF0000, B3
GuiControl, +cFF0000, B4

if (PressedKey = "" && ErrorLevel = "Timeout") {
    GuiControl,, KeyButton, %CustomKey%
    return
}
if (PressedKey = "") {
    StringReplace, PressedKey, ErrorLevel, EndKey:
}
CustomKey := PressedKey
GuiControl,, KeyButton, %CustomKey%
return

MinimizeUI:
Gui, Minimize
return

CloseUI:
ExitApp

; --- وزنية الكاتم المضمون للماوس (تم حل مشكلة التراكم والرمي العشوائي) ---
$*LButton::
if (!ScriptActive) {
    SendInput, {LButton Down}
    KeyWait, LButton
    SendInput, {LButton Up}
    return
}
Random, ChanceRoll, 1, 100
if (ChanceRoll > KatmChance) {
    ; Chance did not trigger: preserve ordinary mouse click behavior.
    SendInput, {LButton Down}
    KeyWait, LButton
    SendInput, {LButton Up}
    return
}

; Apply the selected speed to each step.
SendInput, {2 Up}{%CustomKey% Up}
SendInput, {LButton Down}
DllCall("Sleep", "UInt", SpeedDelay)
SendInput, {%CustomKey% Down}
DllCall("Sleep", "UInt", SpeedDelay)
SendInput, {2 Down}
DllCall("Sleep", "UInt", SpeedDelay + 1)
SendInput, {2 Up}{%CustomKey% Up}{LButton Up}
DllCall("Sleep", "UInt", SpeedDelay + 1)
return

; --- وزنية الكاتم المضمون ليد التحكم ---
WatchJoystick:
if (!ScriptActive) {
    return
}
GetKeyState, JoyZ, 1JoyZ
GetKeyState, JoyButton1, 1Joy1

if (JoyZ > 70 || JoyButton1 = "D") {
    Random, ChanceRoll, 1, 100
    if (ChanceRoll > KatmChance) {
        Sleep, 60
        return
    }

    SendInput, {2 Up}{%CustomKey% Up}
    SendInput, {LButton Down}
    DllCall("Sleep", "UInt", SpeedDelay)
    SendInput, {%CustomKey% Down}
    DllCall("Sleep", "UInt", SpeedDelay)
    SendInput, {2 Down}
    DllCall("Sleep", "UInt", SpeedDelay + 1)
    SendInput, {2 Up}{%CustomKey% Up}{LButton Up}
    Sleep, 60
}
return

*~F5::
GoSub, ToggleActive
return

*~1Joy7::
GoSub, ToggleActive
return

*~Ins::
MenuVisible := !MenuVisible
if (MenuVisible) {
    Gui, Hide
} else {
    Gui, Show, x0 y50 w450 h510
}
return

*~$F12::ExitApp

UpdateLicenseTimer:
todayNow := SubStr(A_Now, 1, 8)
if (todayNow < lastLicenseDate) {
    MsgBox, 16, OLX STORE - License, System date moved backwards. The program will close.
    ExitApp
}
if (todayNow > lastLicenseDate) {
    lastLicenseDate := todayNow
    IniWrite, %todayNow%, %LicenseFile%, License, LastRun
}

; Revalidate with the server every 15 seconds. Network failures are non-destructive:
; after 4 consecutive failures the app closes until the server is reachable again.
if ((A_TickCount - lastServerCheckTick) >= 15000) {
    if (CallLicenseServer("validate", LicenseKey, LicenseDevice, serverRemaining, serverError)) {
        ServerFailures := 0
        LicenseExpiry := A_Now
        EnvAdd, LicenseExpiry, %serverRemaining%, Seconds
        lastServerCheckTick := A_TickCount
    } else {
        ServerFailures += 1
        lastServerCheckTick := A_TickCount
        if (ServerFailures >= 4) {
            ScriptActive := false
            MsgBox, 16, OLX STORE - License, Unable to verify the license server. The program will close.`nError: %serverError%
            ExitApp
        }
    }
}

remaining := LicenseExpiry
EnvSub, remaining, %A_Now%, Seconds
if (remaining <= 0) {
    ScriptActive := false
    GuiControl,, KatmText, [ ] katm
    GuiControl,, TimerText, LICENSE EXPIRED
    MsgBox, 48, OLX STORE, Your license has expired.`nContact Xploton for a new key.
    ExitApp
}
daysLeft := Floor(remaining / 86400)
hoursLeft := Floor(Mod(remaining, 86400) / 3600)
minutesLeft := Floor(Mod(remaining, 3600) / 60)
secondsLeft := Mod(remaining, 60)
if (daysLeft > 0)
    leftText := "TIME LEFT: " . daysLeft . "d " . Format("{:02}", hoursLeft) . ":" . Format("{:02}", minutesLeft) . ":" . Format("{:02}", secondsLeft)
else if (hoursLeft > 0)
    leftText := "TIME LEFT: " . hoursLeft . "h " . Format("{:02}", minutesLeft) . "m " . Format("{:02}", secondsLeft) . "s"
else
    leftText := "TIME LEFT: " . minutesLeft . "m " . Format("{:02}", secondsLeft) . "s"
GuiControl,, TimerText, %leftText%
return


; ---------------- Xploton online license helpers ----------------
EnsureLicense() {
    global LicenseFile, LicenseServerUrl, LicenseExpiry, LicenseKey, LicenseDevice, lastServerCheckTick
    licenseDir := A_AppData . "\OLX_STORE"
    FileCreateDir, %licenseDir%

    if (InStr(LicenseServerUrl, "YOUR-DOMAIN.example")) {
        MsgBox, 16, OLX STORE - Setup, Configure LicenseServerUrl in this AHK file with your real HTTPS server address first.
        return false
    }
    if (SubStr(LicenseServerUrl, 1, 8) != "https://") {
        MsgBox, 16, OLX STORE - Setup, LicenseServerUrl must use HTTPS.
        return false
    }

    IniRead, LicenseKey, %LicenseFile%, License, Key,
    IniRead, LicenseDevice, %LicenseFile%, License, DeviceId,
    if (LicenseDevice = "" || LicenseDevice = "ERROR") {
        LicenseDevice := GenerateInstallId()
        IniWrite, %LicenseDevice%, %LicenseFile%, License, DeviceId
    }

    Loop {
        if (LicenseKey = "" || LicenseKey = "ERROR") {
            InputBox, enteredKey, OLX STORE - Activation, Enter your Xploton license key.`nDurations can be in minutes, hours, or days., , 430, 160
            if (ErrorLevel)
                return false
            StringUpper, enteredKey, enteredKey
            enteredKey := RegExReplace(enteredKey, "\s")
        } else {
            enteredKey := LicenseKey
        }

        if (CallLicenseServer("activate", enteredKey, LicenseDevice, remainingSeconds, serverError)) {
            LicenseKey := enteredKey
            IniWrite, %LicenseKey%, %LicenseFile%, License, Key
            IniWrite, %LicenseDevice%, %LicenseFile%, License, DeviceId
            lastRun := SubStr(A_Now, 1, 8)
            IniWrite, %lastRun%, %LicenseFile%, License, LastRun
            LicenseExpiry := A_Now
            EnvAdd, LicenseExpiry, %remainingSeconds%, Seconds
            lastServerCheckTick := A_TickCount
            MsgBox, 64, OLX STORE, License accepted.`nThe time limit starts on first activation.`nOwned by Xploton
            return true
        }

        if (serverError = "INVALID" || serverError = "REVOKED" || serverError = "EXPIRED" || serverError = "DEVICE") {
            LicenseKey := ""
            IniDelete, %LicenseFile%, License, Key
            if (serverError = "DEVICE")
                message := "This key is already linked to another device."
            else if (serverError = "EXPIRED")
                message := "This license has expired."
            else if (serverError = "REVOKED")
                message := "This license has been revoked."
            else
                message := "Invalid key. Check it and try again."
            MsgBox, 48, OLX STORE - License, %message%
            continue
        }
        MsgBox, 16, OLX STORE - Server, Cannot contact the license server.`nCheck your connection and server URL.`nDetails: %serverError%
        return false
    }
}

CallLicenseServer(action, key, device, ByRef remainingSeconds, ByRef errorCode) {
    global LicenseServerUrl
    remainingSeconds := 0
    errorCode := "NETWORK"
    try {
        request := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        request.SetTimeouts(1000, 1000, 1000, 1000)
        baseUrl := RTrim(LicenseServerUrl, "/")
        request.Open("POST", baseUrl . "/" . action, false)
        request.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
        request.Send("key=" . key . "&device=" . device)
        response := Trim(request.ResponseText)
        if (request.Status != 200) {
            errorCode := "HTTP_" . request.Status
            return false
        }
        if (RegExMatch(response, "^OK\|([0-9]+)$", match)) {
            remainingSeconds := match1 + 0
            if (remainingSeconds <= 0) {
                errorCode := "EXPIRED"
                return false
            }
            errorCode := ""
            return true
        }
        if (RegExMatch(response, "^ERR\|([A-Z_]+)$", match)) {
            errorCode := match1
            return false
        }
        errorCode := "BAD_RESPONSE"
        return false
    } catch e {
        errorCode := "NETWORK"
        return false
    }
}

GenerateInstallId() {
    chars := "0123456789ABCDEF"
    id := ""
    Loop, 32 {
        Random, n, 1, 16
        id .= SubStr(chars, n, 1)
    }
    return id
}
