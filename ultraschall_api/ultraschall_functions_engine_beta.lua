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


ultraschall.ShowLastErrorMessage()



function ultraschall.GetProjectReWireClient(projectfilename_with_path)
--To Do
-- ProjectSettings->Advanced->Rewire Client Settings
end




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





function ultraschall.AddShownoteMarker(pos, name)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AddShownoteMarker</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer markernumber, string guid, integer shownotemarker_index = ultraschall.AddShownoteMarker(number pos, string name)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Will add new shownote-marker.
    
    A shownote-marker has the naming-scheme 
        
        _Shownote: name for this shownote
    
    returns -1 in case of an error
  </description>
  <parameters>
    number pos - the position of the marker in seconds
    string name - the name of the shownote-marker
  </parameters>
  <retvals>
    integer markernumber - the indexnumber of the newly added shownotemarker within all regions and markers; 0-based
                         - use this for Reaper's regular marker-functions
                         - -1 in case of an error
    string guid - the guid of the shownotemarker
    integer shownotemarker_index - the index of the shownote-marker within shownotes only; 1-based. 
                                 - Use this for the other Ultraschall-API-shownote-functions!
  </retvals>
  <chapter_context>
    Markers
    ShowNote Marker
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>marker management, add, shownote, name, position, index, guid</tags>
</US_DocBloc>
]]
  if type(pos)~="number" then ultraschall.AddErrorMessage("AddShownoteMarker", "pos", "must be a number", -2) return -1 end
  if type(name)~="string" then ultraschall.AddErrorMessage("AddShownoteMarker", "name", "must be a string", -3) return -1  end
  local Count = ultraschall.CountAllCustomMarkers("Shownote")
  local Color
  if reaper.GetOS():sub(1,3)=="Win" then
    Color = 0xA8A800|0x1000000
  else
    Color = 0x00A8A8|0x1000000
  end
  local name2=reaper.genGuid("")..reaper.time_precise()..reaper.genGuid("")
  A={ultraschall.AddCustomMarker("Shownote", pos, name2, Count+1, Color)}  
  A[4]=A[4]+1
  ultraschall.SetShownoteMarker(A[4], pos, name)
  if A[1]==false then A[2]=-1 end
  table.remove(A,1)
  return table.unpack(A)
end



function ultraschall.SetShownoteMarker(idx, pos, name)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetShownoteMarker</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetShownoteMarker(integer idx, number pos, string name)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Will set an already existing shownote-marker.
    
    A shownote-marker has the naming-scheme 
        
        _Shownote: name for this shownote
    
    returns false in case of an error
  </description>
  <parameters>
    integer idx - the index of the shownote marker within all shownote-markers you want to set; 1-based
    number pos - the new position of the marker in seconds
    string name - the new name of the shownote-marker
  </parameters>
  <retvals>
    boolean retval - true, if setting the shownote-marker was successful; false, if not or an error occurred
  </retvals>
  <chapter_context>
    Markers
    ShowNote Marker
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>marker management, set, shownote, name, position, index</tags>
</US_DocBloc>
]]
  if type(pos)~="number" then ultraschall.AddErrorMessage("SetShownoteMarker", "pos", "must be a number", -1) return false end
  if type(name)~="string" then ultraschall.AddErrorMessage("SetShownoteMarker", "name", "must be a string", -2) return false end
  if math.type(idx)~="integer" then ultraschall.AddErrorMessage("SetShownoteMarker", "idx", "must be an integer", -3) return false end
  idx=idx-1
  local retval, markerindex, pos2, name2, shown_number = ultraschall.EnumerateCustomMarkers("Shownote", idx)
  if retval==false then ultraschall.AddErrorMessage("SetShownoteMarker", "idx", "no such shownote-marker", -4) return false end
  
  local Count = ultraschall.CountAllCustomMarkers("Shownote")
  local Color
  if reaper.GetOS():sub(1,3)=="Win" then
    Color = 0xA8A800|0x1000000
  else
    Color = 0x00A8A8|0x1000000
  end
  local A={ultraschall.SetCustomMarker("Shownote", idx, pos, name, shown_number, Color)}
  return table.unpack(A)
end

function ultraschall.EnumerateShownoteMarkers(idx)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>EnumerateShownoteMarkers</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval, integer marker_index, number pos, string name, integer shown_number, string guid = ultraschall.EnumerateShownoteMarkers(integer idx)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Will return a specific shownote-marker.
    
    A shownote-marker has the naming-scheme 
        
        _Shownote: name for this marker
        
    returns false in case of an error
  </description>
  <parameters>
    integer idx - the index of the marker within all shownote-markers; 1, for the first shownote-marker
  </parameters>
  <retvals>
    boolean retval - true, if the shownote-marker exists; false, if not or an error occurred
    integer marker_index - the index of the shownote-marker within all markers and regions, as positioned in the project, with 0 for the first, 1 for the second, etc
    number pos - the position of the shownote in seconds
    string name - the name of the shownote
    integer shown_number - the markernumber, that is displayed in the timeline of the arrangeview
    string guid - the guid of the shownote-marker
  </retvals>
  <chapter_context>
    Markers
    ShowNote Marker
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>marker management, enumerate, custom markers, name, position, shown_number, index, guid</tags>
</US_DocBloc>
]]
  if math.type(idx)~="integer" then ultraschall.AddErrorMessage("EnumerateShownoteMarkers", "idx", "must be an integer", -1) return false end
  idx=idx-1
  local A = {ultraschall.EnumerateCustomMarkers("Shownote", idx)}
  if A[1]==false then ultraschall.AddErrorMessage("EnumerateShownoteMarkers", "idx", "no such shownote-marker", -2) return false end  
  table.remove(A, 6)
  return table.unpack(A)
end

ultraschall.ShowNoteAttributes = {"shwn_language",           -- check for validity ISO639
              "shwn_description",
              "shwn_location_gps",       -- check for validity
              "shwn_location_google_maps",-- check for validity
              "shwn_location_open_street_map",-- check for validity
              "shwn_location_apple_maps",-- check for validity
              "shwn_date",       -- check for validity
              "shwn_time",       -- check for validity
              "shwn_timezone",   -- check for validity
              "shwn_event_date_start",   -- check for validity
              "shwn_event_date_end",     -- check for validity
              "shwn_event_time_start",   -- check for validity
              "shwn_event_time_end",     -- check for validity
              "shwn_event_timezone",     -- check for validity
              "shwn_event_name",
              "shwn_event_description",
              "shwn_event_url", 
              "shwn_event_location_gps",       -- check for validity
              "shwn_event_location_google_maps",-- check for validity
              "shwn_event_location_open_street_map",-- check for validity
              "shwn_event_location_apple_maps",-- check for validity
              "shwn_event_ics_data",
              "shwn_quote_cite_source", 
              "shwn_quote", 
              --"image_uri",
              --"image_content",      -- check for validity
              --"image_description",
              --"image_source",
              --"image_license",
              "shwn_url", 
              "shwn_url_description",
              "shwn_url_retrieval_date",
              "shwn_url_retrieval_time",
              "shwn_url_retrieval_timezone_utc",
              "shwn_url_archived_copy_of_original_url",
              "shwn_wikidata_uri",
              "shwn_descriptive_tags",
              "shwn_is_advertisement"
              }

function ultraschall.GetSetShownoteMarker_Attributes(is_set, idx, attributename, content)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetSetShownoteMarker_Attributes</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string content = ultraschall.GetSetShownoteMarker_Attributes(boolean is_set, integer idx, string attributename, string content)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Will get/set additional attributes of a shownote-marker.
    
    A shownote-marker has the naming-scheme 
        
        _Shownote: name for this marker
        
    returns false in case of an error
  </description>
  <parameters>
    boolean is_set - true, set the attribute; false, retrieve the current content
    integer idx - the index of the shownote-marker, whose attribute you want to get; 1-based
    string attributename - the attributename you want to get/set
                         - supported attributes are:
                         - "shwn_description" - a more detailed description for this shownote
                         - "shwn_descriptive_tags" - some tags, that describe the content of the shownote, must separated by newlines
                         - "shwn_url" - the url you want to set
                         - "shwn_url_description" - a short description of the url
                         - "shwn_url_retrieval_date" - the date, at which you retrieved the url; yyyy-mm-dd
                         - "shwn_url_retrieval_time" - the time, at which you retrieved the url; hh:mm:ss
                         - "shwn_url_retrieval_timezone_utc" - the timezone of the retrieval time as utc
                         - "shwn_url_archived_copy_of_original_url" - if you have an archived copy of the url(from archive.org, etc), you can place the link here
                         - "shwn_is_advertisement" - yes, if the shownote is an ad; "", to unset it
                         - "shwn_language" - the language of the content; Languagecode according to ISO639
                         - "shwn_location_gps" - the gps-coordinates of the location
                         - "shwn_location_google_maps" - the coordinates as used in Google Maps
                         - "shwn_location_open_street_map" - the coordinates as used in Open Street Maps
                         - "shwn_location_apple_maps" - the coordinates as used in Apple Maps                         
                         - "shwn_date" - the date of the content of the shownote(when talking about events, etc); yyyy-mm-dd
                         - "shwn_time" - the time of the content of the shownote(when talking about events, etc); hh:mm:ss
                         - "shwn_timezone" - the timezone of the content of the shownote(when talking about events, etc); UTC-format
                         - "shwn_event_date_start" - the startdate of an event associated with the show; yyyy-mm-dd
                         - "shwn_event_date_end" - the enddate of an event associated with the show; yyyy-mm-dd
                         - "shwn_event_time_start" - the starttime of an event associated with the show; hh:mm:ss
                         - "shwn_event_time_end" - the endtime of an event associated with the show; hh:mm:ss
                         - "shwn_event_timezone" - the timezone of the event assocated with the show; UTC-format
                         - "shwn_event_name" - a name for the event
                         - "shwn_event_description" - a description for the event
                         - "shwn_event_url" - an url of the event(for ticket sale or the general url for the event)
                         - "shwn_event_location_gps" - the gps-coordinates of the event-location
                         - "shwn_event_location_google_maps" - the google-maps-coordinates of the event-location
                         - "shwn_event_location_open_street_map" - the open-streetmap-coordinates of the event-location
                         - "shwn_event_location_apple_maps" - the apple-maps-coordinates of the event-location
                         - "shwn_event_ics_data" - the event as ics-data-format; will NOT set other event-attributes; will not be checked for validity!
                         - "shwn_quote_cite_source" - a specific place you want to cite, like bookname + page + paragraph + line or something via webcite
                         - "shwn_quote" - a quote from the cite_source
                         - "shwn_wikidata_uri" - the uri to an entry to wikidata
    string content - the new contents to set the attribute with
  </parameters>
  <retvals>
    boolean retval - true, if the attribute exists/could be set; false, if not or an error occurred
    string content - the content of a specific attribute
  </retvals>
  <chapter_context>
    Markers
    ShowNote Marker
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>marker management, get, set, attribute, shownote, image, png, jpg, citation</tags>
</US_DocBloc>
]]
  if type(is_set)~="boolean" then ultraschall.AddErrorMessage("GetSetShownoteMarker_Attributes", "is_set", "must be a boolean", -1) return false end  
  if math.type(idx)~="integer" then ultraschall.AddErrorMessage("GetSetShownoteMarker_Attributes", "idx", "must be an integer", -2) return false end    
  if type(attributename)~="string" then ultraschall.AddErrorMessage("GetSetShownoteMarker_Attributes", "attributename", "must be a string", -3) return false end  
  if is_set==true and type(content)~="string" then ultraschall.AddErrorMessage("GetSetShownoteMarker_Attributes", "content", "must be a string", -4) return false end  
  
  
  -- WARNING!! CHANGES HERE MUST REFLECT CHANGES IN THE CODE OF CommitShownote_ReaperMetadata() !!!
  local tags=ultraschall.ShowNoteAttributes
              
  local found=false
  for i=1, #tags do
    if attributename==tags[i] then
      found=true
      break
    end
  end
  
  if found==false then ultraschall.AddErrorMessage("GetSetShownoteMarker_Attributes", "attributename", "attributename not supported", -7) return false end
  
  local A,B,Retval
  A={ultraschall.EnumerateShownoteMarkers(idx)}
  if A[1]==false then ultraschall.AddErrorMessage("GetSetShownoteMarker_Attributes", "idx", "no such shownote-marker", -5) return false end

  if is_set==true then
    if attributename=="image_content" and content:sub(1,6)~="ÿØÿ" and content:sub(2,4)~="PNG" then ultraschall.AddErrorMessage("GetSetShownoteMarker_Attributes", "content", "image_content: only png and jpg are supported", -6) return false end    
    if attributename=="shwn_event_ics_data" then content=ultraschall.Base64_Encoder(content) end
    Retval = ultraschall.SetMarkerExtState(A[2]+1, attributename, content)
    if Retval==-1 then Retval=false else Retval=true end
    B=content    
  else
    B=ultraschall.GetMarkerExtState(A[2]+1, attributename, content)
    if attributename=="shwn_event_ics_data" then B=ultraschall.Base64_Decoder(B) end
    if B==nil then Retval=false else Retval=true end
  end
  return Retval, B
end


DAEM=ultraschall.DeleteAllErrorMessages
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DAEM</slug>
  <requires>
    Ultraschall=4.4
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = DAEM()</functioncall>
  <description>
    Deletes all error-messages and returns a boolean value.
    
    this is like ultraschall.DeleteAllErrorMessages(), just shorter
    
    returns false in case of failure
  </description>
  <retvals>
    boolean retval - true, if it worked; false if it didn't
  </retvals>
  <chapter_context>
    Developer
    Error Handling
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>developer, error, delete, message</tags>
</US_DocBloc>
]]



function ultraschall.CountShownoteMarkers()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CountShownoteMarkers</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer num_shownotes = ultraschall.CountShownoteMarkers()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns count of all shownotes
    
    A shownote-marker has the naming-scheme 
        
        _Shownote: name for this marker

  </description>
  <retvals>
    integer num_shownotes - the number of shownotes in the current project
  </retvals>
  <chapter_context>
    Markers
    ShowNote Marker
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>marker management, count, shownote</tags>
</US_DocBloc>
]]
  return ultraschall.CountAllCustomMarkers("Shownote")
end
--Kuddel=FromClip()
--A,B,C=ultraschall.GetSetShownoteMarker_Attributes(false, 1, "image_content", "kuchen")
SLEM()


function ultraschall.DeleteShownoteMarker(idx)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DeleteShownoteMarker</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.DeleteShownoteMarker(integer idx)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Deletes a shownotes
    
    A shownote-marker has the naming-scheme 
        
        _Shownote: name for this marker

    will also delete all stored additional attributes with the shownote!

    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, shownote deleted; false, shownote not deleted
  </retvals>
  <parameters>
    integer idx - the index of the shownote to delete, within all shownotes; 1-based
  </parameters>
  <chapter_context>
    Markers
    ShowNote Marker
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>marker management, delete, shownote</tags>
</US_DocBloc>
]]
  if math.type(idx)~="integer" then ultraschall.AddErrorMessage("DeleteShownoteMarker", "idx", "must be an integer", -1) return false end
  idx=idx-1
  local A = {ultraschall.EnumerateCustomMarkers("Shownote", idx)}
  if A[1]==false then ultraschall.AddErrorMessage("DeleteShownoteMarker", "idx", "no such shownote-marker", -2) return false end  
  ultraschall.SetMarkerExtState(A[2], "", "")
  local retval, marker_index, pos, name, shown_number, color = ultraschall.DeleteCustomMarkers("Shownote", idx)
  return retval
end

ultraschall.PodcastAttributes={"podc_title", 
              "podc_description", 
              --"podc_feed",
              "podc_website", 
              "podc_twitter",
              "podc_facebook",
              "podc_youtube",
              "podc_instagram",
              "podc_tiktok",
              "podc_mastodon",
              --"podc_donate", 
              "podc_contact_email",
              "podc_descriptive_tags"
              }

function ultraschall.GetSetPodcast_MetaData(is_set, attributename, additional_attribute, content, preset_slot)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetSetPodcast_MetaData</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.20
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string content, optional string presetcontent = ultraschall.GetSetPodcast_MetaData(boolean is_set, string attributename, string content, optional integer preset_slot)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Will get/set metadata-attributes for a podcast.
    
    This is about the podcast globally, NOT the individual episodes.
    
         "podc_title" - the title of the podcast
         "podc_description" - a description for your podcast
         "podc_website" - either one url or a list of website-urls of the podcast,separated by newlines
         "podc_contact_email" - an email-address that can be used to contact the podcasters
         "podc_twitter" - twitter-profile of the podcast
         "podc_facebook" - facebook-page of the podcast
         "podc_youtube" - youtube-channel of the podcast
         "podc_instagram" - instagram-channel of the podcast
         "podc_tiktok" - tiktok-channel of the podcast
         "podc_mastodon" - mastodon-channel of the podcast
         "podc_descriptive_tags" - some tags, who describe the podcast, must separated by newlines
    
    For episode's-metadata, use [GetSetPodcastEpisode\_MetaData](#GetSetPodcastEpisode_MetaData)
    
    preset-values will be stored into ressourcepath/ultraschall_podcast_presets.ini
        
    returns false in case of an error
  </description>
  <parameters>
    boolean is_set - true, set the attribute; false, retrieve the current content
    string attributename - the attributename you want to get/set
    string additional_attribute - some attributes allow additional attributes to be set; in all other cases set to ""
                                - when attribute="podcast_website", set this to a number, 1 and higher, which will index possibly multiple websites you have for your podcast
                                -                                 use 1 for the main-website
    string content - the new contents to set the attribute
    optional integer preset_slot - the slot in the podcast-presets to get/set the value from/to; nil, no preset used
  </parameters>
  <retvals>
    boolean retval - true, if the attribute exists/could be set; false, if not or an error occurred
    string content - the content of a specific attribute
    optional string presetcontent - the content of the preset's value in the preset_slot
  </retvals>
  <chapter_context>
    Metadata Management
    Podcast Metadata
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>metadata, get, set, podcast, attributes</tags>
</US_DocBloc>
]]
  -- check for errors in parameter-values
  if type(is_set)~="boolean" then ultraschall.AddErrorMessage("GetSetPodcast_MetaData", "is_set", "must be a boolean", -1) return false end  
  if preset~=nil and math.type(preset)~="integer" then ultraschall.AddErrorMessage("GetSetPodcast_MetaData", "preset", "must be either nil or an integer", -2) return false end    
  if preset~=nil and preset<=0 then ultraschall.AddErrorMessage("GetSetPodcast_MetaData", "preset", "must be higher than 0", -3) return false end 
  if type(attributename)~="string" then ultraschall.AddErrorMessage("GetSetPodcast_MetaData", "attributename", "must be a string", -4) return false end  
  if is_set==true and type(content)~="string" then ultraschall.AddErrorMessage("GetSetPodcast_MetaData", "content", "must be a string", -5) return false end  
  if type(additional_attribute)~="string" then ultraschall.AddErrorMessage("GetSetPodcast_MetaData", "additional_attribute", "must be a string", -6) return false end
  
  -- check, if passed attributes are supported
  local tags=ultraschall.PodcastAttributes
  
  local found=false
  for i=1, #tags do
    if attributename==tags[i] then
      found=true
      break
    end
  end
  
  local retval
  
  -- management additional additional attributes for some attributes
  if attributename=="podcast_feed" then
    if additional_attribute:lower()~="mp3" and
       additional_attribute:lower()~="aac" and
       additional_attribute:lower()~="opus" and
       additional_attribute:lower()~="ogg" and
       additional_attribute:lower()~="flac"
      then
      ultraschall.AddErrorMessage("GetSetPodcast_MetaData", "additional_attribute", "attributename \"podcast_feed\" needs content_attibute being set to the audioformat(mp3, ogg, opus, aac, flac)", -10) 
      return false 
    elseif additional_attribute~="" then
      additional_attribute="_"..additional_attribute
    end
  elseif attributename=="podcast_website" then
    print(attributename.." "..tostring(math.tointeger(additional_attribute)).." "..additional_attribute)
    if math.tointeger(additional_attribute)==nil or math.tointeger(additional_attribute)<1 then
      ultraschall.AddErrorMessage("GetSetPodcast_MetaData", "additional_attribute", "attributename \"podcast_website\" needs content_attibute being set to an integer >=1(as counter for potentially multiple websites of the podcast)", -11) 
      return false 
    elseif additional_attribute~="" then
      additional_attribute="_"..additional_attribute
    end
  elseif attributename=="podcast_donate" then
    if math.tointeger(additional_attribute)==nil or math.tointeger(additional_attribute)<1 then
      ultraschall.AddErrorMessage("GetSetPodcast_MetaData", "additional_attribute", "attributename \"podcast_donate\" needs content_attibute being set to an integer >=1(as counter for potentially multiple websites of the podcast)", -12) 
      return false 
    elseif additional_attribute~="" then
      additional_attribute="_"..additional_attribute
    end
  else
    additional_attribute=""
  end
  
  if found==false then ultraschall.AddErrorMessage("GetSetPodcast_MetaData", "attributename", "attributename not supported", -7) return false end
  local presetcontent, _
  --if attributename=="image_content" and content:sub(1,6)~="ÿØÿ" and content:sub(2,4)~="PNG" then ultraschall.AddErrorMessage("GetSetShownoteMarker_Attributes", "content", "image_content: only png and jpg are supported", -6) return false end
  
  if is_set==true then
    -- set state
    if preset_slot~=nil then
      retval = ultraschall.SetUSExternalState("PodcastMetaData_"..preset_slot, attributename..additional_attribute, content, "ultraschall_podcast_presets.ini")
      if retval==false then ultraschall.AddErrorMessage("GetSetPodcast_MetaData", "", "can not write to ultraschall_podcast_presets.ini", -8) return false end
      presetcontent=content
    else
      presetcontent=nil      
    end
    reaper.SetProjExtState(0, "PodcastMetaData", attributename, content)
  else
    -- get state
    if preset_slot~=nil then
      local old_errorcounter = ultraschall.CountErrorMessages()
      presetcontent=ultraschall.GetUSExternalState("PodcastMetaData_"..preset_slot, attributename, "ultraschall_podcast_presets.ini")
      if old_errorcounter~=ultraschall.CountErrorMessages() then
        ultraschall.AddErrorMessage("GetSetPodcast_MetaData", "", "can not retrieve value from ultraschall_podcast_presets.ini", -9)
        return false
      end
    end
    _, content=reaper.GetProjExtState(0, "PodcastMetaData", attributename)
  end
  return true, content, presetcontent
end

ultraschall.EpisodeAttributes={"epsd_title", 
              "epsd_sponsor",
              "epsd_sponsor_url",
              "epsd_number",
              "epsd_season", 
              "epsd_release_date",
              "epsd_release_time",
              "epsd_release_timezone",
              "epsd_tagline",
              "epsd_description",
              "epsd_cover",
              "epsd_language", 
              "epsd_explicit",
              "epsd_descriptive_tags",
              "epsd_content_notification_tags",
              "epsd_url",
              }

function ultraschall.GetSetPodcastEpisode_MetaData(is_set, attributename, additional_attribute, content, preset_slot)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetSetPodcastEpisode_MetaData</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.02
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string content, optional string presetcontent = ultraschall.GetSetPodcastEpisode_MetaData(boolean is_set, string attributename, string content, optional integer preset_slot)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Will get/set metadata-attributes for a podcast-episode.
    
    This is about the individual podcast-episode, NOT the global podcast itself..
    
    For podcast's-metadata, use [GetSetPodcast\_MetaData](#GetSetPodcast_MetaData)
    
    preset-values will be stored into ressourcepath/ultraschall_podcast_presets.ini
        
    returns false in case of an error
  </description>
  <parameters>
    boolean is_set - true, set the attribute; false, retrieve the current content
    string attributename - the attributename you want to get/set
                         - supported attributes are:
                         - "epsd_title" - the title of the episode
                         - "epsd_number" - the number of the episode
                         - "epsd_season" - the season of the episode
                         - "epsd_release_date" - releasedate of the episode; yyyy-mm-dd
                         - "epsd_release_time" - releasedate of the episode; hh:mm:ss
                         - "epsd_release_timezone" - the time's timezone in UTC of the release-time
                         - "epsd_tagline" - the tagline of the episode
                         - "epsd_description" - the descriptionof the episode
                         - "epsd_cover" - the cover-image of the episode(path+filename)
                         - "epsd_language" - the language of the episode; Languagecode according to ISO639
                         - "epsd_explicit" - yes, if explicit; no, if not explicit
                         - "epsd_descriptive_tags" - some tags, that describe the content of the episode, must separated by newlines
                         - "epsd_sponsor" - the name of the sponsor of this episode
                         - "epsd_sponsor_url" - a link to the sponsor's website
                         - "epsd_content_notification_tags" - some tags, that warn of specific content; must be separated by newlines!
    string additional_attribute - some attributes allow additional attributes to be set; in all other cases set to ""
    string content - the new contents to set the attribute
    optional integer preset_slot - the slot in the podcast-presets to get/set the value from/to; nil, no preset used
  </parameters>
  <retvals>
    boolean retval - true, if the attribute exists/could be set; false, if not or an error occurred
    string content - the content of a specific attribute
    optional string presetcontent - the content of the preset's value in the preset_slot
  </retvals>
  <chapter_context>
    Metadata Management
    Podcast Metadata
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>metadata, get, set, podcast, episode, attributes</tags>
</US_DocBloc>
]]
  -- check for errors in parameter-values
  if type(is_set)~="boolean" then ultraschall.AddErrorMessage("GetSetPodcastEpisode_MetaData", "is_set", "must be a boolean", -1) return false end  
  if preset~=nil and math.type(preset)~="integer" then ultraschall.AddErrorMessage("GetSetPodcastEpisode_MetaData", "preset", "must be either nil or an integer", -2) return false end    
  if preset~=nil and preset<=0 then ultraschall.AddErrorMessage("GetSetPodcastEpisode_MetaData", "preset", "must be higher than 0", -3) return false end 
  if type(attributename)~="string" then ultraschall.AddErrorMessage("GetSetPodcastEpisode_MetaData", "attributename", "must be a string", -4) return false end  
  if is_set==true and type(content)~="string" then ultraschall.AddErrorMessage("GetSetPodcastEpisode_MetaData", "content", "must be a string", -5) return false end  
  if type(additional_attribute)~="string" then ultraschall.AddErrorMessage("GetSetPodcastEpisode_MetaData", "additional_attribute", "must be a string", -6) return false end
  
  -- check, if passed attributes are supported
  local tags=ultraschall.EpisodeAttributes
  
  local found=false
  for i=1, #tags do
    if attributename==tags[i] then
      found=true
      break
    end
  end
  
  local retval
  
  -- management additional additional attributes for some attributes(currently not used, so I keep some defaults in here)
  --[[
  if attributename=="podcast_feed" then
    if additional_attribute:lower()~="mp3" and
       additional_attribute:lower()~="aac" and
       additional_attribute:lower()~="opus" and
       additional_attribute:lower()~="ogg" and
       additional_attribute:lower()~="flac"
       then
      ultraschall.AddErrorMessage("GetSetPodcastEpisode_MetaData", "additional_attribute", "attributename \"podcast_feed\" needs content_attibute being set to the audioformat(mp3, ogg, opus, aac, flac)", -10) 
      return false 
    elseif additional_attribute~="" then
      additional_attribute="_"..additional_attribute
    end
  elseif attributename=="podcast_website" then
    if math.tointeger(additional_attribute)==nil or math.tointeger(additional_attribute)<1 then
      ultraschall.AddErrorMessage("GetSetPodcastEpisode_MetaData", "additional_attribute", "attributename \"podcast_website\" needs content_attibute being set to an integer >=1(as counter for potentially multiple websites of the podcast)", -11) 
      return false 
    elseif additional_attribute~="" then
      additional_attribute="_"..additional_attribute
    end
  elseif attributename=="podcast_donate" then
    if math.tointeger(additional_attribute)==nil or math.tointeger(additional_attribute)<1 then
      ultraschall.AddErrorMessage("GetSetPodcastEpisode_MetaData", "additional_attribute", "attributename \"podcast_donate\" needs content_attibute being set to an integer >=1(as counter for potentially multiple websites of the podcast)", -11) 
      return false 
    elseif additional_attribute~="" then
      additional_attribute="_"..additional_attribute
    end
  else
    additional_attribute=""
  end
  --]]
  
  if found==false then ultraschall.AddErrorMessage("GetSetPodcastEpisode_MetaData", "attributename", "attributename not supported", -7) return false end
  local presetcontent, _
  --if attributename=="image_content" and content:sub(1,6)~="ÿØÿ" and content:sub(2,4)~="PNG" then ultraschall.AddErrorMessage("GetSetShownoteMarker_Attributes", "content", "image_content: only png and jpg are supported", -6) return false end
  
  if is_set==true then
    -- set state
    if preset_slot~=nil then
      retval = ultraschall.SetUSExternalState("EpisodeMetaData_"..preset_slot, attributename..additional_attribute, content, "ultraschall_podcast_presets.ini")
      if retval==false then ultraschall.AddErrorMessage("GetSetPodcastEpisode_MetaData", "", "can not write to ultraschall_podcast_presets.ini", -8) return false end
      presetcontent=content
    else
      presetcontent=nil      
    end
    reaper.SetProjExtState(0, "EpisodeMetaData", attributename, content)
  else
    -- get state
    if preset_slot~=nil then
      local old_errorcounter = ultraschall.CountErrorMessages()
      presetcontent=ultraschall.GetUSExternalState("EpisodeMetaData_"..preset_slot, attributename, "ultraschall_podcast_presets.ini")
      if old_errorcounter~=ultraschall.CountErrorMessages() then
        ultraschall.AddErrorMessage("GetSetPodcastEpisode_MetaData", "", "can not retrieve value from ultraschall_podcast_presets.ini", -9)
        return false
      end
    end
    _, content=reaper.GetProjExtState(0, "EpisodeMetaData", attributename)
  end
  return true, content, presetcontent
end


function ultraschall.GetPodcastShownote_MetaDataEntry(shownote_idx, shownote_index_in_metadata, offset)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetPodcastShownote_MetaDataEntry</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.43
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string shownote_entry = ultraschall.GetPodcastShownote_MetaDataEntry(integer shownote_idx, integer shownote_index_in_metadata, number offset)</functioncall>
  <description>
    returns the metadata-entry of a shownote
    
    The offset allows to offset the starttimes of a shownote-marker. 
    For instance, for files that aren't rendered from projectstart but from position 33.44, this position should be passed as offset
    so the shownote isn't at the wrong position.
    
    Also helpful for podcasts rendered using region-rendering.    

    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, shownote returned; false, shownote not returned
    string shownote_entry - the created shownote-entry for this shownote, according to PODCAST_METADATA:"v1"-standard
  </retvals>
  <parameters>
    integer shownote_idx - the index of the shownote to return
    integer shownote_index_in_metadata - the index, that shall be inserted into the metadata
                                       - this is for cases, where shownote #4 would be the first shownote in the file(region-rendering),
                                       - so you would want it indexed as shownote 1 NOT shownote 4.
                                       - in that case, set this parameter to 1, wheras shownote_idx would be 4
                                       - 
                                       - If you render out the project before the first shownote and after the last one(entire project), 
                                       - simply make shownote_idx=shownote_index_in_metadata
    number offset - the offset in seconds to subtract from the shownote-position(see description for details); set to 0 for no offset; must be 0 or higher
  </parameters>  
  <chapter_context>
     Rendering Projects
     Ultraschall
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Render_Module.lua</source_document>
  <tags>marker management, get, shownote, reaper metadata</tags>
</US_DocBloc>
]]
  if math.type(shownote_idx)~="integer" then ultraschall.AddErrorMessage("GetPodcastShownote_MetaDataEntry", "shownote_idx", "must be an integer", -1) return false end
  if shownote_idx<0 then ultraschall.AddErrorMessage("GetPodcastShownote_MetaDataEntry", "shownote_idx", "must be bigger than 0", -2) return false end
  if math.type(shownote_index_in_metadata)~="integer" then ultraschall.AddErrorMessage("GetPodcastShownote_MetaDataEntry", "shownote_index_in_metadata", "must be an integer", -3) return false end
  if shownote_index_in_metadata<0 then ultraschall.AddErrorMessage("GetPodcastShownote_MetaDataEntry", "shownote_index_in_metadata", "must be bigger than 0", -4) return false end
  
  if type(offset)~="number" then ultraschall.AddErrorMessage("GetPodcastShownote_MetaDataEntry", "offset", "must be a number", -5) return false end
  if offset<0 then ultraschall.AddErrorMessage("GetPodcastShownote_MetaDataEntry", "offset", "must be bigger than 0", -6) return false end
  local retval, marker_index, pos, name, shown_number, guid = ultraschall.EnumerateShownoteMarkers(shownote_idx)
  if retval==false then ultraschall.AddErrorMessage("GetPodcastShownote_MetaDataEntry", "shownote_idx", "no such shownote", -7) return false end
  
  -- WARNING!! CHANGES HERE MUST REFLECT CHANGES IN GetSetShownoteMarker_Attributes() !!!
  local Tags=ultraschall.ShowNoteAttributes
  
  pos=pos-offset
  if pos<0 then ultraschall.AddErrorMessage("GetPodcastShownote_MetaDataEntry", "offset", "shownote-position minus offset is smaller than 0", -8) return false end
  name=string.gsub(name, "\\", "\\\\")
  name=string.gsub(name, "\"", "\\\"")
  --name=string.gsub(name, "\n", "\\n")

  local Shownote_String="  pos:\""..pos.."\" \n  title:\""..name.."\" "
  local temp, retval, gap

  for i=1, #Tags do    
    retval, temp = ultraschall.GetSetShownoteMarker_Attributes(false, shownote_idx, Tags[i], "")
    gap=""
    for a=0, Tags[i]:len() do
     gap=gap.." "
    end
    if temp==nil or retval==false then 
      temp="" 
    else 
      temp=string.gsub(temp, "\r", "")
      temp=string.gsub(temp, "\"", "\\\"")
      temp=string.gsub(temp, "\n", "\"\n  "..gap.."\"")
      
      temp="\n  "..Tags[i]..":\""..temp.."\"" 
      temp=temp.." "
    end
      
    Shownote_String=Shownote_String..temp
  end


  Shownote_String="PODCAST_SHOWNOTE:\"BEG\"\n  idx:\""..shownote_index_in_metadata.."\"\n"..Shownote_String.."\nPODCAST_SHOWNOTE:\"END\""
  --print2(Shownote_String)
  
  return true, Shownote_String
end

ultraschall.ChapterAttributes={"chap_description",
              "chap_url",
              "chap_image",
              "chap_image_description",
              "chap_image_license",
              "chap_image_origin",
              "chap_image_url",
              "chap_descriptive_tags",
              "chap_is_advertisement",
              "chap_content_notification_tags"
              }


function ultraschall.GetSetChapterMarker_Attributes(is_set, idx, attributename, content)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetSetChapterMarker_Attributes</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string content = ultraschall.GetSetChapterMarker_Attributes(boolean is_set, integer idx, string attributename, string content)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Will get/set additional attributes of a chapter-marker.
        
    returns false in case of an error
  </description>
  <parameters>
    boolean is_set - true, set the attribute; false, retrieve the current content
    integer idx - the index of the chapter-marker, whose attribute you want to get
    string attributename - the attributename you want to get/set
                         - supported attributes are:
                         - "chap_url",
                         - "chap_description" - a description of the content of this chapter
                         - "chap_is_advertisement" - yes, if this chapter is an ad; "", to unset it
                         - "chap_image" - the content of the chapter-image, either png or jpg
                         - "chap_image_description" - a description for the chapter-image
                         - "chap_image_license" - the license of the chapter-image
                         - "chap_image_origin" - the origin of the chapterimage, like an institution or similar 
                         - "chap_image_url" - the url that links to the chapter-image
                         - "chap_descriptive_tags" - some tags, that describe the chapter-content, must separated by newlines
                         - "chap_content_notification_tags" - some tags, that warn of specific content; must be separated by newlines!
    string content - the new contents to set the attribute with
  </parameters>
  <retvals>
    boolean retval - true, if the attribute exists/could be set; false, if not or an error occurred
    string content - the content of a specific attribute
  </retvals>
  <chapter_context>
    Markers
    Chapter Marker
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>marker management, get, set, attribute, chapter, url</tags>
</US_DocBloc>
]]
-- TODO: check for chapter-image-content, if it's png or jpg!!
--       is the code still existing in shownote images so I can copy it?
  if type(is_set)~="boolean" then ultraschall.AddErrorMessage("GetSetChapterMarker_Attributes", "is_set", "must be a boolean", -1) return false end  
  if math.type(idx)~="integer" then ultraschall.AddErrorMessage("GetSetChapterMarker_Attributes", "idx", "must be an integer", -2) return false end  
  if type(attributename)~="string" then ultraschall.AddErrorMessage("GetSetChapterMarker_Attributes", "attributename", "must be a string", -3) return false end  
  if is_set==true and type(content)~="string" then ultraschall.AddErrorMessage("GetSetChapterMarker_Attributes", "content", "must be a string", -4) return false end  
  
  local tags=ultraschall.ChapterAttributes
  
  local found=false
  for i=1, #tags do
    if attributename==tags[i] then
      found=true
      break
    end
  end
  
  if attributename=="chap_url" then attributename="url" end
  
  if found==false then ultraschall.AddErrorMessage("GetSetChapterMarker_Attributes", "attributename", "attributename not supported", -7) return false end
  idx=ultraschall.EnumerateNormalMarkers(idx)
  
  if is_set==false then
    return true, ultraschall.GetMarkerExtState(idx, attributename)  
  elseif is_set==true then
    return ultraschall.SetMarkerExtState(idx, attributename, content)~=-1, content
  end
end

function ultraschall.PrepareChapterMarkers4ReaperExport()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>PrepareChapterMarkers4ReaperExport</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.20
    Lua=5.3
  </requires>
  <functioncall>ultraschall.PrepareChapterMarkers4ReaperExport()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Will add CHAP= to the beginning of each chapter-marker name. This will let Reaper embed this marker into the exported
    media-file as metadata, when rendering.
    
    Will add CHAP= only to chapter-markers, who do not already have that in their name.
  </description>
  <chapter_context>
    Markers
    Chapter Marker
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>marker management, prepare, chapter, export</tags>
</US_DocBloc>
]]
  local A,B=ultraschall.GetAllNormalMarkers()
  for i=1, A do
    if B[i][1]:sub(1,5)~="CHAP=" then
      ultraschall.SetNormalMarker(i, B[i][0], B[i][3], "CHAP="..B[i][1])
    end
  end
end

--ultraschall.PrepareChapterMarkers4ReaperExport()

function ultraschall.RestoreChapterMarkersAfterReaperExport()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>RestoreChapterMarkersAfterReaperExport</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.20
    Lua=5.3
  </requires>
  <functioncall>ultraschall.RestoreChapterMarkersAfterReaperExport()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Will remove CHAP= at the beginning of each chapter-marker name, so you have the original marker-names back after render-export.
    
    Will remove only CHAP= from chapter-markers and leave the rest untouched.
  </description>
  <chapter_context>
    Markers
    Chapter Marker
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>marker management, restore, chapter, export</tags>
</US_DocBloc>
]]
  local A,B=ultraschall.GetAllNormalMarkers()
  for i=1, A do
    if B[i][1]:sub(1,5)=="CHAP=" then
      ultraschall.SetNormalMarker(i, B[i][0], B[i][3], B[i][1]:sub(6,-1))
    end
  end
end

--ultraschall.RestoreChapterMarkersAfterReaperExport()


function ultraschall.GetSetPodcastExport_Attributes_String(is_set, attribute, value)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetSetPodcastExport_Attributes_String</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.20
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string content = ultraschall.GetSetPodcastExport_Attributes_String(boolean is_set, string attributename, string content)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Will get/set attributes for podcast-export.
    
    Unset-values will be returned as "" when is_set=false
    
    returns false in case of an error
  </description>
  <parameters>
    boolean is_set - true, set the attribute; false, retrieve the current content
    string attributename - the attributename you want to get/set
                         - supported attributes are:
                         - "output_mp3" - the renderstring of mp3
                         - "output_opus" - the renderstring of opus
                         - "output_ogg" - the renderstring of ogg
                         - "output_wav" - the renderstring of wav
                         - "output_wav_multitrack" - the renderstring of wav-multitrack
                         - "output_flac" - the renderstring of flac
                         - "output_flac_multitrack" - the renderstring of flac-multitrack
                         - "path" - the render-output-path
                         - "filename" - the filename of the rendered file
    string content - the new contents to set the attribute with
  </parameters>
  <retvals>
    boolean retval - true, if the attribute exists/could be set; false, if not or an error occurred
    string content - the content of a specific attribute
  </retvals>
  <chapter_context>
     Rendering Projects
     Ultraschall
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Render_Module.lua</source_document>
  <tags>render management, get, set, attribute, export, string</tags>
</US_DocBloc>
]]
  if type(is_set)~="boolean" then ultraschall.AddErrorMessage("GetSetPodcastExport_Attributes_String", "is_set", "must be a boolean", -1) return false end  
  if type(attribute)~="string" then ultraschall.AddErrorMessage("GetSetPodcastExport_Attributes_String", "attributename", "must be a string", -2) return false end  
  if is_set==true and type(value)~="string" then ultraschall.AddErrorMessage("GetSetPodcastExport_Attributes_String", "value", "must be a string", -3) return false end  
  
  local tags={"output_mp3",
              "output_opus",
              "output_ogg",
              "output_wav",
              "output_wav_multitrack",
              "output_flac",
              "output_flac_multitrack",
              "path",
              "filename"
                          }
  local found=false
  for i=1, #tags do
    if attributename==tags[i] then
      found=true
      break
    end
  end
  
  local _retval
  
  if is_set==false then
    _retval, value=reaper.GetProjExtState(0, "Ultraschall_Podcast_Render_Attributes", attribute)
  elseif is_set==true then
    -- validation checks
    if attribute=="path" and ultraschall.DirectoryExists2(value)==false then
      ultraschall.AddErrorMessage("GetSetPodcastExport_Attributes_String", "value", "path: not a valid path", -4)
    else
      if value:sub(-1,-1)~=ultraschall.Separator then
        value=value..ultraschall.Separator
      end
    end
    if attribute=="output_mp3" and ultraschall.GetRenderCFG_Settings_MP3(value)==-1 then ultraschall.AddErrorMessage("GetSetPodcastExport_Attributes_String", "value", "output_mp3: not a valid mp3-renderstring", -20) return false end  
    if attribute=="output_opus" and ultraschall.GetRenderCFG_Settings_OPUS(value)==-1 then ultraschall.AddErrorMessage("GetSetPodcastExport_Attributes_String", "value", "output_opus: not a valid opus-renderstring", -21) return false end  
    if attribute=="output_ogg" and ultraschall.GetRenderCFG_Settings_OGG(value)==-1 then ultraschall.AddErrorMessage("GetSetPodcastExport_Attributes_String", "value", "output_ogg: not a valid ogg-renderstring", -22) return false end  
    if attribute=="output_wav" and ultraschall.GetRenderCFG_Settings_WAV(value)==-1 then ultraschall.AddErrorMessage("GetSetPodcastExport_Attributes_String", "value", "output_wav: not a valid wav-renderstring", -23) return false end  
    if attribute=="output_wav_multitrack" and ultraschall.GetRenderCFG_Settings_WAV(value)==-1 then ultraschall.AddErrorMessage("GetSetPodcastExport_Attributes_String", "value", "output_wav_multitrack: not a valid wav-renderstring", -23) return false end  
    if attribute=="output_flac" and ultraschall.GetRenderCFG_Settings_FLAC(value)==-1 then ultraschall.AddErrorMessage("GetSetPodcastExport_Attributes_String", "value", "output_flac: not a valid flac-renderstring", -24) return false end  
    if attribute=="output_flac_multitrack" and ultraschall.GetRenderCFG_Settings_FLAC(value)==-1 then ultraschall.AddErrorMessage("GetSetPodcastExport_Attributes_String", "value", "output_flac_multitrack: not a valid flac-renderstring", -24) return false end  
    _retval=reaper.SetProjExtState(0, "Ultraschall_Podcast_Render_Attributes", attribute, value)
  end
  
  return true, value
end

function ultraschall.GetSetPodcastExport_Attributes_Value(is_set, attribute, value)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetSetPodcastExport_Attributes_Value</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.20
    Lua=5.3
  </requires>
  <functioncall>boolean retval, number content = ultraschall.GetSetPodcastExport_Attributes_Value(boolean is_set, string attributename, number content)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Will get/set attributes for podcast-export.
    
    Unset-values will be returned as -1 when is_set=false
    
    returns false in case of an error
  </description>
  <parameters>
    boolean is_set - true, set the attribute; false, retrieve the current content
    string attributename - the attributename you want to get/set
                         - supported attributes are:
                         - "mono_stereo" - 0, export as mono-file; 1, export as stereo-file
                         - "add_rendered_files_to_tracks" - 0, don't add rendered files to project; 1, add rendered files to project
                         - "start_time" - the start-time of the area to render
                         - "end_time" - the end-time of the area to render
    number content - the new contents to set the attribute with
  </parameters>
  <retvals>
    boolean retval - true, if the attribute exists/could be set; false, if not or an error occurred
    number content - the content of a specific attribute
  </retvals>
  <chapter_context>
     Rendering Projects
     Ultraschall
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Render_Module.lua</source_document>
  <tags>render management, get, set, attribute, export, value</tags>
</US_DocBloc>
]]
  if type(is_set)~="boolean" then ultraschall.AddErrorMessage("GetSetPodcastExport_Attributes_Value", "is_set", "must be a boolean", -1) return false end  
  if type(attribute)~="string" then ultraschall.AddErrorMessage("GetSetPodcastExport_Attributes_Value", "attributename", "must be a string", -2) return false end  
  if is_set==true and type(value)~="number" then ultraschall.AddErrorMessage("GetSetPodcastExport_Attributes_Value", "value", "must be a number", -3) return false end  
  
  local tags={"mono_stereo",
              "add_rendered_files_to_tracks",
              "start_time",
              "end_time"
                          }
  local found=false
  for i=1, #tags do
    if attributename==tags[i] then
      found=true
      break
    end
  end
  
  local _retval
  
  if is_set==false then
    _retval, value=reaper.GetProjExtState(0, "Ultraschall_Podcast_Render_Attributes", attribute)
    value=tonumber(value)
    if value==nil then value=-1 end
  elseif is_set==true then
    -- validation checks
    if attribute=="mono_stereo" and math.tointeger(value)==nil then ultraschall.AddErrorMessage("GetSetPodcastExport_Attributes_Value", "value", "mono_stereo: must be an integer", -4) return false end  
    if attribute=="mono_stereo" and (value<0 or value>1) then ultraschall.AddErrorMessage("GetSetPodcastExport_Attributes_Value", "value", "mono_stereo: must be between 0 and 1", -5) return false end  
    if attribute=="add_rendered_files_to_tracks" and math.tointeger(value)==nil then ultraschall.AddErrorMessage("GetSetPodcastExport_Attributes_Value", "value", "add_rendered_files_to_tracks: must be an integer", -6) return false end  
    if attribute=="add_rendered_files_to_tracks" and (value<0 or value>1) then ultraschall.AddErrorMessage("GetSetPodcastExport_Attributes_Value", "value", "add_rendered_files_to_tracks: must be between 0 and 1", -7) return false end  
    if attribute=="start_time" and value<0 then ultraschall.AddErrorMessage("GetSetPodcastExport_Attributes_Value", "value", "start_time: must be bigger than 0", -8) return false end  

    if attribute=="end_time" and value<0 then ultraschall.AddErrorMessage("GetSetPodcastExport_Attributes_Value", "end_time: value", "must be bigger than 0 and start_time", -9) return false end  
    
    _retval=reaper.SetProjExtState(0, "Ultraschall_Podcast_Render_Attributes", attribute, value)    
  end
  
  return true, value
end

function ultraschall.GetAllShownotes_MetaDataEntry(start_time, end_time, offset)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllShownotes_MetaDataEntry</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.43
    Lua=5.3
  </requires>
  <functioncall>integer number_of_shownotes, array shownote_entries = ultraschall.GetAllShownotes_MetaDataEntry(number start_time, number end_time, number offset)</functioncall>
  <description>
    gets the metadata-entries of all shownotes
    
    The offset allows to offset the starttimes of a shownote-marker. 
    For instance, for files that aren't rendered from projectstart but from position 33.44, this position should be passed as offset
    so the shownote isn't at the wrong position.
    
    Also helpful for podcasts rendered using region-rendering.
    
    returns false in case of an error
  </description>
  <retvals>
    integer number_of_shownotes - the number of added shownotes
    array shownote_entries - the individual shownote-entries
  </retvals>
  <parameters>
    number start_time - the start-time of the range, from which to get the shownotes
    number end_time - the end-time of the range, from which to get the shownotes
    number offset - the offset in seconds to subtract from the shownote-positions(see description for details); set to 0 for no offset; must be 0 or higher
  </parameters>  
  <chapter_context>
     Rendering Projects
     Ultraschall
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Render_Module.lua</source_document>
  <tags>marker management, get, all, shownote, reaper metadata</tags>
</US_DocBloc>
]]

  if type(start_time)~="number" then ultraschall.AddErrorMessage("GetAllShownotes_MetaDataEntry", "start_time", "must be a number", -1) return -1 end
  if start_time<0 then ultraschall.AddErrorMessage("GetAllShownotes_MetaDataEntry", "start_time", "must be bigger than 0", -2) return -1 end
  if type(end_time)~="number" then ultraschall.AddErrorMessage("GetAllShownotes_MetaDataEntry", "end_time", "must be a number", -3) return -1 end
  if start_time>end_time then ultraschall.AddErrorMessage("GetAllShownotes_MetaDataEntry", "end_time", "must be bigger than 0", -4) return -1 end
  
  if type(offset)~="number" then ultraschall.AddErrorMessage("GetAllShownotes_MetaDataEntry", "offset", "must be a number", -5) return -1 end
  if offset<0 then ultraschall.AddErrorMessage("GetAllShownotes_MetaDataEntry", "offset", "must be bigger than 0", -6) return -1 end
  
  local A={}
  local counter=0
  for i=1, ultraschall.CountShownoteMarkers()-1 do
    local A1, A2, pos = ultraschall.EnumerateShownoteMarkers(i)
    if pos>=start_time and pos<=end_time then
      counter=counter+1
      retval, A[#A+1]=ultraschall.GetPodcastShownote_MetaDataEntry(i, counter, offset)
    end
  end
  return #A, A
end

--A,B=ultraschall.Commit4AllShownotes_ReaperMetadata(4, 7.1, 0, true, true, true, true)


--ultraschall.RemoveAllShownotes_ReaperMetaData(true, true, true, true)


function ultraschall.GetPodcastChapter_MetaDataEntry(chapter_idx, chapter_index_in_metadata, offset)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetPodcastShownote_MetaDataEntry</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.43
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string chapter_entry = ultraschall.GetPodcastChapter_MetaDataEntry(integer chapter_idx, integer chapter_index_in_metadata, number offset)</functioncall>
  <description>
    returns the metadata-entry of a chapter
    
    The offset allows to offset the starttimes of a chapter-marker. 
    For instance, for files that aren't rendered from projectstart but from position 33.44, this position should be passed as offset
    so the chapter isn't at the wrong position.
    
    Also helpful for podcasts rendered using region-rendering.

    Note: this will include the metadata of "normal markers", that are used as chapter-markers in Ultraschall!

    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, chapter committed; false, chapter not committed
    string chapter_entry - the created chapter-entry for this chapter, according to PODCAST_METADATA:"v1"-standard
  </retvals>
  <parameters>
    integer chapter_idx - the index of the chapter to commit
    integer chapter_index_in_metadata - the index, that shall be inserted into the metadata
                                       - this is for cases, where chapter #4 would be the first chapter in the file(region-rendering),
                                       - so you would want it indexed as chapter 1 NOT chapter 4.
                                       - in that case, set this parameter to 1, wheras chapter_idx would be 4
                                       - 
                                       - If you render out the project before the first chapter and after the last one(entire project), 
                                       - simply make chapter_idx=chapter_index_in_metadata
    number offset - the offset in seconds to subtract from the chapter-position(see description for details); set to 0 for no offset; must be 0 or higher
  </parameters>  
  <chapter_context>
     Rendering Projects
     Ultraschall
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Render_Module.lua</source_document>
  <tags>marker management, get, chapter, reaper metadata</tags>
</US_DocBloc>
]]
  if math.type(chapter_idx)~="integer" then ultraschall.AddErrorMessage("GetPodcastChapter_MetaDataEntry", "chapter_idx", "must be an integer", -1) return false end
  if chapter_idx<0 then ultraschall.AddErrorMessage("GetPodcastChapter_MetaDataEntry", "chapter_idx", "must be bigger than 0", -2) return false end
  if math.type(chapter_index_in_metadata)~="integer" then ultraschall.AddErrorMessage("GetPodcastChapter_MetaDataEntry", "chapter_index_in_metadata", "must be an integer", -3) return false end
  if chapter_index_in_metadata<0 then ultraschall.AddErrorMessage("GetPodcastChapter_MetaDataEntry", "chapter_index_in_metadata", "must be bigger than 0", -4) return false end
  
  if type(offset)~="number" then ultraschall.AddErrorMessage("GetPodcastChapter_MetaDataEntry", "offset", "must be a number", -5) return false end
  if offset<0 then ultraschall.AddErrorMessage("GetPodcastChapter_MetaDataEntry", "offset", "must be bigger than 0", -6) return false end
  local retval, marker_index, pos, name, shown_number, color, guid = ultraschall.EnumerateNormalMarkers(chapter_idx)
  if retval==false then ultraschall.AddErrorMessage("GetPodcastChapter_MetaDataEntry", "chapter_idx", "no such chapter", -7) return false end
  
  -- WARNING!! CHANGES HERE MUST REFLECT CHANGES IN GetSetChapterMarker_Attributes() !!!
  local Tags=ultraschall.ChapterAttributes
  
  pos=pos-offset
  if pos<0 then ultraschall.AddErrorMessage("GetPodcastChapter_MetaDataEntry", "offset", "chapter-position minus offset is smaller than 0", -8) return false end
  name=string.gsub(name, "\\", "\\\\")
  name=string.gsub(name, "\"", "\\\"")

  local Chapter_String="  pos:\""..pos.."\" \n  title:\""..name.."\" "
  local temp, retval, gap

  for i=1, #Tags do
    local retval, temp = ultraschall.GetSetChapterMarker_Attributes(false, chapter_idx, Tags[i], "")
    gap=""
    for a=0, Tags[i]:len() do
     gap=gap.." "
    end
    if temp==nil then 
      temp="" 
    else 
      temp=string.gsub(temp, "\r", "")
      temp=string.gsub(temp, "\"", "\\\"")
      temp=string.gsub(temp, "\n", "\"\n  "..gap.."\"")

      temp="\n  "..Tags[i]..":\""..temp.."\"" 
      temp=temp.." "
    end
    
    Chapter_String=Chapter_String..temp
  end
  
  Chapter_String="PODCAST_CHAPTER:\"BEG\"\n  idx:\""..chapter_index_in_metadata.."\"\n"..Chapter_String.."\nPODCAST_CHAPTER:\"END\""
  
  return true, Chapter_String
end

function ultraschall.GetAllChapters_MetaDataEntry(start_time, end_time, offset)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllChapters_MetaDataEntry</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.43
    Lua=5.3
  </requires>
  <functioncall>integer number_of_chapters, array chapter_entries = ultraschall.GetAllChapters_MetaDataEntry(number start_time, number end_time, number offset)</functioncall>
  <description>
    gets all the metadata-entries of all chapters
    
    The offset allows to offset the starttimes of a chapter-marker. 
    For instance, for files that aren't rendered from projectstart but from position 33.44, this position should be passed as offset
    so the chapter isn't at the wrong position.
    
    Also helpful for podcasts rendered using region-rendering.
    
    Note: uses metadata stored with "normal markers", as they are used by Ultraschall for chapter-markers
    
    returns false in case of an error
  </description>
  <retvals>
    integer number_of_chapters - the number of added chapters
    array chapter_entries - the individual chapter-entries
  </retvals>
  <parameters>
    number start_time - the start-time of the range, from which to commit the chapters
    number end_time - the end-time of the range, from which to commit the chapters
    number offset - the offset in seconds to subtract from the chapter-positions(see description for details); set to 0 for no offset; must be 0 or higher
  </parameters>  
  <chapter_context>
     Rendering Projects
     Ultraschall
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Render_Module.lua</source_document>
  <tags>marker management, get, all, chapter, reaper metadata</tags>
</US_DocBloc>
]]

  if type(start_time)~="number" then ultraschall.AddErrorMessage("GetAllChapters_MetaDataEntry", "start_time", "must be a number", -1) return -1 end
  if start_time<0 then ultraschall.AddErrorMessage("GetAllChapters_MetaDataEntry", "start_time", "must be bigger than 0", -2) return -1 end
  if type(end_time)~="number" then ultraschall.AddErrorMessage("GetAllChapters_MetaDataEntry", "end_time", "must be a number", -3) return -1 end
  if start_time>end_time then ultraschall.AddErrorMessage("GetAllChapters_MetaDataEntry", "end_time", "must be bigger than 0", -4) return -1 end
  
  if type(offset)~="number" then ultraschall.AddErrorMessage("GetAllChapters_MetaDataEntry", "offset", "must be a number", -5) return -1 end
  if offset<0 then ultraschall.AddErrorMessage("GetAllChapters_MetaDataEntry", "offset", "must be bigger than 0", -6) return -1 end
  
  local A={}
  local counter=0
  for i=1, ultraschall.CountNormalMarkers() do
    local A1, A2, pos = ultraschall.EnumerateNormalMarkers(i)
    if pos>=start_time and pos<=end_time then
      counter=counter+1
      retval, A[#A+1]=ultraschall.GetPodcastChapter_MetaDataEntry(i, counter, offset)
    end
  end
  return #A, A
end

--A,B=ultraschall.GetAllChapters_MetaDataEntry(0, 1000, 0, true, true, true, true)
--B=ultraschall.CountNormalMarkers()





function ultraschall.GetGuidFromShownoteMarkerID(idx)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetGuidFromShownoteMarkerID</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>string guid = ultraschall.GetGuidFromShownoteMarkerID(integer index)</functioncall>
  <description>
    Gets the corresponding guid of a shownote marker with a specific index 
    
    The index is for _shownote:-markers only
    
    returns -1 in case of an error
  </description>
  <retvals>
    string guid - the guid of the shownote marker of the marker with a specific index
  </retvals>
  <parameters>
    integer index - the index of the shownote marker, whose guid you want to retrieve
  </parameters>
  <chapter_context>
    Markers
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>marker management, get, shownote marker, markerid, guid</tags>
</US_DocBloc>
--]]
  if math.type(idx)~="integer" then ultraschall.AddErrorMessage("GetGuidFromShownoteMarkerID", "idx", "must be an integer", -1) return -1 end
  local retval, marker_index, pos, name, shown_number, guid2 = ultraschall.EnumerateShownoteMarkers(idx)

  return guid2
end


--A=ultraschall.GetGuidFromShownoteMarkerID(1)
--B={ultraschall.EnumerateShownoteMarkers(1)}
--SLEM()

function ultraschall.GetShownoteMarkerIDFromGuid(guid)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetShownoteMarkerIDFromGuid</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer index = ultraschall.GetShownoteMarkerIDFromGuid(string guid)</functioncall>
  <description>
    Gets the corresponding indexnumber of a shownote-marker-guid
    
    The index is for all _shownote:-markers only.
    
    returns -1 in case of an error
  </description>
  <retvals>
    integer index - the index of the shownote-marker, whose guid you have passed to this function
  </retvals>
  <parameters>
    string guid - the guid of the shownote-marker, whose index-number you want to retrieve
  </parameters>
  <chapter_context>
    Markers
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>marker management, get, shownote marker, markerid, guid</tags>
</US_DocBloc>
--]]
  if type(guid)~="string" then ultraschall.AddErrorMessage("GetShownoteMarkerIDFromGuid", "guid", "must be a string", -1) return -1 end  
  for i=0, ultraschall.CountShownoteMarkers() do
    local retval, marker_index, pos, name, shown_number, guid2 = ultraschall.EnumerateShownoteMarkers(i)
    if guid2==guid then return i end
  end
  return guid2
end

--B=ultraschall.GetShownoteMarkerIDFromGuid(A)



function ultraschall.SetPodcastMetadataPreset_Name(preset_slot, preset_name)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetPodcastMetadataPreset_Name</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.20
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetPodcastMetadataPreset_Name(integer preset_slot, string preset_name)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Sets the name of a podcast-metadata-preset
        
    Note, this sets only the presetname for the podcast-metadata-preset. To set the name of the podcast-episode-metadata-preset, see: [SetPodcastEpisodeMetadataPreset\_Name}(#SetPodcastEpisodeMetadataPreset_Name)
        
    returns false in case of an error
  </description>
  <parameters>
    integer preset_slot - the preset-slot, whose name you want to set
    string preset_name - the new name of the preset
  </parameters>
  <retvals>
    boolean retval - true, if setting the name was successful; false, if setting the name was unsuccessful
  </retvals>
  <chapter_context>
    Metadata Management
    Podcast Metadata
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>metadata, set, podcast, metadata, preset, name</tags>
</US_DocBloc>
]]
  if math.type(preset_slot)~="integer" then ultraschall.AddErrorMessage("SetPodcastMetadataPreset_Name", "preset_slot", "must be an integer", -1) return false end
  if preset_slot<1 then ultraschall.AddErrorMessage("SetPodcastMetadataPreset_Name", "preset_slot", "must be bigger or equal 1", -2) return false end
  if type(preset_name)~="string" then ultraschall.AddErrorMessage("SetPodcastMetadataPreset_Name", "preset_name", "must be a string", -3) return false end
  
  local retval = ultraschall.SetUSExternalState("PodcastMetaData_"..preset_slot, "Preset_Name", preset_name, "ultraschall_podcast_presets.ini")
  if retval==false then ultraschall.AddErrorMessage("SetPodcastMetadataPreset_Name", "", "couldn't store presetname in ultraschall_podcast_presets.ini; is it accessible?", -3) return false end
end
  

--ultraschall.SetPodcastMetadataPreset_Name(1, "Atuch")

function ultraschall.GetPodcastMetadataPreset_Name(preset_slot)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetPodcastMetadataPreset_Name</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.20
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>string preset_name = ultraschall.GetPodcastMetadataPreset_Name(integer preset_slot)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Gets the name of a podcast-metadata-preset
        
    Note, this gets only the presetname for the podcast-metadata-preset. To get the name of the podcast-episode-metadata-preset, see: [GetPodcastEpisodeMetadataPreset\_Name}(#GetPodcastEpisodeMetadataPreset_Name)
        
    returns false in case of an error
  </description>
  <parameters>
    integer preset_slot - the preset-slot, whose name you want to get
  </parameters>
  <retvals>
    string preset_name - the name of the podcast-metadata-preset
  </retvals>
  <chapter_context>
    Metadata Management
    Podcast Metadata
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>metadata, get, podcast, metadata, preset, name</tags>
</US_DocBloc>
]]
  if math.type(preset_slot)~="integer" then ultraschall.AddErrorMessage("SetPodcastMetadataPreset_Name", "preset_slot", "must be an integer", -1) return false end
  if preset_slot<1 then ultraschall.AddErrorMessage("SetPodcastMetadataPreset_Name", "preset_slot", "must be bigger or equal 1", -2) return false end
  
  return ultraschall.GetUSExternalState("PodcastMetaData_"..preset_slot, "Preset_Name", "ultraschall_podcast_presets.ini")
end

--A,B=ultraschall.GetPodcastMetadataPreset_Name(1)

function ultraschall.SetPodcastEpisodeMetadataPreset_Name(preset_slot, presetname)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetPodcastEpisodeMetadataPreset_Name</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.20
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetPodcastEpisodeMetadataPreset_Name(integer preset_slot, string preset_name)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Sets the name of a podcast-episode-metadata-preset
    
    Note, this sets only the presetname for the episode-metadata-preset. To set the name of the podcast-metadata-preset, see: [SetPodcastMetadataPreset\_Name}(#SetPodcastMetadataPreset_Name)
    
    returns false in case of an error
  </description>
  <parameters>
    integer preset_slot - the preset-slot, whose name you want to set
    string preset_name - the new name of the preset
  </parameters>
  <retvals>
    boolean retval - true, if setting the name was successful; false, if setting the name was unsuccessful
  </retvals>
  <chapter_context>
    Metadata Management
    Podcast Metadata
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>metadata, set, podcast, metadata, preset, name, episode</tags>
</US_DocBloc>
]]
  if math.type(preset_slot)~="integer" then ultraschall.AddErrorMessage("SetPodcastEpisodeMetadataPreset_Name", "preset_slot", "must be an integer", -1) return false end
  if preset_slot<1 then ultraschall.AddErrorMessage("SetPodcastEpisodeMetadataPreset_Name", "preset_slot", "must be bigger or equal 1", -2) return false end
  if type(presetname)~="string" then ultraschall.AddErrorMessage("SetPodcastEpisodeMetadataPreset_Name", "preset_name", "must be a string", -3) return false end
  
  local retval = ultraschall.SetUSExternalState("Episode_"..preset_slot, "Preset_Name", presetname, "ultraschall_podcast_presets.ini")
  if retval==false then ultraschall.AddErrorMessage("SetPodcastEpisodeMetadataPreset_Name", "", "couldn't store presetname in ultraschall_podcast_presets.ini; is it accessible?", -3) return false end
  return true
end
  

--A=ultraschall.SetPodcastEpisodeMetadataPreset_Name(1, "AKullerauge sei wachsam")

function ultraschall.GetPodcastEpisodeMetadataPreset_Name(preset_slot)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetPodcastEpisodeMetadataPreset_Name</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.20
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>string preset_name = ultraschall.GetPodcastEpisodeMetadataPreset_Name(integer preset_slot)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Gets the name of a podcast-metadata-preset
        
    Note, this gets only the presetname for the episode-metadata-preset. To get the name of the podcast-metadata-preset, see: [GetPodcastMetadataPreset\_Name}(#GetPodcastMetadataPreset_Name)
        
    returns false in case of an error
  </description>
  <parameters>
    integer preset_slot - the preset-slot, whose name you want to get
  </parameters>
  <retvals>
    string preset_name - the name of the podcast-metadata-preset
  </retvals>
  <chapter_context>
    Metadata Management
    Podcast Metadata
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>metadata, get, podcast, metadata, preset, name</tags>
</US_DocBloc>
]]
  if math.type(preset_slot)~="integer" then ultraschall.AddErrorMessage("GetPodcastEpisodeMetadataPreset_Name", "preset_slot", "must be an integer", -1) return false end
  if preset_slot<1 then ultraschall.AddErrorMessage("GetPodcastEpisodeMetadataPreset_Name", "preset_slot", "must be bigger or equal 1", -2) return false end
  
  return ultraschall.GetUSExternalState("Episode_"..preset_slot, "Preset_Name", "ultraschall_podcast_presets.ini")
end

--A,B=ultraschall.GetPodcastEpisodeMetadataPreset_Name(1)

function ultraschall.GetPodcastEpisode_MetaDataEntry()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetPodcastEpisode_MetaDataEntry</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.43
    Lua=5.3
  </requires>
  <functioncall>string episode_entry = ultraschall.GetPodcastEpisode_MetaDataEntry()</functioncall>
  <description>
    Returns the podcast-metadata-standard-entry of an episode
  </description>
  <retvals>
    string episode_entry - the created podcast-episode-entry for this project, according to PODCAST_METADATA:"v1"-standard
  </retvals>
  <chapter_context>
     Rendering Projects
     Ultraschall
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Render_Module.lua</source_document>
  <tags>marker management, episode, podcast, reaper metadata</tags>
</US_DocBloc>
]]
  local Tags=ultraschall.EpisodeAttributes

  local Episode_String=""
  local temp

  for i=1, #Tags do
    local retval, temp = ultraschall.GetSetPodcastEpisode_MetaData(false, Tags[i], "", "")
        gap=""
    for a=0, Tags[i]:len() do
     gap=gap.." "
    end
    if temp==nil then 
      temp="" 
    else 
      temp=string.gsub(temp, "\r", "")
      temp=string.gsub(temp, "\"", "\\\"")
      temp=string.gsub(temp, "\n", "\"\n  "..gap.."\"")

      temp="\n  "..Tags[i]..":\""..temp.."\"" 
      temp=temp.." "
    end
      
    Episode_String=Episode_String..temp
  end


  Episode_String="PODCAST_EPISODE:\"BEG\" "..Episode_String.."\nPODCAST_EPISODE:\"END\""

  return Episode_String
end

function ultraschall.GetPodcast_MetaDataEntry()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetPodcast_MetaDataEntry</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.43
    Lua=5.3
  </requires>
  <functioncall>string podcast_entry = ultraschall.GetPodcast_MetaDataEntry()</functioncall>
  <description>
    Returns the podcast-metadata-standard-entry with the general podcast-attributes
  </description>
  <retvals>
    string podcast_entry - the created podcast-entry for this project, according to PODCAST_METADATA:"v1"-standard
  </retvals>
  <chapter_context>
     Rendering Projects
     Ultraschall
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Render_Module.lua</source_document>
  <tags>marker management, podcast, reaper metadata</tags>
</US_DocBloc>
]]
  local Tags=ultraschall.PodcastAttributes

  local Podcast_String=""
  local temp

  for i=1, #Tags do
    local retval, temp = ultraschall.GetSetPodcast_MetaData(false, Tags[i], "", "")
    gap=""
    for a=0, Tags[i]:len() do
     gap=gap.." "
    end
    if temp==nil then 
      temp="" 
    else 
      temp=string.gsub(temp, "\r", "")
      temp=string.gsub(temp, "\"", "\\\"")
      temp=string.gsub(temp, "\n", "\"\n  "..gap.."\"")

      temp="\n  "..Tags[i]..":\""..temp.."\"" 
      temp=temp.." "
    end
    
    Podcast_String=Podcast_String..temp
  end


  Podcast_String="PODCAST_GENERAL:\"BEG\" "..Podcast_String.."\nPODCAST_GENERAL:\"END\""

  return Podcast_String
end


function ultraschall.WritePodcastMetaData(start_time, end_time, offset, filename, do_id3, do_vorbis, do_ape_deactivated, do_ixml_deactivated)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>WritePodcastMetaData</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.47
    Lua=5.3
  </requires>
  <functioncall>string podcast_metadata = ultraschall.WritePodcastMetaData(number start_time, number end_time, number offset, optional string filename, optional boolean do_id3, optional boolean do_vorbis)</functioncall>
  <description>
    Creates and returns the metadata-file-entries according to PODCAST_METADATA:"v1"-standard and optionally stores it into a file and/or the accompanying metadata-schemes available.
    
    Includes shownotes and chapters as well as episode and podcast-general-metadata
    
    Note: needs Reaper 6.47 to work properly, as otherwise the metadata gets truncated to 1k!
    
    Returns nil in case of an error
  </description>
  <retvals>
    string podcast_metadata - the created podcast-metadata, according to PODCAST_METADATA:"v1"-standard
  </retvals>
  <parameters>
    number start_time - the start-time of the project, from which to include chapters/shownotes
    number end_time - the end-time of the project, up to which to include chapters/shownotes
    number offset - the offset to subtract from the chapter/shownote-positions(for time-selection/region rendering)
    optional string filename - the filename, to which to write the metadata-data as PODCAST_METADATA:"v1"-standard
    optional boolean do_id3 - add the metadata to id3(mp3)-tag-metadata scheme in Reaper's metadata-storage
    optional boolean do_vorbis - add the metadata to the vorbis(Mp3, Flac, Ogg, Opus)-metadata scheme in Reaper's metadata-storage
  </parameters>
  <chapter_context>
     Rendering Projects
     Ultraschall
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Render_Module.lua</source_document>
  <tags>marker management, write, podcast, reaper metadata, shownotes, chapters, id3, ape, vorbis, ixml</tags>
</US_DocBloc>
]]
  if type(start_time)~="number" then ultraschall.AddErrorMessage("WritePodcastMetaData", "start_time", "must be a number", -1) return end
  if start_time<0 then ultraschall.AddErrorMessage("WritePodcastMetaData", "start_time", "must be bigger than 0", -2) return end
  if type(end_time)~="number" then ultraschall.AddErrorMessage("WritePodcastMetaData", "end_time", "must be a number", -3) return end
  if start_time>end_time then ultraschall.AddErrorMessage("WritePodcastMetaData", "end_time", "must be bigger than 0", -4) return end
  
  if type(offset)~="number" then ultraschall.AddErrorMessage("WritePodcastMetaData", "offset", "must be a number", -5) return end
  if offset<0 then ultraschall.AddErrorMessage("WritePodcastMetaData", "offset", "must be bigger than 0", -6) return end
  
  if filename~=nil and type(filename)~="string" then ultraschall.AddErrorMessage("WritePodcastMetaData", "filename", "must be nil or a string", -7) return end
  
  local retval
  local PodcastGeneralMetadata=ultraschall.GetPodcast_MetaDataEntry()
  local PodcastEpisodeMetadata=ultraschall.GetPodcastEpisode_MetaDataEntry()
  local Chapter_Count,  Chapters = ultraschall.GetAllChapters_MetaDataEntry(start_time, end_time, offset)
  local Shownote_Count, Shownotes = ultraschall.GetAllShownotes_MetaDataEntry(start_time, end_time, offset)
  
  local PodcastMetadata="  "..PodcastGeneralMetadata.."\n\n"..PodcastEpisodeMetadata.."\n"
  
  for i=1, Chapter_Count do
    PodcastMetadata=PodcastMetadata.."\n"..Chapters[i].."\n"
  end
  
  for i=1, Shownote_Count do
    PodcastMetadata=PodcastMetadata.."\n"..Shownotes[i].."\n"
  end
  --"PODCAST_METADATA:\"v1\""
  
  PodcastMetadata="PODCAST_METADATA:\"v1\"\n"..string.gsub(PodcastMetadata, "\n", "\n  "):sub(1,-3).."\nPODCAST_METADATA:\"end\""
  
  if filename~=nil then 
    local errorindex = ultraschall.GetErrorMessage_Funcname("WriteValueToFile", 1)
    retval=ultraschall.WriteValueToFile(filename, PodcastMetadata)
    
    if retval==-1 then 
      local errorindex2, parmname, errormessage = ultraschall.GetErrorMessage_Funcname("WriteValueToFile", 1)
      ultraschall.AddErrorMessage("WritePodcastMetaData", "filename", errormessage, -8) 
      return 
    end
  end
  
  if do_id3==true then
    reaper.GetSetProjectInfo_String(0, "RENDER_METADATA", "ID3:TXXX:Podcast_Metadata|"..PodcastMetadata, true)
  end
  
  if do_vorbis==true then
    reaper.GetSetProjectInfo_String(0, "RENDER_METADATA", "VORBIS:USER:Podcast_Metadata|"..PodcastMetadata, true)
  end
  
  if do_ape==true then
    reaper.GetSetProjectInfo_String(0, "RENDER_METADATA", "APE:User Defined:Podcast_Metadata|"..PodcastMetadata, true)
  end
  
  if do_ixml==true then
    reaper.GetSetProjectInfo_String(0, "RENDER_METADATA", "IXML:USER:Podcast_Metadata|"..PodcastMetadata, true)
  end
  
  return PodcastMetadata
end







function ultraschall.GFX_BlitBBCodeAsText(text)
  -- example code, that parses and shows BBCode, with [b][i] and [u], even combined.
  
  -- missing: img, url, size, color
  --      maybe: indent(?), lists(bullet only)
  
  -- blit-image-destinations
  
  -- return coordinates of blitted urls and images, so they can be checked for clickable-state/tooltips
  -- by GFX_ManageBlitBBCodeElements
  
  gfx.set(1)
  local ParsedStrings={}
  local Link_Coordinates={} -- the coordinates of links currently shown
                            -- so making them "clickable" is possible
                            -- not yet filled, so this must be coded as well
  
  local step=0
  local Temp, Offset
  
  while TestString~=nil do
    step=step+1
    Temp=TestString:match("(.-)%[")
    if Temp==nil then break end
    ParsedStrings[step]={}
    ParsedStrings[step]["text"]=Temp
    TestString=TestString:sub(Temp:len(), -1)
    
    Temp, Offset = TestString:match("%[(.-)%]()")
  
    ParsedStrings[step]["layout_element"]=Temp
    TestString=TestString:sub(Offset, -1)

  end
  
  Temp=TestString:match("(.*)")
  ParsedStrings[step]={}
  ParsedStrings[step]["text"]=Temp
  ParsedStrings[step]["layout_element"]=""
  
  
  ParsedStrings[1]["bold"]=false
  ParsedStrings[1]["italic"]=false
  ParsedStrings[1]["underlined"]=false
  
  for i=1, #ParsedStrings do
    if ParsedStrings[i]["layout_element"]=="b" then
      ParsedStrings[i+1]["bold"]=true
      ParsedStrings[i+1]["italic"]=ParsedStrings[i]["italic"]
      ParsedStrings[i+1]["underlined"]=ParsedStrings[i]["underlined"]
    elseif ParsedStrings[i]["layout_element"]=="/b" then
      ParsedStrings[i+1]["bold"]=false
      ParsedStrings[i+1]["italic"]=ParsedStrings[i]["italic"]
      ParsedStrings[i+1]["underlined"]=ParsedStrings[i]["underlined"]
    elseif ParsedStrings[i]["layout_element"]=="i" then
      ParsedStrings[i+1]["italic"]=true
      ParsedStrings[i+1]["bold"]=ParsedStrings[i]["bold"]
      ParsedStrings[i+1]["underlined"]=ParsedStrings[i]["underlined"]
    elseif ParsedStrings[i]["layout_element"]=="/i" then
      ParsedStrings[i+1]["italic"]=false
      ParsedStrings[i+1]["bold"]=ParsedStrings[i]["bold"]
      ParsedStrings[i+1]["underlined"]=ParsedStrings[i]["underlined"]
    elseif ParsedStrings[i]["layout_element"]=="u" then
      ParsedStrings[i+1]["underlined"]=true
      ParsedStrings[i+1]["bold"]=ParsedStrings[i]["bold"]
      ParsedStrings[i+1]["italic"]=ParsedStrings[i]["italic"]
    elseif ParsedStrings[i]["layout_element"]=="/u" then
      ParsedStrings[i+1]["underlined"]=false
      ParsedStrings[i+1]["bold"]=ParsedStrings[i]["bold"]
      ParsedStrings[i+1]["italic"]=ParsedStrings[i]["italic"]
    end
    ParsedStrings[i]["layout_element"]=""
  end
  
  
  for i=1, #ParsedStrings do
    local layout=ultraschall.GFX_GetTextLayout(ParsedStrings[i]["bold"], ParsedStrings[i]["italic"], ParsedStrings[i]["underlined"], outline, nonaliased, inverse, rotate, rotate2)
    gfx.setfont(1, "Tahoma", 40, layout)
    if ParsedStrings[i]["text"]:match("\n")~=nil then
      local A=ParsedStrings[i]["text"].."\n"
      gfx.drawstr(A:match("(.-)\n"))
      gfx.x=0
      gfx.y=gfx.y+gfx.texth+2
      gfx.drawstr(A:match("\n(.*)"))
    else
      gfx.drawstr(ParsedStrings[i]["text"])
    end
  end
  --gfx.update()

  return Link_Coordinates
end  

  
--gfx.set(0.1)
--gfx.rect(0,0,gfx.w,gfx.h,1)
--ultraschall.GFX_BlitBBCodeAsText(TestString)



function ultraschall.GetSetTranscription_Attributes(is_set, idx, attributename, content)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetSetTranscription_Attributes</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string content = ultraschall.GetSetTranscription_Attributes(boolean is_set, integer idx, string attributename, string content)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Will get/set additional attributes of a transcription.
    
    A podcast can have multiple transcriptions in multiple languages.
    
    Note: transcriptions are not created by Ultraschall, but can be included into the mediafile at export.
          For this, the file must be present locally.
    
    Note too: all attributes must be set; though "url" can be set to "", which means, it's stored in the same location as the media file or the podcast-metadata-exchange-file
              "transcript" is optional
    
    returns false in case of an error
  </description>
  <parameters>
    boolean is_set - true, set the attribute; false, retrieve the current content
    integer idx - the index of the transcript, whose attribute you want to get; 1-based
    string attributename - the attributename you want to get/set
                         - supported attributes are:
                         - "language" - the language of the transcription
                         - "description" - a more detailed description for this transcription
                         - "url" - the url where the webvtt/srt-file is stored; can be relative to the podcast-metadata-exchange-file/mediafile
                         - "transcript" - the actual transcript-content for inclusion into the metadata of the mediafile(only srt or webvtt!)
                         - "type" - srt or webvtt
    string content - the new contents to set the attribute with
  </parameters>
  <retvals>
    boolean retval - true, if the attribute exists/could be set; false, if not or an error occurred
    string content - the content of a specific attribute
  </retvals>
  <chapter_context>
    Metadata Management
    Podcast Metadata
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>metadata, get, set, attribute, transcription</tags>
</US_DocBloc>
]]
  if type(is_set)~="boolean" then ultraschall.AddErrorMessage("GetSetTranscription_Attributes", "is_set", "must be a boolean", -1) return false end  
  if math.type(idx)~="integer" then ultraschall.AddErrorMessage("GetSetTranscription_Attributes", "idx", "must be an integer", -2) return false end    
  if type(attributename)~="string" then ultraschall.AddErrorMessage("GetSetTranscription_Attributes", "attributename", "must be a string", -3) return false end  
  if is_set==true and type(content)~="string" then ultraschall.AddErrorMessage("GetSetTranscription_Attributes", "content", "must be a string", -4) return false end  
  
  
  -- WARNING!! CHANGES HERE MUST REFLECT CHANGES IN THE CODE OF CommitShownote_ReaperMetadata() !!!
  local tags=ultraschall.TranscriptAttributes
              
  local found=false
  for i=1, #tags do
    if attributename==tags[i] then
      found=true
      break
    end
  end
  
  if found==false then ultraschall.AddErrorMessage("GetSetTranscription_Attributes", "attributename", "attributename not supported", -7) return false end
  local Retval

  if is_set==true then
    Retval = reaper.SetProjExtState(0, "PodcastMetaData_Transcript_"..idx, attributename, content)
    return true, content
  else
    Retval, content = reaper.GetProjExtState(0, "PodcastMetaData_Transcript_"..idx, attributename, content)
    return true, content
  end
end

function ultraschall.MetaDataTable_Create()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>MetaDataTable_Create</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>table MetaDataTable = ultraschall.MetaDataTable_Create()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns an empty MetaDataTable for all possible metadata, in which metadata can be set.
  </description> 
  <retvals>
    table MetaDataTable - a table with all metadata-entries available in Reaper
  </retvals>
  <chapter_context>
    Metadata Management
    Reaper Metadata Management
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>metadata, create, metadatatable</tags>
</US_DocBloc>
]]
  local A="APE:Album;APE:Artist;APE:BPM;APE:Catalog;APE:Comment;APE:Composer;APE:Conductor;APE:Copyright;APE:Genre;APE:ISRC;APE:Key;APE:Language;APE:Publisher;APE:REAPER;APE:Record Date;APE:Record Location;APE:Subtitle;APE:Title;APE:Track;APE:User Defined:a;APE:User Defined:User;APE:Year;ASWG:accent;ASWG:actorGender;ASWG:actorName;ASWG:ambisonicChnOrder;ASWG:ambisonicFormat;ASWG:ambisonicNorm;ASWG:artist;ASWG:billingCode;ASWG:category;ASWG:catId;ASWG:channelConfig;ASWG:characterAge;ASWG:characterGender;ASWG:characterName;ASWG:characterRole;ASWG:composer;ASWG:contentType;ASWG:creatorId;ASWG:direction;ASWG:director;ASWG:editor;ASWG:efforts;ASWG:effortType;ASWG:emotion;ASWG:fxChainName;ASWG:fxName;ASWG:fxUsed;ASWG:genre;ASWG:impulseLocation;ASWG:inKey;ASWG:instrument;ASWG:intensity;ASWG:isCinematic;ASWG:isDesigned;ASWG:isDiegetic;ASWG:isFinal;ASWG:isLicensed;ASWG:isLoop;ASWG:isOst;ASWG:isrcId;ASWG:isSource;ASWG:isUnion;ASWG:language;ASWG:library;ASWG:loudness;ASWG:loudnessRange;ASWG:maxPeak;ASWG:micConfig;ASWG:micDistance;ASWG:micType;ASWG:mixer;ASWG:musicPublisher;ASWG:musicSup;ASWG:musicVersion;ASWG:notes;ASWG:orderRef;ASWG:originator;ASWG:originatorStudio;ASWG:papr;ASWG:producer;ASWG:project;ASWG:projection;ASWG:recEngineer;ASWG:recordingLoc;ASWG:recStudio;ASWG:rightsOwner;ASWG:rmsPower;ASWG:session;ASWG:songTitle;ASWG:sourceId;ASWG:specDensity;ASWG:state;ASWG:subCategory;ASWG:subGenre;ASWG:tempo;ASWG:text;ASWG:timeSig;ASWG:timingRestriction;ASWG:usageRights;ASWG:userCategory;ASWG:userData;ASWG:vendorCategory;ASWG:zeroCrossRate;AXML:ISRC;BWF:Description;BWF:LoudnessRange;BWF:LoudnessValue;BWF:MaxMomentaryLoudness;BWF:MaxShortTermLoudness;BWF:MaxTruePeakLevel;BWF:OriginationDate;BWF:OriginationTime;BWF:Originator;BWF:OriginatorReference;CAFINFO:album;CAFINFO:artist;CAFINFO:channel configuration;CAFINFO:channel layout;CAFINFO:comments;CAFINFO:composer;CAFINFO:copyright;CAFINFO:encoding application;CAFINFO:genre;CAFINFO:key signature;CAFINFO:lyricist;CAFINFO:nominal bit rate;CAFINFO:recorded date;CAFINFO:source encoder;CAFINFO:tempo;CAFINFO:time signature;CAFINFO:title;CAFINFO:track number;CAFINFO:year;CART:Artist;CART:Category;CART:ClientID;CART:CutID;CART:EndDate;CART:INT1;CART:SEG1;CART:StartDate;CART:TagText;CART:Title;CART:URL;CUE:DISC_CATALOG;CUE:DISC_PERFORMER;CUE:DISC_REM;CUE:DISC_SONGWRITER;CUE:DISC_TITLE;CUE:INDEX;CUE:TRACK_ISRC;FLACPIC:APIC_DESC;FLACPIC:APIC_FILE;FLACPIC:APIC_TYPE;ID3:APIC_DESC;ID3:APIC_FILE;ID3:APIC_TYPE;ID3:COMM;ID3:COMM_LANG;ID3:TALB;ID3:TBPM;ID3:TCOM;ID3:TCON;ID3:TCOP;ID3:TDRC;ID3:TEXT;ID3:TIME;ID3:TIPL;ID3:TIT1;ID3:TIT2;ID3:TIT3;ID3:TKEY;ID3:TMCL;ID3:TPE1;ID3:TPE2;ID3:TPOS;ID3:TRCK;ID3:TSRC;ID3:TXXX:a;ID3:TXXX:REAPER;ID3:TXXX:User;ID3:TYER;IFF:ANNO;IFF:AUTH;IFF:COPY;IFF:NAME;INFO:IART;INFO:ICMT;INFO:ICOP;INFO:ICRD;INFO:IENG;INFO:IGNR;INFO:IKEY;INFO:INAM;INFO:IPRD;INFO:ISBJ;INFO:ISRC;INFO:TRCK;IXML:CIRCLED;IXML:FILE_UID;IXML:NOTE;IXML:PROJECT;IXML:SCENE;IXML:TAKE;IXML:TAPE;IXML:USER:a;IXML:USER:REAPER;IXML:USER:User;VORBIS:ALBUM;VORBIS:ALBUMARTIST;VORBIS:ARRANGER;VORBIS:ARTIST;VORBIS:AUTHOR;VORBIS:BPM;VORBIS:COMMENT;VORBIS:COMPOSER;VORBIS:CONDUCTOR;VORBIS:COPYRIGHT;VORBIS:DATE;VORBIS:DESCRIPTION;VORBIS:DISCNUMBER;VORBIS:EAN/UPN;VORBIS:ENCODED-BY;VORBIS:ENCODING;VORBIS:ENSEMBLE;VORBIS:GENRE;VORBIS:ISRC;VORBIS:KEY;VORBIS:LABEL;VORBIS:LABELNO;VORBIS:LANGUAGE;VORBIS:LICENSE;VORBIS:LOCATION;VORBIS:LYRICIST;VORBIS:OPUS;VORBIS:PART;VORBIS:PARTNUMBER;VORBIS:PERFORMER;VORBIS:PRODUCER;VORBIS:PUBLISHER;VORBIS:REAPER;VORBIS:SOURCEMEDIA;VORBIS:TITLE;VORBIS:TRACKNUMBER;VORBIS:USER:a;VORBIS:USER:User;VORBIS:VERSION;WAVEXT:channel configuration;XMP:dc/creator;XMP:dc/date;XMP:dc/description;XMP:dc/language;XMP:dc/title;XMP:dm/album;XMP:dm/artist;XMP:dm/composer;XMP:dm/copyright;XMP:dm/engineer;XMP:dm/genre;XMP:dm/key;XMP:dm/logComment;XMP:dm/scene;XMP:dm/tempo;XMP:dm/timeSignature;XMP:dm/trackNumber"
  local B={}

  for k in string.gmatch(A..";", "(.-);") do
    B[k]=""
  end
  return B
end

function ultraschall.MetaDataTable_GetProject()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>MetaDataTable_GetProject</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>table MetaDataTable = ultraschall.MetaDataTable_GetProject()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns a MetaDataTable for all possible metadata, in which metadata can be set.
    
    All metadata currently set in the active project will be set in the MetaDataTable.
  </description> 
  <retvals>
    table MetaDataTable - a table with all metadata-entries available in Reaper and set with all metadata of current project
  </retvals>
  <chapter_context>
    Metadata Management
    Reaper Metadata Management
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
  <tags>metadata, get, metadatatable</tags>
</US_DocBloc>
]]
  local MetaDataTable=ultraschall.MetaDataTable_Create()
  local retval, ProjMetDat=reaper.GetSetProjectInfo_String(0, "RENDER_METADATA", "", false)  

  for k in string.gmatch(ProjMetDat..";", "(.-);") do
    _retval, MetaDataTable[k]=reaper.GetSetProjectInfo_String(0, "RENDER_METADATA", k, false)
  end
  return MetaDataTable
end

function ultraschall.GetRenderTable_ProjectDefaults()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetRenderTable_ProjectDefaults</slug>
  <requires>
    Ultraschall=4.4
    Reaper=6.48
    SWS=2.10.0.1
    JS=0.972
    Lua=5.3
  </requires>
  <functioncall>table RenderTable = ultraschall.GetRenderTable_ProjectDefaults()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns all stored render-settings for the project-defaults, as a handy table.
            
            RenderTable["AddToProj"] - Add rendered items to new tracks in project-checkbox; true, checked; false, unchecked
            RenderTable["Brickwall_Limiter_Enabled"] - true, brickwall limiting is enabled; false, brickwall limiting is disabled            
            RenderTable["Brickwall_Limiter_Method"] - brickwall-limiting-mode; 1, peak; 2, true peak
            RenderTable["Brickwall_Limiter_Target"] - the volume of the brickwall-limit
            RenderTable["Bounds"] - not stored with project defaults; will use the default bounds for the source
                                    0, Custom time range; 
                                    1, Entire project; 
                                    2, Time selection; 
                                    3, Project regions; 
                                    4, Selected Media Items(in combination with Source 32); 
                                    5, Selected regions
                                    6, Razor edit areas
            RenderTable["Channels"] - the number of channels in the rendered file; 
                                      1, mono; 
                                      2, stereo; 
                                      higher, the number of channels
            RenderTable["CloseAfterRender"] - true, closes rendering to file-dialog after render; false, doesn't close it
            RenderTable["Dither"] - &1, dither master mix; 
                                    &2, noise shaping master mix; 
                                    &4, dither stems; 
                                    &8, dither noise shaping stems
            RenderTable["EmbedMetaData"] - Embed metadata; true, checked; false, unchecked
            RenderTable["EmbedStretchMarkers"] - Embed stretch markers/transient guides; true, checked; false, unchecked
            RenderTable["EmbedTakeMarkers"] - Embed Take markers; true, checked; false, unchecked                        
            RenderTable["Enable2ndPassRender"] - true, 2nd pass render is enabled; false, 2nd pass render is disabled
            RenderTable["Endposition"] - the endposition of the rendering selection in seconds; always 0 because it's not stored with project defaults
            RenderTable["MultiChannelFiles"] - Multichannel tracks to multichannel files-checkbox; true, checked; false, unchecked            
            RenderTable["Normalize_Enabled"] - true, normalization enabled; false, normalization not enabled
            RenderTable["Normalize_Method"] - the normalize-method-dropdownlist
                           0, LUFS-I
                           1, RMS-I
                           2, Peak
                           3, True Peak
                           4, LUFS-M max
                           5, LUFS-S max
            RenderTable["Normalize_Only_Files_Too_Loud"] - Only normalize files that are too loud,checkbox
                                                         - true, checkbox checked
                                                         - false, checkbox unchecked
            RenderTable["Normalize_Stems_to_Master_Target"] - true, normalize-stems to master target(common gain to stems)
                                                              false, normalize each file individually
            RenderTable["Normalize_Target"] - the normalize-target as dB-value
            RenderTable["NoSilentRender"] - Do not render files that are likely silent-checkbox; true, checked; false, unchecked
            RenderTable["OfflineOnlineRendering"] - Offline/Online rendering-dropdownlist; 
                                                    0, Full-speed Offline
                                                    1, 1x Offline
                                                    2, Online Render
                                                    3, Online Render(Idle)
                                                    4, Offline Render(Idle)
            RenderTable["OnlyMonoMedia"] - Tracks with only mono media to mono files-checkbox; true, checked; false, unchecked
            RenderTable["ProjectSampleRateFXProcessing"] - Use project sample rate for mixing and FX/synth processing-checkbox; true, checked; false, unchecked
            RenderTable["RenderFile"] - the contents of the Directory-inputbox of the Render to File-dialog; always "" because it's not stored with project defaults
            RenderTable["RenderPattern"] - the render pattern as input into the File name-inputbox of the Render to File-dialog; always "" because it's not stored with project defaults
            RenderTable["RenderQueueDelay"] - Delay queued render to allow samples to load-checkbox; true, checked; false, unchecked
            RenderTable["RenderQueueDelaySeconds"] - the amount of seconds for the render-queue-delay
            RenderTable["RenderResample"] - Resample mode-dropdownlist; 
                                                0, Sinc Interpolation: 64pt (medium quality)
                                                1, Linear Interpolation: (low quality)
                                                2, Point Sampling (lowest quality, retro)
                                                3, Sinc Interpolation: 192pt
                                                4, Sinc Interpolation: 384pt
                                                5, Linear Interpolation + IIR
                                                6, Linear Interpolation + IIRx2
                                                7, Sinc Interpolation: 16pt
                                                8, Sinc Interpolation: 512pt(slow)
                                                9, Sinc Interpolation: 768pt(very slow)
                                                10, r8brain free (highest quality, fast)
            RenderTable["RenderString"] - the render-cfg-string, that holds all settings of the currently set render-output-format as BASE64 string
            RenderTable["RenderString2"] - the render-cfg-string, that holds all settings of the currently set secondary-render-output-format as BASE64 string
            RenderTable["RenderTable"]=true - signals, this is a valid render-table
            RenderTable["SampleRate"] - the samplerate of the rendered file(s)
            RenderTable["SaveCopyOfProject"] - the "Save copy of project to outfile.wav.RPP"-checkbox; true, checked; false, unchecked
            RenderTable["SilentlyIncrementFilename"] - Silently increment filenames to avoid overwriting-checkbox; true, checked; false, unchecked
            RenderTable["Source"] - 0, Master mix; 
                                    1, Master mix + stems; 
                                    3, Stems (selected tracks); 
                                    8, Region render matrix; 
                                    16, Tracks with only Mono-Media to Mono Files; 
                                    32, Selected media items; 
                                    64, selected media items via master; 
                                    128, selected tracks via master
                                    4096, Razor edit areas
                                    4224, Razor edit areas via master
            RenderTable["Startposition"] - the startposition of the rendering selection in seconds; always 0 because it's not stored with project defaults
            RenderTable["TailFlag"] - in which bounds is the Tail-checkbox checked
                                      &1, custom time bounds; 
                                      &2, entire project; 
                                      &4, time selection; 
                                      &8, all project regions; 
                                      &16, selected media items; 
                                      &32, selected project regions
                                      &64, razor edit areas
            RenderTable["TailMS"] - the amount of milliseconds of the tail
    
    Returns nil in case of an error
  </description>
  <retvals>
    table RenderTable - a table with all of the current project's default render-settings
  </retvals>
  <chapter_context>
    Rendering Projects
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Render_Module.lua</source_document>
  <tags>projectfiles, get, project, default, rendertable</tags>
</US_DocBloc>
]]
  local RenderTable = ultraschall.CreateNewRenderTable()

  -- debugging help
  --for k in pairs(RenderTable) do
  --  RenderTable[k]="HONK"
  --end
  
  local attributetable={
    "projrenderstems",
    "rendertails",
    "rendertaillen",
    "projrendernch",
    "projrendersrate",
    "projrenderlimit",
    "projrenderrateinternal",
    "projrenderresample",
    "projrendernorm",
    "projrendernormtgt",
    "projrenderbrickwall",
    "projrenderdither",
    "renderclosewhendone",
    "projrenderaddtoproj",
    "autosaveonrender", 
    "rendercfg",
    "rendercfg2"
  }

  for i=1, #attributetable do
    local retval, temp = reaper.BR_Win32_GetPrivateProfileString("REAPER", attributetable[i], "", reaper.get_ini_file())
    local temp2=tonumber(temp)
    if attributetable[i]~="rendercfg" and attributetable[i]~="rendercfg2" then
      attributetable[attributetable[i]]=temp2
    else
      attributetable[attributetable[i]]=temp
    end
  end
  
  attributetable["rendercfg"]=ultraschall.ConvertHex2Ascii(attributetable["rendercfg"])
  --A_temp=attributetable["rendercfg"]
  attributetable["rendercfg"]=ultraschall.Base64_Encoder(attributetable["rendercfg"]:sub(1,-2))

  attributetable["rendercfg2"]=ultraschall.ConvertHex2Ascii(attributetable["rendercfg2"])
  attributetable["rendercfg2"]=ultraschall.Base64_Encoder(attributetable["rendercfg2"]:sub(1,-2))

  RenderTable["RenderString"]=attributetable["rendercfg"]
  RenderTable["RenderString2"]=attributetable["rendercfg2"]

  if attributetable["projrenderaddtoproj"]~=nil then
    RenderTable["AddToProj"]=attributetable["projrenderaddtoproj"]&1==1
    RenderTable["NoSilentRender"]=attributetable["projrenderaddtoproj"]&2==2
  end
  
  if attributetable["projrenderstems"]~=nil then
    RenderTable["Source"]=attributetable["projrenderstems"]

    RenderTable["MultiChannelFiles"]=RenderTable["Source"]&4==4
    if RenderTable["Source"]&4==4 then RenderTable["Source"]=RenderTable["Source"]-4 end
    
    RenderTable["OnlyMonoMedia"]=RenderTable["Source"]&16==16
    if RenderTable["Source"]&16==16 then RenderTable["Source"]=RenderTable["Source"]-16 end
    
    RenderTable["EmbedStretchMarkers"]=RenderTable["Source"]&256==256
    if RenderTable["Source"]&256==256 then RenderTable["Source"]=RenderTable["Source"]-256 end
    
    RenderTable["EmbedMetaData"]=RenderTable["Source"]&512==512
    if RenderTable["Source"]&512==512 then RenderTable["Source"]=RenderTable["Source"]-512 end
    
    RenderTable["EmbedTakeMarkers"]=RenderTable["Source"]&1024==1024
    if RenderTable["Source"]&1024==1024 then RenderTable["Source"]=RenderTable["Source"]-1024 end
    
    RenderTable["Enable2ndPassRender"]=RenderTable["Source"]&2048==2048
    if RenderTable["Source"]&2048==2048 then RenderTable["Source"]=RenderTable["Source"]-2048 end
    
    RenderTable["Bounds"]=1
    if RenderTable["Source"]==8 then RenderTable["Bounds"]=3 end
    if RenderTable["Source"]==32 then RenderTable["Bounds"]=4 end
    if RenderTable["Source"]==64 then RenderTable["Bounds"]=4 end
    if RenderTable["Source"]==4096 then RenderTable["Bounds"]=6 end
    if RenderTable["Source"]==4224 then RenderTable["Bounds"]=6 end
  end

  if attributetable["projrendernorm"]~=nil then
    RenderTable["Normalize_Enabled"]=attributetable["projrendernorm"]&1==1
    if attributetable["projrendernorm"]&1==1 then attributetable["projrendernorm"]=attributetable["projrendernorm"]-1 end
  
    RenderTable["Normalize_Stems_to_Master_Target"]=attributetable["projrendernorm"]&32==32
    if attributetable["projrendernorm"]&32==32 then attributetable["projrendernorm"]=attributetable["projrendernorm"]-32 end

  
    RenderTable["Brickwall_Limiter_Enabled"]=attributetable["projrendernorm"]&64==64
    if attributetable["projrendernorm"]&64==64 then attributetable["projrendernorm"]=attributetable["projrendernorm"]-64 end
    RenderTable["Brickwall_Limiter_Method"]=(attributetable["projrendernorm"]&128)
    
    if RenderTable["Brickwall_Limiter_Method"]==128 then RenderTable["Brickwall_Limiter_Method"]=2 else RenderTable["Brickwall_Limiter_Method"]=1 end
    if attributetable["projrendernorm"]&128==128 then attributetable["projrendernorm"]=attributetable["projrendernorm"]-128 end  
  
    RenderTable["Normalize_Only_Files_Too_Loud"]=attributetable["projrendernorm"]&256==256
    if attributetable["projrendernorm"]&256==256 then attributetable["projrendernorm"]=attributetable["projrendernorm"]-256 end
    RenderTable["Normalize_Method"]=attributetable["projrendernorm"]>>1
  end  
  if attributetable["autosaveonrender"]~=nil then
    RenderTable["SaveCopyOfProject"]=attributetable["autosaveonrender"]==1
  end
  
  if attributetable["rendertaillen"]~=nil then
    RenderTable["TailMS"]=attributetable["rendertaillen"]
  end
  
  if attributetable["projrendernormtgt"]~=nil then
    RenderTable["Normalize_Target"]=ultraschall.MKVOL2DB(attributetable["projrendernormtgt"])
  end

  if attributetable["projrenderbrickwall"]~=nil then
    RenderTable["Brickwall_Limiter_Target"]=ultraschall.MKVOL2DB(attributetable["projrenderbrickwall"])
  end
  
  if attributetable["projrendersrate"]~=nil then
    RenderTable["Channels"]=attributetable["projrendersrate"]
  end

  RenderTable["Startposition"]=0
  RenderTable["Endposition"]=0
  
  if attributetable["projrendernch"]~=nil then
    RenderTable["SampleRate"]=attributetable["projrendernch"]
  end
  
  if attributetable["renderclosewhendone"]~=nil then
    RenderTable["CloseAfterRender"]=attributetable["renderclosewhendone"]&1==1
    RenderTable["SilentlyIncrementFilename"]=attributetable["renderclosewhendone"]&16==16
  end
  
  RenderTable["RenderPattern"]=""
  RenderTable["RenderFile"]=""

  RenderTable["RenderQueueDelay"], RenderTable["RenderQueueDelaySeconds"] = ultraschall.GetRender_QueueDelay()
  
  if attributetable["rendertails"]~=nil then
    RenderTable["TailFlag"]=attributetable["rendertails"]
  end
  
  if attributetable["projrenderresample"]~=nil then
    RenderTable["RenderResample"]=attributetable["projrenderresample"]
  end
  
  if attributetable["projrenderlimit"]~=nil then
    RenderTable["OfflineOnlineRendering"]=attributetable["projrenderlimit"]
  end
  
  if attributetable["projrenderrateinternal"]~=nil then
    RenderTable["ProjectSampleRateFXProcessing"]=attributetable["projrenderrateinternal"]&1==1
  end
  
  if attributetable["projrenderdither"]~=nil then
    RenderTable["Dither"]=attributetable["projrenderdither"]
  end
  
  return RenderTable
end

function ultraschall.SpectralPeak_GetMinColor()
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>SpectralPeak_GetMinColor</slug>
    <requires>
      Ultraschall=4.3
      Reaper=6.22
      SWS=2.8.8
      Lua=5.3
    </requires>
    <functioncall>number min_color = ultraschall.SpectralPeak_GetMinColor()</functioncall>
    <description>
      returns the minimum value of the spectral peak-view in Media Items, which is the lowest-frequency-color.
      
      The color is encoded, so that:
        0 = red
        1 = green
        2 = blue
        3 = red again
    </description>
    <retvals>
      number min_color - the minimum color of the spectral peak
    </retvals>
    <chapter_context>
      MediaItem Management
      Spectral Peak
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_MediaItem_Module.lua</source_document>
    <tags>mediaitemmanagement, get, min color, spectral peak view</tags>
  </US_DocBloc>
  --]]
  return reaper.SNM_GetDoubleConfigVar("specpeak_huel", -11111)*3
end

--A=ultraschall.SpectralPeak_GetMinColor()

function ultraschall.SpectralPeak_SetMinColor(color, update_arrange)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>SpectralPeak_SetMinColor</slug>
    <requires>
      Ultraschall=4.3
      Reaper=6.22
      SWS=2.8.8
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.SpectralPeak_SetMinColor(number min_color, optional boolean update_arrange)</functioncall>
    <description>
      sets the minimum value of the spectral peak-view in Media Items, which is the lowest-frequency-color.
      
      The color is encoded, so that:
        0 = red
        1 = green
        2 = blue
        3 = red again, etc
        
      return false in case of an error
    </description>
    <retvals>
      boolean retval - true, setting was successful; false, setting was unsuccessful
    </retvals>
    <parameters>
      number min_color - the minimum color of the spectral peak
      optional boolean update_arrange - true, update arrange; false or nil, don't update arrange
    </parameters>
    <chapter_context>
      MediaItem Management
      Spectral Peak
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_MediaItem_Module.lua</source_document>
    <tags>mediaitemmanagement, set, min color, spectral peak view</tags>
  </US_DocBloc>
  --]]
  if type(color)~="number" then ultraschall.AddErrorMessage("SpectralPeak_SetMinColor", "color", "must be a number", -1) return false end
  color=color/3
  reaper.SNM_SetDoubleConfigVar("specpeak_huel", color)
  if update_arrange==true then
    reaper.UpdateArrange()
  end
  return true
end

--ultraschall.SpectralPeak_SetMinColor(0, true)

function ultraschall.SpectralPeak_GetMaxColor()
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>SpectralPeak_GetMaxColor</slug>
    <requires>
      Ultraschall=4.3
      Reaper=6.22
      SWS=2.8.8
      Lua=5.3
    </requires>
    <functioncall>number max_color = ultraschall.SpectralPeak_GetMaxColor()</functioncall>
    <description>
      returns the maximum value of the spectral peak-view in Media Items, which is the highest-frequency-color.
      
      The color is encoded, so that:
        0 = red
        1 = green
        2 = blue
        3 = red again
        
      Max-color should be higher than min-color.
    </description>
    <retvals>
      number max_color - the maximum color of the spectral peak
    </retvals>
    <chapter_context>
      MediaItem Management
      Spectral Peak
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_MediaItem_Module.lua</source_document>
    <tags>mediaitemmanagement, get, max color, spectral peak view</tags>
  </US_DocBloc>
  --]]
  return reaper.SNM_GetDoubleConfigVar("specpeak_hueh", -1111)*3
end

--A=ultraschall.SpectralPeak_GetMaxColor()

function ultraschall.SpectralPeak_SetMaxColor(color, update_arrange)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>SpectralPeak_SetMaxColor</slug>
    <requires>
      Ultraschall=4.3
      Reaper=6.22
      SWS=2.8.8
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.SpectralPeak_SetMaxColor(number color, optional boolean update_arrange)</functioncall>
    <description>
      sets the maximum value of the spectral peak-view in Media Items.
      
      The color is encoded, so that:
        0 = red
        1 = green
        2 = blue
        3 = red again, etc

        Max-color should be higher than min-color.
        
      return false in case of an error
    </description>
    <retvals>
      boolean retval - true, setting was successful; false, setting was unsuccessful
    </retvals>
    <parameters>
      number color - the maximum color of the spectral peak
      optional boolean update_arrange - true, update arrange; false or nil, don't update arrange
    </parameters>
    <chapter_context>
      MediaItem Management
      Spectral Peak
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_MediaItem_Module.lua</source_document>
    <tags>mediaitemmanagement, set, max color, spectral peak view</tags>
  </US_DocBloc>
  --]]
  if type(color)~="number" then ultraschall.AddErrorMessage("SpectralPeak_SetMaxColor", "color", "must be a number", -1) return false end
  color=(color/3)+1
  reaper.SNM_SetDoubleConfigVar("specpeak_hueh", color)
  if update_arrange==true then
    reaper.UpdateArrange()
  end
end

function ultraschall.SpectralPeak_SetMaxColor_Relative(color, update_arrange)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>SpectralPeak_SetMaxColor_Relative</slug>
    <requires>
      Ultraschall=4.3
      Reaper=6.22
      SWS=2.8.8
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.SpectralPeak_SetMaxColor_Relative(number color, optional boolean update_arrange)</functioncall>
    <description>
      sets the maximum value of the spectral peak-view in Media Items relative to the minimum color.
      
      This will set the shown spectrum relative to the minimum-color set.
      
      To set it to the whole spectrum, pass 3 as color.
      To set it to a third of the spectrum, pass 1 as color.
      To set it to two times the spectrum, set color to 6.
        
      return false in case of an error
    </description>
    <retvals>
      boolean retval - true, setting was successful; false, setting was unsuccessful
    </retvals>
    <parameters>
      number color - the maximum spectrum of the spectral peak relative to the minimum color
      optional boolean update_arrange - true, update arrange; false or nil, don't update arrange
    </parameters>
    <chapter_context>
      MediaItem Management
      Spectral Peak
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_MediaItem_Module.lua</source_document>
    <tags>mediaitemmanagement, set, max color, relative, spectral peak view</tags>
  </US_DocBloc>
  --]]
  if type(color)~="number" then ultraschall.AddErrorMessage("SpectralPeak_SetMaxColor_Relative", "color", "must be a number", -1) return false end
  color=(color/3)+reaper.SNM_GetDoubleConfigVar("specpeak_huel", color)
  reaper.SNM_SetDoubleConfigVar("specpeak_hueh", color)
  if update_arrange==true then
    reaper.UpdateArrange()
  end
  return true
end

--ultraschall.SpectralPeak_SetMaxColor_Relative(6, true)

function ultraschall.SpectralPeak_SetColorAttributes(noise_threshold, variance, opacity)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>SpectralPeak_SetColorAttributes</slug>
    <requires>
      Ultraschall=4.3
      Reaper=6.22
      SWS=2.8.8
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.SpectralPeak_SetColorAttributes(optional number noise_threshold, optional number variance, optional number opacity)</functioncall>
    <description>
      sets the noise_threshold, variance and opacity of the spectral peak-view in Media Items.

      return false in case of an error
    </description>
    <retvals>
      boolean retval - true, setting was successful; false, setting was unsuccessful
    </retvals>
    <parameters>
      optional number noise_threshold - the noise threshold, between 0.25 and 8.00
      optional number variance - the variance of the spectrum, between 0 and 1
      optional number opacity - the opacity of the spectrum, between 0 and 1.33; 1, for default
    </parameters>
    <chapter_context>
      MediaItem Management
      Spectral Peak
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_MediaItem_Module.lua</source_document>
    <tags>mediaitemmanagement, set, noise threshold, variance, alpha, opacity, spectral peak view</tags>
  </US_DocBloc>
  --]]
  if noise_threshold~=nil and type(noise_threshold)~="number" then ultraschall.AddErrorMessage("SpectralPeak_SetColorAttributes", "noise_threshold", "must be a number", -1) return false end
  if variance~=nil and type(variance)~="number" then ultraschall.AddErrorMessage("SpectralPeak_SetColorAttributes", "variance", "must be a number between 0 and 1", -2) return false end
  if opacity~=nil and type(opacity)~="number" then ultraschall.AddErrorMessage("SpectralPeak_SetColorAttributes", "opacity", "must be a number between 0 and 1", -3) return false end
  
  
  if noise_threshold~=nil then
    if noise_threshold<0.25 or noise_threshold>8.00 then ultraschall.AddErrorMessage("SpectralPeak_SetColorAttributes", "noise_threshold", "must be a number between 0 and 1", -4) return false end
    local LookUpTable={} -- ugly workaround...please fiddle out the math behind this...
    LookUpTable[25]=16
    LookUpTable[26]=15.548989744238
    LookUpTable[27]=14.96735650067
    LookUpTable[28]=14.545454545455
    LookUpTable[29]=14.001360038635
    LookUpTable[30]=13.349772995397
    LookUpTable[31]=13.097709199531
    LookUpTable[32]=12.488175726571
    LookUpTable[33]=12.252380183218
    LookUpTable[34]=11.90700836321
    LookUpTable[35]=11.571371932756
    LookUpTable[36]=11.245196469324
    LookUpTable[37]=10.928215285841
    LookUpTable[38]=10.620169212648
    LookUpTable[39]=10.320806385595
    LookUpTable[40]=10.125934035717
    LookUpTable[41]=9.8405027795123
    LookUpTable[42]=9.5631172997986
    LookUpTable[43]=9.3825512596322
    LookUpTable[44]=9.1180745819253
    LookUpTable[45]=8.9459116177384
    LookUpTable[46]=8.7769993492957
    LookUpTable[47]=8.5295920542111
    LookUpTable[48]=8.3685405253863
    LookUpTable[49]=8.2105298916913
    LookUpTable[50]=8.0555027364517
    LookUpTable[51]=7.9034027271063
    LookUpTable[52]=7.7541745947374
    LookUpTable[53]=7.6077641139876
    LookUpTable[54]=7.4641180833557
    LookUpTable[55]=7.3231843058652
    LookUpTable[56]=7.1849115700966
    LookUpTable[57]=7.0492496315794
    LookUpTable[58]=6.9161491945341
    LookUpTable[59]=6.7855618939597
    LookUpTable[60]=6.7211958059643
    LookUpTable[61]=6.5942895186293
    LookUpTable[62]=6.4697794129011
    LookUpTable[63]=6.3476202452663
    LookUpTable[64]=6.2874083586674
    LookUpTable[65]=6.1686926308725
    LookUpTable[66]=6.0522184345993
    LookUpTable[67]=5.9948086532994
    LookUpTable[68]=5.8816176480919
    LookUpTable[69]=5.770563859333
    LookUpTable[70]=5.7158257806067
    LookUpTable[71]=5.6616069331611
    LookUpTable[72]=5.5547072776564
    LookUpTable[73]=5.5020167587267
    LookUpTable[74]=5.3981304057826
    LookUpTable[75]=5.346925134629
    LookUpTable[76]=5.2962055834556
    LookUpTable[77]=5.196205255097
    LookUpTable[78]=5.1469153937828
    LookUpTable[79]=5.0497338887786
    LookUpTable[80]=5.0018334170242
    LookUpTable[81]=4.9543873167764
    LookUpTable[82]=4.9073912779842
    LookUpTable[83]=4.814732348596
    LookUpTable[84]=4.769061040771
    LookUpTable[85]=4.7238229591791
    LookUpTable[86]=4.634630075787
    LookUpTable[87]=4.5906671716169
    LookUpTable[88]=4.5471212882038
    LookUpTable[89]=4.5039884697967
    LookUpTable[90]=4.4612647981674
    LookUpTable[91]=4.4189463922554
    LookUpTable[92]=4.3355100370646
    LookUpTable[93]=4.2943845083446
    LookUpTable[94]=4.2536490857709
    LookUpTable[95]=4.2133000688973
    LookUpTable[96]=4.173333792379
    LookUpTable[97]=4.1337466256399
    LookUpTable[98]=4.0945349725424
    LookUpTable[99]=4.0556952710613
    LookUpTable[100]=4.0172239929594
    LookUpTable[101]=3.9554078605272
    LookUpTable[102]=3.917887882906
    LookUpTable[103]=3.8807238101043
    LookUpTable[104]=3.8439122661009
    LookUpTable[105]=3.8074499068986
    LookUpTable[106]=3.7713334202207
    LookUpTable[107]=3.7355595252095
    LookUpTable[108]=3.7001249721291
    LookUpTable[109]=3.6650265420695
    LookUpTable[110]=3.6302610466545
    LookUpTable[111]=3.595825327752
    LookUpTable[112]=3.5617162571873
    LookUpTable[113]=3.5279307364585
    LookUpTable[114]=3.4944656964554
    LookUpTable[116]=3.4613180971806
    LookUpTable[117]=3.4284849274733
    LookUpTable[118]=3.3959632047359
    LookUpTable[119]=3.3637499746628
    LookUpTable[120]=3.3318423109722
    LookUpTable[121]=3.3002373151404
    LookUpTable[122]=3.2689321161382
    LookUpTable[124]=3.2379238701703
    LookUpTable[125]=3.2072097604168
    LookUpTable[126]=3.1767869967776  
    LookUpTable[127]=3.1466528156187  
    LookUpTable[128]=3.1168044795212
    LookUpTable[130]=3.0872392770326
    LookUpTable[131]=3.0579545224207
    LookUpTable[132]=3.0289475554293  
    LookUpTable[133]=3.0002157410367
    LookUpTable[135]=2.9717564692165
    LookUpTable[136]=2.9435671547002  
    LookUpTable[137]=2.9156452367425
    LookUpTable[139]=2.8879881788887
    LookUpTable[140]=2.8605934687443
    LookUpTable[141]=2.8334586177465
    LookUpTable[143]=2.8065811609388
    LookUpTable[144]=2.7799586567461
    LookUpTable[145]=2.7535886867539
    LookUpTable[147]=2.727468855488
    LookUpTable[148]=2.7015967901969
    LookUpTable[149]=2.6759701406366
    LookUpTable[151]=2.6505865788568  
    LookUpTable[152]=2.6254437989898
    LookUpTable[154]=2.6005395170403
    LookUpTable[155]=2.5758714706787
    LookUpTable[157]=2.5514374190352
    LookUpTable[158]=2.5272351424965
    LookUpTable[160]=2.5032624425036
    LookUpTable[161]=2.4795171413527
    LookUpTable[163]=2.4559970819971
    LookUpTable[164]=2.4327001278514
    LookUpTable[166]=2.4096241625971
    LookUpTable[168]=2.3867670899907
    LookUpTable[169]=2.364126833673
    LookUpTable[171]=2.3417013369806
    LookUpTable[172]=2.3194885627593
    LookUpTable[174]=2.2974864931786
    LookUpTable[176]=2.2756931295487
    LookUpTable[177]=2.2541064921388
    LookUpTable[179]=2.2327246199974
    LookUpTable[181]=2.211545570774
    LookUpTable[183]=2.1905674205429
    LookUpTable[184]=2.1697882636279
    LookUpTable[186]=2.14920621243
    LookUpTable[188]=2.1288193972551
    LookUpTable[190]=2.1086259661448
    LookUpTable[192]=2.0886240847078
    LookUpTable[193]=2.0688119359534
    LookUpTable[195]=2.0491877201262
    LookUpTable[197]=2.0297496545431
    LookUpTable[199]=2.0104959734309
    LookUpTable[201]=1.9914249277662
    LookUpTable[203]=1.9725347851163
    LookUpTable[205]=1.9538238294818
    LookUpTable[207]=1.935290361141
    LookUpTable[209]=1.9169326964953
    LookUpTable[211]=1.8987491679162
    LookUpTable[213]=1.880738123594
    LookUpTable[215]=1.8628979273874
    LookUpTable[217]=1.8452269586755
    LookUpTable[219]=1.8277236122099
    LookUpTable[221]=1.8103862979693
    LookUpTable[223]=1.7932134410148
    LookUpTable[225]=1.7762034813471
    LookUpTable[227]=1.7593548737646
    LookUpTable[230]=1.742666087723
    LookUpTable[232]=1.7261356071965
    LookUpTable[234]=1.70976193054  
    LookUpTable[236]=1.6935435703522
    LookUpTable[238]=1.6774790533414
    LookUpTable[241]=1.6615669201909
    LookUpTable[243]=1.6458057254266
    LookUpTable[245]=1.6301940372862
    LookUpTable[248]=1.6147304375883
    LookUpTable[250]=1.5994135216041
    LookUpTable[252]=1.58424189793
    LookUpTable[255]=1.5692141883605
    LookUpTable[257]=1.5543290277636
    LookUpTable[260]=1.5395850639566
    LookUpTable[262]=1.5249809575831
    LookUpTable[265]=1.5105153819917
    LookUpTable[267]=1.4961870231151
    LookUpTable[270]=1.4819945793511
    LookUpTable[272]=1.4679367614439
    LookUpTable[275]=1.4540122923674  
    LookUpTable[278]=1.4402199072091
    LookUpTable[280]=1.426558353055
    LookUpTable[283]=1.413026388876
    LookUpTable[286]=1.3996227854151
    LookUpTable[289]=1.3863463250755
    LookUpTable[291]=1.3731958018106
    LookUpTable[294]=1.3601700210137
    LookUpTable[297]=1.3472677994101
    LookUpTable[300]=1.334487964949
    LookUpTable[303]=1.3218293566976
    LookUpTable[306]=1.3092908247355
    LookUpTable[308]=1.29687123005
    LookUpTable[311]=1.2845694444327
    LookUpTable[314]=1.2723843503773
    LookUpTable[317]=1.2603148409778
    LookUpTable[320]=1.2483598198278
    LookUpTable[323]=1.2365182009216
    LookUpTable[327]=1.2247889085546
    LookUpTable[330]=1.2131708772263
    LookUpTable[333]=1.2016630515433
    LookUpTable[336]=1.1902643861232
    LookUpTable[339]=1.1789738455
    LookUpTable[343]=1.1677904040298
    LookUpTable[346]=1.1567130457976
    LookUpTable[349]=1.1457407645252
    LookUpTable[352]=1.1348725634799
    LookUpTable[356]=1.1241074553833
    LookUpTable[359]=1.1134444623224
    LookUpTable[363]=1.1028826156603
    LookUpTable[366]=1.0924209559485
    LookUpTable[370]=1.0820585328393
    LookUpTable[373]=1.071794405
    LookUpTable[377]=1.061627640027
    LookUpTable[380]=1.0515573143614
    LookUpTable[384]=1.0415825132048
    LookUpTable[388]=1.0317023304362
    LookUpTable[391]=1.0219158685302
    LookUpTable[395]=1.0122222384749
    LookUpTable[399]=1.0026205596912
    LookUpTable[403]=0.99310995995314
    LookUpTable[407]=0.98368957530844
    LookUpTable[411]=0.97435855
    LookUpTable[414]=0.96511603638822
    LookUpTable[418]=0.95596119487402
    LookUpTable[422]=0.94689319382251
    LookUpTable[426]=0.93791120948748
    LookUpTable[431]=0.92901442593658
    LookUpTable[435]=0.92020203497716
    LookUpTable[439]=0.9114732360829
    LookUpTable[443]=0.90282723632104
    LookUpTable[447]=0.8942632502804
    LookUpTable[452]=0.8857805
    LookUpTable[456]=0.87737821489839
    LookUpTable[460]=0.86905563170366
    LookUpTable[465]=0.8608119943841
    LookUpTable[469]=0.85264655407953
    LookUpTable[474]=0.84455856903325
    LookUpTable[478]=0.83654730452469
    LookUpTable[483]=0.82861203280263
    LookUpTable[487]=0.82075203301913
    LookUpTable[492]=0.812966591164
    LookUpTable[497]=0.805255
    LookUpTable[501]=0.79761655899853
    LookUpTable[506]=0.79005057427605
    LookUpTable[511]=0.782556358531
    LookUpTable[516]=0.77513323098139
    LookUpTable[521]=0.76778051730296
    LookUpTable[526]=0.7604975495679
    LookUpTable[531]=0.75328366618421
    LookUpTable[536]=0.74613821183557
    LookUpTable[541]=0.73906053742182
    LookUpTable[546]=0.73205
    LookUpTable[552]=0.72510596272594
    LookUpTable[557]=0.71822779479641
    LookUpTable[562]=0.71141487139182
    LookUpTable[568]=0.70466657361945
    LookUpTable[573]=0.69798228845723
    LookUpTable[579]=0.69136140869809
    LookUpTable[584]=0.68480333289474
    LookUpTable[590]=0.67830746530506
    LookUpTable[595]=0.67187321583802
    LookUpTable[601]=0.6655
    LookUpTable[607]=0.65918723884176
    LookUpTable[613]=0.65293435890583
    LookUpTable[618]=0.64674079217438
    LookUpTable[624]=0.64060597601768
    LookUpTable[630]=0.63452935314294
    LookUpTable[636]=0.62851037154372
    LookUpTable[643]=0.62254848444976
    LookUpTable[649]=0.61664315027733
    LookUpTable[655]=0.61079383258002
    LookUpTable[661]=0.605
    LookUpTable[667]=0.59926112621978
    LookUpTable[674]=0.59357668991439
    LookUpTable[680]=0.58794617470398
    LookUpTable[687]=0.58236906910698
    LookUpTable[693]=0.57684486649358
    LookUpTable[700]=0.57137306503975
    LookUpTable[707]=0.5659531676816
    LookUpTable[714]=0.5605846820703
    LookUpTable[720]=0.55526712052729
    LookUpTable[727]=0.55
    LookUpTable[734]=0.54478284201799
    LookUpTable[741]=0.53961517264944
    LookUpTable[748]=0.53449652245817
    LookUpTable[756]=0.52942642646089
    LookUpTable[763]=0.52440442408507
    LookUpTable[770]=0.51943005912704
    LookUpTable[777]=0.51450287971055
    LookUpTable[785]=0.50962243824573
    LookUpTable[792]=0.50478829138844
    LookUpTable[800]=0.5
    local temp=16
    for i=25, 800 do
      if LookUpTable[i]~=nil then
        temp=LookUpTable[i]
      else
        LookUpTable[i]=temp
      end
    end
    noise_threshold = ultraschall.LimitFractionOfFloat(noise_threshold, 2)
    reaper.SNM_SetDoubleConfigVar("specpeak_na", LookUpTable[noise_threshold*100])
  end
  
  if variance~=nil then
    if variance<0 or variance>1 then ultraschall.AddErrorMessage("SpectralPeak_SetColorAttributes", "variance", "must be a number between 0 and 1", -5) return false end
    reaper.SNM_SetIntConfigVar("specpeak_bv", math.floor(variance*255))
  end

  if opacity~=nil then
    if opacity<0 or opacity>1.33 then ultraschall.AddErrorMessage("SpectralPeak_SetColorAttributes", "opacity", "must be a number between 0 and 1", -6) return false end
    reaper.SNM_SetIntConfigVar("specpeak_alpha", math.floor((opacity*255)/1.328125))
  end
  return true
end

--ultraschall.SpectralPeak_SetColorAttributes(0.25, nil, 1.33)
--SLEM()

function ultraschall.SpectralPeak_GetColorAttributes()
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>SpectralPeak_GetColorAttributes</slug>
    <requires>
      Ultraschall=4.3
      Reaper=6.22
      SWS=2.8.8
      Lua=5.3
    </requires>
    <functioncall>number noise_threshold, number variance, number opacity = ultraschall.SpectralPeak_GetColorAttributes()</functioncall>
    <description>
      returns the noise_threshold, variance and opacity of the spectral peak-view in Media Items.
    </description>
    <retvals>
      number noise_threshold - the noise threshold, between 0.25 and 8.00
      number variance - the variance of the spectrum, between 0 and 1
      number opacity - the opacity of the spectrum, between 0 and 1.33; 1, for default
    </retvals>
    <chapter_context>
      MediaItem Management
      Spectral Peak
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_MediaItem_Module.lua</source_document>
    <tags>mediaitemmanagement, get, noise threshold, variance, alpha, opacity, spectral peak view</tags>
  </US_DocBloc>
  --]]
  local LookUpTable={} -- ugly workaround...please fiddle out the math behind this...
  LookUpTable[25]=16
  LookUpTable[26]=15.548989744238
  LookUpTable[27]=14.96735650067
  LookUpTable[28]=14.545454545455
  LookUpTable[29]=14.001360038635
  LookUpTable[30]=13.349772995397
  LookUpTable[31]=13.097709199531
  LookUpTable[32]=12.488175726571
  LookUpTable[33]=12.252380183218
  LookUpTable[34]=11.90700836321
  LookUpTable[35]=11.571371932756
  LookUpTable[36]=11.245196469324
  LookUpTable[37]=10.928215285841
  LookUpTable[38]=10.620169212648
  LookUpTable[39]=10.320806385595
  LookUpTable[40]=10.125934035717
  LookUpTable[41]=9.8405027795123
  LookUpTable[42]=9.5631172997986
  LookUpTable[43]=9.3825512596322
  LookUpTable[44]=9.1180745819253
  LookUpTable[45]=8.9459116177384
  LookUpTable[46]=8.7769993492957
  LookUpTable[47]=8.5295920542111
  LookUpTable[48]=8.3685405253863
  LookUpTable[49]=8.2105298916913
  LookUpTable[50]=8.0555027364517
  LookUpTable[51]=7.9034027271063
  LookUpTable[52]=7.7541745947374
  LookUpTable[53]=7.6077641139876
  LookUpTable[54]=7.4641180833557
  LookUpTable[55]=7.3231843058652
  LookUpTable[56]=7.1849115700966
  LookUpTable[57]=7.0492496315794
  LookUpTable[58]=6.9161491945341
  LookUpTable[59]=6.7855618939597
  LookUpTable[60]=6.7211958059643
  LookUpTable[61]=6.5942895186293
  LookUpTable[62]=6.4697794129011
  LookUpTable[63]=6.3476202452663
  LookUpTable[64]=6.2874083586674
  LookUpTable[65]=6.1686926308725
  LookUpTable[66]=6.0522184345993
  LookUpTable[67]=5.9948086532994
  LookUpTable[68]=5.8816176480919
  LookUpTable[69]=5.770563859333
  LookUpTable[70]=5.7158257806067
  LookUpTable[71]=5.6616069331611
  LookUpTable[72]=5.5547072776564
  LookUpTable[73]=5.5020167587267
  LookUpTable[74]=5.3981304057826
  LookUpTable[75]=5.346925134629
  LookUpTable[76]=5.2962055834556
  LookUpTable[77]=5.196205255097
  LookUpTable[78]=5.1469153937828
  LookUpTable[79]=5.0497338887786
  LookUpTable[80]=5.0018334170242
  LookUpTable[81]=4.9543873167764
  LookUpTable[82]=4.9073912779842
  LookUpTable[83]=4.814732348596
  LookUpTable[84]=4.769061040771
  LookUpTable[85]=4.7238229591791
  LookUpTable[86]=4.634630075787
  LookUpTable[87]=4.5906671716169
  LookUpTable[88]=4.5471212882038
  LookUpTable[89]=4.5039884697967
  LookUpTable[90]=4.4612647981674
  LookUpTable[91]=4.4189463922554
  LookUpTable[92]=4.3355100370646
  LookUpTable[93]=4.2943845083446
  LookUpTable[94]=4.2536490857709
  LookUpTable[95]=4.2133000688973
  LookUpTable[96]=4.173333792379
  LookUpTable[97]=4.1337466256399
  LookUpTable[98]=4.0945349725424
  LookUpTable[99]=4.0556952710613
  LookUpTable[100]=4.0172239929594
  LookUpTable[101]=3.9554078605272
  LookUpTable[102]=3.917887882906
  LookUpTable[103]=3.8807238101043
  LookUpTable[104]=3.8439122661009
  LookUpTable[105]=3.8074499068986
  LookUpTable[106]=3.7713334202207
  LookUpTable[107]=3.7355595252095
  LookUpTable[108]=3.7001249721291
  LookUpTable[109]=3.6650265420695
  LookUpTable[110]=3.6302610466545
  LookUpTable[111]=3.595825327752
  LookUpTable[112]=3.5617162571873
  LookUpTable[113]=3.5279307364585
  LookUpTable[114]=3.4944656964554
  LookUpTable[116]=3.4613180971806
  LookUpTable[117]=3.4284849274733
  LookUpTable[118]=3.3959632047359
  LookUpTable[119]=3.3637499746628
  LookUpTable[120]=3.3318423109722
  LookUpTable[121]=3.3002373151404
  LookUpTable[122]=3.2689321161382
  LookUpTable[124]=3.2379238701703
  LookUpTable[125]=3.2072097604168
  LookUpTable[126]=3.1767869967776  
  LookUpTable[127]=3.1466528156187  
  LookUpTable[128]=3.1168044795212
  LookUpTable[130]=3.0872392770326
  LookUpTable[131]=3.0579545224207
  LookUpTable[132]=3.0289475554293  
  LookUpTable[133]=3.0002157410367
  LookUpTable[135]=2.9717564692165
  LookUpTable[136]=2.9435671547002  
  LookUpTable[137]=2.9156452367425
  LookUpTable[139]=2.8879881788887
  LookUpTable[140]=2.8605934687443
  LookUpTable[141]=2.8334586177465
  LookUpTable[143]=2.8065811609388
  LookUpTable[144]=2.7799586567461
  LookUpTable[145]=2.7535886867539
  LookUpTable[147]=2.727468855488
  LookUpTable[148]=2.7015967901969
  LookUpTable[149]=2.6759701406366
  LookUpTable[151]=2.6505865788568  
  LookUpTable[152]=2.6254437989898
  LookUpTable[154]=2.6005395170403
  LookUpTable[155]=2.5758714706787
  LookUpTable[157]=2.5514374190352
  LookUpTable[158]=2.5272351424965
  LookUpTable[160]=2.5032624425036
  LookUpTable[161]=2.4795171413527
  LookUpTable[163]=2.4559970819971
  LookUpTable[164]=2.4327001278514
  LookUpTable[166]=2.4096241625971
  LookUpTable[168]=2.3867670899907
  LookUpTable[169]=2.364126833673
  LookUpTable[171]=2.3417013369806
  LookUpTable[172]=2.3194885627593
  LookUpTable[174]=2.2974864931786
  LookUpTable[176]=2.2756931295487
  LookUpTable[177]=2.2541064921388
  LookUpTable[179]=2.2327246199974
  LookUpTable[181]=2.211545570774
  LookUpTable[183]=2.1905674205429
  LookUpTable[184]=2.1697882636279
  LookUpTable[186]=2.14920621243
  LookUpTable[188]=2.1288193972551
  LookUpTable[190]=2.1086259661448
  LookUpTable[192]=2.0886240847078
  LookUpTable[193]=2.0688119359534
  LookUpTable[195]=2.0491877201262
  LookUpTable[197]=2.0297496545431
  LookUpTable[199]=2.0104959734309
  LookUpTable[201]=1.9914249277662
  LookUpTable[203]=1.9725347851163
  LookUpTable[205]=1.9538238294818
  LookUpTable[207]=1.935290361141
  LookUpTable[209]=1.9169326964953
  LookUpTable[211]=1.8987491679162
  LookUpTable[213]=1.880738123594
  LookUpTable[215]=1.8628979273874
  LookUpTable[217]=1.8452269586755
  LookUpTable[219]=1.8277236122099
  LookUpTable[221]=1.8103862979693
  LookUpTable[223]=1.7932134410148
  LookUpTable[225]=1.7762034813471
  LookUpTable[227]=1.7593548737646
  LookUpTable[230]=1.742666087723
  LookUpTable[232]=1.7261356071965
  LookUpTable[234]=1.70976193054  
  LookUpTable[236]=1.6935435703522
  LookUpTable[238]=1.6774790533414
  LookUpTable[241]=1.6615669201909
  LookUpTable[243]=1.6458057254266
  LookUpTable[245]=1.6301940372862
  LookUpTable[248]=1.6147304375883
  LookUpTable[250]=1.5994135216041
  LookUpTable[252]=1.58424189793
  LookUpTable[255]=1.5692141883605
  LookUpTable[257]=1.5543290277636
  LookUpTable[260]=1.5395850639566
  LookUpTable[262]=1.5249809575831
  LookUpTable[265]=1.5105153819917
  LookUpTable[267]=1.4961870231151
  LookUpTable[270]=1.4819945793511
  LookUpTable[272]=1.4679367614439
  LookUpTable[275]=1.4540122923674  
  LookUpTable[278]=1.4402199072091
  LookUpTable[280]=1.426558353055
  LookUpTable[283]=1.413026388876
  LookUpTable[286]=1.3996227854151
  LookUpTable[289]=1.3863463250755
  LookUpTable[291]=1.3731958018106
  LookUpTable[294]=1.3601700210137
  LookUpTable[297]=1.3472677994101
  LookUpTable[300]=1.334487964949
  LookUpTable[303]=1.3218293566976
  LookUpTable[306]=1.3092908247355
  LookUpTable[308]=1.29687123005
  LookUpTable[311]=1.2845694444327
  LookUpTable[314]=1.2723843503773
  LookUpTable[317]=1.2603148409778
  LookUpTable[320]=1.2483598198278
  LookUpTable[323]=1.2365182009216
  LookUpTable[327]=1.2247889085546
  LookUpTable[330]=1.2131708772263
  LookUpTable[333]=1.2016630515433
  LookUpTable[336]=1.1902643861232
  LookUpTable[339]=1.1789738455
  LookUpTable[343]=1.1677904040298
  LookUpTable[346]=1.1567130457976
  LookUpTable[349]=1.1457407645252
  LookUpTable[352]=1.1348725634799
  LookUpTable[356]=1.1241074553833
  LookUpTable[359]=1.1134444623224
  LookUpTable[363]=1.1028826156603
  LookUpTable[366]=1.0924209559485
  LookUpTable[370]=1.0820585328393
  LookUpTable[373]=1.071794405
  LookUpTable[377]=1.061627640027
  LookUpTable[380]=1.0515573143614
  LookUpTable[384]=1.0415825132048
  LookUpTable[388]=1.0317023304362
  LookUpTable[391]=1.0219158685302
  LookUpTable[395]=1.0122222384749
  LookUpTable[399]=1.0026205596912
  LookUpTable[403]=0.99310995995314
  LookUpTable[407]=0.98368957530844
  LookUpTable[411]=0.97435855
  LookUpTable[414]=0.96511603638822
  LookUpTable[418]=0.95596119487402
  LookUpTable[422]=0.94689319382251
  LookUpTable[426]=0.93791120948748
  LookUpTable[431]=0.92901442593658
  LookUpTable[435]=0.92020203497716
  LookUpTable[439]=0.9114732360829
  LookUpTable[443]=0.90282723632104
  LookUpTable[447]=0.8942632502804
  LookUpTable[452]=0.8857805
  LookUpTable[456]=0.87737821489839
  LookUpTable[460]=0.86905563170366
  LookUpTable[465]=0.8608119943841
  LookUpTable[469]=0.85264655407953
  LookUpTable[474]=0.84455856903325
  LookUpTable[478]=0.83654730452469
  LookUpTable[483]=0.82861203280263
  LookUpTable[487]=0.82075203301913
  LookUpTable[492]=0.812966591164
  LookUpTable[497]=0.805255
  LookUpTable[501]=0.79761655899853
  LookUpTable[506]=0.79005057427605
  LookUpTable[511]=0.782556358531
  LookUpTable[516]=0.77513323098139
  LookUpTable[521]=0.76778051730296
  LookUpTable[526]=0.7604975495679
  LookUpTable[531]=0.75328366618421
  LookUpTable[536]=0.74613821183557
  LookUpTable[541]=0.73906053742182
  LookUpTable[546]=0.73205
  LookUpTable[552]=0.72510596272594
  LookUpTable[557]=0.71822779479641
  LookUpTable[562]=0.71141487139182
  LookUpTable[568]=0.70466657361945
  LookUpTable[573]=0.69798228845723
  LookUpTable[579]=0.69136140869809
  LookUpTable[584]=0.68480333289474
  LookUpTable[590]=0.67830746530506
  LookUpTable[595]=0.67187321583802
  LookUpTable[601]=0.6655
  LookUpTable[607]=0.65918723884176
  LookUpTable[613]=0.65293435890583
  LookUpTable[618]=0.64674079217438
  LookUpTable[624]=0.64060597601768
  LookUpTable[630]=0.63452935314294
  LookUpTable[636]=0.62851037154372
  LookUpTable[643]=0.62254848444976
  LookUpTable[649]=0.61664315027733
  LookUpTable[655]=0.61079383258002
  LookUpTable[661]=0.605
  LookUpTable[667]=0.59926112621978
  LookUpTable[674]=0.59357668991439
  LookUpTable[680]=0.58794617470398
  LookUpTable[687]=0.58236906910698
  LookUpTable[693]=0.57684486649358
  LookUpTable[700]=0.57137306503975
  LookUpTable[707]=0.5659531676816
  LookUpTable[714]=0.5605846820703
  LookUpTable[720]=0.55526712052729
  LookUpTable[727]=0.55
  LookUpTable[734]=0.54478284201799
  LookUpTable[741]=0.53961517264944
  LookUpTable[748]=0.53449652245817
  LookUpTable[756]=0.52942642646089
  LookUpTable[763]=0.52440442408507
  LookUpTable[770]=0.51943005912704
  LookUpTable[777]=0.51450287971055
  LookUpTable[785]=0.50962243824573
  LookUpTable[792]=0.50478829138844
  LookUpTable[800]=0.5
  local temp=16
  for i=25, 800 do
    if LookUpTable[i]~=nil then
      temp=LookUpTable[i]
    else
      LookUpTable[i]=nil
    end
  end
  local curval=reaper.SNM_GetDoubleConfigVar("specpeak_na", -99999)
  local curval = ultraschall.LimitFractionOfFloat(curval, 2)
  local found=0
  for i=25, 800 do
    if LookUpTable[i]~=nil and LookUpTable[i]>=curval then
      found=i
    end
  end
  
  local variance=reaper.SNM_GetIntConfigVar("specpeak_bv", -9999)/255
  variance = ultraschall.LimitFractionOfFloat(variance, 2)

  local alpha=(reaper.SNM_GetIntConfigVar("specpeak_alpha", -9999)/255)*1.328125
  alpha = ultraschall.LimitFractionOfFloat(alpha, 2)
  
  return found/100, variance, alpha
end


function ultraschall.AddProjectMarker(proj, isrgn, pos, rgnend, name, wantidx, color)
--[[
    <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
        <slug>AddProjectMarker</slug>
        <title>AddProjectMarker</title>
        <functioncall>integer index = ultraschall.AddProjectMarker2(ReaProject proj, boolean isrgn, number pos, number rgnend, string name, integer wantidx, integer color)</functioncall>
        <requires>
            Ultraschall=4.3
            Reaper=6.22
        </requires>
        <description>
            Creates a new projectmarker/region and returns the shown number, index and guid of the created marker/region. 
            
            Supply wantidx&gt;=0 if you want a particular index number, but you'll get a different index number a region and wantidx is already in use. color should be 0 (default color), or ColorToNative(r,g,b)|0x1000000
            
            Returns -1 in case of an error
        </description>
        <retvals>
            integer index - the shown-number of the newly created marker/region
            integer marker_region_index - the index of the newly created marker/region within all markers/regions
            string guid - the guid of the newly created marker/region
        </retvals>
        <linked_to desc="see:">
            inline:ColorToNative
                   to convert color-value to a native(Mac, Win, Linux) colors
        </linked_to>
        <parameters>
            ReaProject proj - the project, in which to add the new marker; use 0 for the current project; 
            boolean isrgn - true, if it shall be a region; false, if a normal marker
            number pos - the position of the newly created marker/region in seconds
            number rgnend - if the marker is a region, this is the end of the region in seconds
            string name - the shown name of the marker
            integer wantidx - the shown number of the marker/region. Markers can have the same shown marker multiple times. Regions will get another number, if wantidx is already given.
            integer color - the color of the marker
        </parameters>
        <target_document>US_Api_Functions</target_document>
        <source_document>Modules/ultraschall_functions_Markers_Module.lua</source_document>
        <chapter_context>
            Marker Management
            Project Markers
        </chapter_context>
        <tags>markermanagement, region, marker, name, shownnumber, pos, project, add, guid</tags>
        <changelog>
        </changelog>
    </US_DocBloc>
--]]
  if ultraschall.IsValidReaProject(proj)==false then ultraschall.AddErrorMessage("AddProjectMarker", "proj", "not a valid project", -1) return -1 end
  if type(isrgn)~="boolean" then ultraschall.AddErrorMessage("AddProjectMarker", "isrgn", "must be a boolean", -2) return -1 end
  if type(pos)~="number" then ultraschall.AddErrorMessage("AddProjectMarker", "pos", "must be a number", -3) return -1 end
  if type(rgnend)~="number" then ultraschall.AddErrorMessage("AddProjectMarker", "rgnend", "must be a number", -4) return -1 end
  if type(name)~="string" then ultraschall.AddErrorMessage("AddProjectMarker", "name", "must be a string", -5) return -1 end
  if math.type(wantidx)~="integer" then ultraschall.AddErrorMessage("AddProjectMarker", "wantidx", "must be an integer", -6) return -1 end
  if math.type(color)~="integer" then ultraschall.AddErrorMessage("AddProjectMarker", "color", "must be an integer", -7) return -1 end

  -- get attributes of the last marker in the project
  local LastMarker={reaper.EnumProjectMarkers3(proj, reaper.CountProjectMarkers(proj)-1)}
  
  -- add a marker AFTER the current last marker(makes finding Guid for it faster)
  local shown_number=reaper.AddProjectMarker2(proj, isrgn, LastMarker[3]+100, LastMarker[4]+100, name, wantidx, color)
  
  --if shown_number==-1 then ultraschall.AddErrorMessage("AddProjectMarker", "wantidx", "index already in use by a region", -10) return -1 end
  -- get the guid of the new last marker
  local retval, Guid = reaper.GetSetProjectInfo_String(proj, "MARKER_GUID:"..reaper.CountProjectMarkers(proj)-1, "", false)

  -- change position to the actual position of the marker
  local LastMarker2={reaper.EnumProjectMarkers3(proj, reaper.CountProjectMarkers(proj)-1)} -- get the current shown marker-number
  reaper.SetProjectMarkerByIndex2(proj, reaper.CountProjectMarkers(proj)-1, isrgn, pos, rgnend, LastMarker2[6], name, color, 0)
  
  -- find the index-position of the marker by its Guid
  local found_marker_index="Buggy" -- debugline, hope it never gets triggered
  for i=0, reaper.CountProjectMarkers() do
    local retval2, Guid2 = reaper.GetSetProjectInfo_String(proj, "MARKER_GUID:"..i, "", false)
    if Guid2==Guid then found_marker_index=i break end
  end
  
  return shown_number, found_marker_index, Guid
end