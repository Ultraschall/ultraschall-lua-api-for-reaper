  dofile(reaper.GetResourcePath().."/UserPlugins/reagirl.lua")
  
  function Image_RunFunction(clicked_image_id)
    -- this function is run, when the image is clicked
  end
  
  -- create new gui
  reagirl.Gui_New()
  
  -- add the image of a bass guitar to this gui
  image_id = reagirl.Image_Add(10, 10, 100, 100, reaper.GetResourcePath().."/Data/track_icons/bass.png", "An image", "A user selectable image.", Image_RunFunction)
  
  -- open the new gui
  reagirl.Gui_Open("My Dialog Name", false, "Image Viewer", "This is a demo image viewer.", 120, 120)

  -- make the background grey
  reagirl.Background_GetSetColor(true, 55, 55, 55)

  function main()
    -- a function that runs the gui-manage function in the background, so the gui is updated correctly
    reagirl.Gui_Manage()
    
    -- if the gui-window hasn't been closed, keep the script alive.
    if reagirl.Gui_IsOpen()==true then reaper.defer(main) end
  end

  main()