dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

reagirl={}
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

function reagirl.InputField_FindNextGoToPoint(workspace)
  local cursor_offset=workspace["cursor_offset"]
  local Text=workspace["Text"].." "
  local found=Text:utf8_len()
  for i=cursor_offset+1, Text:utf8_len() do
    if Text:utf8_sub(i,i):match("%A")~=nil then found=i found2=Text:utf8_sub(i,i) break end
  end
  for i=found, Text:utf8_len() do
    if Text:utf8_sub(i,i):match("%a")~=nil then return i end
  end
  return found
end

function reagirl.InputField_FindPreviousGoToPoint(workspace)
  local cursor_offset=workspace["cursor_offset"]
  local Text=" "..workspace["Text"]
  local found=0
  for i=cursor_offset-1, 0, -1 do
    if Text:utf8_sub(i,i):match("%A")~=nil then found=i found2=Text:utf8_sub(i,i) break end
  end
  for i=found, 0, -1 do
    if Text:utf8_sub(i,i):match("%a")~=nil then return i end
  end
  return 0
end

function reagirl.InputField_MoveVisibleCursor(workspace, pos)
  local cursor_offset=workspace["cursor_offset"]
  local draw_offset=workspace["draw_offset"]
  local draw_range_cur=workspace["draw_range_cur"]
  local draw_range_max=workspace["draw_range_max"]
  local Text=workspace["Text"]
  
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

  workspace["draw_offset"]=draw_offset
  workspace["draw_range_cur"]=draw_range_cur
end

function reagirl.InputField_SetSelection(workspace, position, cursor_offset)
  local selection_start=workspace["selection_start"]
  local selection_end=workspace["selection_end"]
  local cursor_offset=workspace["cursor_offset"]
  
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
  
  workspace["selection_start"]=selection_start
  workspace["selection_end"]=selection_end
end

function reagirl.InputField_Manage(Key, Key_utf8, workspace)
  local cursor_offset=workspace["cursor_offset"]
  local draw_offset=workspace["draw_offset"]
  local draw_range_cur=workspace["draw_range_cur"]
  local draw_range_max=workspace["draw_range_max"]
  local selection_start=workspace["selection_start"]
  local selection_end=workspace["selection_end"]
  
  local Text=workspace["Text"]
  
  if Key~=0 then
    if Key==1818584692.0 then
      -- left key
      if gfx.mouse_cap&4==4 then
        local offset=reagirl.InputField_FindPreviousGoToPoint(workspace)
        local old_cursor=workspace["cursor_offset"]
        if offset~=nil then
          reagirl.InputField_MoveVisibleCursor(workspace, offset-workspace["cursor_offset"])
          workspace["cursor_offset"]=offset
        end
        if old_cursor~=0 and gfx.mouse_cap&8==8 then
          -- Shift+Ctrl
          reagirl.InputField_SetSelection(workspace, -1)
        else
          reagirl.InputField_SetSelection(workspace, 0)
        end
      elseif gfx.mouse_cap&8==8 then
        -- Shift
        workspace["cursor_offset"]=workspace["cursor_offset"]-1
        if workspace["cursor_offset"]<0 then 
          workspace["cursor_offset"]=0 
        else 
          reagirl.InputField_MoveVisibleCursor(workspace, -1) 
          reagirl.InputField_SetSelection(workspace, -1, workspace["cursor_offset"])
        end
      else 
        workspace["cursor_offset"]=workspace["cursor_offset"]-1
        workspace["selection_start"]=workspace["cursor_offset"]
        workspace["selection_end"]=workspace["cursor_offset"]
        if workspace["cursor_offset"]<0 then workspace["cursor_offset"]=0 else reagirl.InputField_MoveVisibleCursor(workspace, -1) end
      end
    elseif Key==1919379572.0 then
      -- right key
      if gfx.mouse_cap&4==4 then
        local offset=reagirl.InputField_FindNextGoToPoint(workspace)
        if offset~=nil then
          reagirl.InputField_MoveVisibleCursor(workspace, offset-workspace["cursor_offset"]-1)
          workspace["cursor_offset"]=offset-1
        end
        if gfx.mouse_cap&8==8 then
          -- Shift+Ctrl
          reagirl.InputField_SetSelection(workspace, -1, workspace["cursor_offset"])
        else
          reagirl.InputField_SetSelection(workspace, 0, workspace["cursor_offset"])
        end
      elseif gfx.mouse_cap&8==8 then
          -- Shift
        workspace["cursor_offset"]=workspace["cursor_offset"]+1
        if workspace["cursor_offset"]>workspace["Text"]:utf8_len() then 
          workspace["cursor_offset"]=workspace["Text"]:utf8_len()
        else 
          reagirl.InputField_MoveVisibleCursor(workspace, 1)
          reagirl.InputField_SetSelection(workspace, 1, workspace["cursor_offset"])
        end
        
      else
        workspace["cursor_offset"]=workspace["cursor_offset"]+1
        if workspace["cursor_offset"]>workspace["Text"]:utf8_len() then 
          workspace["cursor_offset"]=workspace["Text"]:utf8_len()
        else 
          reagirl.InputField_MoveVisibleCursor(workspace, 1)
        end
        workspace["selection_start"]=workspace["cursor_offset"]
        workspace["selection_end"]=workspace["cursor_offset"]
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
    elseif Key==8.0 then
      -- Backspace
      workspace["Text"]=workspace["Text"]:sub_utf8(1,workspace["cursor_offset"]-1)..workspace["Text"]:sub_utf8(workspace["cursor_offset"]+1,-1)
      workspace["cursor_offset"]=workspace["cursor_offset"]-1
      if workspace["cursor_offset"]<0 then workspace["cursor_offset"]=0 end
    elseif Key==6579564.0 then
      -- Del-Key
      workspace["Text"]=workspace["Text"]:sub_utf8(1,workspace["cursor_offset"])..workspace["Text"]:sub_utf8(workspace["cursor_offset"]+2,-1)
    elseif Key==1752132965.0 then
      -- Home Key
      reagirl.InputField_MoveVisibleCursor(workspace, -workspace["cursor_offset"])
      workspace["cursor_offset"]=0
      workspace["selection_start"]=workspace["cursor_offset"]
      workspace["selection_end"]=workspace["cursor_offset"]
    elseif Key==6647396.0 then
      -- End Key
      reagirl.InputField_MoveVisibleCursor(workspace, -workspace["cursor_offset"])
      reagirl.InputField_MoveVisibleCursor(workspace, workspace["Text"]:utf8_len())
      workspace["cursor_offset"]=workspace["Text"]:utf8_len()
      workspace["selection_start"]=workspace["cursor_offset"]
      workspace["selection_end"]=workspace["cursor_offset"]
    elseif Key==3.0 then
      -- Cmd+C for Copy To Clipboard
      if workspace["selection_start"]~=workspace["selection_end"] then
        reaper.CF_SetClipboard(workspace["Text"]:utf8_sub(workspace["selection_start"]+1, workspace["selection_end"]))
      end
    elseif Key==22.0 then
      -- Cmd+V for Paste from Clipboard
      Clippy=reaper.CF_GetClipboard()
      Clippy=string.gsub(Clippy, "%c", "")
      local NewOffset=Clippy:utf8_len()+workspace["cursor_offset"]
      
      workspace["Text"]=workspace["Text"]:utf8_sub(1, workspace["cursor_offset"])..Clippy..workspace["Text"]:utf8_sub(workspace["cursor_offset"]+1, -1)
      workspace["cursor_offset"]=workspace["cursor_offset"]+Clippy:utf8_len()
      
      if NewOffset>workspace["draw_offset"]+workspace["draw_range_max"] then
        workspace["draw_offset"]=workspace["cursor_offset"]
        workspace["draw_range_cur"]=0
      end
    elseif Key_utf8~=0 and Key_utf8~=nil then
      workspace["Text"]=workspace["Text"]:utf8_sub(1, workspace["cursor_offset"])..utf8.char(Key_utf8)..workspace["Text"]:utf8_sub(workspace["cursor_offset"]+1, -1)
      workspace["cursor_offset"]=workspace["cursor_offset"]+1
      reagirl.InputField_MoveVisibleCursor(workspace, 1)
    else
      workspace["Text"]=workspace["Text"]:utf8_sub(1, workspace["cursor_offset"])..utf8.char(Key)..workspace["Text"]:utf8_sub(workspace["cursor_offset"]+1, -1)
      workspace["cursor_offset"]=workspace["cursor_offset"]+1
      reagirl.InputField_MoveVisibleCursor(workspace, 1)
    end
  end
  
  --workspace["cursor_offset"]=cursor_offset
  --workspace["draw_offset"]=draw_offset
  --workspace["draw_range_cur"]=draw_range_cur
  --workspace["Text"]=Text
  
end

function reagirl.InputField_Draw(Key, Key_utf8, workspace)
  gfx.setfont(1,"Calibri", 20)
  gfx.setfont(1,"Consolas", 20)
  
  local cursor_offset=workspace["cursor_offset"]
  local draw_offset=workspace["draw_offset"]
  local draw_range_max=workspace["draw_range_max"]
  local selection_start=workspace["selection_start"]
  local selection_end=workspace["selection_end"]
  gfx.x=0
  gfx.y=0
  gfx.set(0)
  gfx.rect(0,0,gfx.w,gfx.h,1)
  gfx.set(1)
  CAP_STRING=""
  --print_update(draw_offset, draw_range_max+draw_offset, draw_range_max, draw_offset)
  if draw_offset+1<0 then draw_offset=1 end
  if cursor_offset==draw_offset then
    --gfx.line(gfx.x, gfx.y, gfx.x, gfx.y+gfx.texth)
  end
  
  for i=draw_offset, draw_range_max+draw_offset+1 do
    --print(workspace["Text"]:utf8_sub(i,i))
    if selection_start~=selection_end and i==selection_start+1 then 
      gfx.setfont(1, "Consolas", 20, 86) 
      CAP_STRING=CAP_STRING..workspace["Text"]:utf8_sub(i,i)
    elseif selection_start~=selection_end and i==selection_end+1 then 
      gfx.setfont(1, "Consolas", 20, 0) 
    end
    gfx.drawstr(workspace["Text"]:utf8_sub(i,i))
    if cursor_offset==i then
      gfx.line(gfx.x, gfx.y, gfx.x, gfx.y+gfx.texth)
    end
  end
end


gfx.init()
function main()
  A,B=gfx.getchar()
  --if A>0 then print3(A) end
  C=Aworkspace["Text"]:len()
  reagirl.InputField_Manage(A,B, Aworkspace)
  reagirl.InputField_Draw(A,B, Aworkspace)
  reaper.defer(main)
end

Aworkspace={}
Aworkspace["Text"]=reaper.CF_GetClipboard()--"Test Home of Oblivionsjdijsid juidjsid ALLABAMMA"
Aworkspace["cursor_offset"]=Aworkspace["Text"]:utf8_len()
Aworkspace["selection_start"]=Aworkspace["cursor_offset"]
Aworkspace["selection_end"]=Aworkspace["cursor_offset"]
Aworkspace["draw_range_max"]=20
Aworkspace["draw_offset"]=Aworkspace["cursor_offset"]-Aworkspace["draw_range_max"]
if Aworkspace["draw_offset"]<0 then Aworkspace["draw_offset"]=0 end
Aworkspace["draw_range_cur"]=Aworkspace["draw_range_max"]

cursor_offset=0
draw_offset=0
main()
