--[[
################################################################################
# 
# Copyright (c) 2014-2020 Ultraschall (http://ultraschall.fm)
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


if type(ultraschall)~="table" then 
  -- update buildnumber and add ultraschall as a table, when programming within this file
  local retval, string = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "Functions-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
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
  reaper.BR_Win32_WritePrivateProfileString("Ultraschall-Api-Build", "Functions-Build", string, reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  reaper.BR_Win32_WritePrivateProfileString("Ultraschall-Api-Build", "API-Build", string2, reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")  
  ultraschall={} 
  dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
end
    
function ultraschall.ApiBetaFunctionsTest()
    -- tell the api, that the beta-functions are activated
    ultraschall.functions_beta_works="on"
end

  


--ultraschall.ShowErrorMessagesInReascriptConsole(true)

--ultraschall.WriteValueToFile()

--ultraschall.AddErrorMessage("func","parm","desc",2)




function ultraschall.GetProject_RenderOutputPath(projectfilename_with_path)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetProject_RenderOutputPath</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>string render_output_directory = ultraschall.GetProject_RenderOutputPath(string projectfilename_with_path)</functioncall>
  <description>
    returns the output-directory for rendered files of a project.

    Doesn't return the correct output-directory for queued-projects!
    
    returns nil in case of an error
  </description>
  <parameters>
    string projectfilename_with_path - the projectfilename with path, whose renderoutput-directories you want to know
  </parameters>
  <retvals>
    string render_output_directory - the output-directory for projects
  </retvals>
  <chapter_context>
    Project-Files
    Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>render management, get, project, render, outputpath</tags>
</US_DocBloc>
]]
  if type(projectfilename_with_path)~="string" then ultraschall.AddErrorMessage("GetProject_RenderOutputPath", "projectfilename_with_path", "must be a string", -1) return nil end
  if reaper.file_exists(projectfilename_with_path)==false then ultraschall.AddErrorMessage("GetProject_RenderOutputPath", "projectfilename_with_path", "file does not exist", -2) return nil end
  local ProjectStateChunk=ultraschall.ReadFullFile(projectfilename_with_path)
  local QueueRendername=ProjectStateChunk:match("(QUEUED_RENDER_OUTFILE.-)\n")
  local QueueRenderProjectName=ProjectStateChunk:match("(QUEUED_RENDER_ORIGINAL_FILENAME.-)\n")
  local OutputRender, RenderPattern, RenderFile
  
  if QueueRendername~=nil then
    QueueRendername=QueueRendername:match(" \"(.-)\" ")
    QueueRendername=ultraschall.GetPath(QueueRendername)
  end
  
  if QueueRenderProjectName~=nil then
    QueueRenderProjectName=QueueRenderProjectName:match(" (.*)")
    QueueRenderProjectName=ultraschall.GetPath(QueueRenderProjectName)
  end


  RenderFile=ProjectStateChunk:match("(RENDER_FILE.-)\n")
  if RenderFile~=nil then
    RenderFile=RenderFile:match("RENDER_FILE (.*)")
    RenderFile=string.gsub(RenderFile,"\"","")
  end
  
  RenderPattern=ProjectStateChunk:match("(RENDER_PATTERN.-)\n")
  if RenderPattern~=nil then
    RenderPattern=RenderPattern:match("RENDER_PATTERN (.*)")
    if RenderPattern~=nil then
      RenderPattern=string.gsub(RenderPattern,"\"","")
    end
  end

  -- get the normal render-output-directory
  if RenderPattern~=nil and RenderFile~=nil then
    if ultraschall.DirectoryExists2(RenderFile)==true then
      OutputRender=RenderFile
    else
      OutputRender=ultraschall.GetPath(projectfilename_with_path)..ultraschall.Separator..RenderFile
    end
  elseif RenderFile~=nil then
    OutputRender=ultraschall.GetPath(RenderFile)    
  else
    OutputRender=ultraschall.GetPath(projectfilename_with_path)
  end


  -- get the potential RenderQueue-renderoutput-path
  -- not done yet...todo
  -- that way, I may be able to add the currently opened projects as well...
--[[
  if RenderPattern==nil and (RenderFile==nil or RenderFile=="") and
     QueueRenderProjectName==nil and QueueRendername==nil then
    QueueOutputRender=ultraschall.GetPath(projectfilename_with_path)
  elseif RenderPattern~=nil and RenderFile~=nil then
    if ultraschall.DirectoryExists2(RenderFile)==true then
      QueueOutputRender=RenderFile
    end
  end
  --]]
  
  OutputRender=string.gsub(OutputRender,"\\\\", "\\")
  
  return OutputRender, QueueOutputRender
end

--A="c:\\Users\\meo\\Desktop\\trss\\20Januar2019\\rec\\rec3.RPP"

--B,C=ultraschall.GetProject_RenderOutputPath()


function ultraschall.ResolveRenderPattern(renderpattern)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ResolveRenderPattern</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>string resolved_renderpattern = ultraschall.ResolveRenderPattern(string render_pattern)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    resolves a render-pattern into its render-filename(without extension).

    returns nil in case of an error    
  </description>
  <parameters>
    string render_pattern - the render-pattern, that you want to resolve into its render-filename
  </parameters>
  <retvals>
    string resolved_renderpattern - the resolved renderpattern, that is used for a render-filename.
                                  - just add extension and path to it.
                                  - Stems will be rendered to path/resolved_renderpattern-XXX.ext
                                  -    where XXX is a number between 001(usually for master-track) and 999
  </retvals>
  <chapter_context>
    Rendering Projects
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>rendermanagement, resolve, renderpattern, filename</tags>
</US_DocBloc>
]]
  if type(renderpattern)~="string" then ultraschall.AddErrorMessage("ResolveRenderPattern", "renderpattern", "must be a string", -1) return nil end
  if renderpattern=="" then return "" end
  local TempProject=ultraschall.Api_Path.."misc/tempproject.RPP"
  local TempFolder=ultraschall.Api_Path.."misc/"
  TempFolder=string.gsub(TempFolder, "\\", ultraschall.Separator)
  TempFolder=string.gsub(TempFolder, "/", ultraschall.Separator)
  
  ultraschall.SetProject_RenderFilename(TempProject, "")
  ultraschall.SetProject_RenderPattern(TempProject, renderpattern)
  ultraschall.SetProject_RenderStems(TempProject, 0)
  
  reaper.Main_OnCommand(41929,0)
  reaper.Main_openProject(TempProject)
  
  A,B=ultraschall.GetProjectStateChunk()
  reaper.Main_SaveProject(0,false)
  reaper.Main_OnCommand(40860,0)
  if B==nil then B="" end
  
  count, split_string = ultraschall.SplitStringAtLineFeedToArray(B)

  for i=1, count do
    split_string[i]=split_string[i]:match("\"(.-)\"")
  end
  if split_string[1]==nil then split_string[1]="" end
  return string.gsub(split_string[1], TempFolder, ""):match("(.-)%.")
end

--for i=1, 10 do
--  O=ultraschall.ResolveRenderPattern("I would find a way $day")
--end

ultraschall.ShowLastErrorMessage()


function ultraschall.InsertMediaItemArray2(position, MediaItemArray, trackstring)
  
--ToDo: Die Möglichkeit die Items in andere Tracks einzufügen. Wenn trackstring 1,3,5 ist, die Items im MediaItemArray
--      in 1,2,3 sind, dann landen die Items aus track 1 in track 1, track 2 in track 3, track 3 in track 5
--
-- Beta 3 Material
  
  if type(position)~="number" then return -1 end
  local trackstring,AA,AAA=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if trackstring==-1 then return -1 end
  local count=1
  local i
  if type(MediaItemArray)~="table" then return -1 end
  local NewMediaItemArray={}
  local _count, individual_values = ultraschall.CSV2IndividualLinesAsArray(trackstring) 
  local ItemStart=reaper.GetProjectLength()+1
  while MediaItemArray[count]~=nil do
    local ItemStart_temp=reaper.GetMediaItemInfo_Value(MediaItemArray[count], "D_POSITION")
    if ItemStart>ItemStart_temp then ItemStart=ItemStart_temp end
    count=count+1
  end
  count=1
  while MediaItemArray[count]~=nil do
    local ItemStart_temp=reaper.GetMediaItemInfo_Value(MediaItemArray[count], "D_POSITION")
    local MediaTrack=reaper.GetMediaItem_Track(MediaItemArray[count])
    --nur einfügen, wenn mediaitem aus nem Track stammt, der in trackstring vorkommt
    i=1
    while individual_values[i]~=nil do
--    reaper.MB("Yup"..i,individual_values[i],0)
    if reaper.GetTrack(0,individual_values[i]-1)==reaper.GetMediaItem_Track(MediaItemArray[count]) then 
    NewMediaItemArray[count]=ultraschall.InsertMediaItem_MediaItem(position+(ItemStart_temp-ItemStart),MediaItemArray[count],MediaTrack)
    end
    i=i+1
    end
    count=count+1
  end  
--  TrackArray[count]=reaper.GetMediaItem_Track(MediaItem)
--  MediaItem reaper.AddMediaItemToTrack(MediaTrack tr)
end

--C,CC=ultraschall.GetAllMediaItemsBetween(1,60,"1,3",false)
--A,B=reaper.GetItemStateChunk(CC[1], "", true)
--reaper.ShowConsoleMsg(B)
--ultraschall.InsertMediaItemArray(82, CC, "4,5")

--tr = reaper.GetTrack(0, 1)
--MediaItem=reaper.AddMediaItemToTrack(tr)
--Aboolean=reaper.SetItemStateChunk(CC[1], PUH, true)
--PCM_source=reaper.PCM_Source_CreateFromFile("C:\\Recordings\\01-te.flac")
--boolean=reaper.SetMediaItemTake_Source(MediaItem_Take, PCM_source)
--reaper.SetMediaItemInfo_Value(MediaItem, "D_POSITION", "1")
--ultraschall.InsertMediaItemArray(0,CC)


function ultraschall.RippleDrag_Start(position, trackstring, deltalength)
  A,MediaItemArray = ultraschall.GetMediaItemsAtPosition(position, trackstring)
  ultraschall.ChangeDeltaLengthOfMediaItems_FromArray(MediaItemArray, deltalength)
  C,CC=ultraschall.GetAllMediaItemsBetween(position, reaper.GetProjectLength(), trackstring, false)
  for i=C, 1, -1 do
    for j=A, 1, -1 do
--      reaper.MB(j,"",0)
      if MediaItemArray[j]==CC[i] then  table.remove(CC, i) end 
    end
  end
  ultraschall.ChangePositionOfMediaItems_FromArray(CC, deltalength)
end

--ultraschall.RippleDrag_Start(13,"1,2,3",-1)

function ultraschall.RippleDragSection_Start(startposition, endposition, trackstring, newoffset)
end

function ultraschall.RippleDrag_StartOffset(position, trackstring, newoffset)
--unfertig und buggy
  A,MediaItemArray = ultraschall.GetMediaItemsAtPosition(position, trackstring)
  ultraschall.ChangeOffsetOfMediaItems_FromArray(MediaItemArray, newoffset)
  ultraschall.ChangeDeltaLengthOfMediaItems_FromArray(MediaItemArray, -newoffset)
  C,CC=ultraschall.GetAllMediaItemsBetween(position, reaper.GetProjectLength(), trackstring, false)
  for i=C, 1, -1 do
    for j=A, 1, -1 do
--      reaper.MB(j,"",0)
      if MediaItemArray[j]==CC[i] then  table.remove(CC, i) end 
    end
  end
  ultraschall.ChangePositionOfMediaItems_FromArray(CC, newoffset)
end

--ultraschall.RippleDrag_StartOffset(13,"2",10)

--A=ultraschall.CreateRenderCFG_MP3CBR(1, 4, 10)
--B=ultraschall.CreateRenderCFG_MP3CBR(1, 10, 10)
--L,L2,L3,L4=ultraschall.RenderProject_RenderCFG(nil, "c:\\Reaper-Internal-Docs.mp3", 0, 10, false, true, true,A)
--L,L1,L2,L3,L4=ultraschall.RenderProjectRegions_RenderCFG(nil, "c:\\Reaper-Internal-Docs.mp3", 1, false, false, true, true,A)
--L=reaper.IsProjectDirty(0)

--outputchannel, post_pre_fader, volume, pan, mute, phase, source, unknown, automationmode = ultraschall.GetTrackHWOut(0, 1)

--count, MediaItemArray_selected = ultraschall.GetAllSelectedMediaItems() -- get old selection
--A=ultraschall.PutMediaItemsToClipboard_MediaItemArray(MediaItemArray_selected)

---------------------------
---- Routing Snapshots ----
---------------------------

function ultraschall.SetRoutingSnapshot(snapshot_nr)
end

function ultraschall.RecallRoutingSnapshot(snapshot_nr)
end

function ultraschall.ClearRoutingSnapshot(snapshot_nr)
end




function ultraschall.RippleDragSection_StartOffset(position,trackstring)
end

function ultraschall.RippleDrag_End(position,trackstring)

end

function ultraschall.RippleDragSection_End(position,trackstring)
end



--ultraschall.ShowLastErrorMessage()

function ultraschall.GetProjectReWireSlave(projectfilename_with_path)
--To Do
-- ProjectSettings->Advanced->Rewire Slave Settings
end

function ultraschall.GetLastEnvelopePoint(Envelopeobject)
end

function ultraschall.GetAllTrackEnvelopes_EnvelopePointArray(tracknumber)
--returns all track-envelopes from tracknumber as EnvelopePointArray
end

function ultraschall.GetAllTrackEnvelopes_EnvelopePointArray2(MediaTrack)
--returns all track-envelopes from MediaTrack as EnvelopePointArray
end



function ultraschall.OnlyMediaItemsInBothMediaItemArrays()
end

function ultraschall.OnlyMediaItemsInOneMediaItemArray()
end

function ultraschall.GetMediaItemTake_StateChunk(MediaItem, idx)
--returns an rppxml-statechunk for a MediaItemTake (not existing yet in Reaper!), for the idx'th take of MediaItem

--number reaper.GetMediaItemTakeInfo_Value(MediaItem_Take take, string parmname)
--MediaItem reaper.GetMediaItemTake_Item(MediaItem_Take take)

--[[Get parent item of media item take

integer reaper.GetMediaItemTake_Peaks(MediaItem_Take take, number peakrate, number starttime, integer numchannels, integer numsamplesperchannel, integer want_extra_type, reaper.array buf)
Gets block of peak samples to buf. Note that the peak samples are interleaved, but in two or three blocks (maximums, then minimums, then extra). Return value has 20 bits of returned sample count, then 4 bits of output_mode (0xf00000), then a bit to signify whether extra_type was available (0x1000000). extra_type can be 115 ('s') for spectral information, which will return peak samples as integers with the low 15 bits frequency, next 14 bits tonality.

PCM_source reaper.GetMediaItemTake_Source(MediaItem_Take take)
Get media source of media item take

MediaTrack reaper.GetMediaItemTake_Track(MediaItem_Take take)
Get parent track of media item take


MediaItem_Take reaper.GetMediaItemTakeByGUID(ReaProject project, string guidGUID)
--]]
end

function ultraschall.GetAllMediaItemTake_StateChunks(MediaItem)
--returns an array with all rppxml-statechunk for all MediaItemTakes of a MediaItem.
end


function ultraschall.SetReaScriptConsole_FontStyle(style)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>SetReaScriptConsole_FontStyle</slug>
    <requires>
      Ultraschall=4.1
      Reaper=5.965
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.SetReaScriptConsole_FontStyle(integer style)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      If the ReaScript-console is opened, you can change the font-style of it.
      You can choose between 19 different styles, with 3 being of fixed character length. It will change the next time you output text to the ReaScriptConsole.
      
      If you close and reopen the Console, you need to set the font-style again!
      
      You can only have one style active in the console!
      
      Returns false in case of an error
    </description>
    <retvals>
      boolean retval - true, displaying was successful; false, displaying wasn't successful
    </retvals>
    <parameters>
      integer length - the font-style used. There are 19 different ones.
                      - fixed-character-length:
                      -     1,  fixed, console
                      -     2,  fixed, console alt
                      -     3,  thin, fixed
                      - 
                      - normal from large to small:
                      -     4-8
                      -     
                      - bold from largest to smallest:
                      -     9-14
                      - 
                      - thin:
                      -     15, thin
                      - 
                      - underlined:
                      -     16, underlined, thin
                      -     17, underlined
                      -     18, underlined
                      - 
                      - symbol:
                      -     19, symbol
    </parameters>
    <chapter_context>
      User Interface
      Miscellaneous
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>ultraschall_functions_engine.lua</source_document>
    <tags>user interface, reascript, console, font, style</tags>
  </US_DocBloc>
  ]]
  if math.type(style)~="integer" then ultraschall.AddErrorMessage("SetReaScriptConsole_FontStyle", "style", "must be an integer", -1) return false end
  if style>19 or style<1 then ultraschall.AddErrorMessage("SetReaScriptConsole_FontStyle", "style", "must be between 1 and 17", -2) return false end
  local reascript_console_hwnd = ultraschall.GetReaScriptConsoleWindow()
  if reascript_console_hwnd==nil then return false end
  local styles={32,33,36,31,214,37,218,1606,4373,3297,220,3492,3733,3594,35,1890,2878,3265,4392}
  local Textfield=reaper.JS_Window_FindChildByID(reascript_console_hwnd, 1177)
  reaper.JS_WindowMessage_Send(Textfield, "WM_SETFONT", styles[style] ,0,0,0)
  return true
end
--reaper.ClearConsole()
--ultraschall.SetReaScriptConsole_FontStyle(1)
--reaper.ShowConsoleMsg("ABCDEFGhijklmnop\n123456789.-,!\"§$%&/()=\n----------\nOOOOOOOOOO")




--a,b=reaper.EnumProjects(-1,"")
--A=ultraschall.ReadFullFile(b)

--Mespotine



--[[
hwnd = ultraschall.GetPreferencesHWND()
hwnd2 = reaper.JS_Window_FindChildByID(hwnd, 1110)

--reaper.JS_Window_Move(hwnd2, 110,11)


for i=-1000, 10 do
  A,B,C,D=reaper.JS_WindowMessage_Post(hwnd2, "TVHT_ONITEM", i,i,i,i)
end
--]]


function ultraschall.get_action_context_MediaItemDiff(exlude_mousecursorsize, x, y)
-- TODO:: nice to have feature: when mouse is above crossfades between two adjacent items, return this state as well as a boolean
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>get_action_context_MediaItemDiff</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.975
    Lua=5.3
  </requires>
  <functioncall>MediaItem MediaItem, MediaItem_Take MediaItem_Take, MediaItem MediaItem_unlocked, boolean Item_moved, number StartDiffTime, number EndDiffTime, number LengthDiffTime, number OffsetDiffTime = ultraschall.get_action_context_MediaItemDiff(optional boolean exlude_mousecursorsize, optional integer x, optional integer y)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the currently clicked MediaItem, Take as well as the difference of position, end, length and startoffset since last time calling this function.
    Good for implementing ripple-drag/editing-functions, whose position depends on changes in the currently clicked MediaItem.
    Repeatedly call this (e.g. in a defer-cycle) to get all changes made, during dragging position, length or offset of the MediaItem underneath mousecursor.
    
    This function takes into account the size of the start/end-drag-mousecursor, that means: if mouse-position is within 3 pixels before start/after end of the item, it will get the correct MediaItem. 
    This is a workaround, as the mouse-cursor changes to dragging and can still affect the MediaItem, even though the mouse at this position isn't above a MediaItem anymore.
    To be more strict, set exlude_mousecursorsize to true. That means, it will only detect MediaItems directly beneath the mousecursor. If the mouse isn't above a MediaItem, this function will ignore it, even if the mouse could still affect the MediaItem.
    If you don't understand, what that means: simply omit exlude_mousecursorsize, which should work in almost all use-cases. If it doesn't work as you want, try setting it to true and see, whether it works now.    
    
    returns nil in case of an error
  </description>
  <retvals>
    MediaItem MediaItem - the MediaItem at the current mouse-position; nil if not found
    MediaItem_Take MediaItem_Take - the MediaItem_Take underneath the mouse-cursor
    MediaItem MediaItem_unlocked - if the MediaItem isn't locked, you'll get a MediaItem here. If it is locked, this retval is nil
    boolean Item_moved - true, the item was moved; false, only a part(either start or end or offset) of the item was moved
    number StartDiffTime - if the start of the item changed, this is the difference;
                         -   positive, the start of the item has been changed towards the end of the project
                         -   negative, the start of the item has been changed towards the start of the project
                         -   0, no changes to the itemstart-position at all
    number EndDiffTime - if the end of the item changed, this is the difference;
                         -   positive, the end of the item has been changed towards the end of the project
                         -   negative, the end of the item has been changed towards the start of the project
                         -   0, no changes to the itemend-position at all
    number LengthDiffTime - if the length of the item changed, this is the difference;
                         -   positive, the length is longer
                         -   negative, the length is shorter
                         -   0, no changes to the length of the item
    number OffsetDiffTime - if the offset of the item-take has changed, this is the difference;
                         -   positive, the offset has been changed towards the start of the project
                         -   negative, the offset has been changed towards the end of the project
                         -   0, no changes to the offset of the item-take
                         - Note: this is the offset of the take underneath the mousecursor, which might not be the same size, as the MediaItem itself!
                         - So changes to the offset maybe changes within the MediaItem or the start of the MediaItem!
                         - This could be important, if you want to affect other items with rippling.
  </retvals>
  <parameters>
    optional boolean exlude_mousecursorsize - false or nil, get the item underneath, when it can be affected by the mouse-cursor(dragging etc): when in doubt, use this
                                            - true, get the item underneath the mousecursor only, when mouse is strictly above the item,
                                            -       which means: this ignores the item when mouse is not above it, even if the mouse could affect the item
    optional integer x - nil, use the current x-mouseposition; otherwise the x-position in pixels
    optional integer y - nil, use the current y-mouseposition; otherwise the y-position in pixels
  </parameters>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, get, action, context, difftime, item, mediaitem, offset, length, end, start, locked, unlocked</tags>
</US_DocBloc>
--]]
  if x~=nil and math.type(x)~="integer" then ultraschall.AddErrorMessage("get_action_context_MediaItemDiff", "x", "must be either nil or an integer", -1) return nil end
  if y~=nil and math.type(y)~="integer" then ultraschall.AddErrorMessage("get_action_context_MediaItemDiff", "y", "must be either nil or an integer", -2) return nil end
  if (x~=nil and y==nil) or (y~=nil and x==nil) then ultraschall.AddErrorMessage("get_action_context_MediaItemDiff", "x or y", "must be either both nil or both an integer!", -3) return nil end
  local MediaItem, MediaItem_Take, MediaItem_unlocked
  local StartDiffTime, EndDiffTime, Item_moved, LengthDiffTime, OffsetDiffTime
  if x==nil and y==nil then x,y=reaper.GetMousePosition() end
  MediaItem, MediaItem_Take = reaper.GetItemFromPoint(x, y, true)
  MediaItem_unlocked = reaper.GetItemFromPoint(x, y, false)
  if MediaItem==nil and exlude_mousecursorsize~=true then
    MediaItem, MediaItem_Take = reaper.GetItemFromPoint(x+3, y, true)
    MediaItem_unlocked = reaper.GetItemFromPoint(x+3, y, false)
  end
  if MediaItem==nil and exlude_mousecursorsize~=true then
    MediaItem, MediaItem_Take = reaper.GetItemFromPoint(x-3, y, true)
    MediaItem_unlocked = reaper.GetItemFromPoint(x-3, y, false)
  end
  
  -- crossfade-stuff
  -- example-values for crossfade-parts
  -- Item left: 811 -> 817 , Item right: 818 -> 825
  --               6           7
  -- first:  get, if the next and previous items are at each other/crossing; if nothing -> no crossfade
  -- second: get, if within the aforementioned pixel-ranges, there's another item
  --              6 pixels for the one before the current item
  --              7 pixels for the next item
  -- third: if yes: crossfade-area, else: no crossfade area
  --[[
  -- buggy: need to know the length of the crossfade, as the aforementioned attempt would work only
  --        if the items are adjacent but not if they overlap
  --        also need to take into account, what if zoomed out heavily, where items might be only
  --        a few pixels wide
  
  if MediaItem~=nil then
    ItemNumber = reaper.GetMediaItemInfo_Value(MediaItem, "IP_ITEMNUMBER")
    ItemTrack  = reaper.GetMediaItemInfo_Value(MediaItem, "P_TRACK")
    ItemBefore = reaper.GetTrackMediaItem(ItemTrack, ItemNumber-1)
    ItemAfter = reaper.GetTrackMediaItem(ItemTrack, ItemNumber+1)
    if ItemBefore~=nil then
      ItemBefore_crossfade=reaper.GetMediaItemInfo_Value(ItemBefore, "D_POSITION")+reaper.GetMediaItemInfo_Value(ItemBefore, "D_LENGTH")>=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
    end
  end
  --]]
  
  if ultraschall.get_action_context_MediaItem_old~=MediaItem then
    StartDiffTime=0
    EndDiffTime=0
    LengthDiffTime=0
    OffsetDiffTime=0
    if MediaItem~=nil then
      ultraschall.get_action_context_MediaItem_Start=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
      ultraschall.get_action_context_MediaItem_End=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")+reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
      ultraschall.get_action_context_MediaItem_Length=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")
      ultraschall.get_action_context_MediaItem_Offset=reaper.GetMediaItemTakeInfo_Value(MediaItem_Take, "D_STARTOFFS")
    end
  else
    if MediaItem~=nil then      
      StartDiffTime=ultraschall.get_action_context_MediaItem_Start
      EndDiffTime=ultraschall.get_action_context_MediaItem_End
      LengthDiffTime=ultraschall.get_action_context_MediaItem_Length
      OffsetDiffTime=ultraschall.get_action_context_MediaItem_Offset
      
      ultraschall.get_action_context_MediaItem_Start=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
      ultraschall.get_action_context_MediaItem_End=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")+reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
      ultraschall.get_action_context_MediaItem_Length=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")
      ultraschall.get_action_context_MediaItem_Offset=reaper.GetMediaItemTakeInfo_Value(MediaItem_Take, "D_STARTOFFS")
      
      Item_moved=(ultraschall.get_action_context_MediaItem_Start~=StartDiffTime
              and ultraschall.get_action_context_MediaItem_End~=EndDiffTime)
              
      StartDiffTime=ultraschall.get_action_context_MediaItem_Start-StartDiffTime
      EndDiffTime=ultraschall.get_action_context_MediaItem_End-EndDiffTime
      LengthDiffTime=ultraschall.get_action_context_MediaItem_Length-LengthDiffTime
      OffsetDiffTime=ultraschall.get_action_context_MediaItem_Offset-OffsetDiffTime
      
    end    
  end
  ultraschall.get_action_context_MediaItem_old=MediaItem

  return MediaItem, MediaItem_Take, MediaItem_unlocked, Item_moved, StartDiffTime, EndDiffTime, LengthDiffTime, OffsetDiffTime
end

--a,b,c,d,e,f,g,h,i=ultraschall.get_action_context_MediaItemDiff(exlude_mousecursorsize, x, y)



function ultraschall.TracksToColorPattern(colorpattern, startingcolor, direction)
end


function ultraschall.GetTrackPositions()
  -- only possible, when tracks can be seen...
  -- no windows above them are allowed :/
  local Arrange_view, timeline, TrackControlPanel = ultraschall.GetHWND_ArrangeViewAndTimeLine()
  local retval, left, top, right, bottom = reaper.JS_Window_GetClientRect(Arrange_view)
  local Tracks={}
  local x=left+2
  local OldItem=nil
  local Counter=0
  local B
  for y=top, bottom do
    A,B=reaper.GetTrackFromPoint(x,y)
    if OldItem~=A and A~=nil then
      Counter=Counter+1
      Tracks[Counter]={}
      Tracks[Counter][tostring(A)]=A
      Tracks[Counter]["Track_Top"]=y
      Tracks[Counter]["Track_Bottom"]=y
      OldItem=A
    elseif A==OldItem and A~=nil and B==0 then
      Tracks[Counter]["Track_Bottom"]=y
    elseif A==OldItem and A~=nil and B==1 then
      if Tracks[Counter]["Env_Top"]==nil then
        Tracks[Counter]["Env_Top"]=y
      end
      Tracks[Counter]["Env_Bottom"]=y
    elseif A==OldItem and A~=nil and B==2 then
      if Tracks[Counter]["TrackFX_Top"]==nil then
        Tracks[Counter]["TrackFX_Top"]=y
      end
      Tracks[Counter]["TrackFX_Bottom"]=y
    end
  end
  return Counter, Tracks
end

--A,B=ultraschall.GetTrackPositions()

function ultraschall.GetAllTrackHeights()
  -- can't calculate the dependency between zoom and trackheight... :/
  HH=reaper.SNM_GetIntConfigVar("defvzoom", -999)
  Heights={}
  for i=0, reaper.CountTracks(0) do
    Heights[i+1], heightstate2, unknown = ultraschall.GetTrackHeightState(i)
   -- if Heights[i+1]==0 then Heights[i+1]=HH end
  end

end

--ultraschall.GetAllTrackHeights()



--[[
A=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
--print2(22)
B=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
--print2(22)
C=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
D=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
E=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
F=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
G=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
H=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
--]]


function ultraschall.GetTrackEnvelope_ClickState()
-- how to get the connection to clicked envelopepoint, when mouse moves away from the item while retaining click(moving underneath the item for dragging)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackEnvelope_ClickState</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.981
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>boolean clickstate, number position, MediaTrack track, TrackEnvelope envelope, integer EnvelopePointIDX = ultraschall.GetTrackEnvelope_ClickState()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the currently clicked Envelopepoint and TrackEnvelope, as well as the current timeposition.
    
    Works only, if the mouse is above the EnvelopePoint while having it clicked!
    
    Returns false, if no envelope is clicked at
  </description>
  <retvals>
    boolean clickstate - true, an envelopepoint has been clicked; false, no envelopepoint has been clicked
    number position - the position, at which the mouse has clicked
    MediaTrack track - the track, from which the envelope and it's corresponding point is taken from
    TrackEnvelope envelope - the TrackEnvelope, in which the clicked envelope-point lies
    integer EnvelopePointIDX - the id of the clicked EnvelopePoint
  </retvals>
  <chapter_context>
    Envelope Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>envelope management, get, clicked, envelope, envelopepoint</tags>
</US_DocBloc>
--]]
  -- TODO: Has an issue, if the mousecursor drags the item, but moves above or underneath the item(if item is in first or last track).
  --       Even though the item is still clicked, it isn't returned as such.
  --       The ConfigVar uiscale supports dragging information, but the information which item has been clicked gets lost somehow
  --local B, Track, Info, TrackEnvelope, TakeEnvelope, X, Y
  
  B=reaper.SNM_GetDoubleConfigVar("uiscale", -999)
  if tostring(B)=="-1.#QNAN" then
    ultraschall.EnvelopeClickState_OldTrack=nil
    ultraschall.EnvelopeClickState_OldInfo=nil
    ultraschall.EnvelopeClickState_OldTrackEnvelope=nil
    ultraschall.EnvelopeClickState_OldTakeEnvelope=nil
    return 1
  else
    Track=ultraschall.EnvelopeClickState_OldTrack
    Info=ultraschall.EnvelopeClickState_OldInfo
    TrackEnvelope=ultraschall.EnvelopeClickState_OldTrackEnvelope
    TakeEnvelope=ultraschall.EnvelopeClickState_OldTakeEnvelope
  end
  
  if Track==nil then
    X,Y=reaper.GetMousePosition()
    Track, Info = reaper.GetTrackFromPoint(X,Y)
    ultraschall.EnvelopeClickState_OldTrack=Track
    ultraschall.EnvelopeClickState_OldInfo=Info
  end
  
  -- BUggy, til the end
  -- Ich will hier mir den alten Take auch noch merken, und danach herausfinden, welcher EnvPoint im Envelope existiert, der
  --   a) an der Zeit existiert und
  --   b) selektiert ist
  -- damit könnte ich eventuell es schaffen, die Info zurückzugeben, welcher Envelopepoint gerade beklickt wird.
  if TrackEnvelope==nil then
    reaper.BR_GetMouseCursorContext()
    TrackEnvelope = reaper.BR_GetMouseCursorContext_Envelope()
    ultraschall.EnvelopeClickState_OldTrackEnvelope=TrackEnvelope
  end
  
  if TakeEnvelope==nil then
    reaper.BR_GetMouseCursorContext()
    TakeEnvelope = reaper.BR_GetMouseCursorContext_Envelope()
    ultraschall.EnvelopeClickState_OldTakeEnvelope=TakeEnvelope
  end
  --[[
  
  
  
  reaper.BR_GetMouseCursorContext()
  local TrackEnvelope, TakeEnvelope = reaper.BR_GetMouseCursorContext_Envelope()
  
  if Track==nil then Track=ultraschall.EnvelopeClickState_OldTrack end
  if Track~=nil then ultraschall.EnvelopeClickState_OldTrack=Track end
  if TrackEnvelope~=nil then ultraschall.EnvelopeClickState_OldTrackEnvelope=TrackEnvelope end
  if TrackEnvelope==nil then TrackEnvelope=ultraschall.EnvelopeClickState_OldTrackEnvelope end
  if TakeEnvelope~=nil then ultraschall.EnvelopeClickState_OldTakeEnvelope=TakeEnvelope end
  if TakeEnvelope==nil then TakeEnvelope=ultraschall.EnvelopeClickState_OldTakeEnvelope end
  
  --]]
  --[[
  if TakeEnvelope==true or TrackEnvelope==nil then return false end
  local TimePosition=ultraschall.GetTimeByMouseXPosition(reaper.GetMousePosition())
  local EnvelopePoint=
  return true, TimePosition, Track, TrackEnvelope, EnvelopePoint
  --]]
  if TrackEnvelope==nil then TrackEnvelope=TakeEnvelope end
  return true, ultraschall.GetTimeByMouseXPosition(reaper.GetMousePosition()), Track, TrackEnvelope--, reaper.GetEnvelopePointByTime(TrackEnvelope, TimePosition)
end


function ultraschall.SetLiceCapExe(PathToLiceCapExecutable)
-- works on Mac too?
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetLiceCapExe</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.975
    SWS=2.9.7
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetLiceCapExe(string PathToLiceCapExecutable)</functioncall>
  <description>
    Sets the path and filename of the LiceCap-executable

    Note: Doesn't work on Linux, as there isn't a Linux-port of LiceCap yet.
    
    Returns false in case of error.
  </description>
  <parameters>
    string SetLiceCapExe - the LiceCap-executable with path
  </parameters>
  <retvals>
    boolean retval - false in case of error; true in case of success
  </retvals>
  <chapter_context>
    API-Helper functions
    LiceCap
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, set, licecap, executable</tags>
</US_DocBloc>
]]  
  if type(PathToLiceCapExecutable)~="string" then ultraschall.AddErrorMessage("SetLiceCapExe", "PathToLiceCapExecutable", "Must be a string", -1) return false end
  if reaper.file_exists(PathToLiceCapExecutable)==false then ultraschall.AddErrorMessage("SetLiceCapExe", "PathToLiceCapExecutable", "file not found", -2) return false end
  local A,B=reaper.BR_Win32_WritePrivateProfileString("REAPER", "licecap_path", PathToLiceCapExecutable, reaper.get_ini_file())
  return A
end

--O=ultraschall.SetLiceCapExe("c:\\Program Files (x86)\\LICEcap\\LiceCap.exe")

function ultraschall.SetupLiceCap(output_filename, title, titlems, x, y, right, bottom, fps, gifloopcount, stopafter, prefs)
-- works on Mac too?
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetupLiceCap</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.975
    SWS=2.9.7
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetupLiceCap(string output_filename, string title, integer titlems, integer x, integer y, integer right, integer bottom, integer fps, integer gifloopcount, integer stopafter, integer prefs)</functioncall>
  <description>
    Sets up an installed LiceCap-instance.
    
    To choose the right LiceCap-version, run the action 41298 - Run LICEcap (animated screen capture utility)
    
    Note: Doesn't work on Linux, as there isn't a Linux-port of LiceCap yet.
    
    Returns false in case of error.
  </description>
  <parameters>
    string output_filename - the output-file; you can choose whether it shall be a gif or an lcf by giving it the accompanying extension "mylice.gif" or "milice.lcf"; nil, keep the current outputfile
    string title - the title, which shall be shown at the beginning of the licecap; newlines will be exchanged by spaces, as LiceCap doesn't really support newlines; nil, keep the current title
    integer titlems - how long shall the title be shown, in milliseconds; nil, keep the current setting
    integer x - the x-position of the LiceCap-window in pixels; nil, keep the current setting
    integer y - the y-position of the LiceCap-window in pixels; nil, keep the current setting
    integer right - the right side-position of the LiceCap-window in pixels; nil, keep the current setting
    integer bottom - the bottom-position of the LiceCap-window in pixels; nil, keep the current setting
    integer fps - the maximum frames per seconds, the LiceCap shall have; nil, keep the current setting
    integer gifloopcount - how often shall the gif be looped?; 0, infinite looping; nil, keep the current setting
    integer stopafter - stop recording after xxx milliseconds; nil, keep the current setting
    integer prefs - the preferences-settings of LiceCap, which is a bitfield; nil, keep the current settings
                  - &1 - display in animation: title frame - checkbox
                  - &2 - Big font - checkbox
                  - &4 - display in animation: mouse button press - checkbox
                  - &8 - display in animation: elapsed time - checkbox
                  - &16 - Ctrl+Alt+P pauses recording - checkbox
                  - &32 - Use .GIF transparency for smaller files - checkbox
                  - &64 - Automatically stop after xx seconds - checkbox           
  </parameters>
  <retvals>
    boolean retval - false in case of error; true in case of success
  </retvals>
  <chapter_context>
    API-Helper functions
    LiceCap
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, licecap, setup</tags>
</US_DocBloc>
]]  
  if output_filename~=nil and type(output_filename)~="string" then ultraschall.AddErrorMessage("SetupLiceCap", "output_filename", "Must be a string", -2) return false end
  if title~=nil and type(title)~="string" then ultraschall.AddErrorMessage("SetupLiceCap", "title", "Must be a string", -3) return false end
  if titlems~=nil and math.type(titlems)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "titlems", "Must be an integer", -4) return false end
  if x~=nil and math.type(x)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "x", "Must be an integer", -5) return false end
  if y~=nil and math.type(y)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "y", "Must be an integer", -6) return false end
  if right~=nil and math.type(right)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "right", "Must be an integer", -7) return false end
  if bottom~=nil and math.type(bottom)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "bottom", "Must be an integer", -8) return false end
  if fps~=nil and math.type(fps)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "fps", "Must be an integer", -9) return false end
  if gifloopcount~=nil and math.type(gifloopcount)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "gifloopcount", "Must be an integer", -10) return false end
  if stopafter~=nil and math.type(stopafter)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "stopafter", "Must be an integer", -11) return false end
  if prefs~=nil and math.type(prefs)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "prefs", "Must be an integer", -12) return false end
  
  local CC
  local A,B=reaper.BR_Win32_GetPrivateProfileString("REAPER", "licecap_path", -1, reaper.get_ini_file())
  if B=="-1" or reaper.file_exists(B)==false then ultraschall.AddErrorMessage("SetupLiceCap", "", "LiceCap not installed, please run action \"Run LICEcap (animated screen capture utility)\" to set up LiceCap", -1) return false end
  local Path, File=ultraschall.GetPath(B)
  if reaper.file_exists(Path.."/".."licecap.ini")==false then ultraschall.AddErrorMessage("SetupLiceCap", "", "Couldn't find licecap.ini in LiceCap-path. Is LiceCap really installed?", -13) return false end
  if output_filename~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "lastfn", output_filename, Path.."/".."licecap.ini") end
  if title~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "title", string.gsub(title,"\n"," "), Path.."/".."licecap.ini") end
  if titlems~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "titlems", titlems, Path.."/".."licecap.ini") end
  
  local retval, oldwnd_r=reaper.BR_Win32_GetPrivateProfileString("licecap", "wnd_r", -1, Path.."/".."licecap.ini")  
  if x==nil then x=oldwnd_r:match("(.-) ") end
  if y==nil then y=oldwnd_r:match(".- (.-) ") end
  if right==nil then right=oldwnd_r:match(".- .- (.-) ") end
  if bottom==nil then bottom=oldwnd_r:match(".- .- .- (.*)") end
  
  CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "wnd_r", x.." "..y.." "..right.." "..bottom, Path.."/".."licecap.ini")
  if fps~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "maxfps", fps, Path.."/".."licecap.ini") end
  if gifloopcount~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "gifloopcnt", gifloopcount, Path.."/".."licecap.ini") end
  if stopafter~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "stopafter", stopafter, Path.."/".."licecap.ini") end
  if prefs~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "prefs", prefs, Path.."/".."licecap.ini") end
  
  return true
end


function ultraschall.StartLiceCap(autorun)
-- doesn't work, as I can't click the run and save-buttons
-- maybe I need to add that to the LiceCap-codebase myself...somehow
  reaper.Main_OnCommand(41298, 0)  
  O=0
  while reaper.JS_Window_Find("LICEcap v", false)==nil do
    O=O+1
    if O==1000000 then break end
  end
  local HWND=reaper.JS_Window_Find("LICEcap v", false)
  reaper.JS_WindowMessage_Post(reaper.JS_Window_FindChildByID(HWND, 1001), "WM_LBUTTONDOWN", 1,0,0,0)
  reaper.JS_WindowMessage_Post(reaper.JS_Window_FindChildByID(HWND, 1001), "WM_LBUTTONUP", 1,0,0,0)

  HWNDA0=reaper.JS_Window_Find("Choose file for recording", false)

--[[    
  O=0
  while reaper.JS_Window_Find("Choose file for recording", false)==nil do
    O=O+1
    if O==100 then break end
  end

  HWNDA=reaper.JS_Window_Find("Choose file for recording", false)
  TIT=reaper.JS_Window_GetTitle(HWNDA)
  
  for i=-1000, 10000 do
    if reaper.JS_Window_FindChildByID(HWNDA, i)~=nil then
      print_alt(i, reaper.JS_Window_GetTitle(reaper.JS_Window_FindChildByID(HWNDA, i)))
    end
  end

  print(reaper.JS_Window_GetTitle(reaper.JS_Window_FindChildByID(HWNDA, 1)))

  for i=0, 100000 do
    AA=reaper.JS_WindowMessage_Post(reaper.JS_Window_FindChildByID(HWNDA, 1), "WM_LBUTTONDOWN", 1,0,0,0)
    BB=reaper.JS_WindowMessage_Post(reaper.JS_Window_FindChildByID(HWNDA, 1), "WM_LBUTTONUP", 1,0,0,0)
  end
  
  return HWND
  --]]
  
  ultraschall.WriteValueToFile(ultraschall.API_TempPath.."/LiceCapSave.lua", [[
    dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
    P=0
    
    function main3()
      LiceCapWinPreRoll=reaper.JS_Window_Find(" [stopped]", false)
      LiceCapWinPreRoll2=reaper.JS_Window_Find("LICEcap", false)
      
      if LiceCapWinPreRoll~=nil and LiceCapWinPreRoll2~=nil and LiceCapWinPreRoll2==LiceCapWinPreRoll then
        reaper.JS_Window_Destroy(LiceCapWinPreRoll)
        print("HuiTja", reaper.JS_Window_GetTitle(LiceCapWinPreRoll))
      else
        reaper.defer(main3)
      end
    end
    
    function main2()
      print("HUI:", P)
      A=reaper.JS_Window_Find("Choose file for recording", false)
      if A~=nil and P<20 then  
        P=P+1
        print_alt(reaper.JS_WindowMessage_Send(reaper.JS_Window_FindChildByID(A, 1), "WM_LBUTTONDOWN", 1,1,1,1))
        print_alt(reaper.JS_WindowMessage_Send(reaper.JS_Window_FindChildByID(A, 1), "WM_LBUTTONUP", 1,1,1,1))
        reaper.defer(main2)
      elseif P~=0 and A==nil then
        reaper.defer(main3)
      else
        reaper.defer(main2)
      end
    end
    
    
    main2()
    ]])
    local retval, script_identifier = ultraschall.Main_OnCommandByFilename(ultraschall.API_TempPath.."/LiceCapSave.lua")
end

--ultraschall.StartLiceCap(autorun)

--ultraschall.SetupLiceCap("Hula", "Hachgotterl\nahh", 20, 1, 2, 3, 4, 123, 1, 987, 64)
--ultraschall.SetupLiceCap("Hurtz.lcf")



function ultraschall.SaveProjectAs(filename_with_path, fileformat, overwrite, create_subdirectory, copy_all_media, copy_rather_than_move)
  -- TODO:  - if a file exists already, fileformats like edl and txt may lead to showing of a overwrite-prompt of the savedialog
  --                this is mostly due Reaper adding the accompanying extension to the filename
  --                must be treated somehow or the other formats must be removed
  --        - convert mediafiles into another format(possible at all?)
  --        - check on Linux and Mac
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SaveProjectAs</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.965
    SWS=2.10.0.1
    JS=0.963
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string newfilename_with_path = ultraschall.SaveProjectAs(string filename_with_path, integer fileformat, boolean overwrite, boolean create_subdirectory, integer copy_all_media, boolean copy_rather_than_move)</functioncall>
  <description>
    Saves the current project under a new filename.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, saving was successful; false, saving wasn't succesful
    string newfilename_with_path - the new projectfilename with path, helpful if you only gave the filename
  </retvals>
  <parameters>
    string filename_with_path - the new projectfile; omitting the path saves the project in the last used folder
    integer fileformat - the fileformat, in which you want to save the project
                       - 0, REAPER Project files (*.RPP)
                       - 1, EDL TXT (Vegas) files (*.TXT)
                       - 2, EDL (Samplitude) files (*.EDL)
    boolean overwrite - true, overwrites the projectfile, if it exists; false, keep an already existing projectfile
    boolean create_subdirectory - true, create a subdirectory for the project; false, save it into the given folder
    integer copy_all_media - shall the project's mediafiles be copied or moved or left as they are?
                           - 0, don't copy/move media
                           - 1, copy the project's mediafiles into projectdirectory
                           - 2, move the project's mediafiles into projectdirectory
    boolean copy_rather_than_move - true, copy rather than move source media if not in old project media path; false, leave the files as they are
  </parameters>
  <chapter_context>
    Project-Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>project management, save, project as, edl, rpp, vegas, samplitude</tags>
</US_DocBloc>
--]]
  -- check parameters
  local A=ultraschall.GetSaveProjectAsHWND()
  if A~=nil then ultraschall.AddErrorMessage("SaveProjectAs", "", "SaveAs-dialog already open", -1) return false end
  if type(filename_with_path)~="string" then ultraschall.AddErrorMessage("SaveProjectAs", "filename_with_path", "must be a string", -2) return false end
  local A,B=reaper.BR_Win32_GetPrivateProfileString("REAPER", "lastprojuiref", "", reaper.get_ini_file())
  local C,D=ultraschall.GetPath(B)
  local E,F=ultraschall.GetPath(filename_with_path)
  
  if E=="" then filename_with_path=C..filename_with_path end
  if E~="" and ultraschall.DirectoryExists2(E)==false then 
    reaper.RecursiveCreateDirectory(E,1)
    if ultraschall.DirectoryExists2(E)==false then 
      ultraschall.AddErrorMessage("SaveProjectAs", "filename_with_path", "invalid path", -3)
      return false
    end
  end
  if type(overwrite)~="boolean" then ultraschall.AddErrorMessage("SaveProjectAs", "overwrite", "must be a boolean", -4) return false end
  if type(create_subdirectory)~="boolean" then ultraschall.AddErrorMessage("SaveProjectAs", "create_subdirectory", "must be a boolean", -5) return false end
  if math.type(copy_all_media)~="integer" then ultraschall.AddErrorMessage("SaveProjectAs", "copy_all_media", "must be an integer", -6) return false end
  if type(copy_rather_than_move)~="boolean" then ultraschall.AddErrorMessage("SaveProjectAs", "copy_rather_than_move", "must be a boolean", -7) return false end
  if math.type(fileformat)~="integer" then ultraschall.AddErrorMessage("SaveProjectAs", "fileformat", "must be an integer", -8) return false end
  if fileformat<0 or fileformat>2 then ultraschall.AddErrorMessage("SaveProjectAs", "fileformat", "must be between 0 and 2", -9) return false end
  if copy_all_media<0 or copy_all_media>2 then ultraschall.AddErrorMessage("SaveProjectAs", "copy_all_media", "must be between 0 and 2", -10) return false end
  
  -- management of, if file already exists
  if overwrite==false and reaper.file_exists(filename_with_path)==true then ultraschall.AddErrorMessage("SaveProjectAs", "filename_with_path", "file already exists", -11) return false end
  if overwrite==true and reaper.file_exists(filename_with_path)==true then os.remove(filename_with_path) end

  
  -- create the background-script, which will manage the saveas-dialog and run it
      ultraschall.WriteValueToFile(ultraschall.API_TempPath.."/saveprojectas.lua", [[
      dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
      num_params, params, caller_script_identifier = ultraschall.GetScriptParameters()

      filename_with_path=params[1]
      fileformat=tonumber(params[2])
      create_subdirectory=toboolean(params[3])
      copy_all_media=params[4]
      copy_rather_than_move=toboolean(params[5])
      
      function main2()
        --if A~=nil then print2("Hooray") end
        translation=reaper.JS_Localize("Create subdirectory for project", "DLG_185")
        PP=reaper.JS_Window_Find("Create subdirectory", false)
        A2=reaper.JS_Window_GetParent(PP)
        ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1042), create_subdirectory)
        if copy_all_media==1 then 
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1043), true)
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1044), false)
        elseif copy_all_media==2 then 
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1043), false)
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1044), true)
        else
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1043), false)
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1044), false)
        end
        ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1045), copy_rather_than_move)
        A3=reaper.JS_Window_FindChildByID(A, 0)
        A3=reaper.JS_Window_FindChildByID(A3, 0)
        A3=reaper.JS_Window_FindChildByID(A3, 0)
        A3=reaper.JS_Window_FindChildByID(A3, 0)
        reaper.JS_Window_SetTitle(A3, filename_with_path)
        reaper.JS_WindowMessage_Send(A3, "WM_LBUTTONDOWN", 1,1,1,1)
        reaper.JS_WindowMessage_Send(A3, "WM_LBUTTONUP", 1,1,1,1)
        
        XX=reaper.JS_Window_FindChild(A, "REAPER Project files (*.RPP)", true)

        reaper.JS_WindowMessage_Send(XX, "WM_LBUTTONDOWN", 1,1,1,1)
        reaper.JS_WindowMessage_Send(XX, "WM_LBUTTONUP", 1,1,1,1)
        reaper.JS_WindowMessage_Send(XX, "CB_SETCURSEL", fileformat,0,0,0)
        reaper.JS_WindowMessage_Send(XX, "WM_LBUTTONDOWN", 1,1,1,1)
        reaper.JS_WindowMessage_Send(XX, "WM_LBUTTONUP", 1,1,1,1)
        
        reaper.JS_WindowMessage_Send(reaper.JS_Window_FindChildByID(A, 1), "WM_LBUTTONDOWN", 1,1,1,1)
        reaper.JS_WindowMessage_Send(reaper.JS_Window_FindChildByID(A, 1), "WM_LBUTTONUP", 1,1,1,1)
      end

      function main1()
        A=ultraschall.GetSaveProjectAsHWND()
        if A==nil then reaper.defer(main1) else main2() end
      end
      
      --print("alive")
      
      main1()
      ]])
      local retval, script_identifier = ultraschall.Main_OnCommandByFilename(ultraschall.API_TempPath.."/saveprojectas.lua", filename_with_path, fileformat, create_subdirectory, copy_all_media, copy_rather_than_move)
    
  -- open SaveAs-dialog
  reaper.Main_SaveProject(0, true)
  -- remove background-script
  os.remove(ultraschall.API_TempPath.."/saveprojectas.lua")
  return true, filename_with_path
end

--reaper.Main_SaveProject(0, true)
--ultraschall.SaveProjectAs("Fix it all of that HUUUIII", true, 0, true)


function ultraschall.TransientDetection_Set(Sensitivity, Threshold, ZeroCrossings)
  -- needs to take care of faulty parametervalues AND of correct value-entering into an already opened
  -- 41208 - Transient detection sensitivity/threshold: Adjust... - dialog
  reaper.SNM_SetDoubleConfigVar("transientsensitivity", Sensitivity) -- 0.0 to 1.0
  reaper.SNM_SetDoubleConfigVar("transientthreshold", Threshold) -- -60 to 0
  local val=reaper.SNM_GetIntConfigVar("tabtotransflag", -999)
  if val&2==2 and ZeroCrossings==false then
    reaper.SNM_SetIntConfigVar("tabtotransflag", val-2)
  elseif val&2==0 and ZeroCrossings==true then
    reaper.SNM_SetIntConfigVar("tabtotransflag", val+2)
  end
end

--ultraschall.TransientDetection_Set(0.1, -9, false)



function ultraschall.ReadSubtitles_VTT(filename_with_path)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ReadSubtitles_VTT</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>string Kind, string Language, integer Captions_Counter, table Captions = ultraschall.ReadSubtitles_VTT(string filename_with_path)</functioncall>
  <description>
    parses a webvtt-subtitle-file and returns its contents as table
    
    returns nil in case of an error
  </description>
  <retvals>
    string Kind - the type of the webvtt-file, like: captions
    string Language - the language of the webvtt-file
    integer Captions_Counter - the number of captions in the file
    table Captions - the Captions as a table of the format:
                   -    Captions[index]["start"]= the starttime of this caption in seconds
                   -    Captions[index]["end"]= the endtime of this caption in seconds
                   -    Captions[index]["caption"]= the caption itself
  </retvals>
  <parameters>
    string filename_with_path - the filename with path of the webvtt-file
  </parameters>
  <chapter_context>
    File Management
    Read Files
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>filemanagement, read, file, webvtt, subtitle, import</tags>
</US_DocBloc>
--]]
  if type(filename_with_path)~="string" then ultraschall.AddErrorMessage("ReadSubtitles_VTT", "filename_with_path", "must be a string", -1) return end
  if reaper.file_exists(filename_with_path)=="false" then ultraschall.AddErrorMessage("ReadSubtitles_VTT", "filename_with_path", "must be a string", -2) return end
  local A, Type, Offset, Kind, Language, Subs, Subs_Counter, i
  Subs={}
  Subs_Counter=0
  A=ultraschall.ReadFullFile(filename_with_path)
  Type, Offset=A:match("(.-)\n()")
  if Type~="WEBVTT" then ultraschall.AddErrorMessage("ReadSubtitles_VTT", "filename_with_path", "not a webvtt-file", -3) return end
  A=A:sub(Offset,-1)
  Kind, Offset=A:match(".-: (.-)\n()")
  A=A:sub(Offset,-1)
  Language, Offset=A:match(".-: (.-)\n()")
  A=A:sub(Offset,-1)
  
  i=0
  for k in string.gmatch(A, "(.-)\n") do
    i=i+1
    if i==2 then 
      Subs_Counter=Subs_Counter+1
      Subs[Subs_Counter]={} 
      Subs[Subs_Counter]["start"], Subs[Subs_Counter]["end"] = k:match("(.-) --> (.*)")
      if Subs[Subs_Counter]["start"]==nil or Subs[Subs_Counter]["end"]==nil then ultraschall.AddErrorMessage("ReadSubtitles_VTT", "filename_with_path", "can't parse the file; probably invalid", -3) return end
      Subs[Subs_Counter]["start"]=reaper.parse_timestr(Subs[Subs_Counter]["start"])
      Subs[Subs_Counter]["end"]=reaper.parse_timestr(Subs[Subs_Counter]["end"])
    elseif i==3 then 
      Subs[Subs_Counter]["caption"]=k
      if Subs[Subs_Counter]["caption"]==nil then ultraschall.AddErrorMessage("ReadSubtitles_VTT", "filename_with_path", "can't parse the file; probably invalid", -4) return end
    end
    if i==3 then i=0 end
  end
  
  
  return Kind, Language, Subs_Counter, Subs
end


--A,B,C,D,E=ultraschall.ReadSubtitles_VTT("c:\\test.vtt")

function ultraschall.BatchConvertFiles(filelist, RenderTable, BWFStart, PadStart, PadEnd, FXChain)
-- Todo:
-- Check on Mac and Linux
-- Check all parameters for correct typings
-- Test FXChain-capability
  local BatchConvertData=""
  local ExeFile, filename, path
  if FXChain==nil then FXChain="" end
  if BWFStart==true then BWFStart="    USERCSTART 1\n" else BWFStart="" end
  if PadStart~=nil  then PadStart="    PAD_START "..PadStart.."\n" else PadStart="" end
  if PadEnd~=nil  then PadEnd="    PAD_END "..PadEnd.."\n" else PadEnd="" end
  local i=1
  while filelist[i]~=nil do
    path, filename = ultraschall.GetPath(filelist[i])
    BatchConvertData=BatchConvertData..filelist[i].."\t"..filename.."\n"
    i=i+1
  end
  BatchConvertData=BatchConvertData..[[
<CONFIG
]]..FXChain..[[
  <OUTFMT 
    ]]      ..RenderTable["RenderString"]..[[
    
    SRATE ]]..RenderTable["SampleRate"]..[[
    
    NCH ]]..RenderTable["Channels"]..[[
    
    RSMODE ]]..RenderTable["RenderResample"]..[[
    
    DITHER ]]..RenderTable["Dither"]..[[
    
]]..BWFStart..[[
]]..PadStart..[[
]]..PadEnd..[[
    OUTPATH ]]..RenderTable["RenderFile"]..[[
    
    OUTPATTERN ']]..RenderTable["RenderPattern"]..[['
  >
>
]]

  ultraschall.WriteValueToFile(ultraschall.API_TempPath.."/filelist.txt", BatchConvertData)
  if ultraschall.IsOS_Windows()==true then
    ExeFile=reaper.GetExePath().."\\reaper.exe"
    AAAA, AAAAAA=reaper.ExecProcess(ExeFile.." -batchconvert "..string.gsub(ultraschall.API_TempPath, "/", "\\").."\\filelist.txt", -1)
    print3(ExeFile.." -batchconvert "..string.gsub(ultraschall.API_TempPath, "/", "\\").."\\filelist.txt")

  elseif ultraschall.IsOS_Mac()==true then
    print2("Must be checked on Mac!!!!")
    ExeFile=reaper.GetExePath().."\\reaper"
    AAAA, AAAAAA=reaper.ExecProcess(ExeFile.." -batchconvert "..string.gsub(ultraschall.API_TempPath, "\\\\", "/").."/filelist.txt", -1)
  else
    print2("Must be checked on Linux!!!!")
    ExeFile=reaper.GetExePath().."\\reaper"
    AAAA, AAAAAA=reaper.ExecProcess(ExeFile.." -batchconvert "..string.gsub(ultraschall.API_TempPath, "\\\\", "/").."/filelist.txt", -1)
  end
end


-- These seem to work:

function ultraschall.WebInterface_GetInstalledInterfaces()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>WebInterface_GetInstalledInterfaces</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer reapers_count_of_webinterface, array reapers_webinterface_filenames_with_path, array reapers_webinterface_titles, integer users_count_of_webinterface, array users_webinterface_filenames_with_path, array users_webinterface_titles = ultraschall.WebInterface_GetInstalledInterfaces()</functioncall>
  <description>
    Returns the currently installed web-interface-pages.
    
    Will return Reaper's default ones(resources-folder/Plugins/reaper_www_root/) as well as your customized ones(resources-folder/reaper_www_root/)
  </description>
  <retvals>
    integer reapers_count_of_webinterface - the number of factory-default webinterfaces, installed by Reaper
    array reapers_webinterface_filenames_with_path - the filenames with path of the webinterfaces(can be .htm or .html)
    array reapers_webinterface_titles - the titles of the webinterfaces, as shown in the titlebar of the browser
    integer users_count_of_webinterface - the number of user-customized webinterfaces
    array users_webinterface_filenames_with_path - the filenames with path of the webinterfaces(can be .htm or .html)
    array users_webinterface_titles - the titles of the webinterfaces, as shown in the titlebar of the browser
  </retvals>
  <chapter_context>
    Web Interface
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_WebInterface_Module.lua</source_document>
  <tags>web interface, get, all, installed, webrc, filename, title</tags>
</US_DocBloc>
]]  
  local filecount, files = ultraschall.GetAllFilenamesInPath(reaper.GetResourcePath().."/Plugins/reaper_www_root")
  local files_WEBRC_names={}
  for i=filecount, 1, -1 do
    if files[i]:sub(-5,-1):match("%.htm")==nil then
      table.remove(files, i)
      filecount=filecount-1
    end
  end
  for i=1, filecount do
    local A=ultraschall.ReadFullFile(files[i])
    local start, ende=A:lower():match("<title>().-()</title>")
    files_WEBRC_names[i]=A:sub(start, ende-1)
  end

  local filecount2, files2 = ultraschall.GetAllFilenamesInPath(reaper.GetResourcePath().."/reaper_www_root")
  local files_WEBRC_names2={}
  for i=filecount2, 1, -1 do
    if files2[i]:sub(-5,-1):match("%.htm")==nil then
      table.remove(files2, i)
      filecount2=filecount2-1
    end
  end
  for i=1, filecount2 do
    local A=ultraschall.ReadFullFile(files2[i])
    local start, ende=A:lower():match("<title>().-()</title>")
    files_WEBRC_names2[i]=A:sub(start, ende-1)
  end
  
  return filecount, files, files_WEBRC_names, filecount2, files2, files_WEBRC_names2
end


function ultraschall.MediaItems_Outtakes_AddSelectedItems(TargetProject)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>MediaItems_Outtakes_AddSelectedItems</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer number_of_items = ultraschall.MediaItems_Outtakes_AddSelectedItems(ReaProject TargetProject)</functioncall>
  <description>
    Adds selected MediaItems to the outtakes-vault of a given project.
    
    returns -1 in case of an error
  </description>
  <retvals>
    integer number_of_items - the number of items, added to the outtakes-vault
  </retvals>
  <parameters>
    ReaProject TargetProject - the project, into whose outtakes-vault the selected items shall be added to; 0 or nil, for the current project
  </parameters>
  <chapter_context>
    MediaItem Management
    Outtakes Vault
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_MediaItem_Module.lua</source_document>
  <tags>mediaitem, add, selected, items, outtakes, vault</tags>
</US_DocBloc>
]]  
  if TargetProject~=0 and TargetProject~=nil and ultraschall.type(TargetProject)~="ReaProject" then ultraschall.AddErrorMessage("MediaItems_Outtakes_AddSelectedItems", "TargetProject", "The target-project must be a valid ReaProject or 0/nil for current project", -1) return -1 end
  if TargetProject==nil then TargetProject=0 end
  local count, MediaItemArray, MediaItemStateChunkArray = ultraschall.GetAllSelectedMediaItems()
  local temp, Value = reaper.GetProjExtState(TargetProject, "Ultraschall_Outtakes", "Count")
  if math.tointeger(Value)==nil then Value=0 else Value=math.tointeger(Value) end
  for i=1, count do
    Value=Value+1
    reaper.SetProjExtState(TargetProject, "Ultraschall_Outtakes", "Outtake_"..Value, MediaItemStateChunkArray[i])
  end
  reaper.SetProjExtState(TargetProject, "Ultraschall_Outtakes", "Count", Value)
  return Value
end

--A=ultraschall.MediaItems_Outtakes_AddSelectedItems(0)

function ultraschall.MediaItems_Outtakes_GetAllItems(TargetProject, EachItemsAfterAnother)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>MediaItems_Outtakes_GetAllItems</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer number_of_items, array MediaItemStateChunkArray = ultraschall.MediaItems_Outtakes_GetAllItems(ReaProject TargetProject, optional boolean EachItemsAfterAnother)</functioncall>
  <description>
    Returns all MediaItems stored in the outtakes-vault of a given project.
    
    returns -1 in case of an error
  </description>
  <retvals>
    integer number_of_items - the number of items, added to the outtakes-vault
    array MediaItemStateChunkArray - all the MediaItemStateChunks of the stored MediaItems in the outtakes vault
  </retvals>
  <parameters>
    ReaProject TargetProject - the project, into whose outtakes-vault the selected items shall be added to; 0 or nil, for the current project
    optional boolean EachItemsAfterAnother - position the MediaItems one after the next, so if you import them, they would be stored one after another
                                           - true, position the startposition of the MediaItems one after another
                                           - false, keep old startpositions
  </parameters>
  <chapter_context>
    MediaItem Management
    Outtakes Vault
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_MediaItem_Module.lua</source_document>
  <tags>mediaitem, get, all, items, outtakes, vault</tags>
</US_DocBloc>
]]  
  if TargetProject~=0 and TargetProject~=nil and ultraschall.type(TargetProject)~="ReaProject" then ultraschall.AddErrorMessage("MediaItems_Outtakes_GetAllItems", "TargetProject", "The target-project must be a valid ReaProject or 0/nil for current project", -1) return -1 end
  if TargetProject==nil then TargetProject=0 end
  local temp, Value = reaper.GetProjExtState(TargetProject, "Ultraschall_Outtakes", "Count")
  if math.tointeger(Value)==nil then Value=0 else Value=math.tointeger(Value) end
  local temp
  local MediaItemStateChunkArray={}
  local TempPosition=0
  local Length=0
  for i=1, Value do
    temp, MediaItemStateChunkArray[i]=reaper.GetProjExtState(TargetProject, "Ultraschall_Outtakes", "Outtake_"..i)
    if EachItemsAfterAnother==true then
      Length   = ultraschall.GetItemLength(nil, MediaItemStateChunkArray[i])
      MediaItemStateChunkArray[i] = ultraschall.SetItemPosition(nil, TempPosition, MediaItemStateChunkArray[i])
      TempPosition=TempPosition+Length
    end
  end
  return Value, MediaItemStateChunkArray
end

--B,C=ultraschall.MediaItems_Outtakes_GetAllItems(TargetProject, false)


function ultraschall.MediaItems_Outtakes_InsertAllItems(TargetProject, tracknumber, Startposition)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>MediaItems_Outtakes_InsertAllItems</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval, integer number_of_items, array MediaItemArray = ultraschall.MediaItems_Outtakes_InsertAllItems(ReaProject TargetProject, integer tracknumber, number Startposition)</functioncall>
  <description>
    Inserts all MediaItems from the outtakes-vault into a certain track, with one item after the other, back to back.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, adding was successful; false, adding was unsuccessful
    integer number_of_items - the number of added items
    array MediaItemArray - all the inserted MediaItems
  </retvals>
  <parameters>
    ReaProject TargetProject - the project, into whose outtakes-vault the selected items shall be added to; 0 or nil, for the current project
    integer tracknumber - the tracknumber, into which to insert all items from the outtakes-vault
    number Startposition - the position, at which to insert the first MediaItem; nil, startposition=0
  </parameters>
  <chapter_context>
    MediaItem Management
    Outtakes Vault
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_MediaItem_Module.lua</source_document>
  <tags>mediaitem, insert, all, items, outtakes, vault</tags>
</US_DocBloc>
]]  
  if TargetProject~=0 and TargetProject~=nil and ultraschall.type(TargetProject)~="ReaProject" then ultraschall.AddErrorMessage("MediaItems_Outtakes_InsertAllItems", "TargetProject", "The target-project must be a valid ReaProject or 0/nil for current project", -1) return false end
  if TargetProject==nil then TargetProject=0 end
    
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("MediaItems_Outtakes_InsertAllItems", "tracknumber", "must be an integer", -2) return false end
  if tracknumber<0 or reaper.CountTracks(0)<tracknumber then ultraschall.AddErrorMessage("MediaItems_Outtakes_InsertAllItems", "tracknumber", "no such track", -3) return false end

  if Startposition~=nil and type(Startposition)~="number" then ultraschall.AddErrorMessage("MediaItems_Outtakes_InsertAllItems", "Startposition", "must be a number or nil for default-startposition 0", -4) return false end
  if Startposition==nil then Startposition=0 end
  
  local Count, MediaItemStateChunk = ultraschall.MediaItems_Outtakes_GetAllItems(TargetProject, true)
  local MediaItems={}
  local Position=Startposition
  local retval, startposition, endposition
  for i=1, Count do
    retval, MediaItems[i], startposition, endposition = ultraschall.InsertMediaItem_MediaItemStateChunk(Position, MediaItemStateChunk[i], reaper.GetTrack(0,tracknumber-1))
    Position=endposition
  end  
  return true, Count, MediaItems
end

function ultraschall.IsTimeSelectionActive()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsTimeSelectionActive</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval, optional number start_of_timeselection, optional number end_of_timeselection = ultraschall.IsTimeSelectionActive(optional ReaProject Project)</functioncall>
  <description>
    Returns, if there's a time-selection and its start and endposition in a project.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, there is a time-selection; false, there isn't a time-selection
	optional number start_of_timeselection - start of the time-selection
	optional number end_of_timeselection - end of the time-selection
  </retvals>
  <parameters>
    optional ReaProject Project - the project, whose time-selection-state you want to know; 0 or nil, the current project
  </parameters>
  <chapter_context>
    Project-Management
	Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_MediaItem_Module.lua</source_document>
  <tags>projectmanagement, time selection, get</tags>
</US_DocBloc>
]] 
  if Project~=0 and Project~=nil and ultraschall.type(Project)~="ReaProject" then
    ultraschall.AddErrorMessage("IsTimeSelectionActive", "Project", "must be a valid ReaProject, 0 or nil(for current)", -1)
    return false
  end
  local Start, Endof = reaper.GetSet_LoopTimeRange2(Project, false, false, 0, 0, false)
  if Start==Endof then return false end
  return true, Start, Endof
end

function ultraschall.GetAllTrackEnvelopes(include_mastertrack)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllTrackEnvelopes</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.05
    Lua=5.3
  </requires>
  <functioncall>integer number_of_trackenvelopes, table TrackEnvelopes_Table = ultraschall.GetAllTrackEnvelopes()</functioncall>
  <description>
    Returns all TrackEnvelopes of all tracks from the current project as a handy table
    
    The format of the table is as follows:
        TrackEnvelopes[trackenvelope_idx]["Track"] - the idx of the track; 0, for mastertrack, 1, for first track, etc
        TrackEnvelopes[trackenvelope_idx]["EnvelopeObject"] - the TrackEnvelope-object
        TrackEnvelopes[trackenvelope_idx]["EnvelopeName"] - the name of of TrackEnvelopeObject
  </description>
  <retvals>
    integer number_of_trackenvelopes - the number of TrackEnvelopes found in the current project
    table TrackEnvelopes_Table - all found TrackEnvelopes as a handy table(see description for details)
  </retvals>
  <chapter_context>
    Envelope Management
    Envelopes
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Envelope_Module.lua</source_document>
  <tags>envelope management, get all, track envelopes</tags>
</US_DocBloc>
--]]
  local TrackEnvelopesTable={}
  local TrackEnvelopes_Count=0
  local _temp
  
  if include_mastertrack==true then
    local Track=reaper.GetMasterTrack(0)
    for a=0, reaper.CountTrackEnvelopes(Track)-1 do
      TrackEnvelopes_Count=TrackEnvelopes_Count+1
      TrackEnvelopesTable[TrackEnvelopes_Count]={}
      TrackEnvelopesTable[TrackEnvelopes_Count]["Track"]=0
      TrackEnvelopesTable[TrackEnvelopes_Count]["EnvelopeObject"]=reaper.GetTrackEnvelope(Track, a)
      _temp, TrackEnvelopesTable[TrackEnvelopes_Count]["EnvelopeName"]=reaper.GetEnvelopeName(TrackEnvelopesTable[TrackEnvelopes_Count]["EnvelopeObject"])
    end
  end
  
  for i=0, reaper.CountTracks(0)-1 do
    local Track=reaper.GetTrack(0, i)
    for a=0, reaper.CountTrackEnvelopes(Track)-1 do
      TrackEnvelopes_Count=TrackEnvelopes_Count+1
      TrackEnvelopesTable[TrackEnvelopes_Count]={}
      TrackEnvelopesTable[TrackEnvelopes_Count]["Track"]=i+1
      TrackEnvelopesTable[TrackEnvelopes_Count]["EnvelopeObject"]=reaper.GetTrackEnvelope(Track, a)
      _temp, TrackEnvelopesTable[TrackEnvelopes_Count]["EnvelopeName"]=reaper.GetEnvelopeName(TrackEnvelopesTable[TrackEnvelopes_Count]["EnvelopeObject"])
    end    
  end
  return TrackEnvelopes_Count, TrackEnvelopesTable
end

--A,B=ultraschall.GetAllTrackEnvelopes(true)

function ultraschall.GetAllTakeEnvelopes()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllTakeEnvelopes</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.05
    Lua=5.3
  </requires>
  <functioncall>integer number_of_takeenvelopes, table TakeEnvelopes_Table = ultraschall.GetAllTakeEnvelopes()</functioncall>
  <description>
    Returns all TakeEnvelopes of all MediaItems from the current project as a handy table
    
    The format of the table is as follows:
        TakeEnvelopes[takeenvelope_idx]["MediaItem"] - the idx of the MediaItem
        TakeEnvelopes[takeenvelope_idx]["MediaItem_Take"] - the idx of the trake of the MediaItem
        TakeEnvelopes[takeenvelope_idx]["MediaItem_Take_Name"] - the name of the MediaItek_Take
        TakeEnvelopes[takeenvelope_idx]["EnvelopeObject"] - the TakeEnvelopeObject in question
        TakeEnvelopes[takeenvelope_idx]["EnvelopeName"] - the name of of TakeEnvelopeObject
  </description>
  <retvals>
    integer number_of_takeenvelopes - the number of TakeEnvelopes found in the current project
    table TakeEnvelopes_Table - all found TakeEnvelopes as a handy table(see description for details)
  </retvals>
  <chapter_context>
    Envelope Management
    Envelopes
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Envelope_Module.lua</source_document>
  <tags>envelope management, get all, take envelopes</tags>
</US_DocBloc>
--]]
  local ItemEnvelopesTable={}
  local ItemEnvelopes_Count=0
  local _temp
    
  for i=0, reaper.CountMediaItems(0)-1 do
    local MediaItem=reaper.GetMediaItem(0, i)
    for x=0, reaper.CountTakes(MediaItem)-1 do
      local MediaItem_Take=reaper.GetMediaItemTake(MediaItem, x)
      for a=0, reaper.CountTakeEnvelopes(MediaItem_Take)-1 do
        ItemEnvelopes_Count=ItemEnvelopes_Count+1
        ItemEnvelopesTable[ItemEnvelopes_Count]={}
        ItemEnvelopesTable[ItemEnvelopes_Count]["MediaItem"]=i+1
        ItemEnvelopesTable[ItemEnvelopes_Count]["MediaItemTake"]=i+1
        ItemEnvelopesTable[ItemEnvelopes_Count]["MediaItemTake_Name"]=reaper.GetTakeName(MediaItem_Take)
        ItemEnvelopesTable[ItemEnvelopes_Count]["EnvelopeObject"]=reaper.GetTakeEnvelope(MediaItem_Take, a)
        _temp, ItemEnvelopesTable[ItemEnvelopes_Count]["EnvelopeName"]=reaper.GetEnvelopeName(ItemEnvelopesTable[ItemEnvelopes_Count]["EnvelopeObject"])
      end    
    end
  end
  return ItemEnvelopes_Count, ItemEnvelopesTable
end

--A,B=ultraschall.GetAllItemEnvelopes()

function ultraschall.AutomationItems_GetAll()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AutomationItems_GetAll</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.05
    Lua=5.3
  </requires>
  <functioncall>integer number_of_automationitems, table AutomationItems_Table = ultraschall.AutomationItems_GetAll()</functioncall>
  <description>
    Returns all automation items from the current project as a handy table
    
    The format of the table is as follows:
        AutomationItems[automationitem_idx]["Track"] - the track, in which the automation item is located
        AutomationItems[automationitem_idx]["EnvelopeObject"] - the envelope, in which the automationitem is located
        AutomationItems[automationitem_idx]["EnvelopeName"] - the name of the envelope
        AutomationItems[automationitem_idx]["AutomationItem_Index"] - the index of the automation with EnvelopeObject
        AutomationItems[automationitem_idx]["AutomationItem_PoolID"] - the pool-Id of the automation item
        AutomationItems[automationitem_idx]["AutomationItem_Position"] - the position of the automation item in seconds
        AutomationItems[automationitem_idx]["AutomationItem_Length"] - the length of the automation item in seconds
        AutomationItems[automationitem_idx]["AutomationItem_Startoffset"] - the startoffset of the automation item in seconds
        AutomationItems[automationitem_idx]["AutomationItem_Playrate"]- the playrate of the automation item
        AutomationItems[automationitem_idx]["AutomationItem_Baseline"]- the baseline of the automation item, between 0 and 1
        AutomationItems[automationitem_idx]["AutomationItem_Amplitude"]- the amplitude of the automation item, between -1 and +1
        AutomationItems[automationitem_idx]["AutomationItem_LoopSource"]- the loopsource-state of the automation item; 0, unlooped; 1, looped
        AutomationItems[automationitem_idx]["AutomationItem_UISelect"]- the selection-state of the automation item; 0, unselected; nonzero, selected
        AutomationItems[automationitem_idx]["AutomationItem_Pool_QuarteNoteLength"]- the quarternote-length
  </description>
  <retvals>
    integer number_of_automationitems - the number of automation-items found in the current project
    table AutomationItems_Table - all found automation-items as a handy table(see description for details)
  </retvals>
  <chapter_context>
    Automation Items
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_AutomationItems_Module.lua</source_document>
  <tags>automation items, get all</tags>
</US_DocBloc>
--]]
  local Envelopes_Count, Envelopes=ultraschall.GetAllTrackEnvelopes(true)
  local AutomationItems={}
  local AutomationItems_Count=0
  for i=1, Envelopes_Count do
    for a=0, reaper.CountAutomationItems(Envelopes[i]["EnvelopeObject"])-1 do
       AutomationItems_Count=AutomationItems_Count+1
       AutomationItems[AutomationItems_Count]={}
       AutomationItems[AutomationItems_Count]["Track"]=Envelopes[i]["Track"]
       AutomationItems[AutomationItems_Count]["EnvelopeName"]=Envelopes[i]["EnvelopeName"]
       AutomationItems[AutomationItems_Count]["EnvelopeObject"]=Envelopes[i]["EnvelopeObject"]
       AutomationItems[AutomationItems_Count]["AutomationItem_Index"]=a
       AutomationItems[AutomationItems_Count]["AutomationItem_PoolID"]=reaper.GetSetAutomationItemInfo(Envelopes[i]["EnvelopeObject"], a, "D_POOL_ID", 0, false)
       AutomationItems[AutomationItems_Count]["AutomationItem_Position"]=reaper.GetSetAutomationItemInfo(Envelopes[i]["EnvelopeObject"], a, "D_POSITION", 0, false)
       AutomationItems[AutomationItems_Count]["AutomationItem_Length"]=reaper.GetSetAutomationItemInfo(Envelopes[i]["EnvelopeObject"], a, "D_LENGTH", 0, false)
       AutomationItems[AutomationItems_Count]["AutomationItem_Startoffset"]=reaper.GetSetAutomationItemInfo(Envelopes[i]["EnvelopeObject"], a, "D_STARTOFFS", 0, false)
       AutomationItems[AutomationItems_Count]["AutomationItem_Playrate"]=reaper.GetSetAutomationItemInfo(Envelopes[i]["EnvelopeObject"], a, "D_PLAYRATE", 0, false)
       AutomationItems[AutomationItems_Count]["AutomationItem_Baseline"]=reaper.GetSetAutomationItemInfo(Envelopes[i]["EnvelopeObject"], a, "D_BASELINE", 0, false)
       AutomationItems[AutomationItems_Count]["AutomationItem_Amplitude"]=reaper.GetSetAutomationItemInfo(Envelopes[i]["EnvelopeObject"], a, "D_AMPLITUDE", 0, false)
       AutomationItems[AutomationItems_Count]["AutomationItem_LoopSource"]=reaper.GetSetAutomationItemInfo(Envelopes[i]["EnvelopeObject"], a, "D_LOOPSRC", 0, false)
       AutomationItems[AutomationItems_Count]["AutomationItem_UISelect"]=reaper.GetSetAutomationItemInfo(Envelopes[i]["EnvelopeObject"], a, "D_UISEL", 0, false)
       AutomationItems[AutomationItems_Count]["AutomationItem_Pool_QuarteNoteLength"]=reaper.GetSetAutomationItemInfo(Envelopes[i]["EnvelopeObject"], a, "D_POOL_QNLEN", 0, false)
    end
  end
  return AutomationItems_Count, AutomationItems
end

--A,B=ultraschall.AutomationItems_GetAll()

function ultraschall.AutomationItem_Delete(TrackEnvelope, automationitem_idx, preserve_points)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AutomationItem_Delete</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.05
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.AutomationItem_Delete(TrackEnvelope env, integer automationitem_idx, optional boolean preservepoints)</functioncall>
  <description>
    Deletes an Automation-Item, optionally preserves the points who are added to the underlying envelope.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, deleting was successful; false, deleting was not successful
  </retvals>
  <parameters>
    TrackEnvelope env - the TrackEnvelope, in which the automation-item to be deleted is located
    integer automationitem_idx - the automationitem that shall be deleted; 0, for the first one
    optional boolean preservepoints - true, keepthe envelopepoints and add them to the underlying envelope; nil or false, just delete the AutomationItem
  </parameters>
  <chapter_context>
    Automation Items
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_AutomationItems_Module.lua</source_document>
  <tags>automation items, delete, preserve points</tags>
</US_DocBloc>
--]]
  if ultraschall.type(TrackEnvelope)~="TrackEnvelope" then ultraschall.AddErrorMessage("AutomationItem_Delete", "TrackEnvelope", "must be a valid TrackEnvelope", -1) return false end
  if math.type(automationitem_idx)~="integer" then ultraschall.AddErrorMessage("AutomationItem_Delete", "automationitem_idx", "must be an integer", -2) return false end
  if automationitem_idx<0 then ultraschall.AddErrorMessage("AutomationItem_Delete", "automationitem_idx", "must be bigger or equal 0", -3) return false end
  if reaper.CountAutomationItems(TrackEnvelope)-1<automationitem_idx then ultraschall.AddErrorMessage("AutomationItem_Delete", "automationitem_idx", "no such automationitem in TrackEnvelope", -4) return false end
  local AutomationItems_Count, AutomationItems=ultraschall.GetAllAutomationItems()
  local found
  
  reaper.Undo_BeginBlock()
  for i=AutomationItems_Count, 1, -1 do
    if TrackEnvelope~=AutomationItems[i]["EnvelopeObject"] or
       automationitem_idx~=AutomationItems[i]["AutomationItem_Index"] then
       reaper.GetSetAutomationItemInfo(AutomationItems[i]["EnvelopeObject"], AutomationItems[i]["AutomationItem_Index"], "D_UISEL", 0, true)
    else
      reaper.GetSetAutomationItemInfo(AutomationItems[i]["EnvelopeObject"], AutomationItems[i]["AutomationItem_Index"], "D_UISEL", 1, true)
      AutomationItems_Count=AutomationItems_Count-1
      table.remove(AutomationItems,i)
      found=true
    end
  end
  if preserve_points==true then
    reaper.Main_OnCommand(42088,0)
  else
    reaper.Main_OnCommand(42086,0)
  end
  for i=AutomationItems_Count, 1, -1 do
    reaper.GetSetAutomationItemInfo(AutomationItems[i]["EnvelopeObject"], AutomationItems[i]["AutomationItem_Index"], "D_UISEL", AutomationItems[i]["AutomationItem_UISelect"], true)
  end
  
  reaper.Undo_EndBlock("Deleted Automation Item", -1)
  -- following line necessary? Don't think so.
  if found~=true then ultraschall.AddErrorMessage("AutomationItem_Delete", "automationitem_idx", "no such automation-item found", -5) return false end
  return true
end


function ultraschall.SetTrack_LastTouched(tracknumber)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrack_LastTouched</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.05
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetTrack_LastTouched(integer track)</functioncall>
  <description>
    Sets a track to be last touched track.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was not successful
  </retvals>
  <parameters>
    integer track - the track, which you want to set as last touched track
  </parameters>
  <chapter_context>
    Track Management
	Set Track States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_TrackManagement_Module.lua</source_document>
  <tags>track management, set, last touched track</tags>
</US_DocBloc>
--]]
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrack_LastTouched", "tracknumber", "must be an integer", -1) return false end
  local track = reaper.GetTrack(0,tracknumber-1)
  if track==nil then ultraschall.AddErrorMessage("SetTrack_LastTouched", "tracknumber", "no such track", -2) return false end
  local trackstring = ultraschall.CreateTrackString_SelectedTracks()
  reaper.SetOnlyTrackSelected(track)
  local retval = ultraschall.SetTracksSelected(trackstring, true)
  return true
end

function ultraschall.EscapeMagicCharacters_String(sourcestring)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>EscapeMagicCharacters_String</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.05
    Lua=5.3
  </requires>
  <functioncall>string escaped_string = ultraschall.EscapeMagicCharacters_String(string sourcestring)</functioncall>
  <description>
    Escapes the magic characters(needed for pattern matching), so the string can be fed as is into string.match-functions.
	That way, characters like . or - or * etc do not trigger pattern-matching behavior but are used as regular . or - or * etc.
    
    returns nil in case of an error
  </description>
  <retvals>
    string escaped_string - the string with all magic characters escaped
  </retvals>
  <parameters>
	string sourcestring - the string, whose magic characters you want to escape for future use
  </parameters>
  <chapter_context>
    API-Helper functions
	Data Manipulation
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, escape, magic characters</tags>
</US_DocBloc>
--]]  
   if type(sourcestring)~="string" then ultraschall.AddErrorMessage("EscapeMagicCharacters_String", "sourcestring", "must be a string", -1) return nil end
   return (sourcestring:gsub('%%', '%%%%')
            :gsub('^%^', '%%^')
            :gsub('%$$', '%%$')
            :gsub('%(', '%%(')
            :gsub('%)', '%%)')
            :gsub('%.', '%%.')
            :gsub('%[', '%%[')
            :gsub('%]', '%%]')
            :gsub('%*', '%%*')
            :gsub('%+', '%%+')
            :gsub('%-', '%%-')
            :gsub('%?', '%%?'))
end

function ultraschall.GetTrackByTrackName(trackname, case_sensitive, escaped_strict)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackByTrackName</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.05
    Lua=5.3
  </requires>
  <functioncall>integer number_of_found_tracks, table found_tracks, table found_tracknames = ultraschall.GetTrackByTrackName(string trackname, boolean case_sensitive, integer escaped_strict)</functioncall>
  <description>
    returns all tracks with a certain name.
	
	You can set case-sensitivity, whether pattern-matchin is possible and whether the name shall be used strictly.
	For instance, if you want to look for a track named exactly "JaM.-Enlightened" you set case_sensitive=false and escaped_strict=2. That way, tracks names "JaM.*Enlightened" will be ignored.
	
	returns -1 in case of an error
  </description>
  <retvals>
    integer number_of_found_tracks - the number of found tracks
	table found_tracks - the found tracks as table
	table found_tracknames - the found tracknames
  </retvals>
  <parameters>
    string trackname - the trackname to look for
	boolean case_sensitive - true, take care of case-sensitivity; false, don't take case-sensitivity into account
	integer escaped_strict - 0, use trackname as matching-pattern, will find all tracknames following the pattern(Ja.-m -> Jam, Jam123Police, JaABBAm)
						   - 1, escape trackname off all magic characters, will find all tracknames with the escaped pattern in it (Ja.-m -> Ja.-m, Jam.-boree)
						   - 2, strict, will only find tracks with the exact trackname-string in their name(Jam -> Jam)
  </parameters>			
  <chapter_context>
    Track Management
	Set Track States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_TrackManagement_Module.lua</source_document>
  <tags>track management, set, last touched track</tags>
</US_DocBloc>
--]]
  if type(trackname)~="string" then ultraschall.AddErrorMessage("GetTrackByTrackName", "trackname", "must be a string", -1) return -1 end
  if type(case_sensitive)~="boolean" then ultraschall.AddErrorMessage("GetTrackByTrackName", "case_sensitive", "must be a boolean", -2) return -1 end
  if math.type(escaped_strict)~="integer" then ultraschall.AddErrorMessage("GetTrackByTrackName", "escaped_strict", "must be an integer", -3) return -1 end
  if escaped_strict<0 or escaped_strict>2 then ultraschall.AddErrorMessage("GetTrackByTrackName", "escaped_strict", "must be between 0 and 2", -4) return -1 end
  local trackcount=0
  local Tracks={}
  local TrackNames={}
  local retval, buf, found_track, track, trackname2
  if case_sensitive==false then trackname=trackname:lower() end
  if escaped_strict>0 then
    trackname2=ultraschall.EscapeMagicCharacters_String(trackname)
  else
    ultraschall.IsValidMatchingPattern(trackname)
    if ultraschall.IsValidMatchingPattern(trackname)==false then ultraschall.AddErrorMessage("GetTrackByTrackName", "trackname", "must be valid matching pattern", -5) return -1 end
    trackname2=trackname
  end

  for i=0, reaper.CountTracks()-1 do
    track=reaper.GetTrack(0,i)
    retval, buf = reaper.GetTrackName(track)
    found_track=buf:match(trackname2)

    if found_track~=nil then
      if escaped_strict==2 then
        if buf==trackname then 
          trackcount=trackcount+1 TrackNames[trackcount]=buf Tracks[trackcount]=track 
        end
      else
        trackcount=trackcount+1 TrackNames[trackcount]=buf Tracks[trackcount]=track
      end
    end
  end
  return trackcount, Tracks, TrackNames
end

function ultraschall.IsTimeSigmarkerAtPosition(position, position_mode)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsTimeSigmarkerAtPosition</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.05
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.IsTimeSigmarkerAtPosition(number position, optional integer position_mode)</functioncall>
  <description>
    returns, if at position is a time-signature marker
	
	returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, marker found; false, marker not found
  </retvals>
  <parameters>
    number position - the position to check, whether there's a timesignature marker
	optional integer position_mode - nil or 0, use position in seconds; 1, use position in measures
  </parameters>			
  <chapter_context>
    Markers
	Time Signature Markers
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_TrackManagement_Module.lua</source_document>
  <tags>marker management, check, at position, timesig, marker/tags>
</US_DocBloc>
--]]
  if type(position)~="number" then ultraschall.AddErrorMessage("IsTimeSigmarkerAtPosition", "position", "must be a number", -1) return false end
  if position_mode~=nil and math.type(position_mode)~="integer" then ultraschall.AddErrorMessage("IsTimeSigmarkerAtPosition", "position_mode", "must be an integer or nil", -2) return false end
  if position_mode==nil then position_mode=0 end
  if position_mode~=0 and position_mode~=1 then ultraschall.AddErrorMessage("IsTimeSigmarkerAtPosition", "position", "must be either nil, 0 or 1", -3) return false end
  for i=1, reaper.CountTempoTimeSigMarkers(0) do
    local retval, timepos, measurepos, beatpos, bpm, timesig_num, timesig_denom, lineartempo = reaper.GetTempoTimeSigMarker(0, i)
    if position_mode==0 and ultraschall.FloatCompare(position, timepos, 0.00000000000000000001)==true then return true end
    if position_mode==1 and measurepos==position then return true end
  end
  return false
end

function ultraschall.CollapseTrackHeight(tracknumber)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CollapseTrackHeight</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.05
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.CollapseTrackHeight(integer track)</functioncall>
  <description>
    Collapses the height of a track to the minimum height as set by the theme
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, collapsing was successful; false, collapsing was not successful
  </retvals>
  <parameters>
    integer track - the track, which you want to collapse in height
  </parameters>
  <chapter_context>
    Track Management
	Set Track States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_TrackManagement_Module.lua</source_document>
  <tags>track management, set, collapse, trackheight</tags>
</US_DocBloc>
--]]
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("CollapseTrackHeight", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<0 then ultraschall.AddErrorMessage("CollapseTrackHeight", "tracknumber", "must be bigger 0 for master track for 1 and higher for regular tracks", -2) return false end
  local track
  if tracknumber==0 then track=reaper.GetMasterTrack(0) else
    track=reaper.GetTrack(0,tracknumber-1)
  end
  if track==nil then ultraschall.AddErrorMessage("CollapseTrackHeight", "tracknumber", "no such track", -5) return false end
  local lockstate = reaper.GetMediaTrackInfo_Value(track, "B_HEIGHTLOCK", 0) -- get current lockstate
  reaper.SetMediaTrackInfo_Value(track, "B_HEIGHTLOCK", 0) -- unlock track
  reaper.SetMediaTrackInfo_Value(track, "I_HEIGHTOVERRIDE", 1) -- set new height
  reaper.TrackList_AdjustWindows(false) -- update TCP
  reaper.SetMediaTrackInfo_Value(track, "B_HEIGHTLOCK", lockstate) -- restore lockstate of track
  return true
end

--A=ultraschall.CollapseTrack(1)

function ultraschall.SetTrack_Trackheight_Force(tracknumber, trackheight)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrack_Trackheight_Force</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.05
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetTrack_Trackheight_Force(integer track, integer trackheight)</functioncall>
  <description>
    Sets the trackheight of a track. Forces trackheight beyond limits set by the theme.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, collapsing was successful; false, collapsing was not successful
  </retvals>
  <parameters>
    integer track - the track, which you want to set the height of
	integer trackheigt - the trackheight in pixels, 0 and higher
  </parameters>
  <chapter_context>
    Track Management
	Set Track States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_TrackManagement_Module.lua</source_document>
  <tags>track management, set, trackheight, force</tags>
</US_DocBloc>
--]]
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrack_Trackheight_Force", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<0 then ultraschall.AddErrorMessage("SetTrack_Trackheight_Force", "tracknumber", "must be bigger 0 for master track for 1 and higher for regular tracks", -2) return false end
  if math.type(trackheight)~="integer" then ultraschall.AddErrorMessage("SetTrack_Trackheight_Force", "trackheight", "must be an integer", -3) return false end
  if trackheight<0 then ultraschall.AddErrorMessage("SetTrack_Trackheight_Force", "trackheight", "must be bigger or equal 0", -4) return false end
  local track
  if tracknumber==0 then track=reaper.GetMasterTrack(0) else
    track=reaper.GetTrack(0,tracknumber-1)
  end
  if track==nil then ultraschall.AddErrorMessage("SetTrack_Trackheight_Force", "tracknumber", "no such track", -5) return false end
  local lockstate = reaper.GetMediaTrackInfo_Value(track, "B_HEIGHTLOCK", 0) -- get current lockstate
  reaper.SetMediaTrackInfo_Value(track, "B_HEIGHTLOCK", 1) -- unlock track
  reaper.SetMediaTrackInfo_Value(track, "I_HEIGHTOVERRIDE", trackheight) -- set new height
  reaper.TrackList_AdjustWindows(false) -- update TCP
  reaper.SetMediaTrackInfo_Value(track, "B_HEIGHTLOCK", lockstate) -- restore lockstate of track
  return true
end

--A=ultraschall.SetTrack_Trackheight_Force(1, 2147483586)

function ultraschall.ActionsList_GetSelectedActions()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ActionsList_GetSelectedActions</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.05
	SWS=2.10.0.1
	JS=0.963
    Lua=5.3
  </requires>
  <functioncall>integer num_found_actions, integer sectionID, string sectionName, table selected_actions, table CmdIDs, table ToggleStates = ultraschall.ActionsList_GetSelectedActions()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
	returns the selected entries from the actionlist, when opened.
	
	The order of the tables of found actions, ActionCommandIDs and ToggleStates is the same in all of the three tables.
	They also reflect the order of userselection in the ActionList itself from top to bottom of the ActionList.
	
	returns -1 in case of an error
  </description>
  <retvals>
	integer num_found_actions - the number of selected actions; -1, if not opened
	integer sectionID - the id of the section, from which the selected actions are from
	string sectionName - the name of the selected section
	table selected_actions - the texts of the found actions as a handy table
	table CmdIDs - the ActionCommandIDs of the found actions as a handy table; all of them are strings, even the numbers, but can be converted using Reaper's own function reaper.NamedCommandLookup
	table ToggleStates - the current toggle-states of the selected actions; 1, on; 0, off; -1, no such toggle state available
  </retvals>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, get, action, actionlist, sections, selected, toggle states, commandids, actioncommandid</tags>
</US_DocBloc>
--]]
  local hWnd_action = ultraschall.GetActionsHWND()
  if hWnd_action==nil then ultraschall.AddErrorMessage("ActionsList_GetSelectedActions", "", "Action-List-Dialog not opened", -1) return -1 end
  local hWnd_LV = reaper.JS_Window_FindChildByID(hWnd_action, 1323)
  local combo = reaper.JS_Window_FindChildByID(hWnd_action, 1317)
  local sectionName = reaper.JS_Window_GetTitle(combo,"") -- save item text to table
  local sectionID =  reaper.JS_WindowMessage_Send( combo, "CB_GETCURSEL", 0, 0, 0, 0 )

  -- get selected count & selected indexes
  local sel_count, sel_indexes = reaper.JS_ListView_ListAllSelItems(hWnd_LV)

  -- get the selected action-texts
  local selected_actions = {}
  local i = 0
  for index in string.gmatch(sel_indexes, '[^,]+') do
    i = i + 1
    local desc = reaper.JS_ListView_GetItemText(hWnd_LV, tonumber(index), 1)--:gsub(".+: ", "", 1)
    selected_actions[i] = desc
  end
  
  -- find the cmd-ids
  local temptable={}
  for a=1, i do
    temptable[selected_actions[a]]=selected_actions[a]
  end
  
  -- get command-ids of the found texts
  for aaa=0, 66000 do
    local Retval, Name = reaper.CF_EnumerateActions(sectionID, aaa, "")
    if temptable[Name]~=nil then    
      temptable[Name]=Retval
    end
    if Retval==0 then break end    
  end

  -- get ActionCommandIDs and toggle-states of the found actions
  local CmdIDs={}
  local ToggleStates={}
  for a=1, i do
    CmdIDs[a]=reaper.ReverseNamedCommandLookup(temptable[selected_actions[a]])
    if CmdIDs[a]==nil then CmdIDs[a]=tostring(temptable[selected_actions[a]]) end
    ToggleStates[a]=reaper.GetToggleCommandStateEx(sectionID, temptable[selected_actions[a]])
  end

  return i, sectionID, sectionName, selected_actions, CmdIDs, ToggleStates
end

--A,B,C,D,E,F,G = ultraschall.ActionsList_GetSelectedActions()

function ultraschall.GFX_GetDropFile()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GFX_GetDropFile</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.05
    Lua=5.3
  </requires>
  <functioncall>boolean changed, integer num_dropped_files, array dropped_files, integer drop_mouseposition_x, integer drop_mouseposition_y = ultraschall.GFX_GetDropFile()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
	returns the files drag'n'dropped into a gfx-window, including the mouseposition within the gfx-window, where the files have been dropped.
	
	if changed==true, then the filelist is updated, otherwise this function returns the last dropped files again.
	Note: when the same files will be dropped, changed==true will also be dropped with only the mouse-position updated.
	That way, dropping the same files in differen places is recognised by this function.
	
	Call repeatedly in every defer-cycle to get the latest files and coordinates.
	
	Important: Don't use Reaper's own gfx.dropfile while using this, as this could intefere with this function.
  </description>
  <retvals>
	boolean changed - true, new files have been dropped since last time calling this function; false, no new files have been dropped
	integer num_dropped_files - the number of dropped files; -1, if no files have beend dropped at all
	array dropped_files - an array with all filenames+path of the dropped files
	integer drop_mouseposition_x - the x-mouseposition within the gfx-window, where the files have been dropped; -10000, if no files have been dropped yet
	integer drop_mouseposition_y - the y-mouseposition within the gfx-window, where the files have been dropped; -10000, if no files have been dropped yet
  </retvals>
  <chapter_context>
    Window Handling
  </chapter_context>
  <target_document>US_Api_GFX</target_document>
  <source_document>ultraschall_gfx_engine.lua</source_document>
  <tags>gfx</tags>
</US_DocBloc>
--]]
  if ultraschall.GetDropFile_List==nil then
    ultraschall.GetDropFile_List={}
    ultraschall.GetDropFile_List[1]=""
    ultraschall.GetDropFile_Filecount=-1
    ultraschall.GetDropFile_MouseX=-10000
    ultraschall.GetDropFile_MouseY=-10000
  end
  local A=1
  local filecount=0
  local changed
  local FileList={}
  while A~=0 do
    A,B=gfx.getdropfile(filecount)
    filecount=filecount+1
    FileList[filecount]=B
  end
  if filecount==1 then
    changed=false
  else
    changed=true
  end
  if changed==true then
    ultraschall.GetDropFile_List=FileList
    ultraschall.GetDropFile_Filecount=filecount
    ultraschall.GetDropFile_MouseX=gfx.mouse_x
    ultraschall.GetDropFile_MouseY=gfx.mouse_y
  end
  gfx.getdropfile(-1)
  return changed, ultraschall.GetDropFile_Filecount-1, ultraschall.GetDropFile_List, ultraschall.GetDropFile_MouseX, ultraschall.GetDropFile_MouseY
end

function ultraschall.Benchmark_GetStartTime()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Benchmark_GetStartTime</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.975
    Lua=5.3
  </requires>
  <functioncall>number starttime = ultraschall.Benchmark_GetStartTime()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
	This function is for benchmarking parts of your code.
	It returns the starttime of the last benchmark-start.
	
	returns nil, if no benchmark has been made yet.
	
	Use [Benchmark_MeasureTime](#Benchmark_MeasureTime) to start/reset a new benchmark-measureing.
  </description>
  <retvals>
    number starttime - the starttime of the currently running benchmark
  </retvals>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, get, start, benchmark, time</tags>
</US_DocBloc>
--]]
  return ultraschall.Benchmark_StartTime_Time
end

function ultraschall.Benchmark_MeasureTime(timeformat, reset)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Benchmark_MeasureTime</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.975
    Lua=5.3
  </requires>
  <functioncall>number elapsed_time, string elapsed_time_string, string measure_evaluation = ultraschall.Benchmark_MeasureTime(optional integer time_mode, optional boolean reset)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
	This function is for benchmarking parts of your code.
	It returns the passed time, since last time calling this function.
	
	Use [Benchmark_GetStartTime](#Benchmark_GetStartTime) to start the benchmark.
  </description>
  <retvals>
    number elapsed_time - the elapsed time in seconds
	string elapsed_time_string - the elapsed time, formatted by parameter time_mode
	string measure_evaluation - an evaluation of time, mostly starting with &lt; or &gt; an a number of +
							  - 0, no time passed
							  - >, for elapsed times greater than 1, the following + will show the number of integer digits; example: 12.927 -> ">++"
							  - <, for elapsed times smaller than 1, the following + will show the number of zeros+1 in the fraction, until the first non-zero-digit appears; example: 0.0063 -> "<+++"
  </retvals>
  <parameters>
	optional integer time_mode - the formatting of elapsed_time_string
							   - 0=time
							   - 1=measures.beats + time
							   - 2=measures.beats
							   - 3=seconds
							   - 4=samples
							   - 5=h:m:s:f
	optional boolean reset - true, resets the starttime(for new measuring); false, keeps current measure-starttime(for continuing measuring)
  </parameters>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, get, start, benchmark, time</tags>
</US_DocBloc>
--]]
  local passed_time=reaper.time_precise()
  if ultraschall.Benchmark_StartTime_Time==nil then ultraschall.Benchmark_StartTime_Time=passed_time end
  if timeformat~=nil and math.type(timeformat)~="integer" then ultraschall.AddErrorMessage("Benchmark_MeasureTime", "timeformat", "must be an integer", -2) return end
  if timeformat~=nil and (timeformat<0 or timeformat>7)then ultraschall.AddErrorMessage("Benchmark_MeasureTime", "timeformat", "must be between 0 and 7 or nil", -3) return end
  passed_time=passed_time-ultraschall.Benchmark_StartTime_Time
  if reset==true or reset==nil then ultraschall.Benchmark_StartTime_Time=reaper.time_precise() end
  local valid=""
  local passed_time_string=""
  if passed_time==0 then
  valid="0"
  elseif passed_time>1 then 
    valid=tostring(passed_time):match("(.-)%..*")
    if valid==nil then valid=tostring(passed_time) end
    valid=">"..string.gsub(valid, "%d", "+")
  elseif passed_time<0.00016333148232661 then
    valid="<++++"
  else
    valid=tostring(passed_time):match(".-%.(0*)")
    if valid==nil then valid="0" end
    valid="<"..string.gsub(valid, "0", "+").."+"
  end
  if timeformat==0 or timeformat==nil then
	passed_time_string=tostring(passed_time) 
  else
    passed_time_string=reaper.format_timestr_len(passed_time, "", 0, timeformat-1)
  end
  return passed_time, passed_time_string, valid
end

ultraschall.ShowLastErrorMessage()
