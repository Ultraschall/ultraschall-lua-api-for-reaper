--[[
################################################################################
# 
# Copyright (c) 2023-present Meo-Ada Mespotine mespotine.de
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# 
################################################################################
]] 

dofile(reaper.GetResourcePath().."/UserPlugins/reagirl.lua")

reagirl.Settings_Override=true
dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

function toboolean(value, default)
    -- converts a value to boolean, or returns nil, if not convertible
    if type(value)=="boolean" then return value end
    if value=="" then return default end
    if value==nil then return end
    local value=value:lower()
    local truth=value:match("^\t*%s*()true\t*%s*$")
    local falseness=value:match("^\t*%s*()false\t*%s*$")
    
    if tonumber(truth)==nil and tonumber(falseness)~=nil then
      return false
    elseif tonumber(truth)~=nil and tonumber(falseness)==nil then
      return true
    end
end

testtext=""

function Image(element_id, filename, drag_destination)
  if drag_destination==tab1.image_dest then
    reaper.MB("Successfully dragged", "Dragged", 0)
  end
--  print2("")
end

function Label(A,B,C)
  print2(A,B,C)
end

function button_apply_and_close()
  reaper.SetExtState("ReaGirl", "show_tooltips", tostring(reagirl.Checkbox_GetCheckState(tab1.checkbox_tooltips_id)), true)
  reaper.SetExtState("ReaGirl", "osara_override", tostring(reagirl.Checkbox_GetCheckState(tabs2.checkbox_osara_id)), true)
  reaper.SetExtState("ReaGirl", "osara_debug", tostring(reagirl.Checkbox_GetCheckState(tabs2.checkbox_osara_debug_id)), true)
  reaper.SetExtState("ReaGirl", "osara_move_mouse", tostring(reagirl.Checkbox_GetCheckState(tabs2.checkbox_osara_move_mouse_id)), true)
  reaper.SetExtState("ReaGirl", "highlight_drag_destinations", tostring(reagirl.Checkbox_GetCheckState(tabs2.checkbox_osara_hover_mouse_id)), true)
  reaper.SetExtState("ReaGirl", "osara_hover_mouse", tostring(reagirl.Checkbox_GetCheckState(tab1.checkbox_highlight_drag_destinations)), true)
  reaper.SetExtState("ReaGirl", "osara_enable_accmessage", tostring(reagirl.Checkbox_GetCheckState(tabs2.checkbox_osara_enable_acc_help)), true)

reaper.GetExtState("ReaGirl", "osara_enable_accmessage")

  if reagirl.Slider_GetValue(tab1.slider_blink_every)==1 then val="" else val=math.floor(reagirl.Slider_GetValue(tab1.slider_blink_every)*33) end
  reaper.SetExtState("ReaGirl", "FocusRectangle_BlinkSpeed", val, true)
  if reagirl.Slider_GetValue(tab1.slider_blink_for)==0 then val="" else val=math.floor(reagirl.Slider_GetValue(tab1.slider_blink_for)) end
  reaper.SetExtState("ReaGirl", "FocusRectangle_BlinkTime", val, true)
  if reagirl.Slider_GetValue(tab1.slider_blink_every_cursor)==1 then val="" else val=math.floor(reagirl.Slider_GetValue(tab1.slider_blink_every_cursor)*33) end
  reaper.SetExtState("ReaGirl", "Inputbox_BlinkSpeed", val, true)
  if reagirl.Slider_GetValue(tab1.slider_scale)==0 then val="" else val=math.floor(reagirl.Slider_GetValue(tab1.slider_scale)) end
  reaper.SetExtState("ReaGirl", "scaling_override", val, true)
  if reagirl.Slider_GetValue(tab1.slider_blink_every_draggable)==0 then val="" else val=math.floor(reagirl.Slider_GetValue(tab1.slider_blink_every_draggable)*33) end
  reaper.SetExtState("ReaGirl", "highlight_drag_destination_blink", val, true)
  reagirl.Gui_Close()
end

function button_cancel()
  reagirl.Gui_Close()
end

function huch() end

function SetUpNewGui()
  reagirl.Gui_New()
  
  if tabnumber==nil then tabnumber=1 end
  Tabs=reagirl.Tabs_Add(10, 10, 335, 390, "Settings", "General Settings.", {"General", "Accessibility"}, tabnumber, nil)
  
  tab1={}
  --[[ Blinking Focus Rectangle ]]
  tab1.Label_General=reagirl.Label_Add(nil, nil, "General", "General settings.", false, nil)
  reagirl.Label_SetStyle(tab1.Label_General, 6, 0, 0)
  --reagirl.UI_Element_GetSet_ContextMenu(tab1.Label_General, true, "Tudel|Loo", huch)

  reagirl.NextLine()
  show_tooltips = reaper.GetExtState("ReaGirl", "show_tooltips")
  if show_tooltips=="" or show_tooltips=="true" then show_tooltips=true else show_tooltips=false end
  tab1.checkbox_tooltips_id = reagirl.Checkbox_Add(nil, nil, "Show tooltips when hovering above ui-element", "When checked, ReaGirl will show tooltips when hovering above ui-elements.", show_tooltips, checkbox)
  
  reagirl.NextLine(10)
  tab1.Label_FocusRectangle=reagirl.Label_Add(nil, nil, "Focus Rectangle", "Settings for the focus rectangle.", false, nil)
  reagirl.Label_SetStyle(tab1.Label_FocusRectangle, 6, 0, 0)
  
  reagirl.NextLine()
  val=tonumber(reaper.GetExtState("ReaGirl", "FocusRectangle_BlinkSpeed"))
  if val==nil then val=33 end
  
  val2=tonumber(reaper.GetExtState("ReaGirl", "FocusRectangle_BlinkTime"))
  if val2==nil then val2=0 end
  
  tab1.slider_blink_every = reagirl.Slider_Add(nil, nil, 300, "Blink every", 100, "Set the speed of the blinking of the focus rectangle.", "seconds", 0.4, 3, 0.1, val/33, 1, BlinkSpeed)
  reagirl.NextLine(-4)
  tab1.slider_blink_for = reagirl.Slider_Add(nil, nil, 300, "Blink for", 100, "Set the duration of the blinking of the focus rectangle.", "seconds", 0, 10, 1, val2, 0, BlinkTime)
  
  
  -- [[ Blinking Inputbox-Cursor ]]
  reagirl.NextLine(15)
  tab1.Label_InputBox=reagirl.Label_Add(nil, nil, "Inputbox-Cursor", "Settings for the inputbox-cursor.", false, nil)
  reagirl.Label_SetStyle(tab1.Label_InputBox, 6, 0, 0)
  reagirl.NextLine()
  val3=tonumber(reaper.GetExtState("ReaGirl", "Inputbox_BlinkSpeed"))
  if val3==nil then val3=33 end
  tab1.slider_blink_every_cursor=reagirl.Slider_Add(nil, nil, 300, "Blink every", 100, "Set the speed of the blinking of the cursor.", "seconds", 0.4, 5, 0.1, val3/33, 1, CursorBlinkSpeed)
  reagirl.NextLine()
  tab1.input_id = reagirl.Inputbox_Add(nil, nil, 290, "Test input:", 100, "Input text to check cursor blinking speed.", testtext, nil, nil)
  reagirl.Inputbox_SetEmptyText(tab1.input_id, "Test blink-speed here...")
  
  -- [[ Scaling Override ]]
  reagirl.NextLine(15)
  tab1.Label_Scaling=reagirl.Label_Add(nil, nil, "Scaling", "Settings for the scaling-factor of ReaGirl-Guis.", false, nil)
  reagirl.Label_SetStyle(tab1.Label_Scaling, 6, 0, 0)
  reagirl.NextLine()
  scaling_override=tonumber(reaper.GetExtState("ReaGirl", "scaling_override", value, true))
  if scaling_override==nil then scaling_override2=0 else scaling_override2=scaling_override end
  tab1.slider_scale = reagirl.Slider_Add(nil, nil, 305, "Scale Override", 100, "Set the default scaling-factor for all ReaGirl-Gui-windows; 0, scaling depends automatically on the scaling-factor in the prefs or the presence of Retina/HiDPI.", nil, 0, 8, 1, scaling_override2, 0, ScaleOverride)
  reagirl.NextLine(15)
  
  -- [[ Blinking Drag-Destinations ]]
  reagirl.NextLine(15)
  tab1.Label_Draggable_UI_Elements=reagirl.Label_Add(nil, nil, "Draggable UI-elements", "Settings for draggable ui-elements.", false, nil)
  reagirl.Label_SetStyle(tab1.Label_Draggable_UI_Elements, 6, 0, 0)
  reagirl.NextLine()
  highlight_drag_destinations = reaper.GetExtState("ReaGirl", "highlight_drag_destinations")
  if highlight_drag_destinations=="" or highlight_drag_destinations=="true" then highlight_drag_destinations=true else highlight_drag_destinations=false end
  tab1.checkbox_highlight_drag_destinations = reagirl.Checkbox_Add(nil, nil, "Highlight drag-destinations", "When checked, ReaGirl will highlight the ui-elements, where you can drag a draggable ui-element to, like Images for instance.", highlight_drag_destinations, checkbox)
  reagirl.NextLine()
  drag_blinking=tonumber(reaper.GetExtState("ReaGirl", "highlight_drag_destination_blink"))
  if drag_blinking==nil then drag_blinking=0 end
  tab1.slider_blink_every_draggable=reagirl.Slider_Add(nil, nil, 300, "Blink every", 100, "Set the speed of the blinking of the drag-destinations; 0=no blinking.", "seconds", 0, 5, 0.1, drag_blinking/33, 0, DragBlinkSpeed)
  reagirl.NextLine()
  tab1.image_source=reagirl.Image_Add(50,nil,50,50,reaper.GetResourcePath().."/Data/track_icons/double_bass.png", "The source-image, an image of a double bass.", "Drag this double bass to the microphone.", Image)
  tab1.image_middle=reagirl.Image_Add(160,nil,25,25,reaper.GetResourcePath().."/Data/track_icons/folder_right.png", "Graphics with an arrow pointing to the drag-destination of the double bass.", "Graphics with an arrow pointing to the drag-destination of the double bass.",nil)
  tab1.image_dest=reagirl.Image_Add(250,nil,50,50,reaper.GetResourcePath().."/Data/track_icons/mic_dynamic_1.png", "The destination image, an image of a microphone.", "The destination image, drag the double bass over here.",nil)
  reagirl.Image_SetDraggable(tab1.image_source, true, {tab1.image_dest})
  --reagirl.UI_Element_GetSet_ContextMenu(tab1.image_source, true, "Tudel|Loo", huch)
  --reagirl.NextLine()
  --tab1.ddm = reagirl.DropDownMenu_Add(nil,nil,300,"TUdelu", nil, "Test menu.", {"One", "Two", "Three"}, 1, nil)
  --reagirl.Label_SetDraggable(tab1.Label_General, true, {tab1.image_dest})
  
  reagirl.Tabs_SetUIElementsForTab(Tabs, 1, tab1)
  
  -- [[ Osara override ]]
  tabs2={}
  reagirl.AutoPosition_SetNextYToUIElement(Tabs)
  reagirl.NextLine()
  tabs2.Label_Osara=reagirl.Label_Add(nil, nil, "General settings", "Settings that influence accessibility.", false, nil)
  reagirl.NextLine()
  reagirl.Label_SetStyle(tabs2.Label_Osara, 6, 0, 0)

  osara_override=reaper.GetExtState("ReaGirl", "osara_override")
  if osara_override=="true" or osara_override=="" then osara_override=true else osara_override=false end
  tabs2.checkbox_osara_id = reagirl.Checkbox_Add(nil, nil, "Enable screen reader support(requires OSARA)", "Checking this will provide feedback to screen readers as you navigate. Feedback is delivered through OSARA so please make sure you have that installed.", osara_override, checkbox)
  
  --reagirl.UI_Element_GetSet_ContextMenu(tabs2.checkbox_osara_id, true, "Hudel|Dudel", print)
  
  reagirl.NextLine()
  osara_debug=reaper.GetExtState("ReaGirl", "osara_debug")
  if osara_debug=="false" or osara_debug=="" then osara_debug=false else osara_debug=true end
  tabs2.checkbox_osara_debug_id = reagirl.Checkbox_Add(nil, nil, "Show screen reader messages in console(debug)", "Checking this will show the screen reader messages in the console for debugging purposes.", osara_debug, checkbox)
  
  reagirl.NextLine()
  osara_move_mouse = reaper.GetExtState("ReaGirl", "osara_move_mouse")
  if osara_move_mouse=="" or osara_move_mouse=="true" then osara_move_mouse=true else osara_move_mouse=false end
  tabs2.checkbox_osara_move_mouse_id = reagirl.Checkbox_Add(nil, nil, "Move mouse when tabbing ui-elements", "Uncheck to prevent moving of the mouse when tabbing through ui-elements. Unchecking will make right-clicking for context menus more difficult, though.", osara_move_mouse, checkbox)
  
  reagirl.NextLine()
  osara_hover_mouse = reaper.GetExtState("ReaGirl", "osara_hover_mouse")
  if osara_hover_mouse=="" or osara_hover_mouse=="true" then osara_hover_mouse=true else osara_hover_mouse=false end
  tabs2.checkbox_osara_hover_mouse_id = reagirl.Checkbox_Add(nil, nil, "Report hovered ui-elements", "When checked, ReaGirl will report ui-elements the mouse is hovering above to the screen reader. Uncheck to prevent that.", osara_hover_mouse, checkbox)
  
  reagirl.NextLine()
  osara_enable_accmessage = reaper.GetExtState("ReaGirl", "osara_enable_accmessage")
  if osara_enable_accmessage=="" or osara_enable_accmessage=="true" then osara_enable_accmessage=true else osara_enable_accmessage=false end
  tabs2.checkbox_osara_enable_acc_help = reagirl.Checkbox_Add(nil, nil, "Enable screen reader help-messages for ui-elements.", "When checked, a short description on how to use a tabbed ui-element will be send to the screen reader as well. Uncheck to turn off the help-messages.", osara_enable_accmessage, checkbox)

  reagirl.Tabs_SetUIElementsForTab(Tabs, 2, tabs2)
  
  button_apply_and_close_id = reagirl.Button_Add(-180, 435, 0, 0, "Apply and Close", "Apply the chosen settings and close window.", button_apply_and_close)
  button_cancel_id = reagirl.Button_Add(-65, 435, 0, 0, "Cancel", "Simply close without applying the settings.", button_cancel)
end

SetUpNewGui()

color=40
reagirl.Background_GetSetColor(true,color,color,color)

reagirl.Gui_Open("ReaGirl_Settings", true, "ReaGirl Settings (Reagirl v"..reagirl.GetVersion()..")", "various settings for ReaGirl-Accessible Guis.", 355, 465, nil, nil, nil)

function CheckIfSettingChanged()
  if osara_debug~=toboolean(reaper.GetExtState("ReaGirl", "osara_debug"), false) then 
    osara_debug=toboolean(reaper.GetExtState("ReaGirl", "osara_debug"), false)
    return true, 1
  elseif osara_override~=toboolean(reaper.GetExtState("ReaGirl", "osara_override"), true) then
    osara_override=toboolean(reaper.GetExtState("ReaGirl", "osara_override", true))
    return true, 2 
  elseif scaling_override~=tonumber(reaper.GetExtState("ReaGirl", "scaling_override")) then
    if tonumber(reaper.GetExtState("ReaGirl", "scaling_override"))==nil and scaling_override~=0 then
      scaling_override=tonumber(reaper.GetExtState("ReaGirl", "scaling_override"))
      if scaling_override==nil then scaling_override=0 end
      return true, 3
    else
      return false
    end
  elseif osara_move_mouse~=toboolean(reaper.GetExtState("ReaGirl", "osara_move_mouse"), true) then
    return true, 4
  elseif osara_hover_mouse~=toboolean(reaper.GetExtState("ReaGirl", "osara_hover_mouse"), true) then
    return true, 5
  elseif show_tooltips~=toboolean(reaper.GetExtState("ReaGirl", "show_tooltips"), true) then
    return true, 6
  elseif osara_enable_accmessage~=toboolean(reaper.GetExtState("ReaGirl", "osara_enable_accmessage"), true) then
    return true, 7
  else
    return false
  end
end

function main()
  B,B1,B2=CheckIfSettingChanged()
  if B==true then A=reaper.time_precise() testtext=reagirl.Inputbox_GetText(tab1.input_id) i=reagirl.Elements.FocusedElement if i==nil then i=1 end tabnumber=reagirl.Tabs_GetSelected(Tabs) SetUpNewGui() reagirl.Elements.FocusedElement=i end
  reagirl.Gui_Manage()
  if B==true then
    reagirl.Elements.FocusedElement=i
    reagirl.Gui_ForceRefresh()
  end
  if reagirl.Gui_IsOpen()==true then reaper.defer(main) end
end
main()
--reaper.ShowConsoleMsg("Tudelu")
