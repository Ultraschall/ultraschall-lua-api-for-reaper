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
    Ultraschall=4.1
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

-- Ultraschall 4.1.006

function SFEM()
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>SFEM</slug>
    <requires>
      Ultraschall=4.1
      Reaper=5.40
      Lua=5.3
    </requires>
    <functioncall>requested_error_message = SFEM(optional integer dunk, optional integer target, optional integer message_type)</functioncall>
    <description>
      Displays the first error message in a messagebox, the ReaScript-Console, the clipboard, if error is existing and unread.
    </description>
    <retvals>
      requested_error_message - the errormessage requested; 
    </retvals>
    <parameters>
      optional integer dunk - allows to index the last x'ish message to be returned; nil or 0, the last one; 1, the one before the last one, etc.
      optional integer target - the target, where the error-message shall be output to
                              - 0 or nil, target is a message box
                              - 1, target is the ReaScript-Console
                              - 2, target is the clipboard
                              - 3, target is a returned string
      optional integer message_type - if target is set to 3, you can set, which part of the error-messageshall be returned as returnvalue
                                    - nil or 1, returns true, if error has happened, false, if error didn't happen
                                    - 2, returns the errcode
                                    - 3, returns the functionname which caused the error
                                    - 4, returns the parmname which caused the error
                                    - 5, returns the errormessage
                                    - 6, returns the lastreadtime
                                    - 7, returns the err_creation_date
                                    - 8, returns the err_creation_timestamp      
    </parameters>
    <chapter_context>
      Developer
      Error Handling
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>ultraschall_functions_engine.lua</source_document>
    <tags>developer, error, show, message</tags>
  </US_DocBloc>
  --]]
    local three
    if dunk=="dunk" then three="Three points" end
    dunk=math.tointeger(dunk)
    if dunk==nil then dunk=ultraschall.ErrorCounter-1 end
   
    if target==nil then 
      target=tonumber(reaper.GetExtState("ultraschall_api", "ShowLastErrorMessage_Target"))
    end
    
    local CountErrMessage=ultraschall.CountErrorMessages()
    if CountErrMessage<=0 then return end
    if dunk<0 then dunk=CountErrMessage+dunk else dunk=CountErrMessage-dunk end
    -- get the error-information
    --local retval, errcode, functionname, parmname, errormessage, lastreadtime, err_creation_date, err_creation_timestamp, errorcounter = ultraschall.GetLastErrorMessage()
      local retval, errcode, functionname, parmname, errormessage, lastreadtime, err_creation_date, err_creation_timestamp = ultraschall.ReadErrorMessage(dunk, true)
      --AAA=retval
    -- if errormessage exists and message is unread
    if retval==true and lastreadtime=="unread" then 
      if target==nil or target==0 then
        if parmname~="" then 
          -- if error-causing-parameter was given, display this message
          parmname="param: "..parmname 
          reaper.MB(functionname.."\n\n"..parmname.."\nerror  : "..errormessage.."\n\nerrcode: "..errcode,"Ultraschall Api Error Message",0) 
        else
          -- if no error-causing-parameter was given, display that message
          reaper.MB(functionname.."\n\nerror  : "..errormessage.."\n\nerrcode: "..errcode,"Ultraschall Api Error Message",0) 
        end
      elseif target==1 then
        if parmname~="" then 
          -- if error-causing-parameter was given, display this message
          parmname="param: "..parmname 
          reaper.ShowConsoleMsg("\n\nErrortime: "..os.date().."\n"..functionname.."\n\n"..parmname.."\nerror  : "..errormessage.."\n\nerrcode: "..errcode) 
        else
          -- if no error-causing-parameter was given, display that message
          reaper.ShowConsoleMsg("\n\nErrortime: "..os.date().."\n"..functionname.."\n\nerror  : "..errormessage.."\n\nerrcode: "..errcode) 
        end
      elseif target==2 then
        if parmname~="" then 
          -- if error-causing-parameter was given, display this message
          parmname="param: "..parmname 
          print3(functionname.."\n\n"..parmname.."\nerror  : "..errormessage.."\n\nerrcode: "..errcode) 
        else
          -- if no error-causing-parameter was given, display that message
          print3(functionname.."\n\nerror  : "..errormessage.."\n\nerrcode: "..errcode) 
        end  
      elseif target==3 then
        if      message_type==nil or message_type==1 then return retval
        elseif  message_type==2 then return errcode
        elseif  message_type==3 then return functionname
        elseif  message_type==4 then return parmname
        elseif  message_type==5 then return errormessage
        elseif  message_type==6 then return lastreadtime
        elseif  message_type==7 then return err_creation_date
        elseif  message_type==8 then return err_creation_timestamp     
        end
      end
    end
    local retval
    if parmname~="" then 
      -- if error-causing-parameter was given, display this message
      retval=functionname.."\n\n"..parmname.."\nerror  : "..errormessage.."\n\nerrcode: "..errcode
    else
      -- if no error-causing-parameter was given, display that message
      retval=functionname.."\n\nerror  : "..errormessage.."\n\nerrcode: "..errcode
    end  
    return retval, three
end

function ultraschall.IsTrackVisible(track, completely_visible)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>IsTrackVisible</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.IsTrackVisible(MediaTrack track, boolean completely_visible)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      returns if a track is currently visible in arrangeview
        
      returns nil in case of error
    </description>
    <retvals>
      boolean retval - true, track is visible; false, track is not visible
    </retvals>
    <parameters>
      MediaTrack track - the track, whose visibility you want to query
      boolean completely_visible - false, all tracks including partially visible ones; true, only fully visible tracks
    </parameters>
    <chapter_context>
      Track Management
      Assistance functions
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_TrackManagement_Module.lua</source_document>
    <tags>track management, get, visible, tracks, arrangeview</tags>
  </US_DocBloc>
  --]]
  if ultraschall.type(track)~="MediaTrack" then ultraschall.AddErrorMessage("IsTrackVisible", "track", "must be a MediaTrack", -1) return end
  if type(completely_visible)~="boolean" then ultraschall.AddErrorMessage("IsTrackVisible", "completely_visible", "must be a boolean", -2) return end
  local trackstring, tracktable_count, tracktable = ultraschall.GetAllVisibleTracks_Arrange(true, completely_visible)
  local found=false
  for i=1, tracktable_count do
    if tracktable[i]==track then found=true end
  end
  return found
end

function ultraschall.IsTrackVisible(track, completely_visible)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>IsTrackVisible</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>boolean visible = ultraschall.IsTrackVisible(MediaTrack track, boolean completely_visible)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      returns if a track is currently visible in arrangeview
      
      Note: Tracks who start above and end below the arrangeview will be treated as not completely visible!
        
      returns nil in case of error
    </description>
    <retvals>
      boolean visible - true, track is visible; false, track is not visible
    </retvals>
    <parameters>
      MediaTrack track - the track, whose visibility you want to query
      boolean completely_visible - false, the track can be partially visible; true, the track must be fully visible
    </parameters>
    <chapter_context>
      Track Management
      Assistance functions
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_TrackManagement_Module.lua</source_document>
    <tags>track management, get, visible, track, arrangeview</tags>
  </US_DocBloc>
  --]]
  if ultraschall.type(track)~="MediaTrack" then ultraschall.AddErrorMessage("IsTrackVisible", "track", "must be a MediaTrack", -1) return end
  if type(completely_visible)~="boolean" then ultraschall.AddErrorMessage("IsTrackVisible", "completely_visible", "must be a boolean", -2) return end
  local trackstring, tracktable_count, tracktable = ultraschall.GetAllVisibleTracks_Arrange(true, completely_visible)
  local found=false
  for i=1, tracktable_count do
    if tracktable[i]==track then found=true end
  end
  return found
end

--A=ultraschall.IsTrackVisible(reaper.GetMasterTrack(0,0), true)

--trackstring, tracktable_count, tracktable = ultraschall.GetAllVisibleTracks_Arrange(true, true)
--            ultraschall.GetAllVisibleTracks_Arrange(master_track, completely_visible)


function ultraschall.IsItemVisible(item, completely_visible)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>IsItemVisible</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>boolean visible, boolean parent_track_visible, boolean within_start_and_endtime  = ultraschall.IsItemVisible(MediaItem item, boolean completely_visible)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      returns if n item is currently visible in arrangeview

      Note: Items who start above and end below the visible arrangeview will be treated as not completely visible!
      
      parent_track_visible and within_start_and_endtime will allow you to determine, if the item could be visible if scrolled in only x or y direction.
        
      returns nil in case of error
    </description>
    <retvals>
      boolean visible - true, the item is visible; false, the item is not visible
      boolean parent_track_visible - true, its parent-track is visible; false, its parent track is not visible
      boolean within_start_and_endtime - true, the item is within start and endtime of the arrangeview; false, it is not
    </retvals>
    <parameters>
      MediaTrack track - the track, whose visibility you want to query
      boolean completely_visible - false, all tracks including partially visible ones; true, only fully visible tracks
    </parameters>
    <chapter_context>
      MediaItem Management
      Assistance functions
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_MediaItem_Module.lua</source_document>
    <tags>track management, get, visible, item, arrangeview</tags>
  </US_DocBloc>
  --]]
  if ultraschall.type(item)~="MediaTrack" then ultraschall.AddErrorMessage("IsItemVisible", "item", "must be a MediaItem", -1) return end
  if type(completely_visible)~="boolean" then ultraschall.AddErrorMessage("IsItemVisible", "completely_visible", "must be a boolean", -2) return end
  local MediaTrack=reaper.GetMediaItemInfo_Value(item, "P_TRACK")
  local trackstring, tracktable_count, tracktable = ultraschall.GetAllVisibleTracks_Arrange(false, completely_visible)
  local found=false
  for i=1, tracktable_count do
    if tracktable[i]==MediaTrack then found=true end
  end
  local start_item=reaper.GetMediaItemInfo_Value(item, "D_POSITION")
  local end_item=reaper.GetMediaItemInfo_Value(item, "D_LENGTH")+start_item
  local start_time, end_time = reaper.GetSet_ArrangeView2(0, false, 0, 0, 0, 0)
  local yeah=false
  
  if completely_visible==true then
    if start_item>=start_time and end_item<=end_time then yeah=true else yeah=false end
  else
    if start_item>=start_time and end_item<=end_time then yeah=true end
    if start_item<=end_time and end_item>=start_time then yeah=true end
  end
  return yeah==found, found, yeah
end


--A={ultraschall.IsItemVisible(reaper.GetMediaItem(0,0), false)}

function ultraschall.GetFocusedFX()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetFocusedFX</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer retval, integer tracknumber, integer fxidx, integer itemnumber, integer takeidx, MediaTrack track, optional MediaItem item, optional MediaItemTake take = ultraschall.GetFocusedFX()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the focused FX
  </description>
  <retvals>
    integer retval -   0, if no FX window has focus
                   -   1, if a track FX window has focus or was the last focused and still open
                   -   2, if an item FX window has focus or was the last focused and still open
    integer tracknumber - tracknumber; 0, master track; 1, track 1; etc.
    integer fxidx - the index of the FX; 1-based
    integer itemnumber - -1, if it's a track-fx; 1 and higher, the mediaitem-number
    integer takeidx - -1, if it's a track-fx; 1 and higher, the take-number
    MediaTrack track - the MediaTrack-object
    optional MediaItem item - the MediaItem, if take-fx
    optional MediaItemTake take - the MediaItem-Take, if take-fx
  </retvals>
  <chapter_context>
    FX-Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, get, focused, fx</tags>
</US_DocBloc>
]]    
  local retval, tracknumber, itemnumber, fxnumber = reaper.GetFocusedFX()
  if retval==0 then return 0 end
  local FXID, TakeID, item, take, track
  FXID=fxnumber+1
  TakeID=-1
  if itemnumber~=-1 then
    FXID=fxnumber&1+(fxnumber&2)+(fxnumber&4)+(fxnumber&8)+(fxnumber&16)+(fxnumber&32)+(fxnumber&64)+(fxnumber&128)+
         (fxnumber&256)+(fxnumber&512)+(fxnumber&1024)+(fxnumber&2048)+(fxnumber&4096)+(fxnumber&8192)+(fxnumber&16384)+(fxnumber&32768)
    TakeID=fxnumber>>16
    TakeID=TakeID+1
    FXID=FXID+1
    item=reaper.GetMediaItem(0, itemnumber)
    take=reaper.GetMediaItemTake(reaper.GetMediaItem(0, itemnumber), TakeID-1)
    itemnumber=itemnumber+1
  end

  if tracknumber>0 then 
    track=reaper.GetTrack(0, tracknumber-1)
  elseif tracknumber==0 then
    track=reaper.GetMasterTrack(0)
  end
  return retval, tracknumber, FXID, itemnumber, TakeID, track, item, take
end

function ultraschall.GetLastTouchedFX()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetLastTouchedFX</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval, integer sourcetype, integer track_take_number, integer fxnumber, integer paramnumber, integer takeID, optional MediaTrack track, optional MediaItemTake take = ultraschall.GetLastTouchedFX()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the last touched FX
    
    Note: Does not return last touched monitoring-FX!
  </description>
  <retvals>
    boolean retval - true, valid FX; false, no valid FX
    integer sourcetype - 0, takeFX; 1, trackFX
    integer track_take_number - the track or takenumber(see sourcetype-retval); 1-based
    integer fxnumber - the number of the fx; 1-based
    integer paramnumber - the number of the parameter; 1-based
    integer takeID - the number of the take; 1-based; -1, if takeFX
    optional MediaTrack track - the track of the TrackFX
    optional MediaItemTake take - the take of the TakeFX
  </retvals>
  <chapter_context>
    FX-Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FXManagement_Module.lua</source_document>
  <tags>fx management, get, last touched, fx</tags>
</US_DocBloc>
]]    
  local retval, tracknumber, fxnumber, paramnumber = reaper.GetLastTouchedFX()
  if retval==false then return false end
  local FXID, TakeID, track
  local inputfx=false
  if tracknumber>65536 then
    tracknumber=tracknumber&1+(tracknumber&2)+(tracknumber&4)+(tracknumber&8)+(tracknumber&16)+(tracknumber&32)+(tracknumber&64)+(tracknumber&128)+
         (tracknumber&256)+(tracknumber&512)+(tracknumber&1024)+(tracknumber&2048)+(tracknumber&4096)+(tracknumber&8192)+(tracknumber&16384)+(tracknumber&32768)
    FXID=fxnumber&1+(fxnumber&2)+(fxnumber&4)+(fxnumber&8)+(fxnumber&16)+(fxnumber&32)+(fxnumber&64)+(fxnumber&128)+
         (fxnumber&256)+(fxnumber&512)+(fxnumber&1024)+(fxnumber&2048)+(fxnumber&4096)+(fxnumber&8192)+(fxnumber&16384)+(fxnumber&32768)
    TakeID=fxnumber>>16           
    TakeID=TakeID+1
    Itemnumber=tracknumber
    return retval, 0, Itemnumber,  FXID+1,     paramnumber+1, TakeID, nil,   reaper.GetMediaItemTake(reaper.GetMediaItem(0, tracknumber-1), TakeID-1)
  else
    if tracknumber>0 then 
      track=reaper.GetTrack(0, tracknumber-1)
    elseif tracknumber==0 then
      track=reaper.GetMasterTrack(0)
    end
    return retval, 1, tracknumber, fxnumber+1, paramnumber+1, -1,     track, nil
  end
end

function ultraschall.EditReaScript(filename)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>EditReaScript</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.10
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.EditReaScript(string filename)</functioncall>
  <description>
    Opens a script in Reaper's ReaScript-IDE.
    
    If the file does not exist yet, it will try to create it. If parameter filename doesn't contain a valid directory, it will try to create the script in the Scripts-folder of Reaper.
    
    returns false in case of an error
  </description>
  <parameters>
    boolean flag - true, suppress error-messages; false, don't suppress error-messages
  </parameters>
  <retvals>
    boolean retval - true, setting was successful; false, you didn't pass a boolean as parameter
  </retvals>
  <chapter_context>
    Developer
    Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>developer, edit, reascript, ide</tags>
</US_DocBloc>
]]
  if type(filename)~="string" then ultraschall.AddErrorMessage("EditReaScript", "filename", "must be a string", -1) return false end
  if reaper.file_exists(filename)==false and ultraschall.DirectoryExists2(ultraschall.GetPath(filename))==false then
    local Path, Filename=ultraschall.GetPath(filename)
    filename=reaper.GetResourcePath().."/Scripts/"..Filename
  end
  if reaper.file_exists(filename)==false then
    ultraschall.WriteValueToFile(filename, "")
  end
  local A, B, C
  A=ultraschall.GetUSExternalState("REAPER", "lastscript", "reaper.ini")
  B=ultraschall.SetUSExternalState("REAPER", "lastscript", filename, "reaper.ini")
  reaper.Main_OnCommand(41931,0)
  C=ultraschall.SetUSExternalState("REAPER", "lastscript", A, "reaper.ini")
  return true
end

function ultraschall.Theme_Defaultv6_SetHideTCPElement(Layout, Element, if_mixer_visible, if_track_not_selected, if_track_not_armed, always_hide, persist)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Theme_Defaultv6_SetHideTCPElement</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.Theme_Defaultv6_SetHideTCPElement(string Layout, integer Element, boolean if_mixer_visible, boolean if_track_not_selected, boolean if_track_not_armed, boolean always_hide, boolean persist)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Hides/unhides elements from TCP when using the default Reaper 6-theme
    
    This reflects the settings from the Theme-Adjuster.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
  </retvals>
  <parameters>
    string Layout - the layout, whose element you want to hide/unhide; either "A", "B" or "C"
    integer Element - the element, whose hide-state you want to set
                    - 1, record arm
                    - 2, monitor
                    - 3, trackname
                    - 4, volume
                    - 5, routing
                    - 6, insert fx
                    - 7, envelope
                    - 8, pan and width
                    - 9, record mode
                    - 10, input
                    - 11, labels and values
                    - 12, meter values
    boolean if_mixer_visible - true, hide element, when mixer is visible; false, don't hide element, when mixer is visible
    boolean if_track_not_selected - true, hide element, when track is not selected; false, don't hide element when track is not selected
    boolean if_track_not_armed - true, hides element, when track is not armed; false, don't hide element when track is not armed
    boolean always_hide - true, always hides element; false, don't always hide element
    boolean persist - true, this setting persists after restart of Reaper; false, this setting is only valid until closing Reaper
  </parameters>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, set, hidel, element, tcp, default v6 theme</tags>
</US_DocBloc>
]]
  if Layout~="A" and Layout~="B" and Layout~="C" then ultraschall.AddErrorMessage("Theme_Defaultv6_SetHideTCPElement", "Layout", "must be either A, B or C", -1) return false end
  if math.type(Element)~="integer" then ultraschall.AddErrorMessage("Theme_Defaultv6_SetHideTCPElement", "Element", "must be an integer", -2) return false end
  if Element<1 or Element>12 then ultraschall.AddErrorMessage("Theme_Defaultv6_SetHideTCPElement", "Element", "must be between 1 and 12", -3) return false end
  if type(if_mixer_visible)~="boolean"  then ultraschall.AddErrorMessage("Theme_Defaultv6_SetHideTCPElement", "if_mixer_visible", "must be a boolean", -4) return false end
  
  if type(if_track_not_selected)~="boolean"  then ultraschall.AddErrorMessage("Theme_Defaultv6_SetHideTCPElement", "if_track_not_selected", "must be a boolean", -5) return false end
  if type(if_track_not_armed)~="boolean"  then ultraschall.AddErrorMessage("Theme_Defaultv6_SetHideTCPElement", "if_track_not_armed", "must be a boolean", -6) return false end
  if type(always_hide)~="boolean"  then ultraschall.AddErrorMessage("Theme_Defaultv6_SetHideTCPElement", "always_hide", "must be a boolean", -7) return false end
  if type(persist)~="boolean"  then ultraschall.AddErrorMessage("Theme_Defaultv6_SetHideTCPElement", "persist", "must be a boolean", -8) return false end

  local val=0
  if if_mixer_visible==true then val=val+1 end
  if if_track_not_selected==true then val=val+2 end
  if if_track_not_armed==true then val=val+4 end
  if always_hide==true then val=val+8 end
  if     Element==1 then elementname="Record_Arm" 
  elseif Element==2 then elementname="Monitor" 
  elseif Element==3 then elementname="Track_Name"
  elseif Element==4 then elementname="Volume"
  elseif Element==5 then elementname="Routing"
  elseif Element==6 then elementname="Effects"
  elseif Element==7 then elementname="Envelope"
  elseif Element==8 then elementname="Pan_&_Width"
  elseif Element==9 then elementname="Record_Mode"
  elseif Element==10 then elementname="Input"
  elseif Element==11 then elementname="Values"
  elseif Element==12 then elementname="Meter_Values"
  end

  ultraschall.SetThemeParameterIndexByDescription(Layout.."_tcp_"..elementname, val, persist, false)
  reaper.ThemeLayout_RefreshAll()
  return true
end

--ultraschall.Theme_Defaultv6_HideTCPElement("A", 1, true, false, false, false, false)


function ultraschall.Theme_Defaultv6_GetHideTCPElement(Layout, Element)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Theme_Defaultv6_GetHideTCPElement</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval, boolean if_mixer_visible, boolean if_track_not_selected, boolean if_track_not_armed, boolean always_hide = ultraschall.Theme_Defaultv6_GetHideTCPElement(string Layout, integer Element)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Get the current hides/unhide-state of elements from TCP when using the default Reaper 6-theme
    
    This reflects the settings from the Theme-Adjuster.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, getting was successful; false, getting was unsuccessful
    boolean if_mixer_visible - true, element is hidden, when mixer is visible; false, element is not hidden, when mixer is visible
    boolean if_track_not_selected - true, element is hidden, when track is not selected; false, element is not hidden when track is not selected
    boolean if_track_not_armed - true, element is hidden, when track is not armed; false, element is not hidden when track is not armed
    boolean always_hide - true, element is always hidden; false, element isn't always hidden
  </retvals>
  <parameters>
    string Layout - the layout, whose element-hide/unhide-state you want to get; either "A", "B" or "C"
    integer Element - the element, whose hide-state you want to get
                    - 1, record arm
                    - 2, monitor
                    - 3, trackname
                    - 4, volume
                    - 5, routing
                    - 6, insert fx
                    - 7, envelope
                    - 8, pan and width
                    - 9, record mode
                    - 10, input
                    - 11, labels and values
                    - 12, meter values
  </parameters>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, get, hidel, element, tcp, default v6 theme</tags>
</US_DocBloc>
]]
  if Layout~="A" and Layout~="B" and Layout~="C" then ultraschall.AddErrorMessage("Theme_Defaultv6_GetHideTCPElement", "Layout", "must be either A, B or C", -1) return false end
  if math.type(Element)~="integer" then ultraschall.AddErrorMessage("Theme_Defaultv6_GetHideTCPElement", "Element", "must be an integer", -2) return false end
  if Element<1 or Element>12 then ultraschall.AddErrorMessage("Theme_Defaultv6_GetHideTCPElement", "Element", "must be between 1 and 12", -3) return false end

  if     Element==1 then elementname="Record_Arm" 
  elseif Element==2 then elementname="Monitor" 
  elseif Element==3 then elementname="Track_Name"
  elseif Element==4 then elementname="Volume"
  elseif Element==5 then elementname="Routing"
  elseif Element==6 then elementname="Effects"
  elseif Element==7 then elementname="Envelope"
  elseif Element==8 then elementname="Pan_&_Width"
  elseif Element==9 then elementname="Record_Mode"
  elseif Element==10 then elementname="Input"
  elseif Element==11 then elementname="Values"
  elseif Element==12 then elementname="Meter_Values"
  end

  local parameterindex, retval, desc, val, defValue, minValue, maxValue 
  = ultraschall.GetThemeParameterIndexByDescription(Layout.."_tcp_"..elementname)
  return true, val&1~=0, val&2~=0, val&4~=0, val&8~=0
end

--ultraschall.Theme_Defaultv6_SetHideTCPElement("A", 1, false, false, false, true, false)
--A={ultraschall.Theme_Defaultv6_GetHideTCPElement("A", 1)}

function ultraschall.Theme_Defaultv6_SetTCPNameSize(Layout, size, persist)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Theme_Defaultv6_SetTCPNameSize</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.Theme_Defaultv6_SetTCPNameSize(string Layout, integer size, boolean persist)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Sets the size of the trackname-label in tcp
    
    This reflects the settings from the Theme-Adjuster.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
  </retvals>
  <parameters>
    string Layout - the layout, whose trackname-label-size you want to set; either "A", "B" or "C"
    integer size - the new size of the tcp-trackname-label
                    - 0, auto
                    - 1, 20
                    - 2, 50
                    - 3, 80
                    - 4, 110
                    - 5, 140
                    - 6, 170
    boolean persist - true, this setting persists after restart of Reaper; false, this setting is only valid until closing Reaper
  </parameters>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, set, trackname, label, tcp, default v6 theme</tags>
</US_DocBloc>
]]
  if Layout~="A" and Layout~="B" and Layout~="C" then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTCPNameSize", "Layout", "must be either A, B or C", -1) return false end
  if math.type(size)~="integer" then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTCPNameSize", "size", "must be an integer", -2) return false end
  if size<0 or size>6 then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTCPNameSize", "size", "must be between 0 and 6", -3) return false end
  local elementname="LabelSize"

  ultraschall.SetThemeParameterIndexByDescription(Layout.."_tcp_"..elementname, size+1, persist, false)
  reaper.ThemeLayout_RefreshAll()
  return true
end

--A=ultraschall.Theme_Defaultv6_SetTCPNameSize("A", 6, false)

function ultraschall.Theme_Defaultv6_GetTCPNameSize(Layout)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Theme_Defaultv6_GetTCPNameSize</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer size = ultraschall.Theme_Defaultv6_GetTCPNameSize(string Layout)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Gets the size of the trackname-label in tcp
    
    This reflects the settings from the Theme-Adjuster.
    
    returns nil in case of an error
  </description>
  <retvals>
    integer size - the current size of the tcp-trackname-label
                    - 0, auto
                    - 1, 20
                    - 2, 50
                    - 3, 80
                    - 4, 110
                    - 5, 140
                    - 6, 170
  </retvals>
  <parameters>
    string Layout - the layout, whose trackname-size you want to get; either "A", "B" or "C"
  </parameters>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, get, trackname, label, tcp, default v6 theme</tags>
</US_DocBloc>
]]
  if Layout~="A" and Layout~="B" and Layout~="C" then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTCPNameSize", "Layout", "must be either A, B or C", -1) return end
  local elementname="LabelSize"

  local A, B, C, size = ultraschall.GetThemeParameterIndexByDescription(Layout.."_tcp_"..elementname)
  return size-1
end

--A=ultraschall.Theme_Defaultv6_GetTCPNameSize("C")

function ultraschall.Theme_Defaultv6_SetTCPVolumeSize(Layout, size, persist)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Theme_Defaultv6_SetTCPVolumeSize</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.Theme_Defaultv6_SetTCPVolumeSize(string Layout, integer size, boolean persist)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Sets the size of the volume in tcp
    
    This reflects the settings from the Theme-Adjuster.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
  </retvals>
  <parameters>
    string Layout - the layout, whose volume-size you want to set; either "A", "B" or "C"
    integer size - the new size of the tcp-volume
                    - 0, knob
                    - 1, 40
                    - 2, 70
                    - 3, 100
                    - 4, 130
                    - 5, 160
                    - 6, 190
    boolean persist - true, this setting persists after restart of Reaper; false, this setting is only valid until closing Reaper
  </parameters>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, set, volume, tcp, default v6 theme</tags>
</US_DocBloc>
]]
  if Layout~="A" and Layout~="B" and Layout~="C" then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTCPVolumeSize", "Layout", "must be either A, B or C", -1) return false end
  if math.type(size)~="integer" then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTCPVolumeSize", "size", "must be an integer", -2) return false end
  if size<0 or size>6 then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTCPVolumeSize", "size", "must be between 0 and 6", -3) return false end
  local elementname="vol_size"

  ultraschall.SetThemeParameterIndexByDescription(Layout.."_tcp_"..elementname, size+1, persist, false)
  reaper.ThemeLayout_RefreshAll()
  return true
end

--A=ultraschall.Theme_Defaultv6_SetTCPVolumeSize("A", 2, false)

function ultraschall.Theme_Defaultv6_GetTCPVolumeSize(Layout)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Theme_Defaultv6_GetTCPVolumeSize</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer size = ultraschall.Theme_Defaultv6_GetTCPVolumeSize(string Layout)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Gets the size of the volume in tcp
    
    This reflects the settings from the Theme-Adjuster.
    
    returns nil in case of an error
  </description>
  <retvals>
    integer size - the current size of the tcp-volume
                    - 0, knob
                    - 1, 40
                    - 2, 70
                    - 3, 100
                    - 4, 130
                    - 5, 160
                    - 6, 190
  </retvals>
  <parameters>
    string Layout - the layout, whose volume-size you want to get; either "A", "B" or "C"
  </parameters>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, get, volume, tcp, default v6 theme</tags>
</US_DocBloc>
]]
  if Layout~="A" and Layout~="B" and Layout~="C" then ultraschall.AddErrorMessage("Theme_Defaultv6_GetTCPVolumeSize", "Layout", "must be either A, B or C", -1) return end
  local elementname="vol_size"

  local A, B, C, size = ultraschall.GetThemeParameterIndexByDescription(Layout.."_tcp_"..elementname)
  return size-1
end

--A=ultraschall.Theme_Defaultv6_GetTCPVolumeSize("A")

function ultraschall.Theme_Defaultv6_SetTCPInputSize(Layout, size, persist)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Theme_Defaultv6_SetTCPInputSize</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.Theme_Defaultv6_SetTCPInputSize(string Layout, integer size, boolean persist)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Sets the size of the input in tcp
    
    This reflects the settings from the Theme-Adjuster.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
  </retvals>
  <parameters>
    string Layout - the layout, whose input-size you want to set; either "A", "B" or "C"
    integer size - the new size of the tcp-input
                    - 0, MIN
                    - 1, 25
                    - 2, 40
                    - 3, 60
                    - 4, 90
                    - 5, 150
                    - 6, 200
    boolean persist - true, this setting persists after restart of Reaper; false, this setting is only valid until closing Reaper
  </parameters>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, set, input, tcp, default v6 theme</tags>
</US_DocBloc>
]]
  if Layout~="A" and Layout~="B" and Layout~="C" then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTCPInputSize", "Layout", "must be either A, B or C", -1) return false end
  if math.type(size)~="integer" then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTCPInputSize", "size", "must be an integer", -2) return false end
  if size<0 or size>6 then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTCPInputSize", "size", "must be between 0 and 6", -3) return false end
  local elementname="InputSize"

  ultraschall.SetThemeParameterIndexByDescription(Layout.."_tcp_"..elementname, size+1, persist, false)
  reaper.ThemeLayout_RefreshAll()
  return true
end

--A=ultraschall.Theme_Defaultv6_SetTCPInputSize("A", 2, false)

function ultraschall.Theme_Defaultv6_GetTCPInputSize(Layout)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Theme_Defaultv6_GetTCPInputSize</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer size = ultraschall.Theme_Defaultv6_GetTCPInputSize(string Layout)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Gets the size of the input in tcp
    
    This reflects the settings from the Theme-Adjuster.
    
    returns nil in case of an error
  </description>
  <retvals>
    integer size - the current size of the tcp-input
                    - 0, MIN
                    - 1, 25
                    - 2, 40
                    - 3, 60
                    - 4, 90
                    - 5, 150
                    - 6, 200
  </retvals>
  <parameters>
    string Layout - the layout, whose input-size you want to get; either "A", "B" or "C"
  </parameters>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, get, input, tcp, default v6 theme</tags>
</US_DocBloc>
]]
  if Layout~="A" and Layout~="B" and Layout~="C" then ultraschall.AddErrorMessage("Theme_Defaultv6_GetTCPInputSize", "Layout", "must be either A, B or C", -1) return end
  local elementname="InputSize"

  local A, B, C, size = ultraschall.GetThemeParameterIndexByDescription(Layout.."_tcp_"..elementname)
  return size-1
end

--A=ultraschall.Theme_Defaultv6_GetTCPInputSize("B")

function ultraschall.Theme_Defaultv6_SetTCPMeterSize(Layout, size, persist)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Theme_Defaultv6_SetTCPMeterSize</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.Theme_Defaultv6_SetTCPMeterSize(string Layout, integer size, boolean persist)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Sets the size of the meter in tcp
    
    This reflects the settings from the Theme-Adjuster.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
  </retvals>
  <parameters>
    string Layout - the layout, whose meter-size you want to set; either "A", "B" or "C"
    integer size - the new size of the tcp-meter
                    - 1, 4
                    - 2, 10
                    - 3, 20
                    - 4, 40
                    - 5, 80
                    - 6, 160
                    - 7, 320
    boolean persist - true, this setting persists after restart of Reaper; false, this setting is only valid until closing Reaper
  </parameters>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, set, meter, tcp, default v6 theme</tags>
</US_DocBloc>
]]
  if Layout~="A" and Layout~="B" and Layout~="C" then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTCPMeterSize", "Layout", "must be either A, B or C", -1) return false end
  if math.type(size)~="integer" then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTCPMeterSize", "size", "must be an integer", -2) return false end
  if size<1 or size>7 then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTCPMeterSize", "size", "must be between 1 and 7", -3) return false end
  local elementname="MeterSize"

  ultraschall.SetThemeParameterIndexByDescription(Layout.."_tcp_"..elementname, size, persist, false)
  reaper.ThemeLayout_RefreshAll()
  return true
end

--A=ultraschall.Theme_Defaultv6_SetTCPMeterSize("A", 1, false)

function ultraschall.Theme_Defaultv6_GetTCPMeterSize(Layout)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Theme_Defaultv6_GetTCPMeterSize</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer size = ultraschall.Theme_Defaultv6_GetTCPMeterSize(string Layout)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Gets the size of the meter in tcp
    
    This reflects the settings from the Theme-Adjuster.
    
    returns nil in case of an error
  </description>
  <retvals>
    integer size - the current size of the tcp-meter
                    - 1, 4
                    - 2, 10
                    - 3, 20
                    - 4, 40
                    - 5, 80
                    - 6, 160
                    - 7, 320
  </retvals>
  <parameters>
    string Layout - the layout, whose meter-size you want to get; either "A", "B" or "C"
  </parameters>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, get, meter, tcp, default v6 theme</tags>
</US_DocBloc>
]]
  if Layout~="A" and Layout~="B" and Layout~="C" then ultraschall.AddErrorMessage("Theme_Defaultv6_GetTCPMeterSize", "Layout", "must be either A, B or C", -1) return end
  local elementname="MeterSize"

  local A, B, C, size = ultraschall.GetThemeParameterIndexByDescription(Layout.."_tcp_"..elementname)
  return size
end

--A=ultraschall.Theme_Defaultv6_GetTCPMeterSize("A")

function ultraschall.Theme_Defaultv6_SetTCPMeterLocation(Layout, location, persist)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Theme_Defaultv6_SetTCPMeterLocation</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.Theme_Defaultv6_SetTCPMeterLocation(string Layout, integer location, boolean persist)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Sets the location of the meter in tcp
    
    This reflects the settings from the Theme-Adjuster.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
  </retvals>
  <parameters>
    string Layout - the layout, whose meter-location you want to set; either "A", "B" or "C"
    integer location - the new location of the tcp-meter
                    - 1, LEFT
                    - 2, RIGHT
                    - 3, LEFT IF ARMED
    boolean persist - true, this setting persists after restart of Reaper; false, this setting is only valid until closing Reaper
  </parameters>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, set, meter, location, tcp, default v6 theme</tags>
</US_DocBloc>
]]
  if Layout~="A" and Layout~="B" and Layout~="C" then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTCPMeterLocation", "Layout", "must be either A, B or C", -1) return false end
  if math.type(location)~="integer" then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTCPMeterLocation", "location", "must be an integer", -2) return false end
  if location<1 or location>3 then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTCPMeterLocation", "location", "must be between 1 and 3", -3) return false end
  local elementname="MeterLoc"

  ultraschall.SetThemeParameterIndexByDescription(Layout.."_tcp_"..elementname, location, persist, false)
  reaper.ThemeLayout_RefreshAll()
  return true
end

--A=ultraschall.Theme_Defaultv6_SetTCPMeterLocation("A", 3, false)

function ultraschall.Theme_Defaultv6_GetTCPMeterLocation(Layout)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Theme_Defaultv6_GetTCPMeterLocation</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer location = ultraschall.Theme_Defaultv6_GetTCPMeterLocation(string Layout)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Gets the location of the meter in tcp
    
    This reflects the settings from the Theme-Adjuster.
    
    returns nil in case of an error
  </description>
  <retvals>
    integer location - the current location of the tcp-meter
                    - 1, Left
                    - 2, Right
                    - 3, Left if armed
  </retvals>
  <parameters>
    string Layout - the layout, whose meter-location you want to get; either "A", "B" or "C"
  </parameters>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, get, meter, location, tcp, default v6 theme</tags>
</US_DocBloc>
]]
  if Layout~="A" and Layout~="B" and Layout~="C" then ultraschall.AddErrorMessage("Theme_Defaultv6_GetTCPMeterLocation", "Layout", "must be either A, B or C", -1) return end
  local elementname="MeterLoc"

  local A, B, C, location = ultraschall.GetThemeParameterIndexByDescription(Layout.."_tcp_"..elementname)
  return location
end

--A=ultraschall.Theme_Defaultv6_GetTCPMeterLocation("A")

function ultraschall.Theme_Defaultv6_SetTCPFolderIndent(indent, persist)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Theme_Defaultv6_SetTCPFolderIndent</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.Theme_Defaultv6_SetTCPFolderIndent(integer indent, boolean persist)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Sets the indentation of folders in tcp
    
    This reflects the settings from the Theme-Adjuster.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
  </retvals>
  <parameters>
    integer indent - the indentation-setting of tcp-folders
                    - 0, None
                    - 1, 1/8
                    - 2, 1/4
                    - 3, 1/2
                    - 4, 1
                    - 5, 2
                    - 6, MAX
    boolean persist - true, this setting persists after restart of Reaper; false, this setting is only valid until closing Reaper
  </parameters>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, set, folder, indent, tcp, default v6 theme</tags>
</US_DocBloc>
]]
  if math.type(indent)~="integer" then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTCPFolderIndent", "indent", "must be an integer", -1) return false end
  if indent<0 or indent>6 then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTCPFolderIndent", "indent", "must be between 0 and 6", -2) return false end
  local Layout="A"
  local elementname="indent"

  ultraschall.SetThemeParameterIndexByDescription(Layout.."_tcp_"..elementname, indent+1, persist, false)
  reaper.ThemeLayout_RefreshAll()
  return true
end

--A=ultraschall.Theme_Defaultv6_SetTCPFolderIndent(6, false)

function ultraschall.Theme_Defaultv6_GetTCPFolderIndent()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Theme_Defaultv6_GetTCPFolderIndent</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer indent = ultraschall.Theme_Defaultv6_GetTCPFolderIndent()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Gets the indentation of folders in the tcp
    
    This reflects the settings from the Theme-Adjuster.
    
    returns nil in case of an error
  </description>
  <retvals>
    integer indent - the indentation-setting of tcp-folders
                    - 0, None
                    - 1, 1/8
                    - 2, 1/4
                    - 3, 1/2
                    - 4, 1
                    - 5, 2
                    - 6, MAX
  </retvals>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, get, folder, indent, tcp, default v6 theme</tags>
</US_DocBloc>
]]
  local Layout="A"
  local elementname="indent"

  local A, B, C, size = ultraschall.GetThemeParameterIndexByDescription(Layout.."_tcp_"..elementname)
  return size-1
end

--A=ultraschall.Theme_Defaultv6_GetTCPFolderIndent()

function ultraschall.Theme_Defaultv6_SetTCPAlignControls(alignement, persist)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Theme_Defaultv6_SetTCPAlignControls</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.Theme_Defaultv6_SetTCPAlignControls(integer size, boolean persist)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Sets the alignment of controls in tcp
    
    This reflects the settings from the Theme-Adjuster.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
  </retvals>
  <parameters>
    integer alignement - the alignment-setting of tcp-controls
                    - 1, Folder Indent
                    - 2, Aligned
                    - 3, Extend Name
    boolean persist - true, this setting persists after restart of Reaper; false, this setting is only valid until closing Reaper
  </parameters>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, set, control, alignement, tcp, default v6 theme</tags>
</US_DocBloc>
]]
  if math.type(alignement)~="integer" then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTCPAlignControls", "alignement", "must be an integer", -1) return false end
  if alignement<1 or alignement>3 then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTCPAlignControls", "alignement", "must be between 1 and 3", -2) return false end
  local Layout="A"
  local elementname="control_align"

  ultraschall.SetThemeParameterIndexByDescription(Layout.."_tcp_"..elementname, alignement, persist, false)
  reaper.ThemeLayout_RefreshAll()
  return true
end

--A=ultraschall.Theme_Defaultv6_SetTCPAlignControls(1, false)

function ultraschall.Theme_Defaultv6_GetTCPAlignControls()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Theme_Defaultv6_GetTCPAlignControls</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer alignement = ultraschall.Theme_Defaultv6_GetTCPAlignControls()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Gets the alignment of controls in the tcp
    
    This reflects the settings from the Theme-Adjuster.
    
    returns nil in case of an error
  </description>
  <retvals>
    integer alignement - the alignment-setting of tcp-controls
                    - 1, Folder Indent
                    - 2, Aligned
                    - 3, Extend Name
  </retvals>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, get, control, alignement, tcp, default v6 theme</tags>
</US_DocBloc>
]]
  local Layout="A"
  local elementname="control_align"

  local A, B, C, alignement = ultraschall.GetThemeParameterIndexByDescription(Layout.."_tcp_"..elementname)
  return alignement
end

--A=ultraschall.Theme_Defaultv6_GetTCPAlignControls()

function ultraschall.Theme_Defaultv6_SetMCPAlignControls(alignement, persist)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Theme_Defaultv6_SetMCPAlignControls</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.Theme_Defaultv6_SetMCPAlignControls(integer size, boolean persist)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Sets the alignment of controls in mcp
    
    This reflects the settings from the Theme-Adjuster.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
  </retvals>
  <parameters>
    integer alignement - the alignment-setting of mcp-controls
                    - 1, Folder Indent
                    - 2, Aligned
    boolean persist - true, this setting persists after restart of Reaper; false, this setting is only valid until closing Reaper
  </parameters>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, set, control, alignement, mcp, default v6 theme</tags>
</US_DocBloc>
]]
  if math.type(alignement)~="integer" then ultraschall.AddErrorMessage("Theme_Defaultv6_SetMCPAlignControls", "alignement", "must be an integer", -1) return false end
  if alignement<1 or alignement>2 then ultraschall.AddErrorMessage("Theme_Defaultv6_SetMCPAlignControls", "alignement", "must be between 1 and 2", -2) return false end
  local Layout="A"
  local elementname="control_align"

  ultraschall.SetThemeParameterIndexByDescription(Layout.."_mcp_"..elementname, alignement, persist, false)
  reaper.ThemeLayout_RefreshAll()
  return true
end

--A=ultraschall.Theme_Defaultv6_SetMCPAlignControls(2, false)

function ultraschall.Theme_Defaultv6_GetMCPAlignControls()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Theme_Defaultv6_GetMCPAlignControls</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer alignement = ultraschall.Theme_Defaultv6_GetMCPAlignControls()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Gets the alignment of controls in the mcp
    
    This reflects the settings from the Theme-Adjuster.
    
    returns nil in case of an error
  </description>
  <retvals>
    integer alignement - the alignment-setting of mcp-controls
                    - 1, Folder Indent
                    - 2, Aligned
  </retvals>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, get, control, alignement, mcp, default v6 theme</tags>
</US_DocBloc>
]]
  local Layout="A"
  local elementname="control_align"

  local A, B, C, alignement = ultraschall.GetThemeParameterIndexByDescription(Layout.."_mcp_"..elementname)
  return alignement
end

--A=ultraschall.Theme_Defaultv6_GetMCPAlignControls()

function ultraschall.Theme_Defaultv6_SetTransSize(size)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Theme_Defaultv6_SetTransSize</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.Theme_Defaultv6_SetTransSize(integer size)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Sets the size of the transport-controls
    
    This reflects the settings from the Theme-Adjuster.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
  </retvals>
  <parameters>
    integer alignement - the alignment-setting of mcp-controls
                    - 1, normal
                    - 2, 150%
                    - 3, 200%
  </parameters>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, set, control, size, transport, default v6 theme</tags>
</US_DocBloc>
]]
  if math.type(size)~="integer" then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTransSize", "size", "must be an integer", -1) return false end
  if size<1 or size>3 then ultraschall.AddErrorMessage("Theme_Defaultv6_SetTransSize", "size", "must be between 1 and 3", -2) return false end
  if size==1 then size=""
  elseif size==2 then size="150%_"
  elseif size==3 then size="200%_"
  end
  local A=reaper.ThemeLayout_SetLayout("trans", size.."A")
  reaper.ThemeLayout_RefreshAll()
  return true
end

function ultraschall.Theme_Defaultv6_GetTransSize()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Theme_Defaultv6_GetTransSize</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.Theme_Defaultv6_GetTransSize()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Gets the size of the transport-controls
    
    This reflects the settings from the Theme-Adjuster.
    
    returns false in case of an error
  </description>
  <retvals>
    integer alignement - the alignment-setting of mcp-controls
                    - 1, normal
                    - 2, 150%
                    - 3, 200%
  </retvals>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, get, control, size, transport, default v6 theme</tags>
</US_DocBloc>
]]
  local A,B=reaper.ThemeLayout_GetLayout("trans", -1)
  if B=="A" then return 1
  elseif B=="150%_A" then return 2
  elseif B=="200%_A" then return 3
  end
end

--A=ultraschall.Theme_Defaultv6_SetTransSize(3)
--A=ultraschall.Theme_Defaultv6_GetTransSize()

ultraschall.ShowLastErrorMessage()
