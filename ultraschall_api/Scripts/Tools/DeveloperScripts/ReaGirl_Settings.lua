dofile(reaper.GetResourcePath().."/UserPlugins/reagirl.lua")
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

function CursorBlinkSpeed(slider_id, value)
  if value==1 then
    reaper.SetExtState("ReaGirl", "InputBox_BlinkSpeed", "", true)
  else
    reaper.SetExtState("ReaGirl", "InputBox_BlinkSpeed", math.floor(value*33), true)
  end
  reagirl.FocusRectangle_BlinkStartTime=reaper.time_precise()
end

function button_apply(slider_id, value)
  value=reagirl.Slider_GetValue(slider_scale)
  if value==0 then value="" end
  reaper.SetExtState("ReaGirl", "scaling_override", value, true)
  scaling_override=value
end

function checkbox(checkbox_id, checkstate)
  override=true
  if checkbox_id==checkbox_osara_id then
    reaper.SetExtState("ReaGirl", "osara_override", tostring(checkstate), true)
    osara_override=checkstate
  elseif checkbox_id==checkbox_osara_debug_id then
    reaper.SetExtState("ReaGirl", "osara_debug", tostring(checkstate), true)
    osara_debug=checkstate
  elseif checkbox_id==checkbox_osara_move_mouse_id then
    reaper.SetExtState("ReaGirl", "osara_move_mouse", tostring(checkstate), true)
    osara_move_mouse=checkstate
  elseif checkbox_id==checkbox_osara_hover_mouse_id then
    reaper.SetExtState("ReaGirl", "osara_hover_mouse", tostring(checkstate), true)
    osara_hover_mouse=checkstate
  elseif checkbox_id==checkbox_tooltips_id then
    reaper.SetExtState("ReaGirl", "show_tooltips", tostring(checkstate), true)
    show_tooltips=checkstate
  end
end


function SetUpNewGui()
  reagirl.Gui_New()
  
  --[[ Blinking Focus Rectangle ]]

  Label1=reagirl.Label_Add(nil, nil, "General", "General settings.", 0, false, nil)
  reagirl.Label_SetStyle(Label1, 6, 0, 0)

  reagirl.NextLine(-2)
  show_tooltips = reaper.GetExtState("ReaGirl", "show_tooltips")
  if show_tooltips=="" or show_tooltips=="true" then show_tooltips=true else show_tooltips=false end
  checkbox_tooltips_id = reagirl.CheckBox_Add(nil, nil, "Show tooltips when hovering above ui-element", "When checked, ReaGirl will show tooltips when hovering above ui-elements.", show_tooltips, checkbox)
  
  reagirl.NextLine(10)
  Label1=reagirl.Label_Add(nil, nil, "Focus Rectangle", "Settings for the focus rectangle.", 0, false, nil)
  reagirl.Label_SetStyle(Label1, 6, 0, 0)
  
  reagirl.NextLine(-4)
  val=tonumber(reaper.GetExtState("ReaGirl", "FocusRectangle_BlinkSpeed"))
  if val==nil then val=33 end
  
  val2=tonumber(reaper.GetExtState("ReaGirl", "FocusRectangle_BlinkTime"))
  if val2==nil then val2=0 end
  
  reagirl.Slider_Add(nil, nil, 300, "Blink every", 140, "Set the speed of the blinking of the focus rectangle.", "seconds", 0.4, 3, 0.1, val/33, 1, BlinkSpeed)
  reagirl.NextLine(-4)
  reagirl.Slider_Add(nil, nil, 300, "Blinklength for", 140, "Set the duration of the blinking of the focus rectangle.", "seconds", 0, 10, 1, val2, 0, BlinkTime)
  
  -- [[ Blinking InputBox-Cursor ]]
  reagirl.NextLine(15)
  Label1=reagirl.Label_Add(nil, nil, "Inputbox-Cursor", "Settings for the inputbox-cursor.", 0, false, nil)
  reagirl.Label_SetStyle(Label1, 6, 0, 0)
  reagirl.NextLine(-4)
  val3=tonumber(reaper.GetExtState("ReaGirl", "InputBox_BlinkSpeed"))
  if val3==nil then val3=33 end
  slider=reagirl.Slider_Add(nil, nil, 300, "Blink every", 140, "Set the speed of the blinking of the cursor.", "seconds", 0.4, 3, 0.1, val3/33, 1, CursorBlinkSpeed)
  reagirl.NextLine(-2)
  input_id = reagirl.InputBox_Add(nil, nil, 300, "Test input:", 140, "Input text to check cursor blinking speed.", testtext, nil, nil)
  reagirl.InputBox_SetEmptyText(input_id, "Test blink-speed here...")
  
  -- [[ Scaling Override ]]
  reagirl.NextLine(15)
  Label1=reagirl.Label_Add(nil, nil, "Scaling", "Settings for the scaling-factor of ReaGirl-Guis", 0, false, nil)
  reagirl.Label_SetStyle(Label1, 6, 0, 0)
  reagirl.NextLine(-4)
  scaling_override=tonumber(reaper.GetExtState("ReaGirl", "scaling_override", value, true))
  if scaling_override==nil then scaling_override2=0 else scaling_override2=scaling_override end
  slider_scale = reagirl.Slider_Add(nil, nil, 250, "Scale Override", 140, "Set the default scaling-factor for all ReaGirl-Gui-windows; 0 is auto-scaling.", nil, 0, 8, 1, scaling_override2, 0, ScaleOverride)
  button=reagirl.Button_Add(nil, nil, 0, 0, "Apply", "Apply the chosen scaling value.", button_apply)
  reagirl.NextLine(15)
  
  -- [[ Osara override ]]
  Label1=reagirl.Label_Add(nil, nil, "Osara", "Settings that influence the relationship between Osara and ReaGirl.", 0, false, nil)
  reagirl.NextLine(-4)
  reagirl.Label_SetStyle(Label1, 6, 0, 0)
  osara_override=reaper.GetExtState("ReaGirl", "osara_override")
  if osara_override=="true" or osara_override=="" then osara_override=true else osara_override=false end
  checkbox_osara_id = reagirl.CheckBox_Add(nil, nil, "Enable installed Osara", "Checking this will prevent from screenreader messages to be sent to Osara. You can also type directly into inputboxes.", osara_override, checkbox)
  
  reagirl.NextLine()
  osara_debug=reaper.GetExtState("ReaGirl", "osara_debug")
  if osara_debug=="false" or osara_debug=="" then osara_debug=false else osara_debug=true end
  checkbox_osara_debug_id = reagirl.CheckBox_Add(nil, nil, "Show screenreader messages in console", "Checking this will show the screenreader messages in the console for debugging purposes.", osara_debug, checkbox)
  
  reagirl.NextLine()
  osara_move_mouse = reaper.GetExtState("ReaGirl", "osara_move_mouse")
  if osara_move_mouse=="" or osara_move_mouse=="true" then osara_move_mouse=true else osara_move_mouse=false end
  checkbox_osara_move_mouse_id = reagirl.CheckBox_Add(nil, nil, "Move mouse when tabbing ui-elements", "Uncheck to prevent moving of the mouse when tabbing through ui-elements. Unchecking will make right-clicking for context menus more difficult, though.", osara_move_mouse, checkbox)
  
  reagirl.NextLine()
  osara_hover_mouse = reaper.GetExtState("ReaGirl", "osara_hover_mouse")
  if osara_hover_mouse=="" or osara_hover_mouse=="true" then osara_hover_mouse=true else osara_hover_mouse=false end
  checkbox_osara_hover_mouse_id = reagirl.CheckBox_Add(nil, nil, "Report hovered ui-elements", "When checked, ReaGirl will report ui-elements the mouse is hovering above to the screenreader. Uncheck to prevent that.", osara_hover_mouse, checkbox)
end

SetUpNewGui()

reagirl.Background_GetSetColor(true,55,55,55)

reagirl.Gui_Open("ReaGirl Settings (Reagirl v"..reagirl.GetVersion()..")", "various settings for ReaGirl-Accessible Guis", 355, 390, nil, nil, nil)

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
  if B==true then A=reaper.time_precise() testtext=reagirl.InputBox_GetText(input_id) i=reagirl.Elements.FocusedElement if i==nil then i=1 end SetUpNewGui() reagirl.Elements.FocusedElement=i end
  reagirl.Gui_Manage()
  if B==true then
    reagirl.Elements.FocusedElement=i
    reagirl.Gui_ForceRefresh()
  end
  if reagirl.Gui_IsOpen()==true then reaper.defer(main) end
end
main()
