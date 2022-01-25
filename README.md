# macos-keyboard-remap-for-windows
 
# Alt-Tab

What I actually wanted was to switch the behaviour of <kbd>alt</kbd> + <kbd>tab</kbd> and <kbd>ctrl</kbd> + <kbd>tab</kbd>, so that:

- <kbd>ctrl</kbd> + <kbd>tab</kbd> switches apps
- <kbd>alt</kbd> + <kbd>tab</kbd> switches whatever (it's not really important for me since I didn't have this on macOS)

Coming from macOS I thought that if in Windows I `REWIRE LALT LCTRL` then I'll basically get most macOS shortcuts on Windows for free without the need of remapping every single keyboard shortcut in AutoHotKey.

The biggest problem is that on macOS for windows switching you use <kbd>⌘ cmd</kbd> + <kbd>tab</kbd> and not <kbd>alt</kbd> + <kbd>tab</kbd>. Now in Windows with my remaps, since I `REWIRE LALT LCTRL` I swapped <kbd>alt</kbd> with <kbd>ctrl</kbd> so to get the same key position as on an Apple keyboard I should find a way to make <kbd>ctrl</kbd> + <kbd>tab</kbd> behave like <kbd>alt</kbd> + <kbd>tab</kbd>.

My strategy was to make Windows' <kbd>ctrl</kbd> act like <kbd>⌘ cmd</kbd> on macOS, it's proving really hard to do!

---

I'm gonna document the ways I tried to solve it so if anyone finds this from a search: this is what I tried with AutoHotKey.

### [Method 1](https://github.com/yaserahmady/miss-you/blob/main/alt-tab/method-01.ahk)

This kinda works but <kbd>shift</kbd> + <kbd>ctrl</kbd> + <kbd>tab</kbd> is impossible to do simply because the special event `ShiftAltTab` doesn't support more than 2 keys.

```ahk
; Docs: https://www.autohotkey.com/docs/Hotkeys.htm#AltTabDetail
; Each Alt-Tab hotkey must be either a single key or a combination of two keys, which is typically achieved via the ampersand symbol (&).
; Currently, all special Alt-tab actions must be assigned directly to a hotkey as in the examples above (i.e. they cannot be used as though they were commands). They are not affected by #IfWin or #If.
; An alt-tab action may take effect on key-down and/or key-up regardless of whether the up keyword is used, and cannot be combined with another action on the same key. For example, using both F1::AltTabMenu and F1 up::OtherAction() is unsupported.

<^Tab::AltTab
<+Tab::ShiftAltTab
```

### [Method 2](https://github.com/yaserahmady/miss-you/blob/main/alt-tab/method-02.ahk)

This randomly misses some key up events so one of your keys stays pressed which messes up every other keyboard shortcut you press until you're able to quit AutoHotKey.

```ahk
; https://superuser.com/a/1248610

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
```

### [Method 3](https://github.com/yaserahmady/miss-you/blob/main/alt-tab/method-03.ahk)
Same issues as Method 2.

```ahk
; https://www.autohotkey.com/boards/viewtopic.php?p=308245#p308245

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
```

### [Method 4](https://github.com/yaserahmady/miss-you/blob/main/alt-tab/method-04.ahk)

This one actually works ok but it's a full alt-tab remake with AutoHotKey. It would be perfect but modifying it to work with <kbd>ctrl</kbd> instead of <kbd>alt</kbd> is kinda hard since the code requires some advanced knowledge of AutoHotKey and Windows API (which I don't have). Still I got it to work kinda ok but I'd rather just switch <kbd>ctrl</kbd> + <kbd>tab</kbd> with <kbd>alt</kbd> + <kbd>tab</kbd> and have the native UI.