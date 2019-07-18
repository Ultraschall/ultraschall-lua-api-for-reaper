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

-------------------------------------
--- ULTRASCHALL - API - FUNCTIONS ---
-------------------------------------
---    Track Management Module    ---
-------------------------------------

if type(ultraschall)~="table" then 
  -- update buildnumber and add ultraschall as a table, when programming within this file
  local retval, string = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "Functions-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  local retval, string = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "TrackManagement-Module-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
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
  
  ultraschall.API_TempPath=reaper.GetResourcePath().."/UserPlugins/ultraschall_api/temp/"
end

function ultraschall.GetTrackStateChunk_Tracknumber(tracknumber)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackStateChunk_Tracknumber</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.92
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string trackstatechunk = ultraschall.GetTrackStateChunk_Tracknumber(integer tracknumber)</functioncall>
  <description>
    returns the trackstatechunk for track tracknumber
    
    returns false in case of an error
  </description>
  <parameters>
    integer tracknumber - the tracknumber, 0 for master track, 1 for track 1, 2 for track 2, etc.    
  </parameters>
  <retvals>
    boolean retval - true in case of success; false in case of error
    string trackstatechunk - the trackstatechunk for track tracknumber
  </retvals>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, trackstatechunk, get</tags>
</US_DocBloc>
]]
  -- prepare variables
  local Track, A, AA, Overflow
  
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackStateChunk_Tracknumber","tracknumber", "must be an integer", -1) return false end
  if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackStateChunk_Tracknumber","tracknumber", "only tracknumbers allowed between 0(master), 1(track1) and "..reaper.CountTracks(0).."(last track in this project)", -2) return false end
  
  -- Get Mastertrack, if tracknumber=0
  if tracknumber==0 then Track=reaper.GetMasterTrack(0)
  else Track=reaper.GetTrack(0,tracknumber-1)
  end

  return reaper.GetTrackStateChunk(Track, "", false)
end

--------------------------
---- Get Track States ----
--------------------------

function ultraschall.GetTrackName(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackName</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string trackname = ultraschall.GetTrackName(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns name of the track.
    
    It's the entry NAME
  </description>
  <retvals>
    string trackname  - the name of the track
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, name, state, get, trackstatechunk</tags>
</US_DocBloc>
--]]

  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackName", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackName", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  
  -- get trackname
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackName", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
  local Track_Name=str:match("NAME (.-)%c")
  return Track_Name
end

function ultraschall.GetTrackPeakColorState(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackPeakColorState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer PeakColorState = ultraschall.GetTrackPeakColorState(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns state of the PeakColor-number, which is the trackcolor. Will be returned as string, to avoid losing trailing or preceding zeros.
    
    It's the entry PEAKCOL
  </description>
  <retvals>
    string PeakColorState  - the color of the track
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, trackcolor, color, get, state, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameter
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackPeakColorState", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
    --get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackPeakColorState", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  -- get peakcolor-state
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackPeakColorState", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
  str=str:match("PEAKCOL(%s.-)%c").." "
  return tonumber(str:match("%s(.-)%s"))
end

--A=ultraschall.GetTrackPeakColorState(2)

function ultraschall.GetTrackBeatState(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackBeatState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>number BeatState = ultraschall.GetTrackBeatState(integer tracknumber,optional string TrackStateChunk)</functioncall>
  <description>
    returns Track-BeatState. 

    It's the entry BEAT
  </description>
  <retvals>
    number BeatState  - -1 - Project time base; 0 - Time; 1 - Beats position, length, rate; 2 - Beats position only
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, beat, get, state, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameter
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackBeatState", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackBeatState", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  
  -- get beatstate
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackBeatState", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end        
  str=str:match("BEAT(%s.-)%c").." "
  return tonumber(str:match("%s(.-)%s"))
end

--A=ultraschall.GetTrackBeatState(1)

function ultraschall.GetTrackAutoRecArmState(tracknumber, str)
-- returns nil, if it's unset
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackAutoRecArmState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer AutoRecArmState = ultraschall.GetTrackAutoRecArmState(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns if the track is in AutoRecArm, when selected. Returns nil if not.

    It's the entry AUTO_RECARM
  </description>
  <retvals>
    integer AutoRecArmState  - state of autorecarm; 1 for set; nil if unset
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, autorecarm, rec, state, get, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackAutoRecArmState", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackAutoRecArmState", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackAutoRecArmState", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
    
  -- get recarm
  str=str:match("AUTO_RECARM(%s.-)%c")
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s"))
end

--A=ultraschall.GetTrackAutoRecArmState(1)
  
function ultraschall.GetTrackMuteSoloState(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackMuteSoloState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer Mute, integer Solo, integer SoloDefeat = ultraschall.GetTrackMuteSoloState(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns states of Mute and Solo-Buttons.
    
    It's the entry MUTESOLO
  </description>
  <retvals>
    integer Mute - Mute set to 0 - Mute off, 1 - Mute On
    integer Solo - Solo set to 0 - Solo off, 1 - Solo ignore routing, 2 - Solo on
    integer SoloDefeat  - SoloDefeat set to 0 - off, 1 - on
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, mute, solo, solodefeat, state, get, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackMuteSoloState", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackMuteSoloState", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackMuteSoloState", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
  
  -- get mutesolo-state
  str=str:match("MUTESOLO(%s.-)%c")
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s")),
         tonumber(str:match("%s.-%s(.-)%s")),
         tonumber(str:match("%s.-%s.-%s(.-)%s"))
end

--A1,A2,A3 = ultraschall.GetTrackMuteSoloState(1)
  
function ultraschall.GetTrackIPhaseState(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackIPhaseState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>number IPhase = ultraschall.GetTrackIPhaseState(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns state of the IPhase. If the Phase-button is pressed, it will return 1, else it will return 0.
    
    It's the entry IPHASE
  </description>
  <retvals>
    number IPhase  - state of the phase-button; 0, normal phase; 1, inverted phase(180°)
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, iphase, phase, button, state, get, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackIPhaseState", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
    
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackIPhaseState", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackIPhaseState", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end

  -- get iphase-state
  str=str:match("IPHASE(%s.-)%c")
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s"))
end

--A=ultraschall.GetTrackIPhaseState(1)

function ultraschall.GetTrackIsBusState(tracknumber, str)
-- for folder-management
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackIsBusState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer busstate1, integer busstate2 = ultraschall.GetTrackIsBusState(integer tracknumber, optional string trackstatechunk)</functioncall>
  <description>
    returns busstate of the track, means: if it's a folder track
    
    It's the entry ISBUS
  </description>
  <retvals>
    integer busstate1=0, integer busstate2=0 - track is no folder
    - or
    integer busstate1=1, integer busstate2=1 - track is a folder
    - or
    integer busstate1=1, integer busstate2=2 - track is a folder but view of all subtracks not compactible
    - or
    integer busstate1=2, integer busstate2=-1 - track is last track in folder(no tracks of subfolders follow)
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, busstate, folder, subfolders, state, get, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackIsBusState", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then

    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackIsBusState", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackIsBusState", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
  
  -- get busstate
  str=str:match("ISBUS(%s.-)%c")
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s")),
         tonumber(str:match("%s.-%s(.-)%s"))
end

--A1,A2=ultraschall.GetTrackIsBusState(1)

function ultraschall.GetTrackBusCompState(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackBusCompState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>number BusCompState1, number BusCompState2 = ultraschall.GetTrackBusCompState(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns BusCompState, if the tracks in a folder are compacted or not.
    
    It's the entry BUSCOMP
  </description>
  <retvals>
    number BusCompState1 - 0 - no compacting, 1 - compacted tracks, 2 - minimized tracks
    number BusCompState2 - 0 - unknown,1 - unknown
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, busstate, folder, subfolders, state, get, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackBusCompState", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack        
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackBusCompState", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackBusCompState", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
  
  -- get buscompstate
  str=str:match("BUSCOMP(%s.-)%c")
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s")),
         tonumber(str:match("%s.-%s(.-)%s"))
end

--A,A2=ultraschall.GetTrackBusCompState(1)

function ultraschall.GetTrackShowInMixState(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackShowInMixState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer MCPvisible, number MCP_FX_visible, number MCPTrackSendsVisible, integer TCPvisible, number ShowInMix5, number ShowInMix6, number ShowInMix7, number ShowInMix8 = ultraschall.GetTrackShowInMixState(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns Show in Mix-state.
    
    It's the entry SHOWINMIX
  </description>
  <retvals>
     integer MCPvisible - 0 invisible, 1 visible
     number MCP_FX_visible - 0 visible, 1 FX-Parameters visible, 2 invisible
     number MCPTrackSendsVisible - 0 & 1.1 and higher TrackSends in MCP visible, every other number makes them invisible
     integer TCPvisible - 0 track is invisible in TCP, 1 track is visible in TCP
     number ShowInMix5 - unknown
     number ShowInMix6 - unknown
     number ShowInMix7 - unknown
     number ShowInMix8  - unknown
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, mixer, show, mcp, tcp, fx, visible, state, get, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackShowInMixState", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackShowInMixState", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackShowInMixState", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
  
  -- get showinmix-state
  str=str:match("SHOWINMIX(%s.-)%c")
  local L=str
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s")),
         tonumber(str:match("%s.-%s(.-)%s")),
         tonumber(str:match("%s.-%s.-%s(.-)%s")),
         tonumber(str:match("%s.-%s.-%s.-%s(.-)%s")),
         tonumber(str:match("%s.-%s.-%s.-%s.-%s(.-)%s")),
         
         tonumber(str:match("%s.-%s.-%s.-%s.-%s.-%s(.-)%s")),
         tonumber(str:match("%s.-%s.-%s.-%s.-%s.-%s.-%s(.-)%s")),
         tonumber(str:match("%s.-%s.-%s.-%s.-%s.-%s.-%s.-%s(.-)%s"))
end  

--A1,A2,A3,A4,A5,A6,A7,A8=ultraschall.GetTrackShowInMixState(2)

function ultraschall.GetTrackFreeModeState(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackFreeModeState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer FreeModeState = ultraschall.GetTrackFreeModeState(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns if the track has track free item positioning enabled(1) or not(0).
    
    It's the entry FREEMODE
  </description>
  <retvals>
    integer FreeModeState  - 1 - enabled, 0 - not enabled
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, trackfreemode, state, get, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackFreeModeState", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackFreeModeState", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackFreeModeState", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
  
  -- get freemode-state
  str=str:match("FREEMODE(%s.-)%c")
  local L=str
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s"))
end

--A=ultraschall.GetTrackFreeModeState(2)

function ultraschall.GetTrackRecState(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackRecState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer ArmState, integer InputChannel, integer MonitorInput, integer RecInput, integer MonitorWhileRec, integer presPDCdelay, integer RecordingPath = ultraschall.GetTrackRecState(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns Track Rec State.
    
    It's the entry REC
  </description>
  <retvals>
    integer ArmState - returns 1(armed) or 0(unarmed)
    
     integer InputChannel - returns the InputChannel
    --1 - No Input
    -1-16(more?) - Mono Input Channel
    -1024 - Stereo Channel 1 and 2
    -1026 - Stereo Channel 3 and 4
    -1028 - Stereo Channel 5 and 6
    -...
    -5056 - Virtual MIDI Keyboard all Channels
    -5057 - Virtual MIDI Keyboard Channel 1
    -...
    -5072 - Virtual MIDI Keyboard Channel 16
    -5088 - All MIDI Inputs - All Channels
    -5089 - All MIDI Inputs - Channel 1
    -...
    -5104 - All MIDI Inputs - Channel 16
    
     integer MonitorInput - 0 monitor off, 1 monitor on, 2 monitor on tape audio style
     
     integer RecInput - returns rec-input type
    -0 input(Audio or Midi)
    -1 Record Output Stereo
    -2 Disabled, Input Monitoring Only
    -3 Record Output Stereo, Latency Compensated
    -4 Record Output MIDI
    -5 Record Output Mono
    -6 Record Output Mono, Latency Compensated
    -7 MIDI overdub
    -8 MIDI replace
    -9 MIDI touch replace
    -10 Record Output Multichannel
    -11 Record Output Multichannel, Latency Compensated 
    -12 Record Input Force Mono
    -13 Record Input Force Stereo
    -14 Record Input Force Multichannel
    -15 Record Input Force MIDI
    -16 MIDI latch replace
    
     integer MonitorWhileRec - Monitor Trackmedia when recording, 0 is off, 1 is on
    
     integer presPDCdelay - preserve PDC delayed monitoring in media items
    
     integer RecordingPath  - recording path used 
    -0 - Primary Recording-Path only
    -1 - Secondary Recording-Path only
    -2 - Primary Recording Path and Secondary Recording Path(for invisible backup)
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, midi, recordingpath, path, input, recinput, pdc, monitor, arm, state, get, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackRecState", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackRecState", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackRecState", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
  
  -- get rec-state
  str=str:match("REC(%s.-)%c")
  -- L=str
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s")),
         tonumber(str:match("%s.-%s(.-)%s")),
         tonumber(str:match("%s.-%s.-%s(.-)%s")),
         tonumber(str:match("%s.-%s.-%s.-%s(.-)%s")),
         tonumber(str:match("%s.-%s.-%s.-%s.-%s(.-)%s")),
         
         tonumber(str:match("%s.-%s.-%s.-%s.-%s.-%s(.-)%s")),
         tonumber(str:match("%s.-%s.-%s.-%s.-%s.-%s.-%s(.-)%s"))
end


function ultraschall.GetTrackVUState(tracknumber, str)
-- returns 0 if MultiChannelMetering is off
-- returns 2 if MultichannelMetering is on
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackVUState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer VUState = ultraschall.GetTrackVUState(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns VUState. 
    
    It's the entry VU
  </description>
  <retvals>
    integer VUState  - nil if MultiChannelMetering is off, 2 if MultichannelMetering is on, 3 Metering is off
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, vu, metering, meter, multichannel, state, get, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackVUState", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackVUState", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackVUState", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
  
  -- get VU-state
  str=str:match("VU(%s.-)%c")
  -- L=str
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s"))
end

function ultraschall.GetTrackHeightState(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackHeightState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.941
    Lua=5.3
  </requires>
  <functioncall>integer height, integer heightstate2, integer unknown = ultraschall.GetTrackHeightState(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns height of the track.
    
    It's the entry TRACKHEIGHT
  </description>
  <retvals>
    integer height - 24 up to 443
    integer heightstate2 - 0 - use height, 1 - compact the track and ignore the height
    integer lock_trackheight - 0, don't lock the trackheight; 1, lock the trackheight
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, height, compact, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackHeightState", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackHeightState", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if type(str)~="string" or str:match("<TRACK.*>")==nil then 
    ultraschall.AddErrorMessage("GetTrackHeightState", "TrackStateChunk", "no valid TrackStateChunk", -3) 
    return nil 
  end
  
  -- get trackheight-state
  str=str:match("(TRACKHEIGHT%s.-)%c")
  local L=str
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s")),
         tonumber(str:match("%s.-%s(.-)%s")),
         tonumber(str:match("%s.-%s.-%s(.-)%s"))
end
    
--A,B,C=ultraschall.GetTrackHeightState(1)
    
function ultraschall.GetTrackINQState(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackINQState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer quantMIDI, integer quantPOS, integer quantNoteOffs, number quantToFractBeat, integer quantStrength, integer swingStrength, integer quantRangeMin, integer quantRangeMax =  ultraschall.GetTrackINQState(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    Gets INQ-state, mostly the quantize-settings for MIDI, as set in the "Track: View track recording settings (MIDI quantize, file format/path) for last touched track"-dialog (action 40604)
    
    It's the entry INQ
  </description>
  <retvals>
    integer quantMIDI -  quantize MIDI; 0 or 1
    integer quantPOS -  quantize to position; -1,prev; 0, nearest; 1, next
    integer quantNoteOffs -  quantize note-offs; 0 or 1
    number quantToFractBeat -  quantize to (fraction of beat)
    integer quantStrength -  quantize strength; -128 to 127
    integer swingStrength -  swing strength; -128 to 127
    integer quantRangeMin -  quantize range minimum; -128 to 127
    integer quantRangeMax -  quantize range maximum; -128 to 127
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, inq, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackINQState", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackINQState", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackINQState", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
  
  -- get INQ-state
  str=str:match("(INQ%s.-)%c")
  local L=str
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s")),
         tonumber(str:match("%s.-%s(.-)%s")),
         tonumber(str:match("%s.-%s.-%s(.-)%s")),
         tonumber(str:match("%s.-%s.-%s.-%s(.-)%s")),
         tonumber(str:match("%s.-%s.-%s.-%s.-%s(.-)%s")),
         
         tonumber(str:match("%s.-%s.-%s.-%s.-%s.-%s(.-)%s")),
         tonumber(str:match("%s.-%s.-%s.-%s.-%s.-%s.-%s(.-)%s")),
         tonumber(str:match("%s.-%s.-%s.-%s.-%s.-%s.-%s.-%s(.-)%s"))
end


function ultraschall.GetTrackNChansState(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackNChansState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer channelnumber = ultraschall.GetTrackNChansState(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns the number of channels for this track, as set in the routing.
    
    It's the entry NCHAN
  </description>
  <retvals>
    integer channelnumber  - number of channels for this track
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, channels, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackNChansState", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
    
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackNChansState", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackNChansState", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
    
  -- get Nchans-state
  str=str:match("(NCHAN%s.-)%c")
  local L=str
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s"))
end


function ultraschall.GetTrackBypFXState(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackBypFXState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer FXState = ultraschall.GetTrackBypFXState(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns the off/bypass(0) or nobypass(1) state of the FX-Chain
    
    It's the entry FX
  </description>
  <retvals>
    integer FXState - off/bypass(0) or nobypass(1)
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, bypass, fx, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackBypFXState", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackBypFXState", "tracknumber", "no such track", -2) return nil end

      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackBypFXState", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
  
  -- get bypFX-state
  str=str:match("(FX%s.-)%c")
  local L=str
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s"))
end


function ultraschall.GetTrackPerfState(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackPerfState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer TrackPerfState = ultraschall.GetTrackPerfState(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns TrackPerformance-state
    
    It's the entry PERF
  </description>
  <retvals>
    integer TrackPerfState  - TrackPerformance-state
    -0 - allow anticipative FX + allow media buffering
    -1 - allow anticipative FX + prevent media buffering 
    -2 - prevent anticipative FX + allow media buffering
    -3 - prevent anticipative FX + prevent media buffering
    -settings seem to repeat with higher numbers (e.g. 4(like 0) - allow anticipative FX + allow media buffering)
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, trackperformance, fx, buffering, media, anticipative, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackPerfState", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackPerfState", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackPerfState", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
  
  -- get perf-state
  str=str:match("(PERF%s.-)%c")
  local L=str
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s"))
end

function ultraschall.GetTrackMIDIOutState(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackMIDIOutState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer MidiOutState = ultraschall.GetTrackMIDIOutState(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns MIDI_Out-State, as set in the Routing-Settings
    
    It's the entry MIDIOUT
  </description>
  <retvals>
    integer MidiOutState  - MIDI_Out-State, as set in the Routing-Settings
    --1 no output
    -416 - microsoft GS wavetable synth - send to original channels
    -417-432 - microsoft GS wavetable synth - send to channel state minus 416
    --31 - no Output, send to original channel 1
    --16 - no Output, send to original channel 16
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, midi, outstate, routing, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackMIDIOutState", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
    
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackMIDIOutState", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackMIDIOutState", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
  
  -- get MIDIout-state
  str=str:match("(MIDIOUT%s.-)%c")
  local L=str
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s"))end


function ultraschall.GetTrackMainSendState(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackMainSendState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer MainSendOn, integer ParentChannels = ultraschall.GetTrackMainSendState(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns, if Main-Send is on(1) or off(0) and the ParentChannels(0-63), as set in the Routing-Settings.
    
    It's the entry MAINSEND
  </description>
  <retvals>
    integer MainSendOn - Main-Send is on(1) or off(0)
    integer ParentChannels - ParentChannels(0-63)
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, parent, channel, send, main, routing, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackMainSendState", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
    local tr
    if tracknumber==0 then
      tr=reaper.GetMasterTrack(0)
    else
      tr=reaper.GetTrack(0,0)
    end
    return math.floor(reaper.GetMediaTrackInfo_Value(tr, "B_MAINSEND")), math.floor(reaper.GetMediaTrackInfo_Value(tr, "C_MAINSEND_OFFS"))
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackMainSendState", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
  
  -- get mainsend-state
  str=str:match("(MAINSEND%s.-)%c")
  local L=str
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s")),
         tonumber(str:match("%s.-%s(.-)%s"))
end

--A,AA= ultraschall.GetTrackMainSendState(-1,"")

function ultraschall.GetTrackGroupFlagsState(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackGroupFlagsState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer GroupState_as_Flags, array IndividualGroupState_Flags = ultraschall.GetTrackGroupFlagsState(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns the state of the group-flags, as set in the menu Track Grouping Parameters. Returns a 23bit flagvalue as well as an array with 32 individual 23bit-flagvalues. You must use bitoperations to get the individual values.
    
    You can reach the Group-Flag-Settings in the context-menu of a track.
    
    The groups_bitfield_table contains up to 23 entries. Every entry represents one of the checkboxes in the Track grouping parameters-dialog
    
    Each entry is a bitfield, that represents the groups, in which this flag is set to checked or unchecked.
    
    So if you want to get Volume Master(table entry 1) to check if it's set in Group 1(2^0=1) and 3(2^2=4):
      group1=groups_bitfield_table[1]&1
      group2=groups_bitfield_table[1]&4
    
    The following flags(and their accompanying array-entry-index) are available:
                           1 - Volume Master
                           2 - Volume Slave
                           3 - Pan Master
                           4 - Pan Slave
                           5 - Mute Master
                           6 - Mute Slave
                           7 - Solo Master
                           8 - Solo Slave
                           9 - Record Arm Master
                           10 - Record Arm Slave
                           11 - Polarity/Phase Master
                           12 - Polarity/Phase Slave
                           13 - Automation Mode Master
                           14 - Automation Mode Slave
                           15 - Reverse Volume
                           16 - Reverse Pan
                           17 - Do not master when slaving
                           18 - Reverse Width
                           19 - Width Master
                           20 - Width Slave
                           21 - VCA Master
                           22 - VCA Slave
                           23 - VCA pre-FX slave
    
    The GroupState_as_Flags-bitfield is a hint, if a certain flag is set in any of the groups. So, if you want to know, if VCA Master is set in any group, check if flag &1048576 (2^20) is set to 1048576.
    
    This function will work only for Groups 1 to 32. To get Groups 33 to 64, use <a href="#GetTrackGroupFlags_HighState">GetTrackGroupFlags_HighState</a> instead!
    
    It's the entry GROUP_FLAGS
    
    returns -1 in case of failure
  </description>
  <retvals>
    integer GroupState_as_Flags - returns a flagvalue with 23 bits, that tells you, which grouping-flag is set in at least one of the 32 groups available.
    -returns -1 in case of failure
    -
    -the following flags are available:
    -2^0 - Volume Master
    -2^1 - Volume Slave
    -2^2 - Pan Master
    -2^3 - Pan Slave
    -2^4 - Mute Master
    -2^5 - Mute Slave
    -2^6 - Solo Master
    -2^7 - Solo Slave
    -2^8 - Record Arm Master
    -2^9 - Record Arm Slave
    -2^10 - Polarity/Phase Master
    -2^11 - Polarity/Phase Slave
    -2^12 - Automation Mode Master
    -2^13 - Automation Mode Slave
    -2^14 - Reverse Volume
    -2^15 - Reverse Pan
    -2^16 - Do not master when slaving
    -2^17 - Reverse Width
    -2^18 - Width Master
    -2^19 - Width Slave
    -2^20 - VCA Master
    -2^21 - VCA Slave
    -2^22 - VCA pre-FX slave
    
     array IndividualGroupState_Flags  - returns an array with 23 entries. Every entry represents one of the GroupState_as_Flags, but it's value is a flag, that describes, in which of the 32 Groups a certain flag is set.
    -e.g. If Volume Master is set only in Group 1, entry 1 in the array will be set to 1. If Volume Master is set on Group 2 and Group 4, the first entry in the array will be set to 10.
    -refer to the upper GroupState_as_Flags list to see, which entry in the array is for which set flag, e.g. array[22] is VCA pre-F slave, array[16] is Do not master when slaving, etc
    -As said before, the values in each entry is a flag, that tells you, which of the groups is set with a certain flag. The following flags determine, in which group a certain flag is set:
    -2^0 - Group 1
    -2^1 - Group 2
    -2^2 - Group 3
    -2^3 - Group 4
    -...
    -2^30 - Group 31
    -2^31 - Group 32
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, group, groupstate, individual, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackGroupFlagsState", "tracknumber", "must be an integer", -1) return -1 end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackGroupFlagsState", "tracknumber", "no such track", -2) return -1 end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if ultraschall.IsValidTrackStateChunk(str)==false then ultraschall.AddErrorMessage("GetTrackGroupFlagsState", "TrackStateChunk", "no valid TrackStateChunk", -3) return -1 end    
  local retval=0

  local Track_TrackGroupFlags=str:match("GROUP_FLAGS.-%c") 
  if Track_TrackGroupFlags==nil then ultraschall.AddErrorMessage("GetTrackGroupFlagsState", "", "no trackgroupflags available", -4) return -1 end
  
  -- get groupflags-state  
  local GroupflagString= Track_TrackGroupFlags:match("GROUP_FLAGS (.-)%c")
  local count, Tracktable=ultraschall.CSV2IndividualLinesAsArray(GroupflagString, " ")

  for i=1,23 do
    Tracktable[i]=tonumber(Tracktable[i])
    if Tracktable[i]~=nil and Tracktable[i]>=1 then retval=retval+2^(i-1) end
  end
  
  return retval, Tracktable
end

function ultraschall.GetTrackGroupFlags_HighState(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackGroupFlags_HighState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.941
    Lua=5.3
  </requires>
  <functioncall>integer GroupState_as_Flags, array IndividualGroupState_Flags = ultraschall.GetTrackGroupFlags_HighState(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns the state of the group-flags, as set in the menu Track Grouping Parameters. Returns a 23bit flagvalue as well as an array with 32 individual 23bit-flagvalues. You must use bitoperations to get the individual values.
    
    You can reach the Group-Flag-Settings in the context-menu of a track.
    
    The groups_bitfield_table contains up to 23 entries. Every entry represents one of the checkboxes in the Track grouping parameters-dialog
    
    Each entry is a bitfield, that represents the groups, in which this flag is set to checked or unchecked.
    
    So if you want to get Volume Master(table entry 1) to check if it's set in Group 33(2^0=1) and 35(2^2=4):
      group1=groups_bitfield_table[1]&1
      group2=groups_bitfield_table[1]&4
    
    The following flags(and their accompanying array-entry-index) are available:
                           1 - Volume Master
                           2 - Volume Slave
                           3 - Pan Master
                           4 - Pan Slave
                           5 - Mute Master
                           6 - Mute Slave
                           7 - Solo Master
                           8 - Solo Slave
                           9 - Record Arm Master
                           10 - Record Arm Slave
                           11 - Polarity/Phase Master
                           12 - Polarity/Phase Slave
                           13 - Automation Mode Master
                           14 - Automation Mode Slave
                           15 - Reverse Volume
                           16 - Reverse Pan
                           17 - Do not master when slaving
                           18 - Reverse Width
                           19 - Width Master
                           20 - Width Slave
                           21 - VCA Master
                           22 - VCA Slave
                           23 - VCA pre-FX slave
    
    The GroupState_as_Flags-bitfield is a hint, if a certain flag is set in any of the groups. So, if you want to know, if VCA Master is set in any group, check if flag &1048576 (2^20) is set to 1048576.
    
    This function will work only for Groups 33(2^0) to 64(2^31). To get Groups 1 to 32, use <a href="#GetTrackGroupFlagsState">GetTrackGroupFlagsState</a> instead!
    
    It's the entry GROUP_FLAGS_HIGH
    
    returns -1 in case of failure
  </description>
  <retvals>
    integer GroupState_as_Flags - returns a flagvalue with 23 bits, that tells you, which grouping-flag is set in at least one of the 32 groups available.
    -returns -1 in case of failure
    -
    -the following flags are available:
    -2^0 - Volume Master
    -2^1 - Volume Slave
    -2^2 - Pan Master
    -2^3 - Pan Slave
    -2^4 - Mute Master
    -2^5 - Mute Slave
    -2^6 - Solo Master
    -2^7 - Solo Slave
    -2^8 - Record Arm Master
    -2^9 - Record Arm Slave
    -2^10 - Polarity/Phase Master
    -2^11 - Polarity/Phase Slave
    -2^12 - Automation Mode Master
    -2^13 - Automation Mode Slave
    -2^14 - Reverse Volume
    -2^15 - Reverse Pan
    -2^16 - Do not master when slaving
    -2^17 - Reverse Width
    -2^18 - Width Master
    -2^19 - Width Slave
    -2^20 - VCA Master
    -2^21 - VCA Slave
    -2^22 - VCA pre-FX slave
    
     array IndividualGroupState_Flags  - returns an array with 23 entries. Every entry represents one of the GroupState_as_Flags, but it's value is a flag, that describes, in which of the 32 Groups a certain flag is set.
    -e.g. If Volume Master is set only in Group 33, entry 1 in the array will be set to 1. If Volume Master is set on Group 34 and Group 36, the first entry in the array will be set to 10.
    -refer to the upper GroupState_as_Flags list to see, which entry in the array is for which set flag, e.g. array[22] is VCA pre-F slave, array[16] is Do not master when slaving, etc
    -As said before, the values in each entry is a flag, that tells you, which of the groups is set with a certain flag. The following flags determine, in which group a certain flag is set:
    -2^0 - Group 33
    -2^1 - Group 34
    -2^2 - Group 35
    -2^3 - Group 36
    -...
    -2^30 - Group 63
    -2^31 - Group 64
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, group, groupstate, individual, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackGroupFlags_HighState", "tracknumber", "must be an integer", -1) return -1 end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackGroupFlags_HighState", "tracknumber", "no such track", -2) return -1 end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if ultraschall.IsValidTrackStateChunk(str)==false then ultraschall.AddErrorMessage("GetTrackGroupFlags_HighState", "TrackStateChunk", "no valid TrackStateChunk", -3) return -1 end
    
  local retval=0
  local Track_TrackGroupFlags=str:match("GROUP_FLAGS_HIGH.-%c") 
  if Track_TrackGroupFlags==nil then ultraschall.AddErrorMessage("GetTrackGroupFlags_HighState", "", "no trackgroupflags available", -4) return -1 end
  
  -- get groupflags-state  
  local GroupflagString= Track_TrackGroupFlags:match("GROUP_FLAGS_HIGH (.-)%c")
  local count, Tracktable=ultraschall.CSV2IndividualLinesAsArray(GroupflagString, " ")

  for i=1,23 do
    Tracktable[i]=tonumber(Tracktable[i])
    if Tracktable[i]~=nil and Tracktable[i]>=1 then retval=retval+2^(i-1) end
  end
  
  return retval, Tracktable
end

function ultraschall.GetTrackLockState(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackLockState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer lockedstate = ultraschall.GetTrackLockState(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns, if the track-controls of this track are locked(1) or not(nil).
    
    It's the entry LOCK
    Only the LOCK within TrackStateChunks, but not MediaItemStateChunks
  </description>
  <retvals>
    integer lockedstate  - locked(1) or not(nil)
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, lockstate, locked, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackLockState", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackLockState", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackLockState", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end

  -- get lock-state  
  str=str:match("(LOCK%s.-)%c")
  local L=str
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s"))
end


function ultraschall.GetTrackLayoutNames(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackLayoutNames</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string TCP_Layoutname, string MCP_Layoutname = ultraschall.GetTrackLayoutNames(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns the current selected layouts for TrackControlPanel and MixerControlPanel for this track as strings. Returns nil, if default is set.
    
    It's the entry LAYOUTS
  </description>
  <retvals>
    string TCP_Layoutname - name of the TCP-Layoutname
    string MCP_Layoutname  - name of the MCP-Layoutname
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, theme, layout, name, mcp, tcp, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackLayoutNames", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackLayoutNames", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackLayoutNames", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end

  -- get layout-names
  local Track_LayoutTCP
  local Track_LayoutMCP
  
  str=str:match("(LAYOUTS%s.-)%c")
  if str==nil then return "","" end
  str=str.." "
  local L=str
  if str~=nil then str=str.." " else return nil end
  Track_LayoutTCP, offset1 = str:match("%s\"(.-)\"%s()")
  if Track_LayoutTCP==nil then Track_LayoutTCP, offset = str:match("%s(.-)%s()") str=str:sub(offset, -1) else str=str:sub(offset1, -1) end
  Track_LayoutMCP = str:match("\"(.-)\"%s")
  if Track_LayoutMCP==nil then Track_LayoutMCP = str:match("(.-)%s") end  

  return Track_LayoutTCP, Track_LayoutMCP
end


function ultraschall.GetTrackAutomodeState(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackAutomodeState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer automodestate = ultraschall.GetTrackAutomodeState(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns, if the automation-mode for envelopes of this track
    
    It's the entry AUTOMODE
  </description>
  <retvals>
    integer automodestate  - is set to 0 - trim/read, 1 - read, 2 - touch, 3 - write, 4 - latch.
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, automode, envelopes, automation, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackAutomodeState", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackAutomodeState", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackAutomodeState", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
  
  -- get automode-state
  str=str:match("(AUTOMODE%s.-)%c")
  local L=str
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s"))
end

function ultraschall.GetTrackIcon_Filename(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackIcon_Filename</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string filename_with_path = ultraschall.GetTrackIcon_Filename(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns the filename with path for the track-icon of the current track. Returns nil, if no trackicon has been set.
    
    It's the entry TRACKIMGFN
  </description>
  <retvals>
    string filename_with_path  - filename with path for the current track-icon.
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, graphics, image, icon, trackicon, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackIcon_Filename", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackIcon_Filename", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackIcon_Filename", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
    
  -- get trackicon-filename
  local Track_Image=str:match("TRACKIMGFN.-%c")
  if Track_Image~=nil then Track_Image=Track_Image:sub(13,-3)
  end
  return Track_Image
end

function ultraschall.GetTrackRecCFG(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackRecCFG</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string reccfg = ultraschall.GetTrackRecCFG(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns the Rec-configuration-string, with which recordings are made. Returns nil, if no reccfg exists.
    
    It's the entry <RECCFG
  </description>
  <retvals>
    string reccfg - the string, that encodes the recording configuration of the track.
    integer reccfgnr - the number of the recording-configuration of the track; 
                     - 0, use default project rec-setting
                     - 1, use track-customized rec-setting, as set in the "Track: View track recording settings (MIDI quantize, file format/path) for last touched track"-dialog (action 40604)
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, reccfg, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackRecCFG", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackRecCFG", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackRecCFG", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end

  -- get reccfg
  local RECCFGNR=str:match("<RECCFG (.-)%c")
  if RECCFGNR==nil then return nil end
  local RECCFG=str:match("<RECCFG.-%c(.-)%c")
  
  return RECCFG, tonumber(RECCFGNR)
end

function ultraschall.GetTrackMidiInputChanMap(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackMidiInputChanMap</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer MidiInputChanMap_state = ultraschall.GetTrackMidiInputChanMap(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns the state of the MIDIInputChanMap for the current track, as set in the Input-MIDI->Map Input to Channel menu. 0 for channel 1, 2 for channel 2, etc. Nil, if not existing.
    
    It's the entry MIDI_INPUT_CHANMAP
  </description>
  <retvals>
    integer MidiInputChanMap_state  - 0 for channel 1, 1 for channel 2, ... 15 for channel 16; nil, source channel.
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, midi, input, chanmap, channelmap, channel, mapping, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackMidiInputChanMap", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackMidiInputChanMap", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackMidiInputChanMap", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
  
  -- get midi-input-chanmap
  local Track_MidiChanMap=str:match("MIDI_INPUT_CHANMAP (.-)%c")
  return tonumber(Track_MidiChanMap)
end

function ultraschall.GetTrackMidiCTL(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackMidiCTL</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer LinkedToMidiChannel, integer unknown = ultraschall.GetTrackMidiCTL(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns linked to Midi channel and an unknown value. Nil if not existing.
    
    It's the entry MIDICTL
  </description>
  <retvals>
    integer LinkedToMidiChannel - linked to midichannel
    integer unknown  - unknown
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, midi, channel, linked, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackMidiCTL", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackMidiCTL", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackMidiCTL", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
    
  -- get midi ctl
  str=str:match("(MIDICTL%s.-)%c")
  local L=str
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s")),
         tonumber(str:match("%s.-%s(.-)%s"))
end

function ultraschall.GetTrackWidth(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackWidth</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>number width = ultraschall.GetTrackWidth(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns width of the track. 1 if set to +100%. 
    
    Note for TrackStateChunk-enthusiasts: When set to +100%, it is not stored in the TrackStateChunk
    
    It's the entry WIDTH
  </description>
  <retvals>
    number width - width of the track, from -1(-100%) to 1(+100%)
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, width, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackWidth", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackWidth", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackWidth", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
    
  -- get widtch-state
  str=str:match("(WIDTH%s.-)%c")
  local L=str
  if str==nil then return 1 end
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s"))
end

function ultraschall.GetTrackPanMode(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackPanMode</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer PanMode = ultraschall.GetTrackPanMode(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns Panmode of the track.
    
    It's the entry PANMODE
  </description>
  <retvals>
    integer PanMode - the Panmode of the track
    - nil - Project Default
    - 0 - Reaper 3.x balance (deprecated)
    - 3 - Stereo Balance/ Mono Pan(Default)
    - 5 - Stereo Balance
    - 6 - Dual Pan
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, panmode, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackPanMode", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then

    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackPanMode", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackPanMode", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
    
  -- get panmode-state
  str=str:match("(PANMODE%s.-)%c")
  local L=str
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s"))
end

function ultraschall.GetTrackMidiColorMapFn(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackMidiColorMapFn</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string MidiColorMapFn = ultraschall.GetTrackMidiColorMapFn(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns MidiColorMap-Filename of the track. Nil if not existing.
    
    It's the entry MIDICOLORMAPFN
  </description>
  <retvals>
    string MidiColorMapFn - the MidiColorMap-Filename; nil if not existing
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, midicolormap, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackMidiColorMapFn", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackMidiColorMapFn", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackMidiColorMapFn", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
    
  -- get midicolormap-filename
  local Track_MIDICOLORMAPFN=str:match("MIDICOLORMAPFN (.-)%c")
  return Track_MIDICOLORMAPFN
end

function ultraschall.GetTrackMidiBankProgFn(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackMidiBankProgFn</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string MidiBankProgFn = ultraschall.GetTrackMidiBankProgFn(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns MidiBankProg-Filename of the track. Nil if not existing.
    
    It's the entry MIDIBANKPROGFN
  </description>
  <retvals>
    string MidiBankProgFn - the MidiBankProg-Filename; nil if not existing
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, midibankprog, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackMidiBankProgFn", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackMidiBankProgFn", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackMidiBankProgFn", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
    
  -- get midibank-prog-filename
  local Track_MIDIBANKPROGFN=str:match("MIDIBANKPROGFN (.-)%c")
  return Track_MIDIBANKPROGFN
end



function ultraschall.GetTrackMidiTextStrFn(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackMidiTextStrFn</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string MidiTextStrFn = ultraschall.GetTrackMidiTextStrFn(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns MidiTextStrFn-Filename of the track. Nil if not existing.
    
    It's the entry MIDIEXTSTRFN
  </description>
  <retvals>
    string MidiTextStrFn - the MidiTextStrFn-Filename; nil if not existing
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, MidiTextStrFn, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackMidiTextStrFn", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackMidiTextStrFn", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackMidiTextStrFn", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
    
  -- get midi-text-str-filename
  local Track_MIDITEXTSTRFN=str:match("MIDITEXTSTRFN (.-)%c")
  return Track_MIDITEXTSTRFN
end


function ultraschall.GetTrackID(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackID</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string TrackID = ultraschall.GetTrackID(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns TrackID of the track.
    
    It's the entry TRACKID
  </description>
  <retvals>
    string TrackID - the TrackID as GUID
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, trackid, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackID", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackID", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackID", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
    
  --get track-id
  local Track_TRACKID=str:match("TRACKID (.-)%c")
  return Track_TRACKID
end

function ultraschall.GetTrackScore(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackScore</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer Score1, integer Score2, number Score3, number Score4  = ultraschall.GetTrackScore(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns Score of the track.
    
    It's the entry SCORE
  </description>
  <retvals>
    integer Score1 - unknown 
    integer Score2 - unknown
    number Score3 - unknown
    number Score4 - unknown
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, get, score, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackScore", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackScore", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackScore", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
    
  -- get score
  str=str:match("(SCORE%s.-)%c")
  local L=str
  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s")),
         tonumber(str:match("%s.-%s(.-)%s")),
         tonumber(str:match("%s.-%s.-%s(.-)%s")),
         tonumber(str:match("%s.-%s.-%s.-%s(.-)%s"))
end

function ultraschall.GetTrackVolPan(tracknumber, str)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackVolPan</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>number Vol, number Pan, number OverridePanLaw, number unknown, number unknown2 = ultraschall.GetTrackVolPan(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    returns Vol and Pan-states of the track.
    
    It's the entry VOLPAN
  </description>
  <retvals>
    number Vol - Volume Settings
    - -Inf dB(0) to +12dB (3.98107170553497)
    number Pan - Pan Settings
    - -1(-100%); 0(center); 1(100% R)
    number OverridePanLaw - Override Default Pan Track Law
    - 0dB(1) to -144dB(0.00000006309573)
    number unknown - unknown
    number unknown2 - unknown
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master track; -1, if you want to use the parameter TrackStateChunk instead.
    optional string TrackStateChunk - a TrackStateChunk that you want to use, instead of a given track
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, get, vol, pan, override, panlaw, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackVolPan", "tracknumber", "must be an integer", -1) return nil end
  if tracknumber~=-1 then
  
    -- get trackstatechunk
    local retval, MediaTrack
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackVolPan", "tracknumber", "no such track", -2) return nil end
      if tracknumber==0 then MediaTrack=reaper.GetMasterTrack(0)
      else MediaTrack=reaper.GetTrack(0, tracknumber-1)
      end
      retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "test", false)
  else
  end
  if str==nil or str:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetTrackVolPan", "TrackStateChunk", "no valid TrackStateChunk", -3) return nil end
    
  -- get track-vol-pan-state
  str=str:match("(VOLPAN%s.-)%c")

  if str~=nil then str=str.." " else return nil end
  return tonumber(str:match("%s(.-)%s")),
         tonumber(str:match("%s.-%s(.-)%s")),
         tonumber(str:match("%s.-%s.-%s(.-)%s")),
         tonumber(str:match("%s.-%s.-%s.-%s(.-)%s")),
         tonumber(str:match("%s.-%s.-%s.-%s.-%s(.-)%s"))
end

--------------------------
---- Set Track States ----
--------------------------

function ultraschall.SetTrackName(tracknumber, name, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackName</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackName(integer tracknumber, string name, optional string TrackStateChunk)</functioncall>
  <description>
    Set the name of a track or a trackstatechunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    string name - new name of the track
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, name, set, state, track, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackName", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackName", "tracknumber", "no such track in the project", -2) return false end
  if type(name)~="string" then ultraschall.AddErrorMessage("SetTrackName", "name", "must be a string", -3) return false end
  
  -- create state-entry
  local str="NAME \""..name.."\""
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackName", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state from trackstatechunk
  local B1=AA:match("(.-)NAME")
  local B3=AA:match("NAME.-%c(.*)")

  -- set trackstatechunk and include new-state
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end
  return B, B1.."\n"..str.."\n"..B3
end

function ultraschall.SetTrackPeakColorState(tracknumber, colorvalue, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackPeakColorState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackPeakColorState(integer tracknumber, integer colorvalue, optional string TrackStateChunk)</functioncall>
  <description>
    Set the color of the track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    integer colorvalue - the color for the track
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, color, state, set, track, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackPeakColorState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackPeakColorState", "tracknumber", "no such track in the project", -2) return false end
  if math.type(colorvalue)~="integer" then ultraschall.AddErrorMessage("SetTrackPeakColorState", "colorvalue", "must be an integer", -3) return false end
  
  if colorvalue<0 then ultraschall.AddErrorMessage("SetTrackPeakColorState", "colorvalue", "must be positive value", -4) return false end
  
  -- create state-entry
  local str="PEAKCOL "..colorvalue
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackPeakColorState", "TrackStateChunk", "must be a string", -5) return false end
    AA=TrackStateChunk
  end      
  
  -- remove old state from trackstatechunk
  local B1=AA:match("(.-)PEAKCOL")
  local B3=AA:match("PEAKCOL.-%c(.*)")
  
  -- set trackstatechunk and include new-state
  if tracknumber~=-1 then
    local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end

  return B, B1.."\n"..str.."\n"..B3
end


function ultraschall.SetTrackBeatState(tracknumber, beatstate, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackBeatState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackBeatState(integer tracknumber, integer beatstate, optional string TrackStateChunk)</functioncall>
  <description>
    Set the timebase for a track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    integer beatstate - tracktimebase for this track; -1 - Project time base, 0 - Time, 1 - Beats position, length, rate, 2 - Beats position only
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, beat, state, set, track, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackBeatState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackBeatState", "tracknumber", "no such track in the project", -2) return false end
  if math.type(beatstate)~="integer" then ultraschall.AddErrorMessage("SetTrackBeatState", "beatstate", "must be an integer", -3) return false end
  
  -- create state-entry
  local str="BEAT "..beatstate
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackBeatState", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state from trackstatechunk
  local B1=AA:match("(.-)BEAT")
  local B3=AA:match("BEAT.-%c(.*)")
  
  -- set trackstatechunk and include new-state
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end

  return B, B1.."\n"..str.."\n"..B3
end

function ultraschall.SetTrackAutoRecArmState(tracknumber, autorecarmstate, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackAutoRecArmState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackAutoRecArmState(integer tracknumber, integer autorecarmstate, optional string TrackStateChunk)</functioncall>
  <description>
    Set the AutoRecArmState for a track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    integer autorecarmstate - autorecarmstate - 1 - autorecarm on, <> than 1 - off
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, autorecarm, rec, arm, track, set, state, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackAutoRecArmState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackAutoRecArmState", "tracknumber", "no such track in the project", -2) return false end
  if math.type(autorecarmstate)~="integer" then ultraschall.AddErrorMessage("SetTrackAutoRecArmState", "autorecarmstate", "must be an integer", -3) return false end
  
  local str=""
  
  -- create state-entry
  if autorecarmstate==1 then str="AUTO_RECARM "..autorecarmstate end
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackAutoRecArmState", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state from trackstatechunk
  local B1=AA:match("(.-)AUTO_RECARM")
  local B3=AA:match("AUTO_RECARM.-%c(.*)")
  
  -- set trackstatechunk and include new-state
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end  
  return B, B1.."\n"..str.."\n"..B3
end

function ultraschall.SetTrackMuteSoloState(tracknumber, Mute, Solo, SoloDefeat, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackMuteSoloState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackMuteSoloState(integer tracknumber, integer Mute, integer Solo, integer SoloDefeat, optional string TrackStateChunk)</functioncall>
  <description>
    Set the Track Mute/Solo/Solodefeat for a track or a TrackStateChunk.
    Has no real effect on master track.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    integer Mute - Mute set to 0 - Mute off, 1 - Mute On
    integer Solo - Solo set to 0 - Solo off, 1 - Solo ignore routing, 2 - Solo on
    integer SoloDefeat - SoloDefeat set to 0 - off, 1 - on
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, state, mute, solo, solo defeat, trackstatechunk</tags>
</US_DocBloc>
--]]

  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackMuteSoloState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackMuteSoloState", "tracknumber", "no such track in the project", -2) return false end
  if math.type(Mute)~="integer" then ultraschall.AddErrorMessage("SetTrackMuteSoloState", "Mute", "must be an integer", -3) return false end
  if math.type(Solo)~="integer" then ultraschall.AddErrorMessage("SetTrackMuteSoloState", "Solo", "must be an integer", -4) return false end
  if math.type(SoloDefeat)~="integer" then ultraschall.AddErrorMessage("SetTrackMuteSoloState", "SoloDefeat", "must be an integer", -5) return false end
  
  -- create state-entry
  local str="MUTESOLO "..Mute.." "..Solo.." "..SoloDefeat
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackMuteSoloState", "TrackStateChunk", "must be a string", -6) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state from trackstatechunk
  local B1=AA:match("(.-)MUTESOLO")
  local B3=AA:match("MUTESOLO.-%c(.*)")
  
  -- set trackstatechunk and include new-state
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end
  return B, B1.."\n"..str.."\n"..B3
end


function ultraschall.SetTrackIPhaseState(tracknumber, iphasestate, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackIPhaseState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackIPhaseState(integer tracknumber, integer iphasestate, optional string TrackStateChunk)</functioncall>
  <description>
    Sets IPhase, the Phase-Buttonstate of the track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    integer iphasestate - 0-off, &lt;&gt; than 0-on
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, set, track, state, iphase, phase, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackIPhaseState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackIPhaseState", "tracknumber", "no such track in the project", -2) return false end
  if math.type(iphasestate)~="integer" then ultraschall.AddErrorMessage("SetTrackIPhaseState", "iphasestate", "must be an integer", -3) return false end

  -- create state-entry
  local str="IPHASE "..iphasestate
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackIPhaseState", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state from trackstatechunk
  local B1=AA:match("(.-)IPHASE")
  local B3=AA:match("IPHASE.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  -- set trackstatechunk and include new-state
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end

  return B, B1.."\n"..str.."\n"..B3
end


function ultraschall.SetTrackIsBusState(tracknumber, busstate1, busstate2, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackIsBusState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackIsBusState(integer tracknumber, integer busstate1, integer busstate2, optional string TrackStateChunk)</functioncall>
  <description>
    Sets ISBUS-state of the track or a TrackStateChunk; if it's a folder track.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; -1 if you want to use parameter TrackStateChunk
    integer busstate1=0, integer busstate2=0 - track is no folder
    integer busstate1=1, integer busstate2=1 - track is a folder
    integer busstate1=1, integer busstate2=2 - track is a folder but view of all subtracks not compactible
    integer busstate1=2, integer busstate2=-1 - track is last track in folder(no tracks of subfolders follow)
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, state, busstate, folder, subfolder, compactible, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackIsBusState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber==0 or tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackIsBusState", "tracknumber", "no such track in the project", -2) return false end
  if math.type(busstate1)~="integer" then ultraschall.AddErrorMessage("SetTrackIsBusState", "busstate1", "must be an integer", -3) return false end
  if math.type(busstate2)~="integer" then ultraschall.AddErrorMessage("SetTrackIsBusState", "busstate2", "must be an integer", -4) return false end
  
  -- create state-entry
  local str="ISBUS "..busstate1.." "..busstate2

  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    Mediatrack=reaper.GetTrack(0,tracknumber-1)
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackIsBusState", "TrackStateChunk", "must be a string", -5) return false end
    AA=TrackStateChunk
  end  

  -- remove old state from trackstatechunk
  local B1=AA:match("(.-)ISBUS")
  local B3=AA:match("ISBUS.-%c(.*)")
  
  -- set trackstatechunk and include new-state
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end

  return B, B1.."\n"..str.."\n"..B3
end

function ultraschall.SetTrackBusCompState(tracknumber, buscompstate1, buscompstate2, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackBusCompState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackBusCompState(integer tracknumber, integer buscompstate1, integer buscompstate2, optional string TrackStateChunk)</functioncall>
  <description>
    Sets BUSCOMP-state of the track or a TrackStateChunk; This is the state, if tracks in a folder are compacted or not.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; -1 if you want to use parameter TrackStateChunk
    integer - buscompstate1 - 0 - no compacting, 1 - compacted tracks, 2 - minimized tracks
    integer - buscompstate2 - 0 - unknown, 1 - unknown
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, state, compacting, busstate, folder, minimize, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackBusCompState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber==0 or tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackBusCompState", "tracknumber", "no such track in the project", -2) return false end
  if math.type(buscompstate1)~="integer" then ultraschall.AddErrorMessage("SetTrackBusCompState", "buscompstate1", "must be an integer", -3) return false end
  if math.type(buscompstate2)~="integer" then ultraschall.AddErrorMessage("SetTrackBusCompState", "buscompstate2", "must be an integer", -4) return false end
  
  -- create state-entry
  local str="BUSCOMP "..buscompstate1.." "..buscompstate2
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    Mediatrack=reaper.GetTrack(0,tracknumber-1)
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackBusCompState", "TrackStateChunk", "must be a string", -5) return false end
    AA=TrackStateChunk
  end

  -- remove old state from trackstatechunk
  local B1=AA:match("(.-)BUSCOMP")
  local B3=AA:match("BUSCOMP.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  -- set trackstatechunk and include new-state
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end

  return B, B1.."\n"..str.."\n"..B3
end

function ultraschall.SetTrackShowInMixState(tracknumber, MCPvisible, MCP_FX_visible, MCP_TrackSendsVisible, TCPvisible, ShowInMix5, ShowInMix6, ShowInMix7, ShowInMix8, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackShowInMixState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackShowInMixState(integer tracknumber, integer MCPvisible, number MCP_FX_visible, number MCP_TrackSendsVisible, integer TCPvisible, number ShowInMix5, integer ShowInMix6, integer ShowInMix7, integer ShowInMix8, optional string TrackStateChunk)</functioncall>
  <description>
    Sets SHOWINMIX, that sets visibility of track or TrackStateChunk in MCP and TCP.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    integer MCPvisible - 0 invisible, 1 visible
    number MCP_FX_visible - 0 visible, 1 FX-Parameters visible, 2 invisible
    number MCPTrackSendsVisible - 0 & 1.1 and higher TrackSends in MCP visible, every other number makes them invisible
    integer TCPvisible - 0 track is invisible in TCP, 1 track is visible in TCP
    - with Master-Track, 1 shows all active envelopes, 0 hides all active envelopes
    number ShowInMix5 - unknown
    integer ShowInMix6 - unknown
    integer ShowInMix7 - unknown
    integer ShowInMix8 - unknown
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, state, set, show in mix, mcp, fx, tcp, trackstatechunk</tags>
</US_DocBloc>
--]]

  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackShowInMixState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackShowInMixState", "tracknumber", "no such track in the project", -2) return false end
  if math.type(MCPvisible)~="integer" then ultraschall.AddErrorMessage("SetTrackShowInMixState", "MCPvisible", "must be an integer", -3) return false end
  if type(MCP_FX_visible)~="number" then ultraschall.AddErrorMessage("SetTrackShowInMixState", "MCP_FX_visible", "must be a number", -4) return false end
  if type(MCP_TrackSendsVisible)~="number" then ultraschall.AddErrorMessage("SetTrackShowInMixState", "MCP_TrackSendsVisible", "must be a number", -5) return false end
  if math.type(TCPvisible)~="integer" then ultraschall.AddErrorMessage("SetTrackShowInMixState", "TCPvisible", "must be an integer", -6) return false end
  if type(ShowInMix5)~="number" then ultraschall.AddErrorMessage("SetTrackShowInMixState", "ShowInMix5", "must be a number", -7) return false end
  if math.type(ShowInMix6)~="integer" then ultraschall.AddErrorMessage("SetTrackShowInMixState", "ShowInMix6", "must be an integer", -8) return false end
  if math.type(ShowInMix7)~="integer" then ultraschall.AddErrorMessage("SetTrackShowInMixState", "ShowInMix7", "must be an integer", -9) return false end
  if math.type(ShowInMix8)~="integer" then ultraschall.AddErrorMessage("SetTrackShowInMixState", "ShowInMix8", "must be an integer", -10) return false end
  
  -- create state-entry
  local str="SHOWINMIX "..MCP_FX_visible.." "..MCP_FX_visible.." "..MCP_TrackSendsVisible.." "..TCPvisible.." "..ShowInMix5.." "..ShowInMix6.." "..ShowInMix7.." "..ShowInMix8

  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackShowInMixState", "TrackStateChunk", "must be a string", -11) return false end
    AA=TrackStateChunk
  end

  -- remove old state from trackstatechunk
  local B1=AA:match("(.-)SHOWINMIX")
  local B3=AA:match("SHOWINMIX.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end
  
  -- set trackstatechunk and include new-state
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end

  return B, B1.."\n"..str.."\n"..B3
end

function ultraschall.SetTrackFreeModeState(tracknumber, freemodestate, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackFreeModeState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackFreeModeState(integer tracknumber, integer freemodestate, optional string TrackStateChunk)</functioncall>
  <description>
    Sets FREEMODE-state of a track or a TrackStateChunk; enables Track-Free Item Positioning.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; -1 if you want to use parameter TrackStateChunk
    integer freemodestate - 0 - off, 1 - on
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, state, trackfree, item, positioning, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackFreeModeState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackFreeModeState", "tracknumber", "no such track in the project", -2) return false end
  if math.type(freemodestate)~="integer" then ultraschall.AddErrorMessage("SetTrackFreeModeState", "freemodestate", "must be an integer", -3) return false end

  -- create state-entry
  local str="FREEMODE "..freemodestate

  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackFreeModeState", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end

  -- remove old state from trackstatechunk
  local B1=AA:match("(.-)FREEMODE")
  local B3=AA:match("FREEMODE.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  -- set trackstatechunk and include new-state
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end

  return B, B1.."\n"..str.."\n"..B3
end

function ultraschall.SetTrackRecState(tracknumber, ArmState, InputChannel, MonitorInput, RecInput, MonitorWhileRec, presPDCdelay, RecordingPath, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackRecState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackRecState(integer tracknumber, integer ArmState, integer InputChannel, integer MonitorInput, integer RecInput, integer MonitorWhileRec, integer presPDCdelay, integer RecordingPath, optional string TrackStateChunk)</functioncall>
  <description>
    Sets REC, that sets the Recording-state of the track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    integer ArmState - set to 1(armed) or 0(unarmed)
    
    integer InputChannel - the InputChannel
    --1 - No Input
    -1-16(more?) - Mono Input Channel
    -1024 - Stereo Channel 1 and 2
    -1026 - Stereo Channel 3 and 4
    -1028 - Stereo Channel 5 and 6
    -...
    -5056 - Virtual MIDI Keyboard all Channels
    -5057 - Virtual MIDI Keyboard Channel 1
    -...
    -5072 - Virtual MIDI Keyboard Channel 16
    -5088 - All MIDI Inputs - All Channels
    -5089 - All MIDI Inputs - Channel 1
    -...
    -5104 - All MIDI Inputs - Channel 16
    
    integer Monitor Input - 0 monitor off, 1 monitor on, 2 monitor on tape audio style
    
    integer RecInput - the rec-input type
    -0 input(Audio or Midi)
    -1 Record Output Stereo
    -2 Disabled, Input Monitoring Only
    -3 Record Output Stereo, Latency Compensated
    -4 Record Output MIDI
    -5 Record Output Mono
    -6 Record Output Mono, Latency Compensated
    -7 MIDI overdub
    -8 MIDI replace
    -9 MIDI touch replace
    -10 Record Output Multichannel
    -11 Record Output Multichannel, Latency Compensated 
    -12 Record Input Force Mono
    -13 Record Input Force Stereo
    -14 Record Input Force Multichannel
    -15 Record Input Force MIDI
    -16 MIDI latch replace
    
    integer MonitorWhileRec - Monitor Trackmedia when recording, 0 is off, 1 is on
    
    integer presPDCdelay - preserve PDC delayed monitoring in media items
    
    integer RecordingPath - 0 Primary Recording-Path only, 1 Secondary Recording-Path only, 2 Primary Recording Path and Secondary Recording Path(for invisible backup)
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, armstate, inputchannel, monitorinput, recinput, monitorwhilerec, pdc, recordingpath, midi, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackRecState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackRecState", "tracknumber", "no such track in the project", -2) return false end
  if math.type(ArmState)~="integer" then ultraschall.AddErrorMessage("SetTrackRecState", "ArmState", "must be an integer", -3) return false end
  if math.type(InputChannel)~="integer" then ultraschall.AddErrorMessage("SetTrackRecState", "InputChannel", "must be an integer", -4) return false end
  if math.type(MonitorInput)~="integer" then ultraschall.AddErrorMessage("SetTrackRecState", "MonitorInput", "must be an integer", -5) return false end
  if math.type(RecInput)~="integer" then ultraschall.AddErrorMessage("SetTrackRecState", "RecInput", "must be an integer", -6) return false end
  if math.type(MonitorWhileRec)~="integer" then ultraschall.AddErrorMessage("SetTrackRecState", "MonitorWhileRec", "must be an integer", -7) return false end
  if math.type(presPDCdelay)~="integer" then ultraschall.AddErrorMessage("SetTrackRecState", "presPDCdelay", "must be an integer", -8) return false end
  if math.type(RecordingPath)~="integer" then ultraschall.AddErrorMessage("SetTrackRecState", "RecordingPath", "must be an integer", -9) return false end
  
  -- create state-entry
  local str="REC "..ArmState.." "..InputChannel.." "..MonitorInput.." "..RecInput.." "..MonitorWhileRec.." "..presPDCdelay.." "..RecordingPath
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackRecState", "TrackStateChunk", "must be a string", -10) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state from trackstatechunk
  local B1=AA:match("(.-)REC")
  local B3=AA:match("REC.-%c(.*)")
  
  -- set trackstatechunk and include new-state
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end

  return B, B1.."\n"..str.."\n"..B3
end

function ultraschall.SetTrackVUState(tracknumber, VUState, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackVUState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackVUState(integer tracknumber, integer VUState, optional string TrackStateChunk)</functioncall>
  <description>
    Sets VU-state of a track or a TrackStateChunk; the way metering shows.
    
    Has no real effect on master track.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    integer VUState -  0 MultiChannelMetering is off, 2 MultichannelMetering is on, 3 Metering is off;seems to have no effect on MasterTrack
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, armstate, vu, metering, multichannel, trackstatechunk</tags>
</US_DocBloc>
--]]

  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackVUState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackVUState", "tracknumber", "no such track in the project", -2) return false end
  if math.type(VUState)~="integer" then ultraschall.AddErrorMessage("SetTrackVUState", "VUState", "must be an integer", -3) return false end

  -- create state-entry
  local str="VU "..VUState
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then 
      Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackVUState", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end

  -- remove old state-entry
  local B1=AA:match("(.-)VU")
  local B3=AA:match("VU.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end
  
  -- insert new state into trackstatechunk
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end

  return B, B1.."\n"..str.."\n"..B3
end

function ultraschall.SetTrackHeightState(tracknumber, heightstate1, heightstate2, heightstate3, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackHeightState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.977
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackHeightState(integer tracknumber, integer height, integer heightstate2, integer lockedtrackheight, optional string TrackStateChunk)</functioncall>
  <description>
    Sets TRACKHEIGHT-state; the height and compacted state of the track or a TrackStateChunk.
    
    Has no visible effect on the master-track.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    integer height -  24 up to 443 pixels
    integer lockedtrackheight - 0, trackheight is not locked; 1, trackheight is locked
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, state, trackheight, height, compact, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackHeightState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackHeightState", "tracknumber", "no such track in the project", -2) return false end
  if math.type(heightstate1)~="integer" then ultraschall.AddErrorMessage("SetTrackHeightState", "height", "must be an integer, between 24 and 443", -3) return false end
  if math.type(heightstate2)~="integer" then ultraschall.AddErrorMessage("SetTrackHeightState", "heightstate2", "must be an integer", -4) return false end
  if type(heightstate3)=="string" then 
    TrackStateChunk=heightstate3
    heightstate=""
  elseif math.type(heightstate3)~="integer" then ultraschall.AddErrorMessage("SetTrackHeightState", "lockedtrackheight", "must be an integer", -4) return false 
  end
  
  -- create state-entry
  local str="TRACKHEIGHT "..heightstate1.." "..heightstate2.." "..heightstate3
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackHeightState", "TrackStateChunk", "must be a string", -5) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state-entry from trackstatechunk
  local B1=AA:match("(.-)TRACKHEIGHT")
  local B3=AA:match("TRACKHEIGHT.-%c(.*)")
  
  -- insert new state-entry into trackstatechunk
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end

  return B, B1.."\n"..str.."\n"..B3
end

--A,AA=reaper.GetTrackStateChunk(reaper.GetTrack(0,0),"",false)
--A00,A01=ultraschall.SetTrackHeightState(-1, 100, 1, AA)
--A,AA=reaper.GetTrackStateChunk(reaper.GetTrack(0,0),"",false)
--A1,B1,C1=ultraschall.GetTrackHeightState(-1, A01)
--print2(A01)

function ultraschall.SetTrackINQState(tracknumber, INQ1, INQ2, INQ3, INQ4, INQ5, INQ6, INQ7, INQ8, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackINQState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackINQState(integer tracknumber, integer quantMIDI, integer quantPOS, integer quantNoteOffs, number quantToFractBeat, integer quantStrength, integer swingStrength, integer quantRangeMin, integer quantRangeMax, optional string TrackStateChunk)</functioncall>
  <description>
    Sets INQ-state, mostly the quantize-settings for MIDI, of a track or a TrackStateChunk, as set in the "Track: View track recording settings (MIDI quantize, file format/path) for last touched track"-dialog (action 40604)
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    integer quantMIDI -  quantize MIDI; 0 or 1
    integer quantPOS -  quantize to position; -1,prev; 0, nearest; 1, next
    integer quantNoteOffs -  quantize note-offs; 0 or 1
    number quantToFractBeat -  quantize to (fraction of beat)
    integer quantStrength -  quantize strength; -128 to 127
    integer swingStrength -  swing strength; -128 to 127
    integer quantRangeMin -  quantize range minimum; -128 to 127
    integer quantRangeMax -  quantize range maximum; -128 to 127
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, state, inq, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackINQState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackINQState", "tracknumber", "no such track in the project", -2) return false end
  if math.type(INQ1)~="integer" then ultraschall.AddErrorMessage("SetTrackINQState", "INQ1", "must be an integer", -3) return false end
  if math.type(INQ2)~="integer" then ultraschall.AddErrorMessage("SetTrackINQState", "INQ2", "must be an integer", -4) return false end
  if math.type(INQ3)~="integer" then ultraschall.AddErrorMessage("SetTrackINQState", "INQ3", "must be an integer", -5) return false end
  if type(INQ4)~="number" then ultraschall.AddErrorMessage("SetTrackINQState", "INQ4", "must be a number", -6) return false end
  if math.type(INQ5)~="integer" then ultraschall.AddErrorMessage("SetTrackINQState", "INQ5", "must be an integer", -7) return false end
  if math.type(INQ6)~="integer" then ultraschall.AddErrorMessage("SetTrackINQState", "INQ6", "must be an integer", -8) return false end
  if math.type(INQ7)~="integer" then ultraschall.AddErrorMessage("SetTrackINQState", "INQ7", "must be an integer", -9) return false end
  if math.type(INQ8)~="integer" then ultraschall.AddErrorMessage("SetTrackINQState", "INQ8", "must be an integer", -10) return false end
  
  -- create state-entry
  local str="INQ "..INQ1.." "..INQ2.." "..INQ3.." "..INQ4.." "..INQ5.." "..INQ6.." "..INQ7.." "..INQ8
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackINQState", "TrackStateChunk", "must be a string", -11) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state-entry
  local B1=AA:match("(.-)INQ")
  local B3=AA:match("INQ.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  -- insert new state-entry into trackstatechunk
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end
  return B, B1.."\n"..str.."\n"..B3
end

function ultraschall.SetTrackNChansState(tracknumber, NChans, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackNChansState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackNChansState(integer tracknumber, integer NChans, optional string TrackStateChunk)</functioncall>
  <description>
    Sets NCHAN-state; the number of channels in this track or a TrackStateChunk, as set in the routing.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    integer NChans - 2 to 64, counted every second channel (2,4,6,8,etc) with stereo-tracks. Unknown, if Multichannel and Mono-tracks count differently.
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, state, channels, number, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackNChansState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackNChansState", "tracknumber", "no such track in the project", -2) return false end
  if math.type(NChans)~="integer" then ultraschall.AddErrorMessage("SetTrackNChansState", "NChans", "must be an integer", -3) return false end
  
  -- create new state-entry
  local str="NCHAN "..NChans
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackNChansState", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end

  -- remove old state-entry from trackstatechunk
  local B1=AA:match("(.-)NCHAN")
  local B3=AA:match("NCHAN.-%c(.*)")
  
  -- insert new state-entry into trackstatechunk
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end

  return B, B1.."\n"..str.."\n"..B3
end

function ultraschall.SetTrackBypFXState(tracknumber, FXBypassState, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackBypFXState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackBypFXState(integer tracknumber, integer FXBypassState, optional string TrackStateChunk)</functioncall>
  <description>
    Sets FX, FX-Bypass-state of the track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    integer FXBypassState  - 0 bypass, 1 activate fx; has only effect, if FX or instruments are added to this track
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, track, set, fx, bypass, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackBypFXState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackBypFXState", "tracknumber", "no such track in the project", -2) return false end
  if math.type(FXBypassState)~="integer" then ultraschall.AddErrorMessage("SetTrackBypFXState", "FXBypassState", "must be an integer", -3) return false end
  
  -- create new state-entry
  local str="FX "..FXBypassState
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackBypFXState", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end

  -- remove old state-entry from trackstatechunk
  local B1=AA:match("(.-)FX")
  local B3=AA:match("FX.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  -- insert new entry into trackstatechunk
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end

  return B, B1.."\n"..str.."\n"..B3
end


function ultraschall.SetTrackPerfState(tracknumber, Perf, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackPerfState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackPerfState(integer tracknumber, integer Perf, optional string TrackStateChunk)</functioncall>
  <description>
    Sets PERF, the TrackPerformance-State of a track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; -1 if you want to use parameter TrackStateChunk
    integer Perf  - performance-state
    - 0 - allow anticipative FX + allow media buffering
    - 1 - allow anticipative FX + prevent media buffering
    - 2 - prevent anticipative FX + allow media buffering
    - 3 - prevent anticipative FX + prevent media buffering
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, state, set, fx, performance, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackPerfState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackPerfState", "tracknumber", "no such track in the project", -2) return false end
  if math.type(Perf)~="integer" then ultraschall.AddErrorMessage("SetTrackPerfState", "FXBypassState", "must be an integer", -3) return false end
  
  -- create new state-entry
  local str="PERF "..Perf
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackPerfState", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state-entry from trackstatechunk
  local B1=AA:match("(.-)PERF")
  local B3=AA:match("PERF.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  -- insert new state-entry into trackstatechunk
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1..""..str.."\n"..B3,false)
  else
    B=true
  end  

  return B, B1..""..str.."\n"..B3
end


function ultraschall.SetTrackMIDIOutState(tracknumber, MIDIOutState, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackMIDIOutState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackMIDIOutState(integer tracknumber, integer MIDIOutState, optional string TrackStateChunk)</functioncall>
  <description>
    Sets MIDIOUT, the state of MIDI out for this track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    integer MIDIOutState - 
    - %-1 no output
    - 416 %- microsoft GS wavetable synth-send to original channels
    - 417-432 %- microsoft GS wavetable synth-send to channel state minus 416
    - -31 %- no Output, send to original channel 1
    - -16 %- no Output, send to original channel 16
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, state, set, midi, midiout, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackMIDIOutState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackMIDIOutState", "tracknumber", "no such track in the project", -2) return false end
  if math.type(MIDIOutState)~="integer" then ultraschall.AddErrorMessage("SetTrackMIDIOutState", "MIDIOutState", "must be an integer", -3) return false end

  -- create new state-entry
  local str="MIDIOUT "..MIDIOutState
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackMIDIOutState", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state-entry into the trackstatechunk
  local B1=AA:match("(.-)MIDIOUT")
  local B3=AA:match("MIDIOUT.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  -- insert new state-entry into the trackstatechunk
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end

  return B, B1.."\n"..str.."\n"..B3
end


function ultraschall.SetTrackMainSendState(tracknumber, MainSendOn, ParentChannels, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackMainSendState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
  </requires>
  <functioncall>boolean retval, optional string TrackStateChunk = ultraschall.SetTrackMainSendState(integer tracknumber, integer MainSendOn, integer ParentChannels, optional string TrackStateChunk)</functioncall>
  <description>
    Sets MAINSEND, as set in the routing-settings, of a track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    optional string TrackStateChunk - the altered TrackStateChunk, if tracknumber=-1
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    integer MainSendOn - on(1) or off(0)
    integer ParentChannels  - the ParentChannels(0-64), interpreted as beginning with ParentChannels to ParentChannels+NCHAN
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, state, set, mainsend, parent channels, parent, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackMainSendState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackMainSendState", "tracknumber", "no such track in the project", -2) return false end
  if math.type(MainSendOn)~="integer" then ultraschall.AddErrorMessage("SetTrackMainSendState", "MainSendOn", "must be an integer", -3) return false end
  if math.type(ParentChannels)~="integer" then ultraschall.AddErrorMessage("SetTrackMainSendState", "ParentChannels", "must be an integer", -4) return false end

  -- create new state-entry
  local str="MAINSEND "..MainSendOn.." "..ParentChannels
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    --A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
    reaper.SetMediaTrackInfo_Value(Mediatrack, "B_MAINSEND", MainSendOn)
    reaper.SetMediaTrackInfo_Value(Mediatrack, "C_MAINSEND_OFFS", ParentChannels)
    return true
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackMainSendState", "TrackStateChunk", "must be a string", -5) return false end
    AA=TrackStateChunk
  end

  -- remove old state-entry from trackstatechunk
  local B1=AA:match("(.-)MAINSEND")
  local B3=AA:match("MAINSEND.-%c(.*)")
  
  -- insert new state-entry into trackstatechunk
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end

  return B, B1.."\n"..str.."\n"..B3
end

function ultraschall.SetTrackLockState(tracknumber, LockedState, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackLockState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackLockState(integer tracknumber, integer LockedState, optional string TrackStateChunk)</functioncall>
  <description>
    Sets LOCK-State, as set by the menu entry Lock Track Controls, of a track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; -1 if you want to use parameter TrackStateChunk
    integer LockedState  - 1 - locked, 0 - unlocked
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, lock, state, set, track, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackLockState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackLockState", "tracknumber", "no such track in the project", -2) return false end
  if math.type(LockedState)~="integer" then ultraschall.AddErrorMessage("SetTrackLockState", "LockedState", "must be an integer", -3) return false end

  -- create new state-entry
  local str="LOCK "..LockedState
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B, B1, B3
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackLockState", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state-entry and insert new state-entry into trackstatechunk
  if AA:match("LOCK")=="LOCK" then
    B1=AA:match("(.-)LOCK")
    B3=AA:match("LOCK.-%c(.*)")
  else 
    B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end

  return B, B1.."\n"..str.."\n"..B3
end

function ultraschall.SetTrackLayoutNames(tracknumber, TCP_Layoutname, MCP_Layoutname, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackLayoutNames</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackLayoutNames(integer tracknumber, string TCP_Layoutname, string MCP_Layoutname, optional string TrackStateChunk)</functioncall>
  <description>
    Sets LAYOUTS, the MCP and TCP-layout by name of the layout as defined in the theme, of a track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    string TCP_Layoutname  - name of the TrackControlPanel-Layout from the theme to use
    string MCP_Layoutname  - name of the MixerControlPanel-Layout from the theme to use
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, state, set, mcp, tcp, layout, mixer, trackcontrol, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackLayoutNames", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackLayoutNames", "tracknumber", "no such track in the project", -2) return false end
  if type(TCP_Layoutname)~="string" then ultraschall.AddErrorMessage("SetTrackLayoutNames", "TCP_Layoutname", "must be a string", -3) return false end
  if type(MCP_Layoutname)~="string" then ultraschall.AddErrorMessage("SetTrackLayoutNames", "MCP_Layoutname", "must be a string", -4) return false end
  
  -- create new state-entry
  local str="LAYOUTS \""..TCP_Layoutname.."\" \""..MCP_Layoutname.."\""
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackLayoutNames", "TrackStateChunk", "must be a string", -5) return false end
    AA=TrackStateChunk
  end

  -- remove old state-entry from trackstatechunk
  local B1=AA:match("(.-)LAYOUTS")
  local B3=AA:match("LAYOUTS.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  -- insert new state-entry into statechunk
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1..""..str.."\n"..B3,false)
  else
    B=true
  end

  return B, B1..""..str.."\n"..B3
end

function ultraschall.SetTrackAutomodeState(tracknumber, automodestate, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackAutomodeState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackAutomodeState(integer tracknumber, integer automodestate, optional string TrackStateChunk)</functioncall>
  <description>
    Sets AUTOMODE-State, as set by the menu entry Set Track Automation Mode, for a track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    integer automodestate - 0 - trim/read, 1 - read, 2 - touch, 3 - write, 4 - latch
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, state, automode, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackAutomodeState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackAutomodeState", "tracknumber", "no such track in the project", -2) return false end
  if math.type(automodestate)~="integer" then ultraschall.AddErrorMessage("SetTrackAutomodeState", "automodestate", "must be an integer", -3) return false end

  -- create new state-entry
  local str="AUTOMODE "..automodestate
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackAutomodeState", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end

  -- remove old state-entry from trackstatechunk
  local B1=AA:match("(.-)AUTOMODE")
  local B3=AA:match("AUTOMODE.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  -- insert new state-entry into trackstatechunk
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1..""..str.."\n"..B3,false)
  else
    B=true
  end

  return B, B1..""..str.."\n"..B3
end

function ultraschall.SetTrackIcon_Filename(tracknumber, Iconfilename_with_path, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackIcon_Filename</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackIcon_Filename(integer tracknumber, string Iconfilename_with_path, optional string TrackStateChunk)</functioncall>
  <description>
    Sets TRACKIMGFN, the trackicon-filename with path, of a track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; -1 if you want to use parameter TrackStateChunk
    string Iconfilename_with_path - filename+path of the imagefile to use as the trackicon; "", to remove track-icon
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, state, track, set, trackicon, image, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackIcon_Filename", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackIcon_Filename", "tracknumber", "no such track in the project", -2) return false end
  if type(Iconfilename_with_path)~="string" then ultraschall.AddErrorMessage("SetTrackIcon_Filename", "Iconfilename_with_path", "must be a string", -3) return false end

  -- create new state-entry
  local str="TRACKIMGFN \""..Iconfilename_with_path.."\""
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackIcon_Filename", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end

  -- remove old state-entry from trackstatechunk
  local B1=AA:match("(.-)TRACKIMGFN")
  local B3=AA:match("TRACKIMGFN.-%c(.*)")
  
  -- insert new state-entry into trackstatechunk
  if B1==nil then B1=AA:match("(.-)FX") B3=AA:match(".-(FX.*)") end
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1..""..str.."\n"..B3,false)
  else
    B=true
  end
  return B, B1.."\n"..str.."\n"..B3
end

function ultraschall.SetTrackMidiInputChanMap(tracknumber, InputChanMap, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackMidiInputChanMap</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackMidiInputChanMap(integer tracknumber, integer InputChanMap, optional string TrackStateChunk)</functioncall>
  <description>
    Sets MIDI_INPUT_CHANMAP, as set in the Input-MIDI->Map Input to Channel menu, of a track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    integer InputChanMap - 0 for channel 1, 2 for channel 2, etc. -1 if not existing; nil, to remove MidiInputChanMap
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, state, input, chanmap, channelmap, midi, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackMidiInputChanMap", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackMidiInputChanMap", "tracknumber", "no such track in the project", -2) return false end
  if math.type(InputChanMap)~="integer" then ultraschall.AddErrorMessage("SetTrackMidiInputChanMap", "InputChanMap", "must be an integer", -3) return false end

  -- create new state-entry
  local str="MIDI_INPUT_CHANMAP "..InputChanMap
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackMidiInputChanMap", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end

  -- remove old state-entry from trackstatechunk
  local B1=AA:match("(.-)MIDI_INPUT_CHANMAP")
  local B3=AA:match("MIDI_INPUT_CHANMAP.-%c(.*)")
  if B1==nil then B1=AA:match("(.-REC.-\n)") B3=AA:match(".-TRACK.-\n(.*)") end

  -- insert new state-entry into trackstatechunk
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1..""..str.."\n"..B3,false)
  else
    B=true
  end

  return B, B1..""..str.."\n"..B3
end

function ultraschall.SetTrackMidiCTL(tracknumber, LinkedToMidiChannel, unknown, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackMidiCTL</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackMidiCTL(integer tracknumber, integer LinkedToMidiChannel, integer unknown, optional string TrackStateChunk)</functioncall>
  <description>
    sets MIDICTL-state, the linkage to Midi-Channels of a track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    integer LinkedToMidiChannel - unknown; nil, to remove this setting completely
    integer unknown - unknown
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, state, linked, midi, midichannel, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackMidiCTL", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackMidiCTL", "tracknumber", "no such track in the project", -2) return false end
  if math.type(LinkedToMidiChannel)~="integer" then ultraschall.AddErrorMessage("SetTrackMidiCTL", "LinkedToMidiChannel", "must be an integer", -3) return false end
  if math.type(unknown)~="integer" then ultraschall.AddErrorMessage("SetTrackMidiCTL", "unknown", "must be an integer", -4) return false end

  -- create new state-entry
  local str="MIDICTL "..LinkedToMidiChannel.." "..unknown
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackMidiCTL", "TrackStateChunk", "must be a string", -5) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state-entry from trackstatechunk
  local B1=AA:match("(.-)MIDICTL")
  local B3=AA:match("MIDICTL.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  -- insert new state-entry into trackstatechunk
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end  

  return B, B1.."\n"..str.."\n"..B3
end

function ultraschall.SetTrackID(tracknumber, TrackID, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackID</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackID(integer tracknumber, string guid, optional string TrackStateChunk)</functioncall>
  <description>
    sets the track-id, which must be a valid GUID, of a track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    string guid - a valid GUID. Can be generated with the native Reaper-function reaper.genGuid()
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, state, guid, trackid, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackID", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackID", "tracknumber", "no such track in the project", -2) return false end
  if type(TrackID)~="string" then ultraschall.AddErrorMessage("SetTrackID", "TrackID", "must be a string", -3) return false end


  -- create new state-entry
  local str="TRACKID "..TrackID
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackID", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state-entry from trackstatechunk
  local B1=AA:match("(.-)TRACKID")
  local B3=AA:match("TRACKID.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  -- insert new state-entry into trackstatechunk
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end  

  return B, B1.."\n"..str.."\n"..B3
end

--ATA,ATA2=ultraschall.SetTrackID(nil, "{12345678-1111-1111-1111-123456789012}", L3)

function ultraschall.SetTrackMidiColorMapFn(tracknumber, MIDI_ColorMapFN, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackMidiColorMapFn</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackMidiColorMapFn(integer tracknumber, string MIDI_ColorMapFN, optional string TrackStateChunk)</functioncall>
  <description>
    sets the filename+path to the MIDI-ColorMap-graphicsfile of a track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    string MIDI_ColorMapFN - filename+path to the MIDI-ColorMap-file; "", to remove it
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, state, midi, colormap, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackMidiColorMapFn", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackMidiColorMapFn", "tracknumber", "no such track in the project", -2) return false end
  if type(MIDI_ColorMapFN)~="string" then ultraschall.AddErrorMessage("SetTrackMidiColorMapFn", "MIDI_ColorMapFN", "must be a string", -3) return false end

  -- create new state-entry
  local str="MIDICOLORMAPFN \""..MIDI_ColorMapFN.."\""
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackMidiColorMapFn", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state-entry from trackstatechunk
  local B1=AA:match("(.-)MIDICOLORMAPFN")
  local B3=AA:match("MIDICOLORMAPFN.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  -- insert new state-entry into trackstatechunk
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end  

  return B, B1.."\n"..str.."\n"..B3
end

--ATA,ATA2=ultraschall.SetTrackMidiColorMapFn(1, "", L3)

function ultraschall.SetTrackMidiBankProgFn(tracknumber, MIDIBankProgFn, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackMidiBankProgFn</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackMidiBankProgFn(integer tracknumber, string MIDIBankProgFn, optional string TrackStateChunk)</functioncall>
  <description>
    sets the filename+path to the MIDI-Bank-Prog-file of a track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    string MIDIBankProgFn - filename+path to the MIDI-Bank-Prog-file; "", to remove it
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, state, midi, bank, prog, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackMidiBankProgFn", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackMidiBankProgFn", "tracknumber", "no such track in the project", -2) return false end
  if type(MIDIBankProgFn)~="string" then ultraschall.AddErrorMessage("SetTrackMidiBankProgFn", "MIDIBankProgFn", "must be a string", -3) return false end

  -- create new state-entry
  local str="MIDIBANKPROGFN \""..MIDIBankProgFn.."\""
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackMidiBankProgFn", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state-entry from trackstatechunk
  local B1=AA:match("(.-)MIDIBANKPROGFN")
  local B3=AA:match("MIDIBANKPROGFN.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  -- insert new state-entry into trackstatechunk
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end  

  return B, B1.."\n"..str.."\n"..B3
end

function ultraschall.SetTrackMidiTextStrFn(tracknumber, MIDITextStrFn, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackMidiTextStrFn</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackMidiTextStrFn(integer tracknumber, string MIDITextStrFn, optional string TrackStateChunk)</functioncall>
  <description>
    sets the filename+path to the MIDI-Text-Str-file of a track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    string MIDITextStrFn - filename+path to the MIDI-Text-Str-file; "", to remove it
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, state, midi, text, str, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackMidiTextStrFn", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackMidiTextStrFn", "tracknumber", "no such track in the project", -2) return false end
  if type(MIDITextStrFn)~="string" then ultraschall.AddErrorMessage("SetTrackMidiTextStrFn", "MIDITextStrFn", "must be a string", -3) return false end

  -- create new state-entry
  local str="MIDITEXTSTRFN \""..MIDITextStrFn.."\""
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackMidiTextStrFn", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state-entry from trackstatechunk
  local B1=AA:match("(.-)MIDITEXTSTRFN")
  local B3=AA:match("MIDITEXTSTRFN.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  -- insert new state-entry into trackstatechunk
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end  

  return B, B1.."\n"..str.."\n"..B3
end

--ATA,ATA2=ultraschall.SetTrackMidiTextStrFn(nil, "", L3)

function ultraschall.SetTrackPanMode(tracknumber, panmode, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackPanMode</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackPanMode(integer tracknumber, integer panmode, optional string TrackStateChunk)</functioncall>
  <description>
    sets the panmode for a track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    integer panmode - the Panmode of the track
                            -nil - Project Default
                            -0 - Reaper 3.x balance (deprecated)
                            -3 - Stereo Balance/ Mono Pan(Default)
                            -5 - Stereo Balance
                            -6 - Dual Pan
                            -7 - unknown mode
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, state, panmode, pan, balance, dual pan, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackPanMode", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackPanMode", "tracknumber", "no such track in the project", -2) return false end
  if math.type(panmode)~="integer" then ultraschall.AddErrorMessage("SetTrackPanMode", "panmode", "must be an integer", -3) return false end

  -- create new state-entry
  local str="PANMODE \""..panmode.."\""
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackPanMode", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state-entry from trackstatechunk
  local B1=AA:match("(.-)PANMODE")
  local B3=AA:match("PANMODE.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  -- insert new state-entry into trackstatechunk
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end  

  return B, B1.."\n"..str.."\n"..B3
end


function ultraschall.SetTrackWidth(tracknumber, width, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackWidth</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackWidth(integer tracknumber, number width, optional string TrackStateChunk)</functioncall>
  <description>
    sets the width of a track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    number width - width of the track, from -1(-100%) to 1(+100%)
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, state, width, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackWidth", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackWidth", "tracknumber", "no such track in the project", -2) return false end
  if type(width)~="number" then ultraschall.AddErrorMessage("SetTrackWidth", "width", "must be a number", -3) return false end

  -- create new state-entry
  local str="WIDTH \""..width.."\""
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackWidth", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state-entry from trackstatechunk
  local B1=AA:match("(.-)WIDTH")
  local B3=AA:match("WIDTH.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  -- insert new state-entry into trackstatechunk
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end  

  return B, B1.."\n"..str.."\n"..B3
end

function ultraschall.SetTrackScore(tracknumber, unknown1, unknown2, unknown3, unknown4, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackScore</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackScore(integer tracknumber, integer unknown1, integer unknown2, number unknown3, number unknown4, optional string TrackStateChunk)</functioncall>
  <description>
    sets the SCORE of a track or a TrackStateChunk.
    
    set unknown1 to unknown4 to 0 to remove the entry
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    integer unknown1 - unknown
    integer unknown2 - unknown
    number unknown3 - unknown
    number unknown4 - unknown
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, state, score, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackScore", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackScore", "tracknumber", "no such track in the project", -2) return false end
  if math.type(unknown1)~="integer" then ultraschall.AddErrorMessage("SetTrackScore", "unknown1", "must be an integer", -3) return false end
  if math.type(unknown2)~="integer" then ultraschall.AddErrorMessage("SetTrackScore", "unknown2", "must be an integer", -4) return false end
  if type(unknown3)~="number" then ultraschall.AddErrorMessage("SetTrackScore", "unknown3", "must be a number", -5) return false end
  if type(unknown4)~="number" then ultraschall.AddErrorMessage("SetTrackScore", "unknown4", "must be a number", -6) return false end

  -- create new state-entry
  local str="SCORE "..unknown1.." "..unknown2.." "..unknown3.." "..unknown4
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackScore", "TrackStateChunk", "must be a string", -7) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state-entry from trackstatechunk
  local B1=AA:match("(.-)SCORE")
  local B3=AA:match("SCORE.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  -- insert new state-entry into trackstatechunk
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end  

  return B, B1.."\n"..str.."\n"..B3
end

function ultraschall.SetTrackVolPan(tracknumber, vol, pan, overridepanlaw, unknown, unknown2, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackVolPan</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackVolPan(integer tracknumber, number Vol, number Pan, number OverridePanLaw, number unknown, number unknown2, optional string TrackStateChunk)</functioncall>
  <description>
    sets the VOLPAN-state of a track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1, if you want to use parameter TrackStateChunk
    number Vol - Volume Settings; -Inf dB(0) to +12dB (3.98107170553497)
    number Pan - Pan Settings; -1(-100%); 0(center); 1(100% R)
    number OverridePanLaw - Override Default Pan Track Law; 0dB(1) to -144dB(0.00000006309573)
    number unknown - unknown
    number unknown2 - unknown
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, vol, pan, override, panlaw, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackVolPan", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackVolPan", "tracknumber", "no such track in the project", -2) return false end
  if type(vol)~="number" then ultraschall.AddErrorMessage("SetTrackVolPan", "vol", "must be a number", -3) return false end
  if type(pan)~="number" then ultraschall.AddErrorMessage("SetTrackVolPan", "pan", "must be a number", -4) return false end
  if type(overridepanlaw)~="number" then ultraschall.AddErrorMessage("SetTrackVolPan", "overridepanlaw", "must be a number", -5) return false end
  if type(unknown)~="number" then ultraschall.AddErrorMessage("SetTrackVolPan", "unknown", "must be a number", -6) return false end
  if type(unknown2)~="number" then ultraschall.AddErrorMessage("SetTrackVolPan", "unknown1", "must be a number", -7) return false end

  -- create new state-entry
  local str="VOLPAN "..vol.." "..pan.." "..overridepanlaw.." "..unknown.." "..unknown2
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackVolPan", "TrackStateChunk", "must be a string", -8) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state-entry from trackstatechunk
  local B1=AA:match("(.-)VOLPAN")
  local B3=AA:match("VOLPAN.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  -- insert new state-entry into trackstatechunk
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end  

  return B, B1.."\n"..str.."\n"..B3
end

function ultraschall.SetTrackRecCFG(tracknumber, reccfg_string, reccfg_nr, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackRecCFG</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackRecCFG(integer tracknumber, string reccfg_string, integer reccfg_nr, optional string TrackStateChunk)</functioncall>
  <description>
    sets the RECCFG of a track or a TrackStateChunk.
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    string reccfg_string -  the string, that encodes the recording configuration of the track
    integer reccfgnr - the number of the recording-configuration of the track; 
                     - -1, removes the reccfg-setting
                     - 0, use default project rec-setting
                     - 1, use track-customized rec-setting, as set in the "Track: View track recording settings (MIDI quantize, file format/path) for last touched track"-dialog (action 40604)
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, state, reccfg, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackRecCFG", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackRecCFG", "tracknumber", "no such track in the project", -2) return false end
  if math.type(reccfg_nr)~="integer" then ultraschall.AddErrorMessage("SetTrackRecCFG", "reccfg_nr", "must be an integer", -3) return false end
  if type(reccfg_string)~="string" then ultraschall.AddErrorMessage("SetTrackRecCFG", "reccfg_string", "must be a string", -4) return false end

  -- create new state-entry
  local str="<RECCFG "..reccfg_nr.."\n"..reccfg_string.."\n>"
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackRecCFG", "TrackStateChunk", "must be a string", -5) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state-entry from trackstatechunk
  local B1=AA:match("(.-)<RECCFG")
  local B3=AA:match("RECCFG.->%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  -- insert new state-entry into trackstatechunk
  if tracknumber~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end  

  return B, B1.."\n"..str.."\n"..B3
end


function ultraschall.IsValidTrackString(trackstring)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsValidTrackString</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean valid, integer count, array individual_tracknumbers = ultraschall.IsValidTrackString(string trackstring)</functioncall>
  <description>
    checks, whether a given trackstring is a valid one. Will also return all valid numbers, from trackstring, that can be used as tracknumbers, as an array.
  </description>
  <retvals>
    boolean valid - true, is a valid trackstring; false, is not a valid trackstring
    integer count - the number of entries found in trackstring
    array individual_tracknumbers - an array that contains all available tracknumbers
  </retvals>
  <parameters>
    string trackstring - the trackstring to check, if it's a valid one
  </parameters>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, trackstring, check, valid</tags>
</US_DocBloc>
]]
  -- check parameters
  if type(trackstring)~="string" then ultraschall.AddErrorMessage("IsValidTrackString","trackstring", "Must be a string!", -1) return false end
  local count, individual_values = ultraschall.CSV2IndividualLinesAsArray(trackstring)
  local found=true
  if individual_values==nil then ultraschall.AddErrorMessage("IsValidTrackString","trackstring", "Has no tracknumbers in it!", -1) return false end

  -- check the individual trackstring-entries and throw out all invalid-entries
  for i=count, 1, -1 do
    individual_values[i]=tonumber(individual_values[i])
    if individual_values[i]==nil then table.remove(individual_values,i) count=count-1 found=false end
  end
  
  -- sort it and return it
  table.sort(individual_values) 
  return found, count, individual_values
end


function ultraschall.IsValidTrackStateChunk(statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsValidTrackStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean valid = ultraschall.IsValidTrackStateChunk(string TrackStateChunk)</functioncall>
  <description>
    returns, if a TrackStateChunk is a valid statechunk
  </description>
  <parameters>
    string TrackStateChunk - a string to check, if it's a valid TrackStateChunk
  </parameters>
  <retvals>
    boolean valid - true, if the string is a valid statechunk; false, if not a valid statechunk
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, check, validity, track, statechunk, valid</tags>
</US_DocBloc>
--]]
  if type(statechunk)~="string" then ultraschall.AddErrorMessage("IsValidTrackStateChunk","statechunk", "must be a string", -1) return false end
  if statechunk:match("<TRACK.*>\n$")~=nil then return true end
  return false
end

function ultraschall.CreateTrackString(firstnumber, lastnumber, step)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CreateTrackString</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string trackstring = ultraschall.CreateTrackString(integer firstnumber, integer lastnumber, optional integer step)</functioncall>
  <description>
    returns a string with the all numbers from firstnumber to lastnumber, separated by a ,
    e.g. firstnumber=4, lastnumber=8 -> 4,5,6,7,8
  </description>
  <parameters>
    integer firstnumber - the number, with which the string starts
    integer lastnumber - the number, with which the string ends
    integer step - how many numbers shall be skipped inbetween. Can lead to a different lastnumber, when step is not 1! nil or invalid value=1
  </parameters>
  <retvals>
    string trackstring - a string with all tracknumbers, separated by a ,
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackstring, track, create</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(firstnumber)~="integer" then ultraschall.AddErrorMessage("CreateTrackString","firstnumber", "only integer allowed", -1) return nil end
  if math.type(lastnumber)~="integer" then ultraschall.AddErrorMessage("CreateTrackString","lastnumber", "only integer allowed", -2) return nil end
  if tonumber(step)==nil then step=1 end
    
  -- prepare variables
  firstnumber=tonumber(firstnumber)
  lastnumber=tonumber(lastnumber)
  step=tonumber(step)
  local trackstring=""
  
  -- create trackstring
  for i=firstnumber, lastnumber, step do
    trackstring=trackstring..","..tostring(i)
  end
  return trackstring:sub(2,-1)
end

function ultraschall.CreateTrackString_SelectedTracks()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CreateTrackString_SelectedTracks</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string trackstring = ultraschall.CreateTrackString_SelectedTracks()</functioncall>
  <description>
    Creates a string with all numbers from selected tracks, separated by a ,
    
    Returns an empty string, if no tracks are selected.
  </description>
  <retvals>
    string trackstring - a string with the tracknumbers, separated by a string
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, datastructure</tags>
</US_DocBloc>
]]
  -- prepare variable
  local trackstring=""
  
  -- get the selected tracks and add their tracknumber to trackstring
  for i=1, reaper.CountTracks(0) do
    local MediaTrack=reaper.GetTrack(0,i-1)
    if reaper.IsTrackSelected(MediaTrack)==true then
      trackstring=trackstring..i..","
    end  
  end
  
  -- return trackstring
  return trackstring:sub(1,-2)
end

function ultraschall.InsertTrack_TrackStateChunk(trackstatechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>InsertTrack_TrackStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, MediaTrack MediaTrack = ultraschall.InsertTrack_TrackStateChunk(string trackstatechunk)</functioncall>
  <description>
    Creates a new track at the end of the project and sets it's trackstate, using the parameter trackstatechunk.
    Returns, if it succeeded and the newly created MediaTrack.
  </description>
  <parameters>
    string trackstatechunk - the rpp-xml-Trackstate-Chunk, as created by reaper.GetTrackStateChunk or <a href="#GetProject_TrackStateChunk">GetProject_TrackStateChunk</a>
  </parameters>
  <retvals>
    boolean retval - true, if creation succeeded, false if not
    MediaTrack MediaTrack - the newly created track, as MediaItem-trackobject
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackstring, track, create, trackstate, trackstatechunk, chunk, state</tags>
</US_DocBloc>
]]--
  if ultraschall.IsValidTrackStateChunk(trackstatechunk)==false then ultraschall.AddErrorMessage("InsertTrack_TrackStateChunk", "trackstatechunk", "Must be a valid TrackStateChunk", -1) return false end
  reaper.InsertTrackAtIndex(reaper.CountTracks(0), true)
  local MediaTrack=reaper.GetTrack(0,reaper.CountTracks(0)-1)
  if MediaTrack==nil then ultraschall.AddErrorMessage("InsertTrack_TrackStateChunk", "", "Couldn't create new track.", -2) return false end
  local bool=reaper.SetTrackStateChunk(MediaTrack, trackstatechunk, true)
  if bool==false then reaper.DeleteTrack(MediaTrack) ultraschall.AddErrorMessage("InsertTrack_TrackStateChunk", "trackstatechunk", "Couldn't set TrackStateChunk", -3) return false end
  return true, MediaTrack
end

function ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>RemoveDuplicateTracksInTrackstring</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval, string trackstring, array trackstringarray, integer number_of_entries = ultraschall.RemoveDuplicateTracksInTrackstring(string trackstring)</functioncall>
  <description>
    Sorts tracknumbers in trackstring and throws out duplicates. It also throws out entries, that are no numbers.
    Returns the "cleared" trackstring as string and as array, as well as the number of entries. Returns -1 in case of failure.
  </description>
  <parameters>
    string trackstring - the tracknumbers, separated by a comma
  </parameters>
  <retvals>
    integer retval - -1 in case of error, 1 in case of success
    string trackstring - the cleared trackstring, -1 in case of error
    array trackstringarray - the "cleared" trackstring as an array
    integer number_of_entries - the number of entries in the trackstring
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, tracks, trackstring, sort, order</tags>
</US_DocBloc>
]]
    if type(trackstring)~="string" then ultraschall.AddErrorMessage("RemoveDuplicateTracksInTrackstring","trackstring", "must be a string", -1) return -1 end
    local _count, Trackstring_array=ultraschall.CSV2IndividualLinesAsArray(trackstring)    
    if Trackstring_array==nil then ultraschall.AddErrorMessage("RemoveDuplicateTracksInTrackstring","trackstring", "not a valid trackstring", -3) return -1 end
    table.sort(Trackstring_array)
    local count=2
    while Trackstring_array[count]~=nil do
      if Trackstring_array[count]==Trackstring_array[count-1] then table.remove(Trackstring_array,count) count=count-1 
      elseif tonumber(Trackstring_array[count])==nil then table.remove(Trackstring_array,count) count=count-1
      end
      count=count+1
    end
    count=1
    if tonumber(Trackstring_array[1])==nil then table.remove(Trackstring_array,1) end
    trackstring=""
    while Trackstring_array[count]~=nil do
      trackstring=trackstring..Trackstring_array[count]..","
      Trackstring_array[count]=tonumber(Trackstring_array[count])
      count=count+1
    end
    return 1, trackstring:sub(1,-2), Trackstring_array, count-1
end



function ultraschall.SetAllTracksSelected(selected)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetAllTracksSelected</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval = ultraschall.SetAllTracksSelected(boolean selected)</functioncall>
  <description>
    Sets all tracks selected(if selected is true) of unselected(if selected is false)
    
    returns -1 in case of error
  </description>
  <retvals>
    integer retval - returns -1 in case of error
  </retvals>
  <parameters>
    boolean selected - true, if all tracks shall be selected, false if all shall be deselected
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, tracks, get, selected</tags>
</US_DocBloc>
]]
  if type(selected)~="boolean" then ultraschall.AddErrorMessage("SetAllTracksSelected","selected", "must be a boolean", -1) return -1 end
  for i=0, reaper.CountTracks(0)-1 do
    local MediaTrack=reaper.GetTrack(0,i)
    reaper.SetTrackSelected(MediaTrack, selected)
  end
end

--L=ultraschall.SetAllTracksSelected(false)


function ultraschall.SetTracksSelected(trackstring, reset)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTracksSelected</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval = ultraschall.SetTracksSelected(string trackstring, boolean reset)</functioncall>
  <description>
    Sets tracks in trackstring selected. If reset is set to true, then the previous selection will be discarded.
    
    returns -1 in case of error
  </description>
  <retvals>
    integer retval - returns -1 in case of error
  </retvals>
  <parameters>
    string trackstring - a string with the tracknumbers, separated by a comma; nil or "", deselects all
    boolean reset - true, any previous selection will be discarded; false, it will be kept
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, tracks, get, selected</tags>
</US_DocBloc>
]]
  if type(reset)~="boolean" then ultraschall.AddErrorMessage("SetTracksSelected", "reset", "must be boolean", -1) return -1 end
  if trackstring==nil or trackstring=="" then ultraschall.SetAllTracksSelected(false) return end
  local L,trackstring,AA,AAA=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if trackstring==-1 or trackstring=="" then ultraschall.AddErrorMessage("SetTracksSelected", "trackstring", "must be a valid trackstring", -2) return -1 end
  local count, Aindividual_values = ultraschall.CSV2IndividualLinesAsArray(trackstring)
  if reset==true then ultraschall.SetAllTracksSelected(false) end
  for i=1,count do
     if Aindividual_values[i]-1<reaper.CountTracks(0) and Aindividual_values[i]-1>=0 then
       local MediaTrack=reaper.GetTrack(0,Aindividual_values[i]-1)
       reaper.SetTrackSelected(MediaTrack, true)
     end
  end
end

--L=ultraschall.SetTracksSelected(nil, true)


function ultraschall.IsTrackObjectTracknumber(MediaTrack, tracknumber)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsTrackObjectTracknumber</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, integer tracknumber = ultraschall.IsTrackObjectTracknumber(MediaTrack track, integer tracknumber)</functioncall>
  <description>
    returns true, if MediaTrack has the tracknumber "tracknumber"; false if not.
    Returns nil in case of error.
  </description>
  <parameters>
    MediaTrack track - the MediaTrack of which you want to check it's number
    integer tracknumber - the tracknumber you want to check for
  </parameters>
  <retvals>
    boolean retval - true if track is tracknumber, false if not
    integer tracknumber - the number of track, so in case of false, you know it's number
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, check, tracknumber, mediatrack, object</tags>
</US_DocBloc>
]]
--returns true, if MediaTrack=tracknumber, false if not; as well as the tracknumber of MediaTrack
--returns nil in case of error
    tracknumber=tonumber(tracknumber)
    if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("IsTrackObjectTracknumber","tracknumber", "must be an integer", -1) return nil end

    if tracknumber<1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("IsTrackObjectTracknumber","tracknumber", "no such track", -2) return nil end
    if reaper.ValidatePtr(MediaTrack, "MediaTrack*")==false then ultraschall.AddErrorMessage("IsTrackObjectTracknumber","track", "no valid MediaTrack-object", -3) return nil end
    local number=reaper.GetMediaTrackInfo_Value(MediaTrack, "IP_TRACKNUMBER")
    if number==tracknumber then return true, number
    else return false, number
    end
end

--A=ultraschall.IsTrackObjectTracknumber(reaper.GetTrack(0,0),1)

function ultraschall.InverseTrackstring(trackstring, limit)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>InverseTrackstring</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string inv_trackstring = ultraschall.InverseTrackstring(string trackstring, integer limit)</functioncall>
  <description>
    returns a newtrackstring with numbers, that are NOT in trackstring, in the range between 0 and limit
    returns -1 in case of error
  </description>
  <parameters>
    string trackstring - the tracknumbers, separated with a ,
    integer limit - the maximum tracknumber to include. Use reaper.CountTracks(0) function to use the maximum tracks in current project
  </parameters>
  <retvals>
    string inv_trackstring - the tracknumbers, that are NOT in the parameter trackstring, from 0 to limit
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, trackstring, inverse, tracknumber, tracknumbers, limit</tags>
</US_DocBloc>
]]
--returns a newtrackstring with numbers, that are NOT in trackstring, from 0 to limit
  local retval, trackstring, trackstringarray, number_of_entries = ultraschall.RemoveDuplicateTracksInTrackstring(trackstring) 
  if math.type(limit)~="integer" then ultraschall.AddErrorMessage("InverseTrackstring","limit", "must be an integer", -1) return -1 end
  limit=tonumber(limit)
  local newtrackstring=""
  local dingo
  if retval==-1 then ultraschall.AddErrorMessage("InverseTrackstring","trackstring", "not a valid trackstring", -2) return -1 end
  for i=1,limit do
    dingo=true
    for a=0,number_of_entries do
      if trackstringarray[a]==i then dingo=false break end
    end
    if dingo==true then newtrackstring=newtrackstring..i.."," end
  end
  return newtrackstring:sub(1,-2)
end


function ultraschall.SetTracksToLocked(trackstring, reset)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTracksToLocked</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetTracksToLocked(string trackstring, boolean reset)</functioncall>
  <description>
    sets tracks in trackstring locked. 
    returns false in case or error, true in case of success
  </description>
  <parameters>
    string trackstring - the tracknumbers, separated with a ,
    boolean reset - reset lockedstate of other tracks
    -true - resets the locked-state of all tracks not included in trackstring
    -false - the lockedstate of tracks not in trackstring is retained
  </parameters>
  <retvals>
    boolean retval - true in case of success, false in case of error
  </retvals>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, trackstring, lock, lockstate, lockedstate, locked, set</tags>
</US_DocBloc>
]]
  local retval, trackstring, trackstringarray, number_of_entries = ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if retval==-1 then ultraschall.AddErrorMessage("SetTracksToLocked","trackstring", "must be a valid trackstring", -1) return false end
  if type(reset)~="boolean" then ultraschall.AddErrorMessage("SetTracksToLocked","trackstring", "must be a boolean", -2) return false end
  for i=1,number_of_entries do
    local Aretval = ultraschall.SetTrackLockState(trackstringarray[i], 1)
  end
  if reset==true then 
    local newtrackstring=ultraschall.InverseTrackstring(trackstring,reaper.CountTracks(0))
    local retval, trackstring, trackstringarray, number_of_entries = ultraschall.RemoveDuplicateTracksInTrackstring(newtrackstring)
    for i=1,number_of_entries do
      local Aretval = ultraschall.SetTrackLockState(trackstringarray[i], 0)
    end
  end
  return true
end

--ultraschall.SetTracksToLocked("1,2,3,4", true)

function ultraschall.SetTracksToUnlocked(trackstring)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTracksToUnlocked</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetTracksToUnlocked(string trackstring)</functioncall>
  <description>
    sets tracks in trackstring unlocked. 
    returns false in case or error, true in case of success
  </description>
  <parameters>
    string trackstring - the tracknumbers, separated with a ,
  </parameters>
  <retvals>
    boolean retval - true in case of success, false in case of error
  </retvals>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, trackstring, lock, lockstate, lockedstate, locked, set, unlock, unlocked</tags>
</US_DocBloc>
]]
--sets tracks in trackstring unlocked.
--returns false in case or error, true in case of success
  local retval, trackstring, trackstringarray, number_of_entries = ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if retval==-1 then ultraschall.AddErrorMessage("SetTracksToUnlocked","trackstring", "must be a valid trackstring", -1) return false end
  for i=1,number_of_entries do
    local Aretval = ultraschall.SetTrackLockState(trackstringarray[i], 0)
  end
  return true
end


function ultraschall.GetAllLockedTracks()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllLockedTracks</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string locked_trackstring, string unlocked_trackstring = ultraschall.GetAllLockedTracks()</functioncall>
  <description>
    returns a trackstring with all tracknumbers of tracks, that are locked, as well as one with all tracknumbers of tracks, that are unlocked.
    returns an empty locked_trackstring, if none is locked, returns an empty unlocked_trackstring if all are locked.
  </description>
  <retvals>
    string locked_trackstring - the tracknumbers of all tracks, that are locked; empty string if none is locked
    string unlocked_trackstring - the tracknumbers of all tracks, that are NOT locked; empty string if all are locked
  </retvals>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, trackstring, lock, lockstate, lockedstate, locked, get</tags>
</US_DocBloc>
]]
--returns a trackstring with all locked tracks; empty string if none is locked
  local trackstring=""
  for i=1, reaper.CountTracks() do
    local lockedstate = ultraschall.GetTrackLockState(i)
    if lockedstate==1 then trackstring=trackstring..i.."," end
  end
  return trackstring:sub(1,-2), ultraschall.InverseTrackstring(trackstring, reaper.CountTracks(0))
end


function ultraschall.GetAllSelectedTracks()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllSelectedTracks</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string selected_trackstring, string unselected_trackstring = ultraschall.GetAllSelectedTracks()</functioncall>
  <description>
    returns a trackstring with all tracknumbers of tracks, that are selected, as well as one with all tracknumbers of tracks, that are unselected.
    returns an empty selected_trackstring, if none is selected, returns an empty unselected_trackstring if all are selected.
  </description>
  <retvals>
    string selected_trackstring - the tracknumbers of all tracks, that are selected; empty string if none is selected
    string unselected_trackstring - the tracknumbers of all tracks, that are NOT selected; empty string if all are selected
  </retvals>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, trackstring, selection, unselect, select, get</tags>
</US_DocBloc>
]]
  local trackstring=""
  for i=1, reaper.CountTracks() do
    MediaTrack=reaper.GetTrack(0,i-1)
    local selected = reaper.IsTrackSelected(MediaTrack)
    if selected==true then trackstring=trackstring..i.."," end
  end
  return trackstring:sub(1,-2), ultraschall.InverseTrackstring(trackstring, reaper.CountTracks(0))
end


--A,AA=ultraschall.GetAllSelectedTracks()



function ultraschall.GetTrackHWOut(tracknumber, idx, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackHWOut</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer outputchannel, integer post_pre_fader, number volume, number pan, integer mute, integer phase, integer source, number pan_law, integer automationmode = ultraschall.GetTrackHWOut(integer tracknumber, integer idx, optional string TrackStateChunk)</functioncall>
  <description>
    Returns the settings of the HWOUT-HW-destination, as set in the routing-matrix, as well as in the Destination "Controls for Track"-dialogue, of tracknumber. There can be more than one, which you can choose with idx.
    
    It's the entry HWOUT
    
    returns -1 in case of failure
  </description>
  <parameters markup_type="markdown" markup_version="1.0.1" indent="default">
    integer tracknumber - the number of the track, whose HWOut you want, 0 for Master Track
    integer idx - the id-number of the HWOut, beginning with 1 for the first HWOut-Settings
    optional string TrackStateChunk - a TrackStateChunk, whose HWOUT-entries you want to get
  </parameters>
  <retvals>
    integer outputchannel - outputchannel, with 1024+x the individual hw-outputchannels, 0,2,4,etc stereo output channels
    integer post_pre_fader - 0-post-fader(post pan), 1-preFX, 3-pre-fader(Post-FX), as set in the Destination "Controls for Track"-dialogue
    number volume - volume, as set in the Destination "Controls for Track"-dialogue; see [MKVOL2DB](#MKVOL2DB) to convert it into a dB-value
    number pan - pan, as set in the Destination "Controls for Track"-dialogue
    integer mute - mute, 1-on, 0-off, as set in the Destination "Controls for Track"-dialogue
    integer phase - Phase, 1-on, 0-off, as set in the Destination "Controls for Track"-dialogue
    integer source - source, as set in the Destination "Controls for Track"-dialogue
    -                                    -1 - None
    -                                     0 - Stereo Source 1/2
    -                                     4 - Stereo Source 5/6
    -                                    12 - New Channels On Sending Track Stereo Source Channel 13/14
    -                                    1024 - Mono Source 1
    -                                    1029 - Mono Source 6
    -                                    1030 - New Channels On Sending Track Mono Source Channel 7
    -                                    1032 - New Channels On Sending Track Mono Source Channel 9
    -                                    2048 - MultiChannel 4 Channels 1-4
    -                                    2050 - Multichannel 4 Channels 3-6
    -                                    3072 - Multichannel 6 Channels 1-6
    number pan_law - pan-law, as set in the dialog that opens, when you right-click on the pan-slider in the routing-settings-dialog; default is -1 for +0.0dB
    integer automationmode - automation mode, as set in the Destination "Controls for Track"-dialogue
    -                                    -1 - Track Automation Mode
    -                                     0 - Trim/Read
    -                                     1 - Read
    -                                     2 - Touch
    -                                     3 - Write
    -                                     4 - Latch
    -                                     5 - Latch Preview
  </retvals>
  <chapter_context>
    Track Management
    Hardware Out
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, get, hwout, routing, phase, source, mute, pan, volume, post, pre, fader, channel, automation, pan-law, trackstatechunk</tags>
</US_DocBloc>
]]
-- HWOUT %d %d %.14f %.14f %d %d %d %.14f:U %d
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackHWOut", "tracknumber", "must be an integer", -1) return -1 end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackHWOut", "tracknumber", "no such track", -2) return -1 end
  if math.type(idx)~="integer" then ultraschall.AddErrorMessage("GetTrackHWOut", "idx", "must be an integer", -3) return -1 end

  if tracknumber~=-1 then 
    local tr
    if tracknumber==0 then tr=reaper.GetMasterTrack(0)
    else tr=reaper.GetTrack(0,tracknumber-1) end
    
    if reaper.GetTrackNumSends(tr, 1)<idx then ultraschall.AddErrorMessage("GetTrackHWOut", "idx", "no such index available", -5) return -1 end
    local sendidx=idx
    return math.tointeger(reaper.GetTrackSendInfo_Value(tr, 1, sendidx-1, "I_DSTCHAN")), -- D1
           math.tointeger(reaper.GetTrackSendInfo_Value(tr, 1, sendidx-1, "I_SENDMODE")), -- D2
           reaper.GetTrackSendInfo_Value(tr, 1, sendidx-1, "D_VOL"),  -- D3
           reaper.GetTrackSendInfo_Value(tr, 1, sendidx-1, "D_PAN"),  -- D4
           math.tointeger(reaper.GetTrackSendInfo_Value(tr, 1, sendidx-1, "B_MUTE")), -- D5
           math.tointeger(reaper.GetTrackSendInfo_Value(tr, 1, sendidx-1, "B_PHASE")),-- D6
           math.tointeger(reaper.GetTrackSendInfo_Value(tr, 1, sendidx-1, "I_SRCCHAN")), -- D7
           reaper.GetTrackSendInfo_Value(tr, 1, sendidx-1, "D_PANLAW"), -- D8
           math.tointeger(reaper.GetTrackSendInfo_Value(tr, 1, sendidx-1, "I_AUTOMODE")) -- D9
  end
  
  if ultraschall.IsValidTrackStateChunk(TrackStateChunk)==false then ultraschall.AddErrorMessage("GetTrackHWOut", "TrackStateChunk", "must be a valid TrackStateChunk", -6) return -1 end
  if ultraschall.CountTrackHWOuts(-1, TrackStateChunk)<idx then ultraschall.AddErrorMessage("GetTrackHWOut", "idx", "no such entry", -7) return -1 end
  
  local count=1
  
  for k in string.gmatch(TrackStateChunk, "HWOUT.-\n") do
    if count==idx then 
      local count2, individual_values = ultraschall.CSV2IndividualLinesAsArray(k:match(" (.*)".." "), " ")
      table.remove(individual_values, count2)
      for i=1, count2-1 do
        if tonumber(individual_values[i])~=nil then individual_values[i]=tonumber(individual_values[i]) end
      end
      return table.unpack(individual_values)
    end
    count=count+1
  end
end

--L,LL = reaper.GetTrackStateChunk(reaper.GetTrack(0,0),"",false)
--A,B,C,D,E,F,G,H,I=ultraschall.GetTrackHWOut(1, 2, LL)

function ultraschall.GetTrackAUXSendReceives(tracknumber, idx, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackAUXSendReceives</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer recv_tracknumber, integer post_pre_fader, number volume, number pan, integer mute, integer mono_stereo, integer phase, integer chan_src, integer snd_chan, number pan_law, integer midichanflag, integer automation = ultraschall.GetTrackAUXSendReceives(integer tracknumber, integer idx, optional string TrackStateChunk)</functioncall>
  <description>
    Returns the settings of the Send/Receive, as set in the routing-matrix, as well as in the Destination "Controls for Track"-dialogue, of tracknumber. There can be more than one, which you can choose with idx.
    Remember, if you want to get the sends of a track, you need to check the recv_tracknumber-returnvalues of the OTHER(!) tracks, as you can only get the receives. With the receives checked, you know, which track sends.
    
    It's the entry AUXRECV
    
    returns -1 in case of failure
  </description>
  <parameters markup_type="markdown" markup_version="1.0.1" indent="default">
    integer tracknumber - the number of the track, whose Send/Receive you want
    integer idx - the id-number of the Send/Receive, beginning with 1 for the first Send/Receive-Settings
    optional string TrackStateChunk - a TrackStateChunk, whose AUXRECV-entries you want to get
  </parameters>
  <retvals markup_type="markdown" markup_version="1.0.1" indent="default">
    integer recv_tracknumber - Tracknumber, from where to receive the audio from
    integer post_pre_fader - 0-PostFader, 1-PreFX, 3-Pre-Fader
    number volume - Volume; see [MKVOL2DB](#MKVOL2DB) to convert it into a dB-value
    number pan - pan, as set in the Destination "Controls for Track"-dialogue; negative=left, positive=right, 0=center
    integer mute - Mute this send(1) or not(0)
    integer mono_stereo - Mono(1), Stereo(0)
    integer phase - Phase of this send on(1) or off(0)
    integer chan_src - Audio-Channel Source
    -                                        -1 - None
    -                                        0 - Stereo Source 1/2
    -                                        1 - Stereo Source 2/3
    -                                        2 - Stereo Source 3/4
    -                                        1024 - Mono Source 1
    -                                        1025 - Mono Source 2
    -                                        2048 - Multichannel Source 4 Channels 1-4
    integer snd_chan - send to channel
    -                                        0 - Stereo 1/2
    -                                        1 - Stereo 2/3
    -                                        2 - Stereo 3/4
    -                                        ...
    -                                        1024 - Mono Channel 1
    -                                        1025 - Mono Channel 2
    number pan_law - pan-law, as set in the dialog that opens, when you right-click on the pan-slider in the routing-settings-dialog; default is -1 for +0.0dB
    integer midichanflag -0 - All Midi Tracks
    -                                        1 to 16 - Midi Channel 1 to 16
    -                                        32 - send to Midi Channel 1
    -                                        64 - send to MIDI Channel 2
    -                                        96 - send to MIDI Channel 3
    -                                        ...
    -                                        512 - send to MIDI Channel 16
    -                                        4194304 - send to MIDI-Bus B1
    -                                        send to MIDI-Bus B1 + send to MIDI Channel nr = MIDIBus B1 1/nr:
    -                                        16384 - BusB1
    -                                        BusB1+1 to 16 - BusB1-Channel 1 to 16
    -                                        32768 - BusB2
    -                                        BusB2+1 to 16 - BusB2-Channel 1 to 16
    -                                        49152 - BusB3
    -                                        ...
    -                                        BusB3+1 to 16 - BusB3-Channel 1 to 16
    -                                        262144 - BusB16
    -                                        BusB16+1 to 16 - BusB16-Channel 1 to 16
    -
    -                                        1024 - Add that value to switch MIDI On
    -                                        4177951 - MIDI - None
    integer automation - Automation Mode
    -                                       -1 - Track Automation Mode
    -                                        0 - Trim/Read
    -                                        1 - Read
    -                                        2 - Touch
    -                                        3 - Write
    -                                        4 - Latch
    -                                        5 - Latch Preview
  </retvals>
  <chapter_context>
    Track Management
    Send/Receive-Routing
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, get, send, receive, phase, source, mute, pan, volume, post, pre, fader, channel, automation, midi, trackstatechunk, pan-law</tags>
</US_DocBloc>
]]

  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackAUXSendReceives", "tracknumber", "must be an integer", -1) return -1 end
  if tracknumber~=-1 and (tracknumber<1 or tracknumber>reaper.CountTracks(0)) then ultraschall.AddErrorMessage("GetTrackAUXSendReceives", "tracknumber", "no such track", -2) return -1 end
  if math.type(idx)~="integer" then ultraschall.AddErrorMessage("GetTrackAUXSendReceives", "idx", "must be an integer", -3) return -1 end
  if idx<1 then ultraschall.AddErrorMessage("GetTrackAUXSendReceives", "idx", "no such index available", -4) return -1 end

  if tracknumber~=-1 then 
    local tr=reaper.GetTrack(0,tracknumber-1)
    if reaper.GetTrackNumSends(tr, -1)<idx then ultraschall.AddErrorMessage("GetTrackAUXSendReceives", "idx", "no such index available", -5) return -1 end
    local sendidx=idx
    return math.tointeger(reaper.GetMediaTrackInfo_Value(reaper.BR_GetMediaTrackSendInfo_Track(tr, -1, sendidx-1, 0), "IP_TRACKNUMBER")-1)+1, -- D1
           math.tointeger(reaper.GetTrackSendInfo_Value(tr, -1, sendidx-1, "I_SENDMODE")), -- D2
           reaper.GetTrackSendInfo_Value(tr, -1, sendidx-1, "D_VOL"),  -- D3
           reaper.GetTrackSendInfo_Value(tr, -1, sendidx-1, "D_PAN"),  -- D4
           math.tointeger(reaper.GetTrackSendInfo_Value(tr, -1, sendidx-1, "B_MUTE")), -- D5
           math.tointeger(reaper.GetTrackSendInfo_Value(tr, -1, sendidx-1, "B_MONO")), -- D6
           math.tointeger(reaper.GetTrackSendInfo_Value(tr, -1, sendidx-1, "B_PHASE")),-- D7
           math.tointeger(reaper.GetTrackSendInfo_Value(tr, -1, sendidx-1, "I_SRCCHAN")), -- D8
           math.tointeger(reaper.GetTrackSendInfo_Value(tr, -1, sendidx-1, "I_DSTCHAN")), -- D9
           reaper.GetTrackSendInfo_Value(tr, -1, sendidx-1, "D_PANLAW"), -- D10
           math.tointeger(reaper.GetTrackSendInfo_Value(tr, -1, sendidx-1, "I_MIDIFLAGS")), -- D11
           math.tointeger(reaper.GetTrackSendInfo_Value(tr, -1, sendidx-1, "I_AUTOMODE")) -- D12  
  end
  if ultraschall.IsValidTrackStateChunk(TrackStateChunk)==false then ultraschall.AddErrorMessage("GetTrackAUXSendReceives", "TrackStateChunk", "must be a valid TrackStateChunk", -6) return -1 end
  if ultraschall.CountTrackAUXSendReceives(-1, TrackStateChunk)<idx then ultraschall.AddErrorMessage("GetTrackAUXSendReceives", "idx", "no such entry", -7) return -1 end
  
  local count=1
  
  for k in string.gmatch(TrackStateChunk, "AUXRECV.-\n") do
    if count==idx then 
      local count2, individual_values = ultraschall.CSV2IndividualLinesAsArray(k:match(" (.*)".." "), " ")
      table.remove(individual_values, count2)
      for i=1, count2-1 do
        if tonumber(individual_values[i])~=nil then individual_values[i]=tonumber(individual_values[i]) end
      end
      individual_values[1]=individual_values[1]+1
      individual_values[10]=tonumber(individual_values[10]:sub(1,-3))
      return table.unpack(individual_values)
    end
    count=count+1
  end
end


function ultraschall.CountTrackHWOuts(tracknumber, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CountTrackHWOuts</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer count_HWOuts = ultraschall.CountTrackHWOuts(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    Counts and returns the number of existing HWOUT-HW-destination, as set in the routing-matrix, as well as in the Destination "Controls for Track"-dialogue, of tracknumber.
    returns -1 in case of failure
  </description>
  <parameters>
    integer tracknumber - the number of the track, whose HWOUTs you want to count. 0 for Master Track; -1, to use optional parameter TrackStateChunk instead
    optional string TrackStateChunk - the TrackStateChunk, whose hwouts you want to count; only when tracknumber=-1
  </parameters>
  <retvals>
    integer count_HWOuts - the number of HWOuts in tracknumber
  </retvals>
  <chapter_context>
    Track Management
    Hardware Out
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, get, count, hwout, routing, trackstatechunk</tags>
</US_DocBloc>
]]
  local Track, A
  if tracknumber>-1 then
    if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("CountTrackHWOuts", "tracknumber", "must be an integer", -1) return -1 end
    if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("CountTrackHWOuts", "tracknumber", "no such track", -2) return -1 end
    Track=reaper.GetTrack(0,tracknumber-1)
    if tracknumber==0 then Track=reaper.GetMasterTrack(0) end
--    if Track==nil then return -1 end  
--    A,TrackStateChunk=ultraschall.GetTrackStateChunk(Track,"",true)
    return reaper.GetTrackNumSends(Track, 1)
  elseif tracknumber==-1 then
    if ultraschall.IsValidTrackStateChunk(TrackStateChunk)==false then ultraschall.AddErrorMessage("CountTrackHWOuts", "TrackStateChunk", "must be a valid TrackStateChunk", -3) return -1 end
  else
    ultraschall.AddErrorMessage("CountTrackHWOuts", "tracknumber", "no such track", -4)
    return -1
  end
  local TrackStateChunkArray={}
  local count=1
  while TrackStateChunk:match("HWOUT")=="HWOUT" do
    TrackStateChunkArray[count]=TrackStateChunk:match("HWOUT.-%c")
    TrackStateChunk=TrackStateChunk:match("HWOUT.-%c(.*)")
    count=count+1
  end
  return count-1, TrackStateChunkArray
end


function ultraschall.CountTrackAUXSendReceives(tracknumber, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CountTrackAUXSendReceives</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer count_SendReceives = ultraschall.CountTrackAUXSendReceives(integer tracknumber, optional string TrackStateChunk)</functioncall>
  <description>
    Counts and returns the number of existing Send/Receives/Routing-settings, as set in the routing-matrix, as well as in the Destination "Controls for Track"-dialogue, of tracknumber.
    returns -1 in case of failure
  </description>
  <parameters>
    integer tracknumber - the number of the track, whose Send/Receive you want; -1, if you want to pass a TrackStateChunk instead
    optional string TrackStateChunk - the TrackStateChunk, whose hwouts you want to count; only when tracknumber=-1
  </parameters>
  <retvals>
    integer count_SendReceives - the number of Send/Receives-Settings in tracknumber
  </retvals>
  <chapter_context>
    Track Management
    Send/Receive-Routing
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, get, count, send, receive, routing, trackstatechunk</tags>
</US_DocBloc>
]]
  local A, Track
  if tracknumber>-1 then
    if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("CountTrackAUXSendReceives", "tracknumber", "must be an integer", -1) return -1 end
    if tracknumber<1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("CountTrackAUXSendReceives", "tracknumber", "no such track", -2) return -1 end
    Track=reaper.GetTrack(0,tracknumber-1)
    if Track==nil then ultraschall.AddErrorMessage("CountTrackAUXSendReceives", "tracknumber", "no such track", -3) return -1 end
    A,TrackStateChunk=ultraschall.GetTrackStateChunk(Track,"",true)
  elseif tracknumber==-1 then
    if ultraschall.IsValidTrackStateChunk(TrackStateChunk)==false then ultraschall.AddErrorMessage("CountTrackAUXSendReceives", "TrackStateChunk", "must be a valid TrackStateChunk", -4) return -1 end
  else
    ultraschall.AddErrorMessage("CountTrackAUXSendReceives", "tracknumber", "no such track", -5)
    return -1
  end
  
  
  local TrackStateChunkArray={}
  local count=1
  while TrackStateChunk:match("AUXRECV")=="AUXRECV" do
    TrackStateChunkArray[count]=TrackStateChunk:match("AUXRECV.-%c")
    TrackStateChunk=TrackStateChunk:match("AUXRECV.-%c(.*)")
    count=count+1
  end
  return count-1, TrackStateChunkArray
end


function ultraschall.AddTrackHWOut(tracknumber, outputchannel, post_pre_fader, volume, pan, mute, phase, source, pan_law, automationmode, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AddTrackHWOut</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, optional string TrackStateChunk = ultraschall.AddTrackHWOut(integer tracknumber, integer outputchannel, integer post_pre_fader, number volume, number pan, integer mute, integer phase, integer source, number pan_law, integer automationmode, optional parameter TrackStateChunk)</functioncall>
  <description>
    Adds a setting of the HWOUT-HW-destination, as set in the routing-matrix, as well as in the Destination "Controls for Track"-dialogue, of tracknumber.
    This function does not check the parameters for plausability, so check your settings twice!
    
    returns false in case of failure
  </description>
  <parameters markup_type="markdown" markup_version="1.0.1" indent="default">
    integer tracknumber - the number of the track, whose HWOut you want. 0 for Master Track; -1, use parameter TrackStateChunk instead
    integer outputchannel - outputchannel, with 1024+x the individual hw-outputchannels, 0,2,4,etc stereo output channels
    integer post_pre_fader - 0-post-fader(post pan), 1-preFX, 3-pre-fader(Post-FX), as set in the Destination "Controls for Track"-dialogue
    number volume - volume, as set in the Destination "Controls for Track"-dialogue; see [DB2MKVOL](#DB2MKVOL) to convert from a dB-value
    number pan - pan, as set in the Destination "Controls for Track"-dialogue
    integer mute - mute, 1-on, 0-off, as set in the Destination "Controls for Track"-dialogue
    integer phase - Phase, 1-on, 0-off, as set in the Destination "Controls for Track"-dialogue
    integer source - source, as set in the Destination "Controls for Track"-dialogue
    -                                    -1 - None
    -                                     0 - Stereo Source 1/2
    -                                     4 - Stereo Source 5/6
    -                                    12 - New Channels On Sending Track Stereo Source Channel 13/14
    -                                    1024 - Mono Source 1
    -                                    1029 - Mono Source 6
    -                                    1030 - New Channels On Sending Track Mono Source Channel 7
    -                                    1032 - New Channels On Sending Track Mono Source Channel 9
    -                                    2048 - MultiChannel 4 Channels 1-4
    -                                    2050 - Multichannel 4 Channels 3-6
    -                                    3072 - Multichannel 6 Channels 1-6
    number pan_law - pan-law, as set in the dialog that opens, when you right-click on the pan-slider in the routing-settings-dialog; default is -1 for +0.0dB
    integer automationmode - automation mode, as set in the Destination "Controls for Track"-dialogue
    -                                    -1 - Track Automation Mode
    -                                     0 - Trim/Read
    -                                     1 - Read
    -                                     2 - Touch
    -                                     3 - Write
    -                                     4 - Latch
    -                                     5 - Latch Preview
    optional parameter TrackStateChunk - a TrackStateChunk into which to add the hwout-setting; only available, when tracknumber=-1
  </parameters>
  <retvals>
    boolean retval - true, if it worked; false if it didn't
    optional parameter TrackStateChunk - an altered TrackStateChunk into which you added the new hwout-setting
  </retvals>
  <chapter_context>
    Track Management
    Hardware Out
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, add, hwout, routing, phase, source, mute, pan, volume, post, pre, fader, channel, automation, pan-law, trackstatechunk</tags>
</US_DocBloc>
]]
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("AddTrackHWOut", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("AddTrackHWOut", "tracknumber", "no such track", -2) return false end
  if math.type(outputchannel)~="integer" then ultraschall.AddErrorMessage("AddTrackHWOut", "outputchannel", "must be an integer", -3) return false end
  if math.type(post_pre_fader)~="integer" then ultraschall.AddErrorMessage("AddTrackHWOut", "post_pre_fader", "must be an integer", -4) return false end
  if type(volume)~="number" then ultraschall.AddErrorMessage("AddTrackHWOut", "volume", "must be a number", -5) return false end
  if type(pan)~="number" then ultraschall.AddErrorMessage("AddTrackHWOut", "pan", "must be a number", -6) return false end
  if math.type(mute)~="integer" then ultraschall.AddErrorMessage("AddTrackHWOut", "mute", "must be an integer", -7) return false end
  if math.type(phase)~="integer" then ultraschall.AddErrorMessage("AddTrackHWOut", "phase", "must be an integer", -8) return false end
  if math.type(source)~="integer" then ultraschall.AddErrorMessage("AddTrackHWOut", "source", "must be an integer", -9) return false end
  if type(pan_law)~="number" then ultraschall.AddErrorMessage("AddTrackHWOut", "pan_law", "must be a number", -10) return false end
  if math.type(automationmode)~="integer" then ultraschall.AddErrorMessage("AddTrackHWOut", "automationmode", "must be an integer", -11) return false end

  if tracknumber>-1 then
    -- get track
    if tracknumber==0 then tr=reaper.GetMasterTrack(0)
    else tr=reaper.GetTrack(0,tracknumber-1) end
    -- create new hwout
    local sendidx=reaper.CreateTrackSend(tr, nil)
    -- change it's settings
    reaper.SetTrackSendInfo_Value(tr, 1, sendidx, "I_DSTCHAN", outputchannel) -- D2
    reaper.SetTrackSendInfo_Value(tr, 1, sendidx, "I_SENDMODE", post_pre_fader) -- D2
    reaper.SetTrackSendInfo_Value(tr, 1, sendidx, "D_VOL", volume)  -- D3
    reaper.SetTrackSendInfo_Value(tr, 1, sendidx, "D_PAN", pan)  -- D4
    reaper.SetTrackSendInfo_Value(tr, 1, sendidx, "B_MUTE", mute) -- D5
    reaper.SetTrackSendInfo_Value(tr, 1, sendidx, "B_PHASE", phase)-- D6
    reaper.SetTrackSendInfo_Value(tr, 1, sendidx, "I_SRCCHAN", source) -- D7
    reaper.SetTrackSendInfo_Value(tr, 1, sendidx, "D_PANLAW", pan_law) -- D8
    reaper.SetTrackSendInfo_Value(tr, 1, sendidx, "I_AUTOMODE", automationmode) -- D9
    return true
  end
  
  -- if dealing with a TrackStateChunk, then do the following
  if ultraschall.IsValidTrackStateChunk(TrackStateChunk)==false then ultraschall.AddErrorMessage("AddTrackHWOut", "TrackStateChunk", "must be a valid TrackStateChunk", -13) return false end
  local Startoffs=TrackStateChunk:match("MAINSEND .-\n()")
  
  TrackStateChunk=TrackStateChunk:sub(1,Startoffs-1)..
                  "HWOUT "..outputchannel.." "..post_pre_fader.." "..volume.." "..pan.." "..mute.." "..phase.." "..source.." "..pan_law..":U "..automationmode.."\n"..
                  TrackStateChunk:sub(Startoffs,-1)
                  
  return true, TrackStateChunk
end


function ultraschall.AddTrackAUXSendReceives(tracknumber, recv_tracknumber, post_pre_fader, volume, pan, mute, mono_stereo, phase, chan_src, snd_chan, pan_law, midichanflag, automation, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AddTrackAUXSendReceives</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.975
    Lua=5.3
  </requires>
  <functioncall>boolean retval, optional string TrackStateChunk = ultraschall.AddTrackAUXSendReceives(integer tracknumber, integer recv_tracknumber, integer post_pre_fader, number volume, number pan, integer mute, integer mono_stereo, integer phase, integer chan_src, integer snd_chan, number pan_law, integer midichanflag, integer automation, optional string TrackStateChunk)</functioncall>
  <description>
    Adds a setting of Send/Receive, as set in the routing-matrix, as well as in the Destination "Controls for Track"-dialogue, of tracknumber. There can be more than one.
    Remember, if you want to set the sends of a track, you need to add it to the track, that shall receive, not the track that sends! Set recv_tracknumber in the track that receives with the tracknumber that sends, and you've set it successfully.
    
    Due to the complexity of send/receive-settings, this function does not check, whether the parameters are plausible. So check twice, whether the added sends/receives appear, as they might not appear!
    returns false in case of failure
  </description>
  <parameters markup_type="markdown" markup_version="1.0.1" indent="default">
    integer tracknumber - the number of the track, whose Send/Receive you want; -1, if you want to use the parameter TrackStateChunk
    integer recv_tracknumber - Tracknumber, from where to receive the audio from
    integer post_pre_fader - 0-PostFader, 1-PreFX, 3-Pre-Fader
    number volume - Volume, see [DB2MKVOL](#DB2MKVOL) to convert from a dB-value
    number pan - pan, as set in the Destination "Controls for Track"-dialogue; negative=left, positive=right, 0=center
    integer mute - Mute this send(1) or not(0)
    integer mono_stereo - Mono(1), Stereo(0)
    integer phase - Phase of this send on(1) or off(0)
    integer chan_src - Audio-Channel Source
    -                                       -1 - None
    -                                        0 - Stereo Source 1/2
    -                                        1 - Stereo Source 2/3
    -                                        2 - Stereo Source 3/4
    -                                        1024 - Mono Source 1
    -                                        1025 - Mono Source 2
    -                                        2048 - Multichannel Source 4 Channels 1-4
    integer snd_chan - send to channel
    -                                        0 - Stereo 1/2
    -                                        1 - Stereo 2/3
    -                                        2 - Stereo 3/4
    -                                        ...
    -                                        1024 - Mono Channel 1
    -                                        1025 - Mono Channel 2
    number pan_law - pan-law, as set in the dialog that opens, when you right-click on the pan-slider in the routing-settings-dialog; default is -1 for +0.0dB
    integer midichanflag -0 - All Midi Tracks
    -                                        1 to 16 - Midi Channel 1 to 16
    -                                        32 - send to Midi Channel 1
    -                                        64 - send to MIDI Channel 2
    -                                        96 - send to MIDI Channel 3
    -                                        ...
    -                                        512 - send to MIDI Channel 16    
    -                                        4194304 - send to MIDI-Bus B1
    -                                        send to MIDI-Bus B1 + send to MIDI Channel nr = MIDIBus B1 1/nr:
    -                                        16384 - BusB1
    -                                        BusB1+1 to 16 - BusB1-Channel 1 to 16
    -                                        32768 - BusB2
    -                                        BusB2+1 to 16 - BusB2-Channel 1 to 16
    -                                        49152 - BusB3
    -                                        ...
    -                                        BusB3+1 to 16 - BusB3-Channel 1 to 16
    -                                        262144 - BusB16
    -                                        BusB16+1 to 16 - BusB16-Channel 1 to 16
    -
    -                                        1024 - Add that value to switch MIDI On
    -                                        4177951 - MIDI - None
    integer automation - Automation Mode
    -                                       -1 - Track Automation Mode
    -                                        0 - Trim/Read
    -                                        1 - Read
    -                                        2 - Touch
    -                                        3 - Write
    -                                        4 - Latch
    -                                        5 - Latch Preview
    optional string TrackStateChunk - the TrackStateChunk, to which you want to add a new receive-routing
  </parameters>
  <retvals>
    boolean retval - true if it worked, false if it didn't.
    optional parameter TrackStateChunk - an altered TrackStateChunk into which you added a new receive/routing; only available, when tracknumber=-1
  </retvals>
  <chapter_context>
    Track Management
    Send/Receive-Routing
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, add, send, receive, phase, source, mute, pan, volume, post, pre, fader, channel, automation, midi, pan-law, trackstatechunk</tags>
</US_DocBloc>
]]
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("AddTrackAUXSendReceives", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("AddTrackAUXSendReceives", "tracknumber", "no such track", -2) return false end
  if math.type(recv_tracknumber)~="integer" then ultraschall.AddErrorMessage("AddTrackAUXSendReceives", "recv_tracknumber", "must be an integer", -3) return false end
  if math.type(post_pre_fader)~="integer" then ultraschall.AddErrorMessage("AddTrackAUXSendReceives", "post_pre_fader", "must be an integer", -4) return false end
  if type(volume)~="number" then ultraschall.AddErrorMessage("AddTrackAUXSendReceives", "volume", "must be a number", -5) return false end
  if type(pan)~="number" then ultraschall.AddErrorMessage("AddTrackAUXSendReceives", "pan", "must be a number", -6) return false end
  if math.type(mute)~="integer" then ultraschall.AddErrorMessage("AddTrackAUXSendReceives", "mute", "must be an integer", -7) return false end
  if math.type(mono_stereo)~="integer" then ultraschall.AddErrorMessage("AddTrackAUXSendReceives", "mono_stereo", "must be an integer", -8) return false end
  if math.type(phase)~="integer" then ultraschall.AddErrorMessage("AddTrackAUXSendReceives", "phase", "must be an integer", -9) return false end
  if math.type(chan_src)~="integer" then ultraschall.AddErrorMessage("AddTrackAUXSendReceives", "chan_src", "must be a number", -10) return false end
  if math.type(snd_chan)~="integer" then ultraschall.AddErrorMessage("AddTrackAUXSendReceives", "snd_chan", "must be an integer", -11) return false end
  if type(pan_law)~="number" then ultraschall.AddErrorMessage("AddTrackAUXSendReceives", "pan_law", "must be a number", -12) return false end
  if math.type(midichanflag)~="integer" then ultraschall.AddErrorMessage("AddTrackAUXSendReceives", "midichanflag", "must be an integer", -13) return false end
  if math.type(automation)~="integer" then ultraschall.AddErrorMessage("AddTrackAUXSendReceives", "automation", "must be an integer", -14) return false end

  if tracknumber>-1 then
    -- get track
    if tracknumber==0 then tr=reaper.GetMasterTrack(0)
    else tr=reaper.GetTrack(0,recv_tracknumber-1) end
    -- create new AUXRecv
    local sendidx=reaper.CreateTrackSend(tr, reaper.GetTrack(0,tracknumber-1))
    -- change it's settings
      reaper.SetTrackSendInfo_Value(tr, 0, sendidx, "I_SENDMODE", post_pre_fader) -- D2
      reaper.SetTrackSendInfo_Value(tr, 0, sendidx, "D_VOL", volume)  -- D3
      reaper.SetTrackSendInfo_Value(tr, 0, sendidx, "D_PAN", pan)  -- D4
      reaper.SetTrackSendInfo_Value(tr, 0, sendidx, "B_MUTE", mute) -- D5
      reaper.SetTrackSendInfo_Value(tr, 0, sendidx, "B_MONO", mono_stereo) -- D6
      reaper.SetTrackSendInfo_Value(tr, 0, sendidx, "B_PHASE", phase)-- D7
      reaper.SetTrackSendInfo_Value(tr, 0, sendidx, "I_SRCCHAN", chan_src) -- D8
      reaper.SetTrackSendInfo_Value(tr, 0, sendidx, "I_DSTCHAN", snd_chan) -- D9
      reaper.SetTrackSendInfo_Value(tr, 0, sendidx, "D_PANLAW", pan_law) -- D10
      reaper.SetTrackSendInfo_Value(tr, 0, sendidx, "I_MIDIFLAGS", midichanflag) -- D11
      reaper.SetTrackSendInfo_Value(tr, 0, sendidx, "I_AUTOMODE", automation) -- D12  
    return true
  end
  
  if ultraschall.IsValidTrackStateChunk(TrackStateChunk)==false then ultraschall.AddErrorMessage("AddTrackAUXSendReceives", "TrackStateChunk", "must be a valid TrackStateChunk", -16) return false end
  -- if dealing with a TrackStateChunk, then do the following
  local Startoffs=TrackStateChunk:match("PERF .-\n()")
  
  TrackStateChunk=TrackStateChunk:sub(1,Startoffs-1)..
                  "AUXRECV "..(recv_tracknumber-1).." "..post_pre_fader.." "..volume.." "..pan.." "..mute.." "..mono_stereo.." "..
                  phase.." "..chan_src.." "..snd_chan.." "..pan_law..":U "..midichanflag.." "..automation.." ''".."\n"..
                  TrackStateChunk:sub(Startoffs,-1)
                  
  return true, TrackStateChunk
end


function ultraschall.DeleteTrackHWOut(tracknumber, idx, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DeleteTrackHWOut</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>boolean retval, optional string TrackStateChunk = ultraschall.DeleteTrackHWOut(integer tracknumber, integer idx, optional string TrackStateChunk)</functioncall>
  <description>
    Deletes the idxth HWOut-Setting of tracknumber.
    returns false in case of failure
  </description>
  <parameters>
    integer tracknumber - the number of the track, whose HWOUTs you want to delete. 0 for Master Track. -1, if you want to use the parameter TrackStateChunk instead
    integer idx - the number of the HWOut-setting, that you want to delete; -1, to delete all HWOuts from this track
    optional string TrackStateChunk - the TrackStateChunk, from which you want to delete HWOut-entries
  </parameters>
  <retvals>
    boolean retval - true if it worked, false if it didn't.
    optional string TrackStateChunk - the altered TrackStateChunk, from which you deleted HWOut-entries; only available, when tracknumber=-1
  </retvals>
  <chapter_context>
    Track Management
    Hardware Out
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, delete, hwout, routing, trackstatechunk</tags>
</US_DocBloc>
]]
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("DeleteTrackHWOut", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("DeleteTrackHWOut", "tracknumber", "no such track", -2) return false end
  if math.type(idx)~="integer" then ultraschall.AddErrorMessage("DeleteTrackHWOut", "idx", "must be an integer", -3) return false end
  local Track, A, undo
  undo=false
  if tracknumber>-1 then
    Track=reaper.GetTrack(0,tracknumber-1)
    if tracknumber==0 then Track=reaper.GetMasterTrack(0) end
    A,TrackStateChunk=ultraschall.GetTrackStateChunk(Track,"",true)
    if idx==-1 then return reaper.SetTrackStateChunk(Track, string.gsub(TrackStateChunk, "HWOUT.-\n", ""), undo) end
  elseif ultraschall.IsValidTrackStateChunk(TrackStateChunk)==false then ultraschall.AddErrorMessage("DeleteTrackHWOut", "TrackStateChunk", "must be a valid TrackStateChunk", -5) return false
  else
    if idx==-1 then return true, string.gsub(TrackStateChunk, "HWOUT.-\n", "") end
  end  
  local B,C=ultraschall.CountTrackHWOuts(-1, TrackStateChunk)
  local finalstring=""  
  local Begin
  local Ending
  
  local count, split_string = ultraschall.SplitStringAtLineFeedToArray(TrackStateChunk)
  local count2=0
  for i=1, count do
    if split_string[i]:match("HWOUT")==nil then
      finalstring=finalstring..split_string[i].."\n"
    else
      count2=count2+1
      if count2~=idx then 
        finalstring=finalstring..split_string[i].."\n"
      end
    end
  end
  
  if tracknumber>-1 then 
    return reaper.SetTrackStateChunk(Track, finalstring, undo)
  else
    return true, finalstring
  end
end


function ultraschall.DeleteTrackAUXSendReceives(tracknumber, idx, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DeleteTrackAUXSendReceives</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.DeleteTrackAUXSendReceives(integer tracknumber, integer idx, optional string TrackStateChunk)</functioncall>
  <description>
    Deletes the idxth Send/Receive-Setting of tracknumber.
    returns false in case of failure
  </description>
  <parameters>
    integer tracknumber - the number of the track, whose Send/Receive you want; -1, if you want to use the parameter TrackStateChunk
    integer idx - the number of the send/receive-setting, that you want to delete; -1, deletes all AuxReceives on this track
    optional string TrackStateChunk - a TrackStateChunk, from which you want to delete Send/Receive-entries; only available, when tracknumber=-1
  </parameters>
  <retvals>
    boolean retval - true if it worked, false if it didn't.
    optional string TrackStateChunk - an altered TrackStateChunk, from which you deleted a Send/Receive-entrie; only available, when tracknumber=-1
  </retvals>
  <chapter_context>
    Track Management
    Send/Receive-Routing
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, delete, send, receive, routing, trackstatechunk</tags>
</US_DocBloc>
]]
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("DeleteTrackAUXSendReceives", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("DeleteTrackAUXSendReceives", "tracknumber", "no such track", -2) return false end
  if math.type(idx)~="integer" then ultraschall.AddErrorMessage("DeleteTrackAUXSendReceives", "idx", "must be an integer", -3) return false end
  local Track, A, undo
  undo=false
  if tracknumber>-1 then
    Track=reaper.GetTrack(0,tracknumber-1)
    if tracknumber==0 then Track=reaper.GetMasterTrack(0) end  
    A,TrackStateChunk=ultraschall.GetTrackStateChunk(Track,"",true)
    if idx==-1 then return reaper.SetTrackStateChunk(Track, string.gsub(TrackStateChunk, "AUXRECV.-\n", ""), undo) end
  elseif ultraschall.IsValidTrackStateChunk(TrackStateChunk)==false then ultraschall.AddErrorMessage("DeleteTrackAUXSendReceives", "TrackStateChunk", "must be a valid TrackStateChunk", -5) return false
  else
    if idx==-1 then return true, string.gsub(TrackStateChunk, "AUXRECV.-\n", "") end
  end
  local B,C=ultraschall.CountTrackAUXSendReceives(-1, TrackStateChunk)
  local finalstring=""  
  local Begin
  local Ending  
  
  if B<=0 then Begin=TrackStateChunk:match("(.-PERF.-%c)")
  else Begin=TrackStateChunk:match("(.-)AUXRECV.-%c")
  end
  if B<=0 then Ending=TrackStateChunk:match(".*PERF.-%c(.*)")
  else Ending=TrackStateChunk:match(".*AUXRECV.-%c(.*)")
  end
  
  finalstring=Begin
  for i=1,B do
    if idx~=i then 
      finalstring=finalstring..C[i] 
    end
  end
  finalstring=finalstring..Ending
  if tracknumber~=-1 then
    return reaper.SetTrackStateChunk(Track, finalstring, undo)
  else
    return true, finalstring
  end
end

function ultraschall.SetTrackHWOut(tracknumber, idx, outputchannel, post_pre_fader, volume, pan, mute, phase, source, pan_law, automationmode, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackHWOut</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, optional string TrackStateChunk = ultraschall.SetTrackHWOut(integer tracknumber, integer idx, integer outputchannel, integer post_pre_fader, number volume, number pan, integer mute, integer phase, integer source, number pan_law, integer automationmode, optional string TrackStateChunk)</functioncall>
  <description>
    Sets a setting of the HWOUT-HW-destination, as set in the routing-matrix, as well as in the Destination "Controls for Track"-dialogue, of tracknumber. There can be more than one, so choose the one you want to change with idx.
    To retain old-settings, use nil with the accompanying parameters.
    This function does not check the parameters for plausability, so check your settings twice, or the HWOut-setting might disappear with faulty parameters!
    
    returns false in case of failure
  </description>
  <parameters markup_type="markdown" markup_version="1.0.1" indent="default">
    integer tracknumber - the number of the track, whose HWOut you want. 0 for Master Track
    integer idx - the number of the HWOut-setting, you want to change
    integer outputchannel - outputchannel, with 1024+x the individual hw-outputchannels, 0,2,4,etc stereo output channels
    integer post_pre_fader - 0-post-fader(post pan), 1-preFX, 3-pre-fader(Post-FX), as set in the Destination "Controls for Track"-dialogue
    number volume - volume, as set in the Destination "Controls for Track"-dialogue; see [DB2MKVOL](#DB2MKVOL) to convert from a dB-value
    number pan - pan, as set in the Destination "Controls for Track"-dialogue
    integer mute - mute, 1-on, 0-off, as set in the Destination "Controls for Track"-dialogue
    integer phase - Phase, 1-on, 0-off, as set in the Destination "Controls for Track"-dialogue
    integer source - source, as set in the Destination "Controls for Track"-dialogue
    -                                    -1 - None
    -                                     0 - Stereo Source 1/2
    -                                     4 - Stereo Source 5/6
    -                                    12 - New Channels On Sending Track Stereo Source Channel 13/14
    -                                    1024 - Mono Source 1
    -                                    1029 - Mono Source 6
    -                                    1030 - New Channels On Sending Track Mono Source Channel 7
    -                                    1032 - New Channels On Sending Track Mono Source Channel 9
    -                                    2048 - MultiChannel 4 Channels 1-4
    -                                    2050 - Multichannel 4 Channels 3-6
    -                                    3072 - Multichannel 6 Channels 1-6
    number pan_law - pan-law, as set in the dialog that opens, when you right-click on the pan-slider in the routing-settings-dialog; default is -1 for +0.0dB
    integer automationmode - automation mode, as set in the Destination "Controls for Track"-dialogue
    -                                    -1 - Track Automation Mode
    -                                     0 - Trim/Read
    -                                     1 - Read
    -                                     2 - Touch
    -                                     3 - Write
    -                                     4 - Latch
    -                                     5 - Latch Preview
    optional string TrackStateChunk - sets an HWOUT-entry in a TrackStateChunk
  </parameters>
  <retvals>
    boolean retval - true, if it worked; false if it didn't
    optional string TrackStateChunk - an altered TrackStateChunk, in which you've set a send/receive-setting; only available when track=-1
  </retvals>
  <chapter_context>
    Track Management
    Hardware Out
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, hwout, routing, phase, source, mute, pan, volume, post, pre, fader, channel, automation, pan-law, trackstatechunk</tags>
</US_DocBloc>
]]
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackHWOut", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackHWOut", "tracknumber", "no such track", -2) return false end
  if math.type(idx)~="integer" then ultraschall.AddErrorMessage("SetTrackHWOut", "idx", "must be an integer", -13) return false end
  if idx<1 then ultraschall.AddErrorMessage("SetTrackHWOut", "idx", "no such index", -14) return false end
  if math.type(outputchannel)~="integer" then ultraschall.AddErrorMessage("SetTrackHWOut", "outputchannel", "must be an integer", -3) return false end
  if math.type(post_pre_fader)~="integer" then ultraschall.AddErrorMessage("SetTrackHWOut", "post_pre_fader", "must be an integer", -4) return false end
  if type(volume)~="number" then ultraschall.AddErrorMessage("SetTrackHWOut", "volume", "must be a number", -5) return false end
  if type(pan)~="number" then ultraschall.AddErrorMessage("SetTrackHWOut", "pan", "must be a number", -6) return false end
  if math.type(mute)~="integer" then ultraschall.AddErrorMessage("SetTrackHWOut", "mute", "must be an integer", -7) return false end
  if math.type(phase)~="integer" then ultraschall.AddErrorMessage("SetTrackHWOut", "phase", "must be an integer", -8) return false end
  if math.type(source)~="integer" then ultraschall.AddErrorMessage("SetTrackHWOut", "source", "must be an integer", -9) return false end
  if type(pan_law)~="number" then ultraschall.AddErrorMessage("SetTrackHWOut", "pan_law", "must be a number", -10) return false end
  if math.type(automationmode)~="integer" then ultraschall.AddErrorMessage("SetTrackHWOut", "automationmode", "must be an integer", -11) return false end
  
  if tracknumber~=-1 then
    local tr
    if tracknumber==0 then tr=reaper.GetMasterTrack(0)
    else tr=reaper.GetTrack(0,tracknumber-1) end
    if idx>reaper.GetTrackNumSends(tr, 1) then ultraschall.AddErrorMessage("SetTrackHWOut", "idx", "no such index", -15) return false end
    sendidx=idx
    reaper.SetTrackSendInfo_Value(tr, 1, sendidx-1, "I_DSTCHAN", outputchannel) -- D2
    reaper.SetTrackSendInfo_Value(tr, 1, sendidx-1, "I_SENDMODE", post_pre_fader) -- D2
    reaper.SetTrackSendInfo_Value(tr, 1, sendidx-1, "D_VOL", volume)  -- D3
    reaper.SetTrackSendInfo_Value(tr, 1, sendidx-1, "D_PAN", pan)  -- D4
    reaper.SetTrackSendInfo_Value(tr, 1, sendidx-1, "B_MUTE", mute) -- D5
    reaper.SetTrackSendInfo_Value(tr, 1, sendidx-1, "B_PHASE", phase)-- D6
    reaper.SetTrackSendInfo_Value(tr, 1, sendidx-1, "I_SRCCHAN", source) -- D7
    reaper.SetTrackSendInfo_Value(tr, 1, sendidx-1, "D_PANLAW", pan_law) -- D8
    reaper.SetTrackSendInfo_Value(tr, 1, sendidx-1, "I_AUTOMODE", automationmode) -- D9
    return true
  end  
  if ultraschall.IsValidTrackStateChunk(TrackStateChunk)==false then ultraschall.AddErrorMessage("SetTrackHWOut", "TrackStateChunk", "must be a valid TrackStateChunk", -16) return false end
  if ultraschall.CountTrackHWOuts(-1, TrackStateChunk)<idx then ultraschall.AddErrorMessage("SetTrackHWOut", "idx", "no such index", -17) return false end
  
  local Start, Offset=TrackStateChunk:match("(.-MAINSEND.-\n)()")
  local Ende = TrackStateChunk:match(".*HWOUT.-\n(.*)")
  local count=1
  local Middle="HWOUT "..outputchannel.." "..post_pre_fader.." "..volume.." "..pan.." "..mute.." "..phase.." ".. source.." "..pan_law..":U "..automationmode.."\n"
  local Middle1=""
  local Middle2=""
  
  for k in string.gmatch(TrackStateChunk, "HWOUT.-\n") do
    if count<idx then Middle1=Middle1..k end
    if count>idx then Middle2=Middle2..k end
    count=count+1
  end
  
  TrackStateChunk=Start..Middle1..Middle..Middle2..Ende
  return true, TrackStateChunk
end


function ultraschall.SetTrackAUXSendReceives(tracknumber, idx, recv_tracknumber, post_pre_fader, volume, pan, mute, mono_stereo, phase, chan_src, snd_chan, pan_law, midichanflag, automation, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackAUXSendReceives</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>boolean retval, optional string TrackStateChunk = ultraschall.SetTrackAUXSendReceives(integer tracknumber, integer idx, integer recv_tracknumber, integer post_pre_fader, number volume, number pan, integer mute, integer mono_stereo, integer phase, integer chan_src, integer snd_chan, number pan_law, integer midichanflag, integer automation, optional string TrackStateChunk)</functioncall>
  <description>
    Alters a setting of Send/Receive, as set in the routing-matrix, as well as in the Destination "Controls for Track"-dialogue, of tracknumber. There can be more than one, so choose the right one with idx.
    You can keep the old-setting by using nil as a parametervalue.
    Remember, if you want to set the sends of a track, you need to add it to the track, that shall receive, not the track that sends! Set recv_tracknumber in the track that receives with the tracknumber that sends, and you've set it successfully.
    
    Due to the complexity of send/receive-settings, this function does not check, whether the parameters are plausible. So check twice, whether the change sends/receives still appear, as they might disappear with faulty settings!
    returns false in case of failure
  </description>
  <parameters markup_type="markdown" markup_version="1.0.1" indent="default">
    integer tracknumber - the number of the track, whose Send/Receive you want
    integer idx - the send/receive-setting, you want to set
    integer recv_tracknumber - Tracknumber, from where to receive the audio from
    integer post_pre_fader - 0-PostFader, 1-PreFX, 3-Pre-Fader
    number volume - Volume; see [DB2MKVOL](#DB2MKVOL) to convert from a dB-value
    number pan - pan, as set in the Destination "Controls for Track"-dialogue; negative=left, positive=right, 0=center
    integer mute - Mute this send(1) or not(0)
    integer mono_stereo - Mono(1), Stereo(0)
    integer phase - Phase of this send on(1) or off(0)
    integer chan_src - Audio-Channel Source
    -                                        -1 - None
    -                                        0 - Stereo Source 1/2
    -                                        1 - Stereo Source 2/3
    -                                        2 - Stereo Source 3/4
    -                                        1024 - Mono Source 1
    -                                        1025 - Mono Source 2
    -                                        2048 - Multichannel Source 4 Channels 1-4
    integer snd_chan - send to channel
    -                                        0 - Stereo 1/2
    -                                        1 - Stereo 2/3
    -                                        2 - Stereo 3/4
    -                                        ...
    -                                        1024 - Mono Channel 1
    -                                        1025 - Mono Channel 2
    number pan_law - pan-law, as set in the dialog that opens, when you right-click on the pan-slider in the routing-settings-dialog; default is -1 for +0.0dB
    integer midichanflag -0 - All Midi Tracks
    -                                        1 to 16 - Midi Channel 1 to 16
    -                                        32 - send to Midi Channel 1
    -                                        64 - send to MIDI Channel 2
    -                                        96 - send to MIDI Channel 3
    -                                        ...
    -                                        512 - send to MIDI Channel 16
    -                                        4194304 - send to MIDI-Bus B1
    -                                        send to MIDI-Bus B1 + send to MIDI Channel nr = MIDIBus B1 1/nr:
    -                                        16384 - BusB1
    -                                        BusB1+1 to 16 - BusB1-Channel 1 to 16
    -                                        32768 - BusB2
    -                                        BusB2+1 to 16 - BusB2-Channel 1 to 16
    -                                        49152 - BusB3
    -                                        ...
    -                                        BusB3+1 to 16 - BusB3-Channel 1 to 16
    -                                        262144 - BusB16
    -                                        BusB16+1 to 16 - BusB16-Channel 1 to 16
    -
    -                                        1024 - Add that value to switch MIDI On
    -                                        4177951 - MIDI - None
    integer automation - Automation Mode
    -                                       -1 - Track Automation Mode
    -                                        0 - Trim/Read
    -                                        1 - Read
    -                                        2 - Touch
    -                                        3 - Write
    -                                        4 - Latch
    -                                        5 - Latch Preview
    optional string TrackStateChunk - a TrackStateChunk, whose AUXRECV-entries you want to set
  </parameters>
  <retvals>
    boolean retval - true if it worked, false if it didn't.
    optional string TrackStateChunk - an altered TrackStateChunk, whose AUXRECV-entries you've altered
  </retvals>
  <chapter_context>
    Track Management
    Send/Receive-Routing
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, send, receive, phase, source, mute, pan, volume, post, pre, fader, channel, automation, midi, trackstatechunk, pan-law</tags>
</US_DocBloc>
]]
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackAUXSendReceives", "tracknumber", "must be an integer", -1) return false end
  if tracknumber~=-1 and (tracknumber<1 or tracknumber>reaper.CountTracks(0)) then ultraschall.AddErrorMessage("SetTrackAUXSendReceives", "tracknumber", "no such track", -2) return false end
  if math.type(idx)~="integer" then ultraschall.AddErrorMessage("SetTrackAUXSendReceives", "idx", "must be an integer", -16) return false end
  if idx<1 then ultraschall.AddErrorMessage("SetTrackHWOut", "idx", "no such index", -20) return false end
  if math.type(recv_tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackAUXSendReceives", "recv_tracknumber", "must be an integer", -3) return false end
  if math.type(post_pre_fader)~="integer" then ultraschall.AddErrorMessage("SetTrackAUXSendReceives", "post_pre_fader", "must be an integer", -4) return false end
  if type(volume)~="number" then ultraschall.AddErrorMessage("SetTrackAUXSendReceives", "volume", "must be a number", -5) return false end
  if type(pan)~="number" then ultraschall.AddErrorMessage("SetTrackAUXSendReceives", "pan", "must be a number", -6) return false end
  if math.type(mute)~="integer" then ultraschall.AddErrorMessage("SetTrackAUXSendReceives", "mute", "must be an integer", -7) return false end
  if math.type(mono_stereo)~="integer" then ultraschall.AddErrorMessage("SetTrackAUXSendReceives", "mono_stereo", "must be an integer", -8) return false end
  if math.type(phase)~="integer" then ultraschall.AddErrorMessage("SetTrackAUXSendReceives", "phase", "must be an integer", -9) return false end
  if math.type(chan_src)~="integer" then ultraschall.AddErrorMessage("SetTrackAUXSendReceives", "chan_src", "must be a number", -10) return false end
  if math.type(snd_chan)~="integer" then ultraschall.AddErrorMessage("SetTrackAUXSendReceives", "snd_chan", "must be an integer", -11) return false end
  if type(pan_law)~="number" then ultraschall.AddErrorMessage("SetTrackAUXSendReceives", "pan_law", "must be a number", -12) return false end
  if math.type(midichanflag)~="integer" then ultraschall.AddErrorMessage("SetTrackAUXSendReceives", "midichanflag", "must be an integer", -13) return false end
  if math.type(automation)~="integer" then ultraschall.AddErrorMessage("SetTrackAUXSendReceives", "automation", "must be an integer", -14) return false end
  
  local tr, temp, Track
  if tracknumber~=-1 then
    if tracknumber==0 then tr=reaper.GetMasterTrack(0)
    else tr=reaper.GetTrack(0,tracknumber-1) end
    if idx>reaper.GetTrackNumSends(tr, -1) then ultraschall.AddErrorMessage("SetTrackAUXSendReceives", "idx", "no such index", -17) return false end
    temp, TrackStateChunk=reaper.GetTrackStateChunk(tr, "", false)
  end  
  if ultraschall.IsValidTrackStateChunk(TrackStateChunk)==false then ultraschall.AddErrorMessage("SetTrackAUXSendReceives", "TrackStateChunk", "must be a valid TrackStateChunk", -18) return false end
  if ultraschall.CountTrackAUXSendReceives(-1, TrackStateChunk)<idx then ultraschall.AddErrorMessage("SetTrackAUXSendReceives", "idx", "no such index", -19) return false end
  
  local Start, Offset=TrackStateChunk:match("(.-PERF.-\n)()")
  local Ende = TrackStateChunk:match(".*AUXRECV.-\n(.*)")
  local count=1
  local Middle="AUXRECV "..(recv_tracknumber-1).." "..post_pre_fader.." "..volume.." "..pan.." "..mute.." ".. mono_stereo.." "..phase.." "..chan_src.." "..snd_chan.." "..pan_law..":U "..midichanflag.." "..automation.." ''\n"
  local Middle1=""
  local Middle2=""
  
  for k in string.gmatch(TrackStateChunk, "AUXRECV.-\n") do
    if count<idx then Middle1=Middle1..k end
    if count>idx then Middle2=Middle2..k end
    count=count+1
  end
  
  TrackStateChunk=Start..Middle1..Middle..Middle2..Ende
  if tracknumber==-1 then
    return true, TrackStateChunk
  else
    reaper.SetTrackStateChunk(tr, TrackStateChunk, false)
  end
end

function ultraschall.CountItemsInTrackStateChunk(trackstatechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CountItemsInTrackStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer countitems = ultraschall.CountItemsInTrackStateChunk(string trackstatechunk)</functioncall>
  <description>
    returns the number of items in a trackstatechunk
    
    returns -1 in case of error
  </description>
  <parameters>
    string trackstatechunk - a trackstatechunk, as returned by reaper's api function reaper.GetTrackStateChunk
  </parameters>
  <retvals>
    integer countitems - number of items in the trackstatechunk
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, tracks, media, item, statechunk, chunk, get</tags>
</US_DocBloc>
]]

  if type(trackstatechunk)~="string" then ultraschall.AddErrorMessage("CountItemsInTrackStateChunk", "trackstatechunk", "only trackstatechunk is allowed", -1) return -1 end
  trackstatechunk=trackstatechunk:match("<ITEM.*")
  if trackstatechunk==nil then ultraschall.AddErrorMessage("CountItemsInTrackStateChunk", "trackstatechunk", "no valid trackstatechunk", -2) return -1 end
  local count=0

  while trackstatechunk:match("<ITEM")~=nil do
    count=count+1
    trackstatechunk=trackstatechunk:match("<ITEM.-(<ITEM.*)")
    if trackstatechunk==nil then break end 
  end
  return count
end


function ultraschall.GetItemStateChunkFromTrackStateChunk(trackstatechunk, idx)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemStateChunkFromTrackStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string mediaitemstatechunk = ultraschall.GetItemStateChunkFromTrackStateChunk(string trackstatechunk, integer idx)</functioncall>
  <description>
    Returns a mediaitemstatechunk of the idx'th item in trackstatechunk.
    
    returns false in case of error
  </description>
  <parameters>
    string trackstatechunk - a trackstatechunk, as returned by reaper's api function reaper.GetTrackStateChunk
    integer idx - the number of the item you want to have returned as mediaitemstatechunk
  </parameters>
  <retvals>
    boolean retval - true in case of success, false in case of error
    string mediaitemstatechunk - number of items in the trackstatechunk
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, tracks, media, item, statechunk, chunk, get</tags>
</US_DocBloc>
]]
  if type(trackstatechunk)~="string" then ultraschall.AddErrorMessage("GetItemStateChunkFromTrackStateChunk", "trackstatechunk", "only trackstatechunk is allowed", -1) return false end
  local nums=ultraschall.CountItemsInTrackStateChunk(trackstatechunk)
  if nums==-1 then ultraschall.AddErrorMessage("GetItemStateChunkFromTrackStateChunk", "trackstatechunk", "only trackstatechunk is allowed", -2) return false end
  if nums<idx then ultraschall.AddErrorMessage("GetItemStateChunkFromTrackStateChunk", "idx", "only "..nums.." items in trackstatechunk", -3) return false end
  trackstatechunk=trackstatechunk:match("<ITEM.*")
  if trackstatechunk==nil then ultraschall.AddErrorMessage("GetItemStateChunkFromTrackStateChunk", "trackstatechunk", "no valid trackstatechunk", -4) return false end
  local count=0
  local temptrackstatechunk=""
  while trackstatechunk:match("<ITEM")~=nil do
    count=count+1
    if count==idx then
      temptrackstatechunk=trackstatechunk:match("(<ITEM.-)<ITEM")
      if temptrackstatechunk==nil then temptrackstatechunk=trackstatechunk:match("(<ITEM.*)") end
    end
    
    trackstatechunk=trackstatechunk:match("<ITEM.-(<ITEM.*)")
    if trackstatechunk==nil then break end 
  end
  return true, temptrackstatechunk  
end




function ultraschall.AddMediaItemStateChunk_To_TrackStateChunk(trackstatechunk, mediaitemstatechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AddMediaItemStateChunk_To_TrackStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string trackstatechunk = ultraschall.AddMediaItemStateChunk_To_TrackStateChunk(string trackstatechunk, string mediaitemstatechunk)</functioncall>
  <description>
    Adds the item mediaitemstatechunk into trackstatechunk and returns this altered trackstatechunk.
    
    returns nil in case of error
  </description>
  <parameters>
    string trackstatechunk - a trackstatechunk, as returned by reaper's api function reaper.GetTrackStateChunk
    string mediaitemstatechunk - a mediaitemstatechunk, as returned by reaper's api function reaper.GetItemStateChunk
  </parameters>
  <retvals>
    string trackstatechunk - the new trackstatechunk with mediaitemstatechunk added
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, tracks, media, item, statechunk, chunk, add</tags>
</US_DocBloc>
]]
  if type(trackstatechunk)~="string" then ultraschall.AddErrorMessage("AddMediaItemStateChunk_To_TrackStateChunk", "trackstatechunk", "only trackstatechunk is allowed, not "..type(trackstatechunk), -1) return nil end
  if type(mediaitemstatechunk)~="string" then ultraschall.AddErrorMessage("AddMediaItemStateChunk_To_TrackStateChunk", "mediaitemstatechunk", "only mediaitemstatechunk is allowed, not "..type(mediaitemstatechunk), -2) return nil end
  if trackstatechunk:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("AddMediaItemStateChunk_To_TrackStateChunk", "trackstatechunk", "not a valid trackstatechunk", -3) return nil end
  if mediaitemstatechunk:match("<ITEM.*>")==nil then ultraschall.AddErrorMessage("AddMediaItemStateChunk_To_TrackStateChunk", "mediaitemstatechunk", "not a valid mediaitemstatechunk", -4) return nil end
  return trackstatechunk:match("(.*)>")..mediaitemstatechunk..">"
end



function ultraschall.RemoveMediaItem_TrackStateChunk(trackstatechunk, idx)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>RemoveMediaItem_TrackStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string trackstatechunk = ultraschall.RemoveMediaItem_TrackStateChunk(string trackstatechunk, integer idx)</functioncall>
  <description>
    Deletes the idx'th item from trackstatechunk and returns this altered trackstatechunk.
    
    returns nil in case of error
  </description>
  <parameters>
    string trackstatechunk - a trackstatechunk, as returned by reaper's api function reaper.GetTrackStateChunk
    integer idx - the number of the item you want to delete
  </parameters>
  <retvals>
    boolean retval - true in case of success, false in case of error
    string trackstatechunk - the new trackstatechunk with the idx'th item deleted
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, tracks, media, item, statechunk, chunk, delete</tags>
</US_DocBloc>
]]
  if type(trackstatechunk)~="string" then ultraschall.AddErrorMessage("RemoveMediaItem_TrackStateChunk", "trackstatechunk", "only trackstatechunk is allowed", -1) return false end
  local nums=ultraschall.CountItemsInTrackStateChunk(trackstatechunk)
  if nums==-1 then ultraschall.AddErrorMessage("RemoveMediaItem_TrackStateChunk", "trackstatechunk", "only trackstatechunk is allowed", -2) return false end
  if nums<idx then ultraschall.AddErrorMessage("RemoveMediaItem_TrackStateChunk", "idx", "only "..nums.." items in trackstatechunk", -3) return false end
  if idx<1 then ultraschall.AddErrorMessage("RemoveMediaItem_TrackStateChunk", "idx", "only positive values allowed, beginning with 1", -4) return false end
  local begin=trackstatechunk:match("(.-)<ITEM.*")
  trackstatechunk=trackstatechunk:match("<ITEM.*")
  if trackstatechunk==nil then ultraschall.AddErrorMessage("RemoveMediaItem_TrackStateChunk", "trackstatechunk", "no valid trackstatechunk", -5) return false end
  local count=0
  local temptrackstatechunk=""
  while trackstatechunk:match("<ITEM")~=nil do
    count=count+1
    if count~=idx then
      local temptrackstatechunk2=trackstatechunk:match("(<ITEM.-)<ITEM")
      if temptrackstatechunk2==nil then temptrackstatechunk2=trackstatechunk:match("(<ITEM.*)") end
      temptrackstatechunk=temptrackstatechunk..temptrackstatechunk2
    end
    trackstatechunk=trackstatechunk:match("<ITEM.-(<ITEM.*)")
    if trackstatechunk==nil then break end 
  end
  return true, begin..temptrackstatechunk
end


function ultraschall.RemoveMediaItemByIGUID_TrackStateChunk(trackstatechunk, IGUID)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>RemoveMediaItemByIGUID_TrackStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string trackstatechunk = ultraschall.RemoveMediaItemByIGUID_TrackStateChunk(string trackstatechunk, string IGUID)</functioncall>
  <description>
    Deletes the item with the iguid IGUID from trackstatechunk and returns this altered trackstatechunk.
    
    returns nil in case of error
  </description>
  <parameters>
    string trackstatechunk - a trackstatechunk, as returned by reaper's api function reaper.GetTrackStateChunk
    string IGUID - the IGUID of the item you want to delete
  </parameters>
  <retvals>
    boolean retval - true in case of success, false in case of error
    string trackstatechunk - the new trackstatechunk with the IGUID-item deleted
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, tracks, media, item, statechunk, chunk, delete, iguid</tags>
</US_DocBloc>
]]
  if type(trackstatechunk)~="string" then ultraschall.AddErrorMessage("RemoveMediaItemByIGUID_TrackStateChunk", "trackstatechunk", "only trackstatechunk is allowed", -1) return false end
  if trackstatechunk:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("RemoveMediaItemByIGUID_TrackStateChunk", "trackstatechunk", "no valid trackstatechunk", -2) return false end
  local nums=ultraschall.CountItemsInTrackStateChunk(trackstatechunk)
  local begin=trackstatechunk:match("(.-)<ITEM.*")
  trackstatechunk=trackstatechunk:match("<ITEM.*")
  if trackstatechunk==nil then ultraschall.AddErrorMessage("RemoveMediaItemByIGUID_TrackStateChunk", "trackstatechunk", "no items in trackstatechunk", -3) return false end
  local count=0
  local temptrackstatechunk=""
  local dada
  for i=1,nums do
    local L,M=ultraschall.GetItemStateChunkFromTrackStateChunk(trackstatechunk, i)
    if ultraschall.GetItemIGUID(M)~=IGUID then temptrackstatechunk=temptrackstatechunk..M end
  end
  local lt=ultraschall.CountCharacterInString(begin..temptrackstatechunk,"<")
  local gt=ultraschall.CountCharacterInString(begin..temptrackstatechunk,">")
  if gt<lt then dada=">\n" else dada="" end
  return true, begin..temptrackstatechunk..dada
end

function ultraschall.RemoveMediaItemByGUID_TrackStateChunk(trackstatechunk, GUID)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>RemoveMediaItemByGUID_TrackStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string trackstatechunk = ultraschall.RemoveMediaItemByGUID_TrackStateChunk(string trackstatechunk, string GUID)</functioncall>
  <description>
    Deletes the item with the guid GUID from trackstatechunk and returns this altered trackstatechunk.
    
    returns nil in case of error
  </description>
  <parameters>
    string trackstatechunk - a trackstatechunk, as returned by reaper's api function reaper.GetTrackStateChunk
    string GUID - the GUID of the item you want to delete
  </parameters>
  <retvals>
    boolean retval - true in case of success, false in case of error
    string trackstatechunk - the new trackstatechunk with the GUID-item deleted
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, tracks, media, item, statechunk, chunk, delete, guid</tags>
</US_DocBloc>
]]
  if type(trackstatechunk)~="string" then ultraschall.AddErrorMessage("RemoveMediaItemByGUID_TrackStateChunk", "trackstatechunk", "only trackstatechunk is allowed", -1) return false end
  if trackstatechunk:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("RemoveMediaItemByGUID_TrackStateChunk", "trackstatechunk", "no valid trackstatechunk", -2) return false end
  local nums=ultraschall.CountItemsInTrackStateChunk(trackstatechunk)
  local begin=trackstatechunk:match("(.-)<ITEM.*")
  trackstatechunk=trackstatechunk:match("<ITEM.*")
  if trackstatechunk==nil then ultraschall.AddErrorMessage("RemoveMediaItemByGUID_TrackStateChunk", "trackstatechunk", "no items in trackstatechunk", -3) return false end
  local count=0
  local temptrackstatechunk=""
  local dada
  for i=1,nums do
    local L,M=ultraschall.GetItemStateChunkFromTrackStateChunk(trackstatechunk, i)
    if ultraschall.GetItemGUID(M)~=GUID then temptrackstatechunk=temptrackstatechunk..M 
    else 
    end
  end
  local lt=ultraschall.CountCharacterInString(begin..temptrackstatechunk,"<")
  local gt=ultraschall.CountCharacterInString(begin..temptrackstatechunk,">")
  if gt<lt then dada=">\n" else dada="" end
  return true, begin..temptrackstatechunk..dada
end

function ultraschall.OnlyTracksInBothTrackstrings(trackstring1, trackstring2)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>OnlyTracksInBothTrackstrings</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval, string trackstring, array trackstringarray, integer number_of_entries = ultraschall.OnlyTracksInBothTrackstrings(string trackstring1, string trackstring2)</functioncall>
  <description>
    returns a new trackstring, that contains only the tracknumbers, that are in trackstring1 and trackstring2.
    
    returns -1 in case of error
  </description>
  <parameters>
    string trackstring1 - a string with the tracknumbers, separated by commas
    string trackstring2 - a string with the tracknumbers, separated by commas
  </parameters>
  <retvals>
    integer retval - -1 in case of error, 1 in case of success
    string trackstring - the cleared trackstring, -1 in case of error
    array trackstringarray - the "cleared" trackstring as an array
    integer number_of_entries - the number of entries in the trackstring
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, tracks, trackstring, sort, order</tags>
</US_DocBloc>
]]
  if type(trackstring1)~="string" then ultraschall.AddErrorMessage("OnlyTracksInBothTrackstrings", "trackstring1", "not a valid trackstring", -1) return -1 end
  if type(trackstring2)~="string" then ultraschall.AddErrorMessage("OnlyTracksInBothTrackstrings", "trackstring2", "not a valid trackstring", -2)return -1 end
  local A,A2,A3,A4=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring1)
  local B,B2,B3,B4=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring2)
  local newtrackstring=""
  for i=1, A4 do
    for a=1, B4 do
      if A3[i]==B3[a] then newtrackstring=newtrackstring..A3[i].."," end
    end
  end
  return ultraschall.RemoveDuplicateTracksInTrackstring(newtrackstring)
end

function ultraschall.OnlyTracksInOneTrackstring(trackstring1, trackstring2)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>OnlyTracksInOneTrackstring</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval, string trackstring, array trackstringarray, integer number_of_entries = ultraschall.OnlyTracksInOneTrackstring(string trackstring1, string trackstring2)</functioncall>
  <description>
    returns a new trackstring, that contains only the tracknumbers, that are in either trackstring1 or trackstring2, NOT in both!
    
    returns -1 in case of error
  </description>
  <parameters>
    string trackstring1 - a string with the tracknumbers, separated by commas
    string trackstring2 - a string with the tracknumbers, separated by commas
  </parameters>
  <retvals>
    integer retval - -1 in case of error, 1 in case of success
    string trackstring - the cleared trackstring, -1 in case of error
    array trackstringarray - the "cleared" trackstring as an array
    integer number_of_entries - the number of entries in the trackstring
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, tracks, trackstring, sort, order</tags>
</US_DocBloc>
]]
  if type(trackstring1)~="string" then ultraschall.AddErrorMessage("OnlyTracksInOneTrackstring", "trackstring1", "not a valid trackstring", -1) return -1 end
  if type(trackstring2)~="string" then ultraschall.AddErrorMessage("OnlyTracksInOneTrackstring", "trackstring2", "not a valid trackstring", -2) return -1 end
  local A,A2,A3,A4=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring1)
  local B,B2,B3,B4=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring2)
  local newtrackstring=""
  local count=0
  for i=A4, 1, -1 do
    for a=B4, 1, -1 do
      if A3[i]==B3[a] then table.remove(A3,i) table.remove(B3,a) count=count+1 end
    end
  end

  for i=1,A4-count do
      newtrackstring=newtrackstring..A3[i]..","
  end

  for i=1,B4-count do
      newtrackstring=newtrackstring..B3[i]..","
  end
    
  return ultraschall.RemoveDuplicateTracksInTrackstring(newtrackstring)
end


function ultraschall.SetMediaItemStateChunk_in_TrackStateChunk(trackstatechunk, idx, mediaitemstatechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetMediaItemStateChunk_in_TrackStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string trackstatechunk = ultraschall.SetMediaItemStateChunk_in_TrackStateChunk(string trackstatechunk, integer idx, string mediaitemstatechunk)</functioncall>
  <description>
    Overwrites the idx'th item from trackstatechunk with mediaitemstatechunk and returns this altered trackstatechunk.
    
    returns nil in case of error
  </description>
  <parameters>
    string trackstatechunk - a trackstatechunk, as returned by reaper's api function reaper.GetTrackStateChunk
    integer idx - the number of the item you want to delete
    string mediaitemstatechunk - a mediaitemstatechunk, as returned by reaper's api function reaper.GetItemStateChunk
  </parameters>
  <retvals>
    boolean retval - true in case of success, false in case of error
    string trackstatechunk - the new trackstatechunk with the idx'th item replaced
  </retvals>
  <chapter_context>
    MediaItem Management
    Set MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, chunk, set</tags>
</US_DocBloc>
]]
  if type(trackstatechunk)~="string" then ultraschall.AddErrorMessage("SetMediaItemStateChunk_in_TrackStateChunk", "trackstatechunk", "only trackstatechunk is allowed, not "..type(trackstatechunk), -1) return false end
  if type(mediaitemstatechunk)~="string" then ultraschall.AddErrorMessage("SetMediaItemStateChunk_in_TrackStateChunk", "mediaitemstatechunk", "only mediaitemstatechunk is allowed, not "..type(mediaitemstatechunk), -2) return false end
  local nums=ultraschall.CountItemsInTrackStateChunk(trackstatechunk)
  if nums==-1 then ultraschall.AddErrorMessage("SetMediaItemStateChunk_in_TrackStateChunk", "trackstatechunk", "only trackstatechunk is allowed", -3) return false end
  if nums<idx then ultraschall.AddErrorMessage("SetMediaItemStateChunk_in_TrackStateChunk", "idx", "only "..nums.." items in trackstatechunk", -4) return false end
  if idx<1 then ultraschall.AddErrorMessage("SetMediaItemStateChunk_in_TrackStateChunk", "idx", "only positive values allowed, beginning with 1", -5) return false end
  if mediaitemstatechunk:match("<ITEM.*>")==nil then ultraschall.AddErrorMessage("SetMediaItemStateChunk_in_TrackStateChunk", "mediaitemstatechunk", "not a valid mediaitemstatechunk", -6) return false end
  local begin=trackstatechunk:match("(.-)<ITEM.*")
  trackstatechunk=trackstatechunk:match("<ITEM.*")
  if trackstatechunk==nil then ultraschall.AddErrorMessage("SetMediaItemStateChunk_in_TrackStateChunk", "trackstatechunk", "no valid trackstatechunk", -7) return false end
  local count=0
  local add
  local temptrackstatechunk=""
  while trackstatechunk:match("<ITEM")~=nil do
    count=count+1
    if count~=idx then
      local temptrackstatechunk2=trackstatechunk:match("(<ITEM.-)<ITEM")
      if temptrackstatechunk2==nil then temptrackstatechunk2=trackstatechunk:match("(<ITEM.*)") end
      temptrackstatechunk=temptrackstatechunk..temptrackstatechunk2
    else
      temptrackstatechunk=temptrackstatechunk..mediaitemstatechunk
    end
    trackstatechunk=trackstatechunk:match("<ITEM.-(<ITEM.*)")
    if trackstatechunk==nil then break end 
  end
  if idx==nums then add=">" 
  else add=""
  end
  return true, begin..temptrackstatechunk..add
end

function ultraschall.GetAllMediaItemsFromTrackStateChunk(trackstatechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllMediaItemsFromTrackStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer count, array MediaItemStateChunkArray = ultraschall.GetAllMediaItemsFromTrackStateChunk(string trackstatechunk)</functioncall>
  <description>
    Returns a MediaItemStateChunkArray with all items in trackstatechunk.
    
    returns -1 in case of error
  </description>
  <parameters>
    string trackstatechunk - a trackstatechunk, as returned by functions like reaper.GetTrackStateChunk
  </parameters>
  <retvals>
    integer count - number of MediaItemStateChunks in the returned array. -1 in case of error
    array MediaItemStateChunkArray - an array with all MediaItemStateChunks from trackstatechunk
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, get, trackstatechunk, mediaitemstatechunk, mediaitemstatechunkarray</tags>
</US_DocBloc>
]]
  if type(trackstatechunk)~="string" or trackstatechunk:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("GetAllMediaItemsFromTrackStateChunk", "trackstatechunk", "not a valid trackstatechunk", -1) return -1 end
  local A=trackstatechunk:match("<ITEM.*>")
  if A==nil then ultraschall.AddErrorMessage("GetAllMediaItemsFromTrackStateChunk", "trackstatechunk", "no MediaItems in trackstatechunk", -2) return -1 end
  local MediaItemStateChunkArray={}
  local retval
  local count=ultraschall.CountItemsInTrackStateChunk(trackstatechunk)
  for i=1, count do
    retval, MediaItemStateChunkArray[i] = ultraschall.GetItemStateChunkFromTrackStateChunk(trackstatechunk, i) 
  end
  return count, MediaItemStateChunkArray
end

function ultraschall.CreateTrackString_AllTracks()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CreateTrackString_AllTracks</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string trackstring = ultraschall.CreateTrackString_AllTracks()</functioncall>
  <description>
    Returns a trackstring with all tracknumbers from the current project.
    
    Returns an empty string, if no track is available.
  </description>
  <retvals>
    string trackstring - a string with all tracknumbers, separated by commas.
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, tracks, trackstring</tags>
</US_DocBloc>
]]

  local trackstring=""
  for i=1, reaper.CountTracks(0) do
    trackstring=trackstring..i..","
  end
  return trackstring:sub(1,-2)
end

function ultraschall.GetTrackLength(Tracknumber)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackLength</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer length = ultraschall.GetTrackLength(integer Tracknumber)</functioncall>
  <description>
    Returns the length of a track, that means, the end of the last item in track Tracknumber.
    Will return -1, in case of error
  </description>
  <parameters>
    integer Tracknumber - the tracknumber, whose length you want to know
  </parameters>
  <retvals>
    integer length - the length of the track in seconds
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement,count,length,items,end</tags>
</US_DocBloc>
]]
  if math.type(Tracknumber)~="integer" then ultraschall.AddErrorMessage("GetTrackLength", "Tracknumber", "must be an integer", -1) return -1 end

  local MediaTrack, MediaItem, num_items, Itemcount, MediaItemArray, POS, LEN
  if Tracknumber<0 or Tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetTrackLength", "Tracknumber", "no such track", -2) return -1 end
  if Tracknumber==0 then 
    MediaTrack=reaper.GetMasterTrack(0)
  else
    MediaTrack=reaper.GetTrack(0,Tracknumber-1)
  end
  num_items=reaper.CountTrackMediaItems(MediaTrack)
  MediaItem, Itemcount, MediaItemArray = ultraschall.EnumerateMediaItemsInTrack(Tracknumber, num_items)
  if MediaItem==-1 then ultraschall.AddErrorMessage("GetTrackLength", "Tracknumber", "no items in this track", -3) return -1 end
  POS=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
  LEN=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")
  return POS+LEN
end

--A=ultraschall.GetTrackLength(2)
function ultraschall.GetLengthOfAllMediaItems_Track(Tracknumber)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetLengthOfAllMediaItems_Track</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer length = ultraschall.GetLengthOfAllMediaItems_Track(integer Tracknumber)</functioncall>
  <description>
    Returns the length of all MediaItems in track, combined.
    Will return -1, in case of error
  </description>
  <parameters>
    integer Tracknumber - the tracknumber, whose length you want to know; 1, track 1; 2, track 2, etc
  </parameters>
  <retvals>
    integer length - the length of all MediaItems in the track combined, in seconds
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, count, length, all items, track, end</tags>
</US_DocBloc>
]]
  if math.type(Tracknumber)~="integer" then ultraschall.AddErrorMessage("GetLengthOfAllMediaItems_Track", "Tracknumber", "must be an integer", -1) return -1 end

  local MediaTrack, MediaItem, num_items, Itemcount, MediaItemArray, POS, LEN
  if Tracknumber<1 or Tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetLengthOfAllMediaItems_Track", "Tracknumber", "no such track", -2) return -1 end
  
  LEN=0
  MediaTrack=reaper.GetTrack(0,Tracknumber-1)

  num_items=reaper.CountTrackMediaItems(MediaTrack)
  for i=1, num_items do
    MediaItem, Itemcount, MediaItemArray = ultraschall.EnumerateMediaItemsInTrack(Tracknumber, i)
    LEN=LEN+reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")
  end
  return LEN
end

--A=ultraschall.GetLengthOfAllMediaItems_Track(2)

function ultraschall.SetTrackStateChunk_Tracknumber(tracknumber, trackstatechunk, undo)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackStateChunk_Tracknumber</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.52
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetTrackStateChunk_Tracknumber(integer tracknumber, string trackstatechunk, boolean undo)</functioncall>
  <description>
    Sets the trackstatechunk for track tracknumber. Undo flag is a performance/caching hint.
    
    returns false in case of an error
  </description>
  <parameters>
    integer tracknumber - the tracknumber, 0 for master track, 1 for track 1, 2 for track 2, etc.
    string trackstatechunk - the trackstatechunk, you want to set this track with
    boolean undo - Undo flag is a performance/caching hint.
  </parameters>
  <retvals>
    boolean retval - true in case of success; false in case of error
  </retvals>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, trackstatechunk, set</tags>
</US_DocBloc>
]]

  tracknumber=tonumber(tracknumber)
  local Track
  if type(trackstatechunk)~="string" then ultraschall.AddErrorMessage("SetTrackStateChunk_Tracknumber","trackstatechunk", "not a valid trackstatechunk", -1) return false end
  if undo==nil then undo=true end
  if type(undo)~="boolean" then ultraschall.AddErrorMessage("SetTrackStateChunk_Tracknumber","undo", "only true or false are allowed", -2) return false end
  if tracknumber==nil then ultraschall.AddErrorMessage("SetTrackStateChunk_Tracknumber","tracknumber", "not a valid tracknumber, only integer allowed", -3) return false end
  if tracknumber<0 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackStateChunk_Tracknumber","tracknumber", "only tracknumbers allowed between 0(master), 1(track1) and "..reaper.CountTracks(0).."(last track in this project)", -4) return false end
  if tracknumber==0 then Track=reaper.GetMasterTrack(0)
  else Track=reaper.GetTrack(0,tracknumber-1)
  end
  A=reaper.SetTrackStateChunk(Track, trackstatechunk, undo)
  return A
end

function ultraschall.ApplyActionToTrack(trackstring, actioncommandid)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ApplyActionToTrack</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.77
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ApplyActionToTrack(string trackstring, string/number actioncommandid)</functioncall>
  <description>
    Applies action to the tracks, given by trackstring
    The action given must support applying itself to selected tracks.
    
    Returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, running action was successful; false, running the action was unsuccessful
  </retvals>
  <parameters>
    string trackstring - a string with all tracknumbers, separated by a comma; 1 for the first track, 2 for the second
  </parameters>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, run, command, track</tags>
</US_DocBloc>
]]
  -- check parameters
  if ultraschall.IsValidTrackString(trackstring)==false then ultraschall.AddErrorMessage("ApplyActionToTrack","trackstring", "Must be a valid trackstring!", -1) return false end
  if ultraschall.CheckActionCommandIDFormat2(actioncommandid)==false then ultraschall.AddErrorMessage("ApplyActionToTrack","actioncommandid", "No valid actioncommandid!", -2) return false end
  
  -- store current track-selection, make new track-selection, run the action and restore old track-selection
  reaper.PreventUIRefresh(1)
  local selTrackstring=ultraschall.CreateTrackString_SelectedTracks() 
  ultraschall.SetTracksSelected(trackstring, true)
  ultraschall.RunCommand(actioncommandid)
  ultraschall.SetTracksSelected(selTrackstring, true)
  reaper.PreventUIRefresh(-1)
  return true
end

--ultraschall.ApplyActionToTrack("2,3,5", 6)

function ultraschall.InsertTrackAtIndex(index, number_of_tracks, wantdefaults)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>InsertTrackAtIndex</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.77
    Lua=5.3
  </requires>
  <functioncall>string trackarray, integer new_track_count, array trackarray_newtracks = ultraschall.InsertTrackAtIndex(integer index, integer number_of_tracks, boolean wantdefaults)</functioncall>
  <description>
    Inserts one or more tracks at index.
    
    Returns nil in case of an error
  </description>
  <retvals>
    string trackstring - a trackstring with all newly created tracknumbers
    integer new_track_count - the number of newly created tracks
    array trackarray_newtracks - an array with the MediaTrack-objects of all newly created tracks
  </retvals>
  <parameters>
    integer index - the index, at which to include the new tracks; 0, for including before the first track
    integer number_of_tracks - the number of tracks that you want to create; 0 for including before track 1; number of tracks+1, include new tracks after last track
    boolean wantdefaults - true, set the tracks with default settings/fx/etc; false, create new track without any defaults
  </parameters>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, insert, new, track</tags>
</US_DocBloc>
]]
  if math.type(index)~="integer" then ultraschall.AddErrorMessage("InsertTrackAtIndex", "index", "Must be an integer.", -1) return end
  if math.type(number_of_tracks)~="integer" then ultraschall.AddErrorMessage("InsertTrackAtIndex", "number_of_tracks", "Must be an integer.", -2) return end
  if type(wantdefaults)~="boolean" then ultraschall.AddErrorMessage("InsertTrackAtIndex", "wantdefaults", "Must be a boolean.", -3) return end
  if index<0 or index>reaper.CountTracks(0) then ultraschall.AddErrorMessage("InsertTrackAtIndex", "index", "No such index. Must be 0 to tracknumber+1", -4) return end
  if number_of_tracks<0 then ultraschall.AddErrorMessage("InsertTrackAtIndex", "number_of_tracks", "Must be bigger than 0", -5) return end
  local TrackArray={}
  local count=reaper.CountTracks(0)-1
  local found
  for i=0, reaper.CountTracks(0)-1 do
    TrackArray[i+1]={}
    TrackArray[i+1][1]=reaper.GetTrack(0,i)
    TrackArray[i+1][2]=reaper.IsTrackSelected(TrackArray[i+1][1])
  end
  ultraschall.SetTracksSelected(tostring(index), true)
  for i=1, number_of_tracks do
    reaper.InsertTrackAtIndex(index, wantdefaults)
  end
  ultraschall.SetAllTracksSelected(false) 

  for i=1, count do
    reaper.SetTrackSelected(TrackArray[i+1][1], TrackArray[i+1][2])
  end
  
  local trackstring2=""
  local Trackarray2={}
  local newcount=0
  for i=0, reaper.CountTracks(0)-1 do
    for a=1, count do
      if reaper.GetTrack(0,i)==TrackArray[a+1][1] then found=true end
    end
    if found==false then trackstring2=trackstring2..i.."," newcount=newcount+1 Trackarray2[newcount]=reaper.GetTrack(0,i) end
    found=false
  end
  return trackstring2:sub(1,-2), newcount, Trackarray2
end

--A,B,C=ultraschall.InsertTrackAtIndex(1, 1, false)

function ultraschall.MoveTracks(trackstring, targetindex, makepreviousfolder)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>MoveTracks</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.92
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.MoveTracks(string trackstring, integer targetindex, integer makepreviousfolder)</functioncall>
  <description>
    Moves tracks in trackstring to position targetindex. You can also set, if the tracks shall become folders.
    Multiple tracks in trackstring will be put together, so track 2, 4, 6 would become 1, 2, 3, when moved above the first track!
    
    Returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, moving was successful; false, moving wasn't successful
  </retvals>
  <parameters>
    string trackstring - a string with all tracknumbers of the tracks you want to move, separated by commas
    integer targetindex - the index, to which to move the tracks; 0, move tracks before track 1; number of tracks+1, move after the last track
    integer makepreviousfolder - make tracks a folder or not
                               - 0, for normal, 
                               - 1, as child of track preceding track specified by makepreviousfolder
                               - 2, if track preceding track specified by makepreviousfolder is last track in folder, extend folder
  </parameters>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, move, track, tracks, folder</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidTrackString(trackstring)==false then ultraschall.AddErrorMessage("MoveTracks", "trackstring", "Must be a valid trackstring.", -1) return false end
  if math.type(targetindex)~="integer" then ultraschall.AddErrorMessage("MoveTracks", "targetindex", "Must be an integer.", -2) return false end
  if math.type(makepreviousfolder)~="integer" then ultraschall.AddErrorMessage("MoveTracks", "makepreviousfolder", "Must be an integer.", -3) return false end
  if targetindex<0 or targetindex>reaper.CountTracks(0)+1 then ultraschall.AddErrorMessage("MoveTracks", "targetindex", "No such track.", -4) return false end
  if makepreviousfolder<0 or makepreviousfolder>2 then ultraschall.AddErrorMessage("MoveTracks", "makepreviousfolder", "Must be between 0 and 2.", -5) return false end
  reaper.PreventUIRefresh(1)
  local TrackArray={}
  
  for i=0, reaper.CountTracks(0)-1 do
    TrackArray[i+1]={}
    TrackArray[i+1][1]=reaper.GetTrack(0,i)
    TrackArray[i+1][2]=reaper.IsTrackSelected(TrackArray[i+1][1])
  end
  ultraschall.SetTracksSelected(trackstring, true)
  
  local retval=reaper.ReorderSelectedTracks(targetindex, makepreviousfolder)
  
  for i=0, reaper.CountTracks(0)-1 do
    reaper.SetTrackSelected(TrackArray[i+1][1], TrackArray[i+1][2])
  end
  reaper.PreventUIRefresh(-1)
  return retval
end

--L=ultraschall.MoveTracks("2,3,5", 8, 1)


function ultraschall.SetTrackGroupFlagsState(tracknumber, groups_bitfield_table, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackGroupFlagsState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.941
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackGroupFlagsState(integer tracknumber, array groups_bitfield_table, optional string TrackStateChunk)</functioncall>
  <description>
    Set the GroupFlags-state of a track or trackstatechunk.
    You can reach the Group-Flag-Settings in the context-menu of a track.
    
    The groups_bitfield_table can contain up to 23 entries. Every entry represents one of the checkboxes in the Track grouping parameters-dialog
    
    Each entry is a bitfield, that represents the groups, in which this flag is set to checked or unchecked.
    
    So if you want to set Volume Master(table entry 1) to checked in Group 1(2^0=1) and 3(2^2=4):
      groups_bitfield_table[1]=groups_bitfield_table[1]+1+4
    
    The following flags(and their accompanying array-entry-index) are available:
                           1 - Volume Master
                           2 - Volume Slave
                           3 - Pan Master
                           4 - Pan Slave
                           5 - Mute Master
                           6 - Mute Slave
                           7 - Solo Master
                           8 - Solo Slave
                           9 - Record Arm Master
                           10 - Record Arm Slave
                           11 - Polarity/Phase Master
                           12 - Polarity/Phase Slave
                           13 - Automation Mode Master
                           14 - Automation Mode Slave
                           15 - Reverse Volume
                           16 - Reverse Pan
                           17 - Do not master when slaving
                           18 - Reverse Width
                           19 - Width Master
                           20 - Width Slave
                           21 - VCA Master
                           22 - VCA Slave
                           23 - VCA pre-FX slave
    
    This function will work only for Groups 1 to 32. To set Groups 33 to 64, use <a href="#SetTrackGroupFlags_HighState">SetTrackGroupFlags_HighState</a> instead!
    
    Returns false in case of an error
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    array groups_bitfield_table - an array with all bitfields with all groupflag-settings
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, groupflag, group, set, state, track, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackGroupFlagsState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackGroupFlagsState", "tracknumber", "no such track in the project", -2) return false end
  if type(groups_bitfield_table)~="table" then ultraschall.AddErrorMessage("SetTrackGroupFlagsState", "groups_bitfield_table", "must be a table", -3) return false end
  local str="GROUP_FLAGS"
  for i=1, 23 do
    if groups_bitfield_table[i]==nil then break end
    if math.type(groups_bitfield_table[i])~="integer" then ultraschall.AddErrorMessage("SetTrackGroupFlagsState", "groups_bitfield_table", "every entry must be an integer", -5) return false end
    str=str.." "..groups_bitfield_table[i]
  end
  tracknumber=tonumber(tracknumber)
  
  -- create state-entry
--  local str="GROUP_FLAGS "..groups_bitfield
  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackGroupFlagsState", "tracknumber", "must be an integer", -6) return false end
  if tracknumber~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackGroupFlagsState", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state from trackstatechunk
  local B1, B3
  B1=AA:match("(.-)%cGROUP_FLAGS")
  B3=AA:match("GROUP_FLAGS.-%c(.*)")
  if B1==nil then 
    B1=AA:match("(.*)%c.-TRACKHEIGHT")
    B3=AA:match("(TRACKHEIGHT.*)")
  end

  -- set trackstatechunk and include new-state
  if tonumber(tracknumber)~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end
  return B, B1.."\n"..str.."\n"..B3

end

--A=ultraschall.SetTrackGroupFlagsState(-1, {1,2,3,4,5}, TrackStateChunk)

function ultraschall.SetTrackGroupFlags_HighState(tracknumber, groups_bitfield_table, TrackStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackGroupFlags_HighState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.941
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string TrackStateChunk = ultraschall.SetTrackGroupFlags_HighState(integer tracknumber, array groups_bitfield_table, optional string TrackStateChunk)</functioncall>
  <description>
    Set the GroupFlags-state of a track or trackstatechunk.
    You can reach the Group-Flag-Settings in the context-menu of a track.
    
    The groups_bitfield_table can contain up to 23 entries. Every entry represents one of the checkboxes in the Track grouping parameters-dialog
    
    Each entry is a bitfield, that represents the groups, in which this flag is set to checked or unchecked.
    
    So if you want to set Volume Master(table entry 1) to checked in Group 33(2^0=1) and 35(2^2=4):
      groups_bitfield_table[1]=groups_bitfield_table[1]+1+4
    
    The following flags(and their accompanying array-entry-index) are available:
                           1 - Volume Master
                           2 - Volume Slave
                           3 - Pan Master
                           4 - Pan Slave
                           5 - Mute Master
                           6 - Mute Slave
                           7 - Solo Master
                           8 - Solo Slave
                           9 - Record Arm Master
                           10 - Record Arm Slave
                           11 - Polarity/Phase Master
                           12 - Polarity/Phase Slave
                           13 - Automation Mode Master
                           14 - Automation Mode Slave
                           15 - Reverse Volume
                           16 - Reverse Pan
                           17 - Do not master when slaving
                           18 - Reverse Width
                           19 - Width Master
                           20 - Width Slave
                           21 - VCA Master
                           22 - VCA Slave
                           23 - VCA pre-FX slave
    
    This function will work only for Groups 33(2^0) to 64(2^31). To set Groups 1 to 32, use <a href="#SetTrackGroupFlagsState">SetTrackGroupFlagsState</a> instead!
    
    Returns false in case of an error
  </description>
  <retvals>
    boolean retval  - true, if successful, false if unsuccessful
    string TrackStateChunk - the altered TrackStateChunk
  </retvals>
  <parameters>
    integer tracknumber - number of the track, beginning with 1; 0 for master-track; -1 if you want to use parameter TrackStateChunk
    array groups_bitfield_table - an array with all bitfields with all groupflag-settings
    optional string TrackStateChunk - use a trackstatechunk instead of a track; only used when tracknumber is -1
  </parameters>
  <chapter_context>
    Track Management
    Set Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, groupflag, group, set, state, track, trackstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetTrackGroupFlags_HighState", "tracknumber", "must be an integer", -1) return false end
  if tracknumber<-1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetTrackGroupFlags_HighState", "tracknumber", "no such track in the project", -2) return false end
  if type(groups_bitfield_table)~="table" then ultraschall.AddErrorMessage("SetTrackGroupFlags_HighState", "groups_bitfield_table", "must be a table", -3) return false end
  local str="GROUP_FLAGS_HIGH "
  for i=1, 23 do
    if groups_bitfield_table[i]==nil then break end
    if math.type(groups_bitfield_table[i])~="integer" then ultraschall.AddErrorMessage("SetTrackGroupFlags_HighState", "groups_bitfield_table", "every entry must be an integer", -5) return false end
    str=str.." "..groups_bitfield_table[i]
  end
  tracknumber=tonumber(tracknumber)

  
  -- get trackstatechunk
  local Mediatrack, A, AA, B
  if tonumber(tracknumber)~=-1 then
    if tracknumber==0 then Mediatrack=reaper.GetMasterTrack(0)
    else
      Mediatrack=reaper.GetTrack(0,tracknumber-1)
    end
    A,AA=ultraschall.GetTrackStateChunk(Mediatrack,str,false)
  else
    if type(TrackStateChunk)~="string" then ultraschall.AddErrorMessage("SetTrackGroupFlags_HighState", "TrackStateChunk", "must be a string", -4) return false end
    AA=TrackStateChunk
  end
  
  -- remove old state from trackstatechunk
  local B1, B3
  B1=AA:match("(.-)%cGROUP_FLAGS_HIGH ")
  B3=AA:match("GROUP_FLAGS_HIGH .-%c(.*)")
  if B1==nil then 
    B1=AA:match("(.*)%c.-TRACKHEIGHT")
    B3=AA:match("(TRACKHEIGHT.*)")
  end

  -- set trackstatechunk and include new-state
  if tonumber(tracknumber)~=-1 then
    B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  else
    B=true
  end
  return B, B1.."\n"..str.."\n"..B3

end


function ultraschall.CreateTrackString_ArmedTracks()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CreateTrackString_ArmedTracks</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.941
    Lua=5.3
  </requires>
  <functioncall>string trackstring = ultraschall.CreateTrackString_ArmedTracks()</functioncall>
  <description>
    Gets a trackstring with tracknumbers of all armed tracks in it.
    
    Returns "" if no track is armed.
  </description>
  <retvals>
    string trackstring - a trackstring with the tracknumbers of all armed tracks as comma separated csv-string, eg: "1,3,4,7"
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, get, tracks, armed, trackstring</tags>
</US_DocBloc>
--]]
  local trackstring=""
  for i=0, reaper.CountTracks(0)-1 do
    local MediaTrack=reaper.GetTrack(0,i)
    if reaper.GetMediaTrackInfo_Value(MediaTrack, "I_RECARM")==1 then trackstring=trackstring..(i+1).."," end
  end
  return trackstring:sub(1,-2)
end

function ultraschall.CreateTrackString_UnarmedTracks()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CreateTrackString_UnarmedTracks</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.941
    Lua=5.3
  </requires>
  <functioncall>string trackstring = ultraschall.CreateTrackString_UnarmedTracks()</functioncall>
  <description>
    Gets a trackstring with tracknumbers of all unarmed tracks in it.
    
    Returns "" if all tracks are armed.
  </description>
  <retvals>
    string trackstring - a trackstring with the tracknumbers of all unarmed tracks as comma separated csv-string, eg: "1,3,4,7"
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, get, tracks, unarmed, trackstring</tags>
</US_DocBloc>
--]]
  local trackstring=""
  for i=0, reaper.CountTracks(0)-1 do
    local MediaTrack=reaper.GetTrack(0,i)
    if reaper.GetMediaTrackInfo_Value(MediaTrack, "I_RECARM")==0 then trackstring=trackstring..(i+1).."," end
  end
  return trackstring:sub(1,-2)
end

--L=ultraschall.CreateTrackString_UnarmedTracks()

function ultraschall.CreateTrackStringByGUID(guid_csv_string)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CreateTrackStringByGUID</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    SWS=2.9.7
    Lua=5.3
  </requires>
  <functioncall>string trackstring = ultraschall.CreateTrackStringByGUID(string guid_csv_string)</functioncall>
  <description>
    returns a trackstring with all tracks, as given by the GUIDs in the comma-separated-csv-string guid_csv_string.
    
    returns "" in case of an error, like no track available or an invalid string
  </description>
  <retvals>
    string trackstring - a string with all the tracknumbers of the tracks given as GUIDs in guid_csv_string
  </retvals>
  <parameters>
    string guid_csv_string - a comma-separated csv-string, that includes all GUIDs of all track to be included in the trackstring.
  </parameters>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackstring, track, create, guid</tags>
</US_DocBloc>
--]]
  if type(guid_csv_string)~="string" then ultraschall.AddErrorMessage("CreateTrackStringByGUID", "guid_csv_string", "Must be a string", -1) return "" end
  local Trackstring=""
  local A,B=ultraschall.CSV2IndividualLinesAsArray(guid_csv_string)
  for i=1, A do
    local Track=reaper.BR_GetMediaTrackByGUID(0, B[i])
    if Track~=nil then Trackstring=Trackstring..","..math.ceil(reaper.GetMediaTrackInfo_Value(Track, "IP_TRACKNUMBER")) end
  end
  local retval, Trackstring = ultraschall.RemoveDuplicateTracksInTrackstring(Trackstring)
  return Trackstring
end



function ultraschall.CreateTrackStringByTracknames(tracknames_csv_string)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CreateTrackStringByTracknames</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>string trackstring = ultraschall.CreateTrackStringByTracknames(string tracknames_csv_string)</functioncall>
  <description>
    returns a trackstring with all tracks, as given by the tracknames in the newline(!)-separated-csv-string guid_csv_string.
    
    returns "" in case of an error, like no track available or an invalid string
  </description>
  <retvals>
    string trackstring - a string with all the tracknumbers of the tracks given as tracknames in tracknames_csv_string
  </retvals>
  <parameters>
    string tracknames_csv_string - a newline(!)-separated csv-string, that includes all tracknames of all track to be included in the trackstring. Tracknames are case sensitive!
  </parameters>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackstring, track, create, tracknames</tags>
</US_DocBloc>
--]]
  if type(tracknames_csv_string)~="string" then ultraschall.AddErrorMessage("CreateTrackStringByTracknames", "tracknames_csv_string", "Must be a string", -1) return "" end
  local Trackstring=""
  local A,B=ultraschall.CSV2IndividualLinesAsArray(tracknames_csv_string, "\n")
  for a=0, reaper.CountTracks(0)-1 do    
    local Track=reaper.GetTrack(0,a)
    for i=1,A do
      local retval, Name=reaper.GetTrackName(Track,"")
      if Name==B[i] then Trackstring=Trackstring..","..(a+1) break end
    end
  end
  local retval, Trackstring = ultraschall.RemoveDuplicateTracksInTrackstring(Trackstring)
  return Trackstring
end



function ultraschall.CreateTrackStringByMediaTracks(MediaTrackArray)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CreateTrackStringByMediaTracks</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>string trackstring = ultraschall.CreateTrackStringByMediaTracks(array MediaTrackArray)</functioncall>
  <description>
    returns a trackstring with all tracks, as given in the array MediaTrackArray
    
    returns "" in case of an error, like no track available or an invalid string
  </description>
  <retvals>
    string trackstring - a string with all the tracknumbers of the MediaTrack-objects given in parameter MediaTrackArray
  </retvals>
  <parameters>
    array MediaTrackArray - an array, that includes all MediaTrack-objects to be included in the trackstring; a nil-entry is seen as the end of the array
  </parameters>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackstring, track, create, mediatrack, mediatracks</tags>
</US_DocBloc>
--]]
  if type(MediaTrackArray)~="table" then ultraschall.AddErrorMessage("CreateTrackStringByMediaTracks", "MediaTrackArray", "Must be an array", -1) return "" end
  local Trackstring=""

  local count=1
  while MediaTrackArray[count]~=nil do
    if ultraschall.type(MediaTrackArray[count])=="MediaTrack" then
      Trackstring=Trackstring..","..math.ceil(reaper.GetMediaTrackInfo_Value(MediaTrackArray[count], "IP_TRACKNUMBER"))
    end
    count=count+1
  end
  local retval, Trackstring = ultraschall.RemoveDuplicateTracksInTrackstring(Trackstring)
  return Trackstring
end

function ultraschall.GetTrackSelection_TrackStateChunk(TrackStateChunk)
-- returns the trackname as a string
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackSelection_TrackStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>integer selection_state = ultraschall.GetTrackSelection_TrackStateChunk(string TrackStateChunk)</functioncall>
  <description>
    returns selection of the track.    
    
    It's the entry SEL.
    
    Works only with statechunks stored in ProjectStateChunks, due API-limitations!
  </description>
  <retvals>
    integer selection_state - 0, track is unselected; 1, track is selected
  </retvals>
  <parameters>    
    string TrackStateChunk - a TrackStateChunk whose selection-state you want to retrieve; works only with TrackStateChunks from ProjectStateChunks!
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, selection, state, get, trackstatechunk</tags>
</US_DocBloc>
--]]

  -- check parameters
  if ultraschall.IsValidTrackStateChunk(TrackStateChunk)==false then ultraschall.AddErrorMessage("GetTrackSelection", "TrackStateChunk", "no valid TrackStateChunk", -1) return nil end
  
  -- get selection
  local Track_Name=str:match(".-SEL (.-)%c.-REC")
  return tonumber(Track_Name)
end


function ultraschall.SetTrackSelection_TrackStateChunk(selection_state, TrackStateChunk)
-- returns the trackname as a string
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetTrackSelection_TrackStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>string alteredTrackStateChunk = ultraschall.SetTrackSelection_TrackStateChunk(integer selection_state, string TrackStateChunk)</functioncall>
  <description>
    set selection of the track in a TrackStateChunk.    
    
    It's the entry SEL.
    
    Works only with statechunks stored in ProjectStateChunks, due API-limitations!
  </description>
  <retvals>
    string alteredTrackStateChunk - the altered TrackStateChunk with the new selection
  </retvals>
  <parameters>    
    integer selection_state - 0, track is unselected; 1, track is selected
    string TrackStateChunk - a TrackStateChunk whose selection-state you want to set; works only with TrackStateChunks from ProjectStateChunks!
  </parameters>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, selection, state, get, trackstatechunk</tags>
</US_DocBloc>
--]]

  -- check parameters
  if ultraschall.IsValidTrackStateChunk(TrackStateChunk)==false then ultraschall.AddErrorMessage("GetTrackSelection", "TrackStateChunk", "no valid TrackStateChunk", -1) return nil end
  if math.type(selection_state)~="integer" then ultraschall.AddErrorMessage("GetTrackSelection", "selection_state", "must be an integer", -2) return nil end
  if selection_state<0 or selection_state>1 then ultraschall.AddErrorMessage("GetTrackSelection", "selection_state", "must be either 0 or 1", -3) return nil end
  
  -- set selection
  local Start=TrackStateChunk:match(".-FREEMODE.-\n")
  local End=TrackStateChunk:match("REC.*")
  return Start.."    SEL "..selection_state.."\n    "..End
end


function ultraschall.ClearRoutingMatrix(ClearHWOuts, ClearAuxRecvs, ClearTrackMasterSends, ClearMasterTrack, undo)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ClearRoutingMatrix</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ClearRoutingMatrix(boolean ClearHWOuts, boolean ClearAuxRecvs, boolean ClearTrackMasterSends, boolean ClearMasterTrack, boolean undo)</functioncall>
  <description>
    Clears all routing-matrix-settings or optionally part of them
  </description>
  <retvals>
    boolean retval - true, clearing was successful; false, clearing was unsuccessful
  </retvals>
  <parameters>
    boolean ClearHWOuts - nil or true, clear all HWOuts; false, keep the HWOuts intact
    boolean ClearAuxRecvs - nil or true, clear all Send/Receive-settings; false, keep the Send/Receive-settings intact
    boolean ClearTrackMasterSends - nil or true, clear all send to master-checkboxes; false, keep them intact
    boolean ClearMasterTrack - nil or true, include the Mastertrack as well; false, don't include it
    boolean undo - true, set undo point; false or nil, don't set undo point
  </parameters>
  <chapter_context>
    Track Management
    Hardware Out
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>routing, trackmanagement, routing matrix, clear, tracksend, mainsend, receive, send, hwout, mastertrack</tags>
</US_DocBloc>
--]]
  if ClearHWOuts~=nil and type(ClearHWOuts)~="boolean" then ultraschall.AddErrorMessage("ClearRoutingMatrix", "ClearHWOuts", "must be either nil or boolean", -1) return false end
  if ClearAuxRecvs~=nil and type(ClearAuxRecvs)~="boolean" then ultraschall.AddErrorMessage("ClearRoutingMatrix", "ClearAuxRecvs", "must be either nil or boolean", -2) return false end
  if ClearTrackMasterSends~=nil and type(ClearTrackMasterSends)~="boolean" then ultraschall.AddErrorMessage("ClearRoutingMatrix", "ClearTrackMasterSends", "must be either nil or boolean", -3) return false end
  if ClearMasterTrack~=nil and type(ClearMasterTrack)~="boolean" then ultraschall.AddErrorMessage("ClearRoutingMatrix", "ClearMasterTrack", "must be either nil or boolean", -4) return false end
  if undo~=nil and type(undo)~="boolean" then ultraschall.AddErrorMessage("ClearRoutingMatrix", "undo", "must be either nil or boolean", -5) return false end
  if undo==nil then undo=false end
  if ClearMasterTrack==false then minimumTrack=1 else minimumTrack=0 end
  
  local track, A
  for i=minimumTrack, reaper.CountTracks(0) do
    if i==0 then track=reaper.GetMasterTrack(0) else track=reaper.GetTrack(0,i-1) end
    if ClearHWOuts~=false then 
      ultraschall.DeleteTrackHWOut(i,-1,undo) 
    end
    if ClearAuxRecvs~=false then 
        --print2(i, -1, undo)
      ultraschall.DeleteTrackAUXSendReceives(i,-1) 
    end
    if ClearTrackMasterSends~=false then 
      local MainSendOn, ParentChannels = ultraschall.GetTrackMainSendState(i)
      ultraschall.SetTrackMainSendState(i, 0, ParentChannels)
    end
  end
  return true
end

--A=ultraschall.ClearRoutingMatrix(nil,nil,nil,nil,nil)
--O=ultraschall.ClearRoutingMatrix(false, true, false, true, false)

--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ClearRoutingMatrix</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ClearRoutingMatrix(boolean ClearHWOuts, boolean ClearAuxRecvs, boolean ClearTrackMasterSends, boolean ClearMasterTrack, boolean undo)</functioncall>
  <description>
    Clears all routing-matrix-settings or optionally part of them
  </description>
  <retvals>
    boolean retval - true, clearing was successful; false, clearing was unsuccessful
  </retvals>
  <parameters>
    boolean ClearHWOuts - nil or true, clear all HWOuts; false, keep the HWOuts intact
    boolean ClearAuxRecvs - nil or true, clear all Send/Receive-settings; false, keep the Send/Receive-settings intact
    boolean ClearTrackMasterSends - nil or true, clear all send to master-checkboxes; false, keep them intact
    boolean ClearMasterTrack - nil or true, include the Mastertrack as well; false, don't include it
    boolean undo - true, set undo point; false or nil, don't set undo point
  </parameters>
  <chapter_context>
    Track Management
    Send/Receive-Routing
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>routing, trackmanagement, routing matrix, clear, tracksend, mainsend, receive, send, hwout, mastertrack</tags>
</US_DocBloc>
--]]


function ultraschall.GetTracknumberByGuid(guid)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTracknumberByGuid</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    SWS=2.9.7
    Lua=5.3
  </requires>
  <functioncall>integer tracknumber, MediaTrack tr = ultraschall.GetTracknumberByGuid(string guid)</functioncall>
  <description>
    returns the tracknumber and track of a guid. The track must be in the currently active project!
    
    Supports the returned guids by reaper.BR_GetMediaTrackGUID and reaper.GetTrackGUID.
    
    returns -1 in case of an error
  </description>
  <retvals>
    integer tracknumber - the number of the track; 0, for master track; 1, for track 1; 2, for track 2, etc. -1, in case of an error
    MediaTrack tr - the MediaTrack-object of the requested track; nil, if no track is found
  </retvals>
  <parameters>
    string gui - the guid of the track, that you want to request
  </parameters>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>track management, get, track, guid, tracknumber</tags>
</US_DocBloc>
--]]
  if ultraschall.IsValidGuid(guid, true)==false then ultraschall.AddErrorMessage("GetTracknumberByGuid", "guid", "no valid guid", -1) return -1 end
  if reaper.GetTrackGUID(reaper.GetMasterTrack(0))==guid then return 0, reaper.GetMasterTrack(0) end
  if guid=="{00000000-0000-0000-0000-000000000000}" then 
    return 0, reaper.GetMasterTrack(0)
  else 
    local MediaTrack = reaper.BR_GetMediaTrackByGUID(0, guid)
    if MediaTrack==nil then ultraschall.AddErrorMessage("GetTracknumberByGuid", "guid", "no track with that guid available", -2) return -1 end
    return math.floor(reaper.GetMediaTrackInfo_Value(MediaTrack, "IP_TRACKNUMBER") ), MediaTrack 
  end
end


function ultraschall.GetAllHWOuts()
  -- returned table is of structure:
  --    table[tracknumber]["HWOut_count"]                 - the number of HWOuts of tracknumber, beginning with 1
  --    table[tracknumber][HWOutIndex]["outputchannel"]   - the number of outputchannels of this HWOutIndex of tracknumber
  --    table[tracknumber][HWOutIndex]["post_pre_fader"]  - the setting of post-pre-fader of this HWOutIndex of tracknumber
  --    table[tracknumber][HWOutIndex]["volume"]          - the volume of this HWOutIndex of tracknumber
  --    table[tracknumber][HWOutIndex]["pan"]             - the panning of this HWOutIndex of tracknumber
  --    table[tracknumber][HWOutIndex]["mute"]            - the mute-setting of this HWOutIndex of tracknumber
  --    table[tracknumber][HWOutIndex]["phase"]           - the phase-setting of this HWOutIndex of tracknumber
  --    table[tracknumber][HWOutIndex]["source"]          - the source/input of this HWOutIndex of tracknumber
  --    table[tracknumber][HWOutIndex]["unknown"]         - unknown, leave it -1
  --    table[tracknumber][HWOutIndex]["automationmode"]  - the automation-mode of this HWOutIndex of tracknumber
  --
  -- tracknumber 0 is the Master-Track

--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllHWOuts</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>table AllHWOuts, integer number_of_tracks = ultraschall.GetAllHWOuts()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    returns a table with all HWOut-settings of all tracks, including master-track(track index: 0)
    
    returned table is of structure:
      table["HWOuts"]=true                              - signals, this is a HWOuts-table; don't change that!
      table["number\_of_tracks"]                         - the number of tracks in this table, from track 0(master) to track n
      table[tracknumber]["HWOut_count"]                 - the number of HWOuts of tracknumber, beginning with 1
      table[tracknumber]["TrackID"]                     - the unique id of the track as guid; can be used to get the MediaTrack using reaper.BR_GetMediaTrackByGUID(0, guid)
      table[tracknumber][HWOutIndex]["outputchannel"]   - the number of outputchannels of this HWOutIndex of tracknumber
      table[tracknumber][HWOutIndex]["post\_pre_fader"] - the setting of post-pre-fader of this HWOutIndex of tracknumber
      table[tracknumber][HWOutIndex]["volume"]          - the volume of this HWOutIndex of tracknumber
      table[tracknumber][HWOutIndex]["pan"]             - the panning of this HWOutIndex of tracknumber
      table[tracknumber][HWOutIndex]["mute"]            - the mute-setting of this HWOutIndex of tracknumber
      table[tracknumber][HWOutIndex]["phase"]           - the phase-setting of this HWOutIndex of tracknumber
      table[tracknumber][HWOutIndex]["source"]          - the source/input of this HWOutIndex of tracknumber
      table[tracknumber][HWOutIndex]["pan\_law"]         - pan-law, default is -1
      table[tracknumber][HWOutIndex]["automationmode"]  - the automation-mode of this HWOutIndex of tracknumber    
      
      See [GetTrackHWOut](#GetTrackHWOut) for more details on the individual settings, stored in the entries.
  </description>
  <retvals>
    table AllHWOuts - a table with all HWOuts of the current project.
    integer number_of_tracks - the number of tracks in the AllMainSends-table
  </retvals>
  <chapter_context>
    Track Management
    Hardware Out
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, get, all, hwouts, hardware outputs, routing</tags>
</US_DocBloc>
]]

  local HWOuts={}
  HWOuts["number_of_tracks"]=reaper.CountTracks()
  HWOuts["HWOuts"]=true

  for i=0, reaper.CountTracks() do
    HWOuts[i]={}
    local count_HWOuts = ultraschall.CountTrackHWOuts(i)
    HWOuts[i]["HWOut_count"]=count_HWOuts
    if i>0 then 
      HWOuts[i]["TrackID"]=reaper.BR_GetMediaTrackGUID(reaper.GetTrack(0,i-1))
    else
      HWOuts[i]["TrackID"]=reaper.BR_GetMediaTrackGUID(reaper.GetMasterTrack(0))
    end
    for a=1, count_HWOuts do
      HWOuts[i][a]={}
      HWOuts[i][a]["outputchannel"],
      HWOuts[i][a]["post_pre_fader"],
      HWOuts[i][a]["volume"], 
      HWOuts[i][a]["pan"], 
      HWOuts[i][a]["mute"], 
      HWOuts[i][a]["phase"], 
      HWOuts[i][a]["source"], 
      HWOuts[i][a]["pan_law"], 
      HWOuts[i][a]["automationmode"] = ultraschall.GetTrackHWOut(i, a)
    end
  end
  return HWOuts, reaper.CountTracks()
end

--A=ultraschall.GetAllHWOuts()

function ultraschall.ApplyAllHWOuts(AllHWOuts, option)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ApplyAllHWOuts</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ApplyAllHWOuts(table AllHWOuts, optional integer option)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Takes a table, as returned by [GetAllHWOuts](#GetAllHWOuts) with all HWOut-settings of all tracks and applies it to all tracks.

    When you set option to 2, the individual entries will be applied to the tracks, that have the guids stored in table
    table[tracknumber]["TrackID"], otherwise, this function will apply it to track0 to trackn, which is the same as table["number\_of_tracks"].
    That way, you can create RoutingSnapshots, that will stay in the right tracks, even if they are ordered differently or when tracks have been added/deleted.

    This influences the MasterTrack as well!
    
    expected table is of structure:
      
      table["HWOuts"]=true                              - signals, this is a HWOuts-table; don't change that!
      table["number\_of_tracks"]                         - the number of tracks in this table, from track 0(master) to track n
      table[tracknumber]["HWOut_count"]                 - the number of HWOuts of tracknumber, beginning with 1
      table[tracknumber]["TrackID"]                     - the unique id of the track as guid; can be used to get the MediaTrack using reaper.BR_GetMediaTrackByGUID(0, guid)
      table[tracknumber][HWOutIndex]["outputchannel"]   - the number of outputchannels of this HWOutIndex of tracknumber
      table[tracknumber][HWOutIndex]["post\_pre_fader"] - the setting of post-pre-fader of this HWOutIndex of tracknumber
      table[tracknumber][HWOutIndex]["volume"]          - the volume of this HWOutIndex of tracknumber
      table[tracknumber][HWOutIndex]["pan"]             - the panning of this HWOutIndex of tracknumber
      table[tracknumber][HWOutIndex]["mute"]            - the mute-setting of this HWOutIndex of tracknumber
      table[tracknumber][HWOutIndex]["phase"]           - the phase-setting of this HWOutIndex of tracknumber
      table[tracknumber][HWOutIndex]["source"]          - the source/input of this HWOutIndex of tracknumber
      table[tracknumber][HWOutIndex]["pan\_law"]         - pan-law, default is -1
      table[tracknumber][HWOutIndex]["automationmode"]  - the automation-mode of this HWOutIndex of tracknumber    
          
      See [GetTrackHWOut](#GetTrackHWOut) for more details on the individual settings, stored in the entries.
  </description>
  <parameters>
    table AllHWOuts - a table with all AllHWOut-entries of the current project
    optional integer option - nil or 1, HWOuts will be applied to Track 0(MasterTrack) to table["number_of_tracks"]; 2, HWOuts will be applied to the tracks with the guid TrackID
  </parameters>
  <retvals>
    boolean retval - true, setting was successful; false, it was unsuccessful
  </retvals>
  <chapter_context>
    Track Management
    Hardware Out
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, all, hwout, routing</tags>
</US_DocBloc>
]]
  if type(AllHWOuts)~="table" then ultraschall.AddErrorMessage("ApplyAllHWOuts", "AllHWOuts", "Must be a table.", -1) return false end
  if AllHWOuts["number_of_tracks"]==nil or AllHWOuts["HWOuts"]~=true then ultraschall.AddErrorMessage("ApplyAllHWOuts", "AllHWOuts", "Must be a valid AllAUXSendReceives, as returned by GetAllAUXSendReceive. Get it from there, alter that and pass it into here.", -2) return false end 
  local trackstatechunk, retval, aa
  for i=0, AllHWOuts["number_of_tracks"] do
    if option==2 then aa=ultraschall.GetTracknumberByGuid(AllHWOuts[i]["TrackID"]) else aa=i end
    retval, trackstatechunk = ultraschall.GetTrackStateChunk_Tracknumber(aa)
    for a=1, AllHWOuts[i]["HWOut_count"] do
      retval, trackstatechunk = ultraschall.SetTrackHWOut(-1, a, 
                                   AllHWOuts[i][a]["outputchannel"],
                                   AllHWOuts[i][a]["post_pre_fader"],
                                   AllHWOuts[i][a]["volume"], 
                                   AllHWOuts[i][a]["pan"], 
                                   AllHWOuts[i][a]["mute"], 
                                   AllHWOuts[i][a]["phase"], 
                                   AllHWOuts[i][a]["source"], 
                                   AllHWOuts[i][a]["pan_law"], 
                                   AllHWOuts[i][a]["automationmode"],
                                   trackstatechunk)
      end
    
      ultraschall.SetTrackStateChunk_Tracknumber(aa, trackstatechunk, false)
--      reaper.MB(tostring(trackstatechunk),"",0)
  end
  return true
end

function ultraschall.GetAllAUXSendReceives()
  -- returned table is of structure:
  --    table[tracknumber]["AUXSendReceives_count"]                   - the number of AUXSendReceives of tracknumber, beginning with 1
  --    table[tracknumber][AUXSendReceivesIndex]["recv_tracknumber"]  - the track, from which to receive audio in this AUXSendReceivesIndex of tracknumber
  --    table[tracknumber][AUXSendReceivesIndex]["post_pre_fader"]    - the setting of post-pre-fader of this AUXSendReceivesIndex of tracknumber
  --    table[tracknumber][AUXSendReceivesIndex]["volume"]            - the volume of this AUXSendReceivesIndex of tracknumber
  --    table[tracknumber][AUXSendReceivesIndex]["pan"]               - the panning of this AUXSendReceivesIndex of tracknumber
  --    table[tracknumber][AUXSendReceivesIndex]["mute"]              - the mute-setting of this AUXSendReceivesIndex  of tracknumber
  --    table[tracknumber][AUXSendReceivesIndex]["mono_stereo"]       - the mono/stereo-button-setting of this AUXSendReceivesIndex  of tracknumber
  --    table[tracknumber][AUXSendReceivesIndex]["phase"]             - the phase-setting of this AUXSendReceivesIndex  of tracknumber
  --    table[tracknumber][AUXSendReceivesIndex]["chan_src"]          - the audiochannel-source of this AUXSendReceivesIndex of tracknumber
  --    table[tracknumber][AUXSendReceivesIndex]["snd_src"]           - the send-to-channel-target of this AUXSendReceivesIndex of tracknumber
  --    table[tracknumber][AUXSendReceivesIndex]["unknown"]           - unknown, leave it -1
  --    table[tracknumber][AUXSendReceivesIndex]["midichanflag"]      - the Midi-channel of this AUXSendReceivesIndex of tracknumber, leave it 0
  --    table[tracknumber][AUXSendReceivesIndex]["automation"]        - the automation-mode of this AUXSendReceivesIndex  of tracknumber

--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllAUXSendReceives</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>table AllAUXSendReceives, integer number_of_tracks = ultraschall.GetAllAUXSendReceives()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    returns a table with all AUX-SendReceive-settings of all tracks, excluding master-track
    
    returned table is of structure:
      table["AllAUXSendReceive"]=true                               - signals, this is an AllAUXSendReceive-table. Don't alter!
      table["number\_of_tracks"]                                     - the number of tracks in this table, from track 1 to track n
      table[tracknumber]["AUXSendReceives_count"]                   - the number of AUXSendReceives of tracknumber, beginning with 1
      table[tracknumber]["TrackID"]                                 - the unique id of the track as guid; can be used to get the MediaTrack using reaper.BR_GetMediaTrackByGUID(0, guid)
      table[tracknumber][AUXSendReceivesIndex]["recv\_tracknumber"] - the track, from which to receive audio in this AUXSendReceivesIndex of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["recv\_track\_guid"] - the guid of the receive-track; with that, you can be sure to get the right receive-track, even if trackorder changes
      table[tracknumber][AUXSendReceivesIndex]["post\_pre_fader"]   - the setting of post-pre-fader of this AUXSendReceivesIndex of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["volume"]            - the volume of this AUXSendReceivesIndex of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["pan"]               - the panning of this AUXSendReceivesIndex of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["mute"]              - the mute-setting of this AUXSendReceivesIndex  of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["mono\_stereo"]      - the mono/stereo-button-setting of this AUXSendReceivesIndex  of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["phase"]             - the phase-setting of this AUXSendReceivesIndex  of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["chan\_src"]         - the audiochannel-source of this AUXSendReceivesIndex of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["snd\_src"]          - the send-to-channel-target of this AUXSendReceivesIndex of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["pan\_law"]           - pan-law, default is -1
      table[tracknumber][AUXSendReceivesIndex]["midichanflag"]      - the Midi-channel of this AUXSendReceivesIndex of tracknumber, leave it 0
      table[tracknumber][AUXSendReceivesIndex]["automation"]        - the automation-mode of this AUXSendReceivesIndex  of tracknumber
      
      See [GetTrackAUXSendReceives](#GetTrackAUXSendReceives) for more details on the individual settings, stored in the entries.
  </description>
  <retvals>
    table AllAUXSendReceives - a table with all SendReceive-entries of the current project.
    integer number_of_tracks - the number of tracks in the AllMainSends-table
  </retvals>
  <chapter_context>
    Track Management
    Send/Receive-Routing
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, get, all, send, receive, aux, routing</tags>
</US_DocBloc>
]]

  local AUXSendReceives={}
  AUXSendReceives["number_of_tracks"]=reaper.CountTracks()
  AUXSendReceives["AllAUXSendReceives"]=true 
  
  for i=1, reaper.CountTracks() do
    AUXSendReceives[i]={}
    local count_AUXSendReceives = ultraschall.CountTrackAUXSendReceives(i)
    AUXSendReceives[i]["AUXSendReceives_count"]=count_AUXSendReceives
    AUXSendReceives[i]["TrackID"]=reaper.GetTrackGUID(reaper.GetTrack(0,i-1))

    for a=1, count_AUXSendReceives do
      AUXSendReceives[i][a]={}
      AUXSendReceives[i][a]["recv_tracknumber"],
      AUXSendReceives[i][a]["post_pre_fader"],
      AUXSendReceives[i][a]["volume"], 
      AUXSendReceives[i][a]["pan"], 
      AUXSendReceives[i][a]["mute"], 
      AUXSendReceives[i][a]["mono_stereo"], 
      AUXSendReceives[i][a]["phase"], 
      AUXSendReceives[i][a]["chan_src"], 
      AUXSendReceives[i][a]["snd_src"], 
      AUXSendReceives[i][a]["pan_law"], 
      AUXSendReceives[i][a]["midichanflag"], 
      AUXSendReceives[i][a]["automation"] = ultraschall.GetTrackAUXSendReceives(i, a)     
      AUXSendReceives[i][a]["recv_track_guid"]=reaper.GetTrackGUID(reaper.GetTrack(0,AUXSendReceives[i][a]["recv_tracknumber"]))
      --]]
    end
  end
  return AUXSendReceives, reaper.CountTracks()
end

--A,B,C=ultraschall.GetAllAUXSendReceives()

function ultraschall.ApplyAllAUXSendReceives(AllAUXSendReceives, option)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ApplyAllAUXSendReceives</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ApplyAllAUXSendReceives(table AllAUXSendReceives, optional integer option)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    takes a table, as returned by [GetAllAUXSendReceive](#GetAllAUXSendReceive) with all AUXSendReceive-settings of all tracks and applies it to all tracks.

    When you set option to 2, the individual entries will be applied to the tracks, that have the guids stored in table
    table[tracknumber]["TrackID"], otherwise, this function will apply it to track1 to trackn, which is the same as table["number\_of_tracks"].
    That way, you can create RoutingSnapshots, that will stay in the right tracks, even if they are ordered differently or when tracks have been added/deleted.

    
    expected table is of structure:
      table["AllAUXSendReceive"]=true                               - signals, this is an AllAUXSendReceive-table. Don't alter!
      table["number\_of_tracks"]                                     - the number of tracks in this table, from track 1 to track n
      table[tracknumber]["AUXSendReceives_count"]                   - the number of AUXSendReceives of tracknumber, beginning with 1
      table[tracknumber]["TrackID"]                                 - the unique id of the track as guid; can be used to get the MediaTrack using reaper.BR_GetMediaTrackByGUID(0, guid)
      table[tracknumber][AUXSendReceivesIndex]["recv\_tracknumber"] - the track, from which to receive audio in this AUXSendReceivesIndex of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["recv\_track\_guid"] - the guid of the receive-track; with that, you can be sure to get the right receive-track, even if trackorder changes
      table[tracknumber][AUXSendReceivesIndex]["post\_pre_fader"]   - the setting of post-pre-fader of this AUXSendReceivesIndex of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["volume"]            - the volume of this AUXSendReceivesIndex of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["pan"]               - the panning of this AUXSendReceivesIndex of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["mute"]              - the mute-setting of this AUXSendReceivesIndex  of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["mono\_stereo"]      - the mono/stereo-button-setting of this AUXSendReceivesIndex  of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["phase"]             - the phase-setting of this AUXSendReceivesIndex  of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["chan\_src"]         - the audiochannel-source of this AUXSendReceivesIndex of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["snd\_src"]          - the send-to-channel-target of this AUXSendReceivesIndex of tracknumber
      table[tracknumber][AUXSendReceivesIndex]["pan\_law"]           - pan-law, default is -1
      table[tracknumber][AUXSendReceivesIndex]["midichanflag"]      - the Midi-channel of this AUXSendReceivesIndex of tracknumber, leave it 0
      table[tracknumber][AUXSendReceivesIndex]["automation"]        - the automation-mode of this AUXSendReceivesIndex  of tracknumber
      
      See [GetTrackAUXSendReceives](#GetTrackAUXSendReceives) for more details on the individual settings, stored in the entries.
  </description>
  <parameters>
    table AllAUXSendReceives - a table with all AllAUXSendReceive-entries of the current project
    optional integer option - nil or 1, AUXRecvs will be applied to Track 1 to table["number_of_tracks"]; 2, AUXRecvs will be applied to the tracks with the guid TrackID
  </parameters>
  <retvals>
    boolean retval - true, setting was successful; false, it was unsuccessful
  </retvals>
  <chapter_context>
    Track Management
    Send/Receive-Routing
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, all, send, receive, aux, routing</tags>
</US_DocBloc>
]]
  if type(AllAUXSendReceives)~="table" then ultraschall.AddErrorMessage("GetAllAUXSendReceives", "AllAUXSendReceives", "Must be a table.", -1) return false end
  if AllAUXSendReceives["number_of_tracks"]==nil or AllAUXSendReceives["AllAUXSendReceives"]~=true then ultraschall.AddErrorMessage("GetAllAUXSendReceives", "AllAUXSendReceives", "Must be a valid AllAUXSendReceives, as returned by GetAllAUXSendReceive. Get it from there, alter that and pass it into here.", -2) return false end 

  local trackstatechunk, retval, b
  
  for i=1, AllAUXSendReceives["number_of_tracks"] do
    if option~=2 then b=i
    else b=ultraschall.GetTracknumberByGuid(AllAUXSendReceives[i]["TrackID"]) 
    end
    retval, trackstatechunk = ultraschall.GetTrackStateChunk_Tracknumber(b)
--    print_alt(b,i, ultraschall.IsValidTrackStateChunk(trackstatechunk),"\n")
    
    for a=1, AllAUXSendReceives[i]["AUXSendReceives_count"] do
      if option~=2 then
        retval, trackstatechunk=ultraschall.SetTrackAUXSendReceives(-1, a, 
             AllAUXSendReceives[i][a]["recv_tracknumber"],
             AllAUXSendReceives[i][a]["post_pre_fader"],
             AllAUXSendReceives[i][a]["volume"], 
             AllAUXSendReceives[i][a]["pan"], 
             AllAUXSendReceives[i][a]["mute"], 
             AllAUXSendReceives[i][a]["mono_stereo"], 
             AllAUXSendReceives[i][a]["phase"], 
             AllAUXSendReceives[i][a]["chan_src"], 
             AllAUXSendReceives[i][a]["snd_src"], 
             AllAUXSendReceives[i][a]["pan_law"], 
             AllAUXSendReceives[i][a]["midichanflag"], 
             AllAUXSendReceives[i][a]["automation"],
             trackstatechunk)--]]
      else
           retval, trackstatechunk=ultraschall.SetTrackAUXSendReceives(-1, a, 
                ultraschall.GetTracknumberByGuid(AllAUXSendReceives[i][a]["recv_track_guid"])-1,
                AllAUXSendReceives[i][a]["post_pre_fader"],
                AllAUXSendReceives[i][a]["volume"], 
                AllAUXSendReceives[i][a]["pan"], 
                AllAUXSendReceives[i][a]["mute"], 
                AllAUXSendReceives[i][a]["mono_stereo"], 
                AllAUXSendReceives[i][a]["phase"], 
                AllAUXSendReceives[i][a]["chan_src"], 
                AllAUXSendReceives[i][a]["snd_src"], 
                AllAUXSendReceives[i][a]["pan_law"], 
                AllAUXSendReceives[i][a]["midichanflag"], 
                AllAUXSendReceives[i][a]["automation"],
                trackstatechunk)--]]
      end
    end
      ultraschall.SetTrackStateChunk_Tracknumber(b, trackstatechunk, false)
      --print(P)
  end
  return true
end


function ultraschall.GetAllMainSendStates()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllMainSendStates</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    SWS=2.9.7
    Lua=5.3
  </requires>
  <functioncall>table AllMainSends, integer number_of_tracks  = ultraschall.GetAllMainSendStates()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    returns a table with all MainSend-settings of all tracks, excluding master-track.
    
    The MainSend-settings are the settings, if a certain track sends it's signal to the Master Track
    
    returned table is of structure:
      Table["number\_of_tracks"]            - The number of tracks in this table, from track 1 to track n
      Table["MainSend"]=true               - signals, this is an AllMainSends-table
      table[tracknumber]["TrackID"]        - the unique id of the track as guid; can be used to get the MediaTrack using reaper.BR_GetMediaTrackByGUID(0, guid)
      Table[tracknumber]["MainSendOn"]     - Send to Master on(1) or off(1)
      Table[tracknumber]["ParentChannels"] - the parent channels of this track
      
      See [GetTrackMainSendState](#GetTrackMainSendState) for more details on the individual settings, stored in the entries.
  </description>
  <retvals>
    table AllMainSends - a table with all AllMainSends-entries of the current project.
    integer number_of_tracks - the number of tracks in the AllMainSends-table
  </retvals>
  <chapter_context>
    Track Management
    Send/Receive-Routing
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, get, all, send, main send, master send, routing</tags>
</US_DocBloc>
]]
  
  local MainSend={}
  MainSend["number_of_tracks"]=reaper.CountTracks()
  MainSend["MainSend"]=true
  for i=1, reaper.CountTracks() do
    MainSend[i]={}
    MainSend[i]["TrackID"]=reaper.BR_GetMediaTrackGUID(reaper.GetTrack(0,i-1))
    MainSend[i]["MainSendOn"], MainSend[i]["ParentChannels"] = ultraschall.GetTrackMainSendState(i)
  end
  return MainSend, reaper.CountTracks()
end

--A,B=ultraschall.GetAllMainSendStates()

function ultraschall.ApplyAllMainSendStates(AllMainSendsTable, option)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ApplyAllMainSendStates</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ApplyAllMainSendStates(table AllMainSendsTable, optional integer option)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    takes a table, as returned by [GetAllMainSendStates](#GetAllMainSendStates) with all MainSend-settings of all tracks and applies it to all tracks.
    
    The MainSend-settings are the settings, if a certain track sends it's signal to the Master Track.
    
    When you set option to 2, the individual entries will be applied to the tracks, that have the guids stored in table
    table[tracknumber]["TrackID"], otherwise, this function will apply it to track0 to trackn, which is the same as table["number\_of_tracks"].
    That way, you can create RoutingSnapshots, that will stay in the right tracks, even if they are ordered differently or when tracks have been added/deleted.
    
    This influences the MasterTrack as well!
    
    expected table is of structure:
      Table["number\_of_tracks"]            - The number of tracks in this table, from track 1 to track n
      Table["MainSend"]=true               - signals, this is an AllMainSends-table
      table[tracknumber]["TrackID"]        - the unique id of the track as guid; can be used to get the MediaTrack using reaper.BR_GetMediaTrackByGUID(0, guid)
      Table[tracknumber]["MainSendOn"]     - Send to Master on(1) or off(1)
      Table[tracknumber]["ParentChannels"] - the parent channels of this track
      
      See [GetTrackMainSendState](#GetTrackMainSendState) for more details on the individual settings, stored in the entries.
  </description>
  <parameters>
    table AllMainSends - a table with all AllMainSends-entries of the current project
    optional integer option - nil or 1, MainSend-settings will be applied to Track 1 to table["number_of_tracks"]; 2, MasterSends will be applied to the tracks with the guid stored in table[tracknumber]["TrackID"].
  </parameters>
  <retvals>
    boolean retval - true, setting was successful; false, it was unsuccessful
  </retvals>
  <chapter_context>
    Track Management
    Send/Receive-Routing
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, track, set, all, send, main send, master send, routing</tags>
</US_DocBloc>
]]
  if type(AllMainSendsTable)~="table" then ultraschall.AddErrorMessage("ApplyAllMainSendStates", "AllMainSendsTable", "Must be a table.", -1) return false end
  if AllMainSendsTable["number_of_tracks"]==nil or AllMainSendsTable["MainSend"]==nil  then 
    ultraschall.AddErrorMessage("ApplyAllMainSendStates", "AllMainSendsTable", "Must be a valid AllMainSendsTable, as returned by GetAllMainSendStates. Get it from there, alter that and pass it into here.", -2) return false 
  end
  local a
  for i=1, AllMainSendsTable["number_of_tracks"] do
    if option~=2 then a=i
    else a=ultraschall.GetTracknumberByGuid(AllMainSendsTable[i]["TrackID"]) 
    end
    ultraschall.SetTrackMainSendState(a, AllMainSendsTable[i]["MainSendOn"], AllMainSendsTable[i]["ParentChannels"])
  end
  return true
end


function ultraschall.AreHWOutsTablesEqual(Table1, Table2, option)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AreHWOutsTablesEqual</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>boolean retval  = ultraschall.AreHWOutsTablesEqual(table AllHWOuts, table AllHWOuts2, optional integer option)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Compares two HWOuts-tables, as returned by [GetAllHWOuts](#GetAllHWOuts) or [GetAllHWOuts2](#GetAllHWOuts)

    if option=2 then it will also compare, if the stored track-guids are the equal. Otherwise, it will only check the individual settings, even if the guids are different between the two tables.
  </description>
  <retvals>
    boolean retval - true, if the two tables are equal HWOuts; false, if not
  </retvals>
  <parameters>
    table AllHWOuts - a table with all HWOut-settings of all tracks
    table AllHWOuts2 - a table with all HWOut-settings of all tracks, that you want to compare to AllHWOuts
    optional integer option - nil or 1, to compare everything, except the stored TrackGuids; 2, include comparing the stored TrackGuids as well
  </parameters>
  <chapter_context>
    Track Management
    Hardware Out
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, compare, equal, hwouttable</tags>
</US_DocBloc>
]]
  if type(Table1)~="table" then return false end
  if type(Table2)~="table" then return false end
  if Table1["HWOuts"]~=true or Table2["HWOuts"]~=true then return false end
  if Table1["HWOuts"]~=Table2["HWOuts"] then return false end
  if Table1["number_of_tracks"]~=Table2["number_of_tracks"] then return false end
  for i=0, Table1["number_of_tracks"] do
    if Table1[i]["HWOut_count"]~=Table2[i]["HWOut_count"] then return false end
    if Table1[i]["type"]~=nil and Table2[i]["type"]~=nil and Table1[i]["type"]~=Table2[i]["type"] then return false end
    for a=1, Table1[i]["HWOut_count"] do
      if option==2 and Table1[i]["TrackID"]~=Table2[i]["TrackID"] then return false end
      if Table1[i][a]["automationmode"]~=Table2[i][a]["automationmode"] then return false end
      if Table1[i][a]["mute"]~=Table2[i][a]["mute"] then return false end
      if Table1[i][a]["outputchannel"]~=Table2[i][a]["outputchannel"] then return false end
      if Table1[i][a]["pan"]~=Table2[i][a]["pan"] then return false end
      if Table1[i][a]["phase"]~=Table2[i][a]["phase"] then return false end
      if Table1[i][a]["post_pre_fader"]~=Table2[i][a]["post_pre_fader"] then return false end
      if Table1[i][a]["source"]~=Table2[i][a]["source"] then return false end
      if Table1[i][a]["pan_law"]~=Table2[i][a]["pan_law"] then return false end
      if Table1[i][a]["volume"]~=Table2[i][a]["volume"] then return false end
    end
  end
  return true
end

--AllHWOuts=ultraschall.GetAllHWOuts2()
--AllHWOuts2=ultraschall.GetAllHWOuts2()
--AllHWOuts[0]["TrackID"]=3
--AAAA=ultraschall.AreHWOutsTablesEqual(AllHWOuts, AllHWOuts2, 1)



--AllMainSends, number_of_tracks = ultraschall.GetAllMainSendStates2() 
--AllMainSends2, number_of_tracks = ultraschall.GetAllMainSendStates2() 

function ultraschall.AreMainSendsTablesEqual(Table1, Table2, option)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AreMainSendsTablesEqual</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>boolean retval  = ultraschall.AreMainSendsTablesEqual(table AllMainSends, table AllMainSends2, optional integer option)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Compares two AllMainSends-tables, as returned by [GetAllMainSendStates](#GetAllMainSendStates) or [GetAllMainSendStates2](#GetAllMainSendStates2)

    if option=2 then it will also compare, if the stored track-guids are the equal. Otherwise, it will only check the individual settings, even if the guids are different between the two tables.
  </description>
  <retvals>
    boolean retval - true, if the two tables are equal AllMainSends; false, if not
  </retvals>
  <parameters>
    table AllMainSends - a table with all AllMainSends-settings of all tracks
    table AllMainSends2 - a table with all AllMainSends-settings of all tracks, that you want to compare to AllMainSends
    optional integer option - nil or 1, to compare everything, except the stored TrackGuids; 2, include comparing the stored TrackGuids as well
  </parameters>
  <chapter_context>
    Track Management
    Send/Receive-Routing
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, compare, equal, allmainsendstable</tags>
</US_DocBloc>
]]
  if type(Table1)~="table" then return false end
  if type(Table2)~="table" then return false end
  if Table1["MainSend"]~=true or Table2["MainSend"]~=true then return false end
  if Table1["MainSend"]~=Table2["MainSend"] then return false end
  if Table1["number_of_tracks"]~=Table2["number_of_tracks"] then return false end
  for i=1, Table1["number_of_tracks"] do
    if option==2 and Table1[i]["TrackID"]~=Table2[i]["TrackID"] then return false end
    if Table1[i]["type"]~=nil and Table2[i]["type"]~=nil and Table1[i]["type"]~=Table2[i]["type"] then return false end
    if Table1[i]["MainSendOn"]~=Table2[i]["MainSendOn"] then return false end
    if Table1[i]["ParentChannels"]~=Table2[i]["ParentChannels"] then return false end
  end
  return true
end

--AllMainSends[1]["TrackID"]=0

--AA=ultraschall.AreMainSendsTablesEqual(AllMainSends, AllMainSends2,2)



--AllAUXSendReceives, number_of_tracks = ultraschall.GetAllAUXSendReceives2()
--AllAUXSendReceives2, number_of_tracks = ultraschall.GetAllAUXSendReceives2()

function ultraschall.AreAUXSendReceivesTablesEqual(Table1, Table2, option)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AreAUXSendReceivesTablesEqual</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>boolean retval  = ultraschall.AreAUXSendReceivesTablesEqual(table AllAUXSendReceives, table AllAUXSendReceives2, optional integer option)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Compares two AllAUXSendReceives-tables, as returned by [GetAllAUXSendReceives](#GetAllAUXSendReceives) or [GetAllAUXSendReceives2](#GetAllAUXSendReceives2)
    
    if option=2 then it will also compare, if the stored track-guids are the equal. Otherwise, it will only check the individual settings, even if the guids are different between the two tables.
  </description>
  <retvals>
    boolean retval - true, if the two tables are equal AllMainSends; false, if not
  </retvals>
  <parameters>
    table AllAUXSendReceives - a table with all AllAUXSendReceives-settings of all tracks
    table AllAUXSendReceives2 - a table with all AllAUXSendReceives-settings of all tracks, that you want to compare to AllAUXSendReceives
    optional integer option - nil or 1, to compare everything, except the stored TrackGuids; 2, include comparing the stored TrackGuids as well
  </parameters>
  <chapter_context>
    Track Management
    Send/Receive-Routing
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, compare, equal, allauxsendreceivestables</tags>
</US_DocBloc>
]]
  if type(Table1)~="table" then return false end
  if type(Table2)~="table" then return false end
  if Table1["AllAUXSendReceives"]~=true or Table2["AllAUXSendReceives"]~=true then return false end
  if Table1["AllAUXSendReceives"]~=Table2["AllAUXSendReceives"] then return false end
  if Table1["number_of_tracks"]~=Table2["number_of_tracks"] then return false end
  for i=1, Table1["number_of_tracks"] do
    if Table1[i]["AUXSendReceives_count"]~=Table2[i]["AUXSendReceives_count"] then return false end
    if option==2 and Table1[i]["TrackID"]~=Table2[i]["TrackID"] then return false end
    if Table1[i]["type"]~=nil and Table2[i]["type"]~=nil and Table1[i]["type"]~=Table2[i]["type"] then return false end
    for a=1, Table1[i]["AUXSendReceives_count"] do
      if Table1[i][a]["automation"]~=Table2[i][a]["automation"] then return false end
      if Table1[i][a]["chan_src"]~=Table2[i][a]["chan_src"] then return false end
      if Table1[i][a]["midichanflag"]~=Table2[i][a]["midichanflag"] then return false end
      if Table1[i][a]["mono_stereo"]~=Table2[i][a]["mono_stereo"] then return false end
      if Table1[i][a]["mute"]~=Table2[i][a]["mute"] then return false end
      if Table1[i][a]["pan"]~=Table2[i][a]["pan"] then return false end
      if Table1[i][a]["phase"]~=Table2[i][a]["phase"] then return false end
      if Table1[i][a]["post_pre_fader"]~=Table2[i][a]["post_pre_fader"] then return false end
      if Table1[i][a]["recv_tracknumber"]~=Table2[i][a]["recv_tracknumber"] then return false end
      if option==2 and Table1[i][a]["recv_track_guid"]~=Table2[i][a]["recv_track_guid"] then return false end
      if Table1[i][a]["snd_src"]~=Table2[i][a]["snd_src"] then return false end
      if Table1[i][a]["pan_law"]~=Table2[i][a]["pan_law"] then return false end
      if Table1[i][a]["volume"]~=Table2[i][a]["volume"] then return false end
    end
  end
  return true
end

--AllAUXSendReceives, number_of_tracks = ultraschall.GetAllAUXSendReceives2()
--AllAUXSendReceives2, number_of_tracks = ultraschall.GetAllAUXSendReceives2()
--AllAUXSendReceives[1]["TrackID"]=1
--A=ultraschall.AreAUXSendReceivesTablesEqual(AllAUXSendReceives, AllAUXSendReceives2, 1)


function ultraschall.DeleteTracks_TrackString(trackstring)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DeleteTracks_TrackString</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.975
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.DeleteTracks_TrackString(string trackstring)</functioncall>
  <description>
    deletes all tracks in trackstring
    
    Returns false in case of an error
  </description>
  <parameters>
    string trackstring - a string with all tracknumbers, separated by commas
  </parameters>
  <retvals>
    boolean retval - true, setting it was successful; false, setting it was unsuccessful
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, delete, track, trackstring</tags>
</US_DocBloc>
]]
  local valid, count, individual_tracknumbers = ultraschall.IsValidTrackString(trackstring)
  if valid==false then ultraschall.AddErrorMessage("DeleteTracks_TrackString", "trackstring", "must be a valid trackstring", -1) return false end
  for i=1, count do
    reaper.DeleteTrack(reaper.GetTrack(0,individual_tracknumbers[i]-1))
  end
  return true
end

function ultraschall.AnyTrackMute(master)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AnyTrackMute</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.979
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.AnyTrackMute()</functioncall>
  <description>
    returns true, if any track is muted, otherwise returns false.
  </description>
  <parameters>
    boolean master - true, include the master-track as well; false, don't include master-track
  </parameters>
  <retvals>
    boolean retval - true, if any track is muted; false, if not
  </retvals>
  <chapter_context>
    Track Management
    Get Track States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, is, track, master, mute</tags>
</US_DocBloc>
]]
  local retval, mute
  
  if master==true then
    retval, mute = reaper.GetTrackUIMute(reaper.GetMasterTrack(0))
    if mute==true then return true end
  end
  
  for i=0, reaper.CountTracks(0)-1 do
    retval, mute = reaper.GetTrackUIMute(reaper.GetTrack(0,i))
    if mute==true then return true end
  end
  return false
end


--A=ultraschall.AnyTrackMute()

