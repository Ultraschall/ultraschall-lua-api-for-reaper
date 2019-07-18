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
---       MediaItem Module        ---
-------------------------------------

if type(ultraschall)~="table" then 
  -- update buildnumber and add ultraschall as a table, when programming within this file
  local retval, string = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "Functions-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  local retval, string = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "MediaItem-Module-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
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

function ultraschall.IsValidMediaItemStateChunk(itemstatechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsValidMediaItemStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.92
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.IsValidMediaItemStateChunk(string MediaItemStateChunk)</functioncall>
  <description>
    Checks, whether MediaItemStateChunk is a valide MediaItemStateChunk.
    
    Returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, MediaItemStateChunk is valid; false, MediaItemStateChunk isn't a valid statechunk
  </retvals>
  <parameters>
    string MediaItemStateChunk - the string to check, if it's a valid MediaItemStateChunk
  </parameters>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, check, mediaitemstatechunk, valid</tags>
</US_DocBloc>
]]
  if type(itemstatechunk)~="string" then ultraschall.AddErrorMessage("IsValidMediaItemStateChunk", "itemstatechunk", "Must be a string.", -1) return false end  
  itemstatechunk=itemstatechunk:match("<ITEM.*%c>\n")
  if itemstatechunk==nil then return false end
  local count1=ultraschall.CountCharacterInString(itemstatechunk, "<")
  local count2=ultraschall.CountCharacterInString(itemstatechunk, ">")
  if count1~=count2 then return false end
  return true
end

function ultraschall.CheckMediaItemArray(MediaItemArray)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CheckMediaItemArray</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, integer count, array retMediaItemArray = ultraschall.CheckMediaItemArray(array MediaItemArray)</functioncall>
  <description>
    Checks, whether MediaItemArray is valid.
    It throws out all entries, that are not MediaItems and returns the altered array as result.
    
    returns false in case of error or if it is not a valid MediaItemArray
  </description>
  <parameters>
    array MediaItemArray - a MediaItemArray that shall be checked for validity
  </parameters>
  <retvals>
    boolean retval - returns true if MediaItemArray is valid, false if not
    integer count - the number of entries in the returned retMediaItemArray
    array retMediaItemArray - the, possibly, altered MediaItemArray
  </retvals>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, check</tags>
</US_DocBloc>
]]
  if type(MediaItemArray)~="table" then ultraschall.AddErrorMessage("CheckMediaItemArray", "MediaItemArray", "Only array with MediaItemObjects as entries is allowed.", -1) return false,0,{} end
  local count=1
  while MediaItemArray[count]~=nil do
    if reaper.ValidatePtr(MediaItemArray[count],"MediaItem*")==false then table.remove(MediaItemArray,count)
    else
      count=count+1
    end
  end
  if count==1 then return false, count-1, MediaItemArray
  else return true, count-1, MediaItemArray
  end
end

function ultraschall.IsValidMediaItemArray(MediaItemArray)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsValidMediaItemArray</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, integer count, array retMediaItemArray = ultraschall.IsValidMediaItemArray(array MediaItemArray)</functioncall>
  <description>
    Checks, whether MediaItemArray is valid.
    It throws out all entries, that are not MediaItems and returns the altered array as result.
    
    returns false in case of error or if it is not a valid MediaItemArray
  </description>
  <parameters>
    array MediaItemArray - a MediaItemArray that shall be checked for validity
  </parameters>
  <retvals>
    boolean retval - returns true if MediaItemArray is valid, false if not
    integer count - the number of entries in the returned retMediaItemArray
    array retMediaItemArray - the, possibly, altered MediaItemArray
  </retvals>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, check</tags>
</US_DocBloc>
]]
  if type(MediaItemArray)~="table" then ultraschall.AddErrorMessage("IsValidMediaItemArray", "MediaItemArray", "Only array with MediaItemObjects as entries is allowed.", -1) return false,0,{} end
  local count=1
  while MediaItemArray[count]~=nil do
    if reaper.ValidatePtr(MediaItemArray[count],"MediaItem*")==false then table.remove(MediaItemArray,count)
    else
      count=count+1
    end
  end
  if count==1 then return false, count-1, MediaItemArray
  else return true, count-1, MediaItemArray
  end
end

function ultraschall.CheckMediaItemStateChunkArray(MediaItemStateChunkArray)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CheckMediaItemStateChunkArray</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, integer count, array retMediaItemStateChunkArray = ultraschall.CheckMediaItemStateChunkArray(array MediaItemStateChunkArray)</functioncall>
  <description>
    Checks, whether MediaItemStateChunkArray is valid.
    It throws out all entries, that are not MediaItemStateChunks and returns the altered array as result.
    
    returns false in case of error or if it is not a valid MediaItemStateChunkArray
  </description>
  <parameters>
    array MediaItemStateChunkArray - a MediaItemStateChunkArray that shall be checked for validity
  </parameters>
  <retvals>
    boolean retval - returns true if MediaItemStateChunkArray is valid, false if not
    integer count - the number of entries in the returned retMediaItemStateChunkArray
    array retMediaItemStateChunkArray - the, possibly, altered MediaItemStateChunkArray
  </retvals>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, chunk, check</tags>
</US_DocBloc>
]]
--checks, if MediaItemStateChunkArray is a valid array.
-- throws out all invalid table-entries
  if type(MediaItemStateChunkArray)~="table" then ultraschall.AddErrorMessage("CheckMediaItemStateChunkArray", "MediaItemStateChunkArray", "Only array with MediaItemStateChunks as entries allowed.", -1) return false end
  local count=1
  while MediaItemStateChunkArray[count]~=nil do
    if type(MediaItemStateChunkArray[count])~="string" or MediaItemStateChunkArray[count]:match("<ITEM.*>")==nil then table.remove(MediaItemStateChunkArray,count)
    else
      count=count+1
    end
  end
  if count==1 then return false
  else return true, count-1, MediaItemStateChunkArray
  end
end

function ultraschall.IsValidMediaItemStateChunkArray(MediaItemStateChunkArray)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsValidMediaItemStateChunkArray</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, integer count, array retMediaItemStateChunkArray = ultraschall.IsValidMediaItemStateChunkArray(array MediaItemStateChunkArray)</functioncall>
  <description>
    Checks, whether MediaItemStateChunkArray is valid.
    It throws out all entries, that are not MediaItemStateChunks and returns the altered array as result.
    
    returns false in case of error or if it is not a valid MediaItemStateChunkArray
  </description>
  <parameters>
    array MediaItemStateChunkArray - a MediaItemStateChunkArray that shall be checked for validity
  </parameters>
  <retvals>
    boolean retval - returns true if MediaItemStateChunkArray is valid, false if not
    integer count - the number of entries in the returned retMediaItemStateChunkArray
    array retMediaItemStateChunkArray - the, possibly, altered MediaItemStateChunkArray
  </retvals>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, chunk, check</tags>
</US_DocBloc>
]]
  local retval, errcode, functionname, parmname, errormessage, lastreadtime, err_creation_date, err_creation_timestamp, errorcounter0 = ultraschall.GetLastErrorMessage()
  local retval, count, retMediaItemStateChunkArray = ultraschall.CheckMediaItemStateChunkArray(MediaItemStateChunkArray)
  local retval, errcode, functionname, parmname, errormessage, lastreadtime, err_creation_date, err_creation_timestamp, errorcounter = ultraschall.GetLastErrorMessage() 
  if errorcounter0~=errorcounter and functionname=="CheckMediaItemStateChunkArray" then ultraschall.AddErrorMessage("IsValidMediaItemStateChunkArray",parmname, errormessage, errcode) return false end
  return retval, count, retMediaItemStateChunkArray
end


function ultraschall.GetMediaItemsAtPosition(position, trackstring)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetMediaItemsAtPosition</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer number_of_items, array MediaItemArray, array MediaItemStateChunkArray = ultraschall.GetMediaItemsAtPosition(number position, string trackstring)</functioncall>
  <description>
    Gets all Mediaitems at position, from the tracks given by trackstring.
    Returns a MediaItemArray with the found MediaItems; returns -1 in case of error
  </description>
  <parameters>
    number position - position in seconds
    string trackstring - the tracknumbers, separated by a comma
  </parameters>
  <retvals>
    integer number_of_items - the number of items at position
    array MediaItemArray - an array, that contains all MediaItems at position from the tracks given by trackstring.
    array MediaItemStateChunkArray - an array, that contains all Mediaitem's MediaItemStatechunks at position from the tracks given by trackstring.
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItems
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, selection, statechunk</tags>
</US_DocBloc>
]]

  if type(position)~="number" then ultraschall.AddErrorMessage("GetMediaItemsAtPosition","position", "must be a number", -1) return -1 end
  if ultraschall.IsValidTrackString(trackstring)==false then ultraschall.AddErrorMessage("GetMediaItemsAtPosition","trackstring", "must be a valid trackstring", -2) return -1 end
  local L,trackstring,AA,AAA=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  
  local MediaItemArray={}
  local MediaItemStateChunkArray={}
  local count=0
  local Numbers, LineArray=ultraschall.CSV2IndividualLinesAsArray(trackstring)
  local Anumber=reaper.CountMediaItems(0)
  local temp
  for i=0,Anumber-1 do
    local MediaItem=reaper.GetMediaItem(0, i)
    local Astart=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
    local Alength=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")
    local MediaTrack=reaper.GetMediaItem_Track(MediaItem)
    local MediaTrackNumber=reaper.GetMediaTrackInfo_Value(MediaTrack, "IP_TRACKNUMBER")
    local Aend=Astart+Alength
    if position>=Astart and position<=Aend then
       for a=1, Numbers do
--       reaper.MB(MediaTrackNumber,LineArray[a],0)
        if tonumber(LineArray[a])==nil then ultraschall.AddErrorMessage("GetMediaItemsAtPosition","trackstring", "must be a valid trackstring", -2) return -1 end
        if MediaTrackNumber==tonumber(LineArray[a]) then
          count=count+1 
          MediaItemArray[count]=MediaItem
          temp, MediaItemStateChunkArray[count]=reaper.GetItemStateChunk(MediaItemArray[count], "", true)
--          reaper.MB(MediaTrackNumber,LineArray[a],0)
        end
       end
    end
  end
  return count, MediaItemArray, MediaItemStateChunkArray
end


function ultraschall.OnlyMediaItemsOfTracksInTrackstring(MediaItemArray, trackstring)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>OnlyMediaItemsOfTracksInTrackstring</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval, array MediaItemArray = ultraschall.OnlyMediaItemsOfTracksInTrackstring(array MediaItemArray, string trackstring)</functioncall>
  <description>
    Throws all MediaItems out of the MediaItemArray, that are not within the tracks, as given with trackstring.
    Returns the "cleared" MediaItemArray; returns -1 in case of error
  </description>
  <parameters>
    array MediaItemArray - an array with MediaItems; no nil-entries allowed, will be seen as the end of the array
    string trackstring - the tracknumbers, separated by a comma
  </parameters>
  <retvals>
    integer retval - -1 in case of error, 1 in case of success
    array MediaItemArray - the "cleared" array, that contains only Items in tracks, as given by trackstring, -1 in case of error
  </retvals>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, selection</tags>
</US_DocBloc>
]]
  if ultraschall.CheckMediaItemArray(MediaItemArray)==false then ultraschall.AddErrorMessage("OnlyMediaItemsOfTracksInTrackstring","MediaItemArray", "must be a MediaItemArray", -1) return -1 end
  if ultraschall.IsValidTrackString(trackstring)==false then ultraschall.AddErrorMessage("OnlyMediaItemsOfTracksInTrackstring","trackstring", "must be a valid trackstring", -2) return -1 end
  local L,trackstring,AA,AAA=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  
  local count=1
  local count2=1
  local i=1
  local _count, trackstring_array = ultraschall.CSV2IndividualLinesAsArray(trackstring)
  local MediaItemArray2={}
  
  while MediaItemArray[count]~=nil do
    if MediaItemArray[count]==nil then break end
    i=1
    while trackstring_array[i]~=nil do
      if tonumber(trackstring_array[i])==nil then ultraschall.AddErrorMessage("OnlyMediaItemsOfTracksInTrackstring","MediaItemArray", "must be a valid MediaItemArray", -1) return -1 end
        if reaper.GetTrack(0,trackstring_array[i]-1)==reaper.GetMediaItem_Track(MediaItemArray[count]) then
          MediaItemArray2[count2]=MediaItemArray[count]
          count2=count2+1
        end
        i=i+1
    end
    count=count+1
  end
  return 1, MediaItemArray2
end


function ultraschall.SplitMediaItems_Position(position, trackstring, crossfade)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SplitMediaItems_Position</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, array MediaItemArray = ultraschall.SplitMediaItems_Position(number position, string trackstring, boolean crossfade)</functioncall>
  <description>
    Splits items at position, in the tracks given by trackstring.
    If auto-crossfade is set in the Reaper-preferences, crossfade turns it on(true) or off(false).
    
    Returns false, in case of error.
  </description>
  <parameters>
    number position - the position in seconds
    string trackstring - the numbers for the tracks, where split shall be applied to; numbers separated by a comma
    boolean crossfade - true or nil, automatic crossfade(if enabled) will be applied; false, automatic crossfade is off
  </parameters>
  <retvals>
    boolean retval - true - success, false - error
    array MediaItemArray - an array with the items on the right side of the split
  </retvals>
  <chapter_context>
    MediaItem Management
    Edit
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, split, edit, crossfade</tags>
</US_DocBloc>
]]
  if type(position)~="number" then ultraschall.AddErrorMessage("SplitMediaItems_Position","position", "must be a number", -1) return -1 end
  if ultraschall.IsValidTrackString(trackstring)==false then ultraschall.AddErrorMessage("SplitMediaItems_Position","trackstring", "must be valid trackstring", -2) return -1 end

  local A,trackstring,AA,AAA=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if trackstring==-1 or trackstring=="" then ultraschall.AddErrorMessage("SplitMediaItems_Position","trackstring", "must be valid trackstring", -2) return -1 end

  local FadeOut, MediaItem, oldfade, oldlength
  local ReturnMediaItemArray={}
  local count=0
  local Numbers, LineArray=ultraschall.CSV2IndividualLinesAsArray(trackstring)
  local Anumber=reaper.CountMediaItems(0)

  if crossfade~=nil and type(crossfade)~="boolean" then ultraschall.AddErrorMessage("SplitMediaItems_Position","crossfade", "must be boolean", -3) return false end
  for i=Anumber-1,0,-1 do
    MediaItem=reaper.GetMediaItem(0, i)
    local Astart=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
    local Alength=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")
    FadeOut=reaper.GetMediaItemInfo_Value(MediaItem, "D_FADEOUTLEN")
    local MediaTrack=reaper.GetMediaItem_Track(MediaItem)
    local MediaTrackNumber=reaper.GetMediaTrackInfo_Value(MediaTrack, "IP_TRACKNUMBER")
    local Aend=(Astart+Alength)
    if position>=Astart and position<=Aend then
       for a=1, Numbers do
        if tonumber(LineArray[a])==nil then ultraschall.AddErrorMessage("SplitMediaItems_Position","trackstring", "must be valid trackstring", -2) return false end
        if MediaTrackNumber==tonumber(LineArray[a]) then
          count=count+1 
          ReturnMediaItemArray[count]=reaper.SplitMediaItem(MediaItem, position)
          if crossfade==false then 
              oldfade=reaper.GetMediaItemInfo_Value(MediaItem, "D_FADEOUTLEN_AUTO")
            oldlength=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")
            reaper.SetMediaItemInfo_Value(MediaItem, "D_LENGTH", oldlength-oldfade)
          end
        end
       end
    end
  end
  return true, ReturnMediaItemArray
end

function ultraschall.SplitItemsAtPositionFromArray(position, MediaItemArray, crossfade)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SplitItemsAtPositionFromArray</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, array MediaItemArray = ultraschall.SplitItemsAtPositionFromArray(number position, array MediaItemArray, boolean crossfade)</functioncall>
  <description>
    Splits items in MediaItemArray at position, in the tracks given by trackstring.
    If auto-crossfade is set in the Reaper-preferences, crossfade turns it on(true) or off(false).
    
    Returns false, in case of error.
  </description>
  <parameters>
    number position - the position in seconds
    array MediaItemArray - an array with the items, where split shall be applied to. No nil-entries allowed!
    boolean crossfade - true - automatic crossfade(if enabled) will be applied; false - automatic crossfade is off
  </parameters>
  <retvals>
    boolean retval - true - success, false - error
    array MediaItemArray - an array with the items on the right side of the split
  </retvals>
  <chapter_context>
    MediaItem Management
    Edit
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, split, edit, crossfade, mediaitemarray</tags>
</US_DocBloc>
]]
  if type(position)~="number" then ultraschall.AddErrorMessage("SplitItemsAtPositionFromArray", "position", "Must be a number", -1) return false end
  if ultraschall.IsValidMediaItemArray(MediaItemArray)==false then ultraschall.AddErrorMessage("SplitItemsAtPositionFromArray", "MediaItemArray", "Must be a valid MediaItemArray", -2) return false end
  if type(crossfade)~="boolean" then ultraschall.AddErrorMessage("SplitItemsAtPositionFromArray", "crossfade", "Must be a boolean", -3) return false end

  local ReturnMediaItemArray={}
  local count=1
  while MediaItemArray[count]~=nil do
    ReturnMediaItemArray[count]=reaper.SplitMediaItem(MediaItemArray[count], position)
    if crossfade==false then 
      oldfade=reaper.GetMediaItemInfo_Value(MediaItemArray[count], "D_FADEOUTLEN_AUTO")
      oldlength=reaper.GetMediaItemInfo_Value(MediaItemArray[count], "D_LENGTH")
      reaper.SetMediaItemInfo_Value(MediaItemArray[count], "D_LENGTH", oldlength-oldfade)
    end
    count=count+1
  end
  return true, ReturnMediaItemArray
end



function ultraschall.DeleteMediaItem(MediaItemObject)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DeleteMediaItem</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string MediaItemStateChunk = ultraschall.DeleteMediaItem(MediaItem MediaItem)</functioncall>
  <description>
    deletes a MediaItem. Returns true, in case of success, false in case of error.
    
    returns the MediaItemStateChunk of the deleted MediaItem as well, so you can do additional processing with a deleted item.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem to be deleted
  </parameters>
  <retvals>
    boolean retval - true, delete was successful; false was unsuccessful
    string MediaItemStateChunk - the StateChunk of the deleted MediaItem
                               - the statechunk contains an additional entry "ULTRASCHALL_TRACKNUMBER" which holds the tracknumber, in which the deleted MediaItem was located
  </retvals>
  <chapter_context>
    MediaItem Management
    Delete
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, delete</tags>
</US_DocBloc>
]]
    if reaper.ValidatePtr2(0, MediaItemObject, "MediaItem*")==false then ultraschall.AddErrorMessage("DeleteMediaItem","MediaItem", "must be a MediaItem", -1) return false end
    local MediaTrack=reaper.GetMediaItemTrack(MediaItemObject)
    local _temp, StateChunk=reaper.GetItemStateChunk(MediaItemObject, "", false)
    StateChunk = ultraschall.SetItemUSTrackNumber_StateChunk(StateChunk, math.floor(reaper.GetMediaTrackInfo_Value(MediaTrack, "IP_TRACKNUMBER")))
    return reaper.DeleteTrackMediaItem(MediaTrack, MediaItemObject), StateChunk
end


function ultraschall.DeleteMediaItemsFromArray(MediaItemArray)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DeleteMediaItemsFromArray</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>boolean retval, array MediaItemArray = ultraschall.DeleteMediaItemsFromArray(array MediaItemArray)</functioncall>
  <description>
    deletes the MediaItems from MediaItemArray. Returns true, in case of success, false in case of error.
    In addition, it returns a MediaItemStateChunkArray, that contains the statechunks of all deleted MediaItems
  </description>
  <parameters>
    array MediaItemArray - a array with MediaItem-objects to delete; no nil entries allowed
  </parameters>
  <retvals>
    boolean retval - true, delete was successful; false was unsuccessful
    array MediaItemStateChunkArray - and array with all statechunks of all deleted MediaItems; 
                                   - each statechunk contains an additional entry "ULTRASCHALL_TRACKNUMBER" which holds the tracknumber, in which the deleted MediaItem was located
  </retvals>
  <chapter_context>
    MediaItem Management
    Delete
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, delete</tags>
</US_DocBloc>
]]  
  if ultraschall.IsValidMediaItemArray(MediaItemArray)==false then ultraschall.AddErrorMessage("DeleteMediaItemsFromArray", "MediaItemArray", "must be a valid MediaItemArray", -1) return false end
  local count=1
  local MediaItemStateChunkArray={}
  local hula
  while MediaItemArray[count]~=nil do
    hula, MediaItemStateChunkArray[count]=ultraschall.DeleteMediaItem(MediaItemArray[count])
    count=count+1
  end
  return true, MediaItemStateChunkArray
end


function ultraschall.DeleteMediaItems_Position(position, trackstring)

--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DeleteMediaItems_Position</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>boolean retval, array MediaItemStateChunkArray = ultraschall.DeleteMediaItems_Position(number position, string trackstring)</functioncall>
  <description>
    Delete the MediaItems at given position, from the tracks as given by trackstring.
    returns, if deleting was successful and an array with all statechunks of all deleted MediaItems
  </description>
  <parameters>
    number position - the position in seconds
    string trackstring - the tracknumbers, separated by a comma
  </parameters>
  <retvals>
    boolean retval - true, delete was successful; false was unsuccessful
    array MediaItemStateChunkArray - and array with all statechunks of all deleted MediaItems; 
                                   - each statechunk contains an additional entry "ULTRASCHALL_TRACKNUMBER" which holds the tracknumber, in which the deleted MediaItem was located
  </retvals>
  <chapter_context>
    MediaItem Management
    Delete
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, delete</tags>
</US_DocBloc>
]]
  if type(position)~="number" then ultraschall.AddErrorMessage("DeleteMediaItems_Position", "position", "must be a number", -1) return false end
  if ultraschall.IsValidTrackString(trackstring)==false then ultraschall.AddErrorMessage("DeleteMediaItems_Position", "trackstring", "must be a valid trackstring", -2) return false end
  
  local count=0
  local L,trackstring,AA,AAA=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if trackstring==-1 or trackstring=="" then ultraschall.AddErrorMessage("DeleteMediaItems_Position", "trackstring", "must be a valid trackstring", -3) return false end
  local Numbers, LineArray=ultraschall.CSV2IndividualLinesAsArray(trackstring)
  local Anumber=reaper.CountMediaItems(0)
  local MediaItemStateChunkArray={}
  local _temp
  
  for i=Anumber-1, 0, -1 do
    local MediaItem=reaper.GetMediaItem(0, i)
    local Astart=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
    local Alength=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")
    local MediaTrack=reaper.GetMediaItem_Track(MediaItem)
    local MediaTrackNumber=reaper.GetMediaTrackInfo_Value(MediaTrack, "IP_TRACKNUMBER")
    local Aend=Astart+Alength
    if position>=Astart and position<=Aend then
       for a=1, Numbers do
        if tonumber(LineArray[a])==nil then return false end
        if MediaTrackNumber==tonumber(LineArray[a]) then
          count=count+1 
          _temp, MediaItemStateChunkArray[a] = ultraschall.DeleteMediaItem(MediaItem)
        end
       end
    end
  end
  return true, MediaItemStateChunkArray
end

function ultraschall.GetAllMediaItemsBetween(startposition, endposition, trackstring, inside)

--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllMediaItemsBetween</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer count, array MediaItemArray, array MediaItemStateChunkArray = ultraschall.GetAllMediaItemsBetween(number startposition, number endposition, string trackstring, boolean inside)</functioncall>
  <description>
    Gets all MediaItems between startposition and endposition from the tracks as given by trackstring. 
    Set inside to true to get only items, that are fully within the start and endposition, set it to false, if you also want items, that are just partially inside(end or just the beginning of the item).
    
    Returns the number of items, an array with all the MediaItems and an array with all the MediaItemStateChunks of the items, as used by functions as <a href="#InsertMediaItem_MediaItemStateChunk">InsertMediaItem_MediaItemStateChunk</a>, reaper.GetItemStateChunk and reaper.SetItemStateChunk.
    The statechunks include a new element "ULTRASCHALL_TRACKNUMBER", which contains the tracknumber of where the item originally was in; important, if you delete the items as you'll otherwise loose this information!
    Returns -1 in case of failure.
  </description>
  <parameters>
    number startposition - startposition in seconds
    number endposition - endposition in seconds
    string trackstring - the tracknumbers, separated by a comma
    boolean inside - true, only items that are completely within selection; false, include items that are partially within selection
  </parameters>
  <retvals>
    integer count - the number of selected items
    array MediaItemArray - an array with all the found MediaItems
    array MediaItemStateChunkArray - an array with the MediaItemStateChunks, that can be used to create new items with <a href="#InsertMediaItem_MediaItemStateChunk">InsertMediaItem_MediaItemStateChunk</a>
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItems
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, selection, position, statechunk, rppxml</tags>
</US_DocBloc>
]]
  if type(startposition)~="number" then ultraschall.AddErrorMessage("GetAllMediaItemsBetween", "startposition", "must be a number", -1) return -1 end
  if type(endposition)~="number" then ultraschall.AddErrorMessage("GetAllMediaItemsBetween", "endposition", "must be a number", -2) return -1 end
  if startposition>endposition then ultraschall.AddErrorMessage("GetAllMediaItemsBetween", "endposition", "must be bigger than startposition", -3) return -1 end
  if ultraschall.IsValidTrackString(trackstring)==false then ultraschall.AddErrorMessage("GetAllMediaItemsBetween", "trackstring", "must be a valid trackstring", -4) return -1 end
  if type(inside)~="boolean" then ultraschall.AddErrorMessage("GetAllMediaItemsBetween", "inside", "must be a boolean", -5) return -1 end
    
  local MediaItemArray={}
  local MediaItemStateChunkArray={}
  local count=0
  local L,trackstring,AA,AAA=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if trackstring==-1 or trackstring==""  then return -1 end
  local Numbers, LineArray=ultraschall.CSV2IndividualLinesAsArray(trackstring)
  local Anumber=reaper.CountMediaItems(0)
  local temp
  for i=0,Anumber-1 do
    local MediaItem=reaper.GetMediaItem(0, i)
    local Astart=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
    local Alength=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")
    local MediaTrack=reaper.GetMediaItem_Track(MediaItem)
    local MediaTrackNumber=reaper.GetMediaTrackInfo_Value(MediaTrack, "IP_TRACKNUMBER")
    local Aend=Astart+Alength
    if inside==true and Astart>=startposition and 
        Astart<=endposition  and
        Aend>=startposition and
        Aend<=endposition then
        for a=1, Numbers do
          if tonumber(LineArray[a])==nil then return -1 end
          if MediaTrackNumber==tonumber(LineArray[a]) then
            count=count+1 
            MediaItemArray[count]=MediaItem
            temp,MediaItemStateChunkArray[count] = reaper.GetItemStateChunk(MediaItem, "", true)
            local tempMediaTrack=reaper.GetMediaItemTrack(MediaItem)
            local Tnumber=reaper.GetMediaTrackInfo_Value(tempMediaTrack, "IP_TRACKNUMBER")
            if MediaItemStateChunkArray[count]~=nil then MediaItemStateChunkArray[count]="<ITEM\nULTRASCHALL_TRACKNUMBER "..math.floor(Tnumber).."\n"..MediaItemStateChunkArray[count]:match("<ITEM(.*)") end
          end
       end
    elseif inside==false then
      if (Astart>=startposition and Astart<=endposition) or
          (Aend>=startposition and Aend<=endposition) or
          (Astart<=startposition and Aend>=endposition) then
        for a=1, Numbers do
          if tonumber(LineArray[a])==nil then return -1 end
          if MediaTrackNumber==tonumber(LineArray[a]) then
            count=count+1 
            MediaItemArray[count]=MediaItem
            temp,MediaItemStateChunkArray[count]= reaper.GetItemStateChunk(MediaItem, "", true)
            local tempMediaTrack=reaper.GetMediaItemTrack(MediaItem)
            local Tnumber=reaper.GetMediaTrackInfo_Value(tempMediaTrack, "IP_TRACKNUMBER")
            MediaItemStateChunkArray[count]="<ITEM\nULTRASCHALL_TRACKNUMBER "..Tnumber..MediaItemStateChunkArray[count]:match("<ITEM(.*)")
          end
       end
      end 
    end
  end
  return count, MediaItemArray, MediaItemStateChunkArray

end


function ultraschall.MoveMediaItemsAfter_By(oldposition, changepositionby, trackstring)

--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>MoveMediaItemsAfter_By</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.MoveMediaItemsAfter_By(number old_position, number change_position_by, string trackstring)</functioncall>
  <description>
    Moves all items after old_position by change_position_by-seconds. Affects only items, that begin after oldposition, so items that start before and end after old_position do not move.
    
    Returns false in case of failure, true in case of success.
  </description>
  <parameters>
    number oldposition - the position, from where the movement shall be applied to, in seconds
    number change_position_by - the change of the position in seconds; positive - toward the end of the project, negative - toward the beginning.
    string trackstring - the tracknumbers, separated by a comma
  </parameters>
  <retvals>
    boolean retval - true in case of success; false in case of failure
  </retvals>
  <chapter_context>
    MediaItem Management
    Manipulate
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, move, position</tags>
</US_DocBloc>
]]
  
  if type(oldposition)~="number" then ultraschall.AddErrorMessage("MoveMediaItemsAfter_By", "old_position", "must be a number", -1) return false end
  if type(changepositionby)~="number" then ultraschall.AddErrorMessage("MoveMediaItemsAfter_By", "changepositionby", "must be a number", -2) return false end
  local L,trackstring,AA,AAA=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if trackstring==-1 or trackstring=="" then ultraschall.AddErrorMessage("MoveMediaItemsAfter_By", "trackstring", "must be a valid trackstring", -3) return false end
  local A,MediaItem=ultraschall.GetAllMediaItemsBetween(oldposition,reaper.GetProjectLength(),trackstring,true)
  for i=1, A do
    local ItemStart=reaper.GetMediaItemInfo_Value(MediaItem[i], "D_POSITION")
    local ItemEnd=reaper.GetMediaItemInfo_Value(MediaItem[i], "D_LENGTH")
    local Takes=reaper.CountTakes(MediaItem[i])
    if ItemStart+changepositionby>=0 then reaper.SetMediaItemInfo_Value(MediaItem[i], "D_POSITION", ItemStart+changepositionby)
    elseif ItemStart+changepositionby<=0 then 
      if ItemEnd+changepositionby<0 then reaper.DeleteTrackMediaItem(reaper.GetMediaItem_Track(MediaItem[i]),MediaItem[i]) --reaper.MB("","",0)
      else 
        for k=0, Takes-1 do
          local Offset=reaper.GetMediaItemTakeInfo_Value(reaper.GetMediaItemTake(MediaItem[i], k), "D_STARTOFFS")
          reaper.SetMediaItemTakeInfo_Value(reaper.GetMediaItemTake(MediaItem[i], k), "D_STARTOFFS", Offset-changepositionby)
        end
        reaper.SetMediaItemInfo_Value(MediaItem[i], "D_LENGTH", ItemEnd+changepositionby)
      end
    end
  end
  return true
end

--A=ultraschall.MoveMediaItemsAfter_By(reaper.GetCursorPosition(),-1,"1")

function ultraschall.MoveMediaItemsBefore_By(oldposition, changepositionby, trackstring)

--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>MoveMediaItemsBefore_By</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.MoveMediaItemsBefore_By(number old_position, number change_position_by, string trackstring)</functioncall>
  <description>
    Moves all items before old_position by change_position_by-seconds. Affects only items, that end before oldposition, so items that start before and end after old_position do not move.
    
    Returns false in case of failure, true in case of success.
  </description>
  <parameters>
    number oldposition - the position, from where the movement shall be applied to, in seconds
    number change_position_by - the change of the position in seconds; positive - toward the end of the project, negative - toward the beginning.
    string trackstring - the tracknumbers, separated by a comma
  </parameters>
  <retvals>
    boolean retval - true in case of success; false in case of failure
  </retvals>
  <chapter_context>
    MediaItem Management
    Manipulate
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, move, position</tags>
</US_DocBloc>
]]
  
  if type(oldposition)~="number" then ultraschall.AddErrorMessage("MoveMediaItemsBefore_By", "old_position", "Must be a number.", -1) return false end
  if type(changepositionby)~="number" then ultraschall.AddErrorMessage("MoveMediaItemsBefore_By", "change_position_by", "Must be a number.", -2) return false end
  if ultraschall.IsValidTrackString(trackstring)==false then ultraschall.AddErrorMessage("MoveMediaItemsBefore_By", "trackstring", "Must be a valid trackstring.", -3) return false end
  
  local L,trackstring,AA,AAA=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if trackstring==-1 or trackstring==""  then ultraschall.AddErrorMessage("MoveMediaItemsBefore_By", "trackstring", "Must be a valid trackstring.", -3) return false end
  local A,MediaItem=ultraschall.GetAllMediaItemsBetween(0,oldposition,trackstring,true)
  for i=1, A do
    local ItemStart=reaper.GetMediaItemInfo_Value(MediaItem[i], "D_POSITION")
    local ItemEnd=reaper.GetMediaItemInfo_Value(MediaItem[i], "D_LENGTH")
    local Takes=reaper.CountTakes(MediaItem[i])
    if ItemStart+changepositionby>=0 then reaper.SetMediaItemInfo_Value(MediaItem[i], "D_POSITION", ItemStart+changepositionby)
    elseif ItemStart+changepositionby<=0 then 
      if ItemEnd+changepositionby<0 then reaper.DeleteTrackMediaItem(reaper.GetMediaItem_Track(MediaItem[i]),MediaItem[i]) --reaper.MB("","",0)
      else 
        for k=0, Takes-1 do
          local Offset=reaper.GetMediaItemTakeInfo_Value(reaper.GetMediaItemTake(MediaItem[i], k), "D_STARTOFFS")
          reaper.SetMediaItemTakeInfo_Value(reaper.GetMediaItemTake(MediaItem[i], k), "D_STARTOFFS", Offset-changepositionby)
        end
        reaper.SetMediaItemInfo_Value(MediaItem[i], "D_LENGTH", ItemEnd+changepositionby)
      end
    end
  end
  return true
end

--A=ultraschall.MoveMediaItemsBefore_By(1,1,"1")

function ultraschall.MoveMediaItemsBetween_To(startposition, endposition, newposition, trackstring, inside)

--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>MoveMediaItemsBetween_To</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.MoveMediaItemsBetween_To(number startposition, number endposition, number newposition, string trackstring, boolean inside)</functioncall>
  <description>
    Moves the items between sectionstart and sectionend to newposition, within the tracks given by trackstring.
    If inside is set to true, only items completely within the section are moved; if set to false, also items are affected, that are just partially within the section.
    
    Items, that start after sectionstart, and therefore have an offset, will be moved to newposition+their offset. Keep that in mind.
    
    Returns false in case of failure, true in case of success.
  </description>
  <parameters>
    number startposition - begin of the item-selection in seconds
    number endposition - end of the item-selection in seconds
    number newposition - new position in seconds
    string trackstring - the tracknumbers, separated by a ,
    boolean inside - true, only items completely within the section; false, also items partially within the section
  </parameters>
  <retvals>
    boolean retval - true in case of success; false in case of failure
  </retvals>
  <chapter_context>
    MediaItem Management
    Manipulate
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, move, position</tags>
</US_DocBloc>
]]
-- sectionstart, sectionend, newposition, trackstring, inside
  
  if type(startposition)~="number" then ultraschall.AddErrorMessage("MoveMediaItemsBetween_To", "sectionstart", "Must be a number.", -1) return false end
  if type(endposition)~="number" then ultraschall.AddErrorMessage("MoveMediaItemsBetween_To", "sectionend", "Must be a number.", -2) return false end
  if type(newposition)~="number" then ultraschall.AddErrorMessage("MoveMediaItemsBetween_To", "newposition", "Must be a number.", -3) return false end
  if sectionend<sectionstart then ultraschall.AddErrorMessage("MoveMediaItemsBetween_To", "sectionend", "Must be bigger than sectionstart.", -4) return false end
  if ultraschall.IsValidTrackString(trackstring) then ultraschall.AddErrorMessage("MoveMediaItemsBetween_To", "trackstring", "Must be a valid trackstring.", -5) return false end
  if type(inside)~="boolean" then ultraschall.AddErrorMessage("MoveMediaItemsBetween_To", "inside", "Must be a boolean.", -6) return false end  

  local L,trackstring,AA,AAA=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if trackstring==-1 or trackstring==""  then return false end
  local A,MediaItem=ultraschall.GetAllMediaItemsBetween(sectionstart,sectionend,trackstring,inside)
  for i=1, A do
    local ItemStart=reaper.GetMediaItemInfo_Value(MediaItem[i], "D_POSITION")
    local ItemEnd=reaper.GetMediaItemInfo_Value(MediaItem[i], "D_LENGTH")
    local Takes=reaper.CountTakes(MediaItem[i])
    if ItemStart+newposition>=0 then reaper.SetMediaItemInfo_Value(MediaItem[i], "D_POSITION", ItemStart+newposition)
    elseif ItemStart+newposition<=0 then 
      if ItemEnd+newposition<0 then reaper.DeleteTrackMediaItem(reaper.GetMediaItem_Track(MediaItem[i]),MediaItem[i]) --reaper.MB("","",0)
      else 
        for k=0, Takes-1 do
          local Offset=reaper.GetMediaItemTakeInfo_Value(reaper.GetMediaItemTake(MediaItem[i], k), "D_STARTOFFS")
          reaper.SetMediaItemTakeInfo_Value(reaper.GetMediaItemTake(MediaItem[i], k), "D_STARTOFFS", Offset-newposition)
        end
        reaper.SetMediaItemInfo_Value(MediaItem[i], "D_LENGTH", ItemEnd+newposition)
      end
    end
  end
  return true
end

--A=ultraschall.MoveMediaItemsBetween_To(1, 3, 100, "Ã¶", false)



function ultraschall.ChangeLengthOfMediaItems_FromArray(MediaItemArray, newlength)

--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ChangeLengthOfMediaItems_FromArray</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ChangeLengthOfMediaItems_FromArray(array MediaItemArray, number newlength)</functioncall>
  <description>
    Changes the length of the MediaItems in MediaItemArray to newlength.
    They will all be set to the new length, regardless of their old length. If you want to change the length of the items not >to< newlength, but >by< newlength, use <a href"#ChangeDeltaLengthOfMediaItems_FromArray">ChangeDeltaLengthOfMediaItems_FromArray</a> instead.
    
    Returns false in case of failure, true in case of success.
  </description>
  <parameters>
    array MediaItemArray - an array with items to be changed. No nil entries allowed!
    number newlength - the new length of the items in seconds
  </parameters>
  <retvals>
    boolean retval - true in case of success; false in case of failure
  </retvals>
  <chapter_context>
    MediaItem Management
    Manipulate
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, length</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidMediaItemArray(MediaItemArray)==false then ultraschall.AddErrorMessage("ChangeLengthOfMediaItems_FromArray", "MediaItemArray", "must be a valid MediaItemArray", -1) return false end
  if type(newlength)~="number" then ultraschall.AddErrorMessage("ChangeLengthOfMediaItems_FromArray", "newlength", "must be a number", -2) return false end
  
  local count=1
  while MediaItemArray[count]~=nil do
    reaper.SetMediaItemInfo_Value(MediaItemArray[count], "D_LENGTH", newlength)
    count=count+1
  end
  return true
end


function ultraschall.ChangeDeltaLengthOfMediaItems_FromArray(MediaItemArray, deltalength)

--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ChangeDeltaLengthOfMediaItems_FromArray</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ChangeDeltaLengthOfMediaItems_FromArray(array MediaItemArray, number deltalength)</functioncall>
  <description>
    Changes the length of the MediaItems in MediaItemArray by deltalength.
    If you want to change the length of the items not >by< deltalength, but >to< deltalength, use <a href"#ChangeLengthOfMediaItems_FromArray">ChangeLengthOfMediaItems_FromArray</a> instead.
    
    Returns false in case of failure, true in case of success.
  </description>
  <parameters>
    array MediaItemArray - an array with items to be changed. No nil entries allowed!
    number deltalength - the change of the length of the items in seconds, positive value - longer, negative value - shorter
  </parameters>
  <retvals>
    boolean retval - true in case of success; false in case of failure
  </retvals>
  <chapter_context>
    MediaItem Management
    Manipulate
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, length</tags>
</US_DocBloc>
]]

  if ultraschall.CheckMediaItemArray(MediaItemArray)==false then ultraschall.AddErrorMessage("ChangeDeltaLengthOfMediaItems_FromArray", "MediaItemArray", "Only array with MediaItemObjects as entries is allowed.", -1) return false end
  if type(deltalength)~="number" then ultraschall.AddErrorMessage("ChangeDeltaLengthOfMediaItems_FromArray", "deltalength", "Must be a number in seconds.", -2) return false end
  local count=1
  local ItemLength
  while MediaItemArray[count]~=nil do
    ItemLength=reaper.GetMediaItemInfo_Value(MediaItemArray[count], "D_LENGTH")
    reaper.SetMediaItemInfo_Value(MediaItemArray[count], "D_LENGTH", ItemLength+deltalength)
    count=count+1
  end    
  return true
end

function ultraschall.ChangeOffsetOfMediaItems_FromArray(MediaItemArray, newoffset)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ChangeOffsetOfMediaItems_FromArray</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ChangeOffsetOfMediaItems_FromArray(array MediaItemArray, number newoffset)</functioncall>
  <description>
    Changes the audio-offset of the MediaItems in MediaItemArray to newoffset.
    It affects all(!) takes that the MediaItems has.
    If you want to change the offset of the items not >to< newoffset, but >by< newoffset, use <a href"#ChangeDeltaOffsetOfMediaItems_FromArray">ChangeDeltaOffsetOfMediaItems_FromArray</a> instead.
    
    Returns false in case of failure, true in case of success.
  </description>
  <parameters>
    array MediaItemArray - an array with items to be changed. No nil entries allowed!
    number newoffset - the new offset of the items in seconds
  </parameters>
  <retvals>
    boolean retval - true, in case of success; false, in case of failure
  </retvals>
  <chapter_context>
    MediaItem Management
    Manipulate
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, offset</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidMediaItemArray(MediaItemArray)==false then ultraschall.AddErrorMessage("ChangeOffsetOfMediaItems_FromArray", "MediaItemArray", "must be a valid MediaItemArray", -1) return false end
  if type(newoffset)~="number" then ultraschall.AddErrorMessage("ChangeOffsetOfMediaItems_FromArray", "newoffset", "must be a number", -2) return false end
  
  local count=1
  local ItemLength
  local MediaItem_Take
  while MediaItemArray[count]~=nil do
    ItemLength=reaper.GetMediaItemInfo_Value(MediaItemArray[count], "D_SNAPOFFSET")
    for i=0, reaper.CountTakes(MediaItemArray[count])-1 do
      MediaItem_Take=reaper.GetMediaItemTake(MediaItemArray[count], i)
      reaper.SetMediaItemTakeInfo_Value(MediaItem_Take, "D_STARTOFFS", newoffset)
    end
    count=count+1
  end    
  return true
end

function ultraschall.ChangeDeltaOffsetOfMediaItems_FromArray(MediaItemArray, deltaoffset)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ChangeDeltaOffsetOfMediaItems_FromArray</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ChangeDeltaOffsetOfMediaItems_FromArray(array MediaItemArray, number deltaoffset)</functioncall>
  <description>
    Changes the audio-offset of the MediaItems in MediaItemArray by deltaoffset.
    It affects all(!) takes of the MediaItems have.
    If you want to change the offset of the items not >by< deltaoffset, but >to< deltaoffset, use <a href"#ChangeOffsetOfMediaItems_FromArray">ChangeOffsetOfMediaItems_FromArray</a> instead.
    
    Returns false in case of failure, true in case of success.
  </description>
  <parameters>
    array MediaItemArray - an array with items to be changed. No nil entries allowed!
    number newoffset - the new offset of the items in seconds
  </parameters>
  <retvals>
    boolean retval - true in case of success; false in case of failure
  </retvals>
  <chapter_context>
    MediaItem Management
    Manipulate
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, offset</tags>
</US_DocBloc>
]]

  if ultraschall.IsValidMediaItemArray(MediaItemArray)==false then ultraschall.AddErrorMessage("ChangeDeltaOffsetOfMediaItems_FromArray", "MediaItemArray", "must be a valid MediaItemArray", -1) return false end
  if type(delta)~="number" then ultraschall.AddErrorMessage("ChangeDeltaOffsetOfMediaItems_FromArray", "delta", "must be a number", -2) return false end
  
  local count=1
  local ItemLength, MediaItem_Take, ItemTakeOffset
  while MediaItemArray[count]~=nil do
    ItemLength=reaper.GetMediaItemInfo_Value(MediaItemArray[count], "D_SNAPOFFSET")
    for i=0, reaper.CountTakes(MediaItemArray[count])-1 do
      MediaItem_Take=reaper.GetMediaItemTake(MediaItem[count], i)
      ItemTakeOffset=reaper.GetMediaItemTakeInfo_Value(MediaItem_Take, "D_STARTOFFS")
      reaper.SetMediaItemTakeInfo_Value(MediaItem_Take, "D_STARTOFFS", ItemTakeOffset+deltaoffset)
    end
    count=count+1
  end
  return true    
end


function ultraschall.SectionCut(startposition, endposition, trackstring, add_to_clipboard)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SectionCut</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer number_items, array MediaItemArray_StateChunk = ultraschall.SectionCut(number startposition, number endposition, string trackstring, boolean add_to_clipboard)</functioncall>
  <description>
    Cuts out all items between startposition and endposition in the tracks given by trackstring.
    
    Returns number of cut items as well as an array with the mediaitem-statechunks, which can be used with functions as <a href="#InsertMediaItem_MediaItemStateChunk">InsertMediaItem_MediaItemStateChunk</a>, reaper.GetItemStateChunk and reaper.SetItemStateChunk.
    Returns -1 in case of failure.
  </description>
  <parameters>
    number startposition - the startposition of the section in seconds
    number endposition - the endposition of the section in seconds
    string trackstring - the tracknumbers, separated by ,
    boolean add_to_clipboard - true, puts the cut items into the clipboard; false, don't put into the clipboard
  </parameters>
  <retvals>
    integer number_items - the number of cut items
    array MediaItemArray_StateChunk - an array with the mediaitem-states of the cut items.
  </retvals>
  <chapter_context>
    MediaItem Management
    Edit
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, edit, section, cut, clipboard</tags>
</US_DocBloc>
]]
  -- check parameters
  if type(startposition)~="number" then ultraschall.AddErrorMessage("SectionCut", "startposition", "must be a number", -1) return -1 end
  if type(endposition)~="number" then ultraschall.AddErrorMessage("SectionCut", "endposition", "must be a number", -2) return -1 end
  if endposition<startposition then ultraschall.AddErrorMessage("SectionCut", "endposition", "must be bigger than startposition", -3)  return -1 end
  if ultraschall.IsValidTrackString(trackstring)==false then ultraschall.AddErrorMessage("SectionCut", "trackstring", "must be a valid trackstring", -4)  return -1 end
  if type(add_to_clipboard)~="boolean" then ultraschall.AddErrorMessage("SectionCut", "add_to_clipboard", "must be a boolean", -5) return -1 end  

  -- manage duplicates in trackstring
  local L,trackstring,AA,AAA=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)

  -- do the splitting, selecting and deleting of the items inbetween start and endposition
  local A,AA=ultraschall.SplitMediaItems_Position(startposition,trackstring, false)
  local B,BB=ultraschall.SplitMediaItems_Position(endposition,trackstring,false)
  local C,CC,CCC=ultraschall.GetAllMediaItemsBetween(startposition,endposition,trackstring,true)

  -- put the items into the clipboard  
  if add_to_clipboard==true then ultraschall.PutMediaItemsToClipboard_MediaItemArray(CC) end

  local D=ultraschall.DeleteMediaItemsFromArray(CC)
  return C, CCC
end

--H=reaper.GetCursorPosition()
--reaper.UpdateArrange()

function ultraschall.SectionCut_Inverse(startposition, endposition, trackstring, add_to_clipboard)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SectionCut_Inverse</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer number_items_beforestart, array MediaItemArray_StateChunk_beforestart, integer number_items_afterend, array MediaItemArray_StateChunk_afterend = ultraschall.SectionCut_Inverse(number startposition, number endposition, string trackstring, boolean add_to_clipboard)</functioncall>
  <description>
    Cuts out all items before(!) startposition and after(!) endposition in the tracks given by trackstring; it keeps all items inbetween startposition and endposition.
    
    Returns number of cut items as well as an array with the mediaitem-statechunks, which can be used with functions as <a href="#InsertMediaItem_MediaItemStateChunk">InsertMediaItem_MediaItemStateChunk</a>, reaper.GetItemStateChunk and reaper.SetItemStateChunk.
    Returns -1 in case of failure.
  </description>
  <parameters>
    number startposition - the startposition of the section in seconds
    number endposition - the endposition of the section in seconds
    string trackstring - the tracknumbers, separated by ,
    boolean add_to_clipboard - true, puts the cut items into the clipboard; false, don't put into the clipboard
  </parameters>
  <retvals>
    integer number_items_beforestart - the number of cut items before startposition
    array MediaItemArray_StateChunk_beforestart - an array with the mediaitem-states of the cut items before startposition
    integer number_items_afterend - the number of cut items after endposition
    array MediaItemArray_StateChunk_afterend - an array with the mediaitem-states of the cut items after endposition
  </retvals>
  <chapter_context>
    MediaItem Management
    Edit
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, edit, section, inverse, cut</tags>
</US_DocBloc>
]]
  -- check parameters
  if type(startposition)~="number" then ultraschall.AddErrorMessage("SectionCut_Inverse", "startposition", "must be a number", -1) return -1 end
  if type(endposition)~="number" then ultraschall.AddErrorMessage("SectionCut_Inverse", "endposition", "must be a number", -2) return -1 end
  if endposition<startposition then ultraschall.AddErrorMessage("SectionCut_Inverse", "endposition", "must be bigger than startposition", -3)  return -1 end
  if ultraschall.IsValidTrackString(trackstring)==false then ultraschall.AddErrorMessage("SectionCut_Inverse", "trackstring", "must be a valid trackstring", -4)  return -1 end
  if type(add_to_clipboard)~="boolean" then ultraschall.AddErrorMessage("SectionCut_Inverse", "add_to_clipboard", "must be a boolean", -5) return -1 end  
  
  -- remove duplicate tracks from trackstring
  local L,trackstring,AA,AAA=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if trackstring==-1 or trackstring==""  then return -1 end
  
  -- do the splitting, selection of all mediaitems before first and after last split and delete them
  local A,AA=ultraschall.SplitMediaItems_Position(startposition,trackstring, false)
  local B,BB=ultraschall.SplitMediaItems_Position(endposition,trackstring,false) -- Buggy: needs to take care of autocrossfade!!
  local C,CC,CCC=ultraschall.GetAllMediaItemsBetween(0,startposition,trackstring,true)
  local C2,CC2,CCC2=ultraschall.GetAllMediaItemsBetween(endposition,reaper.GetProjectLength(),trackstring,true)
  
  -- put the items into the clipboard  
  
  if add_to_clipboard==true then 
    local COMBIC, COMBIC2=ultraschall.ConcatIntegerIndexedTables(CC, CC2)
    ultraschall.PutMediaItemsToClipboard_MediaItemArray(COMBIC2) 
  end
  
  local D=ultraschall.DeleteMediaItemsFromArray(CC)
  local D2=ultraschall.DeleteMediaItemsFromArray(CC2)
  
  -- return removed items
  return C,CCC,C2,CCC2
end


function ultraschall.RippleCut(startposition, endposition, trackstring, moveenvelopepoints, add_to_clipboard)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>RippleCut</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer number_items, array MediaItemArray_StateChunk = ultraschall.RippleCut(number startposition, number endposition, string trackstring, boolean moveenvelopepoints, boolean add_to_clipboard)</functioncall>
  <description>
    Cuts out all items between startposition and endposition in the tracks given by trackstring. After cut, it moves the remaining items after(!) endposition toward projectstart, by the difference between start and endposition.
    
    Returns number of cut items as well as an array with the mediaitem-statechunks, which can be used with functions as <a href="#InsertMediaItem_MediaItemStateChunk">InsertMediaItem_MediaItemStateChunk</a>, reaper.GetItemStateChunk and reaper.SetItemStateChunk.
    Returns -1 in case of failure.
  </description>
  <parameters>
    number startposition - the startposition of the section in seconds
    number endposition - the endposition of the section in seconds
    string trackstring - the tracknumbers, separated by ,
    boolean moveenvelopepoints - moves envelopepoints, if existing, as well
    boolean add_to_clipboard - true, puts the cut items into the clipboard; false, don't put into the clipboard
  </parameters>
  <retvals>
    integer number_items - the number of cut items
    array MediaItemArray_StateChunk - an array with the mediaitem-states of the cut items
  </retvals>
  <chapter_context>
    MediaItem Management
    Edit
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, edit, ripple, clipboard</tags>
</US_DocBloc>
]]
  --trackstring=ultraschall.CreateTrackString(1,reaper.CountTracks(),1)
  --returns the number of deleted items as well as a table with the ItemStateChunks of all deleted Items  

  if type(startposition)~="number" then ultraschall.AddErrorMessage("RippleCut", "startposition", "must be a number", -1) return -1 end
  if type(endposition)~="number" then ultraschall.AddErrorMessage("RippleCut", "endposition", "must be a number", -2) return -1 end
  if ultraschall.IsValidTrackString(trackstring)==false then ultraschall.AddErrorMessage("RippleCut", "trackstring", "must be a valid trackstring", -3) return -1 end
  if type(add_to_clipboard)~="boolean" then ultraschall.AddErrorMessage("RippleCut", "add_to_clipboard", "must be a boolean", -4) return -1 end  
  if type(moveenvelopepoints)~="boolean" then ultraschall.AddErrorMessage("RippleCut", "moveenvelopepoints", "must be a boolean", -5) return -1 end

  local L,trackstring,A2,A3=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if trackstring==-1 or trackstring=="" then ultraschall.AddErrorMessage("RippleCut", "trackstring", "must be a valid trackstring", -6) return -1 end
  local delta=endposition-startposition
  local A,AA=ultraschall.SplitMediaItems_Position(startposition,trackstring,false)
  local B,BB=ultraschall.SplitMediaItems_Position(endposition,trackstring,false)
  local C,CC,CCC=ultraschall.GetAllMediaItemsBetween(startposition,endposition,trackstring,true)
    
  -- put the items into the clipboard  
  if add_to_clipboard==true then ultraschall.PutMediaItemsToClipboard_MediaItemArray(CC) end
  
  local D=ultraschall.DeleteMediaItemsFromArray(CC) 
  if moveenvelopepoints==true then
    local CountTracks=reaper.CountTracks()
    for i=0, CountTracks-1 do
      for a=1,A3 do
        if tonumber(A2[a])==i+1 then
          local MediaTrack=reaper.GetTrack(0,i)
          retval = ultraschall.MoveTrackEnvelopePointsBy(endposition, reaper.GetProjectLength(), -delta, MediaTrack, true) 
        end
      end
    end
  end
  
  if movemarkers==true then
    ultraschall.MoveMarkersBy(endposition, reaper.GetProjectLength(), -delta, true)
  end
  ultraschall.MoveMediaItemsAfter_By(endposition, -delta, trackstring)
  return C,CCC
end

--A,B=ultraschall.RippleCut(1,2,"1,2,3",true,true)


function ultraschall.RippleCut_Reverse(startposition, endposition, trackstring, moveenvelopepoints, add_to_clipboard)
  --trackstring=ultraschall.CreateTrackString(1,reaper.CountTracks(),1)
  --returns the number of deleted items as well as a table with the ItemStateChunks of all deleted Items  
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>RippleCut_Reverse</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer number_items, array MediaItemArray_StateChunk = ultraschall.RippleCut_Reverse(number startposition, number endposition, string trackstring, boolean moveenvelopepoints, boolean add_to_clipboard)</functioncall>
  <description>
    Cuts out all items between startposition and endposition in the tracks given by trackstring. After cut, it moves the remaining items before(!) startposition toward projectend, by the difference between start and endposition.
    
    Returns number of cut items as well as an array with the mediaitem-statechunks, which can be used with functions as <a href="#InsertMediaItem_MediaItemStateChunk">InsertMediaItem_MediaItemStateChunk</a>, reaper.GetItemStateChunk and reaper.SetItemStateChunk.
    Returns -1 in case of failure.
  </description>
  <parameters>
    number startposition - the startposition of the section in seconds
    number endposition - the endposition of the section in seconds
    string trackstring - the tracknumbers, separated by ,
    boolean moveenvelopepoints - moves envelopepoints, if existing, as well
    boolean add_to_clipboard - true, puts the cut items into the clipboard; false, don't put into the clipboard
  </parameters>
  <retvals>
    integer number_items - the number of cut items
    array MediaItemArray_StateChunk - an array with the mediaitem-states of the cut items
  </retvals>
  <chapter_context>
    MediaItem Management
    Edit
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, edit, ripple, reverse, clipboard</tags>
</US_DocBloc>
]]

  if type(startposition)~="number" then ultraschall.AddErrorMessage("RippleCut_Reverse", "startposition", "must be a number", -1) return -1 end
  if type(endposition)~="number" then ultraschall.AddErrorMessage("RippleCut_Reverse", "endposition", "must be a number", -2) return -1 end
  if ultraschall.IsValidTrackString(trackstring)==false then ultraschall.AddErrorMessage("RippleCut_Reverse", "trackstring", "must be a valid trackstring", -3) return -1 end
  if type(add_to_clipboard)~="boolean" then ultraschall.AddErrorMessage("RippleCut_Reverse", "add_to_clipboard", "must be a boolean", -4) return -1 end
  if type(moveenvelopepoints)~="boolean" then ultraschall.AddErrorMessage("RippleCut_Reverse", "moveenvelopepoints", "must be a boolean", -5) return -1 end
  
  local L,trackstring,A2,A3=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if trackstring==-1 or trackstring==""  then return -1 end
  local delta=endposition-startposition
  local A,AA=ultraschall.SplitMediaItems_Position(startposition,trackstring,false)
  local B,BB=ultraschall.SplitMediaItems_Position(endposition,trackstring,false)
  local C,CC,CCC=ultraschall.GetAllMediaItemsBetween(startposition,endposition,trackstring,true)

  -- put the items into the clipboard  
  if add_to_clipboard==true then ultraschall.PutMediaItemsToClipboard_MediaItemArray(CC) end

  local D=ultraschall.DeleteMediaItemsFromArray(CC) 
  if moveenvelopepoints==true then
    local CountTracks=reaper.CountTracks()
    for i=0, CountTracks-1 do
      for a=1,A3 do
        if tonumber(A2[a])==i+1 then
          local MediaTrack=reaper.GetTrack(0,i)
          retval = ultraschall.MoveTrackEnvelopePointsBy(0, startposition, delta, MediaTrack, true) 
        end
      end
    end
  end
  
  if movemarkers==true then
    ultraschall.MoveMarkersBy(0, startposition, delta, true)
  end

  ultraschall.MoveMediaItemsBefore_By(endposition, delta, trackstring)  
  return C,CCC
end


--A,AA=ultraschall.RippleCut_Reverse(15,21,"1,2,3", true, true)


function ultraschall.InsertMediaItem_MediaItem(position, MediaItem, MediaTrack)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>InsertMediaItem_MediaItem</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval, MediaItem MediaItem, number startposition, number endposition, number length = ultraschall.InsertMediaItem_MediaItem(number position, MediaItem MediaItem, MediaTrack MediaTrack)</functioncall>
  <description>
    Inserts MediaItem in MediaTrack at position. Returns the newly created(or better: inserted) MediaItem as well as startposition, endposition and length of the inserted item.
    
    Returns -1 in case of failure.
  </description>
  <parameters>
    number position - the position of the newly created mediaitem
    MediaItem MediaItem - the MediaItem that shall be inserted into a track
    MediaTrack MediaTrack - the track, where the item shall be inserted to
  </parameters>
  <retvals>
    integer retval - -1 in case of error, 1 in case of success
    MediaItem MediaItem - the newly created MediaItem
    number startposition - the startposition of the inserted MediaItem in seconds
    number endposition - the endposition of the inserted MediaItem in seconds
    number length - the length of the inserted MediaItem in seconds
  </retvals>
  <chapter_context>
    MediaItem Management
    Insert
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, insert</tags>
</US_DocBloc>
]]
  if type(position)~="number" then ultraschall.AddErrorMessage("InsertMediaItem_MediaItem","position", "must be a number", -1) return -1 end
  if reaper.GetItemStateChunk(MediaItem, "", false)==false then ultraschall.AddErrorMessage("InsertMediaItem_MediaItem","MediaItem", "must be a MediaItem", -2) return -1 end
  if reaper.GetTrackStateChunk(MediaTrack, "", false)==false then ultraschall.AddErrorMessage("InsertMediaItem_MediaItem","MediaTrack", "must be a MediaTrack", -3) return -1 end
  local MediaItemNew=reaper.AddMediaItemToTrack(MediaTrack)
  local Aretval, Astr = reaper.GetItemStateChunk(MediaItem, "", true)
  Astr=Astr:match(".-POSITION ")..position..Astr:match(".-POSITION.-(%c.*)")
  local Aboolean = reaper.SetItemStateChunk(MediaItemNew, Astr, true)
  local start_position=reaper.GetMediaItemInfo_Value(MediaItemNew, "D_POSITION")
  local length=reaper.GetMediaItemInfo_Value(MediaItemNew, "D_LENGTH")
  
  return 1,MediaItemNew, start_position, start_position+length, length
end

--C,CC=ultraschall.GetAllMediaItemsBetween(0,5,"1,2,3,4,5",false)
--MT=reaper.GetTrack(0,0)
--A0,A,AA,AAA,AAAA=ultraschall.InsertMediaItem_MediaItem(42,CC[1],MT)

function ultraschall.InsertMediaItem_MediaItemStateChunk(position, MediaItemStateChunk, MediaTrack)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>InsertMediaItem_MediaItemStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval, MediaItem MediaItem, number startposition, number endposition, number length = ultraschall.InsertMediaItem_MediaItemStateChunk(number position, string MediaItemStateChunk, MediaTrack MediaTrack)</functioncall>
  <description>
    Inserts a new MediaItem in MediaTrack at position. Uses a mediaitem-state-chunk as created by functions like <a href="#GetAllMediaItemsBetween">GetAllMediaItemsBetween</a>, reaper.GetItemStateChunk and reaper.SetItemStateChunk.. Returns the newly created MediaItem.
    
    Returns -1 in case of failure.
  </description>
  <parameters>
    number position - the position of the newly created mediaitem
    string MediaItemStatechunk - the Statechunk for the MediaItem, that shall be inserted into a track
    MediaTrack MediaTrack - the track, where the item shall be inserted to; nil, use the statechunk-entry ULTRASCHALL_TRACKNUMBER for the track instead.
  </parameters>
  <retvals>
    integer retval - -1 in case of error, 1 in case of success
    MediaItem MediaItem - the newly created MediaItem
    number startposition - the startposition of the inserted MediaItem in seconds
    number endposition - the endposition of the inserted MediaItem in seconds
    number length - the length of the inserted MediaItem in seconds
  </retvals>
  <chapter_context>
    MediaItem Management
    Insert
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, insert</tags>
</US_DocBloc>
]]
  if type(position)~="number" then ultraschall.AddErrorMessage("InsertMediaItem_MediaItemStateChunk","position", "must be a number", -1) return -1 end
  if ultraschall.IsValidMediaItemStateChunk(MediaItemStateChunk)==false then ultraschall.AddErrorMessage("InsertMediaItem_MediaItemStateChunk","MediaItemStateChunk", "must be a valid MediaItemStateChunk", -2) return -1 end
  if MediaTrack~=nil and reaper.GetTrackStateChunk(MediaTrack, "", false)==false then ultraschall.AddErrorMessage("InsertMediaItem_MediaItem","MediaTrack", "must be a MediaTrack", -3) return -1 end
  if MediaTrack==nil and ultraschall.GetItemUSTrackNumber_StateChunk(MediaItemStateChunk)==-1 then ultraschall.AddErrorMessage("InsertMediaItem_MediaItemStateChunk","MediaItemStateChunk", "contains no ULTRASCHALL_TRACKNUMBER entry, so I can't determine the original track", -4) return -1 end
  if MediaTrack==nil then MediaTrack=reaper.GetTrack(0,ultraschall.GetItemUSTrackNumber_StateChunk(MediaItemStateChunk)-1) end

  local MediaItemNew=reaper.AddMediaItemToTrack(MediaTrack)
  local MediaItemStateChunk=MediaItemStateChunk:match(".-POSITION ")..position..MediaItemStateChunk:match(".-POSITION.-(%c.*)")
  local Aboolean = reaper.SetItemStateChunk(MediaItemNew, MediaItemStateChunk, true)
  local start_position=reaper.GetMediaItemInfo_Value(MediaItemNew, "D_POSITION")
  local length=reaper.GetMediaItemInfo_Value(MediaItemNew, "D_LENGTH")
    
  return 1, MediaItemNew, start_position, start_position+length, length
end


function ultraschall.InsertMediaItemArray(position, MediaItemArray, trackstring)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>InsertMediaItemArray</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer number_of_items, array MediaItemArray = ultraschall.InsertMediaItemArray(number position, array MediaItemArray, string trackstring)</functioncall>
  <description>
    Inserts the MediaItems from MediaItemArray at position into the tracks, as given by trackstring. 
    
    Returns the number of newly created items, as well as an array with the newly create MediaItems.
    Returns -1 in case of failure.
    
    Note: this inserts the items only in the tracks, where the original items came from. Items from track 1 will be included into track 1. Trackstring only helps to include or exclude the items from inclusion into certain tracks.
    If you have a MediaItemArray with items from track 1,2,3,4,5 and you give trackstring only the tracknumber for track 3 and 4 -> 3,4, then only the items, that were in tracks 3 and 4 originally, will be included, all the others will be ignored.
  </description>
  <parameters>
    number position - the position of the newly created mediaitem
    array MediaItemArray - an array with the MediaItems to be inserted
    string trackstring - the numbers of the tracks, separated by a ,
  </parameters>
  <retvals>
    integer number_of_items - the number of MediaItems created
    array MediaItemArray - an array with the newly created MediaItems
  </retvals>
  <chapter_context>
    MediaItem Management
    Insert
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, insert</tags>
</US_DocBloc>
]]    
  if type(position)~="number" then ultraschall.AddErrorMessage("InsertMediaItemArray","position", "must be a number", -1) return -1 end
  if ultraschall.IsValidMediaItemArray(MediaItemArray)==false then ultraschall.AddErrorMessage("InsertMediaItemArray","MediaItemArray", "must be a valid MediaItemArray", -2) return -1 end
  --if reaper.ValidatePtr(MediaTrack, "MediaTrack*")==false then ultraschall.AddErrorMessage("InsertMediaItemArray","MediaTrack", "must be a valid MediaTrack-object", -3) return -1 end
  if ultraschall.IsValidTrackString(trackstring)==false then ultraschall.AddErrorMessage("InsertMediaItemArray","trackstring", "must be a valid trackstring", -3) return -1 end
  
  local L,trackstring,AA,AAA=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if trackstring==-1 or trackstring==""  then return -1 end
  local count=1
  local i,LL

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
    --nur einfÃ¼gen, wenn mediaitem aus nem Track stammt, der in trackstring vorkommt
    i=1
    while individual_values[i]~=nil do
      if reaper.GetTrack(0,individual_values[i]-1)==reaper.GetMediaItem_Track(MediaItemArray[count]) then 
        LL, NewMediaItemArray[count]=ultraschall.InsertMediaItem_MediaItem(position+(ItemStart_temp-ItemStart),MediaItemArray[count],MediaTrack)
      end
      i=i+1
    end
    count=count+1
  end  

  return count, NewMediaItemArray
end



function ultraschall.GetMediaItemStateChunksFromItems(MediaItemArray)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetMediaItemStateChunksFromItems</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer number_of_items, array MediaItemArray_StateChunks = ultraschall.GetMediaItemStateChunksFromItems(array MediaItemArray)</functioncall>
  <description>
    Returns the MediaItem-StateChunks for all MediaItems in MediaItemArray. It returns the number of items as well as an array, with each entry one MediaItemStateChunk.
    
    StateChunks are used by the reaper-functions reaper.GetItemStateChunk and reaper.SetItemStateChunk.
    
    Returns -1 in case of failure.
  </description>
  <parameters>
    array MediaItemArray - an array with the MediaItems you want the statechunks of
  </parameters>
  <retvals>
    integer number_of_items - the number of trackstatechunks, usually the same as MediaItems in MediaItemArray
    array MediaItemArray_StateChunks - an array with the StateChunks of the MediaItems in MediaItemArray
  </retvals>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, chunk</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidMediaItemArray(MediaItemArray)==false then ultraschall.AddErrorMessage("GetMediaItemStateChunksFromItems", "MediaItemArray", "must be a valid MediaItemArray", -1) return -1 end
  local count=1
  local L
  local MediaItemArray_StateChunk={}
  while MediaItemArray[count]~=nil do
    L, MediaItemArray_StateChunk[count]=reaper.GetItemStateChunk(MediaItemArray[count], "", true)
    count=count+1
  end
  return count-1, MediaItemArray_StateChunk
end


function ultraschall.RippleInsert(position, MediaItemArray, trackstring, moveenvelopepoints)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>RippleInsert</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer number_of_items, array MediaItemArray, number endpos_inserted_items = ultraschall.RippleInsert(number position, array MediaItemArray, string trackstring, boolean moveenvelopepoints, boolean movemarkers)</functioncall>
  <description>
    It inserts the MediaItems from MediaItemArray at position into the tracks, as given by trackstring. It moves the items, that were there before, accordingly toward the end of the project.
    
    Returns the number of newly created items, as well as an array with the newly created MediaItems and the endposition of the last(projectposition) inserted item into the project.
    Returns -1 in case of failure.
    
    Note: this inserts the items only in the tracks, where the original items came from. Items from track 1 will be included into track 1. Trackstring only helps to include or exclude the items from inclusion into certain tracks.
    If you have a MediaItemArray with items from track 1,2,3,4,5 and you give trackstring only the tracknumber for track 3 and 4 -> 3,4, then only the items, that were in tracks 3 and 4 originally, will be included, all the others will be ignored.
  </description>
  <parameters>
    number position - the position of the newly created mediaitem
    array MediaItemArray - an array with the MediaItems to be inserted
    string trackstring - the numbers of the tracks, separated by a ,
    boolean moveenvelopepoints - true, move the envelopepoints as well; false, keep the envelopepoints where they are
    boolean movemarkers - true, move markers as well; false, keep markers where they are
  </parameters>
  <retvals>
    integer number_of_items - the number of newly created items
    array MediaItemArray - an array with the newly created MediaItems
    number endpos_inserted_items - the endposition of the last newly inserted MediaItem
  </retvals>
  <chapter_context>
    MediaItem Management
    Insert
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, insert, ripple</tags>
</US_DocBloc>
]]
  if type(position)~="number" then ultraschall.AddErrorMessage("RippleInsert", "startposition", "must be a number", -1) return -1 end
  if ultraschall.IsValidMediaItemArray(MediaItemArray)==false then ultraschall.AddErrorMessage("RippleInsert", "MediaItemArray", "must be a valid MediaItemArray", -2) return -1 end
  if ultraschall.IsValidTrackString(trackstring)==false then ultraschall.AddErrorMessage("RippleInsert", "trackstring", "must be a valid trackstring", -3) return -1 end
  if type(moveenvelopepoints)~="boolean" then ultraschall.AddErrorMessage("RippleInsert", "moveenvelopepoints", "must be a boolean", -4) return -1 end
  
  local L,trackstring,AA,AAA=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  --reaper.MB(trackstring,"",0)
  if trackstring==-1 or trackstring=="" then ultraschall.AddErrorMessage("RippleInsert", "trackstring", "must be a valid trackstring", -6) return -1 end

-- local NumberOfItems
  local NewMediaItemArray={}
  local count=1
  local ItemStart=reaper.GetProjectLength()+1
  local ItemEnd=0
  local i
  local _count, individual_values = ultraschall.CSV2IndividualLinesAsArray(trackstring)
  while MediaItemArray[count]~=nil do
    local ItemStart_temp=reaper.GetMediaItemInfo_Value(MediaItemArray[count], "D_POSITION")
    local ItemEnd_temp=reaper.GetMediaItemInfo_Value(MediaItemArray[count], "D_LENGTH")
    i=1
    while individual_values[i]~=nil do
      if reaper.GetTrack(0,individual_values[i]-1)==reaper.GetMediaItem_Track(MediaItemArray[count]) then 
        if ItemStart>ItemStart_temp then ItemStart=ItemStart_temp end
        if ItemEnd<ItemEnd_temp+ItemStart_temp then ItemEnd=ItemEnd_temp+ItemStart_temp end
      end
      i=i+1
    end
    count=count+1
  end
  
  --Create copy of the track-state-chunks
  local nums, MediaItemArray_Chunk=ultraschall.GetMediaItemStateChunksFromItems(MediaItemArray)
    
  local A,A2=ultraschall.SplitMediaItems_Position(position,trackstring,false)
--  reaper.MB(tostring(AA),"",0)

  if moveenvelopepoints==true then
    local CountTracks=reaper.CountTracks()
    for i=0, CountTracks-1 do
      for a=1,AAA do
        if tonumber(AA[a])==i+1 then
          local MediaTrack=reaper.GetTrack(0,i)
          retval = ultraschall.MoveTrackEnvelopePointsBy(position, reaper.GetProjectLength()+(ItemEnd-ItemStart), ItemEnd-ItemStart, MediaTrack, true) 
        end
      end
    end
  end
  
  if movemarkers==true then
    ultraschall.MoveMarkersBy(position, reaper.GetProjectLength()+(ItemEnd-ItemStart), ItemEnd-ItemStart, true)
  end
  ultraschall.MoveMediaItemsAfter_By(position-0.000001, ItemEnd-ItemStart, trackstring)
  L,MediaItemArray=ultraschall.OnlyMediaItemsOfTracksInTrackstring(MediaItemArray, trackstring)
  count=1
  while MediaItemArray[count]~=nil do
    local Anumber=reaper.GetMediaItemInfo_Value(MediaItemArray[count], "D_POSITION")
    count=count+1
  end
    NumberOfItems, NewMediaItemArray=ultraschall.InsertMediaItemArray(position, MediaItemArray, trackstring)
  count=1
  while MediaItemArray[count]~=nil do
    local length=MediaItemArray_Chunk[count]:match("LENGTH (.-)%c")
    reaper.SetMediaItemInfo_Value(NewMediaItemArray[count], "D_LENGTH", length)
    count=count+1
  end
  return NumberOfItems, NewMediaItemArray, position+ItemEnd
end



function ultraschall.MoveMediaItems_FromArray(MediaItemArray, newposition)
-- changes position of all MediaItems in MediaItemArray to position
-- if there are more than one mediaitems, it retains the relative-position to each 
-- other, putting the earliest item as position and the rest later, in relation to the earliest item
--
-- MediaItemArray - array with all MediaItems that shall be affected. Must not 
--                    include nil-entries, as they'll be interpreted as end of array.
-- number newposition - new position of Items
--reaper.MB(type(MediaItemArray),"",0)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>MoveMediaItems_FromArray</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval, number earliest_itemtime, number latest_itemtime = ultraschall.MoveMediaItems_FromArray(array MediaItemArray, number newposition)</functioncall>
  <description>
    It changes the position of the MediaItems from MediaItemArray. It keeps the related position to each other, putting the earliest item at newposition, putting the others later, relative to their offset.
    
    Returns -1 in case of failure.
  </description>
  <parameters>
    array MediaItemArray - an array with the MediaItems to be inserted
    number newposition - the new position in seconds
  </parameters>
  <retvals>
    integer retval - -1 in case of error, else returns 1
    number earliest_itemtime - the new earliest starttime of all MediaItems moved
    number latest_itemtime - the new latest endtime of all MediaItems moved
  </retvals>
  <chapter_context>
    MediaItem Management
    Manipulate
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, insert, ripple</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidMediaItemArray(MediaItemArray)==false then ultraschall.AddErrorMessage("MoveMediaItems_FromArray", "MediaItemArray", "must be a valid MediaItemArray", -1) return -1 end
  if type(newposition)~="number" then ultraschall.AddErrorMessage("MoveMediaItems_FromArray", "newposition", "must be a number", -2) return -1 end

  local count=1
  local Earliest_time=reaper.GetProjectLength()+1
  local Latest_time=0
  local ItemStart, ItemEnd
  while MediaItemArray[count]~=nil do
    ItemStart=reaper.GetMediaItemInfo_Value(MediaItemArray[count], "D_POSITION")
    ItemEnd=reaper.GetMediaItemInfo_Value(MediaItemArray[count], "D_LENGTH")+ItemStart
    if ItemStart<Earliest_time then Earliest_time=ItemStart end
    if ItemEnd>Latest_time then Latest_time=ItemEnd end
    count=count+1
  end    

  count=1
  while MediaItemArray[count]~=nil do
    ItemStart=reaper.GetMediaItemInfo_Value(MediaItemArray[count], "D_POSITION")
    reaper.SetMediaItemInfo_Value(MediaItemArray[count], "D_POSITION", (ItemStart-Earliest_time)+newposition)
    count=count+1
  end    
  return 1, Earliest_time, Latest_time
end

function ultraschall.GetItemPosition(MediaItem, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemPosition</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>number position = ultraschall.GetItemPosition(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns position-entry of a MediaItem or MediaItemStateChunk.
    Returns nil in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose position you want to know; nil, use parameter MediaItemStatechunk instead
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    number position - the position in seconds, as set in the statechunk
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, position</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemPosition","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemPosition","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return
  end
  -- get value and return it
  statechunk=statechunk:match("POSITION( .-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
  
  return tonumber(statechunk:match(" (.-) ")), 
         tonumber(statechunk:match(" (.-) (.-) "))
end

--lol, sc=reaper.GetItemStateChunk(reaper.GetMediaItem(0,0),"",false)
--A,B=ultraschall.GetItemPosition(reaper.GetMediaItem(0,0), sc)


function ultraschall.GetItemLength(MediaItem, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemLength</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>number length = ultraschall.GetItemLength(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns length-entry of a MediaItem or MediaItemStateChunk.
    Returns nil in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose length you want to know; nil, use parameter MediaItemStatechunk instead
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    number length - the length in seconds, as set in the statechunk
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, length</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemLength","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemLength","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return
  end
  -- get value and return it
  statechunk=statechunk:match("LENGTH( .-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
  
  return tonumber(statechunk:match(" (.-) ")), 
         tonumber(statechunk:match(" (.-) (.-) "))
end

--A=ultraschall.GetItemLength(reaper.GetMediaItem(0,0))

function ultraschall.GetItemSnapOffset(MediaItem, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemSnapOffset</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>number snapoffset = ultraschall.GetItemSnapOffset(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns snapoffs-entry of a MediaItem or MediaItemStateChunk.
    Returns nil in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose snapoffset you want to know; nil, use parameter MediaItemStatechunk instead
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    number snapoffset - the snapoffset in seconds, as set in the statechunk
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, snap, offset</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemSnapOffset","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemSnapOffset","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return
  end
  -- get value and return it
  statechunk=statechunk:match("SNAPOFFS( .-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
  
  return tonumber(statechunk:match(" (.-) ")), 
         tonumber(statechunk:match(" (.-) (.-) "))
end


--C,CC,CCC=ultraschall.GetAllMediaItemsBetween(1,60,"1,2,3",false)
--A=ultraschall.GetItemSnapOffset(reaper.GetMediaItem(0,0))


function ultraschall.GetItemLoop(MediaItem, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemLoop</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer loopstate = ultraschall.GetItemLoop(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns loopstate-entry of a MediaItem or MediaItemStateChunk.
    Returns nil in case of error.
  </description>
  <parameters>
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    integer loopstate - the loopstate, as set in the statechunk; 1, loop source; 0, don't loop source
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, loop</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemLoop","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemLoop","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return
  end
  -- get value and return it
  statechunk=statechunk:match("LOOP( .-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
  
  return tonumber(statechunk:match(" (.-) ")), 
         tonumber(statechunk:match(" (.-) (.-) "))
end

--C,CC,CCC=ultraschall.GetAllMediaItemsBetween(1,60,"1,2,3",false)
--A=ultraschall.GetItemLoop(reaper.GetMediaItem(0,0))

function ultraschall.GetItemAllTakes(MediaItem, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemAllTakes</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer alltakes = ultraschall.GetItemAllTakes(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns alltakes-entry of a MediaItem or MediaItemStateChunk.
    Returns nil in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose all-takes-playstate you want to know; nil, use parameter MediaItemStatechunk instead
    string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    integer alltakes - Play all takes(1) or don't play all takes(0)
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, alltakes, all, takes</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemAllTakes","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemAllTakes","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return
  end
  -- get value and return it
  statechunk=statechunk:match("ALLTAKES( .-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
  
  return tonumber(statechunk:match(" (.-) ")), 
         tonumber(statechunk:match(" (.-) (.-) "))
end

--A=ultraschall.GetItemAllTakes(reaper.GetMediaItem(0,0))

function ultraschall.GetItemFadeIn(MediaItem, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemFadeIn</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string fadestate1, number fadestate2, number fadestate3, string fadestate4, integer fadestate5, number fadestate6 = ultraschall.GetItemFadeIn(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns fadein-entries of a MediaItem or MediaItemStateChunk.
    Returns nil in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose fadein-state you want to know; nil, use parameter MediaItemStatechunk instead
    string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    string curvetype1 - the type of the curve: 0, 1, 2, 3, 4, 5, 5.1; must be set like curvetype2
    number fadein - fadein in seconds
    number fadestate3 - fadeinstate entry as set in the rppxml-mediaitem-statechunk
    string curvetype2 - the type of the curve: 0, 1, 2, 3, 4, 5, 5.1; must be set like curvetype1
    integer fadestate5 - fadeinstate entry as set in the rppxml-mediaitem-statechunk
    number curve - curve -1 to 1
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, fade in</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemFadeIn","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemFadeIn","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return
  end
  -- get value and return it
  statechunk=statechunk:match("FADEIN( .-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
  
  return tonumber(statechunk:match(" (.-) ")), 
         tonumber(statechunk:match(" .- (.-) ")),
         tonumber(statechunk:match(" .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- .- (.-) "))
end

--C,CC,CCC=ultraschall.GetAllMediaItemsBetween(1,60,"1",false)
--A1,A2,A3,A4,A5,A6=ultraschall.GetItemFadeIn(reaper.GetMediaItem(0,0))

function ultraschall.GetItemFadeOut(MediaItem, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemFadeOut</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string curvetype1, number fadeout_length, number fadeout_length2, string curvetype2, integer fadestate5, number curve = ultraschall.GetItemFadeOut(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns fadeout-entries of a MediaItem or MediaItemStateChunk.
    Returns nil in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose fadeout-state you want to know; nil, use parameter MediaItemStatechunk instead
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    string curvetype1 - the type of the curve: 0, 1, 2, 3, 4, 5, 5.1; must be set like curvetype2
    number fadeout_length - the current fadeout-length in seconds
    number fadeout_length2 - the fadeout-length in seconds; overrides fadeout_length and will be moved to fadeout_length when fadeout-length changes(e.g. mouse-drag); might be autocrossfade-length
    string curvetype2 - the type of the curve: 0, 1, 2, 3, 4, 5, 5.1; must be set like curvetype1
    integer fadestate5 - unknown
    number curve - curvation of the fadeout, -1 to 1
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, fade out</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemFadeOut","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemFadeOut","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return
  end
  -- get value and return it
  statechunk=statechunk:match("FADEOUT( .-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
  
  return tonumber(statechunk:match(" (.-) ")), 
         tonumber(statechunk:match(" .- (.-) ")),
         tonumber(statechunk:match(" .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- .- (.-) "))
end

--A,B,C,D,E,F,G,H,I=ultraschall.GetItemFadeOut(reaper.GetMediaItem(0,0))

function ultraschall.GetItemMute(MediaItem, statechunk)
--  reaper.MB(statechunk,"",0)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemMute</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer mutestate = ultraschall.GetItemMute(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns mutestate-entry of a MediaItem or MediaItemStateChunk.
    Returns nil in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose mute-state you want to know; nil, use parameter MediaItemStatechunk instead
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    integer mutestate - the mute-state; 1, mute is on; 0, mute is off
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, fade out</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemMute","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemMute","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return
  end
  -- get value and return it
  statechunk=statechunk:match("MUTE( .-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
  
  return tonumber(statechunk:match(" (.-) ")), 
         tonumber(statechunk:match(" .- (.-) ")),
         tonumber(statechunk:match(" .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- .- (.-) "))
end

--A=reaper.GetMediaItem(0,0)
--Amutestate = ultraschall.GetItemMute(reaper.GetMediaItem(0,0))

function ultraschall.GetItemFadeFlag(MediaItem, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemFadeFlag</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer autofade_state = ultraschall.GetItemFadeFlag(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns autofade-entry of a MediaItem or MediaItemStateChunk.
    It's the FADEFLAG-entry.
    Returns nil in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose fadeflag-state you want to know; nil, use parameter MediaItemStatechunk instead
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    integer autofade_state - the autofade-state; 1, autofade is off; nil, autofade is on
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, autofade</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemFadeFlag","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemFadeFlag","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return
  end
  -- get value and return it
  statechunk=statechunk:match("FADEFLAG( .-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
  
  return tonumber(statechunk:match(" (.-) ")), 
         tonumber(statechunk:match(" .- (.-) ")),
         tonumber(statechunk:match(" .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- .- (.-) "))
end

--C,CC,CCC=ultraschall.GetAllMediaItemsBetween(1,60,"1,2,3",false)
--AL=ultraschall.GetItemFadeFlag(reaper.GetMediaItem(0,0))

function ultraschall.GetItemLock(MediaItem, statechunk)
--  reaper.MB(statechunk,"",0)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemLock</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer lock_state = ultraschall.GetItemLock(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns itemlock-entry of a MediaItem or MediaItemStateChunk.
    Returns nil in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose itemlock-state you want to know; nil, use parameter MediaItemStatechunk instead
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    integer lock_state - the lock-state; 1, item is locked; nil, item is not locked
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, lock</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemLock","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemLock","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return
  end
  -- get value and return it
  statechunk=statechunk:match("LOCK( .-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
  
  return tonumber(statechunk:match(" (.-) ")), 
         tonumber(statechunk:match(" .- (.-) ")),
         tonumber(statechunk:match(" .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- .- (.-) "))
end

--C,CC,CCC=ultraschall.GetAllMediaItemsBetween(1,60,"1,2,3",false)
--AL=ultraschall.GetItemLock(reaper.GetMediaItem(0,0))

function ultraschall.GetItemSelected(MediaItem, statechunk)
--  reaper.MB(statechunk,"",0)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemSelected</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer selected_state = ultraschall.GetItemSelected(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns item-selected-state-entry of a MediaItem or MediaItemStateChunk.
    It's the SEL-entry.
    Returns nil in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose selection-state you want to know; nil, use parameter MediaItemStatechunk instead
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    integer selected_state - the item-selected-state; 1 - item is selected; 0 - item is not selected
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, selected</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemSelected","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemSelected","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return
  end
  -- get value and return it
  statechunk=statechunk:match("SEL( .-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
  
  return tonumber(statechunk:match(" (.-) ")), 
         tonumber(statechunk:match(" .- (.-) ")),
         tonumber(statechunk:match(" .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- .- (.-) "))
end

--C,CC,CCC=ultraschall.GetAllMediaItemsBetween(1,60,"1,2,3",false)
--AL=ultraschall.GetItemSelected(reaper.GetMediaItem(0,0))

function ultraschall.GetItemGroup(MediaItem, statechunk)
--  reaper.MB(statechunk,"",0)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemGroup</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer item_group = ultraschall.GetItemGroup(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns group of a MediaItem or MediaItemStateChunk, where the item belongs to.
    It's the GROUP-entry
    Returns nil in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose ItemGroup-state you want to know; nil, use parameter MediaItemStatechunk instead
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    integer item_group - the group the item belongs to; nil, if item doesn't belong to any group
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, group</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemGroup","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemGroup","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return
  end
  -- get value and return it
  statechunk=statechunk:match("GROUP( .-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
  
  return tonumber(statechunk:match(" (.-) ")), 
         tonumber(statechunk:match(" .- (.-) ")),
         tonumber(statechunk:match(" .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- .- (.-) "))
end

--A,B,C=ultraschall.GetItemGroup(reaper.GetMediaItem(0,0))


function ultraschall.GetItemIGUID(MediaItem, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemIGUID</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string IGUID = ultraschall.GetItemIGUID(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns the IGUID-entry of a MediaItem or MediaItemStateChunk.
    Returns nil in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose IGUID-state you want to know; nil, use parameter MediaItemStatechunk instead
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    string IGUID - the IGUID of the item
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, guid, iguid</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemIGUID","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemIGUID","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return
  end
  -- get value and return it
  statechunk=statechunk:match("IGUID( .-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
  
  return statechunk:match(" (.-) "), 
         tonumber(statechunk:match(" .- (.-) ")),
         tonumber(statechunk:match(" .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- .- (.-) "))
end

--A=ultraschall.GetItemIGUID(reaper.GetMediaItem(0,0))

function ultraschall.GetItemIID(MediaItem, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemIID</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer IID = ultraschall.GetItemIID(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns the IID-entry of a MediaItem or MediaItemStateChunk.
    Returns nil in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose ItemIID-state you want to know; nil, use parameter MediaItemStatechunk instead
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    integer IID - the IID of the item; the item-id, which is basically a counter of all items created within this project. May change, so use it only as a counter. If you want to identify a specific item, use GUID and IGUID instead.
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, iid</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemIID","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemIID","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return
  end
  -- get value and return it
  statechunk=statechunk:match("IID( .-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
  
  return tonumber(statechunk:match(" (.-) ")), 
         tonumber(statechunk:match(" .- (.-) ")),
         tonumber(statechunk:match(" .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- .- (.-) "))
end

--A=ultraschall.GetItemIID(reaper.GetMediaItem(0,0))

function ultraschall.GetItemName(MediaItem, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemName</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string name = ultraschall.GetItemName(MediaItem MediaItem, string MediaItemStateChunk)</functioncall>
  <description>
    Returns the name-entry of a MediaItem or MediaItemStateChunk.
    Returns nil in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose itemname-state you want to know; nil, use parameter MediaItemStatechunk instead
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    string name - the name of the item
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, name</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemName","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemName","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return
  end
  -- get value and return it
  statechunk=statechunk:match("NAME (.-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
  local name=statechunk:match("\"(.-)\"")
  if name==nil then name=statechunk:match("(.-) ") end
  
  return name
end


--A=ultraschall.GetItemName(reaper.GetMediaItem(0,0))

--MESPOTINE

function ultraschall.GetItemVolPan(MediaItem, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemVolPan</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>number volpan1, number pan, number volume, number volpan4 = ultraschall.GetItemVolPan(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns the vol/pan-entries of a MediaItem or MediaItemStateChunk.
    Returns nil in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose volpan-state you want to know; nil, use parameter MediaItemStatechunk instead
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    number volpan1 - unknown
    number pan - from -1(100%L) to 1(100%R), 0 is center
    number volume - from 0(-inf) to 3.981072(+12db), 1 is 0db; higher numbers are allowed; negative means phase inverted
    number volpan4 - unknown
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, volume, pan</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemVolPan","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemVolPan","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return
  end
  -- get value and return it
  statechunk=statechunk:match("VOLPAN( .-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
    
  return tonumber(statechunk:match(" (.-) ")), 
         tonumber(statechunk:match(" .- (.-) ")),
         tonumber(statechunk:match(" .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- .- (.-) "))
end

--C,CC,CCC=ultraschall.GetAllMediaItemsBetween(1,60,"1,2,3",false)
--A1,A2,A3,A4,A5=ultraschall.GetItemVolPan(reaper.GetMediaItem(0,0))

function ultraschall.GetItemSampleOffset(MediaItem, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemSampleOffset</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>number sampleoffset = ultraschall.GetItemSampleOffset(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns the sampleoffset-entry of a MediaItem or MediaItemStateChunk.
    It's the SOFFS-entry.
    Returns nil in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose sample-offset-state you want to know; nil, use parameter MediaItemStatechunk instead
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    number sampleoffset - sampleoffset in seconds
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, sample, offset</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemSampleOffset","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemSampleOffset","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return
  end
  -- get value and return it
  statechunk=statechunk:match("SOFFS( .-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
    
  return tonumber(statechunk:match(" (.-) ")), 
         tonumber(statechunk:match(" .- (.-) ")),
         tonumber(statechunk:match(" .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- .- (.-) "))
end

--C,CC,CCC=ultraschall.GetAllMediaItemsBetween(1,60,"1,2,3",false)
--A1,A2,A3,A4,A5=ultraschall.GetItemSampleOffset(reaper.GetMediaItem(0,0))

function ultraschall.GetItemPlayRate(MediaItem, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemPlayRate</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.977
    Lua=5.3
  </requires>
  <functioncall>number playbackrate, integer preserve_pitch, number pitch_adjust, integer takepitch_timestretch_mode, integer optimize_tonal_content, number stretch_marker_fadesize = ultraschall.GetItemPlayRate(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns the playback-rate-entries of a MediaItem or MediaItemStateChunk.
    It's the PLAYRATE-entry.
    Returns nil in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose playback-rate-state you want to know; nil, use parameter MediaItemStatechunk instead
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    number playbackrate - 1 is 1x, 2 is 2x, 1.8 is 1.8x,etc
    integer preserve_pitch - preserve pitch, 1 - preserve, 0 - don't preserve
    number pitch_adjust - pitch_adjust(semitones); negative values allowed; 1.1=1.1 semitones higher, -0.3=0.3 semitones lower,etc
    integer takepitch_timestretch_mode - - the item's pitchmode - 65536 for project-default
    -      SoundTouch:
    -          0 - Default settings
    -          1 - High Quality
    -          2 - Fast
    -      
    -      Simple windowed (fast):
    -          131072 - 50ms window, 25ms fade
    -          131073 - 50ms window, 16ms fade
    -          131074 - 50ms window, 10ms fade
    -          131075 - 50ms window, 7ms fade
    -          131076 - 75ms window, 37ms fade
    -          131077 - 75ms window, 25ms fade
    -          131078 - 75ms window, 15ms fade
    -          131079 - 75ms window, 10ms fade
    -          131080 - 100ms window, 50ms fade
    -          131081 - 100ms window, 33ms fade
    -          131082 - 100ms window, 20ms fade
    -          131083 - 100ms window, 14ms fade
    -          131084 - 150ms window, 75ms fade
    -          131085 - 150ms window, 50ms fade
    -          131086 - 150ms window, 30ms fade
    -          131087 - 150ms window, 21ms fade
    -          131088 - 225ms window, 112ms fade
    -          131089 - 225ms window, 75ms fade
    -          131090 - 225ms window, 45ms fade
    -          131091 - 225ms window, 32ms fade
    -          131092 - 300ms window, 150ms fade
    -          131093 - 300ms window, 100ms fade
    -          131094 - 300ms window, 60ms fade
    -          131095 - 300ms window, 42ms fade
    -          131096 - 40ms window, 20ms fade
    -          131097 - 40ms window, 13ms fade
    -          131098 - 40ms window, 8ms fade
    -          131099 - 40ms window, 5ms fade
    -          131100 - 30ms window, 15ms fade
    -          131101 - 30ms window, 10ms fade
    -          131102 - 30ms window, 6ms fade
    -          131103 - 30ms window, 4ms fade
    -          131104 - 20ms window, 10ms fade
    -          131105 - 20ms window, 6ms fade
    -          131106 - 20ms window, 4ms fade
    -          131107 - 20ms window, 2ms fade
    -          131108 - 10ms window, 5ms fade
    -          131109 - 10ms window, 3ms fade
    -          131110 - 10ms window, 2ms fade
    -          131111 - 10ms window, 1ms fade
    -          131112 - 5ms window, 2ms fade
    -          131113 - 5ms window, 1ms fade
    -          131114 - 5ms window, 1ms fade
    -          131115 - 5ms window, 1ms fade
    -          131116 - 3ms window, 1ms fade
    -          131117 - 3ms window, 1ms fade
    -          131118 - 3ms window, 1ms fade
    -          131119 - 3ms window, 1ms fade
    -      
    -      Ã©lastique 2.2.8 Pro:
    -          393216 - Normal
    -          393217 - Preserve Formants (Lowest Pitches)
    -          393218 - Preserve Formants (Lower Pitches)
    -          393219 - Preserve Formants (Low Pitches)
    -          393220 - Preserve Formants (Most Pitches)
    -          393221 - Preserve Formants (High Pitches)
    -          393222 - Preserve Formants (Higher Pitches)
    -          393223 - Preserve Formants (Highest Pitches)
    -          393224 - Mid/Side
    -          393225 - Mid/Side, Preserve Formants (Lowest Pitches)
    -          393226 - Mid/Side, Preserve Formants (Lower Pitches)
    -          393227 - Mid/Side, Preserve Formants (Low Pitches)
    -          393228 - Mid/Side, Preserve Formants (Most Pitches)
    -          393229 - Mid/Side, Preserve Formants (High Pitches)
    -          393230 - Mid/Side, Preserve Formants (Higher Pitches)
    -          393231 - Mid/Side, Preserve Formants (Highest Pitches)
    -          393232 - Synchronized: Normal
    -          393233 - Synchronized: Preserve Formants (Lowest Pitches)
    -          393234 - Synchronized: Preserve Formants (Lower Pitches)
    -          393235 - Synchronized: Preserve Formants (Low Pitches)
    -          393236 - Synchronized: Preserve Formants (Most Pitches)
    -          393237 - Synchronized: Preserve Formants (High Pitches)
    -          393238 - Synchronized: Preserve Formants (Higher Pitches)
    -          393239 - Synchronized: Preserve Formants (Highest Pitches)
    -          393240 - Synchronized:  Mid/Side
    -          393241 - Synchronized:  Mid/Side, Preserve Formants (Lowest Pitches)
    -          393242 - Synchronized:  Mid/Side, Preserve Formants (Lower Pitches)
    -          393243 - Synchronized:  Mid/Side, Preserve Formants (Low Pitches)
    -          393244 - Synchronized:  Mid/Side, Preserve Formants (Most Pitches)
    -          393245 - Synchronized:  Mid/Side, Preserve Formants (High Pitches)
    -          393246 - Synchronized:  Mid/Side, Preserve Formants (Higher Pitches)
    -          393247 - Synchronized:  Mid/Side, Preserve Formants (Highest Pitches)
    -      
    -      Ã©lastique 2.2.8 Efficient:
    -          458752 - Normal
    -          458753 - Mid/Side
    -          458754 - Synchronized: Normal
    -          458755 - Synchronized: Mid/Side
    -      
    -      Ã©lastique 2.2.8 Soloist:
    -          524288 - Monophonic
    -          524289 - Monophonic [Mid/Side]
    -          524290 - Speech
    -          524291 - Speech [Mid/Side]
    -      
    -      Ã©lastique 3.3.0 Pro:
    -          589824 - Normal
    -          589825 - Preserve Formants (Lowest Pitches)
    -          589826 - Preserve Formants (Lower Pitches)
    -          589827 - Preserve Formants (Low Pitches)
    -          589828 - Preserve Formants (Most Pitches)
    -          589829 - Preserve Formants (High Pitches)
    -          589830 - Preserve Formants (Higher Pitches)
    -          589831 - Preserve Formants (Highest Pitches)
    -          589832 - Mid/Side
    -          589833 - Mid/Side, Preserve Formants (Lowest Pitches)
    -          589834 - Mid/Side, Preserve Formants (Lower Pitches)
    -          589835 - Mid/Side, Preserve Formants (Low Pitches)
    -          589836 - Mid/Side, Preserve Formants (Most Pitches)
    -          589837 - Mid/Side, Preserve Formants (High Pitches)
    -          589838 - Mid/Side, Preserve Formants (Higher Pitches)
    -          589839 - Mid/Side, Preserve Formants (Highest Pitches)
    -          589840 - Synchronized: Normal
    -          589841 - Synchronized: Preserve Formants (Lowest Pitches)
    -          589842 - Synchronized: Preserve Formants (Lower Pitches)
    -          589843 - Synchronized: Preserve Formants (Low Pitches)
    -          589844 - Synchronized: Preserve Formants (Most Pitches)
    -          589845 - Synchronized: Preserve Formants (High Pitches)
    -          589846 - Synchronized: Preserve Formants (Higher Pitches)
    -          589847 - Synchronized: Preserve Formants (Highest Pitches)
    -          589848 - Synchronized:  Mid/Side
    -          589849 - Synchronized:  Mid/Side, Preserve Formants (Lowest Pitches)
    -          589850 - Synchronized:  Mid/Side, Preserve Formants (Lower Pitches)
    -          589851 - Synchronized:  Mid/Side, Preserve Formants (Low Pitches)
    -          589852 - Synchronized:  Mid/Side, Preserve Formants (Most Pitches)
    -          589853 - Synchronized:  Mid/Side, Preserve Formants (High Pitches)
    -          589854 - Synchronized:  Mid/Side, Preserve Formants (Higher Pitches)
    -          589855 - Synchronized:  Mid/Side, Preserve Formants (Highest Pitches)
    -      
    -      Ã©lastique 3.3.0 Efficient:
    -          655360 - Normal
    -          655361 - Mid/Side
    -          655362 - Synchronized: Normal
    -          655363 - Synchronized: Mid/Side
    -      
    -      Ã©lastique 3.3.0 Soloist:
    -          720896 - Monophonic
    -          720897 - Monophonic [Mid/Side]
    -          720898 - Speech
    -          720899 - Speech [Mid/Side]
    -      
    -      
    -      Rubber Band Library - Default
    -          851968 - nothing
    -      
    -      Rubber Band Library - Preserve Formants
    -          851969 - Preserve Formants
    -      
    -      Rubber Band Library - Mid/Side
    -          851970 - Mid/Side
    -      
    -      Rubber Band Library - Preserve Formants, Mid/Side
    -          851971 - Preserve Formants, Mid/Side
    -      
    -      Rubber Band Library - Independent Phase
    -          851972 - Independent Phase
    -      
    -      Rubber Band Library - Preserve Formants, Independent Phase
    -          851973 - Preserve Formants, Independent Phase
    -      
    -      Rubber Band Library - Mid/Side, Independent Phase
    -          851974 - Mid/Side, Independent Phase
    -      
    -      Rubber Band Library - Preserve Formants, Mid/Side, Independent Phase
    -          851975 - Preserve Formants, Mid/Side, Independent Phase
    -      
    -      Rubber Band Library - Time Domain Smoothing
    -          851976 - Time Domain Smoothing
    -      
    -      Rubber Band Library - Preserve Formants, Time Domain Smoothing
    -          851977 - Preserve Formants, Time Domain Smoothing
    -      
    -      Rubber Band Library - Mid/Side, Time Domain Smoothing
    -          851978 - Mid/Side, Time Domain Smoothing
    -      
    -      Rubber Band Library - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          851979 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -      
    -      Rubber Band Library - Independent Phase, Time Domain Smoothing
    -          851980 - Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          851981 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Mid/Side, Independent Phase, Time Domain Smoothing
    -          851982 - Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -          851983 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed
    -          851984 - nothing
    -          851985 - Preserve Formants
    -          851986 - Mid/Side
    -          851987 - Preserve Formants, Mid/Side
    -          851988 - Independent Phase
    -          851989 - Preserve Formants, Independent Phase
    -          851990 - Mid/Side, Independent Phase
    -          851991 - Preserve Formants, Mid/Side, Independent Phase
    -          851992 - Time Domain Smoothing
    -          851993 - Preserve Formants, Time Domain Smoothing
    -          851994 - Mid/Side, Time Domain Smoothing
    -          851995 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          851996 - Independent Phase, Time Domain Smoothing
    -          851997 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          851998 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          851999 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth
    -          852000 - nothing
    -          852001 - Preserve Formants
    -          852002 - Mid/Side
    -          852003 - Preserve Formants, Mid/Side
    -          852004 - Independent Phase
    -          852005 - Preserve Formants, Independent Phase
    -          852006 - Mid/Side, Independent Phase
    -          852007 - Preserve Formants, Mid/Side, Independent Phase
    -          852008 - Time Domain Smoothing
    -          852009 - Preserve Formants, Time Domain Smoothing
    -          852010 - Mid/Side, Time Domain Smoothing
    -          852011 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852012 - Independent Phase, Time Domain Smoothing
    -          852013 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852014 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852015 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Detector: Percussive
    -          852016 - nothing
    -          852017 - Preserve Formants
    -          852018 - Mid/Side
    -          852019 - Preserve Formants, Mid/Side
    -          852020 - Independent Phase
    -          852021 - Preserve Formants, Independent Phase
    -          852022 - Mid/Side, Independent Phase
    -          852023 - Preserve Formants, Mid/Side, Independent Phase
    -          852024 - Time Domain Smoothing
    -          852025 - Preserve Formants, Time Domain Smoothing
    -          852026 - Mid/Side, Time Domain Smoothing
    -          852027 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852028 - Independent Phase, Time Domain Smoothing
    -          852029 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852030 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852031 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Detector: Percussive
    -          852032 - nothing
    -          852033 - Preserve Formants
    -          852034 - Mid/Side
    -          852035 - Preserve Formants, Mid/Side
    -          852036 - Independent Phase
    -          852037 - Preserve Formants, Independent Phase
    -          852038 - Mid/Side, Independent Phase
    -          852039 - Preserve Formants, Mid/Side, Independent Phase
    -          852040 - Time Domain Smoothing
    -          852041 - Preserve Formants, Time Domain Smoothing
    -          852042 - Mid/Side, Time Domain Smoothing
    -          852043 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852044 - Independent Phase, Time Domain Smoothing
    -          852045 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852046 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852047 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Detector: Percussive
    -          852048 - nothing
    -          852049 - Preserve Formants
    -          852050 - Mid/Side
    -          852051 - Preserve Formants, Mid/Side
    -          852052 - Independent Phase
    -          852053 - Preserve Formants, Independent Phase
    -          852054 - Mid/Side, Independent Phase
    -          852055 - Preserve Formants, Mid/Side, Independent Phase
    -          852056 - Time Domain Smoothing
    -          852057 - Preserve Formants, Time Domain Smoothing
    -          852058 - Mid/Side, Time Domain Smoothing
    -          852059 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852060 - Independent Phase, Time Domain Smoothing
    -          852061 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852062 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852063 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Detector: Soft
    -          852064 - nothing
    -          852065 - Preserve Formants
    -          852066 - Mid/Side
    -          852067 - Preserve Formants, Mid/Side
    -          852068 - Independent Phase
    -          852069 - Preserve Formants, Independent Phase
    -          852070 - Mid/Side, Independent Phase
    -          852071 - Preserve Formants, Mid/Side, Independent Phase
    -          852072 - Time Domain Smoothing
    -          852073 - Preserve Formants, Time Domain Smoothing
    -          852074 - Mid/Side, Time Domain Smoothing
    -          852075 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852076 - Independent Phase, Time Domain Smoothing
    -          852077 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852078 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852079 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Detector: Soft
    -          852080 - nothing
    -          852081 - Preserve Formants
    -          852082 - Mid/Side
    -          852083 - Preserve Formants, Mid/Side
    -          852084 - Independent Phase
    -          852085 - Preserve Formants, Independent Phase
    -          852086 - Mid/Side, Independent Phase
    -          852087 - Preserve Formants, Mid/Side, Independent Phase
    -          852088 - Time Domain Smoothing
    -          852089 - Preserve Formants, Time Domain Smoothing
    -          852090 - Mid/Side, Time Domain Smoothing
    -          852091 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852092 - Independent Phase, Time Domain Smoothing
    -          852093 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852094 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852095 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Detector: Soft
    -          852096 - nothing
    -          852097 - Preserve Formants
    -          852098 - Mid/Side
    -          852099 - Preserve Formants, Mid/Side
    -          852100 - Independent Phase
    -          852101 - Preserve Formants, Independent Phase
    -          852102 - Mid/Side, Independent Phase
    -          852103 - Preserve Formants, Mid/Side, Independent Phase
    -          852104 - Time Domain Smoothing
    -          852105 - Preserve Formants, Time Domain Smoothing
    -          852106 - Mid/Side, Time Domain Smoothing
    -          852107 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852108 - Independent Phase, Time Domain Smoothing
    -          852109 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852110 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852111 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Pitch Mode: HighQ
    -          852112 - nothing
    -          852113 - Preserve Formants
    -          852114 - Mid/Side
    -          852115 - Preserve Formants, Mid/Side
    -          852116 - Independent Phase
    -          852117 - Preserve Formants, Independent Phase
    -          852118 - Mid/Side, Independent Phase
    -          852119 - Preserve Formants, Mid/Side, Independent Phase
    -          852120 - Time Domain Smoothing
    -          852121 - Preserve Formants, Time Domain Smoothing
    -          852122 - Mid/Side, Time Domain Smoothing
    -          852123 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852124 - Independent Phase, Time Domain Smoothing
    -          852125 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852126 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852127 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Pitch Mode: HighQ
    -          852128 - nothing
    -          852129 - Preserve Formants
    -          852130 - Mid/Side
    -          852131 - Preserve Formants, Mid/Side
    -          852132 - Independent Phase
    -          852133 - Preserve Formants, Independent Phase
    -          852134 - Mid/Side, Independent Phase
    -          852135 - Preserve Formants, Mid/Side, Independent Phase
    -          852136 - Time Domain Smoothing
    -          852137 - Preserve Formants, Time Domain Smoothing
    -          852138 - Mid/Side, Time Domain Smoothing
    -          852139 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852140 - Independent Phase, Time Domain Smoothing
    -          852141 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852142 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852143 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Pitch Mode: HighQ
    -          852144 - nothing
    -          852145 - Preserve Formants
    -          852146 - Mid/Side
    -          852147 - Preserve Formants, Mid/Side
    -          852148 - Independent Phase
    -          852149 - Preserve Formants, Independent Phase
    -          852150 - Mid/Side, Independent Phase
    -          852151 - Preserve Formants, Mid/Side, Independent Phase
    -          852152 - Time Domain Smoothing
    -          852153 - Preserve Formants, Time Domain Smoothing
    -          852154 - Mid/Side, Time Domain Smoothing
    -          852155 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852156 - Independent Phase, Time Domain Smoothing
    -          852157 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852158 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852159 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Detector: Percussive, Pitch Mode: HighQ
    -          852160 - nothing
    -          852161 - Preserve Formants
    -          852162 - Mid/Side
    -          852163 - Preserve Formants, Mid/Side
    -          852164 - Independent Phase
    -          852165 - Preserve Formants, Independent Phase
    -          852166 - Mid/Side, Independent Phase
    -          852167 - Preserve Formants, Mid/Side, Independent Phase
    -          852168 - Time Domain Smoothing
    -          852169 - Preserve Formants, Time Domain Smoothing
    -          852170 - Mid/Side, Time Domain Smoothing
    -          852171 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852172 - Independent Phase, Time Domain Smoothing
    -          852173 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852174 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852175 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Detector: Percussive, Pitch Mode: HighQ
    -          852176 - nothing
    -          852177 - Preserve Formants
    -          852178 - Mid/Side
    -          852179 - Preserve Formants, Mid/Side
    -          852180 - Independent Phase
    -          852181 - Preserve Formants, Independent Phase
    -          852182 - Mid/Side, Independent Phase
    -          852183 - Preserve Formants, Mid/Side, Independent Phase
    -          852184 - Time Domain Smoothing
    -          852185 - Preserve Formants, Time Domain Smoothing
    -          852186 - Mid/Side, Time Domain Smoothing
    -          852187 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852188 - Independent Phase, Time Domain Smoothing
    -          852189 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852190 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852191 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Detector: Percussive, Pitch Mode: HighQ
    -          852192 - nothing
    -          852193 - Preserve Formants
    -          852194 - Mid/Side
    -          852195 - Preserve Formants, Mid/Side
    -          852196 - Independent Phase
    -          852197 - Preserve Formants, Independent Phase
    -          852198 - Mid/Side, Independent Phase
    -          852199 - Preserve Formants, Mid/Side, Independent Phase
    -          852200 - Time Domain Smoothing
    -          852201 - Preserve Formants, Time Domain Smoothing
    -          852202 - Mid/Side, Time Domain Smoothing
    -          852203 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852204 - Independent Phase, Time Domain Smoothing
    -          852205 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852206 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852207 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Detector: Soft, Pitch Mode: HighQ
    -          852208 - nothing
    -          852209 - Preserve Formants
    -          852210 - Mid/Side
    -          852211 - Preserve Formants, Mid/Side
    -          852212 - Independent Phase
    -          852213 - Preserve Formants, Independent Phase
    -          852214 - Mid/Side, Independent Phase
    -          852215 - Preserve Formants, Mid/Side, Independent Phase
    -          852216 - Time Domain Smoothing
    -          852217 - Preserve Formants, Time Domain Smoothing
    -          852218 - Mid/Side, Time Domain Smoothing
    -          852219 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852220 - Independent Phase, Time Domain Smoothing
    -          852221 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852222 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852223 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Detector: Soft, Pitch Mode: HighQ
    -          852224 - nothing
    -          852225 - Preserve Formants
    -          852226 - Mid/Side
    -          852227 - Preserve Formants, Mid/Side
    -          852228 - Independent Phase
    -          852229 - Preserve Formants, Independent Phase
    -          852230 - Mid/Side, Independent Phase
    -          852231 - Preserve Formants, Mid/Side, Independent Phase
    -          852232 - Time Domain Smoothing
    -          852233 - Preserve Formants, Time Domain Smoothing
    -          852234 - Mid/Side, Time Domain Smoothing
    -          852235 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852236 - Independent Phase, Time Domain Smoothing
    -          852237 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852238 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852239 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Detector: Soft, Pitch Mode: HighQ
    -          852240 - nothing
    -          852241 - Preserve Formants
    -          852242 - Mid/Side
    -          852243 - Preserve Formants, Mid/Side
    -          852244 - Independent Phase
    -          852245 - Preserve Formants, Independent Phase
    -          852246 - Mid/Side, Independent Phase
    -          852247 - Preserve Formants, Mid/Side, Independent Phase
    -          852248 - Time Domain Smoothing
    -          852249 - Preserve Formants, Time Domain Smoothing
    -          852250 - Mid/Side, Time Domain Smoothing
    -          852251 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852252 - Independent Phase, Time Domain Smoothing
    -          852253 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852254 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852255 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Pitch Mode: Consistent
    -          852256 - nothing
    -          852257 - Preserve Formants
    -          852258 - Mid/Side
    -          852259 - Preserve Formants, Mid/Side
    -          852260 - Independent Phase
    -          852261 - Preserve Formants, Independent Phase
    -          852262 - Mid/Side, Independent Phase
    -          852263 - Preserve Formants, Mid/Side, Independent Phase
    -          852264 - Time Domain Smoothing
    -          852265 - Preserve Formants, Time Domain Smoothing
    -          852266 - Mid/Side, Time Domain Smoothing
    -          852267 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852268 - Independent Phase, Time Domain Smoothing
    -          852269 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852270 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852271 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Pitch Mode: Consistent
    -          852272 - nothing
    -          852273 - Preserve Formants
    -          852274 - Mid/Side
    -          852275 - Preserve Formants, Mid/Side
    -          852276 - Independent Phase
    -          852277 - Preserve Formants, Independent Phase
    -          852278 - Mid/Side, Independent Phase
    -          852279 - Preserve Formants, Mid/Side, Independent Phase
    -          852280 - Time Domain Smoothing
    -          852281 - Preserve Formants, Time Domain Smoothing
    -          852282 - Mid/Side, Time Domain Smoothing
    -          852283 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852284 - Independent Phase, Time Domain Smoothing
    -          852285 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852286 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852287 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Pitch Mode: Consistent
    -          852288 - nothing
    -          852289 - Preserve Formants
    -          852290 - Mid/Side
    -          852291 - Preserve Formants, Mid/Side
    -          852292 - Independent Phase
    -          852293 - Preserve Formants, Independent Phase
    -          852294 - Mid/Side, Independent Phase
    -          852295 - Preserve Formants, Mid/Side, Independent Phase
    -          852296 - Time Domain Smoothing
    -          852297 - Preserve Formants, Time Domain Smoothing
    -          852298 - Mid/Side, Time Domain Smoothing
    -          852299 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852300 - Independent Phase, Time Domain Smoothing
    -          852301 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852302 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852303 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Detector: Percussive, Pitch Mode: Consistent
    -          852304 - nothing
    -          852305 - Preserve Formants
    -          852306 - Mid/Side
    -          852307 - Preserve Formants, Mid/Side
    -          852308 - Independent Phase
    -          852309 - Preserve Formants, Independent Phase
    -          852310 - Mid/Side, Independent Phase
    -          852311 - Preserve Formants, Mid/Side, Independent Phase
    -          852312 - Time Domain Smoothing
    -          852313 - Preserve Formants, Time Domain Smoothing
    -          852314 - Mid/Side, Time Domain Smoothing
    -          852315 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852316 - Independent Phase, Time Domain Smoothing
    -          852317 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852318 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852319 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Detector: Percussive, Pitch Mode: Consistent
    -          852320 - nothing
    -          852321 - Preserve Formants
    -          852322 - Mid/Side
    -          852323 - Preserve Formants, Mid/Side
    -          852324 - Independent Phase
    -          852325 - Preserve Formants, Independent Phase
    -          852326 - Mid/Side, Independent Phase
    -          852327 - Preserve Formants, Mid/Side, Independent Phase
    -          852328 - Time Domain Smoothing
    -          852329 - Preserve Formants, Time Domain Smoothing
    -          852330 - Mid/Side, Time Domain Smoothing
    -          852331 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852332 - Independent Phase, Time Domain Smoothing
    -          852333 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852334 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852335 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Detector: Percussive, Pitch Mode: Consistent
    -          852336 - nothing
    -          852337 - Preserve Formants
    -          852338 - Mid/Side
    -          852339 - Preserve Formants, Mid/Side
    -          852340 - Independent Phase
    -          852341 - Preserve Formants, Independent Phase
    -          852342 - Mid/Side, Independent Phase
    -          852343 - Preserve Formants, Mid/Side, Independent Phase
    -          852344 - Time Domain Smoothing
    -          852345 - Preserve Formants, Time Domain Smoothing
    -          852346 - Mid/Side, Time Domain Smoothing
    -          852347 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852348 - Independent Phase, Time Domain Smoothing
    -          852349 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852350 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852351 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Detector: Soft, Pitch Mode: Consistent
    -          852352 - nothing
    -          852353 - Preserve Formants
    -          852354 - Mid/Side
    -          852355 - Preserve Formants, Mid/Side
    -          852356 - Independent Phase
    -          852357 - Preserve Formants, Independent Phase
    -          852358 - Mid/Side, Independent Phase
    -          852359 - Preserve Formants, Mid/Side, Independent Phase
    -          852360 - Time Domain Smoothing
    -          852361 - Preserve Formants, Time Domain Smoothing
    -          852362 - Mid/Side, Time Domain Smoothing
    -          852363 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852364 - Independent Phase, Time Domain Smoothing
    -          852365 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852366 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852367 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Detector: Soft, Pitch Mode: Consistent
    -          852368 - nothing
    -          852369 - Preserve Formants
    -          852370 - Mid/Side
    -          852371 - Preserve Formants, Mid/Side
    -          852372 - Independent Phase
    -          852373 - Preserve Formants, Independent Phase
    -          852374 - Mid/Side, Independent Phase
    -          852375 - Preserve Formants, Mid/Side, Independent Phase
    -          852376 - Time Domain Smoothing
    -          852377 - Preserve Formants, Time Domain Smoothing
    -          852378 - Mid/Side, Time Domain Smoothing
    -          852379 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852380 - Independent Phase, Time Domain Smoothing
    -          852381 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852382 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852383 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Detector: Soft, Pitch Mode: Consistent
    -          852384 - nothing
    -          852385 - Preserve Formants
    -          852386 - Mid/Side
    -          852387 - Preserve Formants, Mid/Side
    -          852388 - Independent Phase
    -          852389 - Preserve Formants, Independent Phase
    -          852390 - Mid/Side, Independent Phase
    -          852391 - Preserve Formants, Mid/Side, Independent Phase
    -          852392 - Time Domain Smoothing
    -          852393 - Preserve Formants, Time Domain Smoothing
    -          852394 - Mid/Side, Time Domain Smoothing
    -          852395 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852396 - Independent Phase, Time Domain Smoothing
    -          852397 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852398 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852399 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Window: Short
    -          852400 - nothing
    -          852401 - Preserve Formants
    -          852402 - Mid/Side
    -          852403 - Preserve Formants, Mid/Side
    -          852404 - Independent Phase
    -          852405 - Preserve Formants, Independent Phase
    -          852406 - Mid/Side, Independent Phase
    -          852407 - Preserve Formants, Mid/Side, Independent Phase
    -          852408 - Time Domain Smoothing
    -          852409 - Preserve Formants, Time Domain Smoothing
    -          852410 - Mid/Side, Time Domain Smoothing
    -          852411 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852412 - Independent Phase, Time Domain Smoothing
    -          852413 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852414 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852415 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Window: Short
    -          852416 - nothing
    -          852417 - Preserve Formants
    -          852418 - Mid/Side
    -          852419 - Preserve Formants, Mid/Side
    -          852420 - Independent Phase
    -          852421 - Preserve Formants, Independent Phase
    -          852422 - Mid/Side, Independent Phase
    -          852423 - Preserve Formants, Mid/Side, Independent Phase
    -          852424 - Time Domain Smoothing
    -          852425 - Preserve Formants, Time Domain Smoothing
    -          852426 - Mid/Side, Time Domain Smoothing
    -          852427 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852428 - Independent Phase, Time Domain Smoothing
    -          852429 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852430 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852431 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Window: Short
    -          852432 - nothing
    -          852433 - Preserve Formants
    -          852434 - Mid/Side
    -          852435 - Preserve Formants, Mid/Side
    -          852436 - Independent Phase
    -          852437 - Preserve Formants, Independent Phase
    -          852438 - Mid/Side, Independent Phase
    -          852439 - Preserve Formants, Mid/Side, Independent Phase
    -          852440 - Time Domain Smoothing
    -          852441 - Preserve Formants, Time Domain Smoothing
    -          852442 - Mid/Side, Time Domain Smoothing
    -          852443 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852444 - Independent Phase, Time Domain Smoothing
    -          852445 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852446 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852447 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Detector: Percussive, Window: Short
    -          852448 - nothing
    -          852449 - Preserve Formants
    -          852450 - Mid/Side
    -          852451 - Preserve Formants, Mid/Side
    -          852452 - Independent Phase
    -          852453 - Preserve Formants, Independent Phase
    -          852454 - Mid/Side, Independent Phase
    -          852455 - Preserve Formants, Mid/Side, Independent Phase
    -          852456 - Time Domain Smoothing
    -          852457 - Preserve Formants, Time Domain Smoothing
    -          852458 - Mid/Side, Time Domain Smoothing
    -          852459 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852460 - Independent Phase, Time Domain Smoothing
    -          852461 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852462 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852463 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Detector: Percussive, Window: Short
    -          852464 - nothing
    -          852465 - Preserve Formants
    -          852466 - Mid/Side
    -          852467 - Preserve Formants, Mid/Side
    -          852468 - Independent Phase
    -          852469 - Preserve Formants, Independent Phase
    -          852470 - Mid/Side, Independent Phase
    -          852471 - Preserve Formants, Mid/Side, Independent Phase
    -          852472 - Time Domain Smoothing
    -          852473 - Preserve Formants, Time Domain Smoothing
    -          852474 - Mid/Side, Time Domain Smoothing
    -          852475 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852476 - Independent Phase, Time Domain Smoothing
    -          852477 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852478 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852479 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Detector: Percussive, Window: Short
    -          852480 - nothing
    -          852481 - Preserve Formants
    -          852482 - Mid/Side
    -          852483 - Preserve Formants, Mid/Side
    -          852484 - Independent Phase
    -          852485 - Preserve Formants, Independent Phase
    -          852486 - Mid/Side, Independent Phase
    -          852487 - Preserve Formants, Mid/Side, Independent Phase
    -          852488 - Time Domain Smoothing
    -          852489 - Preserve Formants, Time Domain Smoothing
    -          852490 - Mid/Side, Time Domain Smoothing
    -          852491 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852492 - Independent Phase, Time Domain Smoothing
    -          852493 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852494 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852495 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Detector: Soft, Window: Short
    -          852496 - nothing
    -          852497 - Preserve Formants
    -          852498 - Mid/Side
    -          852499 - Preserve Formants, Mid/Side
    -          852500 - Independent Phase
    -          852501 - Preserve Formants, Independent Phase
    -          852502 - Mid/Side, Independent Phase
    -          852503 - Preserve Formants, Mid/Side, Independent Phase
    -          852504 - Time Domain Smoothing
    -          852505 - Preserve Formants, Time Domain Smoothing
    -          852506 - Mid/Side, Time Domain Smoothing
    -          852507 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852508 - Independent Phase, Time Domain Smoothing
    -          852509 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852510 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852511 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Detector: Soft, Window: Short
    -          852512 - nothing
    -          852513 - Preserve Formants
    -          852514 - Mid/Side
    -          852515 - Preserve Formants, Mid/Side
    -          852516 - Independent Phase
    -          852517 - Preserve Formants, Independent Phase
    -          852518 - Mid/Side, Independent Phase
    -          852519 - Preserve Formants, Mid/Side, Independent Phase
    -          852520 - Time Domain Smoothing
    -          852521 - Preserve Formants, Time Domain Smoothing
    -          852522 - Mid/Side, Time Domain Smoothing
    -          852523 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852524 - Independent Phase, Time Domain Smoothing
    -          852525 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852526 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852527 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Detector: Soft, Window: Short
    -          852528 - nothing
    -          852529 - Preserve Formants
    -          852530 - Mid/Side
    -          852531 - Preserve Formants, Mid/Side
    -          852532 - Independent Phase
    -          852533 - Preserve Formants, Independent Phase
    -          852534 - Mid/Side, Independent Phase
    -          852535 - Preserve Formants, Mid/Side, Independent Phase
    -          852536 - Time Domain Smoothing
    -          852537 - Preserve Formants, Time Domain Smoothing
    -          852538 - Mid/Side, Time Domain Smoothing
    -          852539 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852540 - Independent Phase, Time Domain Smoothing
    -          852541 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852542 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852543 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Pitch Mode: HighQ, Window: Short
    -          852544 - nothing
    -          852545 - Preserve Formants
    -          852546 - Mid/Side
    -          852547 - Preserve Formants, Mid/Side
    -          852548 - Independent Phase
    -          852549 - Preserve Formants, Independent Phase
    -          852550 - Mid/Side, Independent Phase
    -          852551 - Preserve Formants, Mid/Side, Independent Phase
    -          852552 - Time Domain Smoothing
    -          852553 - Preserve Formants, Time Domain Smoothing
    -          852554 - Mid/Side, Time Domain Smoothing
    -          852555 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852556 - Independent Phase, Time Domain Smoothing
    -          852557 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852558 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852559 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Pitch Mode: HighQ, Window: Short
    -          852560 - nothing
    -          852561 - Preserve Formants
    -          852562 - Mid/Side
    -          852563 - Preserve Formants, Mid/Side
    -          852564 - Independent Phase
    -          852565 - Preserve Formants, Independent Phase
    -          852566 - Mid/Side, Independent Phase
    -          852567 - Preserve Formants, Mid/Side, Independent Phase
    -          852568 - Time Domain Smoothing
    -          852569 - Preserve Formants, Time Domain Smoothing
    -          852570 - Mid/Side, Time Domain Smoothing
    -          852571 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852572 - Independent Phase, Time Domain Smoothing
    -          852573 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852574 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852575 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Pitch Mode: HighQ, Window: Short
    -          852576 - nothing
    -          852577 - Preserve Formants
    -          852578 - Mid/Side
    -          852579 - Preserve Formants, Mid/Side
    -          852580 - Independent Phase
    -          852581 - Preserve Formants, Independent Phase
    -          852582 - Mid/Side, Independent Phase
    -          852583 - Preserve Formants, Mid/Side, Independent Phase
    -          852584 - Time Domain Smoothing
    -          852585 - Preserve Formants, Time Domain Smoothing
    -          852586 - Mid/Side, Time Domain Smoothing
    -          852587 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852588 - Independent Phase, Time Domain Smoothing
    -          852589 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852590 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852591 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Detector: Percussive, Pitch Mode: HighQ, Window: Short
    -          852592 - nothing
    -          852593 - Preserve Formants
    -          852594 - Mid/Side
    -          852595 - Preserve Formants, Mid/Side
    -          852596 - Independent Phase
    -          852597 - Preserve Formants, Independent Phase
    -          852598 - Mid/Side, Independent Phase
    -          852599 - Preserve Formants, Mid/Side, Independent Phase
    -          852600 - Time Domain Smoothing
    -          852601 - Preserve Formants, Time Domain Smoothing
    -          852602 - Mid/Side, Time Domain Smoothing
    -          852603 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852604 - Independent Phase, Time Domain Smoothing
    -          852605 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852606 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852607 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Detector: Percussive, Pitch Mode: HighQ, Window: Short
    -          852608 - nothing
    -          852609 - Preserve Formants
    -          852610 - Mid/Side
    -          852611 - Preserve Formants, Mid/Side
    -          852612 - Independent Phase
    -          852613 - Preserve Formants, Independent Phase
    -          852614 - Mid/Side, Independent Phase
    -          852615 - Preserve Formants, Mid/Side, Independent Phase
    -          852616 - Time Domain Smoothing
    -          852617 - Preserve Formants, Time Domain Smoothing
    -          852618 - Mid/Side, Time Domain Smoothing
    -          852619 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852620 - Independent Phase, Time Domain Smoothing
    -          852621 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852622 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852623 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Detector: Percussive, Pitch Mode: HighQ, Window: Short
    -          852624 - nothing
    -          852625 - Preserve Formants
    -          852626 - Mid/Side
    -          852627 - Preserve Formants, Mid/Side
    -          852628 - Independent Phase
    -          852629 - Preserve Formants, Independent Phase
    -          852630 - Mid/Side, Independent Phase
    -          852631 - Preserve Formants, Mid/Side, Independent Phase
    -          852632 - Time Domain Smoothing
    -          852633 - Preserve Formants, Time Domain Smoothing
    -          852634 - Mid/Side, Time Domain Smoothing
    -          852635 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852636 - Independent Phase, Time Domain Smoothing
    -          852637 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852638 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852639 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Detector: Soft, Pitch Mode: HighQ, Window: Short
    -          852640 - nothing
    -          852641 - Preserve Formants
    -          852642 - Mid/Side
    -          852643 - Preserve Formants, Mid/Side
    -          852644 - Independent Phase
    -          852645 - Preserve Formants, Independent Phase
    -          852646 - Mid/Side, Independent Phase
    -          852647 - Preserve Formants, Mid/Side, Independent Phase
    -          852648 - Time Domain Smoothing
    -          852649 - Preserve Formants, Time Domain Smoothing
    -          852650 - Mid/Side, Time Domain Smoothing
    -          852651 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852652 - Independent Phase, Time Domain Smoothing
    -          852653 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852654 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852655 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Detector: Soft, Pitch Mode: HighQ, Window: Short
    -          852656 - nothing
    -          852657 - Preserve Formants
    -          852658 - Mid/Side
    -          852659 - Preserve Formants, Mid/Side
    -          852660 - Independent Phase
    -          852661 - Preserve Formants, Independent Phase
    -          852662 - Mid/Side, Independent Phase
    -          852663 - Preserve Formants, Mid/Side, Independent Phase
    -          852664 - Time Domain Smoothing
    -          852665 - Preserve Formants, Time Domain Smoothing
    -          852666 - Mid/Side, Time Domain Smoothing
    -          852667 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852668 - Independent Phase, Time Domain Smoothing
    -          852669 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852670 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852671 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Detector: Soft, Pitch Mode: HighQ, Window: Short
    -          852672 - nothing
    -          852673 - Preserve Formants
    -          852674 - Mid/Side
    -          852675 - Preserve Formants, Mid/Side
    -          852676 - Independent Phase
    -          852677 - Preserve Formants, Independent Phase
    -          852678 - Mid/Side, Independent Phase
    -          852679 - Preserve Formants, Mid/Side, Independent Phase
    -          852680 - Time Domain Smoothing
    -          852681 - Preserve Formants, Time Domain Smoothing
    -          852682 - Mid/Side, Time Domain Smoothing
    -          852683 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852684 - Independent Phase, Time Domain Smoothing
    -          852685 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852686 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852687 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Pitch Mode: Consistent, Window: Short
    -          852688 - nothing
    -          852689 - Preserve Formants
    -          852690 - Mid/Side
    -          852691 - Preserve Formants, Mid/Side
    -          852692 - Independent Phase
    -          852693 - Preserve Formants, Independent Phase
    -          852694 - Mid/Side, Independent Phase
    -          852695 - Preserve Formants, Mid/Side, Independent Phase
    -          852696 - Time Domain Smoothing
    -          852697 - Preserve Formants, Time Domain Smoothing
    -          852698 - Mid/Side, Time Domain Smoothing
    -          852699 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852700 - Independent Phase, Time Domain Smoothing
    -          852701 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852702 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852703 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Pitch Mode: Consistent, Window: Short
    -          852704 - nothing
    -          852705 - Preserve Formants
    -          852706 - Mid/Side
    -          852707 - Preserve Formants, Mid/Side
    -          852708 - Independent Phase
    -          852709 - Preserve Formants, Independent Phase
    -          852710 - Mid/Side, Independent Phase
    -          852711 - Preserve Formants, Mid/Side, Independent Phase
    -          852712 - Time Domain Smoothing
    -          852713 - Preserve Formants, Time Domain Smoothing
    -          852714 - Mid/Side, Time Domain Smoothing
    -          852715 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852716 - Independent Phase, Time Domain Smoothing
    -          852717 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852718 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852719 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Pitch Mode: Consistent, Window: Short
    -          852720 - nothing
    -          852721 - Preserve Formants
    -          852722 - Mid/Side
    -          852723 - Preserve Formants, Mid/Side
    -          852724 - Independent Phase
    -          852725 - Preserve Formants, Independent Phase
    -          852726 - Mid/Side, Independent Phase
    -          852727 - Preserve Formants, Mid/Side, Independent Phase
    -          852728 - Time Domain Smoothing
    -          852729 - Preserve Formants, Time Domain Smoothing
    -          852730 - Mid/Side, Time Domain Smoothing
    -          852731 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852732 - Independent Phase, Time Domain Smoothing
    -          852733 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852734 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852735 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Detector: Percussive, Pitch Mode: Consistent, Window: Short
    -          852736 - nothing
    -          852737 - Preserve Formants
    -          852738 - Mid/Side
    -          852739 - Preserve Formants, Mid/Side
    -          852740 - Independent Phase
    -          852741 - Preserve Formants, Independent Phase
    -          852742 - Mid/Side, Independent Phase
    -          852743 - Preserve Formants, Mid/Side, Independent Phase
    -          852744 - Time Domain Smoothing
    -          852745 - Preserve Formants, Time Domain Smoothing
    -          852746 - Mid/Side, Time Domain Smoothing
    -          852747 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852748 - Independent Phase, Time Domain Smoothing
    -          852749 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852750 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852751 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Detector: Percussive, Pitch Mode: Consistent, Window: Short
    -          852752 - nothing
    -          852753 - Preserve Formants
    -          852754 - Mid/Side
    -          852755 - Preserve Formants, Mid/Side
    -          852756 - Independent Phase
    -          852757 - Preserve Formants, Independent Phase
    -          852758 - Mid/Side, Independent Phase
    -          852759 - Preserve Formants, Mid/Side, Independent Phase
    -          852760 - Time Domain Smoothing
    -          852761 - Preserve Formants, Time Domain Smoothing
    -          852762 - Mid/Side, Time Domain Smoothing
    -          852763 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852764 - Independent Phase, Time Domain Smoothing
    -          852765 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852766 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852767 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Detector: Percussive, Pitch Mode: Consistent, Window: Short
    -          852768 - nothing
    -          852769 - Preserve Formants
    -          852770 - Mid/Side
    -          852771 - Preserve Formants, Mid/Side
    -          852772 - Independent Phase
    -          852773 - Preserve Formants, Independent Phase
    -          852774 - Mid/Side, Independent Phase
    -          852775 - Preserve Formants, Mid/Side, Independent Phase
    -          852776 - Time Domain Smoothing
    -          852777 - Preserve Formants, Time Domain Smoothing
    -          852778 - Mid/Side, Time Domain Smoothing
    -          852779 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852780 - Independent Phase, Time Domain Smoothing
    -          852781 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852782 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852783 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Detector: Soft, Pitch Mode: Consistent, Window: Short
    -          852784 - nothing
    -          852785 - Preserve Formants
    -          852786 - Mid/Side
    -          852787 - Preserve Formants, Mid/Side
    -          852788 - Independent Phase
    -          852789 - Preserve Formants, Independent Phase
    -          852790 - Mid/Side, Independent Phase
    -          852791 - Preserve Formants, Mid/Side, Independent Phase
    -          852792 - Time Domain Smoothing
    -          852793 - Preserve Formants, Time Domain Smoothing
    -          852794 - Mid/Side, Time Domain Smoothing
    -          852795 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852796 - Independent Phase, Time Domain Smoothing
    -          852797 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852798 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852799 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Detector: Soft, Pitch Mode: Consistent, Window: Short
    -          852800 - nothing
    -          852801 - Preserve Formants
    -          852802 - Mid/Side
    -          852803 - Preserve Formants, Mid/Side
    -          852804 - Independent Phase
    -          852805 - Preserve Formants, Independent Phase
    -          852806 - Mid/Side, Independent Phase
    -          852807 - Preserve Formants, Mid/Side, Independent Phase
    -          852808 - Time Domain Smoothing
    -          852809 - Preserve Formants, Time Domain Smoothing
    -          852810 - Mid/Side, Time Domain Smoothing
    -          852811 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852812 - Independent Phase, Time Domain Smoothing
    -          852813 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852814 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852815 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Detector: Soft, Pitch Mode: Consistent, Window: Short
    -          852816 - nothing
    -          852817 - Preserve Formants
    -          852818 - Mid/Side
    -          852819 - Preserve Formants, Mid/Side
    -          852820 - Independent Phase
    -          852821 - Preserve Formants, Independent Phase
    -          852822 - Mid/Side, Independent Phase
    -          852823 - Preserve Formants, Mid/Side, Independent Phase
    -          852824 - Time Domain Smoothing
    -          852825 - Preserve Formants, Time Domain Smoothing
    -          852826 - Mid/Side, Time Domain Smoothing
    -          852827 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852828 - Independent Phase, Time Domain Smoothing
    -          852829 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852830 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852831 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Window: Long
    -          852832 - nothing
    -          852833 - Preserve Formants
    -          852834 - Mid/Side
    -          852835 - Preserve Formants, Mid/Side
    -          852836 - Independent Phase
    -          852837 - Preserve Formants, Independent Phase
    -          852838 - Mid/Side, Independent Phase
    -          852839 - Preserve Formants, Mid/Side, Independent Phase
    -          852840 - Time Domain Smoothing
    -          852841 - Preserve Formants, Time Domain Smoothing
    -          852842 - Mid/Side, Time Domain Smoothing
    -          852843 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852844 - Independent Phase, Time Domain Smoothing
    -          852845 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852846 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852847 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Window: Long
    -          852848 - nothing
    -          852849 - Preserve Formants
    -          852850 - Mid/Side
    -          852851 - Preserve Formants, Mid/Side
    -          852852 - Independent Phase
    -          852853 - Preserve Formants, Independent Phase
    -          852854 - Mid/Side, Independent Phase
    -          852855 - Preserve Formants, Mid/Side, Independent Phase
    -          852856 - Time Domain Smoothing
    -          852857 - Preserve Formants, Time Domain Smoothing
    -          852858 - Mid/Side, Time Domain Smoothing
    -          852859 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852860 - Independent Phase, Time Domain Smoothing
    -          852861 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852862 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852863 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Window: Long
    -          852864 - nothing
    -          852865 - Preserve Formants
    -          852866 - Mid/Side
    -          852867 - Preserve Formants, Mid/Side
    -          852868 - Independent Phase
    -          852869 - Preserve Formants, Independent Phase
    -          852870 - Mid/Side, Independent Phase
    -          852871 - Preserve Formants, Mid/Side, Independent Phase
    -          852872 - Time Domain Smoothing
    -          852873 - Preserve Formants, Time Domain Smoothing
    -          852874 - Mid/Side, Time Domain Smoothing
    -          852875 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852876 - Independent Phase, Time Domain Smoothing
    -          852877 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852878 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852879 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Detector: Percussive, Window: Long
    -          852880 - nothing
    -          852881 - Preserve Formants
    -          852882 - Mid/Side
    -          852883 - Preserve Formants, Mid/Side
    -          852884 - Independent Phase
    -          852885 - Preserve Formants, Independent Phase
    -          852886 - Mid/Side, Independent Phase
    -          852887 - Preserve Formants, Mid/Side, Independent Phase
    -          852888 - Time Domain Smoothing
    -          852889 - Preserve Formants, Time Domain Smoothing
    -          852890 - Mid/Side, Time Domain Smoothing
    -          852891 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852892 - Independent Phase, Time Domain Smoothing
    -          852893 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852894 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852895 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Detector: Percussive, Window: Long
    -          852896 - nothing
    -          852897 - Preserve Formants
    -          852898 - Mid/Side
    -          852899 - Preserve Formants, Mid/Side
    -          852900 - Independent Phase
    -          852901 - Preserve Formants, Independent Phase
    -          852902 - Mid/Side, Independent Phase
    -          852903 - Preserve Formants, Mid/Side, Independent Phase
    -          852904 - Time Domain Smoothing
    -          852905 - Preserve Formants, Time Domain Smoothing
    -          852906 - Mid/Side, Time Domain Smoothing
    -          852907 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852908 - Independent Phase, Time Domain Smoothing
    -          852909 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852910 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852911 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Detector: Percussive, Window: Long
    -          852912 - nothing
    -          852913 - Preserve Formants
    -          852914 - Mid/Side
    -          852915 - Preserve Formants, Mid/Side
    -          852916 - Independent Phase
    -          852917 - Preserve Formants, Independent Phase
    -          852918 - Mid/Side, Independent Phase
    -          852919 - Preserve Formants, Mid/Side, Independent Phase
    -          852920 - Time Domain Smoothing
    -          852921 - Preserve Formants, Time Domain Smoothing
    -          852922 - Mid/Side, Time Domain Smoothing
    -          852923 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852924 - Independent Phase, Time Domain Smoothing
    -          852925 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852926 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852927 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Detector: Soft, Window: Long
    -          852928 - nothing
    -          852929 - Preserve Formants
    -          852930 - Mid/Side
    -          852931 - Preserve Formants, Mid/Side
    -          852932 - Independent Phase
    -          852933 - Preserve Formants, Independent Phase
    -          852934 - Mid/Side, Independent Phase
    -          852935 - Preserve Formants, Mid/Side, Independent Phase
    -          852936 - Time Domain Smoothing
    -          852937 - Preserve Formants, Time Domain Smoothing
    -          852938 - Mid/Side, Time Domain Smoothing
    -          852939 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852940 - Independent Phase, Time Domain Smoothing
    -          852941 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852942 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852943 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Detector: Soft, Window: Long
    -          852944 - nothing
    -          852945 - Preserve Formants
    -          852946 - Mid/Side
    -          852947 - Preserve Formants, Mid/Side
    -          852948 - Independent Phase
    -          852949 - Preserve Formants, Independent Phase
    -          852950 - Mid/Side, Independent Phase
    -          852951 - Preserve Formants, Mid/Side, Independent Phase
    -          852952 - Time Domain Smoothing
    -          852953 - Preserve Formants, Time Domain Smoothing
    -          852954 - Mid/Side, Time Domain Smoothing
    -          852955 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852956 - Independent Phase, Time Domain Smoothing
    -          852957 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852958 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852959 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Detector: Soft, Window: Long
    -          852960 - nothing
    -          852961 - Preserve Formants
    -          852962 - Mid/Side
    -          852963 - Preserve Formants, Mid/Side
    -          852964 - Independent Phase
    -          852965 - Preserve Formants, Independent Phase
    -          852966 - Mid/Side, Independent Phase
    -          852967 - Preserve Formants, Mid/Side, Independent Phase
    -          852968 - Time Domain Smoothing
    -          852969 - Preserve Formants, Time Domain Smoothing
    -          852970 - Mid/Side, Time Domain Smoothing
    -          852971 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852972 - Independent Phase, Time Domain Smoothing
    -          852973 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852974 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852975 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Pitch Mode: HighQ, Window: Long
    -          852976 - nothing
    -          852977 - Preserve Formants
    -          852978 - Mid/Side
    -          852979 - Preserve Formants, Mid/Side
    -          852980 - Independent Phase
    -          852981 - Preserve Formants, Independent Phase
    -          852982 - Mid/Side, Independent Phase
    -          852983 - Preserve Formants, Mid/Side, Independent Phase
    -          852984 - Time Domain Smoothing
    -          852985 - Preserve Formants, Time Domain Smoothing
    -          852986 - Mid/Side, Time Domain Smoothing
    -          852987 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          852988 - Independent Phase, Time Domain Smoothing
    -          852989 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          852990 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          852991 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Pitch Mode: HighQ, Window: Long
    -          852992 - nothing
    -          852993 - Preserve Formants
    -          852994 - Mid/Side
    -          852995 - Preserve Formants, Mid/Side
    -          852996 - Independent Phase
    -          852997 - Preserve Formants, Independent Phase
    -          852998 - Mid/Side, Independent Phase
    -          852999 - Preserve Formants, Mid/Side, Independent Phase
    -          853000 - Time Domain Smoothing
    -          853001 - Preserve Formants, Time Domain Smoothing
    -          853002 - Mid/Side, Time Domain Smoothing
    -          853003 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          853004 - Independent Phase, Time Domain Smoothing
    -          853005 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          853006 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          853007 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Pitch Mode: HighQ, Window: Long
    -          853008 - nothing
    -          853009 - Preserve Formants
    -          853010 - Mid/Side
    -          853011 - Preserve Formants, Mid/Side
    -          853012 - Independent Phase
    -          853013 - Preserve Formants, Independent Phase
    -          853014 - Mid/Side, Independent Phase
    -          853015 - Preserve Formants, Mid/Side, Independent Phase
    -          853016 - Time Domain Smoothing
    -          853017 - Preserve Formants, Time Domain Smoothing
    -          853018 - Mid/Side, Time Domain Smoothing
    -          853019 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          853020 - Independent Phase, Time Domain Smoothing
    -          853021 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          853022 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          853023 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Detector: Percussive, Pitch Mode: HighQ, Window: Long
    -          853024 - nothing
    -          853025 - Preserve Formants
    -          853026 - Mid/Side
    -          853027 - Preserve Formants, Mid/Side
    -          853028 - Independent Phase
    -          853029 - Preserve Formants, Independent Phase
    -          853030 - Mid/Side, Independent Phase
    -          853031 - Preserve Formants, Mid/Side, Independent Phase
    -          853032 - Time Domain Smoothing
    -          853033 - Preserve Formants, Time Domain Smoothing
    -          853034 - Mid/Side, Time Domain Smoothing
    -          853035 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          853036 - Independent Phase, Time Domain Smoothing
    -          853037 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          853038 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          853039 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Detector: Percussive, Pitch Mode: HighQ, Window: Long
    -          853040 - nothing
    -          853041 - Preserve Formants
    -          853042 - Mid/Side
    -          853043 - Preserve Formants, Mid/Side
    -          853044 - Independent Phase
    -          853045 - Preserve Formants, Independent Phase
    -          853046 - Mid/Side, Independent Phase
    -          853047 - Preserve Formants, Mid/Side, Independent Phase
    -          853048 - Time Domain Smoothing
    -          853049 - Preserve Formants, Time Domain Smoothing
    -          853050 - Mid/Side, Time Domain Smoothing
    -          853051 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          853052 - Independent Phase, Time Domain Smoothing
    -          853053 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          853054 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          853055 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Detector: Percussive, Pitch Mode: HighQ, Window: Long
    -          853056 - nothing
    -          853057 - Preserve Formants
    -          853058 - Mid/Side
    -          853059 - Preserve Formants, Mid/Side
    -          853060 - Independent Phase
    -          853061 - Preserve Formants, Independent Phase
    -          853062 - Mid/Side, Independent Phase
    -          853063 - Preserve Formants, Mid/Side, Independent Phase
    -          853064 - Time Domain Smoothing
    -          853065 - Preserve Formants, Time Domain Smoothing
    -          853066 - Mid/Side, Time Domain Smoothing
    -          853067 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          853068 - Independent Phase, Time Domain Smoothing
    -          853069 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          853070 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          853071 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Detector: Soft, Pitch Mode: HighQ, Window: Long
    -          853072 - nothing
    -          853073 - Preserve Formants
    -          853074 - Mid/Side
    -          853075 - Preserve Formants, Mid/Side
    -          853076 - Independent Phase
    -          853077 - Preserve Formants, Independent Phase
    -          853078 - Mid/Side, Independent Phase
    -          853079 - Preserve Formants, Mid/Side, Independent Phase
    -          853080 - Time Domain Smoothing
    -          853081 - Preserve Formants, Time Domain Smoothing
    -          853082 - Mid/Side, Time Domain Smoothing
    -          853083 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          853084 - Independent Phase, Time Domain Smoothing
    -          853085 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          853086 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          853087 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Detector: Soft, Pitch Mode: HighQ, Window: Long
    -          853088 - nothing
    -          853089 - Preserve Formants
    -          853090 - Mid/Side
    -          853091 - Preserve Formants, Mid/Side
    -          853092 - Independent Phase
    -          853093 - Preserve Formants, Independent Phase
    -          853094 - Mid/Side, Independent Phase
    -          853095 - Preserve Formants, Mid/Side, Independent Phase
    -          853096 - Time Domain Smoothing
    -          853097 - Preserve Formants, Time Domain Smoothing
    -          853098 - Mid/Side, Time Domain Smoothing
    -          853099 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          853100 - Independent Phase, Time Domain Smoothing
    -          853101 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          853102 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          853103 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Detector: Soft, Pitch Mode: HighQ, Window: Long
    -          853104 - nothing
    -          853105 - Preserve Formants
    -          853106 - Mid/Side
    -          853107 - Preserve Formants, Mid/Side
    -          853108 - Independent Phase
    -          853109 - Preserve Formants, Independent Phase
    -          853110 - Mid/Side, Independent Phase
    -          853111 - Preserve Formants, Mid/Side, Independent Phase
    -          853112 - Time Domain Smoothing
    -          853113 - Preserve Formants, Time Domain Smoothing
    -          853114 - Mid/Side, Time Domain Smoothing
    -          853115 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          853116 - Independent Phase, Time Domain Smoothing
    -          853117 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          853118 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          853119 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Pitch Mode: Consistent, Window: Long
    -          853120 - nothing
    -          853121 - Preserve Formants
    -          853122 - Mid/Side
    -          853123 - Preserve Formants, Mid/Side
    -          853124 - Independent Phase
    -          853125 - Preserve Formants, Independent Phase
    -          853126 - Mid/Side, Independent Phase
    -          853127 - Preserve Formants, Mid/Side, Independent Phase
    -          853128 - Time Domain Smoothing
    -          853129 - Preserve Formants, Time Domain Smoothing
    -          853130 - Mid/Side, Time Domain Smoothing
    -          853131 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          853132 - Independent Phase, Time Domain Smoothing
    -          853133 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          853134 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          853135 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Pitch Mode: Consistent, Window: Long
    -          853136 - nothing
    -          853137 - Preserve Formants
    -          853138 - Mid/Side
    -          853139 - Preserve Formants, Mid/Side
    -          853140 - Independent Phase
    -          853141 - Preserve Formants, Independent Phase
    -          853142 - Mid/Side, Independent Phase
    -          853143 - Preserve Formants, Mid/Side, Independent Phase
    -          853144 - Time Domain Smoothing
    -          853145 - Preserve Formants, Time Domain Smoothing
    -          853146 - Mid/Side, Time Domain Smoothing
    -          853147 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          853148 - Independent Phase, Time Domain Smoothing
    -          853149 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          853150 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          853151 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Pitch Mode: Consistent, Window: Long
    -          853152 - nothing
    -          853153 - Preserve Formants
    -          853154 - Mid/Side
    -          853155 - Preserve Formants, Mid/Side
    -          853156 - Independent Phase
    -          853157 - Preserve Formants, Independent Phase
    -          853158 - Mid/Side, Independent Phase
    -          853159 - Preserve Formants, Mid/Side, Independent Phase
    -          853160 - Time Domain Smoothing
    -          853161 - Preserve Formants, Time Domain Smoothing
    -          853162 - Mid/Side, Time Domain Smoothing
    -          853163 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          853164 - Independent Phase, Time Domain Smoothing
    -          853165 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          853166 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          853167 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Detector: Percussive, Pitch Mode: Consistent, Window: Long
    -          853168 - nothing
    -          853169 - Preserve Formants
    -          853170 - Mid/Side
    -          853171 - Preserve Formants, Mid/Side
    -          853172 - Independent Phase
    -          853173 - Preserve Formants, Independent Phase
    -          853174 - Mid/Side, Independent Phase
    -          853175 - Preserve Formants, Mid/Side, Independent Phase
    -          853176 - Time Domain Smoothing
    -          853177 - Preserve Formants, Time Domain Smoothing
    -          853178 - Mid/Side, Time Domain Smoothing
    -          853179 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          853180 - Independent Phase, Time Domain Smoothing
    -          853181 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          853182 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          853183 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Detector: Percussive, Pitch Mode: Consistent, Window: Long
    -          853184 - nothing
    -          853185 - Preserve Formants
    -          853186 - Mid/Side
    -          853187 - Preserve Formants, Mid/Side
    -          853188 - Independent Phase
    -          853189 - Preserve Formants, Independent Phase
    -          853190 - Mid/Side, Independent Phase
    -          853191 - Preserve Formants, Mid/Side, Independent Phase
    -          853192 - Time Domain Smoothing
    -          853193 - Preserve Formants, Time Domain Smoothing
    -          853194 - Mid/Side, Time Domain Smoothing
    -          853195 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          853196 - Independent Phase, Time Domain Smoothing
    -          853197 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          853198 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          853199 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Detector: Percussive, Pitch Mode: Consistent, Window: Long
    -          853200 - nothing
    -          853201 - Preserve Formants
    -          853202 - Mid/Side
    -          853203 - Preserve Formants, Mid/Side
    -          853204 - Independent Phase
    -          853205 - Preserve Formants, Independent Phase
    -          853206 - Mid/Side, Independent Phase
    -          853207 - Preserve Formants, Mid/Side, Independent Phase
    -          853208 - Time Domain Smoothing
    -          853209 - Preserve Formants, Time Domain Smoothing
    -          853210 - Mid/Side, Time Domain Smoothing
    -          853211 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          853212 - Independent Phase, Time Domain Smoothing
    -          853213 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          853214 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          853215 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Detector: Soft, Pitch Mode: Consistent, Window: Long
    -          853216 - nothing
    -          853217 - Preserve Formants
    -          853218 - Mid/Side
    -          853219 - Preserve Formants, Mid/Side
    -          853220 - Independent Phase
    -          853221 - Preserve Formants, Independent Phase
    -          853222 - Mid/Side, Independent Phase
    -          853223 - Preserve Formants, Mid/Side, Independent Phase
    -          853224 - Time Domain Smoothing
    -          853225 - Preserve Formants, Time Domain Smoothing
    -          853226 - Mid/Side, Time Domain Smoothing
    -          853227 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          853228 - Independent Phase, Time Domain Smoothing
    -          853229 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          853230 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          853231 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Mixed, Detector: Soft, Pitch Mode: Consistent, Window: Long
    -          853232 - nothing
    -          853233 - Preserve Formants
    -          853234 - Mid/Side
    -          853235 - Preserve Formants, Mid/Side
    -          853236 - Independent Phase
    -          853237 - Preserve Formants, Independent Phase
    -          853238 - Mid/Side, Independent Phase
    -          853239 - Preserve Formants, Mid/Side, Independent Phase
    -          853240 - Time Domain Smoothing
    -          853241 - Preserve Formants, Time Domain Smoothing
    -          853242 - Mid/Side, Time Domain Smoothing
    -          853243 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          853244 - Independent Phase, Time Domain Smoothing
    -          853245 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          853246 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          853247 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    -      
    -      Rubber Band Library - Transients: Smooth, Detector: Soft, Pitch Mode: Consistent, Window: Long
    -          853248 - nothing
    -          853249 - Preserve Formants
    -          853250 - Mid/Side
    -          853251 - Preserve Formants, Mid/Side
    -          853252 - Independent Phase
    -          853253 - Preserve Formants, Independent Phase
    -          853254 - Mid/Side, Independent Phase
    -          853255 - Preserve Formants, Mid/Side, Independent Phase
    -          853256 - Time Domain Smoothing
    -          853257 - Preserve Formants, Time Domain Smoothing
    -          853258 - Mid/Side, Time Domain Smoothing
    -          853259 - Preserve Formants, Mid/Side, Time Domain Smoothing
    -          853260 - Independent Phase, Time Domain Smoothing
    -          853261 - Preserve Formants, Independent Phase, Time Domain Smoothing
    -          853262 - Mid/Side, Independent Phase, Time Domain Smoothing
    -          853263 - Preserve Formants, Mid/Side, Independent Phase, Time Domain Smoothing
    integer optimize_tonal_content - 2, checkbox for optimize-tonal-content is set on; 0, checkbox for optimize-tonal-content is set off
    number stretch_marker_fadesize - in milliseconds; negative values are allowed
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, playrate, pitch</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemPlayRate","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemPlayRate","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return
  end
  -- get value and return it
  statechunk=statechunk:match("PLAYRATE( .-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
    
  return tonumber(statechunk:match(" (.-) ")), 
         tonumber(statechunk:match(" .- (.-) ")),
         tonumber(statechunk:match(" .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- .- (.-) "))
end

--C,CC,CCC=ultraschall.GetAllMediaItemsBetween(1,60,"1,2,3",false)
--A1,A2,A3,A4,A5,A6=ultraschall.GetItemPlayRate(reaper.GetMediaItem(0,0))

function ultraschall.GetItemChanMode(MediaItem, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemChanMode</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer channelmode = ultraschall.GetItemChanMode(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns the channelmode-entry of a MediaItem or MediaItemStateChunk.
    It's the CHANMODE-entry
    Returns nil in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose channelmode-state you want to know; nil, use parameter MediaItemStatechunk instead
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    integer channelmode - channelmode
    - 0 - normal
    - 1 - reverse stereo
    - 2 - Mono (Mix L+R)
    - 3 - Mono Left
    - 4 - Mono Right
    - 5 - Mono 3
    - ...
    - 66 - Mono 64
    - 67 - Stereo 1/2
    - ...
    - 129 - Stereo 63/64
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, channel, mode</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemChanMode","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemChanMode","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return
  end
  -- get value and return it
  statechunk=statechunk:match("CHANMODE( .-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
    
  return tonumber(statechunk:match(" (.-) ")), 
         tonumber(statechunk:match(" .- (.-) ")),
         tonumber(statechunk:match(" .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- .- (.-) "))
end

--C,CC,CCC=ultraschall.GetAllMediaItemsBetween(1,60,"1,2,3",false)
--A1,A2,A3,A4,A5=ultraschall.GetItemChanMode(reaper.GetMediaItem(0,0))

function ultraschall.GetItemGUID(MediaItem, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemGUID</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string GUID = ultraschall.GetItemGUID(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns the GUID-entry of a MediaItem or MediaItemStateChunk.
    Returns nil in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose GUID-state you want to know; nil, use parameter MediaItemStatechunk instead
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    string GUID - the GUID of the item
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, guid</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemGUID","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemGUID","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return
  end
  -- get value and return it
  return statechunk:match("%cGUID (.-)%c")
end

--C,CC,CCC=ultraschall.GetAllMediaItemsBetween(1,60,"1,3",false)
--AL,AL2,AL3,AL4,AL5,AL6=ultraschall.GetItemGUID(reaper.GetMediaItem(0,0))

function ultraschall.GetItemRecPass(MediaItem, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemRecPass</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer recpass_state = ultraschall.GetItemRecPass(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns the recpass-entry of a MediaItem or MediaItemStateChunk.
    It's the counter of the recorded item-takes within a project, ordered by the order of recording. Only displayed with recorded item-takes, not imported ones.
    
    It's the RECPASS-entry.
    Returns nil in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose recpass-state you want to know; nil, use parameter MediaItemStatechunk instead
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    integer recpass_state - the number of recorded mediaitem; every recorded item gets it's counting-number.
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, recpass</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemRecPass","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemRecPass","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return
  end
  -- get value and return it
  statechunk=statechunk:match("RECPASS( .-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
    
  return tonumber(statechunk:match(" (.-) ")), 
         tonumber(statechunk:match(" .- (.-) ")),
         tonumber(statechunk:match(" .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- .- (.-) "))
end

--A=ultraschall.GetItemRecPass(reaper.GetMediaItem(0,0))

function ultraschall.GetItemBeat(MediaItem, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemBeat</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer beatstate = ultraschall.GetItemBeat(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns the beatstate/timebase-entry of a MediaItem or MediaItemStateChunk.
    Returns -1 in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose beatstate/timebase-state you want to know; nil, use parameter MediaItemStatechunk instead
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    integer beatstate - the item-timebase state
    - nil - Track/project default timebase
    - 0 - Time
    - 1 - Beats (posiiton, length, rate)
    - 2 - Beats (position only)
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, beat, timebase</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemBeat","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemBeat","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return -1
  end
  -- get value and return it
  statechunk=statechunk:match("BEAT( .-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
    
  return tonumber(statechunk:match(" (.-) ")), 
         tonumber(statechunk:match(" .- (.-) ")),
         tonumber(statechunk:match(" .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- .- (.-) "))
end

--C,CC,CCC=ultraschall.GetAllMediaItemsBetween(1,60,"1,3",false)
--AL,AL2,AL3,AL4,AL5,AL6=ultraschall.GetItemBeat(reaper.GetMediaItem(0,0))

function ultraschall.GetItemMixFlag(MediaItem, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemMixFlag</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer itemmix_state = ultraschall.GetItemMixFlag(MediaItem MediaItem, optional string MediaItemStateChunk)</functioncall>
  <description>
    Returns the item-mix-behavior-entry of a MediaItemStateChunk.
    Returns -1 in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose item-mix-behavior-state you want to know; nil, use parameter MediaItemStatechunk instead
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    integer itemmix_state - the item-mix-behavior
    - nil - Project Default item mix behavior
    - 0 - Enclosed items replace enclosing items
    - 1 - Items always mix
    - 2 - Items always replace earlier items
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, itemmix behavior</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if MediaItem~=nil then
    if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then retval, statechunk=reaper.GetItemStateChunk(MediaItem,"",false) 
    else ultraschall.AddErrorMessage("GetItemMixFlag","MediaItem", "must be a MediaItem.", -2) return end
  elseif MediaItem==nil and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemMixFlag","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return -1
  end
  -- get value and return it
  statechunk=statechunk:match("MIXFLAG( .-)%c")
  if statechunk==nil then return nil end
  statechunk=statechunk.." "
  local O=statechunk
    
  return tonumber(statechunk:match(" (.-) ")), 
         tonumber(statechunk:match(" .- (.-) ")),
         tonumber(statechunk:match(" .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- (.-) ")),
         tonumber(statechunk:match(" .- .- .- .- .- .- .- (.-) "))
end

--A=ultraschall.GetItemMixFlag(reaper.GetMediaItem(0,0))

function ultraschall.GetItemUSTrackNumber_StateChunk(statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemUSTrackNumber_StateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer tracknumber, MediaTrack track = ultraschall.GetItemUSTrackNumber_StateChunk(string MediaItemStateChunk)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the tracknumber as well as the mediatrack-object from where the mediaitem was from, as given by a MediaItemStateChunk.
    This works only, if the StateChunk contains the entry "ULTRASCHALL_TRACKNUMBER", which holds the original tracknumber of the MediaItem.

    This entry will only be added by functions from the Ultraschall-API, like [GetAllMediaItemsBetween](#GetAllMediaItemsBetween)
    Returns -1 in case of error.
  </description>
  <parameters>
    string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    integer tracknumber - the tracknumber, where this item came from; starts with 1 for the first track!
    MediaTrack track - the accompanying track as MediaTrack-object
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, track, tracknumber</tags>
</US_DocBloc>
]]
  -- check parameters and prepare statechunk-variable
  local retval
  if ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("GetItemUSTrackNumber_StateChunk","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return -1 end
  -- get value and return it
  tracknumber=statechunk:match("ULTRASCHALL_TRACKNUMBER (.-)%c")
  if tracknumber==nil then ultraschall.AddErrorMessage("GetItemUSTrackNumber_StateChunk","MediaItemStateChunk", "no ULTRASCHALL_TRACKNUMBER-entry found in the statechunk.", -2) return -1 end
  
  return tonumber(statechunk:match("ULTRASCHALL_TRACKNUMBER (.-)%c")), reaper.GetTrack(0,tonumber(statechunk:match("ULTRASCHALL_TRACKNUMBER (.-)%c"))-1)
end


function ultraschall.SetItemUSTrackNumber_StateChunk(statechunk, tracknumber)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetItemUSTrackNumber_StateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string MediaItemStateChunk = ultraschall.SetItemUSTrackNumber_StateChunk(string MediaItemStateChunk, integer tracknumber)</functioncall>
  <description>
    Adds/Replaces the entry "ULTRASCHALL_TRACKNUMBER" in a MediaItemStateChunk, that tells other Ultraschall-Apifunctions, from which track this item originated from.
    It returns the modified MediaItemStateChunk.
    Returns -1 in case of error.
  </description>
  <parameters>
    string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
    integer tracknumber - the tracknumber you want to set, with 1 for track 1, 2 for track 2
  </parameters>
  <retvals>
    string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </retvals>
  <chapter_context>
    MediaItem Management
    Set MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, track, tracknumber</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("SetItemUSTrackNumber_StateChunk","MediaItemStateChunk", "must be a valid MediaItemStateChunk.", -1) return -1 end
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetItemUSTrackNumber_StateChunk","tracknumber", "must be an integer.", -2) end
  if tracknumber<1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("SetItemUSTrackNumber_StateChunk","tracknumber", "no such track.", -3) return -1 end
  if statechunk:match("ULTRASCHALL_TRACKNUMBER") then 
    statechunk="<ITEM\n"..statechunk:match(".-ULTRASCHALL_TRACKNUMBER.-%c(.*)")
  end
  
  statechunk="<ITEM\nULTRASCHALL_TRACKNUMBER "..tracknumber.."\n"..statechunk:match("<ITEM(.*)")
  return statechunk
end

function ultraschall.SetItemPosition(MediaItem, position, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetItemPosition</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string MediaItemStateChunk = ultraschall.SetItemPosition(MediaItem MediaItem, integer position, optional string MediaItemStateChunk)</functioncall>
  <description>
    Sets position in a MediaItem or MediaItemStateChunk in seconds.
    It returns the modified MediaItemStateChunk.
    Returns -1 in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose state you want to change; nil, use parameter MediaItemStateChunk instead
    integer position - position in seconds
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </retvals>
  <chapter_context>
    MediaItem Management
    Set MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, position</tags>
</US_DocBloc>
]]
  -- check parameters
  local _tudelu
  if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then _tudelu, statechunk=reaper.GetItemStateChunk(MediaItem, "", false) 
  elseif ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("SetItemPosition", "statechunk", "Must be a valid statechunk.", -1) return nil
  end
  if type(position)~="number" then ultraschall.AddErrorMessage("SetItemPosition", "position", "Must be a number.", -2) return nil end  
  if position<0 then ultraschall.AddErrorMessage("SetItemPosition", "position", "Must bigger than or equal 0.", -3) return -1 end
  
  -- do the magic
  statechunk=statechunk:match("(<ITEM.-)POSITION").."POSITION "..position.."\n"..statechunk:match("POSITION.-%c(.*)")
  
  -- set statechunk, if MediaItem is provided, otherwise don't set it
  if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then reaper.SetItemStateChunk(MediaItem, statechunk, false) end
  
  -- return
  return statechunk
end


function ultraschall.SetItemLength(MediaItem, length, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetItemLength</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string MediaItemStateChunk = ultraschall.SetItemLength(MediaItem MediaItem, integer length, string MediaItemStateChunk)</functioncall>
  <description>
    Sets length in a MediaItem and MediaItemStateChunk in seconds.
    It returns the modified MediaItemStateChunk.
    Returns -1 in case of error.
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose state you want to change; nil, use parameter MediaItemStateChunk instead
    integer length - length in seconds
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </retvals>
  <chapter_context>
    MediaItem Management
    Set MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, length</tags>
</US_DocBloc>
]]
  -- check parameters
  local _tudelu
  if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then _tudelu, statechunk=reaper.GetItemStateChunk(MediaItem, "", false) 
  elseif ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("SetItemLength", "statechunk", "Must be a valid statechunk.", -1) return nil
  end
--  reaper.MB(type(length),length,0)
  if type(length)~="number" then ultraschall.AddErrorMessage("SetItemLength", "length", "Must be a number.", -2) return nil end  
  if length<0 then ultraschall.AddErrorMessage("SetItemLength", "length", "Must bigger than or equal 0.", -3) return -1 end
  
  -- do the magic
  statechunk=statechunk:match("(<ITEM.-)LENGTH").."LENGTH "..length.."\n"..statechunk:match("LENGTH.-%c(.*)")
  
  -- set statechunk, if MediaItem is provided, otherwise don't set it
  if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then reaper.SetItemStateChunk(MediaItem, statechunk, false) end
  
  -- return
  return statechunk
end


function ultraschall.InsertMediaItemStateChunkArray(position, MediaItemStateChunkArray, trackstring)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>InsertMediaItemStateChunkArray</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer number_of_items, array MediaItemArray = ultraschall.InsertMediaItemStateChunkArray(number position, array MediaItemStateChunkArray, string trackstring)</functioncall>
  <description>
    Inserts the MediaItems from MediaItemStateChunkArray at position into the tracks, as given by trackstring.
    Note:Needs ULTRASCHALL_TRACKNUMBER within the statechunks, which includes the tracknumber for each mediaitem to be included. Else it will return -1. That entry will be included automatically into the MediaItemStateChunkArray as provided by <a href="#GetAllMediaItemsBetween">GetAllMediaItemsBetween</a>. If you need to manually insert that entry into a statechunk, use <a href="#SetItemUSTRackNumber_StateChunk">SetItemUSTRackNumber_StateChunk</a>.
    
    Returns the number of newly created items, as well as an array with the newly create MediaItems.
    Returns -1 in case of failure.
    
    Note: this inserts the items only in the tracks, where the original items came from(or the tracks set with the entry ULTRASCHALL_TRACKNUMBER). Items from track 1 will be included into track 1. Trackstring only helps to include or exclude the items from inclusion into certain tracks.
    If you have a MediaItemStateChunkArray with items from track 1,2,3,4,5 and you give trackstring only the tracknumber for track 3 and 4 -> 3,4, then only the items, that were in tracks 3 and 4 originally, will be included, all the others will be ignored.
  </description>
  <parameters>
    number position - the position of the newly created mediaitem
    array MediaItemStateChunkArray - an array with the statechunks of the MediaItems to be inserted
    string trackstring - the numbers of the tracks, separated by a ,
  </parameters>
  <retvals>
    integer number_of_items - the number of MediaItems created
    array MediaItemArray - an array with the newly created MediaItems
  </retvals>
  <chapter_context>
    MediaItem Management
    Insert
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, insert, statechunk</tags>
</US_DocBloc>
]]    
  if type(position)~="number" then ultraschall.AddErrorMessage("InsertMediaItemStateChunkArray", "position", "Must be a number.", -1) return -1 end
  if ultraschall.IsValidMediaItemStateChunkArray(MediaItemStateChunkArray)==false then ultraschall.AddErrorMessage("InsertMediaItemStateChunkArray", "MediaItemStateChunkArray", "Must be a valid MediaItemStateChunkArray.", -2) return -1 end
  if ultraschall.IsValidTrackString(trackstring)==false then ultraschall.AddErrorMessage("InsertMediaItemStateChunkArray", "trackstring", "Must be a valid trackstring.", -3) return -1 end

  local L,trackstring,AA,AAA=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if trackstring==-1 or trackstring==""  then return -1 end
  local count=1
  local i,LL
  local NewMediaItemArray={}
  local LL
  local _count, individual_values = ultraschall.CSV2IndividualLinesAsArray(trackstring) 
  local ItemStart=reaper.GetProjectLength()+1
  while MediaItemStateChunkArray[count]~=nil do
    local ItemStart_temp=ultraschall.GetItemPosition(nil,MediaItemStateChunkArray[count])
    if ItemStart>ItemStart_temp then ItemStart=ItemStart_temp end
    count=count+1
  end
  count=1
  while MediaItemStateChunkArray[count]~=nil do
    local ItemStart_temp=ultraschall.GetItemPosition(nil,MediaItemStateChunkArray[count])
    local tempo,MediaTrack=ultraschall.GetItemUSTrackNumber_StateChunk(MediaItemStateChunkArray[count])
    if tempo==nil then return -1 end
    i=1
    while individual_values[i]~=nil do
      local tempo,tempoMediaTrack=ultraschall.GetItemUSTrackNumber_StateChunk(MediaItemStateChunkArray[count])
      if tempoMediaTrack==nil then return -1 end
      if reaper.GetTrack(0,individual_values[i]-1)==tempoMediaTrack then
        LL, NewMediaItemArray[count]=ultraschall.InsertMediaItem_MediaItemStateChunk(position+(ItemStart_temp-ItemStart), MediaItemStateChunkArray[count], MediaTrack)
      end
      i=i+1
    end
    count=count+1
  end  

  return count, NewMediaItemArray
end

--ultraschall.InsertMediaItemStateChunkArray(1,,3)

function ultraschall.OnlyMediaItemsOfTracksInTrackstring_StateChunk(MediaItemStateChunkArray, trackstring)
--Throws out all items, that are not in the tracks, as given by trackstring
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>OnlyMediaItemsOfTracksInTrackstring_StateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval, array MediaItemStateChunkArray = ultraschall.OnlyMediaItemsOfTracksInTrackstring_StateChunk(array MediaItemStateChunkArray, string trackstring)</functioncall>
  <description>
    Throws all MediaItems out of the MediaItemStateChunkArray, that are not within the tracks, as given with trackstring.
    Returns the "cleared" MediaItemArray; returns -1 in case of error
  </description>
  <parameters>
    array MediaItemStateChunkArray - an array with MediaItems; no nil-entries allowed, will be seen as the end of the array
    string trackstring - the tracknumbers, separated by a comma
  </parameters>
  <retvals>
    integer retval - -1 in case of error, 1 in case of success
    array MediaItemStateChunkarray - the "cleared" array, that contains only the statechunks of MediaItems in tracks, as given by trackstring, -1 in case of error
  </retvals>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, selection, statechunk</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidMediaItemStateChunkArray(MediaItemStateChunkArray)==false then ultraschall.AddErrorMessage("OnlyMediaItemsOfTracksInTrackstring_StateChunk", "MediaItemStateChunkArray", "Must be a valid MediaItemStateChunkArray.", -1) return -1 end
  if ultraschall.IsValidTrackString(trackstring)==false then ultraschall.AddErrorMessage("OnlyMediaItemsOfTracksInTrackstring_StateChunk", "trackstring", "Must be a valid trackstring.", -2) return -1 end

  local L,trackstring,AA,AAA=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if trackstring==-1 or trackstring=="" then ultraschall.AddErrorMessage("OnlyMediaItemsOfTracksInTrackstring_StateChunk", "trackstring", "Must be a valid trackstring.", -3) return -1 end
  
  local count=1
  local count2=1
  local i=1
  local _count, trackstring_array= ultraschall.CSV2IndividualLinesAsArray(trackstring)
  local MediaItemArray2={}
  
  while MediaItemStateChunkArray[count]~=nil do
    if MediaItemStateChunkArray[count]==nil then break end
    i=1
    while trackstring_array[i]~=nil do
      if tonumber(trackstring_array[i])==nil then return -1 end
        local Atracknumber, Atrack = ultraschall.GetItemUSTrackNumber_StateChunk(MediaItemStateChunkArray[count])
        if reaper.GetTrack(0,trackstring_array[i]-1)==Atrack then
          MediaItemArray2[count2]=MediaItemStateChunkArray[count]
          count2=count2+1
        end
        i=i+1
    end
    count=count+1
  end
  return 1, MediaItemArray2
end


function ultraschall.RippleInsert_MediaItemStateChunks(position, MediaItemStateChunkArray, trackstring, moveenvelopepoints, movemarkers)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>RippleInsert_MediaItemStateChunks</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer number_of_items, array MediaItemStateChunkArray, number endpos_inserted_items = ultraschall.RippleInsert_MediaItemStateChunks(number position, array MediaItemStateChunkArray, string trackstring, boolean moveenvelopepoints, boolean movemarkers)</functioncall>
  <description>
    It inserts the MediaItems from MediaItemStateChunkArray at position into the tracks, as given by trackstring. It moves the items, that were there before, accordingly toward the end of the project.
    
    Returns the number of newly created items, as well as an array with the newly created MediaItems as statechunks and the endposition of the last(projectposition) inserted item into the project.
    Returns -1 in case of failure.
    
    Note: this inserts the items only in the tracks, where the original items came from. Items from track 1 will be included into track 1. Trackstring only helps to include or exclude the items from inclusion into certain tracks.
    If you have a MediaItemStateChunkArray with items from track 1,2,3,4,5 and you give trackstring only the tracknumber for track 3 and 4 -> 3,4, then only the items, that were in tracks 3 and 4 originally, will be included, all the others will be ignored.
  </description>
  <parameters>
    number position - the position of the newly created mediaitem
    array MediaItemStateChunkArray - an array with the statechunks of MediaItems to be inserted
    string trackstring - the numbers of the tracks, separated by a ,
    boolean moveenvelopepoints - true, move the envelopepoints as well; false, keep the envelopepoints where they are
    boolean movemarkers - true, move markers as well; false, keep markers where they are
  </parameters>
  <retvals>
    integer number_of_items - the number of newly created items
    array MediaItemStateChunkArray - an array with the newly created MediaItems as StateChunkArray
    number endpos_inserted_items - the endposition of the last newly inserted MediaItem
  </retvals>
  <chapter_context>
    MediaItem Management
    Insert
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, insert, ripple</tags>
</US_DocBloc>
]]

  if type(position)~="number" then ultraschall.AddErrorMessage("RippleInsert_MediaItemStateChunks", "position", "must be a number", -1) return -1 end
  if ultraschall.IsValidMediaItemStateChunkArray(MediaItemStateChunkArray)==false then ultraschall.AddErrorMessage("RippleInsert_MediaItemStateChunks", "MediaItemStateChunkArray", "must be a valid MediaItemStateChunkArray", -2) return -1 end
  if ultraschall.IsValidTrackString(trackstring)==false then ultraschall.AddErrorMessage("RippleInsert_MediaItemStateChunks", "trackstring", "must be a valid trackstring", -3) return -1 end
  if type(moveenvelopepoints)~="boolean" then ultraschall.AddErrorMessage("RippleInsert_MediaItemStateChunks", "moveenvelopepoints", "must be a boolean", -4) return -1 end    
  if type(movemarkers)~="boolean" then ultraschall.AddErrorMessage("RippleInsert_MediaItemStateChunks", "movemarkers", "must be a boolean", -5) return -1 end
      
  local L,trackstring,AA,AAA=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if trackstring==-1 or trackstring=="" then ultraschall.AddErrorMessage("RippleInsert_MediaItemStateChunks", "trackstring", "must be a valid trackstring", -6) return -1 end

  local NumberOfItems
  local NewMediaItemArray={}
  local count=1
  local ItemStart=reaper.GetProjectLength()+1
  local ItemEnd=0
  local i
  local _count, individual_values = ultraschall.CSV2IndividualLinesAsArray(trackstring)
  while MediaItemStateChunkArray[count]~=nil do
    local ItemStart_temp=ultraschall.GetItemPosition(nil,MediaItemStateChunkArray[count]) --reaper.GetMediaItemInfo_Value(MediaItemArray[count], "D_POSITION") --Buggy
    local ItemEnd_temp=ultraschall.GetItemLength(nil, MediaItemStateChunkArray[count]) --reaper.GetMediaItemInfo_Value(MediaItemArray[count], "D_LENGTH") --Buggy
    i=1
    while individual_values[i]~=nil do
      local Atracknumber, Atrack = ultraschall.GetItemUSTrackNumber_StateChunk(MediaItemStateChunkArray[count])
      if reaper.GetTrack(0,individual_values[i]-1)==Atrack then
        if ItemStart>ItemStart_temp then ItemStart=ItemStart_temp end
        if ItemEnd<ItemEnd_temp+ItemStart_temp then ItemEnd=ItemEnd_temp+ItemStart_temp end
      end
      i=i+1
    end
    count=count+1
  end

  
  --Create copy of the track-state-chunks
  local nums, MediaItemArray_Chunk=ultraschall.GetMediaItemStateChunksFromItems(MediaItemArray)
    
  local A,A2=ultraschall.SplitMediaItems_Position(position,trackstring,false)

  if moveenvelopepoints==true then
    local CountTracks=reaper.CountTracks()
    for i=0, CountTracks-1 do
      for a=1,AAA do
        if tonumber(AA[a])==i+1 then
          local MediaTrack=reaper.GetTrack(0,i)
          retval = ultraschall.MoveTrackEnvelopePointsBy(position, reaper.GetProjectLength()+(ItemEnd-ItemStart), ItemEnd-ItemStart, MediaTrack, true) 
        end
      end
    end
  end
  
  if movemarkers==true then
    ultraschall.MoveMarkersBy(position, reaper.GetProjectLength()+(ItemEnd-ItemStart), ItemEnd-ItemStart, true)
  end
  ultraschall.MoveMediaItemsAfter_By(position-0.000001, ItemEnd-ItemStart, trackstring)

  local L,MediaItemArray=ultraschall.OnlyMediaItemsOfTracksInTrackstring_StateChunk(MediaItemStateChunkArray, trackstring) --BUGGY?
  count=1
  while MediaItemStateChunkArray[count]~=nil do
    local Anumber=ultraschall.GetItemPosition(nil, MediaItemStateChunkArray[count])
    count=count+1
  end
    local NumberOfItems, NewMediaItemArray=ultraschall.InsertMediaItemStateChunkArray(position, MediaItemStateChunkArray, trackstring)
  count=1
  
  while MediaItemStateChunkArray[count]~=nil do
    local length=MediaItemStateChunkArray[count]:match("LENGTH (.-)%c")
--    reaper.MB(length,"",0)
    NewMediaItemArray[count]=ultraschall.SetItemLength(NewMediaItemArray[count], tonumber(length))
    count=count+1
  end
  return NumberOfItems, NewMediaItemArray, position+ItemEnd
end

--A,B,C,D,E=ultraschall.GetAllMediaItemsBetween(1,20,"1,2,3",false)
--ultraschall.RippleInsert_MediaItemStateChunks(l,C,"1,2,3",true, true)




function ultraschall.GetAllMediaItemsFromTrack(tracknumber)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllMediaItemsFromTrack</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    SWS=2.8.8
    Lua=5.3
  </requires>
  <functioncall>integer itemcount, array MediaItemArray, array MediaItemStateChunkArray = ultraschall.GetAllMediaItemsFromTrack(integer tracknumber)</functioncall>
  <description>
    returns the number of items of tracknumber, as well as an array with all MediaItems and an array with all MediaItemStateChunks
    returns -1 in case of error
  </description>
  <parameters>
    integer tracknumber - the tracknumber, from where you want to get the item
  </parameters>
  <retvals>
    integer itemcount - the number of items in that track
    array MediaItemArray - an array with all MediaItems from this track
    array MediaItemStateChunkArray - an array with all MediaItemStateCunks from this track
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItems
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, track, get, item, mediaitem, statechunk, state, chunk</tags>
</US_DocBloc>
]]
--  tracknumber=tonumber(tracknumber) 
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("GetAllMediaItemsFromTrack","tracknumber", "must be an integer", -1) return -1 end
  if tracknumber<1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("GetAllMediaItemsFromTrack","tracknumber", "no such track", -2) return -1 end
  
  local count=1
  local MediaTrack=reaper.GetTrack(0,tracknumber-1)
  local MediaItemArray={}
  local MediaItemArrayStateChunk={}
  local MediaItem=""
  local temp
  local retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "", true)
  str=str:match("<ITEM.*")

  while str:match(".-%cIGUID.-")~= nil do
    local GUID=str:match(".-%cIGUID ({.-})%c")
    MediaItemArray[count]=reaper.BR_GetMediaItemByGUID(0, GUID)
    temp, MediaItemArrayStateChunk[count]=reaper.GetItemStateChunk(MediaItemArray[count],"",true)
    str=str:match(".-%cIGUID.-%c(.*)")
    if count==idx then MediaItem=reaper.BR_GetMediaItemByGUID(0, GUID) end
      count=count+1
    end
  return count-1, MediaItemArray, MediaItemArrayStateChunk
end

--A,B,C=ultraschall.GetAllMediaItemsFromTrack("")

function ultraschall.SetItemsLockState(MediaItemArray, lockstate)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetItemsLockState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetItemsLockState(array MediaItemArray, boolean lockstate)</functioncall>
  <description>
    Sets the lockstate of the items in MediaItemArray. Set lockstate=true to set the items locked; false to set them unlocked.
    
    returns true in case of success, false in case of error
  </description>
  <parameters>
    array MediaItemArray - an array with the MediaItems to be processed
    boolean lockstate - true, to set the MediaItems to locked, false to set them to unlocked
  </parameters>
  <retvals>
    boolean retval - true in case of success, false in case of error
  </retvals>
  <chapter_context>
    MediaItem Management
    Manipulate
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, track, set, item, mediaitem, lock</tags>
</US_DocBloc>
]]

  if type(lockstate)~="boolean" then ultraschall.AddErrorMessage("SetItemsLockState", "lockstate", "Must be a boolean.", -1) return false end
  if ultraschall.CheckMediaItemArray(MediaItemArray)==false then ultraschall.AddErrorMessage("SetItemsLockState", "MediaItemArray", "No valid MediaItemArray.", -2) return false end
  count=1
  while MediaItemArray[count]~=nil do
      if lockstate==true then reaper.SetMediaItemInfo_Value(MediaItemArray[count], "C_LOCK", 1)
      elseif lockstate==false then reaper.SetMediaItemInfo_Value(MediaItemArray[count], "C_LOCK", 0)
      end
      count=count+1
  end
  return true
end


function ultraschall.AddLockStateToMediaItemStateChunk(MediaItemStateChunk, lockstate)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AddLockStateToMediaItemStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string changedMediaItemStateChunk = ultraschall.AddLockStateToMediaItemStateChunk(string MediaItemStateChunk, boolean lockstate)</functioncall>
  <description>
    Sets the lockstate in a MediaItemStateChunk. Set lockstate=true to set the chunk locked; false to set it unlocked.
    
    Does not apply the changes to the MediaItem itself. To do that, use reaper.GetItemStateChunk or <a href="#ApplyStateChunkToItems">ApplyStateChunkToItems</a>!
    
    returns the changed MediaItemStateChunk; -1 in case of failure
  </description>
  <parameters>
    string MediaItemStateChunk - the statechunk of the item to be processed, as returned by functions like reaper.GetItemStateChunk
    boolean lockstate - true, to set the MediaItemStateChunk to locked, false to set it to unlocked
  </parameters>
  <retvals>
    string changedMediaItemStateChunk - the lockstate-modified MediaItemStateChunk
  </retvals>
  <chapter_context>
    MediaItem Management
    Manipulate
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, track, set, item, mediaitem, statechunk, state, chunk, lock</tags>
</US_DocBloc>
]]
  if type(lockstate)~="boolean" then ultraschall.AddErrorMessage("AddLockStateToMediaItemStateChunk", "lockstate", "Must be a boolean.", -1) return -1 end
  if ultraschall.IsValidMediaItemStateChunk(MediaItemStateChunk)==false then ultraschall.AddErrorMessage("AddLockStateToMediaItemStateChunk", "MediaItemStateChunk", "Must be a valid MediaItemStateChunk.", -2) return -1 end
  local Begin=MediaItemStateChunk:match("<ITEM.-MUTE.-%c")
  local End=MediaItemStateChunk:match("<ITEM.-(%cSEL.*)")
  if lockstate==true then return Begin.."LOCK 1"..End
  elseif lockstate==false then return Begin..End end
end

function ultraschall.AddLockStateTo_MediaItemStateChunkArray(MediaItemStateChunkArray, lockstate)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AddLockStateTo_MediaItemStateChunkArray</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer count, array changedMediaItemStateChunkArray = ultraschall.AddLockStateTo_MediaItemStateChunkArray(array MediaItemStateChunkArray, boolean lockstate)</functioncall>
  <description>
    Sets the lockstates in a MediaItemStateChunkArray. Set lockstate=true to set the chunks locked; false to set them unlocked.
    
    Does not apply the changes to the MediaItem itself. To do that, use reaper.GetItemStateChunk or <a href="#ApplyStateChunkToItems">ApplyStateChunkToItems</a>!
    
    returns the number of entries and the altered MediaItemStateChunkArray; -1 in case of failure
  </description>
  <parameters>
    array MediaItemStateChunkArray - the statechunkarray of the items to be processed, as returned by functions like reaper.GetItemStateChunk
    boolean lockstate - true, to set the MediaItemStateChunk to locked, false to set it to unlocked
  </parameters>
  <retvals>
    integer count - the number of entries in the changed MediaItemStateChunkArray
    array changedMediaItemStateChunkArray - the lockstate-modified MediaItemStateChunkArray
  </retvals>
  <chapter_context>
    MediaItem Management
    Manipulate
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, track, set, item, mediaitem, statechunk, state, chunk, lock</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidMediaItemStateChunkArray(MediaItemStateChunkArray)==false then ultraschall.AddErrorMessage("AddLockStateTo_MediaItemStateChunkArray", "MediaItemStateChunkArray", "must be a valid MediaItemStateChunkArray", -1) return -1 end
  if type(lockstate)~="boolean" then ultraschall.AddErrorMessage("AddLockStateTo_MediaItemStateChunkArray", "lockstate", "must be a boolean", -2) return -1 end
  local count=1
  while MediaItemStateChunkArray[count]~=nil do
      if lockstate==true then 
        MediaItemStateChunkArray[count]=ultraschall.AddLockStateToMediaItemStateChunk(MediaItemStateChunkArray[count], true)
      elseif lockstate==false then 
        MediaItemStateChunkArray[count]=ultraschall.AddLockStateToMediaItemStateChunk(MediaItemStateChunkArray[count], false)
      end
      count=count+1
  end
  return count-1, MediaItemStateChunkArray
end

--A,B,C=ultraschall.GetAllMediaItemsBetween(1,20,"1",false)
--ultraschall.AddLockStateTo_MediaItemStateChunkArray(C,1)

function ultraschall.ApplyStateChunkToItems(MediaItemStateChunkArray, undostate)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ApplyStateChunkToItems</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, integer skippeditemscount, array skipped_MediaItemStateChunkArray = ultraschall.ApplyStateChunkToItems(array MediaItemStateChunkArray, boolean undostate)</functioncall>
  <description>
    Applies changed StateChunks to the respective items. Skips deleted items, as they can't be set.
    
    It will look into the IGUID-entry of the statechunks, to find the right corresponding MediaItem to apply the statechunk to.
    
    returns the number of entries and the altered MediaItemStateChunkArray; -1 in case of failure
  </description>
  <parameters>
    array MediaItemStateChunkArray - the statechunkarray of the items to be applied, as returned by functions like reaper.GetItemStateChunk
    boolean undostate - true, sets the changed undo-possible, false undo-impossible
  </parameters>
  <retvals>
    boolean retval - true it worked, false it didn't
    integer skippeditemscount - the number of entries that couldn't be applied
    array skipped_MediaItemStateChunkArray - the StateChunks, that couldn't be aplied
  </retvals>
  <chapter_context>
    MediaItem Management
    Manipulate
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, track, set, item, mediaitem, statechunk, state, chunk, apply</tags>
</US_DocBloc>
]]
  if ultraschall.CheckMediaItemStateChunkArray(MediaItemStateChunkArray)==false then ultraschall.AddErrorMessage("ApplyStateChunkToItems","MediaItemStateChunkArray", "must be a valid MediaItemStateChunkArray", -1) return false end
  if type(undostate)~="boolean" then ultraschall.AddErrorMessage("ApplyStateChunkToItems","undostate", "must be a boolean", -2) return false end
  local count=1
  local count_two=1
  local MediaItemStateChunkArray2={}
  while MediaItemStateChunkArray[count]~=nil do
    local IGUID = ultraschall.GetItemIGUID_StateChunk(MediaItemStateChunkArray[count])
    local MediaItem=reaper.BR_GetMediaItemByGUID(0, IGUID)
    if MediaItem~=nil then local Boolean=reaper.SetItemStateChunk(MediaItem, MediaItemStateChunkArray[count], undostate) 
      --reaper.MB("hula","",0)
    else
      MediaItemStateChunkArray2[count_two]=MediaItemStateChunkArray[count]
      count_two=count_two+1
    end
    count=count+1
  end
  return true, count_two-1, MediaItemStateChunkArray2
end

--ultraschall.ApplyStateChunkToItems("", "")

function ultraschall.GetAllLockedItemsFromMediaItemArray(MediaItemArray)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllLockedItemsFromMediaItemArray</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer countlock, array locked_MediaItemArray, integer countunlock, array unlocked_MediaItemArray = ultraschall.GetAllLockedItemsFromMediaItemArray(array MediaItemArray)</functioncall>
  <description>
    Returns the number and the items that are locked, as well as the number and the items that are NOT locked.
    The items are returned as MediaItemArrays
    returns -1 in case of failure
  </description>
  <parameters>
    array MediaItemArray - the statechunkarray of the items to be checked.
  </parameters>
  <retvals>
    integer countlock - the number of locked items. -1 in case of failure
    array locked_MediaItemArray - the locked items in a mediaitemarray
    integer countunlock - the number of un(!)locked items
    array unlocked_MediaItemArray - the un(!)locked items in a mediaitemarray
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItems
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, track, set, item, mediaitem, selection, lock, lockstate, locked state, unlock, unlocked state</tags>
</US_DocBloc>
]]

  if ultraschall.CheckMediaItemArray(MediaItemArray)==false then ultraschall.AddErrorMessage("GetAllLockedItemsFromMediaItemArray", "MediaItemArray", "Only array with MediaItemObjects as entries is allowed.", -1) return -1 end
  local MediaItemArray_locked={}
  local MediaItemArray_unlocked={}
  local count=1
  local countlock=1
  local countunlock=1
  while MediaItemArray[count]~=nil do
    local number=reaper.GetMediaItemInfo_Value(MediaItemArray[count], "C_LOCK")
    if number==0 then MediaItemArray_unlocked[countunlock]=MediaItemArray[count] countunlock=countunlock+1
    elseif number==1 then MediaItemArray_locked[countlock]=MediaItemArray[count] countlock=countlock+1 
    end
    count=count+1
  end
  return countlock-1, MediaItemArray_locked, countunlock-1, MediaItemArray_unlocked
end

function ultraschall.GetMediaItemStateChunksFromMediaItemArray(MediaItemArray)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetMediaItemStateChunksFromMediaItemArray</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer count, array MediaItemStateChunkArray = ultraschall.GetMediaItemStateChunksFromMediaItemArray(array MediaItemArray)</functioncall>
  <description>
    Returns the number of items and statechunks of the Items in MediaItemArray. It skips items in MediaItemArray, that are deleted.
    returns -1 in case of failure
  </description>
  <parameters>
    array MediaItemArray - the statechunkarray of the items to be checked.
  </parameters>
  <retvals>
    integer count - the number of statechunks returned. -1 in case of failure
    array MediaItemStateChunkArray - the statechunks of the items in mediaitemarray
  </retvals>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, track, set, item, mediaitem, selection, chunk, statechunk, state chunk, state</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidMediaItemArray(MediaItemArray)==false then ultraschall.AddErrorMessage("GetMediaItemStateChunksFromMediaItemArray", "MediaItemArray", "No valid MediaItemArray", -1) return -1 end
  local MediaItemStateChunkArray={}
  local count=1
  local count2=1
  local retval
  while MediaItemArray[count]~=nil do
    if reaper.ValidatePtr(MediaItemArray[count],"MediaItem*")==true then
      retval, MediaItemStateChunkArray[count2] = reaper.GetItemStateChunk(MediaItemArray[count], "", true)
      count2=count2+1
    end
    count=count+1
  end
  return count2-1, MediaItemStateChunkArray
end

function ultraschall.GetSelectedMediaItemsAtPosition(position, trackstring)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetSelectedMediaItemsAtPosition</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer count, array MediaItemArray = ultraschall.GetSelectedMediaItemsAtPosition(number position, string trackstring)</functioncall>
  <description>
    Returns all selected items at position in the tracks as given by trackstring, as MediaItemArray. Empty MediaItemAray if none is found.
    
    returns -1 in case of error
  </description>
  <parameters>
    number position - position in seconds
    string trackstring - the tracknumbers, separated by commas
  </parameters>
  <retvals>
    integer count - the number of entries in the returned MediaItemArray
    array MediaItemArray - the found MediaItems returned as an array
  </retvals>
  <chapter_context>
    MediaItem Management
    Selected Items
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, get, selected, selection</tags>
</US_DocBloc>
]]
  if type(position)~="number" then ultraschall.AddErrorMessage("GetSelectedMediaItemsAtPosition", "position", "must be a number", -1) return -1 end
  local retval, trackstring, trackstringarray, number_of_entries = ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if retval==-1 then ultraschall.AddErrorMessage("GetSelectedMediaItemsAtPosition", "trackstring", "not a valid value. Must be a string with numbers,separated by commas, e.g. \"1,2,4,6,8\"", -2) return -1 end
  local Number_of_items, MediaItemArray, MediaItemStateChunkArray = ultraschall.GetMediaItemsAtPosition(position, trackstring)
  if Number_of_items==-1 then ultraschall.AddErrorMessage("GetSelectedMediaItemsAtPosition", "trackstring", "not a valid value. Must be a string with numbers,separated by commas, e.g. \"1,2,4,6,8\"", -3) return -1 end
  local SelectedMediaItemArray={}
  local count=0
  for i=1,Number_of_items do
    if reaper.GetMediaItemInfo_Value(MediaItemArray[i], "B_UISEL")==1 then 
      count=count+1 
      SelectedMediaItemArray[count]=MediaItemArray[i] 
    end
  end
  return count, SelectedMediaItemArray
end

function ultraschall.GetSelectedMediaItemsBetween(startposition, endposition, trackstring, inside)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetSelectedMediaItemsBetween</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer count, array MediaItemArray = ultraschall.GetSelectedMediaItemsBetween(number startposition, number endposition, string trackstring, boolean inside)</functioncall>
  <description>
    Returns all selected items between startposition and endposition in the tracks as given by trackstring, as MediaItemArray. Empty MediaItemAray if none is found.
    
    returns -1 in case of error
  </description>
  <parameters>
    number startposition - startposition in seconds
    number endposition - endposition in seconds
    string trackstring - the tracknumbers, separated by commas
    boolean inside - true, only items completely within start/endposition; false, also items, that are partially within start/endposition
  </parameters>
  <retvals>
    integer count - the number of entries in the returned MediaItemArray
    array MediaItemArray - the found MediaItems returned as an array
  </retvals>
  <chapter_context>
    MediaItem Management
    Selected Items
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, get, selected, selection, startposition, endposition</tags>
</US_DocBloc>
]]
  if type(inside)~="boolean" then ultraschall.AddErrorMessage("GetSelectedMediaItemsBetween", "inside", "must be either true or false", -1) return -1 end
  if type(startposition)~="number" then ultraschall.AddErrorMessage("GetSelectedMediaItemsBetween", "startposition", "must be a number", -2) return -1 end
  if type(endposition)~="number" then ultraschall.AddErrorMessage("GetSelectedMediaItemsBetween", "endposition", "must be a number", -3) return -1 end
  local retval, trackstring, trackstringarray, number_of_entries = ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if retval==-1 then ultraschall.AddErrorMessage("GetSelectedMediaItemsBetween", "trackstring", "not a valid value. Must be a string with numbers,separated by commas, e.g. \"1,2,4,6,8\"", -4) return -1 end
  local Number_of_items, MediaItemArray, MediaItemStateChunkArray = ultraschall.GetAllMediaItemsBetween(startposition, endposition, trackstring, inside)
  if Number_of_items==-1 then ultraschall.AddErrorMessage("GetSelectedMediaItemsBetween", "trackstring", "not a valid value. Must be a string with numbers,separated by commas, e.g. \"1,2,4,6,8\"", -5) return -1 end
  local SelectedMediaItemArray={}
  local count=0
  for i=1,Number_of_items do
    if reaper.GetMediaItemInfo_Value(MediaItemArray[i], "B_UISEL")==1 then 
      count=count+1 
      SelectedMediaItemArray[count]=MediaItemArray[i] 
    end
  end
  return count, SelectedMediaItemArray
end


function ultraschall.DeselectMediaItems_MediaItemArray(MediaItemArray)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DeselectMediaItems_MediaItemArray</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval = ultraschall.DeselectMediaItems_MediaItemArray(array MediaItemArray)</functioncall>
  <description>
    Deselects all MediaItems, that are in MediaItemArray.
    
    returns -1 in case of error
  </description>
  <parameters>
    array MediaItemArray - an array with all the MediaItemObjects, that shall be deselected
  </parameters>
  <retvals>
    integer retval - -1 in case of error, 1 in case of success
  </retvals>
  <chapter_context>
    MediaItem Management
    Selected Items
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, selected, selection, deselect, unselect</tags>
</US_DocBloc>
]]
  if type(MediaItemArray)~="table" then ultraschall.AddErrorMessage("DeselectMediaItems_MediaItemArray", "MediaItemArray", "must be an array with MediaItem-objects", -1) return -1 end
  local count=1
  while MediaItemArray[count]~=nil do
    if reaper.ValidatePtr(MediaItemArray[count], "MediaItem*")==true then 
      reaper.SetMediaItemInfo_Value(MediaItemArray[count], "B_UISEL", 0)
    end
    count=count+1
  end
  return 1
end

function ultraschall.SelectMediaItems_MediaItemArray(MediaItemArray)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SelectMediaItems_MediaItemArray</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval = ultraschall.SelectMediaItems_MediaItemArray(array MediaItemArray)</functioncall>
  <description>
    Selects all MediaItems, that are in MediaItemArray.
    
    returns -1 in case of error
  </description>
  <parameters>
    array MediaItemArray - an array with all the MediaItemObjects, that shall be selected
  </parameters>
  <retvals>
    integer retval - -1 in case of error, 1 in case of success
  </retvals>
  <chapter_context>
    MediaItem Management
    Selected Items
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, selected, selection, select</tags>
</US_DocBloc>
]]
  if type(MediaItemArray)~="table" then ultraschall.AddErrorMessage("SelectMediaItems_MediaItemArray", "MediaItemArray", "must be an array with MediaItem-objects", -1) return -1 end
  local count=1
  while MediaItemArray[count]~=nil do
    if reaper.ValidatePtr(MediaItemArray[count], "MediaItem*")==true then 
      reaper.SetMediaItemInfo_Value(MediaItemArray[count], "B_UISEL", 1)
    end
    count=count+1
  end
  return 1
end


function ultraschall.EnumerateMediaItemsInTrack(tracknumber, idx)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>EnumerateMediaItemsInTrack</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    SWS=2.8.8
    Lua=5.3
  </requires>
  <functioncall>MediaItem item, integer itemcount, array MediaItemArray = ultraschall.EnumerateMediaItemsInTrack(integer tracknumber, integer itemnumber)</functioncall>
  <description>
    returns the itemnumberth MediaItemobject in track, the number of items in tracknumber and an array with all MediaItems from this track.
    returns -1 in case of error
  </description>
  <parameters>
    integer tracknumber - the tracknumber, from where you want to get the item
    integer itemnumber - the itemnumber within that track. 1 for the first, 2 for the second, etc
  </parameters>
  <retvals>
    MediaItem item - the Mediaitem, as requested by parameter itemnumber
    integer itemcount - the number of items in that track
    array MediaItemArray - an array with all MediaItems from this track
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItems
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, track, get, item, mediaitem</tags>
</US_DocBloc>
]]

  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("EnumerateMediaItemsInTrack","tracknumber", "must be an integer", -1) return -1 end
  if math.type(idx)~="integer" then ultraschall.AddErrorMessage("EnumerateMediaItemsInTrack","idx", "must be an integer", -2) return -1 end
  if tracknumber<1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("EnumerateMediaItemsInTrack","tracknumber", "no such tracknumber", -3) return -1 end
  if idx<0 then ultraschall.AddErrorMessage("EnumerateMediaItemsInTrack","idx", "must be bigger than or equal 0", -4) return -1 end
  local count=1
  local MediaTrack=reaper.GetTrack(0,tracknumber-1)
  local MediaItemArray={}
  local MediaItem=""
  local retval, str = ultraschall.GetTrackStateChunk(MediaTrack, "", true)
  str=str:match("<ITEM.*")
  
  if str==nil then ultraschall.AddErrorMessage("EnumerateMediaItemsInTrack","tracknumber", "No item in track", -5) return -1 end 
  
  while str:match(".-%cIGUID.-")~= nil do
    local GUID=str:match(".-%cIGUID ({.-})%c")
    MediaItemArray[count]=reaper.BR_GetMediaItemByGUID(0, GUID)
    str=str:match(".-%cIGUID.-%c(.*)")
    if count==idx then MediaItem=reaper.BR_GetMediaItemByGUID(0, GUID) end
      count=count+1
    end
  return MediaItem, count-1, MediaItemArray
end

--A,B,C,D,E=ultraschall.EnumerateMediaItemsInTrack(1, 1000)




function ultraschall.GetMediaItemArrayLength(MediaItemArray)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetMediaItemArrayLength</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer start, integer end, integer length = ultraschall.GetMediaItemArrayLength(array MediaItemArray)</functioncall>
  <description>
    Returns the beginning of the first item, the end of the last item as well as the length between start and end of all items within the MediaItemArray.
    Will return -1, in case of error
  </description>
  <parameters>
    array MediaItemArray - an array with MediaItems, as returned by functions like <a href="#GetAllMediaItemsBetween">GetAllMediaItemsBetween</a> or <a href="#GetMediaItemsAtPosition">GetMediaItemsAtPosition</a> or similar.
  </parameters>
  <retvals>
    integer start - the beginning of the earliest item in the MediaItemArray in seconds
    integer end - the end of the latest item in the MediaItemArray, timewise, in seconds
    integer length - the length of the MediaItemArray in seconds
  </retvals>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>itemmanagement,count,length,items,end,mediaitem,item</tags>
</US_DocBloc>
]]
  local retval, count, retMediaItemArray = ultraschall.CheckMediaItemArray(MediaItemArray)
  if retval==false then ultraschall.AddErrorMessage("GetMediaItemArrayLength", "MediaItemArray", "no valid MediaItemArray", -1) return -1 end  local start=reaper.GetMediaItemInfo_Value(retMediaItemArray[1], "D_POSITION")
  local endof=reaper.GetMediaItemInfo_Value(retMediaItemArray[1], "D_POSITION")+reaper.GetMediaItemInfo_Value(retMediaItemArray[1], "D_LENGTH")
  local delta=0
  for i=1, count do
    local tempstart=reaper.GetMediaItemInfo_Value(retMediaItemArray[1], "D_POSITION")
    local tempendof=reaper.GetMediaItemInfo_Value(retMediaItemArray[1], "D_POSITION")+reaper.GetMediaItemInfo_Value(retMediaItemArray[1], "D_LENGTH")
    if tempstart<start then start=tempstart end
    if tempendof>endof then endof=tempendof end
  end
  delta=endof-start
  return start, endof, delta
end


function ultraschall.GetMediaItemStateChunkArrayLength(MediaItemStateChunkArray)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetMediaItemStateChunkArrayLength</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer start, integer end, integer length = ultraschall.GetMediaItemStateChunkArrayLength(array MediaItemStateChunkArray)</functioncall>
  <description>
    Returns the beginning of the first item, the end of the last item as well as the length between start and end of all items within the MediaItemStateChunkArray.
    Will return -1, in case of error
  </description>
  <parameters>
    array MediaItemStateChunkArray - an array with MediaItemStateChunks, as returned by functions like <a href="#GetAllMediaItemsBetween">GetAllMediaItemsBetween</a> or <a href="#GetMediaItemsAtPosition">GetMediaItemsAtPosition</a> or similar.
  </parameters>
  <retvals>
    integer start - the beginning of the earliest item in the MediaItemArray in seconds
    integer end - the end of the latest item in the MediaItemArray, timewise, in seconds
    integer length - the length of the MediaItemArray in seconds
  </retvals>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>itemmanagement,count,length,items,end, mediaitem, statechunk,item</tags>
</US_DocBloc>
]]
  local retval, count, retMediaItemArray = ultraschall.CheckMediaItemStateChunkArray(MediaItemStateChunkArray)
  if retval==false then ultraschall.AddErrorMessage("GetMediaItemStateChunkArrayLength", "MediaItemStateChunkArray", "no valid MediaItemStateChunkArray", -1) return -1 end
  start=retMediaItemArray[1]:match("POSITION (.-)%c")
  endof=retMediaItemArray[1]:match("POSITION (.-)%c")+retMediaItemArray[1]:match("LENGTH (.-)%c")
  local delta=0
  for i=1, count do
    local tempstart=retMediaItemArray[1]:match("POSITION (.-)%c")
    local tempendof=retMediaItemArray[1]:match("POSITION (.-)%c")+retMediaItemArray[1]:match("LENGTH (.-)%c")
    if tempstart<start then start=tempstart end
    if tempendof>endof then endof=tempendof end
  end
  delta=endof-start
  return tonumber(start), tonumber(endof), tonumber(delta)
  --]]
end


function ultraschall.GetAllMediaItemGUIDs()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllMediaItemGUIDs</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>table GUID_Array, integer count_of_GUID = ultraschall.GetAllMediaItemGUIDs()</functioncall>
  <description>
    Returns an array with all MediaItem-GUIDs in order of the MediaItems-count(1 for first MediaItem, etc).
    
    Returns nil in case of an error
  </description>
  <parameters>
    table GUID_Array - an array with all GUIDs of all MediaItems
    integer count_of_GUID - the number of GUIDs(from MediaItems) in the GUID_Array
  </parameters>
  <retvals>
    table diff_array - an array with all entries from CompareArray2, that are not in Array
  </retvals>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, get, guid, mediaitem, item</tags>
</US_DocBloc>
--]]
  local GUID_Array={}
  for i=0, reaper.CountMediaItems(0)-1 do
    local item=reaper.GetMediaItem(0,i)
    GUID_Array[i+1] = reaper.BR_GetMediaItemGUID(item)
  end
  return GUID_Array, reaper.CountMediaItems(0)
end

--C1,C2=ultraschall.GetAllMediaItemGUIDs()


function ultraschall.GetItemSpectralConfig(itemidx, MediaItemStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemSpectralConfig</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer item_spectral_config = ultraschall.GetItemSpectralConfig(integer itemidx, optional string MediaItemStateChunk)</functioncall>
  <description>
    returns the item-spectral-config, which is the fft-size of the spectral view for this item.
    set itemidx to -1 to use the optional parameter MediaItemStateChunk to alter a MediaItemStateChunk instead of an item directly.
    
    returns -1 in case of error or if no spectral-config exists(e.g. when no spectral-edit is applied to this item)
  </description>
  <parameters>
    integer itemidx - the number of the item, with 1 for the first item, 2 for the second, etc.; -1, to use the parameter MediaItemStateChunk
    optional string MediaItemStateChunk - you can give a MediaItemStateChunk to process, if itemidx is set to -1
  </parameters>
  <retvals>
    integer item_spectral_config - the fft-size in points for the spectral-view; 16, 32, 64, 128, 256, 512, 1024(default), 2048, 4096, 8192; -1, if not existing
  </retvals>
  <chapter_context>
    MediaItem Management
    Spectral Edit
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, get, item, spectral edit, fft, size</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(itemidx)~="integer" then ultraschall.AddErrorMessage("GetItemSpectralConfig","itemidx", "only integer allowed", -1) return -1 end
  if itemidx~=-1 and itemidx<1 or itemidx>reaper.CountMediaItems(0) then ultraschall.AddErrorMessage("GetItemSpectralConfig","itemidx", "no such item exists", -2) return -1 end
  if itemidx==-1 and tostring(MediaItemStateChunk):match("<ITEM.*>")==nil then ultraschall.AddErrorMessage("GetItemSpectralConfig","MediaItemStateChunk", "must be a valid MediaItemStateChunk", -5) return false end

  -- get statechunk, if necessary(itemidx~=-1)
  local _retval
  if itemidx~=-1 then 
    local MediaItem=reaper.GetMediaItem(0,itemidx-1)
    _retval, MediaItemStateChunk=reaper.GetItemStateChunk(MediaItem,"",false)
  end
  
  -- get the value of SPECTRAL_CONFIG and return it
  local retval=MediaItemStateChunk:match("SPECTRAL_CONFIG (.-)%c")
  if retval==nil then ultraschall.AddErrorMessage("GetItemSpectralConfig","", "no spectral-edit-config available", -3) return nil end
  return tonumber(retval)
end



function ultraschall.SetItemSpectralConfig(itemidx, item_spectral_config, MediaItemStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetItemSpectralConfig</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string MediaItemStateChunk = ultraschall.SetItemSpectralConfig(integer itemidx, integer item_spectral_config, optional string MediaItemStateChunk)</functioncall>
  <description>
    sets the item-spectral-config, which is the fft-size of the spectral view for this item. 
    
    returns false in case of error or if no spectral-config exists(e.g. when no spectral-edit is applied to this item)
  </description>
  <parameters>
    integer itemidx - the number of the item, with 1 for the first item, 2 for the second, etc.; -1, if you want to use the optional parameter MediaItemStateChunk
    integer item_spectral_config - the fft-size in points for the spectral-view; 16, 32, 64, 128, 256, 512, 1024(default), 2048, 4096, 8192; nil, to remove it
                                 - nil will only remove it, when SPECTRAL_EDIT is removed from item first; returned statechunk will have it removed still
    optional string MediaItemStateChunk - a MediaItemStateChunk you want to have altered; works only, if itemdidx is set to -1, otherwise it will be ignored
  </parameters>
  <retvals>
    boolean retval - true, if setting spectral-config worked; false, if not
    string MediaItemStateChunk - the altered MediaItemStateChunk
  </retvals>
  <chapter_context>
    MediaItem Management
    Spectral Edit
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, set, item, spectral edit, fft, size</tags>
</US_DocBloc>
--]]

  -- check parameters
  if math.type(itemidx)~="integer" then ultraschall.AddErrorMessage("SetItemSpectralConfig","itemidx", "only integer allowed", -1) return false end
  if itemidx~=-1 and (itemidx<1 or itemidx>reaper.CountMediaItems(0)) then ultraschall.AddErrorMessage("SetItemSpectralConfig","itemidx", "no such item exists", -2) return false end
  if math.type(item_spectral_config)~="integer" and item_spectral_config~=nil then ultraschall.AddErrorMessage("SetItemSpectralConfig","item_spectral_config", "only integer or nil allowed", -3) return false end
  if itemidx==-1 and tostring(MediaItemStateChunk):match("<ITEM.*>")==nil then ultraschall.AddErrorMessage("SetItemSpectralConfig","MediaItemStateChunk", "must be a valid MediaItemStateChunk", -5) return false end
  -- check for valid values, but seems not neccessary with Reaper...
  --  if item_spectral_config~=16 and item_spectral_config~=32 and item_spectral_config~=64 and item_spectral_config~=128 and item_spectral_config~=256 and 
  --     item_spectral_config~=512 and item_spectral_config~=1024 and item_spectral_config~=2048 and item_spectral_config~=4096 and item_spectral_config~=8192 and 
  --     item_spectral_config~=-1 then ultraschall.AddErrorMessage("SetItemSpectralConfig","item_spectral_config", "no valid value", -4) return -1 end
  
  -- get statechunk, if necessary(itemidx isn't set to -1)
  local MediaItem, _retval
  if itemidx~=-1 then 
    MediaItem=reaper.GetMediaItem(0,itemidx-1)
    _retval, MediaItemStateChunk=reaper.GetItemStateChunk(MediaItem,"",false)
  end
  
  -- check, if SPECTRAL_CONFIG exists at all
  local retval=MediaItemStateChunk:match("SPECTRAL_CONFIG (.-)%c")
  if retval==nil then ultraschall.AddErrorMessage("SetItemSpectralConfig","itemidx", "can't set, no spectral-config available.", -6)  return false end

  -- add or delete the Spectral-Config-setting
  if item_spectral_config~=nil then MediaItemStateChunk=MediaItemStateChunk:match("(.-)SPECTRAL_CONFIG").."SPECTRAL_CONFIG "..item_spectral_config..MediaItemStateChunk:match("SPECTRAL_CONFIG.-(%c.*)") end
  if item_spectral_config==nil then MediaItemStateChunk=MediaItemStateChunk:match("(.-)SPECTRAL_CONFIG")..MediaItemStateChunk:match("SPECTRAL_CONFIG.-%c(.*)") end
  
  -- set to item, if itemidx~=-1 and return values afterwards
  if itemidx~=-1 then reaper.SetItemStateChunk(MediaItem, MediaItemStateChunk, false) end
  return true, MediaItemStateChunk
end


function ultraschall.CountItemSpectralEdits(itemidx, MediaItemStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CountItemSpectralEdits</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.77
    Lua=5.3
  </requires>
  <functioncall>integer count = ultraschall.CountItemSpectralEdits(integer itemidx, optional string MediaItemStateChunk)</functioncall>
  <description>
    counts the number of SPECTRAL_EDITs in a given MediaItem/MediaItemStateChunk.
    The SPECTRAL_EDITs are the individual edit-boundary-boxes in the spectral-view.
    If itemidx is set to -1, you can give the function a MediaItemStateChunk to look in, instead.
    
    returns -1 in case of error
  </description>
  <parameters>
    integer itemidx - the MediaItem to look in for the spectral-edit; -1, to use the parameter MediaItemStateChunk instead
    optional string MediaItemStateChunk - if itemidx is -1, this can be a MediaItemStateChunk to use, otherwise this will be ignored
  </parameters>
  <retvals>
    integer count - the number of spectral-edits available in a given MediaItem/MediaItemStateChunk
  </retvals>
  <chapter_context>
    MediaItem Management
    Spectral Edit
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, count, item, spectral edit</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(itemidx)~="integer" then ultraschall.AddErrorMessage("CountItemSpectralEdits","itemidx", "only integer allowed", -1) return -1 end
  if itemidx~=-1 and itemidx<1 or itemidx>reaper.CountMediaItems(0) then ultraschall.AddErrorMessage("CountItemSpectralEdits","itemidx", "no such item exists", -2) return -1 end
  if itemidx==-1 and tostring(MediaItemStateChunk):match("<ITEM.*>")==nil then ultraschall.AddErrorMessage("CountItemSpectralEdits","MediaItemStateChunk", "must be a valid MediaItemStateChunk", -5) return -1 end

  -- get statechunk, if necessary(itemidx~=-1)
  local _retval, MediaItem
  if itemidx~=-1 then 
    MediaItem=reaper.GetMediaItem(0,itemidx-1)
    _retval, MediaItemStateChunk=reaper.GetItemStateChunk(MediaItem,"",false)
  end
  
  local offset=0
  local counter=0
  local match=""
  while MediaItemStateChunk:match("SPECTRAL_EDIT", offset)~= nil do
    match, offset=MediaItemStateChunk:match("(SPECTRAL_EDIT)()", offset+1)
    if match~=nil then counter=counter+1 end
  end
  return counter
end



function ultraschall.GetItemSpectralEdit(itemidx, spectralidx, MediaItemStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemSpectralEdit</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.77
    Lua=5.3
  </requires>
  <functioncall>number start_pos, number end_pos, number gain, number fade, number freq_fade, number freq_range_bottom, number freq_range_top, integer h, integer byp_solo, number gate_thres, number gate_floor, number comp_thresh, number comp_exp_ratio, number n, number o, number fade2, number freq_fade2 = ultraschall.GetItemSpectralEdit(integer itemidx, integer spectralidx, optional string MediaItemStateChunk)</functioncall>
  <description>
    returns the settings of a specific SPECTRAL_EDIT in a given MediaItem/MediaItemStateChunk.
    The SPECTRAL_EDITs are the individual edit-boundary-boxes in the spectral-view.
    If itemidx is set to -1, you can give the function a MediaItemStateChunk to look in, instead.
    
    returns -1 in case of error
  </description>
  <parameters>
    integer itemidx - the MediaItem to look in for the spectral-edit; -1, to use the parameter MediaItemStateChunk instead
    integer spectralidx - the number of the spectral-edit to return; 1 for the first, 2 for the second, etc
    optional string MediaItemStateChunk - if itemidx is -1, this can be a MediaItemStateChunk to use, otherwise this will be ignored
  </parameters>
  <retvals>
    number start_pos - the startposition of the spectral-edit-region in seconds
    number end_pos - the endposition of the spectral-edit-region in seconds
    number gain - the gain as slider-value; 0(-224dB) to 98350.1875(99.68dB); 1 for 0dB
    number fade - 0(0%)-0.5(100%); adjusting this affects also parameter fade2!
    number freq_fade - 0(0%)-0.5(100%); adjusting this affects also parameter freq_fade2!
    number freq_range_bottom - the bottom of the edit-region, but can be moved to be top as well! 0 to device-samplerate/2 (e.g 96000 for 192kHz)
    number freq_range_top - the top of the edit-region, but can be moved to be bottom as well! 0 to device-samplerate/2 (e.g 96000 for 192kHz)
    integer h - unknown
    integer byp_solo - sets the solo and bypass-state. 0, no solo, no bypass; 1, bypass only; 2, solo only; 3, bypass and solo
    number gate_thres - sets the threshold of the gate; 0(-224dB)-98786.226563(99.89dB)
    number gate_floor - sets the floor of the gate; 0(-224dB)-99802.171875(99.98dB)
    number comp_thresh - sets the threshold for the compressor; 0(-224dB)-98842.484375(99.90dB); 1(0dB)is default
    number comp_exp_ratio - sets the ratio of the compressor/expander; 0.1(1:10.0)-100(100:1.0); 1(1.0:1) is default
    number n - unknown
    number o - unknown
    number fade2 - negative with fade_in set; positive with fadeout-set
    number freq_fade2 - negative with low frequency-fade, positive with high-frequency-fade
  </retvals>
  <chapter_context>
    MediaItem Management
    Spectral Edit
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, get, item, spectral edit</tags>
</US_DocBloc>
--]]

  -- check parameters
  if math.type(itemidx)~="integer" then ultraschall.AddErrorMessage("GetItemSpectralEdit","itemidx", "only integer allowed", -1) return -1 end
  if itemidx~=-1 and itemidx<1 or itemidx>reaper.CountMediaItems(0) then ultraschall.AddErrorMessage("GetItemSpectralEdit","itemidx", "no such item exists", -2) return -1 end
  if itemidx==-1 and tostring(MediaItemStateChunk):match("<ITEM.*>")==nil then ultraschall.AddErrorMessage("GetItemSpectralEdit","MediaItemStateChunk", "must be a valid MediaItemStateChunk", -3) return -1 end

  if math.type(spectralidx)~="integer" then ultraschall.AddErrorMessage("GetItemSpectralEdit","spectralidx", "only integer allowed", -4) return -1 end
  if spectralidx<1 or spectralidx>ultraschall.CountItemSpectralEdits(itemidx, MediaItemStateChunk) then ultraschall.AddErrorMessage("GetItemSpectralEdit","spectralidx", "no such spectral-edit available, must be between 1 and maximum count of spectral-edits.", -5) return -1 end

  -- get statechunk, if necessary(itemidx~=-1)
  local _retval, MediaItem
  if itemidx~=-1 then 
    MediaItem=reaper.GetMediaItem(0,itemidx-1)
    _retval, MediaItemStateChunk=reaper.GetItemStateChunk(MediaItem,"",false)
  end
  
  -- prepare variables
  local offset=0
  local counter=-1
  local found=""
  local match=""
  
  -- look for the spectralidx-th entry
  while MediaItemStateChunk:match("SPECTRAL_EDIT", offset+1)~= nil do
    offset, match=MediaItemStateChunk:match("()(SPECTRAL_EDIT)", offset+1)
    if match~=nil then counter=counter+1 end
    if counter==spectralidx-1 then found=MediaItemStateChunk:match("(SPECTRAL_EDIT.-%c)", offset) end
  end
  
  -- convert to numbers and return
  local L1,L2,L3,L4,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15,L16,L17 = found:match("SPECTRAL_EDIT (.-) (.-) (.-) (.-) (.-) (.-) (.-) (.-) (.-) (.-) (.-) (.-) (.-) (.-) (.-) (.-) (.-)%c")
  return tonumber(L1), tonumber(L2), tonumber(L3), tonumber(L4), tonumber(L5), tonumber(L6), tonumber(L7), tonumber(L8), tonumber(L9), tonumber(L10), 
         tonumber(L11), tonumber(L12), tonumber(L13), tonumber(L14), tonumber(L15), tonumber(L16), tonumber(L17)
end

--L,L2,L3,L4,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15,L16,L17=ultraschall.GetItemSpectralEdit(1, 4, MediaItemStateChunk)



function ultraschall.DeleteItemSpectralEdit(itemidx, spectralidx, MediaItemStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DeleteItemSpectralEdit</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.77
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string MediaItemStateChunk = ultraschall.DeleteItemSpectralEdit(integer itemidx, integer spectralidx, optional string MediaItemStateChunk)</functioncall>
  <description>
    deletes a specific SPECTRAL_EDIT in a given MediaItem/MediaItemStateChunk.
    The SPECTRAL_EDITs are the individual edit-boundary-boxes in the spectral-view.
    If itemidx is set to -1, you can give the function a MediaItemStateChunk to look in, instead.
    
    returns false in case of error
  </description>
  <parameters>
    integer itemidx - the MediaItem to look in for the spectral-edit; -1, to use the parameter MediaItemStateChunk instead
    integer spectralidx - the number of the spectral-edit to delete; 1 for the first, 2 for the second, etc
    optional string MediaItemStateChunk - if itemidx is -1, this can be a MediaItemStateChunk to use, otherwise this will be ignored
  </parameters>
  <retvals>
    boolean retval - true, if deleting an spectral-edit-entry was successful; false, if it was unsuccessful
    string MediaItemStateChunk - the altered MediaItemStateChunk
  </retvals>
  <chapter_context>
    MediaItem Management
    Spectral Edit
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, delete, item, spectral edit</tags>
</US_DocBloc>
--]]

  -- check parameters
  if math.type(itemidx)~="integer" then ultraschall.AddErrorMessage("DeleteItemSpectralEdit","itemidx", "only integer allowed", -1) return false end
  if itemidx~=-1 and itemidx<1 or itemidx>reaper.CountMediaItems(0) then ultraschall.AddErrorMessage("DeleteItemSpectralEdit","itemidx", "no such item exists", -2) return false end
  if itemidx==-1 and tostring(MediaItemStateChunk):match("<ITEM.*>")==nil then ultraschall.AddErrorMessage("DeleteItemSpectralEdit","MediaItemStateChunk", "must be a valid MediaItemStateChunk", -3) return false end

  if math.type(spectralidx)~="integer" then ultraschall.AddErrorMessage("DeleteItemSpectralEdit","spectralidx", "only integer allowed", -4) return false end
  if spectralidx<1 or spectralidx>ultraschall.CountItemSpectralEdits(itemidx, MediaItemStateChunk) then ultraschall.AddErrorMessage("DeleteItemSpectralEdit","spectralidx", "no such spectral-edit available, must be between 1 and maximum count of spectral-edits.", -5) return false end

  -- get statechunk, if necessary(itemidx~=-1)
  local _retval, MediaItem
  if itemidx~=-1 then 
    MediaItem=reaper.GetMediaItem(0,itemidx-1)
    _retval, MediaItemStateChunk=reaper.GetItemStateChunk(MediaItem,"",false)
  end
  
  -- prepare variables
  local offset=0
  local counter=-1
  local found=""
  local match=""
  local offset2=0
  
  -- look for the spectralidx-th entry
  while MediaItemStateChunk:match("SPECTRAL_EDIT", offset+1)~= nil do
    offset, match, offset2 = MediaItemStateChunk:match("()(SPECTRAL_EDIT.-)%c()", offset+1)
--    reaper.MB(match, offset.." "..offset2,0)
    if match~=nil then counter=counter+1 end
    if counter==spectralidx-1 then found=MediaItemStateChunk:sub(1,offset-1)..MediaItemStateChunk:match("SPECTRAL_EDIT.-%c(.*)", offset) end
  end
  
  -- set to MediaItem(if itemidx==-1) and after that return the altered statechunk
  if itemidx~=-1 then reaper.SetItemStateChunk(MediaItem, found, false) end
  return true, found
end

--L,LL=ultraschall.DeleteItemSpectralEdit(1, 1, "")
--reaper.MB(LL,"",0)

function ultraschall.SetItemSpectralVisibilityState(item, state, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetItemSpectralVisibilityState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string MediaItemStateChunk = ultraschall.SetItemSpectralVisibilityState(integer itemidx, integer state, optional string MediaItemStateChunk)</functioncall>
  <description>
    Sets SPECTROGRAM-state in a MediaItem or MediaItemStateChunk.
    Setting it shows the spectrogram, in which you can do spectral-editing, as selected in the MediaItem-menu "Spectral-editing -> Toggle show spectrogram for selected items"
    
    It returns the modified MediaItemStateChunk.
    Returns -1 in case of error.
  </description>
  <parameters>
    integer itemidx - the number of the item in the project; use -1 to use MediaItemStateChunk instead
    integer state - the state of the SPECTROGRAM; 0, to hide SpectralEdit; 1, to set SpectralEdit visible
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk; only read, when itemidx=-1
  </parameters>
  <retvals>
    string MediaItemStateChunk - the altered rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </retvals>
  <chapter_context>
    MediaItem Management
    Spectral Edit
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, spectrogram, set</tags>
</US_DocBloc>
]]
  if math.type(item)~="integer" then ultraschall.AddErrorMessage("SetItemSpectralVisibilityState", "item", "Must be an integer; -1, to use trackstatechunk.", -1) return -1 end
  if item~=-1 and reaper.ValidatePtr2(0, reaper.GetMediaItem(0,item-1), "MediaItem*")==false then ultraschall.AddErrorMessage("SetItemSpectralVisibilityState", "item", "Must be a valid MediaItem-idx or -1, when using ItemStateChunk).", -2) return -1 end
  if type(statechunk)~="string" and item==-1 then ultraschall.AddErrorMessage("SetItemSpectralVisibilityState", "statechunk", "Must be a string", -3) return -1 end
  if item==-1 and ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("SetItemSpectralVisibilityState", "statechunk", "Must be a valid MediaItemStateChunk", -4) return -1 end
  local _bool, bool
  if item~=-1 then item=reaper.GetMediaItem(0,item-1) _bool, statechunk=reaper.GetItemStateChunk(item,"",false) end
  if math.type(state)~="integer" then ultraschall.AddErrorMessage("SetItemSpectralVisibilityState", "state", "Must be an integer", -5) return -1 end
  if state~=0 and state~=1 then ultraschall.AddErrorMessage("SetItemSpectralVisibilityState", "state", "Must be 1 or 0", -6) return -1 end
  
  if statechunk:match("SPECTROGRAM")~=nil and state==0 then 
    statechunk,temp=statechunk:match("(.-)SPECTROGRAM .-%c(.*)")
    statechunk=statechunk..temp
  elseif statechunk:match("SPECTROGRAM")==nil and state==1 then 
    statechunk, temp=statechunk:match("(.-IID.-%c).-(NAME.*)")
    statechunk=statechunk.."SPECTROGRAM 1\n"..temp
  end
  if item~=-1 then reaper.SetItemStateChunk(item,statechunk,true) end
  return statechunk
end


function ultraschall.SetItemSpectralEdit(itemidx, spectralidx, start_pos, end_pos, gain, fade, freq_fade, freq_range_bottom, freq_range_top, h, byp_solo, gate_thres, gate_floor, comp_thresh, comp_exp_ratio, n, o, fade2, freq_fade2, statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetItemSpectralEdit</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string MediaItemStateChunk = ultraschall.SetItemSpectralEdit(integer itemidx, integer spectralidx, number start_pos, number end_pos, number gain, number fade, number freq_fade, number freq_range_bottom, number freq_range_top, integer h, integer byp_solo, number gate_thres, number gate_floor, number comp_thresh, number comp_exp_ratio, number n, number o, number fade2, number freq_fade2, optional string MediaItemStateChunk)</functioncall>
  <description>
    Sets a spectral-edit-instance in a MediaItem or MediaItemStateChunk.
    
    After committing the changed MediaItemStateChunk to a MediaItem, Reaper may change the order of the spectral-edits! Keep that in mind, when changing numerous Spectral-Edits or use MediaItemStateChunks for the setting before committing them to a MediaItem using Reaper's function reaper.SetItemStateChunk().
    
    It returns the modified MediaItemStateChunk.
    Returns -1 in case of error.
  </description>
  <parameters>
    integer itemidx - the number of the item in the project; use -1 to use MediaItemStateChunk instead
    integer spectralidx - the number of the spectral-edit-instance, that you want to set
    number start_pos - the startposition of the spectral-edit-region in seconds
    number end_pos - the endposition of the spectral-edit-region in seconds
    number gain - the gain as slider-value; 0(-224dB) to 98350.1875(99.68dB); 1 for 0dB
    number fade - 0(0%)-0.5(100%); adjusting this affects also parameter fade2!
    number freq_fade - 0(0%)-0.5(100%); adjusting this affects also parameter freq_fade2!
    number freq_range_bottom - the bottom of the edit-region, but can be moved to be top as well! 0 to device-samplerate/2 (e.g 96000 for 192kHz)
    number freq_range_top - the top of the edit-region, but can be moved to be bottom as well! 0 to device-samplerate/2 (e.g 96000 for 192kHz)
    integer h - unknown
    integer byp_solo - sets the solo and bypass-state. 0, no solo, no bypass; 1, bypass only; 2, solo only; 3, bypass and solo
    number gate_thres - sets the threshold of the gate; 0(-224dB)-98786.226563(99.89dB)
    number gate_floor - sets the floor of the gate; 0(-224dB)-99802.171875(99.98dB)
    number comp_thresh - sets the threshold for the compressor; 0(-224dB)-98842.484375(99.90dB); 1(0dB)is default
    number comp_exp_ratio - sets the ratio of the compressor/expander; 0.1(1:10.0)-100(100:1.0); 1(1.0:1) is default
    number n - unknown
    number o - unknown
    number fade2 - negative with fade_in set; positive with fadeout-set
    number freq_fade2 - negative with low frequency-fade, positive with high-frequency-fade
    optional string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </parameters>
  <retvals>
    string MediaItemStateChunk - an rpp-xml-statechunk, as created by reaper-api-functions like GetItemStateChunk
  </retvals>
  <chapter_context>
    MediaItem Management
    Spectral Edit
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, rppxml, state, chunk, spectraledit, edit, set</tags>
</US_DocBloc>
]]
  if math.type(itemidx)~="integer" then ultraschall.AddErrorMessage("SetItemSpectralEdit", "itemidx", "Must be an integer; -1, to use trackstatechunk.", -1) return -1 end
  if itemidx~=-1 and reaper.ValidatePtr2(0, reaper.GetMediaItem(0,itemidx-1), "MediaItem*")==false then ultraschall.AddErrorMessage("SetItemSpectralEdit", "itemidx", "Must be a valid MediaItem-idx or -1, when using ItemStateChunk).", -2) return -1 end
  if type(statechunk)~="string" and itemidx==-1 then ultraschall.AddErrorMessage("SetItemSpectralEdit", "statechunk", "Must be a string", -3) return -1 end

  local _bool, item2, count
  item2=itemidx
  if itemidx~=-1 then itemidx=reaper.GetMediaItem(0,itemidx-1) _bool, statechunk=reaper.GetItemStateChunk(itemidx,"",false) end
  if math.type(spectralidx)~="integer" then ultraschall.AddErrorMessage("SetItemSpectralEdit", "spectralidx", "Must be an integer", -7) return -1 end
  if type(start_pos)~="number" then ultraschall.AddErrorMessage("SetItemSpectralEdit", "start_pos", "Must be a number", -8) return -1 end
  if type(end_pos)~="number" then ultraschall.AddErrorMessage("SetItemSpectralEdit", "end_pos", "Must be a number", -9) return -1 end
  if type(gain)~="number" then ultraschall.AddErrorMessage("SetItemSpectralEdit", "gain", "Must be a number", -10) return -1 end
  if type(fade)~="number" then ultraschall.AddErrorMessage("SetItemSpectralEdit", "fade", "Must be a number", -11) return -1 end
  if type(freq_fade)~="number" then ultraschall.AddErrorMessage("SetItemSpectralEdit", "freq_fade", "Must be a number", -12) return -1 end
  if type(freq_range_bottom)~="number" then ultraschall.AddErrorMessage("SetItemSpectralEdit", "freq_range_bottom", "Must be a number", -13) return -1 end
  if type(freq_range_top)~="number" then ultraschall.AddErrorMessage("SetItemSpectralEdit", "freq_range_top", "Must be a number", -14) return -1 end
  if math.type(h)~="integer" then ultraschall.AddErrorMessage("SetItemSpectralEdit", "h", "Must be an integer", -15) return -1 end
  if math.type(byp_solo)~="integer" then ultraschall.AddErrorMessage("SetItemSpectralEdit", "byp_solo", "Must be an integer", -16) return -1 end
  if type(gate_thres)~="number" then ultraschall.AddErrorMessage("SetItemSpectralEdit", "gate_thres", "Must be a number", -17) return -1 end
  if type(gate_floor)~="number" then ultraschall.AddErrorMessage("SetItemSpectralEdit", "gate_floor", "Must be a number", -18) return -1 end
  if type(comp_thresh)~="number" then ultraschall.AddErrorMessage("SetItemSpectralEdit", "comp_thresh", "Must be a number", -19) return -1 end
  if type(comp_exp_ratio)~="number" then ultraschall.AddErrorMessage("SetItemSpectralEdit", "comp_exp_ratio", "Must be a number", -20) return -1 end
  if type(n)~="number" then ultraschall.AddErrorMessage("SetItemSpectralEdit", "n", "Must be a number", -21) return -1 end
  if type(o)~="number" then ultraschall.AddErrorMessage("SetItemSpectralEdit", "o", "Must be a number", -22) return -1 end
  if type(fade2)~="number" then ultraschall.AddErrorMessage("SetItemSpectralEdit", "fade2", "Must be a number", -23) return -1 end
  if type(freq_fade2)~="number" then ultraschall.AddErrorMessage("SetItemSpectralEdit", "freq_fade2", "Must be a number", -24) return -1 end

  count = ultraschall.CountItemSpectralEdits(item2, statechunk)
  if spectralidx>count then ultraschall.AddErrorMessage("SetItemSpectralEdit", "spectralidx", "No such spectral edit available", -25) return -1 end
  
  local new_entry="SPECTRAL_EDIT "..start_pos.." "..end_pos.." "..gain.." "..fade.." "..freq_fade.." "..freq_range_bottom.." "..freq_range_top.." "..h.." "..byp_solo.." "..gate_thres.." "..gate_floor.." "..comp_thresh.." "..comp_exp_ratio.." "..n.." "..o.." "..fade2.." "..freq_fade2
  local part1, part2=statechunk:match("(.-)(SPECTRAL_EDIT.*)")
  
  for i=1, spectralidx-1 do
    part1=part1..part2:match("(SPECTRAL_EDIT.-%c)")
    part2=part2:match("SPECTRAL_EDIT.-%c(.*)")
  end

  statechunk=part1..new_entry.."\n"..part2:match("SPECTRAL_EDIT.-%c(.*)")
  
  if itemidx~=-1 then reaper.SetItemStateChunk(itemidx,statechunk,true) end
  return statechunk
end

function ultraschall.GetItemSourceFile_Take(MediaItem, take_nr)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemSourceFile_Take</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.77
    Lua=5.3
  </requires>
  <functioncall>string source_filename, PCM_source source, MediaItem_Take take = ultraschall.GetItemSourceFile_Take(MediaItem MediaItem, integer take_nr)</functioncall>
  <description>
    returns filename, the PCM_Source-object and the MediaItem_Take-object of a specific take. Use take_nr=0 for active take.
    
    returns nil in case of error
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem-object, in which the requested take lies
    integer take_nr - the number of the requested take; use 0 for the active take
  </parameters>
  <retvals>
    string source_filename - the filename of the requested take
    PCM_source source - the PCM_source-object of the requested take
    MediaItem_Take take - the Media-Item_Take-object of the requested take
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem-Takes
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, track, get, item, mediaitem, take, pcmsource, filename</tags>
</US_DocBloc>
--]]
  -- check parameters
  if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")~=true then ultraschall.AddErrorMessage("GetItemSourceFile_Take", "MediaItem", "must be a MediaItem-object", -1) return nil end
  if math.type(take_nr)~="integer" then ultraschall.AddErrorMessage("GetItemSourceFile_Take", "take_nr", "must be an integer; 0 for active take", -2) return nil end
  
  -- get correct MediaItem_Take-object
  local MediaItem_Take
  if take_nr>0 then MediaItem_Take = reaper.GetMediaItemTake(MediaItem, take_nr-1)
  elseif take_nr==0 then MediaItem_Take=reaper.GetActiveTake(MediaItem)
  end
  if MediaItem_Take==nil then ultraschall.AddErrorMessage("GetItemSourceFile_Take", "take_nr", "no such take", -3) return nil end  

  -- get the pcm-source, the source-filename and return it with the MediaItem_Take-object
  local PCM_source=reaper.GetMediaItemTake_Source(MediaItem_Take)
  local filenamebuf = reaper.GetMediaSourceFileName(PCM_source, "")
  
  return filenamebuf, PCM_source, MediaItem_Take
end

--MediaItem=reaper.GetMediaItem(0,1)
--A,A2,A3 = ultraschall.GetItemSourceFile_Take(MediaItem, -1)

function ultraschall.AddItemSpectralEdit(itemidx, start_pos, end_pos, gain, fade, freq_fade, freq_range_bottom, freq_range_top, h, byp_solo, gate_thres, gate_floor, comp_thresh, comp_exp_ratio, n, o, fade2, freq_fade2, MediaItemStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AddItemSpectralEdit</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.77
    Lua=5.3
  </requires>
  <functioncall>boolean retval, MediaItemStateChunk statechunk = ultraschall.AddItemSpectralEdit(integer itemidx, number start_pos, number end_pos, number gain, number fade, number freq_fade, number freq_range_bottom, number freq_range_top, integer h, integer byp_solo, number gate_thres, number gate_floor, number comp_thresh, number comp_exp_ratio, number n, number o, number fade2, number freq_fade2, optional string MediaItemStateChunk)</functioncall>
  <description>
    Adds a new SPECTRAL_EDIT-entry in a given MediaItem/MediaItemStateChunk.
    The SPECTRAL_EDITs are the individual edit-boundary-boxes in the spectral-view.
    If itemidx is set to -1, you can give the function a MediaItemStateChunk to look in, instead.
    
    returns false in case of error
  </description>
  <parameters>
    integer itemidx - the MediaItem to add to another spectral-edit-entry; -1, to use the parameter MediaItemStateChunk instead
    number start_pos - the startposition of the spectral-edit-region in seconds
    number end_pos - the endposition of the spectral-edit-region in seconds
    number gain - the gain as slider-value; 0(-224dB) to 98350.1875(99.68dB); 1 for 0dB
    number fade - 0(0%)-0.5(100%); adjusting this affects also parameter fade2!
    number freq_fade - 0(0%)-0.5(100%); adjusting this affects also parameter freq_fade2!
    number freq_range_bottom - the bottom of the edit-region, but can be moved to be top as well! 0 to device-samplerate/2 (e.g 96000 for 192kHz)
    number freq_range_top - the top of the edit-region, but can be moved to be bottom as well! 0 to device-samplerate/2 (e.g 96000 for 192kHz)
    integer h - unknown
    integer byp_solo - sets the solo and bypass-state. 0, no solo, no bypass; 1, bypass only; 2, solo only; 3, bypass and solo
    number gate_thres - sets the threshold of the gate; 0(-224dB)-98786.226563(99.89dB)
    number gate_floor - sets the floor of the gate; 0(-224dB)-99802.171875(99.98dB)
    number comp_thresh - sets the threshold for the compressor; 0(-224dB)-98842.484375(99.90dB); 1(0dB)is default
    number comp_exp_ratio - sets the ratio of the compressor/expander; 0.1(1:10.0)-100(100:1.0); 1(1.0:1) is default
    number n - unknown
    number o - unknown
    number fade2 - negative with fade_in set; positive with fadeout-set
    number freq_fade2 - negative with low frequency-fade, positive with high-frequency-fade
    string MediaItemStateChunk - if itemidx is -1, this can be a MediaItemStateChunk to use, otherwise this will be ignored
  </parameters>
  <retvals>
    boolean retval - true, if adding was successful; false, if adding wasn't successful
    optional MediaItemStateChunk statechunk - the altered MediaItemStateChunk
  </retvals>
  <chapter_context>
    MediaItem Management
    Spectral Edit
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, add, item, spectral edit</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(itemidx)~="integer" then ultraschall.AddErrorMessage("AddItemSpectralEdit", "itemidx", "must be an integer", -18) return false end
  if type(start_pos)~="number" then ultraschall.AddErrorMessage("AddItemSpectralEdit", "start_pos", "must be a number", -1) return false end
  if type(end_pos)~="number" then ultraschall.AddErrorMessage("AddItemSpectralEdit", "end_pos", "must be a number", -2) return false end
  if type(gain)~="number" then ultraschall.AddErrorMessage("AddItemSpectralEdit", "gain", "must be a number", -3) return false end
  if type(fade)~="number" then ultraschall.AddErrorMessage("AddItemSpectralEdit", "fade", "must be a number", -4) return false end
  if type(freq_fade)~="number" then ultraschall.AddErrorMessage("AddItemSpectralEdit", "freq_fade", "must be a number", -5) return false end
  if type(freq_range_bottom)~="number" then ultraschall.AddErrorMessage("AddItemSpectralEdit", "freq_range_bottom", "must be a number", -6) return false end
  if type(freq_range_top)~="number" then ultraschall.AddErrorMessage("AddItemSpectralEdit", "freq_range_top", "must be a number", -7) return false end
  if math.type(h)~="integer" then ultraschall.AddErrorMessage("AddItemSpectralEdit", "h", "must be an integer", -8) return false end
  if math.type(byp_solo)~="integer" then ultraschall.AddErrorMessage("AddItemSpectralEdit", "byp_solo", "must be an integer", -9) return false end
  if type(gate_thres)~="number" then ultraschall.AddErrorMessage("AddItemSpectralEdit", "gate_thres", "must be a number", -10) return false end
  if type(gate_floor)~="number" then ultraschall.AddErrorMessage("AddItemSpectralEdit", "gate_floor", "must be a number", -11) return false end
  if type(comp_thresh)~="number" then ultraschall.AddErrorMessage("AddItemSpectralEdit", "comp_thresh", "must be a number", -12) return false end
  if type(comp_exp_ratio)~="number" then ultraschall.AddErrorMessage("AddItemSpectralEdit", "comp_exp_ratio", "must be a number", -13) return false end
  if type(n)~="number" then ultraschall.AddErrorMessage("AddItemSpectralEdit", "n", "must be a number", -14) return false end
  if type(o)~="number" then ultraschall.AddErrorMessage("AddItemSpectralEdit", "o", "must be a number", -15) return false end
  if type(fade2)~="number" then ultraschall.AddErrorMessage("AddItemSpectralEdit", "fade2", "must be a number", -16) return false end
  if type(freq_fade2)~="number" then ultraschall.AddErrorMessage("AddItemSpectralEdit", "freq_fade2", "must be a number", -17) return false end
  if itemidx==-1 and (type(MediaItemStateChunk)~="string" or MediaItemStateChunk:match("<ITEM.*>")==nil) then ultraschall.AddErrorMessage("AddItemSpectralEdit", "MediaItemStateChunk", "must be a MediaItemStateChunk", -19) return false end

  -- prepare variables
  local MediaItem, _l

  -- get MediaItemStateChunk, if necessary
  if itemidx~=-1 then 
    MediaItem=reaper.GetMediaItem(0,itemidx-1)
    _l, MediaItemStateChunk=reaper.GetItemStateChunk(MediaItem, "", false)
  end

  -- add new Spectral-Edit-entry
  MediaItemStateChunk=MediaItemStateChunk:match("(.*)>")..
                       "SPECTRAL_EDIT "..start_pos.." "..end_pos.." "..gain.." "..fade.." "..freq_fade.." "..freq_range_bottom.." "..freq_range_top.." "..h.." "..
                       byp_solo.." "..gate_thres.." "..gate_floor.." "..comp_thresh.." "..comp_exp_ratio.." "..n.." "..o.." "..fade2.." "..freq_fade2.."\n>"
                       
  -- add changed statechunk to the item, if necessary
  if itemidx~=-1 then reaper.SetItemStateChunk(MediaItem, MediaItemStateChunk, false) end
  return true, MediaItemStateChunk
end


--LL=ultraschall.AddItemSpectralEdit(1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9, "<ITEM>")

function ultraschall.GetItemSpectralVisibilityState(itemidx, MediaItemStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemSpectralVisibilityState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer spectrogram_state = ultraschall.GetItemSpectralVisibilityState(integer itemidx, optional string MediaItemStateChunk)</functioncall>
  <description>
    returns, if spectral-editing is shown in the arrange-view of item itemidx
    set itemidx to -1 to use the optional parameter MediaItemStateChunk to alter a MediaItemStateChunk instead of an item directly.
    
    returns -1 in case of error
  </description>
  <parameters>
    integer itemidx - the number of the item, with 1 for the first item, 2 for the second, etc.; -1, to use the parameter MediaItemStateChunk
    optional string MediaItemStateChunk - you can give a MediaItemStateChunk to process, if itemidx is set to -1
  </parameters>
  <retvals>
    integer item_spectral_config - 0, if spectral-config isn't shown in arrange-view; 1, if spectral-config is shown in arrange-view
  </retvals>
  <chapter_context>
    MediaItem Management
    Spectral Edit
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, get, item, spectral edit, spectogram, show</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(itemidx)~="integer" then ultraschall.AddErrorMessage("GetItemSpectralVisibilityState","itemidx", "only integer allowed", -1) return -1 end
  if itemidx~=-1 and itemidx<1 or itemidx>reaper.CountMediaItems(0) then ultraschall.AddErrorMessage("GetItemSpectralVisibilityState","itemidx", "no such item exists", -2) return -1 end
  if itemidx==-1 and tostring(MediaItemStateChunk):match("<ITEM.*>")==nil then ultraschall.AddErrorMessage("GetItemSpectralVisibilityState","MediaItemStateChunk", "must be a valid MediaItemStateChunk", -5) return false end

  -- get statechunk, if necessary(itemidx~=-1)
  local _retval
  if itemidx~=-1 then 
    local MediaItem=reaper.GetMediaItem(0,itemidx-1)
    _retval, MediaItemStateChunk=reaper.GetItemStateChunk(MediaItem,"",false)
  end
  
  -- get the value of SPECTROGRAM and return it
  local retval=MediaItemStateChunk:match("SPECTROGRAM (.-)%c")
  if retval==nil then retval=0 end
  return tonumber(retval)
end

--L=ultraschall.GetItemSpectralVisibilityState(-1, "<ITEM\nSPECTROGRAM 1\n>")

--L,LL,LLL=ultraschall.GetAllEntriesFromTable(ultraschall)



function ultraschall.InsertImageFile(filename_with_path, track, position, length, looped)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>InsertImageFile</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    SWS=2.9.7
    Lua=5.3
  </requires>
  <functioncall>boolean retval, MediaItem item = ultraschall.InsertImageFile(string filename_with_path, integer track, number position, number length, boolean looped)</functioncall>
  <description>
    Inserts a supported image-file into your project.
    Due API-limitations, it creates two undo-points(one for inserting the MediaItem and one for changing the length).
    
    Returns false in case of an error
  </description>
  <parameters>
    string filename_with_path - the file to check for it's image-fileformat
    integer track - the track, in which the image shall be inserted
    number position - the position of the inserted image in seconds
    number length - the length of the image-item in seconds; 1, for the default length of 1 second
    boolean looped - true, loop the inserted image-file; false, don't loop the inserted image-file
  </parameters>
  <retvals>
    boolean retval - true, if inserting was successful; false, if inserting was unsuccessful
    MediaItem item - the MediaItem of the newly inserted image
  </retvals>
  <chapter_context>
    MediaItem Management
    Insert
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>markermanagement, insert, mediaitem, position, mediafile, image, loop</tags>
</US_DocBloc>
--]]
  if filename_with_path==nil then ultraschall.AddErrorMessage("InsertImageFile","filename_with_path", "Must be a string!", -1) return false end
  if reaper.file_exists(filename_with_path)==false then ultraschall.AddErrorMessage("InsertImageFile","filename_with_path", "File does not exist!", -2) return false end
  if math.type(track)~="integer" then ultraschall.AddErrorMessage("InsertImageFile","track", "Must be an integer!", -3) return false end
  if track<1 then ultraschall.AddErrorMessage("InsertImageFile","track", "Must be bigger than 0!", -4) return false end
  if type(position)~="number" then ultraschall.AddErrorMessage("InsertImageFile","position", "Must be a number!", -5) return false end
  if position<0 then ultraschall.AddErrorMessage("InsertImageFile","position", "Must be bigger than/equal 0!", -6) return false end
  if type(length)~="number" then ultraschall.AddErrorMessage("InsertImageFile","length", "Must be a number!", -7) return false end
  if length<0 then ultraschall.AddErrorMessage("InsertImageFile","length", "Must be bigger than/equal 0!", -8) return false end
  if type(looped)~="boolean" then ultraschall.AddErrorMessage("InsertImageFile","looped", "Must be boolean!", -9) return false end
  
  local fileext, supported, filetype = ultraschall.CheckForValidFileFormats(filename_with_path)  
  if filetype~="Image" then ultraschall.AddErrorMessage("InsertImageFile","filename_with_path", "Not a supported image-file!", -10) return false end
  local retval, item, ollength, numchannels, Samplerate, Filetype = ultraschall.InsertMediaItemFromFile(filename_with_path, track, position, length, 0)
  
--  reaper.SetMediaItemInfo_Value(item, "D_LENGTH", length)
  if looped==true then reaper.SetMediaItemInfo_Value(item, "B_LOOPSRC", 1) end
  return true, item
end

--ultraschall.InsertImageFile("c:\\us.png", 3, 20, 100, false)


function ultraschall.GetAllSelectedMediaItems()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllSelectedMediaItems</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer count, array MediaItemArray = ultraschall.GetAllSelectedMediaItems()</functioncall>
  <description>
    Returns all selected items in the project as MediaItemArray. Empty MediaItemAray if none is found.
  </description>
  <retvals>
    integer count - the number of entries in the returned MediaItemArray
    array MediaItemArray - all selected MediaItems returned as an array
  </retvals>
  <chapter_context>
    MediaItem Management
    Selected Items
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, get, all, selected, selection</tags>
</US_DocBloc>
]]
  -- prepare variables
  local selitemcount=reaper.CountSelectedMediaItems(0)
  local selitemarray={}
  
  -- get all selected mediaitems and put them into the array
  for i=0, selitemcount-1 do
    selitemarray[i+1]=reaper.GetSelectedMediaItem(0, i)
  end
  return selitemcount, selitemarray
end

--A,B=ultraschall.GetAllSelectedMediaItems()

function ultraschall.SetMediaItemsSelected_TimeSelection()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetMediaItemsSelected_TimeSelection</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>ultraschall.SetMediaItemsSelected_TimeSelection()</functioncall>
  <description>
    Sets all MediaItems selected, that are within the time-selection.
  </description>
  <chapter_context>
    MediaItem Management
    Selected Items
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, set, selected, item, mediaitem, timeselection</tags>
</US_DocBloc>
]]
  reaper.Main_OnCommand(40717,0)
end

function ultraschall.GetParentTrack_MediaItem(MediaItem)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetParentTrack_MediaItem</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer tracknumber, MediaTrack mediatrack = ultraschall.GetParentTrack_MediaItem(MediaItem MediaItem)</functioncall>
  <description>
    Returns the tracknumber and the MediaTrack-object of the track in which the MediaItem is placed.
    
    returns -1 in case of error
  </description>
  <retvals>
    integer tracknumber - the tracknumber of the track, in which the MediaItem is placed; 1 for track 1, 2 for track 2, etc
    MediaTrack mediatrack - the MediaTrack-object of the track, in which the MediaItem is placed
  </retvals>
  <parameters>
    MediaItem MediaItem - the MediaItem, of which you want to know the track is is placed in
  </parameters>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, get, parent, track, item, mediaitem, mediatrack</tags>
</US_DocBloc>
]]
  if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==false then ultraschall.AddErrorMessage("GetParentTrack_MediaItem","MediaItem", "Must be a MediaItem!", -1) return -1 end
  
  local MediaTrack = reaper.GetMediaItemTake_Track(reaper.GetMediaItemTake(MediaItem,0))
  
  return reaper.GetMediaTrackInfo_Value(MediaTrack, "IP_TRACKNUMBER"), MediaTrack
end

--A,B=ultraschall.GetParentTrack_MediaItem(reaper.GetMediaItem(0,1))

function ultraschall.IsItemInTrack2(MediaItem, tracknumber)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsItemInTrack2</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, integer tracknumber = ultraschall.IsItemInTrack2(MediaItem MediaItem, integer tracknumber)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Checks, whether a MediaItem is in track with tracknumber.
    
    see [IsItemInTrack](#IsItemInTrack) to use itemidx instead of the MediaItem-object.
    see [IsItemInTrack3](#IsItemInTrack3) to check against multiple tracks at once using a trackstring.
    
    returns nil in case of error
  </description>
  <retvals>
    boolean retval - true, if item is in track; false, if not
    integer tracknumber - the tracknumber of the track, in which the item lies
  </retvals>
  <parameters>
    MediaItem MediaItem - the MediaItem, of which you want to know the track is is placed in
    integer tracknumber - the tracknumber to check the parent track of the MediaItem against, with 1 for track 1, etc
  </parameters>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helperfunctions, check, item, track</tags>
</US_DocBloc>
]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("IsItemInTrack2","tracknumber", "Must be an integer!", -1) return end
  if tracknumber<1 or tracknumber>reaper.CountTracks(0) then ultraschall.AddErrorMessage("IsItemInTrack2","tracknumber", "No such track!", -2) return end
  if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==false then ultraschall.AddErrorMessage("IsItemInTrack2","MediaItem", "Must be a MediaItem!", -3) return end
  
  -- prepare vaiable
  local itemtracknumber=ultraschall.GetParentTrack_MediaItem(MediaItem)
  
  -- check if item is in track
  if tracknumber==itemtracknumber then return true, itemtracknumber
  else return false, itemtracknumber
  end
end

--A,B=ultraschall.IsItemInTrack2(reaper.GetMediaItem(0,0),1)

function ultraschall.IsItemInTimerange(MediaItem, startposition, endposition, inside)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsItemInTimerange</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.IsItemInTimerange(MediaItem MediaItem, number startposiiton, number endposition, boolean inside)</functioncall>
  <description>
    checks, whether a given MediaItem is within startposition and endposition and returns the result.
    
    returns nil in case of an error
  </description>
  <retvals>
    boolean retval - true, item is in timerange; false, item isn't in timerange
  </retvals>
  <parameters>
    MediaItem MediaItem - the MediaItem to check for, if it's within the timerange
    number startposition - the starttime of the timerange, in which the MediaItem must be, in seconds
    number endposition - the endtime of the timerange, in which the MediaItem must be, in seconds
    boolean inside - true, MediaItem must be fully within timerange; false, MediaItem can be partially inside timerange
  </parameters>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, check, timerange, tracks, mediaitems</tags>
</US_DocBloc>
]]
  -- check parameters
  if type(startposition)~="number" then ultraschall.AddErrorMessage("IsItemInTimerange","startposition", "Must be a number!", -1) return end
  if type(endposition)~="number" then ultraschall.AddErrorMessage("IsItemInTimerange","endposition", "Must be a number!", -2) return end
  if type(inside)~="boolean" then ultraschall.AddErrorMessage("IsItemInTimerange","inside", "Must be a boolean!", -3) return end
  if startposition>endposition then ultraschall.AddErrorMessage("IsItemInTimerange","startposition", "Must be smaller or equal endposition!", -4) return end
  if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==false then ultraschall.AddErrorMessage("IsItemInTimerange","MediaItem", "Must be a MediaItem!", -5) return end  
  
  -- prepare variables
  local itemstartposition=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
  local itemendposition=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")+itemstartposition
  
  -- check, if the item is in tiumerange
  if inside==true then -- if fully within timerange
    if itemstartposition>=startposition and itemendposition<=endposition then return true else return false end
  else -- if also partially within timerange
    if itemstartposition>endposition or itemendposition<startposition then return false
    else return true
    end
  end
end


function ultraschall.OnlyItemsInTracksAndTimerange(MediaItemArray, trackstring, starttime, endtime, inside)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>OnlyItemsInTracksAndTimerange</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer count, MediaItemArray MediaItemArray = ultraschall.OnlyItemsInTracksAndTimerange(MediaItemArray MediaItemArray, string trackstring, number starttime, number endtime, boolean inside)</functioncall>
  <description>
    Removes all items from MediaItemArray, that aren't in tracks, as given by trackstring and are outside the timerange(starttime to endtime).
    
    returns -1 in case of an error
  </description>
  <retvals>
    integer count - the number of items that fit the requested tracks and timerange
    MediaItemArray MediaItemArray - the altered MediaItemArray, that has only the MediaItems from tracks as requested by trackstring and from within timerange
  </retvals>
  <parameters>
    MediaItemArray MediaItemArray - an array with all MediaItems, that shall be checked for trackexistence and timerange
    string trackstring - a string with all requested tracknumbers in which the MediaItem must be, separated by commas; 1 for track 1, 2 for track 2, etc
    number starttime - the starttime of the timerange, in which the MediaItem must be, in seconds
    number endtime - the endtime of the timerange, in which the MediaItem must be, in seconds
    boolean inside - true, only MediaItems are returned, that are fully within starttime and endtime; false, return also MediaItems partially in timerange
  </parameters>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, check, alter, timerange, tracks, mediaitem, mediaitemarray</tags>
</US_DocBloc>
]]
  -- check parameters
  if ultraschall.CheckMediaItemArray(MediaItemArray)==false then ultraschall.AddErrorMessage("OnlyItemsInTracksAndTimerange","MediaItemArray", "No valid MediaItemArray!", -1) return -1 end
  if ultraschall.IsValidTrackString(trackstring)==false then ultraschall.AddErrorMessage("OnlyItemsInTracksAndTimerange","trackstring", "No valid trackstring!", -2) return -1 end
  if type(starttime)~="number" then ultraschall.AddErrorMessage("OnlyItemsInTracksAndTimerange","starttime", "Must be a number!", -3) return -1 end
  if type(endtime)~="number" then ultraschall.AddErrorMessage("OnlyItemsInTracksAndTimerange","endtime", "Must be a number!", -4) return -1 end
  if type(inside)~="boolean" then ultraschall.AddErrorMessage("OnlyItemsInTracksAndTimerange","inside", "Must be a boolean!", -5) return -1 end
  
  -- prepare variables
  local count=1
  local count2=0
  local NewMediaItemArray={}
  
  -- check if the MediaItems are within tracks and timerange and put the "valid" ones into NewMediaItemArray
  while MediaItemArray[count]~=nil do
    if ultraschall.IsItemInTrack3(MediaItemArray[count], trackstring)==true 
      and ultraschall.IsItemInTimerange(MediaItemArray[count], starttime, endtime, inside)==true 
      then 
      count2=count2+1
      NewMediaItemArray[count2]=MediaItemArray[count]    
    end
    count=count+1
  end
  return count2, NewMediaItemArray
end



function ultraschall.ApplyActionToMediaItem(MediaItem, actioncommandid, repeat_action, midi, MIDI_hwnd)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ApplyActionToMediaItem</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.77
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ApplyActionToMediaItem(MediaItem MediaItem, string actioncommandid, integer repeat_action, boolean midi, optional HWND MIDI_hwnd)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Applies an action to a MediaItem, in either main or MIDI-Editor section-context.
    The action given must support applying itself to selected items.    
    
    Returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, if running the action was successful; false, if not or an error occured
  </retvals>
  <parameters>
    MediaItem MediaItem - the MediaItem, to whom the action shall be applied to
    string actioncommandid - the commandid-number or ActionCommandID, that shall be run.
    integer repeat_action - the number of times this action shall be applied to each item; minimum value is 1
    boolean midi - true, run an action from MIDI-Editor-section-context; false, run an action from the main section
    optional HWND MIDI_hwnd - the HWND-handle of the MIDI-Editor, to which a MIDI-action shall be applied to; nil, to use the currently selected one
  </parameters>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, run, action, midi, main, midieditor, item, mediaitem</tags>
</US_DocBloc>
]]
  -- check parameters
  if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==false then ultraschall.AddErrorMessage("ApplyActionToMediaItem","MediaItem", "Must be a MediaItem!", -1) return false end
  if ultraschall.CheckActionCommandIDFormat2(actioncommandid)==false then ultraschall.AddErrorMessage("ApplyActionToMediaItem","actioncommandid", "No such action registered!", -2) return false end
  if type(midi)~="boolean" then ultraschall.AddErrorMessage("ApplyActionToMediaItem","midi", "Must be boolean!", -3) return false end
  if math.type(repeat_action)~="integer" then ultraschall.AddErrorMessage("ApplyActionToMediaItem","repeat_action", "Must be an integer!", -4) return false end
  if repeat_action<1 then ultraschall.AddErrorMessage("ApplyActionToMediaItem","repeat_action", "Must be bigger than 0!", -5) return false end

  -- get old item-selection, delete item selection, select MediaItem
  reaper.PreventUIRefresh(1)
  local oldcount, oldselection = ultraschall.GetAllSelectedMediaItems()
  reaper.SelectAllMediaItems(0, false)
  reaper.SetMediaItemSelected(MediaItem, true)
  if type(actioncommandid)=="string" then actioncommandid=reaper.NamedCommandLookup(actioncommandid) end -- get command-id-number from named actioncommandid

  -- run the action for repeat_action-times
  for i=1, repeat_action do
    if midi==true then 
      reaper.MIDIEditor_OnCommand(MIDI_hwnd, actioncommandid)
    else
      reaper.Main_OnCommand(actioncommandid, 0)
    end
  end
  -- restore old item-selection
  reaper.SelectAllMediaItems(0, false)
  ultraschall.SelectMediaItems_MediaItemArray(oldselection)
  reaper.PreventUIRefresh(-1)
  reaper.UpdateArrange()
  return true
end

--MediaItem=reaper.GetMediaItem(0,0)
--ultraschall.ApplyActionToMediaItem(MediaItem, "_XENAKIOS_MOVEITEMSLEFTBYLEN", 2, false, reaper.MIDIEditor_GetActive())


function ultraschall.ApplyActionToMediaItemArray(MediaItemArray, actioncommandid, repeat_action, midi, MIDI_hwnd)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ApplyActionToMediaItemArray</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.77
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ApplyActionToMediaItemArray(MediaItemArray MediaItemArray, string actioncommandid, integer repeat_action, boolean midi, optional HWND MIDI_hwnd)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Applies an action to the MediaItems in MediaItemArray, in either main or MIDI-Editor section-context
    The action given must support applying itself to selected items.
    
    This function applies the action to each MediaItem individually. To apply the action to all MediaItems in MediaItemArray at once, see <a href="#ApplyActionToMediaItemArray2">ApplyActionToMediaItemArray2</a>.
    
    Returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, if running the action was successful; false, if not or an error occured
  </retvals>
  <parameters>
    MediaItemArray MediaItemArray - an array with all MediaItems, to whom the action shall be applied to
    string actioncommandid - the commandid-number or ActionCommandID, that shall be run.
    integer repeat_action - the number of times this action shall be applied to each item; minimum value is 1
    boolean midi - true, run an action from MIDI-Editor-section-context; false, run an action from the main section
    optional HWND MIDI_hwnd - the HWND-handle of the MIDI-Editor, to which a MIDI-action shall be applied to; nil, to use the currently selected one
  </parameters>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, run, action, midi, main, midieditor, item, mediaitemarray</tags>
</US_DocBloc>
]]
  -- check parameters
  if ultraschall.CheckMediaItemArray(MediaItemArray)==false then ultraschall.AddErrorMessage("ApplyActionToMediaItemArray","MediaItemArray", "No valid MediaItemArray!", -1) return false end
  if ultraschall.CheckActionCommandIDFormat2(actioncommandid)==false then ultraschall.AddErrorMessage("ApplyActionToMediaItemArray","actioncommandid", "No such action registered!", -2) return false end
  if type(midi)~="boolean" then ultraschall.AddErrorMessage("ApplyActionToMediaItemArray","midi", "Must be boolean!", -3) return false end
  if math.type(repeat_action)~="integer" then ultraschall.AddErrorMessage("ApplyActionToMediaItemArray","repeat_action", "Must be an integer!", -4) return false end
  if repeat_action<1 then ultraschall.AddErrorMessage("ApplyActionToMediaItemArray","repeat_action", "Must be bigger than 0!", -5) return false end
  
  -- prepare variable
  local count=1
  
  -- apply action to every MediaItem in MediaItemAray repeat_action times
  while MediaItemArray[count]~=nil do
    for i=1, repeat_action do
      ultraschall.ApplyActionToMediaItem(MediaItemArray[count], actioncommandid, repeat_action, midi, MIDI_hwnd)
    end
    count=count+1
  end
  return true
end


--A,B=ultraschall.GetAllMediaItemsBetween(1,40000,"1,2",true)
--ultraschall.ApplyActionToMediaItemArray(B, 40123, 10, false, MIDI_hwnd)




function ultraschall.GetAllMediaItemsInTimeSelection(trackstring, inside)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllMediaItemsInTimeSelection</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.77
    Lua=5.3
  </requires>
  <functioncall>integer count, array MediaItemArray = ultraschall.GetAllMediaItemsInTimeSelection(string trackstring, boolean inside)</functioncall>
  <description>
    Gets all MediaItems from within a time-selection
    
    Returns -1 in case of an error
  </description>
  <retvals>
    integer count - the number of items found in time-selection
    array MediaItemArray - an array with all MediaItems found within time-selection
  </retvals>
  <parameters>
    string trackstring - a string with all tracknumbers, separated by a comma; 1 for the first track, 2 for the second
  </parameters>
  <chapter_context>
    MediaItem Management
    Get MediaItems
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, get, items, time, selection</tags>
</US_DocBloc>
]]
  -- check parameters
  if ultraschall.IsValidTrackString(trackstring)==false then ultraschall.AddErrorMessage("GetAllMediaItemsInTimeSelection","trackstring", "Must be a valid trackstring!", -1) return -1 end
  if type(inside)~="boolean" then ultraschall.AddErrorMessage("GetAllMediaItemsInTimeSelection","inside", "Must be boolean!", -2) return -1 end
  
  -- prepare variables
  local oldcount, oldselection = ultraschall.GetAllSelectedMediaItems()
  local starttime, endtime = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
  
  -- Do the selection
  reaper.PreventUIRefresh(1)
  reaper.SelectAllMediaItems(0, false) -- deselect all
  ultraschall.SetMediaItemsSelected_TimeSelection() -- select only within time-selection
  local count, MediaItemArray=ultraschall.GetAllSelectedMediaItems() -- get all selected items
  local count2
  if MediaItemArray[1]== nil then count2=0 
  else   
    -- check, whether the item is in a track, as demanded by trackstring
    for i=count, 1, -1 do
      if ultraschall.IsItemInTrack3(MediaItemArray[i], trackstring)==false then table.remove(MediaItemArray, i) count=count-1 end
    end
    
    -- remove all items, that aren't properly within time-selection(like items partially in selection)
    if MediaItemArray[1]==nil then count2=0 
    else count2, MediaItemArray=ultraschall.OnlyItemsInTracksAndTimerange(MediaItemArray, trackstring, starttime, endtime, inside) 
    end
  end
    
  -- reset old selection, redraw arrange and return what has been found
  reaper.SelectAllMediaItems(0, false)
  ultraschall.SelectMediaItems_MediaItemArray(oldselection)
  reaper.PreventUIRefresh(-1)
  reaper.UpdateArrange()
  return count2, MediaItemArray
end

--A,B=ultraschall.GetAllMediaItemsInTimeSelection("2", false)


function ultraschall.NormalizeItems(MediaItemArray)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>NormalizeItems</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.77
    Lua=5.3
  </requires>
  <functioncall>integer retval = ultraschall.NormalizeItems(array MediaItemArray)</functioncall>
  <description>
    Normalizes all items in MediaItemArray.
    
    Returns -1 in case of an error
  </description>
  <retvals>
    integer retval - -1, in case of an error
  </retvals>
  <parameters>
    array MediaItemArray - an array with all MediaItems, that shall be normalized
  </parameters>
  <chapter_context>
    MediaItem Management
    Manipulate
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, normalize, items</tags>
</US_DocBloc>
]]
  if ultraschall.CheckMediaItemArray(MediaItemArray)==false then ultraschall.AddErrorMessage("NormalizeItems","MediaItemArray", "No valid MediaItemArray!", -1) return -1 end
  ultraschall.ApplyActionToMediaItemArray(MediaItemArray, 40108, 1, false)
end

--A,B=ultraschall.GetAllMediaItemsInTimeSelection("1,2", false)
--ultraschall.NormalizeItems(B)


function ultraschall.ChangePathInSource(PCM_source, NewPath)
  local Filenamebuf = reaper.GetMediaSourceFileName(PCM_source, "")
  local filename=Filenamebuf:match(".*/(.*)")
  if filename==nil then filename=Filenamebuf:match(".*\\(.*)") end
  filename=NewPath.."/"..filename
  return reaper.PCM_Source_CreateFromFile(filename)
end

--NewSource=ultraschall.ChangePathInSource(reaper.GetMediaItemTake_Source(reaper.GetMediaItemTake(reaper.GetMediaItem(0,0),0)), "c:\\temp")

function ultraschall.GetAllMediaItems()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllMediaItems</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.77
    Lua=5.3
  </requires>
  <functioncall>integer itemcount, MediaItemArray MediaItemArray = ultraschall.GetAllMediaItems()</functioncall>
  <description>
    Returns a MediaItemArray with all MediaItems in the current project
  </description>
  <retvals>
    integer itemcount - the number of items in the MediaItemArray
    MediaItemArray MediaItemArray - an array with all MediaItems from the current project
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItems
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, get, all, mediaitems, mediaitemarray</tags>
</US_DocBloc>
--]]
  local MediaItemArray={}
  for i=0, reaper.CountMediaItems(0) do
    MediaItemArray[i+1]=reaper.GetMediaItem(0,i)
  end
  return reaper.CountMediaItems(0), MediaItemArray
end


--A,B=ultraschall.GetAllMediaItems()


function ultraschall.PreviewMediaItem(MediaItem, Previewtype)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>PreviewMediaItem</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.77
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.PreviewMediaItem(MediaItem MediaItem, integer Previewtype)</functioncall>
  <description>
    Will play a preview a given MediaItem.
    You can just play one preview at a time, except when previewing additionally through the MediaExplorer.
    
    Returns false in case of an error
  </description>
  <retvals>
    boolean retval - false, in case of error; true, in case of success
  </retvals>
  <parameters>
    MediaItem MediaItem - the MediaItem, of which you want to play a preview
    integer Previewtype - the type of the preview
                        - 0, Preview the MediaItem in the Media Explorer
                        - 1, Preview the MediaItem
                        - 2, Preview the MediaItem at track fader volume of the track, in which it lies
                        - 3, Preview the MediaItem through the track, in which it lies(including FX-settings)
  </parameters>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, preview, audio, mediaitem, track, mediaexplorer</tags>
</US_DocBloc>
]]
  if reaper.ValidatePtr2(0,MediaItem,"MediaItem*")==false then ultraschall.AddErrorMessage("PreviewMediaItem", "MediaItem", "Must be a valid MediaItem.", -1) return false end
  if math.type(Previewtype)~="integer" then ultraschall.AddErrorMessage("PreviewMediaItem", "Previewtype", "Must be an integer.", -2) return false end
  if Previewtype<0 or Previewtype>3 then ultraschall.AddErrorMessage("PreviewMediaItem", "Previewtype", "Must be between 0 and 3.", -3) return false end
  if Previewtype==0 then Previewtype=41623 -- Media explorer: Preview media item source media
  elseif Previewtype==1 then Previewtype="_XENAKIOS_ITEMASPCM1" -- Xenakios/SWS: Preview selected media item
  elseif Previewtype==2 then Previewtype="_SWS_PREVIEWFADER" -- Xenakios/SWS: Preview selected media item at track fader volume
  elseif Previewtype==3 then Previewtype="_SWS_PREVIEWTRACK" -- Xenakios/SWS: Preview selected media item through track
  end
  
  return ultraschall.ApplyActionToMediaItem(MediaItem, Previewtype, 1, false) 
end

--MediaItem1=reaper.GetMediaItem(0,0)
--ultraschall.PreviewMediaItem(MediaItem1, 0)

function ultraschall.StopAnyPreview()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>StopAnyPreview</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.77
    Lua=5.3
  </requires>
  <functioncall>ultraschall.StopAnyPreview()</functioncall>
  <description>
    Stops any playing preview of a MediaItem.
  </description>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, stop, preview, audio, mediaitem, track, mediaexplorer</tags>
</US_DocBloc>
]]
--  ultraschall.RunCommand("_SWS_STOPPREVIEW") -- Xenakios/SWS: Stop current media item/take preview
--  ultraschall.PreviewMediaFile(ultraschall.Api_Path.."/misc/silence.flac")
  --ultraschall.StopAnyPreview()
  reaper.Xen_StopSourcePreview(-1)
end




function ultraschall.PreviewMediaFile(filename_with_path, gain, loop)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>PreviewMediaFile</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.92
    Lua=5.3
  </requires>
  <functioncall>integer retval = ultraschall.PreviewMediaFile(string filename_with_path, optional number gain, optional boolean loop)</functioncall>
  <description>
    Plays a preview of a media-file. You can only play one file at a time.
    
    Returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, starting preview was successful; false, starting preview wasn't successful
  </retvals>
  <parameters>
    string filename_with_path - the filename with path of the media-file to play
    optional number gain - the gain of the volume; nil, defaults to 1
    optional boolean loop - true, loop the previewed file; false or nil, don't loop the file
  </parameters>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, preview, play, audio, file</tags>
</US_DocBloc>
]]

  if type(filename_with_path)~="string" then ultraschall.AddErrorMessage("PreviewMediaItem", "filename_with_path", "Must be a string.", -1) return false end
  if reaper.file_exists(filename_with_path)== false then ultraschall.AddErrorMessage("PreviewMediaItem", "filename_with_path", "File does not exist.", -2) return false end

  if type(loop)~="boolean" then loop=false end
  if type(gain)~="number" then gain=1 end
  --ultraschall.StopAnyPreview()
  reaper.Xen_StopSourcePreview(-1)
  --if ultraschall.PreviewPCMSource~=nil then reaper.PCM_Source_Destroy(ultraschall.PreviewPCMSource) end
  ultraschall.PreviewPCMSource=reaper.PCM_Source_CreateFromFile(filename_with_path)
  
  local retval=reaper.Xen_StartSourcePreview(ultraschall.PreviewPCMSource, gain, loop)
  return retval
end

--ultraschall.StopAnyPreview()
--O=ultraschall.PreviewMediaFile("c:\\Derek And The Dominos - Layla.mp3", 1, false)
--O2=ultraschall.PreviewMediaFile("c:\\Derek And The Dominos - Layla.mp3", 1, false)
--ultraschall.PreviewMediaFile("c:\\Derek And The Dominos - Layla.mp3", 1, false)
--ultraschall.PreviewMediaFile("c:\\Derek And The Dominos - Layla.mp3", 1, false)

function ultraschall.GetMediaItemTake(MediaItem, TakeNr)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetMediaItemTake</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.92
    Lua=5.3
  </requires>
  <functioncall>MediaItem_Take Take, integer TakeCount = ultraschall.GetMediaItemTake(MediaItem MediaItem, integer TakeNr)</functioncall>
  <description>
    Returns the requested MediaItem-Take of MediaItem. Use TakeNr=0 for the active take(!)
    
    Returns nil in case of an error
  </description>
  <retvals>
    MediaItem_Take Take - the requested take of a MediaItem
    integer TakeCount - the number of takes available within this Mediaitem
  </retvals>
  <parameters>
    MediaItem MediaItem - the MediaItem, of whom you want to request a certain take.
    integer TakeNr - the take that you want to request; 1 for the first; 2 for the second, etc; 0, for the current active take
  </parameters>
  <chapter_context>
    MediaItem Management
    Get MediaItem-Takes
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, take, get, take, active</tags>
</US_DocBloc>
]]
  if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==false then ultraschall.AddErrorMessage("GetMediaItemTake", "MediaItem", "must be a valid MediaItem-object", -1) return nil end
  if math.type(TakeNr)~="integer" then ultraschall.AddErrorMessage("GetMediaItemTake", "TakeNr", "must be an integer", -2) return nil end
  if TakeNr<0 or TakeNr>reaper.CountTakes(MediaItem) then ultraschall.AddErrorMessage("GetMediaItemTake", "TakeNr", "No such take in MediaItem", -3) return -1 end
  
  if TakeNr==0 then return reaper.GetActiveTake(MediaItem), reaper.CountTakes(MediaItem)
  else return reaper.GetMediaItemTake(MediaItem, TakeNr-1), reaper.CountTakes(MediaItem) end
end


function ultraschall.ApplyFunctionToMediaItemArray(MediaItemArray, functionname, ...)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ApplyFunctionToMediaItemArray</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.92
    Lua=5.3
  </requires>
  <functioncall>table returnvalues  = ultraschall.ApplyFunctionToMediaItemArray(MediaItemArray MediaItemArray, function functionname, functionparameters1, ..., functionparametersn)</functioncall>
  <description>
    Applies function "functionname" on all items in MediaItemArray. Parameter ... is all parameters used for function "functionname", where you should use nil in place of the parameter that shall hold a MediaItem.
    
    Returns a table with a boolean(did the function run without an error) and all returnvalues returned by function "functionname".
    
    Returns nil in case of an error. Will NOT(!) stop execution, if function "functionname" produces an error(see table returnvalues for more details)
  </description>
  <retvals>
    table returnvalues - a table with all returnvalues of the following structure:
                       -    returnvalues[1]=boolean - true, running the function succeeded; false, running the function did not succeed
                       -    returnvalues[2]=optional(!) string - the errormessage, if returnvalues[1]=false; will be omitted if returnvalues[1]=true
                       - all other tableentries contain the returnvalues, as returned by function "functionname"
  </retvals>
  <parameters>
    MediaItemArray MediaItemArray - an array with all MediaItems, who you want to apply functionname to.
    function functionname - the name of the function to apply to every MediaItem in MediaItemArray
    functionparameters1...n - the parameters needed for function "functionname". Important: the function-parameter that is intended for the MediaItem, must be nil. 
                            - This nil-parameter will be filled with the appropriate MediaItem by ApplyFunctionToMediaItemArray automatically
  </parameters>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, apply, function, mediaitem, mediaitemarray</tags>
</US_DocBloc>
]]  
  if type(functionname)~="function" then ultraschall.AddErrorMessage("ApplyFunctionToMediaItemArray", "functionname", "Must be a function.", -1) return nil end
  if ultraschall.CheckMediaItemArray(MediaItemArray)==false then ultraschall.AddErrorMessage("ApplyFunctionToMediaItemArray", "functionname", "Must be a function.", -1) return nil end
  local L={...}
  local RetValTable={}
  local index=-1
  local max, i
  for i=1, 255 do 
    v=L[i]
    if v==nil and index==-1 then index=i
    elseif v==nil and index~=-1 then max=i break end
  end
  i=1
  while MediaItemArray[i]~=nil do
    L[index]=MediaItemArray[i]
    A={pcall(functionname, ultraschall.ReturnTableAsIndividualValues(L))}
    RetValTable[i]=A    
    i=i+1
  end
  return i, RetValTable
end





function ultraschall.GetGapsBetweenItems(MediaTrack)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetGapsBetweenItems</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.77
    Lua=5.3
  </requires>
  <functioncall>integer number_of_gaps, array gaptable = ultraschall.GetGapsBetweenItems(MediaTrack MediaTrack)</functioncall>
  <description>
    Returns a table with all gaps between items in MediaTrack.
    
    Returns -1 in case of an error
  </description>
  <retvals>
    integer number_of_gaps - the number of gaps found between items; -1, in case of error
    array gaptable - an array with all gappositions found
                   - gaptable[idx][1]=startposition of gap
                   - gaptable[idx][2]=endposition of gap
  </retvals>
  <parameters>
    MediaTrack MediaTrack - the track, of which you want to have the gaps between items
  </parameters>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, get, gaps, between, items, item, mediaitem</tags>
</US_DocBloc>
]]
  if reaper.ValidatePtr2(0, MediaTrack, "MediaTrack*")==false then ultraschall.AddErrorMessage("GetGapsBetweenItems", "MediaTrack", "Must be a valid MediaTrack-object", -1) return -1 end
  if reaper.GetTrackMediaItem(MediaTrack, 0)==nil then ultraschall.AddErrorMessage("GetGapsBetweenItems", "MediaTrack", "No MediaItem in track", -2) return -1 end
  local GapTable={}
  local counter2=0
  local MediaItemArray={}
  local counter=0
  local Iterator, pos1, pos2, end1, end2
  
  -- create MediaItemArray with all items in track
  MediaItemArray[counter]=0
  while MediaItemArray[counter]~=nil do
    counter=counter+1
    MediaItemArray[counter]=reaper.GetTrackMediaItem(MediaTrack, counter-1)
  end
  counter=counter-1
  
  -- throw out all items, that are within/underneath other items
  for i=counter, 2, -1 do
    pos1=reaper.GetMediaItemInfo_Value(MediaItemArray[i], "D_POSITION")
    end1=reaper.GetMediaItemInfo_Value(MediaItemArray[i], "D_LENGTH")+pos1
    pos2=reaper.GetMediaItemInfo_Value(MediaItemArray[i-1], "D_POSITION")
    end2=reaper.GetMediaItemInfo_Value(MediaItemArray[i-1], "D_LENGTH")+pos2
    if pos1>pos2 and end1<end2 then 
      table.remove(MediaItemArray,i) 
      counter=counter-1 
    end
  end
  
  -- see, if there's a gap between projectstart and first item, if yes, add it to GapTable
  if reaper.GetMediaItemInfo_Value(MediaItemArray[1], "D_POSITION")>0 then 
    Iterator=1
    GapTable[1]={}
    GapTable[1][1]=0
    GapTable[1][2]=reaper.GetMediaItemInfo_Value(MediaItemArray[1], "D_POSITION")
  else
    Iterator=0
  end
  
  -- create a table with all Gaps between items  
  for i=1, counter-1 do
    GapTable[i+Iterator]={}
    GapTable[i+Iterator][1]=reaper.GetMediaItemInfo_Value(MediaItemArray[i], "D_POSITION")+reaper.GetMediaItemInfo_Value(MediaItemArray[i], "D_LENGTH")
    GapTable[i+Iterator][2]=reaper.GetMediaItemInfo_Value(MediaItemArray[i+1], "D_POSITION")
    counter2=counter2+1
  end

  -- remove all gaps, that are gaps of length 0 or "gaps" of overlapping items(which aren't gaps because of that)
  for i=counter2+Iterator, 1, -1 do
    if GapTable[i][1]>=GapTable[i][2] then 
      table.remove(GapTable,i) 
      counter2=counter2-1
    end
  end
  
  return counter2+Iterator, GapTable
end


--A,B=ultraschall.GetGapsBetweenItems(reaper.GetTrack(0,0))


function ultraschall.DeleteMediaItemsBetween(startposition, endposition,  trackstring, inside)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DeleteMediaItems_Position</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>boolean retval, array MediaItemStateChunkArray = ultraschall.DeleteMediaItems_Between(number startposition, number endposition, string trackstring, boolean inside)</functioncall>
  <description>
    Delete the MediaItems between start- and endposition, from the tracks as given by trackstring.
    Returns also a MediaItemStateChunkArray, that contains the statechunks of all deleted MediaItem
  </description>
  <parameters>
    number startposition - the startposition in seconds
    number endposition - the endposition in seconds
    string trackstring - the tracknumbers, separated by a comma
    boolean inside - true, delete only MediaItems that are completely within start and endposition; false, also include MediaItems partially within start and endposition
  </parameters>
  <retvals>
    boolean retval - true, delete was successful; false was unsuccessful
    array MediaItemStateChunkArray - and array with all statechunks of all deleted MediaItems; 
                                   - each statechunk contains an additional entry "ULTRASCHALL_TRACKNUMBER" which holds the tracknumber, in which the deleted MediaItem was located
  </retvals>
  <chapter_context>
    MediaItem Management
    Delete
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, delete, between</tags>
</US_DocBloc>
]]
  if type(startposition)~="number" then ultraschall.AddErrorMessage("DeleteMediaItemsBetween", "startposition", "must be a number", -1) return false end
  if type(endposition)~="number" then ultraschall.AddErrorMessage("DeleteMediaItemsBetween", "endposition", "must be a number", -2) return false end
  if type(inside)~="boolean" then ultraschall.AddErrorMessage("DeleteMediaItemsBetween", "inside", "must be a boolean", -3) return false end
  if startposition>endposition then ultraschall.AddErrorMessage("DeleteMediaItemsBetween", "endposition", "must be bigger than startposition", -4) return false end
  if ultraschall.IsValidTrackString(trackstring)==false then ultraschall.AddErrorMessage("DeleteMediaItemsBetween", "trackstring", "must be a valid trackstring", -5) return false end
  
  local count=0
  local MediaItemArray
  count, MediaItemArray = ultraschall.GetAllMediaItemsBetween(startposition, endposition, trackstring, inside)
  return ultraschall.DeleteMediaItemsFromArray(MediaItemArray)
end

--A,AA,AAA=ultraschall.DeleteMediaItemsBetween(1000, 250, "1,2,3", false)


function ultraschall.GetItemStateChunk(MediaItem, AddTracknumber)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string MediaItemStateChunk = ultraschall.GetItemStateChunk(MediaItem MediaItem, boolean AddTracknumber)</functioncall>
  <description>
    Returns the statechunk of MediaItem. Parameter AddTracknumber allows you to set, whether the tracknumber of the MediaItem shall be inserted to the statechunk as well, by the new entry "ULTRASCHALL_TRACKNUMBER".
    
    returns false in case of an error
  </description>
  <parameters>
    MediaItem MediaItem - the MediaItem, whose statechunk you want to have
    boolean AddTracknumber - nil or true; add the tracknumber, where the MediaItem lies, as additional entry entry "ULTRASCHALL_TRACKNUMBER" to the statechunk; false, just return the original statechunk.
  </parameters>
  <retvals>
    boolean retval - true, if getting the statechunk was successful; false, if not
    string MediaItemStateChunk - the statechunk of the MediaItem
  </retvals>
  <chapter_context>
    MediaItem Management
    Get MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, get, statechunk, tracknumber</tags>
</US_DocBloc>
]]
  if ultraschall.type(MediaItem)~="MediaItem" then ultraschall.AddErrorMessage("GetItemStateChunk","MediaItem", "must be a MediaItem", -1) return false end
  if AddTracknumber~=nil and ultraschall.type(AddTracknumber)~="boolean" then ultraschall.AddErrorMessage("GetItemStateChunk","AddTracknumber", "must be a boolean", -1) return false end
  _temp, statechunk=reaper.GetItemStateChunk(MediaItem, "", false)
  if AddTracknumber~=false then statechunk=ultraschall.SetItemUSTrackNumber_StateChunk(statechunk, math.floor(reaper.GetMediaItemInfo_Value(MediaItem, "P_TRACK"))+1) end
  return true, statechunk
end


function ultraschall.ApplyActionToMediaItemArray2(MediaItemArray, actioncommandid, repeat_action, midi, MIDI_hwnd)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ApplyActionToMediaItemArray2</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ApplyActionToMediaItemArray2(MediaItemArray MediaItemArray, string actioncommandid, integer repeat_action, boolean midi, optional HWND MIDI_hwnd)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Applies an action to the MediaItems in MediaItemArray, in either main or MIDI-Editor section-context
    The action given must support applying itself to selected items.
    
    This function applies the action to all MediaItems at once. To apply the action to each MediaItem in MediaItemArray individually, see <a href="#ApplyActionToMediaItemArray">ApplyActionToMediaItemArray</a>
    
    Returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, if running the action was successful; false, if not or an error occured
  </retvals>
  <parameters>
    MediaItemArray MediaItemArray - an array with all MediaItems, to whom the action shall be applied to
    string actioncommandid - the commandid-number or ActionCommandID, that shall be run.
    integer repeat_action - the number of times this action shall be applied to each item; minimum value is 1
    boolean midi - true, run an action from MIDI-Editor-section-context; false, run an action from the main section
    optional HWND MIDI_hwnd - the HWND-handle of the MIDI-Editor, to which a MIDI-action shall be applied to; nil, to use the currently selected one
  </parameters>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, run, action, midi, main, midieditor, item, mediaitemarray</tags>
</US_DocBloc>
]]
  -- check parameters
  if ultraschall.CheckMediaItemArray(MediaItemArray)==false then ultraschall.AddErrorMessage("ApplyActionToMediaItemArray2","MediaItemArray", "No valid MediaItemArray!", -1) return false end
  if ultraschall.CheckActionCommandIDFormat2(actioncommandid)==false then ultraschall.AddErrorMessage("ApplyActionToMediaItemArray2","actioncommandid", "No such action registered!", -2) return false end
  if type(midi)~="boolean" then ultraschall.AddErrorMessage("ApplyActionToMediaItemArray2","midi", "Must be boolean!", -3) return false end
  if math.type(repeat_action)~="integer" then ultraschall.AddErrorMessage("ApplyActionToMediaItemArray2","repeat_action", "Must be an integer!", -4) return false end
  if repeat_action<1 then ultraschall.AddErrorMessage("ApplyActionToMediaItemArray2","repeat_action", "Must be bigger than 0!", -5) return false end
  
  reaper.PreventUIRefresh(1)
  local count, MediaItemArray_selected = ultraschall.GetAllSelectedMediaItems() -- get old selection
  reaper.SelectAllMediaItems(0, false) -- deselect all MediaItems
  local retval = ultraschall.SelectMediaItems_MediaItemArray(MediaItemArray) -- select to-be-processed-MediaItems
  for i=1, repeat_action do
    ultraschall.RunCommand(actioncommandid,0) -- apply the action
  end
  reaper.SelectAllMediaItems(0, false) -- deselect all MediaItems
  local retval = ultraschall.SelectMediaItems_MediaItemArray(MediaItemArray_selected) -- select the MediaItems formerly selected
  reaper.PreventUIRefresh(-1)
  reaper.UpdateArrange()
  return true
end

-- count, MediaItemArray_selected = ultraschall.GetAllSelectedMediaItems()

-- ultraschall.ApplyActionToMediaItemArray2(MediaItemArray_selected, 41925, 100, false)

function ultraschall.GetMediafileAttributes(filename)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetMediafileAttributes</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>number length, integer numchannels, integer Samplerate, string Filetype = ultraschall.GetMediafileAttributes(string filename)</functioncall>
  <description>
    returns the attributes of a mediafile
    
    if the mediafile is an rpp-project, this function creates a proxy-file called filename.RPP-PROX, which is a wave-file of the length of the project.
    This file can be deleted safely after that, but would be created again the next time this function is called.    
  </description>
  <parameters>
    string filename - the file whose attributes you want to have
  </parameters>
  <retvals>
    number length - the length of the mediafile in seconds
    integer numchannels - the number of channels of the mediafile
    integer Samplerate - the samplerate of the mediafile in hertz
    string Filetype - the type of the mediafile, like MP3, WAV, MIDI, FLAC, RPP_PROJECT etc
  </retvals>
  <chapter_context>
    MediaItem Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>markermanagement, get, position, length, num, channels, samplerate, filetype</tags>
</US_DocBloc>
--]]
  if type(filename)~="string" then ultraschall.AddErrorMessage("GetMediafileAttributes","filename", "must be a string", -1) return -1 end
  if reaper.file_exists(filename)==false then ultraschall.AddErrorMessage("GetMediafileAttributes","filename", "file does not exist", -2) return -1 end
  local PCM_source=reaper.PCM_Source_CreateFromFile(filename)
  local Length, lengthIsQN = reaper.GetMediaSourceLength(PCM_source)
  local Numchannels=reaper.GetMediaSourceNumChannels(PCM_source)
  local Samplerate=reaper.GetMediaSourceSampleRate(PCM_source)
  local Filetype=reaper.GetMediaSourceType(PCM_source, "")  
  reaper.PCM_Source_Destroy(PCM_source)
--  if Filetype=="RPP_PROJECT" then os.remove(filename.."-PROX") end
  return Length, Numchannels, Samplerate, Filetype
end


--ultraschall.RenderProject_Regions(nil, "c:\\testofon.lol", 1,true, true, true, true, nil)



function ultraschall.InsertMediaItemFromFile(filename, track, position, endposition, editcursorpos, offset)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>InsertMediaItemFromFile</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    SWS=2.9.7
    Lua=5.3
  </requires>
  <functioncall>integer retval, MediaItem item, number endposition, integer numchannels, integer Samplerate, string Filetype, number editcursorposition, MediaTrack track = ultraschall.InsertMediaItemFromFile(string filename, integer track, number position, number endposition, integer editcursorpos, optional number offset)</functioncall>
  <description>
    Inserts the mediafile filename into the project at position in track
    When giving an rpp-projectfile, it will be rendered by Reaper and inserted as subproject!
    
    Due API-limitations, it creates two undo-points: one for inserting the MediaItem and one for changing the length(when endposition isn't -1).    
    
    Returns -1 in case of failure
  </description>
  <parameters>
    string filename - the path+filename of the mediafile to be inserted into the project
    integer track - the track, in which the file shall be inserted
                  -  0, insert the file into a newly inserted track after the last track
                  - -1, insert the file into a newly inserted track before the first track
    number position - the position of the newly inserted item
    number endposition - the length of the newly created mediaitem; -1, use the length of the sourcefile
    integer editcursorpos - the position of the editcursor after insertion of the mediafile
          - 0 - the old editcursorposition
          - 1 - the position, at which the item was inserted
          - 2 - the end of the newly inserted item
    optional number offset - an offset, to delay the insertion of the item, to overcome possible "too late"-starting of playback of item during recording
  </parameters>
  <retvals>
    integer retval - 0, if insertion worked; -1, if it failed
    MediaItem item - the newly created MediaItem
    number endposition - the endposition of the newly created MediaItem in seconds
    integer numchannels - the number of channels of the mediafile
    integer Samplerate - the samplerate of the mediafile in hertz
    string Filetype - the type of the mediafile, like MP3, WAV, MIDI, FLAC, etc
    number editcursorposition - the (new) editcursorposition
    MediaTrack track - returns the MediaTrack, in which the item is included
  </retvals>
  <chapter_context>
    MediaItem Management
    Insert
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>markermanagement, insert, mediaitem, position, mediafile, track</tags>
</US_DocBloc>
--]]

  -- check parameters
  if reaper.file_exists(filename)==false then ultraschall.AddErrorMessage("InsertMediaItemFromFile", "filename", "file does not exist", -1) return -1 end
  if math.type(track)~="integer" then ultraschall.AddErrorMessage("InsertMediaItemFromFile","track", "must be an integer", -2) return -1 end
  if type(position)~="number" then ultraschall.AddErrorMessage("InsertMediaItemFromFile","position", "must be a number", -3) return -1 end
  if type(endposition)~="number" then ultraschall.AddErrorMessage("InsertMediaItemFromFile","endposition", "must be a number", -4) return -1 end
  if endposition<-1 then ultraschall.AddErrorMessage("InsertMediaItemFromFile","endposition", "must be bigger/equal 0; or -1 for sourcefilelength", -5) return -1 end
  if math.type(editcursorpos)~="integer" then ultraschall.AddErrorMessage("InsertMediaItemFromFile", "editcursorpos", "must be an integer between 0 and 2", -6) return -1 end
  if track<-1 or track>reaper.CountTracks(0) then ultraschall.AddErrorMessage("InsertMediaItemFromFile","track", "no such track available", -7) return -1 end  
  if offset~=nil and type(offset)~="number" then ultraschall.AddErrorMessage("InsertMediaItemFromFile","offset", "must be either nil or a number", -8) return -1 end  
  if offset==nil then offset=0 end
    
  -- where to insert and where to have the editcursor after insert
  local editcursor, mode
  if editcursorpos==0 then editcursor=reaper.GetCursorPosition()
  elseif editcursorpos==1 then editcursor=position
  elseif editcursorpos==2 then editcursor=position+ultraschall.GetMediafileAttributes(filename)
  else ultraschall.AddErrorMessage("InsertMediaItemFromFile","editcursorpos", "must be an integer between 0 and 2", -6) return -1
  end
  
  -- insert file
  local Length, Numchannels, Samplerate, Filetype = ultraschall.GetMediafileAttributes(filename) -- mediaattributes, like length
  local startTime, endTime = reaper.BR_GetArrangeView(0) -- get current arrange-view-range
  local mode=0
  if track>=0 and track<reaper.CountTracks(0) then
    mode=0
  elseif track==0 then
    mode=0
    track=reaper.CountTracks(0)
  elseif track==-1 then
    mode=0
    track=1
    reaper.InsertTrackAtIndex(0,false)
  end
  local SelectedTracks=ultraschall.CreateTrackString_SelectedTracks() -- get old track-selection
  ultraschall.SetTracksSelected(tostring(track), true) -- set track selected, where we want to insert the item
  reaper.SetEditCurPos(position+offset, false, false) -- change editcursorposition to where we want to insert the item
  local CountMediaItems=reaper.CountMediaItems(0) -- the number of items available; the new one will be number of items + 1
  local LLL=ultraschall.GetAllMediaItemGUIDs()
  if LLL[1]==nil then LLL[1]="tudelu" end
  local integer=reaper.InsertMedia(filename, mode)  -- insert item with file
  local LLL2=ultraschall.GetAllMediaItemGUIDs()
  local A,B=ultraschall.CompareArrays(LLL, LLL2)
  local item=reaper.BR_GetMediaItemByGUID(0, A[1])
  if endposition~=-1 then reaper.SetMediaItemInfo_Value(item, "D_LENGTH", endposition) end
  
  reaper.SetEditCurPos(editcursor, false, false)  -- set editcursor to new position
  reaper.BR_SetArrangeView(0, startTime, endTime) -- reset to old arrange-view-range
  if SelectedTracks~="" then ultraschall.SetTracksSelected(SelectedTracks, true) end -- reset old trackselection
  return 0, item, Length, Numchannels, Samplerate, Filetype, editcursor, reaper.GetMediaItem_Track(item)
end

--A,B,C,D,E,F,G,H,I,J=ultraschall.InsertMediaItemFromFile(ultraschall.Api_Path.."/misc/silence.flac", 0, 0, -1, 0)


function ultraschall.CopyMediaItemToDestinationTrack(MediaItem, MediaTrack_destination, position)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>CopyMediaItemToDestinationTrack</slug>
    <requires>
      Ultraschall=4.00
      Reaper=5.965
      Lua=5.3
    </requires>
    <functioncall>MediaItem newMediaItem, MediaItemStateChunk statechunk = ultraschall.CopyMediaItemToDestinationTrack(MediaItem MediaItem, MediaTrack MediaTrack_destination, number position)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      Copies MediaItem to MediaTrack_destination at position.
      
      Returns nil in case of an error
    </description>
    <retvals>
      MediaItem newMediaItem - the newly created MediaItem; nil, if no item could be created
      MediaItemStateChunk statechunk - the statechunk of the newly created MediaItem
    </retvals>
    <parameters>
      MediaItem MediaItem - the MediaItem, that you want to create a copy from
      MediaTrack MediaTrack_destination - the track, into which you want to copy the MediaItem
      number position - the position of the copy of the MediaItem; negative, to keep the position of the source-MediaItem
    </parameters>
    <chapter_context>
      MediaItem Management
      Assistance functions
    </chapter_context>
    <target_document>US_Api_Documentation</target_document>
    <source_document>ultraschall_functions_engine.lua</source_document>
    <tags>mediaitem management, copy, mediaitem, track, mediatrack, position</tags>
  </US_DocBloc>
  ]]
  if ultraschall.type(MediaItem)~="MediaItem" then ultraschall.AddErrorMessage("CopyMediaItemToDestinationTrack", "MediaItem", "must be a valid MediaItem", -1) return end
  if ultraschall.type(MediaTrack_destination)~="MediaTrack" then ultraschall.AddErrorMessage("CopyMediaItemToDestinationTrack", "MediaTrack_destination", "must be a valid MediaTrack-object", -2) return end
  if type(position)~="number" then ultraschall.AddErrorMessage("CopyMediaItemToDestinationTrack", "position", "must be a number", -3) return end
--  if position<0 then ultraschall.AddErrorMessage("CopyMediaItemToDestinationTrack", "position", "must be bigger than 0", -4) return end
  
  local original_position =  reaper.GetMediaItemInfo_Value( MediaItem, "D_POSITION" )
  reaper.SetMediaItemInfo_Value( MediaItem, "D_POSITION" , position )
  local retval, chunk = reaper.GetItemStateChunk(MediaItem, "", false)
  
  local temp_item = reaper.CreateNewMIDIItemInProj(MediaTrack_destination, 3, 0.1, false )
  if ultraschall.type(temp_item)~="MediaItem" then ultraschall.AddErrorMessage("CopyMediaItemToDestinationTrack", "", "could not create the new copy of the MediaItem", -5) return end
  reaper.SetMediaItemInfo_Value(MediaItem, "D_POSITION" , original_position)
  
  chunk=string.gsub(chunk, "\nIGUID.-\n", "\nIGUID "..reaper.genGuid().."\n")
  chunk=string.gsub(chunk, "\nGUID.-\n", "\nGUID "..reaper.genGuid().."\n")
  reaper.SetItemStateChunk(temp_item, chunk, false)
  return temp_item, chunk
end


--ultraschall.CopyMediaItemToDestinationTrack(reaper.GetMediaItem(0,0), reaper.GetTrack(0,2), -10)


