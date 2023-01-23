dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

function string.sub_utf8(source_string, startoffset, endoffset)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>string.sub_utf8</slug>
  <requires>
    Ultraschall=4.8
    Reaper=6.20
    Lua=5.3
  </requires>
  <functioncall>string found_string = string.sub_utf8(string source_string, integer startoffset, integer endoffset)</functioncall>
  <description>
    like Lua's string.sub() but works on utf8-encoded strings
    
    returns nil in case of an error
  </description>
  <retvals>
    string found_string - the sub-string found in 
  </retvals>
  <parameters>
    string source_string - the string, whose utf8-encoded sub-section you want to get
    integer startoffset - the startoffset of the string in utf8-characters; negative values count from the end of the string
    integer endoffset - the endoffset of the string in utf8-characters; negative values count from the end of the string
  </parameters>
  <chapter_context>
    API-Helper functions
    Various
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_ReaperUserInterface_Module.lua</source_document>
  <tags>helperfunctions, utf8, get, subsection, string</tags>
</US_DocBloc>
--]]
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

gfx.init()

String={"Sun Ra - Talking about Nuclear War"} -- the characters as lines
StringDim={} -- the characters as coordinates
             -- StringDim[line][character]{x|y|w|h)
lineoffset=1
lineoffset_max=10
line_autobreak=10
offset=0
line=1


function main()
  Key, Key_utf=gfx.getchar()
  gfx.set(0)
  gfx.rect(0,0,gfx.w,gfx.h,1)
  gfx.set(1)
  TextField_Manage(Key, Key_utf)
  TextField_Draw()
  gfx.update()
  reaper.defer(main)
end

function TextField_Manage(Key, Key_utf)
  if Key~=0 then
    if Key==8 then
      -- Backspace
      
      -- remove character
      String[line]=String[line]:sub_utf8(1,offset-1)..String[line]:sub_utf8(offset+1,-1)
      
      -- manage cursor-offset
      offset=offset-1
      if offset<0 then offset=0 end
      
      -- manage shown offset
      x_range_start=x_range_start-1
      if x_range_start<0 then x_range_start=0 x_drawoffset=x_drawoffset-1 end
      if x_drawoffset<1 then x_drawoffset=1 end
      
    elseif Key==22 then
      -- Paste
      local Clippy=reaper.CF_GetClipboard()
      
      -- remove control characters
      Clippy=string.gsub(Clippy, "%c", "")
      
      local End=String[line]:sub_utf8(offset+1, -1)
      local newoffset=utf8.len(String[line]:sub_utf8(1,offset)..Clippy)
      String[line]=String[line]:sub_utf8(1,offset)..Clippy..String[line]:sub_utf8(offset+1, -1)
      offset=newoffset
      x_range_start=5
      x_drawoffset=x_drawoffset+utf8.len(Clippy)
      if offset<utf8.len(String[line]) then
        if x_range_start>x_range_max-4 then x_drawoffset=x_drawoffset+4 x_range_start=x_range_start-4 end
      else
        x_range_start=x_range_start-1
      end
      
    elseif gfx.mouse_cap&8==0 and Key==1818584692.0 then
    -- left arrow
      offset=offset-1
      if offset<0 then offset=0 end
      x_range_start=x_range_start-1
      if x_range_start<1 then x_range_start=4 x_drawoffset=x_drawoffset-4 end
      if x_drawoffset<1 then x_drawoffset=1 end
    elseif gfx.mouse_cap&8==0 and Key==1919379572.0 then
    -- right arrow
      offset=offset+1
      if offset>utf8.len(String[line]) then offset=utf8.len(String[line]) end
      x_range_start=x_range_start+1 
      if offset<utf8.len(String[line]) then
        if x_range_start>x_range_max-4 then x_drawoffset=x_drawoffset+4 x_range_start=x_range_start-4 end
      else
        x_range_start=x_range_start-1
      end
    elseif gfx.mouse_cap&8==0 and Key==30064 then
    -- up arrow
    
    elseif gfx.mouse_cap&8==0 and Key==1685026670 then
    -- down arrow
    
    elseif Key==6647396 then
    -- end key
      if gfx.mouse_cap&4==0 then
        offset=utf8.len(String[line])
      elseif gfx.mouse_cap&4==4 then
        line=#String
        offset=utf8.len(String[line])
      end
      x_range_start=10
      x_drawoffset=utf8.len(String[line])-x_range_start
    elseif Key==1752132965.0 then
    -- home key
      if gfx.mouse_cap&4==0 then
        offset=0
      elseif gfx.mouse_cap&4==4 then
        offset=0
        line=1
      end
      x_drawoffset=0
      x_range_start=0
    elseif Key==9 then
    -- Tab Key(we'll ignore)
    elseif Key==6579564.0 then
    -- Del-Key
      if utf8.len(String[line])>0 then
        String[line]=String[line]:sub_utf8(1, offset)..String[line]:sub_utf8(offset+2, -1)
      elseif String[line+1]~=nil then
        table.remove(String, line)
        offset=0--utf8.len(String[line])
      end
    elseif Key==13 then
    -- enter
    elseif Key_utf~=0 and Key_utf~=nil then
      String[line]=String[line]:sub_utf8(1,offset)..utf8.char(Key_utf)..String[line]:sub_utf8(offset+1, -1)
      offset=offset+1
      x_range_start=x_range_start+1 
      if offset<utf8.len(String[line]) then
        if x_range_start>x_range_max-4 then x_drawoffset=x_drawoffset+4 x_range_start=x_range_start-4 end
      else
        --x_range_start=x_range_start-1
      end
    else
      String[line]=String[line]:sub_utf8(1,offset)..utf8.char(Key)..String[line]:sub_utf8(offset+1, -1)
      offset=offset+1
      x_range_start=x_range_start+1 
      if offset<utf8.len(String[line]) then
        if x_range_start>x_range_max-4 then x_drawoffset=x_drawoffset+4 x_range_start=x_range_start-4 end
      else
        --x_range_start=x_range_start-1
      end
    end
  end
end

function TextField_Draw()
  gfx.x=10
  gfx.y=1
  local x=0
  StringDim={}
  gfx.setfont(1,"Calibri", 20)
  gfx.setfont(1,"Consolas", 20)
  for x=x_drawoffset-1, x_drawoffset+x_range_max do
    gfx.drawstr(String[1]:sub_utf8(x,x))
    if x==offset then gfx.line(gfx.x, gfx.y, gfx.x, gfx.y+gfx.texth) end
  end
end

x_drawoffset=1
x_range_start=1
x_range_max=20
main()
