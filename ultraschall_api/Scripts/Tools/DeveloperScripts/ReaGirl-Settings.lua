dofile(reaper.GetResourcePath().."/UserPlugins/reagirl.lua")

function BlinkSpeed(slider_id, value)
  if value==0 then
    reaper.SetExtState("ReaGirl", "FocusRectangle_BlinkSpeed", "", true)
  else
    reaper.SetExtState("ReaGirl", "FocusRectangle_BlinkSpeed", value, true)
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
  if value==33 then
    reaper.SetExtState("ReaGirl", "InputBox_BlinkSpeed", "", true)
  else
    reaper.SetExtState("ReaGirl", "InputBox_BlinkSpeed", value, true)
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
  end
end

reagirl.Gui_New()

--[[ Blinking Focus Rectangle ]]

Label1=reagirl.Label_Add(nil, nil, "Blinking of the focus rectangle", "Set the blinking of the focus rectangle", 0, false, nil)
reagirl.Label_SetStyle(Label1, 6, 0, 0)

reagirl.NextLine()
val=tonumber(reaper.GetExtState("ReaGirl", "FocusRectangle_BlinkSpeed"))
if val==nil then val=0 end

val2=tonumber(reaper.GetExtState("ReaGirl", "FocusRectangle_BlinkTime"))
if val2==nil then val2=0 end

reagirl.Slider_Add(nil, nil, 250, "Blinkspeed", 140, "Set the speed of the blinking", nil, 0, 200, 1, val, 0, BlinkSpeed)
reagirl.NextLine()
reagirl.Slider_Add(nil, nil, 250, "Blinklength in seconds", 140, "Set the speed of the blinking", nil, 0, 10, 1, val2, 0, BlinkTime)

-- [[ Blinking InputBox-Cursor ]]
reagirl.NextLine(15)
Label1=reagirl.Label_Add(nil, nil, "Blinking of inputbox-cursor", "Set the blinking of the inputbox-cursor", 0, false, nil)
reagirl.Label_SetStyle(Label1, 6, 0, 0)
reagirl.NextLine()

val3=tonumber(reaper.GetExtState("ReaGirl", "InputBox_BlinkSpeed"))
if val3==nil then val3=33 end
slider=reagirl.Slider_Add(nil, nil, 250, "Speed", 140, "Set the speed of the blinking", nil, 6, 100, 1, val3, 33, CursorBlinkSpeed)
reagirl.NextLine()
input_id = reagirl.InputBox_Add(nil, nil, 300, "Test input:", 140, "Input test text to check cursor blinking speed", "", nil, nil)
reagirl.InputBox_SetEmptyText(input_id, "Enter test-text here...")
-- [[ Scaling Override ]]
val4=tonumber(reaper.GetExtState("reagirl_preferences", "scaling_override"))
if val4==nil then val4=0 end
reagirl.NextLine(15)
Label1=reagirl.Label_Add(nil, nil, "Blinking of inputbox-cursor", "Set the blinking of the inputbox-cursor", 0, false, nil)
reagirl.Label_SetStyle(Label1, 6, 0, 0)
reagirl.NextLine()

-- [[ Scaling Override ]]
val5=tonumber(reaper.GetExtState("ReaGirl", "scaling_override", value, true))
if val5==nil then val5=0 end
slider_scale = reagirl.Slider_Add(nil, nil, 250, "Scale Override", 140, "Set the default scaling-factor for all ReaGirl-Guis; 0 is auto-scaling.", nil, 0, 8, 1, val5, 0, ScaleOverride)
reagirl.Button_Add(nil, nil, 0, 0, "Apply", "Apply the chosen scaling value.", button_apply)
reagirl.NextLine(15)

-- [[ Osara override ]]
val6=reaper.GetExtState("ReaGirl", "osara_override", value, true)
if val6=="true" then val6=true else val6=false end
Label1=reagirl.Label_Add(nil, nil, "Osara specific", "Settings that influence the relationship between Osara and ReaGirl", 0, false, nil)
reagirl.NextLine()
reagirl.Label_SetStyle(Label1, 6, 0, 0)
checkbox_osara_id = reagirl.CheckBox_Add(nil, nil, "Ignore installed Osara", "Checking this will prevent from screenreader messages to be sent to Osara. Also, you can type directly into inputboxes.", val6, checkbox)


reagirl.Background_GetSetColor(true,55,55,55)

reagirl.Gui_Open("ReaGirl Settings", "various settings for ReaGirl-Accessible Guis", 345, 310, nil, nil, nil)

function main()
  reagirl.Gui_Manage()
  
  if reagirl.Gui_IsOpen()==true then reaper.defer(main) end
end
main()
