--[[
################################################################################
# 
# Copyright (c) 2014-2019 Ultraschall (http://ultraschall.fm)
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
    Ultraschall=4.00
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
  <target_document>US_Api_Documentation</target_document>
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
    Ultraschall=4.00
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
  <target_document>US_Api_Documentation</target_document>
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
      Ultraschall=4.00
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
    <target_document>US_Api_Documentation</target_document>
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
    Ultraschall=4.00
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
  <target_document>US_Api_Documentation</target_document>
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

function ultraschall.Localize_UseFile(filename, section, language)
-- TODO: getting the currently installed language for the case, that language = set to nil
--       I think, filename as place for the language is better: XRaym_de.USLangPack, XRaym_us.USLangPack, XRaym_fr.USLangPack or something
--       
--       Maybe I should force to use the extension USLangPack...
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Localize_UseFile</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.975
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.Localize_UseFile(string filename, string section, string language)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Sets the localize-file and the section to use in the localize-file.
    If file cannot be found, the function will also look into resource-path/LangPack/ as well to find it.
    
    The file is of the format:
    ;comment
    ;another comment
    [section]
    original text=translated text
    More Text with\nNewlines and %s - substitution=Translated Text with\nNewlines and %s - substitution
    A third\=example with escaped equal\=in it = translated text with escaped\=equaltext
    
    see [specs for more information](../misc/ultraschall_translation_file_format.USLangPack).
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, translation-file has been found and set successfully; false, translation-file hasn't been found
  </retvals>
  <parameters>
    string filename - the filename with path to the translationfile; if no path is given, it will look in resource-folder/LangPack for the translation-file
    string section - the section of the translation-file, from which to read the translated strings
    string language - the language, which will be put after filename and before extension, like mylangpack_de.USLangPack; 
                    - us, usenglish
                    - es, spanish
                    - fr, french
                    - de, german
                    - jp, japanese
                    - etc
  </parameters>
  <chapter_context>
    Localization
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>localization, use, set, translationfile, section, filename</tags>
</US_DocBloc>
--]]
  if type(filename)~="string" then ultraschall.AddErrorMessage("Localize_UseFile", "filename", "must be a string", -1) return false end
  if type(section)~="string" then ultraschall.AddErrorMessage("Localize_UseFile", "section", "must be a string", -2) return false end
  local filenamestart, filenamsendof=ultraschall.GetPath(filename)
  local filenamext=filenamsendof:match(".*(%..*)")
  if language==nil then language="" end
  local filename2=filename
  if filenamext==nil or filenamsendof==nil then 
    filename=filename.."_"..language
  else
    filename=filenamestart..filenamsendof:sub(1, -filenamext:len()-1).."_"..language..filenamext
  end
  
  if reaper.file_exists(filename)==false then
    if reaper.file_exists(reaper.GetResourcePath().."/LangPack/"..filename)==false then
      ultraschall.AddErrorMessage("Localize_UseFile", "filename", "file does not exist", -3) return false
    else
      ultraschall.Localize_Filename=reaper.GetResourcePath().."/LangPack/"..filename2
      ultraschall.Localize_Section=section
      ultraschall.Localize_Language=language
    end
  else
    ultraschall.Localize_Filename=filename2
    ultraschall.Localize_Section=section
    ultraschall.Localize_Language=language
  end
  ultraschall.Localize_File=ultraschall.ReadFullFile(filename).."\n["
  ultraschall.Localize_File=ultraschall.Localize_File:match(section.."%]\n(.-)%[")
  ultraschall.Localize_File_Content={}
  for k in string.gmatch(ultraschall.Localize_File, "(.-)\n") do
    k=string.gsub(k, "\\n", "\n")
    k=string.gsub(k, "=", "\0")
    k=string.gsub(k, "\\\0", "=")
    local left, right=k:match("(.-)\0(.*)")
    --print2(left, "======", right)
    ultraschall.Localize_File_Content[left]=right
  end
  
  
--  ultraschall.Localize_File2=string.gsub(ultraschall.Localize_File, "\n;.-\n", "\n")
  
  while ultraschall.Localize_File~=ultraschall.Localize_File2 do
    ultraschall.Localize_File2=ultraschall.Localize_File
    ultraschall.Localize_File=string.gsub(ultraschall.Localize_File2, "\n;.-\n", "\n")
  end
  
  ultraschall.Localize_File=string.gsub(ultraschall.Localize_File, "\n\n", "\n")
  
  --print2("9"..ultraschall.Localize_File)
  --print3(ultraschall.Localize_File)
  
  return true
end

--O=ultraschall.Localize_UseFile(reaper.GetResourcePath().."/LangPack/ultraschall.USLangPack", "Export Assistant", "de")


--O={1,2,3}
--P=#O


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
    Ultraschall=4.00
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
  <target_document>US_Api_Documentation</target_document>
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
    Ultraschall=4.00
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
  <target_document>US_Api_Documentation</target_document>
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
    Ultraschall=4.00
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
  <target_document>US_Api_Documentation</target_document>
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
    Ultraschall=4.00
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
  <target_document>US_Api_Documentation</target_document>
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
    Ultraschall=4.00
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
  <target_document>US_Api_Documentation</target_document>
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

-- These seem to work:

function ultraschall.GetRender_EmbedStretchMarkers()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetRender_EmbedStretchMarkers</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    SWS=2.10.0.1
    JS=0.972
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.GetRender_EmbedStretchMarkers()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Gets the current state of the "Embed stretch markers/transient guides"-checkbox from the Render to File-dialog.
  </description>
  <retvals>
    boolean state - true, check the checkbox; false, uncheck the checkbox
  </retvals>
  <chapter_context>
    Configuration Settings
    Render to File
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>render, get, checkbox, render, embed stretch markers, transient guides</tags>
</US_DocBloc>
]]
  local SaveCopyOfProject, hwnd, retval, length, state
  hwnd = ultraschall.GetRenderToFileHWND()
  if hwnd==nil then
    state=reaper.SNM_GetIntConfigVar("projrenderstems", 0)&256
  else
    state = reaper.JS_WindowMessage_Send(reaper.JS_Window_FindChildByID(hwnd,1173), "BM_GETCHECK", 0,0,0,0)
  end
  if state==0 then state=false else state=true end
  return state
end

--A=ultraschall.GetRender_EmbedStretchMarkers()

function ultraschall.SetRender_EmbedStretchMarkers(state)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetRender_EmbedStretchMarkers</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    SWS=2.10.0.1
    JS=0.972
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetRender_EmbedStretchMarkers(boolean state)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Sets the new state of the "Embed stretch markers/transient guides"-checkbox from the Render to File-dialog.
    
    Returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, it was unsuccessful
  </retvals>
  <parameters>
    boolean state - true, check the checkbox; false, uncheck the checkbox
  </parameters>
  <chapter_context>
    Configuration Settings
    Render to File
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>render, set, checkbox, render, embed stretch markers, transient guides</tags>
</US_DocBloc>
]]
  if type(state)~="boolean" then ultraschall.AddErrorMessage("SetRender_EmbedStretchMarkers", "state", "must be a boolean", -1) return false end
  local SaveCopyOfProject, hwnd, retval, Oldstate, Oldstate2, state2
  if state==false then state=0 else state=1 end
  hwnd = ultraschall.GetRenderToFileHWND()
  Oldstate=reaper.SNM_GetIntConfigVar("projrenderstems", -99)
  Oldstate2=Oldstate&256  
  if Oldstate2==256 and state==0 then state2=Oldstate-256
  elseif Oldstate2==0 and state==1 then state2=Oldstate+256
  else state2=Oldstate
  end
  
  
  if hwnd==nil then
    reaper.SNM_SetIntConfigVar("projrenderstems", state2)
  else
    reaper.JS_WindowMessage_Send(reaper.JS_Window_FindChildByID(hwnd, 1173), "BM_SETCHECK", state,0,0,0)
    reaper.SNM_SetIntConfigVar("projrenderstems", state2)
  end
  return true
end

--A=ultraschall.SetRender_EmbedStretchMarkers(false)

function ultraschall.SetProject_MasterTrackView(projectfilename_with_path, tcp_visibility, state2, state3, state4, state5, state6, state7, ProjectStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetProject_MasterTrackView</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer retval, optional string ProjectStateChunk = ultraschall.SetProject_MasterTrackView(string projectfilename_with_path, integer tcp_visibility, number state2, number state3, number state4, integer state5, integer state6, integer state7, optional string ProjectStatechunk)</functioncall>
  <description>
    Sets the master-view-state of the master-track of the project or a ProjectStateChunk.
    
    It is the entry: MASTERTRACKVIEW
    
    Returns -1 in case of error.
  </description>
  <parameters>
    string projectfilename_with_path - the filename of the projectfile; nil, to use Parameter ProjectStateChunk instead
    integer tcp_visibility - 0, Master-track is invisible in MCP; 1, Master-track is visible in MCP
    number state2 - unknown
    number state3 - unknown
    number state4 - unknown
    integer state5 - unknown
    integer state6 - unknown
    integer state7 - unknown
    integer state8 - unknown
    integer state9 - unknown
    integer state10 - unknown
    optional string ProjectStateChunk - a projectstatechunk, that you want to be changed
  </parameters>
  <retvals>
    integer retval - -1 in case of error, 1 in case of success
    optional string ProjectStateChunk - the altered ProjectStateChunk
  </retvals>
  <chapter_context>
    Project-Management
    RPP-Files Set
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>projectfiles, rpp, state, set, ripple, all, one</tags>
</US_DocBloc>
]]
  if projectfilename_with_path==nil and ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("SetProject_RippleState", "ProjectStateChunk", "Must be a valid ProjectStateChunk", -1) return -1 end
  if projectfilename_with_path~=nil and reaper.file_exists(projectfilename_with_path)==false then ultraschall.AddErrorMessage("SetProject_RippleState", "projectfilename_with_path", "File does not exist", -2) return -1 end
  if projectfilename_with_path~=nil then ProjectStateChunk=ultraschall.ReadFullFile(projectfilename_with_path) end
  if projectfilename_with_path~=nil and ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("SetProject_RippleState", "projectfilename_with_path", "File is no valid RPP-Projectfile", -3) return -1 end
  
  if ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("SetProject_RippleState", "projectfilename_with_path", "No valid RPP-Projectfile!", -5) return -1 end
--tcp_visibility, state2, state3, state4, state5, state6, state7
  if math.type(tcp_visibility)~="integer" then ultraschall.AddErrorMessage("SetProject_RippleState", "tcp_visibility", "Must be an integer", -4) return -1 end
  
  
  local FileStart=ProjectStateChunk:match("(<REAPER_PROJECT.-RIPPLE%s).-%c.-<RECORD_CFG.*")
  local FileEnd=ProjectStateChunk:match("<REAPER_PROJECT.-RIPPLE%s.-%c(.-<RECORD_CFG.*)")
  
  ProjectStateChunk=FileStart..ripple_state.."\n"..FileEnd
  if projectfilename_with_path~=nil then return ultraschall.WriteValueToFile(projectfilename_with_path, ProjectStateChunk), ProjectStateChunk
  else return 1, ProjectStateChunk
  end
end

function ultraschall.GetItem_ClickState()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItem_ClickState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.981
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>boolean clickstate, number position, MediaItem item, MediaItem_Take take = ultraschall.GetItem_ClickState()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the currently clicked item and take, as well as the current timeposition.
    
    Mostly useful in defer-scripts.
    
    Returns false, if no item is clicked at
  </description>
  <retvals>
    boolean clickstate - true, item is clicked on; false, item isn't clicked on
    number position - the position, at which the item is currently clicked at
    MediaItem item - the Item, which is currently clicked at
    MediaItem_Take take - the take found at clickposition
  </retvals>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitem management, get, clicked, item</tags>
</US_DocBloc>
--]]
  local B=reaper.SNM_GetDoubleConfigVar("uiscale", -999)
  local X,Y=reaper.GetMousePosition()
  local Item, ItemTake = reaper.GetItemFromPoint(X,Y, true)
  if Item==nil then Item=ultraschall.ItemClickState_OldItem end
  if Item~=nil then ultraschall.ItemClickState_OldItem=Item end
  if ItemTake==nil then ItemTake=ultraschall.ItemClickState_OldTake end
  if ItemTake~=nil then ultraschall.ItemClickState_OldTake=ItemTake end
  if tostring(B)=="-1.#QNAN" or Item==nil then
    ultraschall.ItemClickState_OldTake=nil
    ultraschall.ItemClickState_OldItem=nil
    return false
  end
  return true, ultraschall.GetTimeByMouseXPosition(reaper.GetMousePosition()), Item, ItemTake
end

function ultraschall.GetProjectLength(items, markers_regions, timesig_markers)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetProjectLength</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>number project_length, number last_itemedge, number last_regionedgepos, number last_markerpos, number last_timesigmarker = ultraschall.GetProjectLength(optional boolean return_last_itemedge, optional boolean return_last_markerpos, optional boolean return_lat_timesigmarkerpos)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the position of the last itemedge, regionend, marker, time-signature-marker in the project.
    
    It will return -1, if no such elements are found, means: last\_markerpos=-1 if no marker has been found
    Exception when no items are found, it will return nil for last\_itemedge
    
    You can optimise the speed of the function, by setting the appropriate parameters to false.
    So if you don't need the last itemedge, setting return\_last\_itemedge=false speeds up execution massively.
    
    To do the same for projectfiles, use: [GetProject\_Length](#GetProject_Length)
  </description>
  <retvals>
    number length_of_project - the overall length of the project, including markers, regions, itemedges and time-signature-markers
    number last_itemedge - the position of the last itemedge in the project; nil, if not found
    number last_regionedgepos - the position of the last regionend in the project; -1, if not found
    number last_markerpos - the position of the last marker in the project; -1, if not found 
    number last_timesigmarker - the position of the last timesignature-marker in the project; -1, if not found
  </retvals>
  <parameters>
    optional boolean return_last_itemedge - true or nil, return the last itemedge; false, don't return it
    optional boolean return_last_markerpos - true or nil, return the last marker/regionend-position; false, don't return it 
    optional boolean return_lat_timesigmarkerpos - true or nil, return the last timesignature-marker-position; false, don't return it
  </parameters>
  <chapter_context>
    Project-Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>project management, get, last, position, length of project, marker, regionend, itemend, timesignaturemarker</tags>
</US_DocBloc>
--]]
  local Longest=-10000000000 -- this is a hack for MediaItems, who are stuck before ProjectStart; I hate it
  if items~=false then
    local Position, Length
    for i=0, reaper.CountMediaItems(0)-1 do
      Position=reaper.GetMediaItemInfo_Value(reaper.GetMediaItem(0,i), "D_POSITION")
      Length=reaper.GetMediaItemInfo_Value(reaper.GetMediaItem(0,i), "D_LENGTH")
      if Position+Length>Longest then Longest=Position+Length end
    end
  end
  if Longest==-10000000000 then Longest=nil end -- same hack for MediaItems, who are stuck before ProjectStart; I hate it...
  local Regionend=-1
  local Markerend=-1
  if markers_regions~=false then
    for i=0, reaper.CountProjectMarkers(0)-1 do
      local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
      if isrgn==true then
        if rgnend>Regionend then Regionend=rgnend end
      else
        if pos>Markerend then Markerend=pos end
      end
    end
  end
  local TimeSigEnd=-1
  if timesig_markers~=false then
    for i=0, reaper.CountTempoTimeSigMarkers(0)-1 do
      local retval, timepos, measurepos, beatpos, bpm, timesig_num, timesig_denom, lineartempo = reaper.GetTempoTimeSigMarker(0, i)
      if timepos>TimeSigEnd then TimeSigEnd=timepos end
    end
  end
  return reaper.GetProjectLength(), Longest, Regionend, Markerend, TimeSigEnd
end

function ultraschall.GetEndOfItem(MediaItem)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetEndOfItem</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>number end_of_item_position = ultraschall.GetEndOfItem(MediaItem MediaItem)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the endposition of MediaItem
    
    returns nil in case of an error
  </description>
  <retvals>
    number end_of_item_position - the position of the ending edge of the MediaItem
  </retvals>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose ending-position you want to know
  </parameters>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitem management, get, end of mediaitem, position</tags>
</US_DocBloc>
--]]
  if ultraschall.type(MediaItem)~="MediaItem" then ultraschall.AddErrorMessage("GetEndOfItem", "MediaItem", "must be a valid MediaItem", -1) return end
  return reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")-reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")
end

function ultraschall.GetAllMediaItemAttributes_Table(MediaItem)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllMediaItemAttributes_Table</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>table AttributeTable = ultraschall.GetAllMediaItemAttributes_Table(MediaItem MediaItem)</functioncall>
  <description>
    Returns all attributes of MediaItem as a handy table.
    
    The returned table is of the following scheme:
        AttributeTable["B_MUTE"] - bool * : muted
        AttributeTable["B_LOOPSRC"] - bool * : loop source
        AttributeTable["B_ALLTAKESPLAY"] - bool * : all takes play
        AttributeTable["B_UISEL"] - bool * : selected in arrange view
        AttributeTable["C_BEATATTACHMODE"] - char * : item timebase, -1=track or project default, 1=beats (position, length, rate), 2=beats (position only). for auto-stretch timebase: C_BEATATTACHMODE=1, C_AUTOSTRETCH=1
        AttributeTable["C_AUTOSTRETCH:"] - char * : auto-stretch at project tempo changes, 1=enabled, requires C_BEATATTACHMODE=1
        AttributeTable["C_LOCK"] - char * : locked, &1=locked
        AttributeTable["D_VOL"] - double * : item volume, 0=-inf, 0.5=-6dB, 1=+0dB, 2=+6dB, etc
        AttributeTable["D_POSITION"] - double * : item position in seconds
        AttributeTable["D_LENGTH"] - double * : item length in seconds
        AttributeTable["D_SNAPOFFSET"] - double * : item snap offset in seconds
        AttributeTable["D_FADEINLEN"] - double * : item manual fadein length in seconds
        AttributeTable["D_FADEOUTLEN"] - double * : item manual fadeout length in seconds
        AttributeTable["D_FADEINDIR"] - double * : item fadein curvature, -1..1
        AttributeTable["D_FADEOUTDIR"] - double * : item fadeout curvature, -1..1
        AttributeTable["D_FADEINLEN_AUTO"] - double * : item auto-fadein length in seconds, -1=no auto-fadein
        AttributeTable["D_FADEOUTLEN_AUTO"] - double * : item auto-fadeout length in seconds, -1=no auto-fadeout
        AttributeTable["C_FADEINSHAPE"] - int * : fadein shape, 0..6, 0=linear
        AttributeTable["C_FADEOUTSHAPE"] - int * : fadeout shape, 0..6, 0=linear
        AttributeTable["I_GROUPID"] - int * : group ID, 0=no group
        AttributeTable["I_LASTY"] - int * : Y-position of track in pixels (read-only)
        AttributeTable["I_LASTH"] - int * : height in track in pixels (read-only)
        AttributeTable["I_CUSTOMCOLOR"] - int * : custom color, OS dependent color|0x100000 (i.e. ColorToNative(r,g,b)|0x100000). If you do not |0x100000, then it will not be used, but will store the color anyway)
        AttributeTable["I_CURTAKE"] - int * : active take number
        AttributeTable["IP_ITEMNUMBER"] - int, item number on this track (read-only, returns the item number directly)
        AttributeTable["F_FREEMODE_Y"] - float * : free item positioning Y-position, 0=top of track, 1=bottom of track (will never be 1)
        AttributeTable["F_FREEMODE_H"] - float * : free item positioning height, 0=no height, 1=full height of track (will never be 0)
        AttributeTable["P_TRACK"] - MediaTrack * (read-only)
    
    returns nil in case of an error
  </description>
  <retvals>
    table AttributeTable - a table with all attributes of a MediaItem
  </retvals>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose attributes you want to retrieve
  </parameters>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitem management, get, all, attributes of mediaitem</tags>
</US_DocBloc>
--]]
  if ultraschall.type(MediaItem)~="MediaItem" then ultraschall.AddErrorMessage("GetAllMediaItemAttributes_Table", "MediaItem", "must be a valid MediaItem", -1) return end
  local Attributes={}
  Attributes["B_MUTE"]=reaper.GetMediaItemInfo_Value(MediaItem, "B_MUTE")
  Attributes["B_LOOPSRC"]=reaper.GetMediaItemInfo_Value(MediaItem, "B_LOOPSRC")
  Attributes["B_ALLTAKESPLAY"]=reaper.GetMediaItemInfo_Value(MediaItem, "B_ALLTAKESPLAY")
  Attributes["B_UISEL"]=reaper.GetMediaItemInfo_Value(MediaItem, "B_UISEL")
  Attributes["C_BEATATTACHMODE"]=reaper.GetMediaItemInfo_Value(MediaItem, "C_BEATATTACHMODE")
  Attributes["C_AUTOSTRETCH"]=reaper.GetMediaItemInfo_Value(MediaItem, "C_AUTOSTRETCH")
  Attributes["C_LOCK"]=reaper.GetMediaItemInfo_Value(MediaItem, "C_LOCK")
  Attributes["D_VOL"]=reaper.GetMediaItemInfo_Value(MediaItem, "D_VOL")
  Attributes["D_POSITION"]=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
  Attributes["D_LENGTH"]=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")
  Attributes["D_SNAPOFFSET"]=reaper.GetMediaItemInfo_Value(MediaItem, "D_SNAPOFFSET")
  Attributes["D_FADEINLEN"]=reaper.GetMediaItemInfo_Value(MediaItem, "D_FADEINLEN")
  Attributes["D_FADEOUTLEN"]=reaper.GetMediaItemInfo_Value(MediaItem, "D_FADEOUTLEN")
  Attributes["D_FADEINDIR"]=reaper.GetMediaItemInfo_Value(MediaItem, "D_FADEINDIR")
  Attributes["D_FADEOUTDIR"]=reaper.GetMediaItemInfo_Value(MediaItem, "D_FADEOUTDIR")
  Attributes["D_FADEINLEN_AUTO"]=reaper.GetMediaItemInfo_Value(MediaItem, "D_FADEINLEN_AUTO")
  Attributes["D_FADEOUTLEN_AUTO"]=reaper.GetMediaItemInfo_Value(MediaItem, "D_FADEOUTLEN_AUTO")
  Attributes["C_FADEINSHAPE"]=reaper.GetMediaItemInfo_Value(MediaItem, "C_FADEINSHAPE")
  Attributes["C_FADEOUTSHAPE"]=reaper.GetMediaItemInfo_Value(MediaItem, "C_FADEOUTSHAPE")
  Attributes["I_GROUPID"]=reaper.GetMediaItemInfo_Value(MediaItem, "I_GROUPID")
  Attributes["I_LASTY"]=reaper.GetMediaItemInfo_Value(MediaItem, "I_LASTY")
  Attributes["I_LASTH"]=reaper.GetMediaItemInfo_Value(MediaItem, "I_LASTH")
  Attributes["I_CUSTOMCOLOR"]=reaper.GetMediaItemInfo_Value(MediaItem, "I_CUSTOMCOLOR")
  Attributes["I_CURTAKE"]=reaper.GetMediaItemInfo_Value(MediaItem, "I_CURTAKE")
  Attributes["IP_ITEMNUMBER"]=reaper.GetMediaItemInfo_Value(MediaItem, "IP_ITEMNUMBER")
  Attributes["F_FREEMODE_Y"]=reaper.GetMediaItemInfo_Value(MediaItem, "F_FREEMODE_Y")
  Attributes["F_FREEMODE_H"]=reaper.GetMediaItemInfo_Value(MediaItem, "F_FREEMODE_H")
  Attributes["P_TRACK"]=reaper.GetMediaItemInfo_Value(MediaItem, "P_TRACK")
  return Attributes
end

function ultraschall.SetAllMediaItemAttributes_Table(MediaItem, AttributeTable)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetAllMediaItemAttributes_Table</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetAllMediaItemAttributes_Table(MediaItem MediaItem, table AttributeTable)</functioncall>
  <description>
    Sets all attributes of MediaItem using a AttributeTable, which holds all the new settings for the MediaItem.
    
    The expected table is of the following scheme:
        AttributeTable["B_MUTE"] - bool * : muted
        AttributeTable["B_LOOPSRC"] - bool * : loop source
        AttributeTable["B_ALLTAKESPLAY"] - bool * : all takes play
        AttributeTable["B_UISEL"] - bool * : selected in arrange view
        AttributeTable["C_BEATATTACHMODE"] - char * : item timebase, -1=track or project default, 1=beats (position, length, rate), 2=beats (position only). for auto-stretch timebase: C_BEATATTACHMODE=1, C_AUTOSTRETCH=1
        AttributeTable["C_AUTOSTRETCH:"] - char * : auto-stretch at project tempo changes, 1=enabled, requires C_BEATATTACHMODE=1
        AttributeTable["C_LOCK"] - char * : locked, &1=locked
        AttributeTable["D_VOL"] - double * : item volume, 0=-inf, 0.5=-6dB, 1=+0dB, 2=+6dB, etc
        AttributeTable["D_POSITION"] - double * : item position in seconds
        AttributeTable["D_LENGTH"] - double * : item length in seconds
        AttributeTable["D_SNAPOFFSET"] - double * : item snap offset in seconds
        AttributeTable["D_FADEINLEN"] - double * : item manual fadein length in seconds
        AttributeTable["D_FADEOUTLEN"] - double * : item manual fadeout length in seconds
        AttributeTable["D_FADEINDIR"] - double * : item fadein curvature, -1..1
        AttributeTable["D_FADEOUTDIR"] - double * : item fadeout curvature, -1..1
        AttributeTable["D_FADEINLEN_AUTO"] - double * : item auto-fadein length in seconds, -1=no auto-fadein
        AttributeTable["D_FADEOUTLEN_AUTO"] - double * : item auto-fadeout length in seconds, -1=no auto-fadeout
        AttributeTable["C_FADEINSHAPE"] - int * : fadein shape, 0..6, 0=linear
        AttributeTable["C_FADEOUTSHAPE"] - int * : fadeout shape, 0..6, 0=linear
        AttributeTable["I_GROUPID"] - int * : group ID, 0=no group
        AttributeTable["I_LASTY"] - int * : Y-position of track in pixels (read-only)
        AttributeTable["I_LASTH"] - int * : height in track in pixels (read-only)
        AttributeTable["I_CUSTOMCOLOR"] - int * : custom color, OS dependent color|0x100000 (i.e. ColorToNative(r,g,b)|0x100000). If you do not |0x100000, then it will not be used, but will store the color anyway)
        AttributeTable["I_CURTAKE"] - int * : active take number
        AttributeTable["IP_ITEMNUMBER"] - int, item number on this track (read-only, returns the item number directly)
        AttributeTable["F_FREEMODE_Y"] - float * : free item positioning Y-position, 0=top of track, 1=bottom of track (will never be 1)
        AttributeTable["F_FREEMODE_H"] - float * : free item positioning height, 0=no height, 1=full height of track (will never be 0)
        AttributeTable["P_TRACK"] - MediaTrack * (read-only)
    
    returns false in case of an error or if some of the attributes could not be set.
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting attributes failed
  </retvals>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose attributes you want to set
    table AttributeTable - a table which holds all settings, that you want to set
  </parameters>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitem management, set, all, attributes of mediaitem</tags>
</US_DocBloc>
--]]
  if ultraschall.type(MediaItem)~="MediaItem" then ultraschall.AddErrorMessage("SetAllMediaItemAttributes_Table", "MediaItem", "must be a MediaItem", -1) return false end
  if type(AttributeTable)~="table" then ultraschall.AddErrorMessage("SetAllMediaItemAttributes_Table", "AttributeTable", "must be a table", -2) return false end
  local FailedAttributes=""
  for i,v in pairs(AttributeTable) do
    if i~="P_TRACK" and type(v)=="number" then
      if (reaper.SetMediaItemInfo_Value(MediaItem, i, v))==false then
        FailedAttributes=FailedAttributes..i.."\n"
      end
    elseif i~="P_TRACK" then
        FailedAttributes=FailedAttributes..i.."\n"
    end
  end
  if FailedAttributes~="" then ultraschall.AddErrorMessage("SetAllMediaItemAttributes_Table", "AttributeTable", "Could not set the following attributes: \n"..FailedAttributes:sub(1,-2), -3) return false end
  reaper.UpdateArrange()
  return true
end

function ultraschall.CountFXStateChunksInStateChunk(StateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CountFXStateChunksInStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer count_of_takefx_statechunks, integer count_of_trackfx_statechunks = ultraschall.CountFXStateChunksInStateChunk(string StateChunk)</functioncall>
  <description>
    Counts all FXStateChunks within a StateChunk.
    You can pass ItemStateChunks, TrackStateChunks and ProjectStateChunks.
    
    returns -1 in case of an error.
  </description>
  <retvals>
    integer count_of_takefx_statechunks - the number of take-fx-StateChunks within the StateChunk. When passing Track/ProjectStateChunks, it returns number of all FXStateChunks from all Takes within the StateChunk
    integer count_of_trackfx_statechunks - the number of TrackFX-StateChunks; each track alawys has a single one, so it should match the number of tracks within the StateChunk; 0, if you pass a ItemStateChunk
  </retvals>
  <parameters>
    string StateChunk - the StateChunk, whose count of FXStateChunks you want to retrieve
  </parameters>
  <chapter_context>
    FX-Management
    FXStateChunks
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>fxmanagement, count, all, fxstatechunk</tags>
</US_DocBloc>
--]]
  if ultraschall.IsValidMediaItemStateChunk(StateChunk)==false and
     ultraschall.IsValidTrackStateChunk(StateChunk)==false and
     ultraschall.IsValidProjectStateChunk(StateChunk)==false then
     ultraschall.AddErrorMessage("CountFXStateChunksInStateChunk", "StateChunk", "Must be a valid Project/Track/ItemStateChunk", -1) return -1
  end
  local TrackFX=0
  local TakeFX=0
  for k in string.gmatch(StateChunk, "(.-)\n") do
    if k:match("%s*<FXCHAIN")~=nil then
      TrackFX=TrackFX+1
    elseif k:match("%s*<TAKEFX")~=nil then
      TakeFX=TakeFX+1
    end
  end
  return TakeFX, TrackFX
end 

function ultraschall.RemoveFXStateChunkFromTrackStateChunk(TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>RemoveFXStateChunkFromTrackStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>string altered_TrackStateChunk = ultraschall.RemoveFXStateChunkFromTrackStateChunk(string TrackStateChunk)</functioncall>
  <description>
    Clears the FXChain from a TrackStateChunk
    
    returns nil in case of an error.
  </description>
  <retvals>
    string altered_TrackStateChunk - the TrackStateChunk, cleared of the Track-FXStateChunk
  </retvals>
  <parameters>
    string TrackStateChunk - the TrackStateChunk, whose FXStateChunk you want to remove
  </parameters>
  <chapter_context>
    FX-Management
    FXStateChunks
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>fxmanagement, remove, all, fxstatechunk, trackstatechunk</tags>
</US_DocBloc>
--]]
  if ultraschall.IsValidTrackStateChunk(TrackStateChunk)==false then ultraschall.AddErrorMessage("RemoveFXStateChunkFromTrackStateChunk", "TrackStateChunk", "Must be a valid TrackStateChunk", -1) return end
  TrackStateChunk=ultraschall.StateChunkLayouter(TrackStateChunk)
  return string.gsub(TrackStateChunk, "(  <FXCHAIN.-\n  >\n", "")
end

ultraschall.ShowLastErrorMessage()
