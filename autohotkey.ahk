; AHK Syntax:
;  # Win   ! Alt  ^ Ctrl  + Shift  <# LeftWin
; * any modifier
; ~ the key is always forwarded to windows
; $ prevents the hotkey from triggering itself
; ⇧ Shift
; ⌥ Option
; ⊞ # Win

; https://github.com/rbreaves/kinto/blob/master/windows/kinto.ahk
; https://github.com/stroebjo/autohotkey-windows-mac-keyboard/

; #SingleInstance force
; #NoEnv
; #Persistent

; #include ahk/hookshot.ahk
; #Include ahk/JSON.ahk
; #include ahk/alt-tab.ahk
; #include ahk/alttab.ahk
#include alt-tab/alt-tab.ahk

#include ahk/groups.ahk
#include ahk/finder.ahk
; #include ahk/ahk-accented-characters.ahk
#include ahk/custom.ahk

!8::
    SendInput, {U+00B4}
Return

!9::
    SendInput, {U+0060}
Return

; \::Send, {~}

; Close App
; ⌘ + Q
^q::Send !{F4}

; Minimize specific Window
; ⌥ + M
^m::WinMinimize, A

; Minimize all but Active Window
; ⌘ + ⌥ + M
!^m::
    WinGet, winid ,, A
    WinMinimizeAll
    WinActivate ahk_id %winid%
return

; Hide all instances of active Program
; ⌘ + H
^h::
    WinGetClass, class, A
    WinGet, AllWindows, List
    loop %AllWindows% {
        WinGetClass, WinClass, % "ahk_id " AllWindows%A_Index%
        if(InStr(WinClass,class)){
            WinMinimize, % "ahk_id " AllWindows%A_Index%
        }
    }
return

; Hide all but active program
; ⌘ + ⌥ + H
!^h::
    WinGetClass, class, A
    WinMinimizeAll
    WinGet, AllWindows, List
    loop %AllWindows% {
        WinGetClass, WinClass, % "ahk_id " AllWindows%A_Index%
        if(InStr(WinClass,class)){
            WinRestore, % "ahk_id " AllWindows%A_Index%
        }
    }
return

; Show Desktop
; ⌘ + F3
^F3::Send #d

; Emoji Panel (doesn't work)
; ⌘ + CTRL + Space
; #^Space::Send {LWin down}.{LWin up}

; Full Screenshot
; ⌘ + ⇧ + 3
; ^+3::Send {PrintScreen}

; Region Screenshot
; ⌘ + ⇧ + 4
; ^+4::Send #+{S}

; Wordwise support
#IfWinNotActive, ahk_group Explorer
    ^Up::Send ^{Home}
    ^+Up::Send ^+{Home}
    ^Down::Send ^{End}
    ^+Down::Send ^+{End}
    $^Backspace::Send +{Home}{Delete}
    !Backspace::Send ^{Backspace}
    !Left::Send ^{Left}
    !+Left::Send ^+{Left}
    !Right::Send ^{Right}
    !+Right::Send ^+{Right}
    $^Left::Send {Home}
    $^+Left::Send +{Home}
    $^Right::Send {End}
    $^+Right::Send +{End}
#IfWinNotActive

; Google Chrome
#IfWinActive, ahk_class Chrome_WidgetWin_1

    ; Show Web Developer Tools
    ; ⌘ + ⌥ + I
    ^!i::Send {F12}

    ; Show source code
    ; ⌘ + ⌥ + U
    ^!u::Send ^u

#IfWinActive

; Clipboard History
; ⌘ + ⌥ + C
^!c::
    Send #+{V}
    ; Wox
    ;     Send ^{Space}
    ;     SendInput, clipboard{Space}
return

; Symbol: Ellipsis
; ⌥ + ,
!,::SendInput, …