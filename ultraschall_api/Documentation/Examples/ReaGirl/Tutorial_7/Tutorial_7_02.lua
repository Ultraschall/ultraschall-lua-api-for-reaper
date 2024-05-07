  dofile(reaper.GetResourcePath().."/UserPlugins/reagirl.lua")
  
  -- create new gui
  reagirl.Gui_New()
  
  -- first line of checkboxes
  reagirl.Checkbox_Add(nil, nil, "Checkbox 1", "This is the first checkbox.", true, nil)
  reagirl.Checkbox_Add(nil, nil, "Checkbox 2", "This is the second checkbox.", true, nil)
  reagirl.Checkbox_Add(nil, nil, "Checkbox 3", "This is the third checkbox.", true, nil)

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