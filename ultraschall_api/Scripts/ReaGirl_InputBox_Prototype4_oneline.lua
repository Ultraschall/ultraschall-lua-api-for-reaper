dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

-- TODO:
-- With short initial texts, MoveVisibleCursor doesn't work correctly!
-- Textselection via Mousedrag
-- Paste this into the box and do Home-Key - buggy(line too long)
-- local NewOffset=Clippy:utf8_len()+workspace["cursor_offset"]

reagirl={}

function reagirl.GetMouseCap(doubleclick_wait, drag_wait)
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


--print2(Aworkspace["draw_range_cur"])
--if Aworkspace["draw_range_cur"]<0 then Aworkspace["draw_range_cur"]=Aworkspace["Text"]:utf8_len()-Aworkspace["draw_range_max"] end
--Aworkspace["draw_range_cur"]=
--if Aworkspace["draw_range_cur"]>Aworkspace["draw_range_max"] then Aworkspace["draw_range_cur"]=0 end

gfx.setfont(1,"Calibri", 20)
gfx.setfont(1,"Consolas", 20)

function string.has_control(String)
  if type(String)~="string" then error("bad argument #1, to 'has_control' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%c")~=nil
end

function string.has_alphanumeric(String)
  if type(String)~="string" then error("bad argument #1, to 'has_alphanumeric' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%w")~=nil
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

function reagirl.InputField_FindNextGoToPoint(element_storage)
  local cursor_offset=element_storage["cursor_offset"]
  if cursor_offset==element_storage["Text"]:utf8_len() then return element_storage["Text"]:utf8_len()+1 end
  
  for i=cursor_offset+1, element_storage["Text"]:utf8_len() do
    if element_storage["Text"]:utf8_sub(i,i):has_alphanumeric()~=element_storage["Text"]:utf8_sub(i+1,i+1):has_alphanumeric() then
      return i+1
    end
  end

  return element_storage["Text"]:utf8_len()+1
end

function reagirl.InputField_FindPreviousGoToPoint(element_storage)
  local cursor_offset=element_storage["cursor_offset"]
  if cursor_offset==0 then return 0 end
  
  for i=cursor_offset-1, 1, -1 do
    if element_storage["Text"]:utf8_sub(i,i):has_alphanumeric()~=element_storage["Text"]:utf8_sub(i-1,i-1):has_alphanumeric() then
      return i-1
    end
  end
  
  return 0
end

function reagirl.InputField_MoveVisibleCursor(element_storage, pos)
  local cursor_offset=element_storage["cursor_offset"]
  local draw_offset=element_storage["draw_offset"]
  local draw_range_cur=element_storage["draw_range_cur"]
  local draw_range_max=element_storage["draw_range_max"]
  
  -- moving to the left
  if pos<0 then
    draw_range_cur=draw_range_cur+pos
    if draw_range_cur<0 then
      draw_offset=draw_offset+draw_range_cur
      draw_range_cur=0
    end
  end
  
  -- moving to the right
  if pos>0 then
    draw_range_cur=draw_range_cur+pos
    if draw_range_cur>=draw_range_max then
      draw_offset=draw_offset+(draw_range_cur-draw_range_max)
      draw_range_cur=draw_range_max
    end
  end
  if draw_offset<=0 then draw_offset=1 end
  element_storage["draw_offset"]=draw_offset
  element_storage["draw_range_cur"]=draw_range_cur
end

function reagirl.InputField_SetSelection(element_storage, position, cursor_offset)
  local selection_start=element_storage["selection_start"]
  local selection_end=element_storage["selection_end"]
  local cursor_offset=element_storage["cursor_offset"]
  
  if position<0 then
    if cursor_offset<selection_start then
      selection_start=cursor_offset
    elseif cursor_offset<selection_end and cursor_offset>selection_start then
      selection_end=cursor_offset
    else
      selection_start=cursor_offset
      selection_end=cursor_offset
    end
  elseif position>0 then
    if cursor_offset>selection_end then
      selection_end=cursor_offset
    elseif cursor_offset<selection_end and cursor_offset>selection_start then
      selection_start=cursor_offset
    else
      selection_start=cursor_offset
      selection_end=cursor_offset
    end
  else 
   -- selection_start=cursor_offset
   -- selection_end=cursor_offset
  end
  
  element_storage["selection_start"]=selection_start
  element_storage["selection_end"]=selection_end
end

function reagirl.InputField_Manage(element_id, selected, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  local cursor_offset=element_storage["cursor_offset"]
  
  for i=0, 20 do
    --gfx.rect(math.floor((i)*(gfx.measurechar(65)-1)), y, gfx.measurechar(65)-2, gfx.texth, 0)
  end
  if gfx.mouse_y>=y-4 and gfx.mouse_y<=gfx.y+gfx.texth+4 then
    if gfx.mouse_x>=x and gfx.mouse_x<=x+(gfx.measurechar(65)*(element_storage["draw_range_max"])) then
      if clicked=="FirstCLK" then 
        element_storage["cursor_offset"]=element_storage["draw_offset"]+math.floor((gfx.mouse_x-x)/(gfx.measurechar(65)-1))-1
        element_storage["selection_start"]=element_storage["cursor_offset"]
        element_storage["selection_end"]=element_storage["cursor_offset"]
        element_storage["draw_range_cur"]=element_storage["cursor_offset"]-element_storage["draw_offset"]
      elseif clicked=="DBLCLK" then
        element_storage["selection_start"]=reagirl.InputField_FindPreviousGoToPoint(element_storage)
        element_storage["selection_end"]=reagirl.InputField_FindNextGoToPoint(element_storage)-1
        element_storage["cursor_offset"]=element_storage["selection_end"]
        element_storage["draw_range_cur"]=element_storage["cursor_offset"]-element_storage["draw_offset"]
      elseif clicked=="DRAG" then
        drag=element_storage["draw_offset"]+math.floor((gfx.mouse_x-x)/(gfx.measurechar(65)-1))-1
        if drag>element_storage["cursor_offset"] then
          element_storage["selection_end"]=element_storage["draw_offset"]+math.floor((gfx.mouse_x-x)/(gfx.measurechar(65)-1))-1
        elseif drag<element_storage["cursor_offset"] then
          element_storage["selection_start"]=element_storage["draw_offset"]+math.floor((gfx.mouse_x-x)/(gfx.measurechar(65)-1))-1
        else
          element_storage["selection_start"]=element_storage["cursor_offset"]
          element_storage["selection_end"]=element_storage["cursor_offset"]
        end
      end
    --elseif 
      -- TODO: Wenn Maus links von Textfeld klickt(ohne Drag) -> positioniere Cursor an Anfang des TextFeldes
    --elseif 
      -- TODO: Wenn Maus rechts von Textfeld klickt (ohne Drag) -> positioniere Cursor ans Ende des TextFeldes
    else
      A1=nil
    end
  end
  if Key~=0 then
    if Key==1818584692.0 then
      -- left key
      if gfx.mouse_cap&4==4 then
        local offset=reagirl.InputField_FindPreviousGoToPoint(element_storage)
        local old_cursor=element_storage["cursor_offset"]
        if offset~=nil then
          reagirl.InputField_MoveVisibleCursor(element_storage, offset-element_storage["cursor_offset"])
          element_storage["cursor_offset"]=offset
        end
        if old_cursor>0 and gfx.mouse_cap&8==8 then
        --print2(old_cursor)
          -- Shift+Ctrl
          reagirl.InputField_SetSelection(element_storage, -1)
        elseif old_cursor==0 and gfx.mouse_cap&8==8 then
        else
          element_storage["selection_start"]=element_storage["cursor_offset"]
          element_storage["selection_end"]=element_storage["cursor_offset"]
        end
      elseif gfx.mouse_cap&8==8 then
        -- Shift
        element_storage["cursor_offset"]=element_storage["cursor_offset"]-1
        if element_storage["cursor_offset"]<0 then 
          element_storage["cursor_offset"]=0 
        else 
          reagirl.InputField_MoveVisibleCursor(element_storage, -1) 
          reagirl.InputField_SetSelection(element_storage, -1, element_storage["cursor_offset"])
        end
      else 
        element_storage["cursor_offset"]=element_storage["cursor_offset"]-1
        element_storage["selection_start"]=element_storage["cursor_offset"]
        element_storage["selection_end"]=element_storage["cursor_offset"]
        if element_storage["cursor_offset"]<0 then element_storage["cursor_offset"]=0 else reagirl.InputField_MoveVisibleCursor(element_storage, -1) end
      end
    elseif Key==1919379572.0 then
      -- right key
      if gfx.mouse_cap&4==4 then
        local offset=reagirl.InputField_FindNextGoToPoint(element_storage)
        local old_cursor=element_storage["cursor_offset"]
        if offset~=nil then
          reagirl.InputField_MoveVisibleCursor(element_storage, offset-element_storage["cursor_offset"]-1)
          element_storage["cursor_offset"]=offset-1
        end
        if gfx.mouse_cap&8==8 and old_cursor<element_storage["Text"]:utf8_len() then
          -- Shift+Ctrl
          reagirl.InputField_SetSelection(element_storage, 1, element_storage["cursor_offset"])
        elseif old_cursor==element_storage["Text"]:utf8_len() and gfx.mouse_cap&8==8 then
        else
          element_storage["selection_start"]=element_storage["cursor_offset"]
          element_storage["selection_end"]=element_storage["cursor_offset"]
        end
      elseif gfx.mouse_cap&8==8 then
          -- Shift
        element_storage["cursor_offset"]=element_storage["cursor_offset"]+1
        if element_storage["cursor_offset"]>element_storage["Text"]:utf8_len() then 
          element_storage["cursor_offset"]=element_storage["Text"]:utf8_len()
        else 
          reagirl.InputField_MoveVisibleCursor(element_storage, 1)
          reagirl.InputField_SetSelection(element_storage, 1, element_storage["cursor_offset"])
        end
      else
        element_storage["cursor_offset"]=element_storage["cursor_offset"]+1
        if element_storage["cursor_offset"]>element_storage["Text"]:utf8_len() then 
          element_storage["cursor_offset"]=element_storage["Text"]:utf8_len()
        else 
          reagirl.InputField_MoveVisibleCursor(element_storage, 1)
        end
        element_storage["selection_start"]=element_storage["cursor_offset"]
        element_storage["selection_end"]=element_storage["cursor_offset"]
      end
    elseif Key==30064.0 then
      -- arrow up key
    elseif Key==1685026670.0 then
      -- arrow down key
    elseif Key>=26161.0 and Key<26169 then
      --F1 through F9
    elseif Key>=6697264.0 and Key<=6697270.0 then 
      -- F10 through F16
    elseif Key==27.0 then 
      -- ESC-Key
    elseif Key==9.0 then 
      -- Tab Key
    elseif Key==1.0 then
      element_storage["selection_start"]=0
      element_storage["selection_end"]=element_storage["Text"]:utf8_len()
    elseif Key==8.0 then
      -- Backspace
      if element_storage["selection_start"]==element_storage["selection_end"] and element_storage["cursor_offset"]>0 then
        element_storage["Text"]=element_storage["Text"]:utf8_sub(1,element_storage["selection_start"]-1)..element_storage["Text"]:utf8_sub(element_storage["selection_end"]+1,-1)
        element_storage["cursor_offset"]=element_storage["cursor_offset"]-1
        reagirl.InputField_MoveVisibleCursor(element_storage, -1)
      else
        element_storage["cursor_offset"]=element_storage["selection_start"]
        element_storage["Text"]=element_storage["Text"]:utf8_sub(1,element_storage["selection_start"])..element_storage["Text"]:utf8_sub(element_storage["selection_end"]+1,-1)
      end
      if element_storage["cursor_offset"]<0 then element_storage["cursor_offset"]=0 end
      element_storage["selection_start"]=element_storage["cursor_offset"]
      element_storage["selection_end"]=element_storage["cursor_offset"]
    elseif Key==6579564.0 then
      -- Del-Key
      if element_storage["selection_start"]==element_storage["selection_end"] then
        element_storage["Text"]=element_storage["Text"]:utf8_sub(1,element_storage["selection_start"])..element_storage["Text"]:utf8_sub(element_storage["selection_end"]+2,-1)
      else
        element_storage["cursor_offset"]=element_storage["selection_start"]
        element_storage["Text"]=element_storage["Text"]:utf8_sub(1,element_storage["selection_start"])..element_storage["Text"]:utf8_sub(element_storage["selection_end"]+1,-1)
      end
      if element_storage["cursor_offset"]<0 then element_storage["cursor_offset"]=0 end
      element_storage["selection_start"]=element_storage["cursor_offset"]
      element_storage["selection_end"]=element_storage["cursor_offset"]
    elseif Key==1752132965.0 then
      -- Home Key
      if gfx.mouse_cap&8==0 then
        reagirl.InputField_MoveVisibleCursor(element_storage, -element_storage["cursor_offset"])
        element_storage["cursor_offset"]=0
        element_storage["selection_start"]=element_storage["cursor_offset"]
        element_storage["selection_end"]=element_storage["cursor_offset"]
      elseif gfx.mouse_cap&8==8 then
        reagirl.InputField_MoveVisibleCursor(element_storage, -element_storage["cursor_offset"])
        element_storage["cursor_offset"]=0
        element_storage["selection_start"]=element_storage["cursor_offset"]
      end
    elseif Key==6647396.0 then
      -- End Key
      if gfx.mouse_cap&8==0 then
        reagirl.InputField_MoveVisibleCursor(element_storage, -element_storage["cursor_offset"])
        reagirl.InputField_MoveVisibleCursor(element_storage, element_storage["Text"]:utf8_len()-3)
        element_storage["cursor_offset"]=element_storage["Text"]:utf8_len()
        element_storage["selection_start"]=element_storage["cursor_offset"]
        element_storage["selection_end"]=element_storage["cursor_offset"]
      elseif gfx.mouse_cap&8==8 then
        reagirl.InputField_MoveVisibleCursor(element_storage, -element_storage["cursor_offset"])
        reagirl.InputField_MoveVisibleCursor(element_storage, element_storage["Text"]:utf8_len())
        element_storage["cursor_offset"]=element_storage["Text"]:utf8_len()
        element_storage["selection_end"]=element_storage["cursor_offset"]
      end
    elseif Key==3.0 then
      -- Cmd+C for Copy To Clipboard
      if element_storage["selection_start"]~=element_storage["selection_end"] then
        reaper.CF_SetClipboard(element_storage["Text"]:utf8_sub(element_storage["selection_start"]+1, element_storage["selection_end"]))
      end
    elseif Key==22.0 then
      -- Cmd+V for Paste from Clipboard
      Clippy=reaper.CF_GetClipboard()
      Clippy=string.gsub(Clippy, "%c", "")
      local NewOffset=Clippy:utf8_len()+element_storage["cursor_offset"]
      
      element_storage["Text"]=element_storage["Text"]:utf8_sub(1, element_storage["selection_start"])..Clippy..element_storage["Text"]:utf8_sub(element_storage["selection_end"]+1, -1)
      element_storage["cursor_offset"]=element_storage["cursor_offset"]+Clippy:utf8_len()
      element_storage["selection_start"]=element_storage["cursor_offset"]
      element_storage["selection_end"]=element_storage["cursor_offset"]
      
      if NewOffset>element_storage["draw_offset"]+element_storage["draw_range_max"] then
        element_storage["draw_offset"]=element_storage["cursor_offset"]
        element_storage["draw_range_cur"]=0
      end
    elseif Key_utf8~=0 and Key_utf8~=nil then
      element_storage["Text"]=element_storage["Text"]:utf8_sub(1, element_storage["selection_start"])..utf8.char(Key_utf8)..element_storage["Text"]:utf8_sub(element_storage["selection_end"]+1, -1)
      element_storage["cursor_offset"]=element_storage["selection_start"]+1
      element_storage["selection_start"]=element_storage["cursor_offset"]
      element_storage["selection_end"]=element_storage["cursor_offset"]
      reagirl.InputField_MoveVisibleCursor(element_storage, 1)
    else
      element_storage["Text"]=element_storage["Text"]:utf8_sub(1, element_storage["selection_start"])..utf8.char(Key)..element_storage["Text"]:utf8_sub(element_storage["selection_end"]+1, -1)
      element_storage["cursor_offset"]=element_storage["selection_start"]+1
      element_storage["selection_start"]=element_storage["cursor_offset"]
      element_storage["selection_end"]=element_storage["cursor_offset"]
      reagirl.InputField_MoveVisibleCursor(element_storage, 1)
    end
  end
  
  --element_storage["cursor_offset"]=cursor_offset
  --element_storage["draw_offset"]=draw_offset
  --element_storage["draw_range_cur"]=draw_range_cur
  --element_storage["Text"]=Text
  
end

function reagirl.InputField_Draw(x, y, w, h, Key, Key_utf8, element_storage)
  gfx.setfont(1,"Calibri", 20)
  gfx.setfont(1,"Consolas", 20)
  
  local cursor_offset=element_storage["cursor_offset"]
  local draw_offset=element_storage["draw_offset"]
  local draw_range_max=element_storage["draw_range_max"]
  local selection_start=element_storage["selection_start"]
  local selection_end=element_storage["selection_end"]
  gfx.x=x
  gfx.y=y
  --
  -- rectangle-stuff
  gfx.set(0.2)
  gfx.rect(x-2,y-3,gfx.measurechar(65)*(element_storage["draw_range_max"]+1)+4, gfx.texth+6, 1)
  gfx.set(0.6)
  gfx.rect(x-2,y-3,gfx.measurechar(65)*(element_storage["draw_range_max"]+1)+4, gfx.texth+6, 0)
  gfx.set(1)
  gfx.rect(x-1,y-2,gfx.measurechar(65)*(element_storage["draw_range_max"]+1)+4, gfx.texth+6, 0)
  --]]
  CAP_STRING=""
  CAP_STRING2=element_storage["Text"]:utf8_sub(element_storage["selection_start"]+1, element_storage["selection_end"])
  --print_update(draw_offset, draw_range_max+draw_offset, draw_range_max, draw_offset)
  if draw_offset+1<0 then draw_offset=1 end
  if cursor_offset==draw_offset then
    --gfx.line(gfx.x, gfx.y, gfx.x, gfx.y+gfx.texth)
  end
  
  CAPO=0
  if draw_offset<=0 then draw_offset=0 end
  for i=draw_offset, draw_range_max+draw_offset+2 do
  CAPO=CAPO+1
    --print(element_storage["Text"]:utf8_sub(i,i))
    if i>=selection_start+1 and i<=selection_end then
      gfx.setfont(1, "Consolas", 20, 86) 
    elseif selection_start~=selection_end and i==selection_end+1 then 
      gfx.setfont(1, "Consolas", 20, 0) 
    end
    gfx.drawstr(element_storage["Text"]:utf8_sub(i,i))
    CAP_STRING=CAP_STRING..element_storage["Text"]:utf8_sub(i,i)
    if cursor_offset==i then
      gfx.set(0.6)
      gfx.line(gfx.x, gfx.y, gfx.x, gfx.y+gfx.texth)
      gfx.set(1)
      gfx.line(gfx.x+1, gfx.y+1, gfx.x+1, gfx.y+1+gfx.texth)
    end
  end
end


gfx.init("",640,170)
function main()
  Key,Key_UTF=gfx.getchar()
  --if A>0 then print3(A) end
  C=Aelement_storage["Text"]:len()
  --gfx.set(1,0,0)
  --gfx.rect(1,1,gfx.w,gfx.h,0)
  --gfx.set(1)
  x=100
  y=100
  w=100
  h=100
  clickstate, specific_clickstate, mouse_cap, click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel=reagirl.GetMouseCap(5, 5)
  if specific_clickstate~="" then print(specific_clickstate) end
  reagirl.InputField_Manage(element_id, true, specific_clickstate, gfx.mouse_cap, {click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel}, name, description, x, y, w, h, Key, Key_UTF, Aelement_storage)
  reagirl.InputField_Draw(x, y, w, h, A,B, Aelement_storage)
  --gfx.rect(1,1,gfx.w,gfx.h,1)
  reaper.defer(main)
end

Aelement_storage={}
Aelement_storage["Text"]=reaper.CF_GetClipboard()--"Test Home of Oblivionsjdijsid juidjsid ALLABAMMA"
Aelement_storage["cursor_offset"]=Aelement_storage["Text"]:utf8_len()
Aelement_storage["selection_start"]=Aelement_storage["cursor_offset"]
Aelement_storage["selection_end"]=Aelement_storage["cursor_offset"]
Aelement_storage["draw_range_max"]=20
Aelement_storage["draw_offset"]=Aelement_storage["cursor_offset"]-Aelement_storage["draw_range_max"]-1
if Aelement_storage["draw_offset"]<0 then Aelement_storage["draw_offset"]=0 end
if Aelement_storage["Text"]:utf8_len()>Aelement_storage["draw_range_max"] then
  Aelement_storage["draw_range_cur"]=Aelement_storage["draw_range_max"]
else
  Aelement_storage["draw_range_cur"]=Aelement_storage["Text"]:utf8_len()
end

cursor_offset=0
draw_offset=0
main()
