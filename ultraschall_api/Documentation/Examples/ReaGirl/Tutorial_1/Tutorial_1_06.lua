dofile(reaper.GetResourcePath().."/UserPlugins/reagirl.lua")
  
  function Button_RunFunction(pressed_button_id)
    -- this function is run, when a button is pressed
    if pressed_button_id==button_ok_id then
      reaper.MB("OK Button is pressed", "OK Button", 0)
    elseif pressed_button_id==button_cancel_id then
      reaper.MB("Cancel Button is pressed", "Cancel Button", 0)
    end
  end

  function Checkbox_RunFunction(checked_checkbox_id, checkstate)
    -- this function is run, when the checkstate of a checkbox is changed
    if checked_checkbox_id==checkbox_remember then
      reaper.MB("Checkbox \"Remember\" is "..tostring(checkstate), "Checkbox-State changed", 0)
    elseif checked_checkbox_id==checkbox_mysetting then
      reaper.MB("Checkbox \"my Setting\" is "..tostring(checkstate), "Checkbox-State changed", 0)
    end
  end

  function InputBox_RunFunction_Type(inputbox_id, entered_text)
    -- this function is run, when the user types in text into an inputbox
    reaper.ClearConsole()
    if inputbox_id==inputbox_name_of_setting then
      reaper.ShowConsoleMsg("NAME: "..entered_text)
    elseif inputbox_id==inputbox_description_of_setting then
      reaper.ShowConsoleMsg("DESCRIPTION: "..entered_text)
    end
  end

  function InputBox_RunFunction_Enter(inputbox_id, entered_text)
    -- this function is run, when the user hits enter into an inputbox
    if inputbox_id==inputbox_name_of_setting then
      reaper.MB(entered_text, "The typed text into NAME was", 0)
    elseif inputbox_id==inputbox_description_of_setting then
      reaper.MB(entered_text, "The typed text into DESCRIPTION was", 0)
    end
  end


  -- create new gui
  reagirl.Gui_New()

  -- add a textlabel to the top of the gui
  label_header=reagirl.Label_Add(30, 50, "This is a settings dialog", "Set the settings, as you wish.", false, nil)
  reagirl.Label_SetFontSize(label_header, 40) -- set the font-size of the label to 40
  reagirl.Label_SetStyle(label_header, 6, 0, 0) -- set the label to underlined

  -- add inputboxes to type in text
  inputbox_name_of_setting = reagirl.Inputbox_Add(30, 105, 300, "Name of the setting:", 150, "Type in here the name of the setting.", "No title", InputBox_RunFunction_Enter, InputBox_RunFunction_Type)
  inputbox_description_of_setting = reagirl.Inputbox_Add(30, 130, 300, "Description of the setting:", 150, "Type in here a description of the setting.", "No Description", InputBox_RunFunction_Enter, InputBox_RunFunction_Type)

  -- add two checkboxes to the gui
  checkbox_mysetting = reagirl.Checkbox_Add(30, 150, "My setting", "How shall my setting be set?", true, Checkbox_RunFunction)
  checkbox_remember = reagirl.Checkbox_Add(30, 170, "Remember chosen setting", "Shall this setting be used as future default?", true, Checkbox_RunFunction)

  -- add an ok-button and a cancel button to the gui
  button_ok_id = reagirl.Button_Add(30, 200, 0, 0, "OK", "Apply changes and close dialog.", Button_RunFunction)
  button_cancel_id = reagirl.Button_Add(70, 200, 0, 0, "Cancel", "Discard changes and close dialog.", Button_RunFunction)
  reagirl.Button_SetRadius(button_ok_id, 20)    -- make the ok-button rounder
  reagirl.Button_SetRadius(button_cancel_id, 0) -- make the cancel button square

  -- open the new gui
  reagirl.Gui_Open("My Dialog Name", false, "The dialog", "This is a demo dialog with settings for tool xyz.", 640, 250)

  function main()
    -- a function that runs the gui-manage function in the background, so the gui is updated correctly
    reagirl.Gui_Manage()
    
    -- if the gui-window hasn't been closed, keep the script alive.
    if reagirl.Gui_IsOpen()==true then reaper.defer(main) end
  end

  main()