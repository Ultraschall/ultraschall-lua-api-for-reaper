  dofile(reaper.GetResourcePath().."/UserPlugins/reagirl.lua")

  function Image_Runfunction(element_id, imagepath_plus_filename, drag_destination)
    -- this function will be run when the image is clicked or dragged to a destination
    reaper.MB("Dragged to: "..reagirl.UI_Element_GetSetCaption(drag_destination, false, ""), "", 0)
  end

  -- start a new gui
  reagirl.Gui_New()

  -- add the source-image, which we will draggable
  image_source_id = reagirl.Image_Add(20, 100, 100, 100, reaper.GetResourcePath().."/Data/track_icons/bass.png", "Bass-guitar", "An image of a bass guitar.", Image_Runfunction)

  -- add some additional images and a label, that are the destinations for the dragging
  label_id = reagirl.Label_Add(240, 10, "Nothing has been dragged to this label, yet", "A destination for the source-image to drag to.", false, nil)
  image_dest1_id = reagirl.Image_Add(220, 50, 100, 100, reaper.GetResourcePath().."/Data/track_icons/amp.png", "Amplifier", "An image of an amplifier.", nil)
  image_dest2_id = reagirl.Image_Add(220, 160, 100, 100, reaper.GetResourcePath().."/Data/track_icons/congas.png", "Congas", "An image of congas.", nil)

  -- add the element_ids of image2-4_id as drag-destinations of image1_id
  reagirl.Image_SetDraggable(image_source_id, true, {label_id, image_dest1_id, image_dest2_id})

  -- open gui
  reagirl.Gui_Open("My Dialog Name", false, "ReaGirl Tutorial", "Tutorial for draggable images.", 665, 310, nil, nil, nil)

  -- manage gui
  function main()
    reagirl.Gui_Manage()
    
    if reagirl.Gui_IsOpen()==true then reaper.defer(main) end
  end
  
  main()