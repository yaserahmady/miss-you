#Include lib/LibCon.ahk

Process, Priority,, Realtime
global FontName
FontName:="Calibri"

#NoEnv
#KeyHistory 0
#InstallKeybdHook

#Include lib/GetSysImgLstIcon.ahk
#Include lib/Gdip_All.ahk
pToken := Gdip_Startup()
wsBorder:={}
wsNoBorder:={}
wsTitle:={}
wsShortTitle:={}
wsMinMax:={}
lastWS:={}
exeIcons:={}
hwnds:={}
bgrColor:= "222222"
translucentColor:= "110011"
brgTransparency := 100
icon_size:=213/(A_ScreenDPI/96)
makeTranslucent:=1
WS_BORDER := 0x00800000
ACCENT_COLOR_ORIGINAL:= getAccentColor()
ACCENT_COLOR:="0xff" . ACCENT_COLOR_ORIGINAL ; 0xff721CAA
ACCENT_COLOR_ALPHA:= "0x80" . ACCENT_COLOR_ORIGINAL
EnvGet, vUserProfile, USERPROFILE
OnExit Exit
SetTimer, RefreshWS, 60000
OnMessage(0x404, "AHK_NOTIFYICON")

ListLines Off
Process, Priority, , A
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input

#SingleInstance,Force 
#NoEnv

SetTimer, MonitorTitles, 30000
SetTimer, ImagesInit, -1

return

MonitorTitles:
    if(WinExist("ahk_id " . guid_id))
        return
MonitorTitles0:
    For Key, oldTitle in wsTitle
    {
        WinGetTitle, windowTitle, % "ahk_id " . Key
        WinGet MX, MinMax, % "ahk_id " . Key
        if(windowTitle!=oldTitle || wsMinMax[Key]!=MX)
        {
            wsMinMax[Key]:=MX
            CleanObject(Key)
        }
    }
    GoSub, ImagesInit
return

ImagesInit:
    fnImageInit()
return

fnImageInit()
{
    global icon_size
    IdListExe:=WinsGetProcesses(0)
    IdListCountExe:=IdListExe._MaxIndex()
    Loop % IdListCountExe{
        getIconForExe(IdListExe[A_Index], icon_size, false)
        WinGet, exename, ProcessName,% "ahk_id " . IdListExe[A_Index]
        IdList:=WinsGetWindows(exename,0)
        IdListCount:=IdList._MaxIndex()
        Loop % IdListCount {
            getWsNoBorder(IdList[A_Index])
        }
    }
}

CleanObjects:
    For Key, oldTitle in wsTitle
    {
        CleanObject(Key)
    }
    For Key, hBitmap in exeIcons{
        DeleteObject(hBitmap)
        exeIcons.Delete(Key)
    }
    Gdip_Shutdown(pToken)
return

Exit:
    GoSub, CleanObjects
ExitApp

CloseStartMenu:
    WinClose ahk_class Windows.UI.Core.CoreWindow ahk_exe SearchUI.exe
    WinClose ahk_class Windows.UI.Core.CoreWindow ahk_exe StartMenuExperienceHost.exe
    Process Close, StartMenuExperienceHost.exe
return

#If StartMenuVisible()
Esc::
GoSub, CloseStartMenu
return
#If

StartMenuVisible(){
    WinGet name, ProcessName, A
    return InStr(name, "SearchUI.exe")
}

^Tab::
AltTab:
    WinGet, active_id, ID, A
    if(!active_id)
    {
        IdList:=WinsGetProcesses(0)
        WinActivate, "ahk_id " . IdList[1]
    }
    WinGet, refresh_id, ID, A
    GoSub, CloseStartMenu
    WinGet, exename, ProcessName,A
    IdList:=WinsGetProcesses(0)
    IdListCount:=IdList._MaxIndex()
    Gui, 2: +AlwaysOnTop +ToolWindow -SysMenu -Caption +LastFound +hwndhGui
    guid_id:=hGui
    Gui, 2: Margin, 20, 20
    Loop % IdListCount{
        i:=A_Index
        hwnds[A_Index]:=IdList[A_Index]
        sep:=20+Mod(i-1,7)*(icon_size+20)
        line:=(Floor((i-1)/7))
        y:=20+(icon_size+20)*line
        if(!makeTranslucent)
        {
            Gui, 2: Add, Text, w32 h32 x+%sep% y%y% gSelectWindow vIcon%i% hwndmyIcon%i% 0x3 ; 0x3 = SS_ICON
            myIcon:=myIcon%i%
            hIcon:=getIconForExe(IdList[A_Index],,true)
            SendMessage, STM_SETICON := 0x0170, hIcon, 0,, Ahk_ID %myIcon%
        }
        else
        {
            try
            {
                Gui, 2: Add, Picture, % "w" . (icon_size+10) . " h" . (icon_size+10) . " x" . sep . " y" . y . " gSelectWindow vIconBackground" . i . " hwndmyIconBackground" . i . " +0xE"
                myIconBackground:=myIconBackground%i%
                SetTitleFrameText((icon_size+10)*(A_ScreenDPI/96),(icon_size+10)*(A_ScreenDPI/96),ACCENT_COLOR,"", myIconBackground)
                WinSet, Style, +%WS_BORDER%, ahk_id %myIconBackground%
                GuiControl, Hide, % myIconBackground
                if(icon_size==32 || 1){
                    Gui, 2: Add, Picture, % "w" . icon_size . " h" . icon_size . " x" . (sep+5) . " y" . (y+5) . " gSelectWindow BackgroundTrans vIcon" . i . " hwndmyIcon" . i . " +0xE"
                    myIcon:=myIcon%i%
                    SetImage(myIcon, getIconForExe(IdList[A_Index], icon_size, false))
                } else {
                    Gui, 2: Add, Picture, % "w" . icon_size . " h" . icon_size . " x" . (sep+5) . " y" . (y+5) . " gSelectWindow BackgroundTrans vIcon" . i . " hwndmyIcon" . i . " 0x3"
                    myIcon:=myIcon%i%
                    hIcon:=getIconForExe(IdList[A_Index], icon_size, true)
                    SendMessage, STM_SETICON := 0x0170, hIcon, 0,, Ahk_ID %myIcon%
                }
            }catch e {
                return
            }
        }
    }
    if(!makeTranslucent)
    {
        ;Gui, 2: Color, 333333
    }
    else
    {
        Gui, 2: Color, c%bgrColor%
        SetAcrylicGlassEffect(translucentColor, brgTransparency, hGui)
    }
    GoSub, ShowWindow
    count:=0
    prevWindowId:=""
    selectWindow:=0
    closeWindow:=0
    While((GetKeyState("LCtrl", "P") || GetKeyState("LWin", "P") || count=0) && !selectWindow && !closeWindow)
    {
        if (GetKeyState("Tab", "P") || count=0)
        {
            if(!makeTranslucent)
            {
                WinSet, Style, -%WS_BORDER%, ahk_id %myIcon%
            }
            else
            {
                GuiControl, Hide, % myIconBackground
                GuiControl, +Redraw, % myIcon
            }
            shiftPressed := GetKeyState("Shift")
            count:=count+1-2*shiftPressed
            if(count<0)
                count:=IdList._MaxIndex()
            i:=Abs(Mod(count,IdListCount))+1
            myIcon:=myIcon%i%
            if(!makeTranslucent)
            {
                WinSet, Style, +%WS_BORDER%, ahk_id %myIcon%
            }
            else
            {
                myIconBackground:=myIconBackground%i%
                GuiControl, Show, % myIconBackground
                GuiControl, +Redraw, % myIcon
            }
            prevWindowId:=IdList[i]
            KeyWait Tab
        }
        if (GetKeyState("Esc"))
        {
            prevWindowId:=""
            break
        }
        if GetKeyState("BS", "P")
        {
            WinGet, close_exename, ProcessName, % "ahk_id " . prevWindowId
            Gui, 2: -AlwaysOnTop
            MsgBox, 4,CERRAR, Cerrar %close_exename%? (Si o No)
            IfMsgBox, Yes
            {
                GoSub, CloseExeByName
            } else {
                prevWindowId:=""
                break
            }
        }
    }
    WinMove, % "ahk_id " . guid_id,, -100, -100, 0, 0
    if(prevWindowId!="")
    {
        DllCall("SwitchToThisWindow", "ptr", prevWindowId, "int", 1)
        Loop, % 5
        {
            WinActivate, % "ahk_id " . prevWindowId
            Sleep, 10
        }
    }
    Gui, 2: Cancel
    Gui, 2: Destroy
return

RemoveToolTip:
    ToolTip
return

; #IfWinNotExist, ahk_exe Mac-AltTab.exe
; #BS::
; WinGet, close_exename, ProcessName, A
CloseExeByName:
    IdList:=WinsGetWindows(close_exename,0)
    Loop, % IdList._MaxIndex(){
        close_id := IdList[A_Index]
        WinActivate, % "ahk_id " . close_id
        WinGetTitle, close_title, % "ahk_id " . close_id
        MsgBox, 4,CERRAR, Cerrar %close_title%? (Si o No)
        IfMsgBox, Yes
        {
            WinClose, % "ahk_id " . close_id
        }
    }
return
#If

LCtrl & \::
    WinGet, active_id, ID, A
    if(!active_id)
    {
        IdList:=WinsGetProcesses(0)
        WinActivate, "ahk_id " . IdList[1]
    }
    WinGet, refresh_id, ID, A
    CoordMode, Tooltip, Screen
    WinGet, new_exename, ProcessName,A
    if(new_exename)
        exename:=new_exename
    GoSub, ShowWindowPicker
return

GetPressedKey:
    this_key:=StrReplace(A_ThisHotkey, "#")
    if(this_key="BS")
    {
        if(StrLen(SearchText)>0)
            SearchText:=SubStr(SearchText, 1, StrLen(SearchText)-1)
    }
    else
    {
        if(StrLen(this_key)<2)
            SearchText:=SearchText . this_key
    }
    if(this_key="F4")
    {
        WinClose, ahk_id %prevWindowId%
        WinWaitClose , ahk_id %prevWindowId%, , 1
        closeWindow:=1
    }
    if(this_key="Left" || this_key="Right")
    {
        if(this_key="Left")
        {
            force_shiftPressed:=1
        }
    }
    else
    {
        i:=GetTitleMatch()
        force_ChangeWindowInWindowPicker:=1
    }
    GoSub, ChangeWindowInWindowPicker
    SetTimer, ResetSearchText, -1000
return

ResetSearchText:
    SearchText:=""
    Tooltip
return

ChangeWindowInWindowPicker:
    ; refresh_id:=prevWindowId
    ; SetTimer, RefreshWin, -1
    if(pressedCount)
    {
        WinSet, Style, -Redraw, ahk_id %myIcon%
        SetImage(myIcon, getWsNoBorder(prevWindowId))
        WinSet, Style, +Redraw, ahk_id %myIcon%
    }

    shiftPressed := GetKeyState("Shift") || force_shiftPressed
    force_shiftPressed:=0
    count:=count+1-2*shiftPressed
    if(count<1)
        count:=IdList._MaxIndex()
    if(force_ChangeWindowInWindowPicker)
    {
        force_ChangeWindowInWindowPicker:=0
        count:=i
    }
    else
    {
        i:=Abs(Mod(count,IdListCount))+1
    }
    myIcon:=myIcon%i%
    myIconBorder:=myIconBorder%i%
    ThumbIcon:=ThumbIcon%i%

    WinSet, Style, -Redraw, ahk_id %myIcon%
    SetImage(myIcon, getWsBorder(IdList[i]))
    WinSet, Style, +Redraw, ahk_id %myIcon%
    if(!makeTranslucent)
    {
        GuiControl, 2:, TitleFrame,% " " . getWsTitle(IdList[i])
    }
    else
    {
        titleBarText:=getWsTitle(IdList[i])
        ; if(gwidth1<StrLen(titleBarText)*5)
        ; {
        ; 	titleBarText:=limittext(titleBarText, len=10)
        ; }
        ; tooltip, % gwidth1 . "-" . (StrLen(titleBarText)*5)
        SetTitleFrameText(gwidth1,gheight1,0xff000000,titleBarText, TextBackground)
    }
    ; WinSet, Style, +%WS_BORDER%, ahk_id %myIcon%

    prevWindowId:=IdList[i]
return

ShowWindowPicker:
    IdList:=WinsGetWindows(exename,0)
    count:=0
    IdListCount:=IdList._MaxIndex()
    if(!IdListCount)
        return
    Gui, 2: +AlwaysOnTop +ToolWindow -SysMenu -Caption +LastFound +hwndhGui
    guid_id:=hGui

    SearchText:=""
    Hotkey, IfWinExist, % "ahk_id " . guid_id
        Keys := ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","1","2","3","4","5","6","7","8","9","0","-",".","_","BS","Left","Right", "F4"]
    for k, v in Keys
    {
        Hotkey, #%v%, GetPressedKey
    }
    Hotkey, IfWinExist

    Gui, 2: Margin, 20, 20
    Loop % IdListCount{
        i:=A_Index
        sep:=20+Mod(i-1,5)*240
        line:=(Floor((i-1)/5))
        y:=20+240*line
        y2:=153+240*line-5
        try
        {
            Gui 2:Add, Picture, % "x" . sep . " y" . y . " w230 h230 gSelectWindow vIcon" . i . " hwndmyIcon" . i . " +0xE"
        }catch e {
            return
        }
        ; Gui 2:Add, Picture, % "xp+6 y" . y2 . " w128 h30 BackgroundTrans hwndThumbIcon" . i . " +0xE" ; 203
        image := myIcon%i%
        sourceWin:=IdList[A_Index]
        hwnds[A_Index]:=sourceWin
        SetImage(image, getWsNoBorder(sourceWin))
    }
    y:=20+240*(line+1)+10
    gwidth := Min(IdListCount,5)*230+(Min(IdListCount,5)-1)*10
    if(gwidth="")
        gwidth:=0
    min_win_width:=3
    gwidth:=Max(gwidth, min_win_width*230+(min_win_width-1)*10)
    gheight:=30
    ; makeTranslucent:=0
    if(!makeTranslucent)
    {
        Gui, 2: Font, %FontName% Bold
        Gui, 2: Add, Text, x20 y%y% w%gwidth% h%gheight% +0x200 vTitleFrame cWhite +Left BackgroundTrans ReadOnly 0x1000, ;0x1000->ss_sunken +0x201->center +Center
        Gui, 2: Color, 333333
    }
    else
    {
        Gui, 2: Add, Picture, x20 y%y% w%gwidth% h%gheight% hwndTextBackground +0xE
        gwidth1:=Ceil(gwidth*(A_ScreenDPI/96))
        gheight1:=Ceil(gheight*(A_ScreenDPI/96))
        Gui, 2: Color, c%bgrColor%
        SetAcrylicGlassEffect(translucentColor, brgTransparency, hGui)
    }
    ;SetTimer, ShowWindow, -200
    GoSub, ShowWindow

    count:=0
    pressedCount:=0
    prevWindowId:=active_id
    selectWindow:=0
    closeWindow:=0
    While((GetKeyState("LCtrl", "P") || GetKeyState("LWin", "P") || count=0) && !selectWindow && !closeWindow)
    {
        if (GetKeyState("Tab", "P") || count=0)
        {
            GoSub, ChangeWindowInWindowPicker
            KeyWait Tab
            pressedCount:=pressedCount+1
        }
        if (GetKeyState("\", "P") || count=0)
        {
            GoSub, ChangeWindowInWindowPicker
            KeyWait \
            pressedCount:=pressedCount+1
        }
        if (GetKeyState("F5"))
        {
            IdListCount:=IdList._MaxIndex()
            Loop % IdListCount
            {
                refreshWinId:=IdList[A_Index]
                WinGet MX, MinMax, % "ahk_id " refreshWinId
                if(MX==-1)
                {
                    CleanObject(refreshWinId, 1)
                    WinRestore, ahk_id %refreshWinId%
                    j:=A_Index
                    rIcon:=myIcon%j%
                    WinSet, Style, -Redraw, ahk_id %rIcon%
                    if(j==i)
                        SetImage(rIcon, getWsBorder(refreshWinId))
                    else
                        SetImage(rIcon, getWsNoBorder(refreshWinId))
                    WinSet, Style, +Redraw, ahk_id %rIcon%
                }
            }
        }
        if (GetKeyState("Esc"))
        {
            prevWindowId:=""
            break
        }
        ; if GetKeyState("BS", "P")
        ; {
        ; 	WinGet, close_exename, ProcessName, % "ahk_id " . prevWindowId
        ; 	Gui, 2: -AlwaysOnTop
        ; 	MsgBox, 4,CERRAR, Cerrar %close_exename%? (Si o No)
        ; 	IfMsgBox, Yes
        ; 	{
        ; 		Loop, % IdList._MaxIndex(){
        ; 			i:=Abs(Mod(count,IdListCount))+1
        ; 			close_id := IdList[i]
        ; 			WinActivate, % "ahk_id " . close_id
        ; 			WinGetTitle, close_title, % "ahk_id " . close_id
        ; 			MsgBox, 4,CERRAR, Cerrar %close_title%? (Si o No)
        ; 			IfMsgBox, Yes
        ; 			{
        ; 				WinClose, % "ahk_id " . close_id
        ; 			}
        ; 			count:=count+1
        ; 		}
        ; 	} else {
        ; 		prevWindowId:=""
        ; 		break
        ; 	}
        ; }
    }
    WinMove, % "ahk_id " . guid_id,, -100, -100, 0, 0
    if(prevWindowId!="" && !closeWindow)
    {
        DllCall("SwitchToThisWindow", "ptr", prevWindowId, "int", 1)
        Loop, % 5
        {
            WinActivate, % "ahk_id " . prevWindowId
            Sleep, 10
        }
    }
    Gui, 2: Cancel
    Gui, 2: Destroy
    SetTimer, RefreshPrevWindow, -1
    if(closeWindow)
    {
        GoSub, ShowWindowPicker
    }
return

RefreshPrevWindow:
    ; return
    if(WinExist("ahk_id " . prevWindowId))
    {
        CleanObject(prevWindowId)
        getWsBorder(refreshWinId)
        getWsNoBorder(refreshWinId)
    }
return

ShowWindow:
    ; y_pos := A_ScreenHeight/2-120
    ; Gui, 2:  Show, y%y_pos% NoActivate 
    Gui, 2: Show, NoActivate
    Sleep, 10
    if(A_ThisHotkey=="#Tab" && (!IdListCount || IdListCount>=min_win_width)) ; Last border correction
    {
        myIcon:=myIcon%i%
        ThumbIcon:=ThumbIcon%i%
        SetImage(myIcon, getWsBorder(IdList[i]))
        WinSet, Style, +%WS_BORDER%, ahk_id %myIcon%
        GuiControl, +Redraw, % myIcon
        SetImage(myIcon, getWsNoBorder(IdList[i]))
        WinSet, Style, -%WS_BORDER%, ahk_id %myIcon%
        GuiControl, +Redraw, % myIcon
        GuiControl, +Redraw, % ThumbIcon
        Sleep, 1
    }
return

SelectWindow:
    iconNumber:=StrReplace(A_GuiControl, "Icon")
    iconNumber:=StrReplace(iconNumber, "Background")
    prevWindowId:=hwnds[iconNumber]
    selectWindow:=1
return

2GuiContextMenu:
    if(A_GuiEvent=="RightClick")
    {
        iconNumber:=StrReplace(A_GuiControl, "Icon")
        if(iconNumber is number)
        {
            if(iconNumber!=1)
                actualWindowId:=hwnds[1]
            else
                actualWindowId:=hwnds[2]
            WinActivate, ahk_id %actualWindowId%
            prevWindowId:=hwnds[iconNumber]
            WinClose, ahk_id %prevWindowId%
            WinWaitClose , ahk_id %prevWindowId%, , 1
            closeWindow:=1
        }
    }
return

CalculateToolTipDisplayRight(CData) {
    global tW
    global tH
    CoordMode, ToolTip, Screen
    ToolTip, %CData%,,A_ScreenHeight+100
    thisId:=WinExist()
    WinGetPos,,, tW, tH, ahk_class tooltips_class32 ahk_exe %A_ScriptName%
    ToolTip
Return
}

#IfWinActive ahk_exe Mac-AltTab.exe
$Esc::
    ControlClick, Button2, A
return
#IfWinActive

WinsGetWindows(ahk_exe, dir=0, exclude="") {
    DetectHiddenWindows, Off
    ListArray:=[]
    ListArrayDict:={}
    WinGet, myList, list
    Loop % myList {
        if(!dir)
            index:=A_Index
        else
            index:=myList - A_Index
        WinGetPos, winX, winY, winW, winH, % "ahk_id " myList%index% 
        WinGetTitle, title, % "ahk_id " myList%index%
        WinGetClass, class, % "ahk_id " myList%index%
        WinGet, exename, ProcessName, % "ahk_id " myList%index%
        WinGet MX, MinMax, % "ahk_id " myList%index%
        WinGet, ExStyle, ExStyle, % "ahk_id " myList%index%
        If (ExStyle & 0x8)
            isontop = 1
        Else
            isontop = 0
        If (title!="")
            && (title!="Program Manager")
        && (class!="")
        && (class!="WorkerW")
        && (class!="Cortana")
        && (exename!="video.exe")
        && (!isontop)
        && (exename!="spritz.exe")
        && (exename!="clock.exe")
        && (myList%index%!=exclude)
        && (exename=ahk_exe)
        && (WinIsVisible(myList%index%))
        {
            ListArray.Insert(myList%index%)
        }
    }
return ListArray
}

WinsGetProcesses(dir=0, exclude="") {
    DetectHiddenWindows, Off
    ListArray:=[]
    ListArrayDict:={}
    WinGet, myList, list
    Loop % myList {
        if(!dir)
            index:=A_Index
        else
            index:=myList - A_Index
        WinGetPos, winX, winY, winW, winH, % "ahk_id " myList%index% 
        WinGetTitle, title, % "ahk_id " myList%index%
        WinGetClass, class, % "ahk_id " myList%index%
        WinGet, exename, ProcessName, % "ahk_id " myList%index%
        WinGet MX, MinMax, % "ahk_id " myList%index%
        WinGet, ExStyle, ExStyle, % "ahk_id " myList%index%
        If (ExStyle & 0x8)
            isontop = 1
        Else
            isontop = 0
        If (title!="")
            && (title!="Program Manager")
        && (class!="")
        && (class!="WorkerW")
        && (class!="Cortana")
        && (exename!="video.exe")
        && (!isontop)
        && (exename!="spritz.exe")
        && (exename!="clock.exe")
        && (exename!="")
        && (WinIsVisible(myList%index%))
        {
            if(!ListArrayDict.HasKey(exename) && exclude!=exename)
            {
                ListArrayDict[exename]:=1
                ListArray.Insert(myList%index%)
            }
        }
    }
return ListArray
}

IsInvisibleWin10BackgroundAppWindow(hWindow) {
    result := 0
    VarSetCapacity(cloakedVal, A_PtrSize) ; DWMWA_CLOAKED := 14
    hr := DllCall("DwmApi\DwmGetWindowAttribute", "Ptr", hWindow, "UInt", 14, "Ptr", &cloakedVal, "UInt", A_PtrSize)
    if !hr ; returns S_OK (which is zero) on success. Otherwise, it returns an HRESULT error code
        result := NumGet(cloakedVal) ; omitting the "&" performs better
return result ? true : false
}

WinIsVisible(ahk_id="A"){
    hWindow:=ahk_id
    if(ahk_id!="A")
    {
        ahk_id := "ahk_id " . ahk_id
    }
    else
    {
        WinGet, hWindow, ID, A
    }
    WinGet, Active_Process, ProcessName, ahk_id %hWindow%
    WinGet, es, ExStyle, ahk_id %hWindow%
return (Active_Process<>"spritz.exe") && (!((es & WS_EX_TOOLWINDOW) && !(es & WS_EX_APPWINDOW)) && !IsInvisibleWin10BackgroundAppWindow(hWindow))
}

;###########################################################
SetTitleFrameText(DstWidth,DstHeight, color, text, ctrl)
{
    pBitmapB := Gdip_CreateBitmap(DstWidth,DstHeight)
    GB := Gdip_GraphicsFromImage(pBitmapB)
    pBrush := Gdip_BrushCreateSolid(color)
    Gdip_FillRectangle(GB, pBrush, 0, 0, DstWidth, DstHeight)
    if(text)
    {
        Options := "x0 y5 h" . (DstHeight) . " w" . (DstWidth) . " s24 Left Bold cffffffff"
        Font := FontName
        Gdip_TextToGraphics(GB, " " . text, Options, Font, DstWidth, DstHeight)
    }
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmapB)
    SetImage(ctrl, hBitmap)
    DeleteObject(hBitmap)
    Gdip_DeleteBrush(pBrush)
    Gdip_DeleteGraphics(GB)
    Gdip_DisposeImage(pBitmapB)
}
ReadConsoleLine(){
    global
    totalCmdLineHeight:=0
    GetConsoleCursorPosition(xCmdLine,totalCmdLineHeight)
    linesToRead:=5
    CmdLine:=""
    Loop, % linesToRead
    {
        CmdLine:=ReadConsoleOutput( 0, 0, GetConsoleClientWidth(), A_Index,totalCmdLineHeight)
        if(InStr(CmdLine, "C:") || InStr(CmdLine, "@"))
            break
    }
    CmdLine:=RegExReplace(CmdLine, "C:.*?\>", "")
    CmdLine:=RegExReplace(CmdLine, "\n", "")
return CmdLine
}
CopyWinImgToCache(SourceWin,DstWidth, DstHeight)
{
    global Bord
    global wsBorder
    global wsNoBorder
    global wsTitle
    global wsShortTitle
    global lastWS
    global wsMinMax
    global ACCENT_COLOR
    global vUserProfile

    WinGetTitle, Title, % "ahk_id " . SourceWin
    WinGet, exename, ProcessName,% "ahk_id " . SourceWin
    wsTitle[SourceWin]:=Title
    displayTitle:=limittext(Title)
    try
    {
        if(InStr(exename, "xplorer") || InStr(exename, "cmd"))
        {
            sFolder:=0
            WinGetClass, class, % "ahk_id " . SourceWin
            if(class=="CabinetWClass" || class=="ExploreWClass" )
            {
                windows := ComObjCreate("Shell.Application").Windows
                For window in windows
                {
                    doc := window.document
                    WindowHwnd:=0
                    try
                    WindowHwnd:=window.hWnd
                }
                Until (WindowHwnd && WindowHwnd = SourceWin)
                sFolder := doc.folder.self.path
                if(InStr(sFolder, "::{"))
                    sFolder:=displayTitle
                newWsTitle:=""
                splitFolder:=StrSplit(sFolder, ["\", "/"])
                splitCount:=splitFolder._MaxIndex()
                folderCount:=7
                Loop, % splitCount
                {

                    newWsTitle:= splitFolder[splitCount - A_Index + 1] . (newWsTitle?"/":"") . newWsTitle
                    folderCount:=folderCount-1
                    if(!folderCount)
                        break
                }
                wsTitle[SourceWin]:=newWsTitle
            }
            if(class=="ConsoleWindowClass")
            {
                winget, winpid, PID, % "ahk_id " . SourceWin
                sFolderOld:=RTrim(GetProcessCurrentDirectory(winpid),"\")
                sFolder:=sFolderOld
            }
            if(sFolder)
            {
                sFolder:=StrSplit(sFolder, ["\", "/"])
                folderCount:=sFolder._MaxIndex()
                maxLenght:=24
                if(folderCount>0)
                {
                    displayTitle:=sFolder[folderCount]
                    if(folderCount>1)
                    {
                        newTitle:=sFolder[folderCount-1] . "/" . displayTitle
                        if(StrLen(newTitle)<maxLenght || StrLen(sFolder[folderCount])<(maxLenght-1))
                        {
                            displayTitle:=newTitle
                            newTitle:=sFolder[folderCount-2] . "/" . displayTitle
                            if(folderCount>2)
                            {
                                if(StrLen(newTitle)<maxLenght)
                                    displayTitle:=newTitle
                            }
                        }
                    }
                }
                newTitle:=SubStr(displayTitle, -maxLenght)
                if(StrLen(displayTitle)!=StrLen(newTitle) && InStr(displayTitle, "/"))
                {
                    newTitle:=SubStr(displayTitle, -(maxLenght-3))
                    displayTitle:="..." . newTitle
                }
            }
            if(class=="ConsoleWindowClass")
            {
                WinGet, cmdPid, PID,% "ahk_id " . SourceWin
                AttachConsole(cmdPid)
                cmdLine:=ReadConsoleLine()
                cmdLine:=Trim(LTrim(RTrim(cmdLine, "`n"),"`n"))
                if(cmdLine="" && !WinActive("ahk_id " SourceWin))
                {
                    ControlSend,,{Up},ahk_pid %cmdPid%
                    Sleep, 500
                    cmdLine:=ReadConsoleLine()
                }
                FreeConsole()
                cmdLine:=Trim(LTrim(RTrim(cmdLine, "`n"),"`n"))
                if(cmdLine!="")
                    wsTitle[SourceWin]:=cmdLine
                else
                {
                    newTitle := StrReplace(sFolderOld,vUserProfile,"~")
                    newTitle := StrReplace(newTitle,"\","/")
                    wsTitle[SourceWin]:=newTitle
                }
            }
        }
    } catch {}
    wsShortTitle[SourceWin]:=displayTitle

    WinGet MX, MinMax, % "ahk_id " . SourceWin
    wsMinMax[SourceWin]:=MX

    lastWS[SourceWin]:=A_TickCount

    Bord:=10*(A_ScreenDPI/96)
    DstWidth:=DstWidth-Bord
    DstHeight:=DstHeight-Bord
    pBitmapI :=Gdip_CreateBitmapFromHICON(Get_Window_Icon(SourceWin))
    w1 := Gdip_GetImageWidth(pBitmapI), h1 := Gdip_GetImageHeight(pBitmapI)
    pBitmapI := Gdip_ResizepBitmap(pBitmapI, w1, h1, 128, 128, 0)
    hBitmapI := Gdip_CreateHBITMAPFromBitmap(pBitmapI)

    pBitmap := 	Gdip_BitmapFromHWNDStretchToDst(SourceWin,DstWidth,DstHeight)
    pBitmapB := Gdip_CreateBitmap(DstWidth+Bord, DstHeight+Bord)
    GB := Gdip_GraphicsFromImage(pBitmapB)
    pBrush := Gdip_BrushCreateSolid(ACCENT_COLOR)
    Gdip_FillRectangle(GB, pBrush, 0, 0, DstWidth+Bord, DstHeight+Bord)
    Gdip_DeleteBrush(pBrush)
    Gdip_DrawImage(GB, pBitmap, Bord/2, Bord/2, DstWidth, DstHeight, 0, 0, DstWidth, DstHeight)
    Gdip_DrawImage(GB, pBitmapI, Bord/2, DstHeight-(128-Bord/2), 128, 128, 0, 0, 128, 128)
    pBrush := Gdip_BrushCreateSolid(ACCENT_COLOR)
    Gdip_FillRectangle(GB, pBrush, 0, 0, DstWidth+Bord, 32)
    Gdip_DeleteBrush(pBrush)
    Options := "x0 y5 h30 w" . (DstWidth-Bord) . " s20 Center Bold cffffffff"
    Font := FontName
    Gdip_TextToGraphics(GB, displayTitle, Options, Font, DstWidth-Bord, 30)
    hBitmapB := Gdip_CreateHBITMAPFromBitmap(pBitmapB)

    wsBorder[SourceWin]:=hBitmapB

    pBitmapW := Gdip_CreateBitmap(DstWidth+Bord, DstHeight+Bord)
    G := Gdip_GraphicsFromImage(pBitmapW)
    pBrush := Gdip_BrushCreateSolid(0xff333333)
    Gdip_FillRectangle(G, pBrush, 0, 0, DstWidth+Bord, DstHeight+Bord)
    Gdip_DeleteBrush(pBrush)
    Gdip_DrawImage(G, pBitmap, Bord/2, Bord/2, DstWidth, DstHeight, 0, 0, DstWidth, DstHeight)
    Gdip_DrawImage(G, pBitmapI, Bord/2, DstHeight-(128-Bord/2), 128, 128, 0, 0, 128, 128)
    pBrush := Gdip_BrushCreateSolid(0xff333333)
    Gdip_FillRectangle(G, pBrush, 0, 0, DstWidth+Bord, 32)
    Gdip_DeleteBrush(pBrush)
    Options := "x0 y5 h30 w" . (DstWidth-Bord) . " s20 Center Bold c99ffffff"
    Font := FontName
    Gdip_TextToGraphics(G, displayTitle, Options, Font, DstWidth-Bord, 30)

    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmapW)

    wsNoBorder[SourceWin]:=hBitmap

    Gdip_DeleteGraphics(G)
    Gdip_DeleteGraphics(GB)
    DeleteObject(hBitmapI)
    Gdip_DisposeImage(pBitmap)
    Gdip_DisposeImage(pBitmapB)
    Gdip_DisposeImage(pBitmapW)
    Gdip_DisposeImage(pBitmapI)
    if pBitmap=0
        return false
return true
}

limittext(s,words=5,len=20)
{
    r := ""
    loop,parse,s,`t` -,
    {
        if (StrLen(r . " " . A_LoopField) > len)
            break
        r .= " " A_LoopField
        if (A_Index = words)
            break
    }
    if(r=="")
        loop,parse,s,`t` -,
    {
        r .= " " A_LoopField
        break
    }
    r:=LTrim(RTrim(r))
    if(SubStr(r, -1)=" -")
        r:=RTrim(LTrim(SubStr(r, 1, StrLen(r)-1)))
return r
}

getWsTitle(sourceWin){
    global wsTitle
    global lastWS

    ; if(wsTitle.HasKey(sourceWin) && (A_TickCount - lastWS[sourceWin])<10000)
    ; 	return wsTitle[sourceWin]
    ; WinGetTitle, Title, % "ahk_id " . sourceWin
    ; if(wsTitle[sourceWin]!=Title)
    ; 	CopyWinImgToCache(sourceWin, 230*(A_ScreenDPI/96), 230*(A_ScreenDPI/96))

    if(wsTitle.HasKey(sourceWin)) ; && (A_TickCount - lastWS[sourceWin])<10000)
        return wsTitle[sourceWin]
    CopyWinImgToCache(sourceWin, 230*(A_ScreenDPI/96), 230*(A_ScreenDPI/96))
return wsTitle[sourceWin]
}

getWsBorder(sourceWin){
    global wsBorder
    global lastWS

    if(wsBorder.HasKey(sourceWin)) ; && (A_TickCount - lastWS[sourceWin])<10000)
        return wsBorder[sourceWin]
    CopyWinImgToCache(sourceWin, 230*(A_ScreenDPI/96), 230*(A_ScreenDPI/96))
return wsBorder[sourceWin]
}

getWsNoBorder(sourceWin){
    global wsNoBorder
    global lastWS

    if(wsNoBorder.HasKey(sourceWin)) ; && (A_TickCount - lastWS[sourceWin])<10000)
        return wsNoBorder[sourceWin]
    CopyWinImgToCache(sourceWin, 230*(A_ScreenDPI/96), 230*(A_ScreenDPI/96))
return wsNoBorder[sourceWin]
}

RefreshWin:
    CopyWinImgToCache(refresh_id, 230*(A_ScreenDPI/96), 230*(A_ScreenDPI/96))
return

RefreshWS:
    if(WinExist("ahk_id " . guid_id))
        return
RefreshWS0:
    For Key, hBitmap in wsNoBorder
    {
        if(!WinActive("ahk_id " . Key))
        {
            CleanObject(Key)
        }
    }
    SetTimer, ImagesInit, -1
return

CleanObject(Key, force:=0)
{
    global wsNoBorder
    global wsBorder
    global wsTitle
    global wsShortTitle
    global wsMinMax

    cleanObject:=1
    if(!force && wsMinMax.HasKey(Key))
    {
        if(wsMinMax[Key]==-1)
            cleanObject:=0
    }
    if(cleanObject)
    {
        DeleteObject(wsNoBorder[Key])
        DeleteObject(wsBorder[Key])
        wsNoBorder.Delete(Key)
        wsBorder.Delete(Key)
        wsTitle.Delete(Key)
        wsShortTitle.Delete(Key)
        wsMinMax.Delete(Key)
    }
}

CleanAll:
    Reload
    ; GoSub, CleanObjects
    ; pToken := Gdip_Startup()
return

Get_Window_Icon(wid, Use_Large_Icons_Current=1) ; (window id, whether to get large icons)
{

    ; check status of window - if window is responding or "Not Responding"

    h_icon:=0
    Responding := DllCall("SendMessageTimeout", "UInt", wid, "UInt", 0x0, "Int", 0, "Int", 0, "UInt", 0x2, "UInt", 150, "UInt *", NR_temp) ; 150 = timeout in millisecs
    If (Responding)
    {
        ; WM_GETICON values -    ICON_SMALL =0,   ICON_BIG =1,   ICON_SMALL2 =2
        If Use_Large_Icons_Current =1
        {
            SendMessage, 0x7F, 1, 0,, ahk_id %wid%
            h_icon := ErrorLevel
        }
        If ( ! h_icon )
        {
            SendMessage, 0x7F, 2, 0,, ahk_id %wid%
            h_icon := ErrorLevel
            If ( ! h_icon )
            {
                SendMessage, 0x7F, 0, 0,, ahk_id %wid%
                h_icon := ErrorLevel
                If ( ! h_icon )
                {
                    If Use_Large_Icons_Current =1
                        h_icon := DllCall( "GetClassLong", "uint", wid, "int", -14 ) ; GCL_HICON is -14
                    If ( ! h_icon )
                    {
                        h_icon := DllCall( "GetClassLong", "uint", wid, "int", -34 ) ; GCL_HICONSM is -34
                        ;If ( ! h_icon )
                        ;  h_icon := DllCall( "LoadIcon", "uint", 0, "uint", 32512 ) ; IDI_APPLICATION is 32512
                    }
                }
            }
        }
    }
return h_icon
}

Gdip_BitmapFromHWNDStretchToDst(SrcHwnd,DstWidth,DstHeight,Bord:=0)
{

    WinGetPos,,, Width, Height, ahk_id %SrcHwnd%
    if (Width=0) or (Height=0)
    {
        return 0
    }
    if (A_OSVersion in WIN_XP) ; Note: No spaces around commas.
    {
        pBitmap := Gdip_BitmapFromHWND(SrcHwnd)
    }
    else
    {
        if (SrcHwnd="")
        {
            SrcHwnd:=0
        }
        hdc2 := DllCall("GetDC", UInt, SrcHwnd)
        hdc := DllCall("CreateCompatibleDC", "uint", hdc2)
        hbm := DllCall("gdi32.dll\CreateCompatibleBitmap", UInt,hdc2 , Int,Width, Int,Height)
        obm := DllCall( "gdi32.dll\SelectObject", UInt,hdc, UInt,hbm)
        PrintWindow(SrcHwnd, hdc)
        pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
        sel_obj := SelectObject(hdc, obm)
        DeleteObject(obm), 
        DeleteObject(hbm), 
        DeleteDC(hdc),
        DeleteDC(hdc2),
        DeleteObject(sel_obj)
    }
    pBitmap := Gdip_ResizepBitmap(pBitmap, Width, Height, DstWidth, DstHeight,Bord)
return pBitmap
}

Gdip_ResizepBitmap(pBitmap,SrcW,SrcH,DstW,DstH,Bord:=0)
{
    nwpBitmap := Gdip_CreateBitmap(DstW,DstH)
    nwpGraphics := Gdip_GraphicsFromImage(nwpBitmap)
    Gdip_DrawImage(nwpGraphics, pBitmap, 0, 0, DstW, DstH, Bord, Bord, SrcW, SrcH)
    Gdip_DeleteGraphics(nwpGraphics)
    Gdip_DisposeImage(pBitmap)

return nwpBitmap
}

AHK_NOTIFYICON(wParam, lParam)
{
    if (lParam = 0x203) { ; user double left-clicked tray icon
        Reload
    }
}

ConvertToBGRfromRGB(RGB) { ; Get numeric BGR value from numeric RGB value or HTML color name
    ; HEX values
    BGR := SubStr(RGB, -1, 2) SubStr(RGB, 1, 4) 
Return BGR 
}

SetAcrylicGlassEffect(thisColor, thisAlpha, hWindow) {
    ; based on https://github.com/jNizM/AHK_TaskBar_SetAttr/blob/master/scr/TaskBar_SetAttr.ahk
    ; by jNizM
    initialAlpha := thisAlpha
    If (thisAlpha<16)
        thisAlpha := 16
    Else If (thisAlpha>245)
        thisAlpha := 245

    thisColor := ConvertToBGRfromRGB(thisColor)
    thisAlpha := Format("{1:#x}", thisAlpha)
    gradient_color := thisAlpha . thisColor

    Static init, accent_state := 4, ver := DllCall("GetVersion") & 0xff < 10
    Static pad := A_PtrSize = 8 ? 4 : 0, WCA_ACCENT_POLICY := 19
    accent_size := VarSetCapacity(ACCENT_POLICY, 16, 0)
    NumPut(accent_state, ACCENT_POLICY, 0, "int")

    If (RegExMatch(gradient_color, "0x[[:xdigit:]]{8}"))
        NumPut(gradient_color, ACCENT_POLICY, 8, "int")

    VarSetCapacity(WINCOMPATTRDATA, 4 + pad + A_PtrSize + 4 + pad, 0)
    && NumPut(WCA_ACCENT_POLICY, WINCOMPATTRDATA, 0, "int")
    && NumPut(&ACCENT_POLICY, WINCOMPATTRDATA, 4 + pad, "ptr")
    && NumPut(accent_size, WINCOMPATTRDATA, 4 + pad + A_PtrSize, "uint")
    If !(DllCall("user32\SetWindowCompositionAttribute", "ptr", hWindow, "ptr", &WINCOMPATTRDATA))
        Return 0 
    thisOpacity := (initialAlpha<16) ? 60 + initialAlpha*9 : 250
    WinSet, Transparent, %thisOpacity%, ahk_id %hWindow%
Return 1
}

getAccentColor(){
    f := A_FormatInteger
    SetFormat, Integer, Hex
    RegRead, BgCol, HKEY_CURRENT_USER, Software\Microsoft\Windows\DWM, AccentColor
    BgCol:=StrReplace(BgCol, "0x", "")
    BgCol:=SubStr(BgCol,3,6)
    BgCol:=SubStr(BgCol,5,2) . SubStr(BgCol,3,2) . SubStr(BgCol,1,2)
    SetFormat, Integer, %f%

    ;Gui, Color, c%BgCol%
    ;Gui, Show, w100 h100
return BgCol
}

getIconForExe(winid, icon_size=32, useHIcon=0){
    global makeTranslucent
    global exeIcons
    WinGet FileName, ProcessPath, % "ahk_id " winid
    if(exeIcons.HasKey(FileName))
    {
        return exeIcons[FileName]
    }
    iconPath := 0
    if(icon_size==32) {
        ptr := A_PtrSize =8 ? "ptr" : "uint" ;for AHK Basic
        hIcon := DllCall("Shell32\ExtractAssociatedIcon" (A_IsUnicode ? "W" : "A"), ptr, DllCall("GetModuleHandle", ptr, 0, ptr), str, FileName, "ushort*", lpiIcon, ptr) ;only supports 32x32
    } else {
        SHIL := {LARGE: 0x00, SMALL: 0x01, EXTRALARGE: 0x02, SYSSMALL: 0x03, JUMBO: 0x04}
        Icon := GetSysImgLstIcon(FileName, "JUMBO")
        hIcon := Icon.HICON
        SplitPath, FileName, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
        iconsDir:=A_ScriptDir . "/icons"
        if(!FileExist(iconsDir))
            FileCreateDir, %iconsDir%
        iconPath := iconsDir . "/" . OutNameNoExt . ".ico"
        if(!FileExist(iconPath))
            SaveHICONtoFile( hicon, iconPath)
    }
    if(!useHIcon){
        if(iconPath)
            pBitmapI := Gdip_CreateBitmapFromFile(iconPath)
        else
            pBitmapI :=Gdip_CreateBitmapFromHICON(hIcon)
        icon_size:=icon_size*(A_ScreenDPI/96)
        w1 := Gdip_GetImageWidth(pBitmapI), h1 := Gdip_GetImageHeight(pBitmapI)
        pBitmapI := Gdip_ResizepBitmap(pBitmapI, w1, h1, icon_size, icon_size, 0)
        hBitmapI := Gdip_CreateHBITMAPFromBitmap(pBitmapI)
        Gdip_DisposeImage(pBitmapI)
        exeIcons[FileName]:=hBitmapI
    }
    else
    {
        exeIcons[FileName]:=hIcon
    }
return exeIcons[FileName]
}

SaveHICONtoFile( hicon, iconFile ) { ; By SKAN | 06-Sep-2017 | goo.gl/8NqmgJ
    Static CI_FLAGS:=0x2008 ; LR_CREATEDIBSECTION | LR_COPYDELETEORG
    Local File, Var, mDC, sizeofRGBQUAD, ICONINFO:=[], BITMAP:=[], BITMAPINFOHEADER:=[]

    File := FileOpen( iconFile,"rw" )
    If ( ! IsObject(File) )
        Return 0
    Else File.Length := 0 ; Delete (any existing) file contents                                                   

    VarSetCapacity(Var,32,0) ; ICONINFO Structure
    If ! DllCall( "GetIconInfo", "Ptr",hicon, "Ptr",&Var )
        Return ( File.Close() >> 64 )

    ICONINFO.fIcon := NumGet(Var, 0,"UInt")
    ICONINFO.xHotspot := NumGet(Var, 4,"UInt")
    ICONINFO.yHotspot := NumGet(Var, 8,"UInt")
    ICONINFO.hbmMask := NumGet(Var, A_PtrSize=8 ? 16:12, "UPtr")
    ICONINFO.hbmMask := DllCall( "CopyImage" ; Create a DIBSECTION for hbmMask
        , "Ptr",ICONINFO.hbmMask 
        , "UInt",0 ; IMAGE_BITMAP
    , "Int",0, "Int",0, "UInt",CI_FLAGS, "Ptr" ) 
    ICONINFO.hbmColor := NumGet(Var, A_PtrSize=8 ? 24:16, "UPtr") 
    ICONINFO.hbmColor := DllCall( "CopyImage" ; Create a DIBSECTION for hbmColor
        , "Ptr",ICONINFO.hbmColor
        , "UInt",0 ; IMAGE_BITMAP
    , "Int",0, "Int",0, "UInt",CI_FLAGS, "Ptr" ) 

    VarSetCapacity(Var,A_PtrSize=8 ? 104:84,0) ; DIBSECTION of hbmColor
    DllCall( "GetObject", "Ptr",ICONINFO.hbmColor, "Int",A_PtrSize=8 ? 104:84, "Ptr",&Var )

    BITMAP.bmType := NumGet(Var, 0,"UInt") 
    BITMAP.bmWidth := NumGet(Var, 4,"UInt")
    BITMAP.bmHeight := NumGet(Var, 8,"UInt")
    BITMAP.bmWidthBytes := NumGet(Var,12,"UInt")
    BITMAP.bmPlanes := NumGet(Var,16,"UShort")
    BITMAP.bmBitsPixel := NumGet(Var,18,"UShort")
    BITMAP.bmBits := NumGet(Var,A_PtrSize=8 ? 24:20,"Ptr")

    BITMAPINFOHEADER.biClrUsed := NumGet(Var,32+(A_PtrSize=8 ? 32:24),"UInt")

    File.WriteUINT(0x00010000) ; ICONDIR.idReserved and ICONDIR.idType 
    File.WriteUSHORT(1) ; ICONDIR.idCount (No. of images)
    File.WriteUCHAR(BITMAP.bmWidth < 256 ? BITMAP.bmWidth : 0) ; ICONDIRENTRY.bWidth
    File.WriteUCHAR(BITMAP.bmHeight < 256 ? BITMAP.bmHeight : 0) ; ICONDIRENTRY.bHeight 
    File.WriteUCHAR(BITMAPINFOHEADER.biClrUsed < 256 ; ICONDIRENTRY.bColorCount
    ? BITMAPINFOHEADER.biClrUsed : 0)
    File.WriteUCHAR(0) ; ICONDIRENTRY.bReserved
    File.WriteUShort(BITMAP.bmPlanes) ; ICONDIRENTRY.wPlanes
    File.WriteUSHORT(BITMAP.bmBitsPixel) ; ICONDIRENTRY.wBitCount
    File.WriteUINT(0) ; ICONDIRENTRY.dwBytesInRes (filled later) 
    File.WriteUINT(22) ; ICONDIRENTRY.dwImageOffset  

    NumPut( BITMAP.bmHeight*2, Var, 8+(A_PtrSize=8 ? 32:24),"UInt") ; BITMAPINFOHEADER.biHeight should be 
    ; modified to double the BITMAP.bmHeight  

    File.RawWrite( &Var + (A_PtrSize=8 ? 32:24), 40) ; Writing BITMAPINFOHEADER (40  bytes)               

    If ( BITMAP.bmBitsPixel <= 8 ) ; Bitmap uses a Color table!
    {
        mDC := DllCall( "CreateCompatibleDC", "Ptr",0, "Ptr" ) 
        DllCall( "SaveDC", "Ptr",mDC )
        DllCall( "SelectObject", "Ptr",mDC, "Ptr",ICONINFO.hbmColor )
        sizeofRGBQUAD := ( BITMAPINFOHEADER.biClrUsed * 4 ) ; Colors used x UINT (0x00bbggrr)
        VarSetCapacity( Var,sizeofRGBQUAD,0 ) ; Array of RGBQUAD structures 
        DllCall( "GetDIBColorTable", "Ptr",mDC, "UInt",0, "UInt",BITMAPINFOHEADER.biClrUsed, "Ptr",&Var )
        DllCall( "RestoreDC", "Ptr",mDC, "Int",-1 )
        DllCall( "DeleteDC", "Ptr",mDC )
        File.RawWrite(Var, sizeofRGBQUAD) ; Writing Color table 
    }

    File.RawWrite(BITMAP.bmBits, BITMAP.bmWidthBytes*BITMAP.bmHeight) ; Writing BITMAP bits (hbmColor)

    VarSetCapacity(Var,A_PtrSize=8 ? 104:84,0) ; DIBSECTION of hbmMask
    DllCall( "GetObject", "Ptr",ICONINFO.hbmMask, "Int",A_PtrSize=8 ? 104:84, "Ptr",&Var )

    BITMAP := []
    BITMAP.bmHeight := NumGet(Var, 8,"UInt")
    BITMAP.bmWidthBytes := NumGet(Var,12,"UInt")
    BITMAP.bmBits := NumGet(Var,A_PtrSize=8 ? 24:20,"Ptr")

    File.RawWrite(BITMAP.bmBits, BITMAP.bmWidthBytes*BITMAP.bmHeight) ; Writing BITMAP bits (hbmMask)
    File.Seek(14,0) ; Seeking ICONDIRENTRY.dwBytesInRes
    File.WriteUINT(File.Length()-22) ; Updating ICONDIRENTRY.dwBytesInRes
    File.Close()
    DllCall( "DeleteObject", "Ptr",ICONINFO.hbmMask ) 
    DllCall( "DeleteObject", "Ptr",ICONINFO.hbmColor )
Return True 
}

;###############################################

GetTitleMatch(){
    global wsShortTitle
    global SearchText
    global IdList

    h:={}
    for k, v in IdList
    {
        h[v]:=1
    }
    TitleList:=""
    ExactMatches:=[]
    for k, v in wsShortTitle
    {
        if(h.HasKey(k))
        {
            TitleList:=TitleList . v . "`n"
            if(RegExMatch(v, "i)" . SearchText))
                ExactMatches.Push(v)
        }
    }
    if(ExactMatches._MaxIndex()==0)
    {
        sort, TitleList, F SortByLetterPosition
        Loop,Parse,TitleList,`n,`r
        {
            title:=Trim(A_LoopField)
            break
        }
    }
    else
    {
        if(ExactMatches._MaxIndex()==1)
        {
            title:=ExactMatches[1]
        }
        else
        {
            TitleList:=""
            for k, v in ExactMatches
            {
                TitleList:=TitleList . v . "`n"
            }
            sort, TitleList, F SortByLetterPosition
            Loop,Parse,TitleList,`n,`r
            {
                title:=Trim(A_LoopField)
                break
            }
        }
    }
    for k, v in wsShortTitle
    {
        if(v=title)
        {
            for i, v in IdList
            {
                if(k=v)
                {
                    return i
                }
            }
        }
    }
return 1
}

SortByLetterPosition(a1, a2){
    global SearchText
    a1n:=StringDifference(SearchText, a1, 200)
    a2n:=StringDifference(SearchText, a2, 200)
return a1n > a2n ? 1 : a1n < a2n ? -1 : 0
}

StringDifference(string1, string2, maxOffset=1) { ;returns a float: between "0.0 = identical" and "1.0 = nothing in common" 
    If (string1 = string2) 
        Return (string1 == string2 ? 0/1 : 0.2/StrLen(string1)) ;either identical or (assumption:) "only one" char with different case 
    If (string1 = "" OR string2 = "") 
        Return (string1 = string2 ? 0/1 : 1/1) 
    StringSplit, n, string1 
    StringSplit, m, string2 
    ni := 1, mi := 1, lcs := 0 
    While((ni <= n0) AND (mi <= m0)) { 
        If (n%ni% == m%mi%) 
            EnvAdd, lcs, 1 
        Else If (n%ni% = m%mi%) 
            EnvAdd, lcs, 0.8 
        Else{ 
            Loop, %maxOffset% { 
                oi := ni + A_Index, pi := mi + A_Index 
                If ((n%oi% = m%mi%) AND (oi <= n0)){ 
                    ni := oi, lcs += (n%oi% == m%mi% ? 1 : 0.8) 
                    Break 
                } 
                If ((n%ni% = m%pi%) AND (pi <= m0)){ 
                    mi := pi, lcs += (n%ni% == m%pi% ? 1 : 0.8) 
                    Break 
                } 
            } 
        } 
        EnvAdd, ni, 1 
        EnvAdd, mi, 1 
    } 
Return ((n0 + m0)/2 - lcs) / (n0 > m0 ? n0 : m0) 
}

GetProcessCurrentDirectory(PID) {
    static PROCESS_QUERY_INFORMATION := 0x400, PROCESS_VM_READ := 0x10, STATUS_SUCCESS := 0

    hProc := DllCall("OpenProcess", UInt, PROCESS_QUERY_INFORMATION|PROCESS_VM_READ, Int, 0, UInt, PID, Ptr)
    (A_Is64bitOS && DllCall("IsWow64Process", Ptr, hProc, UIntP, IsWow64))
    if (!A_Is64bitOS || IsWow64)
        PtrSize := 4, PtrType := "UInt", pPtr := "UIntP"
    else
        PtrSize := 8, PtrType := "Int64", pPtr := "Int64P"
    offsetCURDIR := 4*4 + PtrSize*5

    hModule := DllCall("GetModuleHandle", "str", "Ntdll", Ptr)
    if (A_PtrSize < PtrSize) { ; <<—— script 32, target process 64
        if !QueryInformationProcess := DllCall("GetProcAddress", Ptr, hModule, AStr, "NtWow64QueryInformationProcess64", Ptr)
            failed := "NtWow64QueryInformationProcess64"
        if !ReadProcessMemory := DllCall("GetProcAddress", Ptr, hModule, AStr, "NtWow64ReadVirtualMemory64", Ptr)
            failed := "NtWow64ReadVirtualMemory64"
        info := 0, szPBI := 48, offsetPEB := 8
    }
    else {
        if !QueryInformationProcess := DllCall("GetProcAddress", Ptr, hModule, AStr, "NtQueryInformationProcess", Ptr)
            failed := "NtQueryInformationProcess"
        ReadProcessMemory := "ReadProcessMemory"
        if (A_PtrSize > PtrSize) ; <<—— script 64, target process 32
            info := 26, szPBI := 8, offsetPEB := 0
        else ; <<—— script and target process have the same bitness
            info := 0, szPBI := PtrSize * 6, offsetPEB := PtrSize
    }
    if failed {
        DllCall("CloseHandle", Ptr, hProc)
        MsgBox, Failed to get pointer to %failed%
        Return
    }
    VarSetCapacity(PBI, 48, 0)
    if DllCall(QueryInformationProcess, Ptr, hProc, UInt, info, Ptr, &PBI, UInt, szPBI, UIntP, bytes) != STATUS_SUCCESS {
        DllCall("CloseHandle", Ptr, hProc)
        Return
    }
    pPEB := NumGet(&PBI + offsetPEB, PtrType)
    DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pPEB + PtrSize * 4, pPtr, pRUPP, PtrType, PtrSize, UIntP, bytes)
    DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pRUPP + offsetCURDIR, UShortP, szBuff, PtrType, 2, UIntP, bytes)
    DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pRUPP + offsetCURDIR + PtrSize, pPtr, pCURDIR, PtrType, PtrSize, UIntP, bytes)

    VarSetCapacity(buff, szBuff, 0)
    DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pCURDIR, Ptr, &buff, PtrType, szBuff, UIntP, bytes)
    DllCall("CloseHandle", Ptr, hProc)
Return currentDirPath := StrGet(&buff, "UTF-16")
}