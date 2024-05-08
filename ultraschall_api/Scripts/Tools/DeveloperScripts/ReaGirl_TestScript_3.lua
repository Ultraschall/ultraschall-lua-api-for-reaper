dofile(reaper.GetResourcePath().."/UserPlugins/reagirl.lua")

reagirl.Gui_New()

function test()

end

label1 = reagirl.Label_Add(10,10,"Test test", "A test label.",false,nil)
reagirl.UI_Element_GetSet_ContextMenu(label1, true, "The first context menu.", test)
label2 = reagirl.Label_Add(1000,10,"Test test 2", "A second test label.",false,nil)
reagirl.UI_Element_GetSet_ContextMenu(label2, true, "The second context menu.", test)
label3 = reagirl.Label_Add(10,1000,"Test test 3", "A third test label.",false,nil)
reagirl.UI_Element_GetSet_ContextMenu(label3, true, "The third context menu.", test)

reagirl.Gui_Open("Test dialog", false, "A test dialog", "Testing how scrolling affects accessibility.", 100, 100)

function main()
  reagirl.Gui_Manage()
  reaper.defer(main)
end

main()
