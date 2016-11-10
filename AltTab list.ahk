; NOTE: Calling the AltTab_window_list() function makes an array of window IDs:
; AltTab_ID_List_0 = the number of windows found
; AltTab_ID_List_1 to AltTab_ID_List_%AltTab_ID_List_0% contain the window IDs.

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#InstallKeybdHook



AltTab_window_list()


;----------GUI Buttons---------------
Gui, Add, Button,x5 y10 w50 gRefresh_List, Refresh
Gui, Add, Button,x65 y10 w30 gBHide, Hide
Gui, Add, Button, x100 y10 gBShow, Show


Gui, Add, ListView, r20 x5 w500 Grid Checked, #|ID|Title; making list of apps


Loop, %AltTab_ID_List_0% ; this loop won't work in a fucntion...
{
  WinGetTitle, title, % "ahk_id " AltTab_ID_List_%A_Index%
  LV_Add("", A_Index, AltTab_ID_List_%A_Index%, title)
}

LV_ModifyCol()  ; Auto-size each column to fit its contents.

List_Count := LV_GetCount() ;getting the list count
App_status := 0 ; 0 - apps are shown.
				; 1 - apps are hidden.
Gui, Show

WinGet, app_id, ID, A ;Getting the App ID in order to use hotkey to hide/show script

MsgBox, Hide_Win is easy to use. `nCheck the windows that you want to hide, then press alt and ~ (Next to number 1) to hide it!`nJust press alt and ` again to show it again! `nTo hide the app, press ctrl and 9. To show the app, press ctrl and 9! 

return

GuiClose:
Exitapp 


;-----HotKeys------
^9::
	IfWinNotExist AltTab list.ahk
		WinShow, ahk_id %app_id%
	else 
		WinHide, ahk_id %app_id%
	return

!`::
	if (%App_status% == 0 ) 
		goto BHide	
	else
		goto BShow
	return
	
;-----Functions-----
	

BShow:
	Loop, %AltTab_ID_List_0% 
		{
			RowNumber := LV_GetNext(RowNumber,"Checked") ; must use "Checked" in order to find which one is checked
			if not RowNumber 
			break
			LV_GetText(WindowID,RowNumber, 2)
			WinShow, ahk_id %WindowID%
		}
		App_status := 0
	return

BHide: 
    RowNumber = 0 
    Loop, %AltTab_ID_List_0% 
	{
	    RowNumber := LV_GetNext(RowNumber,"Checked") ; must use "Checked" in order to find which one is checked
	    if not RowNumber 
		break
	    LV_GetText(WindowID,RowNumber, 2)
		WinHide, ahk_id %WindowID%
		;GroupAdd, hideWindow, ahk_id %WindowID% ; possible to addGrp here?
	}
	App_status := 1
    return


Refresh_list:

	gosub BShow
	
    LV_Delete()
    AltTab_window_list()
	
	Loop, %AltTab_ID_List_0% 
		{
			WinGetTitle, title, % "ahk_id " AltTab_ID_List_%A_Index%
			LV_Add("", A_Index, AltTab_ID_List_%A_Index%, title)
		}

	LV_ModifyCol()  ; Auto-size each column to fit its contents.
	
	
	return



AltTab_window_list()
{
  global
  WS_EX_CONTROLPARENT =0x10000
  WS_EX_APPWINDOW =0x40000
  WS_EX_TOOLWINDOW =0x80
  WS_DISABLED =0x8000000
  WS_POPUP =0x80000000
  AltTab_ID_List_ =0
  WinGet, Window_List, List ; Gather a list of running programs
  id_list =
  Loop, %Window_List%
    {
    wid := Window_List%A_Index%
    WinGetTitle, wid_Title, ahk_id %wid%
    WinGet, Style, Style, ahk_id %wid%

    If ((Style & WS_DISABLED) or ! (wid_Title)) ; skip unimportant windows ; ! wid_Title or 
        Continue
;--------Hiding Certain Apps From Showing---------
	If(IsInvisibleWin10BackgroundAppWindow(wid))
		Continue
;--------------------------------------------------
    WinGet, es, ExStyle, ahk_id %wid%
    Parent := Decimal_to_Hex( DllCall( "GetParent", "uint", wid ) )
    WinGetClass, Win_Class, ahk_id %wid%
    WinGet, Style_parent, Style, ahk_id %Parent%
    
    If ((es & WS_EX_TOOLWINDOW)
        or ((es & ws_ex_controlparent) and ! (Style & WS_POPUP) and !(Win_Class ="#32770") and ! (es & WS_EX_APPWINDOW)) ; pspad child window excluded
        or ((Style & WS_POPUP) and (Parent) and ((Style_parent & WS_DISABLED) =0))) ; notepad find window excluded ; note - some windows result in blank value so must test for zero instead of using NOT operator!
      continue
     AltTab_ID_List_ ++
     AltTab_ID_List_%AltTab_ID_List_% :=wid
    }
  AltTab_ID_List_0 := AltTab_ID_List_
}

Decimal_to_Hex(var)
{
  SetFormat, integer, hex
  var += 0
  SetFormat, integer, d
  return var 
}

IsInvisibleWin10BackgroundAppWindow(hWindow) ;To Identify app-windows (Containers for Windows Store Apps)
{
  result := 0
  VarSetCapacity(cloakedVal, A_PtrSize) ; DWMWA_CLOAKED := 14
  hr := DllCall("DwmApi\DwmGetWindowAttribute", "Ptr", hWindow, "UInt", 14, "Ptr", &cloakedVal, "UInt", A_PtrSize)
  if !hr ; returns S_OK (which is zero) on success. Otherwise, it returns an HRESULT error code
    result := NumGet(cloakedVal) ; omitting the "&" performs better
  return result ? true : false
  }
