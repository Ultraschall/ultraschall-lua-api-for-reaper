  dofile(reaper.GetResourcePath().."/UserPlugins/reagirl.lua")
  
  -- create new gui
  reagirl.Gui_New()
  
  -- first line of checkboxes
  reagirl.Checkbox_Add(nil, nil, "Checkbox 1", "This is the first checkbox.", true, nil)
  reagirl.Checkbox_Add(nil, nil, "Checkbox 2", "This is the second checkbox.", true, nil)
  reagirl.Checkbox_Add(nil, nil, "Checkbox 3", "This is the third checkbox.", true, nil)
  
  -- second line of checkboxes
  reagirl.NextLine() -- start a new line of ui-elements
  reagirl.Checkbox_Add(nil, nil, "Checkbox 4", "This is the fourth checkbox.", true, nil)
  reagirl.Checkbox_Add(nil, nil, "Checkbox 5", "This is the fifth checkbox.", true, nil)
  
  -- third line with one checkbox and one button anchored to right side of the window
  -- this line is placed 10 pixels lower to gain some distance between the lines
  reagirl.NextLine(10) -- start a new line of ui-elements, ten pixels lower than
  reagirl.Checkbox_Add(-200, nil, "Checkbox 5", "This is the fifth checkbox.", true, nil)
  button = reagirl.Button_Add(nil, nil, 0, 0, "Store", "Store 1.", nil)
  
  -- fourth line with one checkbox and one button anchored to the left side of the window
  reagirl.Checkbox_Add(40, 100, "Checkbox 6", "This is the fifth checkbox.", true, nil)
  button = reagirl.Button_Add(nil, nil, 0, 0, "Store 2", "Store 2.", nil)

  -- open the new gui
  reagirl.Gui_Open("My Dialog Name", false, "The dialog", "This is a demo dialog with settings for tool xyz.", 425, 240)

  -- make the background grey
  reagirl.Background_GetSetColor(true, 55, 55, 55)

  reagirl.Gui_AtExit(AtExit_RunFunction)
  reagirl.Gui_AtEnter(AtEnter_RunFunction)

  function main()
    -- a function that runs the gui-manage function in the background, so the gui is updated correctly
    reagirl.Gui_Manage()
    
    -- if the gui-window hasn't been closed, keep the script alive.
    if reagirl.Gui_IsOpen()==true then reaper.defer(main) end
  end

  main()