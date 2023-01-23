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

String="" -- the characters as lines
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
      if offset>0 then
        String=String:sub_utf8(1,offset-1)..String:sub_utf8(offset+1,-1)
        offset=offset-1
      end
    elseif Key==22 then
      -- Paste
      local Clippy=reaper.CF_GetClipboard()
      local newoffset=utf8.len(String:sub_utf8(1, offset)..Clippy)
      String=String:sub_utf8(1, offset)..Clippy..String:sub_utf8(offset+1, -1)
      offset=newoffset
    elseif gfx.mouse_cap&8==0 and Key==1818584692.0 then
    -- left arrow
      offset=offset-1
      if offset==-1 then 
        if line>1 then
          line=line-1
          offset=utf8.len(String)
        else
          offset=0
        end
      end
    elseif gfx.mouse_cap&8==0 and Key==1919379572.0 then
    -- right arrow
      offset=offset+1
      if offset>utf8.len(String) then
        if line<#String then
          line=line+1
          offset=0
        else
          offset=utf8.len(String)
        end
      end
    elseif gfx.mouse_cap&8==0 and Key==30064 then
    -- up arrow
      line=line-1
      if line<1 then line=1 end
      if offset>utf8.len(String) then offset=utf8.len(String) end
    elseif gfx.mouse_cap&8==0 and Key==1685026670 then
    -- down arrow
      line=line+1
      if line>#String then line=#String end
      if offset>utf8.len(String) then offset=utf8.len(String) end
    elseif Key==6647396 then
    -- end key
      line=#String
      offset=utf8.len(String)
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
      String=String:sub_utf8(1, offset)..String:sub_utf8(offset+2, -1)
    elseif Key==32 then
    -- Space Bar
      String=String:sub_utf8(1, offset).." "..String:sub_utf8(offset+1, -1)
      offset=offset+1
    elseif Key==13 then
    -- enter
      String=String:sub_utf8(1, offset).."\n"..String:sub_utf8(offset+1, -1)
      offset=offset+1
    elseif Key_utf~=0 and Key_utf~=nil then
      String=String:sub_utf8(1,offset)..utf8.char(Key_utf)..String:sub_utf8(offset+1, -1)
      offset=offset+1
    else
      if Key~=-1 then
        String=String:sub_utf8(1,offset)..utf8.char(Key)..String:sub_utf8(offset+1, -1)
        offset=offset+1
      end
    end
  end
end

function TextField_Draw()
  Charlength=gfx.measurestr("A")
  gfx.setfont(1,"Calibri", 20)
  gfx.setfont(1,"Consolas", 20)
  gfx.x=1
  gfx.y=1
  maxlines=1
  maxoffset=0
  xpos=0
  VisCharPos={}
  VisCharPos[maxlines]={}
  VisOffset_End=0
  for i=VisOffset_Start, utf8.len(String) do
    if maxlines>MaxLines then break end
    if String:sub_utf8(i,i)=="\n" then 
      gfx.x=0 
      gfx.y=gfx.y+gfx.texth 
      VisCharPos[maxlines][xpos]=String:sub_utf8(i,i)
      maxlines=maxlines+1
      VisOffset_End=VisOffset_End+1
      VisCharPos[maxlines]={}
      xpos=0
    else
      xpos=xpos+1
      VisOffset_End=VisOffset_End+1
      gfx.drawstr(String:sub_utf8(i,i))
      VisCharPos[maxlines][xpos]=String:sub_utf8(i,i)
      if offset==i then gfx.line(gfx.x,gfx.y,gfx.x,gfx.y+gfx.texth) end
    end
    if xpos>=MaxChars then
      gfx.x=0 
      gfx.y=gfx.y+gfx.texth
      xpos=0
      maxlines=maxlines+1
    end
    
  end
  VisX,VisY=math.floor(gfx.mouse_x/Charlength)+1, math.floor(gfx.mouse_y/gfx.texth)+1
  if VisCharPos[VisY]~=nil and VisCharPos[VisY][VisX]~=nil then
    print_update(VisCharPos[VisY][VisX])
  end
 -- print_update(String:sub_utf8(VisOffset_Start, VisOffset_End))
end


MaxChars=10
MaxLines=3
VisOffset_Start=1
main()

