; Docs: https://www.autohotkey.com/docs/Hotkeys.htm#AltTabDetail
; Each Alt-Tab hotkey must be either a single key or a combination of two keys, which is typically achieved via the ampersand symbol (&).
; Currently, all special Alt-tab actions must be assigned directly to a hotkey as in the examples above (i.e. they cannot be used as though they were commands). They are not affected by #IfWin or #If.
; An alt-tab action may take effect on key-down and/or key-up regardless of whether the up keyword is used, and cannot be combined with another action on the same key. For example, using both F1::AltTabMenu and F1 up::OtherAction() is unsupported.

<^Tab::AltTab
<+Tab::ShiftAltTab
