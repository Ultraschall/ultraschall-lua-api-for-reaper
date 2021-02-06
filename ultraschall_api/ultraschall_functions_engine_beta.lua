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
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>BatchConvertFiles</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.12
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.BatchConvertFiles(table inputfilelist, table outputfilelist, table RenderTable, optional boolean BWFStart, optional integer PadStart, optional integer PadEnd, optional string FXStateChunk)</functioncall>
  <description>
    Converts files using Reaper's own BatchConverter.
    
    This function will open another instance of Reaper that runs the batchconverter, so it will still open the batch-converter-list for the time of conversion.
    Though as it is another instance, you can safely go back to the old instance of Reaper.
    
    This function will probably NOT finish before the batch-converter is finished with conversion, keep this in mind.
    
    Will take away the focus from the currently focused window, as Reaper puts keyboard-focus to the newly started Reaper-instance that does the batch-conversion.    
    
    returns nil in case of an error
  </description>
  <retvals>
    table inputfilelist - a table of filenames+path, that shall be converted
    table outputfilelist - a table of the target filenames+path, where the first filename is the target for the first inputfilename, etc
    table RenderTable - the settings for the conversion; just use the render-table-functions to create one
    optional boolean BWFStart - true, include BWF-start; false or nil, don't include BWF-start
    optional integer PadStart - the start of the padding in seconds; nil, to omit it
    optional integer PadEnd - the end of the padding in seconds; nil, to omit it
    optional string FXStateChunk - an FXChain as FXStateChunk; with that you can add fx on top of the to-convert-files.
  </retvals>
  <parameters>
    boolean retval - true, conversion was successfully started; false, conversion didn't start
  </parameters>
  <chapter_context>
    File Management
    Misc
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>file management, convert, files, rendertable, fxchain</tags>
</US_DocBloc>
--]]
  if type(inputfilelist)~="table" then ultraschall.AddErrorMessage("BatchConvertFiles", "inputfilelist", "must be a table of string", -1) return false end
  
  if #inputfilelist~=#outputfilelist then ultraschall.AddErrorMessage("BatchConvertFiles", "inputfilelist and outputfilelist", "both filelist-tables must have the same number of entries", -2) return false end
  for i=1, #inputfilelist do
    if type(inputfilelist[i])~="string" then ultraschall.AddErrorMessage("BatchConvertFiles", "inputfilelist", "all entries of the table must be strings", -3) return false end
    if reaper.file_exists(inputfilelist[i])==false then ultraschall.AddErrorMessage("BatchConvertFiles", "inputfilelist", "all entries of the table must be valid filenames", -4) return false end
  end

  if type(outputfilelist)~="table" then ultraschall.AddErrorMessage("BatchConvertFiles", "outputfilelist", "must be a table of string", -5) return false end
  for i=1, #inputfilelist do
    if type(inputfilelist[i])~="string" then ultraschall.AddErrorMessage("BatchConvertFiles", "inputfilelist", "all entries of the table must be strings", -6) return false end
  end
  
  if ultraschall.IsValidRenderTable(RenderTable)==false then ultraschall.AddErrorMessage("BatchConvertFiles", "RenderTable", "must be a valid RenderTable", -7) return false end
  
  -- temporary solution:
  if type(MetaDataStateChunk)~="string" then MetaDataStateChunk="" end  

-- Todo:

  local BatchConvertData=""
  local ExeFile, filename, path
  if FXStateChunk~=nil and FXStateChunk~="" and ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("BatchConvertFiles", "FXStateChunk", "must be a valid FXStateChunk", -7) return false end
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

  local ExeFile, AAAA, AAAAAA
  if ultraschall.IsOS_Windows()==true then
    -- Batchconvert On Windows
    ExeFile=reaper.GetExePath().."\\reaper.exe"
    AAAA, AAAAAA=reaper.ExecProcess(ExeFile.." -batchconvert \""..string.gsub(ultraschall.API_TempPath, "/", "\\").."\\filelist.txt\"", -1)
  elseif ultraschall.IsOS_Mac()==true then
    -- Batchconvert On Mac
    ExeFile=reaper.GetExePath().."/Reaper64.app/Contents/MacOS/reaper"
    if reaper.file_exists(ExeFile)==false then
      ExeFile=reaper.GetExePath().."/Reaper.app/Contents/MacOS/reaper"
    end
    AAAA, AAAAAA=reaper.ExecProcess(ExeFile.." -batchconvert \""..string.gsub(ultraschall.API_TempPath, "\\\\", "/").."/filelist.txt\"", -1)
  else
    -- Batchconvert On Linux
    ExeFile=reaper.GetExePath().."/reaper"
    AAAA, AAAAAA=reaper.ExecProcess(ExeFile.." -batchconvert \""..string.gsub(ultraschall.API_TempPath, "\\\\", "/").."/filelist.txt\"", -1)
  end
  
  return true
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

function ultraschall.SetUIScale(scaling)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetUIScale</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.17
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetUIScale(number scaling)</functioncall>
  <description>
    Sets the UI-scaling of Reaper's UI.
    
    Works only, if the "Scale UI elements of track/mixer panels, tansport, etc, by:"-checkbox is enabled in Preferences -> General -> Advanced UI/system tweaks-dialog, 
    by setting the value in the dialog to anything else than 1.0.
    
    returns false in case of an error.
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
  </retvals>
  <parameters>
    number scaling - the scaling-factor; safe range is between 0.30 and 3.00, though 0 to 2000 is supported
  </parameters>
  <chapter_context>
    User Interface
    Miscellaneous
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_ReaperUserInterface_Module.lua</source_document>
  <tags>user interface, uiscaling, set</tags>
</US_DocBloc>
--]]
  if type(scaling)~="number" then ultraschall.AddErrorMessage("SetUIScale", "scaling", "must be a number", -1) return false end
  if scaling<0 or scaling>2000 then ultraschall.AddErrorMessage("SetUIScale", "scaling", "must be between 0 and 2000", -2) return false end
  local B,BB=reaper.BR_Win32_GetPrivateProfileString("REAPER", "uiscale", "", reaper.get_ini_file())
  if BB=="1.00000000" then ultraschall.AddErrorMessage("SetUIScale", "", "Works only, if the \n\n   \"Scale UI elements of track/mixer panels, tansport, etc, by:\"-checkbox \n\nis enabled in \n\n    Preferences -> General -> Advanced UI/system tweaks-dialog,\n\n by setting the value in the dialog to anything else than 1.0.", -3) return false end
  local A=ultraschall.DoubleToInt(scaling)
  return reaper.SNM_SetIntConfigVar("uiscale", A)
end

--B=ultraschall.SetUIScale(1)

function ultraschall.GetActionCommandIDByFilename(searchfilename, searchsection, case_sensitive)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetActionCommandIDByFilename</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.17
    Lua=5.3
  </requires>
  <functioncall>string ActionCommandID = ultraschall.GetActionCommandIDByFilename(string searchfilename, integer searchsection, optional boolean case_sensitive)</functioncall>
  <description>
    Returns the action-command-id of a script by its filename, as registered in the reaper-kb.ini.
    
    Important: scripts in subfolders of Scripts must be written with their full path. \ and / are supported as folder-separators.
    Setting case_sensitive=false will return the action-command-id of the first script matching the filename, when you don't know the exact case-sensitivity.
    Keep in mind, that on Linux, camelcase can mean different filenames. So Prototype.lua and prototype.lua are different files on Linux, when they exist together. 
    Keep that in mind or you risk finding the wrong ActionCommandID.
    
    Returns nil in case of an error 
  </description>
  <parameters>
    string searchfilename - the filename(plus path, if needed) of the script, whose ActionCommandID you want to have.
    integer section - the section, in which the file is stored
                    - 0, Main, 
                    - 100, Main (alt recording), 
                    - 32060, MIDI Editor, 
                    - 32061, MIDI Event List Editor, 
                    - 32062, MIDI Inline Editor,
                    - 32063, Media Explorer.
    optional boolean case_sensitive - true or nil, search for filename on a case-sensitive base; false, case-sensitivity in filename is ignored
  </parameters>
  <retvals>
    string ActionCommandID - the actioncommand-id of the scriptfile; "", if no such file is installed; nil, in case of an error
  </retvals>
  <chapter_context>
    Configuration-Files Management
    Reaper-kb.ini
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configuration files management, get, actioncommandid, scriptfilename, reaper-kb.ini</tags>
</US_DocBloc>
]]

  -- returns the action-command-id for a given scriptfilename installed in Reaper
  -- keep in mind: some scripts are stored in subfolders, like Cockos/lyrics.lua
  --               in that case, you need to give the full path to avoid possible
  --               confusion between files with the same filenames but in different
  --               subfolders.
  --               Scripts that are simply in the Scripts-folder, not within a 
  --               subfolder of Scripts can be accessed just by their filename
  --
  -- Parameters:
  --            string searchfilename - the filename, whose action-command-id you want to have
  --            integer section - the section, in which the file is stored
  --                                0 = Main, 
  --                                100 = Main (alt recording), 
  --                                32060 = MIDI Editor, 
  --                                32061 = MIDI Event List Editor, 
  --                                32062 = MIDI Inline Editor,
  --                                32063 = Media Explorer.
  -- Returnvalue:
  --            string AID - the actioncommand-id of the scriptfile; "", if no such file is installed

  if type(searchfilename)~="string" then ultraschall.AddErrorMessage("GetActionCommandIDByFilename", "searchfilename", "must be a string", -1) return nil end
  if math.type(searchsection)~="integer" then ultraschall.AddErrorMessage("GetActionCommandIDByFilename", "searchsection", "must be an integer", -2) return nil end
  
  if case_sensitive==false then searchfilename=searchfilename:lower() end
  searchfilename=string.gsub(searchfilename, "\\", "/")
  for k in io.lines(reaper.GetResourcePath().."/reaper-kb.ini") do
    if k:sub(1,3)=="SCR" then
      local section, aid, desc, filename=k:match("SCR .- (.-) (.-) (\".-\") (.*)")
      local filename=string.gsub(filename, "\"", "") 
      filename=string.gsub(filename, "\\", "/")
      if case_sensitive==false then filename=filename:lower() end
      if filename==searchfilename and tonumber(section)==searchsection then
        return "_"..aid
      end
    end
  end
  return ""
end

function ultraschall.GetFXWak_FXStateChunk(FXStateChunk, fx_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetFXWak_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer keyboard_input_2_plugin, integer unknown = ultraschall.GetFXWak_FXStateChunk(string FXStateChunk, integer fxid)</functioncall>
  <description>
    returns the WAK-entryvalues of a specific fx from an FXStateChunk, as set by the +-button->Send all keyboard input to plugin-menuentry in the FX-window of the visible plugin.
    
    returns nil in case of an error
  </description>
  <retvals>
    integer keyboard_input_2_plugin - 0, don't send all the keyboard-input to plugin; 1, send all keyboard-input to plugin
    integer unknown - unknown, usually 0
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, from whose fx you want to return the WAK-entry
    integer fxid - the fx, whose WAK-entryvalues you want to return
  </parameters>
  <chapter_context>
    FX-Management
    Get States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, get, fx, wak, keyboard input, plugin</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("GetFXWak_FXStateChunk", "FXStateChunk", "must be a valid FXStateChunk", -1) return nil end
  if math.type(fx_id)~="integer" then ultraschall.AddErrorMessage("GetFXWak_FXStateChunk", "fx_id", "must be an integer", -2) return nil end
  ultraschall.SuppressErrorMessages(true)
  local fx_lines, startoffset, endoffset = ultraschall.GetFXFromFXStateChunk(FXStateChunk, fx_id)
  if fx_lines==nil then ultraschall.SuppressErrorMessages(false) ultraschall.AddErrorMessage("GetFXWak_FXStateChunk", "fx_id", "no such fx", -4) return nil end
  local WAK=fx_lines:match("\n.-WAK (.-)\n")
  
  local count, individual_values = ultraschall.CSV2IndividualLinesAsArray(WAK.." ", " ")
  for i=1, count do
    individual_values[i]=tonumber(individual_values[i])
  end
  ultraschall.SuppressErrorMessages(false)
  return table.unpack(individual_values)
end

function ultraschall.GetFXMidiPreset_FXStateChunk(FXStateChunk, fx_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetFXMidiPreset_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer midi_preset = ultraschall.GetFXMidiPreset_FXStateChunk(string FXStateChunk, integer fxid)</functioncall>
  <description>
    returns the MIDIPRESET-entryvalues of a specific fx from an FXStateChunk as set by the +-button->Link to MIDI program change-menuentry in the FX-window of the visible plugin.
    
    returns nil in case of an error
  </description>
  <retvals>
    integer midi_preset - 0, No Link; 17, Link all channels sequentially; 1-16, MIDI-channel 1-16
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, from whose fx you want to return the MIDIPRESET-entry
    integer fxid - the fx, whose MIDIPRESET-entryvalues you want to return
  </parameters>
  <chapter_context>
    FX-Management
    Get States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, get, fx, midipreset, keyboard input, plugin</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("GetFXMidiPreset_FXStateChunk", "FXStateChunk", "must be a valid FXStateChunk", -1) return nil end
  if math.type(fx_id)~="integer" then ultraschall.AddErrorMessage("GetFXMidiPreset_FXStateChunk", "fx_id", "must be an integer", -2) return nil end
  ultraschall.SuppressErrorMessages(true)
  local fx_lines, startoffset, endoffset = ultraschall.GetFXFromFXStateChunk(FXStateChunk, fx_id)
  if fx_lines==nil then ultraschall.SuppressErrorMessages(false) ultraschall.AddErrorMessage("GetFXMidiPreset_FXStateChunk", "fx_id", "no such fx", -4) return nil end
  local MIDIPreset=fx_lines:match("\n.-MIDIPRESET (.-)\n")
  if MIDIPreset==nil then ultraschall.SuppressErrorMessages(false) return 0 end
  local count, individual_values = ultraschall.CSV2IndividualLinesAsArray(MIDIPreset.." ", " ")
  for i=1, count do
    individual_values[i]=tonumber(individual_values[i])
  end
  ultraschall.SuppressErrorMessages(false)
  return table.unpack(individual_values)
end

function ultraschall.SetFXWak_FXStateChunk(FXStateChunk, fx_id, send_all_keyboard_input_to_fx, fx_embed_state)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetFXWak_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.19
    Lua=5.3
  </requires>
  <functioncall>string FXStateChunk = ultraschall.SetFXWak_FXStateChunk(string FXStateChunk, integer fxid, integer send_all_keyboard_input_to_fx, integer fx_embed_state)</functioncall>
  <description>
    sets the fx-WAK-entry of a specific fx within an FXStateChunk, which allows setting "sending all keyboard input to plugin"-option and "embed fx in tcp/mcp"-option of an fx
    
    returns nil in case of an error
  </description>
  <retvals>
    string FXStateChunk - the altered FXStateChunk with the new wak-state
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, into which you want to set the new wak-state
    integer fxid - the fx, whose wak-state you want to set
    integer send_all_keyboard_input_to_fx - state of sen all keyboard input to plug-in; 0, turned off; 1, turned on
    integer fx_embed_state - set embedding of the fx; &amp;1=TCP, &amp;2=MCP
  </parameters>
  <chapter_context>
    FX-Management
    Set States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, set, fx, wak, embed fx in tcp mcp, send all keyboardinput to fx</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("SetFXWak_FXStateChunk", "FXStateChunk", "must be a valid FXStateChunk", -1) return nil end
  if math.type(fx_id)~="integer" then ultraschall.AddErrorMessage("SetFXWak_FXStateChunk", "fx_id", "must be an integer", -2) return nil end
  if math.type(send_all_keyboard_input_to_fx)~="integer" then ultraschall.AddErrorMessage("SetFXWak_FXStateChunk", "send_all_keyboard_input_to_fx", "must be an integer", -3) return nil end
  if math.type(fx_embed_state)~="integer" then ultraschall.AddErrorMessage("SetFXWak_FXStateChunk", "fx_embed_state", "must be an integer", -4) return nil end
  
  local fx_lines, startoffset, endoffset = ultraschall.GetFXFromFXStateChunk(FXStateChunk, fx_id)
  fx_lines=string.gsub(fx_lines, "WAK.-\n", "WAK "..send_all_keyboard_input_to_fx.." "..fx_embed_state.."\n")
  FXStateChunk=FXStateChunk:sub(1, startoffset-1)..fx_lines..FXStateChunk:sub(endoffset, -1)
  return FXStateChunk
end


function ultraschall.SetFXMidiPreset_FXStateChunk(FXStateChunk, fx_id, midi_preset)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetFXMidiPreset_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>string FXStateChunk = ultraschall.SetFXMidiPreset_FXStateChunk(string FXStateChunk, integer fxid, integer midi_preset)</functioncall>
  <description>
    sets the MIDIPRESET-entryvalues of a specific fx from an FXStateChunk as set by the +-button->Link to MIDI program change-menuentry in the FX-window of the visible plugin.
    
    returns nil in case of an error
  </description>
  <retvals>
    string FXStateChunk - the altered FXStateChunk with the new comment
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, into which you want to set the new comment
    integer fxid - the fx, whose comment you want to set
    integer midi_preset - 0, No Link; 17, Link all channels sequentially; 1-16, MIDI-channel 1-16 
  </parameters>
  <chapter_context>
    FX-Management
    Set States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, set, fx, midi preset</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("SetFXMidiPreset_FXStateChunk", "FXStateChunk", "must be a valid FXStateChunk", -1) return nil end
  if math.type(fx_id)~="integer" then ultraschall.AddErrorMessage("SetFXMidiPreset_FXStateChunk", "fx_id", "must be an integer", -2) return nil end
  if math.type(midi_preset)~="integer" then ultraschall.AddErrorMessage("SetFXMidiPreset_FXStateChunk", "midi_preset", "must be an integer", -3) return nil end
  
  local fx_lines, startoffset, endoffset = ultraschall.GetFXFromFXStateChunk(FXStateChunk, fx_id)
  if midi_preset==0 then midi_preset="" else midi_preset="MIDIPRESET "..midi_preset.."\n    " end
  fx_lines=string.gsub(fx_lines, "\n( -MIDIPRESET.-\n)", "\n")
  local offset=fx_lines:match("()PRESETNAME")
  fx_lines=fx_lines:sub(1,offset-1)..midi_preset..fx_lines:sub(offset,-1)
  FXStateChunk=FXStateChunk:sub(1, startoffset-1)..fx_lines..FXStateChunk:sub(endoffset, -1)
  return FXStateChunk
end

function ultraschall.GetFXBypass_FXStateChunk(FXStateChunk, fx_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetFXBypass_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer bypass, integer offline, integer unknown = ultraschall.GetFXBypass_FXStateChunk(string FXStateChunk, integer fxid)</functioncall>
  <description>
    returns the BYPASS-entryvalues of a specific fx from an FXStateChunk, like bypass and online-state..
    
    returns nil in case of an error
  </description>
  <retvals>
    integer bypass - 0, non-bypassed; 1, bypassed
    integer offline - 0, online; 1, offline
    integer unknown - unknown; default is 0
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, from whose fx you want to return the BYPASS-entry
    integer fxid - the fx, whose BYPASS-entryvalues you want to return
  </parameters>
  <chapter_context>
    FX-Management
    Get States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, get, fx, bypass, online, offline</tags>
</US_DocBloc>
]]

  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("GetFXBypass_FXStateChunk.GetFXWAK_FXStateChunk()", "FXStateChunk", "must be a valid FXStateChunk", -1) return nil end
  if math.type(fx_id)~="integer" then ultraschall.AddErrorMessage("GetFXBypass_FXStateChunk", "fx_id", "must be an integer", -2) return nil end
  ultraschall.SuppressErrorMessages(true)
  local fx_lines, startoffset, endoffset = ultraschall.GetFXFromFXStateChunk(FXStateChunk, fx_id)
  if fx_lines==nil then ultraschall.SuppressErrorMessages(false) ultraschall.AddErrorMessage("GetFXBypass_FXStateChunk", "fx_id", "no such fx", -4) return nil end
  local BYPASS=fx_lines:match("\n.-BYPASS (.-)\n")
  
  local count, individual_values = ultraschall.CSV2IndividualLinesAsArray(BYPASS.." ", " ")
  for i=1, count do
    individual_values[i]=tonumber(individual_values[i])
  end
  ultraschall.SuppressErrorMessages(false)
  return table.unpack(individual_values)
end

function ultraschall.GetFXFloatPos_FXStateChunk(FXStateChunk, fx_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetFXFloatPos_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean floating, integer x, integer y, integer width, integer height = ultraschall.GetFXFloatPos_FXStateChunk(string FXStateChunk, integer fxid)</functioncall>
  <description>
    returns the FLOATPOS/FLOAT-entryvalues of a specific fx from an FXStateChunk, like float-state and float-coordinates.
    
    If all coordinates of the floating fx-window are 0, then the fx-window was never in float-state, yet.
    
    There is only one of the FLOATPOS/FLOAT-entries present at any time.
    FLOATPOS, when the fx-window is not floating
    FLOAT, when the fx-window is floating.
    
    returns nil in case of an error
  </description>
  <retvals>
    boolean floating - true, fx-window is floating; false, fx-window isn't floating
    integer x - the x-position of the floating window; 0, if it hasn't been floating yet
    integer y - the y-position of the floating window; 0, if it hasn't been floating yet
    integer width - the width of the floating window; 0, if it hasn't been floating yet
    integer height - the height of the floating window; 0, if it hasn't been floating yet
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, from whose fx you want to return the FLOAT/FLOATPOS-entry
    integer fxid - the fx, whose FLOAT/FLOATPOS-entryvalues you want to return
  </parameters>
  <chapter_context>
    FX-Management
    Get States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, get, fx, float, floatpos, floatstate</tags>
</US_DocBloc>
]]

  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("GetFXFloatPos_FXStateChunk.GetFXWAK_FXStateChunk()", "FXStateChunk", "must be a valid FXStateChunk", -1) return nil end
  if math.type(fx_id)~="integer" then ultraschall.AddErrorMessage("GetFXFloatPos_FXStateChunk", "fx_id", "must be an integer", -2) return nil end
  ultraschall.SuppressErrorMessages(true)
  local fx_lines, startoffset, endoffset = ultraschall.GetFXFromFXStateChunk(FXStateChunk, fx_id)
  if fx_lines==nil then ultraschall.SuppressErrorMessages(false) ultraschall.AddErrorMessage("GetFXFloatPos_FXStateChunk", "fx_id", "no such fx", -4) return nil end
  local float, FLOATPOS=fx_lines:match("\n.-FLOAT(%a-) (.-)\n")
  
  local count, individual_values = ultraschall.CSV2IndividualLinesAsArray(FLOATPOS.." ", " ")
  for i=1, count do
    individual_values[i]=tonumber(individual_values[i])
  end
  ultraschall.SuppressErrorMessages(false)
  return float~="POS", table.unpack(individual_values)
end

function ultraschall.GetFXGuid_FXStateChunk(FXStateChunk, fx_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetFXGuid_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>string guid = ultraschall.GetFXGuid_FXStateChunk(string FXStateChunk, integer fxid)</functioncall>
  <description>
    returns the FXID-entryvalues of a specific fx from an FXStateChunk, which is the guid of the fx.

    returns nil in case of an error
  </description>
  <retvals>
    string guid - the guid of the fx
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, from whose fx you want to return the guid-entry
    integer fxid - the fx, whose guid you want to return
  </parameters>
  <chapter_context>
    FX-Management
    Get States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, get, fx, guid</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("GetFXGuid_FXStateChunk.GetFXWAK_FXStateChunk()", "FXStateChunk", "must be a valid FXStateChunk", -1) return nil end
  if math.type(fx_id)~="integer" then ultraschall.AddErrorMessage("GetFXGuid_FXStateChunk", "fx_id", "must be an integer", -2) return nil end
  ultraschall.SuppressErrorMessages(true)
  local fx_lines, startoffset, endoffset = ultraschall.GetFXFromFXStateChunk(FXStateChunk, fx_id)
  if fx_lines==nil then ultraschall.SuppressErrorMessages(false) ultraschall.AddErrorMessage("GetFXGuid_FXStateChunk", "fx_id", "no such fx", -4) return nil end
  local GUID=fx_lines:match("\n.-FXID (.-)\n")

  ultraschall.SuppressErrorMessages(false)
  return GUID
end

function ultraschall.GetWndRect_FXStateChunk(FXStateChunk, fx_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetWndRect_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer x, integer y, integer width, integer height = ultraschall.GetWndRect_FXStateChunk(string FXStateChunk, integer fxid)</functioncall>
  <description>
    returns the WNDRECT-entryvalues from an FXStateChunk.
    
    These are the window-positions of the fx-chain, when the window is floating.
    
    returns nil in case of an error
  </description>
  <retvals>
    integer x - the x-position of the floating window; 0, if it hasn't been floating yet
    integer y - the y-position of the floating window; 0, if it hasn't been floating yet
    integer width - the width of the floating window; 0, if it hasn't been floating yet
    integer height - the height of the floating window; 0, if it hasn't been floating yet
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, whose floating-window-position you want to get
  </parameters>
  <chapter_context>
    FX-Management
    Get States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, get, wndrect, fxstatechunk, floating window position</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("GetWndRect_FXStateChunk", "FXStateChunk", "must be a valid FXStateChunk", -1) return nil end
  local WNDRect=FXStateChunk:match("\n.-WNDRECT (.-)\n")
  local count, individual_values = ultraschall.CSV2IndividualLinesAsArray(WNDRect.." ", " ")
  for i=1, count do
    individual_values[i]=tonumber(individual_values[i])
  end
  
  return table.unpack(individual_values)
end

function ultraschall.GetShow_FXStateChunk(FXStateChunk, fx_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetShow_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer showstate = ultraschall.GetShow_FXStateChunk(string FXStateChunk, integer fxid)</functioncall>
  <description>
    returns the SHOW-entryvalues from an FXStateChunk.
    
    This shows, whether the fxchain is currently shown and which fx is visible in Reaper's UI.
    
    returns nil in case of an error
  </description>
  <retvals>
    integer shownstate - 0, the fx-chain is not shown; 1, first fx is shown; 2, second fx is shown, etc
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, whose show-state you want to get
  </parameters>
  <chapter_context>
    FX-Management
    Get States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, get, showstate</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("GetShow_FXStateChunk", "FXStateChunk", "must be a valid FXStateChunk", -1) return nil end
  local Show=FXStateChunk:match("\n.-SHOW (.-)\n")
  local count, individual_values = ultraschall.CSV2IndividualLinesAsArray(Show.." ", " ")
  for i=1, count do
    individual_values[i]=tonumber(individual_values[i])
  end
  
  return table.unpack(individual_values)
end

function ultraschall.GetLastSel_FXStateChunk(FXStateChunk, fx_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetLastSel_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer last_selected_fx = ultraschall.GetLastSel_FXStateChunk(string FXStateChunk, integer fxid)</functioncall>
  <description>
    returns the LASTSEL-entryvalues from an FXStateChunk.
    
    returns nil in case of an error
  </description>
  <retvals>
    integer last_selected_fx - the last selected fx; 1, the first fx; 2, the second fx; 3, the third fx
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, whose last-selected-fx you want to get
  </parameters>
  <chapter_context>
    FX-Management
    Get States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, get, last selected fx</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("GetLastSel_FXStateChunk", "FXStateChunk", "must be a valid FXStateChunk", -1) return nil end
  local LASTSEL=FXStateChunk:match("\n.-LASTSEL (.-)\n")
  local count, individual_values = ultraschall.CSV2IndividualLinesAsArray(LASTSEL.." ", " ")
  for i=1, count do
    individual_values[i]=tonumber(individual_values[i])
  end
  individual_values[1]=individual_values[1]+1
  return table.unpack(individual_values)
end

function ultraschall.GetDocked_FXStateChunk(FXStateChunk, fx_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetDocked_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer dockstate = ultraschall.GetDocked_FXStateChunk(string FXStateChunk, integer fxid)</functioncall>
  <description>
    returns the DOCKED-entryvalues from an FXStateChunk.
    
    returns nil in case of an error
  </description>
  <retvals>
    integer dockstate - 0, undocked; 1, docked
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, whose dockstate you want to get
  </parameters>
  <chapter_context>
    FX-Management
    Get States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, get, dockstate</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("GetDocked_FXStateChunk", "FXStateChunk", "must be a valid FXStateChunk", -1) return nil end
  local GetDocked_FXStateChunk=FXStateChunk:match("\n.-DOCKED (.-)\n")
  local count, individual_values = ultraschall.CSV2IndividualLinesAsArray(GetDocked_FXStateChunk.." ", " ")
  for i=1, count do
    individual_values[i]=tonumber(individual_values[i])
  end
  return table.unpack(individual_values)
end

function ultraschall.GetAllCustomMarkerNames()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllCustomMarkerNames</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer count, table custom_marker_names = ultraschall.GetAllCustomMarkerNames()</functioncall>
  <description>
    Will return all names of all available custom-markers.
  </description>  
  <retvals markup_type="markdown" markup_version="1.0.1" indent="default">
    integer count - the number of found markers; -1, in case of an error
    table custom_marker_names - a table with all found custom-markernames. 
  </retvals>
  <chapter_context>
    Markers
    Custom Markers
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>marker management, get, all, custom marker names</tags>
</US_DocBloc>
]]
  local MarkerNames={}
  local CountMarkerNames=0
  for i=0, reaper.CountProjectMarkers(0)-1 do
    local A,B,C,D,E,F=reaper.EnumProjectMarkers(i)
    if B==false then
      local name=E:match("%_(.-):")
      if name~=nil then CountMarkerNames=CountMarkerNames+1 MarkerNames[CountMarkerNames]=name end
    end
  end
  return CountMarkerNames, MarkerNames
end

--A1,B1=ultraschall.GetAllCustomMarkerNames()

function ultraschall.GetAllCustomRegionNames()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllCustomRegionNames</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer count, table custom_region_names = ultraschall.GetAllCustomRegionNames()</functioncall>
  <description>
    Will return all names of all available custom-regions.
  </description>  
  <retvals markup_type="markdown" markup_version="1.0.1" indent="default">
    integer count - the number of found markers; -1, in case of an error
    table custom_region_names - a table with all found custom-regionnames. 
  </retvals>
  <chapter_context>
    Markers
    Custom Markers
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>marker management, get, all, custom region names</tags>
</US_DocBloc>
]]
  local MarkerNames={}
  local CountMarkerNames=0
  for i=0, reaper.CountProjectMarkers(0)-1 do
    local A,B,C,D,E=reaper.EnumProjectMarkers(i)
    if B==true then
      local name=E:match("%_(.-):")
      if name~=nil then CountMarkerNames=CountMarkerNames+1 MarkerNames[CountMarkerNames]=name end
    end
  end
  return CountMarkerNames, MarkerNames
end

--A,B=ultraschall.GetAllCustomMarkerNames()

function ultraschall.SetFXBypass_FXStateChunk(FXStateChunk, fx_id, bypass, online, unknown)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetFXBypass_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.19
    Lua=5.3
  </requires>
  <functioncall>string FXStateChunk = ultraschall.SetFXBypass_FXStateChunk(string FXStateChunk, integer fxid, integer bypass, integer offline, integer unknown)</functioncall>
  <description>
    sets the fx-BYPASS-entry of a specific fx within an FXStateChunk, which allows setting online/offline and bypass-settings.
    
    returns nil in case of an error
  </description>
  <retvals>
    string FXStateChunk - the altered FXStateChunk with the new BYPASS-state
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, into which you want to set the new bypass-state
    integer fxid - the fx, whose bypass-state you want to set
    integer bypass - 0, non-bypassed; 1, bypassed
    integer offline - 0, online; 1, offline
    integer unknown - unknown; default is 0
  </parameters>
  <chapter_context>
    FX-Management
    Set States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, set, fx, bypass, online/offline</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("SetFXBypass_FXStateChunk", "FXStateChunk", "must be a valid FXStateChunk", -1) return nil end
  if math.type(fx_id)~="integer" then ultraschall.AddErrorMessage("SetFXBypass_FXStateChunk", "fx_id", "must be an integer", -2) return nil end
  if math.type(bypass)~="integer" then ultraschall.AddErrorMessage("SetFXBypass_FXStateChunk", "bypass", "must be an integer", -3) return nil end
  if math.type(online)~="integer" then ultraschall.AddErrorMessage("SetFXBypass_FXStateChunk", "online", "must be an integer", -4) return nil end
  if math.type(unknown)~="integer" then ultraschall.AddErrorMessage("SetFXBypass_FXStateChunk", "unknown", "must be an integer", -5) return nil end
  
  local fx_lines, startoffset, endoffset = ultraschall.GetFXFromFXStateChunk(FXStateChunk, fx_id)
  fx_lines=string.gsub(fx_lines, "BYPASS.-\n", "BYPASS "..bypass.." "..online.." "..unknown.."\n")
  FXStateChunk=FXStateChunk:sub(1, startoffset-1)..fx_lines..FXStateChunk:sub(endoffset, -1)
  return FXStateChunk
end

function ultraschall.SetShow_FXStateChunk(FXStateChunk, showstate)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetShow_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.19
    Lua=5.3
  </requires>
  <functioncall>string FXStateChunk = ultraschall.SetShow_FXStateChunk(string FXStateChunk, integer showstate)</functioncall>
  <description>
    sets the shown-plugin of an FXStateChunk.
    
    It is the SHOW-entry
    
    returns nil in case of an error
  </description>
  <retvals>
    string FXStateChunk - the altered FXStateChunk with the new SHOW-state
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, into which you want to set the new shown-fx-state
    integer showstate - the fx shown; 1, for the first fx; 2, for the second fx; etc
  </parameters>
  <chapter_context>
    FX-Management
    Set States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, set, fx, show fx</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("SetShow_FXStateChunk", "FXStateChunk", "must be a valid FXStateChunk", -1) return nil end
  if math.type(showstate)~="integer" then ultraschall.AddErrorMessage("SetShow_FXStateChunk", "showstate", "must be an integer", -2) return nil end
  
  FXStateChunk=string.gsub(FXStateChunk, "\n    SHOW .-\n", "\n    SHOW "..showstate.."\n")
  return FXStateChunk
end

function ultraschall.SetWndRect_FXStateChunk(FXStateChunk, x, y, w, h)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetWndRect_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.19
    Lua=5.3
  </requires>
  <functioncall>string FXStateChunk = ultraschall.SetWndRect_FXStateChunk(string FXStateChunk, integer x, integer y, integer w, integer h)</functioncall>
  <description>
    sets the docked-state of an FXStateChunk.
    
    It is the WNDRECT-entry
    
    returns nil in case of an error
  </description>
  <retvals>
    string FXStateChunk - the altered FXStateChunk with the new WNDRECT-state
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, into which you want to set the new undocked-windowposition-state
    integer x - the x-position of the undocked window
    integer y - the y-position of the undocked window
    integer w - the width of the window-rectangle
    integer h - the height of the window-rectangle
  </parameters>
  <chapter_context>
    FX-Management
    Set States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, set, fx, last selected</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("SetWndRect_FXStateChunk", "FXStateChunk", "must be a valid FXStateChunk", -1) return nil end
  if math.type(x)~="integer" then ultraschall.AddErrorMessage("SetWndRect_FXStateChunk", "x", "must be an integer", -2) return nil end
  if math.type(y)~="integer" then ultraschall.AddErrorMessage("SetWndRect_FXStateChunk", "y", "must be an integer", -3) return nil end
  if math.type(w)~="integer" then ultraschall.AddErrorMessage("SetWndRect_FXStateChunk", "w", "must be an integer", -4) return nil end
  if math.type(h)~="integer" then ultraschall.AddErrorMessage("SetWndRect_FXStateChunk", "h", "must be an integer", -5) return nil end
  
  FXStateChunk=string.gsub(FXStateChunk, "\n    WNDRECT .-\n", "\n    WNDRECT "..x.." "..y.." "..w.." "..h.."\n")
  return FXStateChunk
end

function ultraschall.SetDocked_FXStateChunk(FXStateChunk, docked)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetDocked_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.19
    Lua=5.3
  </requires>
  <functioncall>string FXStateChunk = ultraschall.SetDocked_FXStateChunk(string FXStateChunk, integer docked)</functioncall>
  <description>
    sets the docked-state of an FXStateChunk.
    
    It is the DOCKED-entry
    
    returns nil in case of an error
  </description>
  <retvals>
    string FXStateChunk - the altered FXStateChunk with the new DOCKED-state
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, into which you want to set the new last-selected-fx-state
    integer docked - the docked-state of the fx-chain-window; 0, undocked; 1, docked
  </parameters>
  <chapter_context>
    FX-Management
    Set States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, set, fx, docked</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("SetDocked_FXStateChunk", "FXStateChunk", "must be a valid FXStateChunk", -1) return nil end
  if math.type(docked)~="integer" then ultraschall.AddErrorMessage("SetDocked_FXStateChunk", "docked", "must be an integer", -2) return nil end
  
  FXStateChunk=string.gsub(FXStateChunk, "\n    DOCKED .-\n", "\n    DOCKED "..docked.."\n")
  return FXStateChunk
end

function ultraschall.SetLastSel_FXStateChunk(FXStateChunk, lastsel)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetLastSel_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.19
    Lua=5.3
  </requires>
  <functioncall>string FXStateChunk = ultraschall.SetLastSel_FXStateChunk(string FXStateChunk, integer lastsel)</functioncall>
  <description>
    sets the last selected-plugin of an FXStateChunk.
    
    It is the LASTSEL-entry
    
    returns nil in case of an error
  </description>
  <retvals>
    string FXStateChunk - the altered FXStateChunk with the new LASTSEL-state
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, into which you want to set the new last-selected-fx-state
    integer lastsel - the last fx selected; 1, for the first fx; 2, for the second fx; etc
  </parameters>
  <chapter_context>
    FX-Management
    Set States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, set, fx, last selected</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("SetLastSel_FXStateChunk", "FXStateChunk", "must be a valid FXStateChunk", -1) return nil end
  if math.type(lastsel)~="integer" then ultraschall.AddErrorMessage("SetLastSel_FXStateChunk", "lastsel", "must be an integer", -2) return nil end
  lastsel=lastsel-1
  
  FXStateChunk=string.gsub(FXStateChunk, "\n    LASTSEL .-\n", "\n    LASTSEL "..lastsel.."\n")
  return FXStateChunk
end

function ultraschall.SetFXGuid_FXStateChunk(FXStateChunk, floating, fx_id, guid)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetFXGuid_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.19
    Lua=5.3
  </requires>
  <functioncall>string FXStateChunk = ultraschall.SetFXGuid_FXStateChunk(string FXStateChunk, integer fxid, string guid)</functioncall>
  <description>
    sets the fx-FXID-entry of a specific fx within an FXStateChunk, which holds the guid for this fx.
    
    returns nil in case of an error
  </description>
  <retvals>
    string FXStateChunk - the altered FXStateChunk with the new BYPASS-state
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, into which you want to set the new gui
    integer fxid - the fx, whose guid you want to set
    string guid - a guid for this fx; use reaper.genGuid to create one
  </parameters>
  <chapter_context>
    FX-Management
    Set States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, set, fx, guid</tags>
</US_DocBloc>
]]

  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("SetFXGuid_FXStateChunk", "FXStateChunk", "must be a valid FXStateChunk", -1) return nil end
  if math.type(fx_id)~="integer" then ultraschall.AddErrorMessage("SetFXGuid_FXStateChunk", "fx_id", "must be an integer", -2) return nil end
  if type(guid)~="string" then ultraschall.AddErrorMessage("SetFXGuid_FXStateChunk", "guid", "must be a string", -3) return nil end
  if ultraschall.IsValidGuid(guid, true)==false then ultraschall.AddErrorMessage("SetFXGuid_FXStateChunk", "guid", "must be a valid guid; use reaper.genGuid to create one.", -4) return nil end
  
  local fx_lines, startoffset, endoffset = ultraschall.GetFXFromFXStateChunk(FXStateChunk, fx_id)
  fx_lines=string.gsub(fx_lines, "FXID.-\n", "FXID "..guid.."\n")
  FXStateChunk=FXStateChunk:sub(1, startoffset-1)..fx_lines..FXStateChunk:sub(endoffset, -1)
  return FXStateChunk
end

function ultraschall.SetFXFloatPos_FXStateChunk(FXStateChunk, fx_id, floating, x, y, w, h)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetFXFloatPos_FXStateChunk</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.19
    Lua=5.3
  </requires>
  <functioncall>string FXStateChunk = ultraschall.SetFXFloatPos_FXStateChunk(string FXStateChunk, integer fxid, boolean floating, integer x, integer y, integer w, integer h)</functioncall>
  <description>
    sets the fx-FXID-entry of a specific fx within an FXStateChunk, which manages floatstate and position of the floating-fx-window.
    
    Note: when committing it to a track/item of an opened project, keep in mind that setting floating=false will have no effect.
    You will also need to commit a TrackStateChunk/ItemStateChunk twice, as in the first commit, w and h will be ignored if the fx isn't already floating.
    This is probably due a Reaper bug and I can't fix it in here, sorry.
    
    returns nil in case of an error
  </description>
  <retvals>
    string FXStateChunk - the altered FXStateChunk with the new BYPASS-state
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, into which you want to set the new bypass-state
    integer fxid - the fx, whose bypass-state you want to set
    boolean floating - true, window is floating; false, window is not floating
    integer x - the x-position of the floating-window
    integer y - the y-position of the floating-window
    integer w - the width of the window(will be ignored, when committing changed statechunk only once to current project's track/item)
    integer h - the height of the window(will be ignored, when committing changed statechunk only once to current project's track/item) 
  </parameters>
  <chapter_context>
    FX-Management
    Set States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, set, fx, floatposition, x, y, w, g</tags>
</US_DocBloc>
]]

  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("SetFXFloatPos_FXStateChunk", "FXStateChunk", "must be a valid FXStateChunk", -1) return nil end
  if math.type(fx_id)~="integer" then ultraschall.AddErrorMessage("SetFXFloatPos_FXStateChunk", "fx_id", "must be an integer", -2) return nil end
  if type(floating)~="boolean" then ultraschall.AddErrorMessage("SetFXFloatPos_FXStateChunk", "floating", "must be a boolean", -3) return nil end
  if math.type(x)~="integer" then ultraschall.AddErrorMessage("SetFXFloatPos_FXStateChunk", "x", "must be an integer", -4) return nil end
  if math.type(y)~="integer" then ultraschall.AddErrorMessage("SetFXFloatPos_FXStateChunk", "y", "must be an integer", -5) return nil end
  if math.type(w)~="integer" then ultraschall.AddErrorMessage("SetFXFloatPos_FXStateChunk", "w", "must be an integer", -6) return nil end
  if math.type(h)~="integer" then ultraschall.AddErrorMessage("SetFXFloatPos_FXStateChunk", "h", "must be an integer", -7) return nil end
  
  if floating==true then floating="" else floating="POS" end
  local fx_lines, startoffset, endoffset = ultraschall.GetFXFromFXStateChunk(FXStateChunk, fx_id)
  fx_lines=string.gsub(fx_lines, "FLOAT.- .-\n", "FLOAT"..floating.." "..x.." "..y.." "..w.." "..h.."\n")
  FXStateChunk=FXStateChunk:sub(1, startoffset-1)..fx_lines..FXStateChunk:sub(endoffset, -1)
  return FXStateChunk
end

ultraschall.ShowLastErrorMessage()
