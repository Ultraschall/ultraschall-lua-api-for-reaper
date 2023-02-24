dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")--0123456789A123456789B123456789C123456789D123456789E

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

gfx.init("", 640, 60,0,0,0)

inputbox={}
inputbox.hasfocus=false
inputbox.hasfocus_old=false
inputbox.x=10
inputbox.y=20
inputbox.w=gfx.w-10
inputbox.h=50
inputbox.cursor_offset=1
inputbox.draw_offset=inputbox.cursor_offset
inputbox.draw_max=inputbox.draw_offset+math.floor(inputbox.w/gfx.measurechar("65")-1)-1-inputbox.draw_offset
inputbox.selection_startoffset=inputbox.cursor_offset-5
inputbox.selection_endoffset=inputbox.cursor_offset+5
inputbox.Text=string.gsub(reaper.CF_GetClipboard(), "\n", "")
reagirl.mouse={}
reagirl.mouse.down=false
reagirl.mouse.downtime=os.clock()
reagirl.mouse.x=gfx.mouse_x
reagirl.mouse.y=gfx.mouse_y
reagirl.mouse.dragged=false


function reagirl.InputBox_GetTextOffset(x,y,element_storage)
  local startoffs=element_storage.x
  local cursoffs=inputbox.draw_offset
  --local textw=gfx.measurechar(65)
  if x<startoffs then return -1, element_storage.draw_offset, element_storage.draw_offset+math.floor(element_storage.w/textw) end
  
  for i=element_storage.draw_offset, element_storage.draw_offset+math.floor(element_storage.w/textw) do
    local textw=gfx.measurestr(element_storage.Text:utf8_sub(i,i))
    if x>=startoffs and x<=startoffs+textw then
      return cursoffs-1, element_storage.draw_offset, element_storage.draw_offset+math.floor(element_storage.w/textw)
    end
    cursoffs=cursoffs+1
    startoffs=startoffs+textw
  end
  return -2, element_storage.draw_offset, element_storage.draw_offset+math.floor(element_storage.w/textw)
end

function reagirl.InputBox_OnMouseDown(mouse_cap, element_storage)
  element_storage.hasfocus_old=element_storage.hasfocus
  element_storage.hasfocus=gfx.mouse_x>=element_storage.x and gfx.mouse_x<element_storage.x+element_storage.w and
                           gfx.mouse_y>=element_storage.y and gfx.mouse_y<element_storage.y+element_storage.h
  reagirl.mouse.down=true
  reagirl.mouse.x=gfx.mouse_x
  reagirl.mouse.y=gfx.mouse_y
  
  if element_storage.hasfocus==true then
    if mouse_cap&8==0 then
      element_storage.cursor_offset=reagirl.InputBox_GetTextOffset(gfx.mouse_x,gfx.mouse_y,element_storage)
      element_storage.selection_startoffset=element_storage.cursor_offset
      element_storage.selection_endoffset=element_storage.cursor_offset
    elseif mouse_cap&8==8 then
      local newoffs, startoffs, endoffs=reagirl.InputBox_GetTextOffset(gfx.mouse_x,gfx.mouse_y,element_storage)
      print_update(newoffs, startoffs, endoffs)
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

function reagirl.InputBox_OnMouseMove(mouse_cap, element_storage)
  if element_storage.hasfocus==false then return end
  local newoffs, startoffs, endoffs=reagirl.InputBox_GetTextOffset(gfx.mouse_x, gfx.mouse_y, element_storage)
  if newoffs>0 then
    if newoffs<element_storage.cursor_offset then
      element_storage.selection_startoffset=newoffs
    elseif newoffs>element_storage.cursor_offset then
      element_storage.selection_endoffset=newoffs
    elseif newoffs==element_storage.cursor_offset then
      element_storage.selection_endoffset=newoffs
      element_storage.selection_startoffset=newoffs
    end
  elseif newoffs==-1 then
    element_storage.selection_startoffset=startoffs-1
    if element_storage.selection_startoffset<0 then element_storage.selection_startoffset=0 end
    element_storage.draw_offset=element_storage.selection_startoffset
  elseif newoffs==-2 then
    element_storage.selection_endoffset=endoffs+1
    if element_storage.selection_endoffset>element_storage.Text:utf8_len() then 
      element_storage.selection_endoffset=element_storage.Text:utf8_len() 
    end
    if endoffs<element_storage.Text:utf8_len()+1 then
      element_storage.draw_offset=element_storage.draw_offset+1
    end
  end
  reagirl.mouse.dragged=true
end

function reagirl.InputBox_OnMouseUp(mouse_cap, element_storage)
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

function reagirl.InputBox_OnMouseDoubleClick(mouse_cap, element_storage)
  if element_storage.hasfocus==true then
--    print("Doppelclick")
  end
end

function reagirl.InputBox_GetShownTextoffsets(x,y,element_storage)
  local textw=gfx.measurechar(65)
  return element_storage.draw_offset, element_storage.draw_offset+math.floor(element_storage.w/textw)
end

function reagirl.InputBox_ConsolidateCursorPos(element_storage)
  if element_storage.cursor_offset>element_storage.draw_offset+element_storage.draw_max then
    element_storage.draw_offset=element_storage.cursor_offset-element_storage.draw_max+1
    if element_storage.draw_offset<0 then element_storage.draw_offset=0 end
  elseif element_storage.cursor_offset<element_storage.draw_offset then
    element_storage.draw_offset=element_storage.cursor_offset
  end
end

function reagirl.InputBox_OnTyping(Key, Key_UTF, element_storage)
  if Key_UTF~=0 then Key=Key_UTF end
  if Key==8 then
    -- Backspace
    if element_storage.cursor_offset>=0 then
      if element_storage.selection_startoffset~=element_storage.selection_endoffset then
        element_storage.Text=element_storage.Text:utf8_sub(1, element_storage.selection_startoffset)..element_storage.Text:utf8_sub(element_storage.selection_endoffset+1, -1)
        element_storage.cursor_offset=element_storage.selection_startoffset
      else
        element_storage.Text=element_storage.Text:utf8_sub(1, element_storage.selection_startoffset-1)..element_storage.Text:utf8_sub(element_storage.selection_endoffset+1, -1)
        element_storage.cursor_offset=element_storage.selection_startoffset-1
      end
      element_storage.selection_startoffset=element_storage.cursor_offset
      element_storage.selection_endoffset=element_storage.cursor_offset
      offset_s,offset_e=reagirl.InputBox_GetShownTextoffsets(x,y,element_storage)
      if element_storage.cursor_offset==offset_s-1 then element_storage.draw_offset=element_storage.draw_offset-1 end
      if element_storage.draw_offset<0 then element_storage.draw_offset=0 end
    end
  elseif Key==3 then
    -- Copy
    if reaper.CF_SetClipboard~=nil then
      reaper.CF_SetClipboard(element_storage.Text_Selected)
    end
  elseif Key==24 then
    -- Cut
    if reaper.CF_SetClipboard~=nil then
      reaper.CF_SetClipboard(element_storage.Text_Selected)
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
      local text=reaper.CF_GetClipboard()
      element_storage.Text=element_storage.Text:utf8_sub(1, element_storage.selection_startoffset)..text..element_storage.Text:utf8_sub(element_storage.selection_endoffset+1, -1)
      element_storage.cursor_offset=element_storage.cursor_offset+text:utf8_len()
      element_storage.selection_startoffset=element_storage.cursor_offset
      element_storage.selection_endoffset=element_storage.cursor_offset
      reagirl.InputBox_ConsolidateCursorPos(element_storage)
    end
  elseif Key==6579564.0 then
    -- Del Key
    if element_storage.selection_startoffset~=element_storage.selection_endoffset then
      element_storage.Text=element_storage.Text:utf8_sub(1, element_storage.selection_startoffset)..element_storage.Text:utf8_sub(element_storage.selection_endoffset+1, -1)
      element_storage.cursor_offset=element_storage.selection_startoffset
      element_storage.selection_startoffset=element_storage.cursor_offset
      element_storage.selection_endoffset=element_storage.cursor_offset
    else
      element_storage.Text=element_storage.Text:utf8_sub(1, element_storage.selection_startoffset)..element_storage.Text:utf8_sub(element_storage.selection_endoffset+2, -1)
    end
    reagirl.InputBox_ConsolidateCursorPos(element_storage)
  elseif Key==1 then
    element_storage.cursor_offset=element_storage.Text:utf8_len()
    element_storage.selection_startoffset=0
    element_storage.selection_endoffset=element_storage.cursor_offset
    reagirl.InputBox_ConsolidateCursorPos(element_storage)
  elseif Key~=0 then
    element_storage.Text=element_storage.Text:utf8_sub(1, element_storage.selection_startoffset)..utf8.char(Key)..element_storage.Text:utf8_sub(element_storage.selection_endoffset+1, -1)
    element_storage.cursor_offset=element_storage.selection_startoffset+1
    element_storage.selection_startoffset=element_storage.cursor_offset
    element_storage.selection_endoffset=element_storage.cursor_offset
    --offset_s,offset_e=reagirl.InputBox_GetShownTextoffsets(x,y,element_storage)
    --if element_storage.cursor_offset==offset_e-1 then element_storage.draw_offset=element_storage.draw_offset+1 end
    reagirl.InputBox_ConsolidateCursorPos(element_storage)
  end
  
end

function reagirl.InputBox_Manage(mouse_cap, element_storage, Key, Key_UTF)
  if mouse_cap&1==1 then 
    if reagirl.mouse.down==false then
      reagirl.InputBox_OnMouseDown(mouse_cap, element_storage) 
      if os.clock()-reagirl.mouse.downtime<0.25 then
        reagirl.InputBox_OnMouseDoubleClick(mouse_cap, element_storage)
      end
    elseif gfx.mouse_x~=reagirl.mouse.x or gfx.mouse_y~= reagirl.mouse.y then
      reagirl.InputBox_OnMouseMove(mouse_cap, element_storage)
    end
  elseif reagirl.mouse.down==true then
    reagirl.InputBox_OnMouseUp(mouse_cap, element_storage)
  end
  
  reagirl.InputBox_OnTyping(Key, Key_UTF, element_storage)
end

function reagirl.InputBox_Draw(mouse_cap, element_storage, c, c2)
  gfx.setfont(1, "Consolas", 20, 0)
  textw=gfx.measurechar("65")-1
  
  -- draw rectangle around text
  if element_storage.hasfocus==true then gfx.set(1) else gfx.set(0.5) end
  gfx.rect(element_storage.x, element_storage.y, element_storage.w, gfx.texth, 0)
  
  -- draw text
  gfx.x=element_storage.x
  gfx.y=element_storage.y
  
  for i=element_storage.draw_offset, element_storage.draw_offset+math.floor(element_storage.w/textw)-1 do
    if i>=element_storage.selection_startoffset+1 and i<=element_storage.selection_endoffset then
      gfx.setfont(1, "Consolas", 20, 86) 
    else
      gfx.setfont(1, "Consolas", 20, 0) 
    end
    element_storage.draw_max=i-element_storage.draw_offset
    
    gfx.drawstr(element_storage.Text:utf8_sub(i,i))
    if element_storage.hasfocus==true and element_storage.cursor_offset==i then 
      gfx.set(1,0,0) 
      gfx.line(gfx.x, element_storage.y, gfx.x, element_storage.y+gfx.texth) 

    if element_storage.hasfocus==true then gfx.set(1) else gfx.set(0.5) end
    end
  end
end

function main()
  c, c2 = gfx.getchar()
  inputbox.w=gfx.w-30
  inputbox.h=gfx.texth
  reagirl.InputBox_Manage(gfx.mouse_cap, inputbox, c, c2)
  reagirl.InputBox_Draw(gfx.mouse_cap, inputbox, c, c2)
  inputbox.Text_Selected=inputbox.Text:utf8_sub(inputbox.selection_startoffset+1, inputbox. selection_endoffset)
  
  A1,B1,C1=reagirl.InputBox_GetTextOffset(gfx.mouse_x, gfx.mouse_y, inputbox)
  
  reaper.defer(main)
end

inputbox.Text_Selected=""

main()
