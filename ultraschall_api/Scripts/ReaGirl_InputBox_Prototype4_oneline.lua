dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

reagirl={}
Aworkspace={}
Aworkspace["Text"]="Test Home of Oblivionsjdijsid"
Aworkspace["cursor_offset"]=utf8.len(Aworkspace["Text"])
Aworkspace["draw_range_max"]=20
Aworkspace["draw_offset"]=Aworkspace["cursor_offset"]-Aworkspace["draw_range_max"]
if Aworkspace["draw_offset"]<0 then Aworkspace["draw_offset"]=0 end
Aworkspace["draw_range_cur"]=Aworkspace["draw_range_max"]
--print2(Aworkspace["draw_range_cur"])
--if Aworkspace["draw_range_cur"]<0 then Aworkspace["draw_range_cur"]=utf8.len(Aworkspace["Text"])-Aworkspace["draw_range_max"] end
--Aworkspace["draw_range_cur"]=
--if Aworkspace["draw_range_cur"]>Aworkspace["draw_range_max"] then Aworkspace["draw_range_cur"]=0 end

gfx.setfont(1,"Calibri", 20)
gfx.setfont(1,"Consolas", 20)

function string.sub_utf8(source_string, startoffset, endoffset)
  if type(source_string)~="string" then error("bad argument #1, to 'sub_utf8' (string expected, got "..type(source_string)..")", 2) end
  if math.type(startoffset)~="integer" then error("bad argument #2, to 'sub_utf8' (integer expected)", 2) end
  if math.type(endoffset)~="integer" then error("bad argument #3, to 'sub_utf8' (integer expected)", 2) end
  if endoffset==nil then endoffset=-1 end
  local A={utf8.codepoint(source_string, 1, -1)}
  local newstring=""
  if endoffset>utf8.len(source_string) then endoffset=utf8.len(source_string) end
  if endoffset<0 then endoffset=utf8.len(source_string)+endoffset+1 end
  if startoffset<0 then startoffset=utf8.len(source_string)+startoffset+1 end
  if startoffset<1 then startoffset=1 end
  for i=startoffset, endoffset do
    newstring=newstring..utf8.char(A[i])
  end
  return newstring
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
      
      cursor_offset=cursor_offset-1
      if cursor_offset<0 then cursor_offset=0 end
      
      draw_range_cur=draw_range_cur-1
      if draw_range_cur<0 and cursor_offset>0 then draw_range_cur=0 draw_offset=draw_offset-1 if draw_offset<0 then draw_offset=0 end end
      if cursor_offset==0 then draw_range_cur=0 end
      if cursor_offset<draw_offset then draw_offset=cursor_offset end
      
    elseif Key==1919379572.0 then
      -- right key
      cursor_offset=cursor_offset+1
      if cursor_offset>utf8.len(Text) then cursor_offset=utf8.len(Text) end
     
      if cursor_offset<utf8.len(Text) then
        draw_range_cur=draw_range_cur+1
        if draw_range_cur>draw_range_max then
          draw_range_cur=draw_range_cur-1
          draw_offset=draw_offset+1
        end
      end
      --if draw_offset>=cursor_offset-2 then draw_offset=cursor_offset-2 end
    elseif Key_utf8~=0 and Key_utf8~=nil then
      Text=Text:sub_utf8(1, cursor_offset)..utf8.char(Key_utf8)..Text:sub_utf8(cursor_offset+1, -1)
      cursor_offset=cursor_offset+1
      draw_range_cur=draw_range_cur+1
      if draw_range_cur>draw_range_max then
        draw_offset=draw_offset+1
        draw_range_cur=draw_range_cur-1
      end
    else
      Text=Text:sub_utf8(1, cursor_offset)..utf8.char(Key)..Text:sub_utf8(cursor_offset+1, -1)
      cursor_offset=cursor_offset+1
      draw_range_cur=draw_range_cur+1
      if draw_range_cur>draw_range_max then
        draw_offset=draw_offset+1
        draw_range_cur=draw_range_cur-1
      end
    end
  end
  
  workspace["cursor_offset"]=cursor_offset
  workspace["draw_offset"]=draw_offset
  workspace["draw_range_cur"]=draw_range_cur
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
  if cursor_offset==draw_offset then
    gfx.line(gfx.x, gfx.y, gfx.x, gfx.y+gfx.texth)
  end
  for i=draw_offset+1, draw_range_max+draw_offset+1 do
    --print(workspace["Text"]:sub_utf8(i,i))
    gfx.drawstr(workspace["Text"]:sub_utf8(i,i))
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

cusor_offset=0
draw_offset=0
main()
