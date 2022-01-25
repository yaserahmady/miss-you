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