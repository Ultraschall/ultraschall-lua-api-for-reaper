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

function ultraschall.GetProjectReWireClient(projectfilename_with_path)
--To Do
-- ProjectSettings->Advanced->Rewire Client Settings
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


function ultraschall.GetTrackEnvelope_ClickStates()
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


function ultraschall.GetTakeEnvelopeUnderMouseCursor()
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>GetTakeEnvelopeUnderMouseCursor</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>TakeEnvelope env, MediaItem_Take take, number projectposition = ultraschall.GetTakeEnvelopeUnderMouseCursor()</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      returns the take-envelope underneath the mouse
    </description>
    <retvals>
      TakeEnvelope env - the take-envelope found unterneath the mouse; nil, if none has been found
      MediaItem_Take take - the take from which the take-envelope is
      number projectposition - the project-position
    </retvals>
    <chapter_context>
      Envelope Management
      Envelopes
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_Envelope_Module.lua</source_document>
    <tags>envelope management, get, take, envelope, mouse position</tags>
  </US_DocBloc>
  --]]
  -- todo: retval for position within the take
  
  local Awindow, Asegment, Adetails = reaper.BR_GetMouseCursorContext()
  local retval, takeEnvelope = reaper.BR_GetMouseCursorContext_Envelope()
  if takeEnvelope==true then 
    return retval, reaper.BR_GetMouseCursorContext_Position(), reaper.BR_GetMouseCursorContext_Item()
  else
    return nil, reaper.BR_GetMouseCursorContext_Position()
  end
end


function ultraschall.VideoProcessor_SetText(text, font, fontsize, x, y, r, g, b, a)
  -- needs modules/additionals/VideoProcessor-Presets.RPL to be imported somehow
  local OldName=ultraschall.Gmem_GetCurrentAttachedName()
  local fontnameoffset=50
  local textoffset=font:len()+20
  reaper.gmem_attach("Ultraschall_VideoProcessor_Settings")
  reaper.gmem_write(0, 0)           -- type: 0, Text
  reaper.gmem_write(1, text:len())  -- length of text
  reaper.gmem_write(2, textoffset)  -- at which gmem-index does the text start
  reaper.gmem_write(3, font:len())  -- the length of the fontname
  reaper.gmem_write(4, fontnameoffset) -- at which gmem-index does the fontname start
  reaper.gmem_write(5, fontsize)    -- the size of the font 0-1
  reaper.gmem_write(6, 0)           -- is the update-signal; 0, update text and fontname; 1, already updated
  reaper.gmem_write(7, x)           -- x-position of the text
  reaper.gmem_write(8, y)           -- y-position of the text
  reaper.gmem_write(9,  r)          -- red color of the text
  reaper.gmem_write(10, g)          -- green color of the text
  reaper.gmem_write(11, b)          -- blue color of the text
  reaper.gmem_write(12, a)          -- alpha of the text
  for i=1, text:len() do
    Byte=string.byte(text:sub(i,i))
    reaper.gmem_write(i+textoffset, Byte)
  end
  
  for i=1, font:len() do
    Byte=string.byte(font:sub(i,i))
    reaper.gmem_write(i+fontnameoffset, Byte)
  end
  
  if OldName~=nil then
    reaper.gmem_attach(OldName)
  end
end

function ultraschall.VideoProcessor_SetTextPosition(x,y)
-- needs modules/additionals/VideoProcessor-Presets.RPL to be imported somehow
  local OldName=ultraschall.Gmem_GetCurrentAttachedName()
  reaper.gmem_attach("Ultraschall_VideoProcessor_Settings")
  reaper.gmem_write(7, x)
  reaper.gmem_write(8, y)
  if OldName~=nil then
    reaper.gmem_attach(OldName)
  end
end

function ultraschall.VideoProcessor_SetFontColor(r,g,b,a)
-- needs modules/additionals/VideoProcessor-Presets.RPL to be imported somehow
  local OldName=ultraschall.Gmem_GetCurrentAttachedName()
  reaper.gmem_attach("Ultraschall_VideoProcessor_Settings")
  
  reaper.gmem_write(9,  r)
  reaper.gmem_write(10, g)  
  reaper.gmem_write(11, b)
  reaper.gmem_write(12, a)
  if OldName~=nil then
    reaper.gmem_attach(OldName)
  end  
end

function ultraschall.VideoProcessor_SetFontSize(fontsize)
-- needs modules/additionals/VideoProcessor-Presets.RPL to be imported somehow
  local OldName=ultraschall.Gmem_GetCurrentAttachedName()
  reaper.gmem_attach("Ultraschall_VideoProcessor_Settings")
  reaper.gmem_write(5, fontsize)
  
  if OldName~=nil then
    reaper.gmem_attach(OldName)
  end
end

function ultraschall.InputFX_GetInstrument()
  -- undone, no idea how to do it. Maybe parsing reaper-hwoutfx.ini or checking fx-names from InputFX_GetFXName against being instruments?
end


function ultraschall.InputFX_SetNamedConfigParm(fxindex, parmname, value)
  -- dunno, if this function works at all with monitoring fx...
  return reaper.TrackFX_SetNamedConfigParm(reaper.GetMasterTrack(0), 0x1000000+fxindex-1, parmname, value)
end


-- These seem to work working:
function ultraschall.DeleteParmLearn2_FXStateChunk(FXStateChunk, fxid, parmidx)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DeleteParmLearn2_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string alteredFXStateChunk = ultraschall.DeleteParmLearn2_FXStateChunk(string FXStateChunk, integer fxid, integer parmidx)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Deletes a ParmLearn-entry from an FXStateChunk, by parameter index.
    
    Unlike [DeleteParmLearn\_FXStateChunk](#DeleteParmLearn_FXStateChunk), this indexes the parameters not the already existing parmlearns.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, if deletion was successful; false, if the function couldn't delete anything
    string alteredFXStateChunk - the altered FXStateChunk
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, which you want to delete a ParmLearn from
    integer fxid - the id of the fx, which holds the to-delete-ParmLearn-entry; beginning with 1
    integer parmidx - the index of the parameter, whose parmlearn you want to delete; beginning with 1
  </parameters>
  <chapter_context>
    FX-Management
    Parameter Mapping Learn
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, parm, learn, delete, parm, learn, midi, osc, binding</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("DeleteParmLearn2_FXStateChunk", "FXStateChunk", "no valid FXStateChunk", -1) return false end
  if math.type(fxid)~="integer" then ultraschall.AddErrorMessage("DeleteParmLearn2_FXStateChunk", "fxid", "must be an integer", -2) return false end
  if math.type(parmidx)~="integer" then ultraschall.AddErrorMessage("DeleteParmLearn2_FXStateChunk", "parmidx", "must be an integer", -3) return false end
    
  local UseFX, startoffset, endoffset = ultraschall.GetFXFromFXStateChunk(FXStateChunk, fxid)
  if UseFX==nil then ultraschall.AddErrorMessage("DeleteParmLearn2_FXStateChunk", "fxid", "no such fx", -4) return false end
  
  local ParmLearnEntry=UseFX:match("%s-PARMLEARN "..(parmidx-1).."[:]*%a* .-\n")
  if ParmLearnEntry==nil then ultraschall.AddErrorMessage("DeleteParmLearn2_FXStateChunk", "parmidx", "no such parameter", -5) return false end
    
  local UseFX2=string.gsub(UseFX, ParmLearnEntry, "\n")

  return true, FXStateChunk:sub(1, startoffset)..UseFX2:sub(2,-2)..FXStateChunk:sub(endoffset-1, -1)
end

-- Ultraschall 4.2.002




function ultraschall.OpenReaperFunctionDoc(functionname)
  if type(functionname)~="string" then ultraschall.AddErrorMessage("OpenReaperFunctionDoc", "functionname", "must be a string", -1) return false end
  if reaper[functionname]==nil then ultraschall.AddErrorMessage("OpenReaperFunctionDoc", "functionname", "no such function", -2) return false end
  local A=[[
  <!DOCTYPE html>
  <html>
    <head>
      <meta http-equiv="refresh" content="0; url=]]..ultraschall.Api_Path.."/Documentation/Reaper_Api_Documentation.html#"..functionname..[[">
    </head>
    <body>
    </body>
  </html>
  ]]
  ultraschall.WriteValueToFile(ultraschall.API_TempPath.."/start.html", A)
  ultraschall.OpenURL(ultraschall.API_TempPath.."/start.html")
  return true
end


--ultraschall.OpenReaperFunctionDoc("MB")

function ultraschall.OpenUltraschallFunctionDoc(functionname)
  if type(functionname)~="string" then ultraschall.AddErrorMessage("OpenUltraschallFunctionDoc", "functionname", "must be a string", -1) return false end
  if ultraschall[functionname]==nil then ultraschall.AddErrorMessage("OpenUltraschallFunctionDoc", "functionname", "no such function", -2) return false end
  local A=[[
  <!DOCTYPE html>
  <html>
    <head>
      <meta http-equiv="refresh" content="0; url=]]..ultraschall.Api_Path.."/Documentation/US_Api_Functions.html#"..functionname..[[">
    </head>
    <body>
    </body>
  </html>
  ]]
  ultraschall.WriteValueToFile(ultraschall.API_TempPath.."/start.html", A)
  ultraschall.OpenURL(ultraschall.API_TempPath.."/start.html")
  return true
end

--ultraschall.OpenUltraschallFunctionDoc("RenderProject")




function ultraschall.CalculateLoudness(mode, timeselection, trackstring)
-- TODO!!
-- multiple tracks, items can be returned by GetSetProjectInfo_String, when items/tracks are selected
-- function currently only supports one, the first one. Please boost it up a little....
--
-- Check trackstring-management.
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CalculateLoudness</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.30
    Lua=5.3
  </requires>
  <functioncall>string filename, string peak, string clip, string rms, string lrange, string lufs_i = ultraschall.CalculateLoudness(integer mode, boolean timeselection)</functioncall>
  <description>
    Calculates the loudness of items and tracks or returns the loudness of last render/dry-render.
    
    Returns nil in case of an error
  </description>
  <retvals>
    string filename - the filename, that would be rendered
    string peak - the peak of the rendered element
    string clip - the clipping of the rendered element
    string rms - the rms of the rendered element
    string lrange - the lrange of the rendered element
    string lufs_i - the lufs-i of the rendered element
  </retvals>
  <parameters>
    integer mode - -1, return loudness-stats of the last render/dry render
                 - 0, calculate loudness-stats of selected media items
                 - 1, calculate loudness-stats of master track
                 - 2, calculate loudness-stats of selected tracks
    boolean timeselection - shall loudness calculation only be within time-selection?
                          - only with mode 1 and 2; if no time-selection is given, use entire track
                          - false, calculate loudness within the entire tracks;
                          - true, calculate loudness-stats within time-selection
  </parameters>
  <chapter_context>
    Rendering Projects
    Loudness Calculation
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Render_Module.lua</source_document>
  <tags>projectfiles, compare, rendertable</tags>
</US_DocBloc>
]]
  -- FILE-management can be improved for dry-rendering, probably...
  if math.type(mode)~="integer" then ultraschall.AddErrorMessage("CalculateLoudness", "mode", "must be an integer", -1) return end
  if type(timeselection)~="boolean" then ultraschall.AddErrorMessage("CalculateLoudness", "timeselection", "must be a boolean", -2) return end
  
  if     mode==-1 then mode=""
  elseif mode==0 then mode=42437
  elseif mode==1 and timeselection==false then mode=42440
  elseif mode==1 and timeselection==true  then mode=42441
  elseif mode==2 and timeselection==false then mode=42438
  elseif mode==2 and timeselection==true  then mode=42439
  end  
  
  local oldtrackstring  
  if mode==2 then
    oldtrackstring = ultraschall.CreateTrackString_SelectedTracks()
    ultraschall.SetTracksSelected(trackstring, true)
  end
  local retval, RenderStats=reaper.GetSetProjectInfo_String(0, "RENDER_STATS", mode, false)
  RenderStats=RenderStats..";"

  local FILE, PEAK, CLIP, RMSI, LRA, LUFSI
  FILE=RenderStats:match("FILE:(.-);")
  PEAK=RenderStats:match("PEAK:(.-);")
  if PEAK==nil then PEAK="-inf" end
  CLIP=RenderStats:match("CLIP:(.-);")
  if CLIP==nil then CLIP="0" end
  RMSI=RenderStats:match("RMSI:(.-);")
  if RMSI==nil then RMSI="-inf" end
  LRA=RenderStats:match("LRA:(.-);")
  if LRA==nil then LRA="-inf" end
  LUFSI=RenderStats:match("LUFSI:(.-);")
  if LUFSI==nil then LUFSI="-inf" end

  if mode==2 then
    ultraschall.SetTracksSelected(oldtrackstring, true)
  end

  return FILE, PEAK, CLIP, RMSI, LRA, LUFSI
end


--A={ultraschall.CalculateLoudness(0, true)}

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

-- Need to be documented, but are finished

function ultraschall.GetRenderTargetFiles()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetRenderTargetFiles</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.33
    Lua=5.3
  </requires>
  <functioncall>string path, integer file_count, array filenames_with_path = ultraschall.GetRenderTargetFiles()</functioncall>
  <description>
    Will return the render output-path and all filenames with path that would be rendered, if rendering would run right now
    
    returns nil in case of error
  </description>
  <retvals>
    string path - the output-path for the rendered files
    integer file_count - the number of files that would be rendered
    array filenames_with_path - the filenames with path of the files that would be rendered
  </retvals>
  <chapter_context>
    Rendering Projects
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Render_Module.lua</source_document>
  <tags>render, get, output filenames, target path</tags>
</US_DocBloc>
--]]
  retval, Targets = reaper.GetSetProjectInfo_String(0, "RENDER_TARGETS", "", false)
  if retval==false then return end
  local Temp=Targets:sub(1,2)
  local Count, Files = ultraschall.CSV2IndividualLinesAsArray(Targets, ";"..Temp)
  for i=2, Count do
    Files[i]=Temp..Files[i]
  end
  
  local Path=Files[1]:match("(.*[\\/])")
  
  return Path, Count, Files
end

function ultraschall.Docs_GetReaperApiFunction_Description(functionname)
  if type(functionname)~="string" then ultraschall.AddErrorMessage("Docs_GetReaperApiFunction_Description", "functionname", "must be a string", -1) return nil end
  if ultraschall.Docs_ReaperApiDocBlocs==nil then
    ultraschall.Docs_ReaperApiDocBlocs=ultraschall.ReadFullFile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api/DocsSourceFiles/reaper-apidocs.USDocML")
    ultraschall.Docs_ReaperApiDocBlocs_Count, ultraschall.Docs_ReaperApiDocBlocs = ultraschall.Docs_GetAllUSDocBlocsFromString(ultraschall.Docs_ReaperApiDocBlocs)
    ultraschall.Docs_ReaperApiDocBlocs_Titles={}
    for i=1, ultraschall.Docs_ReaperApiDocBlocs_Count do 
      ultraschall.Docs_ReaperApiDocBlocs_Titles[i]= ultraschall.Docs_GetUSDocBloc_Title(ultraschall.Docs_ReaperApiDocBlocs[i], 1)
    end
  end

  local found=-1
  for i=1, ultraschall.Docs_ReaperApiDocBlocs_Count do
    if ultraschall.Docs_ReaperApiDocBlocs_Titles[i]:lower()==functionname:lower() then
      found=i
    end
  end
  if found==-1 then ultraschall.AddErrorMessage("Docs_GetReaperApiFunction_Description", "functionname", "function not found", -2) return end

  local Description, markup_type, markup_version

  Description, markup_type, markup_version  = ultraschall.Docs_GetUSDocBloc_Description(ultraschall.Docs_ReaperApiDocBlocs[found], true, 1)
  if Description==nil then ultraschall.AddErrorMessage("Docs_GetReaperApiFunction_Description", "functionname", "no description existing", -3) return end

  Description = string.gsub(Description, "&lt;", "<")
  Description = string.gsub(Description, "&gt;", ">")
  Description = string.gsub(Description, "&amp;", "&")
  return Description, markup_type, markup_version
end



function ultraschall.Docs_GetReaperApiFunction_Call(functionname, proglang)
  if type(functionname)~="string" then ultraschall.AddErrorMessage("Docs_GetReaperApiFunction_Call", "functionname", "must be a string", -1) return nil end
  if math.type(proglang)~="integer" then ultraschall.AddErrorMessage("Docs_GetReaperApiFunction_Call", "proglang", "must be an integer", -2) return nil end
  if proglang<1 or proglang>4 then ultraschall.AddErrorMessage("Docs_GetReaperApiFunction_Call", "proglang", "no such programming language available", -3) return nil end
  if ultraschall.Docs_ReaperApiDocBlocs==nil then
    ultraschall.Docs_ReaperApiDocBlocs=ultraschall.ReadFullFile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api/DocsSourceFiles/reaper-apidocs.USDocML")
    ultraschall.Docs_ReaperApiDocBlocs_Count, ultraschall.Docs_ReaperApiDocBlocs = ultraschall.Docs_GetAllUSDocBlocsFromString(ultraschall.Docs_ReaperApiDocBlocs)
    ultraschall.Docs_ReaperApiDocBlocs_Titles={}
    for i=1, ultraschall.Docs_ReaperApiDocBlocs_Count do 
      ultraschall.Docs_ReaperApiDocBlocs_Titles[i]= ultraschall.Docs_GetUSDocBloc_Title(ultraschall.Docs_ReaperApiDocBlocs[i], 1)
    end
  end

  local found=-1
  for i=1, ultraschall.Docs_ReaperApiDocBlocs_Count do
    if ultraschall.Docs_ReaperApiDocBlocs_Titles[i]:lower()==functionname:lower() then
      found=i
    end
  end
  if found==-1 then ultraschall.AddErrorMessage("Docs_GetReaperApiFunction_Call", "functionname", "function not found", -4) return end

  local Call, prog_lang
  Call, prog_lang  = ultraschall.Docs_GetUSDocBloc_Functioncall(ultraschall.Docs_ReaperApiDocBlocs[found], proglang)
  if Call==nil then ultraschall.AddErrorMessage("Docs_GetReaperApiFunction_Call", "functionname", "no such programming language available", -5) return end
  Call = string.gsub(Call, "&lt;", "<")
  Call = string.gsub(Call, "&gt;", ">")
  Call = string.gsub(Call, "&amp;", "&")
  return Call, prog_lang
end

function ultraschall.Docs_LoadReaperApiDocBlocs()
  ultraschall.Docs_ReaperApiDocBlocs=ultraschall.ReadFullFile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api/DocsSourceFiles/reaper-apidocs.USDocML")
  ultraschall.Docs_ReaperApiDocBlocs_Count, ultraschall.Docs_ReaperApiDocBlocs = ultraschall.Docs_GetAllUSDocBlocsFromString(ultraschall.Docs_ReaperApiDocBlocs)
  ultraschall.Docs_ReaperApiDocBlocs_Titles={}
  for i=1, ultraschall.Docs_ReaperApiDocBlocs_Count do 
    ultraschall.Docs_ReaperApiDocBlocs_Titles[i]= ultraschall.Docs_GetUSDocBloc_Title(ultraschall.Docs_ReaperApiDocBlocs[i], 1)
  end
end

function ultraschall.Docs_FindReaperApiFunction_Pattern(pattern, case_sensitive, include_descriptions, include_retvalnames, include_paramnames, include_tags)
  -- unfinished:
  -- include_retvalnames, include_paramnames not yet implemented
  -- probably needs RetVal/Param-function that returns datatypes and name independently from each other
  -- which also means: all functions must return values with a proper, descriptive name(or at least retval)
  --                   or this breaks -> Doc-CleanUp-Work...Yeah!!! (looking forward to it, actually)
  if desc_startoffset==nil then desc_startoffset=-10 end
  if desc_endoffset==nil then desc_endoffset=-10 end
  if case_sensitive==false then pattern=pattern:lower() end
  local Found_count=0
  local Found={}
  local FoundInformation={}
  if include_descriptions==false then FoundInformation=nil end
  local found_this_time=false
  for i=1, ultraschall.Docs_ReaperApiDocBlocs_Count do
    -- search for titles
    local Title=ultraschall.Docs_ReaperApiDocBlocs_Titles[i]
    if case_sensitive==false then Title=Title:lower() end
    if Title:match(pattern) then
      found_this_time=true
    end
    
    -- search within tags
    if found_this_time==false and include_tags==true then
      local count, tags = ultraschall.Docs_GetUSDocBloc_Tags(ultraschall.Docs_ReaperApiDocBlocs[i], 1)
      for i=1, count do
        if case_sensitive==false then tags[i]=tags[i]:lower() end
        if tags[i]:match(pattern) then found_this_time=true break end
      end
    end
    
    -- search within descriptions
    local _temp, Offset1, Offset2
    if found_this_time==false and include_descriptions==true then
      local Description, markup_type = ultraschall.Docs_GetUSDocBloc_Description(ultraschall.Docs_ReaperApiDocBlocs[i], true, 1)
      Description = string.gsub(Description, "&lt;", "<")
      Description = string.gsub(Description, "&gt;", ">")
      Description = string.gsub(Description, "&amp;", "&")
      if case_sensitive==false then Description=Description:lower() end
      if Description:match(pattern) then
        found_this_time=true
      end
      Offset1, _temp, Offset2=Description:match("()("..pattern..")()")
      if Offset1~=nil then
        if Offset1-desc_startoffset<0 then Offset1=0 else Offset1=Offset1-desc_startoffset end
        FoundInformation[Found_count+1]={}
        FoundInformation[Found_count+1][1]=Description:sub(Offset1, Offset2+desc_endoffset-1)
        FoundInformation[Found_count+1][2]=Offset1 -- startoffset of found pattern, so this part can be highlighted
                                                   -- when displaying somewhere later
      end
    end
    
    if found_this_time==true then
      Found_count=Found_count+1
      Found[Found_count]=ultraschall.Docs_ReaperApiDocBlocs_Titles[i]
    end
    
    found_this_time=false
  end
  return Found_count, Found, FoundInformation
end

--A,B,C=ultraschall.Docs_FindReaperApiFunction_Pattern("tudel", false, false, 10, 14, nil, nil, true)

function ultraschall.Docs_GetUSDocBloc_Changelog(String, unindent_description, index)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Docs_GetUSDocBloc_Changelog</slug>
  <requires>
    Ultraschall=4.2
    Reaper=5.978
    Lua=5.3
  </requires>
  <functioncall>integer changelogscount, table changelogs = ultraschall.Docs_GetUSDocBloc_Changelog(string String, boolean unindent_description, integer index)</functioncall>
  <description>
    returns the changelog-entries of an US_DocBloc-entry
    
    this returns the version-number of the software and the changes introduced in that version inside a table.
    
    returns nil in case of an error
  </description>
  <retvals>
    integer changelogscount - the number of changelog-entries found
    array changelogs - all changelogs found, as an array
                     -   changelogs[index][1] - software-version of the introduction of the change, like "Reaper 6.23" or "US_API 4.2.006"
                     -   changelogs[index][2] - a description of the change
  </retvals>
  <parameters>
    string String - a string which hold a US_DocBloc to retrieve the changelog-entry from
    boolean unindent_description - true, will remove indentation as given in the changelog-tag; false, return the text as it is
    integer index - the index of the changelog-entries, starting with 1 for the first
  </parameters>
  <chapter_context>
    Ultraschall DocML
  </chapter_context>
  <target_document>US_Api_DOC</target_document>
  <source_document>ultraschall_doc_engine.lua</source_document>
  <tags>doc engine, get, changelog, usdocbloc</tags>
</US_DocBloc>
]]
  if type(String)~="string" then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_Changelog", "String", "must be a string", -1) return nil end
  if math.type(index)~="integer" then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_Changelog", "index", "must be an integer", -2) return nil end
  if index<1 then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_Changelog", "index", "must be >0", -3) return nil end
  if type(unindent_description)~="boolean" then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_Changelog", "unindent_description", "must be a boolean", -4) return nil end
  
  local counter=0
  local title, spok_lang, found
  for k in string.gmatch(String, "(<changelog.->.-</changelog>)") do
    counter=counter+1
    if counter==index then String=k found=true end
  end  
  
  if found~=true then return 0 end
  
  local parms=String:match("(<changelog.->.-)</changelog>")
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
      Params[Parmcount][1]=Params[Parmcount][1].."\0"
      Params[Parmcount][1]=Params[Parmcount][1]:match("(.*) %s*\0")
    else
      Params[Parmcount][2]=Params[Parmcount][2].."\n"..split_string[i]:sub(2,-1)
    end
  end
  
  if indent==nil then indent="default" end
  
  if unindent_description~=false then 
    for i=1, Parmcount do
      Params[i][2]=ultraschall.Docs_RemoveIndent(Params[i][2], indent)
    end
  end
  
  return Parmcount, Params
end

function ultraschall.Docs_GetUSDocBloc_LinkedTo(String, unindent_description, index)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Docs_GetUSDocBloc_LinkedTo</slug>
  <requires>
    Ultraschall=4.2
    Reaper=5.978
    Lua=5.3
  </requires>
  <functioncall>integer linked_to_count, table links, string description = ultraschall.Docs_GetUSDocBloc_LinkedTo(string String, boolean unindent_description, integer index)</functioncall>
  <description>
    returns the linked_to-tags of an US_DocBloc-entry
    
    returns nil in case of an error
  </description>
  <retvals>
    integer linked_to_count - the number of linked_to-entries found
    array links - all links found, as an array
                 -   links[index]["location"] - the location of the link, either inline(for slugs inside the same document) or url(for links/urls/uris outside of it)
                 -   links[index]["link"] - the slug to the element inside the document/the url or uri linking outside of the document
                 -   links[index]["description"] - a description for this link
    string description - a description for this linked_to-tag
  </retvals>
  <parameters>
    string String - a string which hold a US_DocBloc to retrieve the linked_to-entry from
    boolean unindent_description - true, will remove indentation as given in the changelog-tag; false, return the text as it is
    integer index - the index of the linked_to-entries, starting with 1 for the first
  </parameters>
  <chapter_context>
    Ultraschall DocML
  </chapter_context>
  <target_document>US_Api_DOC</target_document>
  <source_document>ultraschall_doc_engine.lua</source_document>
  <tags>doc engine, get, linked_to, usdocbloc</tags>
</US_DocBloc>
]]

--[[
    linked_to tags work as follows:
    <linked_to desc="a description for the links in this linked_to-tag">
        inline: slug
              description
              optional second line of description
              optional third line of description
              etc
        url: actual-url.com
              description
              optional second line of description
              optional third line of description
              etc
    </linked_to>
    
    There can be multiple link-tags inside a usdocml-tag!
--]]
  if type(String)~="string" then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_LinkedTo", "String", "must be a string", -1) return nil end
  if math.type(index)~="integer" then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_LinkedTo", "index", "must be an integer", -2) return nil end
  if index<1 then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_LinkedTo", "index", "must be >0", -3) return nil end
  if type(unindent_description)~="boolean" then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_LinkedTo", "unindent_description", "must be a boolean", -4) return nil end
  
  local counter=0
  local title, spok_lang, found
  for k in string.gmatch(String, "(<linked_to.->.-</linked_to>)") do
    counter=counter+1
    if counter==index then String=k found=true end
  end  
  
  if found~=true then return 0 end
  
  local parms=String:match("(<linked_to.->.-)</linked_to>")
  local desc=parms:match("<linked_to.-desc=\"(.-)\">")
  if desc==nil then desc="" end
  local count, split_string = ultraschall.SplitStringAtLineFeedToArray(parms)
  local Linkedcount=0
  local LinkedTo={}
  
  for i=1, count do
    split_string[i]=split_string[i]:match("%s*(.*)")
  end

  for i=2, count-1 do
    if split_string[i]:match(":") then 
      Linkedcount=Linkedcount+1
      LinkedTo[Linkedcount]={}
      LinkedTo[Linkedcount]["location"], LinkedTo[Linkedcount]["link"] = split_string[i]:match("(.-):(.*)")
    else
      if LinkedTo[Linkedcount]["description"]==nil then LinkedTo[Linkedcount]["description"]="" end
      LinkedTo[Linkedcount]["description"]=LinkedTo[Linkedcount]["description"]..split_string[i].."\n"
    end
  end
  
  if unindent_description~=false then 
    for i=1, Linkedcount do
      LinkedTo[i]["description"]=ultraschall.Docs_RemoveIndent(LinkedTo[i]["description"]:sub(1,-2), "default")
    end
  end
  
  return Linkedcount, LinkedTo, desc
end

function ultraschall.ReturnReaperExeFile_With_Path()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ReturnReaperExeFile_With_Path</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.33
    Lua=5.3
  </requires>
  <functioncall>string exefile_with_path = ultraschall.ReturnReaperExeFile_With_Path()</functioncall>
  <description>
    returns the reaper-exe-file with file-path
  </description>
  <retvals>
    string exefile_with_path - the filename and path of the reaper-executable
  </retvals>
  <chapter_context>
    API-Helper functions
    Various
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_HelperFunctions_Module.lua</source_document>
  <tags>helper functions, get, exe, filename, path</tags>
</US_DocBloc>
--]]
  if ultraschall.IsOS_Windows()==true then
    -- On Windows
    ExeFile=reaper.GetExePath().."\\reaper.exe"
  elseif ultraschall.IsOS_Mac()==true then
    -- On Mac
    ExeFile=reaper.GetExePath().."/Reaper64.app/Contents/MacOS/reaper"
    if reaper.file_exists(ExeFile)==false then
      ExeFile=reaper.GetExePath().."/Reaper.app/Contents/MacOS/reaper"
    end
  else
    -- On Linux
    ExeFile=reaper.GetExePath().."/reaper"
  end
  return ExeFile
end

function ultraschall.GetParmLearnID_by_FXParam_FXStateChunk(FXStateChunk, fxid, param_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetParmLearnID_by_FXParam_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=5.975
    Lua=5.3
  </requires>
  <functioncall>integer parmlearn_id, = ultraschall.GetParmLearnID_by_FXParam_FXStateChunk(string FXStateChunk, integer fxid, integer param_id)</functioncall>
  <description>
    Returns the parmlearn_id by parameter.

    This can be used as parameter parm_learn_id for Get/Set/DeleteParmLearn-functions
    
    Returns -1, if the parameter has no ParmLearn associated.
    
    Returns nil in case of an error
  </description>
  <retvals>
    integer parmlearn_id - the idx of the parmlearn, that you can use for Add/Get/Set/DeleteParmLearn-functions; -1, if parameter has no ParmLearn associated
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, from which you want to retrieve the parmlearn
    integer fxid - the fx, of which you want to get the parmlearn_id
    integer param_id - the parameter, whose parmlearn_id you want to get
  </parameters>
  <chapter_context>
    FX-Management
    Parameter Mapping Learn
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fxmanagement, get, parameter, learn, fxstatechunk, osc, midi</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("GetParmLearnID_by_FXParam_FXStateChunk", "StateChunk", "Not a valid FXStateChunk", -1) return nil end
  if math.type(param_id)~="integer" then ultraschall.AddErrorMessage("GetParmLearnID_by_FXParam_FXStateChunk", "param_id", "must be an integer", -2) return nil end
  if math.type(fxid)~="integer" then ultraschall.AddErrorMessage("GetParmLearnID_by_FXParam_FXStateChunk", "fxid", "must be an integer", -3) return nil end
  if string.find(FXStateChunk, "\n  ")==nil then
    FXStateChunk=ultraschall.StateChunkLayouter(FXStateChunk)
  end
  FXStateChunk=ultraschall.GetFXFromFXStateChunk(FXStateChunk, fxid)
  if FXStateChunk==nil then ultraschall.AddErrorMessage("GetParmLearnID_by_FXParam_FXStateChunk", "fxid", "no such fx", -4) return nil end
  local count=0
  local name=""
  local idx, midi_note, checkboxes
  for w in string.gmatch(FXStateChunk, "PARMLEARN.-\n") do
    w=w:sub(1,-2).." " 
    idx = w:match(" (.-) ") 
    if tonumber(idx)==nil then 
      idx, name = w:match(" (.-):(.-) ")
    end
    
    if tonumber(idx)==param_id then 
      return count
    end
    count=count+1
  end
  return -1
end


function ultraschall.GetParmAliasID_by_FXParam_FXStateChunk(FXStateChunk, fxid, param_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetParmAliasID_by_FXParam_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=5.975
    Lua=5.3
  </requires>
  <functioncall>integer parmalias_id, = ultraschall.GetParmAliasID_by_FXParam_FXStateChunk(string FXStateChunk, integer fxid, integer param_id)</functioncall>
  <description>
    Returns the parmalias_id by parameter.

    This can be used as parameter parm_alias_id for Get/Set/DeleteParmAlias-functions
    
    Returns -1, if the parameter has no ParmAlias associated.
    
    Returns nil in case of an error
  </description>
  <retvals>
    integer parmalias_id - the idx of the parmalias, that you can use for Add/Get/Set/DeleteParmAlias-functions; -1, if parameter has no ParmAlias associated
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, from which you want to retrieve the parmalias_id
    integer fxid - the fx, of which you want to get the parmalias_id
    integer param_id - the parameter, whose parmalias_id you want to get
  </parameters>
  <chapter_context>
    FX-Management
    Parameter Mapping Alias
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fxmanagement, get, parameter, alias, fxstatechunk, osc, midi</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("GetParmAliasID_by_FXParam_FXStateChunk", "StateChunk", "Not a valid FXStateChunk", -1) return nil end
  if math.type(param_id)~="integer" then ultraschall.AddErrorMessage("GetParmAliasID_by_FXParam_FXStateChunk", "param_id", "must be an integer", -2) return nil end
  if math.type(fxid)~="integer" then ultraschall.AddErrorMessage("GetParmAliasID_by_FXParam_FXStateChunk", "fxid", "must be an integer", -3) return nil end
  if string.find(FXStateChunk, "\n  ")==nil then
    FXStateChunk=ultraschall.StateChunkLayouter(FXStateChunk)
  end
  FXStateChunk=ultraschall.GetFXFromFXStateChunk(FXStateChunk, fxid)
  if FXStateChunk==nil then ultraschall.AddErrorMessage("GetParmAliasID_by_FXParam_FXStateChunk", "fxid", "no such fx", -4) return nil end
  local count=0
  local name=""
  local idx, midi_note, checkboxes
  for w in string.gmatch(FXStateChunk, "PARMALIAS.-\n") do
    w=w:sub(1,-2).." " 
    idx = w:match(" (.-) ") 
    if tonumber(idx)==nil then 
      idx, name = w:match(" (.-):(.-) ")
    end
    
    if tonumber(idx)==param_id then 
      return count
    end
    count=count+1
  end
  return -1
end


function ultraschall.GetParmLFOLearnID_by_FXParam_FXStateChunk(FXStateChunk, fxid, param_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetParmLFOLearnID_by_FXParam_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=5.975
    Lua=5.3
  </requires>
  <functioncall>integer parm_lfolearn_id, = ultraschall.GetParmLFOLearnID_by_FXParam_FXStateChunk(string FXStateChunk, integer fxid, integer param_id)</functioncall>
  <description>
    Returns the parmlfolearn_id by parameter.

    This can be used as parameter parm_lfolearn_id for Get/Set/DeleteLFOLearn-functions
    
    Returns -1, if the parameter has no ParmLFOLearn associated.
    
    Returns nil in case of an error
  </description>
  <retvals>
    integer parm_lfolearn_id - the idx of the parm_lfolearn, that you can use for Add/Get/Set/DeleteParmLFOLearn-functions; -1, if parameter has no ParmLFOLearn associated
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, from which you want to retrieve the parm_lfolearn_id
    integer fxid - the fx, of which you want to get the parameter-lfo_learn-settings
    integer param_id - the parameter, whose parm_lfolearn_id you want to get
  </parameters>
  <chapter_context>
    FX-Management
    Parameter Mapping LFOLearn
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fxmanagement, get, parameter, lfolearn, fxstatechunk, osc, midi</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("GetParmLFOLearnID_by_FXParam_FXStateChunk", "StateChunk", "Not a valid FXStateChunk", -1) return nil end
  if math.type(param_id)~="integer" then ultraschall.AddErrorMessage("GetParmLFOLearnID_by_FXParam_FXStateChunk", "param_id", "must be an integer", -2) return nil end
  if math.type(fxid)~="integer" then ultraschall.AddErrorMessage("GetParmLFOLearnID_by_FXParam_FXStateChunk", "fxid", "must be an integer", -3) return nil end
  if string.find(FXStateChunk, "\n  ")==nil then
    FXStateChunk=ultraschall.StateChunkLayouter(FXStateChunk)
  end
  FXStateChunk=ultraschall.GetFXFromFXStateChunk(FXStateChunk, fxid)
  if FXStateChunk==nil then ultraschall.AddErrorMessage("GetParmLFOLearnID_by_FXParam_FXStateChunk", "fxid", "no such fx", -4) return nil end
  local count=0
  local name=""
  local idx, midi_note, checkboxes
  for w in string.gmatch(FXStateChunk, "LFOLEARN.-\n") do
    w=w:sub(1,-2).." " 
    idx = w:match(" (.-) ") 
    if tonumber(idx)==nil then 
      idx, name = w:match(" (.-):(.-) ")
    end
    
    if tonumber(idx)==param_id then 
      return count
    end
    count=count+1
  end
  return -1
end

function ultraschall.GetRenderCFG_Settings_CAF(rendercfg)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>GetRenderCFG_Settings_CAF</slug>
    <requires>
      Ultraschall=4.2
      Reaper=6.43
      Lua=5.3
    </requires>
    <functioncall>integer bitdepth, boolean EmbedTempo, integer include_markers = ultraschall.GetRenderCFG_Settings_CAF(string rendercfg)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      Returns the settings stored in a render-cfg-string for CAF.

      You can get this from the current RENDER\_FORMAT using reaper.GetSetProjectInfo_String or from ProjectStateChunks, RPP-Projectfiles and reaper-render.ini
      
      Returns -1 in case of an error
    </description>
    <retvals>
      integer bitdepth - the bitdepth of the CAF-file(8, 16, 24, 32(fp), 33(pcm), 64)
      boolean EmbedTempo - Embed tempo-checkbox; true, checked; false, unchecked
      integer include_markers - the include markers and regions dropdownlist
                              - 0, Do not include markers or regions
                              - 1, Markers + Regions
                              - 2, Markers + Regions starting with #
                              - 3, Markers only
                              - 4, Markers starting with # only
                              - 5, Regions only
                              - 6, Regions starting with # only
    </retvals>
    <parameters>
      string render_cfg - the render-cfg-string, that contains the caf-settings
                        - nil, get the current new-project-default render-settings for caf
    </parameters>
    <chapter_context>
      Rendering Projects
      Analyzing Renderstrings
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_Render_Module.lua</source_document>
    <tags>render management, get, settings, rendercfg, renderstring, caff, caf, bitdepth, beat length</tags>
  </US_DocBloc>
  ]]
  if rendercfg~=nil and type(rendercfg)~="string" then ultraschall.AddErrorMessage("GetRenderCFG_Settings_CAF", "rendercfg", "must be a string", -1) return -1 end
  if rendercfg==nil then
    local retval
    retval, rendercfg = reaper.BR_Win32_GetPrivateProfileString("caff sink defaults", "default", "", reaper.get_ini_file())
    if retval==0 then rendercfg="6666616340B80088" end
    rendercfg = ultraschall.ConvertHex2Ascii(rendercfg)
    rendercfg=ultraschall.Base64_Encoder(rendercfg)
  end
  local Decoded_string = ultraschall.Base64_Decoder(rendercfg)
  if Decoded_string==nil or Decoded_string:sub(1,4)~="ffac" then ultraschall.AddErrorMessage("GetRenderCFG_Settings_CAF", "rendercfg", "not a render-cfg-string of the format caf", -2) return -1 end
  
  if Decoded_string:len()==4 then
    return 24, false
  end
  
  dropdownlist=tonumber(string.byte(Decoded_string:sub(6,6)))
  if dropdownlist&32~=0 then dropdownlist=dropdownlist-32 end
  dropdownlist=dropdownlist>>3
  if dropdownlist==0 then dropdownlist=0
  elseif dropdownlist==1 then dropdownlist=1
  elseif dropdownlist==3 then dropdownlist=2
  elseif dropdownlist==9 then dropdownlist=3
  elseif dropdownlist==11 then dropdownlist=4
  elseif dropdownlist==17 then dropdownlist=5
  elseif dropdownlist==19 then dropdownlist=6
  end
  
  return string.byte(Decoded_string:sub(5,5)), tonumber(string.byte(Decoded_string:sub(6,6)))&32==32, dropdownlist
end

function ultraschall.CreateRenderCFG_CAF(bits, EmbedTempo, include_markers)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CreateRenderCFG_CAF</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.43
    Lua=5.3
  </requires>
  <functioncall>string render_cfg_string = ultraschall.CreateRenderCFG_CAF(integer bits, boolean EmbedTempo, integer include_markers)</functioncall>
  <description>
    Returns the render-cfg-string for the CAF-format. You can use this in ProjectStateChunks, RPP-Projectfiles and reaper-render.ini
    
    Returns nil in case of an error
  </description>
  <retvals>
    string render_cfg_string - the render-cfg-string for the selected CAF-settings
  </retvals>
  <parameters>
      integer bitdepth - the bitdepth of the CAF-file(8, 16, 24, 32(fp), 33(pcm), 64)
      boolean EmbedTempo - Embed tempo-checkbox; true, checked; false, unchecked
      integer include_markers - the include markers and regions dropdownlist
                              - 0, Do not include markers or regions
                              - 1, Markers + Regions
                              - 2, Markers + Regions starting with #
                              - 3, Markers only
                              - 4, Markers starting with # only
                              - 5, Regions only
                              - 6, Regions starting with # only
  </parameters>
  <chapter_context>
    Rendering Projects
    Creating Renderstrings
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Render_Module.lua</source_document>
  <tags>projectfiles, create, render, outputformat, caf</tags>
</US_DocBloc>
]]
  if math.type(bits)~="integer" then ultraschall.AddErrorMessage("CreateRenderCFG_CAF", "bits", "must be an integer", -1) return nil end
  if bits~=8 and bits~=16 and bits~=24 and bits~=32 and bits~=33 and bits~=64 then ultraschall.AddErrorMessage("CreateRenderCFG_CAF", "bits", "only 8, 16, 24, 32, 33(32 pcm) and 64 are supported by CAF", -2) return nil end
  if EmbedTempo~=nil and type(EmbedTempo)~="boolean" then ultraschall.AddErrorMessage("CreateRenderCFG_CAF", "EmbedTempo", "must be a boolean", -3) return nil end  
  
  if include_markers==2 then include_markers=3
  elseif include_markers==3 then include_markers=9
  elseif include_markers==4 then include_markers=11
  elseif include_markers==5 then include_markers=17
  elseif include_markers==6 then include_markers=19
  end
  
  include_markers=include_markers<<3
  
  if EmbedTempo==true then include_markers=include_markers+32 end

  local renderstring="ffac"..string.char(bits)..string.char(include_markers)..string.char(0)
  renderstring=ultraschall.Base64_Encoder(renderstring)
  
  return renderstring
end

function ultraschall.GFX_GetChar(character, manage_clipboard, to_clipboard, readable_characters)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GFX_GetChar</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.42
    Lua=5.3
  </requires>
  <functioncall>integer first_typed_character, integer num_characters, table character_queue = ultraschall.GFX_GetChar(optional integer character, optional boolean manage_clipboard, optional string to_clipboard, optional boolean readable_characters)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    gets all characters from the keyboard-queue of gfx.getchar as a handy table.
    
    the returned table character_queue is of the following format:
    
        character_queue[index]["Code"] - the character-code
        character_queue[index]["Ansi"] - the character-code converted into Ansi
        character_queue[index]["UTF8"] - the character-code converted into UTF8
      
    When readable_characters=true, the entries of the character_queue for Ansi and UTF8 will hold readable strings for non-printable characters, like:
      "ins ", "del ", "home", "F1  "-"F12 ", "tab ", "esc ", "pgup", "pgdn", "up  ", "down", "left", "rght", "bspc", "ente"
      
    You can optionally let this function manage clipboard. So hitting Ctrl+V will get put the content of the clipboard into the character_queue of Ansi/UTF8 in the specific position of the character-queue,
    while hitting Ctrl+C will put the contents of the parameter to_clipboard into the clipboard in this case.
    
    Retval first_typed_character behaves basically like the returned character of Reaper's native function gfx.getchar()
    
    returns -2 in case of an error
  </description>
  <parameters>
    optional integer character - a specific character-code to check for(will ignore all other keys)
                               - 65536 queries special flags, like: &amp;1 (supported in this script), &amp;2=window has focus, &amp;4=window is visible  
    optional boolean manage_clipboard - true, when user hits ctrl+v/cmd+v the character-queue will hold clipboard-contents in this position
                                      - false, treat ctrl+v/cmd+v as regular typed character
    optional string to_clipboard - if get_paste_from_clipboard=true and user hits ctrl+c/cmd+c, the contents of this variable will be put into the clipboard
    optional boolean readable_characters - true, make non-printable characters readable; false, keep them in original state
  </parameters>
  <retvals>
    integer first_typed_character - the character-code of the first character found
    integer num_characters - the number of characters in the queue
    table character_queue - the characters in the queue, within a table(see description for more details)
  </retvals>
  <chapter_context>
    Key-Management
  </chapter_context>
  <target_document>US_Api_GFX</target_document>
  <source_document>ultraschall_gfx_engine.lua</source_document>
  <tags>gfx, functions, gfx, getchar, character, clipboard</tags>
</US_DocBloc>
]]
  if character~=nil and math.type(character)~="integer" then ultraschall.AddErrorMessage("GFX_GetChar", "character", "must be an integer", -1) return -2 end
  if manage_clipboard~=nil and type(manage_clipboard)~="boolean" then ultraschall.AddErrorMessage("GFX_GetChar", "manage_clipboard", "must be either nil or boolean", -2) return -2 end
  if readable_characters~=nil and type(readable_characters)~="boolean" then ultraschall.AddErrorMessage("GFX_GetChar", "readable_characters", "must be either nil or boolean", -3) return -2 end
  to_clipboard=tostring(to_clipboard)
  
  local A=1
  local CharacterTable={}
  local CharacterCount=0
  local first=-2
  while A>0 do
    A=gfx.getchar(character)
    if first==-2 then first=math.tointeger(A) end
    if A>0 then
      CharacterCount=CharacterCount+1
      CharacterTable[CharacterCount]={}
      CharacterTable[CharacterCount]["Code"]=A
      if manage_clipboard==true and A==3 then
        ToClip(to_clipboard)
      elseif manage_clipboard==true and A==22 and gfx.mouse_cap&4==4 then
        CharacterTable[CharacterCount]["Ansi"]=FromClip()
      else
        if A>-1 and A<255 then
          CharacterTable[CharacterCount]["Ansi"]=string.char(A)
        else
          CharacterTable[CharacterCount]["Ansi"]=""
        end
        if A>-1 and A<1114112 then
          CharacterTable[CharacterCount]["UTF8"]=utf8.char(A)
        else
          CharacterTable[CharacterCount]["UTF8"]=""
        end
        if readable_characters==false then
          if A>1114112 then
            CharacterTable[CharacterCount]["UTF8"] = ultraschall.ConvertIntegerIntoString2(4, math.tointeger(A)):reverse()
            CharacterTable[CharacterCount]["Ansi"] = CharacterTable[CharacterCount]["UTF8"]
          end
    
          if A==6647396.0 then -- end-key
            CharacterTable[CharacterCount]["Ansi"] = "end " 
            CharacterTable[CharacterCount]["UTF8"] = "end "
          end
          if A==6909555.0 then -- insert key
            CharacterTable[CharacterCount]["Ansi"] = "ins " 
            CharacterTable[CharacterCount]["UTF8"] = "ins "
          end
          if A==6579564.0 then -- del key
            CharacterTable[CharacterCount]["Ansi"] = "del " 
            CharacterTable[CharacterCount]["UTF8"] = "del "
          end
          if A>26160.0 and A<26170.0 then -- F1 through F9
            CharacterTable[CharacterCount]["Ansi"] = "F"..(math.tointeger(A)-26160).."  "
            CharacterTable[CharacterCount]["UTF8"] = "F"..(math.tointeger(A)-26160).."  "
          end
          if A>=6697264.0 and A<=6697266.0 then -- F10 and higher
            CharacterTable[CharacterCount]["Ansi"] = "F"..(math.tointeger(A)-6697254).." "
            CharacterTable[CharacterCount]["UTF8"] = "F"..(math.tointeger(A)-6697254).." "
          end
          if A==8 then -- backspace
            CharacterTable[CharacterCount]["Ansi"] = "bspc"
            CharacterTable[CharacterCount]["UTF8"] = "bspc"
          end
          if A==9 then -- backspace
            CharacterTable[CharacterCount]["Ansi"] = "tab "
            CharacterTable[CharacterCount]["UTF8"] = "tab "
          end
          if A==13 then -- enter
            CharacterTable[CharacterCount]["Ansi"] = "ente"
            CharacterTable[CharacterCount]["UTF8"] = "ente"
          end
          if A==27 then -- escape
            CharacterTable[CharacterCount]["Ansi"] = "esc "
            CharacterTable[CharacterCount]["UTF8"] = "esc "
          end
          if A==30064.0 then -- upkey, others are treated with A>1114112
            CharacterTable[CharacterCount]["Ansi"] = "up  "
            CharacterTable[CharacterCount]["UTF8"] = "up  "
          end

        end
      end    
    else
      break
    end
  end

  --  local B=""
  --  local C=""
  --  for i=1, CharacterCount do
  --    B=B..CharacterTable[i]["UTF"]
  --    C=C..CharacterTable[i]["Ansi"]
  --  end
  return first, CharacterCount, CharacterTable--, B, C
end

function ultraschall.Docs_GetUSDocBloc_Deprecated(US_DocBloc)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Docs_GetUSDocBloc_Deprecated</slug>
  <requires>
    Ultraschall=4.2
    Reaper=5.978
    Lua=5.3
  </requires>
  <functioncall>string what, string when, string alternative = ultraschall.Docs_GetUSDocBloc_Deprecated(string US_DocBloc)</functioncall>
  <description>
    returns the deprecated-tag of an US-DocBloc, which holds the information about, is a function is deprecated and what to use alternatively.
    
    returns nil in case of an error or if no such deprecated-tag exists for this US_DocBloc
  </description>
  <retvals>
    string what - which software deprecated the function "Reaper" or "SWS" or "JS", etc
    string when - since which version is this function deprecated
    string alternative - what is a possible alternative to this function, if existing
    string removed - function got removed
  </retvals>
  <parameters>
    string US_DocBloc - a string which hold a US_DocBloc to retrieve the deprecated-tag-attributes from
  </parameters>
  <chapter_context>
    Ultraschall DocML
  </chapter_context>
  <target_document>US_Api_DOC</target_document>
  <source_document>ultraschall_doc_engine.lua</source_document>
  <tags>doc engine, get, deprecated, usdocbloc</tags>
</US_DocBloc>
]]  
  if type(US_DocBloc)~="string" then ultraschall.AddErrorMessage("Docs_GetUSDocBloc_Deprecated", "US_DocBloc", "must be a string", -1) return end
  local Deprecated=US_DocBloc:match("<deprecated .*/>")
  if Deprecated == nil then return end
  local DepreWhat, Depr_SinceWhen=Deprecated:match("since_when=\"(.-) (.-)\"")
  local Depr_Alternative=Deprecated:match("alternative=\"(.-)\"")
  local Depr_Removed=Deprecated:match("removed=\"(.-)\"")
  --print2(Depr_Removed)
  return DepreWhat, Depr_SinceWhen, Depr_Alternative, Depr_Removed~=nil
end