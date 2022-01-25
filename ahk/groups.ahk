GroupAdd, Explorer, ahk_class CabinetWClass
GroupAdd, Explorer, ahk_class WorkerW
GroupAdd, Explorer, ahk_class Progman
GroupAdd, Explorer, ahk_class ExploreWClass

GroupAdd, terminals, ahk_exe ubuntu.exe
GroupAdd, terminals, ahk_exe ubuntu2004.exe
GroupAdd, terminals, ahk_exe ConEmu.exe
GroupAdd, terminals, ahk_exe ConEmu64.exe
GroupAdd, terminals, ahk_exe powershell.exe
GroupAdd, terminals, ahk_exe WindowsTerminal.exe
GroupAdd, terminals, ahk_exe Hyper.exe
GroupAdd, terminals, ahk_exe mintty.exe
GroupAdd, terminals, ahk_exe Cmd.exe
GroupAdd, terminals, ahk_exe box.exe
GroupAdd, terminals, ahk_exe Terminus.exe
GroupAdd, terminals, Fluent Terminal ahk_class ApplicationFrameWindow
GroupAdd, terminals, ahk_class Console_2_Main

GroupAdd, posix, ahk_exe ubuntu.exe
GroupAdd, posix, ahk_exe ubuntu2004.exe
GroupAdd, posix, ahk_exe ConEmu.exe
GroupAdd, posix, ahk_exe ConEmu64.exe
GroupAdd, posix, ahk_exe Hyper.exe
GroupAdd, posix, ahk_exe mintty.exe
GroupAdd, posix, ahk_exe Terminus.exe
GroupAdd, posix, Fluent Terminal ahk_class ApplicationFrameWindow
GroupAdd, posix, ahk_class Console_2_Main
GroupAdd, posix, ahk_exe WindowsTerminal.exe

GroupAdd, ConEmu, ahk_exe ConEmu.exe
GroupAdd, ConEmu, ahk_exe ConEmu64.exe

GroupAdd, ExcPaste, ahk_exe Cmd.exe
GroupAdd, ExcPaste, ahk_exe mintty.exe

GroupAdd, editors, ahk_exe sublime_text.exe
GroupAdd, editors, ahk_exe VSCodium.exe
GroupAdd, editors, ahk_exe Code.exe

GroupAdd, browsers, ahk_exe chrome.exe
GroupAdd, browsers, ahk_exe opera.exe
GroupAdd, browsers, ahk_exe firefox.exe
GroupAdd, browsers, ahk_exe msedge.exe

; Disable Key Remapping for Virtual Machines
; Disable for Remote desktop solutions too
GroupAdd, remotes, ahk_exe VirtualBoxVM.exe
GroupAdd, remotes, ahk_exe mstsc.exe
GroupAdd, remotes, ahk_exe msrdc.exe
GroupAdd, remotes, ahk_exe nxplayer.bin

; Disabled Edge for now - no ability to close all instances
; GroupAdd, browsers, Microsoft Edge ahk_class ApplicationFrameWindow

GroupAdd, vscode, ahk_exe VSCodium.exe
GroupAdd, vscode, ahk_exe Code.exe

GroupAdd, vstudio, ahk_exe devenv.exe

GroupAdd, intellij, ahk_exe idea.exe
GroupAdd, intellij, ahk_exe idea64.exe