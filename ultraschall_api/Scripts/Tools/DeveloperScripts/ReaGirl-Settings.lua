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

reagirl.Gui_New()
Label1=reagirl.Label_Add(nil, nil, "Blinking of the focus rectangle", "Set the blinking of the focus rectangle", 0, false, nil)
reagirl.Label_SetStyle(Label1, 6, 0, 0)

reagirl.NextLine()
val=tonumber(reaper.GetExtState("ReaGirl", "FocusRectangle_BlinkSpeed"))
if val==nil then val=0 end

val2=tonumber(reaper.GetExtState("ReaGirl", "FocusRectangle_BlinkTime"))
if val2==nil then val2=0 end

reagirl.Slider_Add(nil, nil, 250, "Blinkspeed", 140, "Set the speed of the blinking", nil, 0, 200, 1, val, BlinkSpeed)
reagirl.NextLine()
reagirl.Slider_Add(nil, nil, 250, "Blinklength in seconds", 140, "Set the speed of the blinking", nil, 0, 10, 1, val2, BlinkTime)

reagirl.NextLine(20)
Label1=reagirl.Label_Add(nil, nil, "Blinking of inputbox-cursor", "Set the blinking of the inputbox-cursor", 0, false, nil)
reagirl.Label_SetStyle(Label1, 6, 0, 0)
reagirl.NextLine()

val3=tonumber(reaper.GetExtState("ReaGirl", "InputBox_BlinkSpeed"))
if val3==nil then val3=33 end
reagirl.Slider_Add(nil, nil, 250, "Speed", 140, "Set the speed of the blinking", nil, 6, 100, 1, val3, CursorBlinkSpeed)
reagirl.NextLine()
reagirl.InputBox_Add(nil, nil, 250, "Test input:", 140, "Input test text to check cursor blinking speed", "Test", nil, nil)

val4=tonumber(reaper.GetExtState("reagirl_preferences", "scaling_override"))
if val4==nil then val4=0 end
reagirl.NextLine(20)
Label1=reagirl.Label_Add(nil, nil, "Blinking of inputbox-cursor", "Set the blinking of the inputbox-cursor", 0, false, nil)
reagirl.Label_SetStyle(Label1, 6, 0, 0)
reagirl.NextLine()
slider_scale = reagirl.Slider_Add(nil, nil, 250, "Scale Override", 140, "Set the default scaling-factor for all ReaGirl-Guis; 0 is auto-scaling.", nil, 0, 8, 1, val4, ScaleOverride)
reagirl.Button_Add(nil, nil, 0, 0, "Apply", "Apply the chosen scaling value.", button_apply)


reagirl.Background_GetSetColor(true,55,55,55)

reagirl.Gui_Open("ReaGirl Settings", "various settings for ReaGirl-Accessible Guis", 345, 263, nil, nil, nil)

function main()
  reagirl.Gui_Manage()
  
  if reagirl.Gui_IsOpen()==true then reaper.defer(main) end
end
main()
