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
end

function BlinkSpeed(slider_id, value)
  if value==0 then
    reaper.SetExtState("ReaGirl", "FocusRectangle_BlinkSpeed", "", true)
  else
    reaper.SetExtState("ReaGirl", "FocusRectangle_BlinkSpeed", math.floor(value*33), true)
  end
  reagirl.FocusRectangle_BlinkStartTime=reaper.time_precise()
end

function BlinkTime(slider_id, value)
  if value==0 then
    reaper.SetExtState("ReaGirl", "FocusRectangle_BlinkTime", "", true)
  else
    reaper.SetExtState("ReaGirl", "FocusRectangle_BlinkTime", value, true)
  end
  reagirl.FocusRectangle_BlinkStartTime=reaper.time_precise()
end

function DragBlinkSpeed(element_id, value)
  if value==0 then
    reaper.SetExtState("ReaGirl", "highlight_drag_destination_blink", "", true)
  else
    reaper.SetExtState("ReaGirl", "highlight_drag_destination_blink", value*33, true)
  end
end

function CursorBlinkSpeed(slider_id, value)
  if value==1 then
    reaper.SetExtState("ReaGirl", "Inputbox_BlinkSpeed", "", true)
  else
    reaper.SetExtState("ReaGirl", "Inputbox_BlinkSpeed", math.floor(value*33), true)
  end
  reagirl.FocusRectangle_BlinkStartTime=reaper.time_precise()
end

function button_apply(slider_id, value)
  value=reagirl.Slider_GetValue(tab1.slider_scale)
  if value==0 then value="" end
  reaper.SetExtState("ReaGirl", "scaling_override", value, true)
  scaling_override=value
end

function checkbox(checkbox_id, checkstate)
  override=true
  if checkbox_id==tabs2.checkbox_osara_id then
    reaper.SetExtState("ReaGirl", "osara_override", tostring(checkstate), true)
    osara_override=checkstate
  elseif checkbox_id==tabs2.checkbox_osara_debug_id then
    reaper.SetExtState("ReaGirl", "osara_debug", tostring(checkstate), true)
    osara_debug=checkstate
  elseif checkbox_id==tabs2.checkbox_osara_move_mouse_id then
    reaper.SetExtState("ReaGirl", "osara_move_mouse", tostring(checkstate), true)
    osara_move_mouse=checkstate
  elseif checkbox_id==tabs2.checkbox_osara_hover_mouse_id then
    reaper.SetExtState("ReaGirl", "osara_hover_mouse", tostring(checkstate), true)
    osara_hover_mouse=checkstate
  elseif checkbox_id==tab1.checkbox_tooltips_id then
    reaper.SetExtState("ReaGirl", "show_tooltips", tostring(checkstate), true)
    show_tooltips=checkstate
  elseif checkbox_id==tab1.checkbox_highlight_drag_destinations then
    reaper.SetExtState("ReaGirl", "highlight_drag_destinations", tostring(checkstate), true)
    highlight_drag_destinations=checkstate
  end
end


function SetUpNewGui()
  reagirl.Gui_New()
  
  Tabs=reagirl.Tabs_Add(10, 10, 335, 390, "General settings", "Choose settings", {"General", "Osara"}, 1, nil)
  
  tab1={}
  --[[ Blinking Focus Rectangle ]]
  tab1.Label_General=reagirl.Label_Add(nil, nil, "General", "General settings.", false, nil)
  reagirl.Label_SetStyle(tab1.Label_General, 6, 0, 0)

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
  tab1.Label_Scaling=reagirl.Label_Add(nil, nil, "Scaling", "Settings for the scaling-factor of ReaGirl-Guis", false, nil)
  reagirl.Label_SetStyle(tab1.Label_Scaling, 6, 0, 0)
  reagirl.NextLine()
  scaling_override=tonumber(reaper.GetExtState("ReaGirl", "scaling_override", value, true))
  if scaling_override==nil then scaling_override2=0 else scaling_override2=scaling_override end
  tab1.slider_scale = reagirl.Slider_Add(nil, nil, 250, "Scale Override", 100, "Set the default scaling-factor for all ReaGirl-Gui-windows; 0, scaling depends automatically on the scaling-factor in the prefs or the presence of Retina/HiDPI.", nil, 0, 8, 1, scaling_override2, 0, ScaleOverride)
  tab1.button_scale = reagirl.Button_Add(nil, nil, 0, 0, "Apply", "Apply the chosen scaling value", button_apply)
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
  tab1.image_source=reagirl.Image_Add(50,nil,50,50,reaper.GetResourcePath().."/Data/track_icons/bass.png", "The sun always shines", "on tv", Image)
  tab1.image_middle=reagirl.Image_Add(160,nil,25,25,reaper.GetResourcePath().."/Data/track_icons/folder_right.png", "The sun always shines", "on tv",nil)
  tab1.image_dest=reagirl.Image_Add(250,nil,50,50,reaper.GetResourcePath().."/Data/track_icons/mic_dynamic_1.png", "The sun always shines", "on tv",nil)
  reagirl.Image_SetDraggable(tab1.image_source, true, {tab1.image_dest})
  
  
  reagirl.Tabs_SetUIElementsForTab(Tabs, 1, tab1)
  
  -- [[ Osara override ]]
  tabs2={}
  reagirl.AutoPosition_SetNextYToUIElement(Tabs)
  reagirl.NextLine()
  tabs2.Label_Osara=reagirl.Label_Add(nil, nil, "Osara", "Settings that influence the relationship between Osara and ReaGirl.", false, nil)
  reagirl.NextLine()
  reagirl.Label_SetStyle(tabs2.Label_Osara, 6, 0, 0)

  osara_override=reaper.GetExtState("ReaGirl", "osara_override")
  if osara_override=="true" or osara_override=="" then osara_override=true else osara_override=false end
  tabs2.checkbox_osara_id = reagirl.Checkbox_Add(nil, nil, "Enable installed Osara", "Checking this will prevent from screenreader messages to be sent to Osara. You can also type directly into inputboxes.", osara_override, checkbox)
  
  reagirl.NextLine()
  osara_debug=reaper.GetExtState("ReaGirl", "osara_debug")
  if osara_debug=="false" or osara_debug=="" then osara_debug=false else osara_debug=true end
  tabs2.checkbox_osara_debug_id = reagirl.Checkbox_Add(nil, nil, "Show screenreader messages in console", "Checking this will show the screenreader messages in the console for debugging purposes.", osara_debug, checkbox)
  
  reagirl.NextLine()
  osara_move_mouse = reaper.GetExtState("ReaGirl", "osara_move_mouse")
  if osara_move_mouse=="" or osara_move_mouse=="true" then osara_move_mouse=true else osara_move_mouse=false end
  tabs2.checkbox_osara_move_mouse_id = reagirl.Checkbox_Add(nil, nil, "Move mouse when tabbing ui-elements", "Uncheck to prevent moving of the mouse when tabbing through ui-elements. Unchecking will make right-clicking for context menus more difficult, though.", osara_move_mouse, checkbox)
  
  reagirl.NextLine()
  osara_hover_mouse = reaper.GetExtState("ReaGirl", "osara_hover_mouse")
  if osara_hover_mouse=="" or osara_hover_mouse=="true" then osara_hover_mouse=true else osara_hover_mouse=false end
  tabs2.checkbox_osara_hover_mouse_id = reagirl.Checkbox_Add(nil, nil, "Report hovered ui-elements", "When checked, ReaGirl will report ui-elements the mouse is hovering above to the screenreader. Uncheck to prevent that.", osara_hover_mouse, checkbox)
  
  reagirl.Tabs_SetUIElementsForTab(Tabs, 2, tabs2)
end

SetUpNewGui()

color=40
reagirl.Background_GetSetColor(true,color,color,color)

reagirl.Gui_Open("ReaGirl_Settings", true, "ReaGirl Settings (Reagirl v"..reagirl.GetVersion()..")", "various settings for ReaGirl-Accessible Guis", 355, 435, nil, nil, nil)

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
  else
    return false
  end
end

function main()
  B,B1,B2=CheckIfSettingChanged()
  if B==true then A=reaper.time_precise() testtext=reagirl.Inputbox_GetText(tab1.input_id) i=reagirl.Elements.FocusedElement if i==nil then i=1 end SetUpNewGui() reagirl.Elements.FocusedElement=i end
  reagirl.Gui_Manage()
  if B==true then
    reagirl.Elements.FocusedElement=i
    reagirl.Gui_ForceRefresh()
  end
  if reagirl.Gui_IsOpen()==true then reaper.defer(main) end
end
main()