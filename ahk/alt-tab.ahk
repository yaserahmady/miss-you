; https://superuser.com/a/1248610
; LCtrl & Tab:: 
;     AltTabMenu := true
;     If GetKeyState("Shift","P")
;         Send {Alt Down}{Shift Down}{Tab}
;     else
;         Send {Alt Down}{Tab}
; return

; #If (AltTabMenu)
; ~*LCtrl Up::
; Send {Shift Up}{Alt Up}
; AltTabMenu := false 
; return
; #If

; https://www.autohotkey.com/boards/viewtopic.php?p=308245#p308245
; Remap Ctrl-Tab to Alt-Tab
; ^Tab::
;     Send {Alt down}{Tab}
;     Keywait Control
;     Send {Alt up}
; return

; ; Remap Ctrl-Shift-Tab to Alt-Shift-Tab
; ^+Tab::
;     Send {Alt down}{Shift down}{Tab}
;     Keywait Control
;     Send {Alt up}
;     Send {Shift up}
; return

; Easy Window Switcher on Italian layouts defaults to ALT + à

; LCtrl & \:: 
;     AltBacktickMenu := true
;     If GetKeyState("Shift", "P")
;         Send {Alt Down}{Shift Down}{vkDEsc028}
;     else
;         Send {Alt Down}{vkDEsc028}
; return

; #If (AltBacktickMenu)
; ~*LCtrl Up::
; Send {Shift Up}{Alt Up}{vkDEsc028 Up}
; AltBacktickMenu := false 
; return
; #If