; https://downloads.gosquared.com/help_sheets/Mac_Glyphs_All.pdf
; https://www.autohotkey.com/board/topic/29341-send-a-dead-key/
; https://www.aaron-gustafson.com/notebook/mac-like-special-characters-in-windows/
; https://github.com/nuj123/AutoHotKey/blob/master/misc/Typing%20Accents%20-%20Emulating%20Macs

#UseHook
KeyHistory

a::Accent("a", "à", "á")
e::Accent("e", "è", "é")
i::Accent("i", "ì", "í")
o::Accent("o", "ò", "ó")
u::Accent("u", "ù", "ú")
+a::Accent("A", "À", "Á")
+e::Accent("E", "È", "É")
+i::Accent("I", "Ì", "Í")
+o::Accent("O", "Ò", "Ó")
+u::Accent("U", "Ù", "Ú")

Accent(Letter, Grave, Acute) {
    Whitespace := ["Space", "BackSpace", "Enter", "Delete", "Escape", "Home", "End"]
    switch A_PriorHotKey
    {
        case "!8": SendInput, % !HasVal(Whitespace, A_PriorKey) && A_TimeSincePriorHotkey < 2000 ? "{BackSpace}" Acute : Letter
        case "!9": SendInput, % !HasVal(Whitespace, A_PriorKey) && A_TimeSincePriorHotkey < 2000 ? "{BackSpace}" Grave : Letter
        default: SendInput, % Letter
    }
}

HasVal(haystack, needle) {
    for index, value in haystack
        if (value = needle)
        return index
    if !(IsObject(haystack))
        throw Exception("Bad haystack!", -1, haystack)
    return 0
}

; ; Symbol: Tick
; ; ⌥ + 8
; !8::
;     Input, InputKey, L1, {delete}{esc}{home}{end} ; ... etc
;     Send, %InputKey%
;     Accent(InputKey, "Acute")
; return

; ; Symbol: Backtick
; ; ⌥ + 9
; !9::
;     Input, InputKey, L1, {delete}{esc}{home}{end} ; ... etc
;     Accent(InputKey, "Grave")
; return

; XAccent(InputKey, Accent) {

;     AccentsJSON =
;     (
;         {
;             "Grave": "{U+0060}",
;             "Acute": "{U+00B4}"
;         }
;     )
;     Accents := JSON.Load(AccentsJSON)

;     AccentMapJSON =
;     (
;         {
;             "Grave": {
;                 "a": "à",
;                 "e": "è",
;                 "i": "ì",
;                 "o": "ò",
;                 "u": "ù",
;                 "1": "{U+0060}",
;                 "3": "{U+0060}{U+0060}{U+0060}",
;                 "9": "{U+0060}",
;                 " ": "{U+0060}"
;             },
;             "Acute": {
;                 "a": "á",
;                 "e": "é",
;                 "i": "í",
;                 "o": "ó",
;                 "u": "ú",
;                 " ": "{U+00B4}"
;             }
;         }
;     )
;     AccentMap := JSON.Load(AccentMapJSON)

;     StringLower, LowercaseInputKey, InputKey

;     if (AccentMap[Accent].HasKey(LowercaseInputKey)) {
;         if (RegExMatch(InputKey,"[a-z]")) {
;             OutputKey := AccentMap[Accent][InputKey]
;         } else if (RegExMatch(InputKey,"[A-Z]")) {
;             OutputKey := AccentMap[Accent][InputKey]
;             StringUpper, OutputKey, OutputKey
;         } else {
;             OutputKey := AccentMap[Accent][InputKey]
;         }
;         Send %OutputKey%
;     } else {
;         OutputKey := Accents[Accent]
;         Send %OutputKey%%InputKey%
;     }
; }