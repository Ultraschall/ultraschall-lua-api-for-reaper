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

String={"Talking about Nuclear War","1","2","3","4","5","6","7","8","9","0","1","2","3","4","5","End"} -- the characters as lines
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
      if offset==0 then
        if line>1 then
          String[line-1]=String[line-1]..String[line]
          table.remove(String, line)
          line=line-1
          offset=utf8.len(String[line])
        end
      else
        String[line]=String[line]:sub_utf8(1,offset-1)..String[line]:sub_utf8(offset+1,-1)
        offset=offset-1
      end
    elseif Key==22 then
      -- Paste
      local Clippy=reaper.CF_GetClipboard()
      
      local End=String[line]:sub_utf8(offset+1, -1)
      StringHuh=Clippy:match("(.-)\n")
      String[line]=String[line]:sub_utf8(1,offset)..(Clippy.."\n"):match("(.-)\n").."GAAK"
      local count=0
      for k in string.gmatch(Clippy.."\n", "(.-)\n") do
        count=count+1
        if count>1 then
          table.insert(String, line+1, k)
        end
      end
      line=line+count-1
      String[line]=String[line]:sub(1,-2)..End
      offset=offset+utf8.len(Clippy)
    elseif gfx.mouse_cap&8==0 and Key==1818584692.0 then
    -- left arrow
      offset=offset-1
      if offset==-1 then 
        if line>1 then
          line=line-1
          offset=utf8.len(String[line])
        else
          offset=0
        end
      end
    elseif gfx.mouse_cap&8==0 and Key==1919379572.0 then
    -- right arrow
      offset=offset+1
      if offset>utf8.len(String[line]) then
        if line<#String then
          line=line+1
          offset=0
        else
          offset=utf8.len(String[line])
        end
      end
    elseif gfx.mouse_cap&8==0 and Key==30064 then
    -- up arrow
      line=line-1
      if line<1 then line=1 end
      if offset>utf8.len(String[line]) then offset=utf8.len(String[line]) end
      if line<draw_offset then draw_offset=draw_offset-1 end
    elseif gfx.mouse_cap&8==0 and Key==1685026670 then
    -- down arrow
      line=line+1
      if line>#String then line=#String end
      if offset>utf8.len(String[line]) then offset=utf8.len(String[line]) end
      if line>draw_maxlines then draw_offset=draw_offset+1 end
      if draw_offset-draw_maxlines>#String then draw_offset=#String-draw_maxlines end
    elseif Key==6647396 then
    -- end key
      if gfx.mouse_cap&4==0 then
        offset=utf8.len(String[line])
      elseif gfx.mouse_cap&4==4 then
        line=#String
        offset=utf8.len(String[line])
      end
    elseif Key==1752132965.0 then
    -- home key
      if gfx.mouse_cap&4==0 then
        offset=0
      elseif gfx.mouse_cap&4==4 then
        offset=0
        line=1
      end
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
    elseif Key==32 then
    -- Space Bar
      String[line]=String[line]:sub_utf8(1, offset).." "..String[line]:sub_utf8(offset+1, -1)
      offset=offset+1
    elseif Key==13 then
    -- enter
      --String[line]=String[line]
      local End=String[line]:sub_utf8(offset+1, -1)
      String[line]=String[line]:sub_utf8(1, offset)
      offset=0
      line=line+1
      table.insert(String, line, End)
      if offset>draw_maxlines then draw_offset=draw_offset+1 end
    elseif Key_utf~=0 and Key_utf~=nil then
      String[line]=String[line]:sub_utf8(1,offset)..utf8.char(Key_utf)..String[line]:sub_utf8(offset+1, -1)
      offset=offset+1
    elseif Key>0 then
      String[line]=String[line]:sub_utf8(1,offset)..utf8.char(Key)..String[line]:sub_utf8(offset+1, -1)
      offset=offset+1
    end
  end
end

function TextField_Draw()
  gfx.x=1
  gfx.y=1
  local x=0
  StringDim={}
  gfx.setfont(1,"Calibri", 20)
  gfx.setfont(1,"Consolas", 20)
  --reaper.ClearConsole()
  for i=draw_offset, draw_offset+draw_maxlines do
    if String[i]==nil then break end
    if line==i then
      gfx.drawstr(String[i]:sub_utf8(1,offset).."|"..String[i]:sub_utf8(offset+1,-1))
    else
      gfx.drawstr(String[i])
    end
    gfx.x=0
    gfx.y=gfx.y+gfx.texth
  end
end


drawline_cur=1
draw_maxlines=10
draw_offset=1

main()
