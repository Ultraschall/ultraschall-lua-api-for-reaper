dofile(reaper.GetResourcePath().."/UserPlugins/reagirl.lua")
dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

testtext=""

function DropDownMenu_RunFunction(element_id, menu_entry)
  reaper.SetExtState("ReaGirl", "osara_override", tostring(menu_entry), true)
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
end

function checkbox(checkbox_id, checkstate)
  if checkbox_id==checkbox_osara_id then
    reaper.SetExtState("ReaGirl", "osara_override", tostring(checkstate), true)
  elseif checkbox_id==checkbox_osara_debug_id then
    reaper.SetExtState("ReaGirl", "osara_debug", tostring(checkstate), true)
  end
end


function SetUpNewGui()
  reagirl.Gui_New()
  
  --[[ Blinking Focus Rectangle ]]
  
  Label1=reagirl.Label_Add(nil, nil, "Focus Rectangle", "Settings for the focus rectangle.", 0, false, nil)
  reagirl.Label_SetStyle(Label1, 6, 0, 0)
  
  reagirl.NextLine()
  val=tonumber(reaper.GetExtState("ReaGirl", "FocusRectangle_BlinkSpeed"))
  if val==nil then val=0 end
  
  val2=tonumber(reaper.GetExtState("ReaGirl", "FocusRectangle_BlinkTime"))
  if val2==nil then val2=0 end
  
  reagirl.Slider_Add(nil, nil, 300, "Blink every", 140, "Set the speed of the blinking of the focus rectangle.", "seconds", 0.4, 3, 0.1, val/33, 1, BlinkSpeed)
  reagirl.NextLine()
  reagirl.Slider_Add(nil, nil, 300, "Blinklength for", 140, "Set the length of the blinking of the focus rectangle.", "seconds", 0, 10, 1, val2, 0, BlinkTime)
  
  -- [[ Blinking InputBox-Cursor ]]
  reagirl.NextLine(15)
  Label1=reagirl.Label_Add(nil, nil, "Inputbox-Cursor", "Settings for the inputbox-cursor.", 0, false, nil)
  reagirl.Label_SetStyle(Label1, 6, 0, 0)
  reagirl.NextLine()
  val3=tonumber(reaper.GetExtState("ReaGirl", "InputBox_BlinkSpeed"))
  if val3==nil then val3=33 end
  slider=reagirl.Slider_Add(nil, nil, 300, "Blink every", 140, "Set the speed of the blinking of the cursor.", "seconds", 0.4, 3, 0.1, val3/33, 1, CursorBlinkSpeed)
  reagirl.NextLine()
  input_id = reagirl.InputBox_Add(nil, nil, 300, "Test input:", 140, "Input text to check cursor blinking speed.", testtext, nil, nil)
  reagirl.InputBox_SetEmptyText(input_id, "Test blink-speed here...")
  
  -- [[ Scaling Override ]]
  reagirl.NextLine(15)
  Label1=reagirl.Label_Add(nil, nil, "Scaling", "Settings for the scaling-factor of ReaGirl-Guis", 0, false, nil)
  reagirl.Label_SetStyle(Label1, 6, 0, 0)
  reagirl.NextLine()
  scaling_override=tonumber(reaper.GetExtState("ReaGirl", "scaling_override", value, true))
  if scaling_override==nil then scaling_override2=0 else scaling_override2=scaling_override end
  slider_scale = reagirl.Slider_Add(nil, nil, 250, "Scale Override", 140, "Set the default scaling-factor for all ReaGirl-Gui-windows; 0 is auto-scaling.", nil, 0, 8, 1, scaling_override2, 0, ScaleOverride)
  reagirl.Button_Add(nil, nil, 0, 0, "Apply", "Apply the chosen scaling value.", button_apply)
  reagirl.NextLine(15)
  
  -- [[ Osara override ]]
  Label1=reagirl.Label_Add(nil, nil, "Osara", "Settings that influence the relationship between Osara and ReaGirl.", 0, false, nil)
  reagirl.NextLine()
  reagirl.Label_SetStyle(Label1, 6, 0, 0)
  osara_override=reaper.GetExtState("ReaGirl", "osara_override", value, true)
  if osara_override=="false" or osara_override=="" then osara_override=false else osara_override=true end
  checkbox_osara_id = reagirl.CheckBox_Add(nil, nil, "Ignore installed Osara", "Checking this will prevent from screenreader messages to be sent to Osara. You can also type directly into inputboxes.", osara_override, checkbox)
  reagirl.NextLine()
  osara_debug=reaper.GetExtState("ReaGirl", "osara_debug", value, true)
  if osara_debug=="false" or osara_debug=="" then osara_debug=false else osara_debug=true end
  checkbox_osara_debug_id = reagirl.CheckBox_Add(nil, nil, "Show screenreader messages in console", "Checking this will show the screenreader messages in the console for debugging purposes.", osara_debug, checkbox)
end

SetUpNewGui()

reagirl.Background_GetSetColor(true,55,55,55)

reagirl.Gui_Open("ReaGirl Settings (Reagirl v"..reagirl.GetVersion()..")", "various settings for ReaGirl-Accessible Guis", 345, 320, nil, nil, nil)

function CheckIfSettingChanged()
  if osara_debug~=toboolean(reaper.GetExtState("ReaGirl", "osara_debug")) then 
    osara_debug=toboolean(reaper.GetExtState("ReaGirl", "osara_debug"))
    return true, 1
  elseif osara_override~=toboolean(reaper.GetExtState("ReaGirl", "osara_override")) then
    osara_override=toboolean(reaper.GetExtState("ReaGirl", "osara_override"))
    return true, 2 
  elseif scaling_override~=tonumber(reaper.GetExtState("ReaGirl", "scaling_override", value, true)) then
    scaling_override=tonumber(reaper.GetExtState("ReaGirl", "scaling_override", value, true))
    if scaling_override==nil then scaling_override=0 end
    return true, 3, tonumber(reaper.GetExtState("ReaGirl", "scaling_override", value, true))
  else
    return false, 4
  end
end

function main()
  B,B1,B2=CheckIfSettingChanged()
  if B==true then A=reaper.time_precise() testtext=reagirl.InputBox_GetText(input_id) SetUpNewGui() end
  reagirl.Gui_Manage()
  
  if reagirl.Gui_IsOpen()==true then reaper.defer(main) end
end
main()