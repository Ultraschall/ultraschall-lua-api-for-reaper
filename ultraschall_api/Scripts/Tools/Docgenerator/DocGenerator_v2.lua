  --[[
  ################################################################################
  # 
  # Copyright (c) 2014-2021 Ultraschall (http://ultraschall.fm)
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
  --]]

-- some variables that can be set in the source-script to control stuff:

-- DontSort=true -- if DontSort==true, then the index and the functions/entries will not be sorted
-- Index=4 -- set the number of columns of the index (1-4)


local FunctionList=FunctionList

-- some functions needed

PanDoc=reaper.GetExtState("Ultraschall", "PanDoc_Path", "\"c:\\Program Files\\Pandoc\\pandoc.exe\"")
if PanDoc=="" then PanDoc="\"c:\\Program Files\\Pandoc\\pandoc.exe\"" end

if CurrentDocs==nil then CurrentDocs="" end

function ultraschall.SplitUSDocBlocs(String)
  local Table={}
  local Counter=0

  local USDocBlockCounter, USDocBlocTable = ultraschall.Docs_GetAllUSDocBlocsFromString(String)
  for i=1, USDocBlockCounter do
    Table[i]={}
    Table[i][2]=USDocBlocTable[i]
    Table[i][1]=Table[i][2]:match("<slug>\n*%s*\t*(.-)\n*%s*\t*</slug>")               -- the Slug
    Table[i][3]=Table[i][2]:match("<US_DocBloc.-version=\"(.-)\".->")   -- version
    Table[i][4]=Table[i][2]:match("<US_DocBloc.-spok_lang=\"(.-)\".->") -- spok-language
    Table[i][5]=Table[i][2]:match("<US_DocBloc.-prog_lang=\"(.-)\".->") -- prog-language
  end
  
  return USDocBlockCounter, Table
end

function ultraschall.ParseChapterContext(String)
  local Chapter={}
  local counter=0
  local chapterstring=""
  local temp
--  reaper.MB(String,"",0)
  String=String:match("<chapter_context>\n*(.*)\n*</chapter_context>")
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


function ColorateFunctionnames(String)
  local offset1, offset2
  String=" "..String
  if String:match("extension_api") and String:match("\"")~=nil then
    offset1, offset2 = String:match("%(\"().-()\"")
  else
    offset1, offset2 = String:match(".* ().-()%(")
  end
  if offset1==nil or offset2==nil then
    --print2(String)
  end
  if offset1==nil or offset2==nil then 
    return "<em>"..String.."</em>"
  else
    return String:sub(1,offset1-1).."<em>"..String:sub(offset1, offset2-1).."</em>"..String:sub(offset2, -1)
  end
end

function ultraschall.ColorateDatatypes(String)
  if String==nil then String=" " end
  String=" "..String.." "
  String=string.gsub(String, "%(", "( ")
  String=string.gsub(String, "%[", "[ ")
  String=string.gsub(String, " boolean ", " <i class=\"dtype\">boolean</i> ")
  String=string.gsub(String, " Boolean ", " <i class=\"dtype\">Boolean</i> ")
  String=string.gsub(String, " bool ", " <i class=\"dtype\">bool</i> ")
  String=string.gsub(String, " bool%* ", " <i class=\"dtype\">bool*</i> ")
--reaper.MB("LULA:"..String,"",0)
  String=string.gsub(String, " void ", " <i class=\"dtype\">void</i> ")
  String=string.gsub(String, " void%* ", " <i class=\"dtype\">void*</i> ")
  String=string.gsub(String, " integer ", " <i class=\"dtype\">integer</i> ")
  String=string.gsub(String, " int ", " <i class=\"dtype\">int</i> ")
  String=string.gsub(String, " int%* ", " <i class=\"dtype\">int*</i> ")
  String=string.gsub(String, " Int ", " <i class=\"dtype\">Int</i> ")
  String=string.gsub(String, " const ", " <i class=\"dtype\">const</i> ")
  String=string.gsub(String, " char ", " <i class=\"dtype\">char</i> ")
  String=string.gsub(String, " char%* ", " <i class=\"dtype\">char*</i> ")
  String=string.gsub(String, " string ", " <i class=\"dtype\">string</i> ")
  String=string.gsub(String, " String ", " <i class=\"dtype\">String</i> ")
  String=string.gsub(String, " number ", " <i class=\"dtype\">number</i> ")
  String=string.gsub(String, " double ", " <i class=\"dtype\">double</i> ")
  String=string.gsub(String, " double%* ", " <i class=\"dtype\">double*</i> ")
  String=string.gsub(String, " float ", " <i class=\"dtype\">float</i> ")
  String=string.gsub(String, " float%* ", " <i class=\"dtype\">float*</i> ")
  String=string.gsub(String, " Float ", " <i class=\"dtype\">Float</i> ")
  String=string.gsub(String, " ReaProject%* ", " <i class=\"dtype\">ReaProject*</i> ")
  String=string.gsub(String, " ReaProject ", " <i class=\"dtype\">ReaProject</i> ")
  String=string.gsub(String, " MediaItem%*", " <i class=\"dtype\">MediaItem*</i> ")
  String=string.gsub(String, " MediaItem ", " <i class=\"dtype\">MediaItem</i> ")
  String=string.gsub(String, " MediaTrack ", " <i class=\"dtype\">MediaTrack</i> ")
  String=string.gsub(String, " MediaTrack%*", " <i class=\"dtype\">MediaTrack*</i> ")
  String=string.gsub(String, " AudioAccessor ", " <i class=\"dtype\">AudioAccessor</i> ")
  String=string.gsub(String, " AudioAccessor%* ", " <i class=\"dtype\">AudioAccessor*</i> ")
  String=string.gsub(String, " BR_Envelope ", " <i class=\"dtype\">BR_Envelope</i> ")
  String=string.gsub(String, " HWND ", " <i class=\"dtype\">HWND</i> ")
  String=string.gsub(String, " ImGui_Context ", " <i class=\"dtype\">ImGui_Context</i> ")
  String=string.gsub(String, " ImGui_DrawList ", " <i class=\"dtype\">ImGui_DrawList</i> ")
  String=string.gsub(String, " identifier ", " <i class=\"dtype\">identifier</i> ")
  String=string.gsub(String, " PackageEntry ", " <i class=\"dtype\">PackageEntry</i> ")  
  String=string.gsub(String, " IReaperControlSurface ", " <i class=\"dtype\">IReaperControlSurface</i> ")
  
  String=string.gsub(String, " joystick_device ", " <i class=\"dtype\">joystick_device</i> ")
  String=string.gsub(String, " KbdSectionInfo ", " <i class=\"dtype\">KbdSectionInfo</i> ")
  String=string.gsub(String, " KbdSectionInfo%* ", " <i class=\"dtype\">KbdSectionInfo*</i> ")
  String=string.gsub(String, " PCM_source ", " <i class=\"dtype\">PCM_source</i> ")
  String=string.gsub(String, " PCM_source%* ", " <i class=\"dtype\">PCM_source*</i> ")
  String=string.gsub(String, " RprMidiTake ", " <i class=\"dtype\">RprMidiTake</i> ")
  String=string.gsub(String, " MediaItem_Take ", " <i class=\"dtype\">MediaItem_Take</i> ")
  String=string.gsub(String, " MediaItem_Take%* ", " <i class=\"dtype\">MediaItem_Take*</i> ")
  String=string.gsub(String, " TrackEnvelope%* ", " <i class=\"dtype\">TrackEnvelope*</i> ")
  String=string.gsub(String, " TrackEnvelope ", " <i class=\"dtype\">TrackEnvelope</i> ")
  String=string.gsub(String, " WDL_FastString ", " <i class=\"dtype\">WDL_FastString</i> ")
  
  String=string.gsub(String, " LICE_IBitmap%* ", " <i class=\"dtype\">LICE_IBitmap*</i> ")  
  String=string.gsub(String, " WDL_VirtualWnd_BGCfg%* ", " <i class=\"dtype\">WDL_VirtualWnd_BGCfg*</i> ")  
  String=string.gsub(String, " preview_register_t%* ", " <i class=\"dtype\">preview_register_t*</i> ")  
  String=string.gsub(String, " screensetNewCallbackFunc ", " <i class=\"dtype\">screensetNewCallbackFunc</i> ")  
  String=string.gsub(String, " ISimpleMediaDecoder%* ", " <i class=\"dtype\">ISimpleMediaDecoder*</i> ")  
  String=string.gsub(String, " LICE_pixel ", " <i class=\"dtype\">LICE_pixel</i> ")  
  String=string.gsub(String, " HINSTANCE ", " <i class=\"dtype\">HINSTANCE</i> ")  
  String=string.gsub(String, " LICE_IFont%* ", " <i class=\"dtype\">LICE_IFont*</i> ")  
  String=string.gsub(String, " HFONT ", " <i class=\"dtype\">HFONT</i> ")  
  String=string.gsub(String, " RECT%* ", " <i class=\"dtype\">RECT*</i> ")  
  String=string.gsub(String, " UINT ", " <i class=\"dtype\">UINT</i> ")  
  String=string.gsub(String, " unsigned ", " <i class=\"dtype\">unsigned</i> ")  
  String=string.gsub(String, " MSG%* ", " <i class=\"dtype\">MSG*</i> ")  
  String=string.gsub(String, " HMENU ", " <i class=\"dtype\">HMENU</i> ")  
  String=string.gsub(String, " MIDI_event_t%* ", " <i class=\"dtype\">MIDI_event_t*</i> ")  
  String=string.gsub(String, " MIDI_eventlist%* ", " <i class=\"dtype\">MIDI_eventlist*</i> ")  
  String=string.gsub(String, " DWORD ", " <i class=\"dtype\">DWORD</i> ")  
  String=string.gsub(String, " ACCEL%* ", " <i class=\"dtype\">ACCEL*</i> ")  
  String=string.gsub(String, " PCM_source_peaktransfer_t%* ", " <i class=\"dtype\">PCM_source_peaktransfer_t*</i> ")  
  String=string.gsub(String, " PCM_source_transfer_t%* ", " <i class=\"dtype\">PCM_source_transfer_t*</i> ")  
  String=string.gsub(String, " audio_hook_register_t%* ", " <i class=\"dtype\">audio_hook_register_t*</i> ")  
  String=string.gsub(String, " size_t ", " <i class=\"dtype\">size_t</i> ")  
  String=string.gsub(String, " function ", " <i class=\"dtype\">function</i> ")  
  String=string.gsub(String, " ReaperArray ", " <i class=\"dtype\">ReaperArray</i> ")  
  String=string.gsub(String, " optional ", " <i class=\"dtype\">optional</i> ")  
  String=string.gsub(String, " table ", " <i class=\"dtype\">table</i> ")  
  String=string.gsub(String, " array ", " <i class=\"dtype\">array</i> ")  
  
  String=string.gsub(String, "%( ", "(")
  String=string.gsub(String, "%[ ", "[")
  return String:sub(2,-2)
end



-- Let's begin:

-- Step 1: read the docs-source-file(s)
String=""
if type(Infilename)=="table" then
  for i=1, #Infilename do
    String=String..ultraschall.ReadFullFile(Infilename[i], false)
  end
else
    String=ultraschall.ReadFullFile(Infilename, false)
end

-- split into individual USDocBlocs
local Ccount, AllUSDocBloc_Header=ultraschall.SplitUSDocBlocs(String)

-- get some API-version-information
local usD,usversion,usdate,usbeta,usTagline,usF,usG=ultraschall.GetApiVersion()


-- Step 2: create the index
index=1
b=0

function contentindex()
  print_update(CurrentDocs..": Create Index\n")
  HeaderList={}
  local count=1
  local count2=0
  
  -- get the chapter-contexts
  -- every entry in HeaderList is "chaptercontext1, chaptercontext2,"
  while AllUSDocBloc_Header[count]~=nil do
    local A, AA, AAA = ultraschall.ParseChapterContext(AllUSDocBloc_Header[count][2])        
      temp=AAA.."\n"
      for i=1, count2 do
        if HeaderList[i]==temp then found=true end
      end
      if found~=true then
        count2=count2+1
        HeaderList[count2]=temp
      end
      found=false
    
    count=count+1
  end
  
  if DontSort==nil then
    table.sort(HeaderList)
  end
  
  -- add to the chapter-contexts the accompanying slugs, using newlines
  -- "chaptercontext1, chaptercontext2,\nslug1\nslug2\nslug3\n" etc
  count=1
  while AllUSDocBloc_Header[count]~=nil do    
    local A1, AA1, AAA1 = ultraschall.ParseChapterContext(AllUSDocBloc_Header[count][2])
    local Slug=AllUSDocBloc_Header[count][1]
    local temp=AAA1.."\n"
       
    for i=1, count2 do
      if HeaderList[i]:match("(.-\n)")==temp then 
            HeaderList[i]=HeaderList[i]..Slug.."\n"
            break 
      end
    end    
    count=count+1
  end
  
  if DontSort==nil then
    table.sort(HeaderList)
  end
  
  -- now we sort the slugs
  for i=1, count2 do
    local chapter=HeaderList[i]:match("(.-\n)")
    local slugs=HeaderList[i]:match("\n(.*)\n")
    local A2, AA2, AAA2 = ultraschall.SplitStringAtLineFeedToArray(slugs)
    if DontSort==nil then
      table.sort(AA2)
    end
    slugs=""
    for i=1, A2 do
      slugs=slugs..AA2[i].."\n"
    end
    HeaderList[i]=chapter..slugs
  end
  
--  FunctionList=""
  
  -- now we create the index
  FunctionsLister={}
  FunctionsLister_Count=0
  
  for i=1, count2 do
    local Top=HeaderList[i]:match("(.-),")
    local Second=HeaderList[i]:match(".-,(.-),")
    local Third=HeaderList[i]:match(".-,.-,(.-),")
    local Counts, Slugs=ultraschall.SplitStringAtLineFeedToArray(HeaderList[i]:match(".-\n(.*)\n"))
    slugs=""
    if Top==nil then One="" else One=Top end
    if Second==nil then Two="" else Two=Second end
    if Third==nil then Three="" else Three=Third end
    FunctionsLister_Count=FunctionsLister_Count+1
    FunctionsLister[FunctionsLister_Count]="HEADER:"..tostring(One).." "..tostring(Two).." "..tostring(Three).."\n"
    if Top==nil then Top="" else Top="<br><a style=\"margin-left:-14\" id=\""..Top.."\"><a href=\"#"..Top.."\">^</a></a><strong> <u>"..Top.."</u></strong><br><br>\n" end
    if i>1 and Top:match("u%>(.-)%</u")==HeaderList[i-1]:match("(.-),") then Top="" end
    if Second==nil then Second="" else Second="<b style=\"font-size:small;\"><br><a style=\"margin-left:-14\" id=\""..Second.."\"><a href=\"#"..Second.."\">^</a></a> "..Second.."</b>\n" end
    if i>1 and Second:match("%>(.-)%<")==HeaderList[i-1]:match("(.-),") then Second="" end
    if Third==nil then Third="" else Third=Third.."\n" end
    if i>1 and Third:match("%>(.-)%<")==HeaderList[i-1]:match("(.-),") then Third="" end
  
    if Index==nil then Index=4 end
    linebreaker=1
    for a=1, Counts do
      if linebreaker==1 then slugs=slugs.."<tr>" end
      --if linebreaker==5 then slugs=slugs.."</tr>" linebreaker=1 end
      if linebreaker==Index+1 then slugs=slugs.."</tr>" linebreaker=1 end
      slugs=slugs.."<td style=\"width:25%; font-size:small;\"><a class=\"smallfontTD\" href=\"#"..Slugs[a].."\">"..Slugs[a].."</a></td>"
      FunctionsLister_Count=FunctionsLister_Count+1
      FunctionsLister[FunctionsLister_Count]=Slugs[a]
      linebreaker=linebreaker+1
    end
    if linebreaker==1 then slugs=slugs.."<td style=\"width:25%;\">&nbsp;</td>" linebreaker=linebreaker+1 end
    if linebreaker==2 and Index>1 then slugs=slugs.."<td style=\"width:25%;\">&nbsp;</td>" linebreaker=linebreaker+1 end
    if linebreaker==3 and Index>2 then slugs=slugs.."<td style=\"width:25%;\">&nbsp;</td>" linebreaker=linebreaker+1 end
    if linebreaker==4 and Index>3 then slugs=slugs.."<td style=\"width:25%;\">&nbsp;</td>" linebreaker=linebreaker+1 end
    slugs=slugs.."</tr>"
    
    FunctionList=FunctionList.."<table class=\"indexpad\" style=\"width:100%;\" border=\"0\"><tr><td>"..Top..Second..Third.."</td></tr>"..slugs.."</table>"
  end

    FunctionList=FunctionList.."<br></div>"
    
    for i=1, FunctionsLister_Count do
      if FunctionsLister[i]:sub(1,4)~="HEAD" then
        for a=1, Ccount do
          if AllUSDocBloc_Header[a][1]==FunctionsLister[i] then
            FunctionsLister[i]=a
          end
        end
      end
    end
end

-- Step 3: convert Markdown to HTML
function convertMarkdown(start, stop)
  if start==nil then start=1 end
  if stop==nil then stop=Ccount end
  
  print_update(CurrentDocs..": Converting Markdown")
  FunctionConverter={}
  FunctionConverter_count=0
  
  for i=start, stop do
    local Description
    Description, AllUSDocBloc_Header[i]["markup_type"] = ultraschall.Docs_GetUSDocBloc_Description(AllUSDocBloc_Header[i][2], true, 1)

    if AllUSDocBloc_Header[i]["markup_type"]=="plaintext" then
      AllUSDocBloc_Header[i][6]=ultraschall.Docs_ConvertPlainTextToHTML(Description)
    else
      ultraschall.WriteValueToFile(Tempfile..i..".md", Description)
      FunctionConverter_count=FunctionConverter_count+1
      FunctionConverter[FunctionConverter_count]=i
    end
    --]]
  end 

  Batch=""
  for i=1, FunctionConverter_count do
    Batch=Batch..PanDoc.." -f markdown_strict -t html \""..ultraschall.Api_Path.."/temp/"..FunctionConverter[i]..".md\" -o \""..ultraschall.Api_Path.."/temp/"..FunctionConverter[i]..".html\"\n"
  end
  
  ultraschall.WriteValueToFile(Tempfile.."/Batch.bat", Batch)
  reaper.ExecProcess(Tempfile.."/Batch.bat", 0)  
  os.remove(Tempfile.."/Batch.bat")
  
  for i=1, FunctionConverter_count do
    AllUSDocBloc_Header[FunctionConverter[i]][6]=ultraschall.ReadFullFile(Tempfile..FunctionConverter[i]..".html")
    os.remove(Tempfile..FunctionConverter[i]..".html")
    os.remove(Tempfile..FunctionConverter[i]..".md")
  end
  
  
  -- add spaces into the beginning (buggy with <pre><code>-tags, so it's deactivated)
  --for i=1, Ccount do
    --AllUSDocBloc_Header[i][6]="\t\t\t\t"..string.gsub(AllUSDocBloc_Header[i][6], "\n", "\n\t\t\t\t")
  --end
end



-- Step 4: create the entries
function entries(start, stop)
  if start==nil then start=1 end
  if stop==nil then stop=FunctionsLister_Count end
  for EntryCount=start, stop do
    if type(FunctionsLister[EntryCount])=="string" then
      -- Insert a header for the next functions-category inside the functions
      -- still ugly. Uncomment it to see it for yourself...
      --FunctionList=FunctionList.."<div class=\"chapterpad\"><hr><h3><a id=\"Functions:"..FunctionsLister[EntryCount]:sub(8,-1).."\"></a><a href=\"#"..FunctionsLister[EntryCount]:sub(8,-1).."\">^</a>"..FunctionsLister[EntryCount]:sub(8,-1).."-functions</h3>"
    else
      --print_update(i)
      local title=ultraschall.Docs_GetUSDocBloc_Title(AllUSDocBloc_Header[FunctionsLister[EntryCount]][2], 1)
  
      -- get the requires
      local req_count, requires, requires_alt = ultraschall.Docs_GetUSDocBloc_Requires(AllUSDocBloc_Header[FunctionsLister[EntryCount]][2])
  
      -- get the functioncalls
      local functioncall={}
      local f1, f2= ultraschall.Docs_GetUSDocBloc_Functioncall(AllUSDocBloc_Header[FunctionsLister[EntryCount]][2], 1)
      if f1~=nil and f2==nil then f2="lua" end
      if f2~=nil and f1~=nil then
        functioncall[f2]=f1
        f1, f2= ultraschall.Docs_GetUSDocBloc_Functioncall(AllUSDocBloc_Header[FunctionsLister[EntryCount]][2], 2)
        if f2~=nil then functioncall[f2]=f1 end
        f1, f2= ultraschall.Docs_GetUSDocBloc_Functioncall(AllUSDocBloc_Header[FunctionsLister[EntryCount]][2], 3)
        if f2~=nil then functioncall[f2]=f1 end
        f1, f2= ultraschall.Docs_GetUSDocBloc_Functioncall(AllUSDocBloc_Header[FunctionsLister[EntryCount]][2], 4)
        if f2~=nil then functioncall[f2]=f1 end
      end
      
      
      -- get the parameters
      local Parmcount, Params, markuptype, markupversion, prog_lang, spok_lang, indent = ultraschall.Docs_GetUSDocBloc_Params(AllUSDocBloc_Header[FunctionsLister[EntryCount]][2], true, 1)
  
      -- get the return values
      local Retvalscount, Retvals, markuptype, markupversion, prog_lang, spok_lang, indent = ultraschall.Docs_GetUSDocBloc_Retvals(AllUSDocBloc_Header[FunctionsLister[EntryCount]][2], true, 1)
      -- slug and anchor
      FunctionList=FunctionList..[[
      
            <div class="chapterpad">
              <hr>
              <a class="anchor" id="]]..AllUSDocBloc_Header[FunctionsLister[EntryCount]][1]..[["></a>
              <a href="#]]..AllUSDocBloc_Header[FunctionsLister[EntryCount]][1]..[["> ^</a> ]]
      
      -- requires
      if requires_alt["Reaper"]~=nil then
        FunctionList=FunctionList.."\n            <img width=\"3%\" src=\"gfx/reaper"..requires_alt["Reaper"]..".png\" alt=\"Reaper version "..requires_alt["Reaper"].."\">"
      end
      if requires_alt["SWS"]~=nil then
        FunctionList=FunctionList.."\n            <img width=\"3%\" src=\"gfx/sws"..requires_alt["SWS"]..".png\" alt=\"SWS version "..requires_alt["SWS"].."\">"
      end
      if requires_alt["JS"]~=nil then
        FunctionList=FunctionList.."\n            <img width=\"3%\" src=\"gfx/js_"..requires_alt["JS"]..".png\" alt=\"JS version "..requires_alt["JS"].."\">"
      end
      if requires_alt["Osara"]~=nil then
        FunctionList=FunctionList.."\n            <img width=\"3%\" src=\"gfx/Osara"..requires_alt["Osara"]..".png\" alt=\"Osara version "..requires_alt["Osara"].."\">"
      end
      if requires_alt["ReaImGui"]~=nil then
        FunctionList=FunctionList.."\n            <img width=\"3%\" src=\"gfx/reaimgui"..requires_alt["ReaImGui"]..".png\" alt=\"ReaImGui version "..requires_alt["ReaImGui"].."\">"
      end
      if requires_alt["ReaBlink"]~=nil then
        FunctionList=FunctionList.."\n            <img width=\"3%\" src=\"gfx/reablink"..requires_alt["ReaBlink"]..".png\" alt=\"ReaBlink version "..requires_alt["ReaBlink"].."\">"
      end
      if requires_alt["Ultraschall"]~=nil then
        FunctionList=FunctionList.."\n            <img width=\"3%\" src=\"gfx/ultraschall"..requires_alt["Ultraschall"]..".png\" alt=\"Ultraschall version "..requires_alt["Ultraschall"].."\">"
      end
      
      -- Title
      --if title==nil then print3(AllUSDocBloc_Header[FunctionsLister[EntryCount]][1]) end
      if title==nil then title=AllUSDocBloc_Header[FunctionsLister[EntryCount]][1]end
      FunctionList=FunctionList.."<u><b>"..title.."</b></u><br><br>"
      if AllUSDocBloc_Header[FunctionsLister[EntryCount]][6]==nil then AllUSDocBloc_Header[FunctionsLister[EntryCount]][6]="PUDELDUDEL" end
      
      
      -- Functioncalls
      if functioncall["cpp"]~=nil or 
         functioncall["lua"]~=nil or 
         functioncall["python"]~=nil or 
         functioncall["eel"]~=nil 
      then
        AllUSDocBloc_Header[FunctionsLister[EntryCount]]["Tohoo"]=true
        FunctionList=FunctionList..[[
  
            <u>Functioncall:</u>
            <div class="chapterpad" style="font-size:104%; color:DDDDDD;">
        ]]
        if functioncall["cpp"]~=nil then
          FunctionList=FunctionList.."\t\t<div class=\"c_func\"><span class='all_view'>C: </span><code>"..ColorateFunctionnames(ultraschall.ColorateDatatypes(functioncall["cpp"])).."</code><br></div>\n"
        end
        if functioncall["eel"]~=nil then
          FunctionList=FunctionList.."\t\t\t\t<div class=\"e_func\"><span class='all_view'>EEL2: </span><code>"..ColorateFunctionnames(ultraschall.ColorateDatatypes(functioncall["eel"])).."</code><br></div>\n"
        end
        if functioncall["lua"]~=nil then
          FunctionList=FunctionList.."\t\t\t\t<div class=\"l_func\"><span class='all_view'>Lua: </span><code>"..ColorateFunctionnames(ultraschall.ColorateDatatypes(functioncall["lua"])).."</code><br></div>\n"
        end
        if functioncall["python"]~=nil then
          FunctionList=FunctionList.."\t\t\t\t<div class=\"p_func\"><span class='all_view'>Python: </span><code>"..ColorateFunctionnames(ultraschall.ColorateDatatypes(functioncall["python"])).."</code><br></div>\n"
        end
        FunctionList=FunctionList.."\t\t\t</div><p>\n"
      end    
      --Description
      FunctionList=FunctionList..[[
              <u>Description:</u><br>
              <div class="chapterpad">
  ]]..AllUSDocBloc_Header[FunctionsLister[EntryCount]][6]
                ..[[
              
              </div>
              <br>]]
  
      -- Parameters
      if Parmcount>0 then
        FunctionList=FunctionList..[[
      
               <u>Parameters:</u>
      ]]
      
        for i=1, Parmcount do
          Params[i][1]=ultraschall.ColorateDatatypes(Params[i][1])
          FunctionList=FunctionList..[[
                 <table class="chapterpad">
                   <tr>
                     <td class="parmret"><i>]]..Params[i][1]..[[</i></td>
                     <td>]]..Params[i][2]..[[</td>
                   </tr>
                  </table
                <br>
          ]]
        end 
        FunctionList=FunctionList.."<br>"
      end
      
      -- Retvals
      if Retvalscount>0 then
        FunctionList=FunctionList..[[
      
               <u>Returnvalues:</u>
      ]]
      
        for i=1, Retvalscount do
          Retvals[i][1]=ultraschall.ColorateDatatypes(Retvals[i][1])
          FunctionList=FunctionList..[[
                 <table class="chapterpad">
                   <tr>
                     <td class="parmret"><i>]]..Retvals[i][1]..[[</i></td>
                     <td>]]..Retvals[i][2]..[[</td>
                   </tr>
                  </table
                <br>
          ]]
        end 
        FunctionList=FunctionList.."<br>"
      end
    end
        
    -- Closing Tags
        FunctionList=FunctionList..[[
            <br>
        </div>
    ]]
    ultraschall.WriteValueToFile(Outfile, FunctionList, nil, true)
    FunctionList=""
    print_update(CurrentDocs..": "..EntryCount.."/"..Ccount, reaper.time_precise())
  end
  
  FunctionList=FunctionList..[[
      <div class="chapterpad">
        <hr>
          <table><td style="width:49%">View: [<span class='aclick'>all</span>] [<span class='cclick'><a href=\"#c\" onClick=\"setdocview('c')\">C/C++</a></span>] [<span class='eclick'><a href=\"#e\" onClick=\"setdocview('e')\">EEL2</a></span>] [<span class='lclick'><a href=\"#l\" onClick=\"setdocview('l')\">Lua</a></span>] [<span class='pclick'><a href=\"#p\" onClick=\"setdocview('p')\">Python</a></span>]</td><td>&#160;</td><td style=\"padding-left:20.5%;\">Automatically generated by Ultraschall-API ]]..usversion..[[ ]]..usbeta..[[ - ]]..Ccount..[[ elements available <br>(Reaper, SWS, JS, ReaImGui, Osara, ReaBlink)</td></table>
        <hr>
      </div>
      <br>
      </body>
  </html>
  ]]
end


contentindex()
convertMarkdown()
ultraschall.WriteValueToFile(Outfile, FunctionList)
FunctionList=""
entries()

-- Step 5: Write the outputfile
ultraschall.WriteValueToFile(Outfile, FunctionList, nil, true)

--ultraschall.WriteValueToFile(ultraschall.Api_Path.."/Documentation/Reaper_Api_Documentation.html", FunctionList)
