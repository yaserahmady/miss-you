; Source: https://www.autohotkey.com/boards/viewtopic.php?p=308245#p308245

; Remap Ctrl-Tab to Alt-Tab
^Tab::
    Send {Alt down}{Tab}
    Keywait Control
    Send {Alt up}
return

; Remap Ctrl-Shift-Tab to Alt-Shift-Tab
^+Tab::
    Send {Alt down}{Shift down}{Tab}
    Keywait Control
    Send {Alt up}
    Send {Shift up}
return