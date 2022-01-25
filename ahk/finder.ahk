; Explorer

#IfWinActive, ahk_group Explorer

    ; Press Enter to rename
    ; https://autohotkey.com/board/topic/109625-can-i-toggle-the-enter-key-when-renaming-files/?p=726369
    $Enter::
        if rename_toggle = 1
        {
            SendInput, {Enter}
            rename_toggle := 0
        }
        else
        {
            SendInput, {F2}
            rename_toggle := 1
        }
    return

    ; ⌘ + ↓
    ^Down::Send, {CtrlUp}{Enter}{CtrlUp}

    ; ⌘ + ↑
    ^Up::Send, {CtrlUp}!{Up}

    ; ⌘-backspace to move files to the Recycle Bin
    ^Backspace::SendInput {Delete}

#IfWinActive