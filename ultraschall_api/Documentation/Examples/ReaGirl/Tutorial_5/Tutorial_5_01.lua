  dofile(reaper.GetResourcePath().."/UserPlugins/reagirl.lua")

  function Image_Runfunction(element_id, imagepath_plus_filename, drag_destination)
    -- this function will be run when the image is clicked or dragged to a destination
  end

  -- start a new gui
  reagirl.Gui_New()

  -- add the source-image, which we will draggable
  image_source_id = reagirl.Image_Add(20, 100, 100, 100, reaper.GetResourcePath().."/Data/track_icons/bass.png", "Bass-guitar", "An image of a bass guitar.", Image_Runfunction)


  -- open gui
  reagirl.Gui_Open("My Dialog Name", false, "ReaGirl Tutorial", "Tutorial for draggable images.", 665, 310, nil, nil, nil)

  -- manage gui
  function main()
    reagirl.Gui_Manage()
    
    if reagirl.Gui_IsOpen()==true then reaper.defer(main) end
  end

  main()