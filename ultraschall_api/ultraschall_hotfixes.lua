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

-- This is the file for hotfixes of buggy functions.

-- If you have found buggy functions, you can submit fixes within here.
--      a) copy the function you found buggy into ultraschall_hotfixes.lua
--      b) debug the function IN HERE(!)
--      c) comment, what you've changed(this is for me to find out, what you did)
--      d) add information to the <US_DocBloc>-bloc of the function. So if the information in the
--         <US_DocBloc> isn't correct anymore after your changes, rewrite it to fit better with your fixes
--      e) add as an additional comment in the function your name and a link to something you do(the latter, if you want), 
--         so I can credit you and your contribution properly
--      f) submit the file as PullRequest via Github: https://github.com/Ultraschall/Ultraschall-Api-for-Reaper.git (preferred !)
--         or send it via lspmp3@yahoo.de(only if you can't do it otherwise!)
--
-- As soon as these functions are in here, they can be used the usual way through the API. They overwrite the older buggy-ones.
--
-- These fixes, once I merged them into the master-branch, will become part of the current version of the Ultraschall-API, 
-- until the next version will be released. The next version will has them in the proper places added.
-- That way, you can help making it more stable without being dependent on me, while I'm busy working on new features.
--
-- If you have new functions to contribute, you can use this file as well. Keep in mind, that I will probably change them to work
-- with the error-messaging-system as well as adding information for the API-documentation.
ultraschall.hotfixdate="30_May_2020"

--ultraschall.ShowLastErrorMessage()

function ultraschall.ApplyRenderTable_Project(RenderTable, apply_rendercfg_string)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ApplyRenderTable_Project</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.10
    SWS=2.10.0.1
    JS=0.972
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ApplyRenderTable_Project(RenderTable RenderTable, optional boolean apply_rendercfg_string)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Sets all stored render-settings from a RenderTable as the current project-settings.

	Note: On Reaper 6.10, you cannot set AddToProj and NoSilentRender simultaneously due a bug in Reaper; is fixed in higher versions.
            
    Expected table is of the following structure:
            RenderTable["AddToProj"] - Add rendered items to new tracks in project-checkbox; true, checked; false, unchecked
            RenderTable["Bounds"] - 0, Custom time range; 1, Entire project; 2, Time selection; 3, Project regions; 4, Selected Media Items(in combination with Source 32); 5, Selected regions
            RenderTable["Channels"] - the number of channels in the rendered file; 1, mono; 2, stereo; higher, the number of channels
            RenderTable["CloseAfterRender"] - true, close rendering to file-dialog after render; false, don't close it
            RenderTable["Dither"] - &1, dither master mix; &2, noise shaping master mix; &4, dither stems; &8, dither noise shaping stems
            RenderTable["EmbedStretchMarkers"] - Embed stretch markers/transient guides; true, checked; false, unchecked
			RenderTable["EmbedTakeMarkers"] - Embed Take markers; true, checked; false, unchecked
            RenderTable["Endposition"] - the endposition of the rendering selection in seconds
            RenderTable["MultiChannelFiles"] - Multichannel tracks to multichannel files-checkbox; true, checked; false, unchecked
			RenderTable["NoSilentRender"] - Do not render files that are likely silent-checkbox; true, checked; false, unchecked
            RenderTable["OfflineOnlineRendering"] - Offline/Online rendering-dropdownlist; 0, Full-speed Offline; 1, 1x Offline; 2, Online Render; 3, Online Render(Idle); 4, Offline Render(Idle)
            RenderTable["OnlyMonoMedia"] - Tracks with only mono media to mono files-checkbox; true, checked; false, unchecked
            RenderTable["ProjectSampleRateFXProcessing"] - Use project sample rate for mixing and FX/synth processing-checkbox; true, checked; false, unchecked
            RenderTable["RenderFile"] - the contents of the Directory-inputbox of the Render to File-dialog
            RenderTable["RenderPattern"] - the render pattern as input into the File name-inputbox of the Render to File-dialog
            RenderTable["RenderQueueDelay"] - Delay queued render to allow samples to load-checkbox; true, checked; false, unchecked
            RenderTable["RenderQueueDelaySeconds"] - the amount of seconds for the render-queue-delay
            RenderTable["RenderResample"] - Resample mode-dropdownlist; 0, Medium (64pt Sinc); 1, Low (Linear Interpolation); 2, Lowest (Point Sampling); 3, Good (192pt Sinc); 4, Better (348 pt Sinc); 5, Fast (IIR + Linear Interpolation); 6, Fast (IIRx2 + Linear Interpolation); 7, Fast (16pt Sinc); 8, HQ (512 pt); 9, Extreme HQ(768pt HQ Sinc)
            RenderTable["RenderString"] - the render-cfg-string, that holds all settings of the currently set render-output-format as BASE64 string
            RenderTable["RenderString2"] - the render-cfg-string, that holds all settings of the currently set secondary-render-output-format as BASE64 string
            RenderTable["RenderTable"]=true - signals, this is a valid render-table
            RenderTable["SampleRate"] - the samplerate of the rendered file(s)
            RenderTable["SaveCopyOfProject"] - the "Save copy of project to outfile.wav.RPP"-checkbox; true, checked; false, unchecked
            RenderTable["SilentlyIncrementFilename"] - Silently increment filenames to avoid overwriting-checkbox; true, checked; false, unchecked
            RenderTable["Source"] - 0, Master mix; 1, Master mix + stems; 3, Stems (selected tracks); 8, Region render matrix; 16, Tracks with only Mono-Media to Mono Files; 32, Selected media items; 64, selected media items via master; 128, selected tracks via master
            RenderTable["Startposition"] - the startposition of the rendering selection in seconds
            RenderTable["TailFlag"] - in which bounds is the Tail-checkbox checked? &1, custom time bounds; &2, entire project; &4, time selection; &8, all project regions; &16, selected media items; &32, selected project regions
            RenderTable["TailMS"] - the amount of milliseconds of the tail
            
    Returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, setting the render-settings was successful; false, it wasn't successful
  </retvals>
  <parameters>
    RenderTable RenderTable - a RenderTable, that contains all render-dialog-settings
    optional boolean apply_rendercfg_string - true or nil, apply it as well; false, don't apply it
  </parameters>
  <chapter_context>
    Rendering Projects
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Render_Module.lua</source_document>
  <tags>projectfiles, set, project, rendertable</tags>
</US_DocBloc>
]]
	
  if ultraschall.IsValidRenderTable(RenderTable)==false then ultraschall.AddErrorMessage("ApplyRenderTable_Project", "RenderTable", "not a valid RenderTable", -1) return false end
  if apply_rendercfg_string~=nil and type(apply_rendercfg_string)~="boolean" then ultraschall.AddErrorMessage("ApplyRenderTable_Project", "apply_rendercfg_string", "must be boolean", -2) return false end
  local _temp, retval, hwnd, AddToProj, ProjectSampleRateFXProcessing, ReaProject, SaveCopyOfProject, retval
  if ReaProject==nil then ReaProject=0 end
  
  if RenderTable["EmbedStretchMarkers"]==true then 
	if RenderTable["Source"]&256==0 then RenderTable["Source"]=RenderTable["Source"]+256 end
  else 
	if RenderTable["Source"]&256~=0 then RenderTable["Source"]=RenderTable["Source"]-256 end
  end
  if RenderTable["EmbedTakeMarkers"]==true then 
	if RenderTable["Source"]&1024==0 then RenderTable["Source"]=RenderTable["Source"]+1024 end
  else 
	if RenderTable["Source"]&1024~=0 then RenderTable["Source"]=RenderTable["Source"]-1024 end
  end
  
  if RenderTable["MultiChannelFiles"]==true and RenderTable["Source"]&4~=0 then RenderTable["Source"]=RenderTable["Source"]+4 end
  if RenderTable["OnlyMonoMedia"]==false and RenderTable["Source"]&16~=0 then RenderTable["Source"]=RenderTable["Source"]+16 end
  
  reaper.GetSetProjectInfo(ReaProject, "RENDER_SETTINGS", RenderTable["Source"], true)
  reaper.GetSetProjectInfo(ReaProject, "RENDER_BOUNDSFLAG", RenderTable["Bounds"], true)
  
  reaper.GetSetProjectInfo(ReaProject, "RENDER_CHANNELS", RenderTable["Channels"], true)
  reaper.GetSetProjectInfo(ReaProject, "RENDER_SRATE", RenderTable["SampleRate"], true)
  
  reaper.GetSetProjectInfo(ReaProject, "RENDER_STARTPOS", RenderTable["Startposition"], true)
  reaper.GetSetProjectInfo(ReaProject, "RENDER_ENDPOS", RenderTable["Endposition"], true)
  reaper.GetSetProjectInfo(ReaProject, "RENDER_TAILFLAG", RenderTable["TailFlag"], true)
  reaper.GetSetProjectInfo(ReaProject, "RENDER_TAILMS", RenderTable["TailMS"], true)
  
  if RenderTable["AddToProj"]==true then AddToProj=1 else AddToProj=0 end
  if RenderTable["NoSilentRender"]==true then AddToProj=AddToProj+2 end

  reaper.GetSetProjectInfo(ReaProject, "RENDER_ADDTOPROJ", AddToProj, true)
  reaper.GetSetProjectInfo(ReaProject, "RENDER_DITHER", RenderTable["Dither"], true)
  
  ultraschall.SetRender_ProjectSampleRateForMix(RenderTable["ProjectSampleRateFXProcessing"])
  ultraschall.SetRender_AutoIncrementFilename(RenderTable["SilentlyIncrementFilename"])
  ultraschall.SetRender_QueueDelay(RenderTable["RenderQueueDelay"], RenderTable["RenderQueueDelaySeconds"])
  ultraschall.SetRender_ResampleMode(RenderTable["RenderResample"])
  ultraschall.SetRender_OfflineOnlineMode(RenderTable["OfflineOnlineRendering"])
  
  if RenderTable["RenderFile"]==nil then RenderTable["RenderFile"]="" end
  if RenderTable["RenderPattern"]==nil then 
    local path, filename = ultraschall.GetPath(RenderTable["RenderFile"])
    if filename:match(".*(%.).")~=nil then
      RenderTable["RenderPattern"]=filename:match("(.*)%.")
      RenderTable["RenderFile"]=string.gsub(path,"\\\\", "\\")
    else
      RenderTable["RenderPattern"]=filename
      RenderTable["RenderFile"]=string.gsub(path,"\\\\", "\\")
    end
  end
  reaper.GetSetProjectInfo_String(ReaProject, "RENDER_FILE", RenderTable["RenderFile"], true)
  reaper.GetSetProjectInfo_String(ReaProject, "RENDER_PATTERN", RenderTable["RenderPattern"], true)
  if apply_rendercfg_string~=false then
    reaper.GetSetProjectInfo_String(ReaProject, "RENDER_FORMAT", RenderTable["RenderString"], true)
    reaper.GetSetProjectInfo_String(ReaProject, "RENDER_FORMAT2", RenderTable["RenderString2"], true)
  end
  
  if RenderTable["SaveCopyOfProject"]==true then SaveCopyOfProject=1 else SaveCopyOfProject=0 end
  hwnd = ultraschall.GetRenderToFileHWND()
  if hwnd==nil then
    retval = reaper.BR_Win32_WritePrivateProfileString("REAPER", "autosaveonrender2", SaveCopyOfProject, reaper.get_ini_file())
  else
    reaper.JS_WindowMessage_Send(reaper.JS_Window_FindChildByID(hwnd,1060), "BM_SETCHECK", SaveCopyOfProject,0,0,0)
  end
  
  if reaper.SNM_GetIntConfigVar("renderclosewhendone",-199)&1==0 and RenderTable["CloseAfterRender"]==true then
    local temp = reaper.SNM_GetIntConfigVar("renderclosewhendone",-199)+1
    reaper.SNM_SetIntConfigVar("renderclosewhendone", temp)
  elseif reaper.SNM_GetIntConfigVar("renderclosewhendone",-199)&1==1 and RenderTable["CloseAfterRender"]==false then
    local temp = reaper.SNM_GetIntConfigVar("renderclosewhendone",-199)-1
    reaper.SNM_SetIntConfigVar("renderclosewhendone", temp)
  end
  return true
end

function ultraschall.ApplyRenderTable_ProjectFile(RenderTable, projectfilename_with_path, apply_rendercfg_string, ProjectStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ApplyRenderTable_ProjectFile</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.10
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string ProjectStateChunk = ultraschall.ApplyRenderTable_ProjectFile(RenderTable RenderTable, string projectfilename_with_path, optional boolean apply_rendercfg_string, optional string ProjectStateChunk)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Sets all stored render-settings from a RenderTable as the current project-settings.
            
    Expected table is of the following structure:
            RenderTable["AddToProj"] - Add rendered items to new tracks in project-checkbox; true, checked; false, unchecked
            RenderTable["Bounds"] - 0, Custom time range; 1, Entire project; 2, Time selection; 3, Project regions; 4, Selected Media Items(in combination with Source 32); 5, Selected regions
            RenderTable["Channels"] - the number of channels in the rendered file; 1, mono; 2, stereo; higher, the number of channels
            RenderTable["CloseAfterRender"] - close rendering to file-dialog after render; ignored, as this can't be set in projectfiles
            RenderTable["Dither"] - &1, dither master mix; &2, noise shaping master mix; &4, dither stems; &8, dither noise shaping stems
            RenderTable["EmbedStretchMarkers"] - Embed stretch markers/transient guides; true, checked; false, unchecked
			RenderTable["EmbedTakeMarkers"] - Embed Take markers; true, checked; false, unchecked
            RenderTable["Endposition"] - the endposition of the rendering selection in seconds
            RenderTable["MultiChannelFiles"] - Multichannel tracks to multichannel files-checkbox; true, checked; false, unchecked
			RenderTable["NoSilentRender"] - Do not render files that are likely silent-checkbox; true, checked; false, unchecked
            RenderTable["OfflineOnlineRendering"] - Offline/Online rendering-dropdownlist; 0, Full-speed Offline; 1, 1x Offline; 2, Online Render; 3, Online Render(Idle); 4, Offline Render(Idle);  
            RenderTable["OnlyMonoMedia"] - Tracks with only mono media to mono files-checkbox; true, checked; false, unchecked
            RenderTable["ProjectSampleRateFXProcessing"] - Use project sample rate for mixing and FX/synth processing-checkbox; true, checked; false, unchecked
            RenderTable["RenderFile"] - the contents of the Directory-inputbox of the Render to File-dialog
            RenderTable["RenderPattern"] - the render pattern as input into the File name-inputbox of the Render to File-dialog
            RenderTable["RenderQueueDelay"] - Delay queued render to allow samples to load-checkbox
            RenderTable["RenderQueueDelaySeconds"] - the amount of seconds for the render-queue-delay
            RenderTable["RenderResample"] - Resample mode-dropdownlist; 0, Medium (64pt Sinc); 1, Low (Linear Interpolation); 2, Lowest (Point Sampling); 3, Good (192pt Sinc); 4, Better (348 pt Sinc); 5, Fast (IIR + Linear Interpolation); 6, Fast (IIRx2 + Linear Interpolation); 7, Fast (16pt Sinc); 8, HQ (512 pt); 9, Extreme HQ(768pt HQ Sinc)
            RenderTable["RenderString"] - the render-cfg-string, that holds all settings of the currently set render-output-format as BASE64 string
            RenderTable["RenderString2"] - the render-cfg-string, that holds all settings of the currently set secondary-render-output-format as BASE64 string
            RenderTable["RenderTable"]=true - signals, this is a valid render-table
            RenderTable["SampleRate"] - the samplerate of the rendered file(s)
            RenderTable["SaveCopyOfProject"] - the "Save copy of project to outfile.wav.RPP"-checkbox; ignored, as this can't be stored in projectfiles
            RenderTable["SilentlyIncrementFilename"] - Silently increment filenames to avoid overwriting-checkbox; ignored, as this can't be stored in projectfiles
            RenderTable["Source"] - 0, Master mix; 1, Master mix + stems; 3, Stems (selected tracks); 8, Region render matrix; 16, Tracks with only Mono-Media to Mono Files; 32, Selected media items; 64, selected media items via master; 128, selected tracks via master
            RenderTable["Startposition"] - the startposition of the rendering selection in seconds
            RenderTable["TailFlag"] - in which bounds is the Tail-checkbox checked? &1, custom time bounds; &2, entire project; &4, time selection; &8, all project regions; &16, selected media items; &32, selected project regions
            RenderTable["TailMS"] - the amount of milliseconds of the tail
            
    Returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, setting the render-settings was successful; false, it wasn't successful
    string ProjectStateChunk - the altered project/ProjectStateChunk as a string
  </retvals>
  <parameters>
    RenderTable RenderTable - a RenderTable, that contains all render-dialog-settings
    string projectfilename_with_path - the rpp-projectfile, to which you want to apply the RenderTable; nil, to use parameter ProjectStateChunk instead
    optional boolean apply_rendercfg_string - true or nil, apply it as well; false, don't apply it
    optional parameter ProjectStateChunk - the ProjectStateChunkk, to which you want to apply the RenderTable
  </parameters>
  <chapter_context>
    Rendering Projects
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Render_Module.lua</source_document>
  <tags>projectfiles, set, projectfile, rendertable</tags>
</US_DocBloc>
]]
  local retval, AddToProj, ProjectSampleRateFXProcessing
  if ultraschall.IsValidRenderTable(RenderTable)==false then ultraschall.AddErrorMessage("ApplyRenderTable_ProjectFile", "RenderTable", "not a valid RenderTable", -1) return false end
  
  if projectfilename_with_path==nil and ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("ApplyRenderTable_ProjectFile", "ProjectStateChunk", "not a valid ProjectStateChunk", -2) return false end
  if projectfilename_with_path~=nil and (type(projectfilename_with_path)~="string" or reaper.file_exists(projectfilename_with_path)==false) then ultraschall.AddErrorMessage("ApplyRenderTable_ProjectFile", "projectfilename_with_path", "no such file", -3) return false end
  if ProjectStateChunk==nil then ProjectStateChunk=ultraschall.ReadFullFile(projectfilename_with_path) end
  if ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("ApplyRenderTable_ProjectFile", "projectfilename_with_path", "not a valid rpp-projectfile", -4) return false end
  if apply_rendercfg_string~=nil and type(apply_rendercfg_string)~="boolean" then ultraschall.AddErrorMessage("ApplyRenderTable_ProjectFile", "apply_rendercfg_string", "must be boolean", -5) return false end
  
  
  
  if RenderTable["MultiChannelFiles"]==true and RenderTable["Source"]&4~=0 then RenderTable["Source"]=RenderTable["Source"]+4 end
  if RenderTable["OnlyMonoMedia"]==false and RenderTable["Source"]&16~=0 then RenderTable["Source"]=RenderTable["Source"]+16 end
  
  if RenderTable["EmbedStretchMarkers"]==true then 
    if RenderTable["Source"]&256==0 then 
       RenderTable["Source"]=RenderTable["Source"]+256
    end
  else
    if RenderTable["Source"]&256~=0 then 
       RenderTable["Source"]=RenderTable["Source"]-256
    end
  end
  if RenderTable["EmbedTakeMarkers"]==true then 
    if RenderTable["Source"]&1024==0 then 
       RenderTable["Source"]=RenderTable["Source"]+1024
    end
  else
    if RenderTable["Source"]&1024~=0 then 
       RenderTable["Source"]=RenderTable["Source"]-1024
    end
  end
  retval, ProjectStateChunk = ultraschall.SetProject_RenderStems(nil, RenderTable["Source"], ProjectStateChunk)
  retval, ProjectStateChunk = ultraschall.SetProject_RenderRange(nil, RenderTable["Bounds"], RenderTable["Startposition"], RenderTable["Endposition"], RenderTable["TailFlag"], RenderTable["TailMS"], ProjectStateChunk)  
  retval, ProjectStateChunk = ultraschall.SetProject_RenderFreqNChans(nil, 0, RenderTable["Channels"], RenderTable["SampleRate"], ProjectStateChunk)

  if RenderTable["AddToProj"]==true then AddToProj=1 else AddToProj=0 end  
  if RenderTable["NoSilentRender"]==true then AddToProj=AddToProj+2 end 
  retval, ProjectStateChunk = ultraschall.SetProject_AddMediaToProjectAfterRender(nil, AddToProj, ProjectStateChunk)

    
  retval, ProjectStateChunk = ultraschall.SetProject_RenderDitherState(nil, RenderTable["Dither"], ProjectStateChunk)
  
  if RenderTable["ProjectSampleRateFXProcessing"]==true then ProjectSampleRateFXProcessing=1 else ProjectSampleRateFXProcessing=0 end
  local resample_mode, playback_resample_mode, project_smplrate4mix_and_fx = ultraschall.GetProject_RenderResample(nil, ProjectStateChunk)
  retval, ProjectStateChunk = ultraschall.SetProject_RenderResample(nil, RenderTable["RenderResample"], playback_resample_mode, ProjectSampleRateFXProcessing, ProjectStateChunk)
  
  retval, ProjectStateChunk = ultraschall.SetProject_RenderSpeed(nil, RenderTable["OfflineOnlineRendering"], ProjectStateChunk)
  retval, ProjectStateChunk = ultraschall.SetProject_RenderFilename(nil, RenderTable["RenderFile"], ProjectStateChunk)
  retval, ProjectStateChunk = ultraschall.SetProject_RenderPattern(nil, RenderTable["RenderPattern"], ProjectStateChunk)

  if RenderTable["RenderQueueDelay"]==true then 
    retval, ProjectStateChunk = ultraschall.SetProject_RenderQueueDelay(nil, RenderTable["RenderQueueDelaySeconds"], ProjectStateChunk)
  else
    retval, ProjectStateChunk = ultraschall.SetProject_RenderQueueDelay(nil, nil, ProjectStateChunk)
  end
  
  if apply_rendercfg_string==true or apply_rendercfg_string==nil then
    retval, ProjectStateChunk = ultraschall.SetProject_RenderCFG(nil, RenderTable["RenderString"], RenderTable["RenderString2"], ProjectStateChunk)
  end
  
  if projectfilename_with_path~=nil then ultraschall.WriteValueToFile(projectfilename_with_path, ProjectStateChunk) return true, ProjectStateChunk
  else return true, ProjectStateChunk
  end
end

