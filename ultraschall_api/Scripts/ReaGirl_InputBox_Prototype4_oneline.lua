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
  if type(source_string)~="string" then error("bad argument #1, to 'utf8_sub' (string expected, got "..type(source_string)..")", 2) end
  if math.type(startoffset)~="integer" then error("bad argument #2, to 'utf8_sub' (integer expected)", 2) end
  if math.type(endoffset)~="integer" then error("bad argument #3, to 'utf8_sub' (integer expected)", 2) end
  if endoffset==nil then endoffset=-1 end
  local A={utf8.codepoint(source_string, 1, -1)}
  local newstring=""
  if endoffset>source_string:utf8_len() then endoffset=source_string:utf8_len() end
  if endoffset<0 then endoffset=source_string:utf8_len()+endoffset+1 end
  if startoffset<0 then startoffset=source_string:utf8_len()+startoffset+1 end
  if startoffset<1 then startoffset=1 end
  for i=startoffset, endoffset do
    newstring=newstring..utf8.char(A[i])
  end
  return newstring
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
    if Text:utf8_sub(i,i):match("%a")~=nil then print_update(i, Text:utf8_sub(i,i)) return i end
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
    if Text:utf8_sub(i,i):match("%a")~=nil then print_update(i, Text:utf8_sub(i,i)) return i end
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

function reagirl.InputField_Manage(Key, Key_utf8, workspace)
  local cursor_offset=workspace["cursor_offset"]
  local draw_offset=workspace["draw_offset"]
  local draw_range_cur=workspace["draw_range_cur"]
  local draw_range_max=workspace["draw_range_max"]
  local Text=workspace["Text"]
  
  if Key~=0 then
    if Key==1818584692.0 then
      -- left key
      if gfx.mouse_cap&4==0 then
        cursor_offset=cursor_offset-1
        if cursor_offset<0 then cursor_offset=0 else reagirl.InputField_MoveVisibleCursor(workspace, -1) end
      elseif gfx.mouse_cap&4==4 then
        local offset=reagirl.InputField_FindPreviousGoToPoint(workspace)
        if offset~=nil then
          reagirl.InputField_MoveVisibleCursor(workspace, offset-cursor_offset)
          cursor_offset=offset
        end
      end
    elseif Key==1919379572.0 then
      -- right key
      if gfx.mouse_cap&4==0 then
        cursor_offset=cursor_offset+1
        if cursor_offset>Text:utf8_len() then 
          cursor_offset=Text:utf8_len()
        else 
          reagirl.InputField_MoveVisibleCursor(workspace, 1)
        end
      elseif gfx.mouse_cap&4==4 then
        local offset=reagirl.InputField_FindNextGoToPoint(workspace)
        if offset~=nil then
          reagirl.InputField_MoveVisibleCursor(workspace, offset-cursor_offset-1)
          cursor_offset=offset-1
        end
      end
     
    elseif Key==1752132965.0 then
      reagirl.InputField_MoveVisibleCursor(workspace, -cursor_offset)
      cursor_offset=0
    elseif Key==6647396.0 then
      reagirl.InputField_MoveVisibleCursor(workspace, -cursor_offset)
      reagirl.InputField_MoveVisibleCursor(workspace, Text:utf8_len())
      cursor_offset=Text:utf8_len()
    elseif Key_utf8~=0 and Key_utf8~=nil then
      Text=Text:utf8_sub(1, cursor_offset)..utf8.char(Key_utf8)..Text:utf8_sub(cursor_offset+1, -1)
      cursor_offset=cursor_offset+1
      reagirl.InputField_MoveVisibleCursor(workspace, 1)
    else
      Text=Text:utf8_sub(1, cursor_offset)..utf8.char(Key)..Text:utf8_sub(cursor_offset+1, -1)
      cursor_offset=cursor_offset+1
      reagirl.InputField_MoveVisibleCursor(workspace, 1)
    end
  end
  
  workspace["cursor_offset"]=cursor_offset
  --workspace["draw_offset"]=draw_offset
  --workspace["draw_range_cur"]=draw_range_cur
  workspace["Text"]=Text
  
end

function reagirl.InputField_Draw(Key, Key_utf8, workspace)
  local cursor_offset=workspace["cursor_offset"]
  local draw_offset=workspace["draw_offset"]
  local draw_range_max=workspace["draw_range_max"]
  gfx.x=0
  gfx.y=0
  gfx.set(0)
  gfx.rect(0,0,gfx.w,gfx.h,1)
  gfx.set(1)
  --print_update(draw_offset, draw_range_max+draw_offset, draw_range_max, draw_offset)
  if draw_offset+1<0 then draw_offset=1 end
  if cursor_offset==draw_offset then
    gfx.line(gfx.x, gfx.y, gfx.x, gfx.y+gfx.texth)
  end
  
  for i=draw_offset+1, draw_range_max+draw_offset+1 do
    --print(workspace["Text"]:utf8_sub(i,i))
    gfx.drawstr(workspace["Text"]:utf8_sub(i,i))
    if cursor_offset==i then
      gfx.line(gfx.x, gfx.y, gfx.x, gfx.y+gfx.texth)
    end
  end
end


gfx.init()
function main()
  A,B=gfx.getchar()
  if A>0 then print3(A) end
  C=Aworkspace["Text"]:len()
  reagirl.InputField_Manage(A,B, Aworkspace)
  reagirl.InputField_Draw(A,B, Aworkspace)
  reaper.defer(main)
end

Aworkspace={}
Aworkspace["Text"]="Test Home of Oblivionsjdijsid juidjsid ALLABAMMA"
Aworkspace["cursor_offset"]=Aworkspace["Text"]:utf8_len()
Aworkspace["draw_range_max"]=20
Aworkspace["draw_offset"]=Aworkspace["cursor_offset"]-Aworkspace["draw_range_max"]
if Aworkspace["draw_offset"]<0 then Aworkspace["draw_offset"]=0 end
Aworkspace["draw_range_cur"]=Aworkspace["draw_range_max"]

cusor_offset=0
draw_offset=0
main()
