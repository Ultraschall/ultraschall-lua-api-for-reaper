dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
reagirl={}
reagirl.Elements={}

function reagirl.OpenWindow(...)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GFX_Init</slug>
  <requires>
    ReaGirl=1.0
    Reaper=5.965
    JS=0.964
    Lua=5.3
  </requires>
  <functioncall>integer retval, optional HWND hwnd = reagirl.Init(string "name", optional integer width, optional integer height, optional integer dockstate, optional integer xpos, optional integer ypos)</functioncall>
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
  <target_document>US_Api_GFX</target_document>
  <source_document>ultraschall_gfx_engine.lua</source_document>
  <tags>gfx, functions, gfx, init, window, create, hwnd</tags>
</US_DocBloc>
]]
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
  <target_document>US_Api_GFX</target_document>
  <source_document>ultraschall_gfx_engine.lua</source_document>
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

function reagirl.NewGUI()
  gfx.setfont(1, "Arial", 20, 0)
  reagirl.MaxImage=-1
  gfx.set(reagirl["WindowBackgroundColorR"], reagirl["WindowBackgroundColorG"], reagirl["WindowBackgroundColorB"])
  gfx.rect(0,0,gfx.w,gfx.h,1)
  gfx.x=0
  gfx.y=0
  reagirl.Elements={}
  reagirl.Elements["FocusedElement"]=1
end

function reagirl.OpenGUI(title, w, h, dock, x, y)
  return reagirl.OpenWindow(title, w, h, dock, x, y)
end

function reagirl.CloseGUI()
  gfx.quit()
end



function reagirl.ManageGUI()
  for i=1, #reagirl.Elements do reagirl.Elements[i]["clicked"]=false end
  local Key, Key_utf=gfx.getchar()
  if Key==-1 then return end
  if gfx.mouse_cap&8==0 and Key==9 then reagirl.Elements["FocusedElement"]=reagirl.Elements["FocusedElement"]+1 end
  if reagirl.Elements["FocusedElement"]>#reagirl.Elements then reagirl.Elements["FocusedElement"]=#reagirl.Elements end
  if gfx.mouse_cap&8==8 and Key==9 then reagirl.Elements["FocusedElement"]=reagirl.Elements["FocusedElement"]-1 end
  if reagirl.Elements["FocusedElement"]<1 then reagirl.Elements["FocusedElement"]=1 end
  if Key==32 then reagirl.Elements[reagirl.Elements["FocusedElement"]]["clicked"]=true end
  local clickstate, specific_clickstate, mouse_cap, click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel = reagirl.GetMouseCap(5, 5)
  if (specific_clickstate=="FirstCLK") then
    for i=#reagirl.Elements, 1, -1 do
      local x2, y2
      if reagirl.Elements[i]["x"]<0 then x2=gfx.w+reagirl.Elements[i]["x"] else x2=reagirl.Elements[i]["x"] end
      if reagirl.Elements[i]["y"]<0 then y2=gfx.h+reagirl.Elements[i]["y"] else y2=reagirl.Elements[i]["y"] end
      
      if gfx.mouse_x>=x2 and
         gfx.mouse_x<=x2+reagirl.Elements[i]["w"] and
         gfx.mouse_y>=y2 and
         gfx.mouse_y<=y2+reagirl.Elements[i]["h"] then
         reagirl.Elements["FocusedElement"]=i
         reagirl.Elements[i]["clicked"]=true
         break
      end
    end
  end
  reagirl.DrawGui(Key, Key_utf, clickstate, specific_clickstate, mouse_cap, click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel)
end

function reagirl.GetSetBackgroundColor(is_set, r, g, b)
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


function reagirl.DrawGui(Key, clickstate, specific_clickstate, mouse_cap, click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel)
  -- no docs in API-docs
  local selected
  gfx.set(reagirl["WindowBackgroundColorR"],reagirl["WindowBackgroundColorG"],reagirl["WindowBackgroundColorB"])
  gfx.rect(0,0,gfx.w,gfx.h,1)
  for i=#reagirl.Elements, 1, -1 do
    if reagirl.Elements["FocusedElement"]==i then selected=true else selected=false end
    local message=reagirl.Elements[i]["func"](i, selected,
      reagirl.Elements[i]["clicked"],
      gfx.mouse_cap,
      {click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel},
      reagirl.Elements[i]["Name"],
      reagirl.Elements[i]["Description"], 
      reagirl.Elements[i]["Tooltip"], 
      reagirl.Elements[i]["x"], 
      reagirl.Elements[i]["y"],
      reagirl.Elements[i]["w"],
      reagirl.Elements[i]["h"],
      Key,
      Key_utf,
      reagirl.Elements[i]
    )
    if selected==true and reagirl.old_osara_message~=message and reaper.osara_outputMessage~=nil then
      reaper.osara_outputMessage(message)
      reagirl.old_osara_message=message
    end
  end
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
  reagirl.Elements[#reagirl.Elements]["func"]=reagirl.DrawDummyElement
  
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

function reagirl.AddImage(image_file, x, y, w, h, Name, Description, Tooltip, run_function, func_params)
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
  reagirl.Elements[#reagirl.Elements]["Image_File"]=image_file
  reagirl.Elements[#reagirl.Elements]["Image_Storage"]=reagirl.MaxImage
  reagirl.Elements[#reagirl.Elements]["func"]=reagirl.DrawImage
  reagirl.Elements[#reagirl.Elements]["run_function"]=run_function
  reagirl.Elements[#reagirl.Elements]["func_params"]=func_params
  gfx.dest=reagirl.Elements[#reagirl.Elements]["Image_Storage"]
  local r,g,b,a=gfx.r,gfx.g,gfx.b,gfx.a
  gfx.set(0)
  gfx.rect(0,0,8192,8192)
  gfx.set(r,g,b,a)
  gfx.dest=-1
  local AImage=gfx.loadimg(reagirl.Elements[#reagirl.Elements]["Image_Storage"], image_file)
  local retval = ultraschall.GFX_ResizeImageKeepAspectRatio(reagirl.Elements[#reagirl.Elements]["Image_Storage"], w, h, 0, 0, 0)
  return #reagirl.Elements
end

function reagirl.DrawImage(element_id, selected, clicked, mouse_cap, mouse_attributes, name, description, tooltip, x, y, w, h, Key, Key_UTF, element_storage)
  -- no docs in API-docs
  local r,g,b,a,message,oldx,oldy,oldmode
  r=gfx.r
  g=gfx.g
  b=gfx.b
  a=gfx.a
  oldmode=gfx.mode
  --gfx.mode=1
  gfx.set(0)
  gfx.rect(x,y,w,h,1)
  oldx,oldy=gfx.x, gfx.y
  
  if selected==true then
    message="Focused Image "..description
  else
    message=""
  end
  if x<0 then x2=gfx.w+x else x2=x end
  if y<0 then y2=gfx.h+y else y2=y end
  
  gfx.x=x2
  gfx.y=y2
  
  if selected==true and 
    (Key==32 or mouse_cap==1) and 
    (gfx.mouse_x>=x2 and gfx.mouse_x<=x2+w and gfx.mouse_y>=y2 and gfx.mouse_y<=y2+h) and
    element_storage["run_function"]~=nil then element_storage["run_function"](table.unpack(element_storage["func_params"])) end
  
  gfx.dest=-1
  gfx.blit(element_storage["Image_Storage"], 1, 0)
  if selected==true then
    gfx.set(1)
    gfx.rect(x2,y2,w,h,0)
    message="Focused Image "..description
  end
  gfx.r,gfx.g,gfx.b,gfx.a=r,g,b,a
  gfx.mode=oldmode
  gfx.x=oldx
  gfx.y=oldy
  return message
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
end

function reagirl.UI_Element_SetSelected(element_id)
  if element_id<1 or element_id>#reagirl.Elements then error("UI_Element_SetSelected: param #1 - no such UI-element", 2) end
  reagirl.Elements["FocusedElement"]=element_id
end

function UpdateUI(update)
  reagirl.NewGUI()
  if update==true then
    retval, filename = reaper.GetUserFileNameForRead("", "", "")
    if retval==true then
      Images[1]=filename
    end
  end
  --reagirl.SetWindowBackground(0.10, 0, 0)
  A=reagirl.AddImage(Images[1], -105, -110, 100, 100, "Mespotine", "Mespotine: A Podcast Empress", "See internet for more details", UpdateUI, {true})
  --reagirl.AddDummyElement()
  B=reagirl.AddImage(Images[2], -150, -170, 100, 100, "Contrapoints", "Contrapoints: A Youtube-Channel", "See internet for more details")
  C=reagirl.AddImage(Images[3], 140, 140, 100, 100, "Contrapoints2", "Contrapoints2: A Youtube-Channel", "See internet for more details")  
  
end

Images={"c:\\m.png","c:\\c.png","c:\\logo.jpg"}
reagirl.OpenGUI("Test")
UpdateUI()



--reagirl.GetSetBackgroundColor(true, 100, g, b)
--reagirl.Button(10, 10, 10, 100, "Hulubuluberg", "Description", "Tooltip")
count=0
count2=0
function main()
  reagirl.ManageGUI()
  count=count+2
  count2=count2+4
  if count>100 then count=0 end
  if count2>300 then count2=0 end
  reagirl.UI_Element_Move(1, count, count2, w, h)
  --[[if gfx.mouse_cap==1 then reagirl.UI_Element_SetSelected(1)
  elseif gfx.mouse_cap==2 then reagirl.UI_Element_SetSelected(2)
  elseif gfx.mouse_cap==3 then reagirl.UI_Element_SetSelected(3)
  end
  --]]
  reaper.defer(main)
end

main()
