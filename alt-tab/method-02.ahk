; Source: https://superuser.com/a/1248610

LCtrl & Tab:: 
    AltTabMenu := true
    If GetKeyState("Shift", "P")
        Send, {Alt Down}{Shift Down}{Tab}
    else
        Send, {Alt Down}{Tab}
return

if (AltTabMenu) {
~*LCtrl Up::
    Send, {Shift Up}{Alt Up}
    AltTabMenu := false 
return
}