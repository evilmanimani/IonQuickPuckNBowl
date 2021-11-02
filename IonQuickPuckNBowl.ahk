; IonQuickFryPuckNBowl v1.1, by evilmanimani


#SingleInstance, Force
#UseHook, On
; SendMode, Input
SetWorkingDir, %A_ScriptDir%
SetBatchLines, -1

xbutton := 0
global functions
hotkeys := {}
readme=
(LTrim
-----------Bowling bombs-----------
Shortcut will swap to bowling bombs, charge for as long as you hold the shortcut, then swap back to your last weapon.

Double-tap the key to light a time-delayed bomb. holding the key will cook off the bomb until you release to throw.

-----------Cluster puck-----------
Shortcut will swap to, and immediately fire a puck, then swap back. Double-tapping the key before firing will switch it to the alt fire mode.

Holding Ctrl while pressing the Cluster puck shortcut will toggle prepping the alt-fire for the next puck after throwing one.

-------------Quick Fry-------------
Uses the "Quick Swap Electrifryer" binding in-game for a quick melee which repeats while the key is held. Double tap + hold will
fire the alt-fire mode of the Fryer; swaps back to the previous weapon when released.

In-game bindings are read from the config file which is only written at game exit, reload your game then save settings
in the script to see those changes reflected.
)
mouseDDL := "None|LButton|RButton|MButton|XButton1|XButton2"

mouseBtns:= { MouseButton0:"LButton" ; cfg mouse binds to ahk buttons reference
            , MouseButton1:"RButton"
            , MouseButton2:"MButton"
            , MouseButton3:"XButton1"
            , MouseButton4:"XButton2" }

iniValues := {QuickBowlKey : "f" ; default keybinds
            , QuickPuckKey : "g"
            , QuickBowlMouse : "MButton3"
            , QuickPuckMouse : "XButton1"
            , QuickFry: 1}

cfgPath := A_AppData . "\Ion Fury\"

for k, v in iniValues
    IniRead, %k% , IonQuickPuckNBowl.ini, Config, % k, % v1

ReadSettings()
Gui, +hwndgui_id
Gui, Font,s10,Consolas
btnW := 85
Gui, Add, Edit, w300 R14 ReadOnly, % readme
Gui, Add, Hotkey, vQuickBowlKey w%btnW%, % QuickBowlKey
Gui, Add, Text, x+m yp+2, Bowling Bomb Key

Gui, Add, DDL, xs w%btnW% vQuickBowlMouse gSubmit, % mouseDDL
GuiControl, ChooseString, QuickBowlMouse, % QuickBowlMouse
Gui, Add, Text, x+m yp+2, Bowling Bomb Mouse Button

Gui, Add, Hotkey, xm vQuickPuckKey w%btnW%, % QuickPuckKey
Gui, Add, Text, x+m yp+2, Cluster Puck Key

Gui, Add, DDL, xs w%btnW% vQuickPuckMouse gSubmit, % mouseDDL
GuiControl, ChooseString, QuickPuckMouse, % QuickPuckMouse
Gui, Add, Text, x+m yp+2, Cluster Puck Mouse Button
Gui, Add, CheckBox, xm vQuickFry, Enable QuickFry -
Gui, Font, Italic
Gui, Add, Text, x+2 wp vQuickFryLabel
Gui, Font, Norm
GuiControl,, QuickFry, % QuickFry

Gui, Add, Button, xm hwndhotkeySaveBtn, Save
func := Func("Submit")
GuiControl, +g, % hotkeySaveBtn, % func
Gui, Add, Button, x+2 gReload, Reload 
Gui, Show
WinWait, ahk_id %gui_id%
WinGetPos, , , w, , ahk_id %gui_id%

Menu, Tray, Icon, IonQuickPuckNBowl.ico
Gui, Show, Autosize
ControlSend, Edit1, ^{Home}, % "ahk_id" WinActive("A")
Submit()

Return

Reload:
Reload

Submit() {
    global
    ReadSettings()
    Hotkey, IfWinActive, ahk_exe fury.exe
    hotkeyVars := ["QuickBowlKey", "QuickPuckKey", "QuickBowlMouse", "QuickPuckMouse","QuickElectrifryer"]
    for _, hotkey in hotkeyVars
        Try Hotkey, % "*" %hotkey%,   HotkeyDoubleCheck, Off
    Gui, Submit, NoHide
    if (QuickBowlKey <> "")
        Hotkey, % "*" QuickBowlKey, HotkeyDoubleCheck, On
    if (QuickPuckKey <> "")
        Hotkey, % "*" QuickPuckKey, HotkeyDoubleCheck, On
    if (QuickBowlMouse <> "None")
        Hotkey, % "*" QuickBowlMouse, HotkeyDoubleCheck, On
    if (QuickPuckMouse <> "None")
        Hotkey, % "*" QuickPuckMouse, HotkeyDoubleCheck, On
    if (QuickFry = 1)
        Hotkey, % "*" QuickElectrifryer, HotkeyDoubleCheck, On
    for k, v in iniValues
        IniWrite, % %k%, IonQuickPuckNBowl.ini, Config, %k%
    functions := {(QuickBowlKey):"QuickBowl",(QuickBowlMouse):"QuickBowl"
    , (QuickPuckKey):"QuickPuck",(QuickPuckMouse):"QuickPuck",(QuickElectrifryer):"QuickElectrifryer"}
    GuiControl,, QuickFryLabel, % "bound in-game to: " Format("{:U}",QuickElectrifryer)
    If (A_GuiControl = "Save") {
        ToolTip, Saved settings
        Sleep 3000
        tooltip
    }
}

HotkeyDoubleCheck() {
    global
    OutputDebug, % A_ThisHotkey
    thisKey := StrReplace(A_ThisHotkey,"*")
    if (thisKey = QuickPuckKey && GetKeyState("Ctrl","P")) {
        prepPuck := !prepPuck
        tooltip, % "Prep new pucks is " . (prepPuck ? "On" : "Off"),0,0
        SetTimer, ToolTipOff, -3000
        return
    }
    if InStr(thisKey, "XButton")
        xbutton := 1
    if !var {
        var := 1
        settimer,check, -200
        KeyWait, % thisKey
        return
    } else {
        settimer,check, off
        Func(functions[thisKey]).Call(1)
        var := 0
        return
    }
    check:
        Func(functions[thisKey]).Call()
        var := 0
    return
}

QuickElectrifryer(double := 0) {
    local thisKey, fire
    SetKeyDelay, 100, 50
    fire := double ? altFireKey : fireKey
    thisKey := StrReplace(A_ThisHotkey,"*")
    Send, {%selectElectrifryer%}
    Sleep 500
    Send, {%fire% Down}
    Sleep 650
    KeyWait, % thisKey
    Send, {%fire% Up}
    Sleep 700
    Send, {%lastUsedWep%}
    KeyWait, % thisKey
}

QuickBowl(double := 0) {
    local thisKey, swapSleep
    thisKey := StrReplace(A_ThisHotkey,"*")
    OutputDebug, % thisKey "; " (double ? altFireKey : fireKey)
    SetKeyDelay, 100, 50
    swapSleep := double ? 1350 : 1200
    send, % "{" selectBowlingBombs "}{" (double ? altFireKey : fireKey) " Down}"
    sleep, 650
    while (InStr(thisKey, "XButton") ? xbutton = 1 : GetKeyState(thisKey, "P"))
        sleep, 10
    SetKeyDelay, -1, 10
    Send, % "{" altFireKey " Up}{" fireKey " Up}"
    sleep, % swapSleep
    Send, {%lastUsedWep%}
    KeyWait, % thisKey
}

QuickPuck(double:=0) {
    local thisKey
    thisKey := StrReplace(A_ThisHotkey,"*")
    SetKeyDelay, 100, 50
    send, {%selectClusterPuck%}
    sleep, 650
    if double {
        send, {%altFireKey%}
        sleep, 550
    }
    Send, {%fireKey%}
    sleep 1100
    if prepPuck {
        send, {%altFireKey%}
        sleep, 600
    }
    Send, {%lastUsedWep%}
    KeyWait, % thisKey
}

ReadSettings() {
    global
    FileRead, furyCFG, % cfgPath . "fury.cfg"
    FileRead, settingsCFG, % cfgPath . "settings.cfg"    
    RegExMatch(furyCFG, "(.*)(?=\s=\s""Fire"")", fireKey)
    RegExMatch(furyCFG, "(.*)(?=\s=\s""Alt_Fire"")", altFireKey)
    fireKey := mouseBtns.hasKey(firekey) ? mouseBtns[firekey] : "LButton"
    altFireKey := mouseBtns.hasKey(altFireKey) ? mouseBtns[altFireKey] : "RButton"

    RegExMatch(settingsCFG,"(?<=bind "")([^""]*)(?="" ""gamefunc_Last_Used_Weapon"")", lastUsedWep)
    RegExMatch(settingsCFG,"(?<=bind "")([^""]*)(?="" ""gamefunc_Bowling_Bombs"")", selectBowlingBombs)
    RegExMatch(settingsCFG,"(?<=bind "")([^""]*)(?="" ""gamefunc_Clusterpuck"")", selectClusterPuck)
    RegExMatch(settingsCFG,"(?<=bind "")([^""]*)(?="" ""gamefunc_Quick_Swap_Electrifryer"")", QuickElectrifryer)
    RegExMatch(settingsCFG,"(?<=bind "")([^""]*)(?="" ""gamefunc_Electrifryer"")", selectElectrifryer)
    QuickElectrifryer := Format("{:L}",QuickElectrifryer)    
}

GuiClose:
ExitApp

~xbutton1 up:: ; check for release of xbutton1/2, fix for some mouse software
~xbutton2 up::
xbutton := 0
return

ToolTipOff:
tooltip
return