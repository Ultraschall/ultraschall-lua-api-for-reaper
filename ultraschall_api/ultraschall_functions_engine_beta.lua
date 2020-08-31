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
    boolean retval - true, saving was successful; false, saving wasn't successful
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

function ultraschall.BatchConvertFiles(inputfilelist, outputfilelist, RenderTable, BWFStart, PadStart, PadEnd, FXStateChunk, MetaDataStateChunk)
-- Todo:
-- Check on Mac and Linux
--    Linux saves outfile into wrong directory -> lastcwd not OUTPATH for some reason
-- Check all parameters for correct typings
-- Test FXStateChunk-capability
  local BatchConvertData=""
  --local ExeFile, filename, path
  if FXStateChunk~=nil and FXStateChunk~="" and ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("BatchConvertFiles", "FXStateChunk", "must be a valid FXStateChunk", -1) return nil end
  if FXStateChunk==nil then FXStateChunk="" end
  if MetaDataStateChunk==nil then MetaDataStateChunk="" end
  if BWFStart==true then BWFStart="    USERCSTART 1\n" else BWFStart="" end
  if PadStart~=nil  then PadStart="    PAD_START "..PadStart.."\n" else PadStart="" end
  if PadEnd~=nil  then PadEnd="    PAD_END "..PadEnd.."\n" else PadEnd="" end
  local i=1
  local outputfile
  while inputfilelist[i]~=nil do
    if ultraschall.type(inputfilelist[i])=="string" then
      if outputfilelist[i]==nil then outputfile="" else outputfile=outputfilelist[i] end
      BatchConvertData=BatchConvertData..inputfilelist[i].."\t"..outputfile.."\n"
    end
    i=i+1
  end
  BatchConvertData=BatchConvertData..[[
<CONFIG
    SRATE ]]..RenderTable["SampleRate"]..[[
    
    NCH ]]..RenderTable["Channels"]..[[
    
    RSMODE ]]..RenderTable["RenderResample"]..[[
    
    DITHER ]]..RenderTable["Dither"]..[[
    
]]..BWFStart..[[
]]..PadStart..[[
]]..PadEnd..[[
    OUTPATH ]]..RenderTable["RenderFile"]..[[
    
    OUTPATTERN ']]..[['
  <OUTFMT 
    ]]      ..RenderTable["RenderString"]..[[

  >
  ]]..FXStateChunk..[[
  ]]..string.gsub(MetaDataStateChunk, "<RENDER_METADATA", "<METADATA")..[[

>
]]

  ultraschall.WriteValueToFile(ultraschall.API_TempPath.."/filelist.txt", BatchConvertData)
print3(BatchConvertData)
--if ll==nil then return end

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
    ExeFile=reaper.GetExePath().."/reaper"
--print3(ExeFile.." -batchconvert "..string.gsub(ultraschall.API_TempPath, "\\\\", "/").."/filelist.txt")
    AAAA, AAAAAA=reaper.ExecProcess(ExeFile.." -batchconvert "..string.gsub(ultraschall.API_TempPath, "\\\\", "/").."/filelist.txt", -1)
  end
end


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

function ultraschall.GetAllSelectedRegions_Project()
  -- still has an issue, when GetProjectStateChunk doesn't return a ProjectStateChunk(probably due timeout-issues)
  -- so check, if ProjectStateChunk is an actual one or nil!!
  -- seems to be problematic on Mac mostly...
  local ProjectStateChunk = ultraschall.GetProjectStateChunk(nil, false)
  local markerregioncount, NumMarker, Numregions, Markertable = ultraschall.GetProject_MarkersAndRegions(nil, ProjectStateChunk)
  
  local regions={}
  local regionscnt=0

  for i=1, markerregioncount do
    if Markertable[i][1]==true and Markertable[i][8]==true then
      regionscnt=regionscnt+1
      regions[regionscnt]=Markertable[i][5]
    end
  end
  return regionscnt, regions
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

-- These seem to work working:

function ultraschall.BringReaScriptConsoleToFront()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>BringReaScriptConsoleToFront</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>ultraschall.BringReaScriptConsoleToFront()</functioncall>
  <description>
    Brings Reaper's ReaScriptConsole-window to the front, when it's opened.
  </description>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>user interface, activate, front, reascript console, window</tags>
</US_DocBloc>
]]
  local OldHWND=reaper.JS_Window_GetForeground()
  local HWND=ultraschall.GetReaScriptConsoleWindow()
  if HWND~=nil and OldHWND~=HWND then 
    reaper.JS_Window_SetForeground(HWND)
  end
end

function ultraschall.print_BringReaScriptToFrontToggle(toggle)
  if ultraschall.type(toggle)~="string" then ultraschall.AddErrorMessage("GetProject_RenderOutputPath", "projectfilename_with_path", "must be a string", -1) return nil end
end

function ultraschall.GFX_DrawEmbossedSquare(x, y, w, h, rbg, gbg, bbg, r, g, b)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GFX_DrawEmbossedSquare</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.GFX_DrawEmbossedSquare(integer x, integer y, integer w, integer h, optional integer rgb, optional integer gbg, optional integer bbg, optional integer r, optional integer g, optional integer b)</functioncall>
  <description>
    draws an embossed rectangle, optionally with a background-color
    
    returns false in case of an error
  </description>
  <parameters>
    integer x - the x position of the rectangle
    integer y - the y position of the rectangle
    integer w - the width of the rectangle
    integer h - the height of the rectangle
    optional integer rgb - the red-color of the background-rectangle; set to nil for no background-color
    optional integer gbg - the green-color of the background-rectangle; set to nil for no background-color/uses rbg if gbg and bbg are set to nil
    optional integer bbg - the blue-color of the background-rectangle; set to nil for no background-color/uses rbg if gbg and bbg are set to nil
    optional integer r - the red-color of the embossed-rectangle; nil, to use 1
    optional integer g - the green-color of the embossed-rectangle; nil, to use 1
    optional integer b - the blue-color of the embossed-rectangle; nil, to use 1
  </parameters>
  <retvals>
    boolean retval - true, drawing was successful; false, drawing wasn't successful
  </retvals>
  <chapter_context>
    Basic Shapes
  </chapter_context>
  <target_document>US_Api_GFX</target_document>
  <source_document>ultraschall_gfx_engine.lua</source_document>
  <tags>gfx, functions, gfx, draw, thickness, embossed rectangle</tags>
</US_DocBloc>
]]
  if gfx.getchar()==-1 then ultraschall.AddErrorMessage("GFX_DrawEmbossedSquare", "", "no gfx-window opened", -1) return false end
  if ultraschall.type(x)~="number: integer" then ultraschall.AddErrorMessage("GFX_DrawEmbossedSquare", "x", "must be an integer", -2) return false end
  if ultraschall.type(y)~="number: integer" then ultraschall.AddErrorMessage("GFX_DrawEmbossedSquare", "y", "must be an integer", -3) return false end
  if ultraschall.type(w)~="number: integer" then ultraschall.AddErrorMessage("GFX_DrawEmbossedSquare", "w", "must be an integer", -4) return false end
  if ultraschall.type(h)~="number: integer" then ultraschall.AddErrorMessage("GFX_DrawEmbossedSquare", "h", "must be an integer", -5) return false end
  
  if rbg~=nil and type(rbg)~="number" then ultraschall.AddErrorMessage("GFX_DrawEmbossedSquare", "rbg", "must be a number or nil", -6) return false end
  if bbg~=nil and type(bbg)~="number" then ultraschall.AddErrorMessage("GFX_DrawEmbossedSquare", "gbg", "must be a number or nil", -7) return false end
  if gbg~=nil and type(gbg)~="number" then ultraschall.AddErrorMessage("GFX_DrawEmbossedSquare", "bbg", "must be a number or nil", -8) return false end
  
  if r~=nil and type(r)~="number" then ultraschall.AddErrorMessage("GFX_DrawEmbossedSquare", "r", "must be a number or nil", -9) return false end
  if g~=nil and type(g)~="number" then ultraschall.AddErrorMessage("GFX_DrawEmbossedSquare", "g", "must be a number or nil", -10) return false end
  if b~=nil and type(b)~="number" then ultraschall.AddErrorMessage("GFX_DrawEmbossedSquare", "b", "must be a number or nil", -11) return false end
  local offsetx=1
  local offsety=1
  
  
  if r~=nil and g==nil and b==nil then g=r b=r end
  if r==nil or g==nil or g==nil then r=1 g=1 b=1 end   
  if b==nil or g==nil then ultraschall.AddErrorMessage("GFX_DrawEmbossedSquare", "r, g and b", "either all three must be set or only one of them", -12) return false end 
  -- background
  if rbg~=nil and bbg==nil and gbg==nil then
    bbg=rbg
    gbg=rbg
  end
  if rbg~=nil and bbg~=nil and gbg~=nil then
    gfx.set(rbg,gbg,bbg)
    gfx.rect(x+1,y+1,w,h,1)
  end
  
  -- darker-edges
  gfx.set(0.5*r, 0.5*g, 0.5*b)
  gfx.line(x+offsetx  , y+offsety,   x+w+offsetx, y+offsety  )
  gfx.line(x+w+offsetx, y+offsety,   x+w+offsetx, y+h+offsety)
  gfx.line(x+w+offsetx, y+h+offsety, x+offsetx  , y+h+offsety)
  gfx.line(x+offsetx  , y+h+offsety, x+offsetx  , y+offsety  )

  -- brighter-edges
  gfx.set(r, g, b)
  gfx.line(x,   y,   x+w, y  )
  gfx.line(x+w, y,   x+w, y+h)
  gfx.line(x+w, y+h, x  , y+h)
  gfx.line(x  , y+h, x  , y  )
  return true
end 

function ultraschall.GetParmModulationTable(FXStateChunk, fxindex, parmodindex)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetParmModulationTable</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>table ParmModulationTable = ultraschall.GetParmModulationTable(string FXStateChunk, integer fxindex, integer parmodindex)</functioncall>
  <description>
    Returns a table with all values of a specific Parameter-Modulation from an FXStateChunk.
  
    The table's format is as follows:
    <pre><code>
                ParamModTable["PARAM_NR"]               - the parameter that you want to modulate; 1 for the first, 2 for the second, etc
                ParamModTable["PARAM_TYPE"]             - the type of the parameter, usually "", "wet" or "bypass"

                ParamModTable["PARAMOD_ENABLE_PARAMETER_MODULATION"] 
                                                        - Enable parameter modulation, baseline value(envelope overrides)-checkbox; 
                                                          true, checked; false, unchecked
                ParamModTable["PARAMOD_BASELINE"]       - Enable parameter modulation, baseline value(envelope overrides)-slider; 
                                                            0.000 to 1.000

                ParamModTable["AUDIOCONTROL"]           - is the Audio control signal(sidechain)-checkbox checked; true, checked; false, unchecked
                                                            Note: if true, this needs all AUDIOCONTROL_-entries to be set
                ParamModTable["AUDIOCONTROL_CHAN"]      - the Track audio channel-dropdownlist; When stereo, the first stereo-channel; 
                                                          nil, if not available
                ParamModTable["AUDIOCONTROL_STEREO"]    - 0, just use mono-channels; 1, use the channel AUDIOCONTROL_CHAN plus 
                                                            AUDIOCONTROL_CHAN+1; nil, if not available
                ParamModTable["AUDIOCONTROL_ATTACK"]    - the Attack-slider of Audio Control Signal; 0-1000 ms; nil, if not available
                ParamModTable["AUDIOCONTROL_RELEASE"]   - the Release-slider; 0-1000ms; nil, if not available
                ParamModTable["AUDIOCONTROL_MINVOLUME"] - the Min volume-slider; -60dB to 11.9dB; must be smaller than AUDIOCONTROL_MAXVOLUME; 
                                                          nil, if not available
                ParamModTable["AUDIOCONTROL_MAXVOLUME"] - the Max volume-slider; -59.9dB to 12dB; must be bigger than AUDIOCONTROL_MINVOLUME; 
                                                          nil, if not available
                ParamModTable["AUDIOCONTROL_STRENGTH"]  - the Strength-slider; 0(0%) to 1000(100%)
                ParamModTable["AUDIOCONTROL_DIRECTION"] - the direction-radiobuttons; -1, negative; 0, centered; 1, positive

                ParamModTable["LFO"]                    - if the LFO-checkbox checked; true, checked; false, unchecked
                                                            Note: if true, this needs all LFO_-entries to be set
                ParamModTable["LFO_SHAPE"]              - the LFO Shape-dropdownlist; 
                                                            0, sine; 1, square; 2, saw L; 3, saw R; 4, triangle; 5, random
                                                            nil, if not available
                ParamModTable["LFO_SHAPEOLD"]           - use the old-style of the LFO_SHAPE; 
                                                            0, use current style of LFO_SHAPE; 
                                                            1, use old style of LFO_SHAPE; 
                                                            nil, if not available
                ParamModTable["LFO_TEMPOSYNC"]          - the Tempo sync-checkbox; true, checked; false, unchecked
                ParamModTable["LFO_SPEED"]              - the LFO Speed-slider; 0(0.0039Hz) to 1(8.0000Hz); nil, if not available
                ParamModTable["LFO_STRENGTH"]           - the LFO Strength-slider; 0.000(0.0%) to 1.000(100.0%)
                ParamModTable["LFO_PHASE"]              - the LFO Phase-slider; 0.000 to 1.000; nil, if not available
                ParamModTable["LFO_DIRECTION"]          - the LFO Direction-radiobuttons; -1, Negative; 0, Centered; 1, Positive
                ParamModTable["LFO_PHASERESET"]         - the LFO Phase reset-dropdownlist; 
                                                            0, On seek/loop(deterministic output)
                                                            1, Free-running(non-deterministic output)
                                                            nil, if not available

                ParamModTable["PARMLINK"]               - the Link from MIDI or FX parameter-checkbox
                                                          true, checked; false, unchecked
                ParamModTable["PARMLINK_LINKEDPLUGIN"]  - the selected plugin; nil, if not available
                                                            -1, nothing selected yet
                                                            -100, MIDI-parameter-settings
                                                            1 - the first fx-plugin
                                                            2 - the second fx-plugin
                                                            3 - the third fx-plugin, etc
                ParamModTable["PARMLINK_LINKEDPARMIDX"] - the id of the linked parameter; -1, if none is linked yet; nil, if not available
                                                            When MIDI, this is irrelevant.
                                                            When FX-parameter:
                                                              0 to n; 0 for the first; 1, for the second, etc

                ParamModTable["PARMLINK_OFFSET"]        - the Offset-slider; -1.00(-100%) to 1.00(+100%); nil, if not available
                ParamModTable["PARMLINK_SCALE"]         - the Scale-slider; -1.00(-100%) to 1.00(+100%); nil, if not available

                ParamModTable["MIDIPLINK"]              - true, if any parameter-linking with MIDI-stuff; false, if not
                                                            Note: if true, this needs all MIDIPLINK_-entries and PARMLINK_LINKEDPLUGIN=-100 to be set
                ParamModTable["MIDIPLINK_BUS"]          - the MIDI-bus selected in the button-menu; 
                                                            0 to 15 for bus 1 to 16; 
                                                            nil, if not available
                ParamModTable["MIDIPLINK_CHANNEL"]      - the MIDI-channel selected in the button-menu; 
                                                            0, omni; 1 to 16 for channel 1 to 16; 
                                                            nil, if not available
                ParamModTable["MIDIPLINK_MIDICATEGORY"] - the MIDI_Category selected in the button-menu; nil, if not available
                                                            144, MIDI note
                                                            160, Aftertouch
                                                            176, CC 14Bit and CC
                                                            192, Program Change
                                                            208, Channel Pressure
                                                            224, Pitch
                ParamModTable["MIDIPLINK_MIDINOTE"]     - the MIDI-note selected in the button-menu; nil, if not available
                                                          When MIDI note:
                                                               0(C-2) to 127(G8)
                                                          When Aftertouch:
                                                               0(C-2) to 127(G8)
                                                          When CC14 Bit:
                                                               128 to 159; see dropdownlist for the commands(the order of the list 
                                                               is the same as this numbering)
                                                          When CC:
                                                               0 to 119; see dropdownlist for the commands(the order of the list 
                                                               is the same as this numbering)
                                                          When Program Change:
                                                               0
                                                          When Channel Pressure:
                                                               0
                                                          When Pitch:
                                                               0
                ParamModTable["WINDOW_ALTERED"]         - false, if the windowposition hasn't been altered yet; true, if the window has been altered
                                                            Note: if true, this needs all WINDOW_-entries to be set
                ParamModTable["WINDOW_ALTEREDOPEN"]     - if the position of the ParmMod-window is altered and currently open; 
                                                            nil, unchanged; 0, unopened; 1, open
                ParamModTable["WINDOW_XPOS"]            - the x-position of the altered ParmMod-window in pixels; nil, default position
                ParamModTable["WINDOW_YPOS"]            - the y-position of the altered ParmMod-window in pixels; nil, default position
                ParamModTable["WINDOW_RIGHT"]           - the right-position of the altered ParmMod-window in pixels; 
                                                            nil, default position; only readable
                ParamModTable["WINDOW_BOTTOM"]          - the bottom-position of the altered ParmMod-window in pixels; 
                                                            nil, default position; only readable
    </code></pre>
    returns nil in case of an error
  </description>
  <parameters>
    string FXStateChunk - an FXStateChunk, of which you want to get the values of a specific parameter-modulation
    integer fxindex - the index if the fx, of which you want to get specific parameter-modulation-values
    integer parmodindex - the parameter-modulation, whose values you want to get; 1, for the first; 2, for the second, etc
  </parameters>
  <retvals>
    table ParmModulationTable - a table which holds all values of a specfic parameter-modulation
  </retvals>
  <chapter_context>
    FX-Management
    Parameter Modulation
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fxmanagement, get, parameter modulation, table, all values</tags>
</US_DocBloc>
]]
  if ultraschall.type(FXStateChunk)~="string" then ultraschall.AddErrorMessage("GetParmModulationTable", "FXStateChunk", "must be a string", -1) return end
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("GetParmModulationTable", "FXStateChunk", "must be a valid FXStateChunk", -2) return end
  if math.type(fxindex)~="integer" then ultraschall.AddErrorMessage("GetParmModulationTable", "fxindex", "must be an integer", -3) return end
  if fxindex<1 then ultraschall.AddErrorMessage("GetParmModulationTable", "fxindex", "must be bigger than 0", -4) return end
  
  if ultraschall.type(parmodindex)~="number: integer" then ultraschall.AddErrorMessage("GetParmModulationTable", "parmodindex", "must be an integer", -5) return end
  if parmodindex<1 then ultraschall.AddErrorMessage("GetParmModulationTable", "parmodindex", "must be bigger than 0", -6) return end
  local count=0
  local found=""
  local ParmModTable={}
  local FX,StartOFS,EndOFS=ultraschall.GetFXFromFXStateChunk(FXStateChunk, fxindex)
  
  if FX==nil then ultraschall.AddErrorMessage("GetParmModulationTable", "fxindex", "no such index", -7) return nil end
  for k in string.gmatch(FX, "\n    <PROGRAMENV.-\n    >") do
    count=count+1
    if count==parmodindex then found=k break end
  end
  if found=="" then ultraschall.AddErrorMessage("GetParmModulationTable", "parmodindex", "no such index", -8) return nil end
  found=string.gsub(found, "\n", " \n")
  
--  print_update(found)

  -- <PROGRAMENV
  ParmModTable["PARAM_NR"], ParmModTable["PARAMOD_ENABLE_PARAMETER_MODULATION"]=found:match("<PROGRAMENV (.-) (.-) ")
  if tonumber(ParmModTable["PARAM_NR"])~=nil then
    ParmModTable["PARAM_NR"]=tonumber(ParmModTable["PARAM_NR"])
    ParmModTable["PARAM_TYPE"]=""
  else
    ParmModTable["PARAM_TYPE"]=ParmModTable["PARAM_NR"]:match(":(.*)") -- removes the : separator
    ParmModTable["PARAM_NR"]=tonumber(ParmModTable["PARAM_NR"]:match("(.-):"))
  end
  ParmModTable["PARAM_NR"]=ParmModTable["PARAM_NR"]+1 -- add one to the paramnr(compared to the statechunk) so the 
                                                      -- number matches the shown fx-number in the ui of Reaper
  ParmModTable["PARAMOD_ENABLE_PARAMETER_MODULATION"]=tonumber(ParmModTable["PARAMOD_ENABLE_PARAMETER_MODULATION"])==0

  -- PARAMBASE
  ParmModTable["PARAMOD_BASELINE"]=tonumber(found:match("PARAMBASE (.-) "))
  
  ParmModTable["LFO"]=tonumber(found:match("LFO (.-) "))==1

  -- LFOWT  
  ParmModTable["LFO_STRENGTH"], 
  ParmModTable["LFO_DIRECTION"]=found:match("LFOWT (.-) (.-) ")
  ParmModTable["LFO_STRENGTH"]=tonumber(ParmModTable["LFO_STRENGTH"])
  ParmModTable["LFO_DIRECTION"]=tonumber(ParmModTable["LFO_DIRECTION"])

  -- AUDIOCTL
  ParmModTable["AUDIOCONTROL"]=tonumber(found:match("AUDIOCTL (.-) "))==1
  
  -- AUDIOCTLWT
  ParmModTable["AUDIOCONTROL_STRENGTH"], 
  ParmModTable["AUDIOCONTROL_DIRECTION"]=found:match("AUDIOCTLWT (.-) (.-) ")
  ParmModTable["AUDIOCONTROL_STRENGTH"]=tonumber(ParmModTable["AUDIOCONTROL_STRENGTH"])
  ParmModTable["AUDIOCONTROL_DIRECTION"]=tonumber(ParmModTable["AUDIOCONTROL_DIRECTION"])
  
  -- PLINK
  ParmModTable["PARMLINK_SCALE"], 
  ParmModTable["PARMLINK_LINKEDPLUGIN"],
  ParmModTable["PARMLINK_LINKEDPARMIDX"],
  ParmModTable["PARMLINK_OFFSET"]
  =found:match(" PLINK (.-) (.-) (.-) (.-) ")
  
  ParmModTable["PARMLINK_SCALE"]=tonumber(ParmModTable["PARMLINK_SCALE"])
  if ParmModTable["PARMLINK_LINKEDPLUGIN"]~=nil then
    if ParmModTable["PARMLINK_LINKEDPLUGIN"]:match(":")~=nil then 
      ParmModTable["PARMLINK_LINKEDPLUGIN"]=tonumber(ParmModTable["PARMLINK_LINKEDPLUGIN"]:match("(.-):"))+1
    else
      ParmModTable["PARMLINK_LINKEDPLUGIN"]=tonumber(ParmModTable["PARMLINK_LINKEDPLUGIN"])
    end
  end
  ParmModTable["PARMLINK_LINKEDPARMIDX"]=tonumber(ParmModTable["PARMLINK_LINKEDPARMIDX"])
  if ParmModTable["PARMLINK_LINKEDPARMIDX"]~=nil and ParmModTable["PARMLINK_LINKEDPARMIDX"]>-1 then ParmModTable["PARMLINK_LINKEDPARMIDX"]=ParmModTable["PARMLINK_LINKEDPARMIDX"]+1 end
  ParmModTable["PARMLINK_OFFSET"]=tonumber(ParmModTable["PARMLINK_OFFSET"])

  ParmModTable["PARMLINK"]=ParmModTable["PARMLINK_SCALE"]~=nil

  -- MIDIPLINK
  ParmModTable["MIDIPLINK_BUS"], 
  ParmModTable["MIDIPLINK_CHANNEL"],
  ParmModTable["MIDIPLINK_MIDICATEGORY"],
  ParmModTable["MIDIPLINK_MIDINOTE"]
  =found:match("MIDIPLINK (.-) (.-) (.-) (.-) ")
  if ParmModTable["MIDIPLINK_BUS"]~=nil then ParmModTable["MIDIPLINK_BUS"]=tonumber(ParmModTable["MIDIPLINK_BUS"])+1 end -- add 1 to match the bus-number shown in Reaper's UI
  ParmModTable["MIDIPLINK_CHANNEL"]=tonumber(ParmModTable["MIDIPLINK_CHANNEL"])
  ParmModTable["MIDIPLINK_MIDICATEGORY"]=tonumber(ParmModTable["MIDIPLINK_MIDICATEGORY"])
  ParmModTable["MIDIPLINK_MIDINOTE"]=tonumber(ParmModTable["MIDIPLINK_MIDINOTE"])

  ParmModTable["MIDIPLINK"]=ParmModTable["MIDIPLINK_MIDINOTE"]~=nil
  
  -- LFOSHAPE
  ParmModTable["LFO_SHAPE"]=tonumber(found:match("LFOSHAPE (.-) "))
  
  -- LFOSYNC
  ParmModTable["LFO_TEMPOSYNC"], 
  ParmModTable["LFO_SHAPEOLD"],
  ParmModTable["LFO_PHASERESET"]
  =found:match("LFOSYNC (.-) (.-) (.-) ")
  ParmModTable["LFO_TEMPOSYNC"] = tonumber(ParmModTable["LFO_TEMPOSYNC"])==1
  ParmModTable["LFO_SHAPEOLD"]  = tonumber(ParmModTable["LFO_SHAPEOLD"])
  ParmModTable["LFO_PHASERESET"]= tonumber(ParmModTable["LFO_PHASERESET"])
  
  -- LFOSPEED
  ParmModTable["LFO_SPEED"], 
  ParmModTable["LFO_PHASE"]
  =found:match("LFOSPEED (.-) (.-) ")
  ParmModTable["LFO_SPEED"]=tonumber(ParmModTable["LFO_SPEED"])
  ParmModTable["LFO_PHASE"]=tonumber(ParmModTable["LFO_PHASE"])
  
  if found:match("CHAN (.-) ")~=nil then
    ParmModTable["AUDIOCONTROL_CHAN"]  =tonumber(found:match("CHAN (.-) "))+1
  end
  ParmModTable["AUDIOCONTROL_STEREO"]=tonumber(found:match("STEREO (.-) "))

  -- RMS
  ParmModTable["AUDIOCONTROL_ATTACK"], 
  ParmModTable["AUDIOCONTROL_RELEASE"]
  =found:match("RMS (.-) (.-) ")
  ParmModTable["AUDIOCONTROL_ATTACK"]=tonumber(ParmModTable["AUDIOCONTROL_ATTACK"])
  ParmModTable["AUDIOCONTROL_RELEASE"]=tonumber(ParmModTable["AUDIOCONTROL_RELEASE"])
  
  --DBLO and DBHI
  ParmModTable["AUDIOCONTROL_MINVOLUME"]=tonumber(found:match("DBLO (.-) "))
  ParmModTable["AUDIOCONTROL_MAXVOLUME"]=tonumber(found:match("DBHI (.-) "))
  
  -- X2, Y2
  ParmModTable["X2"]=tonumber(found:match("X2 (.-) "))
  ParmModTable["Y2"]=tonumber(found:match("Y2 (.-) "))

  -- MODHWND
  ParmModTable["WINDOW_ALTEREDOPEN"], 
  ParmModTable["WINDOW_XPOS"],
  ParmModTable["WINDOW_YPOS"],
  ParmModTable["WINDOW_RIGHT"],
  ParmModTable["WINDOW_BOTTOM"]
  =found:match("MODWND (.-) (.-) (.-) (.-) (.-) ")
  if ParmModTable["WINDOW_ALTEREDOPEN"]==nil then ParmModTable["WINDOW_ALTERED"]=false else ParmModTable["WINDOW_ALTERED"]=true end
  ParmModTable["WINDOW_ALTEREDOPEN"]=tonumber(ParmModTable["WINDOW_ALTEREDOPEN"])==1
  ParmModTable["WINDOW_XPOS"]  =tonumber(ParmModTable["WINDOW_XPOS"])
  ParmModTable["WINDOW_YPOS"]  =tonumber(ParmModTable["WINDOW_YPOS"])
  ParmModTable["WINDOW_RIGHT"] =tonumber(ParmModTable["WINDOW_RIGHT"])
  ParmModTable["WINDOW_BOTTOM"]=tonumber(ParmModTable["WINDOW_BOTTOM"])  
  
  return ParmModTable
end

function ultraschall.CreateDefaultParmModTable()
--[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>CreateDefaultParmModTable</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>table ParmModTable = ultraschall.CreateDefaultParmModTable()</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      returns a parameter-modulation-table with default settings set.
      You can alter these settings to your needs before committing it to an FXStateChunk.
      
      The checkboxes for "Audio control signal (sidechain)", "LFO", "Link from MIDI or FX parameter" are unchecked and the fx-parameter is set to 1(the first parameter of the plugin).
      To enable and change them, alter the following entries accordingly:
        
              ParmModTable["AUDIOCONTROL"] - the checkbox for "Audio control signal (sidechain)"
              ParmModTable["LFO"]      - the checkbox for "LFO"
              ParmModTable["PARMLINK"] - the checkbox for "Link from MIDI or FX parameter"
              ParmModTable["PARAM_NR"] - the index of the fx-parameter for which the parameter-modulation-table is intended
       
      The table's format and its default-values is as follows:
          <pre><code>
                      ParamModTable["PARAM_NR"]=1              - the parameter that you want to modulate; 1 for the first, 2 for the second, etc
                      ParamModTable["PARAM_TYPE"]=""           - the type of the parameter, usually "", "wet" or "bypass"
      
                      ParamModTable["PARAMOD_ENABLE_PARAMETER_MODULATION"]=true
                                                              - Enable parameter modulation, baseline value(envelope overrides)-checkbox; 
                                                                true, checked; false, unchecked
                      ParamModTable["PARAMOD_BASELINE"]=0     - Enable parameter modulation, baseline value(envelope overrides)-slider; 
                                                                  0.000 to 1.000
      
                      ParamModTable["AUDIOCONTROL"]=false           - is the Audio control signal(sidechain)-checkbox checked; true, checked; false, unchecked
                                                                        Note: if true, this needs all AUDIOCONTROL_-entries to be set                      
                      ParamModTable["AUDIOCONTROL_CHAN"]=0          - the Track audio channel-dropdownlist; When stereo, the first stereo-channel; 
                                                                      nil, if not available
                      ParamModTable["AUDIOCONTROL_STEREO"]=0        - 0, just use mono-channels; 1, use the channel AUDIOCONTROL_CHAN plus 
                                                                        AUDIOCONTROL_CHAN+1; nil, if not available
                      ParamModTable["AUDIOCONTROL_ATTACK"]=300      - the Attack-slider of Audio Control Signal; 0-1000 ms; nil, if not available
                      ParamModTable["AUDIOCONTROL_RELEASE"]=300     - the Release-slider; 0-1000ms; nil, if not available
                      ParamModTable["AUDIOCONTROL_MINVOLUME"]=-24   - the Min volume-slider; -60dB to 11.9dB; must be smaller than AUDIOCONTROL_MAXVOLUME; 
                                                                        nil, if not available
                      ParamModTable["AUDIOCONTROL_MAXVOLUME"]=0     - the Max volume-slider; -59.9dB to 12dB; must be bigger than AUDIOCONTROL_MINVOLUME; 
                                                                        nil, if not available
                      ParamModTable["AUDIOCONTROL_STRENGTH"]=1      - the Strength-slider; 0(0%) to 1000(100%)
                      ParamModTable["AUDIOCONTROL_DIRECTION"]=1     - the direction-radiobuttons; -1, negative; 0, centered; 1, positive
      
                      ParamModTable["LFO"]=false                    - if the LFO-checkbox checked; true, checked; false, unchecked
                                                                       Note: if true, this needs all LFO_-entries to be set
                      ParamModTable["LFO_SHAPE"]=0                  - the LFO Shape-dropdownlist; 
                                                                       0, sine; 1, square; 2, saw L; 3, saw R; 4, triangle; 5, random
                                                                       nil, if not available
                      ParamModTable["LFO_SHAPEOLD"]=0              - use the old-style of the LFO_SHAPE; 
                                                                      0, use current style of LFO_SHAPE; 
                                                                      1, use old style of LFO_SHAPE; 
                                                                      nil, if not available
                      ParamModTable["LFO_TEMPOSYNC"]=false         - the Tempo sync-checkbox; true, checked; false, unchecked
                      ParamModTable["LFO_SPEED"]=0.124573          - the LFO Speed-slider; 0(0.0039Hz) to 1(8.0000Hz); nil, if not available
                      ParamModTable["LFO_STRENGTH"]=1              - the LFO Strength-slider; 0.000(0.0%) to 1.000(100.0%)
                      ParamModTable["LFO_PHASE"]=0                 - the LFO Phase-slider; 0.000 to 1.000; nil, if not available
                      ParamModTable["LFO_DIRECTION"]=1             - the LFO Direction-radiobuttons; -1, Negative; 0, Centered; 1, Positive
                      ParamModTable["LFO_PHASERESET"]=0            - the LFO Phase reset-dropdownlist; 
                                                                      0, On seek/loop(deterministic output)
                                                                      1, Free-running(non-deterministic output)
                                                                      nil, if not available
      
                      ParamModTable["PARMLINK"]=false              - the Link from MIDI or FX parameter-checkbox
                                                                      true, checked; false, unchecked
                      ParamModTable["PARMLINK_LINKEDPLUGIN"]=-1    - the selected plugin; nil, if not available
                                                                      -1, nothing selected yet
                                                                      -100, MIDI-parameter-settings
                                                                      1 - the first fx-plugin
                                                                      2 - the second fx-plugin
                                                                      3 - the third fx-plugin, etc
                      ParamModTable["PARMLINK_LINKEDPARMIDX"]=-1   - the id of the linked parameter; -1, if none is linked yet; nil, if not available
                                                                      When MIDI, this is irrelevant.
                                                                      When FX-parameter:
                                                                        0 to n; 0 for the first; 1, for the second, etc
      
                      ParamModTable["PARMLINK_OFFSET"]=0           - the Offset-slider; -1.00(-100%) to 1.00(+100%); nil, if not available
                      ParamModTable["PARMLINK_SCALE"]=1            - the Scale-slider; -1.00(-100%) to 1.00(+100%); nil, if not available
      
      
                      ParamModTable["MIDIPLINK"]=false             - true, if any parameter-linking with MIDI-stuff; false, if not
                                                                     Note: if true, this needs all MIDIPLINK_-entries and PARMLINK_LINKEDPLUGIN=-100 to be set
                      ParamModTable["MIDIPLINK_BUS"]=nil           - the MIDI-bus selected in the button-menu; 
                                                                      0 to 15 for bus 1 to 16; 
                                                                      nil, if not available
                      ParamModTable["MIDIPLINK_CHANNEL"]=nil       - the MIDI-channel selected in the button-menu; 
                                                                      0, omni; 1 to 16 for channel 1 to 16; 
                                                                      nil, if not available
                                                                     
                      ParamModTable["MIDIPLINK_MIDICATEGORY"]=nil  - the MIDI_Category selected in the button-menu; nil, if not available
                                                                      144, MIDI note
                                                                      160, Aftertouch
                                                                      176, CC 14Bit and CC
                                                                      192, Program Change
                                                                      208, Channel Pressure
                                                                      224, Pitch
                      ParamModTable["MIDIPLINK_MIDINOTE"]=nil      - the MIDI-note selected in the button-menu; nil, if not available
                                                                      When MIDI note:
                                                                         0(C-2) to 127(G8)
                                                                      When Aftertouch:
                                                                         0(C-2) to 127(G8)
                                                                      When CC14 Bit:
                                                                         128 to 159; see dropdownlist for the commands(the order of the list 
                                                                         is the same as this numbering)
                                                                      When CC:
                                                                         0 to 119; see dropdownlist for the commands(the order of the list 
                                                                         is the same as this numbering)
                                                                      When Program Change:
                                                                         0
                                                                      When Channel Pressure:
                                                                         0
                                                                      When Pitch:
                                                                         0
                      ParamModTable["WINDOW_ALTERED"]=false         - false, if the windowposition hasn't been altered yet; true, if the window has been altered
                                                                        Note: if true, this needs all WINDOW_-entries to be set
                      ParamModTable["WINDOW_ALTEREDOPEN"]=true      - if the position of the ParmMod-window is altered and currently open; 
                                                                       nil, unchanged; 0, unopened; 1, open
                      ParamModTable["WINDOW_XPOS"]=0                - the x-position of the altered ParmMod-window in pixels; nil, default position
                      ParamModTable["WINDOW_YPOS"]=40               - the y-position of the altered ParmMod-window in pixels; nil, default position
                      ParamModTable["WINDOW_RIGHT"]=594             - the right-position of the altered ParmMod-window in pixels; 
                                                                       nil, default position; only readable
                      ParamModTable["WINDOW_BOTTOM"]=729            - the bottom-position of the altered ParmMod-window in pixels; 
                                                                       nil, default position; only readable
          </code></pre>
    </description>
    <retvals>
      integer number_of_parmmodulations - the number of parameter-modulations available for this fx within this FXStateChunk
    </retvals>
    <parameters>
      string FXStateChunk - the FXStateChunk from which you want to count the parameter-modulations available for a specific fx
      integer fxindex - the index of the fx, whose number of parameter-modulations you want to know
    </parameters>
    <chapter_context>
      FX-Management
      Parameter Modulation
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
    <tags>fxmanagement, create, default, parameter modulation</tags>
  </US_DocBloc>
  --]] 
  
  local ParmModTable={}
  ParmModTable["AUDIOCONTROL_RELEASE"]=300
  ParmModTable["PARMLINK_LINKEDPLUGIN"]=-1
  ParmModTable["LFO_STRENGTH"]=1
  ParmModTable["LFO_SPEED"]=0.124573
  ParmModTable["WINDOW_ALTERED"]=false
  ParmModTable["AUDIOCONTROL_DIRECTION"]=1
  ParmModTable["AUDIOCONTROL_CHAN"]=0
  ParmModTable["AUDIOCONTROL_MINVOLUME"]=-24
  ParmModTable["AUDIOCONTROL_MAXVOLUME"]=0
  ParmModTable["AUDIOCONTROL_ATTACK"]=300
  ParmModTable["PARAMOD_ENABLE_PARAMETER_MODULATION"]=true
  ParmModTable["LFO_SHAPEOLD"]=0
  ParmModTable["WINDOW_ALTEREDOPEN"]=true
  ParmModTable["PARAMOD_BASELINE"]=0
  ParmModTable["PARMLINK_LINKEDPARMIDX"]=-1
  ParmModTable["LFO_TEMPOSYNC"]=false
  ParmModTable["Y2"]=0.5
  ParmModTable["PARMLINK_OFFSET"]=0
  ParmModTable["WINDOW_YPOS"]=40
  ParmModTable["AUDIOCONTROL"]=false
  ParmModTable["WINDOW_XPOS"]=0
  ParmModTable["LFO"]=false
  ParmModTable["WINDOW_BOTTOM"]=729
  ParmModTable["LFO_DIRECTION"]=1
  ParmModTable["WINDOW_RIGHT"]=594
  ParmModTable["X2"]=0.5
  ParmModTable["PARAM_NR"]=1
  ParmModTable["MIDIPLINK"]=false
  ParmModTable["AUDIOCONTROL_STEREO"]=0
  ParmModTable["LFO_SHAPE"]=0
  ParmModTable["LFO_PHASE"]=0
  ParmModTable["AUDIOCONTROL_STRENGTH"]=1
  ParmModTable["PARMLINK_SCALE"]=1
  ParmModTable["PARMLINK"]=false
  ParmModTable["PARAM_TYPE"]=""
  ParmModTable["LFO_PHASERESET"]=0
  
  return ParmModTable
end

function ultraschall.IsValidParmModTable(ParmModTable)
--[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>IsValidParmModTable</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.IsValidParmModTable(table ParmModTable)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      checks, if a ParmModTable is a valid one
      
      Does not check, if the value-ranges are valid, only if the datatypes are correct and if certain combinations are valid!
      
      Use SLEM() to get error-messages who tell you, which entries are problematic.
      
      returns false in case of an error
    </description>
    <retvals>
      boolean retval - true, ParmModTable is a valid one; false, ParmModTable has errors(use SLEM() to get which one)
    </retvals>
    <parameters>
      table ParmModTable - the table to check, if it's a valid ParmModTable
    </parameters>
    <chapter_context>
      FX-Management
      Parameter Modulation
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
    <tags>fxmanagement, check, parameter modulation, parmmodtable</tags>
  </US_DocBloc>
  --]] 
  -- check if table is valid in the first place
  if ParmModTable==nil then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModTable", "Warning: empty ParmModTable. This will remove a parameter-modulation if applied.", -100) return true end
  if type(ParmModTable)~="table" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModTable", "must be a table", -1) return false end
  
  -- check, if the contents of the table have valid datatypes
  if type(ParmModTable["AUDIOCONTROL"])~="boolean" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry AUDIOCONTROL must be boolean", -2 ) return false end
  if math.type(ParmModTable["AUDIOCONTROL_ATTACK"])~=nil and math.type(ParmModTable["AUDIOCONTROL_ATTACK"])~="integer" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry AUDIOCONTROL_ATTACK must either nil or be integer", -3 ) return false end
  if ParmModTable["AUDIOCONTROL_CHAN"]~=nil and math.type(ParmModTable["AUDIOCONTROL_CHAN"])~="integer" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry AUDIOCONTROL_CHAN must be either nil or integer", -4) return false end
  if ParmModTable["AUDIOCONTROL_DIRECTION"]~=nil and math.type(ParmModTable["AUDIOCONTROL_DIRECTION"])~="integer" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry AUDIOCONTROL_DIRECTION must be either nil or an integer", -5 ) return false end
  if ParmModTable["AUDIOCONTROL_MAXVOLUME"]~=nil and type(ParmModTable["AUDIOCONTROL_MAXVOLUME"])~="number" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry AUDIOCONTROL_MAXVOLUME must be either nil or a number", -6 ) return false end
  if ParmModTable["AUDIOCONTROL_MINVOLUME"]~=nil and type(ParmModTable["AUDIOCONTROL_MINVOLUME"])~="number" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry AUDIOCONTROL MINVOLUME must be either nil or a number", -7 ) return false end
  if ParmModTable["AUDIOCONTROL_RELEASE"]~=nil and math.type(ParmModTable["AUDIOCONTROL_RELEASE"])~="integer" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry AUDIOCONTROL_RELEASE must be either nil or an integer", -8 ) return false end
  if ParmModTable["AUDIOCONTROL_STEREO"]~=nil and math.type(ParmModTable["AUDIOCONTROL_STEREO"])~="integer" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry AUDIOCONTROL_STEREO must be either nil or an integer", -9 ) return false end
  if type(ParmModTable["AUDIOCONTROL_STRENGTH"])~="number" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry AUDIOCONTROL_STRENGTH must be a number", -10 ) return false end
  if type(ParmModTable["LFO"])~="boolean" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry LFO must be a boolean", -11 ) return false end
  if math.type(ParmModTable["LFO_DIRECTION"])~="integer" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry LFO_DIRECTION must be an integer", -12 ) return false end
  if ParmModTable["LFO_PHASE"]~=nil and type(ParmModTable["LFO_PHASE"])~="number" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry LFO_PHASE must be either nil or a number", -13 ) return false end
  if ParmModTable["LFO_PHASERESET"]~=nil and math.type(ParmModTable["LFO_PHASERESET"])~="integer" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry LFO PHASERESET must be either nil or an integer", -14 ) return false end
  if ParmModTable["LFO_SHAPE"]~=nil and math.type(ParmModTable["LFO_SHAPE"])~="integer" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry LFO_SHAPE must be either nil or an integer", -15 ) return false end
  if ParmModTable["LFO_SHAPEOLD"]~=nil and math.type(ParmModTable["LFO_SHAPEOLD"])~="integer" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry LFO_SHAPEOLD must be either nil or an integer", -16 ) return false end
  if ParmModTable["LFO_SPEED"]~=nil and type(ParmModTable["LFO_SPEED"])~="number" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry LFO_SPEED must be either nil or a number", -17 ) return false end
  if type(ParmModTable["LFO_STRENGTH"])~="number" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry LFO_STRENGTH must be a number", -18 ) return false end
  if type(ParmModTable["LFO_TEMPOSYNC"])~="boolean" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry LFO_TEMPOSYNC must be a boolean", -19 ) return false end
  if type(ParmModTable["MIDIPLINK"])~="boolean" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry MIDIPLINK must be a boolean", -20 ) return false end
  if ParmModTable["MIDIPLINK_BUS"]~=nil and math.type(ParmModTable["MIDIPLINK_BUS"])~="integer" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry MIDIPLINK_BUS must be either nil or an integer", -21 ) return false end
  if ParmModTable["MIDIPLINK_CHANNEL"]~=nil and math.type(ParmModTable["MIDIPLINK_CHANNEL"])~="integer" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry MIDIPLINK_CHANNEL must be either nil or an integer", -22 ) return false end
  if ParmModTable["MIDIPLINK_MIDICATEGORY"]~=nil and math.type(ParmModTable["MIDIPLINK_MIDICATEGORY"])~="integer" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry MIDIPLINK_MIDICATEGORY must be either nil or an integer", -23 ) return false end
  if ParmModTable["MIDIPLINK_MIDINOTE"]~=nil and math.type(ParmModTable["MIDIPLINK_MIDINOTE"])~="integer" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry MIDIPLINK_MIDINOTE must be either nil or an integer", -24 ) return false end
  if math.type(ParmModTable["PARAM_NR"])~="integer" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry PARAM_NR must be an integer", -25 ) return false end
  if type(ParmModTable["PARAM_TYPE"])~="string" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry PARAM_TYPE must be wet or bypass or empty string", -26 ) return false end
  if type(ParmModTable["PARAMOD_BASELINE"])~="number" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry PARAMOD_BASELINE must be a number", -27 ) return false end
  if type(ParmModTable["PARAMOD_ENABLE_PARAMETER_MODULATION"])~="boolean" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry PARAMOD_ENABLE_PARAMETER_MODULATION must be boolean", -28 ) return false end
  if type(ParmModTable["PARMLINK"])~="boolean" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry PARMLINK must be a boolean", -29 ) return false end
  if ParmModTable["PARMLINK_LINKEDPARMIDX"]~=nil and math.type(ParmModTable["PARMLINK_LINKEDPARMIDX"])~="integer" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry PARMLINK_LINKEDPARMIDX must be either nil or an integer", -30 ) return false end
  if ParmModTable["PARMLINK_LINKEDPLUGIN"]~=nil and math.type(ParmModTable["PARMLINK_LINKEDPLUGIN"])~="integer" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry PARMLINK_LINKEDPLUGIN must be either nil or an integer", -31 ) return false end
  if ParmModTable["PARMLINK_OFFSET"]~=nil and type(ParmModTable["PARMLINK_OFFSET"])~="number" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry PARMLINK_OFFSET must be either nil or a number", -32 ) return false end
  if ParmModTable["PARMLINK_SCALE"]~=nil and type(ParmModTable["PARMLINK_SCALE"])~="number" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry PARMLINK_SCALE must be either nil or a number", -33 ) return false end
  if type(ParmModTable["WINDOW_ALTERED"])~="boolean" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry WINDOW_ALTERED must be boolean", -34 ) return false end
  if ParmModTable["WINDOW_ALTEREDOPEN"]~=nil and type(ParmModTable["WINDOW_ALTEREDOPEN"])~="boolean" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry WINDOW_ALTEREDOPEN must be either nil or a boolean", -35 ) return false end
  if ParmModTable["WINDOW_BOTTOM"]~=nil and math.type(ParmModTable["WINDOW_BOTTOM"])~="integer" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry WINDOW_BOTTOM must be either nil or an integer", -36 ) return false end
  if ParmModTable["WINDOW_RIGHT"]~=nil and math.type(ParmModTable["WINDOW_RIGHT"])~="integer" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry WINDOW_RIGHT must be either nil or an integer", -37 ) return false end
  if ParmModTable["WINDOW_XPOS"]~=nil and math.type(ParmModTable["WINDOW_XPOS"])~="integer" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry WINDOW_XPOS must be either nil or an integer", -38 ) return false end
  if ParmModTable["WINDOW_YPOS"]~=nil and math.type(ParmModTable["WINDOW_YPOS"])~="integer" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry WINDOW_YPOS must be either nil or an integer", -39 ) return false end
  if ParmModTable["X2"]~=nil and type(ParmModTable["X2"])~="number" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry X2 must be either nil or a number", -40 ) return false end
  if ParmModTable["Y2"]~=nil and type(ParmModTable["Y2"])~="number" then ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry Y2 must be either nil or a number", -41 ) return false end
  
  -- check, if certain combinations are valid, like LFO-checkbox=true but some LFO-settings are still set to nil
  if ParmModTable["PARMLINK"]==true then
    local errormsg=""
    if ParmModTable["PARMLINK_LINKEDPARMIDX"]==nil then errormsg=errormsg.."PARMLINK_LINKEDPARMIDX, " end
    if ParmModTable["PARMLINK_LINKEDPLUGIN"]==nil then  errormsg=errormsg.."PARMLINK_LINKEDPLUGIN, " end
    if ParmModTable["PARMLINK_OFFSET"]==nil then        errormsg=errormsg.."PARMLINK_OFFSET, " end
    if ParmModTable["PARMLINK_SCALE"]==nil then         errormsg=errormsg.."PARMLINK_SCALE, " end
    if errormsg~="" then
      ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry PARMLINK=true but "..errormsg:sub(1,-3).." is still set to nil", -46 ) 
      return false
    end
  end

  if ParmModTable["MIDIPLINK"]==true then
    if ParmModTable["PARMLINK_LINKEDPLUGIN"]~=-100 then
       ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry MIDIPLINK=true but PARMLINK_LINKEDPLUGIN is not set to -100", -43 ) return false
    end
    local errormsg=""
    if ParmModTable["MIDIPLINK_BUS"]==nil then           errormsg=errormsg.."MIDIPLINK_BUS, " end
    if ParmModTable["MIDIPLINK_CHANNEL"]==nil then       errormsg=errormsg.."MIDIPLINK_CHANNEL, " end
    if ParmModTable["MIDIPLINK_MIDICATEGORY"]==nil then  errormsg=errormsg.."MIDIPLINK_MIDICATEGORY, " end
    if ParmModTable["MIDIPLINK_MIDINOTE"]==nil then      errormsg=errormsg.."MIDIPLINK_MIDINOTE, " end
    if errormsg~="" then
      ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry MIDIPLINK=true but "..errormsg:sub(1,-3).." is still set to nil", -46 ) 
      return false
    end
  end
  
  if ParmModTable["LFO"]==true then
    local errormsg=""
    if ParmModTable["LFO_PHASE"]==nil then       errormsg=errormsg.."LFO_PHASE, " end
    if ParmModTable["LFO_PHASERESET"]==nil then  errormsg=errormsg.."LFO_PHASERESET, " end
    if ParmModTable["LFO_SHAPE"]==nil then       errormsg=errormsg.."LFO_SHAPE, " end
    if ParmModTable["LFO_SHAPEOLD"]==nil then    errormsg=errormsg.."LFO_SHAPEOLD, " end
    if ParmModTable["LFO_SPEED"]==nil then       errormsg=errormsg.."LFO_SPEED, " end
    if errormsg~="" then
      ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry LFO=true but "..errormsg:sub(1,-3).." is still set to nil", -46 ) 
      return false
    end
  end
  
  if ParmModTable["WINDOW_ALTERED"]==true then
    local errormsg=""
    if ParmModTable["WINDOW_ALTEREDOPEN"]==nil then errormsg=errormsg.."WINDOW_ALTEREDOPEN, " end
    if ParmModTable["WINDOW_BOTTOM"]==nil then      errormsg=errormsg.."WINDOW_BOTTOM, " end
    if ParmModTable["WINDOW_RIGHT"]==nil then       errormsg=errormsg.."WINDOW_RIGHT, " end
    if ParmModTable["WINDOW_XPOS"]==nil then        errormsg=errormsg.."WINDOW_XPOS, " end
    if ParmModTable["WINDOW_YPOS"]==nil then        errormsg=errormsg.."WINDOW_YPOS, " end
    if errormsg~="" then
      ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry WINDOW_ALTERED=true but "..errormsg:sub(1,-3).." is still set to nil", -46 ) 
      return false
    end
  end

  if ParmModTable["AUDIOCONTROL"]==true then
    local errormsg=""
    if ParmModTable["AUDIOCONTROL_ATTACK"]==nil then    errormsg=errormsg.."AUDIOCONTROL_ATTACK, " end
    if ParmModTable["AUDIOCONTROL_CHAN"]==nil then      errormsg=errormsg.."AUDIOCONTROL_CHAN, " end
    if ParmModTable["AUDIOCONTROL_MAXVOLUME"]==nil then errormsg=errormsg.."AUDIOCONTROL_MAXVOLUME, " end
    if ParmModTable["AUDIOCONTROL_MINVOLUME"]==nil then errormsg=errormsg.."AUDIOCONTROL_MINVOLUME, " end
    if ParmModTable["AUDIOCONTROL_RELEASE"]==nil   then errormsg=errormsg.."AUDIOCONTROL_RELEASE, " end
    if ParmModTable["AUDIOCONTROL_STEREO"]==nil then    errormsg=errormsg.."AUDIOCONTROL_STEREO, " end
    if errormsg~="" then 
      ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry AUDIOCONTROL=true but "..errormsg:sub(1,-3).." is still set to nil", -47 ) 
      return false
    end
  end
  
  if ParmModTable["MIDIPLINK"]==false and ParmModTable["PARMLINK_LINKEDPLUGIN"]==-100 then
    ultraschall.AddErrorMessage("IsValidParmModTable", "ParmModulationTable", "Entry PARMLINK_LINKEDPLUGIN=-100(linked plugin is MIDI) but MIDIPLINK(selected MIDI-plugin) is set to false", -48 ) return false
  end
  return true
end

function ultraschall.AddParmModulationTable(FXStateChunk, fxindex, ParmModTable)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AddParmModulationTable</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>string FXStateChunk = ultraschall.AddParmModulationTable(string FXStateChunk, integer fxindex, table ParmModTable)</functioncall>
  <description>
    Takes a ParmModTable and adds with its values a new Parameter Modulation of a specifix fx within an FXStateChunk.
  
    The expected table's format is as follows:
    <pre><code>
                ParamModTable["PARAM_NR"]               - the parameter that you want to modulate; 1 for the first, 2 for the second, etc
                ParamModTable["PARAM_TYPE"]             - the type of the parameter, usually "", "wet" or "bypass"

                ParamModTable["PARAMOD_ENABLE_PARAMETER_MODULATION"] 
                                                        - Enable parameter modulation, baseline value(envelope overrides)-checkbox; 
                                                          true, checked; false, unchecked
                ParamModTable["PARAMOD_BASELINE"]       - Enable parameter modulation, baseline value(envelope overrides)-slider; 
                                                            0.000 to 1.000

                ParamModTable["AUDIOCONTROL"]           - is the Audio control signal(sidechain)-checkbox checked; true, checked; false, unchecked
                                                            Note: if true, this needs all AUDIOCONTROL_-entries to be set                
                ParamModTable["AUDIOCONTROL_CHAN"]      - the Track audio channel-dropdownlist; When stereo, the first stereo-channel; 
                                                          nil, if not available
                ParamModTable["AUDIOCONTROL_STEREO"]    - 0, just use mono-channels; 1, use the channel AUDIOCONTROL_CHAN plus 
                                                            AUDIOCONTROL_CHAN+1; nil, if not available
                ParamModTable["AUDIOCONTROL_ATTACK"]    - the Attack-slider of Audio Control Signal; 0-1000 ms; nil, if not available
                ParamModTable["AUDIOCONTROL_RELEASE"]   - the Release-slider; 0-1000ms; nil, if not available
                ParamModTable["AUDIOCONTROL_MINVOLUME"] - the Min volume-slider; -60dB to 11.9dB; must be smaller than AUDIOCONTROL_MAXVOLUME; 
                                                          nil, if not available
                ParamModTable["AUDIOCONTROL_MAXVOLUME"] - the Max volume-slider; -59.9dB to 12dB; must be bigger than AUDIOCONTROL_MINVOLUME; 
                                                          nil, if not available
                ParamModTable["AUDIOCONTROL_STRENGTH"]  - the Strength-slider; 0(0%) to 1000(100%)
                ParamModTable["AUDIOCONTROL_DIRECTION"] - the direction-radiobuttons; -1, negative; 0, centered; 1, positive

                ParamModTable["LFO"]                    - if the LFO-checkbox checked; true, checked; false, unchecked
                                                            Note: if true, this needs all LFO_-entries to be set
                ParamModTable["LFO_SHAPE"]              - the LFO Shape-dropdownlist; 
                                                            0, sine; 1, square; 2, saw L; 3, saw R; 4, triangle; 5, random
                                                            nil, if not available
                ParamModTable["LFO_SHAPEOLD"]           - use the old-style of the LFO_SHAPE; 
                                                            0, use current style of LFO_SHAPE; 
                                                            1, use old style of LFO_SHAPE; 
                                                            nil, if not available
                ParamModTable["LFO_TEMPOSYNC"]          - the Tempo sync-checkbox; true, checked; false, unchecked
                ParamModTable["LFO_SPEED"]              - the LFO Speed-slider; 0(0.0039Hz) to 1(8.0000Hz); nil, if not available
                ParamModTable["LFO_STRENGTH"]           - the LFO Strength-slider; 0.000(0.0%) to 1.000(100.0%)
                ParamModTable["LFO_PHASE"]              - the LFO Phase-slider; 0.000 to 1.000; nil, if not available
                ParamModTable["LFO_DIRECTION"]          - the LFO Direction-radiobuttons; -1, Negative; 0, Centered; 1, Positive
                ParamModTable["LFO_PHASERESET"]         - the LFO Phase reset-dropdownlist; 
                                                            0, On seek/loop(deterministic output)
                                                            1, Free-running(non-deterministic output)
                                                            nil, if not available
                
                ParamModTable["MIDIPLINK"]              - true, if any parameter-linking with MIDI-stuff; false, if not
                                                            Note: if true, this needs all MIDIPLINK_-entries and PARMLINK_LINKEDPLUGIN=-100 to be set
                ParamModTable["PARMLINK"]               - the Link from MIDI or FX parameter-checkbox
                                                          true, checked; false, unchecked
                ParamModTable["PARMLINK_LINKEDPLUGIN"]  - the selected plugin; nil, if not available
                                                            -1, nothing selected yet
                                                            -100, MIDI-parameter-settings
                                                            1 - the first fx-plugin
                                                            2 - the second fx-plugin
                                                            3 - the third fx-plugin, etc
                ParamModTable["PARMLINK_LINKEDPARMIDX"] - the id of the linked parameter; -1, if none is linked yet; nil, if not available
                                                            When MIDI, this is irrelevant.
                                                            When FX-parameter:
                                                              0 to n; 0 for the first; 1, for the second, etc

                ParamModTable["PARMLINK_OFFSET"]        - the Offset-slider; -1.00(-100%) to 1.00(+100%); nil, if not available
                ParamModTable["PARMLINK_SCALE"]         - the Scale-slider; -1.00(-100%) to 1.00(+100%); nil, if not available

                ParamModTable["MIDIPLINK"]              - true, if any parameter-linking with MIDI-stuff; false, if not
                                                            Note: if true, this needs all MIDIPLINK_-entries and PARMLINK_LINKEDPLUGIN=-100 to be set
                ParamModTable["MIDIPLINK_BUS"]          - the MIDI-bus selected in the button-menu; 
                                                            0 to 15 for bus 1 to 16; 
                                                            nil, if not available
                ParamModTable["MIDIPLINK_CHANNEL"]      - the MIDI-channel selected in the button-menu; 
                                                            0, omni; 1 to 16 for channel 1 to 16; 
                                                            nil, if not available
                ParamModTable["MIDIPLINK_MIDICATEGORY"] - the MIDI_Category selected in the button-menu; nil, if not available
                                                            144, MIDI note
                                                            160, Aftertouch
                                                            176, CC 14Bit and CC
                                                            192, Program Change
                                                            208, Channel Pressure
                                                            224, Pitch
                ParamModTable["MIDIPLINK_MIDINOTE"]     - the MIDI-note selected in the button-menu; nil, if not available
                                                          When MIDI note:
                                                               0(C-2) to 127(G8)
                                                          When Aftertouch:
                                                               0(C-2) to 127(G8)
                                                          When CC14 Bit:
                                                               128 to 159; see dropdownlist for the commands(the order of the list 
                                                               is the same as this numbering)
                                                          When CC:
                                                               0 to 119; see dropdownlist for the commands(the order of the list 
                                                               is the same as this numbering)
                                                          When Program Change:
                                                               0
                                                          When Channel Pressure:
                                                               0
                                                          When Pitch:
                                                               0
                ParamModTable["WINDOW_ALTERED"]         - false, if the windowposition hasn't been altered yet; true, if the window has been altered
                                                            Note: if true, this needs all WINDOW_-entries to be set
                ParamModTable["WINDOW_ALTEREDOPEN"]     - if the position of the ParmMod-window is altered and currently open; 
                                                            nil, unchanged; 0, unopened; 1, open
                ParamModTable["WINDOW_XPOS"]            - the x-position of the altered ParmMod-window in pixels; nil, default position
                ParamModTable["WINDOW_YPOS"]            - the y-position of the altered ParmMod-window in pixels; nil, default position
                ParamModTable["WINDOW_RIGHT"]           - the right-position of the altered ParmMod-window in pixels; 
                                                            nil, default position; only readable
                ParamModTable["WINDOW_BOTTOM"]          - the bottom-position of the altered ParmMod-window in pixels; 
                                                            nil, default position; only readable
    </code></pre>
    
    This function does not check, if the values are within valid value-ranges, only if the datatypes are valid.
    
    returns nil in case of an error
  </description>
  <parameters>
    string FXStateChunk - an FXStateChunk, of which you want to add the values of a specific parameter-modulation
    integer fxindex - the index of the fx, of which you want to add specific parameter-modulation-values
    table ParmModTable - the table which holds all parameter-modulation-values to be added
  </parameters>
  <retvals>
    string FXStateChunk - the altered FXStateChunk, where the ParameterModulation shall be added
  </retvals>
  <chapter_context>
    FX-Management
    Parameter Modulation
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fxmanagement, set, parameter modulation, table, fxstatechunk</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidParmModTable(ParmModTable)==false then ultraschall.AddErrorMessage("AddParmModulationTable", "ParmModTable", SLEM(nil, 3, 5), -1) return FXStateChunk end
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("AddParmModulationTable", "FXStateChunk", "must be a valid FXStateChunk", -2) return FXStateChunk end
  
  if math.type(fxindex)~="integer" then ultraschall.AddErrorMessage("AddParmModulationTable", "fxindex", "must be an integer", -3) return FXStateChunk end
  if fxindex<1 then ultraschall.AddErrorMessage("AddParmModulationTable", "fxindex", "must be bigger than 0", -4) return FXStateChunk end
    
  local NewParmModTable=""
  if ParmModTable~=nil and (ParmModTable["PARMLINK"]==true or ParmModTable["LFO"]==true or ParmModTable["AUDIOCONTROL"]==true) then
    local Sep=""
    local LFO, AudioControl, LinkedPlugin, offset, ParmModEnable, LFOTempoSync, WindowAlteredOpen
    if ParmModTable["PARAM_TYPE"]~="" then Sep=":" end
    if ParmModTable["PARAMOD_ENABLE_PARAMETER_MODULATION"]==true then ParmModEnable=0 else ParmModEnable=1 end
    if ParmModTable["LFO"]==true then LFO=1 else LFO=0 end
    if ParmModTable["AUDIOCONTROL"]==true then AudioControl=1 else AudioControl=0 end
    
    NewParmModTable=
    " <PROGRAMENV "..(tonumber(ParmModTable["PARAM_NR"])-1)..Sep..ParmModTable["PARAM_TYPE"].." "..ParmModEnable.."\n"..
    "      PARAMBASE " ..ParmModTable["PARAMOD_BASELINE"].."\n"..
    "      LFO "       ..LFO.."\n"..
    "      LFOWT "     ..ParmModTable["LFO_STRENGTH"].." "..ParmModTable["LFO_DIRECTION"].."\n"..
    "      AUDIOCTL "  ..AudioControl.."\n"..
    "      AUDIOCTLWT "..ParmModTable["AUDIOCONTROL_STRENGTH"].." "..ParmModTable["AUDIOCONTROL_DIRECTION"].."\n"
    
    -- if ParameterLinking is enabled, then add this line
    if ParmModTable["PARMLINK"]==true then 
      if ParmModTable["PARMLINK_LINKEDPLUGIN"]>=0 then
        LinkedPlugin=(ParmModTable["PARMLINK_LINKEDPLUGIN"]-1)..":"..(ParmModTable["PARMLINK_LINKEDPLUGIN"]-1)
      else
        LinkedPlugin=tostring(ParmModTable["PARMLINK_LINKEDPLUGIN"])
      end
      if ParmModTable["PARMLINK_LINKEDPARMIDX"]==-1 then offset=0 else offset=1 end
      NewParmModTable=NewParmModTable..
    "      PLINK "..ParmModTable["PARMLINK_SCALE"].." "..LinkedPlugin.." "..(ParmModTable["PARMLINK_LINKEDPARMIDX"]-offset).." "..ParmModTable["PARMLINK_OFFSET"].."\n"
    
      -- if midi-parameter is linked, then add this line
      if ParmModTable["PARMLINK_LINKEDPLUGIN"]<-1 then
        NewParmModTable=NewParmModTable.."      MIDIPLINK "..(ParmModTable["MIDIPLINK_BUS"]-1).." "..ParmModTable["MIDIPLINK_CHANNEL"].." "..ParmModTable["MIDIPLINK_MIDICATEGORY"].." "..ParmModTable["MIDIPLINK_MIDINOTE"].."\n"
      end
    end
    
    -- if LFO is turned on, add these lines
    if ParmModTable["LFO"]==true then
      if ParmModTable["LFO_TEMPOSYNC"]==true then LFOTempoSync=1 else LFOTempoSync=0 end
      NewParmModTable=NewParmModTable..
    "      LFOSHAPE "..ParmModTable["LFO_SHAPE"].."\n"..
    "      LFOSYNC " ..LFOTempoSync.." "..ParmModTable["LFO_SHAPEOLD"].." "..ParmModTable["LFO_PHASERESET"].."\n"..
    "      LFOSPEED "..ParmModTable["LFO_SPEED"].." "..ParmModTable["LFO_PHASE"].."\n"
    end
    
    -- if Audio Control Signal(sidechain) is enabled, add these lines
    if ParmModTable["AUDIOCONTROL"]==true then
      NewParmModTable=NewParmModTable..
    "      CHAN "  ..(ParmModTable["AUDIOCONTROL_CHAN"]-1).."\n"..
    "      STEREO "..(ParmModTable["AUDIOCONTROL_STEREO"]).."\n"..
    "      RMS "   ..(ParmModTable["AUDIOCONTROL_ATTACK"]).." "..(ParmModTable["AUDIOCONTROL_RELEASE"]).."\n"..
    "      DBLO "  ..(ParmModTable["AUDIOCONTROL_MINVOLUME"]).."\n"..
    "      DBHI "  ..(ParmModTable["AUDIOCONTROL_MAXVOLUME"]).."\n"..
    "      X2 "    ..(ParmModTable["X2"]).."\n"..
    "      Y2 "    ..(ParmModTable["Y2"]).."\n"
    end
    
    -- if the window shall be modified, add these lines
    if ParmModTable["WINDOW_ALTERED"]==true then
      if ParmModTable["WINDOW_ALTEREDOPEN"]==true then 
        WindowAlteredOpen=1
      else
        WindowAlteredOpen=0
      end
      
      NewParmModTable=NewParmModTable..
    "      MODWND "..WindowAlteredOpen.." "..ParmModTable["WINDOW_XPOS"].." "..ParmModTable["WINDOW_YPOS"].." "..ParmModTable["WINDOW_RIGHT"].." "..ParmModTable["WINDOW_BOTTOM"].."\n"
    end
    
    NewParmModTable=NewParmModTable.."    >\n"
  end
  local cindex=0

  local FX,StartOFS,EndOFS=ultraschall.GetFXFromFXStateChunk(FXStateChunk, fxindex)
  
  FX=FX:match("(.*\n%s-)%sWAK")..NewParmModTable..FX:match("%s-WAK.*")

  return string.gsub(FXStateChunk:sub(1,StartOFS)..FX.."\n"..FXStateChunk:sub(EndOFS, -1), "\n\n", "\n")
end


function ultraschall.SetParmModulationTable(FXStateChunk, fxindex, parmodindex, ParmModTable)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetParmModulationTable</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>string FXStateChunk = ultraschall.SetParmModulationTable(string FXStateChunk, integer fxindex, integer parmodindex, table ParmModTable)</functioncall>
  <description>
    Takes a ParmModTable and sets its values into a Parameter Modulation of a specifix fx within an FXStateChunk.
  
    The expected table's format is as follows:
    <pre><code>
                ParamModTable["PARAM_NR"]               - the parameter that you want to modulate; 1 for the first, 2 for the second, etc
                ParamModTable["PARAM_TYPE"]             - the type of the parameter, usually "", "wet" or "bypass"

                ParamModTable["PARAMOD_ENABLE_PARAMETER_MODULATION"] 
                                                        - Enable parameter modulation, baseline value(envelope overrides)-checkbox; 
                                                          true, checked; false, unchecked
                ParamModTable["PARAMOD_BASELINE"]       - Enable parameter modulation, baseline value(envelope overrides)-slider; 
                                                            0.000 to 1.000

                ParamModTable["AUDIOCONTROL"]           - is the Audio control signal(sidechain)-checkbox checked; true, checked; false, unchecked
                                                            Note: if true, this needs all AUDIOCONTROL_-entries to be set
                ParamModTable["AUDIOCONTROL_CHAN"]      - the Track audio channel-dropdownlist; When stereo, the first stereo-channel; 
                                                          nil, if not available
                ParamModTable["AUDIOCONTROL_STEREO"]    - 0, just use mono-channels; 1, use the channel AUDIOCONTROL_CHAN plus 
                                                            AUDIOCONTROL_CHAN+1; nil, if not available
                ParamModTable["AUDIOCONTROL_ATTACK"]    - the Attack-slider of Audio Control Signal; 0-1000 ms; nil, if not available
                ParamModTable["AUDIOCONTROL_RELEASE"]   - the Release-slider; 0-1000ms; nil, if not available
                ParamModTable["AUDIOCONTROL_MINVOLUME"] - the Min volume-slider; -60dB to 11.9dB; must be smaller than AUDIOCONTROL_MAXVOLUME; 
                                                          nil, if not available
                ParamModTable["AUDIOCONTROL_MAXVOLUME"] - the Max volume-slider; -59.9dB to 12dB; must be bigger than AUDIOCONTROL_MINVOLUME; 
                                                          nil, if not available
                ParamModTable["AUDIOCONTROL_STRENGTH"]  - the Strength-slider; 0(0%) to 1000(100%)
                ParamModTable["AUDIOCONTROL_DIRECTION"] - the direction-radiobuttons; -1, negative; 0, centered; 1, positive

                ParamModTable["LFO"]                    - if the LFO-checkbox checked; true, checked; false, unchecked
                                                            Note: if true, this needs all LFO_-entries to be set
                ParamModTable["LFO_SHAPE"]              - the LFO Shape-dropdownlist; 
                                                            0, sine; 1, square; 2, saw L; 3, saw R; 4, triangle; 5, random
                                                            nil, if not available
                ParamModTable["LFO_SHAPEOLD"]           - use the old-style of the LFO_SHAPE; 
                                                            0, use current style of LFO_SHAPE; 
                                                            1, use old style of LFO_SHAPE; 
                                                            nil, if not available
                ParamModTable["LFO_TEMPOSYNC"]          - the Tempo sync-checkbox; true, checked; false, unchecked
                ParamModTable["LFO_SPEED"]              - the LFO Speed-slider; 0(0.0039Hz) to 1(8.0000Hz); nil, if not available
                ParamModTable["LFO_STRENGTH"]           - the LFO Strength-slider; 0.000(0.0%) to 1.000(100.0%)
                ParamModTable["LFO_PHASE"]              - the LFO Phase-slider; 0.000 to 1.000; nil, if not available
                ParamModTable["LFO_DIRECTION"]          - the LFO Direction-radiobuttons; -1, Negative; 0, Centered; 1, Positive
                ParamModTable["LFO_PHASERESET"]         - the LFO Phase reset-dropdownlist; 
                                                            0, On seek/loop(deterministic output)
                                                            1, Free-running(non-deterministic output)
                                                            nil, if not available

                ParamModTable["PARMLINK"]               - the Link from MIDI or FX parameter-checkbox
                                                          true, checked; false, unchecked
                ParamModTable["PARMLINK_LINKEDPLUGIN"]  - the selected plugin; nil, if not available
                                                            -1, nothing selected yet
                                                            -100, MIDI-parameter-settings
                                                            1 - the first fx-plugin
                                                            2 - the second fx-plugin
                                                            3 - the third fx-plugin, etc
                ParamModTable["PARMLINK_LINKEDPARMIDX"] - the id of the linked parameter; -1, if none is linked yet; nil, if not available
                                                            When MIDI, this is irrelevant.
                                                            When FX-parameter:
                                                              0 to n; 0 for the first; 1, for the second, etc

                ParamModTable["PARMLINK_OFFSET"]        - the Offset-slider; -1.00(-100%) to 1.00(+100%); nil, if not available
                ParamModTable["PARMLINK_SCALE"]         - the Scale-slider; -1.00(-100%) to 1.00(+100%); nil, if not available

                ParamModTable["MIDIPLINK"]              - true, if any parameter-linking with MIDI-stuff; false, if not
                                                            Note: if true, this needs all MIDIPLINK_-entries and PARMLINK_LINKEDPLUGIN=-100 to be set
                ParamModTable["MIDIPLINK_BUS"]          - the MIDI-bus selected in the button-menu; 
                                                            0 to 15 for bus 1 to 16; 
                                                            nil, if not available
                ParamModTable["MIDIPLINK_CHANNEL"]      - the MIDI-channel selected in the button-menu; 
                                                            0, omni; 1 to 16 for channel 1 to 16; 
                                                            nil, if not available
                ParamModTable["MIDIPLINK_MIDICATEGORY"] - the MIDI_Category selected in the button-menu; nil, if not available
                                                            144, MIDI note
                                                            160, Aftertouch
                                                            176, CC 14Bit and CC
                                                            192, Program Change
                                                            208, Channel Pressure
                                                            224, Pitch
                ParamModTable["MIDIPLINK_MIDINOTE"]     - the MIDI-note selected in the button-menu; nil, if not available
                                                          When MIDI note:
                                                               0(C-2) to 127(G8)
                                                          When Aftertouch:
                                                               0(C-2) to 127(G8)
                                                          When CC14 Bit:
                                                               128 to 159; see dropdownlist for the commands(the order of the list 
                                                               is the same as this numbering)
                                                          When CC:
                                                               0 to 119; see dropdownlist for the commands(the order of the list 
                                                               is the same as this numbering)
                                                          When Program Change:
                                                               0
                                                          When Channel Pressure:
                                                               0
                                                          When Pitch:
                                                               0
                ParamModTable["WINDOW_ALTERED"]         - false, if the windowposition hasn't been altered yet; true, if the window has been altered
                                                            Note: if true, this needs all WINDOW_-entries to be set
                ParamModTable["WINDOW_ALTEREDOPEN"]     - if the position of the ParmMod-window is altered and currently open; 
                                                            nil, unchanged; 0, unopened; 1, open
                ParamModTable["WINDOW_XPOS"]            - the x-position of the altered ParmMod-window in pixels; nil, default position
                ParamModTable["WINDOW_YPOS"]            - the y-position of the altered ParmMod-window in pixels; nil, default position
                ParamModTable["WINDOW_RIGHT"]           - the right-position of the altered ParmMod-window in pixels; 
                                                            nil, default position; only readable
                ParamModTable["WINDOW_BOTTOM"]          - the bottom-position of the altered ParmMod-window in pixels; 
                                                            nil, default position; only readable
    </code></pre>
    
    This function does not check, if the values are within valid value-ranges, only if the datatypes are valid.
    
    returns nil in case of an error
  </description>
  <parameters>
    string FXStateChunk - an FXStateChunk, of which you want to set the values of a specific parameter-modulation
    integer fxindex - the index if the fx, of which you want to set specific parameter-modulation-values
    integer parmodindex - the parameter-modulation, whose values you want to set; 1, for the first; 2, for the second, etc
    table ParmModTable - the table which holds all parameter-modulation-values to be set
  </parameters>
  <retvals>
    string FXStateChunk - the altered FXStateChunk, where the ParameterModulation had been set
  </retvals>
  <chapter_context>
    FX-Management
    Parameter Modulation
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fxmanagement, set, parameter modulation, table, fxstatechunk</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidParmModTable(ParmModTable)==false then ultraschall.AddErrorMessage("SetParmModulationTable", "ParmModTable", SLEM(nil, 3, 5), -1) return FXStateChunk end
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("SetParmModulationTable", "FXStateChunk", "must be a valid FXStateChunk", -2) return FXStateChunk end
  if math.type(parmodindex)~="integer" then ultraschall.AddErrorMessage("SetParmModulationTable", "parmodindex", "must be an integer", -3) return FXStateChunk end
  if parmodindex<1 then ultraschall.AddErrorMessage("SetParmModulationTable", "parmodindex", "must be bigger than 0", -4) return FXStateChunk end
  
  if math.type(fxindex)~="integer" then ultraschall.AddErrorMessage("SetParmModulationTable", "fxindex", "must be an integer", -5) return FXStateChunk end
  if fxindex<1 then ultraschall.AddErrorMessage("SetParmModulationTable", "fxindex", "must be bigger than 0", -6) return FXStateChunk end
    
  local NewParmModTable=""
  
  if ParmModTable~=nil and (ParmModTable["PARMLINK"]==true or ParmModTable["LFO"]==true or ParmModTable["AUDIOCONTROL"]==true) then
    
    
    local Sep=""
    local LFO, AudioControl, LinkedPlugin, offset, ParmModEnable, LFOTempoSync, WindowAlteredOpen
    if ParmModTable["PARAM_TYPE"]~="" then Sep=":" end
    if ParmModTable["PARAMOD_ENABLE_PARAMETER_MODULATION"]==true then ParmModEnable=0 else ParmModEnable=1 end
    if ParmModTable["LFO"]==true then LFO=1 else LFO=0 end
    if ParmModTable["AUDIOCONTROL"]==true then AudioControl=1 else AudioControl=0 end
    
    NewParmModTable=
    " <PROGRAMENV "..(tonumber(ParmModTable["PARAM_NR"])-1)..Sep..ParmModTable["PARAM_TYPE"].." "..ParmModEnable.."\n"..
    "      PARAMBASE " ..ParmModTable["PARAMOD_BASELINE"].."\n"..
    "      LFO "       ..LFO.."\n"..
    "      LFOWT "     ..ParmModTable["LFO_STRENGTH"].." "..ParmModTable["LFO_DIRECTION"].."\n"..
    "      AUDIOCTL "  ..AudioControl.."\n"..
    "      AUDIOCTLWT "..ParmModTable["AUDIOCONTROL_STRENGTH"].." "..ParmModTable["AUDIOCONTROL_DIRECTION"].."\n"
    
    -- if ParameterLinking is enabled, then add this line
    if ParmModTable["PARMLINK"]==true then 
      if ParmModTable["PARMLINK_LINKEDPLUGIN"]>=0 then
        LinkedPlugin=(ParmModTable["PARMLINK_LINKEDPLUGIN"]-1)..":"..(ParmModTable["PARMLINK_LINKEDPLUGIN"]-1)
      else
        LinkedPlugin=tostring(ParmModTable["PARMLINK_LINKEDPLUGIN"])
      end
      if ParmModTable["PARMLINK_LINKEDPARMIDX"]==-1 then offset=0 else offset=1 end
      NewParmModTable=NewParmModTable..
    "      PLINK "..ParmModTable["PARMLINK_SCALE"].." "..LinkedPlugin.." "..(ParmModTable["PARMLINK_LINKEDPARMIDX"]-offset).." "..ParmModTable["PARMLINK_OFFSET"].."\n"
    
      -- if midi-parameter is linked, then add this line
      if ParmModTable["PARMLINK_LINKEDPLUGIN"]<-1 then
        NewParmModTable=NewParmModTable.."      MIDIPLINK "..(ParmModTable["MIDIPLINK_BUS"]-1).." "..ParmModTable["MIDIPLINK_CHANNEL"].." "..ParmModTable["MIDIPLINK_MIDICATEGORY"].." "..ParmModTable["MIDIPLINK_MIDINOTE"].."\n"
      end
    end
    
    -- if LFO is turned on, add these lines
    if ParmModTable["LFO"]==true then
      if ParmModTable["LFO_TEMPOSYNC"]==true then LFOTempoSync=1 else LFOTempoSync=0 end      
      NewParmModTable=NewParmModTable..
    "      LFOSHAPE "..ParmModTable["LFO_SHAPE"].."\n"..
    "      LFOSYNC " ..LFOTempoSync.." "..ParmModTable["LFO_SHAPEOLD"].." "..ParmModTable["LFO_PHASERESET"].."\n"..
    "      LFOSPEED "..ParmModTable["LFO_SPEED"].." "..ParmModTable["LFO_PHASE"].."\n"
    end
    
    -- if Audio Control Signal(sidechain) is enabled, add these lines
    if ParmModTable["AUDIOCONTROL"]==true then
      NewParmModTable=NewParmModTable..
    "      CHAN "  ..(ParmModTable["AUDIOCONTROL_CHAN"]-1).."\n"..
    "      STEREO "..(ParmModTable["AUDIOCONTROL_STEREO"]).."\n"..
    "      RMS "   ..(ParmModTable["AUDIOCONTROL_ATTACK"]).." "..(ParmModTable["AUDIOCONTROL_RELEASE"]).."\n"..
    "      DBLO "  ..(ParmModTable["AUDIOCONTROL_MINVOLUME"]).."\n"..
    "      DBHI "  ..(ParmModTable["AUDIOCONTROL_MAXVOLUME"]).."\n"..
    "      X2 "    ..(ParmModTable["X2"]).."\n"..
    "      Y2 "    ..(ParmModTable["Y2"]).."\n"
    end
    
    -- if the window shall be modified, add these lines
    if ParmModTable["WINDOW_ALTERED"]==true then
      if ParmModTable["WINDOW_ALTEREDOPEN"]==true then 
        WindowAlteredOpen=1
      else
        WindowAlteredOpen=0
      end
      
      NewParmModTable=NewParmModTable..
    "      MODWND "..WindowAlteredOpen.." "..ParmModTable["WINDOW_XPOS"].." "..ParmModTable["WINDOW_YPOS"].." "..ParmModTable["WINDOW_RIGHT"].." "..ParmModTable["WINDOW_BOTTOM"].."\n"
    end
    
    NewParmModTable=NewParmModTable.."    >\n"
  end
  local cindex=0

  local FX,StartOFS,EndOFS=ultraschall.GetFXFromFXStateChunk(FXStateChunk, fxindex)
  

  for k,v in string.gmatch(FX, "()  <PROGRAMENV.-\n%s->()\n") do
    cindex=cindex+1
    if cindex==parmodindex then
      FX=FX:sub(1,k)..NewParmModTable..FX:sub(v,-1)
      break
    end    
  end
  
  FX=string.gsub(FX, "\n%s-\n", "\n")

  return string.gsub(FXStateChunk:sub(1,StartOFS)..FX.."\n"..FXStateChunk:sub(EndOFS, -1), "\n\n", "\n")
end

function ultraschall.DeleteParmModFromFXStateChunk(FXStateChunk, fxindex, parmmodidx)
--[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>DeleteParmModFromFXStateChunk</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>string altered_FXStateChunk, boolean altered = ultraschall.DeleteParmModFromFXStateChunk(string FXStateChunk, integer fxindex, integer parmmodidx)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      deletes a parameter-modulation of a specific fx from an FXStateChunk
      
      retval altered returns false in case of an error
    </description>
    <retvals>
      string altered_FXStateChunk - the FXStateChunk, from which the 
      boolean altered - true, deleting was successful; false, deleting was unsuccessful
    </retvals>
    <parameters>
      string FXStateChunk - the FXStateChunk from which you want to delete a parameter-modulation of a specific fx
      integer fxindex - the index of the fx, whose parameter-modulations you want to delete
      integer parmmodidx - the parameter-modulation that you want to delete
    </parameters>
    <chapter_context>
      FX-Management
      Parameter Modulation
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
    <tags>fxmanagement, delete, parameter modulation, fxstatechunk</tags>
  </US_DocBloc>
  --]] 
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("DeleteParmModFromFXStateChunk", "FXStateChunk", "must be a valid FXStateChunk", -1) return FXStateChunk, false end
  if math.type(parmmodidx)~="integer" then ultraschall.AddErrorMessage("DeleteParmModFromFXStateChunk", "parmmodidx", "must be an integer", -2) return FXStateChunk, false end
  if math.type(fxindex)~="integer" then ultraschall.AddErrorMessage("DeleteParmModFromFXStateChunk", "fxindex", "must be an integer", -3) return FXStateChunk, false end
  if parmmodidx<1 then ultraschall.AddErrorMessage("DeleteParmModFromFXStateChunk", "parmmodidx", "must be bigger than 0", -4) return FXStateChunk, false end
  
  local index=0
  
  local FX,StartOFS,EndOFS=ultraschall.GetFXFromFXStateChunk(FXStateChunk, fxindex)
  
  for k,v in string.gmatch(FX, "()%s-<PROGRAMENV.-\n%s->()\n") do
    index=index+1
    if index==parmmodidx then
      FX=FX:sub(1,k-1)..""..FX:sub(v,-1).."\n"
      return string.gsub(FXStateChunk:sub(1,StartOFS-1)..FX..FXStateChunk:sub(EndOFS,-1), "\n\n", "\n"), true
    end
  end
  ultraschall.AddErrorMessage("DeleteParmModFromFXStateChunk", "parmmodidx", "no such parameter-modulation-entry found", -6)
  return FXStateChunk, false
end

function ultraschall.CountParmModFromFXStateChunk(FXStateChunk, fxindex)
--[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>CountParmModFromFXStateChunk</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>integer number_of_parmmodulations = ultraschall.CountParmModFromFXStateChunk(string FXStateChunk, integer fxindex)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      returns the number of parameter-modulations available for a specific fx in an FXStateChunk
      
      returns -1 in case of an error
    </description>
    <retvals>
      integer number_of_parmmodulations - the number of parameter-modulations available for this fx within this FXStateChunk
    </retvals>
    <parameters>
      string FXStateChunk - the FXStateChunk from which you want to count the parameter-modulations available for a specific fx
      integer fxindex - the index of the fx, whose number of parameter-modulations you want to know
    </parameters>
    <chapter_context>
      FX-Management
      Parameter Modulation
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
    <tags>fxmanagement, count, parameter modulation, fxstatechunk</tags>
  </US_DocBloc>
  --]] 
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("CountParmModFromFXStateChunk", "FXStateChunk", "must be a valid FXStateChunk", -1) return -1 end
  if math.type(fxindex)~="integer" then ultraschall.AddErrorMessage("CountParmModFromFXStateChunk", "fxindex", "must be an integer", -2) return end
  
  local index=0

  local FX,StartOFS,EndOFS=ultraschall.GetFXFromFXStateChunk(FXStateChunk, fxindex)
  if FX==nil then ultraschall.AddErrorMessage("CountParmModFromFXStateChunk", "fxindex", "no such fx", -3) return end
  for k,v in string.gmatch(FX, "()  <PROGRAMENV.-\n%s->()\n") do
    index=index+1
  end

  return index
end
--[[
function ultraschall.GetFXFromFXStateChunk(FXStateChunk, fxindex)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>GetFXFromFXStateChunk</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>string fx_lines, integer startoffset, integer endoffset = ultraschall.GetFXFromFXStateChunk(string FXStateChunk, integer fxindex)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      returns the statechunk-lines of fx with fxindex from an FXStateChunk
      
      It also returns the start and endoffset of these lines, so you can manipulate these lines and replace them in the
      original FXStateChunk, by replacing the part between start and endoffset with your altered lines.
      
      returns nil in case of an error
    </description>
    <retvals>
      string fx_lines - the statechunk-lines associated with this fx
      integer startoffset - the startoffset in bytes of these lines within the FXStateChunk
      integer endoffset - the endoffset in bytes of these lines within the FXStateChunk
    </retvals>
    <parameters>
      string FXStateChunk - the FXStateChunk from which you want to retrieve the fx's-lines
      integer fxindex - the index of the fx, whose statechunk lines you want to retrieve; with 1 for the first
    </parameters>
    <chapter_context>
      FX-Management
      Get States
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
    <tags>fxmanagement, get, fxlines, fxstatechunk</tags>
  </US_DocBloc>

  -- returns the individual fx-statechunk-lines and the start/endoffset of these lines within the FXStateChunk
  -- so its easy to manipulate the stuff
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("GetFXFromFXStateChunk", "FXStateChunk", "must be a valid FXStateChunk", -1) return end
  if math.type(fxindex)~="integer" then ultraschall.AddErrorMessage("GetFXFromFXStateChunk", "fxindex", "must be an integer", -2) return end
  local index=0
  for a,b,c in string.gmatch(FXStateChunk, "()(%s-BYPASS.-\n.-WAK.-)\n()") do
    index=index+1
    if index==fxindex then return b,a,c end
  end
  return nil
end
--]]
--]]
function ultraschall.IsAnyNamedEnvelopeVisible(name)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>IsAnyMuteEnvelopeVisible</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.IsAnyMuteEnvelopeVisible(string name)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      returns, if any mute-envelopes are currently set to visible in the current project
      
      Visible=true does include mute-envelopes, who are scrolled outside of the arrangeview
    </description>
    <retvals>
      boolean retval - true, there are visible mute-envelopes in the project; false, no mute-envelope visible
    </retvals>
    <parameters>
      string name - the name of the envelope; case-sensitive, just take the one displayed in the envelope-lane
                  - Standard-Envelopes are: 
                  -      "Volume (Pre-FX)", "Pan (Pre-FX)", "Width (Pre-FX)", "Volume", "Pan", "Width", "Trim Volume", "Mute"
                  - Plugin's envelopes can also be checked against, like
                  -      "Freq-Band 1 / ReaEQ"
    </parameters>
    <chapter_context>
      Envelope Management
      Envelopes
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_Envelope_Module.lua</source_document>
    <tags>envelope management, get, any mute envelope, envelope, visible</tags>
  </US_DocBloc>
  --]] 
  -- todo: 
  --   visible in viewable arrangeview only, but this is difficult, as I need to know first, how high the arrangeview is.
  for i=0, reaper.CountTracks()-1 do
    local Track=reaper.GetTrack(0,i)
    local TrackEnvelope = reaper.GetTrackEnvelopeByName(Track, name)
    if TrackEnvelope~=nil then
      local Aretval2 = reaper.GetEnvelopeInfo_Value(TrackEnvelope, "I_TCPH_USED")
      if Aretval2>0 then return true end
    end
  end
  return false
end

function ultraschall.IsEnvelope_Track(TrackEnvelope)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>IsEnvelope_Track</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.IsEnvelope_Track(TrackEnvelope env)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      returns, if the envelope is a track envelope(true) or a take-envelope(false)
      
      returns nil in case of an error
    </description>
    <retvals>
      boolean retval - true, the envelope is a TrackEnvelope; false, the envelope is a TakeEnvelope
    </retvals>
    <parameters>
      TrackEnvelope env - the envelope to check
    </parameters>
    <chapter_context>
      Envelope Management
      Envelopes
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_Envelope_Module.lua</source_document>
    <tags>envelope management, check, track envelope, take envelope</tags>
  </US_DocBloc>
  --]] 
  if ultraschall.type(TrackEnvelope)~="TrackEnvelope" then ultraschall.AddErrorMessage("IsEnvelope_Track", "TrackEnvelope", "must be an envelope-object", -1) return end
  if reaper.GetEnvelopeInfo_Value(Mute, "P_TRACK")==0 then return false else return true end
end

function ultraschall.IsTrackEnvelopeVisible_ArrangeView(TrackEnvelope)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>IsTrackEnvelopeVisible_ArrangeView</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.IsTrackEnvelopeVisible_ArrangeView(TrackEnvelope env)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      returns, if the envelope is currently visible within arrange-view
      
      returns nil in case of an error
    </description>
    <retvals>
      boolean retval - true, the envelope is a TrackEnvelope; false, the envelope is a TakeEnvelope
    </retvals>
    <parameters>
      TrackEnvelope env - the envelope to check for visibility
    </parameters>
    <chapter_context>
      Envelope Management
      Envelopes
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_Envelope_Module.lua</source_document>
    <tags>envelope management, check, track envelope, take envelope, visible, arrangeview</tags>
  </US_DocBloc>
  --]] 
  if ultraschall.IsEnvelope_Track(TrackEnvelope)==false then ultraschall.AddErrorMessage("IsTrackEnvelopeVisible_ArrangeView", "TrackEnvelope", "must be a track-envelope-object", -1) return false end
  if reaper.GetEnvelopeInfo_Value(TrackEnvelope, "I_TCPH_USED")==0 then return false end
  local arrange_view = ultraschall.GetHWND_ArrangeViewAndTimeLine()
  local retval, left, top, right, bottom = reaper.JS_Window_GetClientRect(arrange_view)
  
  local Item = reaper.GetMediaTrackInfo_Value(reaper.GetEnvelopeInfo_Value(Mute, "P_TRACK"), "P_ITEM")
  local HeightTrackY = reaper.GetMediaTrackInfo_Value(reaper.GetEnvelopeInfo_Value(Mute, "P_TRACK"), "I_TCPY")
  local HeightTrack = reaper.GetMediaTrackInfo_Value(reaper.GetEnvelopeInfo_Value(Mute, "P_TRACK"), "I_TCPH")
  local HeightEnv = reaper.GetEnvelopeInfo_Value(Mute, "I_TCPH")
  local A=HeightTrack+HeightTrackY+HeightEnv>0
  local B=HeightTrackY+HeightEnv+top<bottom
  return A==B
end

function ultraschall.ActionsList_GetAllActions()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ActionsList_GetAllActions</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.05
	SWS=2.10.0.1
	JS=0.963
    Lua=5.3
  </requires>
  <functioncall>integer num_found_actions, integer sectionID, string sectionName, table actions, table CmdIDs, table ToggleStates, table shortcuts = ultraschall.ActionsList_GetAllActions()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
	returns the all actions from the actionlist, when opened.
	
	The order of the tables of found actions, ActionCommandIDs and ToggleStates is the same in all of the three tables.
	They also reflect the order of userselection in the ActionList itself from top to bottom of the ActionList.
	
	returns -1 in case of an error
  </description>
  <retvals>
	integer num_found_actions - the number of found actions; -1, if not opened
	integer sectionID - the id of the section, from which the found actions are from
	string sectionName - the name of the found section
	table actions - the texts of the found actions as a handy table
	table CmdIDs - the ActionCommandIDs of the found actions as a handy table; all of them are strings, even the numbers, but can be converted using Reaper's own function reaper.NamedCommandLookup
	table ToggleStates - the current toggle-states of the found actions; 1, on; 0, off; -1, no such toggle state available
    table shortcuts - the shortcuts of the action as a handy table; separated by ", "
  </retvals>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, get, action, actionlist, sections, toggle states, commandids, actioncommandid, shortcuts</tags>
</US_DocBloc>
--]]
  local hWnd_action = ultraschall.GetActionsHWND()
  if hWnd_action==nil then ultraschall.AddErrorMessage("ActionsList_GetAllActions", "", "Action-List-Dialog not opened", -1) return -1 end
  local hWnd_LV = reaper.JS_Window_FindChildByID(hWnd_action, 1323)
  local combo = reaper.JS_Window_FindChildByID(hWnd_action, 1317)
  local sectionName = reaper.JS_Window_GetTitle(combo,"") -- save item text to table
  local sectionID =  reaper.JS_WindowMessage_Send( combo, "CB_GETCURSEL", 0, 0, 0, 0 )

  -- get the action-texts
  local actions = {}
  local shortcuts = {}
  local i = 0
    --for index in string.gmatch(sel_indexes, '[^,]+') do
  for index=0, 65535 do    
    i = i + 1
    local desc = reaper.JS_ListView_GetItemText(hWnd_LV, tonumber(index), 1)--:gsub(".+: ", "", 1)
    local shortcut = reaper.JS_ListView_GetItemText(hWnd_LV, tonumber(index), 0)--:gsub(".+: ", "", 1)
    --ToClip(FromClip()..tostring(desc).."\n")
    if desc=="" then break end    
    actions[i] = desc    
    shortcuts[i] = shortcut
  end
  i=i-1 
  -- find the cmd-ids
  local temptable={}
  for a=1, i do
    if actions[a]==nil then break end
    selectA=a
    selectI=i
    temptable[actions[a]]=actions[a]
  end
  
  -- get command-ids of the found texts
  for aaa=0, 65535 do
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
    CmdIDs[a]=reaper.ReverseNamedCommandLookup(temptable[actions[a]])
    if CmdIDs[a]==nil then CmdIDs[a]=tostring(temptable[actions[a]]) end
    ToggleStates[a]=reaper.GetToggleCommandStateEx(sectionID, temptable[actions[a]])
  end

  return i, sectionID, sectionName, actions, CmdIDs, ToggleStates, shortcuts
end


function ultraschall.GetFXSettingsString_FXLines(fx_lines)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetFXSettingsString_FXLines</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>string fx_statestring_base64, string fx_statestring = ultraschall.GetFXSettingsString_FXLines(string fx_lines)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the fx-states-string of a fx, as stored as an base64-string.byte
    It returns its decoded and encoded version of it.
    
    Use [GetFXFromFXStateChunk](#GetFXFromFXStateChunk) to get the requested parameter "fx_lines"
  
    returns nil in case of an error
  </description>
  <parameters>
    string fx_lines - the statechunk-lines of an fx, as returned by the function GetFXFromFXStateChunk()
  </parameters>
  <retvals>
    string fx_statestring_base64 - the base64-version of the state-string, which holds all fx-settings of the fx
    string fx_statestring - the decoded binary-version of the state-string, which holds all fx-settings of the fx
  </retvals>
  <chapter_context>
    FX-Management
    Get States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fxmanagement, get, fxstatestring, base64</tags>
</US_DocBloc>
--]]
  if ultraschall.type(FXLines)~="string" then ultraschall.AddErrorMessage("GetFXSettingsString_FXLines", "fx_lines" , "must be a string", -1) return nil end
  if FXLines:match("    <VST")~=nil then
    FXSettings=FXLines:match("<VST.-\n(.-)    >")
  elseif FXLines:match("    <JS_SER")~=nil then
    FXSettings=FXLines:match("<JS_SER.-\n(.-)    >")
  elseif FXLines:match("    <DX")~=nil then
    FXSettings=FXLines:match("<DX.-\n(.-)    >")
  elseif FXLines:match("    <AU")~=nil then
    FXSettings=FXLines:match("<AU.-\n(.-)    >")
  elseif FXLines:match("    <VIDEO_EFFECT")~=nil then
    return "", string.gsub(FXLines:match("<VIDEO_EFFECT.-      <CODE\n(.-)      >"), "%s-|", "\n")
  end
    FXSettings=string.gsub(FXSettings, "[\n%s]*", "")
    FXSettings_dec=ultraschall.Base64_Decoder(FXSettings)
    return FXSettings, FXSettings_dec
end


ultraschall.reaper_gmem_attach=reaper.gmem_attach

function reaper.gmem_attach(GMem_Name)
  
  ultraschall.reaper_gmem_attach_curname=GMem_Name
  ultraschall.reaper_gmem_attach(GMem_Name)
end

function ultraschall.Gmem_GetCurrentAttachedName()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gmem_GetCurrentAttachedName</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>string current_gmem_attachname = ultraschall.Gmem_GetCurrentAttachedName()</functioncall>
  <description>
    returns nil if no gmem had been attached since addition of Ultraschall-API
  </description>
  <retvals>
    string current_gmem_attachname - the name of the currently attached gmem
  </retvals>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>helperfunctions, get, current, gmem, attached name</tags>
</US_DocBloc>
--]]
  return ultraschall.reaper_gmem_attach_curname
end


function ultraschall.GetAllParmAliasNames_FXStateChunk(FXStateChunk, fxindex)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllParmAliasNames_FXStateChunk</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.979
    Lua=5.3
  </requires>
  <functioncall>integer count_aliasnames, array parameteridx, array parameter_aliasnames = ultraschall.GetAllParmAliasNames_FXStateChunk(string FXStateChunk, integer fxid)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns all aliasnames of a specific fx within an FXStateChunk
    
    returns false in case of an error
  </description>
  <retvals>
    integer count_aliasnames - the number of parameter-aliases found for this fx
    array parameteridx - an array, which holds all parameter-index-numbers of all fx with parameter-aliasnames
    array parameter_aliasnames - an array with all parameter-aliasnames found
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, from which you want to get all Parm-Aliases
    integer fxid - the id of the fx, whose Parm-Aliases you want to get
  </parameters>
  <chapter_context>
    FX-Management
    Parameter Mapping Alias
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, get, all, parm, aliasname</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("GetAllParmAliasNames_FXStateChunk", "FXStateChunk", "no valid FXStateChunk", -1) return -1 end
  if math.type(fxindex)~="integer" then ultraschall.AddErrorMessage("GetAllParmAliasNames_FXStateChunk", "fxindex", "must be an integer", -2) return -1 end
  local fx_lines, startoffset, endoffset = ultraschall.GetFXFromFXStateChunk(FXStateChunk, fxindex)
  if fx_lines==nil then ultraschall.AddErrorMessage("GetAllParmAliasNames_FXStateChunk", "fxindex", "no such fx", -3) return -1 end
  local aliasnames={}
  local aliasparm={}
  local aliascount=0
  for parmidx, k in string.gmatch(fx_lines, "%s-PARMALIAS (.-) (.-)\n") do
    aliascount=aliascount+1
    aliasnames[aliascount]=k
    aliasparm[aliascount]=tonumber(parmidx)+1
  end
  for i=1, aliascount do
    if aliasnames[i]:sub(1,1)=="\"" and aliasnames[i]:sub(-1,-1)=="\"" then aliasnames[i]=aliasnames[i]:sub(2,-2) end
  end
  return aliascount, aliasparm, aliasnames
end

function ultraschall.DeleteParmAlias2_FXStateChunk(FXStateChunk, fxid, parmidx)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DeleteParmAlias2_FXStateChunk</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.979
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string alteredFXStateChunk = ultraschall.DeleteParmAlias2_FXStateChunk(string FXStateChunk, integer fxid, integer parmidx)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Deletes a ParmAlias-entry from an FXStateChunk.
    
    It's the PARMALIAS-entry
    
    Unlike DeleteParmAlias_FXStateChunk, this indexes aliasnames by parameter-index directly, not by number of already existing aliasnames.
    When in doubt, use this one.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, if deletion was successful; false, if the function couldn't delete anything
    string alteredFXStateChunk - the altered FXStateChunk
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, which you want to delete a ParmAlias from
    integer fxid - the id of the fx, which holds the to-delete-ParmAlias-entry; beginning with 1
    integer parmidx - the id of the parameter, whose parmalias you want to delete; beginning with 1
  </parameters>
  <chapter_context>
    FX-Management
    Parameter Mapping Alias
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, parm, alias, delete, parm, learn, midi, osc, binding</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("DeleteParmAlias2_FXStateChunk", "FXStateChunk", "no valid FXStateChunk", -1) return false end
  if math.type(fxid)~="integer" then ultraschall.AddErrorMessage("DeleteParmAlias2_FXStateChunk", "fxid", "must be an integer", -2) return false end
  if math.type(parmidx)~="integer" then ultraschall.AddErrorMessage("DeleteParmAlias2_FXStateChunk", "parmidx", "must be an integer", -3) return false end
    
  local count=0
  local FX, UseFX2, start, stop, UseFX
  for k in string.gmatch(FXStateChunk, "    BYPASS.-WAK.-\n") do
    count=count+1
    if count==fxid then UseFX=k end
  end
  
  if UseFX~=nil then
    UseFX2=string.gsub(UseFX, "\n%s-PARMALIAS "..(parmidx-1).." .-\n", "\n")
    if UseFX2==UseFX then UseFX2=nil end
  end  
  
  if UseFX2~=nil then
    start,stop=string.find(FXStateChunk, UseFX, 0, true)
    return true, FXStateChunk:sub(1, start)..UseFX2:sub(2,-2)..FXStateChunk:sub(stop, -1)
  else
    return false, FXStateChunk
  end
end

function ultraschall.GetParmAlias2_FXStateChunk(FXStateChunk, fxid, parmidx)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetParmAlias2_FXStateChunk</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.975
    Lua=5.3
  </requires>
  <functioncall>integer parm_idx, string parm_aliasname = ultraschall.GetParmAlias2_FXStateChunk(string FXStateChunk, integer fxid, integer id)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns a parameter-alias-setting of a specific parameter from an FXStateChunk
    An FXStateChunk holds all FX-plugin-settings for a specific MediaTrack or MediaItem.
    
    Parameter-aliases are only stored for MediaTracks.
    
    It is the PARMALIAS-entry
    
    Returns nil in case of an error or if no such aliasname has been found
  </description>
  <retvals>
    integer parm_idx - the idx of the parameter; order is exactly like the order in the contextmenu of Parameter List -> Learn
    string parm_aliasname - the alias-name of the parameter
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, from which you want to retrieve the ParmAlias-settings
    integer fxid - the fx, of which you want to get the parameter-alias-settings
    integer parmidx - the id of the parameter whose aliasname you want to have, starting with 1 for the first
  </parameters>
  <chapter_context>
    FX-Management
    Parameter Mapping Alias
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fxmanagement, get, parameter, alias, fxstatechunk</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("GetParmAlias2_FXStateChunk", "StateChunk", "Not a valid FXStateChunk", -1) return nil end
  if math.type(parmidx)~="integer" then ultraschall.AddErrorMessage("GetParmAlias2_FXStateChunk", "parmidx", "must be an integer", -2) return nil end
  if math.type(fxid)~="integer" then ultraschall.AddErrorMessage("GetParmAlias2_FXStateChunk", "fxid", "must be an integer", -3) return nil end
  if string.find(FXStateChunk, "\n  ")==nil then
    FXStateChunk=ultraschall.StateChunkLayouter(FXStateChunk)
  end
  local fx_lines, startoffset, endoffset = ultraschall.GetFXFromFXStateChunk(FXStateChunk, fxid)
  
  if fx_lines==nil then ultraschall.AddErrorMessage("GetParmAlias2_FXStateChunk", "fxid", "no such fx", -4) return nil end

  local aliasname=fx_lines:match("\n%s-PARMALIAS "..(parmidx-1).." (.-)\n")
  if aliasname:sub(1,1)=="\"" and aliasname:sub(-1,-1)=="\"" then aliasname=aliasname:sub(2,-2) end
  
  return aliasname
end


function ultraschall.ReturnAllChildHWND(hwnd)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ReturnAllChildHWND</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.965    
    JS=0.962
    Lua=5.3
  </requires>
  <functioncall>integer count_of_hwnds, table hwnds = ultraschall.ReturnAllChildHWND(HWND hwnd)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns all child-window-handler of hwnd.
    
    Returns -1 in case of an error
  </description>
  <retvals>
    integer count_of_hwnds - the number of found child-window-handler
    table hwnds - the found child-window-handler of hwnd
  </retvals>
  <parameters>
    HWND hwnd - the HWND-handler to check for
  </parameters>
  <chapter_context>
    User Interface
    Window Management
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_ReaperUserInterface_Module.lua</source_document>
  <tags>window, hwnd, get, all, child</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidHWND(hwnd)==false then ultraschall.AddErrorMessage("ReturnAllChildHWND", "hwnd", "must be a valid hwnd", -1) return -1 end
  local Aretval, Alist = reaper.JS_Window_ListAllChild(hwnd)
  local HWND={}
  local count=0
  for k in string.gmatch(Alist..",", "(.-),") do
    count=count+1
    HWND[count]=reaper.JS_Window_HandleFromAddress(k)
  end
  return count, HWND
end
ultraschall.ShowLastErrorMessage()
