dofile(reaper.GetResourcePath().."/UserPlugins/reagirl.lua")

function Button_RunFunction(pressed_button_id)
  -- this function is run, when a button is pressed
  if pressed_button_id==button_ok_id then
    reaper.MB("OK Button is pressed", "OK Button", 0)
  elseif pressed_button_id==button_cancel_id then
    reaper.MB("Cancel Button is pressed", "Cancel Button", 0)
  end
end

-- create new gui
reagirl.Gui_New()
-- add an ok-button and a cancel button to the gui
button_ok_id = reagirl.Button_Add(30, 200, 0, 0, "OK", "Apply changes and close dialog.", Button_RunFunction)
button_cancel_id = reagirl.Button_Add(70, 200, 0, 0, "Cancel", "Discard changes and close dialog.", Button_RunFunction)

-- open the new gui
reagirl.Gui_Open("My Dialog Name", false, "The dialog", "This is a demo dialog with settings for tool xyz.", 640, 250)

function main()
  -- a function that runs the gui-manage function in the background, so the gui is updated correctly
  reagirl.Gui_Manage()
  
  -- if the gui-window hasn't been closed, keep the script alive.
  if reagirl.Gui_IsOpen()==true then reaper.defer(main) end
end

main()