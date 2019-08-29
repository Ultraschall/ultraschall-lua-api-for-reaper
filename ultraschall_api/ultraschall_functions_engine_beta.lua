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




--Event Manager
function ultraschall.ResetEvent(Event_Section)
  if Event_Section==nil and Ultraschall_Event_Section~=nil then 
    Event_Section=Ultraschall_Event_Section 
  end
  if type(Event_Section)~="string" then ultraschall.AddErrorMessage("ResetEvent", "Event_Section", "must be a string", -1) return false end
  local A=reaper.GetExtState(Event_Section, "NumEvents")
  if A~="" then 
    for i=1, A do
      reaper.DeleteExtState(Event_Section, "Event"..i, false)
    end
  end
  reaper.DeleteExtState(Event_Section, "NumEvents", false)
  reaper.DeleteExtState(Event_Section, "Old", false)
  reaper.DeleteExtState(Event_Section, "New", false)
  reaper.DeleteExtState(Event_Section, "ScriptIdentifier", false)
end


function ultraschall.RegisterEvent(Event_Section, Event)
  if type(Event_Section)~="string" then ultraschall.AddErrorMessage("RegisterEvent", "Event_Section", "must be a string", -1) return false end
  if type(Event)~="string" then ultraschall.AddErrorMessage("RegisterEvent", "Event", "must be a string", -2) return false end
  local A=reaper.GetExtState(Event_Section, "NumEvents")
  if A=="" then A=0 else A=tonumber(A) end
  reaper.SetExtState(Event_Section, "ScriptIdentifier", ultraschall.ScriptIdentifier, false)
  reaper.SetExtState(Event_Section, "NumEvents", A+1, false)
  reaper.SetExtState(Event_Section, "Event"..A+1, Event, false)
end

function ultraschall.SetEventState(Event_Section, OldEvent, NewEvent)
  if type(Event_Section)~="string" then ultraschall.AddErrorMessage("RegisterEvent", "Event_Section", "must be a string", -1) return false end
  OldEvent=tostring(OldEvent)
  NewEvent=tostring(NewEvent)
  reaper.SetExtState(Event_Section, "Old", OldEvent, false)
  reaper.SetExtState(Event_Section, "New", NewEvent, false)
  reaper.SetExtState(Event_Section, "ScriptIdentifier", ultraschall.ScriptIdentifier, false)
end

function ultraschall.RegisterEventAction(eventconditions, action)
  -- eventconditions is an array of the following structure
  -- eventconditions[idx][1] - oldstate
  -- eventconditions[idx][2] - newstate
  -- eventconditions[idx][3] - comparison 
  --                                fixed events: ! for not and = for equal
  --                                unfixed events(numbers): < = >
  -- if all these conditions are met, the eventmanager will run the action, otherwise it does nothing
end

function ultraschall.GetAllAvailableEvents()
  return ultraschall.SplitStringAtLineFeedToArray(reaper.GetExtState("ultraschall_event_manager", "allevents"))
end

--A,B=ultraschall.GetAllAvailableEvents()

function ultraschall.GetAllEventStates()
  local count, array = ultraschall.SplitStringAtLineFeedToArray(reaper.GetExtState("ultraschall_event_manager", "eventstates"))
  if array[1]~="" then
    return reaper.GetExtState("ultraschall_event_manager", "event"), count, array
  else
    return "", 0, {}
  end
end

--A,B,C=ultraschall.GetAllEventStates()

function ultraschall.SetAlterableEvent(Event)
  if type(Event)~="string" then ultraschall.AddErrorMessage("SetAlterableEvent", "Event", "must be a string", -1) return end
  reaper.SetExtState("ultraschall_event_manager", "event", Event, false)
end

--ultraschall.SetAlterableEvent("LoopState")

function ultraschall.SetEvent(command)
  if type(command)~="string" then ultraschall.AddErrorMessage("SetEvent", "command", "must be a string", -1) return end
  reaper.SetExtState("ultraschall_event_manager", "do_command", command, false)
end

--ultraschall.SetEvent("start")

function ultraschall.UpdateEventList()
  reaper.SetExtState("ultraschall_event_manager", "do_command", "update", false)
end

--ultraschall.UpdateEventList()

function ultraschall.GetCurrentEventTransition()
  local event=reaper.GetExtState("ultraschall_event_manager", "event")
  return event, reaper.GetExtState(event, "Old"), reaper.GetExtState(event, "New")
end

--A,B,C=ultraschall.GetCurrentEventTransition()


function ultraschall.StartAllEventListeners()
  reaper.SetExtState("ultraschall_event_manager", "do_command", "startall", false)
end

--A,B,C=ultraschall.StartAllEventListeners()

function ultraschall.StopAllEventListeners()
  reaper.SetExtState("ultraschall_event_manager", "do_command", "stopall", false)
end

--A,B,C=ultraschall.StopAllEventListeners()

function ultraschall.StopEventManager()
  reaper.SetExtState("ultraschall_event_manager", "do_command", "stop_eventlistener", false)
end

function ultraschall.StartEventManager()
  ultraschall.Main_OnCommandByFilename(ultraschall.Api_Path.."/Scripts/ultraschall_EventManager.lua")
end

--ultraschall.StartEventManager()
--A,B,C=ultraschall.StartAllEventListeners()



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


-----------------------
---- Render Export ----
-----------------------


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

function ultraschall.GetAllActions(section)
-- ToDo:
-- pattern matching through the actions, so you can filter them
-- return the consolidate-state of actions 
-- and the consolidate/terminate running-script-state of scripts as well
-- Bonus: maybe returning shortcuts as well, but maybe, this fits better in it's own function
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllActions</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.977
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>integer number_of_actions, table actiontable = ultraschall.GetAllActions(integer section)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns all actions from a specific section as a handy table
    
    The table is of the following format:

            actiontable[index]["commandid"]       - the command-id-number of the action
            actiontable[index]["actioncommandid"] - the action-command-id-string of the action, if it's a named command(usually scripts or extensions), otherwise empty string
            actiontable[index]["name"]            - the name of command
            actiontable[index]["scriptfilename"]  - the filename+path of a command, that is a ReaScript, otherwise empty string
     
    returns -1 in case of an error.
  </description>
  <retvals>
    integer number_of_actions - the number of actions found; -1 in case of an error
    table actiontable - a table, which holds all attributes of an action
  </retvals>
  <parameters>
    integer sections - the section, whose actions you want to retrieve
                     - 0, Main=0
                     - 100, Main (alt recording)
                     - 32060, MIDI Editor=32060
                     - 32061, MIDI Event List Editor
                     - 32062, MIDI Inline Editor
                     - 32063, Media Explorer=32063
  </parameters>
  <chapter_context>
    User Interface
    Dialogs
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>userinterface, dialog, get, user input</tags>
</US_DocBloc>
--]]
  if section~=0 and section~=100 and section~=32060 and section~=32061 and section~=32062 and section~=32063 then
    ultraschall.AddErrorMessage("GetAllActions", "section", "no valid section, must be a number for one of the following sections: Main=0, Main (alt recording)=100, MIDI Editor=32060, MIDI Event List Editor=32061, MIDI Inline Editor=32062, Media Explorer=32063", -1) 
    return -1 
  end

  local A=ultraschall.ReadFullFile(reaper.GetResourcePath().."/reaper-kb.ini").."\n"
  local B=""
  for k in string.gmatch(A, "SCR.-\n") do
    B=B..k
  end
  
  local Table={}
  local counter=1
  for i=0, 65555 do
    counter=counter+1
    local retval, name = reaper.CF_EnumerateActions(section, i, "")
    if retval==0 then break end
    Table[counter]={}
    Table[counter]["commandid"]=retval
    Table[counter]["name"]=name
    Table[counter]["actioncommandid"]=reaper.ReverseNamedCommandLookup(retval)
    if Table[counter]["actioncommandid"]~=nil then
      Table[counter]["scriptfilename"]=B:match(""..Table[counter]["actioncommandid"]..".*%s(.-)\n")
      if Table[counter]["scriptfilename"]~=nil and reaper.file_exists(Table[counter]["scriptfilename"])==false then 
        Table[counter]["scriptfilename"]=reaper.GetResourcePath()..ultraschall.Separator.."Scripts"..ultraschall.Separator..Table[counter]["scriptfilename"]
      end
    --  if Table[counter]["scriptfilename"]~=nil then print3(Table[counter]["scriptfilename"]) end
    --else
    --  counter=counter-1
    end
    if Table[counter]["actioncommandid"]==nil then Table[counter]["actioncommandid"]="" end
    if Table[counter]["scriptfilename"]==nil then Table[counter]["scriptfilename"]="" end
  end
  return counter-1, Table
end

--A,B=ultraschall.GetAllActions(0)

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
  -- can't calculate the dependency between zoom and trackheigt... :/
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

function ultraschall.GetFXStateChunk(StateChunk, TakeFXChain_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetFXStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.975
    Lua=5.3
  </requires>
  <functioncall>string FXStateChunk = ultraschall.GetFXStateChunk(string StateChunk, optional integer TakeFXChain_id)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns an FXStateChunk from a TrackStateChunk or a MediaItemStateChunk.
    
    An FXStateChunk holds all FX-plugin-settings for a specific MediaTrack or MediaItem.
    
    Returns nil in case of an error or if no FXStateChunk has been found.
  </description>
  <retvals>
    string FXStateChunk - the FXStateChunk, stored in the StateChunk
  </retvals>
  <parameters>
    string StateChunk - the StateChunk, from which you want to retrieve the FXStateChunk
    optional integer TakeFXChain_id - when using MediaItemStateChunks, this allows you to choose the take of which you want the FXChain; default is 1
  </parameters>
  <chapter_context>
    FX-Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>fxmanagement, get, fxstatechunk, trackstatechunk, mediaitemstatechunk</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidTrackStateChunk(StateChunk)==false and ultraschall.IsValidMediaItemStateChunk(StateChunk)==false then ultraschall.AddErrorMessage("GetFXStateChunk", "StateChunk", "no valid Track/ItemStateChunk", -1) return end
  if TakeFXChain_id~=nil and math.type(TakeFXChain_id)~="integer" then ultraschall.AddErrorMessage("GetFXStateChunk", "TakeFXChain_id", "must be an integer", -2) return end
  if TakeFXChain_id==nil then TakeFXChain=1 end
  
  if string.find(StateChunk, "\n  ")==nil then
    StateChunk=ultraschall.StateChunkLayouter(StateChunk)
  end
  for w in string.gmatch(StateChunk, " <FXCHAIN.-\n  >") do
    return string.gsub("\n"..w, "\n      ", "\n    "):sub(2,-1)
    --return w
  end
  local count=0
  for w in string.gmatch(StateChunk, " <TAKEFX.-\n  >") do
    count=count+1
    if TakeFXChain_id==count then
      return string.gsub("\n"..w, "\n      ", "\n    "):sub(2,-1)
    end
  end
end


function ultraschall.GetRecCounter()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetRecCounter</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.981
    Lua=5.3
  </requires>
  <functioncall>integer highest_item_reccount = ultraschall.GetRecCounter()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Takes the RECPASS-counters of all items and takes and returns the highest one, which usually means, the number of items, who have been recorded since the project has been created.
    
    Note: a RECPASS-entry can also be part of a copy of a recorded item, so multiple items/takes can share the same RECPASS-entries.
     
    returns -1 if no recorded item/take has been found.
  </description>
  <retvals>
    integer highest_item_reccount - the highest reccount of all MediaItems, which usually means, that so many Items have been recorded in this project
  </retvals>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, count, all, mediaitem, take, recpass, counter</tags>
</US_DocBloc>
--]]
  local String=""
  local recpass=-1
  local found=0
  for i=0, reaper.CountTracks()-1 do
    local retval, str = reaper.GetTrackStateChunk(reaper.GetTrack(0,i), "", false)
    String=String.."\n"..str
  end
  for k in string.gmatch(String, "RECPASS (.-)\n") do
    found=found+1
    if recpass<tonumber(k) then 
      recpass=tonumber(k)
    end
 end
 return recpass, found
end


function ultraschall.GetMediaItem_ClickState()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetMediaItem_ClickState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.981
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>boolean clickstate, number position, MediaItem item, MediaItem_Take take = ultraschall.GetMediaItem_ClickState()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the currently clicked item and take, as well as the current timeposition.
    
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
  -- TODO: Has an issue, if the mousecursor drags the item, but moves above or underneath the item(if item is in first or last track).
  --       Even though the item is still clicked, it isn't returned as such.
  --       The ConfigVar uiscale supports dragging information, but the information which item has been clicked gets lost somehow
  local B=reaper.SNM_GetDoubleConfigVar("uiscale", -999)
  local X,Y=reaper.GetMousePosition()
  local Item, ItemTake = reaper.GetItemFromPoint(X,Y, true)
  if tostring(B)=="-1.#QNAN" or Item==nil then
    return false
  end
  return true, ultraschall.GetTimeByMouseXPosition(reaper.GetMousePosition()), Item, ItemTake
end

function ultraschall.GetTrackEnvelope_ClickState()
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
  local B=reaper.SNM_GetDoubleConfigVar("uiscale", -999)
  local X,Y=reaper.GetMousePosition()
  local Track, Info = reaper.GetTrackFromPoint(X,Y)
  if tostring(B)=="-1.#QNAN" or Info==0 then
    return false
  end
  reaper.BR_GetMouseCursorContext()
  local TrackEnvelope, TakeEnvelope = reaper.BR_GetMouseCursorContext_Envelope()
  if TakeEnvelope==true or TrackEnvelope==nil then return false end
  local TimePosition=ultraschall.GetTimeByMouseXPosition(reaper.GetMousePosition())
  local EnvelopePoint=reaper.GetEnvelopePointByTime(TrackEnvelope, TimePosition)
  return true, TimePosition, Track, TrackEnvelope, EnvelopePoint
end

function ultraschall.GetTimeByMouseXPosition(xmouseposition)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTimeByMouseXPosition</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.981
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>number position = ultraschall.GetTimeByMouseXPosition(integer xposition)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the projectposition at x-mouseposition.
    
    Returns nil in case of an error
  </description>
  <retvals>
    number position - the projectposition at x-coordinate in seconds
  </retvals>
  <parameters>
    integer xposition - the x-position in pixels, from which you would love to have the projectposition
  </parameters>
  <chapter_context>
    User Interface
    Miscellaneous
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>userinterface, get, projectposition, from x-position</tags>
</US_DocBloc>
--]]
  -- TODO: check, if mouse is above arrangeview and return an additional boolean parameter for that.
  if math.type(xmouseposition)~="integer" then ultraschall.AddErrorMessage("GetTimeByMouseXPosition", "xmouseposition", "must be an integer", -1) return nil end
  local Ax,AAx= reaper.GetSet_ArrangeView2(0, false, xmouseposition,xmouseposition+1)
  return Ax
end

function ultraschall.ShowTrackInputMenu(x, y, MediaTrack, HWNDParent)
 --[[
 <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
   <slug>ShowTrackInputMenu</slug>
   <requires>
     Ultraschall=4.00
     Reaper=5.92
     JS=0.986
     Lua=5.3
   </requires>
   <functioncall>boolean retval = ultraschall.ShowTrackInputMenu(integer x, integer y, optional MediaTrack MediaTrack, optional HWND HWNDParent)</functioncall>
   <description markup_type="markdown" markup_version="1.0.1" indent="default">
     Opens a TrackInput-context menu
     
     Returns false in case of error.
   </description>
   <parameters>
     integer x - x position of the context-menu in pixels
     integer y - y position of the context-menu in pixels
     optional MediaTrack MediaTrack - the MediaTrack, which shall be influenced by the menu-selection of the opened context-menu; nil, use the currently selected one
     optional HWND HWNDParent - a HWND, in which the context-menu shall be shown in; nil, use Reaper's main window
   </parameters>
   <retvals>
     boolean retval - true, opening the menu worked; false, there was an error
   </retvals>
   <chapter_context>
     User Interface
     Menu Management
   </chapter_context>
   <target_document>US_Api_Documentation</target_document>
   <source_document>ultraschall_functions_engine.lua</source_document>
   <tags>userinterface, show, context menu, trackinput</tags>
 </US_DocBloc>
 --]]
  if math.type(x)~="integer" then ultraschall.AddErrorMessage("ShowTrackInputMenu", "x", "must be an integer", -1) return false end
  if math.type(y)~="integer" then ultraschall.AddErrorMessage("ShowTrackInputMenu", "y", "must be an integer", -2) return false end
  if MediaTrack~=nil and ultraschall.type(MediaTrack)~="MediaTrack" then ultraschall.AddErrorMessage("ShowTrackInputMenu", "MediaTrack", "must be nil or a valid MediaTrack", -3) return false end
  if HWNDParent~=nil and ultraschall.IsValidHWND(HWNDParent)==false then ultraschall.AddErrorMessage("ShowTrackInputMenu", "HWNDParent", "must be nil or a valid HWND", -4) return false end
  reaper.ShowPopupMenu("track_input", x, y, HWNDParent, MediaTrack)
  return true
end

--ultraschall.ShowTrackInputMenu(100,200, MediaTrack, HWNDParent)

function ultraschall.ShowTrackPanelMenu(x, y, MediaTrack, HWNDParent)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ShowTrackPanelMenu</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.92
    JS=0.986
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ShowTrackPanelMenu(integer x, integer y, optional MediaTrack MediaTrack, optional HWND HWNDParent)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Opens a TrackPanel-context menu
    
    Returns false in case of error.
  </description>
  <parameters>
    integer x - x position of the context-menu in pixels
    integer y - y position of the context-menu in pixels
    optional MediaTrack MediaTrack - the MediaTrack, which shall be influenced by the menu-selection of the opened context-menu; nil, use the currently selected one
    optional HWND HWNDParent - a HWND, in which the context-menu shall be shown in; nil, use Reaper's main window
  </parameters>
  <retvals>
    boolean retval - true, opening the menu worked; false, there was an error
  </retvals>
  <chapter_context>
    User Interface
    Menu Management
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>userinterface, show, context menu, trackpanel</tags>
</US_DocBloc>
--]]
  if math.type(x)~="integer" then ultraschall.AddErrorMessage("ShowTrackPanelMenu", "x", "must be an integer", -1) return false end
  if math.type(y)~="integer" then ultraschall.AddErrorMessage("ShowTrackPanelMenu", "y", "must be an integer", -2) return false end
  if MediaTrack~=nil and ultraschall.type(MediaTrack)~="MediaTrack" then ultraschall.AddErrorMessage("ShowTrackPanelMenu", "MediaTrack", "must be nil or a valid MediaTrack", -3) return false end
  if HWNDParent~=nil and ultraschall.IsValidHWND(HWNDParent)==false then ultraschall.AddErrorMessage("ShowTrackPanelMenu", "HWNDParent", "must be nil or a valid HWND", -4) return false end

  reaper.ShowPopupMenu("track_panel", x, y, HWNDParent, MediaTrack)
  return true
end

--ultraschall.ShowTrackPanelMenu(100,200, MediaTrack, HWNDParent)

function ultraschall.ShowTrackAreaMenu(x, y, HWNDParent)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ShowTrackAreaMenu</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.92
    JS=0.986
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ShowTrackAreaMenu(integer x, integer y, optional HWND HWNDParent)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Opens a TrackArea-context menu
    
    Returns false in case of error.
  </description>
  <parameters>
    integer x - x position of the context-menu in pixels
    integer y - y position of the context-menu in pixels
    optional HWND HWNDParent - a HWND, in which the context-menu shall be shown in; nil, use Reaper's main window
  </parameters>
  <retvals>
    boolean retval - true, opening the menu worked; false, there was an error
  </retvals>
  <chapter_context>
    User Interface
    Menu Management
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>userinterface, show, context menu, trackarea</tags>
</US_DocBloc>
--]]
  if math.type(x)~="integer" then ultraschall.AddErrorMessage("ShowTrackAreaMenu", "x", "must be an integer", -1) return false end
  if math.type(y)~="integer" then ultraschall.AddErrorMessage("ShowTrackAreaMenu", "y", "must be an integer", -2) return false end
  if HWNDParent~=nil and ultraschall.IsValidHWND(HWNDParent)==false then ultraschall.AddErrorMessage("ShowTrackAreaMenu", "HWNDParent", "must be nil or a valid HWND", -3) return false end

  reaper.ShowPopupMenu("track_area", x, y, HWNDParent)
  return true
end

--ultraschall.ShowTrackAreaMenu(100,200, HWNDParent)

function ultraschall.ShowTrackRoutingMenu(x, y, MediaTrack, HWNDParent)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ShowTrackRoutingMenu</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.92
    JS=0.986
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ShowTrackRoutingMenu(integer x, integer y, optional MediaTrack MediaTrack, optional HWND HWNDParent)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Opens a TrackRouting-context menu
    
    Returns false in case of error.
  </description>
  <parameters>
    integer x - x position of the context-menu in pixels
    integer y - y position of the context-menu in pixels
    optional MediaTrack MediaTrack - the MediaTrack, which shall be influenced by the menu-selection of the opened context-menu; nil, use the currently selected one
    optional HWND HWNDParent - a HWND, in which the context-menu shall be shown in; nil, use Reaper's main window
  </parameters>
  <retvals>
    boolean retval - true, opening the menu worked; false, there was an error
  </retvals>
  <chapter_context>
    User Interface
    Menu Management
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>userinterface, show, context menu, trackrouting</tags>
</US_DocBloc>
--]]
  if math.type(x)~="integer" then ultraschall.AddErrorMessage("ShowTrackRoutingMenu", "x", "must be an integer", -1) return false end
  if math.type(y)~="integer" then ultraschall.AddErrorMessage("ShowTrackRoutingMenu", "y", "must be an integer", -2) return false end
  if MediaTrack~=nil and ultraschall.type(MediaTrack)~="MediaTrack" then ultraschall.AddErrorMessage("ShowTrackRoutingMenu", "MediaTrack", "must be nil or a valid MediaTrack", -3) return false end
  if HWNDParent~=nil and ultraschall.IsValidHWND(HWNDParent)==false then ultraschall.AddErrorMessage("ShowTrackRoutingMenu", "HWNDParent", "must be nil or a valid HWND", -4) return false end

  reaper.ShowPopupMenu("track_routing", x, y, HWNDParent, MediaTrack)
  return true
end

--ultraschall.ShowTrackRoutingMenu(100,200, reaper.GetTrack(0,0), HWNDParent)


function ultraschall.ShowRulerMenu(x, y, HWNDParent)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ShowRulerMenu</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.92
    JS=0.986
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ShowRulerMenu(integer x, integer y, optional HWND HWNDParent)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Opens a Ruler-context menu
    
    Returns false in case of error.
  </description>
  <parameters>
    integer x - x position of the context-menu in pixels
    integer y - y position of the context-menu in pixels
    optional HWND HWNDParent - a HWND, in which the context-menu shall be shown in; nil, use Reaper's main window
  </parameters>
  <retvals>
    boolean retval - true, opening the menu worked; false, there was an error
  </retvals>
  <chapter_context>
    User Interface
    Menu Management
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>userinterface, show, context menu, ruler</tags>
</US_DocBloc>
--]]
  -- MediaTrack=nil, use selected MediaTrack
  if math.type(x)~="integer" then ultraschall.AddErrorMessage("ShowRulerMenu", "x", "must be an integer", -1) return false end
  if math.type(y)~="integer" then ultraschall.AddErrorMessage("ShowRulerMenu", "y", "must be an integer", -2) return false end
  if HWNDParent~=nil and ultraschall.IsValidHWND(HWNDParent)==false then ultraschall.AddErrorMessage("ShowRulerMenu", "HWNDParent", "must be nil or a valid HWND", -3) return false end

  reaper.ShowPopupMenu("ruler", x, y, HWNDParent, MediaTrack)
  return true
end

--ultraschall.ShowRulerMenu(100,200, HWNDParent)

function ultraschall.ShowMediaItemMenu(x, y, MediaItem, HWNDParent)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ShowMediaItemMenu</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.92
    JS=0.986
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ShowMediaItemMenu(integer x, integer y, optional MediaItem MediaItem, optional HWND HWNDParent)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Opens a MediaItem-context menu
    
    Returns false in case of error.
  </description>
  <parameters>
    integer x - x position of the context-menu in pixels
    integer y - y position of the context-menu in pixels
    optional MediaItem MediaItem - the MediaItem, which shall be influenced by the menu-selection of the opened context-menu; nil, use the currently selected one
    optional HWND HWNDParent - a HWND, in which the context-menu shall be shown in; nil, use Reaper's main window
  </parameters>
  <retvals>
    boolean retval - true, opening the menu worked; false, there was an error
  </retvals>
  <chapter_context>
    User Interface
    Menu Management
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>userinterface, show, context menu, item, mediaitem</tags>
</US_DocBloc>
--]]
  if math.type(x)~="integer" then ultraschall.AddErrorMessage("ShowMediaItemMenu", "x", "must be an integer", -1) return false end
  if math.type(y)~="integer" then ultraschall.AddErrorMessage("ShowMediaItemMenu", "y", "must be an integer", -2) return false end
  if MediaItem~=nil and ultraschall.type(MediaItem)~="MediaItem" then ultraschall.AddErrorMessage("ShowMediaItemMenu", "MediaItem", "must be nil or a valid MediaItem", -3) return false end
  if HWNDParent~=nil and ultraschall.IsValidHWND(HWNDParent)==false then ultraschall.AddErrorMessage("ShowMediaItemMenu", "HWNDParent", "must be nil or a valid HWND", -4) return false end

  reaper.ShowPopupMenu("item", x, y, HWNDParent, MediaItem)
  return true
end

--ultraschall.ShowMediaItemMenu(100,200, reaper.GetMediaItem(0,0), HWNDParent)

function ultraschall.ShowEnvelopeMenu(x, y, TrackEnvelope, HWNDParent)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ShowEnvelopeMenu</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.92
    JS=0.986
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ShowEnvelopeMenu(integer x, integer y, optional TrackEnvelope TrackEnvelope, optional HWND HWNDParent)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Opens a Track/TakeEnvelope-context menu
    
    Returns false in case of error.
  </description>
  <parameters>
    integer x - x position of the context-menu in pixels
    integer y - y position of the context-menu in pixels
    optional TrackEnvelope TrackEnvelope - the TrackEnvelope/TakeEnvelope, which shall be influenced by the menu-selection of the opened context-menu; nil, use the currently selected TrackEnvelope
    optional HWND HWNDParent - a HWND, in which the context-menu shall be shown in; nil, use Reaper's main window
  </parameters>
  <retvals>
    boolean retval - true, opening the menu worked; false, there was an error
  </retvals>
  <chapter_context>
    User Interface
    Menu Management
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>userinterface, show, context menu, item, track envelope, take envelope</tags>
</US_DocBloc>
--]]
  if math.type(x)~="integer" then ultraschall.AddErrorMessage("ShowEnvelopeMenu", "x", "must be an integer", -1) return false end
  if math.type(y)~="integer" then ultraschall.AddErrorMessage("ShowEnvelopeMenu", "y", "must be an integer", -2) return false end
  if TrackEnvelope~=nil and ultraschall.type(TrackEnvelope)~="TrackEnvelope" then ultraschall.AddErrorMessage("ShowEnvelopeMenu", "TrackEnvelope", "must be nil or a valid TrackEnvelope", -3) return false end
  if HWNDParent~=nil and ultraschall.IsValidHWND(HWNDParent)==false then ultraschall.AddErrorMessage("ShowEnvelopeMenu", "HWNDParent", "must be nil or a valid HWND", -4) return false end

-- MediaTrack=nil, use selected MediaTrack
  reaper.ShowPopupMenu("envelope", x, y, HWNDParent, TrackEnvelope)
  return true
end

--ultraschall.ShowEnvelopeMenu(100,200, nil, HWNDParent)

function ultraschall.ShowEnvelopePointMenu(x, y, Pointidx, Trackenvelope, HWNDParent)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ShowEnvelopePointMenu</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.92
    JS=0.986
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ShowEnvelopePointMenu(integer x, integer y, integer Pointidx, optional TrackEnvelope TrackEnvelope, optional HWND HWNDParent)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Opens a Track/TakeEnvelope-Point-context menu
    
    Returns false in case of error.
  </description>
  <parameters>
    integer x - x position of the context-menu in pixels
    integer y - y position of the context-menu in pixels
    integer Pointidx - the envelope-point, which shall be influenced by the context-menu
    optional TrackEnvelope TrackEnvelope - the TrackEnvelope/TakeEnvelope, which shall be influenced by the menu-selection of the opened context-menu; nil, use the currently selected TrackEnvelope
    optional HWND HWNDParent - a HWND, in which the context-menu shall be shown in; nil, use Reaper's main window
  </parameters>
  <retvals>
    boolean retval - true, opening the menu worked; false, there was an error
  </retvals>
  <chapter_context>
    User Interface
    Menu Management
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>userinterface, show, context menu, item, track envelope, take envelope, envelope point</tags>
</US_DocBloc>
--]]
  if math.type(x)~="integer" then ultraschall.AddErrorMessage("ShowEnvelopePointMenu", "x", "must be an integer", -1) return false end
  if math.type(y)~="integer" then ultraschall.AddErrorMessage("ShowEnvelopePointMenu", "y", "must be an integer", -2) return false end
  if TrackEnvelope~=nil and ultraschall.type(TrackEnvelope)~="TrackEnvelope" then ultraschall.AddErrorMessage("ShowEnvelopePointMenu", "TrackEnvelope", "must be nil or a valid TrackEnvelope", -3) return false end
  if HWNDParent~=nil and ultraschall.IsValidHWND(HWNDParent)==false then ultraschall.AddErrorMessage("ShowEnvelopePointMenu", "HWNDParent", "must be nil or a valid HWND", -4) return false end
  if math.type(Pointidx)~="integer" then ultraschall.AddErrorMessage("ShowEnvelopePointMenu", "Pointidx", "must be an integer", -5) return false end
  if Pointidx<0 then ultraschall.AddErrorMessage("ShowEnvelopePointMenu", "Pointidx", "must be bigger than/equal 0", -6) return false end

  reaper.ShowPopupMenu("envelope_point", x, y, HWNDParent, Trackenvelope, Pointidx, 0)
  return true
end

--ultraschall.ShowEnvelopePointMenu(100,200, nil, 0, HWNDParent)

function ultraschall.ShowEnvelopePointMenu_AutomationItem(x, y, Pointidx, AutomationIDX, Trackenvelope, HWNDParent)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ShowEnvelopePointMenu_AutomationItem</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.92
    JS=0.986
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ShowEnvelopePointMenu_AutomationItem(integer x, integer y, integer Pointidx, integer AutomationIDX, optional TrackEnvelope TrackEnvelope, optional HWND HWNDParent)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Opens a Track/TakeEnvelope-Point-context menu for AutomationItems
    
    Returns false in case of error.
  </description>
  <parameters>
    integer x - x position of the context-menu in pixels
    integer y - y position of the context-menu in pixels
    integer Pointidx - the envelope-point, which shall be influenced by the context-menu
    integer AutomationIDX - the automation item-id within this Envelope, beginning with 1 for the first
    optional TrackEnvelope TrackEnvelope - the TrackEnvelope/TakeEnvelope, which shall be influenced by the menu-selection of the opened context-menu; nil, use the currently selected TrackEnvelope
    optional HWND HWNDParent - a HWND, in which the context-menu shall be shown in; nil, use Reaper's main window
  </parameters>
  <retvals>
    boolean retval - true, opening the menu worked; false, there was an error
  </retvals>
  <chapter_context>
    User Interface
    Menu Management
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>userinterface, show, context menu, item, track envelope, take envelope, envelope point, automation item</tags>
</US_DocBloc>
--]]
  if math.type(x)~="integer" then ultraschall.AddErrorMessage("ShowEnvelopePointMenu_AutomationItem", "x", "must be an integer", -1) return false end
  if math.type(y)~="integer" then ultraschall.AddErrorMessage("ShowEnvelopePointMenu_AutomationItem", "y", "must be an integer", -2) return false end
  if TrackEnvelope~=nil and ultraschall.type(TrackEnvelope)~="TrackEnvelope" then ultraschall.AddErrorMessage("ShowEnvelopePointMenu_AutomationItem", "TrackEnvelope", "must be nil or a valid TrackEnvelope", -3) return false end
  if HWNDParent~=nil and ultraschall.IsValidHWND(HWNDParent)==false then ultraschall.AddErrorMessage("ShowEnvelopePointMenu_AutomationItem", "HWNDParent", "must be nil or a valid HWND", -4) return false end
  if math.type(Pointidx)~="integer" then ultraschall.AddErrorMessage("ShowEnvelopePointMenu_AutomationItem", "Pointidx", "must be an integer", -5) return false end
  if Pointidx<0 then ultraschall.AddErrorMessage("ShowEnvelopePointMenu_AutomationItem", "Pointidx", "must be bigger than/equal 0", -6) return false end
  if math.type(AutomationIDX)~="integer" then ultraschall.AddErrorMessage("ShowEnvelopePointMenu_AutomationItem", "AutomationIDX", "must be an integer", -7) return false end
  if AutomationIDX<1 then ultraschall.AddErrorMessage("ShowEnvelopePointMenu_AutomationItem", "AutomationIDX", "must be bigger than 0", -8) return false end

  reaper.ShowPopupMenu("envelope_point", x, y, HWNDParent, Trackenvelope, Pointidx, AutomationIDX)
  return true
end

--ultraschall.ShowEnvelopePointMenu_AutomationItem(100,200, nil, 1, 1, HWNDParent)


function ultraschall.ShowAutomationItemMenu(x, y, AutomationIDX, Trackenvelope, HWNDParent)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ShowAutomationItemMenu</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.92
    JS=0.986
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ShowAutomationItemMenu(integer x, integer y, integer AutomationIDX, optional TrackEnvelope TrackEnvelope, optional HWND HWNDParent)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Opens an AutomationItem-context menu
    
    Returns false in case of error.
  </description>
  <parameters>
    integer x - x position of the context-menu in pixels
    integer y - y position of the context-menu in pixels
    integer AutomationIDX - the automation item-id within this Envelope which shall be influenced by the menu-selection of the opened context-menu, beginning with 1 for the first
    optional TrackEnvelope TrackEnvelope - the TrackEnvelope/TakeEnvelope, which shall be influenced by the menu-selection of the opened context-menu; nil, use the currently selected TrackEnvelope
    optional HWND HWNDParent - a HWND, in which the context-menu shall be shown in; nil, use Reaper's main window
  </parameters>
  <retvals>
    boolean retval - true, opening the menu worked; false, there was an error
  </retvals>
  <chapter_context>
    User Interface
    Menu Management
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>userinterface, show, context menu, item, track envelope, take envelope, automation item</tags>
</US_DocBloc>
--]]
  if math.type(x)~="integer" then ultraschall.AddErrorMessage("ShowAutomationItemMenu", "x", "must be an integer", -1) return false end
  if math.type(y)~="integer" then ultraschall.AddErrorMessage("ShowAutomationItemMenu", "y", "must be an integer", -2) return false end
  if TrackEnvelope~=nil and ultraschall.type(TrackEnvelope)~="TrackEnvelope" then ultraschall.AddErrorMessage("ShowAutomationItemMenu", "TrackEnvelope", "must be nil or a valid TrackEnvelope", -3) return false end
  if HWNDParent~=nil and ultraschall.IsValidHWND(HWNDParent)==false then ultraschall.AddErrorMessage("ShowAutomationItemMenu", "HWNDParent", "must be nil or a valid HWND", -4) return false end
  if math.type(AutomationIDX)~="integer" then ultraschall.AddErrorMessage("ShowAutomationItemMenu", "AutomationIDX", "must be an integer", -5) return false end
  if AutomationIDX<1 then ultraschall.AddErrorMessage("ShowAutomationItemMenu", "AutomationIDX", "must be bigger than 0", -6) return false end

  reaper.ShowPopupMenu("envelope_item", x, y, HWNDParent, Trackenvelope, AutomationIDX)
  return true
end

--ultraschall.ShowAutomationItemMenu(100,200, nil, 1, HWNDParent)

ultraschall.ShowLastErrorMessage()
