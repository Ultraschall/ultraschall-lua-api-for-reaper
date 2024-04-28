dofile(reaper.GetResourcePath().."/UserPlugins/reagirl.lua")

reagirl.Gui_New()

reagirl.Label_Add(nil, nil, "A label with some text", "Labels are there to describe things in the gui.", false, nil)
reagirl.NextLine()

reagirl.Checkbox_Add(nil, nil, "Checkbox #1", "The first checkbox.", true, nil)
reagirl.Checkbox_Add(nil, nil, "Checkbox #2", "The second checkbox.", true, nil)
reagirl.NextLine()
reagirl.Checkbox_Add(nil, nil, "Checkbox #3", "The third checkbox.", true, nil)

reagirl.NextLine()

reagirl.Slider_Add(nil, nil, -20, "A Slider-ui-element", nil, "A test slider in this gui.", "tests", 1, 200, 0.1, 10, 20, nil)
reagirl.NextLine()
reagirl.DropDownMenu_Add(nil,nil, -20,"Drop Down Menu", 100, "A test Drop Down Menu or Combo Box as it's probably known.", {"First menu entry", "The second menu entry", "A third menu entry"}, 1, nil)
reagirl.NextLine()
reagirl.Inputbox_Add(nil, nil, -20, "An input box:", 100, "Input some text in here.", "", nil, nil)

reagirl.Gui_Open("ReaGirl Testdialog #1", false, "ReaGirl Testdialog #1", "a test dialog that features all available ui-elements.", 355, 435, nil, nil, nil)

function main()
  reagirl.Gui_Manage()

  if reagirl.Gui_IsOpen()==true then reaper.defer(main) end
end
main()
