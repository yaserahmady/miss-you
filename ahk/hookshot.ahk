coordmode, mouse, screen

LCtrl & LWin::
LWin & LCtrl::
mousegetpos, sx, sy
settimer, check, 250

check:
    if (GetKeyState("LCtrl", "P") AND GetKeyState("LWin", "P")) {
        mousegetpos, cx, cy
        if (cx != sx or cy != sy) {
            ; mouse has moved, calculate by how much
            if (cx > (sx+500) or cx < (sx-500)) {
                if (sx > cx) {
                    Send #{Left}{Esc}
                    mousegetpos, sx, sy ; get new mouse position
                }

                if (sx < cx) {
                    Send #{Right}{Esc}
                    mousegetpos, sx, sy ; get new mouse position
                }
            }  
        }     
    }
return