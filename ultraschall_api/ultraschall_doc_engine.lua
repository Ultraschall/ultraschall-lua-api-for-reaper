--[[
################################################################################
# 
# Copyright (c) 2014-2018 Ultraschall (http://ultraschall.fm)
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# 
################################################################################
]] 

--------------------------------------
--- ULTRASCHALL - API - Doc-Engine ---
--------------------------------------


if type(ultraschall)~="table" then 
  -- update buildnumber and add ultraschall as a table, when programming within this file
  local retval, string = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "DOC-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  local retval, string2 = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "API-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  if string=="" then string=10000 
  else 
    string=tonumber(string) 
    string=string+1
  end
  if string2=="" then string2=10000 
  else 
    string2=tonumber(string2)
    string2=string2+1
  end
  reaper.BR_Win32_WritePrivateProfileString("Ultraschall-Api-Build", "DOC-Build", string, reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  reaper.BR_Win32_WritePrivateProfileString("Ultraschall-Api-Build", "API-Build", string2, reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")  
  ultraschall={} 
  dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
end
--[[
function ultraschall.SplitUSDocBlocs(String)
  local Table={}
  local Counter=0
  TUT=""
  while String:match("<%US_DocBloc")~=nil do
    Counter=Counter+1
    Table[Counter]={}
    Table[Counter][2], Offset=String:match("(<%US_DocBloc.-</%US_DocBloc>)()")        -- USDocBloc
    Table[Counter][1]=Table[Counter][2]:match("<%slug>\n*%s*\t*(.-)\n*%s*\t*</%slug>")               -- the Slug
    TUT=TUT.."\n"..Table[Counter][1]
    Table[Counter][3]=Table[Counter][2]:match("<%US_DocBloc.-version=\"(.-)\".->")   -- version
    Table[Counter][4]=Table[Counter][2]:match("<%US_DocBloc.-spok_lang=\"(.-)\".->") -- spok-language
    Table[Counter][5]=Table[Counter][2]:match("<%US_DocBloc.-prog_lang=\"(.-)\".->") -- prog-language
    
    String=String:sub(Offset,-1)
  end
  --reaper.CF_SetClipboard(TUT)
  return Counter+1, Table
end


function ultraschall.ParseSlug(String)
  return String:match("<%slug>.-\n*%s*\t*(.-)\n*%s*\t*</%slug>")
end



function ultraschall.ParseTitle(String)
  return String:match("<title>.-\n*%s*\t*(.-)\n*%s*\t*</title>")
end

function ultraschall.ParseFunctionCall(String)
  local FoundFuncArray={}
  local count, positions = ultraschall.CountPatternInString(String, "<functioncall", true) 
  local temp, func, prog_lang
  for i=1, count do
    temp=String:sub(positions[i], String:match("</functioncall>\n()", positions[i]))
    func=temp:match("<functioncall.->.-\n*(.-)\n*</functioncall>")
    prog_lang=temp:match("prog_lang=\"(.-)\"")
    if prog_lang==nil then prog_lang="*" end
    FoundFuncArray[i]={}
    FoundFuncArray[i][1]=func
    FoundFuncArray[i][2]=prog_lang
  end
  return count, FoundFuncArray
end

--LLLL=ultraschall.CountLinesInString(0)

function ultraschall.ParseChapterContext(String)
  local ChapContext={}
  local Count=0
  local TempChapCont=String:match("<chapter_context>.-\n*(.-)\n*</chapter_context>")
  for i=1, ultraschall.CountLinesInString(TempChapCont) do
--    reaper.MB(Count,"",0)
    ChapContext[Count],offset=TempChapCont:match("%s*t*(.-)\n()")
    if offset~=nil then TempChapCont=TempChapCont:sub(offset,-1) Count=Count+1 end
  end
  return ChapContext, Count
end

function ultraschall.ParseDescription(String)
-- TODO: What if there are numerous descriptions, for other languages/prog_langs?
--       Still missing...
  local description=String:match("<description.->.-\n(.-)</description>")
  local markup_type=String:match("<description.-markup_type=\"(.-)\".-</description>")
  local markup_version=String:match("<description.-markup_version=\"(.-)\".-</description>")
  local lang=String:match("<description.-lang=\"(.-)\"")
  local lang=String:match("<description.-prog_lang=\"(.-)\"")
  local indent=String:match("<description.-indent=\"(.-)\"")
  local newdesc=""
  if markup_type==nil then markup_type="plain_text" end
  if markup_version==nil then markup_version="-" end
  if lang==nil then lang="*" end
  if prog_lang==nil then prog_lang="*" end
  if description==nil then return newdesc, markup_type, markup_version, lang, prog_lang end
  
  if indent==nil then indent="default" end
  if indent=="default" then
    -- the default indent-behavior: read the tabs/spaces from the first line and subtract them from
    -- every other line    
    local L=description:match("^%s*%t*()")
    local description=description.."\n"
    while description:len()>0 do
      local line, offset=description:match("(.-\n)()")
      local L2=line:match("^%s*%t*()")
      if L<L2 then line=line:sub(L,-1) else line=line:sub(L2, -1) end
      if line:len()==0 then line="\n" end
      description=description:sub(offset,-1)
      newdesc=newdesc..line
    end
  elseif indent=="minus_starts_line" then
    -- remove all spaces and tabs, until the first -
-- Still missing: what if a line has no - at the beginning? (Leave it that way, probably.)
    newdesc=string.gsub(description, "\n%s*%t*-", "\n")
  end
  return newdesc, markup_type, markup_version, lang, prog_lang
end

function ultraschall.ParseRequires(String)
  return String:match("Reaper=(.-)\n"), String:match("SWS=(.-)\n"), String:match("Lua=(.-)\n")
end

function ultraschall.ParseChapterContext(String)
  local Chapter={}
  local counter=0
  local chapterstring=""
--  reaper.MB(String,"",0)
  String=String:match("<chapter_context>.-\n*(.*)\n*</chapter_context>")
  if String==nil then String="" end
  String=String.."\n"
  while String~=nil do
    temp, pos=String:match("(.-)\n()")
    if pos==nil then break end
    temp=temp:match("^%s*%t*(.*)")
    counter=counter+1
    Chapter[counter]=temp
--    reaper.MB(String,"",0)
    String=String:sub(pos)
--    reaper.MB(String,"",0)
  end
  for i=1, counter do
    chapterstring=chapterstring..Chapter[i]..", "
  end
  return counter, Chapter, chapterstring:sub(1,-3)
end

function ultraschall.ParseTags(String)
  String=String:match("<tags>.-\n*%s*%t*(.-)\n*%s*%t*</tags>")
  String=string.gsub(String, " ,", "\n")
  String=string.gsub(String, ", ", "\n")
  String=string.gsub(String, ",", "\n")
  local count, splitarray= ultraschall.CSV2IndividualLinesAsArray(String, "\n")
  for i=count, 1, -1 do
    if splitarray[i]=="" then table.remove(splitarray, i) count=count-1
    elseif splitarray[i]:match("%a")==nil then table.remove(splitarray, i) count=count-1 
    end
  end
  return splitarray, count
end


--A,B=ultraschall.ParseTags("<tags>a,b ,c ,,,,,,k,                   \n\t  , ,</tags>")

function ultraschall.ParseParameters(String)
  local MarkupType=String:match("markup_type=\"(.-)\"")
  local MarkupVers=String:match("markup_version=\"(.-)\"")
  String=String:match("<parameters.->.-\n*(.*)\n*</parameters>")
  local Params={}
  local counter=0
  local Count, Splitarray = ultraschall.CSV2IndividualLinesAsArray(String, "\n")
  if Count==-1 then return -1 end
  for i=1, Count do
    local temppar, tempdesc=Splitarray[i]:match("(.-)%s-%-(.*)")
    if temppar==nil then break end -- Hack, make it better plz
    if temppar:match("%a")~=nil then 
      counter=counter+1
      Params[counter]={}
      Params[counter][1]=temppar:match("^%t*%s*(.*)")
      Params[counter][2]=tempdesc
    else
      Params[counter][2]=Params[counter][2].."\n"..tempdesc
    end
  end
  if MarkupType==nil then MarkupType="plain_text" end
  if MarkupVers==nil then MarkupVers="-" end
  return counter, Params, MarkupType, MarkupVers
end

function ultraschall.ParseRetvals(String)
--reaper.MB(String,"",0)
  MarkupType=String:match("markup_type=\"(.-)\"")
  MarkupVers=String:match("markup_version=\"(.-)\"")
  ASLUG=String:match("slug>\n*(.-)\n*</slug")
  String=String:match("<retvals.->.-\n*(.*)\n*</retvals>")
  Retvals={}
  counter=0
  Count, Splitarray = ultraschall.CSV2IndividualLinesAsArray(String, "\n")
  if Count==-1 then return -1 end
  for i=1, Count do
    tempretv, tempdesc=Splitarray[i]:match("(.-)%s-%-(.*)")
--    reaper.MB(Splitarray[i],"",0)
    if tempretv==nil then break end -- Hack, make it better plz
    if tempretv:match("%a")~=nil then 
      counter=counter+1
      Retvals[counter]={}
      Retvals[counter][1]=tempretv:match("^%t*%s*(.*)")
      Retvals[counter][2]=tempdesc
    else
      if Retvals[counter]==nil then Retvals[counter]={} Retvals[counter][2]="" end
      Retvals[counter][2]=Retvals[counter][2].."\n"..tempdesc
    end
  end
  if MarkupType==nil then MarkupType="plain_text" end
  if MarkupVers==nil then MarkupVers="-" end
  return counter, Retvals, MarkupType, MarkupVers
end

function ultraschall.GetIndexNumberFromSlug(Table,Slug)
  local i=1
  while Table[i]~=nil do
    if string.lower(Table[i][1])==string.lower(Slug) then return i end
    i=i+1
  end
end

function ultraschall.ParseTargetDocument(String)
  return String:match("<target_document>.-\n*(.-)\n*</target_document>")
end

function ultraschall.ParseSourceDocument(String)
  return String:match("<source_document>.-\n*(.-)\n*</source_document>")
end

function ultraschall.BubbleSortDocBlocTable_Slug(Table)
  local count=1
  while Table[count]~=nil and Table[count+1]~=nil do
    if Table[count][1]>Table[count+1][1] then
      temp=Table[count]
      Table[count]=Table[count+1]
      Table[count+1]=temp
    end
    count=count+1
  end
end

function ultraschall.GetAllSlugs(Table)
-- returns a table with the slugnames as index and the index-numbers of Table as value
  local counter=1
  local SlugTable={}
  while Table[counter]~=nil do
  --]]
  --SlugTable[Table[counter][1]]=counter
  --[[
    counter=counter+1
  end
  return counter-1, SlugTable
end
--]]
--[[
function ultraschall.ConvertSplitDocBlocTableIndex_Slug(Table)
  local counter=1
  local TableSlug={}
  while Table[counter]~=nil do
  --]]
--    TableSlug[Table[counter][1]]=Table[counter]
--[[
    counter=counter+1    
  end
  return TableSlug
end

function ultraschall.GetAllChapterContexts(Table)
  local counter=1
  local count=0
  local ChapterTable={}
  
  local tempstring=""
  
  local found=false
  local i=0
  while Table[counter]~=nil do
    local temp_count,table2=ultraschall.ParseChapterContext(Table[counter][2])
    if temp_count>count then count=temp_count end
    for a=1, temp_count do
      tempstring=tempstring..table2[a]..", "
    end
    tempstring=tempstring:sub(1,-3)
    for a=1, i do
      if ChapterTable[a]==tempstring then found=true break else found=false end
    end
    if found==false then i=i+1 ChapterTable[i]=tempstring end
    tempstring=""

    counter=counter+1
  end
  table.sort(ChapterTable)
  
  return count, ChapterTable, counter-1
end

function ultraschall.ConvertPlainTextToHTML(text)  
  text=string.gsub(text, "\r", "")
  text=string.gsub(text, "\n", "<br>")
  text=string.gsub(text, "  ", "&nbsp;&nbsp;")
  text=string.gsub(text, "\t", "&nbsp;&nbsp;&nbsp;&nbsp;")
  return text
end

function ultraschall.ConvertMarkdownToHTML(text, version)
  text=string.gsub(text, "usdocml://", "US_Api_Functions.html#") -- this line is a hack, just supporting functions-reference!
  ultraschall.WriteValueToFile(Tempfile..".md", text)
  L=reaper.ExecProcess(ConversionToolMD2HTML, 0)
  L3=text
  L3=ultraschall.ReadFullFile(Tempfile..".html")
--  L3=string.gsub(L3, "\r", "")
--  L3=string.gsub(L3, "\n", "<br>\n")
--  if L3:sub(-4,-1)=="<br>" then L3=L3:sub(1,-5) end

--  L3=string.gsub(L3,"<p>","")
--  L3=string.gsub(L3,"</p>","")
--  L3=string.gsub(L3, "  ", "&nbsp;&nbsp;")
--  L3=string.gsub(L3, "\t", "&nbsp;&nbsp;&nbsp;&nbsp;")
--  reaper.MB(L3,"",0)
  reaper.CF_SetClipboard(L3)
  return L3
end

  
function ultraschall.ColorateDatatypes(String)
  if String==nil then String=" " end
  String=" "..String.." "
  String=string.gsub(String, "%(", "( ")
  String=string.gsub(String, "%[", "[ ")
  String=string.gsub(String, " boolean ", " <i style=\"color:#0000ff;\">boolean</i> ")
  String=string.gsub(String, " Boolean ", " <i style=\"color:#0000ff;\">Boolean</i> ")
  String=string.gsub(String, " bool ", " <i style=\"color:#0000ff;\">bool</i> ")
  String=string.gsub(String, " bool%* ", " <i style=\"color:#0000ff;\">bool*</i> ")
--reaper.MB("LULA:"..String,"",0)
  String=string.gsub(String, " %.%.%. ", " <i style=\"color:#0000ff;\">...</i> ")
  String=string.gsub(String, " void ", " <i style=\"color:#0000ff;\">void</i> ")
  String=string.gsub(String, " void%* ", " <i style=\"color:#0000ff;\">void*</i> ")
  String=string.gsub(String, " integer ", " <i style=\"color:#0000ff;\">integer</i> ")
  String=string.gsub(String, " int ", " <i style=\"color:#0000ff;\">int</i> ")
  String=string.gsub(String, " int%* ", " <i style=\"color:#0000ff;\">int*</i> ")
  String=string.gsub(String, " Int ", " <i style=\"color:#0000ff;\">Int</i> ")
  String=string.gsub(String, " const ", " <i style=\"color:#0000ff;\">const</i> ")
  String=string.gsub(String, " char ", " <i style=\"color:#0000ff;\">char</i> ")
  String=string.gsub(String, " char%* ", " <i style=\"color:#0000ff;\">char*</i> ")
  String=string.gsub(String, " string ", " <i style=\"color:#0000ff;\">string</i> ")
  String=string.gsub(String, " String ", " <i style=\"color:#0000ff;\">String</i> ")
  String=string.gsub(String, " number ", " <i style=\"color:#0000ff;\">number</i> ")
  String=string.gsub(String, " double ", " <i style=\"color:#0000ff;\">double</i> ")
  String=string.gsub(String, " double%* ", " <i style=\"color:#0000ff;\">double*</i> ")
  String=string.gsub(String, " float ", " <i style=\"color:#0000ff;\">float</i> ")
  String=string.gsub(String, " float%* ", " <i style=\"color:#0000ff;\">float*</i> ")
  String=string.gsub(String, " Float ", " <i style=\"color:#0000ff;\">Float</i> ")
  String=string.gsub(String, " ReaProject%* ", " <i style=\"color:#0000ff;\">ReaProject*</i> ")
  String=string.gsub(String, " ReaProject ", " <i style=\"color:#0000ff;\">ReaProject</i> ")
  String=string.gsub(String, " MediaItem%*", " <i style=\"color:#0000ff;\">MediaItem*</i> ")
  String=string.gsub(String, " MediaItem ", " <i style=\"color:#0000ff;\">MediaItem</i> ")
  String=string.gsub(String, " MediaTrack ", " <i style=\"color:#0000ff;\">MediaTrack</i> ")
  String=string.gsub(String, " MediaTrack%*", " <i style=\"color:#0000ff;\">MediaTrack*</i> ")
  String=string.gsub(String, " AudioAccessor ", " <i style=\"color:#0000ff;\">AudioAccessor</i> ")
  String=string.gsub(String, " AudioAccessor%* ", " <i style=\"color:#0000ff;\">AudioAccessor*</i> ")
  String=string.gsub(String, " BR_Envelope ", " <i style=\"color:#0000ff;\">BR_Envelope</i> ")
  String=string.gsub(String, " HWND ", " <i style=\"color:#0000ff;\">HWND</i> ")
  String=string.gsub(String, " IReaperControlSurface ", " <i style=\"color:#0000ff;\">IReaperControlSurface</i> ")
  
  String=string.gsub(String, " joystick_device ", " <i style=\"color:#0000ff;\">joystick_device</i> ")
  String=string.gsub(String, " KbdSectionInfo ", " <i style=\"color:#0000ff;\">KbdSectionInfo</i> ")
  String=string.gsub(String, " KbdSectionInfo%* ", " <i style=\"color:#0000ff;\">KbdSectionInfo*</i> ")
  String=string.gsub(String, " PCM_source ", " <i style=\"color:#0000ff;\">PCM_source</i> ")
  String=string.gsub(String, " PCM_source%* ", " <i style=\"color:#0000ff;\">PCM_source*</i> ")
  String=string.gsub(String, " RprMidiTake ", " <i style=\"color:#0000ff;\">RprMidiTake</i> ")
  String=string.gsub(String, " MediaItem_Take ", " <i style=\"color:#0000ff;\">MediaItem_Take</i> ")
  String=string.gsub(String, " MediaItem_Take%* ", " <i style=\"color:#0000ff;\">MediaItem_Take*</i> ")
  String=string.gsub(String, " TrackEnvelope%* ", " <i style=\"color:#0000ff;\">TrackEnvelope*</i> ")
  String=string.gsub(String, " TrackEnvelope ", " <i style=\"color:#0000ff;\">TrackEnvelope</i> ")
  String=string.gsub(String, " WDL_FastString ", " <i style=\"color:#0000ff;\">WDL_FastString</i> ")
  
  String=string.gsub(String, " LICE_IBitmap%* ", " <i style=\"color:#0000ff;\">LICE_IBitmap*</i> ")  
  String=string.gsub(String, " WDL_VirtualWnd_BGCfg%* ", " <i style=\"color:#0000ff;\">WDL_VirtualWnd_BGCfg*</i> ")  
  String=string.gsub(String, " preview_register_t%* ", " <i style=\"color:#0000ff;\">preview_register_t*</i> ")  
  String=string.gsub(String, " screensetNewCallbackFunc ", " <i style=\"color:#0000ff;\">screensetNewCallbackFunc</i> ")  
  String=string.gsub(String, " ISimpleMediaDecoder%* ", " <i style=\"color:#0000ff;\">ISimpleMediaDecoder*</i> ")  
  String=string.gsub(String, " LICE_pixel ", " <i style=\"color:#0000ff;\">LICE_pixel</i> ")  
  String=string.gsub(String, " HINSTANCE ", " <i style=\"color:#0000ff;\">HINSTANCE</i> ")  
  String=string.gsub(String, " LICE_IFont%* ", " <i style=\"color:#0000ff;\">LICE_IFont*</i> ")  
  String=string.gsub(String, " HFONT ", " <i style=\"color:#0000ff;\">HFONT</i> ")  
  String=string.gsub(String, " RECT%* ", " <i style=\"color:#0000ff;\">RECT*</i> ")  
  String=string.gsub(String, " UINT ", " <i style=\"color:#0000ff;\">UINT</i> ")  
  String=string.gsub(String, " unsigned ", " <i style=\"color:#0000ff;\">unsigned</i> ")  
  String=string.gsub(String, " MSG%* ", " <i style=\"color:#0000ff;\">MSG*</i> ")  
  String=string.gsub(String, " HMENU ", " <i style=\"color:#0000ff;\">HMENU</i> ")  
  String=string.gsub(String, " MIDI_event_t%* ", " <i style=\"color:#0000ff;\">MIDI_event_t*</i> ")  
  String=string.gsub(String, " MIDI_eventlist%* ", " <i style=\"color:#0000ff;\">MIDI_eventlist*</i> ")  
  String=string.gsub(String, " DWORD ", " <i style=\"color:#0000ff;\">DWORD</i> ")  
  String=string.gsub(String, " ACCEL%* ", " <i style=\"color:#0000ff;\">ACCEL*</i> ")  
  String=string.gsub(String, " PCM_source_peaktransfer_t%* ", " <i style=\"color:#0000ff;\">PCM_source_peaktransfer_t*</i> ")  
  String=string.gsub(String, " PCM_source_transfer_t%* ", " <i style=\"color:#0000ff;\">PCM_source_transfer_t*</i> ")  
  String=string.gsub(String, " audio_hook_register_t%* ", " <i style=\"color:#0000ff;\">audio_hook_register_t*</i> ")  
  String=string.gsub(String, " size_t ", " <i style=\"color:#0000ff;\">size_t</i> ")  
  String=string.gsub(String, " function ", " <i style=\"color:#0000ff;\">function</i> ")  
  String=string.gsub(String, " ReaperArray ", " <i style=\"color:#0000ff;\">ReaperArray</i> ")  
  String=string.gsub(String, " optional ", " <i style=\"color:#0000ff;\">optional</i> ")  
  
--  String=string.gsub(String, " trackstring ", " <i style=\"color:#0000ff;\">trackstring</i> ")  
  String=string.gsub(String, " MediaItemArray ", " <i style=\"color:#0000ff;\">MediaItemArray</i> ")  
  String=string.gsub(String, " MediaItemStateChunkArray ", " <i style=\"color:#0000ff;\">MediaItemStateChunkArray</i> ")  
  String=string.gsub(String, " table ", " <i style=\"color:#0000ff;\">table</i> ")  
  String=string.gsub(String, " array ", " <i style=\"color:#0000ff;\">array</i> ")  
  String=string.gsub(String, " identifier ", " <i style=\"color:#0000ff;\">identifier</i> ")  
  String=string.gsub(String, " EnvelopePointArray ", " <i style=\"color:#0000ff;\">EnvelopePointArray</i> ")  
  
  String=string.gsub(String, "%( ", "(")
  String=string.gsub(String, "%[ ", "[")
  return String:sub(2,-2)
end
--]]

function ultraschall.Docs_RemoveIndent(String, indenttype)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Docs_RemoveIndent</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.978
    Lua=5.3
  </requires>
  <functioncall>string unindented_text = ultraschall.Docs_RemoveIndent(string String, string indenttype)</functioncall>
  <description>
    unindents an indented text from a US_DocBloc.
    
    There are different styles of unindention:
      as_typed - keeps the text, as it is
      minus_starts_line - will throw away everything from start of the line until(and including) the firt - in it
      preceding_spaces - will remove all spaces/tabs in the beginning of each line
      default - will take the indention of the first line and apply it to each of the following lines
                that means, indention relative to the first line is kept
    
    returns nil in case of an error
  </description>
  <retvals>
    string unindented_text - the string, from which the indention was removed
  </retvals>
  <parameters>
    string String - the string, which shall be unindented
    string indenttype - the type of indention you want to remove
                      - as_typed - keeps the text, as it is
                      - minus_starts_line - will throw away everything from start of the line until(and including) the firt - in it
                      - preceding_spaces - will remove all spaces/tabs in the beginning of each line
                      - default - will take the indention of the first line and apply it to each of the following lines
                                  that means, indention relative to the first line is kept
  </parameters>
  <chapter_context>
    Ultraschall DocML
  </chapter_context>
  <target_document>US_Api_DOC</target_document>
  <source_document>ultraschall_doc_engine.lua</source_document>
  <tags>doc engine, indent, unindent, text, usdocbloc</tags>
</US_DocBloc>
]]
  if type(String)~="string" then ultraschall.AddErrorMessage("Docs_RemoveIndent", "String", "must be a string", -1) return nil end
  if type(indenttype)~="string" then ultraschall.AddErrorMessage("Docs_RemoveIndent", "indenttype", "must be a string", -2) return nil end
  if indenttype=="as_typed" then return String end
  if indenttype=="minus_starts_line" then return string.gsub("\n"..String, "\n.-%-", "\n"):sub(2,-1) end
  if indenttype=="preceding_spaces" then  return string.gsub("\n"..String, "\n%s*", "\n"):sub(2,-1) end
  if indenttype=="default" then 
    local Length=String:match("(%s*)")
    if Length==nil then Length="" end
    return string.gsub("\n"..String, "\n"..Length, "\n"):sub(2,-1)
  end
  
  return String
end



function ultraschall.Docs_GetAllUSDocBlocsFromString(String)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Docs_GetAllUSDocBlocsFromString</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.978
    Lua=5.3
  </requires>
  <functioncall>integer found_usdocblocs, array all_found_usdocblocs = ultraschall.Docs_GetAllUSDocBlocsFromString(string String)</functioncall>
  <description>
    returns all US_DocBloc-elements from a string.
    
    returns nil in case of an error
  </description>
  <retvals>
    integer found_usdocblocs - the number of found US_DocBlocs in the string
    array all_found_usdocblocs - the individual US_DocBlocs found in the string
  </retvals>
  <parameters>
    string String - a string, from which to retrieve the US_DocBlocs
  </parameters>
  <chapter_context>
    Ultraschall DocML
  </chapter_context>
  <target_document>US_Api_DOC</target_document>
  <source_document>ultraschall_doc_engine.lua</source_document>
  <tags>doc engine, get, all, usdocbloc</tags>
</US_DocBloc>
]]
  if type(String)~="string" then ultraschall.AddErrorMessage("Docs_GetAllUSDocBlocsFromString", "String", "must be a string ", -1) return nil end
  local Array={}
  local count=0
  for k in string.gmatch(String, "<(US_DocBloc.-</US_DocBloc>)") do
    count=count+1
    Array[count]="<"..k
  end
  return count, Array
end

function ultraschall.Docs_GetUSDocBloc_Slug(String)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Docs_GetUSDocBloc_Slug</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.978
    Lua=5.3
  </requires>
  <functioncall>string slug = ultraschall.Docs_GetUSDocBloc_Slug(string String)</functioncall>
  <description>
    returns the slug from an US_DocBloc-element
    
    returns nil in case of an error
  </description>
  <retvals>
    string slug - the slug, as stored in the USDocBloc
  </retvals>
  <parameters>
    string String - a string which hold a US_DocBloc to retrieve the slug from
  </parameters>
  <chapter_context>
    Ultraschall DocML
  </chapter_context>
  <target_document>US_Api_DOC</target_document>
  <source_document>ultraschall_doc_engine.lua</source_document>
  <tags>doc engine, get, slug, usdocbloc</tags>
</US_DocBloc>
]]
  if type(String)~="string" then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_Slug", "String", "must be a string", -1) return nil end
  return String:match("<slug>(.-)</slug>")
end

function ultraschall.Docs_GetUSDocBloc_Title(String, index)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Docs_GetUSDocBloc_Title</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.978
    Lua=5.3
  </requires>
  <functioncall>string title, string spok_lang = ultraschall.Docs_GetUSDocBloc_Title(string String, integer index)</functioncall>
  <description>
    returns the title from an US_DocBloc-element.
    There can be multiple titles, e.g. in multiple languages
    
    returns nil in case of an error
  </description>
  <retvals>
    string title - the title, as stored in the USDocBloc
    string spok_lang - the language, in which the title is stored
  </retvals>
  <parameters>
    string String - a string which hold a US_DocBloc to retrieve the title from
    integer index - the index of the title to get, starting with 1 for the first title
  </parameters>
  <chapter_context>
    Ultraschall DocML
  </chapter_context>
  <target_document>US_Api_DOC</target_document>
  <source_document>ultraschall_doc_engine.lua</source_document>
  <tags>doc engine, get, title, languages, spoken, spok_lang, usdocbloc</tags>
</US_DocBloc>
]]
  if type(String)~="string" then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_Title", "String", "must be a string", -1) return nil end
  if math.type(index)~="integer" then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_Title", "index", "must be an integer", -2) return nil end
  if index<1 then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_Title", "index", "must be >0", -3) return nil end
  local counter=0
  local title, spok_lang
  for k in string.gmatch(String, "(<title.->.-)</title>") do
    counter=counter+1
    if counter==index then title=k:match("<title.->(.*)") spok_lang=k:match("spok_lang=\"(.-)\".->") if spok_lang==nil then spok_lang="" end return title, spok_lang end
  end
end


function ultraschall.Docs_GetUSDocBloc_Description(String, unindent_description, index)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Docs_GetUSDocBloc_Description</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.978
    Lua=5.3
  </requires>
  <functioncall>string title, string spok_lang = ultraschall.Docs_GetUSDocBloc_Description(string String, boolean unindent_description, integer index)</functioncall>
  <description>
    returns the description-text from an US_DocBloc-element.
    There can be multiple descriptions, e.g. in multiple languages
    
    It will remove automatically indentation(as requested by the description-tag of the US_DocBloc), if unindent_description==true.
    If no indentation is requested by the description-tag, it will assume default(the indentation of the first line will be applied to all other lines).
    
    returns nil in case of an error
  </description>
  <retvals>
    string title - the title, as stored in the USDocBloc
    string spok_lang - the language, in which the title is stored
  </retvals>
  <parameters>
    string String - a string which hold a US_DocBloc to retrieve the description from
    boolean unindent_description - true, will remove indentation as given in the description-tag; false, return the text as it is
    integer index - the index of the title to get, starting with 1 for the first title
  </parameters>
  <chapter_context>
    Ultraschall DocML
  </chapter_context>
  <target_document>US_Api_DOC</target_document>
  <source_document>ultraschall_doc_engine.lua</source_document>
  <tags>doc engine, get, description, languages, spoken, spok_lang, indentation, usdocbloc</tags>
</US_DocBloc>
]]
  if type(String)~="string" then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_Description", "String", "must be a string", -1) return nil end
  if math.type(index)~="integer" then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_Description", "index", "must be an integer", -2) return nil end
  if index<1 then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_Description", "index", "must be >0", -3) return nil end
  if type(unindent_description)~="boolean" then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_Description", "unindent_description", "must be a boolean", -4) return nil end
  
  local counter=0
  local title, spok_lang, found
  for k in string.gmatch(String, "(<description.->.-</description>)") do
    counter=counter+1
    if counter==index then String=k found=true end
  end
  
  if found~=true then return end
  
  local Description=String:match("<description.->(.-)\n%s*</description>")
  local markup_type=Description:match("markup_type=\"(.-)\"")
  local markup_version=Description:match("markup_version=\"(.-)\"")
  local indent=String:match("indent=\"(.-)\"")
  local language=String:match("spok_lang=\"(.-)\"")
  if language==nil then language="" end
  if indent==nil then indent="default" end
  if markup_type==nil then markup_type="text" end
  if markup_version==nil then markup_version="" end
  if unindent_description~=false then 
    Description=ultraschall.Docs_RemoveIndent(Description, indent)
  end
  return Description, markup_type, markup_version, indent, language
end

function ultraschall.Docs_GetUSDocBloc_TargetDocument(String)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Docs_GetUSDocBloc_TargetDocument</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.978
    Lua=5.3
  </requires>
  <functioncall>string target_document = ultraschall.Docs_GetUSDocBloc_TargetDocument(string String)</functioncall>
  <description>
    returns the target-document from an US_DocBloc-element.
    The target-document is the document, into which the converted DocBloc shall be stored into.
    
    returns nil in case of an error
  </description>
  <retvals>
    string target_document - the target-document, into which the converted US_DocBloc shall be stored into
  </retvals>
  <parameters>
    string String - a string which hold a US_DocBloc to retrieve the target-document-entry from
  </parameters>
  <chapter_context>
    Ultraschall DocML
  </chapter_context>
  <target_document>US_Api_DOC</target_document>
  <source_document>ultraschall_doc_engine.lua</source_document>
  <tags>doc engine, get, target-document, usdocbloc</tags>
</US_DocBloc>
]]
  if type(String)~="string" then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_TargetDocument", "String", "must be a string", -1) return nil end
  return String:match("<target_document>(.-)</target_document>")
end

function ultraschall.Docs_GetUSDocBloc_SourceDocument(String)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Docs_GetUSDocBloc_SourceDocument</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.978
    Lua=5.3
  </requires>
  <functioncall>string source_document = ultraschall.Docs_GetUSDocBloc_SourceDocument(string String)</functioncall>
  <description>
    returns the source-document from an US_DocBloc-element.
    The source-document is the document, into which the converted DocBloc shall be stored into.
    
    returns nil in case of an error
  </description>
  <retvals>
    string source_document - the source-document, into which the converted US_DocBloc shall be stored into
  </retvals>
  <parameters>
    string String - a string which hold a US_DocBloc to retrieve the source-document-entry from
  </parameters>
  <chapter_context>
    Ultraschall DocML
  </chapter_context>
  <target_document>US_Api_DOC</target_document>
  <source_document>ultraschall_doc_engine.lua</source_document>
  <tags>doc engine, get, source-document, usdocbloc</tags>
</US_DocBloc>
]]
  if type(String)~="string" then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_SourceDocument", "String", "must be a string", -1) return nil end
  return String:match("<source_document>(.-)</source_document>")
end

function ultraschall.Docs_GetUSDocBloc_ChapterContext(String, index)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Docs_GetUSDocBloc_ChapterContext</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.978
    Lua=5.3
  </requires>
  <functioncall>integer count, array chapters, string spok_lang = ultraschall.Docs_GetUSDocBloc_ChapterContext(string String, integer index)</functioncall>
  <description>
    returns the chapters and subchapters, in which the US_DocBloc shall be stored into
    A US_DocBloc can have multiple chapter-entries, e.g. for multiple languages.
    
    returns nil in case of an error
  </description>
  <retvals>
    integer count - the number of chapters found
    array chapters - the chapternams as an array
    string spok_lang - the language of the chapters; "" if no languages is given
  </retvals>
  <parameters>
    string String - a string which hold a US_DocBloc to retrieve the source-document-entry from
    integer index - the index of the chapter-entries, starting with 1 for the first
  </parameters>
  <chapter_context>
    Ultraschall DocML
  </chapter_context>
  <target_document>US_Api_DOC</target_document>
  <source_document>ultraschall_doc_engine.lua</source_document>
  <tags>doc engine, get, chapters, spoken languages, usdocbloc</tags>
</US_DocBloc>
]]
  if type(String)~="string" then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_ChapterContext", "String", "must be a string", -1) return nil end
  if math.type(index)~="integer" then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_ChapterContext", "index", "must be an integer", -2) return nil end
  if index<1 then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_ChapterContext", "index", "must be >0", -3) return nil end
  
  local counter=0
  local title, spok_lang, found
  for k in string.gmatch(String, "(<chapter_context.->.-</chapter_context>)") do
    counter=counter+1
    if counter==index then String=k found=true end
  end
  
  if found~=true then return end
    
  local language=String:match("spok_lang=\"(.-)\"")
  if language==nil then language="" end
  
  local Chapters=String:match("<chapter_context.->.-\n(.-)</chapter_context>")
  local count, split_string = ultraschall.SplitStringAtLineFeedToArray(Chapters)
  for i=1, count do
    split_string[i]=split_string[i]:match("%s*(.*)")
  end
  return count, split_string, language
end


-- add numerous of these elements, so you can have multiple spok_langs
function ultraschall.Docs_GetUSDocBloc_Tags(String)
  if type(String)~="string" then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_Tags", "String", "must be a string", -1) return nil end
  local Tags=String:match("<tags>(.-)</tags>")
  local count, split_string = ultraschall.CSV2IndividualLinesAsArray(Tags)
  for i=1, count do
    split_string[i]=split_string[i]:match("%s*(.*)")
  end
  return count, split_string
end

function ultraschall.Docs_GetUSDocBloc_Params(String)
  if type(String)~="string" then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_Params", "String", "must be a string", -1) return nil end
  local parms=String:match("(<parameters.->.-)</parameters>")
  local count, split_string = ultraschall.SplitStringAtLineFeedToArray(parms)
  local Parmcount=0
  local Params={}
  for i=1, count do
    split_string[i]=split_string[i]:match("%s*(.*)")
  end
  for i=2, count do
    if split_string[i]:match("%-")==nil then
    elseif split_string[i]:sub(1,1)~="-" then
      Parmcount=Parmcount+1
      Params[Parmcount]={}
      Params[Parmcount][1], Params[Parmcount][2]=split_string[i]:match("(.-)%-(.*)")
    else
      Params[Parmcount][2]=Params[Parmcount][2].."\n"..split_string[i]:sub(2,-1)
    end
  end
  local markuptype=split_string[1]:match("markup_type=\"(.-)\"")
  if markuptype==nil then markuptype="text" end
  local markupversion=split_string[1]:match("markup_version=\"(.-)\"")
  if markupversion==nil then markupversion="" end
  local prog_lang=split_string[1]:match("prog_lang=\"(.-)\"")
  if prog_lang==nil then prog_lang="*" end
  local indent=split_string[1]:match("indent=\"(.-)\"")
  if indent==nil then indent="default" end
  
  return Parmcount, Params, markuptype, markupversion, prog_lang, indent
end

function ultraschall.Docs_GetUSDocBloc_Retvals(String)
  if type(String)~="string" then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_Retvals", "String", "must be a string", -1) return nil end
  local retvals=String:match("(<retvals.->.-)</retvals>")
  local count, split_string = ultraschall.SplitStringAtLineFeedToArray(retvals)
  local Retvalscount=0
  local Retvals={}
  for i=1, count do
    split_string[i]=split_string[i]:match("%s*(.*)")
  end
  for i=2, count do
    if split_string[i]:match("%-")==nil then
    elseif split_string[i]:sub(1,1)~="-" then
      Retvalscount=Retvalscount+1
      Retvals[Retvalscount]={}
      Retvals[Retvalscount][1], Retvals[Retvalscount][2]=split_string[i]:match("(.-)%-(.*)")
    else
      Retvals[Retvalscount][2]=Retvals[Retvalscount][2].."\n"..split_string[i]:sub(2,-1)
    end
  end
  local markuptype=split_string[1]:match("markup_type=\"(.-)\"")
  if markuptype==nil then markuptype="text" end
  local markupversion=split_string[1]:match("markup_version=\"(.-)\"")
  if markupversion==nil then markupversion="" end
  local prog_lang=split_string[1]:match("prog_lang=\"(.-)\"")
  if prog_lang==nil then prog_lang="*" end
  local indent=split_string[1]:match("indent=\"(.-)\"")
  if indent==nil then indent="default" end
  
  return Retvalscount, Retvals, markuptype, markupversion, prog_lang, indent
end

--A_1=ultraschall.GetStringFromClipboard_SWS("")
--A0,CCC=ultraschall.Docs_GetAllUSDocBlocsFromString(A_1)
--B=ultraschall.Docs_GetUSDocBloc_Slug(CCC[1])
--A1, A2, A3, A4, A5=ultraschall.Docs_GetUSDocBloc_Description(CCC[1], true, 1)
--print2(A1)

--AAA=ultraschall.Docs_RemoveIndent(ultraschall.GetStringFromClipboard_SWS(""), "preceding_spaces")
--print2(AAA)

