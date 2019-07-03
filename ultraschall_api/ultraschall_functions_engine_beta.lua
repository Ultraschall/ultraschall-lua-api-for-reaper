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
    Rendering of Project
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

function ultraschall.GetUserInputs(title, caption_names, default_retvals, values_length, caption_length, x_pos, y_pos)
--TODO: when there are newlines in captions, count them and resize these captions automatically, as well as move down the following captions and inputfields, so they
--      match the captionheights, without interfering into each other.
--      will need resizing of the window as well and moving OK and Cancel-buttons
--      if a caption ends with a newline, it will get the full width of the window, with the input-field moving one down, getting full length as well

--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetUserInputs</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.977
    JS=0.986
    Lua=5.3
  </requires>
  <functioncall>boolean retval, integer number_of_inputfields, table returnvalues = ultraschall.GetUserInputs(string title, table caption_names, table default_retvals, optional integer values_length, optional integer caption_length, optional integer x_pos, optional integer y_pos)</functioncall>
  <description>
    Gets inputs from the user.
    
    The captions and the default-returnvalues must be passed as an integer-index table.
    e.g.
      caption_names[1]="first caption name"
      caption_names[2]="second caption name"
      caption_names[1]="*third caption name, which creates an inputfield for passwords, due the * at the beginning"
      
   The number of entries in the tables "caption_names" and "default_retvals" decide, how many inputfields are shown. Maximum is 16 inputfields.
   You can safely pass "" as entry for a name, if you don't want to set it.
      
      The following example shows an input-dialog with three fields, where the first two the have default-values:
      
        retval, number_of_inputfields, returnvalues = ultraschall.GetUserInputs("I am the title", {"first", "second", "third"}, {1,"two"})   
     
   Note: Don't use this function within defer-scripts or scripts that are started by defer-scripts, as this produces errors.
         This is due limitations in Reaper, sorry.

   returns false in case of an error.
  </description>
  <retvals>
    boolean retval - true, the user clicked ok on the userinput-window; false, the user clicked cancel or an error occured
    integer number_of_inputfields - the number of returned values; nil, in case of an error
    table returnvalues - the returnvalues input by the user as a table; nil, in case of an error
  </retvals>
  <parameters>
    string title - the title of the inputwindow
    table caption_names - a table with all inputfield-captions. All non-string-entries will be converted to string-entries. Begin an entry with a * for password-entry-fields.
                        - it can be up to 16 fields
                        - This dialog only allows limited caption-field-length, about 19-30 characters, depending on the size of the used characters.
                        - Don't enter nil as captionname, as this will be seen as end of the table by this function, omitting possible following captionnames!
    table default_retvals - a table with all default retvals. All non-string-entries will be converted to string-entries.
                          - it can be up to 16 fields
                          - Only enter nil as default-retval, if no further default-retvals are existing, otherwise use "" for empty retvals.
    optional integer values_length - the extralength of the values-inputfield. With that, you can enhance the length of the inputfields. 
                            - 1-500
    optional integer caption_length - the length of the caption in pixels; inputfields and OK, Cancel-buttons will be moved accordingly.
    optional integer x_pos - the x-position of the GetUserInputs-dialog; nil, to keep default position
    optional integer y_pos - the y-position of the GetUserInputs-dialog; nil, to keep default position
                           - keep in mind: on Mac, the y-position starts with 0 at the bottom, while on Windows and Linux, 0 starts at the top of the screen!
                           -               this is the standard-behavior of the operating-systems themselves.
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
  local count33, autolength
  if type(title)~="string" then ultraschall.AddErrorMessage("GetUserInputs", "title", "must be a string", -1) return false end
  if type(caption_names)~="table" then ultraschall.AddErrorMessage("GetUserInputs", "caption_names", "must be a table", -2) return false end
  if type(default_retvals)~="table" then ultraschall.AddErrorMessage("GetUserInputs", "default_retvals", "must be a table", -3) return false end
  if values_length~=nil and math.type(values_length)~="integer" then ultraschall.AddErrorMessage("GetUserInputs", "values_length", "must be an integer", -4) return false end
  if values_length==nil then values_length=10 end
  if (values_length>500 or values_length<1) and values_length~=-1 then ultraschall.AddErrorMessage("GetUserInputs", "values_length", "must be between 1 and 500, or -1 for autolength", -5) return false end
  if values_length==-1 then values_length=1 autolength=true end
  local count = ultraschall.CountEntriesInTable_Main(caption_names)
  local count2 = ultraschall.CountEntriesInTable_Main(default_retvals)
  if count>16 then ultraschall.AddErrorMessage("GetUserInputs", "caption_names", "must be no more than 16 caption-names!", -5) return false end
  if count2>16 then ultraschall.AddErrorMessage("GetUserInputs", "default_retvals", "must be no more than 16 default-retvals!", -6) return false end
  if count2>count then count33=count2 else count33=count end
  values_length=(values_length*2)+18
 
  if x_pos~=nil and math.type(x_pos)~="integer" then ultraschall.AddErrorMessage("GetUserInputs", "x_pos", "must be an integer or nil!", -7) return false end
  if y_pos~=nil and math.type(y_pos)~="integer" then ultraschall.AddErrorMessage("GetUserInputs", "y_pos", "must be an integer or nil!", -8) return false end
  if x_pos==nil then x_pos="keep" end
  if y_pos==nil then y_pos="keep" end
  
  if caption_length~=nil and math.type(caption_length)~="integer" then ultraschall.AddErrorMessage("GetUserInputs", "caption_length", "must be an integer or nil!", -9) return false end
  if caption_length==nil then caption_length="keep" end
  
  local captions=""
  local retvals=""  
  
  for i=1, count2 do
    if default_retvals[i]==nil then default_retvals[i]="" end
    retvals=retvals..tostring(default_retvals[i])..","
    if autolength==true and values_length<tostring(default_retvals[i]):len() then values_length=(tostring(default_retvals[i]):len()*6.6)+18 end
  end
  retvals=retvals:sub(1,-2)  
  
  for i=1, count do
    if caption_names[i]==nil then caption_names[i]="" end
    captions=captions..tostring(caption_names[i])..","
    --if autolength==true and length<tostring(caption_names[i]):len()+length then length=(tostring(caption_names[i]):len()*16.6)+18+length end
  end
  captions=captions:sub(1,-2)
  if count<count2 then
    for i=count, count2 do
      captions=captions..","
    end
  end
  captions=captions..",extrawidth="..values_length
  
  --print2(captions)
  -- fill up empty caption-names, so the passed parameters are 16 in count
  for i=1, 16 do
    if caption_names[i]==nil then
      caption_names[i]=""
    end
  end
  caption_names[17]=nil

  -- fill up empty default-values, so the passed parameters are 16 in count  
  for i=1, 16 do
    if default_retvals[i]==nil then
      default_retvals[i]=""
    end
  end
  default_retvals[17]=nil

  local numentries, concatenated_table = ultraschall.ConcatIntegerIndexedTables(caption_names, default_retvals)
  
  local temptitle="Tudelu"..reaper.genGuid()
  
  ultraschall.Main_OnCommandByFilename(ultraschall.Api_Path.."/Scripts/GetUserInputValues_Helper_Script.lua", temptitle, title, 3, x_pos, y_pos, caption_length, "Tudelu", table.unpack(concatenated_table))

  local retval, retvalcsv = reaper.GetUserInputs(temptitle, count33, captions, "")
  if retval==false then reaper.DeleteExtState(ultraschall.ScriptIdentifier, "values", false) return false end
  local Values=reaper.GetExtState(ultraschall.ScriptIdentifier, "values")
  --print2(Values)
  reaper.DeleteExtState(ultraschall.ScriptIdentifier, "values", false)
  local count2,Values=ultraschall.CSV2IndividualLinesAsArray(Values ,"\n")
  for i=count+1, 17 do
    Values[i]=nil
  end
  return retval, count33, Values
end

--A,B,C,D=ultraschall.GetUserInputs("I got you", {"ShalalalaOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOHAH"}, {"HHHAAAAHHHHHHHHHHHHHHHHHHHHHHHHAHHHHHHHA"}, -1)

function ultraschall.ScanVSTPlugins(clear_cache)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ScanVSTPlugins</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.977
    SWS=2.10.0.1
    JS=0.986
    Lua=5.3
  </requires>
  <functioncall>ultraschall.ScanVSTPlugins(optional boolean clear_cache)</functioncall>
  <description>
    Re-scans all VST-Plugins.
  </description>
  <parameters>
    optional boolean clear_cache - true, clear cache before re-scanning; false or nil, just scan vts-plugins
  </parameters>
  <chapter_context>
    FX-Management
    Plugins
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>fx-management, scan, plugins, vst</tags>
</US_DocBloc>
--]]
  local hwnd, hwnd1, hwnd2, retval, prefspage, reopen, id
  local use_prefspage=210
  if clear_cache==true then id=1058 else id=1057 end
  hwnd = ultraschall.GetPreferencesHWND()
  if hwnd~=nil then reaper.JS_Window_Destroy(hwnd) reopen=true end
  retval, prefspage = reaper.BR_Win32_GetPrivateProfileString("REAPER", "prefspage", "-1", reaper.get_ini_file())
  reaper.ViewPrefs(use_prefspage, 0)
  hwnd = ultraschall.GetPreferencesHWND()
  hwnd1=reaper.JS_Window_FindChildByID(hwnd, 0)
  hwnd2=reaper.JS_Window_FindChildByID(hwnd1, id)
  reaper.JS_WindowMessage_Send(hwnd2, "WM_LBUTTONDOWN", 1,1,1,1)
  reaper.JS_WindowMessage_Send(hwnd2, "WM_LBUTTONUP", 1,1,1,1)

  if hwnd~=nil then reaper.JS_Window_Destroy(hwnd) end
  retval = reaper.BR_Win32_WritePrivateProfileString("REAPER", "prefspage", prefspage, reaper.get_ini_file())
  reaper.ViewPrefs(prefspage, 0) 

  if reopen~=true then 
    hwnd = ultraschall.GetPreferencesHWND() 
    if hwnd~=nil then reaper.JS_Window_Destroy(hwnd) end
  end
end

--ultraschall.ScanVSTPlugins(true)

function ultraschall.AutoDetectVSTPlugins()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AutoDetectVSTPlugins</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.977
    SWS=2.10.0.1
    JS=0.986
    Lua=5.3
  </requires>
  <functioncall>ultraschall.AutoDetectVSTPlugins()</functioncall>
  <description>
    Auto-detects the vst-plugins-folder.
  </description>
  <chapter_context>
    FX-Management
    Plugins
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>fx-management, path, folder, auto-detect, plugins, vst</tags>
</US_DocBloc>
--]]
  local hwnd, hwnd1, hwnd2, retval, prefspage, reopen, id
  local use_prefspage=210
  id=1117
  hwnd = ultraschall.GetPreferencesHWND()
  if hwnd~=nil then reaper.JS_Window_Destroy(hwnd) reopen=true end
  retval, prefspage = reaper.BR_Win32_GetPrivateProfileString("REAPER", "prefspage", "-1", reaper.get_ini_file())
  reaper.ViewPrefs(use_prefspage, 0)
  hwnd = ultraschall.GetPreferencesHWND()
  hwnd1=reaper.JS_Window_FindChildByID(hwnd, 0)
  hwnd2=reaper.JS_Window_FindChildByID(hwnd1, id)
  reaper.JS_WindowMessage_Send(hwnd2, "WM_LBUTTONDOWN", 1,1,1,1)
  reaper.JS_WindowMessage_Send(hwnd2, "WM_LBUTTONUP", 1,1,1,1)

  if hwnd~=nil then reaper.JS_Window_Destroy(hwnd) end
  retval = reaper.BR_Win32_WritePrivateProfileString("REAPER", "prefspage", prefspage, reaper.get_ini_file())
  reaper.ViewPrefs(prefspage, 0) 

  if reopen~=true then 
    hwnd = ultraschall.GetPreferencesHWND() 
    if hwnd~=nil then reaper.JS_Window_Destroy(hwnd) end
  end
end

--ultraschall.AutoDetectVSTPlugins()

function ultraschall.ScanDXPlugins(re_scan)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ScanDXPlugins</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.977
    SWS=2.10.0.1
    JS=0.986
    Lua=5.3
  </requires>
  <functioncall>ultraschall.ScanDXPlugins(optional boolean re_scan)</functioncall>
  <description>
    (Re-)scans all DX-Plugins.
  </description>
  <parameters>
    optional boolean clear_cache - true, re-scan all DX-plugins; false or nil, only scan new DX-plugins
  </parameters>
  <chapter_context>
    FX-Management
    Plugins
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>fx-management, scan, plugins, dx</tags>
</US_DocBloc>
--]]
  local hwnd, hwnd1, hwnd2, retval, prefspage, reopen, id
  local use_prefspage=209
  if re_scan==true then id=1060 else id=1059 end
  hwnd = ultraschall.GetPreferencesHWND()
  if hwnd~=nil then reaper.JS_Window_Destroy(hwnd) reopen=true end
  retval, prefspage = reaper.BR_Win32_GetPrivateProfileString("REAPER", "prefspage", "-1", reaper.get_ini_file())
  reaper.ViewPrefs(use_prefspage, 0)
  hwnd = ultraschall.GetPreferencesHWND()
  hwnd1=reaper.JS_Window_FindChildByID(hwnd, 0)
  hwnd2=reaper.JS_Window_FindChildByID(hwnd1, id)
  reaper.JS_WindowMessage_Send(hwnd2, "WM_LBUTTONDOWN", 1,1,1,1)
  reaper.JS_WindowMessage_Send(hwnd2, "WM_LBUTTONUP", 1,1,1,1)

  if hwnd~=nil then reaper.JS_Window_Destroy(hwnd) end
  retval = reaper.BR_Win32_WritePrivateProfileString("REAPER", "prefspage", prefspage, reaper.get_ini_file())
  reaper.ViewPrefs(prefspage, 0) 

  if reopen~=true then 
    hwnd = ultraschall.GetPreferencesHWND() 
    if hwnd~=nil then reaper.JS_Window_Destroy(hwnd) end
  end
end

--ultraschall.ScanDXPlugins()

function ultraschall.AutoSearchReaMoteSlaves()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AutoSearchReaMoteSlaves</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.977
    SWS=2.10.0.1
    JS=0.986
    Lua=5.3
  </requires>
  <functioncall>ultraschall.AutoSearchReaMoteSlaves()</functioncall>
  <description>
    Auto-searches for new ReaMote-Slaves
  </description>
  <chapter_context>
    ReaMote
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>reamote, scan, search, slaves</tags>
</US_DocBloc>
--]]
  local hwnd, hwnd1, hwnd2, retval, prefspage, reopen, id
  local use_prefspage=227
  id=1076
  hwnd = ultraschall.GetPreferencesHWND()
  if hwnd~=nil then reaper.JS_Window_Destroy(hwnd) reopen=true end
  retval, prefspage = reaper.BR_Win32_GetPrivateProfileString("REAPER", "prefspage", "-1", reaper.get_ini_file())
  reaper.ViewPrefs(use_prefspage, 0)
  hwnd = ultraschall.GetPreferencesHWND()
  hwnd1=reaper.JS_Window_FindChildByID(hwnd, 0)
  hwnd2=reaper.JS_Window_FindChildByID(hwnd1, id)
  reaper.JS_WindowMessage_Send(hwnd2, "WM_LBUTTONDOWN", 1,1,1,1)
  reaper.JS_WindowMessage_Send(hwnd2, "WM_LBUTTONUP", 1,1,1,1)

  if hwnd~=nil then reaper.JS_Window_Destroy(hwnd) end
  retval = reaper.BR_Win32_WritePrivateProfileString("REAPER", "prefspage", prefspage, reaper.get_ini_file())
  reaper.ViewPrefs(prefspage, 0) 

  if reopen~=true then 
    hwnd = ultraschall.GetPreferencesHWND() 
    if hwnd~=nil then reaper.JS_Window_Destroy(hwnd) end
  end
end

--ultraschall.AutoSearchReaMoteSlaves()


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

function ultraschall.Localize(text, ...)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Localize</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.975
    Lua=5.3
  </requires>
  <functioncall>string translated_string, boolean translated = ultraschall.Localize(string original_string, ...)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Translates the string original_string into its translated version, as stored in a translation-file.
    
    To set a translationfile, see [Localize_UseFile](#Localize_UseFile).

    If the string contains %s, the optional parameters "..." will replace them. The order of the parameters is the order of the replacement of the %s in the string.
        
    If no translation is available, it returns the original string. In that case, %s in the string could be replaced by optional parameters ...
    
    This function can be used with or without ultraschall. at the beginning, for your convenience.
    
    returns false in case of an error
  </description>
  <retvals>
    string translated_string - the translated string; will be the original_string(with optional substitution), if translation is not possible
    boolean retval - true, translation-was successful; false, translation wasn't successful
  </retvals>
  <parameters>
    string original_string - the original string, that you want to translate
    ... - optional parameters, who will be used to substitute %s in the returned string; order of the optional parameters reflects order of %s in the string
  </parameters>
  <chapter_context>
    Localization
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>localization, translate, string, translationfile</tags>
</US_DocBloc>
--]]
  local retval=true
  if type(text)~="string" then ultraschall.AddErrorMessage("Localize", "text", "must be a string", -1) return nil, retval end
  local Tab={...}
  if ultraschall.Localize_File_Content==nil then return text, false end
  local retvaltext=ultraschall.Localize_File_Content[text]
  if retvaltext==nil then retvaltext=text retval=false end
  retvaltext=string.gsub(retvaltext, "\\n", "\n")
  for i=1, #Tab do
    retvaltext=string.gsub(retvaltext, "%%s"..i.." ", tostring(Tab[i]))
  end
  retvaltext=string.gsub(retvaltext, "\\=", "=")
  return retvaltext, retval
end


Localize=ultraschall.Localize


--A=Localize("Export MP3\nEcht", " Eins ", " Zwo ", " Drei ")
--A=Localize("Hud=el%s=", -22,2,3,4,5,6,7,8,9, "ZEHN")
--print2(A)
--A=ultraschall.Localize("Export MP3\nRender your Podcast to a MP3 File.\n\n\nChapter Markers\nYou may take a final look at your chapter markers.\n\n\nID3 Metadata\nUse the ID3 Editor to add metadata to your podcast.\n\n\nPodcast Episode Image:\nFound.\n\n\n\n\nFinalize MP3\nHit the button and select your MP3 to finalize it\nwith metadata, chapters and episode image!")
--AAA,AAA2=ultraschall.Localize("Export MP3\nRender your Podcast to a MP3 File.\n\n\nChapter Markers\nYou may take a final look at your chapter markers.\n\n\nID3 Metadata\nUse the ID3 Editor to add metadata to your podcast.\n\n\nPodcast Episode Image:\nFound.\n\n\n\n\nFinalize MP3\nHit the button and select your MP3 to finalize it\nwith metadata, chapters and episode image!", "ALABASTERHEINRICH")
--AA=reaper.file_exists(ultraschall.Localize_Filename)

function ultraschall.Localize_RefreshFile()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Localize_RefreshFile</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.975
    Lua=5.3
  </requires>
  <functioncall>string translated_string, boolean translated = Localize_RefreshFile()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Reloads the translation-file, that has been set using [Localize_UseFile](#Localize_UseFile).
  </description>
  <chapter_context>
    Localization
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>localization, reload, refresh, translationfile</tags>
</US_DocBloc>
--]]
  if ultraschall.Localize_Filename~=nil then
    return ultraschall.Localize_UseFile(ultraschall.Localize_Filename, ultraschall.Localize_Section, ultraschall.Localize_Language)
  else
    ultraschall.AddErrorMessage("Localize_RefreshFile", "", "no translation-file loaded", -1)
    return false
  end
end

--OOO=ultraschall.Localize_RefreshFile()

--print2(ultraschall.Localize_File)


function ultraschall.AddSelectedItemsToRenderQueue(render_items_individually, render_items_through_master, RenderTable)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AddSelectedItemsToRenderQueue</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.979
    Lua=5.3
  </requires>
  <functioncall>boolean retval, integer num_queued_projects = ultraschall.AddSelectedItemsToRenderQueue(optional boolean render_items_individually, optional boolean render_items_through_master, optional RenderTable RenderTables)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Adds the selected MediaItems to the render-queue.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, adding was successful; false, adding was unsuccessful
    integer num_queued_projects - the number of newly created projects in the render-queue
  </retvals>
  <parameters>
    optional boolean render_items_individually - false or nil, render all selected MediaItems in one render-queued-project; true, render all selected MediaItems individually as separate Queued-projects
    optional boolean render_items_through_master - false or nil, just render the MediaItems; true, render the MediaItems through the Master-channel
    optional RenderTable RenderTables - a RenderTable to apply for the renders in the render-queue
  </parameters>
  <chapter_context>
    Rendering Projects
    RenderQueue
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>projectfiles, add, mediaitem, item, items, selected, render, queue, renderqueue</tags>
</US_DocBloc>
]]
  if reaper.CountSelectedMediaItems(0)<1 then ultraschall.AddErrorMessage("AddSelectedItemsToRenderQueue", "", "no MediaItem selected", -1) return false end
  if RenderTable==nil then
    RenderTable = ultraschall.GetRenderTable_Project()
  else
    if ultraschall.IsValidRenderTable(RenderTable)==false then ultraschall.AddErrorMessage("AddSelectedItemsToRenderQueue", "RenderTable", "no valid Rendertable", -2) return false end
  end
  local RenderTable_org = ultraschall.GetRenderTable_Project()
  
  if render_items_through_master==true then
    RenderTable["Source"]=64
  else
    RenderTable["Source"]=32
  end
  RenderTable["Bounds"]=4
  RenderTable["RenderFile"]="c:\\temp\\"
  local retval = ultraschall.ApplyRenderTable_Project(RenderTable, true)
  
  if render_items_individually~=true then
    reaper.Main_OnCommand(41823,0)
    count=1
  else
    count, MediaItemArray = ultraschall.GetAllSelectedMediaItems()
    reaper.SelectAllMediaItems(0, false)
    for i=1, count do
      reaper.SetMediaItemSelected(MediaItemArray[i], true)
      reaper.Main_OnCommand(41823,0)
      reaper.SetMediaItemSelected(MediaItemArray[i], false)
    end
    ultraschall.SelectMediaItems_MediaItemArray(MediaItemArray)
  end
  
  
  retval = ultraschall.ApplyRenderTable_Project(RenderTable_org, true)
  return true, count
end

--A,AA=ultraschall.AddSelectedItemsToRenderQueue(false, false)
--ultraschall.AddProjectFileToRenderQueue("c:\\Users\\meo\\Desktop\\trss\\Maerz2019-1\\rec\\rec-edit.RPP")


--RenderTable = ultraschall.GetRenderTable_Project()

function ultraschall.GetRenderingToFileHWND()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetRenderingToFileHWND</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.977
    Lua=5.3
  </requires>
  <functioncall>HWND rendertofile_dialog = ultraschall.GetRenderingToFileHWND()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Gets the HWND of the Rendering to File-dialog, if Reaper is currently rendering.
    
    returns nil in case of an error
  </description>
  <retvals>
    HWND rendertofile_dialog - the HWND of the render to file-dialog; nil, in case of an error
  </retvals>
  <parameters>
    optional boolean render_items_individually - false or nil, render all selected MediaItems in one render-queued-project; true, render all selected MediaItems individually as separate Queued-projects
    optional boolean render_items_through_master - false or nil, just render the MediaItems; true, render the MediaItems through the Master-channel
    optional RenderTable RenderTables - a RenderTable to apply for the renders in the render-queue
  </parameters>
  <chapter_context>
    Rendering Projects
    RenderQueue
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>render, get, hwnd, render to file, dialog</tags>
</US_DocBloc>
]]
  local HWND=reaper.JS_Window_Find(reaper.JS_Localize("Rendering to File..." ,"DLG_124"), true)
  if HWND==nil then HWND=reaper.JS_Window_Find(reaper.JS_Localize("Finished in" ,"render"), false) end
  if HWND==nil then HWND=reaper.JS_Window_Find(reaper.JS_Localize("Rendering region " ,"render"), false) end
  if HWND==nil then ultraschall.AddErrorMessage("GetRenderingToFileHWND", "", "Can't find Rendering to File-window", -1) return end
  if ultraschall.IsValidHWND(HWND)==true then
    local Retval1 = ultraschall.HasHWNDChildWindowNames(HWND, reaper.JS_Localize("Launch File", "DLG_124"))
    local Retval2= ultraschall.HasHWNDChildWindowNames(HWND, reaper.JS_Localize("Automatically close when finished", "DLG_124"))
    local Retval3= ultraschall.HasHWNDChildWindowNames(HWND, reaper.JS_Localize("Render status", "DLG_124"))
    if Retval1==true and Retval2==true and Retval3==true then
      return HWND
    else
      ultraschall.AddErrorMessage("GetRenderingToFileHWND", "", "Can't find Rendering to File-window", -2) return
    end
  else
    ultraschall.AddErrorMessage("GetRenderingToFileHWND", "", "Can't find Rendering to File-window", -3) return
  end
end

--A=ultraschall.GetRenderingToFileHWND()


function DeleteParmLearn_FXStateChunk(FXStateChunk, fxid, id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DeleteParmLearn_FXStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.979
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string alteredFXStateChunk = ultraschall.DeleteParmLearn_FXStateChunk(string FXStateChunk, integer fxid, integer id)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Deletes a ParmLearn-entry from an FXStateChunk.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, if deletion was successful; false, if the function couldn't delete anything
    string alteredFXStateChunk - the altered FXStateChunk
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, which you want to delete a ParmLearn from
    integer fxid - the id of the fx, which holds the to-delete-ParmLearn-entry; beginning with 1
    integer id - the id of the ParmLearn-entry to delete; beginning with 1
  </parameters>
  <chapter_context>
    FX-Management
    Parameter Mapping
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>fx management, parm, learn, delete, parm, learn, midi, osc, binding</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("DeleteParmLearn_FXStateChunk", "FXStateChunk", "no valid FXStateChunk", -1) return false end
  if math.type(fxid)~="integer" then ultraschall.AddErrorMessage("DeleteParmLearn_FXStateChunk", "fxid", "must be an integer", -2) return false end
  if math.type(id)~="integer" then ultraschall.AddErrorMessage("DeleteParmLearn_FXStateChunk", "id", "must be an integer", -3) return false end
    
  local count=0
  local FX, UseFX2, start, stop
  for k in string.gmatch(FXStateChunk, "    BYPASS.-WAK.-\n") do
    count=count+1
    if count==fxid then UseFX=k end
  end
  
  count=0
  if UseFX~=nil then
    for k in string.gmatch(UseFX, "    PARMLEARN.-\n") do
      count=count+1
      if count==id then UseFX2=string.gsub(UseFX, k, "") break end
    end
  end
  
  if UseFX2~=nil then
    start,stop=string.find(FXStateChunk, UseFX, 0, true)
    return true, FXStateChunk:sub(1, start)..UseFX2:sub(2,-2)..FXStateChunk:sub(stop, -1)
  else
    return false, FXStateChunk
  end
end

--DeleteParmLearn_FXStateChunk(FXStateChunk, 1, 1)

ultraschall.ShowLastErrorMessage()
