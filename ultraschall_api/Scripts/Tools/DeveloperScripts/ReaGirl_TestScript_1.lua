function CheckForDependencies(ReaImGui, js_ReaScript, US_API, SWS, Osara)
  if US_API==true or js_ReaScript==true or ReaImGui==true or SWS==true or Osara==true then
    if US_API==true and reaper.file_exists(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")==false then
      US_API="Ultraschall API" -- "Ultraschall API" or ""
    else
      US_API=""
    end
    
    if reaper.JS_ReaScriptAPI_Version==nil and js_ReaScript==true then
      js_ReaScript="js_ReaScript" -- "js_ReaScript" or ""
    else
      js_ReaScript=""
    end
    
    if reaper.ImGui_GetVersion==nil and ReaImGui==true then
      ReaImGui="ReaImGui" -- "ReaImGui" or ""
    else
      ReaImGui=""
    end
    
    if reaper.CF_GetSWSVersion==nil and SWS==true then
      SWS="SWS" -- "ReaImGui" or ""
    else
      SWS=""
    end
    
    if reaper.osara_outputMessage==nil and Osara==true then
      Osara="Osara" -- "ReaImGui" or ""
    else
      Osara=""
    end
    
    if Osara=="" and SWS=="" and js_ReaScript=="" and ReaImGui=="" and US_API=="" then return true end
    local state=reaper.MB("This script needs additionally \n\n"..ReaImGui.."\n"..js_ReaScript.."\n"..US_API.."\n"..SWS.."\n"..Osara.."\n\ninstalled to work. Do you want to install them?", "Dependencies required", 4) 
    if state==7 then return false end
    if SWS~="" then
      reaper.MB("SWS can be downloaded from sws-extension.org/download/pre-release/", "SWS missing", 0)
    end
    
    if Osara~="" then
      reaper.MB("Osara can be downloaded from https://osara.reaperaccessibility.com/", "Osara missing", 0)
    end
    
    if reaper.ReaPack_BrowsePackages==nil and (US_API~="" or ReaImGui~="" or js_ReaScript~="") then
      reaper.MB("Some uninstalled dependencies need ReaPack to be installed. Can be downloaded from https://reapack.com/", "ReaPack missing", 0)
      return false
    else
      
      if US_API=="Ultraschall API" then
        reaper.ReaPack_AddSetRepository("Ultraschall API", "https://github.com/Ultraschall/ultraschall-lua-api-for-reaper/raw/master/ultraschall_api_index.xml", true, 2)
        reaper.ReaPack_ProcessQueue(true)
      end
      
      if US_API~="" or ReaImGui~="" or js_ReaScript~="" then 
        reaper.ReaPack_BrowsePackages(js_ReaScript.." OR "..ReaImGui.." OR "..US_API)
      end
    end
  end
  return true
end

state=CheckForDependencies(false, true, false, true, true)
if state==false then reaper.MB("Can't start script due to missing dependencies", "Error", 0) return end
if reaper.JS_ReaScriptAPI_Version==nil then return end

dofile(reaper.GetResourcePath().."/UserPlugins/reagirl.lua")

function button(element_id)
  if butt1==element_id then
    reaper.MB("First button pressed", "Button pressed", 0)
  elseif butt2==element_id then
    reaper.MB("Second button pressed", "Button pressed", 0)
  end
  reagirl.Window_SetFocus()
end

reagirl.Gui_New()

label=reagirl.Label_Add(nil, nil, "A label with some text", "Labels are there to describe things in the gui.", false, nil)
reagirl.UI_Element_GetSet_ContextMenu(label, true, "A|Context|Menu", button)
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

reagirl.NextLine(5)
butt1=reagirl.Button_Add(nil, nil, 0, 0, "Button #1", "The first button.", button)
butt2=reagirl.Button_Add(nil, nil, 0, 0, "Button #2", "The second button.", button)

reagirl.Background_GetSetColor(true, 55, 55, 55)

reagirl.Gui_Open("ReaGirl Testdialog #1", false, "ReaGirl Testdialog #1", "a test dialog that features all available ui-elements.", 355, 165, nil, nil, nil)

function main()
  reagirl.Gui_Manage()

  if reagirl.Gui_IsOpen()==true then reaper.defer(main) end
end
main()
