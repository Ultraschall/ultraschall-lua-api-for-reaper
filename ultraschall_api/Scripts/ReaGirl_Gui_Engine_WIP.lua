dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
reagirl={}
reagirl.Elements={}
reagirl.MoveItAllUp=0
reagirl.MoveItAllRight=0

--[[
TODO: 
  Dpi2Scale-conversion must be included(currently using Ultraschall-API in OpenWindow)
--]]

function reagirl.BlitText_AdaptLineLength(text, x, y, width, height, align)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GFX_BlitText_AdaptLineLength</slug>
  <requires>
    ReaGirl=1.0
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>boolean retval = reagirl.BlitText_AdaptLineLength(string text, integer x, integer y, integer width, optional integer height, optional integer align)</functioncall>
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
    Text
  </chapter_context>
  <target_document>US_Api_GFX</target_document>
  <source_document>ultraschall_gfx_engine.lua</source_document>
  <tags>gfx, functions, blit, text, line breaks, adapt line length</tags>
</US_DocBloc>
]]
  if type(text)~="string" then error("GFX_BlitText_AdaptLineLength: #1 - must be a string", 2) end
  if math.type(x)~="integer" then error("GFX_BlitText_AdaptLineLength: #2 - must be an integer", 2) end
  if math.type(y)~="integer" then error("GFX_BlitText_AdaptLineLength: #3 - must be an integer", 2) end
  if type(width)~="number" then error("GFX_BlitText_AdaptLineLength: #4 - must be an integer", 2) end
  if height~=nil and type(height)~="number" then error("GFX_BlitText_AdaptLineLength: #5 - must be an integer", 2) end
  if align~=nil and math.type(align)~="integer" then error("GFX_BlitText_AdaptLineLength: 6 - must be an integer", 2) end
  local l=gfx.measurestr("A")
  if width<gfx.measurestr("A") then error("GFX_BlitText_AdaptLineLength: #4 - must be at least "..l.." pixels for this font.", -7) end

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
  old_x, old_y=gfx.x, gfx.y
  gfx.x=x
  gfx.y=y
  local xwidth, xheight = gfx.measurestr(newtext)
  gfx.drawstr(newtext.."\n  ", center)--xwidth+3+x, xheight)
  gfx.x=old_x
  gfx.y=old_y
  return true
end

function reagirl.ResizeImageKeepAspectRatio(image, neww, newh, bg_r, bg_g, bg_b)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ResizeImageKeepAspectRatio</slug>
  <requires>
    ReaGirl=1.0
    Reaper=5.95
    Lua=5.3
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
    Blitting
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, resize, image</tags>
</US_DocBloc>
]]
  if math.type(image)~="integer" then error("ResizeImageKeepAspectRatio: #1 - must be an integer", 2) end
  if math.type(neww)~="integer" then error("ResizeImageKeepAspectRatio: #2 - must be an integer", 2) end
  if math.type(newh)~="integer" then error("ResizeImageKeepAspectRatio: #3 - must be an integer", 2) end
  
  if bg_r~=nil and type(bg_r)~="number" then error("ResizeImageKeepAspectRatio: #4 - must be a number", 2) end
  if bg_r==nil then bg_r=0 end
  if bg_g~=nil and type(bg_g)~="number" then error("ResizeImageKeepAspectRatio: #5 - must be a number", 2) end
  if bg_g==nil then bg_g=0 end
  if bg_b~=nil and type(bg_b)~="number" then error("ResizeImageKeepAspectRatio: #6 - must be a number", 2) end
  if bg_b==nil then bg_b=0 end
  
  if image<0 or image>1022 then error("ResizeImageKeepAspectRatio: #1 - must be between 0 and 1022", 2) end
  if neww<0 or neww>8192 then error("ResizeImageKeepAspectRatio: #2 - must be between 0 and 8192", 2) end
  if newh<0 or newh>8192 then error("ResizeImageKeepAspectRatio: #3 - must be between 0 and 8192", 2) end
  
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

function reagirl.Window_Open(...)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Window_Open</slug>
  <requires>
    ReaGirl=1.0
    Reaper=5.965
    JS=0.964
    Lua=5.3
  </requires>
  <functioncall>integer retval, optional HWND hwnd = reagirl.Window_Open(string "name", optional integer width, optional integer height, optional integer dockstate, optional integer xpos, optional integer ypos)</functioncall>
  <description>
    Opens a new graphics window and returns its HWND-windowhandler object.
  </description>
  <parameters>
    string "name" - the name of the window, which will be shown in the title of the window
    optional integer width -  the width of the window; minmum is 50
    optional integer height -  the height of the window; minimum is 16
    optional integer dockstate - &1=0, undocked; &1=1, docked
    optional integer xpos - x-position of the window in pixels; minimum is -80; nil, to center it horizontally
    optional integer ypos - y-position of the window in pixels; minimum is -15; nil, to center it vertically
  </parameters>
  <retvals>
    number retval  -  1.0, if window is opened
    optional HWND hwnd - when JS-extension is installed, the window-handler of the newly created window; can be used with JS_Window_xxx-functions of the JS-extension-plugin
  </retvals>
  <chapter_context>
    Window Handling
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, gfx, init, window, create, hwnd</tags>
</US_DocBloc>
]]
  local AAA, AAA2=reaper.ThemeLayout_GetLayout("tcp", -3)
  local minimum_scale_for_dpi, maximum_scale_for_dpi = ultraschall.GetScaleRangeFromDpi(tonumber(AAA2))
  maximum_scale_for_dpi = math.floor(maximum_scale_for_dpi)
  local A=gfx.getchar(65536)
  local HWND, retval
  if A&4==0 then
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
    
    local A1,B,C,D=reaper.my_getViewport(0,0,0,0, 0,0,0,0, false)
    parms[2]=parms[2]*minimum_scale_for_dpi
    parms[3]=parms[3]*minimum_scale_for_dpi
    if parms[5]==nil then
      parms[5]=(C-parms[2])/2
    end
    if parms[6]==nil then
      parms[6]=(D-parms[3])/2
    end

    if reaper.JS_Window_SetTitle==nil then return gfx.init(table.unpack(parms)) end
    
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
    retval=0.0
  end
  return retval, reagirl.GFX_WindowHWND
end

function reagirl.GetMouseCap(doubleclick_wait, drag_wait)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetMouseCap</slug>
  <requires>
    ReaGirl=1.0
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>string clickstate, string specific_clickstate, integer mouse_cap, integer click_x, integer click_y, integer drag_x, integer drag_y, integer mouse_wheel, integer mouse_hwheel = reagirl.GetMouseCap(optional integer doubleclick_wait, optional integer drag_wait)</functioncall>
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
    Mouse Handling
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, mouse, mouse cap, leftclick, rightclick, doubleclick, drag, wheel, mousewheel, horizontal mousewheel</tags>
</US_DocBloc>
]]
--HUITOO=reaper.time_precise()
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

function reagirl.Gui_New()
  reagirl.SetFont(1, "Arial", 16, 0)
  reagirl.MaxImage=1
  gfx.set(reagirl["WindowBackgroundColorR"], reagirl["WindowBackgroundColorG"], reagirl["WindowBackgroundColorB"])
  gfx.rect(0,0,gfx.w,gfx.h,1)
  gfx.x=0
  gfx.y=0
  reagirl.Elements={}
  reagirl.Elements["FocusedElement"]=1
  reagirl.DecorativeImages=nil
  
end

function reagirl.SetFont(idx, fontface, size, flags)
  if size~=nil then size=size* reagirl.dpi_scale end
  font_size = size * (1+reagirl.dpi_scale)*0.5
  gfx.setfont(idx, fontface, size, flags)
end

function reagirl.Gui_Open(title, description, w, h, dock, x, y)
  local retval
  retval, reagirl.dpi = reaper.ThemeLayout_GetLayout("tcp", -3)
  if dpi == "512" then
    reagirl.dpi_scale = 2
    gfx.ext_retina = 1
  else
    reagirl.dpi_scale = 1
  end
  
  reagirl.IsWindowOpen_attribute=true
  reagirl.Gui_ForceRefresh()
  ALL=reaper.time_precise()
  if reagirl.Window_ForceSize_Toggle==nil then reagirl.Window_ForceSize_Toggle=false end
  reagirl.osara_init_message=title.."-dialog, "..description..". "
  return reagirl.Window_Open(title, w, h, dock, x, y)
end

function reagirl.Window_IsOpen()
  return reagirl.IsWindowOpen_attribute
end

function reagirl.Gui_Close()
  gfx.quit()
  reagirl.IsWindowOpen_attribute=false
end


--up 30064.0
--down 1685026670.0

function reagirl.Gui_Manage()
  reagirl.UI_Element_MinX=gfx.w
  reagirl.UI_Element_MinY=gfx.h
  reagirl.UI_Element_MaxW=0
  reagirl.UI_Element_MaxH=0
  
  reagirl.FileDropZone_CheckForDroppedFiles()
  for i=1, #reagirl.Elements do reagirl.Elements[i]["clicked"]=false end
  local Key, Key_utf=gfx.getchar()
  if Key~=0 then reaper.CF_SetClipboard(Key) end
  local Screenstate=gfx.getchar(65536) -- currently unused
  if Key==-1 then reagirl.IsWindowOpen_attribute=false return end
  
  --Debug Code - move ui-elements via arrow keys
  if Key==30064 then reagirl.MoveItAllUp=reagirl.MoveItAllUp-10 reagirl.Gui_ForceRefresh() end
  if Key==1685026670 then reagirl.MoveItAllUp=reagirl.MoveItAllUp+10 reagirl.Gui_ForceRefresh() end
  if Key==1818584692.0 then reagirl.MoveItAllRight=reagirl.MoveItAllRight+10 reagirl.Gui_ForceRefresh() end
  if Key==1919379572.0 then reagirl.MoveItAllRight=reagirl.MoveItAllRight-10 reagirl.Gui_ForceRefresh() end
  --Debug End
  
  
  if Key==27 then reagirl.Gui_Close() else reagirl.Window_ForceSize() end
  if Key==26161 and reaper.osara_outputMessage~=nil then reaper.osara_outputMessage(reagirl.old_osara_message) end
  if reagirl.OldMouseX==gfx.mouse_x and reagirl.OldMouseY==gfx.mouse_y then
    reagirl.TooltipWaitCounter=reagirl.TooltipWaitCounter+1
  else
    reagirl.TooltipWaitCounter=0
  end
  reagirl.OldMouseX=gfx.mouse_x
  reagirl.OldMouseY=gfx.mouse_y
  if reagirl.Windows_OldH~=gfx.h then reagirl.Windows_OldH=gfx.h reagirl.Gui_ForceRefresh() end
  if reagirl.Windows_OldW~=gfx.w then reagirl.Windows_OldW=gfx.w reagirl.Gui_ForceRefresh() end
  
  if gfx.mouse_cap&8==0 and Key==9 then reagirl.Elements["FocusedElement"]=reagirl.Elements["FocusedElement"]+1 if reagirl.Elements["FocusedElement"]>#reagirl.Elements then reagirl.Elements["FocusedElement"]=1 end reagirl.Gui_ForceRefresh() end
  if reagirl.Elements["FocusedElement"]>#reagirl.Elements then reagirl.Elements["FocusedElement"]=1 end
  if gfx.mouse_cap&8==8 and Key==9 then reagirl.Elements["FocusedElement"]=reagirl.Elements["FocusedElement"]-1 reagirl.Gui_ForceRefresh() end
  if reagirl.Elements["FocusedElement"]<1 then reagirl.Elements["FocusedElement"]=#reagirl.Elements end
  if Key==32 then reagirl.Elements[reagirl.Elements["FocusedElement"]]["clicked"]=true end
  
  local clickstate, specific_clickstate, mouse_cap, click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel = reagirl.GetMouseCap(2, 5)
  for i=#reagirl.Elements, 1, -1 do
    local x2, y2, w2, h2
    if reagirl.Elements[i]["x"]<0 then x2=gfx.w+reagirl.Elements[i]["x"] else x2=reagirl.Elements[i]["x"] end
    if reagirl.Elements[i]["y"]<0 then y2=gfx.h+reagirl.Elements[i]["y"] else y2=reagirl.Elements[i]["y"] end
    if reagirl.Elements[i]["w"]<0 then w2=gfx.w-x2+reagirl.Elements[i]["w"] else w2=reagirl.Elements[i]["w"] end
    if reagirl.Elements[i]["h"]<0 then h2=gfx.h-h2+reagirl.Elements[i]["h"] else h2=reagirl.Elements[i]["h"] end
    if reagirl.Elements[i]["GUI_Element_Type"]=="DropDownMenu" then
      if w2<20 then w2=20 end
    end
    
    -- is any gui-element outside of the window
    if x2+reagirl.MoveItAllRight<reagirl.UI_Element_MinX then reagirl.UI_Element_MinX=x2+reagirl.MoveItAllRight end
    if y2<reagirl.UI_Element_MinY+reagirl.MoveItAllUp then reagirl.UI_Element_MinY=y2+reagirl.MoveItAllUp end
    
    if x2+reagirl.MoveItAllRight+w2>reagirl.UI_Element_MaxW then reagirl.UI_Element_MaxW=x2+reagirl.MoveItAllRight+w2 end
    if y2+reagirl.MoveItAllUp+h2>reagirl.UI_Element_MaxH then reagirl.UI_Element_MaxH=y2+h2+reagirl.MoveItAllUp end
    
    if gfx.mouse_x>=x2+reagirl.MoveItAllRight and
       gfx.mouse_x<=x2+reagirl.MoveItAllRight+w2 and
       gfx.mouse_y>=y2+reagirl.MoveItAllUp and
       gfx.mouse_y<=y2+reagirl.MoveItAllUp+h2 then
       if reagirl.TooltipWaitCounter==14 then
        local x,y=reaper.GetMousePosition()
        reaper.TrackCtl_SetToolTip(reagirl.Elements[i]["Description"], x+15, y+10, false)
       end
       if (specific_clickstate=="FirstCLK") then
         reagirl.Elements["FocusedElement"]=i
         reagirl.Elements[i]["clicked"]=true
         reagirl.Gui_ForceRefresh() 
       end
       break
    end
  end
  for i=#reagirl.Elements, 1, -1 do
    local x2, y2, w2, h2
    if reagirl.Elements[i]["x"]<0 then x2=gfx.w+reagirl.Elements[i]["x"] else x2=reagirl.Elements[i]["x"] end
    if reagirl.Elements[i]["y"]<0 then y2=gfx.h+reagirl.Elements[i]["y"] else y2=reagirl.Elements[i]["y"] end
    if reagirl.Elements[i]["w"]<0 then w2=gfx.w-x2+reagirl.Elements[i]["w"] else w2=reagirl.Elements[i]["w"] end
    if reagirl.Elements[i]["h"]<0 then h2=gfx.h-h2+reagirl.Elements[i]["h"] else h2=reagirl.Elements[i]["h"] end
    local message, refresh=reagirl.Elements[i]["func_manage"](i, reagirl.Elements["FocusedElement"]==i,
      specific_clickstate,
      gfx.mouse_cap,
      {click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel},
      reagirl.Elements[i]["Name"],
      reagirl.Elements[i]["Description"], 
      reagirl.Elements[i]["Tooltip"], 
      x2+reagirl.MoveItAllRight,
      y2+reagirl.MoveItAllUp,
      w2,
      h2,
      Key,
      Key_utf,
      reagirl.Elements[i]
    )
    if reagirl.Elements["FocusedElement"]==i and reagirl.old_osara_message~=message and reaper.osara_outputMessage~=nil then
      reaper.osara_outputMessage(reagirl.osara_init_message..message)
      reagirl.old_osara_message=message
      reagirl.osara_init_message=""
    end
    if refresh==true then reagirl.Gui_ForceRefresh() end
  end
  reagirl.Gui_Draw(Key, Key_utf, clickstate, specific_clickstate, mouse_cap, click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel)
end

function reagirl.UI_Elements_OutsideWindow()
  local vert=0
  local horz=0
  
  if reagirl.UI_Element_MinX<0 then vert=reagirl.UI_Element_MaxW-gfx.w
  elseif reagirl.UI_Element_MaxW>gfx.w then vert=reagirl.UI_Element_MaxW-gfx.w end
  
  if reagirl.UI_Element_MinY<0 then horz=gfx.h-reagirl.UI_Element_MaxH horz=-horz
  elseif reagirl.UI_Element_MaxH>gfx.h then horz=gfx.h-reagirl.UI_Element_MaxH horz=-horz end
  return vert, horz
end

function reagirl.Gui_Draw(Key, Key_utf, clickstate, specific_clickstate, mouse_cap, click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel)
  -- no docs in API-docs
  local selected
  
  
  if reagirl.Gui_ForceRefreshState==true then
    gfx.set(reagirl["WindowBackgroundColorR"],reagirl["WindowBackgroundColorG"],reagirl["WindowBackgroundColorB"])
    gfx.rect(0,0,gfx.w,gfx.h,1)
    reagirl.Background_DrawImage()
    
    for i=#reagirl.DecorativeElements, 1, -1 do
      local x2, y2, w2, h2
      if reagirl.DecorativeElements[i]["x"]<0 then x2=gfx.w+reagirl.DecorativeElements[i]["x"] else x2=reagirl.DecorativeElements[i]["x"] end
      if reagirl.DecorativeElements[i]["y"]<0 then y2=gfx.h+reagirl.DecorativeElements[i]["y"] else y2=reagirl.DecorativeElements[i]["y"] end
      if reagirl.DecorativeElements[i]["w"]<0 then w2=gfx.w-x2+reagirl.DecorativeElements[i]["w"] else w2=reagirl.DecorativeElements[i]["w"] end
      if reagirl.DecorativeElements[i]["h"]<0 then h2=gfx.h-y2+reagirl.DecorativeElements[i]["h"] else h2=reagirl.DecorativeElements[i]["h"] end
      local message=reagirl.DecorativeElements[i]["func_draw"](i, reagirl.DecorativeElements["FocusedElement"]==i,
              specific_clickstate,
              gfx.mouse_cap,
              {click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel},
              reagirl.DecorativeElements[i]["Name"],
              reagirl.DecorativeElements[i]["Description"], 
              reagirl.DecorativeElements[i]["Tooltip"], 
              x2+reagirl.MoveItAllRight,
              y2+reagirl.MoveItAllUp,
              w2,
              h2,
              Key,
              Key_utf,
              reagirl.DecorativeElements[i]
            )
            
    end
    
    for i=#reagirl.Elements, 1, -1 do
      local x2, y2, w2, h2
      if reagirl.Elements[i]["x"]<0 then x2=gfx.w+reagirl.Elements[i]["x"] else x2=reagirl.Elements[i]["x"] end
      if reagirl.Elements[i]["y"]<0 then y2=gfx.h+reagirl.Elements[i]["y"] else y2=reagirl.Elements[i]["y"] end
      if reagirl.Elements[i]["w"]<0 then w2=gfx.w-x2+reagirl.Elements[i]["w"] else w2=reagirl.Elements[i]["w"] end
      if reagirl.Elements[i]["h"]<0 then h2=gfx.h-y2+reagirl.Elements[i]["h"] else h2=reagirl.Elements[i]["h"] end

      local message=reagirl.Elements[i]["func_draw"](i, reagirl.Elements["FocusedElement"]==i,
        specific_clickstate,
        gfx.mouse_cap,
        {click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel},
        reagirl.Elements[i]["Name"],
        reagirl.Elements[i]["Description"], 
        reagirl.Elements[i]["Tooltip"], 
        x2+reagirl.MoveItAllRight,
        y2+reagirl.MoveItAllUp,
        w2,
        h2,
        Key,
        Key_utf,
        reagirl.Elements[i]
      )
      if reagirl.Elements["FocusedElement"]==i then
        if reagirl.Elements[i]["GUI_Element_Type"]=="DropDownMenu" then
        --  if w2<20 then w2=20 end
        end
        local r,g,b,a=gfx.r,gfx.g,gfx.b,gfx.a
        local dest=gfx.dest
        gfx.dest=-1
        gfx.set(0.7,0.7,0.7,0.8)
        gfx.rect(x2+reagirl.MoveItAllRight-2,y2+reagirl.MoveItAllUp-2,w2+2,h2+3,0)
        gfx.set(r,g,b,a)
        gfx.dest=dest
        if reaper.osara_outputMessage~=nil and reagirl.oldselection~=i then
          reagirl.oldselection=i
          if reaper.JS_Mouse_SetPosition~=nil then reaper.JS_Mouse_SetPosition(gfx.clienttoscreen(x2+reagirl.MoveItAllRight+4,y2+reagirl.MoveItAllUp+4)) end
        end
      end
    end
    Manage=reaper.time_precise()
  end
  reagirl.Gui_ForceRefreshState=false
  
end

function reagirl.AddDummyElement()  
  reagirl.Elements[#reagirl.Elements+1]={}
  reagirl.Elements[#reagirl.Elements]["GUI_Element_Type"]="Dummy"
  reagirl.Elements[#reagirl.Elements]["Name"]="Dummy"
  reagirl.Elements[#reagirl.Elements]["Description"]="Description"
  reagirl.Elements[#reagirl.Elements]["Tooltip"]="Tooltip"
  reagirl.Elements[#reagirl.Elements]["x"]=math.random(140)
  reagirl.Elements[#reagirl.Elements]["y"]=math.random(140)
  reagirl.Elements[#reagirl.Elements]["w"]=math.random(40)
  reagirl.Elements[#reagirl.Elements]["h"]=math.random(40)
  reagirl.Elements[#reagirl.Elements]["func_manage"]=reagirl.DrawDummyElement
  reagirl.Elements[#reagirl.Elements]["func_draw"]=reagirl.DrawDummyElement
  
  return #reagirl.Elements
end


function reagirl.DrawDummyElement(element_id, selected, clicked, mouse_cap, mouse_attributes, name, description, tooltip, x, y, w, h, Key, Key_UTF)
  -- no docs in API-docs
  local message
  gfx.set(1)
  gfx.rect(x,y,w,h,1)
  if selected==true then
    gfx.set(0.5)
    gfx.rect(x,y,w,h,0)
    if selected==true then
      message="Dummy Element "..description.." focused"..element_id
      C=clicked
    else
      --message=""
    end
    if mouse_cap==1 and clicked==true then
      message="Dummy Element "..description.." clicked"..element_id
      
    elseif mouse_cap==2 and clicked==true then
      gfx.showmenu("Huch|Tuch|Much")
      --message=""
    end
  end
  
  if Key~=0 then message=Key_Utf end

  gfx.x=x
  gfx.y=y
  gfx.set(0)
  gfx.drawstr(element_id)
  
  return "HUCH", message
end

function reagirl.CheckBox_Add(x, y, Name, Description, Tooltip, default, run_function)
  local tx,ty=gfx.measurestr(Name)
  reagirl.Elements[#reagirl.Elements+1]={}
  reagirl.Elements[#reagirl.Elements]["GUI_Element_Type"]="Checkbox"
  reagirl.Elements[#reagirl.Elements]["Name"]=Name
  reagirl.Elements[#reagirl.Elements]["Description"]=Description
  reagirl.Elements[#reagirl.Elements]["Tooltip"]=Tooltip
  reagirl.Elements[#reagirl.Elements]["x"]=x
  reagirl.Elements[#reagirl.Elements]["y"]=y
  reagirl.Elements[#reagirl.Elements]["w"]=gfx.texth+tx+4
  reagirl.Elements[#reagirl.Elements]["h"]=gfx.texth
  reagirl.Elements[#reagirl.Elements]["checked"]=default
  reagirl.Elements[#reagirl.Elements]["func_manage"]=reagirl.Checkbox_Manage
  reagirl.Elements[#reagirl.Elements]["func_draw"]=reagirl.CheckBox_Draw
  reagirl.Elements[#reagirl.Elements]["run_function"]=run_function
  reagirl.Elements[#reagirl.Elements]["userspace"]={}
  return #reagirl.Elements
end

function reagirl.Checkbox_Manage(element_id, selected, clicked, mouse_cap, mouse_attributes, name, description, tooltip, x, y, w, h, Key, Key_UTF, element_storage)
  local refresh=false
  if selected==true and ((clicked=="FirstCLK" and mouse_cap&1==1) or Key==32) then 
    if (gfx.mouse_x>=x 
      and gfx.mouse_x<=x+w 
      and gfx.mouse_y>=y 
      and gfx.mouse_y<=y+h) 
      or Key==32 then
      if reagirl.Elements[element_id]["checked"]==true then 
        reagirl.Elements[element_id]["checked"]=false 
        element_storage["run_function"](element_id, reagirl.Elements[element_id]["checked"])
        refresh=true
      else 
        reagirl.Elements[element_id]["checked"]=true 
        element_storage["run_function"](element_id, reagirl.Elements[element_id]["checked"])
        refresh=true
      end
    end
  end
  if reagirl.Elements[element_id]["checked"]==true then
    return name.." Checkbox checked. "..description, refresh
  else
    return name.." Checkbox unchecked. "..description, refresh
  end
end

function reagirl.CheckBox_Draw(element_id, selected, clicked, mouse_cap, mouse_attributes, name, description, tooltip, x, y, w, h, Key, Key_UTF, element_storage)
  gfx.x=x
  gfx.y=y
  gfx.set(0.1)
  gfx.rect(x+1,y+1,h,h,0)
  gfx.set(1)
  gfx.rect(x,y,h,h,0)
  
  if reagirl.Elements[element_id]["checked"]==true then
    gfx.set(0.9843137254901961, 0.8156862745098039, 0)
    gfx.rect(x+4,y+4,h-8,h-8,1)
  end
  gfx.set(0.3)
  gfx.x=x+h+3
  gfx.y=y+1
  gfx.drawstr(name)
  gfx.set(1)
  gfx.x=x+h+2
  gfx.y=y
  gfx.drawstr(name)
end

--gfx.setfont(

function reagirl.DropDownMenu_Add(x, y, w, Name, Description, Tooltip, default, MenuEntries, run_function)
  local tx,ty=gfx.measurestr(Name)
  reagirl.Elements[#reagirl.Elements+1]={}
  reagirl.Elements[#reagirl.Elements]["GUI_Element_Type"]="DropDownMenu"
  reagirl.Elements[#reagirl.Elements]["Name"]=Name
  reagirl.Elements[#reagirl.Elements]["Description"]=Description
  reagirl.Elements[#reagirl.Elements]["Tooltip"]=Tooltip
  reagirl.Elements[#reagirl.Elements]["x"]=x
  reagirl.Elements[#reagirl.Elements]["y"]=y
  reagirl.Elements[#reagirl.Elements]["w"]=w
  reagirl.Elements[#reagirl.Elements]["h"]=gfx.texth
  reagirl.Elements[#reagirl.Elements]["MenuDefault"]=default
  reagirl.Elements[#reagirl.Elements]["MenuEntries"]=MenuEntries
  reagirl.Elements[#reagirl.Elements]["func_manage"]=reagirl.DropDownMenu_Manage
  reagirl.Elements[#reagirl.Elements]["func_draw"]=reagirl.DropDownMenu_Draw
  reagirl.Elements[#reagirl.Elements]["run_function"]=run_function
  reagirl.Elements[#reagirl.Elements]["userspace"]={}
  return #reagirl.Elements
end

function reagirl.DropDownMenu_Manage(element_id, selected, clicked, mouse_cap, mouse_attributes, name, description, tooltip, x, y, w, h, Key, Key_UTF, element_storage)
  local Entries=""
  local Default, insert
  local refresh=false
  for i=1, #element_storage["MenuEntries"] do
    if i==element_storage["MenuDefault"] then insert="!" else insert="" end
    Entries=Entries..insert..element_storage["MenuEntries"][i].."|"
  end
  
  if w<20 then w=20 end
  if selected==true and ((clicked=="FirstCLK" and mouse_cap&1==1) or Key==1685026670) then 
    if (gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h) or Key==32 then
      gfx.x=x
      gfx.y=y+gfx.texth
      local selection=gfx.showmenu(Entries:sub(1,-2))
      if selection>0 then
        reagirl.Elements[element_id]["MenuDefault"]=selection
        reagirl.Elements[element_id]["run_function"](element_id, selection, element_storage["MenuEntries"][selection])
        refresh=true
      end
    end
  end
  return name..". "..element_storage["MenuEntries"][element_storage["MenuDefault"]]..". ComboBox collapsed ", refresh
end

function reagirl.DropDownMenu_Draw(element_id, selected, clicked, mouse_cap, mouse_attributes, name, description, tooltip, x, y, w, h, Key, Key_UTF, element_storage)
  local offset=gfx.measurestr(name.." ")
  gfx.x=x
  gfx.y=y
  gfx.set(0.1)

  gfx.set(1)
  gfx.rect(x,y,w,h+1,0)
  

  gfx.triangle(x+1, y, x+gfx.texth, y, x-1+gfx.texth/2+2, y+gfx.texth)
  gfx.set(0.1)
  gfx.rect(x+1,y+1,w,h+1,0)
  gfx.line(x+gfx.texth+1, y+1, x+gfx.texth/2+1, y+1+gfx.texth)
  gfx.set(0.7)
  gfx.set(0.7)
  gfx.line(x, y, x+gfx.texth/2, y+gfx.texth)
  --]]
  
  gfx.set(0.3)
  gfx.x=x+1+2+gfx.texth
  gfx.y=y+1
  gfx.drawstr(element_storage["MenuEntries"][element_storage["MenuDefault"]],0,gfx.x+w-gfx.texth-3, gfx.y+gfx.texth)
  
  gfx.set(1)
  gfx.line(x+gfx.texth,y,x+gfx.texth,y+gfx.texth)
  gfx.x=x+2+gfx.texth
  gfx.y=y
  gfx.drawstr(element_storage["MenuEntries"][element_storage["MenuDefault"]],0,gfx.x+w-gfx.texth-3, gfx.y+gfx.texth)
  
end

function reagirl.Label_Add(label, x, y, w, align, description)
  --label=string.gsub(label, "\n", "")
  --label=string.gsub(label, "\r", "")
  if reagirl.DecorativeElements==nil then reagirl.DecorativeElements={} end
  reagirl.DecorativeElements[#reagirl.DecorativeElements+1]={}
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["GUI_Element_Type"]="Label"
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["Name"]=label
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["x"]=x
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["y"]=y
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["w"]=w
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["h"]=gfx.texth
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["align"]=align
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["func_draw"]=reagirl.Label_Draw
  
  return #reagirl.DecorativeElements
end

function reagirl.Label_Draw(element_id, selected, clicked, mouse_cap, mouse_attributes, name, description, tooltip, x, y, w, h, Key, Key_UTF, element_storage)
    gfx.set(0.1)
    reagirl.BlitText_AdaptLineLength(name, 
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
end

function reagirl.Rect_Add(x,y,w,h,r,g,b,a,filled)
  if reagirl.DecorativeElements==nil then reagirl.DecorativeElements={} end
  reagirl.DecorativeElements[#reagirl.DecorativeElements+1]={}
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["GUI_Element_Type"]="Rectangle"
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["x"]=x
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["y"]=y
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["w"]=w
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["h"]=h
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["r"]=r
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["g"]=g
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["b"]=b
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["a"]=a
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["filled"]=filled
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["func_draw"]=reagirl.Rect_Draw
  return #reagirl.DecorativeElements
end

function reagirl.Rect_Draw(element_id, selected, clicked, mouse_cap, mouse_attributes, name, description, tooltip, x, y, w, h, Key, Key_UTF, element_storage)
  gfx.set(element_storage["r"], element_storage["g"], element_storage["b"], element_storage["a"])
  gfx.rect(x,y,w,h, element_storage["filled"])
end


function reagirl.Line_Add(x,y,x2,y2,r,g,b,a)
  if reagirl.DecorativeElements==nil then reagirl.DecorativeElements={} end
  reagirl.DecorativeElements[#reagirl.DecorativeElements+1]={}
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["GUI_Element_Type"]="Line"
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["x"]=x
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["y"]=y
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["w"]=x2
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["h"]=y2
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["r"]=r
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["g"]=g
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["b"]=b
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["a"]=a
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["filled"]=filled
  reagirl.DecorativeElements[#reagirl.DecorativeElements]["func_draw"]=reagirl.Line_Draw
  return #reagirl.DecorativeElements
end

function reagirl.Line_Draw(element_id, selected, clicked, mouse_cap, mouse_attributes, name, description, tooltip, x, y, w, h, Key, Key_UTF, element_storage)
  gfx.set(element_storage["r"], element_storage["g"], element_storage["b"], element_storage["a"])
  if element_storage["w"]<0 then x2=gfx.w+element_storage["w"] else x2=element_storage["w"] end
  if element_storage["h"]<0 then y2=gfx.h+element_storage["h"] else y2=element_storage["h"] end
  gfx.line(x,y,x2,y2)
end


function reagirl.Image_Add(image_file, x, y, w, h, Name, Description, Tooltip, run_function, func_params)
  if reagirl.MaxImage==nil then reagirl.MaxImage=1 end
  reagirl.MaxImage=reagirl.MaxImage+1
  reagirl.Elements[#reagirl.Elements+1]={}
  reagirl.Elements[#reagirl.Elements]["GUI_Element_Type"]="Image"
  reagirl.Elements[#reagirl.Elements]["Name"]=Name
  reagirl.Elements[#reagirl.Elements]["Description"]=Description
  reagirl.Elements[#reagirl.Elements]["Tooltip"]=Tooltip
  reagirl.Elements[#reagirl.Elements]["x"]=x
  reagirl.Elements[#reagirl.Elements]["y"]=y
  reagirl.Elements[#reagirl.Elements]["w"]=w
  reagirl.Elements[#reagirl.Elements]["h"]=h
  reagirl.Elements[#reagirl.Elements]["func_manage"]=reagirl.Image_Manage
  reagirl.Elements[#reagirl.Elements]["func_draw"]=reagirl.Image_Draw
  reagirl.Elements[#reagirl.Elements]["run_function"]=run_function
  reagirl.Elements[#reagirl.Elements]["func_params"]=func_params
  
  reagirl.Elements[#reagirl.Elements]["Image_Storage"]=reagirl.MaxImage
  reagirl.Elements[#reagirl.Elements]["Image_File"]=image_file
  gfx.dest=reagirl.Elements[#reagirl.Elements]["Image_Storage"]
  local r,g,b,a=gfx.r,gfx.g,gfx.b,gfx.a
  gfx.set(0)
  gfx.rect(0,0,8192,8192)
  gfx.set(r,g,b,a)
  local AImage=gfx.loadimg(reagirl.Elements[#reagirl.Elements]["Image_Storage"], image_file)
  local retval = reagirl.ResizeImageKeepAspectRatio(reagirl.Elements[#reagirl.Elements]["Image_Storage"], w, h, 0, 0, 0)
  gfx.dest=-1
  return #reagirl.Elements
end


function reagirl.Image_Manage(element_id, selected, clicked, mouse_cap, mouse_attributes, name, description, tooltip, x, y, w, h, Key, Key_UTF, element_storage)
  if selected==true and 
    (Key==32 or mouse_cap==1) and 
    (gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h) and
    element_storage["run_function"]~=nil then 
      element_storage["run_function"](element_id, table.unpack(element_storage["func_params"])) 
  end
  if selected==true then
    message="Image "..description
  end
  return message
end

function reagirl.Image_Draw(element_id, selected, clicked, mouse_cap, mouse_attributes, name, description, tooltip, x, y, w, h, Key, Key_UTF, element_storage)
  -- no docs in API-docs
  
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
  gfx.blit(element_storage["Image_Storage"], 1, 0)
  
  -- revert changes
  gfx.r,gfx.g,gfx.b,gfx.a=r,g,b,a
  gfx.mode=oldmode
  gfx.x=oldx
  gfx.y=oldy
  gfx.dest=olddest
end

function reagirl.Image_Update(element_id, image_file)
  gfx.dest=reagirl.Elements[element_id]["Image_Storage"]
  reagirl.Elements[element_id]["Image_File"]=image_file
  local r,g,b,a=gfx.r,gfx.g,gfx.b,gfx.a
  gfx.set(1)
  gfx.rect(0,0,8192,8192)
  gfx.set(r,g,b,a)
  gfx.dest=-1
  AImage=gfx.loadimg(reagirl.Elements[element_id]["Image_Storage"], image_file)
  retval = reagirl.ResizeImageKeepAspectRatio(reagirl.Elements[element_id]["Image_Storage"], reagirl.Elements[element_id]["w"], reagirl.Elements[element_id]["h"], 0, 0, 0)
  reagirl.Gui_ForceRefresh()
end

function reagirl.ReserveImageBuffer()
  -- reserves an image buffer for custom UI elements
  -- returns -1 if no buffer can be reserved anymore
  if reagirl.MaxImage==nil then reagirl.MaxImage=1 end
  if reagirl.MaxImage==1022 then return -1 end
  reagirl.MaxImage=reagirl.MaxImage+1
  return reagirl.MaxImage
end

function reagirl.UI_Element_Move(element_id, x, y, w, h)
  if math.type(element_id)~="integer" then error("UI_Element_Move: param #1 - must be an integer", 2) end
  if x~=nil and math.type(x)~="integer" then error("UI_Element_Move: param #2 - must be an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("UI_Element_Move: param #3 - must be an integer", 2) end
  if w~=nil and math.type(w)~="integer" then error("UI_Element_Move: param #4 - must be an integer", 2) end
  if h~=nil and math.type(h)~="integer" then error("UI_Element_Move: param #5 - must be an integer", 2) end
  if element_id<1 or element_id>#reagirl.Elements then error("UI_Element_Move: param #1 - no such UI-element", 2) end
  if x~=nil then reagirl.Elements[element_id]["x"]=x end
  if y~=nil then reagirl.Elements[element_id]["y"]=y end
  if w~=nil then reagirl.Elements[element_id]["w"]=w end
  if h~=nil then reagirl.Elements[element_id]["h"]=h end
  if element_id==reagirl.Elements["FocusedElement"] then
    reagirl.oldselection=-1
  end
  reagirl.Gui_ForceRefresh()
end

function reagirl.UI_Element_SetSelected(element_id)
  if element_id<1 or element_id>#reagirl.Elements then error("UI_Element_SetSelected: param #1 - no such UI-element", 2) end
  reagirl.Elements["FocusedElement"]=element_id
  reagirl.Gui_ForceRefresh()
end


function reagirl.Background_GetSetColor(is_set, r, g, b)
  if type(is_set)~="boolean" then error("GetSetBackgroundColor: param #1 - must be a boolean", 2) end
  if math.type(r)~="integer" then error("GetSetBackgroundColor: param #2 - must be an integer", 2) end
  if g~=nil and math.type(g)~="integer" then error("GetSetBackgroundColor: param #3 - must be an integer", 2) end
  if b~=nil and math.type(b)~="integer" then error("GetSetBackgroundColor: param #4 - must be an integer", 2) end
  if g==nil then g=r end
  if b==nil then b=r end
  if reagirl.Elements==nil then reagirl.Elements={} end
  if is_set==true then
    reagirl["WindowBackgroundColorR"],reagirl["WindowBackgroundColorG"],reagirl["WindowBackgroundColorB"]=r/255, g/255, b/255
  else
    return math.floor(reagirl["WindowBackgroundColorR"]*255), math.floor(reagirl["WindowBackgroundColorG"]*255), math.floor(reagirl["WindowBackgroundColorB"]*255)
  end
end


function reagirl.Background_GetSetImage(filename, x, y, scaled, fixed_x, fixed_y)
  if reagirl.MaxImage==nil then reagirl.MaxImage=1 end
  reagirl.Background_FixedX=fixed_x
  reagirl.Background_FixedY=fixed_y
  reagirl.MaxImage=reagirl.MaxImage+1
  gfx.loadimg(reagirl.MaxImage, filename)
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
end

function reagirl.Background_DrawImage()
  if reagirl.DecorativeImages==nil then return end
  local xoffset=0
  local yoffset=0
  if reagirl.Background_FixedX==true then xoffset=reagirl.MoveItAllRight end
  if reagirl.Background_FixedY==true then yoffset=reagirl.MoveItAllUp end
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

function reagirl.FileDropZone_CheckForDroppedFiles()
  local x, y, w, h
  local i=1
  if reagirl.DropZone~=nil then
    for i=1, #reagirl.DropZone do
      if reagirl.DropZone[i]["DropZoneX"]<0 then x=gfx.w+reagirl.DropZone[i]["DropZoneX"]+reagirl.MoveItAllRight else x=reagirl.DropZone[i]["DropZoneX"]+reagirl.MoveItAllRight end
      if reagirl.DropZone[i]["DropZoneY"]<0 then y=gfx.h+reagirl.DropZone[i]["DropZoneY"]+reagirl.MoveItAllUp else y=reagirl.DropZone[i]["DropZoneY"]+reagirl.MoveItAllUp end
      if reagirl.DropZone[i]["DropZoneW"]<0 then w=gfx.w-x+reagirl.DropZone[i]["DropZoneW"] else w=reagirl.DropZone[i]["DropZoneW"] end
      if reagirl.DropZone[i]["DropZoneH"]<0 then h=gfx.h-y+reagirl.DropZone[i]["DropZoneH"] else h=reagirl.DropZone[i]["DropZoneH"] end
      -- debug dropzone-rectangle, for checking, if it works
      --[[  gfx.set(1)
        gfx.rect(x, y, w, h, 0)
      --]]
      local files={}
      local retval
      if gfx.mouse_x>=x and
         gfx.mouse_y>=y and
         gfx.mouse_x<=x+w and
         gfx.mouse_y<=y+h then
         for i=0, 65555 do
           retval, files[i+1]=gfx.getdropfile(i)
           if retval==false then break end
         end
         if #files>0 then
          reagirl.DropZone[i]["DropZoneFunc"](files)
          reagirl.Gui_ForceRefresh()
         end
      end
    end
    gfx.getdropfile(-1)
  end
end

function reagirl.FileDropZone_Add(x,y,w,h,func)
  if reagirl.DropZone==nil then reagirl.DropZone={} end
  reagirl.DropZone[#reagirl.DropZone+1]={}
  reagirl.DropZone[#reagirl.DropZone]["DropZoneFunc"]=func
  reagirl.DropZone[#reagirl.DropZone]["DropZoneX"]=x
  reagirl.DropZone[#reagirl.DropZone]["DropZoneY"]=y
  reagirl.DropZone[#reagirl.DropZone]["DropZoneW"]=w
  reagirl.DropZone[#reagirl.DropZone]["DropZoneH"]=h
end

function reagirl.Window_ForceSize()
  if reagirl.Window_ForceSize_Toggle==false then return end
  local h,w
  if gfx.w<reagirl.Window_MinW-1 then w=reagirl.Window_MinW else w=gfx.w end
  if gfx.h<reagirl.Window_MinH-1 then h=reagirl.Window_MinH else h=gfx.h end
  
  if gfx.w==w and gfx.h==h then return end
  gfx.init("", w, h)
  reagirl.Gui_ForceRefresh()
end

function reagirl.Gui_ForceRefresh()
  reagirl.Gui_ForceRefreshState=true
end

function reagirl.Window_ForceMinSize(MinW, MinH)
  reagirl.Window_ForceSize_Toggle=true
  reagirl.Window_MinW=MinW
  reagirl.Window_MinH=MinH
end


--- End of ReaGirl-functions


function DropDownList(element_id, check, name)
  print2(element_id, check, name)
end







function UpdateImage2(element_id)
  reagirl.Gui_ForceRefreshState=true
  if gfx.mouse_cap==1 then
    retval, filename = reaper.GetUserFileNameForRead("", "", "")
    if retval==true then
      reagirl.Image_Update(element_id, filename)
    end
  end
  --]]
end

function GetFileList(filelist)
  reagirl.Image_Update(4, filelist[1])
  AFile=filelist
  list=""
  for i=1, 1000 do
    if filelist[i]~=nil then 
      list=list..i..": "..filelist[i].."\n"
    end
  end
 -- print2(list)
end

function GetFileList2(filelist)
  list=""
  for i=1, 1000 do
    if filelist[i]==nil then break end
    list=list..filelist[i].."\n"
  end
  print2("Zwo:"..list)
end

function CheckMe(tudelu)
--  print2(tudelu)
end


local count=0
local count2=0
function main()
  reagirl.Gui_Manage()
  count=count+2
  count2=count2+4
  if count>100 then count=0 end
  if count2>300 then count2=0 end
  --reagirl.UI_Element_Move(2, count, count2, w, h)
  --[[if gfx.mouse_cap==1 then reagirl.UI_Element_SetSelected(1)
  elseif gfx.mouse_cap==2 then reagirl.UI_Element_SetSelected(2)
  elseif gfx.mouse_cap==3 then reagirl.UI_Element_SetSelected(3)
  end
  --]]
  AVert, AHorz = reagirl.UI_Elements_OutsideWindow()
  if reagirl.Window_IsOpen()==true then reaper.defer(main) end
end

function Dummy()
end


function UpdateUI()
  reagirl.Gui_New()
  reagirl.Background_GetSetColor(true, 44,44,44)
  reagirl.Background_GetSetImage("c:\\m.png", 1, 0, true, false, true)
  if update==true then
    retval, filename = reaper.GetUserFileNameForRead("", "", "")
    if retval==true then
      Images[1]=filename
    end
  end
  --reagirl.SetWindowBackground(0.10, 0, 0)
  
  C=reagirl.Image_Add(Images[2], -230, 175, 100, 100, "Contrapoints", "Contrapoints: A Youtube-Channel", "See internet for more details")
  A=reagirl.CheckBox_Add(-230, 90, "CoreAudio", "Description of the Checkbox", "Tooltip", true, CheckMe)
  
  A1=reagirl.CheckBox_Add(-230, 110, "Tudelu2", "Description of the Checkbox", "Tooltip", true, CheckMe)
  A2=reagirl.CheckBox_Add(-230, 130, "Tudelu3", "Description of the Checkbox", "Tooltip", true, CheckMe)
  
  reagirl.FileDropZone_Add(-230,175,100,100, GetFileList)
  B=reagirl.Image_Add(Images[3], 100, 100, 100, 100, "Mespotine", "Mespotine: A Podcast Empress", "See internet for more details", UpdateImage2, {1})
  reagirl.FileDropZone_Add(100,100,100,100, GetFileList2)
  
  E=reagirl.DropDownMenu_Add(-230, 150, -10, "DropDownMenu:", "Desc of DDM", "DDM", 5, {"The", "Death", "Of", "A", "Party                  Hardy Hard Scooter",2,3,4,5}, DropDownList)
  reagirl.Label_Add("Stonehenge\nWhere the demons dwell\nwhere the banshees live\nand they do live well:", -317, 150, 100, 0, "everything under control")
  --reagirl.AddDummyElement()
  D=reagirl.Image_Add(Images[1], 0, 0, 100, 100, "Contrapoints2", "Contrapoints2: A Youtube-Channel", "See internet for more details")  
  reagirl.Rect_Add(-400,-200,320,120,1,0,1,0.5,1)
  reagirl.Line_Add(-1,-2,-1,1,0,1,1,1)
  
end


Images={"c:\\c.png","c:\\f.png","c:\\m.png"}
reagirl.Gui_Open("Faily", "A Failstate Manager", nil,nil,nil,nil,nil)
UpdateUI()
reagirl.Window_ForceMinSize(640, 277)
--reagirl.Gui_ForceRefreshState=true
--main()

main()

--print2("Pudeldu")