; NOTE: Calling the AltTab_window_list() function makes an array of window IDs:
; AltTab_ID_List_0 = the number of windows found
; AltTab_ID_List_1 to AltTab_ID_List_%AltTab_ID_List_0% contain the window IDs.

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.



AltTab_window_list()


;----------GUI Buttons---------------
Gui, Add, Button,x5 y10 w50 gRefresh_List, Refresh
Gui, Add, Button,x65 y10 w30 gBHide, Hide
Gui, Add, Button, x100 y10 gBShow, Show

;-----List of Apps-----
Gui, Add, ListView, r20 x5 w500 Grid Checked, #|ID|Title


Loop, %AltTab_ID_List_0% ; this loop won't work in a fucntion...
{
  WinGetTitle, title, % "ahk_id " AltTab_ID_List_%A_Index%
  LV_Add("", A_Index, AltTab_ID_List_%A_Index%, title)
}

LV_ModifyCol()  ; Auto-size each column to fit its contents.

List_Count := LV_GetCount() ;getting the list count
Gui, Show

WinGet, app_id, ID, A ;Getting the App ID in order to use hotkey to hide/show

return

GuiClose:
Exitapp


;-----HotKeys------
^9::
	;if 	
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
	return

BHide: 
    RowNumber = 0 
    Loop, %AltTab_ID_List_0% 
	{
	    RowNumber := LV_GetNext(RowNumber,"Checked") ; must use "Checked" in order to find which one is checked
	    if not RowNumber 
		break
	    LV_GetText(WindowID,RowNumber, 2)
		WinHide, ahk_id %WindowID% ;WinHide only works on ahk_id..?
	}
    return


Refresh_list:
	gosub BShow
	
    LV_Delete()
    AltTab_window_list()
	
	Loop, %AltTab_ID_List_0% ; this loop won't work in a fucntion...
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
    If(wid_Title == "Settings" or wid_Title == "Store" or wid_Title == "Windows Shell Experience Host" or wid_Title == "Calculator")
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