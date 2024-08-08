--[[
################################################################################
# 
# Copyright (c) 2023-present Meo-Ada Mespotine mespotine.de
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# 
################################################################################
]] 

--[[
TODO: 
  - Gui_Manage: document parameter keep_running for ReaGirl v1.2
  - Sliders: add a way to limit unit to x digits after the punkt. Now: multiply it by 10^number_of_digits, make math.floor, then divide it back by 10^number_of_digits to get only the numbers needed.
             If that doesn't work, use your RoundNumber-function from Ultraschall-API.
  - Labels: boundary rectangle, like in preferences -> Media the Labels "Media item labels" and "Media item buttons"
  - fillable bar: vertical and horizontal, allows you to display a rectangle that gets filled to a certain point, like the "space on disk"-bars on windows of Workbench 1.3.
  - planned ui-elements and features
    > ProgressBars, Color-ui-element, top menus, Toolbar Buttons, graphical vertical tabs, Listviews, Multiline Inputbox, Radio Buttons, virtual ui-elements(for making other guis accessible), decorative elements to hide ui elements, Burgermenu, global context-menu(maybe)
    > fillable rectangles(for something like volume-full-indicator like in WB1.3)
    > color-themes,ui-elements linkable to toggle-states, extstates and ini-file-entries, Gui-Editor, stickyness
    > reagirl.GetChar(), which returns all typed characters when gfx.getchar had been used
    > Shortcut-support(needs mechanism to override certain shortcuts)
  - Gui_Open - w and h parameters=nil mean, make the size of the window big enough to fit all ui-elements
  - Sliders: make default-value optional
  - sticky elements need more work, as tabbing to one might move a ui-element behind a sticky-ui-element. In that case, we need to
    scroll accordingly.
  - Draggable UI-Elements other than Image: use reagirl.DragImageSlot to draw the dragging-image, which will be blit by the Gui_Draw-function
  - EdgeCase: when the scrollbars dis(!)appear while dragging the slider, the slider doesn't drag anymore
              -- see this with a slider -100 to 100 that sets x and y of a button in a way, that scrollbars
                 are drawn when the button is outside of the window(x and y -2 for instance)
               needs to be fixed or is it igual?
  - UI-Elements that manage values(checkbox, slider, dropdownmenu, inputbox) should be linkable to extstates,
            so if the extstate changes, the shown state changes and if the shown state is change, the extstate gets changed too
  - ui-elements, who are anchored to right side/bottom of the window: when shrinking the window, they might scroll outside of left/top-side of the window
    so you can't scroll to them. Maybe fix that?
  - DropDownMenu: line "if gfx.mouse_x>=x+cap_w and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then"
          in DropDownMenu_Manage occasionally produces nil-error on x for some reason...
          Maybe only after using EditMode?
  - general: instead of math.floor() use number // 1 | 0 as this is massively faster for creating integers!
            9.87654 // 1 | 0
            1.23456 // 1 | 0
  - general: for functions that I do not expose to the user(like RoundRect), remove math.XXX()-functioncalls for improved performance.
  - mouse-wheel/mouse-hwheel: sometimes using mousewheel to drag sliders/options in drop down menu stops for no apparent reason; probably fixed now, was due to scrolling issue
  - General: when no run-function is provided, adjust the accessibility-hint acordingly(probably only for image)
  - Inputbox: if they are too small, they aren't drawn properly
  - Inputbox: when dragging the textselection to the left/right edge(during scrolling) the textselection isn't drawn properly(keeps text selected that is outside of scope)
              it will be drawn too far until the "source of the text-selection" is in view
              -- I debugged it in Inputbox_OnMouseMove() and it seems to work now? 
  - Inputbox: allow "Unit" for stuff like " Enable processing on [16] CPUs". Currently you can't have CPUs or anything else as suffix right after the inputbox.
          - but it's doable using labels...but dunno...
  - jumping to ui-elements outside window(means autoscroll to them) doesn't always work
    - ui-elements might still be out of view when jumping to them(x-coordinate outside of window for instance)
  - Slider: disappears when scrolling upwards/leftwards: because of the "only draw neccessary gui-elements"-code, which is buggy for some reason(still is existing?)
  - Slider: when width is too small, drawing bugs appear(i.e. autowidth plus window is too small)
  - Image: reload of scaled image-override; if override==true then it loads only the image.png, not image-2x.png
  - Labels: ACCHoverMessage should hold the text of the paragraph the mouse is hovering above only
            That way, not everything is read out as message to TTS, only the hovered paragraph.
            This makes reading longer label-texts much easier.
            Needs this Osara-Issue to be done, if this is possible in the first place:
              https://github.com/jcsteh/osara/issues/961
  - DropZones: the target should be notified, which ui-element had been dragged to it
  
!!For 10k-UI-Elements(already been tested)!!  
  - Gui_Manage
    -- check for y-coordinates first, then for x-coordinates
    -- only run manage-function of focused and hovered ui-element
  - Gui_Draw
    -- optimize drawing of only visible ui-elements
    
    
--]]


--dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

-- DEBUG:
--reaper.osara_outputMessage=nil

reagirl={}

function reagirl.CheckForDependencies(ReaImGui, js_ReaScript, US_API, SWS, Osara)
  local function OpenURL(url)
  
    if type(url)~="string" then return -1 end
    local OS=reaper.GetOS()
    url="\""..url.."\""
    if OS=="OSX32" or OS=="OSX64" or OS=="macOS-arm64" then
      os.execute("open ".. url)
    elseif OS=="Other" then
      os.execute("xdg-open "..url)
    else
      --reaper.BR_Win32_ShellExecute("open", url, "", "", 0)
      --ACHWAS,ACHWAS2 = reaper.ExecProcess("%WINDIR\\SysWow64\\cmd.exe \"Ultraschall-URL\" /B ".. url, 0)
      os.execute("start \"Ultraschall-URL\" /B ".. url)
    end
    return 1
  end

  local retval=true  
  if US_API==true or js_ReaScript==true or ReaImGui==true or SWS==true or Osara==true then
    if US_API==true and reaper.file_exists(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")==false then
      US_API="Ultraschall API" -- "Ultraschall API" or ""
    else
      US_API=""
    end
    
    if reaper.JS_ReaScriptAPI_Version==nil and js_ReaScript==true then
      js_ReaScript="js_ReaScript" -- "js_ReaScript" or ""
      retval=false
    else
      js_ReaScript=""
    end
    
    if reaper.ImGui_GetVersion==nil and ReaImGui==true then
      ReaImGui="ReaImGui" -- "ReaImGui" or ""
      retval=false
    else
      ReaImGui=""
    end
    
    if reaper.CF_GetSWSVersion==nil and SWS==true then
      SWS="SWS" -- "ReaImGui" or ""
      retval=false
    else
      SWS=""
    end
    
    if reaper.osara_outputMessage==nil and Osara==true then
      Osara="Osara" -- "ReaImGui" or ""
      retval=false
    else
      Osara=""
    end
    
    if Osara=="" and SWS=="" and js_ReaScript=="" and ReaImGui=="" and US_API=="" then return true end
    local state=reaper.MB("This script needs additionally \n\n"..ReaImGui.."\n"..js_ReaScript.."\n"..US_API.."\n"..SWS.."\n"..Osara.."\n\ninstalled to work. Do you want to install them?", "Dependencies required", 4) 
    if state==7 then return false end
    if SWS~="" then
      local A=reaper.MB("SWS can be downloaded from sws-extension.org/download/pre-release/\n\nDo you want to open the download page?", "SWS missing", 4)
      if A==6 then OpenURL("https://sws-extension.org/download/pre-release/") end
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
  return retval
end

if reagirl.CheckForDependencies(false, true, false, true, false)==false then error("Couldn't start Gui yet, dependencies still missing...", 2) end

reagirl.MaxImage=-1
reagirl.osara_AddedMessage=""
function reagirl.GetVersion()
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>GetVersion</slug>
    <requires>
      ReaGirl=1.0
      Reaper=7.03
      Lua=5.4
    </requires>
    <functioncall>number version = reagirl.GetVersion()</functioncall>
    <description>
      Returns the version-number of the installed ReaGirl.
    </description>
    <retvals>
      number version - the version-number of the installed ReaGirl
    </retvals>
    <chapter_context>
      Misc
    </chapter_context>
    <tags>misc, get, version</tags>
  </US_DocBloc>
  --]]
  return 1.0
end

reagirl.osara_outputMessage=reaper.osara_outputMessage
reagirl.osara=reaper.osara_outputMessage

if reaper.GetExtState("ReaGirl", "osara_override")=="" or reaper.GetExtState("ReaGirl", "osara_override")=="true" or reagirl.Settings_Override==true then 
  reagirl.osara_outputMessage=reagirl.osara
else
  reagirl.osara_outputMessage=nil
end

function reagirl.Osara_Debug_Message(message)
  if reaper.GetExtState("ReaGirl", "osara_debug")=="true" then
    reaper.ShowConsoleMsg(message.."\n")
  end
end

--]]
-- let's force some of Reaper's/JS-extension functions to return window-focus to ReaGirl-window
reagirl.GetUserInputs=reaper.GetUserInputs
reagirl.GetUserFileNameForRead=reaper.GetUserFileNameForRead
reagirl.GR_SelectColor=reaper.GR_SelectColor
reagirl.MB=reaper.MB
reagirl.ShowMessageBox=reaper.ShowMessageBox
reagirl.DoActionShortcutDialog=reaper.DoActionShortcutDialog
reagirl.JS_Dialog_BrowseForFolder=reaper.JS_Dialog_BrowseForFolder
reagirl.JS_Dialog_BrowseForOpenFiles=reaper.JS_Dialog_BrowseForOpenFiles
reagirl.JS_Dialog_BrowseForSaveFile=reaper.JS_Dialog_BrowseForOpenFiles
reagirl.JS_Actions_DoShortcutDialog=reaper.JS_Actions_DoShortcutDialog

reagirl.error=error

function error(msg, stack)
  local context=debug.getinfo(stack+1)
  if reaper.GetExtState("ReaGirl", "Error_Message_Destination")=="2" then
    reaper.MB("Error in: "..context.source.."\n\nLine:\t"..context.currentline.."\nErrMsg:\t"..msg, "Error", 0)
  elseif reaper.GetExtState("ReaGirl", "Error_Message_Destination")=="3" then
    reaper.ShowConsoleMsg("> Error in: "..context.source.."\nLine:\t"..context.currentline.."\nErrMsg:\t"..msg.."\n\n")
  end
  reagirl.error(msg, stack+1)
end

--error("Tudelu", 2)

function reaper.GetUserInputs(...)
  local retvals={pcall(reagirl.GetUserInputs, table.unpack({...}))}
  if retvals[1]==false then error("GetUserInputs: "..retvals[2], 2) end
  table.remove(retvals, 1)
  reagirl.Window_SetFocus(true)
  return table.unpack(retvals)
end


function reaper.GetUserFileNameForRead(...)
  local retvals={pcall(reagirl.GetUserFileNameForRead, table.unpack({...}))}
  if retvals[1]==false then error("GetUserFileNameForRead: "..retvals[2], 2) end
  table.remove(retvals, 1)
  reagirl.Window_SetFocus(true)
  return table.unpack(retvals)
end

function reaper.GR_SelectColor(...)
  local retvals={pcall(reagirl.GR_SelectColor, table.unpack({...}))}
  if retvals[1]==false then error("GR_SelectColor: "..retvals[2], 2) end
  table.remove(retvals, 1)
  reagirl.Window_SetFocus(true)
  return table.unpack(retvals)
end

function reaper.MB(...)
  local retvals={pcall(reagirl.MB, table.unpack({...}))}
  if retvals[1]==false then error("MB: "..retvals[2], 2) end
  table.remove(retvals, 1)
  reagirl.Window_SetFocus(true)
  return table.unpack(retvals)
end

function reaper.ShowMessageBox(...)
  local retvals={pcall(reagirl.ShowMessageBox, table.unpack({...}))}
  if retvals[1]==false then error("ShowMessageBox: "..retvals[2], 2) end
  table.remove(retvals, 1)
  reagirl.Window_SetFocus(true)
  return table.unpack(retvals)
end

function reaper.DoActionShortcutDialog(...)
  local retvals={pcall(reagirl.DoActionShortcutDialog, table.unpack({...}))}
  if retvals[1]==false then error("DoActionShortcutDialog: "..retvals[2], 2) end
  table.remove(retvals, 1)
  reagirl.Window_SetFocus(true)
  return table.unpack(retvals)
end

function reaper.JS_Dialog_BrowseForFolder(...)
  local retvals={pcall(reagirl.JS_Dialog_BrowseForFolder, table.unpack({...}))}
  if retvals[1]==false then error("JS_Dialog_BrowseForFolder: "..retvals[2], 2) end
  table.remove(retvals, 1)
  reagirl.Window_SetFocus(true)
  return table.unpack(retvals)
end

function reaper.JS_Dialog_BrowseForOpenFiles(...)
  local retvals={pcall(reagirl.JS_Dialog_BrowseForOpenFiles, table.unpack({...}))}
  if retvals[1]==false then error("JS_Dialog_BrowseForOpenFiles: "..retvals[2], 2) end
  table.remove(retvals, 1)
  reagirl.Window_SetFocus(true)
  return table.unpack(retvals)
end

function reaper.JS_Dialog_BrowseForSaveFile(...)
  local retvals={pcall(reagirl.JS_Dialog_BrowseForSaveFile, table.unpack({...}))}
  if retvals[1]==false then error("JS_Dialog_BrowseForSaveFile: "..retvals[2], 2) end
  table.remove(retvals, 1)
  reagirl.Window_SetFocus(true)
  return table.unpack(retvals)
end

function reaper.JS_Actions_DoShortcutDialog(...)
  local retvals={pcall(reagirl.JS_Actions_DoShortcutDialog, table.unpack({...}))}
  if retvals[1]==false then error("JS_Actions_DoShortcutDialog: "..retvals[2], 2) end
  table.remove(retvals, 1)
  reagirl.Window_SetFocus(true)
  return table.unpack(retvals)
end

reagirl.Elements={}
reagirl.NextLine_Overflow=0 -- will be set when a ui-element in a line is higher than usual
reagirl.EditMode=false
reagirl.EditMode_Grid=false
reagirl.EditMode_FocusedElement=10
reagirl.MoveItAllUp=0
reagirl.MoveItAllRight=0
reagirl.MoveItAllRight_Delta=0
reagirl.MoveItAllUp_Delta=0

-- margin between ui-elements
reagirl.UI_Element_NextX_Margin=10
reagirl.UI_Element_NextY_Margin=2 -- nextline =2

-- offset for first ui-element
reagirl.UI_Element_NextX_Default=20
reagirl.UI_Element_NextY_Default=10

reagirl.UI_Element_NextLineY=0 -- don't change
reagirl.UI_Element_NextLineX=10 -- don't change
reagirl.Font_Size=15

reagirl.mouse={}
reagirl.mouse.down=false
reagirl.mouse.downtime=os.clock()
reagirl.mouse.x=gfx.mouse_x
reagirl.mouse.y=gfx.mouse_y
reagirl.mouse.dragged=false

reagirl.init_refresh=0

reagirl.UI_Element_HeightMargin=5

reagirl.Colors={}
reagirl.Colors.Scrollbar={}
reagirl.Colors.Scrollbar_Background_r=0.39
reagirl.Colors.Scrollbar_Background_g=0.39
reagirl.Colors.Scrollbar_Background_b=0.39

reagirl.Colors.Scrollbar_Foreground_r=0.49
reagirl.Colors.Scrollbar_Foreground_g=0.49
reagirl.Colors.Scrollbar_Foreground_b=0.49
reagirl.Colors.Checkbox_TextBG_r=0.2
reagirl.Colors.Checkbox_TextBG_g=0.2
reagirl.Colors.Checkbox_TextBG_b=0.2
reagirl.Colors.Checkbox_TextFG_r=0.8
reagirl.Colors.Checkbox_TextFG_g=0.8
reagirl.Colors.Checkbox_TextFG_b=0.8
reagirl.Colors.Checkbox_TextFG_disabled_r=0.6
reagirl.Colors.Checkbox_TextFG_disabled_g=0.6
reagirl.Colors.Checkbox_TextFG_disabled_b=0.6
reagirl.Colors.Checkbox_r=0.9843137254901961
reagirl.Colors.Checkbox_g=0.8156862745098039
reagirl.Colors.Checkbox_b=0
reagirl.Colors.Checkbox_rectangle_r=0.5
reagirl.Colors.Checkbox_rectangle_g=0.5
reagirl.Colors.Checkbox_rectangle_b=0.5
reagirl.Colors.Checkbox_disabled_r=0.5843137254901961
reagirl.Colors.Checkbox_disabled_g=0.5843137254901961
reagirl.Colors.Checkbox_disabled_b=0
reagirl.Colors.Checkbox_background_r=0.234
reagirl.Colors.Checkbox_background_g=0.234
reagirl.Colors.Checkbox_background_b=0.234
reagirl.Colors.Slider_TextBG_r=0.2
reagirl.Colors.Slider_TextBG_g=0.2
reagirl.Colors.Slider_TextBG_b=0.2
reagirl.Colors.Slider_TextFG_r=0.8
reagirl.Colors.Slider_TextFG_g=0.8
reagirl.Colors.Slider_TextFG_b=0.8
reagirl.Colors.Slider_TextFG_disabled_r=0.6
reagirl.Colors.Slider_TextFG_disabled_g=0.6
reagirl.Colors.Slider_TextFG_disabled_b=0.6
reagirl.Colors.Slider_DefaultLine_r=0.584
reagirl.Colors.Slider_DefaultLine_g=0.584
reagirl.Colors.Slider_DefaultLine_b=0.584
reagirl.Colors.Slider_Border_r=0.5
reagirl.Colors.Slider_Border_g=0.5
reagirl.Colors.Slider_Border_b=0.5
reagirl.Colors.Slider_Center_r=0.7
reagirl.Colors.Slider_Center_g=0.7
reagirl.Colors.Slider_Center_b=0.7
reagirl.Colors.Slider_Center_disabled_r=0.6
reagirl.Colors.Slider_Center_disabled_g=0.6
reagirl.Colors.Slider_Center_disabled_b=0.6
reagirl.Colors.Slider_Circle_1_r=0.584
reagirl.Colors.Slider_Circle_1_g=0.584
reagirl.Colors.Slider_Circle_1_b=0.584
reagirl.Colors.Slider_Circle_2_r=0.2725490196078431
reagirl.Colors.Slider_Circle_2_g=0.2725490196078431
reagirl.Colors.Slider_Circle_2_b=0.2725490196078431
reagirl.Colors.Slider_Circle_center_r=0.584
reagirl.Colors.Slider_Circle_center_g=0.584
reagirl.Colors.Slider_Circle_center_b=0.584
reagirl.Colors.Slider_Circle_center_disabled_r=0.9843137254901961
reagirl.Colors.Slider_Circle_center_disabled_g=0.8156862745098039
reagirl.Colors.Slider_Circle_center_disabled_b=0
reagirl.Colors.Tabs_Border_Tabs_r=0.403921568627451
reagirl.Colors.Tabs_Border_Tabs_g=0.403921568627451
reagirl.Colors.Tabs_Border_Tabs_b=0.403921568627451
reagirl.Colors.Tabs_Inner_Tabs_Selected_r=0.253921568627451
reagirl.Colors.Tabs_Inner_Tabs_Selected_g=0.253921568627451
reagirl.Colors.Tabs_Inner_Tabs_Selected_b=0.253921568627451
reagirl.Colors.Tabs_Inner_Tabs_Unselected_r=0.153921568627451
reagirl.Colors.Tabs_Inner_Tabs_Unselected_g=0.153921568627451
reagirl.Colors.Tabs_Inner_Tabs_Unselected_b=0.153921568627451
reagirl.Colors.Tabs_Text_r=0.8
reagirl.Colors.Tabs_Text_g=0.8
reagirl.Colors.Tabs_Text_b=0.8
reagirl.Colors.Tabs_Border_Background_r=0.403921568627451
reagirl.Colors.Tabs_Border_Background_g=0.403921568627451
reagirl.Colors.Tabs_Border_Background_b=0.403921568627451
reagirl.Colors.Tabs_Inner_Background_r=0.253921568627451
reagirl.Colors.Tabs_Inner_Background_g=0.253921568627451
reagirl.Colors.Tabs_Inner_Background_b=0.253921568627451

-- Cursor-Blinkspeed for inputboxes, live-settable in extstate ReaGirl -> Inputbox_BlinkSpeed
-- 7 and higher is supported
if reaper.GetExtState("ReaGirl", "Inputbox_BlinkSpeed")=="" then
  reagirl.Inputbox_BlinkSpeed=33
else
  reagirl.Inputbox_BlinkSpeed=tonumber(reaper.GetExtState("ReaGirl", "Inputbox_BlinkSpeed"))
end

-- Blinkspeed for the focus-rectangle, live-settable in extstate 
--    ReaGirl -> FocusRect_BlinkSpeed - sets the speed of the blinking
-- and 
--    ReaGirl -> FocusRectangle_BlinkTime - sets the duration in seconds for how long the blinking shall happen
-- 7 and higher is supported
reagirl.FocusRectangle_Alpha=0.4
reagirl.FocusRectangle_Blink=0
reagirl.FocusRectangle_BlinkTime=0
if reaper.GetExtState("ReaGirl", "FocusRectangle_BlinkSpeed")=="" then
  reagirl.FocusRectangle_BlinkSpeed=nil
else
  reagirl.FocusRectangle_BlinkSpeed=tonumber(reaper.GetExtState("ReaGirl", "FocusRectangle_BlinkSpeed"))
end

if reaper.GetExtState("ReaGirl", "FocusRectangle_BlinkTime")=="" then
  reagirl.FocusRectangle_BlinkTime=nil
else
  reagirl.FocusRectangle_BlinkTime=tonumber(reaper.GetExtState("ReaGirl", "FocusRectangle_BlinkTime"))
end
  
function reagirl.FormatNumber(n, p)
  --reaper.MB(n,"",0)
  if n<0.00000000000001 then return 0 end
  --if number<0.0000001 then return 0 end
  --[[
  local adder, fraction, fraction2, int
  number=number+0.0
  int, fraction=tostring(number):match("(.-)%.(.*)")

  adder=0
  if fraction:len()>length_of_fraction then 
    fraction2=fraction:sub(1,length_of_fraction)
    if roundit==true and tonumber(fraction:sub(length_of_fraction+1, length_of_fraction+1))>5 then adder=1 end
    adder=adder/(10^(length_of_fraction))
  else 
    fraction2=fraction
  end
  return int.."."..(fraction2+adder)
  --]]
  local p = (math.log(math.abs(n), 10) // 1) + (p or 3) + 1
  if tostring(p):match("INF")~=nil then p=0 end
  return ('%%.%dg'):format(p):format(n)
end

function string.has_control(String)
  if type(String)~="string" then error("bad argument #1, to 'has_control' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%c")~=nil
end

function string.has_alphanumeric_plus_underscore(String)
  if type(String)~="string" then error("bad argument #1, to 'has_control' (string expected, got "..type(source_string)..")", 2) end
  return String:match("[%w%_]")~=nil
end

function string.has_alphanumeric(String)
  if type(String)~="string" then error("bad argument #1, to 'has_alphanumeric' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%w")~=nil
end

function string.has_non_alphanumeric(String)
  if type(String)~="string" then error("bad argument #1, to 'has_non_alphanumeric' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%w")==nil
end

function string.has_letter(String)
  if type(String)~="string" then error("bad argument #1, to 'has_letter' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%a")~=nil
end

function string.has_digits(String)
  if type(String)~="string" then error("bad argument #1, to 'has_digits' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%d")~=nil
end

function string.has_printables(String)
  if type(String)~="string" then error("bad argument #1, to 'has_printables' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%g")~=nil
end

function string.has_uppercase(String)
  if type(String)~="string" then error("bad argument #1, to 'has_uppercase' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%u")~=nil
end

function string.has_lowercase(String)
  if type(String)~="string" then error("bad argument #1, to 'has_lowercase' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%l")~=nil
end

function string.has_space(String)
  if type(String)~="string" then error("bad argument #1, to 'has_space' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%s")~=nil
end

function string.has_hex(String)
  if type(String)~="string" then error("bad argument #1, to 'has_hex' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%x")~=nil
end

function string.utf8_sub(source_string, startoffset, endoffset)
  -- written by CFillion for his Interactive ReaScript-Tool, available in the ReaTeam-repository(install via ReaPack)
  -- thanks for allowing me to use it :)
  startoffset = utf8.offset(source_string, startoffset)
  if not startoffset then return '' end -- i is out of bounds

  if endoffset and (endoffset > 0 or endoffset < -1) then
    endoffset = utf8.offset(source_string, endoffset + 1)
    if endoffset then endoffset = endoffset - 1 end
  end

  return string.sub(source_string, startoffset, endoffset)
end

function string.utf8_len(source_string)
  if type(source_string)~="string" then error("bad argument #1, to 'utf8_len' (string expected, got "..type(source_string)..")", 2) end
  return utf8.len(source_string)
end

function reagirl.GetMediaExplorerHWND()
  local A=reaper.GetToggleCommandState(50124)
  if A~=0 then return reaper.OpenMediaExplorer("", false) else return end
end 

function reagirl.MediaExplorer_OnCommand(actioncommandid)
  local HWND=reagirl.GetMediaExplorerHWND()
  if HWND==nil then return end
  local Actioncommandid=reaper.NamedCommandLookup(actioncommandid)
  return reaper.JS_Window_OnCommand(HWND, tonumber(Actioncommandid))
end

function reagirl.NextLine_SetDefaults(x, y)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>NextLine_SetDefaults</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.NextLine_SetDefaults(optional integer x, optional integer y)</functioncall>
  <description>
    Set the defaults for new lines in the gui-elements, when using autopositioning.
    
    Y sets the y-offset of the first ui-element in the gui, x the x-offset for each line
  </description>
  <parameters>
    optional integer x - the default-offset for the x-position of the first ui-element in a new line
    optional integer y - the default-offset for the y-position of the first ui-element in a gui
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <tags>ui-elements, set, next line, defaults</tags>
</US_DocBloc>
--]]
  if x~=nil and math.type(x)~="integer" then error("NextLine_SetDefaults: param #1 - must be either nil or an integer", -1) return end
  if y~=nil and math.type(y)~="integer" then error("NextLine_SetDefaults: param #2 - must be either nil or an integer", -1) return end
  if x<0 then error("NextLine_SetDefaults: param #1 - must be bigger or equal 0", -1) return end
  if y<0 then error("NextLine_SetDefaults: param #2 - must be bigger or equal 0", -1) return end
  if x~=nil then
    reagirl.UI_Element_NextX_Default=x
  end
  
  if y~=nil then
    reagirl.UI_Element_NextY_Default=y  
  end
end

function reagirl.NextLine_GetDefaults()
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>NextLine_GetDefaults</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer x, integer y = reagirl.NextLine_GetDefaults()</functioncall>
  <description>
    Get the defaults for new lines in the gui-elements, when using autopositioning.
    
    Y is the y-offset of the first ui-element in the gui, x the x-offset for each line
  </description>
  <retvals>
    integer x - the default-offset for the x-position of the first ui-element in a new line
    integer y - the default-offset for the y-position of the first ui-element in a gui
  </retvals>
  <chapter_context>
    UI Elements
  </chapter_context>
  <tags>ui-elements, get, next line, defaults</tags>
</US_DocBloc>
--]]
  return reagirl.UI_Element_NextX_Default, reagirl.UI_Element_NextY_Default
end

function reagirl.Gui_ReserveImageBuffer()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ReserveImageBuffer</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer image_buffer_index = reagirl.Gui_ReserveImageBuffer()</functioncall>
  <description>
    Reserves a framebuffer which will not be used by ReaGirl for drawing.
    So if you want to code additional ui-elements, you can reserve an image buffer for blitting that way.
    
    nil, if no additional framebuffer is available
  </description>
  <retvals>
    integer image_buffer_index - the index of a framebuffer you can safely use; nil, no more framebuffer available
  </retvals>
  <chapter_context>
    Misc
  </chapter_context>
  <tags>gui, reserve, image buffer</tags>
</US_DocBloc>
--]]
  -- reserves an image buffer for custom UI elements
  -- returns -1 if no buffer can be reserved anymore
  if reagirl.MaxImage>=1000 then return  end
  reagirl.MaxImage=reagirl.MaxImage+1
  return reagirl.MaxImage
end

reagirl.DragImageSlot=reagirl.Gui_ReserveImageBuffer()

function reagirl.Gui_PreventScrollingForOneCycle(keyboard, mousewheel_swipe, scroll_buttons)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_PreventScrollingForOneCycle</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Gui_PreventScrollingForOneCycle(optional boolean keyboard, optional boolean mousewheel_swipe, optional boolean scroll_buttons)</functioncall>
  <description>
    Prevents the scrolling of the gui via keyboard/mousewheel/swiping for this defer-cycle.
  </description>
  <parameters>
    optional boolean keyboard - true, prevent the scrolling via keyboard; false, scroll; nil, don't change
    optional boolean mousewheel_swipe - true, prevent the scrolling via mousewheel/swiping; false, scroll; nil, don't change
  </parameters>
  <chapter_context>
    Gui
  </chapter_context>
  <tags>gui, set, override, prevent, scrolling</tags>
</US_DocBloc>
--]]
  if keyboard~=nil and type(keyboard)~="boolean" then error("Gui_PreventScrollingForOneCycle: param #1 - must be either nil or a boolean") end
  if mousewheel_swipe~=nil and type(mousewheel_swipe)~="boolean" then error("Gui_PreventScrollingForOneCycle: param #2 - must be either nil or a boolean") end
  if scroll_buttons~=nil and type(scroll_buttons)~="boolean" then error("Gui_PreventScrollingForOneCycle: param #3 - must be either nil or a boolean") end
  
  if mousewheel_swipe~=nil and reagirl.Scroll_Override_MouseWheel~=true then
    reagirl.Scroll_Override_MouseWheel=mousewheel_swipe
  end
  if keyboard~=nil and reagirl.Scroll_Override~=true then 
    reagirl.Scroll_Override=keyboard
  end
  if scroll_buttons~=nil and reagirl.Scroll_Override_ScrollButtons~=true then 
    reagirl.Scroll_Override_ScrollButtons=scroll_buttons
  end
end

function reagirl.Gui_PreventCloseViaEscForOneCycle()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_PreventCloseViaEscForOneCycle</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Gui_PreventScrollingForOneCycle()</functioncall>
  <description>
    Prevents the closing of the gui via esc-key for one defer-cycle.
  </description>
  <chapter_context>
    Gui
  </chapter_context>
  <tags>gui, set, override, prevent, close via esc, escape</tags>
</US_DocBloc>
--]]
  reagirl.Gui_PreventCloseViaEscForOneCycle_State=true
end

function reagirl.Gui_PreventEnterForOneCycle()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_PreventEnterForOneCycle</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Gui_PreventEnterForOneCycle()</functioncall>
  <description>
    Prevents the user from hitting the enter-key for one cycle, so the run-function for the enter-key is not run in this cycle.
  </description>
  <chapter_context>
    Gui
  </chapter_context>
  <tags>gui, set, override, prevent, enter key</tags>
</US_DocBloc>
--]]
  reagirl.Gui_PreventEnterForOneCycle_State=true
end

function reagirl.IsValidGuid(guid, strict)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsValidGuid</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>boolean retval = reagirl.IsValidGuid(string guid, boolean strict)</functioncall>
  <description>
    Checks, if guid is a valid guid. Can also be used for strings, that contain a guid somewhere in them(strict=false)
    
    A valid guid is a string that follows the following pattern:
    {........-....-....-....-............}
    where . is a hexadecimal value(0-F)
  </description>
  <parameters>
    string guid - the guid to check for validity
    boolean strict - true, guid must only be the valid guid; false, guid must contain a valid guid somewhere in it(means, can contain trailing or preceding characters)
  </parameters>
  <retvals>
    boolean retval - true, guid is/contains a valid guid; false, guid isn't/does not contain a valid guid
  </retvals>
  <chapter_context>
    Misc
  </chapter_context>
  <tags>helper functions, guid, check</tags>
</US_DocBloc>
--]]
  if type(guid)~="string" then return false end
  if type(strict)~="boolean" then error("IsValidGuid: param #2 - must be a boolean", -2) return false end
  if strict==true and guid:match("^{%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x%}$")~=nil then return true
  elseif strict==false and guid:match(".-{%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x%}.*")~=nil then return true
  else return false
  end
end

function reagirl.RoundRect(x, y, w, h, r, antialias, fill, square_top_left, square_bottom_left, square_top_right, square_bottom_right)
--[[
<US_  DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>RoundRect</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.RoundRect(integer x, integer y, integer w, integer h, number r, number antialias, number fill, optional boolean square_top_left, optional boolean square_bottom_left, optional boolean square_top_right, optional boolean square_bottom_right)</functioncall>
  <description>
    This draws a rectangle with rounded corners to x and y
  </description>
  <parameters>
    integer x - the x-position of the rectangle
    integer y - the y-position of the rectangle
    integer w - the width of the rectangle
    integer h - the height of the rectangle
    number r - the radius of the corners of the rectangle
    number antialias - 1, antialias; 0, no antialias
    number fill - 1, filled; 0, not filled
    optional boolean square_top_left - true, make top-left corner square; false or nil, make it round
    optional boolean square_bottom_left - true, make bottom-left corner square; false or nil, make it round
    optional boolean square_top_right - true, make top-right corner square; false or nil, make it round
    optional boolean square_bottom_right - true, make bottom-right corner square; false or nil, make it round
  </parameters>
  <chapter_context>
    Misc
  </chapter_context>
  <tags>gfx, functions, round rect, draw</tags>
</US_DocBloc>
]]
  if math.type(x)~="integer" then error("RoundRect: param #1 - must be an integer", 2) end
  if math.type(y)~="integer" then error("RoundRect: param #2 - must be an integer", 2) end
  if math.type(w)~="integer" then error("RoundRect: param #3 - must be an integer", 2) end
  if math.type(h)~="integer" then error("RoundRect: param #4 - must be an integer", 2) end
  if type(r)~="number" then error("RoundRect: param #5 - must be a number", 2) end
  --if r>12 then r=12 end
  if type(antialias)~="number" then error("RoundRect: param #6 - must be a number", 2) end
  if type(fill)~="number" then error("RoundRect: param #7 - must be a number", 2) end
  if square_top_left~=nil     and type(square_top_left)~="boolean"     then error("RoundRect: param #8 - must be a boolean or nil", 2)  end
  if square_bottom_left~=nil  and type(square_bottom_left)~="boolean"  then error("RoundRect: param #9 - must be a boolean or nil", 2)  end
  if square_top_right~=nil    and type(square_top_right)~="boolean"    then error("RoundRect: param #10 - must be a boolean or nil", 2) end
  if square_bottom_right~=nil and type(square_bottom_right)~="boolean" then error("RoundRect: param #11 - must be a boolean or nil", 2) end
  local offset
  local aa = antialias or 1
  fill = fill or 0

  if fill == 0 or false then
    -- unfilled
    if h >=2*r then 
      if square_top_left~=true then
        gfx.arc(x+r, y+r, r, -1.6, 0, aa) -- top left
      else
        gfx.line(x, y, x+r,   y, aa)
        gfx.line(x, y,   x, y+r, aa)
      end
      if square_top_right~=true then
        gfx.arc(x+w-r, y+r, r, 0, 1.6, aa) -- top right
      else
        gfx.line(x+w, y, x+w-r,   y, aa)
        gfx.line(x+w, y,   x+w, y+r, aa)
      end
      if square_bottom_left~=true then
        gfx.arc(x+r, y+h-r, r, -3.2, -1.6, aa) -- bottom left
      else
        gfx.line(x, y+h, x+r,   y+h, aa)
        gfx.line(x, y+h,   x, y+h-r, aa)
      end
      if square_bottom_right~=true then
        gfx.arc(x+w-r, y+h-r, r,  1.6,  3.2, aa) -- bottom right
      else
        gfx.line(x+w, y+h-r,   x+w, y+h, aa)
        gfx.line(x+w,   y+h, x+w-r, y+h, aa)
      end
      
      gfx.line(x+r,     y, x+w-r,     y, aa) -- top line
      gfx.line(x+r,   y+h, x+w-r,   y+h, aa) -- bottom line
      gfx.line(x,     y+r,     x, y+h-r, aa) -- left edge
      gfx.line(x+w,   y+r,   x+w, y+h-r, aa) -- right edge
    end
  else
    -- filled
    
    -- Corners
    if h >=2*r then 
      local filled=1
      if 1+y+h-r*2<y then offset=y-(1+y+h-r*2) else offset=0 end
      
      -- top-left
      if square_top_left~=true then
        gfx.circle(x + r, y + r, r, 1, aa)
      else
        gfx.rect(x, y, r, r, filled)
      end
      
      -- bottom-left
      if square_bottom_left~=true then
        gfx.circle(x + r, offset+y + h - r, r, filled, aa)
      else
        gfx.rect(x, offset+y+h-r, r, r+1, filled)
      end
      
      -- top-right
      if square_top_right~=true then
        gfx.circle(x + w - r, y + r, r, filled, aa)
      else
        gfx.rect(x+w-r, y, r+1, r+1, filled)
      end
      
      -- bottom-right
      if square_bottom_right~=true then
        gfx.circle(x + w - r, y + h - r, r , filled, aa)
      else
        gfx.rect(x+w-r, y+h-r, r+1, r+1, filled)
      end
      
      -- Ends
      gfx.rect(x, y + r, r, h - r * 2, filled)
      gfx.rect(x + w - r, y + r, r + 1, h - r * 2, filled)
  
      -- Body + sides
      gfx.rect(x + r, y, w - r * 2, h + 1, filled)
    else
      local filled=1
      r = math.ceil(h / 2)-1
      local offset
      if 1+y+h-r*2<y then offset=y-(1+y+h-r*2) else offset=0 end
      -- Ends
      --gfx.set(1,0,0)
      gfx.circle(x + r,     y + r, r, filled, aa)
      --gfx.set(1)
      gfx.circle(x + w - r-1, y + r, r, filled, aa)
      if square_top_left==true then    gfx.rect(x,       y,   w/2, h/2, filled) end
      if square_top_right==true then   gfx.rect(x+w-w/2, y, w/2+1, h/2, filled) end
      
      if square_bottom_right==true then gfx.rect(x+w-w/2, y+h-(h/2), w/2+1,   h/2, filled) end
      if square_bottom_left==true  then gfx.rect(x,       y+h-(h/2), w/2, h/2, filled) end
      -- Body
      gfx.rect(x + r, y, w - ((h/2) * 2), h, filled)
    end
  end
end



function reagirl.BlitText_AdaptLineLength(text, x, y, width, height, align)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>BlitText_AdaptLineLength</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>boolean retval, integer width, integer height = reagirl.BlitText_AdaptLineLength(string text, integer x, integer y, integer width, optional integer height, optional integer align)</functioncall>
  <description>
    This draws text to x and y and adapts the line-lengths to fit into width and height.
  </description>
  <parameters>
    string text - the text to be shown
    integer x - the x-position of the text
    integer y - the y-position of the text
    integer width - the maximum width of a line in pixels; text after this will be put into the next line
    optional integer height - the maximum height the text shall be shown in pixels; everything after this will be truncated
    optional integer align - 0 or nil, left aligned text; 1, center text
  </parameters>
  <retvals>
    boolean retval - true, text-blitting was successful; false, text-blitting was unsuccessful
  </retvals>
  <chapter_context>
    Misc
  </chapter_context>
  <target_document>US_Api_GFX</target_document>
  <source_document>ultraschall_gfx_engine.lua</source_document>
  <tags>gfx, functions, blit, text, line breaks, adapt line length</tags>
</US_DocBloc>
]]
  if type(text)~="string" then error("GFX_BlitText_AdaptLineLength: param #1 - must be a string", 2) end
  if math.type(x)~="integer" then error("GFX_BlitText_AdaptLineLength: param #2 - must be an integer", 2) end
  if math.type(y)~="integer" then error("GFX_BlitText_AdaptLineLength: param #3 - must be an integer", 2) end
  if math.type(width)~="integer" then error("GFX_BlitText_AdaptLineLength: param #4 - must be an integer", 2) end
  if height~=nil and math.type(height)~="number" then error("GFX_BlitText_AdaptLineLength: param #5 - must be either nil or an integer", 2) end
  if align~=nil and math.type(align)~="integer" then error("GFX_BlitText_AdaptLineLength: param #6 - must be either nil or an integer", 2) end
  local l=gfx.measurestr("A")
  if width<gfx.measurestr("A") then error("GFX_BlitText_AdaptLineLength: param #4 - must be at least "..l.." pixels for this font.", -7) end

  if align==nil or align==0 then center=0 
  elseif align==1 then center=1 
  end
  local newtext=""

  for a=0, 100 do
    newtext=newtext..text:sub(a,a)
    local nwidth, nheight = gfx.measurestr(newtext)
    if nwidth>width then
      newtext=newtext:sub(1,a-1).."\n"..text:sub(a,a)
    end
    if height~=nil and nheight>=height then newtext=newtext:sub(1,-3) break end
  end
  local old_x, old_y=gfx.x, gfx.y
  gfx.x=x
  gfx.y=y
  local xwidth, xheight = gfx.measurestr(newtext)
  gfx.drawstr(newtext.."\n  ", center)--xwidth+3+x, xheight)
  gfx.x=old_x
  gfx.y=old_y
  local w,h=gfx.measurestr(newtext)
  return true, math.tointeger(w), math.tointeger(h)
end

function reagirl.ResizeImageKeepAspectRatio(image, neww, newh, bg_r, bg_g, bg_b)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ResizeImageKeepAspectRatio</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>boolean retval = reagirl.ResizeImageKeepAspectRatio(integer image, integer neww, integer newh, optional number r, optional number g, optional number b)</functioncall>
  <description>
    Resizes an image, keeping its aspect-ratio. You can set a background-color for non rectangular-images.
    
    Resizing upwards will probably cause artifacts!
    
    Note: this uses image 1023 as temporary buffer so don't use image 1023, when using this function!
  </description>
  <parameters>
    integer image - an image between 0 and 1022, that you want to resize
    integer neww - the new width of the image
    integer newh - the new height of the image
    optional number r - the red-value of the background-color; nil, = 0
    optional number g - the green-value of the background-color; nil, = 0
    optional number b - the blue-value of the background-color; nil, = 0
  </parameters>
  <retvals>
    boolean retval - true, blitting was successful; false, blitting was unsuccessful
  </retvals>
  <chapter_context>
    Misc
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, resize, image</tags>
</US_DocBloc>
]]
  if math.type(image)~="integer" then error("ResizeImageKeepAspectRatio: param #1 - must be an integer", 2) end
  if math.type(neww)~="integer" then error("ResizeImageKeepAspectRatio: param #2 - must be an integer", 2) end
  if math.type(newh)~="integer" then error("ResizeImageKeepAspectRatio: param #3 - must be an integer", 2) end
  
  if bg_r~=nil and type(bg_r)~="number" then error("ResizeImageKeepAspectRatio: param #4 - must be either nil or a number", 2) end
  if bg_r==nil then bg_r=0 end
  if bg_g~=nil and type(bg_g)~="number" then error("ResizeImageKeepAspectRatio: param #5 - must be either nil or a number", 2) end
  if bg_g==nil then bg_g=0 end
  if bg_b~=nil and type(bg_b)~="number" then error("ResizeImageKeepAspectRatio: param #6 - must be either nil or a number", 2) end
  if bg_b==nil then bg_b=0 end
  
  if image<0 or image>1022 then error("ResizeImageKeepAspectRatio: param #1 - must be between 0 and 1022", 2) end
  if neww<0 or neww>8192 then error("ResizeImageKeepAspectRatio: param #2 - must be between 0 and 8192", 2) end
  if newh<0 or newh>8192 then error("ResizeImageKeepAspectRatio: param #3 - must be between 0 and 8192", 2) end
  
  local old_r, old_g, old_g=gfx.r, gfx.g, gfx.b  
  local old_dest=gfx.dest
  local oldx, oldy = gfx.x, gfx.y
  
  local x,y=gfx.getimgdim(image)
  local ratiox=((100/x)*neww)/100
  local ratioy=((100/y)*newh)/100
  local ratio
  if ratiox<ratioy then ratio=ratiox else ratio=ratioy end
  gfx.setimgdim(1023, neww, newh)
  gfx.dest=1023
  gfx.set(bg_r, bg_g, bg_b)
  gfx.rect(0,0,8192,8192,1)
  gfx.x=0
  gfx.y=0
  gfx.blit(image, ratio, 0)

  gfx.setimgdim(image, neww, newh)
  gfx.dest=image
  if bg_r~=nil then gfx.r=bg_r end
  if bg_g~=nil then gfx.g=bg_g end
  if bg_b~=nil then gfx.b=bg_b end
  x,y=gfx.getimgdim(image)
  gfx.rect(-1,-1,x+1,y+1,1)
  gfx.set(old_r, old_g, old_g)
  gfx.blit(1023, 1, 0)
  gfx.dest=old_dest
  gfx.x, gfx.y = oldx, oldy
  return true
end

--reagirl.ResizeImageKeepAspectRatio(1, 1, 1, 1, 1, 1)


function reagirl.Window_Reposition(x_or_y)
  if x_or_y==true then
    if reagirl.BoundaryY_Max-gfx.h<-reagirl.MoveItAllUp then
      local dif=-(reagirl.BoundaryY_Max-gfx.h)-reagirl.MoveItAllUp
      reagirl.MoveItAllUp=reagirl.MoveItAllUp+dif
    end
    if reagirl.MoveItAllUp>0 then reagirl.MoveItAllUp=0 end
  else
    if reagirl.BoundaryX_Max-gfx.w<-reagirl.MoveItAllRight then
      local dif=-(reagirl.BoundaryX_Max-gfx.w)-reagirl.MoveItAllRight
      reagirl.MoveItAllRight=reagirl.MoveItAllRight+dif
    end
    if reagirl.MoveItAllRight>0 then reagirl.MoveItAllRight=0 end
  end
end

function reagirl.Window_Open(...)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Window_Open</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    JS=0.964
    Lua=5.4
  </requires>
  <functioncall>integer retval, optional HWND hwnd = reagirl.Window_Open(string title, optional integer width, optional integer height, optional integer dockstate, optional integer xpos, optional integer ypos)</functioncall>
  <description>
    Opens a new graphics window and returns its HWND-windowhandler object.
  </description>
  <parameters>
    string title - the name of the window, which will be shown in the title of the window
    optional integer width -  the width of the window; minmum is 50
    optional integer height -  the height of the window; minimum is 16
    optional integer dockstate - &1=0, undocked; &1=1, docked
    optional integer xpos - x-position of the window in pixels; minimum is -80; nil, to center it horizontally
    optional integer ypos - y-position of the window in pixels; minimum is -15; nil, to center it vertically
  </parameters>
  <retvals>
    number retval - 1.0, if window is opened
    optional HWND hwnd - when JS-extension is installed, the window-handler of the newly created window; can be used with JS_Window_xxx-functions of the JS-extension-plugin
  </retvals>
  <chapter_context>
    Window
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>init, window, create, hwnd</tags>
</US_DocBloc>
]]
  --gfx.quit()
  local parms={...}
  --reaper.MB(tostring(parms[5]), tostring(parms[6]), 0)
  if type(parms[1])~="string" then error("Window_Open: param #1 - must be a string", 2) end
  if parms[2]~=nil and type(parms[2])~="number" then error("Window_Open: param #2 - must be either nil or an integer", 2) end
  if parms[3]~=nil and type(parms[3])~="number" then error("Window_Open: param #3 - must be either nil or an integer", 2) end
  if parms[4]~=nil and type(parms[4])~="number" then error("Window_Open: param #4 - must be either nil or an integer", 2) end
  if parms[5]~=nil and type(parms[5])~="number" then error("Window_Open: param #5 - must be either nil or an integer", 2) end
  if parms[6]~=nil and type(parms[6])~="number" then error("Window_Open: param #6 - must be either nil or an integer", 2) end
  
  local AAA, AAA2=reaper.ThemeLayout_GetLayout("tcp", -3)
  local minimum_scale_for_dpi, maximum_scale_for_dpi = 1,1--ultraschall.GetScaleRangeFromDpi(tonumber(AAA2))
  maximum_scale_for_dpi = math.floor(maximum_scale_for_dpi)
  local A=gfx.getchar(65536)
  local HWND, retval
  
  if A&4==0 then
    reagirl.Window_RescaleIfNeeded()
    --reagirl.MoveItAllRight=0
    --reagirl.MoveItAllUp=0
    local parms={...}
    local temp=parms[1]
    if parms[2]==nil then parms[2]=640 end
    if parms[3]==nil then parms[3]=400 end
    if parms[4]==nil then parms[4]=0 end
    -- check, if the given windowtitle is a valid one, 
    -- if that's not the case, use "" as name
    if temp==nil or type(temp)~="string" then temp="" end  
    if type(parms[1])~="string" then parms[1]="" 
    end
    
    parms[2]=parms[2]*reagirl.Window_CurrentScale
    parms[3]=parms[3]*reagirl.Window_CurrentScale
    
    local A1,B,C,D=reaper.my_getViewport(0,0,0,0, 0,0,0,0, false)
    parms[2]=parms[2]*minimum_scale_for_dpi
    parms[3]=parms[3]*minimum_scale_for_dpi
    if parms[5]==nil then
      parms[5]=(C-parms[2])/2
    end
    if parms[6]==nil then
      parms[6]=(D-parms[3])/2
    end
    if reaper.JS_Window_SetTitle==nil then 
      local B=gfx.init(table.unpack(parms)) 
      return B 
    end
    
    -- check for a window-name not being used yet, which is 
    -- windowtitleX, where X is a number
    local freeslot=0
    for i=0, 65555 do
      if reaper.JS_Window_Find(parms[1]..i, true)==nil then freeslot=i break end
    end
    -- use that found, unused windowtitle as temporary windowtitle
    parms[1]=parms[1]..freeslot
    
    -- open window  
    retval=gfx.init(table.unpack(parms))
    
    -- find the window with the temporary windowtitle and get its HWND
    HWND=reaper.JS_Window_Find(parms[1], true)
    
    -- rename it to the original title
    if HWND~=nil then reaper.JS_Window_SetTitle(HWND, temp) end
    reagirl.GFX_WindowHWND=HWND    
  else 
    local A1,B,C,D=reaper.my_getViewport(0,0,0,0, 0,0,0,0, false)
    parms[1]=""
    local _, _, _, _, _, w2, _, h2 = reagirl.Gui_GetBoundaries()
    
    if parms[2]==nil then 
      parms[2]=w2+10
    end
    if parms[3]==nil then
      parms[3]=h2+10
    end
    if parms[5]==nil then
      parms[5]=(C-parms[2])/2
    end
    if parms[6]==nil then
      parms[6]=(D-parms[3])/2
    end
    local B=gfx.init(table.unpack(parms)) 
    retval=0.0
  end
  
  return retval, reagirl.GFX_WindowHWND
end

function reagirl.Window_SetFocus(accmessage)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Window_SetFocus</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    JS=0.964
    Lua=5.4
  </requires>
  <functioncall>reagirl.Window_SetFocus()</functioncall>
  <description>
    Sets window focus back to the ReaGirl-gui-window.
  </description>
  <chapter_context>
    Window
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>refocus, focus, window, hwnd</tags>
</US_DocBloc>
]]
  local window_state=gfx.getchar(65536)
  if window_state&2==0 then
    if reaper.JS_Window_SetFocus~=nil then
      reaper.JS_Window_SetFocus(reagirl.GFX_WindowHWND)
    end
    local add=""
    if accmessage~=true then
      if "ReaGirl-Window "..reagirl.Window_Title.." re-focused."==reagirl.Elements["GlobalAccHoverMessage"] then add=" " end
      reagirl.Elements["GlobalAccHoverMessage"]="ReaGirl-Gui "..reagirl.Window_Title.." re-focused."..add
    end
  end
end

function reagirl.Window_RescaleIfNeeded()
  -- rescales window and gui, if the scaling changes
  local scale
  
  if reagirl.Window_CurrentScale_Override==nil then
    if tonumber(reaper.GetExtState("ReaGirl", "scaling_override"))~=nil then
      scale=tonumber(reaper.GetExtState("ReaGirl", "scaling_override"))
    else
      local retval, dpi = reaper.ThemeLayout_GetLayout("tcp", -3)
      local dpi=tonumber(dpi)
      
      if dpi<384 then scale=1
      elseif dpi>=384 and dpi<512 then scale=1--.5
      elseif dpi>=512 and dpi<640 then scale=2
      elseif dpi>=640 and dpi<768 then scale=2--.5
      elseif dpi>=768 and dpi<896 then scale=3
      elseif dpi>=896 and dpi<1024 then scale=3--.5
      elseif dpi>=1024 and dpi<1152 then scale=4 
      elseif dpi>=1152 and dpi<1280 then scale=4--.5
      elseif dpi>=1280 and dpi<1408 then scale=5
      elseif dpi>=1408 and dpi<1536 then scale=5--.5
      elseif dpi>=1536 and dpi<1664 then scale=6
      elseif dpi>=1664 and dpi<1792 then scale=6--.5
      elseif dpi>=1792 and dpi<1920 then scale=7
      elseif dpi>=1920 and dpi<2048 then scale=7--.5
      else scale=8
      end
    end
  else
    scale=reagirl.Window_OldScale
    reagirl.Window_OldScale=scale
  end
  if reagirl.Window_CurrentScale==nil then reagirl.Window_CurrentScale=scale end
  local retval
  if reagirl.Window_CurrentScale~=scale then
    local unscaled_w = gfx.w/reagirl.Window_CurrentScale
    local unscaled_h = gfx.h/reagirl.Window_CurrentScale
    if gfx.getchar(65536)>1 then
      local A,B,C,D,E,F,G,H=gfx.dock(-1,0,0,0,0)
      if A<0 then A=0 end
      if B<0 then B=0 end
      gfx.init("", math.floor(unscaled_w*scale), math.floor(unscaled_h*scale), 0, A, B)
    end
    reagirl.Window_CurrentScale=scale
    reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
    reagirl.MoveItAllUp=0
    reagirl.MoveItAllRight=0
    for i=1, #reagirl.Elements do 
      if reagirl.Elements[i]["GUI_Element_Type"]=="Image" then
        retval=reagirl.Image_ReloadImage_Scaled(reagirl.Elements[i]["Guid"])
      end
    end
    reagirl.Gui_ForceRefresh(1)
  end
  return retval
end

function reagirl.Mouse_GetCap(doubleclick_wait, drag_wait)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Mouse_GetCap</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>string clickstate, string specific_clickstate, integer mouse_cap, integer click_x, integer click_y, integer drag_x, integer drag_y, integer mouse_wheel, integer mouse_hwheel = reagirl.Mouse_GetCap(optional integer doubleclick_wait, optional integer drag_wait)</functioncall>
  <description>
    Checks clickstate and mouseclick/wheel-behavior, since last time calling this function and returns their states.
    Allows you to get click, doubleclick, dragging, including the appropriate coordinates and mousewheel-states.

    Much more convenient, than fiddling around with gfx.mouse_cap
    
    Note: After doubleclicked, this will not return mouse-clicked-states, until the mouse-button is released. So any mouse-clicks during that can be only gotten from the retval mouse_cap.
          This is to prevent automatic mouse-dragging after double-clicks.
  </description>
  <parameters>
    optional integer doubleclick_wait - the timeframe, in which a second click is recognized as double-click, in defer-cycles. 30 is approximately 1 second; nil, will use 15(default)
    optional integer drag_wait - the timeframe, after which a mouseclick without moving the mouse is recognized as dragging, in defer-cycles. 30 is approximately 1 second; nil, will use 5(default)
  </parameters>
  <retvals>
      string clickstate - "", if not clicked, "CLK" for clicked and "FirstCLK", if the click is a first-click.
      string specific_clickstate - either "" for not clicked, "CLK" for clicked, "DBLCLK" for doubleclick or "DRAG" for dragging
      integer mouse_cap - the mouse_cap, a bitfield of mouse and keyboard modifier states
                        -   1: left mouse button
                        -   2: right mouse button
                        -   4: Control key
                        -   8: Shift key
                        -   16: Alt key
                        -   32: Windows key
                        -   64: middle mouse button
      integer click_x - the x position, when the mouse has been clicked the last time
      integer click_y - the y position, when the mouse has been clicked the last time
      integer drag_x  - the x-position of the mouse-dragging-coordinate; is like click_x for non-dragging mousestates
      integer drag_y  - the y-position of the mouse-dragging-coordinate; is like click_y for non-dragging mousestates
      integer mouse_wheel - the mouse_wheel-delta, since the last time calling this function
      integer mouse_hwheel - the mouse_horizontal-wheel-delta, since the last time calling this function
  </retvals>
  <chapter_context>
    Misc
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>functions, mouse, mouse cap, leftclick, rightclick, doubleclick, drag, wheel, mousewheel, horizontal mousewheel</tags>
</US_DocBloc>
]]
  if doubleclick_wait~=nil and math.type(doubleclick_wait)~="integer" then error("Mouse_GetCap: param #1 - must be nil or an integer", 2) end
  if drag_wait~=nil and math.type(drag_wait)~="integer" then error("Mouse_GetCap: param #2 - must be nil or an integer", 2) end

  -- prepare variables
  if reagirl.MouseCap==nil then
    -- if mouse-function hasn't been used yet, initialize variables
    reagirl.MouseCap={}
    reagirl.MouseCap.mouse_last_mousecap=0         -- last mousecap when last time this function got called, including 0
    reagirl.MouseCap.mouse_last_clicked_mousecap=0 -- last mousecap, the last time a button was clicked
    reagirl.MouseCap.mouse_dragcounter=0           -- the counter for click and wait, until drag is "activated"
    reagirl.MouseCap.mouse_lastx=0                 -- last mouse-x position
    reagirl.MouseCap.mouse_lasty=0                 -- last mouse-y position
    reagirl.MouseCap.mouse_endx=0                  -- end-x-position, for dragging
    reagirl.MouseCap.mouse_endy=0                  -- end-y-position, for dragging
    reagirl.MouseCap.mouse_dblclick=0              -- double-click-counter; 1, if a possible doubleclick can happen
    reagirl.MouseCap.mouse_dblclick_counter=0      -- double-click-waiting-counter; doubleclicks are only recognized, until this is "full"
    reagirl.MouseCap.mouse_clickblock=false        -- blocks mouseclicks after double-click, until button-release
    reagirl.MouseCap.mouse_last_hwheel=0           -- last horizontal mouse-wheel-state, the last time this function got called
    reagirl.MouseCap.mouse_last_wheel=0            -- last mouse-wheel-state, the last time this function got called
  end
  if math.type(doubleclick_wait)~="integer" then doubleclick_wait=0 end
  if math.type(drag_wait)~="integer" then drag_wait=15 end
  -- if mousewheels have been changed, store the new values and reset the gfx-variables
  if reagirl.MouseCap.mouse_last_hwheel~=gfx.mouse_hwheel or reagirl.MouseCap.mouse_last_wheel~=gfx.mouse_wheel then
    reagirl.MouseCap.mouse_last_hwheel=math.floor(gfx.mouse_hwheel)
    reagirl.MouseCap.mouse_last_wheel=math.floor(gfx.mouse_wheel)
  end
  gfx.mouse_hwheel=0
  gfx.mouse_wheel=0
  
  local newmouse_cap=0
  if gfx.mouse_cap&1~=0 then newmouse_cap=newmouse_cap+1 end
  if gfx.mouse_cap&2~=0 then newmouse_cap=newmouse_cap+2 end
  if gfx.mouse_cap&64~=0 then newmouse_cap=newmouse_cap+64 end
  
  if newmouse_cap==0 then
  -- if no mouse_cap is set, reset all counting-variables and return just the basics
    reagirl.MouseCap.mouse_last_mousecap=0
    reagirl.MouseCap.mouse_dragcounter=0
    reagirl.MouseCap.mouse_dblclick_counter=reagirl.MouseCap.mouse_dblclick_counter+1
    if reagirl.MouseCap.mouse_dblclick_counter>doubleclick_wait then
      -- if the doubleclick-timer is over, the next click will be recognized as normal click
      reagirl.MouseCap.mouse_dblclick=0
      reagirl.MouseCap.mouse_dblclick_counter=doubleclick_wait
    end
    reagirl.MouseCap.mouse_clickblock=false
    return "", "", gfx.mouse_cap, gfx.mouse_x, gfx.mouse_y, gfx.mouse_x, gfx.mouse_y, reagirl.MouseCap.mouse_last_wheel, reagirl.MouseCap.mouse_last_hwheel
  end
  if reagirl.MouseCap.mouse_clickblock==false then
    
    if newmouse_cap~=reagirl.MouseCap.mouse_last_mousecap then
      -- first mouseclick
      if reagirl.MouseCap.mouse_dblclick~=1 or (reagirl.MouseCap.mouse_lastx==gfx.mouse_x and reagirl.MouseCap.mouse_lasty==gfx.mouse_y) then

        -- double-click-checks
        if reagirl.MouseCap.mouse_dblclick~=1 then
          -- the first click, activates the double-click-timer
          reagirl.MouseCap.mouse_dblclick=1
          reagirl.MouseCap.mouse_dblclick_counter=0
        elseif reagirl.MouseCap.mouse_dblclick==1 and reagirl.MouseCap.mouse_dblclick_counter<doubleclick_wait 
            and reagirl.MouseCap.mouse_last_clicked_mousecap==newmouse_cap then
          -- when doubleclick occured, gfx.mousecap is still the same as the last clicked mousecap:
          -- block further mouseclick, until mousebutton is released and return doubleclick-values
          reagirl.MouseCap.mouse_dblclick=2
          reagirl.MouseCap.mouse_dblclick_counter=doubleclick_wait
          reagirl.MouseCap.mouse_clickblock=true
          return "CLK", "DBLCLK", gfx.mouse_cap, reagirl.MouseCap.mouse_lastx, reagirl.MouseCap.mouse_lasty, reagirl.MouseCap.mouse_lastx, reagirl.MouseCap.mouse_lasty, reagirl.MouseCap.mouse_last_wheel, reagirl.MouseCap.mouse_last_hwheel
        elseif reagirl.MouseCap.mouse_dblclick_counter==doubleclick_wait then
          -- when doubleclick-timer is full, reset mouse_dblclick to 0, so the next mouseclick is 
          -- recognized as normal mouseclick
          reagirl.MouseCap.mouse_dblclick=0
          reagirl.MouseCap.mouse_dblclick_counter=doubleclick_wait
        end
      end
      -- in every other case, this is a first-click, so set the appropriate variables and return 
      -- the first-click state and values
      reagirl.MouseCap.mouse_last_mousecap=newmouse_cap
      reagirl.MouseCap.mouse_last_clicked_mousecap=newmouse_cap
      reagirl.MouseCap.mouse_lastx=gfx.mouse_x
      reagirl.MouseCap.mouse_lasty=gfx.mouse_y
      return "CLK", "FirstCLK", gfx.mouse_cap, reagirl.MouseCap.mouse_lastx, reagirl.MouseCap.mouse_lasty, reagirl.MouseCap.mouse_lastx, reagirl.MouseCap.mouse_lasty, reagirl.MouseCap.mouse_last_wheel, reagirl.MouseCap.mouse_last_hwheel
    elseif newmouse_cap==reagirl.MouseCap.mouse_last_mousecap and reagirl.MouseCap.mouse_dragcounter<drag_wait
      and (gfx.mouse_x~=reagirl.MouseCap.mouse_lastx or gfx.mouse_y~=reagirl.MouseCap.mouse_lasty) then
      -- dragging when mouse moves, sets dragcounter to full waiting-period
      reagirl.MouseCap.mouse_endx=gfx.mouse_x
      reagirl.MouseCap.mouse_endy=gfx.mouse_y
      reagirl.MouseCap.mouse_dragcounter=drag_wait
      reagirl.MouseCap.mouse_dblclick=0
      return "CLK", "DRAG", gfx.mouse_cap, reagirl.MouseCap.mouse_lastx, reagirl.MouseCap.mouse_lasty, reagirl.MouseCap.mouse_endx, reagirl.MouseCap.mouse_endy, reagirl.MouseCap.mouse_last_wheel, reagirl.MouseCap.mouse_last_hwheel
    elseif newmouse_cap==reagirl.MouseCap.mouse_last_mousecap and reagirl.MouseCap.mouse_dragcounter<drag_wait then
      -- when clicked but mouse doesn't move, count up, until we reach the countlimit for
      -- activating dragging
      reagirl.MouseCap.mouse_dragcounter=reagirl.MouseCap.mouse_dragcounter+1
      return "CLK", "CLK", gfx.mouse_cap, reagirl.MouseCap.mouse_lastx, reagirl.MouseCap.mouse_lasty, reagirl.MouseCap.mouse_endx, reagirl.MouseCap.mouse_endy, reagirl.MouseCap.mouse_last_wheel, reagirl.MouseCap.mouse_last_hwheel
    elseif newmouse_cap==reagirl.MouseCap.mouse_last_mousecap and reagirl.MouseCap.mouse_dragcounter==drag_wait then
      -- dragging, after drag-counter is set to full waiting-period
      reagirl.MouseCap.mouse_endx=gfx.mouse_x
      reagirl.MouseCap.mouse_endy=gfx.mouse_y
      reagirl.MouseCap.mouse_dblclick=0
      return "CLK", "DRAG", gfx.mouse_cap, reagirl.MouseCap.mouse_lastx, reagirl.MouseCap.mouse_lasty, reagirl.MouseCap.mouse_endx, reagirl.MouseCap.mouse_endy, reagirl.MouseCap.mouse_last_wheel, reagirl.MouseCap.mouse_last_hwheel
    end
  else
    return "", "", gfx.mouse_cap, gfx.mouse_x, gfx.mouse_y, gfx.mouse_x, gfx.mouse_y, reagirl.MouseCap.mouse_last_wheel, reagirl.MouseCap.mouse_last_hwheel
  end
end

function reagirl.Gui_AtExit(run_func)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_AtExit</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Gui_AtExit(optional function run_func)</functioncall>
  <description>
    Adds a function that shall be run when the gui is closed with reagirl.Gui_Close()
    
    Good to do clean up or committing of settings.
  </description>
  <parameters>
    optional function run_func - a function, that shall be run when the gui closes; nil to remove the function
  </parameters>
  <chapter_context>
    Gui
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>functions, atexit, gui, function</tags>
</US_DocBloc>
]]
  if run_func~=nil and type(run_func)~="function" then error("Gui_AtExit: param #1 - must be a function", -2) return end
  reagirl.AtExit_RunFunc=run_func
end

function reagirl.Gui_AtEnter(run_func)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AtEnter</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Gui_AtEnter(optional function run_func)</functioncall>
  <description>
    Adds a function that shall be run when someone hits Enter while the gui is opened.
  </description>
  <parameters>
    function run_func - a function, that shall be run when the user hits enter while gui is open; nil, removes the function
  </parameters>
  <chapter_context>
    Gui
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>functions, atenter, gui, function</tags>
</US_DocBloc>
]]
  if run_func~=nil and type(run_func)~="function" then error("Gui_AtEnter: param #1 - must be a function", -2) return end
  reagirl.AtEnter_RunFunc=run_func
end

function reagirl.Gui_New()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_New</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Gui_New()</functioncall>
  <description>
    Creates a new gui by removing all currently(if available) ui-elements.
  </description>
  <chapter_context>
    Gui
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>functions, new, gui</tags>
</US_DocBloc>
]]
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  reagirl.NewUI=true
  reagirl.MaxImage=1
  gfx.set(reagirl["WindowBackgroundColorR"], reagirl["WindowBackgroundColorG"], reagirl["WindowBackgroundColorB"])
  gfx.rect(0,0,gfx.w,gfx.h,1)
  gfx.x=0
  gfx.y=0
  reagirl.Elements={}
  reagirl.Elements["FocusedElement"]=nil
  reagirl.ScrollButton_Left_Add() 
  reagirl.ScrollButton_Right_Add()
  reagirl.ScrollButton_Up_Add()
  reagirl.ScrollButton_Down_Add()
  reagirl.ScrollBar_Right_Add()
  reagirl.ScrollBar_Bottom_Add()
  reagirl.Tabs_Count=nil
  if reagirl.UI_Element_NextX_Default_temp==nil then
    reagirl.UI_Element_NextX_Default_temp=reagirl.UI_Element_NextX_Default
  else
    reagirl.UI_Element_NextX_Default=reagirl.UI_Element_NextX_Default_temp
  end
end

function reagirl.ScrollBar_Right_Add()
  reagirl.Elements[#reagirl.Elements+1]={}
  reagirl.Elements[#reagirl.Elements]["Guid"]=reaper.genGuid("")
  reagirl.Elements[#reagirl.Elements]["GUI_Element_Type"]="Scroll Bar"
  reagirl.Elements[#reagirl.Elements]["Name"]="Scroll bar right"
  reagirl.Elements[#reagirl.Elements]["Text"]=""
  reagirl.Elements[#reagirl.Elements]["IsDisabled"]=false
  reagirl.Elements[#reagirl.Elements]["Description"]="Scroll bar"
  reagirl.Elements[#reagirl.Elements]["AccHint"]="Scrolls the user interface up and down, using the arrowkeys"
  reagirl.Elements[#reagirl.Elements]["ContextMenu_ACC"]=""
  reagirl.Elements[#reagirl.Elements]["DropZoneFunction_ACC"]=""
  reagirl.Elements[#reagirl.Elements]["z_buffer"]=256
  reagirl.Elements[#reagirl.Elements]["x"]=-15
  reagirl.Elements[#reagirl.Elements]["y"]=15
  reagirl.Elements[#reagirl.Elements]["w"]=-1
  reagirl.Elements[#reagirl.Elements]["h"]=-30
  reagirl.Elements[#reagirl.Elements]["sticky_x"]=true
  reagirl.Elements[#reagirl.Elements]["sticky_y"]=true
  reagirl.Elements[#reagirl.Elements]["func_manage"]=reagirl.ScrollBar_Right_Manage
  reagirl.Elements[#reagirl.Elements]["func_draw"]=reagirl.ScrollBar_Right_Draw
  reagirl.Elements[#reagirl.Elements]["userspace"]={}
  reagirl.Elements[#reagirl.Elements]["a"]=0
  return reagirl.Elements[#reagirl.Elements]["Guid"]
end

function reagirl.ScrollBar_Right_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  -- ToDo: scrolling only from y+15 to y+h-30
  --       - adding scroll "marker"(probably in Draw-function)
  if reagirl.Scroll_Override_ScrollButtons==true then return "" end
  if element_storage.IsDisabled==false and element_storage.a<=0.85 then element_storage.a=element_storage.a+.1 reagirl.Gui_ForceRefresh(44) end
  
  if selected~="not selected" and gfx.mouse_x>=x and gfx.mouse_x<=x+w then
    if element_storage.clickme~=true and mouse_cap&1==1 and gfx.mouse_y>=y and gfx.mouse_y<=element_storage.scrollstart then
      reagirl.MoveItAllUp=reagirl.MoveItAllUp+10
      if reagirl.MoveItAllUp>0 then reagirl.MoveItAllUp=0 end
      element_storage.clickme=false
      reagirl.Gui_ForceRefresh(999)
    elseif element_storage.clickme~=true and mouse_cap&1==1 and gfx.mouse_y>=element_storage.scrollend and gfx.mouse_y<=y+h then
      reagirl.MoveItAllUp=reagirl.MoveItAllUp-10
      if reagirl.MoveItAllUp>reagirl.BoundaryY_Max-gfx.h then reagirl.MoveItAllUp=reagirl.BoundaryY_Max-gfx.h end
      element_storage.clickme=false
      reagirl.Gui_ForceRefresh(998)
    elseif clicked=="FirstCLK" then
      element_storage.clickme=true
    end
  end
  
  if selected~="not selected" then
    reagirl.UI_Element_SetFocusRect(true, x,y,w+1,h)
  end
  
  if mouse_cap==0 then element_storage.clickme=false end
  
  local dpi_scale = reagirl.Window_GetCurrentScale()
  if element_storage.clickme==true and mouse_cap&1==1 and gfx.mouse_y>=y+7*dpi_scale and gfx.mouse_y<=y+h-8*dpi_scale then
    
    --element_storage.stepsize=math.ceil((h-90*dpi_scale)/(reagirl.BoundaryY_Max-gfx.h))
    element_storage.stepsize=(h-13)/(reagirl.BoundaryY_Max-gfx.h)
    --if element_storage.stepsize==0 then element_storage.stepsize=1 end
    local count=0
    for i=y+7, y+h+element_storage.stepsize, element_storage.stepsize do
      count=count+1
      if gfx.mouse_y<i then
        element_storage.scroll_pos=gfx.mouse_y
        reagirl.MoveItAllUp=-count
        reagirl.Gui_ForceRefresh(997)
        break
      end
    end
  elseif element_storage.clickme==true and gfx.mouse_y<=y+7*dpi_scale then
    element_storage.scroll_pos=y+7*dpi_scale
    reagirl.MoveItAllUp=0
    reagirl.Gui_ForceRefresh(996)
  elseif element_storage.clickme==true and gfx.mouse_y>=y+h-8*dpi_scale then
    element_storage.scroll_pos=w+h-6*dpi_scale
    reagirl.MoveItAllUp=-reagirl.BoundaryY_Max+gfx.h
    reagirl.Gui_ForceRefresh(995)
  end
end

function reagirl.ScrollBar_Right_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if reagirl.Scroll_Override_ScrollButtons==true then return "" end
  local scale=reagirl.Window_CurrentScale
  if reagirl.BoundaryY_Max>gfx.h then
    element_storage.IsDisabled=false
  else
    element_storage.a=0 
    if element_storage.IsDisabled==false then
      reagirl.UI_Element_SetNothingFocused()
      element_storage.IsDisabled=true
    end
  end
  local oldr, oldg, oldb, olda = gfx.r, gfx.g, gfx.b, gfx.a

  gfx.set(reagirl.Colors.Scrollbar_Background_r, reagirl.Colors.Scrollbar_Background_g, reagirl.Colors.Scrollbar_Background_b, element_storage.a-0.3)
  gfx.rect(x, y, w+1, h, 1)
  --gfx.set(reagirl.Colors.Scrollbar_Foreground_r, reagirl.Colors.Scrollbar_Foreground_g, reagirl.Colors.Scrollbar_Foreground_b, element_storage.a)
  
  local y2=element_storage.scroll_pos
  if y2==nil then y2=-((h-13*scale)/(reagirl.BoundaryY_Max-gfx.h))*reagirl.MoveItAllUp else y2=y2-22*scale end
  
  gfx.set(reagirl.Colors.Scrollbar_Foreground_r, reagirl.Colors.Scrollbar_Foreground_g, reagirl.Colors.Scrollbar_Foreground_b, element_storage.a)
  gfx.rect(x,y2+15*scale,16*scale,14*scale,1)
  
  element_storage.scroll_pos=nil
  element_storage.scrollstart=y2+15*scale
  element_storage.scrollend=y2+15*scale+14*scale
end

function reagirl.ScrollBar_Bottom_Add()
  reagirl.Elements[#reagirl.Elements+1]={}
  reagirl.Elements[#reagirl.Elements]["Guid"]=reaper.genGuid("")
  reagirl.Elements[#reagirl.Elements]["GUI_Element_Type"]="Scroll Bar"
  reagirl.Elements[#reagirl.Elements]["Name"]="Scroll bar bottom"
  reagirl.Elements[#reagirl.Elements]["Text"]=""
  reagirl.Elements[#reagirl.Elements]["IsDisabled"]=false
  reagirl.Elements[#reagirl.Elements]["Description"]="Scroll bar"
  reagirl.Elements[#reagirl.Elements]["AccHint"]="Scrolls the user interface left and right, using the arrowkeys"
  reagirl.Elements[#reagirl.Elements]["ContextMenu_ACC"]=""
  reagirl.Elements[#reagirl.Elements]["DropZoneFunction_ACC"]=""
  reagirl.Elements[#reagirl.Elements]["z_buffer"]=256
  reagirl.Elements[#reagirl.Elements]["x"]=15
  reagirl.Elements[#reagirl.Elements]["y"]=-15
  reagirl.Elements[#reagirl.Elements]["w"]=-30
  reagirl.Elements[#reagirl.Elements]["h"]=15
  reagirl.Elements[#reagirl.Elements]["sticky_x"]=true
  reagirl.Elements[#reagirl.Elements]["sticky_y"]=true
  reagirl.Elements[#reagirl.Elements]["func_manage"]=reagirl.ScrollBar_Bottom_Manage
  reagirl.Elements[#reagirl.Elements]["func_draw"]=reagirl.ScrollBar_Bottom_Draw
  reagirl.Elements[#reagirl.Elements]["userspace"]={}
  reagirl.Elements[#reagirl.Elements]["a"]=0
  return reagirl.Elements[#reagirl.Elements]["Guid"]
end

function reagirl.ScrollBar_Bottom_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  -- still buggy, though it somehow works...(without clicking yet)
  -- ToDo: - scrolling only from x+15 to x+w-30
  --       - adding scroll "marker"(probably in Draw-function)
  if reagirl.Scroll_Override_ScrollButtons==true then return "" end
  if element_storage.IsDisabled==false and element_storage.a<=0.85 then element_storage.a=element_storage.a+.1 reagirl.Gui_ForceRefresh(44) end
  local dpi_scale = reagirl.Window_GetCurrentScale()
  
  if selected~="not selected" and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    if element_storage.clickme~=true and mouse_cap&1==1 and gfx.mouse_x>=x and gfx.mouse_x<=element_storage.scrollstart then
      reagirl.MoveItAllRight=reagirl.MoveItAllRight+10
      if reagirl.MoveItAllRight>0 then reagirl.MoveItAllRight=0 end
      element_storage.clickme=false
      reagirl.Gui_ForceRefresh(993)
    elseif element_storage.clickme~=true and mouse_cap&1==1 and gfx.mouse_x>=element_storage.scrollend and gfx.mouse_x<=x+w then
      reagirl.MoveItAllRight=reagirl.MoveItAllRight-10
      if reagirl.MoveItAllRight>reagirl.BoundaryX_Max-gfx.w then reagirl.MoveItAllRight=reagirl.BoundaryX_Max-gfx.w end
      element_storage.clickme=false
      reagirl.Gui_ForceRefresh(992)
    elseif clicked=="FirstCLK" then
      element_storage.clickme=true
    end
  end
  
  --print_update(element_storage.clicked)
  
  if selected~="not selected" then
    reagirl.UI_Element_SetFocusRect(true, x,y,w,h-1)
  end
  
  if mouse_cap==0 then element_storage.clickme=false end
  
  local dpi_scale = reagirl.Window_GetCurrentScale()
  if element_storage.clickme==true and gfx.mouse_x>=x+7*dpi_scale and gfx.mouse_x<=x+w-8*dpi_scale then
    element_storage.stepsize=(w-13)/(reagirl.BoundaryX_Max-gfx.w)
    local count=-2
    for i=x+7, x+w+element_storage.stepsize, element_storage.stepsize do
      if gfx.mouse_x<i then
        element_storage.scroll_pos=gfx.mouse_x
        reagirl.MoveItAllRight=-count
        reagirl.Gui_ForceRefresh(991)
        break
      end
      count=count+1
    end
  elseif element_storage.clickme==true and gfx.mouse_x<=x+7*dpi_scale then
    element_storage.scroll_pos=x+7*dpi_scale
    reagirl.MoveItAllRight=0
    reagirl.Gui_ForceRefresh(990)
  elseif element_storage.clickme==true and gfx.mouse_x>=x+w-8*dpi_scale then
    element_storage.scroll_pos=x+w-6*dpi_scale
    reagirl.MoveItAllRight=-reagirl.BoundaryX_Max+gfx.w
    reagirl.Gui_ForceRefresh(989)
    --]]
  end
end

function reagirl.ScrollBar_Bottom_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if reagirl.Scroll_Override_ScrollButtons==true then return "" end
  local scale=reagirl.Window_CurrentScale
  if reagirl.BoundaryX_Max>gfx.w then
    element_storage.IsDisabled=false
  else
    element_storage.a=0 
    if element_storage.IsDisabled==false then
      reagirl.UI_Element_SetNothingFocused()
      element_storage.IsDisabled=true
    end
  end
  local oldr, oldg, oldb, olda = gfx.r, gfx.g, gfx.b, gfx.a
  --gfx.set(reagirl["WindowBackgroundColorR"], reagirl["WindowBackgroundColorG"], reagirl["WindowBackgroundColorB"], element_storage.a)
  
  gfx.set(reagirl.Colors.Scrollbar_Background_r, reagirl.Colors.Scrollbar_Background_g, reagirl.Colors.Scrollbar_Background_b, element_storage.a-0.3)
  gfx.rect(x, y, w, h, 1)

  local x2=element_storage.scroll_pos
  if x2==nil then x2=-((w-13*scale)/(reagirl.BoundaryX_Max-gfx.w))*reagirl.MoveItAllRight else x2=x2-22*scale end
  
  gfx.set(reagirl.Colors.Scrollbar_Foreground_r, reagirl.Colors.Scrollbar_Foreground_g, reagirl.Colors.Scrollbar_Foreground_b, element_storage.a)
  gfx.rect(x2+15*scale,y,13*scale,15*scale,1)
  element_storage.scroll_pos=nil
  element_storage.scrollstart=x2+15*scale
  element_storage.scrollend=x2+15*scale+13*scale
end

function reagirl.Window_GetCurrentScale()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Window_GetCurrentScale</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer current_scaling_factor, boolean scaling_factor_override, integer current_system_scaling_factor = reagirl.Window_GetCurrentScale()</functioncall>
  <description>
    Gets the current scaling-factor
  </description>
  <retvals>
    integer current_scaling_factor - the scaling factor currently used by the script; nil, if autoscaling is activated
    boolean scaling_factor_override - does the current script override auto-scaling
    integer current_system_scaling_factor - the scaling factor that would be used, if auto-scaling would be on
  </retvals>
  <chapter_context>
    Misc
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>window, get, current scale</tags>
</US_DocBloc>
]]
  local retval, dpi = reaper.ThemeLayout_GetLayout("tcp", -3)
  local scale
  local dpi=tonumber(dpi)
  
  if dpi<384 then scale=1
  elseif dpi>=384 and dpi<512 then scale=1--.5
  elseif dpi>=512 and dpi<640 then scale=2
  elseif dpi>=640 and dpi<768 then scale=2--.5
  elseif dpi>=768 and dpi<896 then scale=3
  elseif dpi>=896 and dpi<1024 then scale=3--.5
  elseif dpi>=1024 and dpi<1152 then scale=4 
  elseif dpi>=1152 and dpi<1280 then scale=4--.5
  elseif dpi>=1280 and dpi<1408 then scale=5
  elseif dpi>=1408 and dpi<1536 then scale=5--.5
  elseif dpi>=1536 and dpi<1664 then scale=6
  elseif dpi>=1664 and dpi<1792 then scale=6--.5
  elseif dpi>=1792 and dpi<1920 then scale=7
  elseif dpi>=1920 and dpi<2048 then scale=7--.5
  else scale=8
  end
  if reagirl.Window_CurrentScale==nil then reagirl.Window_CurrentScale=scale end
  return reagirl.Window_CurrentScale, reagirl.Window_CurrentScale_Override~=nil, scale
end

function reagirl.Window_SetCurrentScale(newscale)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Window_SetCurrentScale</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Window_SetCurrentScale(optional integer newscale)</functioncall>
  <description>
    Sets a new scaling-factor that overrides auto-scaling/scaling preferences
  </description>
  <retvals>
    optional integer newscale - the scaling factor that shall be used in the script
                              - nil, autoscaling/use preference
                              - 1-8, scaling factor between 1 and 8
  </retvals>
  <chapter_context>
    Misc
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>window, get, current scale</tags>
</US_DocBloc>
]]
  if newscale~=nil and math.type(newscale)~="integer" then error("Window_SetCurrentScale: param #1 - must be either nil or an integer", 2) end
  if newscale~=nil and (newscale<1 or newscale>8) then error("Window_SetCurrentScale: param #1 - must be between 1 and 8", 2) end
  if newscale==nil then reagirl.Window_CurrentScale_Override=nil
  else 
    reagirl.Window_OldScale=newscale
    reagirl.Window_CurrentScale_Override=true
  end
  reagirl.Window_RescaleIfNeeded()
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0, newscale)
end

--

function reagirl.SetFont(idx, fontface, size, flags, scale_override)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetFont</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer font_size = reagirl.SetFont(integer idx, string fontface, integer size, integer flags, optional integer scale_override)</functioncall>
  <description>
    Sets the new font-size.
  </description>
  <parameters>
    integer idx - the index of the font to set
    string fontface - the name of the font, like "arial" or "tahoma" or "times"
    integer size - the size of the font(will be adjusted correctly on Mac)
    integer flags - a multibyte character, which can include 'i' for italics, 'u' for underline, or 'b' for bold. 
                      - These flags may or may not be supported depending on the font and OS. 
                      -   66 and 98, Bold (B), (b)
                      -   73 and 105, italic (I), (i)
                      -   77 and 109, non antialias (M), (m)
                      -   79 and 111, white outline (O), (o)
                      -   82 and 114, blurred (R), (r)
                      -   83 and 115, shadow (S), (s)
                      -   85 and 117, underline (U), (u)
                      -   86 and 118, inVerse (V), (v)
                      -   89 and 121, 90° counter-clockwise
                      -   90 and 122, 90° counter-clockwise
                      -
                      - To create such a multibyte-character, assume this flag-value as a 32-bit-value.
                      - The first 8 bits are the first flag, the next 8 bits are the second flag, 
                      - the next 8 bits are the third flag and the last 8 bits are the second flag.
                      - The flagvalue(each dot is a bit): .... ....   .... ....   .... ....   .... ....
                      - If you want to set it to Bold(B) and Italic(I), you use the ASCII-Codes of both(66 and 73 respectively),
                      - take them apart into bits and set them in this 32-bitfield.
                      - The first 8 bits will be set by the bits of ASCII-value 66(B), the second 8 bits will be set by the bits of ASCII-Value 73(I).
                      - The resulting flagvalue is: 0100 0010   1001 0010   0000 0000   0000 0000
                      - which is a binary representation of the integer value 18754, which combines 66 and 73 in it.
    optional integer scale_override - set the scaling-factor for the font
                                    - nil, use autoscaling
                                    - 1-8, scale between 1-8
  </parmeters>
  <retvals>
    integer font_size - the properly scaled font-size
  </retvals>
  <chapter_context>
    Misc
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>functions, set, font</tags>
</US_DocBloc>
]]
  if math.type(idx)~="integer" then error("SetFont: param #1 - must be an integer", 2) end
  if type(fontface)~="string" then error("SetFont: param #2 - must be a string", 2) end
  if math.type(size)~="integer" then error("SetFont: param #3 - must be an integer", 2) end
  if math.type(flags)~="integer" then error("SetFont: param #4 - must be an integer", 2) end
  if scale_override~=nil and math.type(scale_override)~="integer" then error("SetFont: param #5 - must be either nil(for autoscale) or an integer", 2) end
  if scale_override~=nil and (scale_override<1 or scale_override>8) then error("SetFont: param #5 - must be between 1 and 8 or nil(for autoscale)", 2) end
  if scale_override~=nil then size=size*scale_override 
  else 
    if size~=nil then size=size*reagirl.Window_GetCurrentScale() end
  end
  
  --local font_size = size * (1+reagirl.Window_CurrentScale)*0.5
  if reaper.GetOS():match("OS")~=nil then size=math.floor(size*0.8) end
  gfx.setfont(idx, fontface, size, flags)
  return size
end

function reagirl.Gui_Open(name, restore_old_window_state, title, description, w, h, dock, x, y)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_Open</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    JS=0.963
    Lua=5.4
  </requires>
  <functioncall>integer window_open, optional hwnd window_handler = reagirl.Gui_Open(string name, boolean restore_old_window_state, string title, string description, optional integer w, optional integer h, optional integer dock, optional integer x, optional integer y)</functioncall>
  <description>
    Opens a gui-window. If x and/or y are not given, it will be opened centered.
    
    ReaGirl stores in the background the position, size and dockstate of the window. Set restore_old_window_state=true to automatically reopen the window with the position, size and dockstate of the window when it was closed the last time.
  </description>
  <retvals>
    number retval - 1.0, if window is opened
    optional hwnd window_handler - a hwnd-window-handler for this window; only returned, with JS-extension installed!
  </retvals>
  <parameters>
    string name - name, will be used to store window position, size and dockstate when window is closed; make this name unique to your script like with your name as prefix for instance; newlines are not allowed
    boolean restore_old_window_state - true, restore the window position, size and dockstate when the window last got closed
                                     - false, always open with the same position, size and dockstate
    string title - the title of the window
    string description - a description of what this dialog does, for blind users. Make it a sentence.
    optional integer w - the width of the window; nil, try to autosize the to be opened window according to the ui-elements currently added to the gui(including invisible ones)
    optional integer h - the height of the window; nil, try to autosize the to be opened window according to the ui-elements currently added to the gui(including invisible ones)
    optional integer dock - the dockstate of the window; 0, undocked; 1, docked; nil=undocked
    optional integer x - the x-position of the window; nil=x-centered
    optional integer y - the y-position of the window; nil=y-centered
  </parameters>
  <chapter_context>
    Gui
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>functions, open, gui</tags>
</US_DocBloc>
]]
  if type(name)~="string" then error("Gui_Open: param #1 - must be a string", 2) end
  if type(restore_old_window_state)~="boolean" then error("Gui_Open: param #2 - must be a boolean", 2) end
  if type(title)~="string" then error("Gui_Open: param #3 - must be a string", 2) end
  if type(description)~="string" then error("Gui_Open: param #4 - must be a string", 2) end
  if description:sub(-1,-1)~="." and description:sub(-1,-1)~="?" then error("Gui_Open: param #4 - must end on a . like a regular sentence.", 2) end
  if w~=nil and math.type(w)~="integer" then error("Gui_Open: param #5 - must be either nil or an integer", 2) end
  if h~=nil and math.type(h)~="integer" then error("Gui_Open: param #6 - must be either nil or an integer", 2) end
  if dock~=nil and math.type(dock)~="integer" then error("Gui_Open: param #7 - must be either nil or an integer", 2) end
  if x~=nil and math.type(x)~="integer" then error("Gui_Open: param #8 - must be either nil or an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("Gui_Open: param #9 - must be either nil or an integer", 2) end
  local retval
  retval, reagirl.dpi = reaper.ThemeLayout_GetLayout("tcp", -3)
  if reagirl.dpi == "512" then
    reagirl.dpi_scale = 1
  else
    reagirl.dpi_scale = 0
  end
  
  local _, _, _, _, _, w2, _, h2 = reagirl.Gui_GetBoundaries()
  local tab_add=0
  if reagirl.Tabs_Count~=nil then tab_add=13 end 
  if w==nil then 
    w=w2+15+tab_add
  end
  if h==nil then
    h=h2+15+tab_add
  end

  name=string.gsub(name, "[\n\r]", "")
  reagirl.IsWindowOpen_attribute=true
  reagirl.Gui_ForceRefresh(2)
  
  if reaper.GetExtState("ReaGirl", "osara_enable_accmessage")~="false" and reaper.GetExtState("ReaGirl", "osara_move_mouse")~="false" then
    description=description.." When tabbing, mouse moves to tabbed ui-element."
  end
  
  if restore_old_window_state==false or (restore_old_window_state==true and reaper.GetExtState("Reagirl_Window_"..name, "stored")=="") then
    reagirl.Window_name=name
    reagirl.Window_Title=title
    reagirl.Window_Description=description
    reagirl.Window_x=x
    reagirl.Window_y=y
    reagirl.Window_w=w
    reagirl.Window_h=h
    reagirl.Window_dock=dock
    
    reagirl.Window_Title_default=title
    reagirl.Window_Description_default=description
    reagirl.Window_x_default=x
    reagirl.Window_y_default=y
    reagirl.Window_w_default=w
    reagirl.Window_h_default=h
    reagirl.Window_dock_default=dock
  else
    reagirl.Window_Title_default=title
    reagirl.Window_Description_default=description
    reagirl.Window_x_default=x
    reagirl.Window_y_default=y
    reagirl.Window_w_default=w
    reagirl.Window_h_default=h
    reagirl.Window_dock_default=dock
    
    reagirl.Window_Title=title
    reagirl.Window_Description=description
    --ReaGirl_Window_my_dialog
    reagirl.Window_name=name
    reagirl.Window_x=tonumber(reaper.GetExtState("Reagirl_Window_"..name, "x"))
    reagirl.Window_y=tonumber(reaper.GetExtState("Reagirl_Window_"..name, "y"))
    reagirl.Window_w=tonumber(reaper.GetExtState("Reagirl_Window_"..name, "w"))
    reagirl.Window_h=tonumber(reaper.GetExtState("Reagirl_Window_"..name, "h"))
    reagirl.Window_dock=tonumber(reaper.GetExtState("Reagirl_Window_"..name, "dock"))
    x=reagirl.Window_x
    y=reagirl.Window_y
    w=reagirl.Window_w
    h=reagirl.Window_h
    dock=reagirl.Window_dock
  end
  
  if reagirl.Window_ForceMinSize_Toggle==nil then reagirl.Window_ForceMinSize_Toggle=false end
  reagirl.osara_init_message=false
  --reagirl.FocusRectangle_BlinkStartTime=nil
  reagirl.FocusRectangle_BlinkStartTime=reaper.time_precise()
  reaper.SetExtState("Reagirl_Window_"..name, "open", "true", false)
  reaper.atexit(reagirl.AtExit)
  return reagirl.Window_Open(title, w, h, dock, x, y)
end

function reagirl.Gui_IsOpen()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_IsOpen</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>boolean retval = reagirl.Gui_IsOpen()</functioncall>
  <description>
    Checks, whether the gui-window is open.
  </description>
  <retvals>
    boolean retval - true, Gui is open; false, Gui is not open
  </retvals>
  <chapter_context>
    Gui
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>functions, is open, gui</tags>
</US_DocBloc>
]]
  return reagirl.IsWindowOpen_attribute==true
end

function reagirl.Gui_Close()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_Close</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Gui_Close()</functioncall>
  <description>
    Closes the gui-window.
  </description>
  <chapter_context>
    Gui
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>functions, close, gui</tags>
</US_DocBloc>
]]
  gfx.quit()  
  reagirl.IsWindowOpen_attribute=false
  reagirl.IsWindowOpen_attribute_Old=true
  reaper.SetExtState("Reagirl_Window_"..reagirl.Window_name, "open", "", false)
end

function reagirl.AtExit()
  reaper.SetExtState("Reagirl_Window_"..reagirl.Window_name, "open", "", false)
end

function reagirl.Ext_Window_GetState(gui_name)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Ext_Window_GetState</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer width, integer height, integer dockstate, integer x_position, integer y_position = reagirl.Ext_Window_GetState(string gui_name)</functioncall>
  <description>
    Gets the current width, height, position and dockstate of a ReaGirl-gui-window.
    
    Returns nil if no such window exists/was ever opened.
  </description>
  <parameters>
    optional string gui_name - the name of the gui-window, of which you want to get the states(NOT the window title!); nil, use this script's currently/last opened window
  </parameters>
  <retvals>
    integer width - the width of the window in pixels
    integer height - the height of the window in pixels 
    integer dockstate - 0, window isn't docked; 1, window is docked
    integer x_position - the x-position of the window in pixels
    integer y_position - the y-position of the window in pixels
  </retvals>
  <chapter_context>
    Ext
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ext, get, window, state</tags>
</US_DocBloc>
]]
  if gui_name~=nil and type(gui_name)~="string" then error("Ext_Window_GetState: param #1 - must be a string", 2) end
  if gui_name==nil then gui_name=reagirl.Window_name end
  if gui_name==nil then error("Ext_Window_GetState: param #1 - no such window", 2) end

  return tonumber(math.floor(reaper.GetExtState("Reagirl_Window_"..gui_name, "w"))),
         tonumber(math.floor(reaper.GetExtState("Reagirl_Window_"..gui_name, "h"))),
         tonumber(math.floor(reaper.GetExtState("Reagirl_Window_"..gui_name, "dock"))),
         tonumber(math.floor(reaper.GetExtState("Reagirl_Window_"..gui_name, "x"))),
         tonumber(math.floor(reaper.GetExtState("Reagirl_Window_"..gui_name, "y")))
end

function reagirl.Ext_Window_SetState(gui_name, width, height, dockstate, x_position, y_position)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Ext_Window_SetState</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Ext_Window_SetState(string gui_name, optional integer width, optional integer height, optional integer dockstate, optional integer x_position, optional integer y_position)</functioncall>
  <description>
    Sets a new width, height, position and dockstate of a ReaGirl-gui-window.
    
    To keep a parameter to its current state, set it to nil.
  </description>
  <parameters>
    string gui_name - the name of the gui-window, of which you want to get the states; nil, use this script's currently/last opened window
    optional integer width - the width of the window in pixels; nil, keep current
    optional integer height - the height of the window in pixels; nil, keep current
    optional integer dockstate - 0, window isn't docked; 1, window is docked; nil, keep current
    optional integer x_position - the x-position of the window in pixels; nil, keep current
    optional integer y_position - the y-position of the window in pixels; nil, keep current
  </parameters>
  <chapter_context>
    Ext
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ext, set, window, state</tags>
</US_DocBloc>
]]
  if type(gui_name)~="string" then error("Ext_Window_SetState: param #1 - must be a string", 2) end
  if width~=nil and math.type(width)~="integer" then error("Ext_Window_SetState: param #2 - must be nil or an integer", 2) end
  if height~=nil and math.type(height)~="integer" then error("Ext_Window_SetState: param #3 - must be nil or an integer", 2) end
  if dockstate~=nil and math.type(dockstate)~="integer" then error("Ext_Window_SetState: param #4 - must be nil or an integer", 2) end
  if x_position~=nil and math.type(x_position)~="integer" then error("Ext_Window_SetState: param #5 - must be nil or an integer", 2) end
  if y_position~=nil and math.type(y_position)~="integer" then error("Ext_Window_SetState: param #6 - must be nil or an integer", 2) end
  
  reaper.SetExtState("Reagirl_Window_"..gui_name, "newstate", "newstate", false)
  reaper.SetExtState("Reagirl_Window_"..gui_name, "newstate_w", width, false)
  reaper.SetExtState("Reagirl_Window_"..gui_name, "newstate_h", height, false)
  reaper.SetExtState("Reagirl_Window_"..gui_name, "newstate_dock", dockstate, false)
  reaper.SetExtState("Reagirl_Window_"..gui_name, "newstate_x", x_position, false)
  reaper.SetExtState("Reagirl_Window_"..gui_name, "newstate_y", y_position, false)
  
end

--reagirl.Window_Title="ReaGirl_Settings"
--A={reagirl.Ext_Window_SetState("ReaGirl_Settings", 100, 100, 0, 10, 10)}

function reagirl.Ext_Window_ResetToDefault(gui_name)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Ext_Window_ResetToDefault</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Ext_Window_ResetToDefault(string gui_name)</functioncall>
  <description>
    Resets a ReaGirl-gui-window to it's default window dimensions and dockstate.
  </description>
  <parameters>
    string gui_name - the name of the gui-window, of which you want to get the states; nil, use this script's currently/last opened window
  </parameters>
  <chapter_context>
    Ext
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ext, set, reset, default, window, state</tags>
</US_DocBloc>
]]
  if type(gui_name)~="string" then error("Ext_Window_SetState: param #1 - must be a string", 2) end
  reaper.SetExtState("Reagirl_Window_"..gui_name, "newstate", "reset", false)
end

function reagirl.Ext_Window_Focus(gui_name)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Ext_Window_Focus</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>boolean retval = reagirl.Ext_Window_Focus(string gui_name)</functioncall>
  <description>
    Focuses an opened ReaGirl-gui-window.
    
    Parameter gui_name is the same as the name set in the first parameter of Gui_Open.
    
    Returns false, if no window with the window name is currently opened.
  </description>
  <parameters>
    string gui_name - the name of the gui-window, which you want to focus
  </parameters>
  <retvals>
    boolean retval - the gui-window is opened; false, the gui-window isn't opened
  </retvals>
  <chapter_context>
    Ext
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ext, focus, window</tags>
</US_DocBloc>
]]
  if type(gui_name)~="string" then error("Ext_Window_Focus: param #1 - must be a string", 2) end
  if reaper.GetExtState("Reagirl_Window_"..gui_name, "open")=="true" then
    reaper.SetExtState("ReaGirl", "ReFocusWindow", gui_name, false)
    return true
  end
  return false
end

function reagirl.Ext_Window_IsOpen(gui_name)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Ext_Window_IsOpen</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>boolean retval = reagirl.Ext_Window_IsOpen(string gui_name)</functioncall>
  <description>
    Returns, if a specific gui-window is open.
  </description>
  <parameters>
    string gui_name - the name of the gui-window, whose open-state you want to get
  </parameters>
  <retvals>
    boolean retval - the gui-window is opened; false, the gui-window isn't opened
  </retvals>
  <chapter_context>
    Ext
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ext, get, open, window</tags>
</US_DocBloc>
]]
  if type(gui_name)~="string" then error("Ext_Window_Focus: param #1 - must be a string", 2) end
  if reaper.GetExtState("Reagirl_Window_"..gui_name, "open")=="true" then
    return true
  end
  return false
end

function reagirl.Ext_Tab_SetSelected(gui_name, tabnumber)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Ext_Tab_SetSelected</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Ext_Tab_SetSelected(string gui_name)</functioncall>
  <description>
    Focuses a specific tab of a ReaGirl-gui-window.
    
    Parameter gui_name is the same as the name set in the first parameter of Gui_Open.
    
    You can set a focused tab even if the window isn't opened yet. It will be focused the next time the specified gui-window is opened.
    It also works for opened gui-windows.
  </description>
  <parameters>
    string gui_name - the name of the gui-window, whose tab you want to set to focused
  </parameters>
  <chapter_context>
    Ext
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ext, focus, tab, window</tags>
</US_DocBloc>
]]
  if type(gui_name)~="string" then error("Ext_Tab_SetSelected: param #1 - must be a string", 2) end
  if math.type(tabnumber)~="integer" then error("Ext_Tab_SetSelected: param #2 - must be an integer", 2) end
  reaper.SetExtState("Reagirl_Window_"..gui_name, "open_tabnumber", tabnumber, false)
end

function reagirl.Ext_UpdateWindow()
  local w, h, dock, x, y  
  
  local focus_state=gfx.getchar(65536)
  local acc_hint=""
  local repositioned=""
  local resized=""
  local docked=""
  
  if reaper.GetExtState("Reagirl_Window_"..reagirl.Window_name, "newstate")=="newstate" then
    w=tonumber(reaper.GetExtState("Reagirl_Window_"..reagirl.Window_name, "newstate_w"))
    h=tonumber(reaper.GetExtState("Reagirl_Window_"..reagirl.Window_name, "newstate_h"))
    dock=tonumber(reaper.GetExtState("Reagirl_Window_"..reagirl.Window_name, "newstate_dock"))
    x=tonumber(reaper.GetExtState("Reagirl_Window_"..reagirl.Window_name, "newstate_x"))
    y=tonumber(reaper.GetExtState("Reagirl_Window_"..reagirl.Window_name, "newstate_y"))
    
    local cur_dock, cur_x, cur_y, cur_w, cur_h = gfx.dock(-1, 0, 0, 0, 0)
    
    if w~=nil or h~=nil then resized="resized" end
    if x~=nil or y~=nil then repositioned="repositioned" end
    if dock~=nil then
      if dock==1 then docked="docked" else docked="undocked" end
    end
    
    if focus_state&2==2 and resized~="" or repositioned~="" and docked~="" then
      local move_mouse=""
      if reaper.GetExtState("ReaGirl", "osara_move_mouse")~="false" then
        move_mouse=" Hit Tab and Shift Tab to reposition mouse to ui-element."
      end
      reagirl.osara_AddedMessage="Window got "..resized.." "..repositioned.." "..docked.."."..move_mouse
    end
    
    if w==nil then w=cur_w end
    if h==nil then h=cur_h end
    if dock==nil then dock=gfx.dock(-1) end
    if x==nil then x=cur_x end
    if y==nil then y=cur_y end
  elseif reaper.GetExtState("Reagirl_Window_"..reagirl.Window_name, "newstate")=="reset" then
    if w==nil then w=reagirl.Window_w_default end
    if h==nil then h=reagirl.Window_h_default end
    if dock==nil then dock=reagirl.Window_dock_default end
    if x==nil then x=reagirl.Window_x_default end
    if y==nil then y=reagirl.Window_y_default end
    
    if focus_state&2==2 then
      local move_mouse=""
      if reaper.GetExtState("ReaGirl", "osara_move_mouse")~="false" then
        move_mouse=" Hit Tab and Shift Tab to reposition mouse to ui-element."
      end
      reagirl.osara_AddedMessage="Window position, focus and dockstate got reset to default."..move_mouse
    end
  end
  --gfx.init("", w, h, dock, x, y)
  reagirl.Window_Open("", w, h, dock, x, y)
  gfx.dock(dock)
  reaper.SetExtState("Reagirl_Window_"..reagirl.Window_name, "newstate", "", true)
  reagirl.Gui_ForceRefresh()
end

function reagirl.ScreenReader_SendMessage(message)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>ScreenReader_SendMessage</slug>
    <requires>
      ReaGirl=1.0
      Reaper=7.03
      Lua=5.4
    </requires>
    <functioncall>reagirl.ScreenReader_SendMessage()</functioncall>
    <description>
      Sends a message to the screen reader
      
      Use this only when needed, means, don't permanently send messages. Otherwise, they will be cut off and the user doesn't get them.
    </description>
    <chapter_context>
      Screen Reader
    </chapter_context>
    <target_document>ReaGirl_Docs</target_document>
    <source_document>reagirl_GuiEngine.lua</source_document>
    <tags>screen reader, send, message</tags>
  </US_DocBloc>
  ]]
  if type(message)~="string" then error("ScreenReader_SendMessage: param #1 - must be a string", 2) end
  reagirl.ScreenReader_SendMessage_ActualMessage=message
end

function reagirl.Gui_Manage(keep_running)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_Manage</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Gui_Manage()</functioncall>
  <description>
    Manages the gui-window.
    
    Put this function in a defer-loop. It will manage, draw, show the gui.
  </description>
  <chapter_context>
    Gui
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gui, functions, manage</tags>
</US_DocBloc>
]]
  -- manages the gui, including tts, mouse and keyboard-management and ui-focused-management

  -- initialize shit
  if keep_running==true then reagirl.Gui_Manage_keep_running=true end
  local message
  if reagirl.Gui_IsOpen()==false then return end
  if reagirl.NewUI~=false then reagirl.NewUI=false if reagirl.Elements.FocusedElement==nil then reagirl.Elements.FocusedElement=reagirl.UI_Element_GetNext(0) end end
  if #reagirl.Elements==0 then error("Gui_Manage: no ui-element available", -2) end
  
  if #reagirl.Elements<reagirl.Elements.FocusedElement then reagirl.Elements.FocusedElement=1 end
  
  reagirl.Window_State=gfx.getchar(65536)

  if reaper.GetExtState("ReaGirl_Window_"..reagirl.Window_name, "newstate")~="" then
    reagirl.Ext_UpdateWindow()
  end
  
  -- store position, size and dockstate of window for next opening
  local dock,x,y,w,h=gfx.dock(-1,0,0,0,0)
  reaper.SetExtState("Reagirl_Window_"..reagirl.Window_name, "stored", "true", true)
  reaper.SetExtState("Reagirl_Window_"..reagirl.Window_name, "x", x, true)
  reaper.SetExtState("Reagirl_Window_"..reagirl.Window_name, "y", y, true)
  reaper.SetExtState("Reagirl_Window_"..reagirl.Window_name, "w", w, true)
  reaper.SetExtState("Reagirl_Window_"..reagirl.Window_name, "h", h, true)
  reaper.SetExtState("Reagirl_Window_"..reagirl.Window_name, "dock", dock, true)
  --]]
  
  if reaper.GetExtState("ReaGirl", "ReFocusWindow")==reagirl.Window_name then
    reagirl.Window_SetFocus()
    reaper.SetExtState("ReaGirl", "ReFocusWindow","",false)
  end
  
  -- Osara Override
  if reaper.GetExtState("ReaGirl", "osara_override")=="" or reaper.GetExtState("ReaGirl", "osara_override")=="true" or reagirl.Settings_Override==true then 
    reagirl.osara_outputMessage=reagirl.osara
  else
    reagirl.osara_outputMessage=nil     
  end
  
  if reaper.GetExtState("ReaGirl", "edit_mode")=="true" and reagirl.EditMode==false then
    reagirl.EditMode=true
    reagirl.Gui_ForceRefresh()
  elseif reaper.GetExtState("ReaGirl", "edit_mode")=="false" and reagirl.EditMode==true then
    reagirl.EditMode=false
    reagirl.Gui_ForceRefresh()
  end
  
  -- initialize cursor-blinkspeed
  if reaper.GetExtState("ReaGirl", "Inputbox_BlinkSpeed")=="" then
    reagirl.Inputbox_BlinkSpeed=33
  else
    reagirl.Inputbox_BlinkSpeed=tonumber(reaper.GetExtState("ReaGirl", "Inputbox_BlinkSpeed"))
  end
  
  -- focus rectangle blinking
  if reaper.GetExtState("ReaGirl", "FocusRectangle_BlinkSpeed")=="" then
    reagirl.FocusRectangle_BlinkSpeed=33
  else
    reagirl.FocusRectangle_BlinkSpeed=tonumber(reaper.GetExtState("ReaGirl", "FocusRectangle_BlinkSpeed"))
  end
  if reagirl.FocusRectangle_BlinkStartTime==nil then
    reagirl.FocusRectangle_BlinkStartTime=reaper.time_precise()
  end
  
  if reaper.GetExtState("ReaGirl", "FocusRectangle_BlinkTime")=="" then
    reagirl.FocusRectangle_BlinkTime=0.001
  else
    reagirl.FocusRectangle_BlinkTime=tonumber(reaper.GetExtState("ReaGirl", "FocusRectangle_BlinkTime"))
  end
  if reagirl.FocusRectangle_BlinkStartTime==nil then
    reagirl.FocusRectangle_BlinkStartTime=reaper.time_precise()
  end
  
  if reaper.time_precise()<reagirl.FocusRectangle_BlinkStartTime+reagirl.FocusRectangle_BlinkTime then
    if reagirl.FocusRectangle_BlinkSpeed>1 then
      reagirl.FocusRectangle_Blink=reagirl.FocusRectangle_Blink+1
      if reagirl.FocusRectangle_Blink>reagirl.FocusRectangle_BlinkSpeed then reagirl.FocusRectangle_Blink=0 end
      if reagirl.FocusRectangle_Blink==(reagirl.FocusRectangle_BlinkSpeed>>1) then reagirl.FocusRectangle_Alpha=0 reagirl.Gui_ForceRefresh(988) end
      if reagirl.FocusRectangle_Blink==0 then reagirl.FocusRectangle_Alpha=0.5 reagirl.Gui_ForceRefresh(987) end
    end
  elseif reagirl.FocusRectangle_BlinkStop~=true then
    reagirl.FocusRectangle_Alpha=0.5    
    reagirl.FocusRectangle_Blink=0
    reagirl.Gui_ForceRefresh(986)
    reagirl.FocusRectangle_BlinkStop=true
  end
  
  reagirl.UI_Element_MinX=gfx.w
  reagirl.UI_Element_MinY=gfx.h
  reagirl.UI_Element_MaxW=0
  reagirl.UI_Element_MaxH=0
  local x2, y2
  reagirl.Window_RescaleIfNeeded()
  reagirl.UI_Elements_Boundaries()
  local scale=reagirl.Window_CurrentScale
  --local Window_State=gfx.getchar(65536)
  
  -- initialize focus of first element, if not done already
  if reagirl.Elements["FocusedElement"]==nil then reagirl.Elements["FocusedElement"]=reagirl.UI_Element_GetNext(0) end
  -- initialize osara-message
  local init_message=""
  local helptext=""
  if reagirl.osara_init_message==false then
    if reagirl.Elements["FocusedElement"]~=-1 then
      if reagirl.Elements[1]~=nil then
        reagirl.osara_init_message=reagirl.Window_Title .."-dialog, ".. reagirl.Window_Description .." ".. reagirl.Elements[reagirl.Elements["FocusedElement"]]["Name"].." ".. reagirl.Elements[reagirl.Elements["FocusedElement"]]["GUI_Element_Type"]..". "
        local acc_message=""
        if reaper.GetExtState("ReaGirl", "osara_enable_accmessage")~="false" then
          acc_message=reagirl.Elements[reagirl.Elements["FocusedElement"]]["AccHint"]
        end
        helptext=reagirl.Elements[reagirl.Elements["FocusedElement"]]["Description"].." "..acc_message
      else
        reagirl.osara_init_message=reagirl.Window_Title.."-dialog, "..reagirl.Window_Description.." "
      end
    end
  end
  
  -- reset clicked state
  --for i=1, #reagirl.Elements do reagirl.Elements[i]["clicked"]=false end
  
  
  -- [[ Keyboard Management ]]
  local Key, Key_utf=gfx.getchar()
  
  --Debug Code - move ui-elements via arrow keys, including stopping when end of ui-elements has been reached.
  -- This can be used to build more extensive scrollcode, including smooth scroll and scrollbars
  -- see reagirl.UI_Elements_Boundaries() for the calculation of it and more information
  if reagirl.Scroll_Override_MouseWheel~=true then
    if gfx.mouse_hwheel~=0 then reagirl.UI_Element_ScrollX(gfx.mouse_hwheel/50) end
    if gfx.mouse_wheel~=0 then reagirl.UI_Element_ScrollY(gfx.mouse_wheel/50) end
  end
  reagirl.Scroll_Override_MouseWheel=nil
  if reagirl.Elements["FocusedElement"]~=-1 and reagirl.Elements[reagirl.Elements["FocusedElement"]].GUI_Element_Type~="Edit" and reagirl.Elements[reagirl.Elements["FocusedElement"]].GUI_Element_Type~="Edit Multiline" then
  -- scroll via keys
    if reagirl.Scroll_Override~=true and reaper.GetExtState("ReaGirl", "scroll_via_keyboard")~="false" then
      if gfx.mouse_cap&8==0 and Key==30064 then reagirl.UI_Element_ScrollY(2) end -- up
      if gfx.mouse_cap&8==0 and Key==1685026670 then reagirl.UI_Element_ScrollY(-2) end --down
      if Key==1818584692.0 and gfx.mouse_cap==0 then reagirl.UI_Element_ScrollX(2) end -- left
      if Key==1919379572.0 and gfx.mouse_cap==0 then reagirl.UI_Element_ScrollX(-2) end -- right
      if Key==1885828464.0 and gfx.mouse_cap==0 then reagirl.UI_Element_ScrollY(20) end -- pgdown
      if Key==1885824110.0 and gfx.mouse_cap==0 then reagirl.UI_Element_ScrollY(-20) end -- pgup
      if gfx.mouse_cap&8==8 and Key==1818584692.0 then reagirl.UI_Element_ScrollX(20) end -- Shift+left  - pgleft
      if gfx.mouse_cap&8==8 and Key==1919379572.0 then reagirl.UI_Element_ScrollX(-20) end --Shift+right - pgright
      if Key==1752132965.0 and gfx.mouse_cap==0 then reagirl.MoveItAllUp=0 reagirl.Gui_ForceRefresh(3) end -- home
      if Key==6647396.0 then MoveItAllUp_Delta=0 reagirl.MoveItAllUp=gfx.h-reagirl.BoundaryY_Max reagirl.Gui_ForceRefresh(4) end -- end
    end
  end
  reagirl.Scroll_Override=nil
  reagirl.UI_Element_SmoothScroll(1)
  -- End of Debug
  
  if Key==-1 then reagirl.IsWindowOpen_attribute_Old=true reagirl.IsWindowOpen_attribute=false end
  
  if reagirl.Gui_PreventCloseViaEscForOneCycle_State~=true then
    if Key==27 then 
      reagirl.Gui_Close() 
    end -- esc closes window
  end 
  reagirl.Window_ForceMinSize() 
  reagirl.Window_ForceMaxSize() 
  -- run atexit-function when window gets closed by the close button
  
  if reagirl.IsWindowOpen_attribute_Old==true and reagirl.IsWindowOpen_attribute==false then
    reagirl.IsWindowOpen_attribute_Old=false
    if reagirl.AtExit_RunFunc~=nil then reagirl.AtExit_RunFunc() end
  end
  
  if reagirl.Gui_PreventEnterForOneCycle_State~=true then
    if Key==13 and gfx.mouse_cap==0 then 
      if reagirl.AtEnter_RunFunc~=nil then reagirl.AtEnter_RunFunc() end
    end -- esc closes window
  end 
  reagirl.Gui_PreventEnterForOneCycle_State=false
  
  if Key==30064.0 and gfx.mouse_cap==8 then 
    -- Shift+Up reads out focused ui-element
    if reagirl.osara_outputMessage~=nil then
      local acc_message=""
      if reaper.GetExtState("ReaGirl", "osara_enable_accmessage")~="false" then
        acc_message=reagirl.Elements[reagirl.Elements["FocusedElement"]]["AccHint"]
      end
      reagirl.osara_outputMessage(reagirl.Elements[reagirl.Elements["FocusedElement"]]["Name"].." "..reagirl.Elements[reagirl.Elements["FocusedElement"]]["GUI_Element_Type"]..". "..reagirl.Elements[reagirl.Elements["FocusedElement"]]["Description"].." "..acc_message)
    end
  elseif Key==84 and gfx.mouse_cap==8 then
    if reagirl.osara_outputMessage~=nil then
      reagirl.osara_outputMessage(reagirl.Window_Title.. "-dialog, ".. reagirl.Window_Description.." ".. reagirl.Elements[reagirl.Elements["FocusedElement"]]["Name"].." ".. reagirl.Elements[reagirl.Elements["FocusedElement"]]["GUI_Element_Type"]..". ")
    end
  end 
  
  -- if mouse has been moved, reset wait-counter for displaying tooltip
  if reagirl.OldMouseX==gfx.mouse_x and reagirl.OldMouseY==gfx.mouse_y then
    reagirl.TooltipWaitCounter=reagirl.TooltipWaitCounter+1
  else
    reagirl.TooltipWaitCounter=0
  end
  reagirl.OldMouseX=gfx.mouse_x
  reagirl.OldMouseY=gfx.mouse_y
  
  -- if window has been resized, force refresh
  if reagirl.Windows_OldH~=gfx.h then reagirl.Windows_OldH=gfx.h reagirl.Window_Reposition(true) reagirl.Gui_ForceRefresh(5) end
  if reagirl.Windows_OldW~=gfx.w then reagirl.Windows_OldW=gfx.w reagirl.Window_Reposition(false) reagirl.Gui_ForceRefresh(6) end
  
  if reagirl.ui_element_selected==nil then 
    reagirl.ui_element_selected="first selected"
  else
    reagirl.ui_element_selected="selected"
  end
  local skip_hover_acc_message=false
  -- Tab-key - next ui-element
  if gfx.mouse_cap==0 and Key==9 then 
    local old_selection=reagirl.Elements.FocusedElement
    reagirl.Elements["FocusedElement"]=reagirl.UI_Element_GetNext(reagirl.Elements["FocusedElement"])
    
    reagirl.FocusRectangle_BlinkStartTime=reaper.time_precise()
    reagirl.FocusRectangle_BlinkStop=nil
    
    if reagirl.Elements["FocusedElement"]~=-1 then
      if reagirl.Elements["FocusedElement"]>#reagirl.Elements then reagirl.Elements["FocusedElement"]=1 end 
      init_message=reagirl.Elements[reagirl.Elements["FocusedElement"]]["Name"].." "..reagirl.Elements[reagirl.Elements["FocusedElement"]]["GUI_Element_Type"]..". "
      local acc_message=""
      if reaper.GetExtState("ReaGirl", "osara_enable_accmessage")~="false" then
        acc_message=reagirl.Elements[reagirl.Elements["FocusedElement"]]["AccHint"]
      end
      helptext=reagirl.Elements[reagirl.Elements["FocusedElement"]]["Description"].." "..acc_message
      if reagirl.Elements["FocusedElement"]<=#reagirl.Elements-6 then
        reagirl.UI_Element_ScrollToUIElement(reagirl.Elements[reagirl.Elements["FocusedElement"]].Guid) -- buggy, should scroll to ui-element...
      end
      reagirl.UI_Element_SetFocusRect()
      reagirl.old_osara_message=""
      reagirl.Gui_ForceRefresh(7) 
      if old_selection~=reagirl.Elements.FocusedElement then
        reagirl.ui_element_selected="first selected"
      else
        reagirl.ui_element_selected="selected"
      end
    end
    skip_hover_acc_message=true
  end
  if reagirl.Elements["FocusedElement"]>#reagirl.Elements then reagirl.Elements["FocusedElement"]=1 end
  
  -- Shift+Tab-key - previous ui-element
  if gfx.mouse_cap==8 and Key==9 then 
    local old_selection=reagirl.Elements.FocusedElement
    reagirl.Elements["FocusedElement"]=reagirl.UI_Element_GetPrevious(reagirl.Elements["FocusedElement"])
    
    reagirl.FocusRectangle_BlinkStartTime=reaper.time_precise()
    reagirl.FocusRectangle_BlinkStop=nil
    
    if reagirl.Elements["FocusedElement"]~=-1 then
      if reagirl.Elements["FocusedElement"]<1 then reagirl.Elements["FocusedElement"]=#reagirl.Elements end
      init_message=reagirl.Elements[reagirl.Elements["FocusedElement"]]["Name"].." "..
      reagirl.Elements[reagirl.Elements["FocusedElement"]]["GUI_Element_Type"]..". "
      local acc_message=""
      if reaper.GetExtState("ReaGirl", "osara_enable_accmessage")~="false" then
        acc_message=reagirl.Elements[reagirl.Elements["FocusedElement"]]["AccHint"]
      end
      helptext=reagirl.Elements[reagirl.Elements["FocusedElement"]]["Description"].." "..acc_message
      reagirl.old_osara_message=""
      if reagirl.Elements["FocusedElement"]<=#reagirl.Elements-6 then
        reagirl.UI_Element_ScrollToUIElement(reagirl.Elements[reagirl.Elements["FocusedElement"]].Guid) -- buggy, should scroll to ui-element...
      end
      reagirl.UI_Element_SetFocusRect()
      reagirl.Gui_ForceRefresh(8) 
      if old_selection~=reagirl.Elements.FocusedElement then
        reagirl.ui_element_selected="first selected"
      else
        reagirl.ui_element_selected="selected"
      end
    end
    skip_hover_acc_message=true
  end
  if reagirl.Elements["FocusedElement"]<1 then reagirl.Elements["FocusedElement"]=#reagirl.Elements end
  
  -- Space-Bar "clicks" currently focused ui-element
  if Key==32 then reagirl.Elements[reagirl.Elements["FocusedElement"]]["clicked"]=true end
  
  
  -- [[ click management-code]]
  local clickstate, specific_clickstate, mouse_cap, click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel = reagirl.Mouse_GetCap(5, 10)
  -- finds out also, which ui-element shall be seen as clicked(only the last ui-element within click-area will be seen as clicked)
  -- changes the selected ui-element when clicked AND shows tooltip
  local Scroll_Override_ScrollButtons=6
  if reagirl.Scroll_Override_ScrollButtons==true then Scroll_Override_ScrollButtons=4 end
  reagirl.UI_Elements_HoveredElement=-1
    
  local found_element, old_selection 
  local restore=false
  
  for i=#reagirl.Elements-Scroll_Override_ScrollButtons, #reagirl.Elements do
    if i==0 then break end
    if reagirl.Elements[i]["hidden"]~=true then
      local x2, y2, w2, h2
      if reagirl.Elements[i]["x"]<0 then x2=gfx.w+(reagirl.Elements[i]["x"]*scale) else x2=reagirl.Elements[i]["x"]*scale end
      if reagirl.Elements[i]["y"]<0 then y2=gfx.h+(reagirl.Elements[i]["y"]*scale) else y2=reagirl.Elements[i]["y"]*scale end
      if reagirl.Elements[i]["w"]<0 then w2=gfx.w+(-x2+reagirl.Elements[i]["w"]*scale) else w2=reagirl.Elements[i]["w"]*scale end
      if reagirl.Elements[i]["h"]<0 then h2=gfx.h+(-y2+reagirl.Elements[i]["h"]*scale) else h2=reagirl.Elements[i]["h"]*scale end
      if reagirl.Elements[i]["GUI_Element_Type"]=="DropDownMenu" then if w2<20 then w2=20 end end
  
      -- is any gui-element outside of the window
      local MoveItAllUp=reagirl.MoveItAllUp  
      local MoveItAllRight=reagirl.MoveItAllRight
      if reagirl.Elements[i]["sticky_y"]==true then MoveItAllUp=0 end
      if reagirl.Elements[i]["sticky_x"]==true then MoveItAllRight=0 end
      
      if x2+MoveItAllRight<reagirl.UI_Element_MinX then reagirl.UI_Element_MinX=x2+MoveItAllRight end
      if y2<reagirl.UI_Element_MinY+MoveItAllUp then reagirl.UI_Element_MinY=y2+MoveItAllUp end
      
      if x2+MoveItAllRight+w2>reagirl.UI_Element_MaxW then reagirl.UI_Element_MaxW=x2+MoveItAllRight+w2 end
      if y2+MoveItAllUp+h2>reagirl.UI_Element_MaxH then reagirl.UI_Element_MaxH=y2+h2+MoveItAllUp end
    
      -- show tooltip when hovering over a ui-element
      -- also set clicked ui-element to the one at mouse-position, when specific_clickstate="FirstCLK"
      
      if gfx.mouse_x>=x2+MoveItAllRight and
         gfx.mouse_x<=x2+MoveItAllRight+w2 and
         gfx.mouse_y>=y2+MoveItAllUp and
         gfx.mouse_y<=y2+MoveItAllUp+h2 then
         reagirl.UI_Elements_HoveredElement=i
         -- tooltip management
         if reagirl.TooltipWaitCounter==14 then
          local XX,YY=reaper.GetMousePosition()
          if reagirl.Window_State&8==8 and reaper.GetExtState("ReaGirl", "show_tooltips")~="false" then
            local contextmenu=""
            local dropfiles=""
            local draggable=""
            if reagirl.Elements[i]["ContextMenu_ACC"]~="" then
              contextmenu="Has context-menu. "
            end
            if reagirl.Elements[i]["DropZoneFunction_ACC"]~="" then
              dropfiles="Allows dropping of files. "
            end
            if reagirl.Elements[i]["Draggable"]==true then 
              draggable="Draggable. " 
            end
            reaper.TrackCtl_SetToolTip(reagirl.Elements[i]["Description"].." "..draggable..contextmenu..dropfiles, XX+15, YY+10, true)
          end

          if reagirl.SetPosition_MousePositionY~=gfx.mouse_y 
          and reagirl.SetPosition_MousePositionY~=gfx.mouse_x 
          and reagirl.Elements[i]["AccHoverMessage"]~=nil then
            --reagirl.osara_outputMessage(reagirl.Elements[i]["AccHoverMessage"])
            --reagirl.SetPosition_MousePositionX=-1
            --reagirl.SetPosition_MousePositionY=-1
          end
          
          --if reagirl.osara_outputMessage~=nil then reagirl.osara_outputMessage(reagirl.Elements[i]["Text"],2--[[:utf8_sub(1,20)]]) end
         end
         
         -- focused/clicked ui-element-management
         if (specific_clickstate=="FirstCLK") and reagirl.Elements[i]["IsDisabled"]==false then
           if i~=reagirl.Elements["FocusedElement"] then
             init_message=reagirl.Elements[i]["Name"].." "..reagirl.Elements[i]["GUI_Element_Type"]:sub(1,-1).." "
             local acc_message=""
             if reaper.GetExtState("ReaGirl", "osara_enable_accmessage")~="false" then
               acc_message=reagirl.Elements[i]["AccHint"]
             end
             helptext=reagirl.Elements[i]["Description"].." "..acc_message
             reagirl.FocusRectangle_BlinkStartTime=reaper.time_precise()
             reagirl.FocusRectangle_BlinkStop=nil
           end
           
           -- set found ui-element as focused and clicked
           old_selection=reagirl.Elements.FocusedElement
           if reagirl.Elements[i].IsDecorative==true then restore=true end
           reagirl.Elements["FocusedElement"]=i
           if old_selection~=reagirl.Elements.FocusedElement then
             reagirl.ui_element_selected="first selected"
           else
             reagirl.ui_element_selected="selected"
           end
           reagirl.Elements[i]["clicked"]=true
           reagirl.UI_Element_SetFocusRect()
           reagirl.Gui_ForceRefresh(9) 
         end
         found_element=i
         break
      end
    end
  end
  
  if found_element==nil then
    for i=1, #reagirl.Elements-Scroll_Override_ScrollButtons, 1 do
      if reagirl.Elements[i]["hidden"]~=true then
        local x2, y2, w2, h2
        if reagirl.Elements[i]["x"]<0 then x2=gfx.w+(reagirl.Elements[i]["x"]*scale) else x2=reagirl.Elements[i]["x"]*scale end
        if reagirl.Elements[i]["y"]<0 then y2=gfx.h+(reagirl.Elements[i]["y"]*scale) else y2=reagirl.Elements[i]["y"]*scale end
        if reagirl.Elements[i]["w"]<0 then w2=gfx.w+(-x2+reagirl.Elements[i]["w"]*scale) else w2=reagirl.Elements[i]["w"]*scale end
        if reagirl.Elements[i]["h"]<0 then h2=gfx.h+(-y2+reagirl.Elements[i]["h"]*scale) else h2=reagirl.Elements[i]["h"]*scale end
        if reagirl.Elements[i]["GUI_Element_Type"]=="DropDownMenu" then if w2<20 then w2=20 end end
  
        -- is any gui-element outside of the window
        local MoveItAllUp=reagirl.MoveItAllUp  
        local MoveItAllRight=reagirl.MoveItAllRight
        if reagirl.Elements[i]["sticky_y"]==true then MoveItAllUp=0 end
        if reagirl.Elements[i]["sticky_x"]==true then MoveItAllRight=0 end
        
        if x2+MoveItAllRight<reagirl.UI_Element_MinX then reagirl.UI_Element_MinX=x2+MoveItAllRight end
        if y2<reagirl.UI_Element_MinY+MoveItAllUp then reagirl.UI_Element_MinY=y2+MoveItAllUp end
        
        if x2+MoveItAllRight+w2>reagirl.UI_Element_MaxW then reagirl.UI_Element_MaxW=x2+MoveItAllRight+w2 end
        if y2+MoveItAllUp+h2>reagirl.UI_Element_MaxH then reagirl.UI_Element_MaxH=y2+h2+MoveItAllUp end
      
        -- show tooltip when hovering over a ui-element
        -- also set clicked ui-element to the one at mouse-position, when specific_clickstate="FirstCLK"
        if gfx.mouse_x>=x2+MoveItAllRight and
           gfx.mouse_x<=x2+MoveItAllRight+w2 and
           gfx.mouse_y>=y2+MoveItAllUp and
           gfx.mouse_y<=y2+MoveItAllUp+h2 then
           reagirl.UI_Elements_HoveredElement=i
           -- tooltip management
           if reagirl.TooltipWaitCounter==14 then
            local XX,YY=reaper.GetMousePosition()
            
            if reagirl.Window_State&8==8 and reaper.GetExtState("ReaGirl", "show_tooltips")~="false" then
              local contextmenu=""
              local dropfiles=""
              local draggable=""
              if reagirl.Elements[i]["ContextMenu_ACC"]~="" then
                contextmenu="Has context-menu. "
              end
              if reagirl.Elements[i]["DropZoneFunction_ACC"]~="" then
                dropfiles="Allows dropping of files. "
              end
              if reagirl.Elements[i]["Draggable"]==true then 
                draggable="Draggable. " 
              end
              reaper.TrackCtl_SetToolTip(reagirl.Elements[i]["Description"].." "..draggable..contextmenu..dropfiles, XX+15, YY+10, true)
            end
            
            if reagirl.SetPosition_MousePositionY~=gfx.mouse_y 
            and reagirl.SetPosition_MousePositionY~=gfx.mouse_x 
            and reagirl.Elements[i]["AccHoverMessage"]~=nil then
              --reagirl.osara_outputMessage(reagirl.Elements[i]["AccHoverMessage"])
              --reagirl.SetPosition_MousePositionX=-1
              --reagirl.SetPosition_MousePositionY=-1
            end
            
            --if reagirl.osara_outputMessage~=nil then reagirl.osara_outputMessage(reagirl.Elements[i]["Text"],2--[[:utf8_sub(1,20)]]) end
           end
           
           -- focused/clicked ui-element-management
           if (specific_clickstate=="FirstCLK") and reagirl.Elements[i]["IsDisabled"]==false then
             if i~=reagirl.Elements["FocusedElement"] then
               init_message=reagirl.Elements[i]["Name"].." "..reagirl.Elements[i]["GUI_Element_Type"]:sub(1,-1).." "
               local acc_message=""
               if reaper.GetExtState("ReaGirl", "osara_enable_accmessage")~="false" then
                 acc_message=reagirl.Elements[i]["AccHint"]
               end
               helptext=reagirl.Elements[i]["Description"].." "..acc_message
               reagirl.FocusRectangle_BlinkStartTime=reaper.time_precise()
               reagirl.FocusRectangle_BlinkStop=nil
             end
             
             -- set found ui-element as focused and clicked
             old_selection=reagirl.Elements.FocusedElement
             if reagirl.Elements[i].IsDecorative==true then restore=true end
             reagirl.Elements["FocusedElement"]=i
             if old_selection~=reagirl.Elements.FocusedElement then
               reagirl.ui_element_selected="first selected"
             else
               reagirl.ui_element_selected="selected"
             end
             reagirl.Elements[i]["clicked"]=true
             reagirl.UI_Element_SetFocusRect()
             reagirl.Gui_ForceRefresh(9) 
           end
           found_element=i
           break
        end
      end
    end
  end
  
  -- if osara is installed, move mouse to hover above ui-element
  if reagirl.osara_outputMessage~=nil and reagirl.oldselection~=reagirl.Elements.FocusedElement then
    reagirl.oldselection=reagirl.Elements.FocusedElement
    local i=reagirl.Elements.FocusedElement    
    if reagirl.osara_outputMessage~=nil and reaper.JS_Mouse_SetPosition~=nil then 
      local x2, y2, w2, h2
      if reagirl.Elements[i]["x"]<0 then x2=gfx.w+(reagirl.Elements[i]["x"]*scale) else x2=reagirl.Elements[i]["x"]*scale end
      if reagirl.Elements[i]["y"]<0 then y2=gfx.h+(reagirl.Elements[i]["y"]*scale) else y2=reagirl.Elements[i]["y"]*scale end
      if reagirl.Elements[i]["w"]<0 then w2=gfx.w+(-x2+reagirl.Elements[i]["w"]*scale) else w2=reagirl.Elements[i]["w"]*scale end
      if reagirl.Elements[i]["h"]<0 then h2=gfx.h+(-y2+reagirl.Elements[i]["h"]*scale) else h2=reagirl.Elements[i]["h"]*scale end

        local MoveItAllUp=reagirl.MoveItAllUp
        local MoveItAllRight=reagirl.MoveItAllRight
        if reagirl.Elements[i]["sticky_y"]==true then MoveItAllUp=0 end
        if reagirl.Elements[i]["sticky_x"]==true then MoveItAllRight=0 end
        if x2+MoveItAllRight+4<0 or x2+MoveItAllRight+4>gfx.w or 
           y2+MoveItAllUp+4<0 or y2+MoveItAllUp+4>gfx.h then
          if reagirl.Elements[i]["ContextMenu"]~=nil then
            reaper.MB("This sticky ui-element, that contains a context menu, is outside of the viewable area of the window. If you want to right-click it to use the context-menu, try resizing the window.\n\nIf that doesn't work, report this issue to the developer of this script, please. The name of the ui-element in question is: "..reagirl.Elements[i]["Name"], "Potential Issue with this gui-script.", 0)
            gfx.init("")
          end
        else
          if gfx.mouse_cap&1==0 and gfx.mouse_cap&2==0 then
            local cap_w=0
            if reagirl.Elements[i]["Cap_width"]~=nil then
              cap_w=reagirl.Elements[i]["Cap_width"]
            end
            if reaper.GetExtState("ReaGirl", "osara_move_mouse")~="false" then
              if reagirl.MouseJump_Skip==nil then
                reaper.JS_Mouse_SetPosition(gfx.clienttoscreen(x2+cap_w+MoveItAllRight+4,y2+MoveItAllUp+4)) 
              end
            end
          end
        end
        reagirl.SetPosition_MousePositionX=gfx.mouse_x
        reagirl.SetPosition_MousePositionY=gfx.mouse_y
        reagirl.UI_Elements_HoveredElement_Old=i
        reagirl.UI_Elements_HoveredElement=i
        skip_hover_acc_message=true
    end
  end
  
  --[[
  if reagirl.SetPosition_MousePositionY~=gfx.mouse_y or reagirl.SetPosition_MousePositionX~=gfx.mouse_x then
    if reagirl.UI_Elements_HoveredElement~=-1 and reagirl.UI_Elements_HoveredElement~=reagirl.UI_Elements_HoveredElement_Old then
      if reagirl.osara_outputMessage~=nil then
        if skip_hover_acc_message==false then
          reagirl.osara_outputMessage(reagirl.Elements[reagirl.UI_Elements_HoveredElement]["Name"])
        end
      end
      reagirl.UI_Elements_HoveredElement_Old=reagirl.UI_Elements_HoveredElement
    end
  end
  
  reagirl.SetPosition_MousePositionX=gfx.mouse_x
  reagirl.SetPosition_MousePositionY=gfx.mouse_y
  --]]
  if skip_hover_acc_message==false then
    if reagirl.SetPosition_MousePositionX~=gfx.mouse_x or reagirl.SetPosition_MousePositionY~=gfx.mouse_y then
      if reagirl.UI_Elements_HoveredElement~=-1 then
        if reagirl.UI_Elements_HoveredElement~=reagirl.UI_Elements_HoveredElement_Old then
          local description=""
          if reagirl.Elements[reagirl.UI_Elements_HoveredElement]["GUI_Element_Type"]=="Edit" then
            description=reagirl.Elements[reagirl.UI_Elements_HoveredElement]["Text"]
          end
          if reagirl.Elements[reagirl.UI_Elements_HoveredElement]["GUI_Element_Type"]~="Tabs" then
            if reagirl.Window_State&8==8 and reaper.GetExtState("ReaGirl", "osara_hover_mouse")~="false" then
              if reagirl.osara_outputMessage~=nil then
                reagirl.osara_outputMessage(reagirl.Elements[reagirl.UI_Elements_HoveredElement]["Name"].." "..description)
              end
              reagirl.Osara_Debug_Message(reagirl.Elements[reagirl.UI_Elements_HoveredElement]["Name"].." "..description)
            end
          end
        end
      end
    end
  end
  if reagirl.UI_Elements_HoveredElement~=-1 then
    --print_update(reagirl.UI_Elements_HoveredElement_Old, reagirl.UI_Elements_HoveredElement,reaper.time_precise())
    --for i=0, 10000000 do end
    reagirl.UI_Elements_HoveredElement_Old=reagirl.UI_Elements_HoveredElement
  end
  reagirl.SetPosition_MousePositionX=gfx.mouse_x
  reagirl.SetPosition_MousePositionY=gfx.mouse_y
  
  if reagirl.Elements["GlobalAccHoverMessage"]~=reagirl.Elements["GlobalAccHoverMessageOld"] then
    if reagirl.osara_outputMessage~=nil then
      reagirl.osara_outputMessage(reagirl.Elements["GlobalAccHoverMessage"])
    end
    reagirl.Osara_Debug_Message(reagirl.Elements["GlobalAccHoverMessage"])
    reagirl.Elements["GlobalAccHoverMessageOld"]=reagirl.Elements["GlobalAccHoverMessage"]
  end

  --[[context menu]]
  -- show context-menu if the last defer-loop had a right-click onto a ui-element
  local ContextShow
  if reagirl.UI_Elements_HoveredElement~=-1 and reagirl.ContextMenuClicked==true then
    gfx.x=gfx.mouse_x
    gfx.y=gfx.mouse_y
    if reagirl.Elements[reagirl.UI_Elements_HoveredElement]["ContextMenu"]~=nil then
      local selection=gfx.showmenu(reagirl.Elements[reagirl.UI_Elements_HoveredElement]["ContextMenu"])
      
      if selection>0 then
        reagirl.Elements[reagirl.UI_Elements_HoveredElement]["ContextMenuFunction"](reagirl.Elements[reagirl.UI_Elements_HoveredElement]["Guid"], math.tointeger(selection))
        reagirl.Gui_ForceRefresh(985)
      end
    end
    -- workaround to prevent, that the menu is shown twice in a row
    ContextShow=true
  end
  reagirl.ContextMenuClicked=nil
  -- if rightclicked on a ui-element, signal that the next defer-loop(after gui-refresh) shall show a context-menu
  if ContextShow~=true and reagirl.ContextMenuClicked~=true and reagirl.UI_Elements_HoveredElement~=-1 and gfx.mouse_cap==2 then
    reagirl.ContextMenuClicked=true
  end
  reagirl.UI_Elements_HoveredElement_Old=reagirl.UI_Elements_HoveredElement
  
  --[[dropdown-menu]]
  local retval=gfx.getdropfile(0)
  local count=0
  local files={}
  if retval>0 then
    while gfx.getdropfile(count)==1 do
      retval, files[count+1]=gfx.getdropfile(count)
      count=count+1
    end
    gfx.getdropfile(-1)
  end
  if #files>0 and reagirl.UI_Elements_HoveredElement~=-1 and reagirl.Elements[reagirl.UI_Elements_HoveredElement]["DropZoneFunction"]~=nil then 
    reagirl.Elements[reagirl.UI_Elements_HoveredElement]["DropZoneFunction"](reagirl.Elements[reagirl.UI_Elements_HoveredElement]["Guid"], files)
    reagirl.Gui_ForceRefresh(984)
  end
  
  -- run all gui-element-management functions once. They shall decide, if a refresh is needed, provide the osara-screen reader-message and everything
  -- this is also the code, where a clickstate of a selected ui-element is interpreted
  
  for i=#reagirl.Elements, 1, -1 do
    if reagirl.Elements[i]["hidden"]~=true then
      local x2, y2, w2, h2
      if reagirl.Elements[i]["x"]<0 then x2=gfx.w+(reagirl.Elements[i]["x"]*scale) else x2=(reagirl.Elements[i]["x"]*scale) end
      if reagirl.Elements[i]["y"]<0 then y2=gfx.h+(reagirl.Elements[i]["y"]*scale) else y2=(reagirl.Elements[i]["y"]*scale) end
      if reagirl.Elements[i]["w"]<0 then w2=gfx.w+(-x2+reagirl.Elements[i]["w"]*scale) else w2=reagirl.Elements[i]["w"]*scale end
      if reagirl.Elements[i]["h"]<0 then h2=gfx.h+(-y2+reagirl.Elements[i]["h"]*scale) else h2=reagirl.Elements[i]["h"]*scale end
      
      local MoveItAllUp=reagirl.MoveItAllUp   
      local MoveItAllRight=reagirl.MoveItAllRight
      if reagirl.Elements[i]["sticky_y"]==true then MoveItAllUp=0 end
      if reagirl.Elements[i]["sticky_x"]==true then MoveItAllRight=0 end
      --if (x2+MoveItAllRight>=0 and x2+MoveItAllRight<=gfx.w) or (y2+MoveItAllUp>=0 and y2+MoveItAllUp<=gfx.h) or (x2+MoveItAllRight+w2>=0 and x2+MoveItAllRight+w2<=gfx.w) or (y2+MoveItAllUp+h2>=0 and y2+MoveItAllUp+h2<=gfx.h) then
      -- uncommented code: might improve performance by running only manage-functions of UI-elements, who are visible(though might be buggy)
      --                   but seems to work without it as well
      if reagirl.Elements[i]["IsDisabled"]==false and reagirl.EditMode~=true then
        if i==reagirl.Elements["FocusedElement"] or ((((x2+reagirl.MoveItAllRight>0 and x2+reagirl.MoveItAllRight<=gfx.w) 
        or (x2+w2+reagirl.MoveItAllRight>0 and x2+w2+reagirl.MoveItAllRight<=gfx.w) 
        or (x2+reagirl.MoveItAllRight<=0 and x2+w2+reagirl.MoveItAllRight>=gfx.w))
        and ((y2+reagirl.MoveItAllUp>=0 and y2+reagirl.MoveItAllUp<=gfx.h)
        or (y2+h2+reagirl.MoveItAllUp>=0 and y2+h2+reagirl.MoveItAllUp<=gfx.h)
        or (y2+reagirl.MoveItAllUp<=0 and y2+h2+reagirl.MoveItAllUp>=gfx.h))) or i>#reagirl.Elements-6)
        then--]]  
        
          -- run manage-function of ui-element
          local selected="not selected"
          if reagirl.Elements.FocusedElement==i then selected=reagirl.ui_element_selected end
          local cur_message, refresh=reagirl.Elements[i]["func_manage"](i, selected,
            reagirl.UI_Elements_HoveredElement==i,
            specific_clickstate,
            gfx.mouse_cap,
            {click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel},
            reagirl.Elements[i]["Name"],
            reagirl.Elements[i]["Description"], 
            math.tointeger(x2+MoveItAllRight),
            math.tointeger(y2+MoveItAllUp),
            math.tointeger(w2),
            math.tointeger(h2),
            Key,
            Key_utf,
            reagirl.Elements[i]
          )
          if i==reagirl.Elements.FocusedElement then message=cur_message end
          --print_update(message)
        end -- only run manage-functions of visible gui-elements
        
        -- output screen reader-message of ui-element
        if reagirl.Elements["FocusedElement"]==i and reagirl.Elements[reagirl.Elements["FocusedElement"]]["IsDisabled"]==false and reagirl.old_osara_message~=message then
          
          if message==nil then message="" end
          
          -- ContextMenu_ACC
          -- DropZoneFunction_ACC
          --print(init_message)
          local acc_message=""
          local contextmenu=reagirl.Elements[reagirl.Elements["FocusedElement"]]["ContextMenu_ACC"]
          local dropfiles=reagirl.Elements[reagirl.Elements["FocusedElement"]]["DropZoneFunction_ACC"]
          local draggable=""
          if init_message~="" then
            acc_message=""--reagirl.Elements[reagirl.Elements["FocusedElement"]]["ContextMenu_ACC"]..reagirl.Elements[reagirl.Elements["FocusedElement"]]["DropZoneFunction_ACC"]
          end
          if reaper.GetExtState("ReaGirl", "osara_enable_accmessage")=="false" then
            if reagirl.Elements[reagirl.Elements["FocusedElement"]]["ContextMenu_ACC"]~="" then
              contextmenu=" Has Contextmenu."
            end
            if reagirl.Elements[reagirl.Elements["FocusedElement"]]["DropZoneFunction_ACC"]~="" then
              dropfiles=" Allows dropping of files."
            end
            if reagirl.Elements[reagirl.Elements["FocusedElement"]]["Draggable"]==true then 
              draggable=" Draggable. " 
            end
          end
          if reagirl.osara_outputMessage~=nil then
            reagirl.osara_outputMessage(reagirl.osara_init_message.." "..init_message.." "..message.." "..helptext..draggable..acc_message..contextmenu..dropfiles..reagirl.osara_AddedMessage)
            reagirl.osara_AddedMessage=""
          end
          reagirl.Osara_Debug_Message(reagirl.osara_init_message.." "..init_message.." "..message.." "..helptext..draggable..acc_message..contextmenu..dropfiles)
          reagirl.old_osara_message=message
          reagirl.osara_init_message=""
        end
        -- ugly hack to prevent focus rect being drawn wrong
        if reagirl.init_refresh~=6 then reagirl.Gui_ForceRefresh(-99) reagirl.init_refresh=reagirl.init_refresh+1 end
        -- end of ugly hack
        
        if refresh==true then reagirl.Gui_ForceRefresh(10) end
      end
    end
  end
  
  if restore==true then
    reagirl.Elements.FocusedElement=old_selection
  end
  
  if specific_clickstate=="FirstCLK" then
    reagirl.EditMode_FocusedElement=reagirl.Elements.FocusedElement
    reagirl.EditMode_OldMouseX=gfx.mouse_x
    reagirl.EditMode_OldMouseY=gfx.mouse_y
  end
  --[[
  if mouse_cap==28 and Key==261 then
    if reagirl.EditMode==true then reagirl.EditMode=false else reagirl.EditMode=true end
    reagirl.Gui_ForceRefresh(983)
    reaper.MB("Edit_Mode="..tostring(reagirl.EditMode),"",0)
  end
  --]]
  if reagirl.EditMode==true then
    if Key==103 then
      if reagirl.EditMode_Grid then reagirl.EditMode_Grid=false else reagirl.EditMode_Grid=true end
      reagirl.Gui_ForceRefresh(982)
    end
    if specific_clickstate=="DBLCLK" then 
      local retval, retval_csv = reaper.GetUserInputs("Enter new name", 1, "extrawidth=300", reagirl.Elements[reagirl.EditMode_FocusedElement]["Name"])
      reagirl.Window_SetFocus()
      if retval==true then
        reagirl.Elements[reagirl.EditMode_FocusedElement]["Name"]=retval_csv
        reagirl.Gui_ForceRefresh(981)
      end
    elseif specific_clickstate=="DRAG" then
     local difx, dify
     local dpi_scale=reagirl.Window_GetCurrentScale()
      difx=gfx.mouse_x-reagirl.EditMode_OldMouseX
      dify=gfx.mouse_y-reagirl.EditMode_OldMouseY
      reagirl.Elements[reagirl.EditMode_FocusedElement]["x"]=reagirl.Elements[reagirl.EditMode_FocusedElement]["x"]+difx/dpi_scale
      reagirl.Elements[reagirl.EditMode_FocusedElement]["y"]=reagirl.Elements[reagirl.EditMode_FocusedElement]["y"]+dify/dpi_scale
      reagirl.EditMode_OldMouseX=gfx.mouse_x
      reagirl.EditMode_OldMouseY=gfx.mouse_y
      reagirl.Gui_ForceRefresh(980)
    elseif mouse_hwheel<0 then 
      reagirl.Elements[reagirl.EditMode_FocusedElement]["w"]=reagirl.Elements[reagirl.EditMode_FocusedElement]["w"]+2
      reagirl.Gui_PreventScrollingForOneCycle(true, true, true)
    elseif mouse_hwheel>0 then 
      reagirl.Elements[reagirl.EditMode_FocusedElement]["w"]=reagirl.Elements[reagirl.EditMode_FocusedElement]["w"]-2
      reagirl.Gui_PreventScrollingForOneCycle(true, true, true)
    elseif mouse_wheel>0 then 
      reagirl.Elements[reagirl.EditMode_FocusedElement]["h"]=reagirl.Elements[reagirl.EditMode_FocusedElement]["h"]+1
      reagirl.Gui_PreventScrollingForOneCycle(true, true, true)
    elseif mouse_wheel<0 then 
      reagirl.Elements[reagirl.EditMode_FocusedElement]["h"]=reagirl.Elements[reagirl.EditMode_FocusedElement]["h"]-1
      reagirl.Gui_PreventScrollingForOneCycle(true, true, true)
    end
  end
  
  -- custom-screen reader message
  if reagirl.ScreenReader_SendMessage_ActualMessage~="" and reagirl.osara_outputMessage~=nil then
    reagirl.osara_outputMessage(reagirl.ScreenReader_SendMessage_ActualMessage)
  end
  reagirl.ScreenReader_SendMessage_ActualMessage=""
  
  -- go over to draw the ui-elements
  reagirl.Gui_Draw(Key, Key_utf, clickstate, specific_clickstate, mouse_cap, click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel)
  if reagirl.Window_SetFocus_Trigger==true then
    reagirl.Window_SetFocus()
    reagirl.Window_SetFocus_Trigger=nil
  end
  if reagirl.UI_Elements_HoveredElement==-1 and gfx.mouse_cap==0 then
    gfx.setcursor(1)
  end
  if reagirl.Gui_Manage_keep_running==true and reagirl.Gui_IsOpen()==true then
    reaper.defer(reagirl.Gui_Manage)
  else
    reagirl.Gui_Manage_keep_running=nil
  end
end

function reagirl.Gui_Draw(Key, Key_utf, clickstate, specific_clickstate, mouse_cap, click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel)
  -- no docs in API-docs
  -- draw the ui-elements, if refresh-state=true
  
  local selected, x2, y2
  local scale=reagirl.Window_CurrentScale
  
  if reagirl.Gui_ForceRefreshState==true then
    -- clear background and draw bg-color/background image
    gfx.set(reagirl["WindowBackgroundColorR"],reagirl["WindowBackgroundColorG"],reagirl["WindowBackgroundColorB"])
    gfx.rect(0,0,gfx.w,gfx.h,1)
    reagirl.Background_DrawImage()

    -- draw Tabs
    if reagirl.Tabs_Count~=nil then
      local i=reagirl.Tabs_Count
      local minimum_visible_x, maximum_visible_x, minimum_visible_y, maximum_visible_y, minimum_all_x, maximum_all_x, maximum_all_y, maximum_all_y = reagirl.Gui_GetBoundaries()
      local w_add=reagirl.Elements[i]["bg_w"]
      if w_add==nil then w_add=maximum_visible_x end
      local h_add=reagirl.Elements[i]["bg_h"]
      if h_add==nil then h_add=maximum_visible_y end
      local x2, y2, w2, h2
      if reagirl.Elements[i]["x"]<0 then x2=gfx.w+(reagirl.Elements[i]["x"]*scale) else x2=reagirl.Elements[i]["x"]*scale end
      if reagirl.Elements[i]["y"]<0 then y2=gfx.h+(reagirl.Elements[i]["y"]*scale) else y2=reagirl.Elements[i]["y"]*scale end
    
      if reagirl.Elements[i]["w"]<0 then w2=gfx.w+(-x2+(reagirl.Elements[i]["w"]+w_add)*scale) else w2=(reagirl.Elements[i]["w"]+w_add)*scale end
      if reagirl.Elements[i]["h"]<0 then h2=gfx.h+(-y2+(reagirl.Elements[i]["h"]+h_add)*scale) else h2=(reagirl.Elements[i]["h"]+h_add)*scale end
      
      local selected="not selected"
      if reagirl.Elements.FocusedElement==i then selected=reagirl.ui_element_selected end
      local message=reagirl.Elements[i]["func_draw"](i, selected,
        reagirl.UI_Elements_HoveredElement==i,
        specific_clickstate,
        gfx.mouse_cap,
        {click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel},
        reagirl.Elements[i]["Name"],
        reagirl.Elements[i]["Description"], 
        math.floor(x2+reagirl.MoveItAllRight),
        math.floor(y2+reagirl.MoveItAllUp),
        math.floor(w2),
        math.floor(h2),
        Key,
        Key_utf,
        reagirl.Elements[i]
      )
    end
    
    -- draw all ui-elements
    
    for i=#reagirl.Elements-6, 1, -1 do

      if reagirl.Elements[i]["hidden"]~=true then
        local x2, y2, w2, h2

        if reagirl.Elements[i]["x"]<0 then x2=gfx.w+(reagirl.Elements[i]["x"]*scale) else x2=reagirl.Elements[i]["x"]*scale end
        if reagirl.Elements[i]["y"]<0 then y2=gfx.h+(reagirl.Elements[i]["y"]*scale) else y2=reagirl.Elements[i]["y"]*scale end
        
        if reagirl.Elements[i]["w"]<0 then w2=gfx.w+(-x2+(reagirl.Elements[i]["w"])*scale) else w2=(reagirl.Elements[i]["w"])*scale end
        if reagirl.Elements[i]["h"]<0 then h2=gfx.h+(-y2+(reagirl.Elements[i]["h"])*scale) else h2=(reagirl.Elements[i]["h"])*scale end

  
        local MoveItAllUp=reagirl.MoveItAllUp  
        local MoveItAllRight=reagirl.MoveItAllRight
        if reagirl.Elements[i]["sticky_y"]==true then MoveItAllUp=0 end
        if reagirl.Elements[i]["sticky_x"]==true then MoveItAllRight=0 end
        
        -- run the draw-function of the ui-element
        
        -- the following lines shall limit drawing on only visible areas. However, when non-resized images are used, the width and height don't match and therefor the image might disappear when scrolling
        --if (x2+MoveItAllRight>=0 and x2+MoveItAllRight<=gfx.w)       and (y2+MoveItAllUp>=0    and y2+MoveItAllUp<=gfx.h) 
        --or (x2+MoveItAllRight+w2>=0 and x2+MoveItAllRight+w2<=gfx.w) and (y2+MoveItAllUp+h2>=0 and y2+MoveItAllUp+h2<=gfx.h) then
        
        local w_add=0
        local h_add=0
        if reagirl.Elements[i]["GUI_Element_Type"]:sub(-5, -1)=="Label" then
          w_add=reagirl.Elements[i]["bg_w"]*reagirl.Window_GetCurrentScale()
          h_add=reagirl.Elements[i]["bg_h"]*reagirl.Window_GetCurrentScale()
        end
        
        if reagirl.Elements[i]["GUI_Element_Type"]=="Tabs" or 
         (((x2+MoveItAllRight>0 and x2+MoveItAllRight<=gfx.w) 
        or (x2+w2+w_add+MoveItAllRight>0 and x2+w2+w_add+MoveItAllRight<=gfx.w) 
        or (x2+MoveItAllRight<=0 and x2+w2+w_add+MoveItAllRight>=gfx.w))
        and ((y2+MoveItAllUp>=0 and y2+MoveItAllUp<=gfx.h)
        or (y2+h2+h_add+MoveItAllUp>=0 and y2+h_add+h2+MoveItAllUp<=gfx.h)
        or (y2+MoveItAllUp<=0 and y2+h2+h_add+MoveItAllUp>=gfx.h))) or i>#reagirl.Elements-6
        then
        --]]
   --     print_update((x2+reagirl.MoveItAllRight>=0 and x2+reagirl.MoveItAllRight<=gfx.w), x2+MoveItAllRight, (x2+reagirl.MoveItAllRight+w2>=0 and x2+reagirl.MoveItAllRight+w2<=gfx.w))
        --AAAAA=AAAAA+1
          local selected="not selected"
          if reagirl.Elements.FocusedElement==i then selected=reagirl.ui_element_selected end
          if i~=reagirl.Tabs_Count then
            local message=reagirl.Elements[i]["func_draw"](i, selected,
              reagirl.UI_Elements_HoveredElement==i,
              specific_clickstate,
              gfx.mouse_cap,
              {click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel},
              reagirl.Elements[i]["Name"],
              reagirl.Elements[i]["Description"], 
              math.floor(x2+MoveItAllRight),
              math.floor(y2+MoveItAllUp),
              math.floor(w2),
              math.floor(h2),
              Key,
              Key_utf,
              reagirl.Elements[i]
            )
          end
        end -- draw_only_necessary-elements
        if reagirl.Elements["FocusedElement"]~=-1 and reagirl.Elements["FocusedElement"]==i then
          --if reagirl.Elements[i]["GUI_Element_Type"]=="DropDownMenu" then --  if w2<20 then w2=20 end end
          local r,g,b,a=gfx.r,gfx.g,gfx.b,gfx.a
          local dest=gfx.dest
          gfx.dest=-1
          gfx.set(0.7,0.7,0.7,0.8)
          local _,_,_,_,x,y,w,h=reagirl.UI_Element_GetFocusRect()
          --print_update(scale, x, y, w, h, reagirl.Font_Size)
          if reagirl.Focused_Rect_Override==nil then
            local a=gfx.a
            local dpi_scale=reagirl.Window_GetCurrentScale()
            gfx.a=reagirl.FocusRectangle_Alpha
            gfx.rect((x2+MoveItAllRight)-dpi_scale, (y2+MoveItAllUp-dpi_scale*2), (w2+dpi_scale*3), reagirl.Window_GetCurrentScale(), 1)
            gfx.rect((x2+MoveItAllRight)-dpi_scale-dpi_scale, (y2+MoveItAllUp)-dpi_scale*2, reagirl.Window_GetCurrentScale(), h2+dpi_scale+dpi_scale+dpi_scale+dpi_scale, 1)
            gfx.rect((x2+MoveItAllRight)+w2+dpi_scale, (y2+MoveItAllUp)-dpi_scale*2+reagirl.Window_GetCurrentScale(), reagirl.Window_GetCurrentScale(), h2+dpi_scale+dpi_scale+dpi_scale+dpi_scale, 1)
            gfx.rect((x2+MoveItAllRight)-dpi_scale-dpi_scale, (y2+h2+dpi_scale+dpi_scale+MoveItAllUp), (w2+dpi_scale*3), reagirl.Window_GetCurrentScale(), 1)
            
            gfx.a=a
            reagirl.Focused_Rect_Override=nil
          else
            local dpi_scale=reagirl.Window_GetCurrentScale()
            local a=gfx.a
            gfx.a=reagirl.FocusRectangle_Alpha
            gfx.rect((reagirl.Elements["Focused_x"])+reagirl.Window_GetCurrentScale(), (reagirl.Elements["Focused_y"]), reagirl.Elements["Focused_w"], reagirl.Window_GetCurrentScale(), 1)
            gfx.rect((reagirl.Elements["Focused_x"]), (reagirl.Elements["Focused_y"]), reagirl.Window_GetCurrentScale(), reagirl.Elements["Focused_h"], 1)
            gfx.rect((reagirl.Elements["Focused_x"])+reagirl.Elements["Focused_w"], (reagirl.Elements["Focused_y"])+reagirl.Window_GetCurrentScale(), reagirl.Window_GetCurrentScale(), reagirl.Elements["Focused_h"], 1)
            gfx.rect((reagirl.Elements["Focused_x"]), (reagirl.Elements["Focused_y"])+reagirl.Elements["Focused_h"], reagirl.Elements["Focused_w"], reagirl.Window_GetCurrentScale(), 1)
            gfx.a=a
            
          end
          reagirl.Focused_Rect_Override=nil
          gfx.set(r,g,b,a)
          gfx.dest=dest
          
          
        end
      end
    end
  
    -- draw scrollbars and scrollbuttons
    for i=#reagirl.Elements-5, #reagirl.Elements, 1 do
      local selected="not selected"
      local x2,y2,h2,w2
      if reagirl.Elements.FocusedElement==i then selected=reagirl.ui_element_selected end
      
      if reagirl.Elements[i]["x"]<0 then x2=gfx.w+(reagirl.Elements[i]["x"]*scale) else x2=reagirl.Elements[i]["x"]*scale end
      if reagirl.Elements[i]["y"]<0 then y2=gfx.h+(reagirl.Elements[i]["y"]*scale) else y2=reagirl.Elements[i]["y"]*scale end
    
      if reagirl.Elements[i]["w"]<0 then w2=gfx.w+(-x2+(reagirl.Elements[i]["w"])*scale) else w2=(reagirl.Elements[i]["w"])*scale end
      if reagirl.Elements[i]["h"]<0 then h2=gfx.h+(-y2+(reagirl.Elements[i]["h"])*scale) else h2=(reagirl.Elements[i]["h"])*scale end
  
      local message=reagirl.Elements[i]["func_draw"](i, selected,
        reagirl.UI_Elements_HoveredElement==i,
        specific_clickstate,
        gfx.mouse_cap,
        {click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel},
        reagirl.Elements[i]["Name"],
        reagirl.Elements[i]["Description"], 
        math.floor(x2),
        math.floor(y2),
        math.floor(w2),
        math.floor(h2),
        Key,
        Key_utf,
        reagirl.Elements[i]
      )
    end
  end
  if reagirl.EditMode==true and reagirl.Gui_ForceRefreshState==true then
    if reagirl.EditMode_Grid==true then
      local olda=gfx.a
      gfx.a=0.1
      for i=0, gfx.w, reagirl.Window_GetCurrentScale()*10 do
        gfx.line(i, 0, i, gfx.h)
      end
      for i=0, gfx.w, reagirl.Window_GetCurrentScale()*10 do
        gfx.line(0, i, gfx.w, i)
      end
      gfx.a=olda
    end
    local oldx=gfx.x
    local oldy=gfx.y
    local r=gfx.r
    local g=gfx.g
    local b=gfx.b
    local a=gfx.a
    gfx.x=0
    gfx.y=0
    gfx.set(1,0,0,0.5)
    gfx.drawstr("X:\t"..reagirl.Elements[reagirl.EditMode_FocusedElement]["x"])
    gfx.y=gfx.y+gfx.texth
    gfx.x=0
    gfx.drawstr("Y:\t"..reagirl.Elements[reagirl.EditMode_FocusedElement]["y"])
    gfx.y=gfx.y+gfx.texth
    gfx.x=0
    gfx.drawstr("W:\t"..reagirl.Elements[reagirl.EditMode_FocusedElement]["w"])
    gfx.y=gfx.y+gfx.texth
    gfx.x=0
    gfx.drawstr("H:\t"..reagirl.Elements[reagirl.EditMode_FocusedElement]["h"])
    gfx.x=oldx
    gfx.y=oldy
    gfx.set(1,0,0,0.5)
    local x2, y2, w2, h2
    local scale=reagirl.Window_GetCurrentScale()
    if reagirl.Elements[reagirl.EditMode_FocusedElement]["x"]<0 then x2=gfx.w+(reagirl.Elements[reagirl.EditMode_FocusedElement]["x"]*scale) else x2=reagirl.Elements[reagirl.EditMode_FocusedElement]["x"]*scale end
    if reagirl.Elements[reagirl.EditMode_FocusedElement]["y"]<0 then y2=gfx.h+(reagirl.Elements[reagirl.EditMode_FocusedElement]["y"]*scale) else y2=reagirl.Elements[reagirl.EditMode_FocusedElement]["y"]*scale end
    if reagirl.Elements[reagirl.EditMode_FocusedElement]["w"]<0 then w2=gfx.w+(-x2+reagirl.Elements[reagirl.EditMode_FocusedElement]["w"]*scale) else w2=reagirl.Elements[reagirl.EditMode_FocusedElement]["w"]*scale end
    if reagirl.Elements[reagirl.EditMode_FocusedElement]["h"]<0 then h2=gfx.h+(-y2+reagirl.Elements[reagirl.EditMode_FocusedElement]["h"]*scale) else h2=reagirl.Elements[reagirl.EditMode_FocusedElement]["h"]*scale end
    
    local cap_w=reagirl.Elements[reagirl.EditMode_FocusedElement]["cap_w"]
    if cap_w~=nil then cap_w=math.tointeger(cap_w)+scale*5+5*scale end
    if reagirl.Elements[reagirl.EditMode_FocusedElement]["Cap_width"]~=nil then 
      cap_w=reagirl.Elements[reagirl.EditMode_FocusedElement]["Cap_width"]
    end
    
    gfx.line(x2+reagirl.MoveItAllRight, 0, x2+reagirl.MoveItAllRight, gfx.h)
    if cap_w~=nil then gfx.line(x2+reagirl.MoveItAllRight+cap_w*scale, 0, x2+reagirl.MoveItAllRight+cap_w*scale, gfx.h) end
    gfx.line(x2+w2+reagirl.MoveItAllRight, 0, x2+w2+reagirl.MoveItAllRight, gfx.h)
    gfx.line(0, y2-1+reagirl.MoveItAllUp, gfx.w, y2-1+reagirl.MoveItAllUp)
    gfx.line(0, y2+h2-1+reagirl.MoveItAllUp, gfx.w, y2+h2-1+reagirl.MoveItAllUp)
    gfx.set(r,g,b,a)
  end
  
  if reagirl.Draggable_Element~=nil then
    --ABBA=reaper.time_precise()
    if gfx.mouse_x~=reagirl.Elements[reagirl.Draggable_Element]["mouse_x"] or
       gfx.mouse_y~=reagirl.Elements[reagirl.Draggable_Element]["mouse_y"] then
      local image_slot=reagirl.DragImageSlot
      local resize=1
      local mode=1
      if reagirl.Elements[reagirl.Draggable_Element]["GUI_Element_Type"]=="Image" then image_slot=reagirl.Elements[reagirl.Draggable_Element]["Image_Storage"] resize=0.5 mode=0 end
      local imgw, imgh = gfx.getimgdim(image_slot)
      local oldgfxa=gfx.a
      gfx.a=0.7
      local oldmode=gfx.mode
      gfx.mode=mode
      gfx.blit(image_slot,1,0,0,0,imgw,imgh,gfx.mouse_x-20,gfx.mouse_y-20,imgw*resize,imgh*resize)
      gfx.a=oldgfxa
      gfx.mode=oldmode
      reagirl.Elements[reagirl.Draggable_Element]["mouse_x"]=-1
      reagirl.Elements[reagirl.Draggable_Element]["mouse_y"]=-1
      local blink_length=tonumber(reaper.GetExtState("ReaGirl", "highlight_drag_destination_blink"))
      if blink_length==nil then blink_length=0 end

      local x2, w2, y2, h2
      if reaper.GetExtState("ReaGirl", "highlight_drag_destinations")~="false" then
        if reagirl.Blink_DragDestinations<=blink_length then
          local scale=reagirl.Window_GetCurrentScale()
          local oldr,oldg,oldb,olda=gfx.r, gfx.g, gfx.b, gfx.a
          --reaper.ClearConsole()
          for i=1, #reagirl.Elements[reagirl.Draggable_Element]["DraggableDestinations"] do
            local element_id=reagirl.Elements[reagirl.Draggable_Element]["DraggableDestinations"][i]
            element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
            
            --print(reagirl.Elements[reagirl.Draggable_Element]["DraggableDestinations"][i])
            if reagirl.Elements[element_id]["x"]<0 then x2=gfx.w+(reagirl.Elements[element_id]["x"]*scale) else x2=reagirl.Elements[element_id]["x"]*scale end
            if reagirl.Elements[element_id]["y"]<0 then y2=gfx.h+(reagirl.Elements[element_id]["y"]*scale) else y2=reagirl.Elements[element_id]["y"]*scale end
            if reagirl.Elements[element_id]["w"]<0 then w2=gfx.w+(-x2+reagirl.Elements[element_id]["w"]*scale) else w2=reagirl.Elements[element_id]["w"]*scale end
            if reagirl.Elements[element_id]["h"]<0 then h2=gfx.h+(-y2+reagirl.Elements[element_id]["h"]*scale) else h2=reagirl.Elements[element_id]["h"]*scale end
            gfx.set(1,1,1,0.2)
            
            gfx.rect(x2+reagirl.MoveItAllRight,y2+reagirl.MoveItAllUp,w2,h2,1)
            gfx.set(0,0,0,0.4)
            gfx.rect(x2+reagirl.MoveItAllRight,y2+reagirl.MoveItAllUp,w2,h2,0)
          end
        end
        reagirl.Blink_DragDestinations=reagirl.Blink_DragDestinations+1
        if reagirl.Blink_DragDestinations>blink_length*2 then 
          reagirl.Blink_DragDestinations=0
        end
      end
    end
    if gfx.mouse_x>gfx.w then reagirl.UI_Element_ScrollX(-2) end
    if gfx.mouse_x<0 then reagirl.UI_Element_ScrollX(2) end
    if gfx.mouse_y>gfx.h then reagirl.UI_Element_ScrollY(-2) end
    if gfx.mouse_y<0 then reagirl.UI_Element_ScrollY(2) end
    if gfx.mouse_x>0 and gfx.mouse_x<gfx.w and gfx.mouse_y>0 and gfx.mouse_y<gfx.h then
      reagirl.MoveItAllUp_Delta=0
      reagirl.MoveItAllRight_Delta=0
    end
  else
    reagirl.Gui_ForceRefreshState=false
    reagirl.Blink_DragDestinations=0
  end
  
  
  reagirl.Scroll_Override_ScrollButtons=nil
  --DebugRect()
end

function reagirl.Dummy()

end

function reagirl.UI_Element_SetFocusRect(override, x, y, w, h)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_SetFocusRect</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.UI_Element_SetFocusRect(optional boolean override, integer x, integer y, integer w, integer h)</functioncall>
  <description>
    sets the rectangle for focused ui-element. Can be used for custom ui-element, who need to control the focus-rectangle due some of their own ui-elements incorporated, like options in radio-buttons, etc.
  </description>
  <parameters>
    optional boolean override - I forgot...
    integer x - the x-position of the focus-rectangle; negative, anchor to the right windowborder
    integer y - the y-position of the focus-rectangle; negative, anchor to the bottom windowborder
    integer w - the width of the focus-rectangle; negative, anchor to the right windowborder
    integer h - the height of the focus-rectangle; negative, anchor to the bottom windowborder
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, focus rectangle</tags>
</US_DocBloc>
]]
  if override==nil then override=false end
  if override~=nil and type(override)~="boolean" then error("UI_Element_SetFocusRect: param #1 - must be either nil or a boolean", 2) end
  if override==true then
    if math.type(x)~="integer" then error("UI_Element_SetFocusRect: param #2 - when override=nil then it must be an integer", 2) end
    if math.type(y)~="integer" then error("UI_Element_SetFocusRect: param #3 - when override=nil then it must be an integer", 2) end
    if math.type(w)~="integer" then error("UI_Element_SetFocusRect: param #4 - when override=nil then it must be an integer", 2) end
    if math.type(h)~="integer" then error("UI_Element_SetFocusRect: param #5 - when override=nil then it must be an integer", 2) end
  end
  
  if override==false then 
    if reagirl.Elements[reagirl.Elements["FocusedElement"]]==nil then error("UI_Element_SetFocusRect: - no ui-elements existing", 2) end
    x=reagirl.Elements[reagirl.Elements["FocusedElement"]]["x"]
    y=reagirl.Elements[reagirl.Elements["FocusedElement"]]["y"]
    w=reagirl.Elements[reagirl.Elements["FocusedElement"]]["w"]
    h=reagirl.Elements[reagirl.Elements["FocusedElement"]]["h"]
    reagirl.Focused_Rect_Override=nil
  end
  if override==true then 
    reagirl.Focused_Rect_Override=true 
    reagirl.Elements["Focused_x"]=x
    reagirl.Elements["Focused_y"]=y
    reagirl.Elements["Focused_w"]=w
    reagirl.Elements["Focused_h"]=h
  end
end



function reagirl.UI_Element_GetFocusRect()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetFocusRect</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer x, integer y, integer w, integer h, integer x2, integer y2, integer w2, integer h2 = reagirl.UI_Element_GetFocusRect()</functioncall>
  <description>
    gets the rectangle for focused ui-element. Can be used for custom ui-element, who need to control the focus-rectangle due some of their own ui-elements incorporated, like options in radio-buttons, etc.
    
    the first four retvals give the set-position(including possible negative values), the second four retvals give the actual window-coordinates.
  </description>
  <parameters>
    integer x - the x-position of the focus-rectangle; negative, anchored to the right windowborder
    integer y - the y-position of the focus-rectangle; negative, anchored to the bottom windowborder
    integer w - the width of the focus-rectangle; negative, anchored to the right windowborder
    integer h - the height of the focus-rectangle; negative, anchored to the bottom windowborder
    integer x2 - the actual x-position of the focus-rectangle
    integer y2 - the actual y-position of the focus-rectangle
    integer w2 - the actual width of the focus-rectangle
    integer h2 - the actual height of the focus-rectangle
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, get, focus rectangle</tags>
</US_DocBloc>
]]
  if reagirl.Elements["Focused_x"]==nil then 
    if reagirl.Elements[reagirl.Elements["FocusedElement"]]~=nil then 
      local x,y,w,h
      x=reagirl.Elements[reagirl.Elements["FocusedElement"]]["x"]
      y=reagirl.Elements[reagirl.Elements["FocusedElement"]]["y"]
      w=reagirl.Elements[reagirl.Elements["FocusedElement"]]["w"]
      h=reagirl.Elements[reagirl.Elements["FocusedElement"]]["h"]
      
      reagirl.UI_Element_SetFocusRect(true, x, y, w, h)
    --else
      --reagirl.UI_Element_SetFocusRect(true, 0,0,0,0)
    end
  end
  
  local x,y,w,h,x2,y2,w2,h2
  x=reagirl.Elements["Focused_x"]
  y=reagirl.Elements["Focused_y"]
  w=reagirl.Elements["Focused_w"]
  h=reagirl.Elements["Focused_h"]
  
  if x<0 then x2=gfx.w+x else x2=x end
  if y<0 then y2=gfx.h+y else y2=y end
  if w<0 then w2=gfx.w-x2+w else w2=w end
  if h<0 then h2=gfx.h-y2+h else h2=h end
  
  return x,y,w,h,x2,y2,w2,h2
end

function reagirl.UI_Elements_OutsideWindow()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Elements_OutsideWindow</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer horz_outside, integer vert_outside = reagirl.UI_Elements_OutsideWindow()</functioncall>
  <description>
    returns, if any of the gui-elements are outside of the window and by how much.
    
    Good for management of resizing window or scrollbars.
  </description>
  <retvals>
    integer horz_outside - the number of horizontal-pixels the ui-elements are outside of the window
    integer vert_outside - the number of vertical-pixels the ui-elements are outside of the window
  </retvals>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, is outside window</tags>
</US_DocBloc>
]]
  local vert=0
  local horz=0
  
  if reagirl.UI_Element_MinX<0 then vert=reagirl.UI_Element_MaxW-gfx.w
  elseif reagirl.UI_Element_MaxW>gfx.w then vert=reagirl.UI_Element_MaxW-gfx.w end
  
  if reagirl.UI_Element_MinY<0 then horz=gfx.h-reagirl.UI_Element_MaxH horz=-horz
  elseif reagirl.UI_Element_MaxH>gfx.h then horz=gfx.h-reagirl.UI_Element_MaxH horz=-horz end
  return horz, vert
end

function reagirl.UI_Element_GetNextOfType(ui_type, startoffset)
  -- will return the ui-element of a specific type next to the startoffset
  -- will "overflow", if the next element has a lower index
  local count=startoffset
  for i=1, #reagirl.Elements do
    count=count+1
    if count>#reagirl.Elements then count=1 end
    if reagirl.Elements[count].GUI_Element_Type==ui_type then return count, reagirl.Elements[count].Guid end
  end
  return -1, ""
end

function reagirl.UI_Element_GetPreviousOfType(ui_type, startoffset)
  -- will return the ui-element of a specific type next to the startoffset
  -- will "overflow", if the next element has a lower index
  local count=startoffset
  for i=1, #reagirl.Elements do
    count=count-1
    if count<1 then count=#reagirl.Elements end
    if reagirl.Elements[count].GUI_Element_Type==ui_type then return count, reagirl.Elements[count].Guid end
  end
  return -1, ""
end

function reagirl.UI_Element_GetNext(startoffset)
  -- will return the ui-element of a specific type next to the startoffset
  -- will "overflow", if the next element has a lower index
  local count=startoffset
  
  for i=1, #reagirl.Elements do
    count=count+1
    if count>#reagirl.Elements-6 then count=1 end
    if reagirl.Elements[count]~=nil and reagirl.Elements[count].IsDisabled==false and reagirl.Elements[count].IsDecorative~=true and reagirl.Elements[count]["hidden"]~=true then 
      return count, reagirl.Elements[count].Guid 
    end
  end
  return -1, ""
end


function reagirl.UI_Element_GetPrevious(startoffset)
  -- will return the ui-element of a specific type next to the startoffset
  -- will "overflow", if the next element has a lower index
  local count=startoffset
  for i=1, #reagirl.Elements do
    count=count-1
    if count<1 then count=#reagirl.Elements-6 end
    if reagirl.Elements[count].IsDisabled==false and reagirl.Elements[count].IsDecorative~=true and reagirl.Elements[count]["hidden"]~=true then return count, reagirl.Elements[count].Guid end
  end
  return -1, ""
end


function reagirl.UI_Element_GetType(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetType</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>string ui_type = reagirl.UI_Element_GetType(string element_id)</functioncall>
  <description>
    returns the type of the ui-element
  </description>
  <retvals>
    string ui_type - the type of the ui-element, like "Button", "Image", "Checkbox", "Edit" for InputBoxes and "ComboBox" for DropDownMenu, etc
  </retvals>
  <parameters>
    string element_id - the id of the element, whose type you want to get
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, get, type</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_GetType: param #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("UI_Element_GetType: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetType: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]~=nil then
    return reagirl.Elements[element_id]["GUI_Element_Type"]
  end
end

function reagirl.UI_Element_GetNextXAndYPosition(x, y, functionname)
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  local slot3=slot
  if reagirl.Next_Y~=nil then slot=reagirl.Next_Y+1 end
  local slot2
  if x==nil then
    if slot==1 or reagirl.UI_Element_NextLineY>0 then
      x=reagirl.UI_Element_NextX_Default
    elseif reagirl.Next_Y~=nil then
      local x2=reagirl.Elements[reagirl.Next_Y]["x"]
      local w2=reagirl.Elements[reagirl.Next_Y]["w"]
      local y=reagirl.Elements[reagirl.Next_Y]["y"]
      x=x2+w2+10
      reagirl.Next_Y=nil
    elseif slot>1 then
      for i=slot-1, 1, -1 do
        if reagirl.Elements[i]["IsDecorative"]~=true then
          slot2=i
          break
        end
      end
      local x2=reagirl.Elements[slot2]["x"]
      local w2=reagirl.Elements[slot2]["w"]
      if x2<0 and x2+w2+reagirl.UI_Element_NextX_Margin>0 then error(functionname..": param #1 - can't anchor ui-element closer to right side of window", 3) end
      x=x2+w2+reagirl.UI_Element_NextX_Margin
    end
  end
  
  local taboffset=0
  if y==nil and reagirl.Next_Y~=nil and reagirl.NextLine_triggered==true then
    local y2=reagirl.Elements[reagirl.Next_Y]["y"]
    local h2=reagirl.Elements[reagirl.Next_Y]["h"]
    if reagirl.Elements[reagirl.Next_Y]["GUI_Element_Type"]=="Tabs" then
      taboffset=3
    else 
      taboffset=4
    end
    reagirl.Next_Y=nil
    if y2<0 and y2+h2+reagirl.UI_Element_NextLineY>0 then error(functionname..": param #2 - can't anchor ui-element closer to bottom of window", 2) end
    y=y2+h2+taboffset
  elseif y==nil then 
    y=reagirl.UI_Element_NextY_Default
    if slot>1 then
    
      for i=slot-1, 1, -1 do
        if reagirl.Elements[i]["IsDecorative"]~=true then
          slot2=i
          break
        end
      end
      local y2=reagirl.Elements[slot2]["y"]
      local h2=reagirl.Elements[slot2]["h"]
      local offset=0
      if reagirl.Elements[slot2]["GUI_Element_Type"]:sub(-5, -1)=="Label" then
        --offset=10
      end
      if y2<0 and y2+h2+reagirl.UI_Element_NextLineY>0 then error(functionname..": param #2 - can't anchor ui-element closer to bottom of window", 3) end
      y=y2+reagirl.UI_Element_NextLineY+offset
    end
  end  
  reagirl.UI_Element_NextLineY=0
  reagirl.NextLine_triggered=nil
  --print_alt(slot, y, reagirl.UI_Element_NextY_Default)
  return x, y, slot3
end

function reagirl.UI_Element_GetSet_ContextMenu(element_id, is_set, menu, menu_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSet_ContextMenu</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>string menu, function menu_runfunction = reagirl.UI_Element_GetSet_ContextMenu(string element_id, boolean is_set, optional string menu, optional function menu_runfunction)</functioncall>
  <description>
    gets/sets the context-menu and context-menu-run-function of a ui-element.
    
    Setting this will show a context-menu, when the user rightclicks the ui-element.
    
    Parameter menu is a list of fields separated by | characters. Each field represents a menu item.
    Fields can start with special characters:

    # : grayed out
    ! : checked
    > : this menu item shows a submenu
    < : last item in the current submenu
    
    The menu_runfunction will be called with two parameters: 
      string element_id - the guid of the ui-element, whose context-menu has been used
      integer selection - the index of the menu-item selected by the user
  </description>
  <retvals>
    string menu - the currently set menu for this ui-element; nil, no menu is available
    function menu_function - a function that is called, after the user made a context-menu-selection; nil, no such function added to this ui-element
  </retvals>
  <parameters>
    string element_id - the id of the element, whose context-menu you want to get/set
    boolean is_set - true, set the menu; false, only retrieve the current menu
    optional string menu - sets a menu for this ui-element; nil, no context-menu available
    optional function menu_runfunction - sets a function that is called, after the user made a context-menu-selection; must be given when menu~=nil
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, context menu</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_GetSet_ContextMenu: param #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_GetSet_ContextMenu: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetSet_ContextMenu: param #1 - no such ui-element", 2) end
  if type(is_set)~="boolean" then error("UI_Element_GetSet_ContextMenu: param #2 - must be a boolean", 2) end
  if is_set==true and menu~=nil and type(menu)~="string" then error("UI_Element_GetSet_ContextMenu: param #3 - must be a string when #2==true", 2) end
  if is_set==true and menu~=nil and type(menu_function)~="function" then error("UI_Element_GetSet_ContextMenu: param #4 - must be a function when #2==true", 2) end
  
  if is_set==true then
    reagirl.Elements[element_id]["ContextMenu"]=menu
    reagirl.Elements[element_id]["ContextMenuFunction"]=menu_function
    reagirl.Elements[element_id]["ContextMenu_ACC"]=" Right click for context menu. "
  else
    reagirl.Elements[element_id]["ContextMenu_ACC"]=""
  end
  return reagirl.Elements[element_id]["ContextMenu"], reagirl.Elements[element_id]["ContextMenuFunction"]
end

function reagirl.UI_Element_GetSet_DropZoneFunction(element_id, is_set, dropzone_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSet_DropZoneFunction</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>function dropzone_function = reagirl.UI_Element_GetSet_DropZoneFunction(string element_id, boolean is_set, optional function dropzone_function)</functioncall>
  <description>
    gets/sets the dropzone-run-function of a ui-element.
    
    This will be called, when the user drag'n'drops files onto this ui-element.
    
    The dropzone_function will be called with two parameters: 
      string element_id - the guid of the ui-element, on which files were dropped
      table filenames - a table with all dropped filenames
      
    It's also possible, that fx were dropped onto a drop-zone, since Reaper allows that.
    So if you just want to have filenames, check, if the filename is not of format "@fx:fx_ident"
  </description>
  <retvals>
    function dropzone_function - a function that is called, after files were drag'n'dropped onto this ui-element
  </retvals>
  <parameters>
    string element_id - the id of the element, whose description you want to get/set
    boolean is_set - true, set the dropzone-function; false, only retrieve the dropzone-function
    optional function dropzone_function - sets a function that is called, after the drag'n'dropped files onto this ui-element; nil, removes drop-zone
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, dropzone</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_GetSet_DropZoneFunction: param #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_GetSet_DropZoneFunction: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetSet_DropZoneFunction: param #1 - no such ui-element", 2) end
  if type(is_set)~="boolean" then error("UI_Element_GetSet_DropZoneFunction: param #2 - must be a boolean", 2) end
  if is_set==true and dropzone_function~=nil and type(dropzone_function)~="function" then error("UI_Element_GetSet_DropZoneFunction: param #3 - must be a function when #2==true", 2) end
  
  if is_set==true then
    reagirl.Elements[element_id]["DropZoneFunction"]=dropzone_function
    reagirl.Elements[element_id]["DropZoneFunction_ACC"]="You can drop files on this UI-element or use control + shift + F for a file-selection dialog."
  else
    reagirl.Elements[element_id]["DropZoneFunction_ACC"]=""
  end
  return reagirl.Elements[element_id]["DropZoneFunction"]
end

function reagirl.UI_Element_GetSetCaption(element_id, is_set, caption)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSetCaption</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>string caption = reagirl.UI_Element_GetSetCaption(string element_id, boolean is_set, string caption)</functioncall>
  <description>
    gets/sets the caption of the ui-element
  </description>
  <retvals>
    string caption - the caption of the ui-element
  </retvals>
  <parameters>
    string element_id - the id of the element, whose caption you want to get/set
    boolean is_set - true, set the caption; false, only retrieve the current caption
    string caption - the caption of the ui-element
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, caption</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_GetSetCaption: param #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_GetSetCaption: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetSetCaption: param #1 - no such ui-element", 2) end
  if type(is_set)~="boolean" then error("UI_Element_GetSetCaption: param #2 - must be a boolean", 2) end
  if is_set==true and type(caption)~="string" then error("UI_Element_GetSetCaption: param #3 - must be a string when #2==true", 2) end
  
  if is_set==true then
    caption=string.gsub(caption, "[\n\r]", "")
    reagirl.Elements[element_id]["Name"]=caption
  end
  return reagirl.Elements[element_id]["Name"]
end
--mespotine
function reagirl.UI_Element_GetSetVisibility(element_id, is_set, visible)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSetVisibility</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>boolean visible = reagirl.UI_Element_GetSetVisibility(string element_id, boolean is_set, boolean visible)</functioncall>
  <description>
    gets/sets the hidden-state of the ui-element
  </description>
  <retvals>
    boolean hidden - the hidden-state of the ui-element
  </retvals>
  <parameters>
    string element_id - the id of the element, whose hidden-state you want to get/set
    boolean is_set - true, set the hidden-state; false, only retrieve current hidde-state
    boolean visible - true, set to visible; false, set to hidden
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, hidden, visibility</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_GetSetVisibility: param #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_GetSetVisibility: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetSetVisibility: param #1 - no such ui-element", 2) end
  if type(is_set)~="boolean" then error("UI_Element_GetSetVisibility: param #2 - must be a boolean", 2) end
  if is_set==true and type(visible)~="boolean" then error("UI_Element_GetSetVisibility: param #3 - must be a boolean when #2==true", 2) end
  
  if is_set==true then
    if visible==false then
      reagirl.Elements[element_id]["hidden"]=true
    else
      reagirl.Elements[element_id]["hidden"]=nil
    end
  end
  return reagirl.Elements[element_id]["hidden"]==true
end

function reagirl.UI_Element_GetSetSticky(element_id, is_set, sticky_x, sticky_y)
--[[
<US _DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSetSticky</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>boolean sticky_x, boolean sticky_y = reagirl.UI_Element_GetSetSticky(string element_id, boolean is_set, boolean sticky_x, boolean sticky_y)</functioncall>
  <description>
    gets/sets the stickiness of the ui-element.
    
    Sticky-elements will not be moved by the global scrollbar-scrolling.
    
    IMPORTANT: 
    Make sure that sticky elements are always visible by forcing a minimum width/height of the window
    using reagirl.Window_ForceSize_Minimum(). 
    Otherwise a ui-element might not be clickable, since it can't be scrolled to. 
    This would also affect blind users, as tabbing through ui-elements moves the mouse to the ui-element(so they can right-click context-menus), 
    which might be outside of the window and therefore the mouse would move to nowhere.
  </description>
  <retvals>
    boolean sticky_x - true, x-movement is sticky; false, x-movement isn't sticky
    boolean sticky_y - true, y-movement is sticky; false, y-movement isn't sticky
  </retvals>
  <parameters>
    string element_id - the id of the element, whose stickiness you want to get/set
    boolean is_set - true, set the stickiness; false, only retrieve current stickiness of the ui-element
    boolean sticky_x - true, x-movement is sticky; false, x-movement isn't sticky
    boolean sticky_y - true, y-movement is sticky; false, y-movement isn't sticky
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, sticky</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_GetSetSticky: param #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_GetSetSticky: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetSetSticky: param #1 - no such ui-element", 2) end
  if type(is_set)~="boolean" then error("UI_Element_GetSetSticky: param #2 - must be a boolean", 2) end
  if type(sticky_x)~="boolean" then error("UI_Element_GetSetSticky: param #3 - must be a boolean", 2) end
  if type(sticky_y)~="boolean" then error("UI_Element_GetSetSticky: param #4 - must be a boolean", 2) end
  
  if is_set==true then
    reagirl.Elements[element_id]["sticky_x"]=sticky_x
    reagirl.Elements[element_id]["sticky_y"]=sticky_y
  end
  return reagirl.Elements[element_id]["sticky_x"], reagirl.Elements[element_id]["sticky_y"]
end

function reagirl.UI_Element_GetSetMeaningOfUIElement(element_id, is_set, meaningOfUI_Element)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSetMeaningOfUIElement</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>string meaningOfUI_Element = reagirl.UI_Element_GetSetMeaningOfUIElement(string element_id, boolean is_set, string meaningOfUI_Element)</functioncall>
  <description>
    gets/sets the meaningOfUI_Element of the ui-element, which will describe, how to use the ui-element to blind persons.
    
    Very important when seting meaning_Of_UI_Elements for images: write into meaningOfUI_Element a small description of what the image shows. This will help blind people know, what the image means and what to do with it.
    If you can't know what the image shows(an image viewer for instance) explain what's the purpose of the image like "cover image for the project" or something.
    Keep in mind: blind people can't see the image so any kind of description will help them understand your script.
  </description>
  <retvals>
    string meaningOfUI_Element - the meaningOfUI_Element of the ui-element(for tooltips and blind users). Make it a sentence that ends with . or ?
  </retvals>
  <parameters>
    string element_id - the id of the element, whose meaningOfUI_Element you want to get/set
    boolean is_set - true, set the meaningOfUI_Element; false, only retrieve the current meaningOfUI_Element
    string meaningOfUI_Element - the meaningOfUI_Element of the ui-element(for tooltips and blind users). Make it a sentence that ends with . or ?
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, accessibility_hint, meaningOfUI_Element</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_GetSetMeaningOfUIElement: param #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_GetSetMeaningOfUIElement: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetSetMeaningOfUIElement: param #1 - no such ui-element", 2) end
  if type(is_set)~="boolean" then error("UI_Element_GetSetMeaningOfUIElement: param #2 - must be a boolean", 2) end
  if is_set==true and type(meaningOfUI_Element)~="string" then error("UI_Element_GetSetMeaningOfUIElement: param #3 - must be a string when #2==true", 2) end
  if meaningOfUI_Element:sub(-1,-1)~="." and meaningOfUI_Element:sub(-1,-1)~="?" then error("UI_Element_GetSetMeaningOfUIElement: param #3 - must end on a . like a regular sentence.", 2) end
  if is_set==true then
    reagirl.Elements[element_id]["Description"]=meaningOfUI_Element
  end
  return reagirl.Elements[element_id]["Description"]
end

function reagirl.UI_Element_IsElementAtMousePosition(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_IsElementAtMousePosition</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>boolean element_is_at_position = reagirl.UI_Element_IsElementAtMousePosition(string element_id)</functioncall>
  <description>
    returns, if ui-element with element_id is at mouse-position
  </description>
  <retvals>
    boolean element_is_at_position - true, ui-element is at mouse-position; false, ui-element is not at mouse-position
  </retvals>
  <parameters>
    string element_id - the id of the element, of which you want to know, if it's at mouse-position
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, get, is at position</tags>
</US_DocBloc>
]]
  local x, y, real_x, real_y = reagirl.UI_Element_GetSetPosition(element_id, false)
  local w, h, real_w, real_h =reagirl.UI_Element_GetSetDimension(element_id, false)
  return gfx.mouse_x>=real_x and gfx.mouse_x<=real_x+real_w and gfx.mouse_y>=real_y and gfx.mouse_y<=real_y+real_h
end

function reagirl.UI_Element_GetSetPosition(element_id, is_set, x, y)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSetPosition</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer x, integer y, integer actual_x, integer actual_y = reagirl.UI_Element_GetSetPosition(string element_id, boolean is_set, integer x, integer y)</functioncall>
  <description>
    gets/sets the position of the ui-element
  </description>
  <retvals>
    integer x - the x-position of the ui-element
    integer y - the y-position of the ui-element
    integer actual_x - the actual current x-position resolved to the anchor-position including scaling and scroll-offset
    integer actual_y - the actual current y-position resolved to the anchor-position including scaling and scroll-offset
  </retvals>
  <parameters>
    string element_id - the id of the element, whose position you want to get/set
    boolean is_set - true, set the position; false, only retrieve the current position
    integer x - the x-position of the ui-element
    integer y - the y-position of the ui-element
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, position</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_GetSetPosition: param #1 - must be a guid as string", 2) end
  local elid=element_id
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_GetSetPosition: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetSetPosition: param #1 - no such ui-element", 2) end
  if type(is_set)~="boolean" then error("UI_Element_GetSetPosition: param #2 - must be a boolean", 2) end
  if is_set==true and math.type(x)~="integer" then error("UI_Element_GetSetPosition: param #3 - must be an integer when is_set==true", 2) end
  if is_set==true and math.type(y)~="integer" then error("UI_Element_GetSetPosition: param #4 - must be an integer when is_set==true", 2) end
  
  if is_set==true then
    reagirl.Elements[element_id]["x"]=x
    reagirl.Elements[element_id]["y"]=y
  end
  local x2, y2
  local cap_w=reagirl.Elements[element_id]["Cap_width"]
  if cap_w==nil then cap_w=0 end 
  local scale=reagirl.Window_GetCurrentScale()
  if reagirl.Elements[element_id]["x"]<0 then x2=gfx.w+reagirl.Elements[element_id]["x"]*scale else x2=reagirl.Elements[element_id]["x"]*scale end
  if reagirl.Elements[element_id]["y"]<0 then y2=gfx.h+reagirl.Elements[element_id]["y"]*scale else y2=reagirl.Elements[element_id]["y"]*scale end
  if reagirl.Elements.FocusedElement==element_id then
    if reagirl.osara_outputMessage~=nil then
      reagirl.UI_Element_ScrollToUIElement(elid, -cap_w)
      if reaper.GetExtState("ReaGirl", "osara_move_mouse")~="false" then
        reaper.JS_Mouse_SetPosition(gfx.clienttoscreen(x2+cap_w+reagirl.MoveItAllRight+4,y2+reagirl.MoveItAllUp+4)) 
      end
    end
  end
  
  return reagirl.Elements[element_id]["x"], reagirl.Elements[element_id]["y"], x2+reagirl.MoveItAllRight, y2+reagirl.MoveItAllUp
end

function reagirl.UI_Element_GetSetDimension(element_id, is_set, w, h)
  -- maybe restrict this to certain ui-elements
  if type(element_id)~="string" then error("UI_Element_GetSetDimension: param #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_GetSetDimension: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetSetDimension: param #1 - no such ui-element", 2) end
  if type(is_set)~="boolean" then error("UI_Element_GetSetDimension: param #2 - must be a boolean", 2) end
  if is_set==true and math.type(w)~="integer" then error("UI_Element_GetSetDimension: param #3 - must be an integer when is_set==true", 2) end
  if is_set==true and math.type(h)~="integer" then error("UI_Element_GetSetDimension: param #4 - must be an integer when is_set==true", 2) end
  
  local w2, h2, x2, y2
  local scale=reagirl.Window_GetCurrentScale()
  if reagirl.Elements[element_id]["x"]<0 then x2=gfx.w+reagirl.Elements[element_id]["x"]*scale else x2=reagirl.Elements[element_id]["x"]*scale end
  if reagirl.Elements[element_id]["y"]<0 then y2=gfx.h+reagirl.Elements[element_id]["y"]*scale else y2=reagirl.Elements[element_id]["y"]*scale end
  if reagirl.Elements[element_id]["w"]<0 then w2=gfx.w-x2+reagirl.Elements[element_id]["w"]*scale else w2=reagirl.Elements[element_id]["w"]*scale end
  if reagirl.Elements[element_id]["h"]<0 then h2=gfx.h-y2+reagirl.Elements[element_id]["h"]*scale else h2=reagirl.Elements[element_id]["h"]*scale end
  
  if is_set==true then
    reagirl.Elements[element_id]["w"]=w
    reagirl.Elements[element_id]["h"]=h
  end
          
  return reagirl.Elements[element_id]["w"], reagirl.Elements[element_id]["h"], w2, h2
end


function reagirl.UI_Element_GetSetAllHorizontalOffset(is_set, x_offset)
--[[
<US  _DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSetAllHorizontalOffset</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer x_offset = reagirl.UI_Element_GetSetAllHorizontalOffset(boolean is_set, integer x_offset)</functioncall>
  <description>
    gets/sets the horizontal offset of all non-sticky ui-elements
    
    when setting, this scrolls all ui-elements on x-axis
  </description>
  <retvals>
    integer x_offset - the current horizontal offset of all ui-elements
  </retvals>
  <parameters>
    boolean is_set - true, set the horizontal-offset; false, only retrieve current horizontal offset
    integer x_offset - the x-offset of all ui-elements
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, horizontal offset</tags>
</US_DocBloc>
]]
  if type(is_set)~="boolean" then error("UI_Element_GetSetAllHorizontalOffset: param #2 - must be a boolean", 2) end
  if is_set==true and math.type(x_offset)~="integer" then error("UI_Element_GetSetAllHorizontalOffset: param #3 - must be an integer when is_set==true", 2) end
  
  if is_set==true then reagirl.MoveItAllRight=x_offset end
  return reagirl.MoveItAllRight
end

function reagirl.UI_Element_GetSetAllVerticalOffset(is_set, y_offset)
--[[
<US  _DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSetAllVerticalOffset</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer y_offset = reagirl.UI_Element_GetSetAllVerticalOffset(boolean is_set, integer y_offset)</functioncall>
  <description>
    gets/sets the vertical offset of all ui-elements
    
    when setting, this scrolls all ui-elements on y-axis
  </description>
  <retvals>
    integer y_offset - the current vertical offset of all non-sticky ui-elements
  </retvals>
  <parameters>
    boolean is_set - true, set the vertical-offset; false, only retrieve current vertical offset
    integer y_offset - the y-offset of all ui-elements
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, vertical offset</tags>
</US_DocBloc>
]]
  if type(is_set)~="boolean" then error("UI_Element_GetSetAllVerticalOffset: param #2 - must be a boolean", 2) end
  if is_set==true and math.type(y_offset)~="integer" then error("UI_Element_GetSetAllVerticalOffset: param #3 - must be an integer when is_set==true", 2) end
  
  if is_set==true then reagirl.MoveItAllUp=y_offset end
  return reagirl.MoveItAllUp
end

function reagirl.UI_Element_GetSetRunFunction(element_id, is_set, run_function, run_function2)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSetRunFunction</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>func run_function, optional func run_function2 = reagirl.UI_Element_GetSetRunFunction(string element_id, boolean is_set, optional func run_function, optional func_run_function2)</functioncall>
  <description>
    gets/sets the run_function of the ui-element, which will be run, when the ui-element is toggled
  </description>
  <retvals>
    func run_function - the run_function of the ui-element
    optional func_run_function2 - a second run-function used by some ui-elements; type-run-function for inputboxes
  </retvals>
  <parameters>
    string element_id - the id of the element, whose run_function you want to get/set
    boolean is_set - true, set the run_function; false, only retrieve the current run_function
    optional func run_function - the run function of the ui-element; enter-run-function for inputboxes
    optional func_run_function2 - a second run-function used by some ui-elements; type-run-function for inputboxes
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, run function</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_GetSetRunFunction: param #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_GetSetRunFunction: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetSetRunFunction: param #1 - no such ui-element", 2) end
  if type(is_set)~="boolean" then error("UI_Element_GetSetRunFunction: param #2 - must be a boolean", 2) end
  if is_set==true and run_function~=nil and type(run_function)~="function" then error("UI_Element_GetSetRunFunction: param #3 - must be either nil or a function, when #2==true", 2) end
  if is_set==true and run_function2~=nil and type(run_function2)~="function" then error("UI_Element_GetSetRunFunction: param #4 - must be either nil or a function, when #2==true", 2) end
  
  if is_set==true then
    reagirl.Elements[element_id]["run_function"]=run_function
    reagirl.Elements[element_id]["run_function_type"]=run_function2
  end
  return reagirl.Elements[element_id]["run_function"], reagirl.Elements[element_id]["run_function_type"]
end
--mespotine

function reagirl.UI_Element_Remove(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_Remove</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.UI_Element_Remove(string element_id)</functioncall>
  <description>
    Removes a ui-element.
  </description>
  <parameters>
    string element_id - the id of the element that you want to remove
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, remove</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_Remove: param #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_Remove: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]=="Tabs" then
    reagirl.Tabs_Count=nil
  end
  table.remove(reagirl.Elements, element_id)
  if element_id<=reagirl.Elements["FocusedElement"] then
    reagirl.Elements["FocusedElement"]=reagirl.Elements["FocusedElement"]-1
  end
  if reagirl.Elements["FocusedElement"]>#reagirl.Elements then
    reagirl.Elements["FocusedElement"]=#reagirl.Elements
  end
  if reagirl.Elements["FocusedElement"]>0 then 
    reagirl.UI_Element_SetFocusRect(true, 
                                    reagirl.Elements[reagirl.Elements["FocusedElement"]]["x"], 
                                    reagirl.Elements[reagirl.Elements["FocusedElement"]]["y"], 
                                    reagirl.Elements[reagirl.Elements["FocusedElement"]]["w"], 
                                    reagirl.Elements[reagirl.Elements["FocusedElement"]]["h"]
                                    )
  end
  reagirl.Gui_ForceRefresh(13)
end

function reagirl.UI_Element_GetIDFromGuid(guid)
  if guid==nil then return -1 end
  if type(guid)~="string" then error("UI_Element_GetIDFromGuid: param #1 - must be a string", 2) end
  if guid:match("{........%-....%-....%-....%-............}")==nil then error("UI_Element_GetIDFromGuid: param #1 - must be a valid guid", 2) end
  for i=1, #reagirl.Elements do
    if guid==reagirl.Elements[i]["Guid"] then return i end
  end
  return -1
end

function reagirl.UI_Element_GetGuidFromID(id)
  if math.type(id)~="integer" then error("UI_Element_GetGuidFromID: param #1 - must be an integer", 2) end
  if id>#reagirl.Elements-6 then
    return reagirl.Elements[id]["Guid"]
  else
    error("UI_Element_GetGuidFromID: param #1 - no such ui-element", 2)
  end
end

function reagirl.Checkbox_Add(x, y, caption, meaningOfUI_Element, default, run_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Checkbox_Add</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>string checkbox_guid = reagirl.Checkbox_Add(integer x, integer y, string caption, string meaningOfUI_Element, optional function run_function)</functioncall>
  <description>
    Adds a checkbox to a gui.
    
    You can autoposition the checkbox by setting x and/or y to nil, which will position the new checkbox after the last ui-element.
    To autoposition into the next line, use reagirl.NextLine()
    
    The run-function will get two parameters:
    - string element_id - the element_id of the toggled checkbox
    - boolean checkstate - the new checkstate of the checkbox
    
    Note: to align multiple lines of checkboxes under each other, check out Checkbox_SetWidth.
  </description>
  <parameters>
    optional integer x - the x position of the checkbox in pixels; negative anchors the checkbox to the right window-side; nil, autoposition after the last ui-element(see description)
    optional integer y - the y position of the checkbox in pixels; negative anchors the checkbox to the bottom window-side; nil, autoposition after the last ui-element(see description)
    string caption - the caption of the checkbox
    string meaningOfUI_Element - the meaningOfUI_Element of the ui-element(for tooltips and blind users). Make it a sentence that ends with . or ?
    boolean default - true, set the checkbox checked; false, set the checkbox unchecked
    optional function run_function - a function that shall be run when the checkbox is clicked; will get passed over the checkbox-element_id as first and the new checkstate as second parameter
  </parameters>
  <retvals>
    string checkbox_guid - a guid that can be used for altering the checkbox-attributes
  </retvals>
  <chapter_context>
    Checkbox
  </chapter_context>
  <tags>checkbox, add</tags>
</US_DocBloc>
--]]
  if x~=nil and math.type(x)~="integer" then error("Checkbox_Add: param #1 - must be either nil or an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("Checkbox_Add: param #2 - must be either nil or an integer", 2) end
  if type(caption)~="string" then error("Checkbox_Add: param #3 - must be a string", 2) end
  caption=string.gsub(caption, "[\n\r]", "")
  if type(meaningOfUI_Element)~="string" then error("Checkbox_Add: param #4 - must be a string", 2) end
  if meaningOfUI_Element:sub(-1,-1)~="." and meaningOfUI_Element:sub(-1,-1)~="?" then error("Checkbox_Add: param #4 - must end on a . like a regular sentence.", 2) end
  if type(default)~="boolean" then error("Checkbox_Add: param #5 - must be a boolean", 2) end
  if run_function~=nil and type(run_function)~="function" then error("Checkbox_Add: param #6 - must be either nil or a function", 2) end
  
  local x,y,slot=reagirl.UI_Element_GetNextXAndYPosition(x, y, "Checkbox_Add")
  --reagirl.UI_Element_NextX_Default=x
  
  table.insert(reagirl.Elements, slot, {})
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0, 1)
  local tx,ty=gfx.measurestr(caption)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  
  reagirl.Elements[slot]["Guid"]=reaper.genGuid("")
  reagirl.Elements[slot]["GUI_Element_Type"]="Checkbox"
  reagirl.Elements[slot]["Name"]=caption
  reagirl.Elements[slot]["Text"]=caption
  reagirl.Elements[slot]["IsDisabled"]=false
  reagirl.Elements[slot]["Description"]=meaningOfUI_Element
  reagirl.Elements[slot]["AccHint"]="Space or left mouse-click to toggle checkbox."
  reagirl.Elements[slot]["ContextMenu_ACC"]=""
  reagirl.Elements[slot]["DropZoneFunction_ACC"]=""
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["w"]=math.tointeger(ty+tx)+9
  reagirl.Elements[slot]["h"]=math.tointeger(ty)--+reagirl.UI_Element_HeightMargin
  if ty>reagirl.NextLine_Overflow then reagirl.NextLine_Overflow=math.tointeger(ty) end
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false
  reagirl.Elements[slot]["top_edge"]=true
  reagirl.Elements[slot]["bottom_edge"]=true
  reagirl.Elements[slot]["checked"]=default
  reagirl.Elements[slot]["linked_to"]=0
  reagirl.Elements[slot]["func_manage"]=reagirl.Checkbox_Manage
  reagirl.Elements[slot]["func_draw"]=reagirl.Checkbox_Draw
  reagirl.Elements[slot]["run_function"]=run_function
  reagirl.Elements[slot]["userspace"]={}
  return reagirl.Elements[slot]["Guid"]
end

function reagirl.Checkbox_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
-- ToDo: SetTogglecommandState for MediaExplorer and Midi-Inline Editor, needs JS-extension features(see Ultraschall-API for details)
  local refresh=false
  
  -- drop files for accessibility using a file-requester, after typing ctrl+shift+f
  if element_storage["DropZoneFunction"]~=nil and Key==6 and mouse_cap==12 then
    local retval, filenames = reaper.GetUserFileNameForRead("", "Choose file to drop into "..element_storage["Name"], "")
    reagirl.Window_SetFocus()
    if retval==true then element_storage["DropZoneFunction"](element_storage["Guid"], {filenames}) refresh=true reagirl.Gui_ForceRefresh(979) end
  end
  
  if element_storage["linked_to"]~=0 then
    if element_storage["linked_to"]==1 then
      -- if checkbox is linked to extstate then
      local val=reaper.GetExtState(element_storage["linked_to_section"], element_storage["linked_to_key"])
      if val=="" then 
        -- if extstate==unset
        if element_storage["linked_to_default"]==true then
          -- if default is true
          reaper.SetExtState(element_storage["linked_to_section"], element_storage["linked_to_key"], element_storage["linked_to_true"], element_storage["linked_to_persist"]) 
          element_storage["checked"]=linked_to_true
          val=element_storage["linked_to_true"]
          reagirl.Gui_ForceRefresh()
        else
          -- if default is false
          reaper.SetExtState(element_storage["linked_to_section"], element_storage["linked_to_key"], element_storage["linked_to_false"], element_storage["linked_to_persist"]) 
          element_storage["checked"]=linked_to_false
          val=element_storage["linked_to_false"]
          reagirl.Gui_ForceRefresh()
        end
      end
      if val==element_storage["linked_to_true"] then val=true else val=false end
      if val~=element_storage["checked"] then element_storage["checked"]=val reagirl.Gui_ForceRefresh() end
    elseif element_storage["linked_to"]==2 then
      -- if checkbox is linked to extstate then
      local retval, val = reaper.BR_Win32_GetPrivateProfileString(element_storage["linked_to_section"], element_storage["linked_to_key"], "", element_storage["linked_to_ini_file"])
      if val=="" then 
        -- if extstate==unset
        if element_storage["linked_to_default"]==true then
          -- if default is true
          local retval, val = reaper.BR_Win32_WritePrivateProfileString(element_storage["linked_to_section"], element_storage["linked_to_key"], element_storage["linked_to_true"], element_storage["linked_to_ini_file"])
          --reaper.SetExtState(element_storage["linked_to_section"], element_storage["linked_to_key"], element_storage["linked_to_true"], element_storage["linked_to_persist"]) 
          element_storage["checked"]=linked_to_true
          val=element_storage["linked_to_true"]
          reagirl.Gui_ForceRefresh()
        else
          -- if default is false
          local retval, val = reaper.BR_Win32_WritePrivateProfileString(element_storage["linked_to_section"], element_storage["linked_to_key"], element_storage["linked_to_false"], element_storage["linked_to_ini_file"])
          --reaper.SetExtState(element_storage["linked_to_section"], element_storage["linked_to_key"], element_storage["linked_to_false"], element_storage["linked_to_persist"]) 
          element_storage["checked"]=linked_to_false
          val=element_storage["linked_to_false"]
          reagirl.Gui_ForceRefresh()
        end
      end
      if val==element_storage["linked_to_true"] then val=true else val=false end
      if val~=element_storage["checked"] then element_storage["checked"]=val reagirl.Gui_ForceRefresh() end
    elseif element_storage["linked_to"]==3 then 
      local val=reaper.SNM_GetIntConfigVar(element_storage["linked_to_configvar"], -999999999999999)
      val=val&element_storage["linked_to_bit"]
      if val==0 then val=false else val=true end
      if val~=element_storage["checked"] then element_storage["checked"]=val reagirl.Gui_ForceRefresh() end
    elseif element_storage["linked_to"]==4 then
      local val=false
      if reaper.GetToggleCommandStateEx(element_storage["linked_to_section"], element_storage["linked_to_command_id"])==1 then val=true end
      if val~=element_storage["checked"] then element_storage["checked"]=val reagirl.Gui_ForceRefresh() end
    end
  end
  
  if selected~="not selected" and (((clicked=="FirstCLK" or clicked=="DBLCLK" )and mouse_cap&1==1) or Key==32) then 
    if (gfx.mouse_x>=x 
      and gfx.mouse_x<=x+w 
      and gfx.mouse_y>=y 
      and gfx.mouse_y<=y+h) 
      or Key==32 then
      if reagirl.Elements[element_id]["checked"]==true then 
        reagirl.Elements[element_id]["checked"]=false 
        if element_storage["run_function"]~=nil then element_storage["run_function"](element_storage["Guid"], reagirl.Elements[element_id]["checked"]) end
        refresh=true
      else 
        reagirl.Elements[element_id]["checked"]=true 
        if element_storage["run_function"]~=nil then element_storage["run_function"](element_storage["Guid"], reagirl.Elements[element_id]["checked"]) end
        refresh=true
      end
    end
  end
  if refresh==true then reagirl.Gui_ForceRefresh(14) end
  local unchecked="checked"
  if element_storage["checked"]==false then unchecked="unchecked" end
  element_storage["AccHoverMessage"]=element_storage["Name"].." "..unchecked
  
  if refresh==true and element_storage["linked_to"]~=0 then
    if element_storage["linked_to"]==1 then
      local val=reaper.GetExtState(element_storage["linked_to_section"], element_storage["linked_to_key"])
      if element_storage["checked"]==true then 
        reaper.SetExtState(element_storage["linked_to_section"], element_storage["linked_to_key"], element_storage["linked_to_true"], element_storage["linked_to_persist"])
        --local retval, val = reaper.BR_Win32_WritePrivateProfileString(element_storage["linked_to_section"], element_storage["linked_to_key"], element_storage["linked_to_true"], element_storage["linked_to_ini_file"])
      else
        reaper.SetExtState(element_storage["linked_to_section"], element_storage["linked_to_key"], element_storage["linked_to_false"], element_storage["linked_to_persist"])
        --local retval, val = reaper.BR_Win32_WritePrivateProfileString(element_storage["linked_to_section"], element_storage["linked_to_key"], element_storage["linked_to_false"], element_storage["linked_to_ini_file"])
      end
    elseif element_storage["linked_to"]==2 then
      local val=reaper.GetExtState(element_storage["linked_to_section"], element_storage["linked_to_key"])
      if element_storage["checked"]==true then 
        --reaper.SetExtState(element_storage["linked_to_section"], element_storage["linked_to_key"], element_storage["linked_to_true"], element_storage["linked_to_persist"])
        local retval, val = reaper.BR_Win32_WritePrivateProfileString(element_storage["linked_to_section"], element_storage["linked_to_key"], element_storage["linked_to_true"], element_storage["linked_to_ini_file"])
      else
        --reaper.SetExtState(element_storage["linked_to_section"], element_storage["linked_to_key"], element_storage["linked_to_false"], element_storage["linked_to_persist"])
        local retval, val = reaper.BR_Win32_WritePrivateProfileString(element_storage["linked_to_section"], element_storage["linked_to_key"], element_storage["linked_to_false"], element_storage["linked_to_ini_file"])
      end
    elseif element_storage["linked_to"]==3 then
      val=reaper.SNM_GetIntConfigVar(element_storage["linked_to_configvar"], -9999999999)
      if val&element_storage["linked_to_bit"]>0 then val=val-element_storage["linked_to_bit"] end
      if element_storage["checked"]==true then val=val+element_storage["linked_to_bit"] end
      reaper.SNM_SetIntConfigVar(element_storage["linked_to_configvar"], val)
      if element_storage["linked_to_persist"]==true then
        reaper.BR_Win32_WritePrivateProfileString("REAPER", element_storage["linked_to_configvar"], val, reaper.get_ini_file())
      end
    elseif element_storage["linked_to"]==4 then
      if element_storage["checked"]==true then 
        reaper.SetToggleCommandState(element_storage["linked_to_section"], element_storage["linked_to_command_id"], 1)
        if reaper.GetToggleCommandStateEx(element_storage["linked_to_section"], element_storage["linked_to_command_id"])==0 then
          if element_storage["linked_to_section"]==32060 then  
            reaper.MIDIEditor_LastFocused_OnCommand(element_storage["linked_to_command_id"], false)
          elseif element_storage["linked_to_section"]==32061 then  
            reaper.MIDIEditor_LastFocused_OnCommand(element_storage["linked_to_command_id"], true)
          elseif element_storage["linked_to_section"]==32063 then
            reagirl.MediaExplorer_OnCommand(element_storage["linked_to_command_id"])
          elseif element_storage["linked_to_section"]==0 then
            reaper.Main_OnCommand(element_storage["linked_to_command_id"], 0)
          end
        end
      else
        reaper.SetToggleCommandState(element_storage["linked_to_section"], element_storage["linked_to_command_id"], 0)
        if reaper.GetToggleCommandStateEx(element_storage["linked_to_section"], element_storage["linked_to_command_id"])==1 then
          if element_storage["linked_to_section"]==32060 then  
            reaper.MIDIEditor_LastFocused_OnCommand(element_storage["linked_to_command_id"], false)
          elseif element_storage["linked_to_section"]==32061 then  
            reaper.MIDIEditor_LastFocused_OnCommand(element_storage["linked_to_command_id"], true)
          elseif element_storage["linked_to_section"]==32063 then
            reagirl.MediaExplorer_OnCommand(element_storage["linked_to_command_id"])
          elseif element_storage["linked_to_section"]==0 then
            reaper.Main_OnCommand(element_storage["linked_to_command_id"], 0)
          end
        end
      end
      reaper.RefreshToolbar2(element_storage["linked_to_section"], element_storage["linked_to_command_id"])
    end
  end
  
  if reagirl.Elements[element_id]["checked"]==true then
    return " checked. ", refresh
  else
    return " not checked. ", refresh
  end
end



function reagirl.Checkbox_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)

  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  gfx.x=x
  gfx.y=y
  local offset
  local scale=reagirl.Window_CurrentScale
  y=y+scale
  local top=element_storage["top_edge"]
  local bottom=element_storage["bottom_edge"]
  --gfx.set(1)
  --gfx.rect(x,y,w,h,1)

  gfx.set(reagirl.Colors.Checkbox_rectangle_r, reagirl.Colors.Checkbox_rectangle_g, reagirl.Colors.Checkbox_rectangle_b)
  reagirl.RoundRect(x, y-scale, h, h, 2*scale-1, 1,1, false, false, false, false)
  
  gfx.set(reagirl.Colors.Checkbox_background_r, reagirl.Colors.Checkbox_background_g, reagirl.Colors.Checkbox_background_b)
  reagirl.RoundRect(x+scale, y, h-scale*2, h-scale*2, scale-1, 0, 1, false, false, false, false)

  if element_storage["checked"]==true then
    if element_storage["IsDisabled"]==false then
      gfx.set(reagirl.Colors.Checkbox_r, reagirl.Colors.Checkbox_g, reagirl.Colors.Checkbox_b)
    else
      gfx.set(reagirl.Colors.Checkbox_disabled_r, reagirl.Colors.Checkbox_disabled_g, reagirl.Colors.Checkbox_disabled_b)
    end
    reagirl.RoundRect(x+(scale)*3, y+scale+scale, h-scale*6, h-scale*6, 3*scale, 1, 1, top, bottom, true, true)
    
  end
  
  local offset
  if scale==1 then offset=0
  elseif scale==2 then offset=2
  elseif scale==3 then offset=5
  elseif scale==4 then offset=8
  elseif scale==5 then offset=11
  elseif scale==6 then offset=14
  elseif scale==7 then offset=17
  elseif scale==8 then offset=20
  end
  
  
  gfx.x=x+h+5*scale
  gfx.y=y+scale--+scale+(h-gfx.texth)/2
  gfx.set(reagirl.Colors.Checkbox_TextBG_r, reagirl.Colors.Checkbox_TextBG_g, reagirl.Colors.Checkbox_TextBG_b)
  gfx.drawstr(name)
  
  if element_storage["IsDisabled"]==false then gfx.set(reagirl.Colors.Checkbox_TextFG_r, reagirl.Colors.Checkbox_TextFG_g, reagirl.Colors.Checkbox_TextFG_b) else gfx.set(reagirl.Colors.Checkbox_TextFG_disabled_r, reagirl.Colors.Checkbox_TextFG_disabled_g, reagirl.Colors.Checkbox_TextFG_disabled_b) end
  gfx.x=x+h+4*scale
  gfx.y=y--+(h-gfx.texth)/2
  gfx.drawstr(name)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  --]]
end

function reagirl.Checkbox_SetWidth(element_id, width)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Checkbox_SetWidth</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Checkbox_SetWidth(string element_id, integer width)</functioncall>
  <description>
    Sets width of a checkbox.
    
    This can help to get checkboxes perfectly aligned with auto-position. Just use this function right after the Checkbox_Add-function-calls.
    So if you have two lines of checkboxes with two checkboxes each, apply this function to the first checkbox in each line with the same width.
    The second checkboxes in ech line will be aligned at the same position.
    
    Will warn you if the width is too short.
  </description>
  <parameters>
    string element_id - the guid of the checkbox, that you want to link to an extstate
    integer width - the with of the checkbox in pixels. Must be bigger than 0.
  </parameters>
  <chapter_context>
    Checkbox
  </chapter_context>
  <tags>checkbox, set, width</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Checkbox_SetWidth: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Checkbox_SetWidth: param #1 - must be a valid guid", 2) end
  if math.type(width)~="integer" then error("Checkbox_SetWidth: param #2 - must be an integer", 2) end
  if width<=0 then error("Checkbox_SetWidth: param #2 - must be bigger than 0", 2) end
  
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Checkbox_SetWidth: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Checkbox" then
    error("Checkbox_SetWidth: param #1 - ui-element is not a checkbox", 2)
  else
    if reagirl.Elements[element_id]["w"]>width then error("Checkbox_SetWidth: param #2 - too short, would truncate caption. Must be at least "..reagirl.Elements[element_id]["w"], 2) end
    reagirl.Elements[element_id]["w"]=width
    reagirl.Gui_ForceRefresh(16)
  end
end

function reagirl.Checkbox_LinkToExtstate(element_id, section, key, false_val, true_val, default, persist)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Checkbox_LinkToExtstate</slug>
  <requires>
    ReaGirl=1.1
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Checkbox_LinkToExtstate(string element_id, string section, string key, string false_val, string true_val, string default, boolean persist)</functioncall>
  <description>
    Links a checkbox to an extstate. 
    
    All changes to the extstate will be immediately visible for this checkbox.
    Clicking the checkbox also updates the extstate immediately.
    
    If the checkbox was already linked to a config-var or ini-file, the linked-state will be replaced by this new one.
    Use reagirl.Checkbox_Unlink() to unlink the checkbox from extstate/ini-file/config var.
  </description>
  <parameters>
    string element_id - the guid of the checkbox, that you want to link to an extstate
    string section - the section of the linked extstate
    string key - the key of the linked extstate
    string false_val - the value that shall be seen and stored as false
    string true_val - the value that shall be seen and stored as true
    string default - the default value, if the extstate hasn't been set yet
    boolean persist - true, the extstate shall be stored persistantly; false, the extstate shall not be stored persistantly
  </parameters>
  <chapter_context>
    Checkbox
  </chapter_context>
  <tags>checkbox, link to, extstate</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Checkbox_LinkToExtstate: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Checkbox_LinkToExtstate: param #1 - must be a valid guid", 2) end
  if type(section)~="string" then error("Checkbox_LinkToExtstate: param #2 - must be a string", 2) end
  if type(key)~="string" then error("Checkbox_LinkToExtstate: param #3 - must be a string", 2) end
  if type(false_val)~="string" then error("Checkbox_LinkToExtstate: param #4 - must be a string", 2) end
  if type(true_val)~="string" then error("Checkbox_LinkToExtstate: param #5 - must be a string", 2) end
  if type(default)~="boolean" then error("Checkbox_LinkToExtstate: param #6 - must be a boolean", 2) end
  if type(persist)~="boolean" then error("Checkbox_LinkToExtstate: param #7 - must be a boolean", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Checkbox_LinkToExtstate: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Checkbox" then
    error("Checkbox_LinkToExtstate: param #1 - ui-element is not a checkbox", 2)
  else
    reagirl.Elements[element_id]["linked_to"]=1
    reagirl.Elements[element_id]["linked_to_section"]=section
    reagirl.Elements[element_id]["linked_to_key"]=key
    reagirl.Elements[element_id]["linked_to_true"]=true_val
    reagirl.Elements[element_id]["linked_to_false"]=false_val
    reagirl.Elements[element_id]["linked_to_default"]=default
    reagirl.Elements[element_id]["linked_to_persist"]=persist
    reagirl.Gui_ForceRefresh(16)
  end
end

function reagirl.Checkbox_LinkToIniValue(element_id, ini_file, section, key, false_val, true_val, default
)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Checkbox_LinkToIniValue</slug>
  <requires>
    ReaGirl=1.1
    Reaper=7.03
    SWS=2.10.0.1
    Lua=5.4
  </requires>
  <functioncall>reagirl.Checkbox_LinkToIniValue(string element_id, string ini_file, string section, string key, string false_val, string true_val, string default, boolean persist)</functioncall>
  <description>
    Links a checkbox to an ini-value. 
    
    All changes to the ini-value will be immediately visible for this checkbox.
    Clicking the checkbox also updates the inivalue immediately.
    
    If the checkbox was already linked to extstate or config-variable, the linked-state will be replaced by this new one.
    Use reagirl.Checkbox_Unlink() to unlink the checkbox from extstate/ini-file/config var.
  </description>
  <parameters>
    string element_id - the guid of the checkbox that you want to link to an ini-value
    string ini_file - the filename of the ini-file
    string section - the section of the ini-file
    string key - the key of the ini-file
    string false_val - the value that shall be seen and stored as false
    string true_val - the value that shall be seen and stored as true
    string default - the default value, if the ini-file hasn't been set yet
  </parameters>
  <chapter_context>
    Checkbox
  </chapter_context>
  <tags>checkbox, link to, ini-file</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Checkbox_LinkToIniValue: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Checkbox_LinkToIniValue: param #1 - must be a valid guid", 2) end
  if type(ini_file)~="string" then error("Checkbox_LinkToIniValue: param #2 - must be a string", 2) end
  if type(section)~="string" then error("Checkbox_LinkToIniValue: param #3 - must be a string", 2) end
  if type(key)~="string" then error("Checkbox_LinkToIniValue: param #4 - must be a string", 2) end
  if type(false_val)~="string" then error("Checkbox_LinkToIniValue: param #5 - must be a string", 2) end
  if type(true_val)~="string" then error("Checkbox_LinkToIniValue: param #6 - must be a string", 2) end
  if type(default)~="boolean" then error("Checkbox_LinkToIniValue: param #7 - must be a boolean", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Checkbox_LinkToIniValue: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Checkbox" then
    error("Checkbox_LinkToIniValue: param #1 - ui-element is not a checkbox", 2)
  else
    reagirl.Elements[element_id]["linked_to"]=2
    reagirl.Elements[element_id]["linked_to_ini_file"]=ini_file
    reagirl.Elements[element_id]["linked_to_section"]=section
    reagirl.Elements[element_id]["linked_to_key"]=key
    reagirl.Elements[element_id]["linked_to_false"]=false_val
    reagirl.Elements[element_id]["linked_to_true"]=true_val
    reagirl.Elements[element_id]["linked_to_default"]=default
    reagirl.Gui_ForceRefresh(16)
  end
end

function reagirl.Checkbox_LinkToConfigVar(element_id, configvar_name, bit, persist)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Checkbox_LinkToConfigVar</slug>
  <requires>
    ReaGirl=1.1
    Reaper=7.03
    SWS=2.10.0.1
    Lua=5.4
  </requires>
  <functioncall>reagirl.Checkbox_LinkToConfigVar(string element_id, string configvar_name, integer bit, boolean persist)</functioncall>
  <description>
    Links a checkbox to a configvar-bit. 
    
    All changes to the configvar-bit will be immediately visible for this checkbox.
    Clicking the checkbox also updates the configvar-bit immediately.
    
    Note: this will only allow bitfield-integer config-vars. All others could cause malfunction of Reaper!
    
    Read the Reaper Internals-docs for all available config-variables(run the action ultraschall_Help_Reaper_ConfigVars_Documentation.lua for more details)
    
    If the checkbox was already linked to extstate or ini-file, the linked-state will be replaced by this new one.
    Use reagirl.Checkbox_Unlink() to unlink the checkbox from extstate/ini-file/config var.
  </description>
  <parameters>
    string element_id - the guid of the checkbox that shall toggle a config-var-bit
    string configvar_name - the config-variable, whose bit you want to toggle
    integer bit - the bit that shall be toggled; &1, &2, &4, &8, &16, etc
    boolean persist - true, make this setting persist; false, make this setting only temporary until Reaper restart
  </parameters>
  <chapter_context>
    Checkbox
  </chapter_context>
  <tags>checkbox, link to, config variable</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Checkbox_LinkToConfigVar: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Checkbox_LinkToConfigVar: param #1 - must be a valid guid", 2) end
  if type(configvar_name)~="string" then error("Checkbox_LinkToConfigVar: param #2 - must be a string", 2) end
  if math.type(bit)~="integer" then error("Checkbox_LinkToConfigVar: param #3 - must be an integer", 2) end
  if type(persist)~="boolean" then error("Checkbox_LinkToConfigVar: param #4 - must be a boolean", 2) end
  
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Checkbox_LinkToConfigVar: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Checkbox" then
    error("Checkbox_LinkToIniValue: param #1 - ui-element is not a checkbox", 2)
  else
    reagirl.Elements[element_id]["linked_to"]=3
    reagirl.Elements[element_id]["linked_to_configvar"]=configvar_name
    reagirl.Elements[element_id]["linked_to_bit"]=bit
    reagirl.Elements[element_id]["linked_to_persist"]=persist
    reagirl.Gui_ForceRefresh(16)
  end
end

function reagirl.Checkbox_LinkToToggleState(element_id, section, command_id)
-- ToDo in Checkbox_Manage(): SetTogglecommandState for Midi-Inline Editor, needs JS-extension features(see Ultraschall-API for details)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Checkbox_LinkToToggleState</slug>
  <requires>
    ReaGirl=1.1
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Checkbox_LinkToToggleState(string element_id, integer section, string command_id)</functioncall>
  <description>
    Links a checkbox to a toggle-command-state of an action. 
    
    All changes to the toggle-state will be immediately visible for this checkbox.
    Clicking the checkbox also updates the toggle-state immediately.
    
    If the checkbox was already linked to a config-var or ini-file, the linked-state will be replaced by this new one.
    Use reagirl.Checkbox_Unlink() to unlink the checkbox from extstate/ini-file/config var.
  </description>
  <parameters>
    string element_id - the guid of the checkbox, that you want to link to an extstate
    integer section - the section of the command, whose toggle state you want to link
                    - 0, Main
                    - 100, Main (alt recording)
                    - 32060, MIDI Editor
                    - 32061, MIDI Event List Editor
                    - 32062, MIDI Inline Editor
                    - 32063, Media Explorer
    string command_id - the action command id of the command
  </parameters>
  <chapter_context>
    Checkbox
  </chapter_context>
  <tags>checkbox, link to, toggle command state</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Checkbox_LinkToExtstate: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Checkbox_LinkToExtstate: param #1 - must be a valid guid", 2) end
  if math.type(section)~="integer" then error("Checkbox_LinkToExtstate: param #2 - must be an integer", 2) end
  if type(command_id)~="string" and math.type(command_id)~="integer" then error("Checkbox_LinkToExtstate: param #3 - must be a string", 2) end
  
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Checkbox_LinkToExtstate: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Checkbox" then
    error("Checkbox_LinkToExtstate: param #1 - ui-element is not a checkbox", 2)
  else
    if reaper.GetToggleCommandStateEx(section, reaper.NamedCommandLookup(command_id))==-1 then error("Checkbox_LinkToExtstate: param #3 - has not toggle-state", 2) end
    reagirl.Elements[element_id]["linked_to"]=4
    reagirl.Elements[element_id]["linked_to_section"]=section
    reagirl.Elements[element_id]["linked_to_command_id"]=reaper.NamedCommandLookup(command_id)
    reagirl.Gui_ForceRefresh(16)
  end
end

function reagirl.Checkbox_Unlink(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Checkbox_Unlink</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Checkbox_Unlink(string element_id)</functioncall>
  <description>
    Unlinks a checkbox from extstate/ini-file/configvar. 
  </description>
  <parameters>
    string element_id - the guid of the checkbox that you want to unlink from extstates/ini-files/configvars
  </parameters>
  <chapter_context>
    Checkbox
  </chapter_context>
  <tags>checkbox, link to, unlink</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Checkbox_Unlink: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Checkbox_Unlink: param #1 - must be a valid guid", 2) end
  
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Checkbox_Unlink: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Checkbox" then
    error("Checkbox_Unlink: param #1 - ui-element is not a checkbox", 2)
  else
    reagirl.Elements[element_id]["linked_to"]=0
    reagirl.Gui_ForceRefresh(16)
  end
end

function reagirl.Checkbox_SetCheckState(element_id, check_state)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Checkbox_SetCheckState</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Checkbox_SetCheckState(string element_id, boolean check_state)</functioncall>
  <description>
    Sets a checkbox's state of the checkbox.
  </description>
  <parameters>
    string element_id - the guid of the checkbox, whose checkbox-state you want to set
    boolean check_state - true, set checkbox checked; false, set checkbox unchecked
  </parameters>
  <chapter_context>
    Checkbox
  </chapter_context>
  <tags>checkbox, set, check-state</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Checkbox_SetCheckState: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Checkbox_SetCheckState: param #1 - must be a valid guid", 2) end
  if type(check_state)~="boolean" then error("Checkbox_SetCheckState: param #2 - must be a boolean", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Checkbox_SetCheckState: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Checkbox" then
    error("Checkbox_SetCheckState: param #1 - ui-element is not a checkbox", 2)
  else
    reagirl.Elements[element_id]["checked"]=check_state
    reagirl.Gui_ForceRefresh(16)
  end
end

function reagirl.Checkbox_GetCheckState(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Checkbox_GetCheckState</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>boolean check_state = reagirl.Checkbox_GetCheckState(string element_id)</functioncall>
  <description>
    Gets a checkbox's current checked-state.
  </description>
  <parameters>
    string element_id - the guid of the checkbox, whose checkbox-state you want to get
  </parameters>
  <retvals>
    boolean check_state - true, checkbox is checked; false, the checkbox is unchecked
  </retvals>
  <chapter_context>
    Checkbox
  </chapter_context>
  <tags>checkbox, get, check-state</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Checkbox_GetCheckState: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Checkbox_GetCheckState: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Checkbox_GetCheckState: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Checkbox" then
    error("Checkbox_GetCheckState: param #1 - ui-element is not a checkbox", 2)
  else
    return reagirl.Elements[element_id]["checked"]
  end
end

function reagirl.Checkbox_SetDisabled(element_id, state)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Checkbox_SetDisabled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Checkbox_SetDisabled(string element_id, boolean state)</functioncall>
  <description>
    Sets a checkbox as disabled(non clickable).
  </description>
  <parameters>
    string element_id - the guid of the checkbox, whose disability-state you want to set
    boolean state - true, the checkbox is disabled; false, the checkbox is not disabled.
  </parameters>
  <chapter_context>
    Checkbox
  </chapter_context>
  <tags>checkbox, set, disabled</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Checkbox_SetDisabled: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Checkbox_SetDisabled: param #1 - must be a valid guid", 2) end
  if type(state)~="boolean" then error("Checkbox_SetDisabled: param #2 - must be a boolean", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Checkbox_SetDisabled: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Checkbox" then
    error("Checkbox_SetDisabled: param #1 - ui-element is not a checkbox", 2)
  else
    reagirl.Elements[element_id]["IsDisabled"]=state
    reagirl.Gui_ForceRefresh(17)
  end
end


function reagirl.Checkbox_GetDisabled(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Checkbox_GetDisabled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>boolean retval = reagirl.Checkbox_GetDisabled(string element_id)</functioncall>
  <description>
    Gets a checkbox's disabled(non clickable)-state.
  </description>
  <parameters>
    string element_id - the guid of the checkbox, whose disability-state you want to get
  </parameters>
  <retvals>
    boolean state - true, the checkbox is disabled; false, the checkbox is not disabled.
  </retvals>
  <chapter_context>
    Checkbox
  </chapter_context>
  <tags>checkbox, get, disabled</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Checkbox_GetDisabled: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Checkbox_GetDisabled: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Checkbox_GetDisabled: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Checkbox" then
    error("Checkbox_GetDisabled: param #1 - ui-element is not a checkbox", 2)
  else
    return reagirl.Elements[element_id]["IsDisabled"]
  end
end


function reagirl.UI_Element_OnMouse(element_id, mouse_cap, mouse_event, mouse_x, mouse_y, mouse_wheel, mouse_hwheel, Key, Key_utf)
-- more complicated than I thought. For some reason, it's not clicking the ui-element...
-- seems like the y-position if somehow the problem
  --[[- UI_Element_OnMouse(ui_element_guid, mouseevent, mouse_x, mouse_y)
            - mouseevent=
            -   1, FirstClk
            -   2, Click
            -   3, DBLCLK
            -   4, DRAG(in conjunction to a first run of UI_Element_OnMouse() with mouseevent=clk
            - Runs the manage-function of the ui_element_guid and ForceRefresh to sent mouse-events to mouse
            -   also needs to temporarily alter gfx.mouse_x and gfx.mouse_y to the desired coordinate
            --]]
  local id=reagirl.UI_Element_GetIDFromGuid(element_id)
  reagirl.Elements.FocusedElement=id
  local x2, y2, w2, h2
  local scale=reagirl.Window_GetCurrentScale()
  if reagirl.Elements[id]["x"]<0 then x2=gfx.w+(reagirl.Elements[id]["x"]*scale) else x2=(reagirl.Elements[id]["x"]*scale) end
  if reagirl.Elements[id]["y"]<0 then y2=gfx.h+(reagirl.Elements[id]["y"]*scale) else y2=(reagirl.Elements[id]["y"]*scale) end
  if reagirl.Elements[id]["w"]<0 then w2=gfx.w+(-x2+reagirl.Elements[id]["w"]*scale) else w2=reagirl.Elements[id]["w"]*scale end
  if reagirl.Elements[id]["h"]<0 then h2=gfx.h+(-y2+reagirl.Elements[id]["h"]*scale) else h2=reagirl.Elements[id]["h"]*scale end
  oldmouse_x=gfx.mouse_x
  oldmouse_y=gfx.mouse_y
  oldwheel=gfx.mouse_wheel
  oldhwheel=gfx.mouse_hwheel
  oldmousecap=gfx.mouse_cap
  gfx.mouse_x=mouse_x
  gfx.mouse_y=mouse_y
  gfx.mouse_wheel=mouse_wheel
  gfx.mouse_hwheel=mouse_hwheel
  gfx.mouse_cap=mouse_cap
  
  local cur_message, refresh=reagirl.Elements[id]["func_manage"](id, true,
              true,
              mouse_event,
              mouse_cap,
              {mouse_x, mouse_y, mouse_x, mouse_y, mouse_wheel, mouse_hwheel},
              reagirl.Elements[id]["Name"],
              reagirl.Elements[id]["Description"], 
              math.tointeger(x2+reagirl.MoveItAllRight),
              math.tointeger(y2+reagirl.MoveItAllUp),
              math.tointeger(w2),
              math.tointeger(h2),
              Key,
              Key_utf,
              reagirl.Elements[id]
            )
  gfx.mouse_x=oldmouse_x
  gfx.mouse_y=oldmouse_y
  gfx.mouse_wheel=oldwheel
  gfx.mouse_hwheel=oldhwheel
  gfx.mouse_cap=oldmousecap
end
--mespotine
function reagirl.UI_Element_Last_Element_Current_Position()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_Last_Element_Current_Position</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer last_x, integer last_y, integer last_w, integer last_h = reagirl.UI_Element_Last_Element_Current_Position()</functioncall>
  <description>
    Returns the x and y position as well as width and height of the last added ui-element.
  </description>
  <retvals>
    integer last_x - the x-position of the last added ui-element
    integer last_y - the y-position of the last added ui-element
    integer last_w - the width of the last added ui-element
    integer last_h - the height of the last added ui-element
  </retvals>
  <chapter_context>
    UI Elements
  </chapter_context>
  <tags>ui-elements, get, last ui-element, current position, width, height</tags>
</US_DocBloc>
--]]
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  local x
  x=reagirl.UI_Element_NextX_Default
  if slot-1>0 then
    x=x+reagirl.Elements[slot-1]["x"]
  end
  
  local y
  y=reagirl.UI_Element_NextY_Default
  if slot-1>0 then
    y=reagirl.Elements[slot-1]["y"]
  end
  
  local w, h
  w=0
  h=0
  if slot-1>0 then
    w=reagirl.Elements[slot-1]["w"]
    h=reagirl.Elements[slot-1]["h"]
  end
  return x,y
end

function reagirl.NextLine(y_offset)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>NextLine</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.NextLine(integer y_offset)</functioncall>
  <description>
    Starts a new line, when autopositioning ui-elements using the _add-functions.
  </description>
  <parameters>
    integer y_offset - an additional y-offset, by which the next line shall be moved downwards; nil, for no offset
  </parameters>
  <chapter_context>
    Autoposition
  </chapter_context>
  <tags>ui-elements, set, next line</tags>
</US_DocBloc>
--]]
  if y_offset~=nil and math.type(y_offset)~="integer" then error("NextLine: param #1 - must be either nil or an integer", 2) end
  if y_offset==nil then y_offset=0 end
  local UI_Element_NextLineY=0
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  local slot2=slot
  if reagirl.Next_Y~=nil then slot2=reagirl.Next_Y+1 end
  if reagirl.UI_Element_NextLineY==0 then
    for i=slot2-1, 1, -1 do
      if reagirl.Elements[i]["IsDecorative"]~=true then
        if reagirl.Elements[i]["NextLine"]==nil then
          local x2, y2, w2, h2
          if reagirl.Elements[i]["y"]<0 then y2=gfx.h+(reagirl.Elements[i]["y"]) else y2=reagirl.Elements[i]["y"] end
          if reagirl.Elements[i]["h"]<0 then h2=gfx.h+(-y2+reagirl.Elements[i]["h"]) else h2=reagirl.Elements[i]["h"] end
          if reagirl.UI_Element_NextLineY+h2+1+reagirl.UI_Element_NextY_Margin+y_offset>UI_Element_NextLineY then
            UI_Element_NextLineY=reagirl.UI_Element_NextLineY+h2+1+reagirl.UI_Element_NextY_Margin+y_offset
          end
        else
          break
        end
      end
    end
  else
    UI_Element_NextLineY=reagirl.UI_Element_NextLineY+reagirl.UI_Element_NextY_Margin
  end
  if UI_Element_NextLineY>reagirl.NextLine_Overflow then
    reagirl.UI_Element_NextLineY=UI_Element_NextLineY+2
  else
    reagirl.UI_Element_NextLineY=reagirl.NextLine_Overflow+2
  end
  reagirl.NextLine_Overflow=0
  reagirl.NextLine_triggered=true
  reagirl.UI_Element_NextLineX=reagirl.UI_Element_NextX_Default
  if reagirl.Elements[slot-1]~=nil then
    reagirl.Elements[slot-1]["NextLine"]=true
  end
end

function reagirl.ColorRectangle_Add(x, y, w, h, r, g, b, caption, meaningOfUI_Element, color_selector_when_clicked, run_function)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ColorRectangle_Add</slug>
  <requires>
    ReaGirl=1.1
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>string color_rectangle_guid = reagirl.ColorRectangle_Add(optional integer x, optional integer y, integer r, integer g, integer b, string caption, string meaningOfUI_Element, optional function run_function)</functioncall>
  <description>
    Adds a color-rectangle to a gui.
    
    You can autoposition the color-rectangle by setting x and/or y to nil, which will position the new color_rectangle after the last ui-element.
    To autoposition into the next line, use reagirl.NextLine()
    
    The run-function gets as parameter:
    - string element_id - the element_id as string of the clicked color-rectangle that uses this run-function
  </description>
  <parameters>
    optional integer x - the x position of the color-rectangle in pixels; negative anchors the color-rectangle to the right window-side; nil, autoposition after the last ui-element(see description)
    optional integer y - the y position of the color-rectangle in pixels; negative anchors the color-rectangle to the bottom window-side; nil, autoposition after the last ui-element(see description)
    integer w - the width of the color-rectangle in pixels
    integer h - the height of the color-rectangle in pixels
    integer r - red-value from 0-255
    integer g - green-value from 0-255
    integer b - blue-value from 0-255
    string caption - the caption of the color-rectangle
    string meaningOfUI_Element - the meaningOfUI_Element of the ui-element(for tooltips and blind users). Make it a sentence that ends with . or ?
    boolean color_selector_when_clicked - true, clicking the color rectangle will open up a color-selection dialog(will ignore run_function parameter)
                                        - false, clicking will run the run-function
    optional function run_function - a function that shall be run when the color-rectangle is clicked; will get the color-rectangle-element_id passed over as first parameter; nil, no run-function for this color-rectangle
  </parameters>
  <retvals>
    string color_rectangle_guid - a guid that can be used for altering the color-rectangle-attributes
  </retvals>
  <chapter_context>
    Color Rectangle
  </chapter_context>
  <tags>color rectangle, add</tags>
</US_DocBloc>
--]]
  if x~=nil and math.type(x)~="integer" then error("ColorRectangle_Add: param #1 - must be either nil or an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("ColorRectangle_Add: param #2 - must be either nil or an integer", 2) end
  if math.type(w)~="integer" then error("ColorRectangle_Add: param #3 - must be an integer", 2) end
  if math.type(h)~="integer" then error("ColorRectangle_Add: param #4 - must be an integer", 2) end
  if math.type(r)~="integer" then error("ColorRectangle_Add: param #5 - must be an integer", 2) end
  if math.type(g)~="integer" then error("ColorRectangle_Add: param #6 - must be an integer", 2) end
  if math.type(b)~="integer" then error("ColorRectangle_Add: param #7 - must be an integer", 2) end
  
  if type(caption)~="string" then error("ColorRectangle_Add: param #8 - must be a string", 2) end
  caption=string.gsub(caption, "[\n\r]", "")
  if type(meaningOfUI_Element)~="string" then error("ColorRectangle_Add: param #9 - must be a string", 2) end
  if meaningOfUI_Element:sub(-1,-1)~="." and meaningOfUI_Element:sub(-1,-1)~="?" then error("ColorRectangle_Add: param #9 - must end on a . like a regular sentence.", 2) end
  if type(color_selector_when_clicked)~="boolean" then error("ColorRectangle_Add: param #10 - must be a boolean", 2) end
  if run_function~=nil and type(run_function)~="function" then error("ColorRectangle_Add: param #11 - must be either nil or a function(ignored when #10 is set to true)", 2) end
  
  local x,y,slot=reagirl.UI_Element_GetNextXAndYPosition(x, y, "ColorRectangle_Add")
  --reagirl.UI_Element_NextX_Default=x
  
  --reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0, 1)
  --local tx,ty=gfx.measurestr(caption)
  --reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  
  table.insert(reagirl.Elements, slot, {})
  reagirl.Elements[slot]["Guid"]=reaper.genGuid("")
  reagirl.Elements[slot]["GUI_Element_Type"]="Color"
  reagirl.Elements[slot]["Name"]=caption
  reagirl.Elements[slot]["Text"]=caption
  reagirl.Elements[slot]["IsDisabled"]=false
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false
  reagirl.Elements[slot]["Description"]=meaningOfUI_Element
  reagirl.Elements[slot]["AccHint"]="Click with space or left mouseclick."
  reagirl.Elements[slot]["ContextMenu_ACC"]=""
  reagirl.Elements[slot]["DropZoneFunction_ACC"]=""
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["w"]=w
  reagirl.Elements[slot]["h"]=h
  reagirl.Elements[slot]["r"]=r/255
  reagirl.Elements[slot]["g"]=g/255
  reagirl.Elements[slot]["b"]=b/255
  --if math.tointeger(ty+h_margin)>reagirl.NextLine_Overflow then reagirl.NextLine_Overflow=math.tointeger(ty+h_margin) end
  reagirl.Elements[slot]["radius"]=2
  reagirl.Elements[slot]["func_manage"]=reagirl.ColorRectangle_Manage
  reagirl.Elements[slot]["func_draw"]=reagirl.ColorRectangle_Draw
  reagirl.Elements[slot]["run_function"]=run_function
  reagirl.Elements[slot]["color_selector_when_clicked"]=color_selector_when_clicked
  reagirl.Elements[slot]["userspace"]={}
  return reagirl.Elements[slot]["Guid"]
end

function reagirl.ColorRectangle_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
-- !!TODO!! - send color to screenreader
--          - get/set disabled
--          - get/set color
  if selected~="not selected" and clicked=="FirstCLK" and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    if element_storage["color_selector_when_clicked"]==true then
      local retval, color2=reaper.GR_SelectColor()
      if retval==1 then
        local r,g,b=reaper.ColorFromNative(color2)
        element_storage["r"]=r/255
        element_storage["g"]=g/255
        element_storage["b"]=b/255
      end
    elseif element_storage["run_function"]~=nil then
      element_storage["run_function"](element_storage["Guid"])
    end
  end
end

function reagirl.ColorRectangle_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  gfx.set(element_storage["r"],element_storage["g"],element_storage["b"])
  reagirl.RoundRect(x,y,w,h, element_storage["radius"]*reagirl.Window_GetCurrentScale(), 1, 1)
end

function reagirl.ColorRectangle_GetRadius(element_id)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ColorRectangle_GetRadius</slug>
  <requires>
    ReaGirl=1.1
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer radius = reagirl.ColorRectangle_GetRadius(string element_id)</functioncall>
  <description>
    Gets a color-rectangle's radius.
  </description>
  <parameters>
    string element_id - the guid of the color-rectangle, whose radius you want to get
  </parameters>
  <retvals>
    integer radius - the radius of the color-rectangle
  </retvals>
  <chapter_context>
    Color Rectangle
  </chapter_context>
  <tags>button, get, radius</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("ColorRectangle_GetRadius: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("ColorRectangle_GetRadius: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("ColorRectangle_GetRadius: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Color" then
    error("ColorRectangle_GetRadius: param #1 - ui-element is not a color-rectangle", 2)
  else
    return reagirl.Elements[element_id]["radius"]
  end
end

function reagirl.ColorRectangle_SetRadius(element_id, radius)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ColorRectangle_SetRadius</slug>
  <requires>
    ReaGirl=1.1
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.ColorRectangle_SetRadius(string element_id, integer radius)</functioncall>
  <description>
    Sets the radius of a color-rectangle.
  </description>
  <parameters>
    string element_id - the guid of the color-rectangle, whose radius you want to set
    integer radius - between 0 and 10
  </parameters>
  <chapter_context>
    Color Rectangle
  </chapter_context>
  <tags>color rectangle, set, radius</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("ColorRectangle_SetRadius: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("ColorRectangle_SetRadius: param #1 - must be a valid guid", 2) end
  if math.type(radius)~="integer" then error("ColorRectangle_SetRadius: param #2 - must be a integer", 2) end
  --if radius>10 then radius=10 end
  if radius<0 then radius=0 end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("ColorRectangle_SetRadius: param #1 - no such ui-element", 2) end
  
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Color" then
    return false
  else
    reagirl.Elements[element_id]["radius"]=radius
    reagirl.Gui_ForceRefresh(19)
  end
  return true
end

function reagirl.Button_Add(x, y, w_margin, h_margin, caption, meaningOfUI_Element, run_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Button_Add</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>string button_guid = reagirl.Button_Add(optional integer x, optional integer y, integer w_margin, integer h_margin, string caption, string meaningOfUI_Element, optional function run_function)</functioncall>
  <description>
    Adds a button to a gui.
    
    You can autoposition the button by setting x and/or y to nil, which will position the new button after the last ui-element.
    To autoposition into the next line, use reagirl.NextLine()
    
    The run-function gets as parameter:
    - string element_id - the element_id as string of the pressed button that uses this run-function
  </description>
  <parameters>
    optional integer x - the x position of the button in pixels; negative anchors the button to the right window-side; nil, autoposition after the last ui-element(see description)
    optional integer y - the y position of the button in pixels; negative anchors the button to the bottom window-side; nil, autoposition after the last ui-element(see description)
    integer w_margin - a margin left and right of the caption
    integer h_margin - a margin top and bottom of the caption
    string caption - the caption of the button
    string meaningOfUI_Element - the meaningOfUI_Element of the ui-element(for tooltips and blind users). Make it a sentence that ends with . or ?
    optional function run_function - a function that shall be run when the button is clicked; will get the button-element_id passed over as first parameter; nil, no run-function for this button
  </parameters>
  <retvals>
    string button_guid - a guid that can be used for altering the button-attributes
  </retvals>
  <chapter_context>
    Button
  </chapter_context>
  <tags>button, add</tags>
</US_DocBloc>
--]]
  if x~=nil and math.type(x)~="integer" then error("Button_Add: param #1 - must be either nil or an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("Button_Add: param #2 - must be either nil or an integer", 2) end
  if math.type(w_margin)~="integer" then error("Button_Add: param #3 - must be an integer", 2) end
  if math.type(h_margin)~="integer" then error("Button_Add: param #4 - must be an integer", 2) end
  if type(caption)~="string" then error("Button_Add: param #5 - must be a string", 2) end
  caption=string.gsub(caption, "[\n\r]", "")
  if type(meaningOfUI_Element)~="string" then error("Button_Add: param #6 - must be a string", 2) end
  if meaningOfUI_Element:sub(-1,-1)~="." and meaningOfUI_Element:sub(-1,-1)~="?" then error("Button_Add: param #6 - must end on a . like a regular sentence.", 2) end
  if run_function~=nil and type(run_function)~="function" then error("Button_Add: param #7 - must be either nil or a function", 2) end
  
  local x,y,slot=reagirl.UI_Element_GetNextXAndYPosition(x, y, "Button_Add")
  --reagirl.UI_Element_NextX_Default=x
  
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0, 1)
  local tx,ty=gfx.measurestr(caption)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  
  table.insert(reagirl.Elements, slot, {})
  reagirl.Elements[slot]["Guid"]=reaper.genGuid("")
  reagirl.Elements[slot]["GUI_Element_Type"]="Button"
  reagirl.Elements[slot]["Name"]=caption
  reagirl.Elements[slot]["Text"]=caption
  reagirl.Elements[slot]["IsDisabled"]=false
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false
  reagirl.Elements[slot]["Description"]=meaningOfUI_Element
  reagirl.Elements[slot]["AccHint"]="Click with space or left mouseclick."
  reagirl.Elements[slot]["ContextMenu_ACC"]=""
  reagirl.Elements[slot]["DropZoneFunction_ACC"]=""
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["w"]=math.tointeger(tx+15+w_margin)
  reagirl.Elements[slot]["h"]=math.tointeger(ty+h_margin)
  if math.tointeger(ty+h_margin)>reagirl.NextLine_Overflow then reagirl.NextLine_Overflow=math.tointeger(ty+h_margin) end
  reagirl.Elements[slot]["w_margin"]=w_margin
  reagirl.Elements[slot]["h_margin"]=h_margin
  reagirl.Elements[slot]["radius"]=2
  reagirl.Elements[slot]["func_manage"]=reagirl.Button_Manage
  reagirl.Elements[slot]["func_draw"]=reagirl.Button_Draw
  reagirl.Elements[slot]["run_function"]=run_function
  reagirl.Elements[slot]["userspace"]={}
  return reagirl.Elements[slot]["Guid"]
end

function reagirl.Button_SetDisabled(element_id, state)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Button_SetDisabled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Button_SetDisabled(string element_id, boolean state)</functioncall>
  <description>
    Sets a button as disabled(non clickable).
  </description>
  <parameters>
    string element_id - the guid of the button, whose disability-state you want to set
    boolean state - true, the button is disabled; false, the button is not disabled.
  </parameters>
  <chapter_context>
    Button
  </chapter_context>
  <tags>button, set, disabled</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Button_SetDisabled: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Button_SetDisabled: param #1 - must be a valid guid", 2) end
  if type(state)~="boolean" then error("Button_SetDisabled: param #2 - must be a boolean", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Button_SetDisabled: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Button" then
    error("Button_SetDisabled: param #1 - ui-element is not a button", 2)
  else
    reagirl.Elements[element_id]["IsDisabled"]=state
    reagirl.Gui_ForceRefresh(18)
  end
end

function reagirl.Button_GetDisabled(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Button_GetDisabled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>boolean retval = reagirl.Button_GetDisabled(string element_id)</functioncall>
  <description>
    Gets a button's disabled(non clickable)-state.
  </description>
  <parameters>
    string element_id - the guid of the button, whose disability-state you want to get
  </parameters>
  <retvals>
    boolean state - true, the button is disabled; false, the button is not disabled.
  </retvals>
  <chapter_context>
    Button
  </chapter_context>
  <tags>button, get, disabled</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Button_GetDisabled: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Button_GetDisabled: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Button_GetDisabled: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Button" then
    error("Button_GetDisabled: param #1 - ui-element is not a button", 2)
  else
    return reagirl.Elements[element_id]["IsDisabled"]
  end
end

function reagirl.Button_GetRadius(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Button_GetRadius</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer radius = reagirl.Button_GetRadius(string element_id)</functioncall>
  <description>
    Gets a button's radius.
  </description>
  <parameters>
    string element_id - the guid of the button, whose radius you want to get
  </parameters>
  <retvals>
    integer radius - the radius of the button
  </retvals>
  <chapter_context>
    Button
  </chapter_context>
  <tags>button, get, radius</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Button_GetRadius: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Button_GetRadius: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Button_GetRadius: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Button" then
    error("Button_GetRadius: param #1 - ui-element is not a button", 2)
  else
    return reagirl.Elements[element_id]["radius"]
  end
end

function reagirl.Button_SetRadius(element_id, radius)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Button_SetRadius</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Button_SetRadius(string element_id, integer radius)</functioncall>
  <description>
    Sets the radius of a button.
  </description>
  <parameters>
    string element_id - the guid of the button, whose radius you want to set
    integer radius - between 0 and 10
  </parameters>
  <chapter_context>
    Button
  </chapter_context>
  <tags>button, set, radius</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Button_SetRadius: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Button_SetRadius: param #1 - must be a valid guid", 2) end
  if math.type(radius)~="integer" then error("Button_SetRadius: param #2 - must be a integer", 2) end
  if radius>10 then 
     radius=10 end
  if radius<0 then radius=0 end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Button_SetRadius: param #1 - no such ui-element", 2) end
  
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Button" then
    return false
  else
    reagirl.Elements[element_id]["radius"]=radius
    reagirl.Gui_ForceRefresh(19)
  end
  return true
end

function reagirl.Button_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  local message=" "
  local refresh=false
  local oldpressed=element_storage["pressed"]
  
  -- drop files for accessibility using a file-requester, after typing ctrl+shift+f
  if element_storage["DropZoneFunction"]~=nil and Key==6 and mouse_cap==12 then
    local retval, filenames = reaper.GetUserFileNameForRead("", "Choose file to drop into "..element_storage["Name"], "")
    reagirl.Window_SetFocus()
    if retval==true then element_storage["DropZoneFunction"](element_storage["Guid"], {filenames}) refresh=true end
  end
  
  if selected~="not selected" and (Key==32 or Key==13) then 
    element_storage["pressed"]=true
    message=""
    reagirl.Gui_ForceRefresh(20)
  elseif selected~="not selected" and mouse_cap&1~=0 and gfx.mouse_x>x and gfx.mouse_y>y and gfx.mouse_x<x+w and gfx.mouse_y<y+h then
    local oldstate=element_storage["pressed"]
    element_storage["pressed"]=true
    if oldstate~=element_storage["pressed"] then
      reagirl.Gui_ForceRefresh(21)
    end
    message=""
  else
    local oldstate=element_storage["pressed"]
    element_storage["pressed"]=false
    if oldstate~=element_storage["pressed"] then
      reagirl.Gui_ForceRefresh(22)
    end
  end
  if oldpressed==true and element_storage["pressed"]==false and (mouse_cap&1==0 and Key~=32) then
    if element_storage["run_function"]~=nil then element_storage["run_function"](element_storage["Guid"]) message="pressed" end
  end

  return message, oldpressed~=element_storage["pressed"]
end

function reagirl.Button_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  gfx.x=x
  gfx.y=y
  local offset
  local dpi_scale, state
  local radius = element_storage["radius"]
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  
  local sw,sh=gfx.measurestr(element_storage["Name"])
  
  local dpi_scale=reagirl.Window_CurrentScale
  y=y+dpi_scale
  if reagirl.Elements[element_id]["pressed"]==true then
    local scale=reagirl.Window_CurrentScale-1
    state=1*dpi_scale-1
    
    offset=1--math.floor(dpi_scale)
    
    if offset==0 then offset=1 end
    
    gfx.set(0.06) -- background 2
    reagirl.RoundRect(x, y, w+dpi_scale+dpi_scale, h, (radius) * dpi_scale, 1, 1)
    
    gfx.set(0.274) -- button-area
    reagirl.RoundRect(x+dpi_scale, y+dpi_scale, w+dpi_scale, h, (radius-1) * dpi_scale, 1, 1)
    
    if element_storage["IsDisabled"]==false then
      gfx.x=x+(w-sw)/2+2+scale
    
      if reaper.GetOS():match("OS")~=nil then offset=1 end
      gfx.y=y+(h-sh)/2+scale
      gfx.set(0.784)
      gfx.drawstr(element_storage["Name"])
    end
    reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  else
    local scale=1--reagirl.Window_CurrentScale
    state=0
    
    gfx.set(0.06) -- background 1
    reagirl.RoundRect((x)*scale, (y)*scale, w, h, radius * dpi_scale, 1, 1)
    
    gfx.set(0.45) -- background 2
    reagirl.RoundRect(x*scale, (y - dpi_scale) * scale, w-dpi_scale, h, radius * dpi_scale, 1, 1)
    
    gfx.set(0.274) -- button-area
    reagirl.RoundRect((x + dpi_scale) * scale, (y) * scale, w-dpi_scale-dpi_scale, h-dpi_scale, (radius-1) * dpi_scale, 1, 1)
    
    local offset=0
    if element_storage["IsDisabled"]==false then
      gfx.x=x+(w-sw)/2+1
      if reaper.GetOS():match("OS")~=nil then offset=1 end
      gfx.y=y--+(h-sh)/2-dpi_scale
      gfx.set(0.784)
      gfx.drawstr(element_storage["Name"])
    else
      if reaper.GetOS():match("OS")~=nil then offset=1 end
      
      gfx.x=x+(w-sw)/2+1+dpi_scale
      gfx.y=y+(h-sh)/2+1+offset-1
      gfx.y=y+dpi_scale--(h-gfx.texth)/2+offset
      gfx.set(0.09)
      gfx.drawstr(element_storage["Name"])
      
      gfx.x=x+(w-sw)/2+1
      
      gfx.y=y--+(h-gfx.texth)/2+offset-1
      gfx.set(0.55)
      gfx.drawstr(element_storage["Name"])
    end
  end
  
end




function reagirl.Inputbox_Add(x, y, w, caption, Cap_width, meaningOfUI_Element, Default, run_function_enter, run_function_type)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Inputbox_Add</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>string inputbox_guid = reagirl.Inputbox_Add(optional integer x, optional integer y, integer w, string caption, optional integer cap_width, string meaningOfUI_Element, optional string Default, optional function run_function_enter, function run_function_type)</functioncall>
  <description>
    Adds an inputbox to a gui.
    
    You can autoposition the inputbox by setting x and/or y to nil, which will position the new inputbox after the last ui-element.
    To autoposition into the next line, use reagirl.NextLine()
    
    The caption will be shown before the inputbox.    
    
    Unlike other ui-elements, this one has the option for two run_functions, one for when the user hits enter in the inputbox and one for when the user types anything into the inputbox.
    
    Important:
    Screen reader users get an additional dialog shown when entering text, that will NOT run the run-function for typed text. This is due some limitations in Reaper's API and can't be circumvented.
    So you can't rely only on the run_function_type but also need to add a run_function_enter, when you want to use the value immediately when typed in your script(like setting as a setting into an ini-file).
    Otherwise blind users would be able to enter text but it will be ignored at hitting enter by your code, which would be unfortunate.
    
    The run-functions get as parameters:
    - string element_id - the element_id as string 
    - string text - the currently entered text
  </description>
  <parameters>
    optional integer x - the x position of the inputbox in pixels; negative anchors the inputbox to the right window-side; nil, autoposition after the last ui-element(see description)
    optional integer y - the y position of the inputbox in pixels; negative anchors the inputbox to the bottom window-side; nil, autoposition after the last ui-element(see description)
    integer w - the width of the inputbox in pixels
    string caption - the caption of the inpubox
    optional integer cap_width - the width of the caption to set the actual inputbox to a fixed position; nil, put inputbox directly after caption
    string meaningOfUI_Element - the meaningOfUI_Element of the ui-element(for tooltips and blind users). Make it a sentence that ends with . or ?
    optional string Default - the "typed text" that the inputbox shall contain
    optional function run_function_enter - a function that is run when the user hits enter in the inputbox(always used, even for screen reader users)
    function run_function_type - a function that is run when the user types into the inputbox(only used if no screen reader is used)
  </parameters>
  <retvals>
    string inputbox_guid - a guid that can be used for altering the inputbox-attributes
  </retvals>
  <chapter_context>
    Inputbox
  </chapter_context>
  <tags>inputbox, add</tags>
</US_DocBloc>
--]]
  if x~=nil and math.type(x)~="integer" then error("Inputbox_Add: param #1 - must be either nil or an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("Inputbox_Add: param #2 - must be either nil or an integer", 2) end
  if math.type(w)~="integer" then error("Inputbox_Add: param #3 - must be an integer", 2) end
  if type(caption)~="string" then error("Inputbox_Add: param #4 - must be a string", 2) end
  caption=string.gsub(caption, "[\n\r]", "")
  if Cap_width~=nil and math.type(Cap_width)~="integer" then error("Inputbox_Add: param #5 - must be either nil or an integer", 2) end
  if type(meaningOfUI_Element)~="string" then error("Inputbox_Add: param #6 - must be a string", 2) end
  if meaningOfUI_Element:sub(-1,-1)~="." and meaningOfUI_Element:sub(-1,-1)~="?" then error("Inputbox_Add: param #6 - must end on a . like a regular sentence.", 2) end
  if type(Default)~="string" then error("Inputbox_Add: param #7 - must be a string", 2) end
  if run_function_enter~=nil and type(run_function_enter)~="function" then error("Inputbox_Add: param #8 - must be either nil or a function", 2) end
  if run_function_type~=nil and type(run_function_type)~="function" then error("Inputbox_Add: param #9 - must be either nil or a function", 2) end
  if run_function_type~=nil and run_function_enter==nil then error("Inputbox_Add: param #8 - must be set when using one for type, or blind people might not be able to use the gui properly", -2) end
  
  local x,y,slot=reagirl.UI_Element_GetNextXAndYPosition(x, y, "Inputbox_Add")
  --reagirl.UI_Element_NextX_Default=x
  
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0, 1)
  local tx,ty=gfx.measurestr(caption)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  
  table.insert(reagirl.Elements, slot, {})
  reagirl.Elements[slot]["Guid"]=reaper.genGuid("")
  reagirl.Elements[slot]["GUI_Element_Type"]="Edit"
  reagirl.Elements[slot]["Name"]=caption
  reagirl.Elements[slot]["cap_w"]=math.tointeger(tx)+10
  reagirl.Elements[slot]["Description"]=meaningOfUI_Element
  reagirl.Elements[slot]["IsDisabled"]=false
  reagirl.Elements[slot]["AccHint"]="Hit Enter to open up an accessible input dialog to enter text."
  reagirl.Elements[slot]["ContextMenu_ACC"]=""
  reagirl.Elements[slot]["DropZoneFunction_ACC"]=""
  reagirl.Elements[slot]["Cap_width"]=Cap_width
  if Cap_width==nil then 
    reagirl.Elements[slot]["Cap_width"]=math.floor(tx)
  end
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["w"]=w
  reagirl.Elements[slot]["h"]=math.tointeger(ty)
  if math.tointeger(ty)>reagirl.NextLine_Overflow then reagirl.NextLine_Overflow=math.tointeger(ty) end
  reagirl.Elements[slot]["blink"]=0
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false
  Default=string.gsub(Default, "\n", "")
  Default=string.gsub(Default, "\r", "")
  reagirl.Elements[slot]["Text"]=Default
  reagirl.Elements[slot]["draw_offset"]=0
  reagirl.Elements[slot]["draw_offset_end"]=10
  reagirl.Elements[slot]["cursor_offset"]=0
  reagirl.Elements[slot]["selection_startoffset"]=1
  reagirl.Elements[slot]["selection_endoffset"]=1
  reagirl.Elements[slot]["empty_text"]=""
  
  reagirl.Elements[slot]["password"]=""
  
  reagirl.Elements[slot].hasfocus=false
  reagirl.Elements[slot].hasfocus_old=false
  reagirl.Elements[slot].cursor_offset=1
  reagirl.Elements[slot].draw_offset=reagirl.Elements[slot].cursor_offset
  reagirl.Elements[slot].draw_offset_end=reagirl.Elements[slot].cursor_offset

  reagirl.Elements[slot].selection_startoffset=reagirl.Elements[slot].cursor_offset
  reagirl.Elements[slot].selection_endoffset=reagirl.Elements[slot].cursor_offset
  
  reagirl.Elements[slot]["func_manage"]=reagirl.Inputbox_Manage
  reagirl.Elements[slot]["func_draw"]=reagirl.Inputbox_Draw
  reagirl.Elements[slot]["run_function"]=run_function_enter
  reagirl.Elements[slot]["run_function_type"]=run_function_type
  reagirl.Elements[slot]["userspace"]={}
  reagirl.Inputbox_Calculate_DrawOffset(true, reagirl.Elements[slot])
  
  return reagirl.Elements[slot]["Guid"]
end


function reagirl.Inputbox_SetPassword(element_id, password)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Inputbox_SetPassword</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Inputbox_SetPassword(string element_id, boolean password_state)</functioncall>
  <description>
    Sets an inputbox to show * instead of the text(for password entry, etc)
  </description>
  <parameters>
    string element_id - the guid of the inputbox, that you want to set to password-input
    boolean password_state - true, set the inputbox to show * instead of the actual text; false, show normal text
  </parameters>
  <chapter_context>
    Inputbox
  </chapter_context>
  <tags>inputbox, set, password</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Inputbox_SetPassword: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Inputbox_SetPassword: param #1 - must be a valid guid", 2) end
  if type(password)~="boolean" then error("Inputbox_SetPassword: param #2 - must be a boolean", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Inputbox_SetPassword: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Edit" then
    error("Inputbox_SetPassword: param #1 - ui-element is not an inputbox", 2)
  else
    if password==true then 
      reagirl.Elements[element_id]["password"]="*"
    else
      reagirl.Elements[element_id]["password"]=""
    end
    reagirl.Gui_ForceRefresh(15)
  end
end

function reagirl.Inputbox_GetPassword(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Inputbox_GetPassword</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Inputbox_GetPassword(string element_id, boolean password_state)</functioncall>
  <description>
    gets an inputbox to show * instead of the text(for password entry, etc)
  </description>
  <parameters>
    string element_id - the guid of the inputbox, whose password-input-state you want to get
  </parameters>
  <retvals>
    boolean password_state - true, the inputbox shows * instead of the actual text; false, shows normal text
  </retvals>
  <chapter_context>
    Inputbox
  </chapter_context>
  <tags>inputbox, get, password</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Inputbox_GetPassword: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Inputbox_GetPassword: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Inputbox_GetPasswort: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Edit" then
    error("Inputbox_GetPassword: param #1 - ui-element is not an inputbox", 2)
  else
    return reagirl.Elements[element_id]["password"]=="*"
  end
end



function reagirl.Inputbox_OnMouseDown(mouse_cap, element_storage)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  element_storage.hasfocus_old=element_storage.hasfocus
  element_storage.hasfocus=gfx.mouse_x>=element_storage.x2 and gfx.mouse_x<element_storage.x2+element_storage.w2 and
                           gfx.mouse_y>=element_storage.y2 and gfx.mouse_y<element_storage.y2+element_storage.h2
  reagirl.mouse.down=true
  reagirl.mouse.x=gfx.mouse_x
  reagirl.mouse.y=gfx.mouse_y
  
  if element_storage.hasfocus==true then
    if mouse_cap&8==0 then
      element_storage.cursor_offset=reagirl.Inputbox_GetTextOffset(gfx.mouse_x,gfx.mouse_y, element_storage)
      
      element_storage.cursor_startoffset=element_storage.cursor_offset
      element_storage.clicked1=true
      if element_storage.cursor_offset==-2 then 
        element_storage.cursor_offset=element_storage.Text:utf8_len() 
        element_storage.selection_startoffset=element_storage.cursor_offset
        element_storage.selection_endoffset=element_storage.cursor_offset
        element_storage.cursor_startoffset=element_storage.cursor_offset
      elseif element_storage.cursor_offset==-1 then
        element_storage.cursor_offset=0
        element_storage.selection_startoffset=0
        element_storage.selection_endoffset=0
        element_storage.cursor_startoffset=element_storage.cursor_offset
      else
        element_storage.selection_startoffset=element_storage.cursor_offset
        element_storage.selection_endoffset=element_storage.cursor_offset
      end
    elseif mouse_cap&8==8 then
      local newoffs, startoffs, endoffs=reagirl.Inputbox_GetTextOffset(gfx.mouse_x,gfx.mouse_y, element_storage)
      
      if newoffs>0 then
        if newoffs<element_storage.cursor_offset then 
          element_storage.selection_startoffset=newoffs
          element_storage.selection_endoffset=element_storage.cursor_offset
          reagirl.mouse.dragged=true
        elseif newoffs>element_storage.cursor_offset then
          element_storage.selection_startoffset=element_storage.cursor_offset
          element_storage.selection_endoffset=newoffs
          reagirl.mouse.dragged=true
        else
          element_storage.cursor_offset=newoffs
          element_storage.selection_startoffset=element_storage.cursor_offset
          element_storage.selection_endoffset=element_storage.cursor_offset
        end
      elseif newoffs==-2 then 
        element_storage.selection_startoffset=element_storage.cursor_offset
        element_storage.selection_endoffset=endoffs
        reagirl.mouse.dragged=true
      elseif newoffs==-1 then 
        element_storage.selection_startoffset=startoffs
        element_storage.selection_endoffset=element_storage.cursor_offset
        reagirl.mouse.dragged=true
      end
    end
  end
end

function reagirl.Inputbox_GetTextOffset(x,y,element_storage)
  -- BUGGY!
  -- Offset is off
  -- still is?
  local dpi_scale = reagirl.Window_GetCurrentScale()
  local cap_w
  if element_storage["Cap_width"]==nil then
    cap_w=gfx.measurestr(element_storage["Name"])
    cap_w=math.tointeger(cap_w)+dpi_scale*5+5*dpi_scale
  else
    cap_w=element_storage["Cap_width"]*dpi_scale
    cap_w=cap_w+dpi_scale
  end
  
  local startoffs=element_storage.x2+cap_w
  local cursoffs=element_storage.draw_offset
  
  local textw=gfx.measurechar(65)
  local x2, w2
  if element_storage["x"]<0 then x2=gfx.w+element_storage["x"]*dpi_scale else x2=element_storage["x"]*dpi_scale end
  if element_storage["w"]<0 then w2=gfx.w-x2+element_storage["w"]*dpi_scale else w2=element_storage["w"]*dpi_scale end
  w2=w2-cap_w
  
  -- if click==outside of left edge of the inputbox
  if x<startoffs then return -1, element_storage.draw_offset, element_storage.draw_offset+math.floor(element_storage.w2/textw) end
  
  local draw_offset=dpi_scale*5
  for i=element_storage.draw_offset, element_storage.Text:utf8_len() do --draw_offset+math.floor(element_storage.w2/textw) do
    
    if draw_offset+textw>w2 then break end -- this line is buggy, it doesn't go off, when auto-width is set and the user tries to move selection outside the right edge of the boundary box
    local textw
    if element_storage["password"]=="*" then
      textw=gfx.measurestr("*")
    else
      textw=gfx.measurestr(element_storage.Text:utf8_sub(i,i))
    end
    --local textw=gfx.measurestr(element_storage.Text:utf8_sub(i,i))
    
    if x>=startoffs and x<=startoffs+textw then
      return cursoffs-1, element_storage.draw_offset-1, element_storage.draw_offset+math.floor(element_storage.w2/textw)-1
    end
    cursoffs=cursoffs+1
    startoffs=startoffs+textw
    draw_offset=draw_offset+textw
  end
  --]]
  
  -- if click==outside of right edge of the inputbox
  return -2, element_storage.draw_offset, element_storage.draw_offset_end+1--element_storage.draw_offset+math.floor(element_storage.w/textw)
end

function reagirl.Inputbox_OnMouseMove(mouse_cap, element_storage)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  if element_storage.selection_startoffset==-1 then element_storage.selection_startoffset=0 end
  if element_storage.cursor_startoffset==-1 then element_storage.cursor_startoffset=0 end
  if element_storage.hasfocus==false then return end
  local newoffs, startoffs, endoffs=reagirl.Inputbox_GetTextOffset(gfx.mouse_x, gfx.mouse_y, element_storage)
  --print_update(newoffs, startoffs, endoffs)
  if newoffs>0 then -- buggy, resettet die Selection, wenn man "zurück" geht nach scrolling am Ende der Boundary Box
    if newoffs<element_storage.cursor_startoffset then
      element_storage.selection_startoffset=newoffs
      element_storage.selection_endoffset=element_storage.cursor_startoffset
    elseif newoffs>element_storage.cursor_startoffset then
      element_storage.selection_endoffset=newoffs
      element_storage.selection_startoffset=element_storage.cursor_startoffset
    elseif newoffs==element_storage.cursor_offset then
      element_storage.selection_endoffset=newoffs
      element_storage.selection_startoffset=newoffs
    end
    
    element_storage.cursor_offset=newoffs
  elseif newoffs==-1 then
    -- when dragging is outside of left edge
    element_storage.cursor_offset=startoffs-1
    if element_storage.cursor_offset<0 then element_storage.cursor_offset=0 end
    
    element_storage.draw_offset=element_storage.draw_offset-1
    if element_storage.draw_offset<0 then 
      element_storage.draw_offset=0
    end
    
    if startoffs<element_storage.cursor_startoffset then
      element_storage.selection_startoffset=element_storage.draw_offset
      element_storage.selection_endoffset=element_storage.cursor_startoffset
    elseif startoffs>=element_storage.cursor_offset then
      element_storage.selection_startoffset=element_storage.cursor_startoffset--element_storage.draw_offset
      element_storage.selection_endoffset=element_storage.cursor_startoffset
    end
    
    reagirl.Inputbox_Calculate_DrawOffset(true, element_storage)
  elseif newoffs==-2 then
    -- when dragging is outside the right edge
    element_storage.cursor_offset=endoffs+1
    if element_storage.cursor_offset>element_storage.Text:utf8_len() then element_storage.cursor_offset=element_storage.Text:utf8_len() end
    
    element_storage.draw_offset_end=element_storage.draw_offset_end+1
    if element_storage.draw_offset_end>element_storage.Text:utf8_len() then 
      element_storage.draw_offset_end=element_storage.Text:utf8_len()
    end

    if endoffs>element_storage.cursor_startoffset then
      element_storage.selection_startoffset=element_storage.cursor_startoffset
      element_storage.selection_endoffset=element_storage.draw_offset_end
    elseif endoffs<=element_storage.cursor_startoffset then
      element_storage.selection_startoffset=element_storage.cursor_startoffset
      element_storage.selection_endoffset=element_storage.cursor_startoffset--element_storage.draw_offset_end
    end
    
    
    
    reagirl.Inputbox_Calculate_DrawOffset(false, element_storage)
  end
  reagirl.mouse.dragged=true
end

function reagirl.Inputbox_OnMouseUp(mouse_cap, element_storage)
  reagirl.mouse.down=false
  reagirl.mouse.downtime=os.clock()
  
  if element_storage.hasfocus==false then
    element_storage.draw_offset=1
    element_storage.selection_startoffset=element_storage.cursor_offset
    element_storage.selection_endoffset=element_storage.cursor_offset
  end
  if reagirl.mouse.dragged~=true and element_storage.hasfocus==true then
    element_storage.selection_startoffset=element_storage.cursor_offset
    element_storage.selection_endoffset=element_storage.cursor_offset
    reagirl.mouse.dragged=false
  end
end

function reagirl.Inputbox_GetPreviousPOI(element_storage)
  for i=element_storage.cursor_offset, 0, -1 do
    if element_storage.Text:utf8_sub(i,i):has_alphanumeric_plus_underscore()==false then
      return i
    end
  end
  return 0
end

function reagirl.Inputbox_GetNextPOI(element_storage)
  for i=element_storage.cursor_offset+1, element_storage.Text:utf8_len() do
    if element_storage.Text:utf8_sub(i,i):has_alphanumeric_plus_underscore()==false then
      return i-1
    end
  end
  return element_storage.Text:utf8_len()
end

function reagirl.Inputbox_OnMouseDoubleClick(mouse_cap, element_storage)
  if element_storage["password"]=="*" then
    element_storage.selection_startoffset=0
    element_storage.selection_endoffset=element_storage["Text"]:utf8_len()
    return  
  end
  local newoffs, startoffs, endoffs=reagirl.Inputbox_GetTextOffset(gfx.mouse_x, gfx.mouse_y, element_storage)
  
  if element_storage.hasfocus==true and newoffs~=-1 then
    element_storage.selection_startoffset=reagirl.Inputbox_GetPreviousPOI(element_storage)
    element_storage.selection_endoffset=reagirl.Inputbox_GetNextPOI(element_storage)
  else
    element_storage.selection_startoffset=0
    element_storage.selection_endoffset=element_storage.Text:utf8_len()
  end
end

function reagirl.Inputbox_GetShownTextoffsets(x,y,element_storage)
  local textw=gfx.measurechar(65)
  return element_storage.draw_offset, element_storage.draw_offset+math.floor(element_storage.w/textw)
end

function reagirl.Inputbox_ConsolidateCursorPos(element_storage)
  if element_storage.cursor_offset>=element_storage.draw_offset_end-3 then
    element_storage.draw_offset_end=element_storage.cursor_offset+3
    reagirl.Inputbox_Calculate_DrawOffset(false, element_storage)
  elseif element_storage.cursor_offset<element_storage.draw_offset-1 then
    element_storage.draw_offset=element_storage.cursor_offset-3
    if element_storage.draw_offset<0 then element_storage.draw_offset=0 end
    reagirl.Inputbox_Calculate_DrawOffset(true, element_storage)
  end
end

function reagirl.Inputbox_OnTyping(Key, Key_UTF, mouse_cap, element_storage)
  if Key_UTF~=0 then Key=Key_UTF end
  local refresh=false
  local entered_text=""
  
  if Key==-1 then
  elseif Key==13 then
    if element_storage["run_function"]~=nil then
      element_storage["run_function"](element_storage["Guid"], element_storage.Text)
    end
  elseif Key==1885824110.0 then
    -- Pg down
  elseif Key==1885828464.0 then
    -- Pg up
  elseif Key==8 then
    -- Backspace
    if element_storage.cursor_offset>=0 then
      if element_storage.selection_startoffset~=element_storage.selection_endoffset then
        element_storage.Text=element_storage.Text:utf8_sub(1, element_storage.selection_startoffset)..element_storage.Text:utf8_sub(element_storage.selection_endoffset+1, -1)
        element_storage.cursor_offset=element_storage.selection_startoffset
      else
        if element_storage.cursor_offset-1>=0 then
          element_storage.Text=element_storage.Text:utf8_sub(1, element_storage.selection_startoffset-1)..element_storage.Text:utf8_sub(element_storage.selection_endoffset+1, -1)
          element_storage.cursor_offset=element_storage.selection_startoffset-1
          if element_storage.cursor_offset<element_storage.draw_offset then
            element_storage.draw_offset=element_storage.cursor_offset
          end
          reagirl.Inputbox_Calculate_DrawOffset(true, element_storage)
        end
      end
      element_storage.selection_startoffset=element_storage.cursor_offset
      element_storage.selection_endoffset=element_storage.cursor_offset
      reagirl.Inputbox_ConsolidateCursorPos(element_storage)
      
    end
  elseif Key==25 then
    -- Ctrl+Y = Redo
  elseif Key==26 then
    -- Ctrl+Z = Undo
  elseif Key==1919379572.0 then
    -- right arrow key
    if mouse_cap&4==0 then
      element_storage.cursor_offset=element_storage.cursor_offset+1
      if element_storage.cursor_offset<0 then element_storage.cursor_offset=0 
      elseif element_storage.cursor_offset>element_storage.Text:utf8_len() then
        element_storage.cursor_offset=element_storage.Text:utf8_len()
      end
      if mouse_cap&8==8 then
        if element_storage.selection_endoffset<element_storage.cursor_offset then
          element_storage.selection_endoffset=element_storage.cursor_offset
        else
          element_storage.selection_startoffset=element_storage.cursor_offset
        end
      elseif element_storage.cursor_offset>0 then
        element_storage.selection_startoffset=element_storage.cursor_offset
        element_storage.selection_endoffset=element_storage.cursor_offset
      end
    elseif mouse_cap&4==4 then
      -- ctrl+right
      local found=element_storage.cursor_offset
      for i=element_storage.cursor_offset+1, element_storage.Text:utf8_len() do
        if element_storage.Text:utf8_sub(i,i):has_alphanumeric_plus_underscore()==false or element_storage.Text:utf8_sub(i,i):has_alphanumeric_plus_underscore()~=element_storage.Text:utf8_sub(i+1,i+1):has_alphanumeric_plus_underscore() then
          found=i
          break
        end
      end

      if mouse_cap&8==8 then
        if element_storage.selection_endoffset<found then
          element_storage.selection_endoffset=found
        elseif element_storage.selection_startoffset<found then
          element_storage.selection_startoffset=found
        end
      end
      element_storage.cursor_offset=found
    end

    if element_storage.draw_offset_end<=element_storage.cursor_offset then
      element_storage.draw_offset_end=element_storage.cursor_offset+3
      reagirl.Inputbox_Calculate_DrawOffset(false, element_storage)
    end
  elseif Key==1818584692.0 then
    -- left arrow key
    if mouse_cap&4==0 then
      element_storage.cursor_offset=element_storage.cursor_offset-1
      if element_storage.cursor_offset<0 then element_storage.cursor_offset=0 
      elseif element_storage.cursor_offset>element_storage.Text:utf8_len() then
        element_storage.cursor_offset=element_storage.Text:utf8_len()
      end
      if mouse_cap&8==8 then
        if element_storage.selection_startoffset>element_storage.cursor_offset then
          element_storage.selection_startoffset=element_storage.cursor_offset
        else
          element_storage.selection_endoffset=element_storage.cursor_offset
        end
      elseif element_storage.cursor_offset>=0 then
        element_storage.selection_startoffset=element_storage.cursor_offset
        element_storage.selection_endoffset=element_storage.cursor_offset
      end
    elseif mouse_cap&4==4 then
      local found=element_storage.cursor_offset
      for i=element_storage.cursor_offset-1, 0, -1 do
        if element_storage.Text:utf8_sub(i,i):has_alphanumeric_plus_underscore()==false or element_storage.Text:utf8_sub(i,i):has_alphanumeric_plus_underscore()~=element_storage.Text:utf8_sub(i+1,i+1):has_alphanumeric_plus_underscore() then
          found=i
          break
        end
      end
      if mouse_cap&8==8 then
        if element_storage.selection_startoffset>found then
          element_storage.selection_startoffset=found
        elseif element_storage.selection_endoffset>found then
          element_storage.selection_endoffset=found
        end
      end
      element_storage.cursor_offset=found
    end

    if element_storage.draw_offset>element_storage.cursor_offset then
      element_storage.draw_offset=element_storage.cursor_offset
      reagirl.Inputbox_Calculate_DrawOffset(true, element_storage)
    end
    
  elseif Key==30064 then
    -- up arrow key
    
  elseif Key==1685026670.0 then
    -- down arrow key
    
  elseif Key>=26161 and Key<=26169 then
    -- F1 through F9
  elseif Key>=6697264.0 and Key<=6697270.0 then 
    -- F10 through F16
  elseif Key==27 then
    -- esc Key
  elseif Key==9 then
    -- Tab Key
  elseif Key==1752132965.0 then
    -- Home Key
    element_storage.cursor_offset=0
    element_storage.draw_offset=element_storage.cursor_offset+1
    if mouse_cap&8==0 then
      element_storage.selection_startoffset=0
      element_storage.selection_endoffset=0
    elseif mouse_cap&8==8 then
      element_storage.selection_endoffset=element_storage.selection_startoffset
      element_storage.selection_startoffset=0
    end
    reagirl.Inputbox_Calculate_DrawOffset(true, element_storage)
  elseif Key==6647396.0 then
    -- End Key
    element_storage.cursor_offset=element_storage.Text:utf8_len()
    
    if mouse_cap&8==0 then
      element_storage.selection_startoffset=element_storage.cursor_offset
      element_storage.selection_endoffset=element_storage.Text:utf8_len()
    elseif mouse_cap&8==8 then
      element_storage.selection_startoffset=element_storage.selection_endoffset
      element_storage.selection_endoffset=element_storage.Text:utf8_len()
    end
    reagirl.Inputbox_ConsolidateCursorPos(element_storage)
  elseif Key==3 then
    -- Copy
    if reaper.CF_SetClipboard~=nil then
      reaper.CF_SetClipboard(element_storage.Text:utf8_sub(element_storage.selection_startoffset+1, element_storage.selection_endoffset))
    end
  elseif Key==24 then
    -- Cut
    if reaper.CF_SetClipboard~=nil then
      reaper.CF_SetClipboard(element_storage.Text:utf8_sub(element_storage.selection_startoffset+1, element_storage.selection_endoffset))
      if element_storage.selection_startoffset~=element_storage.selection_endoffset then
         element_storage.Text=element_storage.Text:utf8_sub(1, element_storage.selection_startoffset)..element_storage.Text:utf8_sub(element_storage.selection_endoffset+1, -1)
         element_storage.cursor_offset=element_storage.selection_startoffset
         element_storage.selection_startoffset=element_storage.cursor_offset
         element_storage.selection_endoffset=element_storage.cursor_offset
      end
    end
  elseif Key==22 then
    -- Paste Cmd+V
    if reaper.CF_GetClipboard~=nil then
      local text=string.gsub(reaper.CF_GetClipboard(), "\n", "")
      text=string.gsub(text, "\r", "")
      element_storage.Text=element_storage.Text:utf8_sub(1, element_storage.selection_startoffset)..text..element_storage.Text:utf8_sub(element_storage.selection_endoffset+1, -1)
      element_storage.cursor_offset=element_storage.cursor_offset+text:utf8_len()
      element_storage.selection_startoffset=element_storage.cursor_offset
      element_storage.selection_endoffset=element_storage.cursor_offset
      reagirl.Inputbox_ConsolidateCursorPos(element_storage)
      entered_text=text
    end
  elseif Key==6579564.0 then
    -- Del Key
    if element_storage.selection_startoffset~=element_storage.selection_endoffset then
      --print2("1")
      element_storage.Text=element_storage.Text:utf8_sub(0, element_storage.selection_startoffset)..element_storage.Text:utf8_sub(element_storage.selection_endoffset+1, -1)
      element_storage.cursor_offset=element_storage.selection_startoffset
      element_storage.selection_startoffset=element_storage.cursor_offset
      element_storage.selection_endoffset=element_storage.cursor_offset
    else
      --print2("2")
      element_storage.Text=element_storage.Text:utf8_sub(1, element_storage.selection_startoffset)..element_storage.Text:utf8_sub(element_storage.selection_endoffset+2, -1)
    end
    reagirl.Inputbox_ConsolidateCursorPos(element_storage)
  elseif Key==1 then
    element_storage.cursor_offset=element_storage.Text:utf8_len()
    element_storage.selection_startoffset=0
    element_storage.selection_endoffset=element_storage.cursor_offset
    reagirl.Inputbox_ConsolidateCursorPos(element_storage)
  elseif Key~=0 then
    element_storage.Text=element_storage.Text:utf8_sub(1, element_storage.selection_startoffset)..utf8.char(Key)..element_storage.Text:utf8_sub(element_storage.selection_endoffset+1, -1)
    element_storage.cursor_offset=element_storage.selection_startoffset+1
    element_storage.selection_startoffset=element_storage.cursor_offset
    element_storage.selection_endoffset=element_storage.cursor_offset

    reagirl.Inputbox_ConsolidateCursorPos(element_storage)
    reagirl.Inputbox_Calculate_DrawOffset(true, element_storage)
    entered_text=utf8.char(Key)
  end
  
  if Key>0 then 
    if element_storage["run_function_type"]~=nil and Key~=13 then
      element_storage["run_function_type"](element_storage["Guid"], element_storage.Text, entered_text)
    end
    refresh=true 
  end
  
  return refresh
end

function reagirl.Inputbox_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  local refresh=false
  local run_function=false
  -- drop files for accessibility using a file-requester, after typing ctrl+shift+f
  if element_storage["DropZoneFunction"]~=nil and Key==6 and mouse_cap==12 then
    local retval, filenames = reaper.GetUserFileNameForRead("", "Choose file to drop into "..element_storage["Name"], "")
    reagirl.Window_SetFocus()
    if retval==true then element_storage["DropZoneFunction"](element_storage["Guid"], {filenames}) refresh=true end
  end  
  
  local Cap_width=element_storage.Cap_width
  
  if hovered==true then
    if gfx.mouse_x>=x+Cap_width then
      if selected=="not selected" and gfx.mouse_cap==0 then
        gfx.setcursor(101)
      elseif selected~="not selected" then
        gfx.setcursor(101)
      end
    else
      gfx.setcursor(1)
    end
  end
  local entered_character=""
  local blink_refresh=false
  
  if element_storage["linked_to"]~=0 then
    if element_storage["linked_to"]==1 then
      local val=reaper.GetExtState(element_storage["linked_to_section"], element_storage["linked_to_key"])
      if val=="" then val=element_storage["linked_to_default"] refresh=true end
      if element_storage["Text"]~=val then 
        element_storage["Text"]=val 
        reagirl.Inputbox_Calculate_DrawOffset(true, element_storage) 
        element_storage["selection_endoffset"]=element_storage["cursor_offset"] 
        element_storage["selection_startoffset"]=element_storage["cursor_offset"] 
        reagirl.Gui_ForceRefresh() 
      end
    elseif element_storage["linked_to"]==2 then
      local retval, val = reaper.BR_Win32_GetPrivateProfileString(element_storage["linked_to_section"], element_storage["linked_to_key"], "", element_storage["linked_to_ini_file"])
      if val=="" then val=element_storage["linked_to_default"] refresh=true end
      if element_storage["Text"]~=val then 
        element_storage["Text"]=val 
        reagirl.Inputbox_Calculate_DrawOffset(true, element_storage) 
        element_storage["selection_endoffset"]=element_storage["cursor_offset"] 
        element_storage["selection_startoffset"]=element_storage["cursor_offset"] 
        reagirl.Gui_ForceRefresh() 
      end
    elseif element_storage["linked_to"]==3 then
      local retval, val=reaper.get_config_var_string(element_storage["linked_to_configvar"])

      if element_storage["Text"]~=val then 
        element_storage["Text"]=val 
        reagirl.Inputbox_Calculate_DrawOffset(true, element_storage) 
        element_storage["selection_endoffset"]=element_storage["cursor_offset"] 
        element_storage["selection_startoffset"]=element_storage["cursor_offset"] 
        reagirl.Gui_ForceRefresh() 
      end
      if element_storage["linked_to_persist"]==true then
        reaper.BR_Win32_WritePrivateProfileString("REAPER", element_storage["linked_to_configvar"], val, reaper.get_ini_file())
      end
    end
  end
  --]]
  
  if reagirl.osara_outputMessage~=nil and selected~="not selected" then
    reagirl.Gui_PreventEnterForOneCycle()
    if selected~="not selected" and (Key==13 or (mouse_cap&1==1 and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h)) then      
      local retval, text = reaper.GetUserInputs("Enter or edit the text", 1, element_storage["password"]..",extrawidth=150", element_storage.Text)
      reagirl.Window_SetFocus_Trigger=true
      --element_storage.draw_offset=1
      --reagirl.Inputbox_Calculate_DrawOffset(true, element_storage)
      if retval==true then
        refresh=true
        element_storage.Text=text
        reagirl.Inputbox_Calculate_DrawOffset(true, element_storage)
        if element_storage["run_function"]~=nil then
          element_storage["run_function"](element_storage["Guid"], element_storage.Text)
        end
      end
    end
  else
    if selected~="not selected" then
      element_storage["blink"]=element_storage["blink"]+1
      if reagirl.Window_State&2==2 then
        element_storage["continue_blink"]=true
        if element_storage["blink"]>reagirl.Inputbox_BlinkSpeed then element_storage["blink"]=0 end
        if element_storage["blink"]==(reagirl.Inputbox_BlinkSpeed>>1)+4 or element_storage["blink"]==1 then refresh=true end
      elseif element_storage["continue_blink"]==true and reagirl.Window_State&2==0 then
        element_storage["blink"]=0
        element_storage["continue_blink"]=false
        refresh=true
      end
       
    else
      element_storage["blink"]=0
    end
    if element_storage["run_function"]~=nil and selected~="not selected" then
      reagirl.Gui_PreventEnterForOneCycle()
    end
    if selected=="not selected" then
      element_storage.hasfocus=false
    end
    if element_storage.cursor_offset==-1 and clicked~="DBLCLK" then 
      element_storage.cursor_offset=element_storage.Text:utf8_len() 
    end
    
    if selected=="first selected" then      
      element_storage["cursor_offset"]=element_storage["Text"]:utf8_len()
      element_storage["draw_offset_end"]=element_storage["Text"]:utf8_len()
      element_storage["selection_endoffset"]=element_storage["Text"]:utf8_len()
      element_storage["selection_startoffset"]=0
      reagirl.Inputbox_Calculate_DrawOffset(true, element_storage)
      element_storage.hasfocus=true
    elseif selected=="not selected" then
      element_storage["selection_endoffset"]=element_storage["cursor_offset"]
      element_storage["selection_startoffset"]=element_storage["cursor_offset"]
    end
    gfx.setfont(1, "Arial", reagirl.Font_Size, 0)
  
    
    if selected~="not selected" and mouse_cap==1 and (gfx.mouse_x>=x and gfx.mouse_y>=y and gfx.mouse_x<=x+w and gfx.mouse_y<=y+h) then 
      -- mousewheel scroll the text inside the input-box via hmousewheel(doesn't work properly, yet)
      reagirl.Gui_PreventScrollingForOneCycle(true, true, false)
      if mouse_attributes[6]>0 then 
        if mouse_attributes[6]>-300 then factor=10 else factor=1 end  
        element_storage["draw_offset"]=element_storage["draw_offset"]-factor
        if element_storage["draw_offset"]<1 then 
          element_storage["draw_offset"]=1 
        end 
        refresh=true 
        reagirl.Inputbox_Calculate_DrawOffset(true, element_storage)
      end
      
      if mouse_attributes[6]<0 then 
        if mouse_attributes[6]<300 then factor=10 else factor=1 end
        element_storage["draw_offset"]=element_storage["draw_offset"]+factor
        if element_storage["draw_offset"]>element_storage["Text"]:utf8_len() then 
          element_storage["draw_offset"]=element_storage["Text"]:utf8_len()
        end 
        refresh=true 
        reagirl.Inputbox_Calculate_DrawOffset(true, element_storage)
      end
      element_storage.x2=x
      element_storage.y2=y
      element_storage.w2=w
      element_storage.h2=h
      refreshme=clicked
      -- mouse management
      if selected~="not selected" and clicked=="FirstCLK" and mouse_cap==1 then 
        element_storage["hasfocus"]=true
        if reagirl.mouse.down==false then 
          reagirl.Inputbox_OnMouseDown(mouse_cap, element_storage) 
          refresh=true
        end
      elseif selected~="not selected" and clicked=="DBLCLK" and mouse_cap==1 then
        reagirl.Inputbox_OnMouseDoubleClick(mouse_cap, element_storage)
        refresh=true
        element_storage["hasfocus"]=true
      elseif selected~="not selected" and reagirl.mouse.down==true and mouse_cap==1 then
        reagirl.Inputbox_OnMouseUp(mouse_cap, element_storage)
        refresh=true
        element_storage["hasfocus"]=true
      end
    end
    -- keyboard management
    if element_storage.hasfocus==true then
      local refresh2
      refresh2, entered_character=reagirl.Inputbox_OnTyping(Key, Key_UTF, mouse_cap, element_storage)
      if refresh~=true and refresh2==true then
        refresh=true
        run_function=true 
      end
    end
  end
  if selected~="not selected" and element_storage.clicked1==true and clicked=="DRAG" then --reagirl.mouse.down==true and clicked=="DRAG" then gfx.mouse_x~=reagirl.mouse.x or gfx.mouse_y~=reagirl.mouse.y then
    reagirl.Inputbox_OnMouseMove(mouse_cap, element_storage)
    refresh=true
    element_storage["hasfocus"]=true
  end
  
  if mouse_cap==0 then
    element_storage.clicked1=nil
  end
  
  if element_storage.w2_old~=w then
    if element_storage.draw_offset<element_storage.cursor_offset then
      reagirl.Inputbox_Calculate_DrawOffset(false, element_storage)
    else
      reagirl.Inputbox_Calculate_DrawOffset(true, element_storage)
    end
    refresh=true
  end
  element_storage.w2_old=w
  element_storage["AccHoverMessage"]=element_storage["Name"].." "..element_storage["Text"]
  
  if refresh==true then
    if element_storage["linked_to"]~=0 then
      if element_storage["linked_to"]==1 then
        reaper.SetExtState(element_storage["linked_to_section"], element_storage["linked_to_key"], element_storage["Text"], element_storage["linked_to_persist"])
      elseif element_storage["linked_to"]==2 then
        local retval, val = reaper.BR_Win32_WritePrivateProfileString(element_storage["linked_to_section"], element_storage["linked_to_key"], element_storage["Text"], element_storage["linked_to_ini_file"])
      elseif element_storage["linked_to"]==3 then
        reaper.SNM_SetStringConfigVar(element_storage["linked_to_configvar"], element_storage["Text"])
      end
    end
  end
  
  if refresh==true then
    reagirl.Gui_ForceRefresh(23)
  end
  return element_storage["Text"].." "
end

function reagirl.Inputbox_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  local dpi_scale=reagirl.Window_GetCurrentScale()
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  y=y+dpi_scale
  local cap_w
  if element_storage["Cap_width"]==nil then
    cap_w=gfx.measurestr(element_storage["Name"])
    cap_w=math.tointeger(cap_w)+dpi_scale*5
  else
    cap_w=element_storage["Cap_width"]*dpi_scale
  end
  cap_w=cap_w+dpi_scale
  
  -- draw caption
  gfx.x=x+dpi_scale
  gfx.y=y+dpi_scale--+dpi_scale+(h-gfx.texth)/2
  gfx.set(0.2)
  gfx.drawstr(name)
  
  if element_storage["IsDisabled"]==false then gfx.set(0.8) else gfx.set(0.6) end
  gfx.x=x
  gfx.y=y--+(h-gfx.texth)/2
  gfx.drawstr(name)
  
  local textw=gfx.measurechar("65")-1
  
  -- draw rectangle around text
  gfx.set(0.45)
  reagirl.RoundRect(x+cap_w-dpi_scale, y-dpi_scale-dpi_scale, w-cap_w+dpi_scale+dpi_scale, h+dpi_scale+dpi_scale+dpi_scale, 2*dpi_scale-1, 0, 1)
  
  gfx.set(0.234)
  reagirl.RoundRect(x+cap_w, y-dpi_scale, w-cap_w, h+dpi_scale, dpi_scale-1, 0, 1)
  
  
  -- draw text
  if element_storage["IsDisabled"]==false then gfx.set(0.8) else gfx.set(0.6) end
  gfx.x=x+cap_w+dpi_scale+dpi_scale+dpi_scale
  
  gfx.y=y--+(h-gfx.texth)/2
  if element_storage["Text"]:len()==0 then
    gfx.set(0.6)
    gfx.x=gfx.x+dpi_scale*5
    gfx.drawstr(element_storage["empty_text"],0, x+w, y+h)
    gfx.set(0.8)
  end
  local draw_offset=0
  
  for i=element_storage.draw_offset, element_storage.draw_offset_end do
    if i>element_storage.Text:utf8_len() then break end
    local textw
    if element_storage["password"]=="*" then
      textw=gfx.measurestr("*")
    else
      textw=gfx.measurestr(element_storage.Text:utf8_sub(i,i))
    end
    if draw_offset+textw>w then break end
    if i>=element_storage.selection_startoffset+1 and i<=element_storage.selection_endoffset then
      reagirl.SetFont(1, "Arial", reagirl.Font_Size, 86)
    else
      reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
    end
    if element_storage["password"]=="*" then
      gfx.drawstr("*")
    else
      gfx.drawstr(element_storage.Text:utf8_sub(i,i))
    end
    
    if selected~="not selected" and element_storage.hasfocus==true and element_storage.cursor_offset==i then 
      gfx.set(0.9843137254901961, 0.8156862745098039, 0)
      if element_storage["blink"]>0 and element_storage["blink"]<(reagirl.Inputbox_BlinkSpeed>>1)+4 then
        local y3=y+(h-gfx.texth)/3
        if reagirl.Window_State&2==2 then
          --gfx.line(gfx.x, y, gfx.x, y+gfx.texth-dpi_scale)
          gfx.rect(gfx.x, y+dpi_scale, dpi_scale, gfx.texth-dpi_scale-dpi_scale)
        end
      end
      if element_storage.hasfocus==true then gfx.set(0.8) else gfx.set(0.5) end
    end
    draw_offset=draw_offset+textw
  end
  if selected~="not selected" and element_storage.cursor_offset==element_storage.draw_offset-1 then
    gfx.set(0.9843137254901961, 0.8156862745098039, 0)
    --gfx.set(1,0,0)
    if reagirl.Window_State&2==2 and element_storage["blink"]>0 and element_storage["blink"]<(reagirl.Inputbox_BlinkSpeed>>1)+4 then
      --gfx.line(x+cap_w+dpi_scale+dpi_scale+dpi_scale, y+dpi_scale, x+cap_w+dpi_scale+dpi_scale+dpi_scale, y+gfx.texth-dpi_scale)
      gfx.rect(x+cap_w+dpi_scale+dpi_scale+dpi_scale, y+dpi_scale, dpi_scale, gfx.texth-dpi_scale-dpi_scale)
    end
  end
end

function reagirl.Inputbox_LinkToExtstate(element_id, section, key, default, persist)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Inputbox_LinkToExtstate</slug>
  <requires>
    ReaGirl=1.1
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Inputbox_LinkToExtstate(string element_id, string section, string key, string default, boolean persist)</functioncall>
  <description>
    Links an inputbox to an extstate. 
    
    All changes to the extstate will be immediately visible for this inputbox.
    
    If the inputbox was already linked to a config-var or ini-file, the linked-state will be replaced by this new one.
    Use reagirl.Inputbox_UnLink() to unlink the inputbox from extstate/ini-file/config var.
  </description>
  <parameters>
    string element_id - the guid of the inputbox, that you want to link to an extstate
    string section - the section of the linked extstate
    string key - the key of the linked extstate
    string default - the default value, if the extstate hasn't been set yet
    boolean persist - true, the extstate shall be stored persistantly; false, the extstate shall not be stored persistantly
  </parameters>
  <chapter_context>
    Inputbox
  </chapter_context>
  <tags>inputbox, link to, extstate</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Inputbox_LinkToExtstate: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Inputbox_LinkToExtstate: param #1 - must be a valid guid", 2) end
  if type(section)~="string" then error("Inputbox_LinkToExtstate: param #2 - must be a string", 2) end
  if type(key)~="string" then error("Inputbox_LinkToExtstate: param #3 - must be a string", 2) end
  if type(default)~="string" then error("Inputbox_LinkToExtstate: param #4 - must be a string", 2) end
  if type(persist)~="boolean" then error("Inputbox_LinkToExtstate: param #5 - must be a boolean", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Inputbox_LinkToExtstate: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Edit" then
    error("Inputbox_LinkToExtstate: param #1 - ui-element is not a inputbox", 2)
  else
    reagirl.Elements[element_id]["linked_to"]=1
    reagirl.Elements[element_id]["linked_to_section"]=section
    reagirl.Elements[element_id]["linked_to_key"]=key
    reagirl.Elements[element_id]["linked_to_default"]=default
    reagirl.Elements[element_id]["linked_to_persist"]=persist
    reagirl.Gui_ForceRefresh(16)
  end
end

function reagirl.Inputbox_LinkToIniFile(element_id, ini_file, section, key, default, persist)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Inputbox_LinkToIniFile</slug>
  <requires>
    ReaGirl=1.1
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Inputbox_LinkToIniFile(string element_id, string ini_file, string section, string key, string default, boolean persist)</functioncall>
  <description>
    Links an inputbox to an ini-file-entry. 
    
    All changes to the ini-file-entry will be immediately visible for this inputbox.
    Entering text into the inputbox also updates the ini-file-entry immediately.
    
    If the inputbox was already linked to a config-var or extstate, the linked-state will be replaced by this new one.
    Use reagirl.Inputbox_UnLink() to unlink the inputbox from extstate/ini-file/config var.
  </description>
  <parameters>
    string element_id - the guid of the inputbox, that you want to link to an extstate
    string ini_file - the filename of the ini-file, whose value you want to link to this slider
    string section - the section of the linked ini-file
    string key - the key of the linked ini-file
    string default - the default value, if the ini-file hasn't been set yet
    boolean persist - true, the ini-file shall be stored persistantly; false, the ini-file shall not be stored persistantly
  </parameters>
  <chapter_context>
    Inputbox
  </chapter_context>
  <tags>inputbox, link to, ini-file</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Inputbox_LinkToIniFile: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Inputbox_LinkToIniFile: param #1 - must be a valid guid", 2) end
  if type(ini_file)~="string" then error("Inputbox_LinkToIniFile: param #2 - must be a string", 2) end
  if type(section)~="string" then error("Inputbox_LinkToIniFile: param #3 - must be a string", 2) end
  if type(key)~="string" then error("Inputbox_LinkToIniFile: param #4 - must be a string", 2) end
  if type(default)~="string" then error("Inputbox_LinkToIniFile: param #5 - must be a string", 2) end

  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Inputbox_LinkToIniFile: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Edit" then
    error("Inputbox_LinkToIniFile: param #1 - ui-element is not a inputbox", 2)
  else
    reagirl.Elements[element_id]["linked_to"]=2
    reagirl.Elements[element_id]["linked_to_ini_file"]=ini_file
    reagirl.Elements[element_id]["linked_to_section"]=section
    reagirl.Elements[element_id]["linked_to_key"]=key
    reagirl.Elements[element_id]["linked_to_default"]=default
    reagirl.Elements[element_id]["linked_to_persist"]=persist
    reagirl.Gui_ForceRefresh(16)
  end
end

function reagirl.Inputbox_LinkToConfigVar(element_id, configvar_name, persist)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Inputbox_LinkToConfigVar</slug>
  <requires>
    ReaGirl=1.1
    Reaper=7.03
    SWS=2.10.0.1
    Lua=5.4
  </requires>
  <functioncall>reagirl.Inputbox_LinkToConfigVar(string element_id, string configvar_name, boolean persist)</functioncall>
  <description>
    Links an inputbox to a configvar. 
    
    All changes to the configvar will be immediately visible for this inputbox.
    Entering text also updates the configvar-bit immediately.
    
    Note: this will only allow string config-variables. All others could cause malfunction of Reaper!
    
    Read the Reaper Internals-docs for all available config-variables(run the action ultraschall_Help_Reaper_ConfigVars_Documentation.lua for more details)
    
    If the inputbox was already linked to extstate or ini-file, the linked-state will be replaced by this new one.
    Use reagirl.Inputbox_Unlink() to unlink the inputbox from extstate/ini-file/config var.
  </description>
  <parameters>
    string element_id - the guid of the inputbox that shall set a config-var
    string configvar_name - the config-variable, whose value you want to update using the slider
    boolean persist - true, make this setting persist; false, make this setting only temporary until Reaper restart
  </parameters>
  <chapter_context>
    Inputbox
  </chapter_context>
  <tags>inputbox, link to, double, config variable</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Inputbox_LinkToConfigVar: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Inputbox_LinkToConfigVar: param #1 - must be a valid guid", 2) end
  if type(configvar_name)~="string" then error("Inputbox_LinkToConfigVar: param #2 - must be a string", 2) end
  if type(persist)~="boolean" then error("Inputbox_LinkToConfigVar: param #3 - must be a boolean", 2) end
  
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Inputbox_LinkToConfigVar: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Edit" then
    error("Inputbox_LinkToConfigVar: param #1 - ui-element is not a inputbox", 2)
  else
    reagirl.Elements[element_id]["linked_to"]=3
    reagirl.Elements[element_id]["linked_to_configvar"]=configvar_name
    reagirl.Elements[element_id]["linked_to_persist"]=persist
    reagirl.Gui_ForceRefresh(16)
  end
end

function reagirl.Inputbox_Unlink(element_id, section, key, default, persist)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Inputbox_Unlink</slug>
  <requires>
    ReaGirl=1.1
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Inputbox_Unlink(string element_id)</functioncall>
  <description>
    Unlinks an inputbox from extstate/ini-file/configvar. 
  </description>
  <parameters>
    string element_id - the guid of the inputbox, that you want to unlink from an extstate/inifile-entry/configvar
  </parameters>
  <chapter_context>
    Inputbox
  </chapter_context>
  <tags>inputbox, unlink</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Inputbox_Unlink: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Inputbox_Unlink: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Inputbox_Unlink: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Edit" then
    error("Inputbox_Unlink: param #1 - ui-element is not a inputbox", 2)
  else
    reagirl.Elements[element_id]["linked_to"]=0
    reagirl.Gui_ForceRefresh(16)
  end
end

function reagirl.Inputbox_Calculate_DrawOffset(forward, element_storage)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  local dpi_scale = reagirl.Window_GetCurrentScale()
  local cap_w, x2, w2
  if element_storage["Cap_width"]==nil then
    cap_w=gfx.measurestr(element_storage["Name"])+dpi_scale*5
  else
    cap_w=element_storage["Cap_width"]*dpi_scale
    cap_w=cap_w+dpi_scale
  end
  
  if element_storage["x"]<0 then x2=gfx.w+element_storage["x"]*dpi_scale else x2=element_storage["x"]*dpi_scale end
  if element_storage["w"]<0 then w2=gfx.w-x2+element_storage["w"]*dpi_scale else w2=element_storage["w"]*dpi_scale end
  local w2=w2-cap_w
  local offset_me=dpi_scale*2
  
  if forward==true then
    -- forward calculation from offset
    for i=element_storage.draw_offset, element_storage.Text:utf8_len() do
      local x,y
      if element_storage["password"]=="*" then
        x,y=gfx.measurestr("*")
      else
        x,y=gfx.measurestr(element_storage.Text:utf8_sub(i,i))
      end
      --local x,y=gfx.measurestr(element_storage.Text:utf8_sub(i,i))
      offset_me=offset_me+x
      if offset_me>w2 then break else element_storage.draw_offset_end=i end
    end
  elseif forward==false then
    -- backwards calculation from offset_end
    for i=element_storage.draw_offset_end, 1, -1 do
      local x,y
      if element_storage["password"]=="*" then
        x,y=gfx.measurestr("*")
      else
        x,y=gfx.measurestr(element_storage.Text:utf8_sub(i,i))
      end
      --local x,y=gfx.measurestr(element_storage.Text:utf8_sub(i,i))
      offset_me=offset_me+x
      if offset_me>w2 then break else element_storage.draw_offset=i end
    end
  end
end


function reagirl.Inputbox_SetDisabled(element_id, state)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Inputbox_SetDisabled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Inputbox_SetDisabled(string element_id, boolean state)</functioncall>
  <description>
    Sets an inputbox as disabled(non clickable).
  </description>
  <parameters>
    string element_id - the guid of the inputbox, whose disability-state you want to set
    boolean state - true, the inputbox is disabled; false, the inputbox is not disabled.
  </parameters>
  <chapter_context>
    Inputbox
  </chapter_context>
  <tags>inputbox, set, disabled</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Inputbox_SetDisabled: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Inputbox_SetDisabled: param #1 - must be a valid guid", 2) end
  if type(state)~="boolean" then error("Inputbox_SetDisabled: param #2 - must be a boolean", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Inputbox_SetDisabled: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Edit" then
    error("Inputbox_SetDisabled: param #1 - ui-element is not an input-box", 2)
  else
    reagirl.Elements[element_id]["IsDisabled"]=state
    reagirl.Gui_ForceRefresh(24)
  end
end

function reagirl.Inputbox_GetDisabled(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Inputbox_GetDisabled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>boolean state = reagirl.Inputbox_GetDisabled(string element_id)</functioncall>
  <description>
    Gets an inputbox's disabled(non clickable)-state.
  </description>
  <parameters>
    string element_id - the guid of the inputbox, whose disability-state you want to get
  </parameters>
  <retvals>
    boolean state - true, the inputbox is disabled; false, the inputbox is not disabled.
  </retvals>
  <chapter_context>
    Inputbox
  </chapter_context>
  <tags>inputbox, get, disabled</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Inputbox_GetDisabled: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Inputbox_GetDisabled: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Inputbox_GetDisabled: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Edit" then
    error("Inputbox_GetDisabled: param #1 - ui-element is not an input-box", 2)
  else
    return reagirl.Elements[element_id]["IsDisabled"]
  end
end

function reagirl.Inputbox_SetText(element_id, new_text)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Inputbox_SetText</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Inputbox_SetText(string element_id, string new_text)</functioncall>
  <description>
    Sets a new text of an inputbox.
    
    Will remove newlines from it.
  </description>
  <parameters>
    string element_id - the guid of the inputbox, whose disability-state you want to set
    string new_text - the new text for the inputbox
  </parameters>
  <chapter_context>
    Inputbox
  </chapter_context>
  <tags>inputbox, set, text</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Inputbox_SetText: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Inputbox_SetText: param #1 - must be a valid guid", 2) end
  if type(new_text)~="string" then error("Inputbox_SetText: param #2 - must be a string", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Inputbox_SetText: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Edit" then
    error("Inputbox_SetText: param #1 - ui-element is not an input-box", 2)
  else
    new_text=string.gsub(new_text, "\n", "")
    new_text=string.gsub(new_text, "\r", "")
    reagirl.Elements[element_id]["Text"]=new_text
    reagirl.Elements[element_id]["cursor_offset"]=reagirl.Elements[element_id]["Text"]:utf8_len()
    reagirl.Elements[element_id]["draw_offset_end"]=reagirl.Elements[element_id]["cursor_offset"]
    reagirl.Inputbox_Calculate_DrawOffset(false, reagirl.Elements[element_id])
    
    reagirl.Elements[element_id]["selection_endoffset"]=reagirl.Elements[element_id]["cursor_offset"]
    reagirl.Elements[element_id]["selection_startoffset"]=reagirl.Elements[element_id]["cursor_offset"]
    reagirl.Gui_ForceRefresh(25)
  end
end

function reagirl.Inputbox_GetText(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Inputbox_GetText</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>string text = reagirl.Inputbox_GetText(string element_id)</functioncall>
  <description>
    Gets an inputbox's current text.
  </description>
  <parameters>
    string element_id - the guid of the inputbox, whose text you want to get
  </parameters>
  <retvals>
    string text - the text currently in the inputbox
  </retvals>
  <chapter_context>
    Inputbox
  </chapter_context>
  <tags>inputbox, get, text</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Inputbox_GetText: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Inputbox_GetText: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Inputbox_GetText: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Edit" then
    error("Inputbox_GetText: param #1 - ui-element is not an input-box", 2)
  else
    return reagirl.Elements[element_id]["Text"]
  end
end

function reagirl.Inputbox_SetEmptyText(element_id, empty_text)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Inputbox_SetEmptyText</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>string text = reagirl.Inputbox_SetEmptyText(string element_id, string empty_text)</functioncall>
  <description>
    Sets an inputbox's shown text when nothing has been input.
  </description>
  <parameters>
    string element_id - the guid of the inputbox, whose text you want to get
  </parameters>
  <retvals>
    string empty_text - a text that is shown, when nothing has been input
  </retvals>
  <chapter_context>
    Inputbox
  </chapter_context>
  <tags>inputbox, set, empty text</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Inputbox_SetEmptyText: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Inputbox_SetEmptyText: param #1 - must be a valid guid", 2) end
  if type(empty_text)~="string" then error("Inputbox_SetEmptyText: param #2 - must be a string", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Inputbox_SetEmptyText: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Edit" then
    error("Inputbox_SetEmptyText: param #1 - ui-element is not an input-box", 2)
  else
    reagirl.Elements[element_id]["empty_text"]=empty_text
  end
end

function reagirl.Inputbox_GetSelectedText(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Inputbox_GetSelectedText</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>string text = reagirl.Inputbox_GetSelectedText(string element_id)</functioncall>
  <description>
    Gets an inputbox's currently selected text.
  </description>
  <parameters>
    string element_id - the guid of the inputbox, whose selected text you want to get
  </parameters>
  <retvals>
    string text - the text currently selected in the inputbox
    integer selection_startoffset - the startoffset of the text-selection; -1, no text is selected
    integer selection_endoffset - the endoffset of the text-selection; -1, no text is selected
  </retvals>
  <chapter_context>
    Inputbox
  </chapter_context>
  <tags>inputbox, get, selected, text</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Inputbox_GetSelectedText: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Inputbox_GetSelectedText: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Inputbox_SetSelectedText: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Edit" then
    error("Inputbox_GetSelectedText: param #1 - ui-element is not an input-box", 2)
  else
    if reagirl.Elements[element_id]["selection_startoffset"]~=reagirl.Elements[element_id]["selection_endoffset"] then
      return reagirl.Elements[element_id]["Text"]:utf8_sub(reagirl.Elements[element_id]["selection_startoffset"]+1, reagirl.Elements[element_id]["selection_endoffset"]), reagirl.Elements[element_id]["selection_startoffset"], reagirl.Elements[element_id]["selection_endoffset"]
    else
      return "", -1, -1
    end
  end
end

function reagirl.Inputbox_GetCursorOffset(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Inputbox_GetCursorOffset</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer cursor_offset = reagirl.Inputbox_GetCursorOffset(string element_id)</functioncall>
  <description>
    Gets an inputbox's current cursor offset.
  </description>
  <parameters>
    string element_id - the guid of the inputbox, whose cursor offset you want to get
  </parameters>
  <retvals>
    integer cursor_offset - the offset the cursor has in the current text in the inputbox
  </retvals>
  <chapter_context>
    Inputbox
  </chapter_context>
  <tags>inputbox, get, cursor offset</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Inputbox_GetCursorOffset: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Inputbox_GetCursorOffset: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Inputbox_GetCursorOffset: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Edit" then
    error("Inputbox_GetCursorOffset: param #1 - ui-element is not an input-box", 2)
  else
    return reagirl.Elements[element_id]["cursor_offset"]
  end
end



function reagirl.DropDownMenu_Add(x, y, w, caption, Cap_width, meaningOfUI_Element, menuItems, menuSelectedItem, run_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DropDownMenu_Add</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>string dropdown-menu_guid = reagirl.DropDownMenu_Add(optional integer x, optional integer y, integer w, string caption, optional integer Cap_width, string meaningOfUI_Element, table menuItems, integer menuSelectedItem, optional function run_function)</functioncall>
  <description>
    Adds a dropdown-menu to a gui.
    
    You can autoposition the dropdown-menu by setting x and/or y to nil, which will position the new dropdown-menu after the last ui-element.
    To autoposition into the next line, use reagirl.NextLine()
    
    The run-function gets as parameters:
    - string element_id - the element_id
    - integer selected_menu_entry - the selected menu entry number
    - string selected_menu_entry_name - the name of the selected menu entry
  </description>
  <parameters>
    optional integer x - the x position of the dropdown-menu in pixels; negative anchors the dropdown-menu to the right window-side; nil, autoposition after the last ui-element(see description)
    optional integer y - the y position of the dropdown-menu in pixels; negative anchors the dropdown-menu to the bottom window-side; nil, autoposition after the last ui-element(see description)
    integer w - the width of the dropdown-menu; negative links width to the right-edge of the window
    string caption - the caption of the dropdown-menu, shown to the left of the drop down menu
    optional integer Cap_width - the width of the caption to set the actual menu to a fixed position; nil, put menu directly after caption
    string meaningOfUI_Element - the meaningOfUI_Element of the ui-element(for tooltips and blind users). Make it a sentence that ends with . or ?
    table menuItems - a table, where every entry is a menu-item
    integer menuSelectedItem - the index of the pre-selected menu-item
    optional function run_function - a function that shall be run when the menu is clicked/a new entry is selected; will get the dropdown-menu-element_id passed over as first parameter and the selected menu_item as second parameter
  </parameters>
  <retvals>
    string dropdown-menu_guid - a guid that can be used for altering the dropdown-menu-attributes
  </retvals>
  <chapter_context>
    DropDown Menu
  </chapter_context>
  <tags>dropdown menu, add</tags>
</US_DocBloc>
--]]
  if x~=nil and math.type(x)~="integer" then error("DropDownMenu_Add: param #1 - must be either nil or an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("DropDownMenu_Add: param #2 - must be either nil or an integer", 2) end
  if math.type(w)~="integer" then error("DropDownMenu_Add: param #3 - must be an integer", 2) end
  if type(caption)~="string" then error("DropDownMenu_Add: param #4 - must be a string", 2) end
  caption=string.gsub(caption, "[\n\r]", "")
  if Cap_width~=nil and math.type(Cap_width)~="integer" then error("DropDownMenu_Add: param #5 - must be either nil or an integer", 2) end
  if type(meaningOfUI_Element)~="string" then error("DropDownMenu_Add: param #6 - must be a string", 2) end
  if meaningOfUI_Element:sub(-1,-1)~="." and meaningOfUI_Element:sub(-1,-1)~="?" then error("DropDownMenu_Add: param #6 - must end on a . like a regular sentence.", 2) end
  if type(menuItems)~="table" then error("DropDownMenu_Add: param #7 - must be a table", 2) end
  for i=1, #menuItems do
    menuItems[i]=tostring(menuItems[i])
    menuItems[i]=string.gsub(menuItems[i], "[\n\r]", "")
  end
  if math.type(menuSelectedItem)~="integer" then error("DropDownMenu_Add: param #8 - must be an integer", 2) end
  if menuSelectedItem>#menuItems or menuSelectedItem<1 then error("DropDownMenu_Add: param #9 - no such menu-item", 2) end
  if run_function~=nil and type(run_function)~="function" then error("DropDownMenu_Add: param #10 - must be either nil or a function", 2) end
  
  local x,y,slot=reagirl.UI_Element_GetNextXAndYPosition(x, y, "DropDownMenu_Add")
  --reagirl.UI_Element_NextX_Default=x
  
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0, 1)
  local tx1, ty1 =gfx.measurestr(caption)
  if Cap_width==nil then Cap_width=tx1+5 end
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  
  table.insert(reagirl.Elements, slot, {})
  reagirl.Elements[slot]["Guid"]=reaper.genGuid("")
  reagirl.Elements[slot]["GUI_Element_Type"]="ComboBox"
  reagirl.Elements[slot]["Name"]=caption
  reagirl.Elements[slot]["Text"]=menuItems[menuSelectedItem]
  reagirl.Elements[slot]["Description"]=meaningOfUI_Element
  reagirl.Elements[slot]["IsDisabled"]=false
  reagirl.Elements[slot]["AccHint"]="Select via arrow-keys."
  reagirl.Elements[slot]["ContextMenu_ACC"]=""
  reagirl.Elements[slot]["DropZoneFunction_ACC"]=""
  reagirl.Elements[slot]["cap_w"]=math.tointeger(tx1)+5
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["w"]=w
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0, 1)
  local tx,ty=gfx.measurestr(menuItems[menuSelectedItem])
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  reagirl.Elements[slot]["h"]=math.tointeger(ty)--math.tointeger(gfx.texth)
  if math.tointeger(ty)>reagirl.NextLine_Overflow then reagirl.NextLine_Overflow=math.tointeger(ty) end
  reagirl.Elements[slot]["radius"]=2
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false
  reagirl.Elements[slot]["menuSelectedItem"]=menuSelectedItem
  reagirl.Elements[slot]["MenuEntries"]=menuItems
  reagirl.Elements[slot]["MenuCount"]=1
  reagirl.Elements[slot]["MenuCount"]=#menuItems
  reagirl.Elements[slot]["func_manage"]=reagirl.DropDownMenu_Manage
  reagirl.Elements[slot]["func_draw"]=reagirl.DropDownMenu_Draw
  reagirl.Elements[slot]["run_function"]=run_function
  reagirl.Elements[slot]["Cap_width"]=math.floor(Cap_width)
  reagirl.Elements[slot]["userspace"]={}
  return  reagirl.Elements[slot]["Guid"]
end


function reagirl.DropDownMenu_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  -- drop files for accessibility using a file-requester, after typing ctrl+shift+f
  if element_storage["DropZoneFunction"]~=nil and Key==6 and mouse_cap==12 then
    local retval, filenames = reaper.GetUserFileNameForRead("", "Choose file to drop into "..element_storage["Name"], "")
    reagirl.Window_SetFocus()
    if retval==true then element_storage["DropZoneFunction"](element_storage["Guid"], {filenames}) refresh=true end
  end
  
  local cap_w=element_storage["cap_w"]
  if element_storage["Cap_width"]~=nil then
    cap_w=element_storage["Cap_width"]
  end
  cap_w=cap_w*reagirl.Window_GetCurrentScale()

  if w<50 then w=50 end
  local refresh=false
  
  if element_storage["linked_to"]~=0 then
    if element_storage["linked_to"]==1 then
      local val=reaper.GetExtState(element_storage["linked_to_section"], element_storage["linked_to_key"])
      val=tonumber(val)
      if val==nil then val=element_storage["linked_to_default"] refresh=true end
      if element_storage["menuSelectedItem"]~=val then 
        element_storage["menuSelectedItem"]=val 
        reagirl.Gui_ForceRefresh() 
      end
    elseif element_storage["linked_to"]==2 then
      local retval, val = reaper.BR_Win32_GetPrivateProfileString(element_storage["linked_to_section"], element_storage["linked_to_key"], "", element_storage["linked_to_ini_file"])
      val=tonumber(val)
      if val==nil then val=element_storage["linked_to_default"] refresh=true end
      if element_storage["menuSelectedItem"]~=val then 
        element_storage["menuSelectedItem"]=val 
        reagirl.Gui_ForceRefresh() 
      end
    end
    if element_storage["menuSelectedItem"]>element_storage["MenuCount"] then refresh=true element_storage["menuSelectedItem"]=element_storage["MenuCount"] end
    if element_storage["menuSelectedItem"]<1 then element_storage["menuSelectedItem"]=1 refresh=true  end
  end
  
  if gfx.mouse_x>=x+cap_w and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    reagirl.Scroll_Override_MouseWheel=true
    if reagirl.MoveItAllRight_Delta==0 and reagirl.MoveItAllUp_Delta==0 then
      if mouse_attributes[5]<0 then element_storage["menuSelectedItem"]=element_storage["menuSelectedItem"]+1 refresh=true end
      if mouse_attributes[5]>0 then element_storage["menuSelectedItem"]=element_storage["menuSelectedItem"]-1 refresh=true end
      
      if element_storage["menuSelectedItem"]<1 then element_storage["menuSelectedItem"]=1 end
      if element_storage["menuSelectedItem"]>element_storage["MenuCount"] then element_storage["menuSelectedItem"]=element_storage["MenuCount"] end
      if refresh==true and element_storage["run_function"]~=nil then reagirl.Elements[element_id]["run_function"](element_storage["Guid"], element_storage["menuSelectedItem"], element_storage["MenuEntries"][element_storage["menuSelectedItem"]]) reagirl.Gui_ForceRefresh(26) end
    end
  end
  local Entries=""
  local collapsed=""
  local Default, insert

  for i=1, #element_storage["MenuEntries"] do
    if i==element_storage["menuSelectedItem"] then insert="!" else insert="" end
    Entries=Entries..insert..element_storage["MenuEntries"][i].."|"
  end
  
  if w<20 then w=20 end
  if selected~="not selected" then
    reagirl.Scroll_Override=true
  end
  
  if element_storage["pressed"]==true then
      gfx.x=x+cap_w
      gfx.y=y+h--*scale
      local selection=gfx.showmenu(Entries:sub(1,-2))
      
      if selection>0 then
        reagirl.Elements[element_id]["menuSelectedItem"]=math.tointeger(selection)
        reagirl.Elements[element_id]["Text"]=element_storage["MenuEntries"][math.tointeger(selection)]
      end
      refresh=true
      element_storage["pressed"]=false
  end

  if selected~="not selected" then
    if Key==32 or Key==13 then 
      element_storage["pressed"]=true
      collapsed=""
      refresh=true
    elseif Key==1685026670 then
      element_storage["menuSelectedItem"]=element_storage["menuSelectedItem"]+1
      refresh=true
      if element_storage["menuSelectedItem"]>element_storage["MenuCount"] then refresh=false element_storage["menuSelectedItem"]=element_storage["MenuCount"] end
      collapsed=""
      reagirl.Scroll_Override=true
      reagirl.Scroll_Override_MouseWheel=true
    elseif Key==30064 then 
      element_storage["menuSelectedItem"]=element_storage["menuSelectedItem"]-1
      refresh=true
      if element_storage["menuSelectedItem"]<1 then element_storage["menuSelectedItem"]=1 refresh=false end
      collapsed=""
      reagirl.Scroll_Override=true
    elseif Key==1752132965.0 or Key==1885828464.0 then -- home
      if element_storage["menuSelectedItem"]~=1 then
        reagirl.Scroll_Override=true
        element_storage["menuSelectedItem"]=1 
        refresh=true
      end
    elseif Key==6647396.0 or Key==1885824110.0 then -- end
      if element_storage["menuSelectedItem"]~=element_storage["MenuCount"] then
        reagirl.Scroll_Override=true
        element_storage["menuSelectedItem"]=element_storage["MenuCount"] 
        refresh=true
      end
    elseif selected~="not selected" and (clicked=="FirstCLK" and mouse_cap&1==1) and (gfx.mouse_x>=x+cap_w and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h) then
      element_storage["pressed"]=true
      collapsed=""
    else
      element_storage["pressed"]=false
    end
  end
  
  if refresh==true then 
    reagirl.Gui_ForceRefresh(28)
    if element_storage["run_function"]~=nil then 
      reagirl.Elements[element_id]["run_function"](element_storage["Guid"], element_storage["menuSelectedItem"], element_storage["MenuEntries"][element_storage["menuSelectedItem"]])
    end
    
    if element_storage["linked_to"]~=0 then
      if element_storage["linked_to"]==1 then
        reaper.SetExtState(element_storage["linked_to_section"], element_storage["linked_to_key"], element_storage["menuSelectedItem"], element_storage["linked_to_persist"])
      elseif element_storage["linked_to"]==2 then
        local retval, val = reaper.BR_Win32_WritePrivateProfileString(element_storage["linked_to_section"], element_storage["linked_to_key"], element_storage["menuSelectedItem"], element_storage["linked_to_ini_file"])
      end
    end
  end
  element_storage["AccHoverMessage"]=element_storage["Name"].." "..element_storage["MenuEntries"][element_storage["menuSelectedItem"]]
  return element_storage["MenuEntries"][element_storage["menuSelectedItem"]]..". "..collapsed, refresh
end

function reagirl.DropDownMenu_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  local dpi_scale, state
  local dpi_scale=reagirl.Window_CurrentScale
  y=y+dpi_scale
  local cap_w=element_storage["cap_w"]
  if element_storage["Cap_width"]~=nil then
    cap_w=element_storage["Cap_width"]
  end
  cap_w=cap_w*reagirl.Window_GetCurrentScale()
  if w-cap_w<50 then w=50+cap_w end
  local offset=gfx.measurestr(name.." ")
  gfx.x=x+cap_w
  gfx.y=y
  local menuentry=element_storage["MenuEntries"][element_storage["menuSelectedItem"]]
  
  gfx.x=x+cap_w
  gfx.y=y
  --w=w-5
  --h=h-5
  local radius=element_storage["radius"]
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  
  local sw,sh=gfx.measurestr(menuentry)
  local scale=1
  
  
  gfx.x=x+dpi_scale
  gfx.y=y+dpi_scale--+dpi_scale+(h-gfx.texth)/2
  gfx.set(0.2)
  gfx.drawstr(element_storage["Name"])
  
  gfx.x=x
  gfx.y=y--+dpi_scale+(h-gfx.texth)/2
  if element_storage["IsDisabled"]==true then gfx.set(0.6) else gfx.set(0.8) end
  gfx.drawstr(element_storage["Name"])
  
  if reagirl.Elements[element_id]["pressed"]==true then
    state=1*dpi_scale-1
    if offset==0 then offset=1 end

    gfx.set(0.06) -- background 2
    reagirl.RoundRect(cap_w+x, y, w-cap_w+dpi_scale+dpi_scale+dpi_scale, h+dpi_scale, (radius) * dpi_scale, 1, 1)
    
    gfx.set(0.274) -- button-area
    reagirl.RoundRect(cap_w+x+dpi_scale, y+dpi_scale+dpi_scale, w-cap_w+dpi_scale, h+dpi_scale, (radius-1) * dpi_scale, 1, 1)
    
    gfx.set(0.45)
    local circ=dpi_scale
    gfx.circle(x+dpi_scale+w-h/2, y+dpi_scale+dpi_scale+dpi_scale+dpi_scale+dpi_scale+dpi_scale+dpi_scale+dpi_scale, 3*dpi_scale, 1, 0)
    gfx.rect(x-dpi_scale+w-h+2*(dpi_scale-1), y+dpi_scale+dpi_scale, dpi_scale, h-dpi_scale, 1)
    
    
    gfx.x=x+(4*dpi_scale)+cap_w+dpi_scale
    if reaper.GetOS():match("OS")~=nil then offset=1 end
    gfx.y=y+dpi_scale--+(h-gfx.texth)/2+dpi_scale
    gfx.set(0.784)
    gfx.drawstr(menuentry, 0, x+w-21*dpi_scale, gfx.y+gfx.texth)
    reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  else
    state=0
    gfx.set(0.06) -- background 1
    reagirl.RoundRect(cap_w+x, y, w-cap_w+dpi_scale+dpi_scale, h, (radius) * dpi_scale, 1, 1)
    
    gfx.set(0.45) -- background 2
    reagirl.RoundRect(cap_w+x, y-dpi_scale, w-cap_w+dpi_scale, h, (radius) * dpi_scale, 1, 1)
    
    gfx.set(0.274) -- button-area
    reagirl.RoundRect(cap_w+x+dpi_scale, y, w-cap_w, h-dpi_scale, (radius-1) * dpi_scale, 1, 1)
    
    if element_storage["IsDisabled"]==false then
      gfx.set(0.45)
    else
      gfx.set(0.35)
    end
    local circ=dpi_scale    
    gfx.circle(x+w-h/2, y+dpi_scale+dpi_scale+dpi_scale+dpi_scale+dpi_scale+dpi_scale+dpi_scale, 3*dpi_scale, 1, 0)
    gfx.rect(x-dpi_scale-dpi_scale+w-h+2*(dpi_scale-1), y, dpi_scale, h-dpi_scale, 1)
    
    local offset=0
    if element_storage["IsDisabled"]==false then
      gfx.x=x+(4*dpi_scale)+cap_w
      if reaper.GetOS():match("OS")~=nil then offset=1 end
      gfx.y=y
      gfx.set(0.784)
      gfx.drawstr(menuentry, 0, x+w-21*dpi_scale, gfx.y+gfx.texth)
    else
      if reaper.GetOS():match("OS")~=nil then offset=1 end
      
      gfx.x=x+(4*dpi_scale)+offset+cap_w--+(w-sw)/2+1
      gfx.y=y+2--+dpi_scale+(h-gfx.texth)/2+offset+2
      gfx.set(0.09)
      gfx.drawstr(menuentry,0,x+w-21*dpi_scale, gfx.y+gfx.texth)
      
      gfx.x=x+(4*dpi_scale)+offset+cap_w--+(w-sw)/2+1
      gfx.y=y--+dpi_scale+(h-gfx.texth)/2+offset
      gfx.set(0.55)
      gfx.drawstr(menuentry,0,x+w-21*dpi_scale, gfx.y+gfx.texth)
    end
  end
end

function reagirl.DropDownMenu_LinkToExtstate(element_id, section, key, default, persist)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DropDownMenu_LinkToExtstate</slug>
  <requires>
    ReaGirl=1.1
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.DropDownMenu_LinkToExtstate(string element_id, string section, string key, string default, boolean persist)</functioncall>
  <description>
    Links a drop down menu to an extstate. 
    
    All changes to the extstate will be immediately visible for this drop down menu.
    
    If the drop down menu was already linked to an ini-file, the linked-state will be replaced by this new one.
    Use reagirl.DropDownMenu_UnLink() to unlink the drop down menu from extstate/ini-file/config var.
  </description>
  <parameters>
    string element_id - the guid of the drop down menu, that you want to link to an extstate
    string section - the section of the linked extstate
    string key - the key of the linked extstate
    string default - the default value, if the extstate hasn't been set yet
    boolean persist - true, the extstate shall be stored persistantly; false, the extstate shall not be stored persistantly
  </parameters>
  <chapter_context>
    DropDown Menu
  </chapter_context>
  <tags>dropdown menu, link to, extstate</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("DropDownMenu_LinkToExtstate: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("DropDownMenu_LinkToExtstate: param #1 - must be a valid guid", 2) end
  if type(section)~="string" then error("DropDownMenu_LinkToExtstate: param #2 - must be a string", 2) end
  if type(key)~="string" then error("DropDownMenu_LinkToExtstate: param #3 - must be a string", 2) end
  if math.type(default)~="integer" then error("DropDownMenu_LinkToExtstate: param #4 - must be an integer", 2) end
  if type(persist)~="boolean" then error("DropDownMenu_LinkToExtstate: param #5 - must be a boolean", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("DropDownMenu_LinkToExtstate: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="ComboBox" then
    error("Inputbox_LinkToExtstate: param #1 - ui-element is not a drop down menu", 2)
  else
    reagirl.Elements[element_id]["linked_to"]=1
    reagirl.Elements[element_id]["linked_to_section"]=section
    reagirl.Elements[element_id]["linked_to_key"]=key
    reagirl.Elements[element_id]["linked_to_default"]=default
    reagirl.Elements[element_id]["linked_to_persist"]=persist
    reagirl.Gui_ForceRefresh(16)
  end
end

function reagirl.DropDownMenu_LinkToIniFile(element_id, ini_file, section, key, default, persist)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DropDownMenu_LinkToIniFile</slug>
  <requires>
    ReaGirl=1.1
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.DropDownMenu_LinkToIniFile(string element_id, string ini_file, string section, string key, string default, boolean persist)</functioncall>
  <description>
    Links a drop down menu to an ini-file-entry. 
    
    All changes to the ini-file-entry will be immediately visible for this drop down menu.
    Entering text into the inputbox also updates the ini-file-entry immediately.
    
    If the drop down menu was already linked to an ini-file, the linked-state will be replaced by this new one.
    Use reagirl.Inputbox_UnLink() to unlink the inputbox from extstate/ini-file/config var.
  </description>
  <parameters>
    string element_id - the guid of the inputbox, that you want to link to an extstate
    string ini_file - the filename of the ini-file, whose value you want to link to this slider
    string section - the section of the linked ini-file
    string key - the key of the linked ini-file
    string default - the default value, if the ini-file hasn't been set yet
    boolean persist - true, the ini-file shall be stored persistantly; false, the ini-file shall not be stored persistantly
  </parameters>
  <chapter_context>
    DropDown Menu
  </chapter_context>
  <tags>dropdown menu, link to, ini-file</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("DropDownMenu_LinkToIniFile: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("DropDownMenu_LinkToIniFile: param #1 - must be a valid guid", 2) end
  if type(ini_file)~="string" then error("DropDownMenu_LinkToIniFile: param #2 - must be a string", 2) end
  if type(section)~="string" then error("DropDownMenu_LinkToIniFile: param #3 - must be a string", 2) end
  if type(key)~="string" then error("DropDownMenu_LinkToIniFile: param #4 - must be a string", 2) end
  if math.type(default)~="integer" then error("DropDownMenu_LinkToIniFile: param #5 - must be an integer", 2) end

  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("DropDownMenu_LinkToIniFile: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="ComboBox" then
    error("DropDownMenu_LinkToIniFile: param #1 - ui-element is not a drop down menu", 2)
  else
    reagirl.Elements[element_id]["linked_to"]=2
    reagirl.Elements[element_id]["linked_to_ini_file"]=ini_file
    reagirl.Elements[element_id]["linked_to_section"]=section
    reagirl.Elements[element_id]["linked_to_key"]=key
    reagirl.Elements[element_id]["linked_to_default"]=default
    reagirl.Elements[element_id]["linked_to_persist"]=persist
    reagirl.Gui_ForceRefresh(16)
  end
end

function reagirl.DropDownMenu_Unlink(element_id, section, key, default, persist)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DropDownMenu_Unlink</slug>
  <requires>
    ReaGirl=1.1
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.DropDownMenu_Unlink(string element_id)</functioncall>
  <description>
    Unlinks a drop down menu from extstate/ini-file/configvar. 
  </description>
  <parameters>
    string element_id - the guid of the drop down menu, that you want to unlink from an extstate/inifile-entry/configvar
  </parameters>
  <chapter_context>
    DropDown Menu
  </chapter_context>
  <tags>dropdown menu, unlink</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("DropDownMenu_Unlink: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("DropDownMenu_Unlink: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("DropDownMenu_Unlink: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="ComboBox" then
    error("DropDownMenu_Unlink: param #1 - ui-element is not a drop down menu", 2)
  else
    reagirl.Elements[element_id]["linked_to"]=0
    reagirl.Gui_ForceRefresh(16)
  end
end

function reagirl.DropDownMenu_SetDimensions(element_id, width)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DropDownMenu_SetDimensions</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.DropDownMenu_SetDimensions(string element_id, optional integer width)</functioncall>
  <description>
    Sets the width of a dropdownmenu.
  </description>
  <parameters>
    string element_id - the guid of the drop down menu, whose width-state you want to set
    optional integer width - the new width of the drop down menu; negative anchors to right window-edge; nil, keep current width
  </parameters>
  <chapter_context>
    DropDown Menu
  </chapter_context>
  <tags>dropdown menu, set, width</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("DropDownMenu_SetDimensions: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("DropDownMenu_SetDimensions: param #1 - must be a valid guid", 2) end
  if width~=nil and math.type(width)~="integer" then error("DropDownMenu_SetDimensions: param #2 - must be either nil or an integer", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("DropDownMenu_SetDimensions: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="ComboBox" then
    error("DropDownMenu_SetDimensions: param #1 - ui-element is not a drop down menu", 2)
  else
    if width~=nil then
      reagirl.Elements[element_id]["w"]=width
    end
    reagirl.Gui_ForceRefresh(18.4)
  end
end

function reagirl.DropDownMenu_GetDimensions(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DropDownMenu_GetDimensions</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer width = reagirl.DropDownMenu_GetDimensions(string element_id)</functioncall>
  <description>
    Gets the width of a drop down menu.
  </description>
  <parameters>
    string element_id - the guid of the drop down menu, whose width-state you want to set
  </parameters>
  <retvals>
    integer width - the width of the drop down menu; negative anchors to right window-edge
  </retvals>
  <chapter_context>
    DropDown Menu
  </chapter_context>
  <tags>dropdown menu, get, width</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("DropDownMenu_GetDimensions: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("DropDownMenu_GetDimensions: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("DropDownMenu_GetDimensions: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="ComboBox" then
    error("DropDownMenu_GetDimensions: param #1 - ui-element is not a drop down menu", 2)
  else
    return reagirl.Elements[element_id]["w"]
  end
end

function reagirl.DropDownMenu_SetDisabled(element_id, state)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DropDownMenu_SetDisabled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.DropDownMenu_SetDisabled(string element_id, boolean state)</functioncall>
  <description>
    Sets a drop down menu as disabled(non clickable)-state.
  </description>
  <parameters>
    string element_id - the guid of the dropdown-menu, whose disability-state you want to set
    boolean state - true, the dropdown-menu is disabled; false, the dropdown-menu is not disabled.
  </parameters>
  <chapter_context>
    DropDown Menu
  </chapter_context>
  <tags>dropdown menu, set, disabled</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("DropDownMenu_SetDisabled: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("DropDownMenu_SetDisabled: param #1 - must be a valid guid", 2) end
  if type(state)~="boolean" then error("DropDownMenu_SetDisabled: param #2 - must be a boolean", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("DropDownMenu_SetDisabled: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="ComboBox" then
    error("DropDownMenu_SetDisabled: param #1 - ui-element is not a dropdown-menu", 2)
  else
    reagirl.Elements[element_id]["IsDisabled"]=state
    reagirl.Gui_ForceRefresh(977)
  end
end

function reagirl.DropDownMenu_GetDisabled(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DropDownMenu_GetDisabled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>boolean state = reagirl.DropDownMenu_GetDisabled(string element_id)</functioncall>
  <description>
    Gets a dropdown-menu's disabled(non clickable)-state.
  </description>
  <parameters>
    string element_id - the guid of the dropdown-menu, whose disability-state you want to get
  </parameters>
  <retvals>
    boolean state - true, the dropdown-menu is disabled; false, the dropdown-menu is not disabled.
  </retvals>
  <chapter_context>
    DropDown Menu
  </chapter_context>
  <tags>dropdown menu, get, disabled</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("DropDownMenu_GetDisabled: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("DropDownMenu_GetDisabled: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("DropDownMenu_GetDisabled: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="ComboBox" then
    error("DropDownMenu_GetDisabled: param #1 - ui-element is not a dropdown-menu", 2)
  else
    return reagirl.Elements[element_id]["IsDisabled"]
  end
end

function reagirl.DropDownMenu_GetMenuItems(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DropDownMenu_GetMenuItems</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>table menuItems, integer menuSelectedItem = reagirl.DropDownMenu_GetMenuItems(string element_id)</functioncall>
  <description>
    Gets a dropdown-menu's menu-items and the index of the currently selected menu-item.
  </description>
  <parameters>
    string element_id - the guid of the dropdown-menu, whose menuitems/currently selected item you want to get
  </parameters>
  <retvals>
    table menuItems - a table that holds all menu-items
    integer menuSelectedItem - the index of the currently selected menu-item
  </retvals>
  <chapter_context>
    DropDown Menu
  </chapter_context>
  <tags>dropdown menu, get, menuitem, menudefault</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("DropDownMenu_GetMenuItems: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("DropDownMenu_GetMenuItems: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("DropDownMenu_GetMenuItems: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="ComboBox" then
    error("DropDownMenu_GetMenuItems: param #1 - ui-element is not a dropdown-menu", 2)
  else
    local newtable={}
    for i=1, #reagirl.Elements[element_id]["MenuEntries"] do
      newtable[i]=reagirl.Elements[element_id]["MenuEntries"][i]
    end
    return newtable, reagirl.Elements[element_id]["menuSelectedItem"]
  end
end

function reagirl.DropDownMenu_SetMenuItems(element_id, menuItems, menuSelectedItem)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DropDownMenu_SetMenuItems</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.DropDownMenu_SetMenuItems(string element_id, table menuItems, integer menuSelectedItem)</functioncall>
  <description>
    Sets a dropdown-menu's menuitems and the index of the currently selected menu-item.
  </description>
  <parameters>
    string element_id - the guid of the dropdown-menu, whose menuitems/selected menu-item you want to set
    table menuItems - an indexed table with all the menu-items
    integer menuSelectedItem - the index of the pre-selected menu-item
  </parameters>
  <chapter_context>
    DropDown Menu
  </chapter_context>
  <tags>dropdown menu, set, menuitem, menudefault</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("DropDownMenu_SetMenuItems: param #1 - must be a string", 2) end
  if type(menuItems)~="table" then error("DropDownMenu_SetMenuItems: param #2 - must be a table", 2) end
  if math.type(menuSelectedItem)~="integer" then error("DropDownMenu_SetMenuItems: param #3 - must be an integer", 2) end
  for i=1, #menuItems do
    menuItems[i]=tostring(menuItems[i])
  end
  if menuSelectedItem>#menuItems or menuSelectedItem<1 then error("DropDownMenu_SetMenuItems: param #3 - no such menu-item", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("DropDownMenu_SetMenuItems: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("DropDownMenu_SetMenuItems: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="ComboBox" then
    error("DropDownMenu_SetMenuItems: param #1 - ui-element is not a dropdown-menu", 2)
  else
    reagirl.Elements[element_id]["MenuEntries"]=menuItems
    reagirl.Elements[element_id]["menuSelectedItem"]=menuSelectedItem
    reagirl.Gui_ForceRefresh(29)
  end
end


function reagirl.Label_SetLabelText(element_id, label)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Label_SetLabelText</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Label_SetLabelText(string element_id, string label)</functioncall>
  <description>
    Sets a new label text to an already existing label.
  </description>
  <parameters>
    string element_id - the id of the element, whose label you want to set
    string label - the new text of the label
  </parameters>
  <chapter_context>
    Label
  </chapter_context>
  <tags>label, set, text</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Label_SetLabelText: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Label_SetLabelText: param #1 - must be a valid guid", 2) end
  if type(label)~="string" then error("Label_SetLabelText: param #2 - must be a string", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Label_SetLabelText: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]:sub(-5,-1)~="Label" then
    error("Label_SetLabelText: param #1 - ui-element is not a label", 2)
  else
    local w,h=gfx.measurestr(label)
    reagirl.Elements[element_id]["Name"]=label
    reagirl.Elements[element_id]["w"]=math.tointeger(w)
    reagirl.Elements[element_id]["h"]=math.tointeger(h)--math.tointeger(gfx.texth)
    reagirl.Gui_ForceRefresh(30)
  end
end

function reagirl.Label_GetFontSize(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Label_GetFontSize</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer font_size = reagirl.Label_GetFontSize(string element_id)</functioncall>
  <description>
    Gets the font-size of a label.
  </description>
  <retvals>
    integer font_size - the font_size of the label
  </retvals>
  <parameters>
    string element_id - the id of the element, whose font-size you want to get
  </parameters>
  <chapter_context>
    Label
  </chapter_context>
  <tags>label, get, font size</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Label_GetFontSize: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Label_GetFontSize: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Label_GetFontSize: param #1 - no such ui-element", 2) end

  if reagirl.Elements[element_id]["GUI_Element_Type"]:sub(-5,-1)~="Label" then
    error("Label_GetFontSize: param #1 - ui-element is not a label", 2)
  else
    return reagirl.Elements[element_id]["font_size"]
  end
end

function reagirl.Label_SetFontSize(element_id, font_size)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Label_SetFontSize</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Label_SetFontSize(string element_id, integer font_size)</functioncall>
  <description>
    Sets the font-size of a label.
  </description>
  <parameters>
    string element_id - the id of the element, whose font-size you want to set
    integer font_size - the font_size of the label
  </parameters>
  <chapter_context>
    Label
  </chapter_context>
  <tags>label, set, font size</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Label_SetFontSize: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Label_SetFontSize: param #1 - must be a valid guid", 2) end
  if math.type(font_size)~="integer" then error("Label_SetFontSize: param #2 - must be an integer", 2) end
  if font_size<1 then error("Label_SetFontSize: param #2 - must be 1 or higher", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Label_SetFontSize: param #1 - no such ui-element", 2) end

  if reagirl.Elements[element_id]["GUI_Element_Type"]:sub(-5,-1)~="Label" then
    error("Label_SetFontSize: param #1 - ui-element is not a label", 2)
  else
    reagirl.Elements[element_id]["font_size"]=font_size
    style1=reagirl.Elements[element_id]["style1"]
    style2=reagirl.Elements[element_id]["style2"]
    style3=reagirl.Elements[element_id]["style3"]
    
    local styles={66,73,77,79,83,85,86,89,90}
    styles[0]=0
    local style=styles[style1]<<8
    style=style+styles[style2]<<8
    style=style+styles[style3]<<8
    if reagirl.Elements[element_id]["clickable"] then
      style=style+85
    end
    
    reagirl.SetFont(1, "Arial", reagirl.Elements[element_id]["font_size"], style, 1)
    local w,h=gfx.measurestr(reagirl.Elements[element_id]["Name"])
    reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
    --reaper.MB(h, reagirl.Elements[element_id]["Name"],0)
    reagirl.Elements[element_id]["w"]=math.tointeger(w)
    reagirl.Elements[element_id]["h"]=math.tointeger(h)
  end
end

function reagirl.Label_GetAlignment(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Label_GetAlignement</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer alignment = reagirl.Label_GetAlignement(string element_id)</functioncall>
  <description>
    Gets the alignment of a label.
  </description>
  <retvals>
    integer alignment - the alignment of the label
                      - flags&1: center horizontally
                      - flags&2: right justify
                      - flags&4: center vertically
                      - flags&8: bottom justify
  </retvals>
  <parameters>
    string element_id - the id of the element, whose alignment you want to get
  </parameters>
  <chapter_context>
    Label
  </chapter_context>
  <tags>label, get, alignment</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Label_GetAlignement: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Label_GetAlignement: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Label_GetAlignement: param #1 - no such ui-element", 2) end

  if reagirl.Elements[element_id]["GUI_Element_Type"]:sub(-5,-1)~="Label" then
    error("Label_GetAlignement: param #1 - ui-element is not a label", 2)
  else
    return reagirl.Elements[element_id]["align"]
  end
end

function reagirl.Label_SetAlignment(element_id, alignment)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Label_SetAlignment</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Label_SetAlignment(string element_id, integer alignment)</functioncall>
  <description>
    Sets the font-size of a label.
  </description>
  <parameters>
    string element_id - the id of the element, whose font-size you want to set
    integer alignment - the alignment of the label
                      - flags&1: center horizontally
                      - flags&2: right justify
                      - flags&4: center vertically
                      - flags&8: bottom justify
  </parameters>
  <chapter_context>
    Label
  </chapter_context>
  <tags>label, set, alignment</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Label_SetAlignment: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Label_SetAlignment: param #1 - must be a valid guid", 2) end
  if math.type(alignment)~="integer" then error("Label_SetAlignment: param #2 - must be an integer", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Label_SetAlignment: param #1 - no such ui-element", 2) end

  if reagirl.Elements[element_id]["GUI_Element_Type"]:sub(-5,-1)~="Label" then
    error("Label_SetAlignment: param #1 - ui-element is not a label", 2)
  else
    reagirl.Elements[element_id]["align"]=alignment
  end
end

function reagirl.Label_SetStyle(element_id, style1, style2, style3)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Label_SetStyle</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Label_SetStyle(string element_id, integer style1, optional integer style2, optional integer style3)</functioncall>
  <description>
    Sets the style of a label.
    
    You can combine different styles with each other in style1 through style3.
  </description>
  <parameters>
    string element_id - the id of the element, whose label-style you want to set
    integer style1 - choose a style
                   - 0, no style
                   - 1, bold
                   - 2, italic
                   - 3, non anti-alias
                   - 4, outline
                   - 5, drop-shadow
                   - 6, underline
                   - 7, negative
                   - 8, 90° counter-clockwise
                   - 9, 90° clockwise
    optional integer style2 - nil for no style; the rest, see style1 for more details
    optional integer style3 - nil for no style; the rest, see style1 for more details
  </parameters>
  <chapter_context>
    Label
  </chapter_context>
  <tags>label, set, text, style</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Label_SetStyle: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Label_SetStyle: param #1 - must be a valid guid", 2) end
  if math.type(style1)~="integer" then error("Label_SetStyle: param #2 - must be an integer", 2) end
  if style2~=nil and math.type(style2)~="integer" then error("Label_SetStyle: param #3 - must be nil or an integer", 2) end
  if style3~=nil and math.type(style3)~="integer" then error("Label_SetStyle: param #4 - must be nil or an integer", 2) end
  if style2==nil then style2=0 end
  if style3==nil then style3=0 end
  if style1<0 or style1>9 then error("Label_SetStyle: param #2 - no such style", 2) end
  if style2<0 or style2>9 then error("Label_SetStyle: param #3 - no such style", 2) end
  if style3<0 or style3>9 then error("Label_SetStyle: param #4 - no such style", 2) end

  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Label_SetStyle: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]:sub(-5,-1)~="Label" then
    error("Label_SetStyle: param #1 - ui-element is not a label", 2)
  else
    reagirl.Elements[element_id]["style1"]=style1
    reagirl.Elements[element_id]["style2"]=style2
    reagirl.Elements[element_id]["style3"]=style3
    
    local styles={66,73,77,79,83,85,86,89,90}
    styles[0]=0
    local style=styles[style1]<<8
    style=style+styles[style2]<<8
    style=style+styles[style3]<<8
    if reagirl.Elements[element_id]["clickable"] then
      style=style+85
    end
    
    reagirl.SetFont(1, "Arial", reagirl.Elements[element_id]["font_size"], style, 1)
    local w,h=gfx.measurestr(reagirl.Elements[element_id]["Name"])
    reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
    
    reagirl.Elements[element_id]["w"]=math.tointeger(w)
    reagirl.Elements[element_id]["h"]=math.tointeger(h)
    
    reagirl.Gui_ForceRefresh(30)
  end
end

function reagirl.Label_GetStyle(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Label_GetStyle</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer style1, integer style2, integer style3 = reagirl.Label_GetStyle(string element_id)</functioncall>
  <description>
    Gets the style of a label.
  </description>
  <retvals>
    integer style1 - the first style used:
                   - 0, no style
                   - 1, bold
                   - 2, italic
                   - 3, non anti-alias
                   - 4, outline
                   - 5, drop-shadow
                   - 6, underline
                   - 7, negative
                   - 8, 90° counter-clockwise
                   - 9, 90° clockwise
    integer style2 - the rest, see style1 for more details
    integer style3 - the rest, see style1 for more details
  </retvals>
  <parameters>
    string element_id - the id of the element, whose label-style you want to get
  </parameters>
  <chapter_context>
    Label
  </chapter_context>
  <tags>label, get, style</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Label_GetStyle: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Label_GetStyle: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Label_GetStyle: param #1 - no such ui-element", 2) end

  if reagirl.Elements[element_id]["GUI_Element_Type"]:sub(-5,-1)~="Label" then
    error("Label_GetStyle: param #1 - ui-element is not a label", 2)
  else
    return reagirl.Elements[element_id]["style1"], reagirl.Elements[element_id]["style2"], reagirl.Elements[element_id]["style3"]
  end
end

  
function reagirl.Label_Add(x, y, label, meaningOfUI_Element, clickable, run_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Label_Add</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Label_Add(optional integer x, optional integer y, string label, string meaningOfUI_Element, boolean clickable, optional function run_function)</functioncall>
  <description>
    Adds a label to the gui.
    
    You can autoposition the label by setting x and/or y to nil, which will position the new label after the last ui-element.
    To autoposition into the next line, use reagirl.NextLine()
    
    It is possible to make labels draggable. See Label_SetDraggable and Label_GetDraggable for how to do it.
    
    The run-function will get as parameters:
    - string element_id - the element_id of the clicked label
    - optional string dropped_element_id - the element_id of the ui-element, onto which the label was dragged
  </description>
  <parameters>
    optional integer x - the x position of the label in pixels; negative anchors the label to the right window-side; nil, autoposition after the last ui-element(see description)
    optional integer y - the y position of the label in pixels; negative anchors the label to the bottom window-side; nil, autoposition after the last ui-element(see description)
    string label - the text of the label
    string meaningOfUI_Element - the meaningOfUI_Element of the ui-element(for tooltips and blind users). Make it a sentence that ends with . or ?
    boolean clickable - true, the text is a clickable link-text; false or nil, the label-text is normal text
    optional function run_function - a function that gets run when clicking the link-text(clickable=true)
  </parameters>
  <chapter_context>
    Label
  </chapter_context>
  <tags>label, add</tags>
</US_DocBloc>
--]]
  if x~=nil and math.type(x)~="integer" then error("Label_Add: param #1 - must be either nil or an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("Label_Add: param #2 - must be either nil or an integer", 2) end
  if type(label)~="string" then error("Label_Add: param #3 - must be a string", 2) end
  if type(meaningOfUI_Element)~="string" then error("Label_Add: param #4 - must be a string", 2) end
  if meaningOfUI_Element:sub(-1,-1)~="." and meaningOfUI_Element:sub(-1,-1)~="?" then error("Label_Add: param #4 - must end on a . like a regular sentence.", 2) end
  if type(clickable)~="boolean" then error("Label_Add: param #6 - must be a boolean", 2) end
  if run_function==nil then run_function=reagirl.Dummy end
  if type(run_function)~="function" then error("Label_Add: param #6 - must be either nil or a function", 2) end
  
  local x,y,slot=reagirl.UI_Element_GetNextXAndYPosition(x, y, "Label_Add")
  --reagirl.UI_Element_NextX_Default=x
  
  local acc_clickable=""
  local clickable_text=""
  if clickable==true then clickable_text="Clickable " acc_clickable="Enter or leftclick to click link. " else acc_clickable="" end
  
  table.insert(reagirl.Elements, slot, {})
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0, 1)
  local w,h=gfx.measurestr(label)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  reagirl.Elements[slot]["Guid"]=reaper.genGuid("")
  reagirl.Elements[slot]["GUI_Element_Type"]=clickable_text.."Label"
  reagirl.Elements[slot]["Name"]=label
  reagirl.Elements[slot]["Text"]=""
  reagirl.Elements[slot]["Description"]=meaningOfUI_Element
  reagirl.Elements[slot]["IsDisabled"]=false
  reagirl.Elements[slot]["AccHint"]=acc_clickable.."Ctrl+C copies label-text to clipboard. "
  reagirl.Elements[slot]["ContextMenu_ACC"]=""
  reagirl.Elements[slot]["DropZoneFunction_ACC"]=""
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  
  reagirl.Elements[slot]["font_size"]=reagirl.Font_Size
  reagirl.Elements[slot]["clickable"]=clickable
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false
  reagirl.Elements[slot]["w"]=math.tointeger(w)
  reagirl.Elements[slot]["h"]=math.tointeger(h)
  if math.tointeger(h)>reagirl.NextLine_Overflow then reagirl.NextLine_Overflow=math.tointeger(h) end
  reagirl.Elements[slot]["align"]=0
  reagirl.Elements[slot]["style1"]=0
  reagirl.Elements[slot]["style2"]=0
  reagirl.Elements[slot]["style3"]=0
  reagirl.Elements[slot]["style4"]=0
  reagirl.Elements[slot]["bg_w"]=0
  reagirl.Elements[slot]["bg_h"]=0
  reagirl.Elements[slot]["func_draw"]=reagirl.Label_Draw
  reagirl.Elements[slot]["run_function"]=run_function
  reagirl.Elements[slot]["func_manage"]=reagirl.Label_Manage
  
  return reagirl.Elements[slot]["Guid"]
end
-- mespotine
function reagirl.Label_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  -- drop files for accessibility using a file-requester, after typing ctrl+shift+f
  if element_storage["DropZoneFunction"]~=nil and Key==6 and mouse_cap==12 then
    local retval, filenames = reaper.GetUserFileNameForRead("", "Choose file to drop into "..element_storage["Name"], "")
    reagirl.Window_SetFocus()
    if retval==true then element_storage["DropZoneFunction"](element_storage["Guid"], {filenames}) refresh=true end
  end
  
  if hovered==true then
    if element_storage["clickable"]==true then
      gfx.setcursor(114)
    elseif element_storage["DraggableDestinations"]~=nil then
      gfx.setcursor(114)
    end
  end
  
  if Key==3 and selected~="not selected" then reaper.CF_SetClipboard(name) end
  if gfx.mouse_cap&2==2 and selected~="not selected" and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    local oldx, oldy=gfx.x, gfx.y
    gfx.x=gfx.mouse_x
    gfx.y=gfx.mouse_y
    --local selection=gfx.showmenu("Copy Text to Clipboard")
    gfx.x=oldx
    gfx.y=oldy
    --if selection==1 then reaper.CF_SetClipboard(name) end
  end
  
  if selected~="not selected" and 
    (Key==32 or mouse_cap==1) and 
    (gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h) 
    and clicked=="FirstCLK" 
    and element_storage["run_function"]~=nil then 
    --print("1")
      element_storage["clickstate"]="clicked"
      if element_storage["Draggable"]==true and hovered==true then
        reagirl.Draggable_Element=element_id
        element_storage["mouse_x"]=gfx.mouse_x
        element_storage["mouse_y"]=gfx.mouse_y
        gfx.setcursor(114)
      end
  end
  if element_storage["Draggable"]==true and element_storage.DraggableDestinations~=nil then
    if selected~="not selected" and gfx.mouse_cap==12 and Key==1885828464.0 then
      if element_storage.Draggable_DestAccessibility==nil then 
        element_storage.Draggable_DestAccessibility=1 
      else
        element_storage.Draggable_DestAccessibility=element_storage.Draggable_DestAccessibility+1
        if element_storage.Draggable_DestAccessibility>#element_storage.DraggableDestinations then
          element_storage.Draggable_DestAccessibility=1
        end
      end
      local id = reagirl.UI_Element_GetIDFromGuid(element_storage.DraggableDestinations[element_storage.Draggable_DestAccessibility])
      reagirl.Elements.GlobalAccHoverMessageOld=""
      reagirl.Elements["GlobalAccHoverMessage"]="Dropdestination: "..reagirl.Elements[id]["Name"].." Destination "..element_storage.Draggable_DestAccessibility.." of "..#element_storage.DraggableDestinations
    elseif selected~="not selected" and gfx.mouse_cap==12 and Key==1885824110.0 then
      if element_storage.Draggable_DestAccessibility==nil then 
        element_storage.Draggable_DestAccessibility=1 
      else
        element_storage.Draggable_DestAccessibility=element_storage.Draggable_DestAccessibility-1
        if element_storage.Draggable_DestAccessibility<1 then
          element_storage.Draggable_DestAccessibility=#element_storage.DraggableDestinations
        end
      end
      local id = reagirl.UI_Element_GetIDFromGuid(element_storage.DraggableDestinations[element_storage.Draggable_DestAccessibility])
      reagirl.Elements.GlobalAccHoverMessageOld=""
      reagirl.Elements["GlobalAccHoverMessage"]="Dropdestination: "..reagirl.Elements[id]["Name"].." Destination "..element_storage.Draggable_DestAccessibility.." of "..#element_storage.DraggableDestinations
    elseif selected~="not selected" and gfx.mouse_cap==12 and Key==13 then
      if element_storage.Draggable_DestAccessibility==nil then 
        element_storage.Draggable_DestAccessibility=1 
      end
      element_storage["run_function"](element_storage["Guid"], element_storage.DraggableDestinations[element_storage.Draggable_DestAccessibility]) 
      local id = reagirl.UI_Element_GetIDFromGuid(element_storage.DraggableDestinations[element_storage.Draggable_DestAccessibility])
      reagirl.Elements["GlobalAccHoverMessage"]="Dropped onto "..reagirl.Elements[id]["Name"]
    end
  end
  if element_storage["clickstate"]=="clicked" and mouse_cap&1==0 then
    element_storage["clickstate"]=nil
    if element_storage["Draggable"]==true and (element_storage["mouse_x"]~=gfx.mouse_x or element_storage["mouse_y"]~=gfx.mouse_y) then
      for i=1, #element_storage["DraggableDestinations"] do
        if reagirl.UI_Element_IsElementAtMousePosition(element_storage["DraggableDestinations"][i])==true then
          element_storage["run_function"](element_storage["Guid"], element_storage["DraggableDestinations"][i]) 
        end
      end
    end
    reagirl.Draggable_Element=nil
  end
  --]]
  if element_storage["clickstate2"]==true and gfx.mouse_cap&1==0 and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    if element_storage["run_function"]~=nil then reagirl.Elements[element_id]["run_function"](element_storage["Guid"]) end
  end
  
  if element_storage["clickable"]==true and (Key==13 or gfx.mouse_cap&1==1) 
    and selected~="not selected" and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    element_storage["clickstate2"]=true
  end
  
  if element_storage["clickable"]==true and Key==13 then
    if element_storage["run_function"]~=nil then reagirl.Elements[element_id]["run_function"](element_storage["Guid"]) end
  end
  
  if gfx.mouse_cap&1==0 then
    element_storage["clickstate2"]=nil
  end
  local contextmenu=""
  --if element_storage["ContextMenu"]~=nil then contextmenu="Has Contextmanu." end
  local draggable=""
  --if element_storage["Draggable"]==true then draggable="Draggable,. " draggable2=" Use Ctrl plus alt plus Tab and Ctrl plus alt plus Tab to select the dragging-destinations and ctrl plus alt plus enter to drop the image into the dragging-destination." else draggable="" end
  return draggable..contextmenu.." ", false
end

function reagirl.Label_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  -- BUG: with multiline-texts, when they scroll outside the top of the window, they disappear when the first line is outside of the window
                        --   85 and 117, underline (U), (u)
  local styles={66,73,77,79,83,85,86,89,90}
  styles[0]=0
  local dpi_scale=reagirl.Window_GetCurrentScale()
  y=y+dpi_scale
  local style=styles[element_storage["style1"]]<<8
  style=style+styles[element_storage["style2"]]<<8
  style=style+styles[element_storage["style3"]]<<8
  if element_storage["clickable"] then
    style=style+85
  end
  
  --print2(style)
  reagirl.SetFont(1, "Arial", element_storage["font_size"], style)
  local olddest=gfx.dest
  local oldx, oldy = gfx.x, gfx.y
  local old_gfx_r=gfx.r
  local old_gfx_g=gfx.g
  local old_gfx_b=gfx.b
  local old_gfx_a=gfx.a
  local old_mode=gfx.mode
  gfx.setimgdim(1001, gfx.w, gfx.h)
  --gfx.dest=1001
  --gfx.set(0)
  --gfx.rect(0, 0, gfx.w, gfx.h, 1)
  local w2,h2=gfx.measurestr(name)  
  if selected~="not selected" then
    reagirl.UI_Element_SetFocusRect(true, x, y, math.floor(w2), math.floor(h2))
  end
  
  if element_storage["auto_breaks"]==true then
  --[[
  -- old code, might work now in most recent Reaper-version
    gfx.set(0.1)
    local retval, w, h = reagirl.BlitText_AdaptLineLength(name, 
                                                          math.floor(x)+1, 
                                                          math.floor(y)+2, 
                                                          gfx.w,
                                                          gfx.h,--gfx.texth,
                                                          element_storage["align"])
    
    gfx.set(1,1,1)
    reagirl.BlitText_AdaptLineLength(name, 
                                     math.floor(x), 
                                     math.floor(y)+1, 
                                     gfx.w,
                                     gfx.h,--gfx.texth,
                                     element_storage["align"])
                                     --]]
  else
    local col=0.8
    local col2=0.8
    local col3=0.2
    if element_storage["clickable"]==true then 
      col=0.4
      col2=0.8
      col3=0.2
    end
    gfx.set(col3)
    gfx.x=x+dpi_scale
    gfx.y=y+dpi_scale
    gfx.drawstr(name, element_storage["align"])--, x+w, y+h)
    
    gfx.set(col,col,col2)
    gfx.x=x
    gfx.y=y
    gfx.drawstr(name, element_storage["align"])--, x+w, y+h)
    
    if element_storage["bg"]=="auto" then
      _, _, _, _, _, _, _, _, bg_w = reagirl.Gui_GetBoundaries()
      bg_w=bg_w-x
      local element_id=reagirl.UI_Element_GetIDFromGuid(element_storage["bg_dest"])
      local y2=reagirl.Elements[element_id]["y"]
      local h2=reagirl.Elements[element_id]["h"]
      y3=y/reagirl.Window_GetCurrentScale()
      if y2>=0 then
        bg_h=y2+h2-y3
      else
        -- buggy
        bg_h=y2+h2
      end
      --reaper.MB(bg_w, bg_h, 0)
      element_storage["bg_w"]=bg_w/reagirl.Window_GetCurrentScale()
      element_storage["bg_h"]=bg_h-1
      element_storage["bg"]=nil
      --element_storage["bg_auto"]=true
    end
    
    local bg_h=element_storage["bg_h"]
    if bg_h<0 then bg_h=gfx.h+bg_h-y-(gfx.texth>>1) end
    bg_h=bg_h--*dpi_scale
    local bg_w=element_storage["bg_w"]
    if bg_w<0 then bg_w=gfx.w+bg_w-x end
    bg_w=bg_w--*dpi_scale
    if element_storage["bg_auto"]==true then
      _, _, _, _, _, _, _, _, bg_w = reagirl.Gui_GetBoundaries()
      bg_w=bg_w-x
    end
    
    if bg_w~=0 and bg_h~=0 then
    --[[
      gfx.set(0.2)
      gfx.rect(x-10+dpi_scale, y+(gfx.texth>>1)+dpi_scale, 5, dpi_scale, 1)
      gfx.rect(x-10+dpi_scale, y+(gfx.texth>>1)+dpi_scale, dpi_scale, bg_h, 1)
      if bg_h>1 then
        gfx.rect(x-10+dpi_scale, y+bg_h+(gfx.texth>>1)+dpi_scale, bg_w+12, dpi_scale, 1)
      end
      gfx.rect(x+dpi_scale+bg_w+dpi_scale, y+(gfx.texth>>1)+dpi_scale, dpi_scale, bg_h, 1)
      gfx.rect(x+dpi_scale+w2+5+dpi_scale, y+(gfx.texth>>1)+dpi_scale, bg_w-w2-5, dpi_scale, 1)
      --]]
      gfx.set(0.5)
      gfx.rect(x-10*dpi_scale, y+(gfx.texth>>1), 5*dpi_scale, dpi_scale, 1)
      gfx.rect(x-10*dpi_scale, y+(gfx.texth>>1), dpi_scale, bg_h*dpi_scale, 1)
      if bg_h>1 then
        gfx.rect(x-10*dpi_scale, y+bg_h*dpi_scale+(gfx.texth>>1)-dpi_scale, bg_w*dpi_scale+12*dpi_scale, dpi_scale, 1)
      end
      gfx.rect(x+dpi_scale+bg_w*dpi_scale, y+(gfx.texth>>1), dpi_scale, bg_h*dpi_scale, 1)
      gfx.rect(x+dpi_scale+w2+5, y+(gfx.texth>>1), bg_w*dpi_scale-w2-5, dpi_scale, 1)
    end
    
    
    if selected~="not selected" then
      local olddest=gfx.dest
      gfx.dest=reagirl.DragImageSlot
      local tx,ty=gfx.measurestr(name)
      gfx.setimgdim(reagirl.DragImageSlot, tx, ty)
      gfx.set(0)
      gfx.rect(0,0,tx,ty,1)
      local col=0.8
      local col2=0.8
      local col3=0.2
      if element_storage["clickable"]==true then 
        col=0.4
        col2=0.8
        col3=0.2
      end
      gfx.set(col3)
      gfx.x=0+dpi_scale
      gfx.y=0+dpi_scale
      gfx.drawstr(name, element_storage["align"])
      
      gfx.set(col,col,col2)
      gfx.x=0
      gfx.y=0
      gfx.drawstr(name, element_storage["align"])
      gfx.dest=olddest
    end
    --reagirl.SetFont(1, "Arial", element_storage["font_size"],0)
  end
  --[[gfx.dest=-1
  gfx.x=x
  gfx.y=y
  gfx.mode=1
  gfx.blit(1001, 1, 0)
  
  --]]
  
  gfx.x=oldx
  gfx.y=oldy
  gfx.set(old_gfx_r, old_gfx_g, old_gfx_b, old_gfx_a)
  gfx.mode=old_mode
end

function reagirl.Label_SetBackdrop(element_id, width, height)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Label_SetBackdrop</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Label_SetBackdrop(string element_id, integer width, integer height)</functioncall>
  <description>
    Sets a background-rectangle in line-style for this label. You can use this to "include" different ui-elements of a common context underneath this label.
    That way, you can structure your guis a little better.
    
    Set height to 1 to just have a line before and after the first line of the label-text.
  </description>
  <parameters>
    string element_id - the label-element, that shall draw a backdrop
    integer width - the width of the backdrop in pixels
    integer height - the height of the backdrop in pixels
  </parameters>
  <chapter_context>
    Label
  </chapter_context>
  <tags>label, set, backdrop</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Label_SetBackdrop: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==false then error("Label_SetBackdrop: param #1 - must be a valid guid", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Label_SetBackdrop: param #1 - no such ui-element", 2) end
  
  if reagirl.Elements[element_id]["GUI_Element_Type"]:sub(-5, -1)~="Label" then
    reagirl.Elements[element_id]["GUI_Element_Type"]:sub(-5, -1)
    error("Label_SetBackdrop: param #1 - ui-element is not a label", 2)
  else
    reagirl.Elements[element_id]["bg_w"]=width
    reagirl.Elements[element_id]["bg_h"]=height
  end
end

function reagirl.Label_AutoBackdrop(element_id, dest_element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Label_AutoBackdrop</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Label_GetBackdrop(string element_id, string dest_element_id)</functioncall>
  <description>
    Sets a backdrop from label to underneath a specific ui-element defined by dest_element_id.
    It will be autosized. The width will be determined from all ui-elements currently visible, the height will be determined by the position and height of dest_element_id.
    
    To use it: determine, which ui-element shall be the lowest inside the rectangle(like one directly above the bottom line of the backdrop.)
    Any ui-element in the same line does the trick. However, you should choose the highest ui-element in the lowest line or the backdrop might be drawn through it.
  </description>
  <parameters>
    string element_id - the label-element, that shall draw a backdrop
    string dest_element_id - the ui-element, that shall be the lowest inside the backdrop(directly above the bottom line of the backdrop)
  </parameters>
  <chapter_context>
    Label
  </chapter_context>
  <tags>label, set, auto, backdrop</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Label_AutoBackdrop: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==false then error("Label_AutoBackdrop: param #1 - must be a valid guid", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Label_AutoBackdrop: param #1 - no such ui-element", 2) end
  if type(dest_element_id)~="string" then error("Label_AutoBackdrop: param #2 - must be a string", 2) end
  if reagirl.IsValidGuid(dest_element_id, true)==false then error("Label_AutoBackdrop: param #2 - must be a valid guid", 2) end
  if reagirl.UI_Element_GetIDFromGuid(dest_element_id)==-1 then error("Label_AutoBackdrop: param #2 - no such ui-element", 2) end
  
  if reagirl.Elements[element_id]["GUI_Element_Type"]:sub(-5, -1)~="Label" then
    error("Label_AutoBackdrop: param #1 - ui-element is not a label", 2)
  else
    --A=reagirl.UI_Element_GetIDFromGuid(dest_element_id)
    --reaper.MB(reagirl.Elements[A]["h"],"",0)
    reagirl.Elements[element_id]["bg"]="auto"
    reagirl.Elements[element_id]["bg_dest"]=dest_element_id
    reagirl.Elements[element_id]["bg_w"]=0
    reagirl.Elements[element_id]["bg_h"]=0
  end
end

function reagirl.Label_GetBackdrop(element_id, width, height)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Label_GetBackdrop</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer width, integer height = reagirl.Label_GetBackdrop(string element_id)</functioncall>
  <description>
    Sets a background-rectangle in line-style for this label. You can use this to "include" different ui-elements of a common context underneath this label.
    That way, you can structure your guis a little better.
    
    Set height to 1 to just have a line before and after the first line of the label-text.
  </description>
  <parameters>
    string element_id - the label-element, whose dragable state you want to get
  </parameters>
  <retvals>
    integer width - the width of the backdrop in pixels
    integer height - the height of the backdrop in pixels
  </retvals>
  <chapter_context>
    Label
  </chapter_context>
  <tags>label, get, backdrop</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Label_GetBackdrop: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==false then error("Label_GetBackdrop: param #1 - must be a valid guid", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Label_GetBackdrop: param #1 - no such ui-element", 2) end
  
  if reagirl.Elements[element_id]["GUI_Element_Type"]:sub(-5, -1)~="Label" then
    error("Label_GetBackdrop: param #1 - ui-element is not a label", 2)
  else
    return reagirl.Elements[element_id]["bg_w"], reagirl.Elements[element_id]["bg_h"]
  end
end

function reagirl.Label_GetDraggable(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Label_GetDraggable</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>boolean draggable = reagirl.Label_GetDraggable(string element_id)</functioncall>
  <description>
    Gets the current draggable state of a label.
    
    When draggable==true: if the user drags the label onto a different ui-element, the run_function of 
    the label will get a second parameter, holding the element_id of the destination-ui-element of the dragging. 
    Otherwise this second parameter will be nil.
    
    Add a note in the meaningOfUI_element of the label of the ui-element, which clarifies, which ui-element is a source 
    and which is a target for dragging operations, so blind users know, which label can be dragged and whereto.
    Otherwise, blind users will not know what to do!
  </description>
  <parameters>
    string element_id - the label-element, whose dragable state you want to get
  </parameters>
  <retvals>
    boolean draggable - true, label is draggable; false, label is not draggable
  </retvals>
  <chapter_context>
    Label
  </chapter_context>
  <tags>label, get, draggable</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Label_GetDraggable: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==false then error("Label_GetDraggable: param #1 - must be a valid guid", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Label_GetDraggable: param #1 - no such ui-element", 2) end
  
  if reagirl.Elements[element_id]["GUI_Element_Type"]:sub(-5, -1)~="Label" then
    error("Label_GetDraggable: param #1 - ui-element is not a label", 2)
  else
    return reagirl.Elements[element_id]["Draggable"]==true
  end
end

function reagirl.Label_SetDraggable(element_id, draggable, destination_element_ids)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Label_SetDraggable</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Label_SetDraggable(string element_id, boolean draggable, table destination_element_ids)</functioncall>
  <description>
    Sets the current draggable state of a label.
    
    When draggable==true: if the user drags the label onto a different ui-element, the run_function of 
    the label will get a second parameter, holding the element_id of the destination-ui-element of the dragging. 
    Otherwise this second parameter will be nil.
    
    Add a note in the meaningOfUI_element of the ui-element, which clarifies, which ui-element is a source 
    and which is a target for dragging operations, so blind users know, which label can be dragged and whereto.
    Otherwise, blind users will not know what to do!
  </description>
  <parameters>
    string element_id - the label-element, whose dragable state you want to set
    boolean draggable - true, label is draggable; false, label is not draggable
    table destination_element_ids - a table with all guids of the ui-elements, where the label can be dragged to
  </parameters>
  <chapter_context>
    Label
  </chapter_context>
  <tags>label, set, draggable</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Label_SetDraggable: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==false then error("Label_SetDraggable: param #1 - must be a valid guid", 2) end
  if type(draggable)~="boolean" then error("Label_SetDraggable: param #2 - must be a boolean", 2) end
  if type(destination_element_ids)~="table" then error("Label_SetDraggable: param #2 - must be a table", 2) end
  for i=1, #destination_element_ids do
    if reagirl.IsValidGuid(destination_element_ids[i], true)==false then
      error("Label_SetDraggable: param #2 - all entries in the table must be valid guids", 2)
    end
  end
  local slot=reagirl.UI_Element_GetIDFromGuid(element_id)
  if slot==-1 then error("Label_SetDraggable: param #1 - no such ui-element") end
  if reagirl.Elements[slot]["GUI_Element_Type"]:sub(-5, -1)~="Label" then 
    error("Label_SetDraggable: param #1 - ui-element is not a label") 
  end
  if #destination_element_ids==0 then error("Label_SetDraggable: param #2 - no elements passed", 2) end
  for i=1, #destination_element_ids do
    if reagirl.UI_Element_GetIDFromGuid(destination_element_ids[i])==-1 then error("Label_SetDraggable: param #2 - element "..i.." is not a valid ui-element", 2) end
  end
  reagirl.Elements[slot]["Draggable"]=draggable
  reagirl.Elements[slot]["DraggableDestinations"]=destination_element_ids
  --reagirl.Elements[slot]["Draggable_DestAccessibility"]=1
  if draggable==true then
    reagirl.Elements[slot]["AccHint"]=reagirl.Elements[slot]["AccHint"].."Choose drag destination with Ctrl+Shift+PageUp and Ctrl+Shift+PageDown and hit ctrl+Shift+Enter to drop it at destination."
  else
    reagirl.Elements[slot]["AccHint"]=reagirl.Elements[slot]["AccHint"]:utf8_sub(1,43)
  end
end

function reagirl.Image_Add(x, y, w, h, image_filename, caption, meaningOfUI_Element, run_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Image_Add</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>string image_guid = reagirl.Image_Add(integer x, integer y, integer w, integer h, string image_filename, string caption, string meaning of UI_Element, optional function run_function)</functioncall>
  <description>
    Adds an image to the gui. This image can run a function when clicked on it. 
    
    Very important: write into meaningOfUI_Element a small description of what the image shows. This will help blind people know, what the image means and what to do with it.
    If you can't know what the image shows(an image viewer for instance) explain what's the purpose of the image like "cover image for the project" or something.
    Keep in mind: blind people can't see the image so any kind of description will help them understand your script.
    
    You can have different images for different scaling-ratios. You put them into the same folder and name them like:
    image-filename.png - 1x-scaling
    image-filename-2x.png - 2x-scaling
    image-filename-3x.png - 3x-scaling
    image-filename-4x.png - 4x-scaling
    image-filename-5x.png - 5x-scaling
    image-filename-6x.png - 6x-scaling
    image-filename-7x.png - 7x-scaling
    image-filename-8x.png - 8x-scaling
    
    If a filename doesn't exist, it reverts to the default one for 1x-scaling.
    
    ReaGirl will obey transparency set in png-images.
  
    Images can be set to draggable. See Image_GetDraggable and Image_SetDraggable for enabling 
    dragging of the image to a destination ui-element.
    
    The run_function will get three parameters: 
     - string element_id - the guid of the image
     - string filename - the filename of the image 
     - optional string dropped_element_id - the element_id of the destination, where the image has been 
    dragged to
  
    You can autoposition the image by setting x and/or y to nil, which will position the new image after the last ui-element.
    To autoposition into the next line, use reagirl.NextLine()
    
    If you want to force the image to be displayed with correct aspect ratio, see Image_KeepAspectRatio.
  </description>
  <parameters>
    optional integer x - the x position of the image in pixels; nil, autoposition after the last ui-element(see description)
    optional integer y - the y position of the image in pixels; nil, autoposition after the last ui-element(see description)
    integer w - the width of the image in pixels(might result in stretched images!)
    integer h - the height of the image in pixels(might result in stretched images!)
    string image_filename - the filename of the imagefile to be shown
    string caption - a descriptive name for the image
    string meaningOfUI_Element - the meaningOfUI_Element of the ui-element(for tooltips and blind users). Make it a sentence that ends with . or ?
    optional function run_function - a function that is run when the image is clicked; will get the image-element-id as first parameter and the image-filename passed as second parameter
  </parameters>
  <retvals>
    string image_guid - a guid that can be used for altering the image-attributes
  </retvals>
  <chapter_context>
    Image
  </chapter_context>
  <tags>image, add</tags>
</US_DocBloc>
--]]
  if x~=nil and math.type(x)~="integer" then error("Image_Add: param #1 - must be either nil or an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("Image_Add: param #2 - must be either nil or an integer", 2) end
  if math.type(w)~="integer" then error("Image_Add: param #3 - must be an integer", 2) end
  if math.type(h)~="integer" then error("Image_Add: param #4 - must be an integer", 2) end
  if type(image_filename)~="string" then error("Image_Add: param #5 - must be a string", 2) end
  if type(caption)~="string" then error("Image_Add: param #6 - must be a string", 2) end
  if type(meaningOfUI_Element)~="string" then error("Image_Add: param #7 - must be a string", 2) end
  if meaningOfUI_Element:sub(-1,-1)~="." and meaningOfUI_Element:sub(-1,-1)~="?" then error("Image_Add: param #7 - must end on a . like a regular sentence.", 2) end
  if run_function==nil then run_function=reagirl.Dummy end
  if run_function~=nil and type(run_function)~="function" then error("Image_Add: param #8 - must be either nil or a function", 2) end
  
  local x,y,slot=reagirl.UI_Element_GetNextXAndYPosition(x, y, "Image_Add")
  --reagirl.UI_Element_NextX_Default=x
  
  table.insert(reagirl.Elements, slot, {})
  reagirl.Elements[slot]["Guid"]=reaper.genGuid("")
  reagirl.Elements[slot]["GUI_Element_Type"]="Image"
  reagirl.Elements[slot]["Description"]=meaningOfUI_Element
  reagirl.Elements[slot]["Name"]=caption
  reagirl.Elements[slot]["Text"]=caption
  reagirl.Elements[slot]["IsDisabled"]=false
  reagirl.Elements[slot]["AccHint"]="Space or left mouse-click to select. "
  reagirl.Elements[slot]["ContextMenu_ACC"]=""
  reagirl.Elements[slot]["DropZoneFunction_ACC"]=""
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["w"]=w
  reagirl.Elements[slot]["h"]=h
  if h>reagirl.NextLine_Overflow then reagirl.NextLine_Overflow=h end
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false
  reagirl.Elements[slot]["func_manage"]=reagirl.Image_Manage
  reagirl.Elements[slot]["func_draw"]=reagirl.Image_Draw
  reagirl.Elements[slot]["run_function"]=run_function
  reagirl.Elements[slot]["Image_Resize"]=resize
  local fb=reagirl.Gui_ReserveImageBuffer()
  if fb==nil then error("Image_Add: All available framebuffers used up, so can't add another Image.", 2) end
  reagirl.Elements[slot]["Image_Storage"]=fb
  reagirl.Elements[slot]["Image_Filename"]=image_filename
  gfx.dest=reagirl.Elements[slot]["Image_Storage"]
  local r,g,b,a=gfx.r,gfx.g,gfx.b,gfx.a
  gfx.set(0)
  gfx.rect(0,0,8192,8192)
  gfx.set(r,g,b,a)
  local scale=reagirl.Window_CurrentScale
  
  if reaper.file_exists(image_filename)==false then error("Image_Add: param #5 - file not found", 2) end
  local path, filename = string.gsub(image_filename, "\\", "/"):match("(.*)(/.*)")
  --if filename==nil then error("Image_Add: param #5 - can't load file")
  if filename==nil then filename=image_filename path="" end
  local filename2, filename3=image_filename:match("(.*)%."), image_filename:match(".*(%..*)")
  if filename2==nil or filename3==nil then
    error("Image_Add: param #4 - filename has no extension", 2)
  end
  if reaper.file_exists(image_filename:match("(.*)%.").."-"..scale.."x"..image_filename:match(".*(%..*)"))==true then
    image_filename=image_filename:match("(.*)%.").."-"..scale.."x"..image_filename:match(".*(%..*)")
  elseif reaper.file_exists(path.."/"..scale.."00/"..filename) then
    image_filename=path.."/"..scale.."00/"..filename
  end
  local AImage=gfx.loadimg(reagirl.Elements[slot]["Image_Storage"], image_filename)
  reagirl.Elements[slot]["Image_Filename_Scaled"]=image_filename
  gfx.dest=-1
  return reagirl.Elements[slot]["Guid"]
end

function reagirl.Image_GetDraggable(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Image_GetDraggable</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>boolean draggable = reagirl.Image_GetDraggable(string element_id)</functioncall>
  <description>
    Gets the current draggable state of an image.
    
    When draggable==true: if the user drags the image onto a different ui-element, the run_function of 
    the image will get a third parameter, holding the element_id of the destination-ui-element of the dragging. 
    Otherwise this third parameter will be nil.
    
    Add a note in the meaningOfUI_element and the name of the image/caption of the ui-element, which clarifies, which ui-element is a source 
    and which is a target for dragging operations, so blind users know, which image can be dragged and whereto.
    Otherwise, blind users will not know what to do!
  </description>
  <parameters>
    string element_id - the image-element, whose dragable state you want to get
  </parameters>
  <retvals>
    boolean draggable - true, image is draggable; false, image is not draggable
  </retvals>
  <chapter_context>
    Image
  </chapter_context>
  <tags>image, get, draggable</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Image_GetDraggable: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==false then error("Image_GetDraggable: param #1 - must be a valid guid", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Image_GetDraggable: param #1 - no such ui-element", 2) end
  
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Image" then
    error("Image_GetDraggable: param #1 - ui-element is not an image", 2)
  else
    return reagirl.Elements[element_id]["Draggable"]==true
  end
end

function reagirl.Image_SetDraggable(element_id, draggable, destination_element_ids)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Image_SetDraggable</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Image_SetDraggable(string element_id, boolean draggable, table destination_element_ids)</functioncall>
  <description>
    Sets the current draggable state of an image.
    
    When draggable==true: if the user drags the image onto a different ui-element, the run_function of 
    the image will get a third parameter, holding the element_id of the destination-ui-element of the dragging. 
    Otherwise this third parameter will be nil.
    
    Add a note in the meaningOfUI_element and the name of the image/caption of the ui-element, which clarifies, which ui-element is a source 
    and which is a target for dragging operations, so blind users know, which image can be dragged and whereto.
    Otherwise, blind users will not know what to do!
  </description>
  <parameters>
    string element_id - the image-element, whose dragable state you want to set
    boolean draggable - true, image is draggable; false, image is not draggable
    table destination_element_ids - a table with all guids of the ui-elements, where the image can be dragged to
  </parameters>
  <chapter_context>
    Image
  </chapter_context>
  <tags>image, set, draggable</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Image_SetDraggable: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==false then error("Image_SetDraggable: param #1 - must be a valid guid", 2) end
  if reagirl.UI_Element_GetType(element_id)~="Image" then error("Image_SetDraggable: param #1 - UI-element is not an image", 2) end
  if type(draggable)~="boolean" then error("Image_SetDraggable: param #2 - must be a boolean", 2) end
  if type(destination_element_ids)~="table" then error("Image_SetDraggable: param #2 - must be a table", 2) end
  for i=1, #destination_element_ids do
    if reagirl.IsValidGuid(destination_element_ids[i], true)==false then
      error("Image_SetDraggable: param #2 - all entries in the table must be valid guids", 2)
    end
  end
  local slot=reagirl.UI_Element_GetIDFromGuid(element_id)
  if slot==-1 then error("Image_SetDraggable: param #1 - no such ui-element") end
  if reagirl.Elements[slot]["GUI_Element_Type"]~="Image" then error("Image_SetDraggable: param #1 - ui-element is not an image") end
  reagirl.Elements[slot]["Draggable"]=draggable
  if #destination_element_ids==0 then error("Image_SetDraggable: param #2 - no elements passed", 2) end
  for i=1, #destination_element_ids do
    if reagirl.UI_Element_GetIDFromGuid(destination_element_ids[i])==-1 then error("Image_SetDraggable: param #2 - element "..i.." is not a valid ui-element", 2) end
  end
  reagirl.Elements[slot]["DraggableDestinations"]=destination_element_ids
  if draggable==true then
    reagirl.Elements[slot]["AccHint"]=reagirl.Elements[slot]["AccHint"].."Choose drag destination with Ctrl+Shift+PageUp and Ctrl+Shift+PageDown and hit ctrl+Shift+Enter to drop it at destination."
  else
    reagirl.Elements[slot]["AccHint"]=reagirl.Elements[slot]["AccHint"]:utf8_sub(1,43)
  end
end



function reagirl.Image_SetDimensions(element_id, width, height)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Image_SetDimensions</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Image_SetDimensions(string element_id, optional integer width, optional integer height)</functioncall>
  <description>
    Sets the width and height of an image.
  </description>
  <parameters>
    string element_id - the guid of the image, whose width and height you want to set
    optional integer width - the new width of the image; negative anchors to right window-edge; nil, keep current width
    optional integer height - the new height of the image; negative anchors to bottom window-edge; nil, keep current height
  </parameters>
  <chapter_context>
    Image
  </chapter_context>
  <tags>image, set, width, height</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Image_SetDimensions: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Image_SetDimensions: param #1 - must be a valid guid", 2) end
  if width~=nil and math.type(width)~="integer" then error("Image_SetDimensions: param #2 - must be either nil or an integer", 2) end
  if height~=nil and math.type(height)~="integer" then error("Image_SetDimensions: param #3 - must be either nil or an integer", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Image_SetDimensions: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Image" then
    error("Image_SetDimensions: param #1 - ui-element is not an image", 2)
  else
    if width~=nil then
      reagirl.Elements[element_id]["w"]=width
    end
    if height~=nil then
      reagirl.Elements[element_id]["h"]=height
    end
    reagirl.Gui_ForceRefresh(18.3)
  end
end

function reagirl.Image_GetDimensions(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Image_GetDimensions</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer width, integer height = reagirl.Image_GetDimensions(string element_id)</functioncall>
  <description>
    Gets the width and height of an image.
  </description>
  <parameters>
    string element_id - the guid of the image, whose disability-state you want to set
  </parameters>
  <retvals>
    integer width - the width of the image; negative anchors to right window-edge
    integer height - the height of the image; negative anchors to bottom window-edge
  </retvals>
  <chapter_context>
    Image
  </chapter_context>
  <tags>image, get, width, height</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Image_GetDimensions: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Image_GetDimensions: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Image_GetDimensions: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Image" then
    error("Image_GetDimensions: param #1 - ui-element is not an image", 2)
  else
    return reagirl.Elements[element_id]["w"], reagirl.Elements[element_id]["h"]
  end
end

function reagirl.Image_ReloadImage_Scaled(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Image_ReloadImage_Scaled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>boolean loading_success = reagirl.Image_ReloadImage_Scaled(string element_id)</functioncall>
  <description>
    Realoads an image. 
  </description>
  <parameters>
    string element_id - the image-element, whose image you want to reload
  </parameters>
  <retvals>
    boolean loading_success - true, loading was successful; false, loading was unsuccessful(missing file, etc)
  </retvals>
  <chapter_context>
    Image
  </chapter_context>
  <tags>image, reload</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Image_ReloadImage_Scaled: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==false then error("Image_ReloadImage_Scaled: param #1 - must be a valid guid", 2) end
  local slot=reagirl.UI_Element_GetIDFromGuid(element_id)
  
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Image_ReloadImage_Scaled: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Image" then
    error("Image_ReloadImage_Scaled: param #1 - ui-element is not an image", 2)
  end
  
  local image_filename=reagirl.Elements[element_id]["Image_Filename"]
  local scale=reagirl.Window_CurrentScale
  
  local path, filename = string.gsub(image_filename, "\\", "/"):match("(.*)(/.*)")
  
  if reaper.file_exists(image_filename:match("(.*)%.").."-"..scale.."x"..image_filename:match(".*(%..*)"))==true then
    image_filename=image_filename:match("(.*)%.").."-"..scale.."x"..image_filename:match(".*(%..*)")
  elseif reaper.file_exists(path.."/"..scale.."00/"..filename) then
    image_filename=path.."/"..scale.."00/"..filename
  end
  
  gfx.dest=reagirl.Elements[element_id]["Image_Storage"]
  
  local image=reagirl.Elements[element_id]["Image_Storage"]
  local r,g,b,a=gfx.r,gfx.g,gfx.b,gfx.a
  gfx.set(0)
  gfx.rect(0,0,8192,8192,1)
  gfx.set(r,g,b,a)
  reagirl.Elements[element_id]["Image_Filename_Scaled"]=image_filename
  local AImage=gfx.loadimg(image, image_filename )
  if AImage==-1 then return false end

  gfx.dest=-1
  return true
end


function reagirl.Image_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  -- drop files for accessibility using a file-requester, after typing ctrl+shift+f
  if element_storage["DropZoneFunction"]~=nil and Key==6 and mouse_cap==12 then
    local retval, filenames = reaper.GetUserFileNameForRead("", "Choose file to drop into "..element_storage["Name"], "")
    reagirl.Window_SetFocus()
    if retval==true then element_storage["DropZoneFunction"](element_storage["Guid"], {filenames}) refresh=true end
  end

  if hovered==true then
    if element_storage["clickable"]==true then
      gfx.setcursor(114)
    elseif element_storage["DraggableDestinations"]~=nil then
      gfx.setcursor(114)
    end
  end
  
  local message
  if selected~="not selected" then
    message=" "
  else
    message=""
  end
  if selected~="not selected" and 
    (Key==32 or Key==13) or (mouse_cap==1 and 
    gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h) 
    and clicked=="FirstCLK" and
    element_storage["run_function"]~=nil then 
    --print("1")
      element_storage["clickstate"]="clicked"
      if element_storage["Draggable"]==true and hovered==true then
        reagirl.Draggable_Element=element_id
        element_storage["mouse_x"]=gfx.mouse_x
        element_storage["mouse_y"]=gfx.mouse_y
        gfx.setcursor(114)
      end
  end
  if element_storage["Draggable"]==true and element_storage.DraggableDestinations~=nil then
    if selected~="not selected" and gfx.mouse_cap==12 and Key==1885828464.0 then
      if element_storage.Draggable_DestAccessibility==nil then 
        element_storage.Draggable_DestAccessibility=1 
      else
        element_storage.Draggable_DestAccessibility=element_storage.Draggable_DestAccessibility+1
        if element_storage.Draggable_DestAccessibility>#element_storage.DraggableDestinations then
          element_storage.Draggable_DestAccessibility=1
        end
      end
      local id = reagirl.UI_Element_GetIDFromGuid(element_storage.DraggableDestinations[element_storage.Draggable_DestAccessibility])
      reagirl.Elements.GlobalAccHoverMessageOld=""
      reagirl.Elements["GlobalAccHoverMessage"]="Dropdestination: "..reagirl.Elements[id]["Name"].." Destination "..element_storage.Draggable_DestAccessibility.." of "..#element_storage.DraggableDestinations
    elseif selected~="not selected" and gfx.mouse_cap==12 and Key==1885824110.0 then
      if element_storage.Draggable_DestAccessibility==nil then 
        element_storage.Draggable_DestAccessibility=1 
      else
        element_storage.Draggable_DestAccessibility=element_storage.Draggable_DestAccessibility-1
        if element_storage.Draggable_DestAccessibility<1 then
          element_storage.Draggable_DestAccessibility=#element_storage.DraggableDestinations
        end
      end
      local id = reagirl.UI_Element_GetIDFromGuid(element_storage.DraggableDestinations[element_storage.Draggable_DestAccessibility])
      reagirl.Elements.GlobalAccHoverMessageOld=""
      reagirl.Elements["GlobalAccHoverMessage"]="Dropdestination: "..reagirl.Elements[id]["Name"].." Destination "..element_storage.Draggable_DestAccessibility.." of "..#element_storage.DraggableDestinations
    elseif selected~="not selected" and gfx.mouse_cap==12 and Key==13 then
      if element_storage.Draggable_DestAccessibility==nil then 
        element_storage.Draggable_DestAccessibility=1 
      end
      element_storage["run_function"](element_storage["Guid"], element_storage["Image_Filename"], element_storage.DraggableDestinations[element_storage.Draggable_DestAccessibility]) 
      local id = reagirl.UI_Element_GetIDFromGuid(element_storage.DraggableDestinations[element_storage.Draggable_DestAccessibility])
      reagirl.Elements["GlobalAccHoverMessage"]="Dropped onto "..reagirl.Elements[id]["Name"]
    end
  end
  if element_storage["clickstate"]=="clicked" and mouse_cap&1==0 then
    element_storage["clickstate"]=nil
    if element_storage["Draggable"]==true and (element_storage["mouse_x"]~=gfx.mouse_x or element_storage["mouse_y"]~=gfx.mouse_y) then
      for i=1, #element_storage["DraggableDestinations"] do
        if reagirl.UI_Element_IsElementAtMousePosition(element_storage["DraggableDestinations"][i])==true then
          element_storage["run_function"](element_storage["Guid"], element_storage["Image_Filename"], element_storage["DraggableDestinations"][i]) 
        end
      end
    else
      element_storage["run_function"](element_storage["Guid"], element_storage["Image_Filename"]) 
    end
    reagirl.Draggable_Element=nil
  end
  
  local draggable, draggable2 = "", ""
  --if element_storage["Draggable"]==true then draggable="Draggable,. " draggable2=" Use Ctrl plus alt plus Tab and Ctrl plus alt plus Tab to select the dragging-destinations and ctrl plus alt plus enter to drop the image into the dragging-destination." else draggable="" end
  return draggable..message
end

function reagirl.Image_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if w<0 or h<0 then return end
  -- no docs in API-docs
  local scale=reagirl.Window_CurrentScale
  -- store changes
  local olddest, r, g, b, a, oldmode, oldx, oldy
  olddest=gfx.dest
  r=gfx.r
  g=gfx.g
  b=gfx.b
  a=gfx.a
  oldmode=gfx.mode
  oldx,oldy=gfx.x, gfx.y
  
  -- blit the image
  gfx.set(0)
  gfx.x=x
  gfx.y=y
  
  gfx.dest=-1
  local imgw, imgh = gfx.getimgdim(element_storage["Image_Storage"])
  
  if element_storage.KeepAspectRatio==true then
    local x1,y1=gfx.getimgdim(element_storage["Image_Storage"])
    local ratio
    local ratiox=((100/x1)*w)/100
    local ratioy=((100/y1)*h)/100
    if ratiox<ratioy then ratio=ratiox else ratio=ratioy end
    gfx.x=x+(math.floor((w-(x1*ratio)))/2)
    gfx.y=y+(math.floor((h-(y1*ratio)))/2)
    gfx.blit(element_storage["Image_Storage"], ratio, 0)
  else    
    gfx.blit(element_storage["Image_Storage"],1,0,0,0,imgw,imgh,x,y,w,h,0,0)
  end
  -- revert changes
  gfx.r,gfx.g,gfx.b,gfx.a=r,g,b,a
  gfx.mode=oldmode
  gfx.x=oldx
  gfx.y=oldy
  gfx.dest=olddest
end

function reagirl.Image_KeepAspectRatio(element_id, state)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Image_KeepAspectRatio</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Image_KeepAspectRatio(string element_id, boolean state)</functioncall>
  <description>
    Set if the image shall keep its aspect ratio when shown.
  </description>
  <parameters>
    string element_id - the guid of the image, whose aspect ratio you want to set
    boolean state - true, keep aspect ratio; false, stretch to meet dimensions of the image
  </parameters>
  <chapter_context>
    Image
  </chapter_context>
  <tags>image, set, keep, aspect ratio</tags>
</US_DocBloc>
--]]  
  if type(element_id)~="string" then error("Image_KeepAspectRatio: param #1 - must be a string", 2) end
  if type(state)~="boolean" then error("Image_KeepAspectRatio: param #2 - must be a boolean", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Image_KeepAspectRatio: param #1 - must be a valid guid", 2) end
  local el_id=element_id
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Image_KeepAspectRatio: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Image" then
    error("Image_KeepAspectRatio: param #1 - ui-element is not an image", 2)
  else
    reagirl.Elements[element_id]["KeepAspectRatio"]=state    
  end
end
--mespotine
function reagirl.Image_GetImageFilename(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Image_GetImageFilename</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>string filename, string filename_scaled = reagirl.Image_GetImageFilename(string element_id)</functioncall>
  <description>
    Returns the filename of the currently loaded image.
  </description>
  <parameters>
    string element_id - the guid of the image whose filename you want to get
  </parameters>
  <retvals>
    string filename - the filename of the currently loaded image
    string filename_scale - if the gui is scaled>1, this will hold the filename of the loaded scaled image
  </retvals>
  <chapter_context>
    Image
  </chapter_context>
  <tags>image, get, filename</tags>
</US_DocBloc>
--]]  
  if type(element_id)~="string" then error("Image_GetImageFilename: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Image_GetImageFilename: param #1 - must be a valid guid", 2) end
  local el_id=element_id
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Image_GetImageFilename: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Image" then
    error("Image_GetImageFilename: param #1 - ui-element is not an image", 2)
  else
    return reagirl.Elements[element_id]["Image_Filename"], reagirl.Elements[element_id]["Image_Filename_Scaled"]
  end
end

function reagirl.Image_ClearToColor(element_id, r, g, b)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Image_ClearToColor</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Image_ClearToColor(string element_id, integer r, integer g, integer b)</functioncall>
  <description>
    Clears the image with a set r-g-b-color. It also clears the previously loaded image-filename.
  </description>
  <parameters>
    string element_id - the guid of the image
    integer r - the red-value 0-255
    integer g - the green-value 0-255
    integer b - the blue-value 0-255
  </parameters>
  <chapter_context>
    Image
  </chapter_context>
  <tags>image, clear, to color</tags>
</US_DocBloc>
--]]  
  if type(element_id)~="string" then error("Image_ClearToColor: param #1 - must be a string", 2) end
  if math.type(r)~="integer" then error("Image_ClearToColor: param #2 - must be an integer", 2) end
  if math.type(g)~="integer" then error("Image_ClearToColor: param #2 - must be an integer", 2) end
  if math.type(b)~="integer" then error("Image_ClearToColor: param #2 - must be an integer", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Image_ClearToColor: param #1 - must be a valid guid", 2) end
  local el_id=element_id
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Image_ClearToColor: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Image" then
    error("Image_ClearToColor: param #1 - ui-element is not an image", 2)
  else
    local oldgfx_dest=gfx.dest
    local oldr, oldg, oldb = gfx.r, gfx.g, gfx.b
    gfx.dest=reagirl.Elements[element_id]["Image_Storage"]
    gfx.set(r/255, g/255, b/255, 1)
    local w,h=gfx.getimgdim(gfx.dest)
    gfx.rect(0, 0, w, h, 1)
    gfx.r=oldr
    gfx.g=oldg
    gfx.b=oldb
    gfx.dest=oldgfx_dest
    reagirl.Elements[element_id]["Image_Filename"]=""
    reagirl.Elements[element_id]["Image_Filename_Scaled"]=""
  end
end

function reagirl.Image_Load(element_id, image_filename)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Image_Load</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Image_Load(string element_id, string image_filename)</functioncall>
  <description>
    Loads a new image-file of an existing image in the gui. 
    
    You can have different images for different scaling-ratios. You put them into the same folder and name them like:
    image-filename.png - 1x-scaling
    image-filename-2x.png - 2x-scaling
    image-filename-3x.png - 3x-scaling
    image-filename-4x.png - 4x-scaling
    image-filename-5x.png - 5x-scaling
    image-filename-6x.png - 6x-scaling
    image-filename-7x.png - 7x-scaling
    image-filename-8x.png - 8x-scaling
    
    If a scaled-filename doesn't exist, the function reverts to the default one for 1x-scaling.
  </description>
  <parameters>
    string element_id - the guid of the image
    string image_filename - the filename of the imagefile to be loaded
  </parameters>
  <chapter_context>
    Image
  </chapter_context>
  <tags>image, load new image</tags>
</US_DocBloc>
--]]  
  if type(element_id)~="string" then error("Image_Load: param #1 - must be a string", 2) end
  if type(image_filename)~="string" then error("Image_Load: param #2 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Image_Load: param #1 - must be a valid guid", 2) end
  if reaper.file_exists(image_filename)==false then error("Image_Load: param #2 - file not found", 2) end
  local el_id=element_id
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Image_Load: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Image" then
    error("Image_Load: param #1 - ui-element is not an image", 2)
  else
    if reaper.file_exists(image_filename)==false then error("Image_Add: param #5 - file not found", 2) end
    
    local filename2, filename3=image_filename:match("(.*)%."), image_filename:match(".*(%..*)")
    if filename2==nil or filename3==nil then
      error("Image_Add: param #4 - filename has no extension", 2)
    end
    
    reagirl.Elements[element_id]["Image_Filename"]=image_filename
    
    reagirl.Image_ReloadImage_Scaled(el_id)
    reagirl.Gui_ForceRefresh(32)
  end
end



function reagirl.Background_GetSetColor(is_set, r, g, b)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Background_GetSetColor</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer red, integer green, integer blue = reagirl.Background_GetSetColor(boolean is_set, integer red, integer green, integer blue)</functioncall>
  <description>
    Gets/Sets the color of the background.
  </description>
  <parameters>
    boolean is_set - true, set the new background-color; false, only retrieve the current background-color
    integer red - the new red-color; 0-255
    integer green - the new green-color; 0-255
    integer blue - the new blue-color; 0-255
  </parameters>
  <retvals>
    integer red - the current red-color of the background
    integer green - the current green-color of the background
    integer blue - the current blue-color of the background
  </retvals>
  <chapter_context>
    Background
  </chapter_context>
  <tags>background, set, get, color, red, gree, blue</tags>
</US_DocBloc>
--]]
  if type(is_set)~="boolean" then error("Background_GetSetColor: param #1 - must be a boolean", 2) end
  if math.type(r)~="integer" then error("Background_GetSetColor: param #2 - must be an integer", 2) end
  if math.type(g)~="integer" then error("Background_GetSetColor: param #3 - must be an integer", 2) end
  if math.type(b)~="integer" then error("Background_GetSetColor: param #4 - must be an integer", 2) end

  if reagirl.Elements==nil then reagirl.Elements={} end
  if is_set==true and r~=nil and g~=nil and b~=nil then
    reagirl["WindowBackgroundColorR"],reagirl["WindowBackgroundColorG"],reagirl["WindowBackgroundColorB"]=r/255, g/255, b/255
  else
    return math.floor(reagirl["WindowBackgroundColorR"]*255), math.floor(reagirl["WindowBackgroundColorG"]*255), math.floor(reagirl["WindowBackgroundColorB"]*255)
  end
end


function reagirl.Background_GetSetImage(filename, x, y, scaled, fixed_x, fixed_y)
-- unfinished
--[[
<  US _DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Background_GetSetImage</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>boolean imageload_success = reagirl.Background_GetSetImage(string filename, integer x, integer y, boolean scaled, boolean fixed_x, boolean fixed_y)</functioncall>
  <description>
    Gets/Sets the background-image.
  </description>
  <parameters>
    string filename - the filename of the new background-image
    integer x - the x-position of the background-image
    integer y - the y-position of the background-image
    boolean scaled - true, scale the image to the window-size; false, don't scale image
    boolean fixed_x - true, don't scroll the image on x-axis; false, scroll background-image on x-axis
    boolean fixed_y - true, don't scroll the image on y-axix; false, scroll background-image on y-axis
  </parameters>
  <retvals>
    boolean imageload_success - true, loading of the image was successful; false, loading of the image was unsuccessful
  </retvals>
  <chapter_context>
    Background
  </chapter_context>
  <tags>background, set, background image</tags>
</US_DocBloc>
--]]
  if type(filename)~="string" then error("Background_GetSetImage: param #1 - must be a string", 2) end
  if math.type(x)~="integer"  then error("Background_GetSetImage: param #2 - must be an integer", 2) end
  if math.type(y)~="integer"  then error("Background_GetSetImage: param #3 - must be an integer", 2) end
  if type(scaled)~="boolean"  then error("Background_GetSetImage: param #4 - must be a boolean", 2) end
  if type(fixed_x)~="boolean" then error("Background_GetSetImage: param #5 - must be an boolean", 2) end
  if type(fixed_y)~="boolean" then error("Background_GetSetImage: param #6 - must be an boolean", 2) end
  if reagirl.MaxImage==nil then reagirl.MaxImage=1 end
  reagirl.Background_FixedX=fixed_x
  reagirl.Background_FixedY=fixed_y
  reagirl.MaxImage=reagirl.MaxImage+1
  local AImage=gfx.loadimg(reagirl.MaxImage, filename)
  if AImage==-1 then return false end
  local se={reaper.my_getViewport(0,0,0,0, 0,0,0,0, false)}
  reagirl.ResizeImageKeepAspectRatio(reagirl.MaxImage, se[3], se[4], bg_r, bg_g, bg_b)
  if reagirl.DecorativeImages==nil then
    reagirl.DecorativeImages={}
    reagirl.DecorativeImages["Background"]=reagirl.MaxImage
    reagirl.DecorativeImages["Background_Scaled"]=scaled
    reagirl.DecorativeImages["Background_Centered"]=centered
    reagirl.DecorativeImages["Background_x"]=x
    reagirl.DecorativeImages["Background_y"]=y
  end
  return true
end



function reagirl.Background_DrawImage()
  if reagirl.DecorativeImages==nil then return end
  local xoffset=0
  local yoffset=0
  if reagirl.Background_FixedX==false then xoffset=reagirl.MoveItAllRight end
  if reagirl.Background_FixedY==false then yoffset=reagirl.MoveItAllUp end
  gfx.dest=-1
  local scale=1
  local x,y=gfx.getimgdim(reagirl.DecorativeImages["Background"])
  local ratiox=((100/x)*gfx.w)/100
  local ratioy=((100/y)*gfx.h)/100
  if reagirl.DecorativeImages["Background_Scaled"]==true then
    if ratiox<ratioy then scale=ratiox else scale=ratioy end
    if x<gfx.w and y<gfx.h then scale=1 end
  end
  gfx.x=reagirl.DecorativeImages["Background_x"]+xoffset
  gfx.y=reagirl.DecorativeImages["Background_y"]+yoffset
  gfx.blit(reagirl.DecorativeImages["Background"], scale, 0)
end

function reagirl.Window_ForceMinSize()
  if reagirl.Gui_IsOpen()==false then return end
  if reagirl.Window_ForceMinSize_Toggle~=true then return end
  local scale=reagirl.Window_CurrentScale
  local h,w
  if gfx.w<(reagirl.Window_MinW*scale)-1 then w=reagirl.Window_MinW*scale else w=gfx.w end
  if gfx.h<(reagirl.Window_MinH*scale)-1 then h=reagirl.Window_MinH*scale else h=gfx.h end
  
  if gfx.w==w and gfx.h==h then return end
  gfx.init("", w, h)
  reagirl.Gui_ForceRefresh(33)
end

function reagirl.Window_ForceMaxSize()
  if reagirl.Gui_IsOpen()==false then return end
  if reagirl.Window_ForceMaxSize_Toggle~=true then return end
  local scale=reagirl.Window_CurrentScale
  local h,w
  if gfx.w>reagirl.Window_MaxW*scale then w=reagirl.Window_MaxW*scale else w=gfx.w end
  if gfx.h>reagirl.Window_MaxH*scale then h=reagirl.Window_MaxH*scale else h=gfx.h end
  
  if gfx.w==w and gfx.h==h then return end
  gfx.init("", w, h)
  reagirl.Gui_ForceRefresh(34)
end

function reagirl.Gui_ForceRefresh(place)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_ForceRefresh</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Gui_ForceRefresh()</functioncall>
  <description>
    Forces a refresh of the gui.
  </description>
  <chapter_context>
    Gui
  </chapter_context>
  <tags>gui, force, refresh</tags>
</US_DocBloc>
--]]
  reagirl.Gui_ForceRefreshState=true
  reagirl.Gui_ForceRefresh_place=place
  reagirl.Gui_ForceRefresh_time=reaper.time_precise()
end

function reagirl.Window_ForceSize_Minimum(MinW, MinH)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Window_ForceSize_Minimum</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Window_ForceSize_Minimum(integer MinW, integer MinH)</functioncall>
  <description>
    Sets a minimum window size that will be enforced by ReaGirl.
  </description>
  <parameters>
    integer MinW - the minimum window-width in pixels
    integer MinH - the minimum window-height in pixels
  </parameters>
  <chapter_context>
    Window
  </chapter_context>
  <tags>window, set, force size, minimum</tags>
</US_DocBloc>
--]]
  if math.type(MinW)~="integer" then error("Window_ForceSize_Minimum: MinW - must be an integer", 2) end
  if math.type(MinH)~="integer" then error("Window_ForceSize_Minimum: MinH - must be an integer", 2) end
  reagirl.Window_ForceMinSize_Toggle=true
  reagirl.Window_MinW=MinW
  reagirl.Window_MinH=MinH
end

function reagirl.Window_ForceSize_Maximum(MaxW, MaxH)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Window_ForceSize_Maximum</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Window_ForceSize_Maximum(integer MaxW, integer MaxH)</functioncall>
  <description>
    Sets a maximum window size that will be enforced by ReaGirl.
  </description>
  <parameters>
    integer MaxW - the maximum window-width in pixels
    integer MaxH - the maximum window-height in pixels
  </parameters>
  <chapter_context>
    Window
  </chapter_context>
  <tags>window, set, force size, maximum</tags>
</US_DocBloc>
--]]
  if math.type(MaxW)~="integer" then error("Window_ForceSize_Maximum: MinW - must be an integer", 2) end
  if math.type(MaxH)~="integer" then error("Window_ForceSize_Maximum: MinH - must be an integer", 2) end
  reagirl.Window_ForceMaxSize_Toggle=true
  reagirl.Window_MaxW=MaxW
  reagirl.Window_MaxH=MaxH
end


function reagirl.UI_Element_ScrollX(deltapx_x)
  if deltapx_x>0 and reagirl.MoveItAllRight_Delta<0 then reagirl.MoveItAllRight_Delta=0 end
  if deltapx_x<0 and reagirl.MoveItAllRight_Delta>0 then reagirl.MoveItAllRight_Delta=0 end
  reagirl.MoveItAllRight_Delta=reagirl.MoveItAllRight_Delta+deltapx_x
end

function reagirl.UI_Element_ScrollY(deltapx_y)
  if deltapx_y>0 and reagirl.MoveItAllUp_Delta<0 then reagirl.MoveItAllUp_Delta=0 end
  if deltapx_y<0 and reagirl.MoveItAllUp_Delta>0 then reagirl.MoveItAllUp_Delta=0 end
  reagirl.MoveItAllUp_Delta=reagirl.MoveItAllUp_Delta+deltapx_y
end

function reagirl.UI_Element_SmoothScroll(Smoothscroll) -- parameter for debugging only
  --reagirl.SmoothScroll=Smoothscroll -- for debugging only
  --Boundary=reaper.time_precise() -- for debugging only
  -- scroll y position
  
  --if the boundary is bigger than screen, we need to scroll
  if reagirl.BoundaryY_Max>gfx.h then
    
    -- Scrolllimiter bottom
    if reagirl.MoveItAllUp_Delta<0 and reagirl.BoundaryY_Max+reagirl.MoveItAllUp-gfx.h<=0 then 
      reagirl.MoveItAllUp_Delta=0 
      reagirl.MoveItAllUp=gfx.h-reagirl.BoundaryY_Max
      reagirl.Gui_ForceRefresh(35) 
    end
    
    -- Scrolllimiter top
    if reagirl.MoveItAllUp_Delta>0 and reagirl.BoundaryY_Min+reagirl.MoveItAllUp>=0 then 
      reagirl.MoveItAllUp_Delta=0 
      reagirl.MoveItAllUp=0 
      reagirl.Gui_ForceRefresh(36) 
    end
    
    if reagirl.MoveItAllUp_Delta>0 then 
      reagirl.MoveItAllUp_Delta=reagirl.MoveItAllUp_Delta-1
      if reagirl.MoveItAllUp_Delta<0 then reagirl.MoveItAllUp_Delta=0 end
    elseif reagirl.MoveItAllUp_Delta<0 then 
      reagirl.MoveItAllUp_Delta=reagirl.MoveItAllUp_Delta+1
      if reagirl.MoveItAllUp_Delta>0 then reagirl.MoveItAllUp_Delta=0 end
    end
    if reagirl.BoundaryY_Max>gfx.h then
      reagirl.MoveItAllUp=math.floor(reagirl.MoveItAllUp+reagirl.MoveItAllUp_Delta)
    end
  elseif reagirl.MoveItAllUp_Delta<0 then
    reagirl.MoveItAllUp_Delta=reagirl.MoveItAllUp_Delta+1 --reagirl.MoveItAllUp_Delta=0
  elseif reagirl.BoundaryY_Max<=gfx.h then
    reagirl.MoveItAllUp=0
    reagirl.MoveItAllUp_Delta=0
  end
  if reagirl.MoveItAllUp_Delta>-1 and reagirl.MoveItAllUp_Delta<1 then reagirl.MoveItAllUp_Delta=0 end
  
  -- scroll x-position
  if reagirl.BoundaryX_Max>gfx.w then
    if reagirl.MoveItAllRight_Delta<0 and reagirl.BoundaryX_Max+reagirl.MoveItAllRight-gfx.w<=0 then reagirl.MoveItAllRight_Delta=0 reagirl.MoveItAllRight=gfx.w-reagirl.BoundaryX_Max reagirl.Gui_ForceRefresh(37) end
    if reagirl.MoveItAllRight_Delta>0 and reagirl.BoundaryX_Min+reagirl.MoveItAllRight>=0 then reagirl.MoveItAllRight_Delta=0 reagirl.MoveItAllRight=0 reagirl.Gui_ForceRefresh(38) end
    if reagirl.BoundaryX_Max>gfx.w and reagirl.MoveItAllRight_Delta>0 then 
      reagirl.MoveItAllRight_Delta=reagirl.MoveItAllRight_Delta-1
      if reagirl.MoveItAllRight_Delta<0 then reagirl.MoveItAllRight_Delta=0 end
    elseif reagirl.BoundaryX_Max>gfx.w and reagirl.MoveItAllRight_Delta<0 then 
      reagirl.MoveItAllRight_Delta=reagirl.MoveItAllRight_Delta+1
      if reagirl.MoveItAllRight_Delta>0 then reagirl.MoveItAllRight_Delta=0 end
    end
    if reagirl.BoundaryX_Max>gfx.w then
      reagirl.MoveItAllRight=math.floor(reagirl.MoveItAllRight+reagirl.MoveItAllRight_Delta)
    end
  elseif reagirl.MoveItAllRight>0 and reagirl.MoveItAllRight_Delta<0 then
    refreshh_1=reagirl.MoveItAllRight
    refreshh_2=reagirl.MoveItAllRight_Delta
    reagirl.MoveItAllRight_Delta=reagirl.MoveItAllRight_Delta+1 --reagirl.MoveItAllUp_Delta=0
  elseif reagirl.BoundaryX_Max<=gfx.w then
    reagirl.MoveItAllRight=0
    reagirl.MoveItAllRight_Delta=0
  end
  if reagirl.MoveItAllRight_Delta>-1 and reagirl.MoveItAllRight_Delta<1 then reagirl.MoveItAllRight_Delta=0 end
  
  if reagirl.MoveItAllRight_Delta~=0 or reagirl.MoveItAllUp_Delta~=0 then reagirl.Gui_ForceRefresh(reagirl.MoveItAllUp_Delta) end
end

function reagirl.UI_Elements_Boundaries()
  -- sets the boundaries of the maximum scope of all ui-elements into reagirl.Boundary[X|Y]_[Min|Max]-variables.
  -- these can be used to calculate scrolling including stopping at the minimum, maximum position of the ui-elements,
  -- so you don't scroll forever.
  -- This function only calculates non-locked ui-element-directions
  
  --[[
  -- Democode for Gui_ Manage, that scrolls via arrow-keys including "scroll lock" when reaching end of ui-elements.
  if Key==30064 then 
    -- Up
    if reagirl.BoundaryY_Max+reagirl.MoveItAllUp>gfx.h then 
      reagirl.MoveItAllUp=reagirl.MoveItAllUp-10 
      reagirl.Gui_ForceRefresh(40) 
    end
  end
  if Key==1685026670 then 
    -- Down
    if reagirl.BoundaryY_Min+reagirl.MoveItAllUp<0 then 
      reagirl.MoveItAllUp=reagirl.MoveItAllUp+10 
      reagirl.Gui_ForceRefresh(41)   
    end
  end
  if Key==1818584692.0 then 
    -- left
    if reagirl.BoundaryX_Min+reagirl.MoveItAllRight<0 then 
      reagirl.MoveItAllRight=reagirl.MoveItAllRight+10 
      reagirl.Gui_ForceRefresh(42) 
    end
  end
  if Key==1919379572.0 then 
    if reagirl.BoundaryX_Max+reagirl.MoveItAllRight>gfx.w then 
      reagirl.MoveItAllRight=reagirl.MoveItAllRight-10 
      reagirl.Gui_ForceRefresh(43) 
    end
  end
  --]]
  
  local scale=reagirl.Window_CurrentScale
  local minx, miny, maxx, maxy = 2147483648, 2147483648, -2147483648, -2147483648
  local oldmaxx=reagirl.BoundaryX_Max
  local oldmaxy=reagirl.BoundaryY_Max
  local MaxW, MAXH
  -- first the x position
  for i=1, #reagirl.Elements do
    if reagirl.Elements[i].hidden~=true then
      if reagirl.Elements[i].sticky_x==false or reagirl.Elements[i].sticky_y==false then
        local x2, y2, w2, h2
        if reagirl.Elements[i]["x"]*scale<0 then x2=gfx.w+reagirl.Elements[i]["x"]*scale else x2=reagirl.Elements[i]["x"]*scale end
        if reagirl.Elements[i]["y"]*scale<0 then y2=gfx.h+reagirl.Elements[i]["y"]*scale else y2=reagirl.Elements[i]["y"]*scale end
        if reagirl.Elements[i]["w"]*scale<0 then w2=gfx.w-x2+reagirl.Elements[i]["w"]*scale else w2=reagirl.Elements[i]["w"]*scale end
        if reagirl.Elements[i]["GUI_Element_Type"]=="ComboBox" then if w2<20 then w2=20 end end -- Correct for DropDownMenu?
        if reagirl.Elements[i]["h"]*scale<0 then h2=gfx.h-y2+reagirl.Elements[i]["h"]*scale else h2=reagirl.Elements[i]["h"]*scale end
        if x2<minx then minx=x2 end
        if w2+x2>maxx then maxx=w2+x2 MaxW=w2 end
        
        if y2<miny then miny=y2 end
        if h2+y2>maxy then maxy=h2+y2 MAXH=h2 end
        --MINY=miny
        --MAXY=maxy
      end
    end
  end
  --gfx.line(minx+reagirl.MoveItAllRight,miny+reagirl.MoveItAllUp, maxx+reagirl.MoveItAllRight, maxy+reagirl.MoveItAllUp, 1)
  --gfx.line(minx+reagirl.MoveItAllRight,miny+reagirl.MoveItAllUp, minx+reagirl.MoveItAllRight, maxy+reagirl.MoveItAllUp)
  
  local scale_offset
  if scale==1 then scale_offset=50
  elseif scale==2 then scale_offset=150
  elseif scale==3 then scale_offset=300
  elseif scale==4 then scale_offset=450
  elseif scale==5 then scale_offset=550
  elseif scale==6 then scale_offset=650
  elseif scale==7 then scale_offset=750
  elseif scale==8 then scale_offset=850
  end
  --]]
  
  reagirl.BoundaryX_Min=0--minx
  reagirl.BoundaryX_Max=maxx--+15*scale
  reagirl.BoundaryY_Min=0--miny
  reagirl.BoundaryY_Max=maxy+15*scale -- +scale_offset
  --gfx.rect(reagirl.BoundaryX_Min, reagirl.BoundaryY_Min+reagirl.MoveItAllUp, 10, 10, 1)
  --gfx.rect(reagirl.BoundaryX_Max-20, reagirl.BoundaryY_Max+reagirl.MoveItAllUp-20, 10, 10, 1)
  --gfx.drawstr(reagirl.MoveItAllUp.." "..reagirl.BoundaryY_Min)
  
  local tab_offset_x=15*scale
  local tab_offset_y=15*scale
  if gfx.w<reagirl.BoundaryX_Max-tab_offset_x then tab_offset_y=0 end
  if gfx.h<reagirl.BoundaryY_Max-tab_offset_y then tab_offset_x=0 end
  
  if gfx.w<reagirl.BoundaryX_Max-tab_offset_x then
    reagirl.Elements[#reagirl.Elements-4].hidden=nil
    reagirl.Elements[#reagirl.Elements-5].hidden=nil
    reagirl.Elements[#reagirl.Elements].hidden=nil
    reagirl.BoundaryX_Max=reagirl.BoundaryX_Max+15*scale
  else
    reagirl.Elements[#reagirl.Elements-4].hidden=true
    reagirl.Elements[#reagirl.Elements-5].hidden=true
    reagirl.Elements[#reagirl.Elements].hidden=true
  end
  
  if gfx.h<reagirl.BoundaryY_Max-tab_offset_y then
    reagirl.Elements[#reagirl.Elements-3].hidden=nil
    reagirl.Elements[#reagirl.Elements-2].hidden=nil
    reagirl.Elements[#reagirl.Elements-1].hidden=nil
    reagirl.BoundaryY_Max=reagirl.BoundaryY_Max+15*scale
  else
    reagirl.Elements[#reagirl.Elements-3].hidden=true
    reagirl.Elements[#reagirl.Elements-2].hidden=true
    reagirl.Elements[#reagirl.Elements-1].hidden=true
  end
  
  if oldmaxx~=reagirl.BoundaryX_Max or oldmaxy~=reagirl.BoundaryY_Max then
    reagirl.Gui_ForceRefresh(12345)
  end
end

function reagirl.Gui_GetBoundaries()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_GetBoundaries</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer minimum_visible_x, integer maximum_visible_x, integer minimum_visible_y, integer maximum_visible_y, integer minimum_all_x, integer maximum_all_x, integer maximum_all_y, integer maximum_all_y = reagirl.Gui_GetBoundaries()</functioncall>
  <description>
    Returns the current boundaries of the ui-elements. Means, from 0 to the the farthest ui-element-width/height at right/bottom edge of the gui-window.
    These boundaries are where the scrolling happens. If the boundaries are smaller/equal window size, all ui-elements are visible in the window and therefore no scrolling happens.
    
    The first four retvals return the boundaries of all visible ui-elements, the last four return the boundaries of all ui-elements, including invisible.
    Sticky ui-elements will be ignored.
  </description>
  <retals>
    integer minmum_visible_x - the minimum x of the currently visible ui-elements(usually 0)
    integer maximum_visible_x - the maximum x of the currently visible ui-elements
    integer minmum_visible_y - the minimum y of the currently visible ui-elements(usually 0)
    integer maximum_visible_y - the maximum y of the currently visible ui-elements
    integer minmum_all_x - the minimum x of all ui-elements(usually 0)
    integer maximum_all_x - the maximum x of all ui-elements
    integer minmum_all_y - the minimum y of all visible ui-elements(usually 0)
    integer maximum_all_y - the maximum y of all visible ui-elements
  </retvals>
  <chapter_context>
    Gui
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gui, functions, get, boundaries</tags>
</US_DocBloc>
]]
  local minx=0
  local maxx=0
  local miny=0
  local maxy=0
  local scale=reagirl.Window_GetCurrentScale()
  for i=1, #reagirl.Elements do
    if reagirl.Elements[i].hidden~=true then
      if reagirl.Elements[i].sticky_x==false or reagirl.Elements[i].sticky_y==false then
        local x2, y2, w2, h2
        if reagirl.Elements[i]["x"]*scale<0 then x2=gfx.w+reagirl.Elements[i]["x"]*scale else x2=reagirl.Elements[i]["x"]*scale end
        if reagirl.Elements[i]["y"]*scale<0 then y2=gfx.h+reagirl.Elements[i]["y"]*scale else y2=reagirl.Elements[i]["y"]*scale end
        if reagirl.Elements[i]["w"]*scale<0 then w2=gfx.w-x2+reagirl.Elements[i]["w"]*scale else w2=reagirl.Elements[i]["w"]*scale end
        if reagirl.Elements[i]["GUI_Element_Type"]=="ComboBox" then if w2<20 then w2=20 end end -- Correct for DropDownMenu?
        if reagirl.Elements[i]["h"]*scale<0 then h2=gfx.h-y2+reagirl.Elements[i]["h"]*scale else h2=reagirl.Elements[i]["h"]*scale end
        if x2<minx then minx=x2 end
        if w2+x2>maxx then maxx=w2+x2 end
        
        if y2<miny then miny=y2 end
        if h2+y2>maxy then maxy=h2+y2 end
        --MINY=miny
        --MAXY=maxy
      end
    end
  end
  local minx2=0
  local maxx2=0
  local miny2=0
  local maxy2=0
  for i=1, #reagirl.Elements do
    if reagirl.Elements[i].sticky_x==false or reagirl.Elements[i].sticky_y==false then
      local x2, y2, w2, h2
      
      if reagirl.Elements[i]["x"]*scale<0 then x2=gfx.w+reagirl.Elements[i]["x"]*scale else x2=reagirl.Elements[i]["x"]*scale end
      if reagirl.Elements[i]["y"]*scale<0 then y2=gfx.h+reagirl.Elements[i]["y"]*scale else y2=reagirl.Elements[i]["y"]*scale end
      if reagirl.Elements[i]["w"]*scale<0 then w2=gfx.w-x2+reagirl.Elements[i]["w"]*scale else w2=reagirl.Elements[i]["w"]*scale end
      if reagirl.Elements[i]["GUI_Element_Type"]=="ComboBox" then if w2<20 then w2=20 end end -- Correct for DropDownMenu?
      if reagirl.Elements[i]["h"]*scale<0 then h2=gfx.h-y2+reagirl.Elements[i]["h"]*scale else h2=reagirl.Elements[i]["h"]*scale end
      if x2<minx2 then minx2=x2 end
      if w2+x2>maxx2 then maxx2=w2+x2 end
      
      if y2<miny2 then miny2=y2 end
      if h2+y2>maxy2 then maxy2=h2+y2 end
      --MINY=miny
      --MAXY=maxy
      --reaper.MB(maxx, i, 0)
    end
  end
  -- mespotine Tudelu
  local h3=maxy
  local w3=maxx
  
  if reagirl.Tabs_Count~=nil then
    local x2=reagirl.Elements[reagirl.Tabs_Count]["x"]
    local y2=reagirl.Elements[reagirl.Tabs_Count]["y"]
    local w2=reagirl.Elements[reagirl.Tabs_Count]["w"]
    local h2=reagirl.Elements[reagirl.Tabs_Count]["h"]
    if x2*scale<0 then x2=gfx.w+x2*scale else x2=x2*scale end
    if y2*scale<0 then y2=gfx.h+y2*scale else y2=y2*scale end
    if w2*scale<0 then w2=gfx.w-x2+w2*scale else w2=w2*scale end
    if h2*scale<0 then h2=gfx.h-y2+h2*scale else h2=h2*scale end
    if reagirl.Elements[reagirl.Tabs_Count]["w_background"]~=nil then 
      if x2+reagirl.Elements[reagirl.Tabs_Count]["w_background"]>maxx then maxx=x2+reagirl.Elements[reagirl.Tabs_Count]["w_background"] end
      if x2+reagirl.Elements[reagirl.Tabs_Count]["w_background"]>maxx2 then maxx2=x2+reagirl.Elements[reagirl.Tabs_Count]["w_background"] end
    end
    if reagirl.Elements[reagirl.Tabs_Count]["h_background"]~=nil then 
      if y2+h2+reagirl.Elements[reagirl.Tabs_Count]["h_background"]>maxy then maxy=y2+h2+reagirl.Elements[reagirl.Tabs_Count]["h_background"] end
      if y2+h2+reagirl.Elements[reagirl.Tabs_Count]["h_background"]>maxy2 then maxy2=y2+h2+reagirl.Elements[reagirl.Tabs_Count]["h_background"] end
    end
  end
  
  return math.floor(minx), math.floor(maxx), math.floor(miny), math.floor(maxy), math.floor(minx2), math.floor(maxx2), math.floor(miny2), math.floor(maxy2), math.floor(w3), math.floor(h3)
end

function reagirl.ScrollButton_Right_Add()
  reagirl.Elements[#reagirl.Elements+1]={}
  reagirl.Elements[#reagirl.Elements]["Guid"]=reaper.genGuid("")
  reagirl.Elements[#reagirl.Elements]["GUI_Element_Type"]="Scroll button"
  reagirl.Elements[#reagirl.Elements]["Name"]="Scroll right"
  reagirl.Elements[#reagirl.Elements]["Text"]=""
  reagirl.Elements[#reagirl.Elements]["IsDisabled"]=false
  reagirl.Elements[#reagirl.Elements]["Description"]="Scroll Right"
  reagirl.Elements[#reagirl.Elements]["AccHint"]="Scrolls the user interface to the right"
  reagirl.Elements[#reagirl.Elements]["ContextMenu_ACC"]=""
  reagirl.Elements[#reagirl.Elements]["DropZoneFunction_ACC"]=""
  reagirl.Elements[#reagirl.Elements]["z_buffer"]=256
  reagirl.Elements[#reagirl.Elements]["x"]=-30
  reagirl.Elements[#reagirl.Elements]["y"]=-15
  reagirl.Elements[#reagirl.Elements]["w"]=15
  reagirl.Elements[#reagirl.Elements]["h"]=15
  reagirl.Elements[#reagirl.Elements]["sticky_x"]=true
  reagirl.Elements[#reagirl.Elements]["sticky_y"]=true
  reagirl.Elements[#reagirl.Elements]["func_manage"]=reagirl.ScrollButton_Right_Manage
  reagirl.Elements[#reagirl.Elements]["func_draw"]=reagirl.ScrollButton_Right_Draw
  reagirl.Elements[#reagirl.Elements]["userspace"]={}
  reagirl.Elements[#reagirl.Elements]["a"]=0
  return reagirl.Elements[#reagirl.Elements]["Guid"]
end

function reagirl.ScrollButton_Right_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if reagirl.Scroll_Override_ScrollButtons==true then return "" end
  if element_storage.IsDisabled==false and element_storage.a<=0.85 then element_storage.a=element_storage.a+.1 reagirl.Gui_ForceRefresh(44) end
  if mouse_cap&1==1 and selected~="not selected" and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    reagirl.UI_Element_ScrollX(-2)
  elseif selected~="not selected" and Key==32 then
    reagirl.UI_Element_ScrollX(-15)
  end
  return ""
end

function reagirl.ScrollButton_Right_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if reagirl.Scroll_Override_ScrollButtons==true then return "" end
  local scale=reagirl.Window_CurrentScale
  local x_offset=-15*scale
  if reagirl.BoundaryX_Max>gfx.w then
    element_storage.IsDisabled=false    
  else
    element_storage.a=0 
    if element_storage.IsDisabled==false then
      reagirl.UI_Element_SetNothingFocused()
      element_storage.IsDisabled=true
    end
  end
  local oldr, oldg, oldb, olda = gfx.r, gfx.g, gfx.b, gfx.a
  gfx.set(reagirl.Colors.Scrollbar_Foreground_r, reagirl.Colors.Scrollbar_Foreground_g, reagirl.Colors.Scrollbar_Foreground_b, element_storage.a-0.3)
  gfx.rect(gfx.w-15*scale+x_offset, gfx.h-15*scale, 15*scale, 15*scale, 1)
  if mouse_cap==1 and selected~="not selected" then
    gfx.set(reagirl.Colors.Scrollbar_Foreground_r, reagirl.Colors.Scrollbar_Foreground_g, reagirl.Colors.Scrollbar_Foreground_b, element_storage.a)
  else
    gfx.set(reagirl.Colors.Scrollbar_Foreground_r, reagirl.Colors.Scrollbar_Foreground_g, reagirl.Colors.Scrollbar_Foreground_b, element_storage.a)
  end
  gfx.rect(gfx.w-15*scale+x_offset, gfx.h-15*scale, 15*scale, 15*scale, 0)
  gfx.triangle(gfx.w-10*scale+x_offset, gfx.h-3*scale,
               gfx.w-10*scale+x_offset, gfx.h-13*scale,
               gfx.w-5*scale+x_offset, gfx.h-8*scale)
  gfx.set(oldr, oldg, oldb, olda)
end

function reagirl.ScrollButton_Left_Add()
  reagirl.Elements[#reagirl.Elements+1]={}
  reagirl.Elements[#reagirl.Elements]["Guid"]=reaper.genGuid("")
  reagirl.Elements[#reagirl.Elements]["GUI_Element_Type"]="Scroll button"
  reagirl.Elements[#reagirl.Elements]["Name"]="Scroll left"
  reagirl.Elements[#reagirl.Elements]["Text"]=""
  reagirl.Elements[#reagirl.Elements]["IsDisabled"]=false
  reagirl.Elements[#reagirl.Elements]["Description"]="Scroll left"
  reagirl.Elements[#reagirl.Elements]["AccHint"]="Scrolls the user interface to the left"
  reagirl.Elements[#reagirl.Elements]["ContextMenu_ACC"]=""
  reagirl.Elements[#reagirl.Elements]["DropZoneFunction_ACC"]=""
  reagirl.Elements[#reagirl.Elements]["z_buffer"]=256
  reagirl.Elements[#reagirl.Elements]["x"]=1
  reagirl.Elements[#reagirl.Elements]["y"]=-15
  reagirl.Elements[#reagirl.Elements]["w"]=15
  reagirl.Elements[#reagirl.Elements]["h"]=15
  reagirl.Elements[#reagirl.Elements]["sticky_x"]=true
  reagirl.Elements[#reagirl.Elements]["sticky_y"]=true
  reagirl.Elements[#reagirl.Elements]["func_manage"]=reagirl.ScrollButton_Left_Manage
  reagirl.Elements[#reagirl.Elements]["func_draw"]=reagirl.ScrollButton_Left_Draw
  reagirl.Elements[#reagirl.Elements]["userspace"]={}
  reagirl.Elements[#reagirl.Elements]["a"]=0
  return reagirl.Elements[#reagirl.Elements]["Guid"]
end

function reagirl.ScrollButton_Left_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if reagirl.Scroll_Override_ScrollButtons==true then return "" end
  if element_storage.IsDisabled==false and element_storage.a<=0.85 then element_storage.a=element_storage.a+.1 reagirl.Gui_ForceRefresh(45) end
  if mouse_cap&1==1 and selected~="not selected" and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    reagirl.UI_Element_ScrollX(2)
  elseif selected~="not selected" and Key==32 then
    reagirl.UI_Element_ScrollX(15)
  end
  return ""
end

function reagirl.ScrollButton_Left_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if reagirl.Scroll_Override_ScrollButtons==true then return "" end
  local scale=reagirl.Window_CurrentScale
  if reagirl.BoundaryX_Max>gfx.w then
    element_storage.IsDisabled=false
  else
    element_storage.a=0 
    if element_storage.IsDisabled==false then
      reagirl.UI_Element_SetNothingFocused()
      element_storage.IsDisabled=true
    end
  end
  local oldr, oldg, oldb, olda = gfx.r, gfx.g, gfx.b, gfx.a
  gfx.set(reagirl.Colors.Scrollbar_Foreground_r, reagirl.Colors.Scrollbar_Foreground_g, reagirl.Colors.Scrollbar_Foreground_b, element_storage.a-0.3)
  gfx.rect(0, gfx.h-15*scale, 15*scale, 15*scale, 1)
--  print(mouse_cap)
  if mouse_cap==1 and selected~="not selected" then
    gfx.set(reagirl.Colors.Scrollbar_Foreground_r, reagirl.Colors.Scrollbar_Foreground_g, reagirl.Colors.Scrollbar_Foreground_b, element_storage.a)
  else
    gfx.set(reagirl.Colors.Scrollbar_Foreground_r, reagirl.Colors.Scrollbar_Foreground_g, reagirl.Colors.Scrollbar_Foreground_b, element_storage.a)
  end
  gfx.rect(0, gfx.h-15*scale, 15*scale, 15*scale, 0)
  gfx.triangle(8*scale, gfx.h-3*scale,
               8*scale, gfx.h-13*scale,
               3*scale, gfx.h-8*scale)
  gfx.set(oldr, oldg, oldb, olda)
end

function reagirl.ScrollButton_Up_Add()
  reagirl.Elements[#reagirl.Elements+1]={}
  reagirl.Elements[#reagirl.Elements]["Guid"]=reaper.genGuid("")
  reagirl.Elements[#reagirl.Elements]["GUI_Element_Type"]="Scroll button"
  reagirl.Elements[#reagirl.Elements]["Name"]="Scroll Up"
  reagirl.Elements[#reagirl.Elements]["Text"]=""
  reagirl.Elements[#reagirl.Elements]["IsDisabled"]=false
  reagirl.Elements[#reagirl.Elements]["Description"]="Scroll up"
  reagirl.Elements[#reagirl.Elements]["AccHint"]="Scrolls the user interface upwards"
  reagirl.Elements[#reagirl.Elements]["ContextMenu_ACC"]=""
  reagirl.Elements[#reagirl.Elements]["DropZoneFunction_ACC"]=""
  reagirl.Elements[#reagirl.Elements]["z_buffer"]=256
  reagirl.Elements[#reagirl.Elements]["x"]=-15
  reagirl.Elements[#reagirl.Elements]["y"]=0
  reagirl.Elements[#reagirl.Elements]["w"]=15
  reagirl.Elements[#reagirl.Elements]["h"]=15
  reagirl.Elements[#reagirl.Elements]["sticky_x"]=true
  reagirl.Elements[#reagirl.Elements]["sticky_y"]=true
  reagirl.Elements[#reagirl.Elements]["func_manage"]=reagirl.ScrollButton_Up_Manage
  reagirl.Elements[#reagirl.Elements]["func_draw"]=reagirl.ScrollButton_Up_Draw
  reagirl.Elements[#reagirl.Elements]["userspace"]={}
  reagirl.Elements[#reagirl.Elements]["a"]=0
  return reagirl.Elements[#reagirl.Elements]["Guid"]
end

function reagirl.ScrollButton_Up_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if reagirl.Scroll_Override_ScrollButtons==true then return "" end
  if element_storage.IsDisabled==false and element_storage.a<=0.85 then element_storage.a=element_storage.a+.1 reagirl.Gui_ForceRefresh(47) end
  if mouse_cap&1==1 and selected~="not selected" and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    reagirl.UI_Element_ScrollY(2)
  elseif selected~="not selected" and Key==32 then
    reagirl.UI_Element_ScrollY(15)
  end
  return ""
end

function reagirl.ScrollButton_Up_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if reagirl.Scroll_Override_ScrollButtons==true then return "" end
  local scale=reagirl.Window_CurrentScale
  if reagirl.BoundaryY_Max>gfx.h then
    element_storage.IsDisabled=false
  else
    element_storage.a=0 
    if element_storage.IsDisabled==false then
      reagirl.UI_Element_SetNothingFocused()
      element_storage.IsDisabled=true
    end
  end
  local oldr, oldg, oldb, olda = gfx.r, gfx.g, gfx.b, gfx.a
  gfx.set(reagirl.Colors.Scrollbar_Foreground_r, reagirl.Colors.Scrollbar_Foreground_g, reagirl.Colors.Scrollbar_Foreground_b, element_storage.a-0.3)
  gfx.rect(gfx.w-15*scale, 0, 15*scale, 15*scale, 1)
  if mouse_cap==1 and selected~="not selected" then
    gfx.set(reagirl.Colors.Scrollbar_Foreground_r, reagirl.Colors.Scrollbar_Foreground_g, reagirl.Colors.Scrollbar_Foreground_b, element_storage.a)
  else
    gfx.set(reagirl.Colors.Scrollbar_Foreground_r, reagirl.Colors.Scrollbar_Foreground_g, reagirl.Colors.Scrollbar_Foreground_b, element_storage.a)
  end
  gfx.rect(gfx.w-15*scale, 0, 15*scale, 15*scale, 0)
  gfx.triangle(gfx.w-8*scale, 4*scale,
               gfx.w-3*scale, 9*scale,
               gfx.w-13*scale, 9*scale)
  gfx.set(oldr, oldg, oldb, olda)
end

function reagirl.ScrollButton_Down_Add()
  reagirl.Elements[#reagirl.Elements+1]={}
  reagirl.Elements[#reagirl.Elements]["Guid"]=reaper.genGuid("")
  reagirl.Elements[#reagirl.Elements]["GUI_Element_Type"]="Scroll button"
  reagirl.Elements[#reagirl.Elements]["Name"]="Scroll Down"
  reagirl.Elements[#reagirl.Elements]["Text"]=""
  reagirl.Elements[#reagirl.Elements]["IsDisabled"]=false
  reagirl.Elements[#reagirl.Elements]["Description"]="Scroll Down"
  reagirl.Elements[#reagirl.Elements]["AccHint"]="Scrolls the user interface downwards"
  reagirl.Elements[#reagirl.Elements]["ContextMenu_ACC"]=""
  reagirl.Elements[#reagirl.Elements]["DropZoneFunction_ACC"]=""
  reagirl.Elements[#reagirl.Elements]["z_buffer"]=256
  reagirl.Elements[#reagirl.Elements]["x"]=-15
  reagirl.Elements[#reagirl.Elements]["y"]=-30
  reagirl.Elements[#reagirl.Elements]["w"]=15
  reagirl.Elements[#reagirl.Elements]["h"]=15
  reagirl.Elements[#reagirl.Elements]["sticky_x"]=true
  reagirl.Elements[#reagirl.Elements]["sticky_y"]=true
  reagirl.Elements[#reagirl.Elements]["func_manage"]=reagirl.ScrollButton_Down_Manage
  reagirl.Elements[#reagirl.Elements]["func_draw"]=reagirl.ScrollButton_Down_Draw
  reagirl.Elements[#reagirl.Elements]["userspace"]={}
  reagirl.Elements[#reagirl.Elements]["a"]=0
  return reagirl.Elements[#reagirl.Elements]["Guid"]
end

function reagirl.ScrollButton_Down_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if reagirl.Scroll_Override_ScrollButtons==true then return "" end
  
  if element_storage.IsDisabled==false and element_storage.a<=0.85 then element_storage.a=element_storage.a+.1 reagirl.Gui_ForceRefresh(49) end
  if mouse_cap&1==1 and selected~="not selected" and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    reagirl.UI_Element_ScrollY(-2)
  elseif selected~="not selected" and Key==32 then
    reagirl.UI_Element_ScrollY(-15)
  end
  return ""
end

function reagirl.ScrollButton_Down_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if reagirl.Scroll_Override_ScrollButtons==true then return "" end
  local scale=reagirl.Window_CurrentScale
  if reagirl.BoundaryY_Max>gfx.h then
    element_storage.IsDisabled=false
  else
    element_storage.a=0 
    if element_storage.IsDisabled==false then
      reagirl.UI_Element_SetNothingFocused()
      element_storage.IsDisabled=true
    end
  end
  local oldr, oldg, oldb, olda = gfx.r, gfx.g, gfx.b, gfx.a
  gfx.set(reagirl.Colors.Scrollbar_Foreground_r, reagirl.Colors.Scrollbar_Foreground_g, reagirl.Colors.Scrollbar_Foreground_b, element_storage.a-0.3)
  gfx.rect(gfx.w-15*scale, gfx.h-30*scale, 15*scale, 15*scale, 1)
  if mouse_cap==1 and selected~="not selected" then
    gfx.set(reagirl.Colors.Scrollbar_Foreground_r, reagirl.Colors.Scrollbar_Foreground_g, reagirl.Colors.Scrollbar_Foreground_b, element_storage.a)
  else
    gfx.set(reagirl.Colors.Scrollbar_Foreground_r, reagirl.Colors.Scrollbar_Foreground_g, reagirl.Colors.Scrollbar_Foreground_b, element_storage.a)
  end
  gfx.rect(gfx.w-15*scale, gfx.h-30*scale, 15*scale, 15*scale, 0)
  gfx.triangle(gfx.w-8*scale, gfx.h-20*scale,
               gfx.w-3*scale, gfx.h-25*scale,
               gfx.w-13*scale, gfx.h-25*scale)
  gfx.set(oldr, oldg, oldb, olda)
end

function reagirl.UI_Element_GetNextFreeSlot()
  if #reagirl.Elements-5<1 then return #reagirl.Elements+1 end
  return #reagirl.Elements-5
end

function reagirl.UI_Element_ScrollToUIElement(element_id, x_offset, y_offset)
  if x_offset==nil then x_offset=10 end
  if y_offset==nil then y_offset=10 end
  local i=reagirl.UI_Element_GetIDFromGuid(element_id)
  local x2,y2,w2,h2
  local scale=reagirl.Window_GetCurrentScale()
  
  if reagirl.Elements[i]["x"]<0 then x2=gfx.w+reagirl.Elements[i]["x"]*scale else x2=reagirl.Elements[i]["x"]*scale end
  if reagirl.Elements[i]["y"]<0 then y2=gfx.h+reagirl.Elements[i]["y"]*scale else y2=reagirl.Elements[i]["y"]*scale end
  if reagirl.Elements[i]["w"]<0 then w2=gfx.w-x2+reagirl.Elements[i]["w"]*scale else w2=reagirl.Elements[i]["w"]*scale end
  if reagirl.Elements[i]["h"]<0 then h2=gfx.h-y2+reagirl.Elements[i]["h"]*scale else h2=reagirl.Elements[i]["h"]*scale end
  
  local cap_w=0
  if reagirl.Elements[i]["Cap_width"]~=nil then
    cap_w=reagirl.Elements[i]["Cap_width"]+15*scale
  end
  
  if reagirl.Elements[i]["sticky_x"]==false then
    if x2+reagirl.MoveItAllRight<0 then
      reagirl.MoveItAllRight=-x2+x_offset
    elseif x2+cap_w+reagirl.MoveItAllRight>gfx.w-15*scale and x2+w2+reagirl.MoveItAllRight>gfx.w-15*scale then
      reagirl.MoveItAllRight=gfx.w-30*scale-w2-x2
    end
  end
  
  if reagirl.Elements[i]["sticky_y"]==false then
    if y2+reagirl.MoveItAllUp<0 then
      reagirl.MoveItAllUp=-y2+y_offset
    elseif y2+reagirl.MoveItAllUp>gfx.h-15*scale and y2+h2+reagirl.MoveItAllUp>gfx.h-15*scale then
      reagirl.MoveItAllUp=gfx.h-15*scale-h2-y2
    end
  end
  --[[
  if x2+reagirl.MoveItAllRight<0 or x2+reagirl.MoveItAllRight>gfx.w or y2+reagirl.MoveItAllUp<0 or y2+reagirl.MoveItAllUp>gfx.h or
     x2+w2+reagirl.MoveItAllRight<0 or x2+w2+reagirl.MoveItAllRight>gfx.w or y2+h2+reagirl.MoveItAllUp<0 or y2+h2+reagirl.MoveItAllUp>gfx.h 
  then
    if reagirl.Elements[i]["sticky_y"]==false then
      reagirl.MoveItAllRight=-x2+x_offset
    end
    if reagirl.Elements[i]["sticky_x"]==false then
      reagirl.MoveItAllUp=-y2+y_offset
    end
    reagirl.Gui_ForceRefresh(51)
  end
  --]]
end

function reagirl.UI_Element_SetNothingFocused()
  reagirl.Elements.FocusedElement=reagirl.UI_Element_GetNext(0)
end

function reagirl.UI_Element_GetHovered()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetHovered</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>string element_guid = reagirl.UI_Element_GetHovered()</functioncall>
  <description>
    Get the ui-element-guid, where the mouse is currently.
  </description>
  <retvals>
    string element_id - the element-id of the currently hovered ui-element
  </retvals>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>functions, get, hovered, hover, gui</tags>
</US_DocBloc>
]]
  if reagirl.UI_Elements_HoveredElement==-1 then return end
  return reagirl.Elements[reagirl.UI_Elements_HoveredElement]["Guid"]
end

function reagirl.UI_Element_GetFocused()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetFocused</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>string element_guid = reagirl.UI_Element_GetFocused()</functioncall>
  <description>
    Get the ui-element-guid, that is currently focused. 
  </description>
  <retvals>
    string element_guid - the element-id of the currently focused ui-element
  </retvals>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>functions, get, focused, gui</tags>
</US_DocBloc>
]]
  if reagirl.Elements.FocusedElement>=#reagirl.Elements-5 then return end
  return reagirl.Elements[reagirl.Elements.FocusedElement]["Guid"]
end

function reagirl.UI_Element_SetFocused(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_SetFocused</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.UI_Element_SetFocused(string element_id)</functioncall>
  <description>
    Set an ui-element focused. 
  </description>
  <parameters>
    string element_id - the id of the ui-element, which you want to set to focused
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>functions, set, focused, gui</tags>
</US_DocBloc>
]]
  if reagirl.Elements.FocusedElement>=#reagirl.Elements-5 then return end
  local id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if id==-1 then error("UI_Element_SetFocused: param #1 - no such ui-element", -2) end

  reagirl.Elements.FocusedElement=id
  reagirl.Gui_ForceRefresh(52)
end

function reagirl.UI_Element_SetHiddenFromTable(table_element_ids, visible)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_SetHiddenFromTable</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.UI_Element_SetHiddenFromTable(table table_element_ids, boolean visible)</functioncall>
  <description>
    Set ui-elements stored in a table to hidden or visible.
  </description>
  <parameters>
     table table_element_ids - a table with all element_ids that you want to hide or make visible
     boolean visible - true, set all ui-elements in table_element_ids to visible; false, set them to hidden
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>functions, set, hidden, visible, from table, gui</tags>
</US_DocBloc>
]]
  if type(table_element_ids)~="table" then error("UI_Element_SetHiddenFromTable: param #1: must be a table", 2) return end
  if type(visible)~="boolean" then error("UI_Element_SetHiddenFromTable: param #2: must be a boolean", 2) return end
  --for i=1, #table_element_ids do
  for k, v in pairs(table_element_ids) do
    if reagirl.IsValidGuid(v, true)==false then error("UI_Element_SetHiddenFromTable: param #1: table-entry "..i.." is not a valid guid", -2) return end
    reagirl.UI_Element_GetSetVisibility(v, true, visible)
  end
end

function reagirl.AutoPosition_SetNextUIElementRelativeTo(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AutoPosition_SetNextUIElementRelativeTo</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.AutoPosition_SetNextUIElementRelativeTo(string element_id)</functioncall>
  <description>
    Set the auto-positioning starting point to the position of a certain ui-element.
    
    Means, autpositioning will place the next ui-element either underneath(when using reagirl.NextLine()) or next to the right of ui-element with element_id.
    
    Note: when passing tabs as parameter, the next ui-element will be placed underneath it(as if you had used reagirl.NextLine())
  </description>
  <parameters>
     string element_id - the element-id of the ui-element, whose position shall be the starting point for the next autopositioned ui-element
  </parameters>
  <chapter_context>
    Autoposition
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>functions, set, auto position, next line</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("AutoPosition_SetNextUIElementRelativeTo: param #1: must be a string", 2) return end
  if reagirl.IsValidGuid(element_id, true)~=true then error("AutoPosition_SetNextUIElementRelativeTo: param #1: must be a valid element_id", 2) return end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("AutoPosition_SetNextUIElementRelativeTo: param #1: no such ui-element", 2) return end
  if reagirl.Elements[element_id]["GUI_Element_Type"]=="Tabs" then reagirl.NextLine() end
  reagirl.Next_Y=element_id
end

-- mespotine
function reagirl.Slider_Add(x, y, w, caption, Cap_width, meaningOfUI_Element, unit, start, stop, step, init_value, default, run_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_Add</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>string slider_guid = reagirl.Slider_Add(optional integer x, optional integer y, integer width, string caption, optional integer cap_width, string meaningOfUI_Element, optional string unit, number start_val, number end_val, number step, number init_value, number default, optional function run_function)</functioncall>
  <description>
    Adds a slider to a gui.
    
    You can autoposition the slider by setting x and/or y to nil, which will position the new slider after the last ui-element.
    To autoposition into the next line, use reagirl.NextLine()
    
    The caption will be shown before, the unit will be shown after the slider.
    Note: when setting the unit to nil, no unit and number will be shown at the end of the slider.
    
    Also note: when the number of steps is too many to be shown in a narrow slider, step-values may be skipped.
    
    The run-function will get as parameters:
    - string element_id - the element_id of the slider that uses this run-function 
    - integer value - the current slider-value
  </description>
  <parameters>
    optional integer x - the x position of the slider in pixels; negative anchors the slider to the right window-side; nil, autoposition after the last ui-element(see description)
    optional integer y - the y position of the slider in pixels; negative anchors the slider to the bottom window-side; nil, autoposition after the last ui-element(see description)
    integer width - the width of the slider in pixels
    string caption - the caption of the slider
    optional integer cap_width - the width of the caption to set the actual slider to a fixed position; nil, put slider directly after caption
    string meaningOfUI_Element - the meaningOfUI_Element of the ui-element(for tooltips and blind users). Make it a sentence that ends with . or ?
    optional string unit - the unit shown next to the number the slider is currently set to
    number start_val - the minimum value of the slider
    number end_val - the maximum value of the slider
    number step - the stepsize until the next value within the slider
    number init_value - the initial value of the slider
    number default - the default value of the slider
    optional function run_function - a function that shall be run when the slider is dragged; will get passed over the slider-element_id as first and the new slider-value as second parameter
  </parameters>
  <retvals>
    string slider_guid - a guid that can be used for altering the slider-attributes
  </retvals>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, add</tags>
</US_DocBloc>
--]]

-- Parameter Unit==nil means, no number of unit shown
  if x~=nil and math.type(x)~="integer" then error("Slider_Add: param #1 - must be either nil or an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("Slider_Add: param #2 - must be either nil or an integer", 2) end
  if math.type(w)~="integer" then error("Slider_Add: param #3 - must be an integer", 2) end
  if type(caption)~="string" then error("Slider_Add: param #4 - must be a string", 2) end
  caption=string.gsub(caption, "[\n\r]", "")
  if Cap_width~=nil and math.type(Cap_width)~="integer" then error("Slider_Add: param #5 - must be either nil or an integer", 2) end
  if type(meaningOfUI_Element)~="string" then error("Slider_Add: param #6 - must be a string", 2) end
  if meaningOfUI_Element:sub(-1,-1)~="." and meaningOfUI_Element:sub(-1,-1)~="?" then error("Slider_Add: param #6 - must end on a . like a regular sentence.", 2) end
  if unit~=nil and type(unit)~="string" then error("Slider_Add: param #7 - must be a string", 2) end
  if unit==nil then unit="" end
  unit=string.gsub(unit, "[\n\r]", "")
  if type(start)~="number" then error("Slider_Add: param #8 - must be a number", 2) end
  if type(stop)~="number" then error("Slider_Add: param #9 - must be a number", 2) end
  if type(step)~="number" then error("Slider_Add: param #10 - must be a number", 2) end
  if type(init_value)~="number" then error("Slider_Add: param #11 - must be a number", 2) end  
  if type(default)~="number" then error("Slider_Add: param #12 - must be a number", 2) end
  if step>stop-start then error("Slider_Add: param #10 - must be smaller than start minus stop", 2) end
  if run_function~=nil and type(run_function)~="function" then error("Slider_Add: param #13 - must be either nil or a function", 2) end
  
  local x,y,slot=reagirl.UI_Element_GetNextXAndYPosition(x, y, "Slider_Add")
  --reagirl.UI_Element_NextX_Default=x
  
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0, 1)
  local tx, ty =gfx.measurestr(caption.."")
  if Cap_width==nil then Cap_width=tx+5 end
  local unit2=" "..unit
  if unit==nil then unit2="" unit="" end
  local tx1,ty1=gfx.measurestr(unit2)
  tx1=tx1+gfx.texth+gfx.texth
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  table.insert(reagirl.Elements, slot, {})
  reagirl.Elements[slot]["Guid"]=reaper.genGuid("")
  reagirl.Elements[slot]["GUI_Element_Type"]="Slider"
  reagirl.Elements[slot]["Name"]=caption
  reagirl.Elements[slot]["Text"]=caption
  reagirl.Elements[slot]["Unit"]=" "..unit
  reagirl.Elements[slot]["Start"]=start
  reagirl.Elements[slot]["Stop"]=stop
  reagirl.Elements[slot]["Step"]=step
  reagirl.Elements[slot]["Default"]=default
  reagirl.Elements[slot]["CurValue"]=init_value
  reagirl.Elements[slot]["IsDisabled"]=false
  reagirl.Elements[slot]["linked_to"]=0
  reagirl.Elements[slot]["Description"]=meaningOfUI_Element
  reagirl.Elements[slot]["AccHint"]="Change via arrowkeys, home, end, pageUp, pageDown."
  reagirl.Elements[slot]["ContextMenu_ACC"]=""
  reagirl.Elements[slot]["DropZoneFunction_ACC"]=""
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["w"]=math.tointeger(w)--math.tointeger(ty+tx+4)
  reagirl.Elements[slot]["h"]=math.tointeger(ty)
  if math.tointeger(ty)>reagirl.NextLine_Overflow then reagirl.NextLine_Overflow=math.tointeger(ty) end
  reagirl.Elements[slot]["cap_w"]=math.tointeger(tx)
  reagirl.Elements[slot]["Cap_width"]=Cap_width
  
  if math.type(step)=="integer" then
    reagirl.Elements[slot]["UnitLen"]=0
  else
    local step2=tostring(step)
    step2=step2:match("%.(.*)")
    reagirl.Elements[slot]["UnitLen"]=step2:len()
  end
  
  reagirl.Elements[slot]["unit_w"]=math.tointeger(tx1)
  reagirl.Elements[slot]["slider_w"]=math.tointeger(w-tx-tx1-10)
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false
  reagirl.Elements[slot]["checked"]=default
  reagirl.Elements[slot]["func_manage"]=reagirl.Slider_Manage
  reagirl.Elements[slot]["func_draw"]=reagirl.Slider_Draw
  reagirl.Elements[slot]["run_function"]=run_function
  reagirl.Elements[slot]["userspace"]={}
  return reagirl.Elements[slot]["Guid"]
end

function reagirl.Slider_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  --print_update(reaper.time_precise(), table.unpack(mouse_attributes))
  -- drop files for accessibility using a file-requester, after typing ctrl+shift+f
  if element_storage["DropZoneFunction"]~=nil and Key==6 and mouse_cap==12 then
    local retval, filenames = reaper.GetUserFileNameForRead("", "Choose file to drop into "..element_storage["Name"], "")
    reagirl.Window_SetFocus()
    if retval==true then element_storage["DropZoneFunction"](element_storage["Guid"], {filenames}) refresh=true end
  end
  
  local refresh=false
  local dpi_scale=reagirl.Window_GetCurrentScale()
  local slider, slider4, slider_x, slider_x2
  if w<element_storage["cap_w"]+element_storage["unit_w"]+20 then w=element_storage["cap_w"]+element_storage["unit_w"]+20 end
  local offset_cap=element_storage["cap_w"]
  if element_storage["Cap_width"]~=nil then
    offset_cap=element_storage["Cap_width"]*dpi_scale
    offset_cap=offset_cap+dpi_scale
  end
  
  if element_storage["linked_to"]~=0 then
    if element_storage["linked_to"]==1 then
      local val=tonumber(reaper.GetExtState(element_storage["linked_to_section"], element_storage["linked_to_key"]))
      if val==nil then val=element_storage["linked_to_default"] refresh=true end
      if element_storage["CurValue"]~=val then element_storage["CurValue"]=val reagirl.Gui_ForceRefresh() end
    elseif element_storage["linked_to"]==2 then
      local retval, val = reaper.BR_Win32_GetPrivateProfileString(element_storage["linked_to_section"], element_storage["linked_to_key"], "", element_storage["linked_to_ini_file"])
      val=tonumber(val)
      if val==nil then val=element_storage["linked_to_default"] refresh=true end
      if element_storage["CurValue"]~=val then element_storage["CurValue"]=val reagirl.Gui_ForceRefresh() end
    elseif element_storage["linked_to"]==3 then
      local val=reaper.SNM_GetDoubleConfigVar(element_storage["linked_to_configvar"], -9999999)
      if element_storage["CurValue"]~=val then element_storage["CurValue"]=val reagirl.Gui_ForceRefresh() end
      if element_storage["linked_to_persist"]==true then
        reaper.BR_Win32_WritePrivateProfileString("REAPER", element_storage["linked_to_configvar"], val, reaper.get_ini_file())
      end
    elseif element_storage["linked_to"]==4 then
      local val=reaper.SNM_GetIntConfigVar(element_storage["linked_to_configvar"], -9999999)
      if element_storage["CurValue"]~=val then element_storage["CurValue"]=val reagirl.Gui_ForceRefresh() end
      if element_storage["linked_to_persist"]==true then
        reaper.BR_Win32_WritePrivateProfileString("REAPER", element_storage["linked_to_configvar"], val, reaper.get_ini_file())
      end
    end
  end

  local offset_unit=element_storage["unit_w"]
  element_storage["slider_w"]=math.tointeger(w-element_storage["cap_w"]-element_storage["unit_w"]-10)
  local rect_w, step_current, step_size
  if selected~="not selected" then
    reagirl.Scroll_Override=true
    if Key==1919379572.0 or Key==1685026670.0 then element_storage["CurValue"]=element_storage["CurValue"]+element_storage["Step"] refresh=true reagirl.Scroll_Override=true end
    if Key==1818584692.0 or Key==30064.0 then element_storage["CurValue"]=element_storage["CurValue"]-element_storage["Step"] refresh=true reagirl.Scroll_Override=true end
    if Key==1752132965.0 then element_storage["CurValue"]=element_storage["Start"] refresh=true reagirl.Scroll_Override=true end
    if Key==6647396.0 then element_storage["CurValue"]=element_storage["Stop"] refresh=true reagirl.Scroll_Override=true end
    if Key==1885824110.0 then element_storage["CurValue"]=element_storage["CurValue"]+element_storage["Step"]*5 refresh=true reagirl.Scroll_Override=true end
    if Key==1885828464.0 then element_storage["CurValue"]=element_storage["CurValue"]-element_storage["Step"]*5 refresh=true reagirl.Scroll_Override=true end
    
    if gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
      slider_x=x+element_storage["cap_w"]
      slider_x2=x+element_storage["cap_w"]+element_storage["slider_w"]
      rect_w=slider_x2-slider_x

      slider=x--+element_storage["cap_w"]
      slider_x2=(gfx.mouse_x-slider_x-10) -- here you need to add an offset for higher scalings...but how?
      --[[
      -- debug rectangle(see end of Gui_Draw for the function)
      dx=gfx.mouse_x-slider_x
      dy=y 
      dw=10
      dh=10
      --]]
      
      if (clicked=="FirstCLK" or clicked=="DRAG") and mouse_cap==1 and gfx.mouse_x>=x+offset_cap-10*dpi_scale and gfx.mouse_x<=x+offset_cap then
        element_storage["CurValue"]=element_storage["Start"]
      elseif (clicked=="FirstCLK" or clicked=="DRAG") and mouse_cap==1 and gfx.mouse_x>=x+w-offset_unit and gfx.mouse_x<=x+w-offset_unit+10*dpi_scale then
        element_storage["CurValue"]=element_storage["Stop"]
        
      elseif mouse_cap==1 then
      
        element_storage["TempValue"]=element_storage["CurValue"]     
        if slider_x2>=0 and slider_x2<=element_storage["slider_w"] then
          if clicked=="DBLCLK" then
          else
            if clicked=="FirstCLK" or clicked=="DRAG" then
              step_size=(rect_w/(element_storage["Stop"]-element_storage["Start"])/1)
              slider4=slider_x2/step_size
              element_storage["CurValue"]=element_storage["Start"]+slider4
              if element_storage["Step"]~=-1 then 
                local old=element_storage["Start"]
                for i=element_storage["Start"]-1, element_storage["Stop"]+1, element_storage["Step"] do
                  if element_storage["CurValue"]<i then
                   element_storage["CurValue"]=i
                   break
                  end
                  old=i
                end
              end
  
              element_storage["OldMouseX"]=gfx.mouse_x
              element_storage["OldMouseY"]=gfx.mouse_y 
            end
          end
        elseif slider_x2<0 and slider_x2>=-15 and clicked=="FirstCLK" then element_storage["CurValue"]=element_storage["Start"] 
        elseif slider_x2>element_storage["slider_w"] and clicked=="FirstCLK" then 
          element_storage["CurValue"]=element_storage["Stop"] 
        end
      end
      if mouse_cap~=0 and element_storage["TempValue"]~=element_storage["CurValue"] then --element_storage["OldMouseX"]~=gfx.mouse_x or element_storage["OldMouseY"]~=gfx.mouse_y then
        refresh=true
      end
      if math.type(element_storage["Step"])=="integer" and math.type(element_storage["Start"])=="integer" and math.type(element_storage["Stop"])=="integer" then
        element_storage["CurValue"]=math.floor(element_storage["CurValue"])
      end
    end
  end
  if gfx.mouse_x>=x+offset_cap-5*dpi_scale and 
     gfx.mouse_x<=x+w-offset_unit+5*dpi_scale and --x+w and 
     gfx.mouse_y>=y and 
     gfx.mouse_y<=y+h then
    if mouse_cap==1 and clicked=="DBLCLK" then
      element_storage["CurValue"]=element_storage["Default"]
      refresh=true
    end
    reagirl.Scroll_Override_MouseWheel=true
    if reagirl.MoveItAllRight_Delta==0 and reagirl.MoveItAllUp_Delta==0 then
      if mouse_attributes[5]<0 or mouse_attributes[6]>0 then 
        local stepme
        if mouse_attributes[5]<0 then stepme=math.tointeger(-mouse_attributes[5]) else stepme=math.tointeger(mouse_attributes[6]) end
        if stepme<120 then stepme=1
        elseif stepme<500 then stepme=2
        elseif stepme<1000 then stepme=8
        elseif stepme<2000 then stepme=16
        elseif stepme<4000 then stepme=64
        end
        element_storage["CurValue"]=element_storage["CurValue"]+element_storage["Step"]*(stepme)        
        refresh=true 
      end
      if mouse_attributes[5]>0 or mouse_attributes[6]<0 then 
        local stepme
        if mouse_attributes[5]>0 then stepme=math.tointeger(mouse_attributes[5]) else stepme=math.tointeger(-mouse_attributes[6]) end
        if stepme<120 then stepme=1
        elseif stepme<500 then stepme=2
        elseif stepme<1000 then stepme=8
        elseif stepme<2000 then stepme=16
        elseif stepme<4000 then stepme=64
        end
        element_storage["CurValue"]=element_storage["CurValue"]-element_storage["Step"]*(stepme)
        refresh=true 
      end
    end
  end
  
  local skip_func
  if element_storage["CurValue"]<element_storage["Start"] then element_storage["CurValue"]=element_storage["Start"] skip_func=true end
  if element_storage["CurValue"]>element_storage["Stop"] then element_storage["CurValue"]=element_storage["Stop"] skip_func=true end
  
  if refresh==true then 
    reagirl.Gui_ForceRefresh(53) 
    if element_storage["run_function"]~=nil and skip_func~=true then 
      element_storage["run_function"](element_storage["Guid"], element_storage["CurValue"]) 
    end
    
    if element_storage["linked_to"]~=0 then
      if element_storage["linked_to"]==1 then
        reaper.SetExtState(element_storage["linked_to_section"], element_storage["linked_to_key"], element_storage["CurValue"], element_storage["linked_to_persist"])
      elseif element_storage["linked_to"]==2 then
        local retval, val = reaper.BR_Win32_WritePrivateProfileString(element_storage["linked_to_section"], element_storage["linked_to_key"], element_storage["CurValue"], element_storage["linked_to_ini_file"])
      elseif element_storage["linked_to"]==3 then
        reaper.SNM_SetDoubleConfigVar(element_storage["linked_to_configvar"], element_storage["CurValue"])
      elseif element_storage["linked_to"]==4 then
        reaper.SNM_SetIntConfigVar(element_storage["linked_to_configvar"], math.floor(element_storage["CurValue"]))
      end
    end
  end
  
  element_storage["AccHoverMessage"]=element_storage["Name"].." "..element_storage["CurValue"]
  return element_storage["CurValue"].." "..element_storage["Unit"]..". ", refresh
end


function reagirl.Slider_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  local dpi_scale=reagirl.Window_GetCurrentScale()
  y=y+dpi_scale
  local step_current, step_size
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  local offset_cap=gfx.measurestr(name.." ")+5
  if element_storage["Cap_width"]~=nil then
    offset_cap=element_storage["Cap_width"]
    offset_cap=offset_cap+dpi_scale
  end
  offset_cap=offset_cap*dpi_scale
  local offset_unit=gfx.measurestr(element_storage["Unit"].."8888")
  
  element_storage["cap_w"]=offset_cap
  element_storage["unit_w"]=offset_unit
  element_storage["slider_w"]=w-offset_cap-offset_unit
  gfx.x=x+dpi_scale
  gfx.y=y+dpi_scale--+(h-gfx.texth)/2
  gfx.set(reagirl.Colors.Slider_TextBG_r, reagirl.Colors.Slider_TextBG_g, reagirl.Colors.Slider_TextBG_b)
  gfx.drawstr(element_storage["Name"])
  
  gfx.x=x
  gfx.y=y--+(h-gfx.texth)/2
  if element_storage["IsDisabled"]==true then gfx.set(reagirl.Colors.Slider_TextFG_disabled_r, reagirl.Colors.Slider_TextFG_disabled_g, reagirl.Colors.Slider_TextFG_disabled_b) else gfx.set(reagirl.Colors.Slider_TextFG_r,reagirl.Colors.Slider_TextFG_g,reagirl.Colors.Slider_TextFG_b) end
  -- draw caption
  gfx.drawstr(element_storage["Name"])
  
  -- draw unit
  local unit=reagirl.FormatNumber(element_storage["CurValue"], element_storage["UnitLen"])
  if element_storage["Unit"]~=nil then 
    gfx.x=x+w-offset_unit+9*dpi_scale
    gfx.y=y+dpi_scale+(h-gfx.texth)/2
    gfx.set(reagirl.Colors.Slider_TextBG_r, reagirl.Colors.Slider_TextBG_g, reagirl.Colors.Slider_TextBG_b)
    gfx.drawstr(" "..unit..element_storage["Unit"])
    
    gfx.x=x+w-offset_unit+8*dpi_scale
    gfx.y=y+(h-gfx.texth)/2
  
    if element_storage["IsDisabled"]==true then gfx.set(reagirl.Colors.Slider_TextFG_disabled_r, reagirl.Colors.Slider_TextFG_disabled_g, reagirl.Colors.Slider_TextFG_disabled_b) else gfx.set(reagirl.Colors.Slider_TextFG_r, reagirl.Colors.Slider_TextFG_g, reagirl.Colors.Slider_TextFG_b) end
    gfx.drawstr(" "..unit..element_storage["Unit"]) 
  end

  --if element_storage["IsDisabled"]==true then gfx.set(0.5) else gfx.set(0.7) end
  -- draw slider-area
  
  local rect_w=w-offset_unit-offset_cap-5*dpi_scale
  local step_size=((rect_w/(element_storage["Stop"]-element_storage["Start"])/1))
  local step_current=step_size*(element_storage["CurValue"]-element_storage["Start"])
  local offset_cap2=offset_cap+7*dpi_scale
  
  -- draw default-line
  gfx.set(reagirl.Colors.Slider_DefaultLine_r, reagirl.Colors.Slider_DefaultLine_g, reagirl.Colors.Slider_DefaultLine_b)
  gfx.rect(x+offset_cap2+step_size*(element_storage["Default"]-element_storage["Start"]), y+dpi_scale+dpi_scale, dpi_scale, h-dpi_scale-dpi_scale-dpi_scale-dpi_scale, 1)
  offset_cap=offset_cap+dpi_scale
  
  -- line_border
  gfx.set(reagirl.Colors.Slider_Border_r, reagirl.Colors.Slider_Border_g, reagirl.Colors.Slider_Border_b)
  reagirl.RoundRect(math.tointeger(x+offset_cap-dpi_scale), math.floor(y+(h-7*dpi_scale)/2), math.tointeger(w-offset_cap-offset_unit+dpi_scale+dpi_scale), math.tointeger(dpi_scale)*6, 2*math.tointeger(dpi_scale), 1, 1)
  
  if element_storage["IsDisabled"]==true then gfx.set(reagirl.Colors.Slider_Center_disabled_r, reagirl.Colors.Slider_Center_disabled_g, reagirl.Colors.Slider_Center_disabled_b) else gfx.set(reagirl.Colors.Slider_Center_r, reagirl.Colors.Slider_Center_g, reagirl.Colors.Slider_Center_b) end
  reagirl.RoundRect(math.tointeger(x+offset_cap),math.floor(y+(h-5*dpi_scale)/2), math.tointeger(w-offset_cap-offset_unit), math.tointeger(dpi_scale)*4, dpi_scale, 1, 1)
  offset_cap=offset_cap+6*dpi_scale  
  
  -- drag-circle
  gfx.set(reagirl.Colors.Slider_Circle_1_r, reagirl.Colors.Slider_Circle_1_g, reagirl.Colors.Slider_Circle_1_b)
  gfx.circle(x+offset_cap+step_current, math.floor(y+h/2), 7*dpi_scale, 1, 1)
  gfx.set(reagirl.Colors.Slider_Circle_2_r, reagirl.Colors.Slider_Circle_2_g, reagirl.Colors.Slider_Circle_2_b)
  gfx.circle(x+offset_cap+step_current, math.floor(y+h/2), 6*dpi_scale, 1, 1)
  
  if element_storage["IsDisabled"]==true then
    gfx.set(reagirl.Colors.Slider_Circle_center_r, reagirl.Colors.Slider_Circle_center_g, reagirl.Colors.Slider_Circle_center_b)
  else
    gfx.set(reagirl.Colors.Slider_Circle_center_disabled_r, reagirl.Colors.Slider_Circle_center_disabled_g, reagirl.Colors.Slider_Circle_center_disabled_b)
  end
  
  gfx.circle(x+offset_cap+step_current, math.floor(y+h/2), 5*dpi_scale, 1, 1)  
end

function reagirl.Slider_LinkToExtstate(element_id, section, key, default, persist)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_LinkToExtstate</slug>
  <requires>
    ReaGirl=1.1
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Slider_LinkToExtstate(string element_id, string section, string key, string default, boolean persist)</functioncall>
  <description>
    Links a slider to an extstate. 
    
    All changes to the extstate will be immediately visible for this slider.
    Dragging the slider also updates the extstate immediately.
    
    If the slider was already linked to a config-var or ini-file, the linked-state will be replaced by this new one.
    Use reagirl.Slider_UnLink() to unlink the slider from extstate/ini-file/config var.
  </description>
  <parameters>
    string element_id - the guid of the slider, that you want to link to an extstate
    string section - the section of the linked extstate
    string key - the key of the linked extstate
    string default - the default value, if the extstate hasn't been set yet
    boolean persist - true, the extstate shall be stored persistantly; false, the extstate shall not be stored persistantly
  </parameters>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, link to, extstate</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_LinkToExtstate: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_LinkToExtstate: param #1 - must be a valid guid", 2) end
  if type(section)~="string" then error("Slider_LinkToExtstate: param #2 - must be a string", 2) end
  if type(key)~="string" then error("Slider_LinkToExtstate: param #3 - must be a string", 2) end
  if type(default)~="number" then error("Slider_LinkToExtstate: param #4 - must be a number", 2) end
  if type(persist)~="boolean" then error("Slider_LinkToExtstate: param #5 - must be a boolean", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_LinkToExtstate: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_LinkToExtstate: param #1 - ui-element is not a slider", 2)
  else
    reagirl.Elements[element_id]["linked_to"]=1
    reagirl.Elements[element_id]["linked_to_section"]=section
    reagirl.Elements[element_id]["linked_to_key"]=key
    reagirl.Elements[element_id]["linked_to_default"]=default
    reagirl.Elements[element_id]["linked_to_persist"]=persist
    reagirl.Gui_ForceRefresh(16)
  end
end

function reagirl.Slider_LinkToIniFile(element_id, ini_file, section, key, default, persist)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_LinkToIniFile</slug>
  <requires>
    ReaGirl=1.1
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Slider_LinkToIniFile(string element_id, string ini_file, string section, string key, string default, boolean persist)</functioncall>
  <description>
    Links a slider to an ini-file-entry. 
    
    All changes to the ini-file-entry will be immediately visible for this slider.
    Dragging the slider also updates the ini-file-entry immediately.
    
    If the slider was already linked to a config-var or extstate, the linked-state will be replaced by this new one.
    Use reagirl.Slider_UnLink() to unlink the slider from extstate/ini-file/config var.
  </description>
  <parameters>
    string element_id - the guid of the slider, that you want to link to an extstate
    string ini_file - the filename of the ini-file, whose value you want to link to this slider
    string section - the section of the linked ini-file
    string key - the key of the linked ini-file
    string default - the default value, if the ini-file hasn't been set yet
    boolean persist - true, the ini-file shall be stored persistantly; false, the ini-file shall not be stored persistantly
  </parameters>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, link to, ini-file</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_LinkToIniFile: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_LinkToIniFile: param #1 - must be a valid guid", 2) end
  if type(ini_file)~="string" then error("Slider_LinkToIniFile: param #2 - must be a string", 2) end
  if type(section)~="string" then error("Slider_LinkToIniFile: param #3 - must be a string", 2) end
  if type(key)~="string" then error("Slider_LinkToIniFile: param #4 - must be a string", 2) end
  if type(default)~="number" then error("Slider_LinkToIniFile: param #5 - must be a number", 2) end

  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_LinkToIniFile: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_LinkToIniFile: param #1 - ui-element is not a slider", 2)
  else
    reagirl.Elements[element_id]["linked_to"]=2
    reagirl.Elements[element_id]["linked_to_ini_file"]=ini_file
    reagirl.Elements[element_id]["linked_to_section"]=section
    reagirl.Elements[element_id]["linked_to_key"]=key
    reagirl.Elements[element_id]["linked_to_default"]=default
    reagirl.Elements[element_id]["linked_to_persist"]=persist
    reagirl.Gui_ForceRefresh(16)
  end
end

function reagirl.Slider_LinkToDoubleConfigVar(element_id, configvar_name, persist)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_LinkToDoubleConfigVar</slug>
  <requires>
    ReaGirl=1.1
    Reaper=7.03
    SWS=2.10.0.1
    Lua=5.4
  </requires>
  <functioncall>reagirl.Slider_LinkToDoubleConfigVar(string element_id, string configvar_name, boolean persist)</functioncall>
  <description>
    Links a slider to a configvar. 
    
    All changes to the configvar will be immediately visible for this slider.
    Draggint the slider also updates the configvar-bit immediately.
    
    Note: this will only allow double-float config-variables. All others could cause malfunction of Reaper!
    Use reagirl.Slider_LinkToIntConfigVar() for integer-config-variables.
    
    Read the Reaper Internals-docs for all available config-variables(run the action ultraschall_Help_Reaper_ConfigVars_Documentation.lua for more details)
    
    If the slider was already linked to extstate or ini-file, the linked-state will be replaced by this new one.
    Use reagirl.Slider_Unlink() to unlink the slider from extstate/ini-file/config var.
  </description>
  <parameters>
    string element_id - the guid of the slider that shall set a config-var
    string configvar_name - the config-variable, whose value you want to update using the slider
    boolean persist - true, make this setting persist; false, make this setting only temporary until Reaper restart
  </parameters>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, link to, double, config variable</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_LinkToDoubleConfigVar: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_LinkToDoubleConfigVar: param #1 - must be a valid guid", 2) end
  if type(configvar_name)~="string" then error("Slider_LinkToDoubleConfigVar: param #2 - must be a string", 2) end
  if type(persist)~="boolean" then error("Slider_LinkToDoubleConfigVar: param #3 - must be a boolean", 2) end
  
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_LinkToDoubleConfigVar: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_LinkToDoubleConfigVar: param #1 - ui-element is not a slider", 2)
  else
    reagirl.Elements[element_id]["linked_to"]=3
    reagirl.Elements[element_id]["linked_to_configvar"]=configvar_name
    reagirl.Elements[element_id]["linked_to_persist"]=persist
    reagirl.Gui_ForceRefresh(16)
  end
end

function reagirl.Slider_LinkToIntConfigVar(element_id, configvar_name, persist)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_LinkToIntConfigVar</slug>
  <requires>
    ReaGirl=1.1
    Reaper=7.03
    SWS=2.10.0.1
    Lua=5.4
  </requires>
  <functioncall>reagirl.Slider_LinkToIntConfigVar(string element_id, string configvar_name, boolean persist)</functioncall>
  <description>
    Links a slider to a configvar. 
    
    All changes to the configvar will be immediately visible for this slider.
    Dragging the slider also updates the configvar-bit immediately.
    
    Note: this will only allow integer-config-variables. All others could cause malfunction of Reaper!
    Use reagirl.Slider_LinkToDoubleConfigVar() for integer-config-variables.
    
    Read the Reaper Internals-docs for all available config-variables(run the action ultraschall_Help_Reaper_ConfigVars_Documentation.lua for more details)
    
    If the slider was already linked to extstate or ini-file, the linked-state will be replaced by this new one.
    Use reagirl.Slider_Unlink() to unlink the slider from extstate/ini-file/config var.
  </description>
  <parameters>
    string element_id - the guid of the slider that shall set a config-var
    string configvar_name - the config-variable, whose value you want to update using the slider
    boolean persist - true, make this setting persist; false, make this setting only temporary until Reaper restart
  </parameters>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, link to, int, config variable</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_LinkToIntConfigVar: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_LinkToIntConfigVar: param #1 - must be a valid guid", 2) end
  if type(configvar_name)~="string" then error("Slider_LinkToIntConfigVar: param #2 - must be a string", 2) end
  if type(persist)~="boolean" then error("Slider_LinkToIntConfigVar: param #3 - must be a boolean", 2) end
  
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_LinkToIntConfigVar: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_LinkToIntConfigVar: param #1 - ui-element is not a slider", 2)
  else
    reagirl.Elements[element_id]["linked_to"]=4
    reagirl.Elements[element_id]["linked_to_configvar"]=configvar_name
    reagirl.Elements[element_id]["linked_to_persist"]=persist
    reagirl.Gui_ForceRefresh(16)
  end
end

function reagirl.Slider_Unlink(element_id, section, key, default, persist)
--[[
<US_ DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_Unlink</slug>
  <requires>
    ReaGirl=1.1
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Slider_Unlink(string element_id)</functioncall>
  <description>
    Unlinks a slider from extstate/ini-file/configvar. 
  </description>
  <parameters>
    string element_id - the guid of the slider, that you want to unlink from an extstate/inifile-entry/configvar
  </parameters>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, unlink</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_Unlink: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_Unlink: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_Unlink: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_Unlink: param #1 - ui-element is not a slider", 2)
  else
    reagirl.Elements[element_id]["linked_to"]=0
    reagirl.Gui_ForceRefresh(16)
  end
end

function reagirl.Slider_SetDimensions(element_id, width)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_SetDimensions</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Slider_SetDimensions(string element_id, integer width)</functioncall>
  <description>
    Sets the width of a slider.
  </description>
  <parameters>
    string element_id - the guid of the slider, whose width you want to set
    integer width - the new width of the slider; negative anchors to right window-edge; nil, keep current width
  </parameters>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, set, width</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_SetDimensions: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_SetDimensions: param #1 - must be a valid guid", 2) end
  if math.type(width)~="integer" then error("Slider_SetDimensions: param #2 - must be an integer", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_SetDimensions: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_SetDimensions: param #1 - ui-element is not a slider", 2)
  else
    if width~=nil then
      reagirl.Elements[element_id]["w"]=width
    end
    reagirl.Gui_ForceRefresh(18.4)
  end
end

function reagirl.Slider_GetDimensions(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_GetDimensions</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer width = reagirl.Slider_GetDimensions(string element_id)</functioncall>
  <description>
    Gets the width of a slider.
  </description>
  <parameters>
    string element_id - the guid of the slider, whose width you want to get
  </parameters>
  <retvals>
    integer width - the width of the slider; negative anchors to right window-edge
  </retvals>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, get, width</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_GetDimensions: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_GetDimensions: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_GetDimensions: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_GetDimensions: param #1 - ui-element is not a slider", 2)
  else
    return reagirl.Elements[element_id]["w"]
  end
end

function reagirl.Slider_SetValue(element_id, value)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_SetValue</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Slider_SetValue(string element_id, number value)</functioncall>
  <description>
    Sets the current value of the slider.
    
    Will not check, whether it is a valid value settable using the stepsize!
  </description>
  <parameters>
    string element_id - the guid of the slider, whose value you want to set
    number value - the new value of the slider
  </parameters>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, set, value</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_SetValue: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_SetValue: param #1 - must be a valid guid", 2) end
  if type(value)~="number" then error("Slider_SetValue: param #2 - must be a number", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_SetValue: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_SetValue: param #1 - ui-element is not a slider", 2)
  else
    if value<reagirl.Elements[element_id]["Start"] or value>reagirl.Elements[element_id]["Stop"] then
      error("Slider_SetValue: param #2 - value must be within start and stop of the slider", 2)
    end
    reagirl.Elements[element_id]["CurValue"]=value
    reagirl.Gui_ForceRefresh(54)
  end
end

function reagirl.Slider_GetValue(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_GetValue</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>number value = reagirl.Slider_GetValue(string element_id)</functioncall>
  <description>
    Gets the current set value of the slider.
  </description>
  <parameters>
    string element_id - the guid of the slider, whose current value you want to get
  </parameters>
  <retvals>
    number value - the current value set in the slider
  </retvals>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, get, value</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_GetValue: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_GetValue: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_GetValue: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_GetValue: param #1 - ui-element is not a slider", 2)
  else
    return reagirl.Elements[element_id]["CurValue"]
  end
end

function reagirl.Slider_SetDisabled(element_id, state)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_SetDisabled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Slider_SetDisabled(string element_id, boolean state)</functioncall>
  <description>
    Sets a slider disabled.
  </description>
  <parameters>
    string element_id - the guid of the slider, whose disablility-state you want to set
    boolean state - true, slider is disabled; false, slider is enabled
  </parameters>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, set, disability</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_SetDisabled: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_SetDisabled: param #1 - must be a valid guid", 2) end
  if type(state)~="boolean" then error("Slider_SetDisabled: param #2 - must be a boolean", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_SetDisabled: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_SetDisabled: param #1 - ui-element is not a slider", 2)
  else
    reagirl.Elements[element_id]["IsDisabled"]=state
    reagirl.Gui_ForceRefresh(55)
  end
end
--mespotine
function reagirl.Slider_GetDisabled(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_GetDisabled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>boolean state = reagirl.Slider_GetDisabled(string element_id)</functioncall>
  <description>
    Gets the current disability state of the slider.
  </description>
  <parameters>
    string element_id - the guid of the slider, whose current disability-state you want to get
  </parameters>
  <retvals>
    boolean state - true, slider is disabled; false, slider is enabled
  </retvals>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, get, disability</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_GetDisabled: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_GetDisabled: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_GetDisabled: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_GetDisabled: param #1 - ui-element is not a slider", 2)
  else
    return reagirl.Elements[element_id]["IsDisabled"]
  end
end

function reagirl.Slider_SetDefaultValue(element_id, default_value)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_SetDefaultValue</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Slider_SetDefaultValue(string element_id, number default_value)</functioncall>
  <description>
    Sets the default value of the slider.
    
    Will not check, whether it is a valid value settable using the stepsize!
  </description>
  <parameters>
    string element_id - the guid of the slider, whose default value you want to set
    number default_value - the new default value of the slider
  </parameters>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, set, default, value</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_SetDefaultValue: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_SetDefaultValue: param #1 - must be a valid guid", 2) end
  if type(default_value)~="number" then error("Slider_SetDefaultValue: param #2 - must be a number", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_SetDefaultValue: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_SetDefaultValue: param #1 - ui-element is not a slider", 2)
  else
    if default_value<reagirl.Elements[element_id]["Start"] or default_value>reagirl.Elements[element_id]["Stop"] then
      error("Slider_SetDefaultValue: param #2 - value must be within start and stop of the slider", 2)
    end
    reagirl.Elements[element_id]["Default"]=default_value
    reagirl.Gui_ForceRefresh(56)
  end
end

function reagirl.Slider_GetDefaultValue(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_GetDefaultValue</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>number value = reagirl.Slider_GetDefaultValue(string element_id)</functioncall>
  <description>
    Gets the current set value of the slider.
  </description>
  <parameters>
    string element_id - the guid of the slider, whose default value you want to get
  </parameters>
  <retvals>
    number value - the current default value set in the slider
  </retvals>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, get, default, value</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_GetDefaultValue: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_GetDefaultValue: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_GetDefaultValue: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_GetDefaultValue: param #1 - ui-element is not a slider", 2)
  else
    return reagirl.Elements[element_id]["Default"]
  end
end

function reagirl.Slider_SetStartValue(element_id, start_value)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_SetStartValue</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Slider_SetStartValue(string element_id, number start_value)</functioncall>
  <description>
    Sets the minimum value of the slider.
    
    If current slider-value is smaller than minimum, the current slider-value will be changed to minimum.
  </description>
  <parameters>
    string element_id - the guid of the slider, whose minimum-value you want to set
    number start_value - the new minimum value of the slider
  </parameters>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, set, minimum, value</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_SetStartValue: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_SetStartValue: param #1 - must be a valid guid", 2) end
  if type(start_value)~="number" then error("Slider_SetStartValue: param #2 - must be a number", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_SetStartValue: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_SetStartValue: param #1 - ui-element is not a slider", 2)
  else
    reagirl.Elements[element_id]["Start"]=start_value
    if reagirl.Elements[element_id]["CurValue"]<start_value then
      reagirl.Elements[element_id]["CurValue"]=start_value
    end
    reagirl.Gui_ForceRefresh(57)
  end
end

function reagirl.Slider_GetStartValue(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_GetStartValue</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>number min_value = reagirl.Slider_GetStartValue(string element_id)</functioncall>
  <description>
    Gets the current set minimum-value of the slider.
  </description>
  <parameters>
    string element_id - the guid of the slider, whose current minimum-value you want to get
  </parameters>
  <retvals>
    number min_value - the current minimum-value set in the slider
  </retvals>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, get, minimum, value</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_GetStartValue: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_GetStartValue: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_GetStartValue: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_GetStartValue: param #1 - ui-element is not a slider", 2)
  else
    return reagirl.Elements[element_id]["Start"]
  end
end

function reagirl.Slider_SetEndValue(element_id, max_value)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_SetEndValue</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Slider_SetEndValue(string element_id, number max_value)</functioncall>
  <description>
    Sets the maximum value of the slider.
    
    If current slider-value is bigger than maximum, the current slider-value will be changed to maximum.
  </description>
  <parameters>
    string element_id - the guid of the slider, whose max-value you want to set
    number max_value - the new max value of the slider
  </parameters>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, set, maximum, value</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_SetEndValue: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_SetEndValue: param #1 - must be a valid guid", 2) end
  if type(max_value)~="number" then error("Slider_SetEndValue: param #2 - must be a number", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_SetEndValue: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_SetEndValue: param #1 - ui-element is not a slider", 2)
  else
    reagirl.Elements[element_id]["Stop"]=max_value
    if reagirl.Elements[element_id]["CurValue"]>max_value then
      reagirl.Elements[element_id]["CurValue"]=max_value
    end
    reagirl.Gui_ForceRefresh(58)
  end
end

function reagirl.Slider_GetEndValue(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_GetEndValue</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>number max_value = reagirl.Slider_GetEndValue(string element_id)</functioncall>
  <description>
    Gets the current set maximum-value of the slider.
  </description>
  <parameters>
    string element_id - the guid of the slider, whose current maximum-value you want to get
  </parameters>
  <retvals>
    number max_value - the current maximum-value set in the slider
  </retvals>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, get, maximum, value</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_GetEndValue: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_GetEndValue: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_GetEndValue: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_GetEndValue: param #1 - ui-element is not a slider", 2)
  else
    return reagirl.Elements[element_id]["Stop"]
  end
end

function reagirl.Slider_ResetToDefaultValue(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_ResetToDefaultValue</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Slider_ResetToDefaultValue(string element_id)</functioncall>
  <description>
    Resets the current set value of the slider to the default value.
  </description>
  <parameters>
    string element_id - the guid of the slider, whose current value you want to reset to default
  </parameters>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, reset, value, default</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_ResetToDefaultValue: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_ResetToDefaultValue: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_ResetToDefaultValue: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_ResetToDefaultValue: param #1 - ui-element is not a slider", 2)
  else
    reagirl.Elements[element_id]["CurValue"]=reagirl.Elements[element_id]["Default"]
    reagirl.Gui_ForceRefresh(59)
  end
end

function reagirl.NextLine_SetMargin(x_margin, y_margin)
-- needs more checks
--[[
<US _DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>NextLine_SetMargin</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.NextLine_SetMargin(optional integer x_margin, optional integer y_margin)</functioncall>
  <description>
    Set the margin between ui-elements when using autopositioning.
    
    This way, you can set the spaces between ui-elements and lines higher or lower.
  </description>
  <parameters>
    optional integer x_margin - the margin between ui-elements on the same line
    optional integer y_margin - the margin between ui-elements between lines(as set by reagirl.NextLine())
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <tags>ui-elements, set, next line, margin</tags>
</US_DocBloc>
--]]
  if x_margin~=nil and math.type(x_margin)~="integer" then error("NextLine_SetMargin: param #1 - must be either nil or an integer", 2) end
  if y_margin~=nil and math.type(y_margin)~="integer" then error("NextLine_SetMargin: param #2 - must be either nil or an integer", 2) end
  if x_margin<0 then error("NextLine_SetMargin: param #1 - must be bigger than or equal 0", 2) end
  if y_margin<0 then error("NextLine_SetMargin: param #2 - must be bigger than or equal 0", 2) end
  if x_margin~=nil then reagirl.UI_Element_NextX_Margin=x_margin end
  if y_margin~=nil then reagirl.UI_Element_NextY_Margin=y_margin end
end

function reagirl.NextLine_GetMargin()
-- needs more checks
--[[
<US_  DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>NextLine_GetMargin</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>integer x_margin, integer y_margin = reagirl.NextLine_GetMargin()</functioncall>
  <description>
    Gets the margin between ui-elements when using autopositioning.
  </description>
  <retvals>
    optional integer x_margin - the margin between ui-elements on the same line
    optional integer y_margin - the margin between ui-elements between lines(as set by reagirl.NextLine())
  </retvals>
  <chapter_context>
    UI Elements
  </chapter_context>
  <tags>ui-elements, get, next line, margin</tags>
</US_DocBloc>
--]]
  return reagirl.UI_Element_NextX_Margin, reagirl.UI_Element_NextY_Margin
end

function reagirl.Tabs_Add(x, y, w_backdrop, h_backdrop, caption, meaningOfUI_Element, tab_names, selected_tab, run_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Tabs_Add</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>string tabs_guid = reagirl.Tabs_Add(optional integer x, optional integer y, integer w, integer w_backdrop, integer h_backdrop, string caption, string meaningOfUI_Element, table tab_names, integer selected_tab, optional function run_function)</functioncall>
  <description>
    Adds a tab to a gui.
    
    You can autoposition the tab by setting x and/or y to nil, which will position the new tab after the last ui-element.
    To autoposition into the next line, use reagirl.NextLine()
    
    You can also have a background drawn by the tab, which could be set to a specific size or set to autosize.
    When set to autosize, it will enclose ui-elements currently visible in the gui.
    If you don't want a background, set w_background or h_background to 0.
    
    Keep in mind, that using auto-sizing of the background might lead to smaller backgrounds than the tabs themselves when there's only a few ui-elements available!
    
    The run-function will get as parameters:
    - string element_id - the tab's element-id 
    - integer selected_tab - the clicked tab 
    - string selected_tab_name - the clicked tab-name
  </description>
  <parameters>
    optional integer x - the x position of the tab in pixels; negative anchors the tab to the right window-side; nil, autoposition after the last ui-element(see description)
    optional integer y - the y position of the tab in pixels; negative anchors the tab to the bottom window-side; nil, autoposition after the last ui-element(see description)
    optional integer w_backdrop - the width of the tab's backdrop; negative, anchor it to the right window-edge; nil, autosize the backdrop to the gui-elements currently shown
    optional integer h_backdrop - the height of the tab's backdrop; negative, anchor it to the bottom window-edge; nil, autosize the backdrop to the gui-elements currently shown
    string caption - the caption of the tab
    string meaningOfUI_Element - the meaningOfUI_Element of the ui-element(for tooltips and blind users). Make it a sentence that ends with . or ?
    table tab_names - an indexed table with all tab-names 
    integer selected_tab - the index of the currently selected tab; 1-based
    optional function run_function - a function that shall be run when a tab is clicked/selected via keys; 
                                   - will get passed over the tab-element_id as first and 
                                   - the new selected tab as second parameter as well as 
                                   - the selected tab-name as third parameter
  </parameters>
  <retvals>
    string tabs_guid - a guid that can be used for altering the tab-attributes
  </retvals>
  <chapter_context>
    Tabs
  </chapter_context>
  <tags>tabs, add</tags>
</US_DocBloc>
--]]

-- Parameter Unit==nil means, no number of unit shown
  if reagirl.Tabs_Count==1 then error("Tabs_Add: only one tab per gui allowed", 2) end
  if x~=nil and math.type(x)~="integer" then error("Tabs_Add: param #1 - must be either nil or an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("Tabs_Add: param #2 - must be either nil or an integer", 2) end
  if w_backdrop~=nil and math.type(w_backdrop)~="integer" then error("Tabs_Add: param #3 - must be either nil or an integer", 2) end
  if h_backdrop~=nil and math.type(h_backdrop)~="integer" then error("Tabs_Add: param #4 - must be either nil or an integer", 2) end
  if type(caption)~="string" then error("Tabs_Add: param #5 - must be a string", 2) end
  caption=string.gsub(caption, "[\n\r]", "")
  if type(meaningOfUI_Element)~="string" then error("Tabs_Add: param #6 - must be a string", 2) end
  if meaningOfUI_Element:sub(-1,-1)~="." and meaningOfUI_Element:sub(-1,-1)~="?" then error("Tabs_Add: param #6 - must end on a . like a regular sentence.", 2) end
  if type(tab_names)~="table" then error("Tabs_Add: param #7 - must be a table", 2) end
  for i=1, #tab_names do
    tab_names[i]=tostring(tab_names[i])
    tab_names[i]=string.gsub(tab_names[i], "[\n\r]", "")
  end
  if math.type(selected_tab)~="integer" then error("Tabs_Add: param #8 - must be an integer", 2) end
  if run_function~=nil and type(run_function)~="function" then error("Tabs_Add: param #9 - must be either nil or a function", 2) end
  
  local add=false
  if x==nil then 
    reagirl.UI_Element_NextX_Default=reagirl.UI_Element_NextX_Default+10
    add=true
  end
  
  local x,y,slot=reagirl.UI_Element_GetNextXAndYPosition(x, y, "Tabs_Add")
  if add==true then
    x=x-18
    add=0
  else
    add=0
  end
  --reagirl.UI_Element_NextX_Default=x
  
  
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0, 1)
  local tx, ty =gfx.measurestr(caption.."")
  
  --reagirl.UI_Element_NextX_Default=10

  --reagirl.UI_Element_NextX_Default=x
  reagirl.UI_Element_NextLineY=0
  
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  table.insert(reagirl.Elements, slot, {})
  reagirl.Elements[slot]["Guid"]=reaper.genGuid("")
  reagirl.Elements[slot]["GUI_Element_Type"]="Tabs"
  reagirl.Elements[slot]["Name"]=caption
  reagirl.Elements[slot]["Text"]=caption
  reagirl.Elements[slot]["TabNames"]=tab_names
  reagirl.Elements[slot]["TabSelected"]=selected_tab
  reagirl.Elements[slot]["IsDisabled"]=false
  reagirl.Elements[slot]["Description"]=meaningOfUI_Element
  reagirl.Elements[slot]["AccHint"]="Switch using arrow-keys."
  reagirl.Elements[slot]["ContextMenu_ACC"]=""
  reagirl.Elements[slot]["DropZoneFunction_ACC"]=""
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["text_offset_x"]=20
  reagirl.Elements[slot]["text_offset_y"]=5
  local width=0
  for i=1, #tab_names do
    width=width+gfx.measurestr(tab_names[i])
  end
  width=width+(#tab_names*(reagirl.Window_GetCurrentScale()+reagirl.Elements[slot]["text_offset_x"])*2)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  reagirl.Elements[slot]["w"]=math.tointeger(width)
  reagirl.Elements[slot]["h"]=math.tointeger(ty)+15
  
  if w_backdrop==0 then 
    reagirl.Elements[slot]["w_background"]="zero" 
    reagirl.Elements[slot]["bg_w"]=0
  else 
    reagirl.Elements[slot]["w_background"]=w_backdrop 
    reagirl.Elements[slot]["bg_w"]=w_backdrop 
  end
  if h_backdrop==0 then 
    reagirl.Elements[slot]["h_background"]="zero" 
    reagirl.Elements[slot]["bg_h"]=0
  else 
    reagirl.Elements[slot]["h_background"]=h_backdrop 
    reagirl.Elements[slot]["bg_h"]=h_backdrop 
  end
  
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false

  reagirl.Elements[slot]["func_manage"]=reagirl.Tabs_Manage
  reagirl.Elements[slot]["func_draw"]=reagirl.Tabs_Draw
  reagirl.Elements[slot]["run_function"]=run_function
  reagirl.Elements[slot]["userspace"]={}

  reagirl.UI_Element_NextX_Default=reagirl.UI_Element_NextX_Default+10+add
  
  reagirl.Tabs_Count=slot
  reagirl.NextLine(-2)
  return reagirl.Elements[slot]["Guid"]
end
-- mespotine
function reagirl.Tabs_SetSelected(element_id, selected_tab)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Tabs_SetSelected</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Tabs_SetSelected(string element_id, integer selected_tab)</functioncall>
  <description>
    Sets the selected tab of a tabs-element.
  </description>
  <parameters>
    string element_id - the guid of the tabs, whose selected tab you want to set
    integer selected_tab - the new selected tab
  </parameters>
  <chapter_context>
    Tabs
  </chapter_context>
  <tags>tabs, set, selected tab</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Tabs_SetSelected: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Tabs_SetSelected: param #1 - must be a valid guid", 2) end
  if math.type(selected_tab)~="integer" then error("Tabs_SetSelected: param #2 - must be an integer", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Tabs_SetSelected: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Tabs" then
    error("Tabs_SetSelected: param #1 - ui-element is not a tab", 2)
  else
    if selected_tab<1 or selected_tab>#reagirl.Elements[element_id]["TabNames"] then error("Tabs_SetSelected: param #2 - no such tab", 2) end
    reagirl.Elements[element_id]["TabSelected"]=selected_tab
    reagirl.Gui_ForceRefresh(60)
  end
end

function reagirl.Tabs_SetUIElementsForTab(element_id, tab_number, element_ids_table)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Tabs_SetUIElementsForTab</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>reagirl.Tabs_SetUIElementsForTab(string element_id, integer tab_number, table element_ids_table)</functioncall>
  <description>
    Sets the ui-elements for a tab from a table.
    
    The element_ids in the table element_ids_table consists of all ui-elements that shall be visible when this tab is selected.
  </description>
  <parameters>
    string element_id - the guid of the tabs, whose selected tab you want to set
    integer tab_number - the number of the tab, whose ui-elements you want to set; 1-based
    table element_ids_table - a table with all element_ids of all ui-elements that shall be shown when the tab is selected
  </parameters>
  <chapter_context>
    Tabs
  </chapter_context>
  <tags>tabs, set, ui-elements shown in selected tab</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Tabs_SetUIElementsForTab: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Tabs_SetUIElementsForTab: param #1 - must be a valid guid", 2) end
  if math.type(tab_number)~="integer" then error("Tabs_SetUIElementsForTab: param #2 - must be an integer", 2) end
  if type(element_ids_table)~="table" then error("Tabs_SetUIElementsForTab: param #3 - must be a table", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Tabs_SetUIElementsForTab: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Tabs" then
    error("Tabs_SetUIElementsForTab: param #1 - ui-element is not a tab", 2)
  else
    for k, v in pairs(element_ids_table) do
      if reagirl.IsValidGuid(v, true)==false then
        error("Tabs_SetUIElementsForTab: param #3: value "..tostring(k).." is not a valid element_id", 2)
      end
    end
    reagirl.Elements[element_id]["Tab"..tab_number]=element_ids_table
    reagirl.Elements[element_id]["TabRefresh"]=true
    reagirl.Gui_ForceRefresh(60)
  end
end

function reagirl.Tabs_GetSelected(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Tabs_GetSelected</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>number value = reagirl.Tabs_GetSelected(string element_id)</functioncall>
  <description>
    Gets the selected tab of a tabs-element.
  </description>
  <parameters>
    string element_id - the guid of the tabs, whose selected tab you want to get
  </parameters>
  <retvals>
    integer selected_tab - the selected tab
  </retvals>
  <chapter_context>
    Tabs
  </chapter_context>
  <tags>tabs, get, selected tab</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Tabs_GetSelected: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Tabs_GetSelected: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Tabs_GetSelected: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Tabs" then
    error("Tabs_GetSelected: param #1 - ui-element is not tabs", 2)
  else
    return reagirl.Elements[element_id]["TabSelected"]
  end
end


function reagirl.Tabs_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  local refresh
  
  -- drop files for accessibility using a file-requester, after typing ctrl+shift+f
  if element_storage["DropZoneFunction"]~=nil and Key==6 and mouse_cap==12 then
    local retval, filenames = reaper.GetUserFileNameForRead("", "Choose file to drop into "..element_storage["Name"], "")
    reagirl.Window_SetFocus()
    if retval==true then element_storage["DropZoneFunction"](element_storage["Guid"], {filenames}) refresh=true end
  end
  
  -- external influence on the opened tab
  if reagirl.Window_name~=nil and reaper.GetExtState("Reagirl_Window_"..reagirl.Window_name, "open_tabnumber")~="" then
    local tabnumber=tonumber(reaper.GetExtState("Reagirl_Window_"..reagirl.Window_name, "open_tabnumber"))
    if tabnumber>=1 and tabnumber<=#element_storage["TabNames"] then
      element_storage["TabSelected"]=tabnumber
      if reaper.GetExtState("ReaGirl", "osara_override")=="" then
        element_storage["TabsSelected_MouseJump"]=element_storage["TabSelected"]
      end
      element_storage["TabRefresh"]=true 
      refresh=true
    end
    reaper.SetExtState("Reagirl_Window_"..reagirl.Window_name, "open_tabnumber", "", false)
  end
  
  local acc_message=""
  if selected~="not selected" then
    acc_message=element_storage["TabNames"][element_storage["TabSelected"]].." tab selected."
  end
  -- hover management for the tabs
  if hovered==true and reaper.GetExtState("ReaGirl", "osara_hover_mouse")~="false" then
    if element_storage["Tabs_Pos"]~=nil then
      for i=1, #element_storage["Tabs_Pos"] do
        if gfx.mouse_y>=y and gfx.mouse_y<=element_storage["Tabs_Pos"][i]["h"]+y then
          if gfx.mouse_x>=element_storage["Tabs_Pos"][i]["x"] and gfx.mouse_x<=element_storage["Tabs_Pos"][i]["x"]+element_storage["Tabs_Pos"][i]["w"] then
            --element_storage["AccHoverMessage"]=element_storage["TabNames"][i]
            local selected1=""
            if element_storage["TabSelected"]==i then selected1=" selected" end
            acc_message=element_storage["TabNames"][i].." tab"..selected1.."."
            if selected=="not selected" then
              reagirl.Elements["GlobalAccHoverMessage"]=element_storage["TabNames"][i].." tab "..selected1
            end
          end
        end
      end
    end
  end
  
  -- click management for the tabs
  if element_storage["Tabs_Pos"]==nil then reagirl.Gui_ForceRefresh(61) end
  if element_storage["Tabs_Pos"]~=nil and clicked=="FirstCLK" then 
    for i=1, #element_storage["Tabs_Pos"] do
      if gfx.mouse_y>=y and gfx.mouse_y<=element_storage["Tabs_Pos"][i]["h"]+y then
        if gfx.mouse_x>=element_storage["Tabs_Pos"][i]["x"] and gfx.mouse_x<=element_storage["Tabs_Pos"][i]["x"]+element_storage["Tabs_Pos"][i]["w"] then
          if element_storage["TabSelected"]~=i then
            element_storage["TabSelected"]=i
            acc_message=element_storage["TabNames"][i].." tab selected."
            element_storage["TabRefresh"]=true
            refresh=true
          end
          break
        end
      end
    end
  end
  
  if Key==9 and gfx.mouse_cap==4 then
    -- ctrl+tab work globally !!! UX-convention!!!
    -- cycle through tabs forward
    element_storage["TabSelected"]=element_storage["TabSelected"]+1
    if element_storage["TabSelected"]>#element_storage["TabNames"] then
      element_storage["TabSelected"]=1
    end
    refresh=true
    element_storage["TabRefresh"]=true
    acc_message=element_storage["TabNames"][element_storage["TabSelected"]].." tab selected."
    element_storage["TabsSelected_MouseJump"]=element_storage["TabSelected"]
    reagirl.UI_Element_SetFocused(element_storage["Guid"])
    reagirl.MouseJump_Skip=true
  end
  
  if Key==9 and gfx.mouse_cap==12 then
    -- ctrl+Shift+tab work globally !!! UX-convention!!!
    -- cycle through tabs backward
    element_storage["TabSelected"]=element_storage["TabSelected"]-1
    if element_storage["TabSelected"]<1 then
      element_storage["TabSelected"]=#element_storage["TabNames"]
    end
    refresh=true
    element_storage["TabRefresh"]=true
    acc_message=element_storage["TabNames"][element_storage["TabSelected"]].." tab selected."
    element_storage["TabsSelected_MouseJump"]=element_storage["TabSelected"]
    reagirl.UI_Element_SetFocused(element_storage["Guid"])
    reagirl.MouseJump_Skip=true
  end
  
  if (selected~="not selected" and Key==1919379572.0) then 
    if element_storage["TabSelected"]+1~=#element_storage["TabNames"]+1 then
      element_storage["TabSelected"]=element_storage["TabSelected"]+1
      element_storage["TabsSelected_MouseJump"]=element_storage["TabSelected"]
      refresh=true
      element_storage["TabRefresh"]=true
      acc_message=element_storage["TabNames"][element_storage["TabSelected"]].." tab selected."
    end
  end
  if selected~="not selected" and Key==1818584692.0 then
    if element_storage["TabSelected"]-1~=0 then
      element_storage["TabSelected"]=element_storage["TabSelected"]-1
      element_storage["TabsSelected_MouseJump"]=element_storage["TabSelected"]
      refresh=true
      element_storage["TabRefresh"]=true
      acc_message=element_storage["TabNames"][element_storage["TabSelected"]].." tab selected."
    end
  end
  
  
  if selected~="not selected" and element_storage["Tabs_Pos"]~=nil then
    reagirl.Gui_PreventScrollingForOneCycle(true, false)
  end
  
  if refresh==true then 
    reagirl.Gui_ForceRefresh(62) 
    if element_storage["run_function"]~=nil and skip_func~=true then 
      element_storage["run_function"](element_storage["Guid"], element_storage["TabSelected"], element_storage["TabNames"][element_storage["TabSelected"]]) 
    end
  end
  
  if element_storage["TabRefresh"]==true then
    for i=1, #element_storage["TabNames"] do
      if element_storage["Tab"..i]~=nil then
        reagirl.UI_Element_SetHiddenFromTable(element_storage["Tab"..i], element_storage["TabSelected"]==i)
      end
    end
    element_storage["TabRefresh"]=false
  end
  
  if selected=="first selected" then
    element_storage["TabsSelected_MouseJump"]=element_storage["TabSelected"]
    refresh=true
  end
  
  --return element_storage["TabNames"][element_storage["TabSelected"]].." tab selected", refresh
  return acc_message, refresh
end


function reagirl.Tabs_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  local dpi_scale=reagirl.Window_GetCurrentScale()
  local text_offset_x=dpi_scale*element_storage["text_offset_x"]
  local text_offset_y=dpi_scale*element_storage["text_offset_y"]
  local x_offset_factor=20
  local x_offset=dpi_scale*x_offset_factor
  local tab_height=text_offset_y+text_offset_y
  element_storage["Tabs_Pos"]={}
  local tx,ty,bg_h,bg_w
  local offset
  for i=1, #element_storage["TabNames"] do
    element_storage["Tabs_Pos"][i]={}
    
    gfx.x=x+x_offset
    gfx.y=y+text_offset_y
    
    tx,ty=gfx.measurestr(element_storage["TabNames"][i])
    tx=math.tointeger(tx)
    ty=math.tointeger(ty)
    element_storage["Tabs_Pos"][i]["x"]=x+text_offset_x
    element_storage["Tabs_Pos"][i]["w"]=x_offset+text_offset_x+tx+text_offset_x
    
    if i==element_storage["TabSelected"] then offset=dpi_scale else offset=0 end
    -- border around tabs
    gfx.set(reagirl.Colors.Tabs_Border_Tabs_r, reagirl.Colors.Tabs_Border_Tabs_g, reagirl.Colors.Tabs_Border_Tabs_b)
    reagirl.RoundRect(math.tointeger(x+x_offset-text_offset_x), y, math.tointeger(tx+text_offset_x+text_offset_x), tab_height+ty, 3*dpi_scale, 1, 1, false, true, false, true)
    
    -- inner part of tabs
    if i==element_storage["TabSelected"] then offset=dpi_scale gfx.set(reagirl.Colors.Tabs_Inner_Tabs_Selected_r, reagirl.Colors.Tabs_Inner_Tabs_Selected_g, reagirl.Colors.Tabs_Inner_Tabs_Selected_b) else offset=0 gfx.set(reagirl.Colors.Tabs_Inner_Tabs_Unselected_r, reagirl.Colors.Tabs_Inner_Tabs_Unselected_g, reagirl.Colors.Tabs_Inner_Tabs_Unselected_b) end
    reagirl.RoundRect(math.tointeger(x+x_offset-text_offset_x)+dpi_scale, y+dpi_scale, math.tointeger(tx+text_offset_x+text_offset_x)-dpi_scale-dpi_scale, tab_height+ty+dpi_scale, 2*dpi_scale, 1, 1, false, true, false, true)
    
    
    if i==element_storage["TabSelected"] then offset=dpi_scale else offset=0 end
    if reagirl.osara_outputMessage~=nil and selected~="not selected" and i==element_storage["TabsSelected_MouseJump"] then
      if reaper.GetExtState("ReaGirl", "osara_move_mouse")~="false" then
        local x,y=gfx.clienttoscreen(math.tointeger(x+x_offset), y+4)
        reaper.JS_Mouse_SetPosition(x, y)
        element_storage["TabsSelected_MouseJump"]=nil
      end
    end
    -- store the dimensions and positions of individual tabs for the manage-function
    element_storage["Tabs_Pos"][i]["x"]=math.tointeger(x+x_offset-text_offset_x)
    element_storage["Tabs_Pos"][i]["w"]=math.tointeger(tx+text_offset_x+text_offset_x)-1
    element_storage["Tabs_Pos"][i]["h"]=tab_height+ty
    
    x_offset=x_offset+math.tointeger(tx)+text_offset_x+text_offset_x+dpi_scale*2
    if selected~="not selected" and i==element_storage["TabSelected"] then
        reagirl.UI_Element_SetFocusRect(true, math.tointeger(gfx.x), y+text_offset_y, math.tointeger(tx), math.tointeger(ty))
    end
    
    -- text of tabname
    gfx.set(reagirl.Colors.Tabs_Text_r, reagirl.Colors.Tabs_Text_g, reagirl.Colors.Tabs_Text_b)
    gfx.drawstr(element_storage["TabNames"][i])
  end
  
  -- backdrop -- will be implemented into Gui_Draw
  
  if element_storage["w_background"]~="zero" and element_storage["h_background"]~="zero" then
    local offset_x=0
    local offset_y=0
    if x>0 then offset_x=x end
    if y>0 then offset_y=element_storage["Tabs_Pos"][element_storage["TabSelected"] ]["h"]+y end
    
    local x2,y2
    if element_storage["x"]<0 then x2=gfx.w+(element_storage["x"]*dpi_scale) else x2=element_storage["x"]*dpi_scale end
    if element_storage["y"]<0 then y2=gfx.h+(element_storage["y"]*dpi_scale) else y2=element_storage["y"]*dpi_scale end    
    local bg_w, _
    
    if element_storage["w_background"]==nil then 
      _, _, _, _, _, _, _, _, bg_w = reagirl.Gui_GetBoundaries()
      bg_w=(bg_w-x2+15*dpi_scale)--*dpi_scale 
      element_storage["bg_w"]=bg_w
      --element_storage["w_background"]=bg_w
    else 
      if element_storage["w_background"]>0 then bg_w=element_storage["w_background"]*dpi_scale else bg_w=gfx.w+element_storage["w_background"]*dpi_scale-offset_x end
    end
    --ABBA=bg_w
    if element_storage["h_background"]==nil then 
      if element_storage["bg_h"]==nil then
        local _, _, _, _, _, _, _, _, _, bg_h2 = reagirl.Gui_GetBoundaries()
        bg_h=(bg_h2+15-y2-element_storage["Tabs_Pos"][element_storage["TabSelected"] ]["h"])/reagirl.Window_GetCurrentScale()--*dpi_scale 
        element_storage["bg_h"]=bg_h
      else
        bg_h=element_storage["bg_h"]
      end
    else
      if element_storage["h_background"]>0 then bg_h=element_storage["h_background"]*dpi_scale else bg_h=gfx.h+element_storage["h_background"]*dpi_scale-offset_y end
    end
    -- border around background
    gfx.set(reagirl.Colors.Tabs_Border_Background_r, reagirl.Colors.Tabs_Border_Background_g, reagirl.Colors.Tabs_Border_Background_b)
    gfx.rect(x, y+element_storage["Tabs_Pos"][element_storage["TabSelected"] ]["h"], bg_w, bg_h*dpi_scale, 1)
    
    -- inner part of background
    gfx.set(reagirl.Colors.Tabs_Inner_Background_r, reagirl.Colors.Tabs_Inner_Background_g, reagirl.Colors.Tabs_Inner_Background_b)
    gfx.rect(x+dpi_scale, y+element_storage["Tabs_Pos"][element_storage["TabSelected"] ]["h"]+dpi_scale, bg_w-dpi_scale-dpi_scale, bg_h*dpi_scale-dpi_scale-dpi_scale, 1)
  end
  gfx.set(reagirl.Colors.Tabs_Inner_Tabs_Selected_r, reagirl.Colors.Tabs_Inner_Tabs_Selected_g, reagirl.Colors.Tabs_Inner_Tabs_Selected_b)
  -- ugly hack...ugh...
  local offset_tabline=0
  if dpi_scale==1 then offset_tabline=offset_tabline+1 
  elseif dpi_scale>=3 then offset_tabline=offset_tabline-(dpi_scale-2) end
  -- end of ugly hack
  gfx.rect(element_storage["Tabs_Pos"][element_storage["TabSelected"] ]["x"]+dpi_scale, 
           y+element_storage["Tabs_Pos"][element_storage["TabSelected"] ]["h"],
           element_storage["Tabs_Pos"][element_storage["TabSelected"] ]["w"]+offset_tabline-dpi_scale,--+element_storage["Tabs_Pos"][element_storage["TabSelected"] ]["w"], 
           dpi_scale, 1)--]]
end


function reagirl.Base64_Encoder(source_string, remove_newlines, remove_tabs)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Base64_Encoder</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03.0
    Lua=5.4
  </requires>
  <functioncall>string encoded_string = reagirl.Base64_Encoder(string source_string, optional integer remove_newlines, optional integer remove_tabs)</functioncall>
  <description>
    Converts a string into a Base64-Encoded string. 
    
    Returns nil in case of an error
  </description>
  <retvals>
    string encoded_string - the encoded string
  </retvals>
  <parameters>
    string source_string - the string that you want to convert into Base64
    optional integer remove_newlines - 1, removes \n-newlines(including \r-carriage return) from the string
                                     - 2, replaces \n-newlines(including \r-carriage return) from the string with a single space
    optional integer remove_tabs     - 1, removes \t-tabs from the string
                                     - 2, replaces \t-tabs from the string with a single space
  </parameters>
  <chapter_context>
    Misc
  </chapter_context>
  <tags>helper functions, convert, encode, base64, string</tags>
</US_DocBloc>
]]
  -- Not to myself:
  -- When you do the decoder, you need to take care, that the bitorder must be changed first, before creating the final-decoded characters
  -- that means: reverse the process of the "tear apart the source-string into bits"-code-passage
  
  -- check parameters and prepare variables
  if type(source_string)~="string" then error("Base64_Encoder: param #1 - must be a string", 2) return nil end
  if remove_newlines~=nil and math.type(remove_newlines)~="integer" then error("Base64_Encoder: param #2 - must be either nil or an integer", -2) return nil end
  if remove_tabs~=nil and math.type(remove_tabs)~="integer" then error("Base64_Encoder: param #3 - must be either nil or an integer", 2) return nil end
  if base64_type~=nil and math.type(base64_type)~="integer" then error("Base64_Encoder: base64_type - must be either nil or an integer", 2) return nil end
  
  local tempstring={}
  local a=1
  local temp
  
  -- this is probably the future space for more base64-encoding-schemes
  local base64_string="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    
  -- if source_string is multiline, get rid of \r and replace \t and \n with a single whitespace
  if remove_newlines==1 then
    source_string=string.gsub(source_string, "\n", "")
    source_string=string.gsub(source_string, "\r", "")
  elseif remove_newlines==2 then
    source_string=string.gsub(source_string, "\n", " ")
    source_string=string.gsub(source_string, "\r", "")  
  end

  if remove_tabs==1 then
    source_string=string.gsub(source_string, "\t", "")
  elseif remove_tabs==2 then 
    source_string=string.gsub(source_string, "\t", " ")
  end
  
  --print2(0)
  -- tear apart the source-string into bits
  -- bitorder of bytes will be reversed for the later parts of the conversion!
  for i=1, source_string:len() do
    temp=string.byte(source_string:sub(i,i))
    --temp=temp
    if temp&1==0 then tempstring[a+7]=0 else tempstring[a+7]=1 end
    if temp&2==0 then tempstring[a+6]=0 else tempstring[a+6]=1 end
    if temp&4==0 then tempstring[a+5]=0 else tempstring[a+5]=1 end
    if temp&8==0 then tempstring[a+4]=0 else tempstring[a+4]=1 end
    if temp&16==0 then tempstring[a+3]=0 else tempstring[a+3]=1 end
    if temp&32==0 then tempstring[a+2]=0 else tempstring[a+2]=1 end
    if temp&64==0 then tempstring[a+1]=0 else tempstring[a+1]=1 end
    if temp&128==0 then tempstring[a]=0 else tempstring[a]=1 end
    a=a+8
  end
  
  -- now do the encoding
  local encoded_string=""
  local temp2=0
  
  -- take six bits and make a single integer-value off of it
  -- after that, use this integer to know, which place in the base64_string must
  -- be read and included into the final string "encoded_string"
  local Entries={}
  local Entries_Count=1
  Entries[Entries_Count]=""
  local Count=0
    
  --print2("1")
  for i=0, a-2, 6 do
    temp2=0
    if tempstring[i+1]==1 then temp2=temp2+32 end
    if tempstring[i+2]==1 then temp2=temp2+16 end
    if tempstring[i+3]==1 then temp2=temp2+8 end
    if tempstring[i+4]==1 then temp2=temp2+4 end
    if tempstring[i+5]==1 then temp2=temp2+2 end
    if tempstring[i+6]==1 then temp2=temp2+1 end
    
    if Count>810 then
      Entries_Count=Entries_Count+1
      Entries[Entries_Count]=""
      Count=0
    end
    Count=Count+1
    Entries[Entries_Count]=Entries[Entries_Count]..base64_string:sub(temp2+1,temp2+1)
  end
  --print2("2")
  
  local Count=0
  local encoded_string2=""
  local encoded_string=""
  for i=1, Entries_Count do
    Count=Count+1
    encoded_string2=encoded_string2..Entries[i]
    if Count==6 then
      encoded_string=encoded_string..encoded_string2
      encoded_string2=""
      Count=0
    end
  end
  encoded_string=encoded_string..encoded_string2
  --]]
  --print2("3")
  -- if the number of characters in the encoded_string isn't exactly divideable 
  -- by 3, add = to fill up missing bytes
  --  OOO=encoded_string:len()%4
  if encoded_string:len()%4==2 then encoded_string=encoded_string.."=="
  elseif encoded_string:len()%2==1 then encoded_string=encoded_string.."="
  end
  
  return encoded_string
end

function reagirl.Base64_Decoder(source_string)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Base64_Decoder</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7.03
    Lua=5.4
  </requires>
  <functioncall>string decoded_string = reagirl.Base64_Decoder(string source_string)</functioncall>
  <description>
    Converts a Base64-encoded string into a normal string. 
    
    Returns nil in case of an error
  </description>
  <retvals>
    string decoded_string - the decoded string
  </retvals>
  <parameters>
    string source_string - the Base64-encoded string
  </parameters>
  <chapter_context>
    Misc
  </chapter_context>
  <tags>helper functions, convert, decode, base64, string</tags>
</US_DocBloc>
]]
  if type(source_string)~="string" then error("Base64_Decoder: param #1 - must be a string", 2) return nil end
  
  -- this is probably the place for other types of base64-decoding-stuff  
  local base64_string="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  
  local Table={}
  local count=0
  for i=65, 90 do  count=count+1 Table[string.char(i)]=count end
  for i=97, 122 do count=count+1 Table[string.char(i)]=count end
  for i=48, 57 do  count=count+1 Table[string.char(i)]=count end
  count=count+1 Table[string.char(43)]=count
  count=count+1 Table[string.char(47)]=count
  
  -- remove =
  source_string=string.gsub(source_string,"=","")
  
  -- split the string into bits
  local bitarray={}
  local count=1
  local temp

  for i=1, source_string:len() do
    local temp=Table[source_string:sub(i,i)]
    --temp=base64_string:match(source_string:sub(i,i).."()")    
    if temp==nil then error("Base64_Decoder: param #2: no valid Base64-string: invalid character found - "..source_string:sub(i,i).." at position "..i, -3) return nil end
    temp=temp-1
    if temp&32~=0 then bitarray[count]=1 else bitarray[count]=0 end
    if temp&16~=0 then bitarray[count+1]=1 else bitarray[count+1]=0 end
    if temp&8~=0 then bitarray[count+2]=1 else bitarray[count+2]=0 end
    if temp&4~=0 then bitarray[count+3]=1 else bitarray[count+3]=0 end
    if temp&2~=0 then bitarray[count+4]=1 else bitarray[count+4]=0 end
    if temp&1~=0 then bitarray[count+5]=1 else bitarray[count+5]=0 end
    count=count+6
  end

  -- combine the bits into the original bytes and put them into decoded_string
  local Entries={}
  local Entries_Count=1
  Entries[Entries_Count]=""
  local Count=0

  local decoded_string=""
  
  local temp2=0
  for i=0, count-1, 8 do
    temp2=0
    if bitarray[i+1]==1 then temp2=temp2+128 end
    if bitarray[i+2]==1 then temp2=temp2+64 end
    if bitarray[i+3]==1 then temp2=temp2+32 end
    if bitarray[i+4]==1 then temp2=temp2+16 end
    if bitarray[i+5]==1 then temp2=temp2+8 end
    if bitarray[i+6]==1 then temp2=temp2+4 end
    if bitarray[i+7]==1 then temp2=temp2+2 end
    if bitarray[i+8]==1 then temp2=temp2+1 end
    
    if Count>780 then
      Entries_Count=Entries_Count+1
      Entries[Entries_Count]=""
      Count=0
    end
    Count=Count+1
    Entries[Entries_Count]=Entries[Entries_Count]..string.char(temp2)
  end

  local Count=0
  local decoded_string2=""
  local decoded_string=""
  for i=1, Entries_Count do
    Count=Count+1
    decoded_string2=decoded_string2..Entries[i]
    if Count==6 then
      decoded_string=decoded_string..decoded_string2
      decoded_string2=""
      Count=0
    end
  end
  decoded_string=decoded_string..decoded_string2

  if decoded_string:sub(-1,-1)=="\0" then decoded_string=decoded_string:sub(1,-2) end
  return decoded_string
end
reagirl.Gui_New()
--- End of ReaGirl-functions

--print2(reaper.GetUserInputs("", 1, "", ""))
