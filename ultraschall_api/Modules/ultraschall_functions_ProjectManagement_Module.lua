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
---  Projects: Management Module  ---
-------------------------------------

if type(ultraschall)~="table" then 
  -- update buildnumber and add ultraschall as a table, when programming within this file
  local retval, string = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "Functions-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  local retval, string = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "Projectmanagement-Projectfiles-Module-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
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


function ultraschall.CountProjectTabs()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CountProjectTabs</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer number_of_projecttabs = ultraschall.CountProjectTabs()</functioncall>
  <description>
    Counts the number of opened project tabs.
  </description>
  <retvals>
    integer number_of_projecttabs - the number of projecttabs currently opened
  </retvals>
  <chapter_context>
    Project-Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helperfunctions, projectfiles, count, projecttab</tags>
</US_DocBloc>
]]
  local ProjCount=-1
  local Aretval="t"
  while Aretval~=nil do
    local Aretval, Aprojfn = reaper.EnumProjects(ProjCount+1, "")
    if Aretval~=nil then ProjCount=ProjCount+1
    else break
    end
  end
  return ProjCount+1
end

function ultraschall.GetProject_Tabs()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetProject_Tabs</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer number_of_projecttabs, array projecttablist = ultraschall.GetProject_Tabs()</functioncall>
  <description>
    Returns the ReaProject-objects, as well as the filenames of all opened project-tabs.
  </description>
  <retvals>
    integer number_of_projecttabs - the number of projecttabs currently opened
    array projecttablist - an array, that holds all ReaProjects as well as the projectfilenames
                         - projecttablist[idx][1] = ReaProject
                         - projecttablist[idx][2] = projectfilename with path
  </retvals>
  <chapter_context>
    Project-Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helperfunctions, projectfiles, count, projecttab, project, filename</tags>
</US_DocBloc>
]]
  local ProjTabList={}
  local CountProj=ultraschall.CountProjectTabs()
  for i=1, CountProj do
    ProjTabList[i]={}
    ProjTabList[i][1], ProjTabList[i][2] = reaper.EnumProjects(i-1, "")
  end  
  return CountProj, ProjTabList
end

ultraschall.tempCount, ultraschall.tempProjects = ultraschall.GetProject_Tabs()
if ultraschall.ProjectList==nil then 
  ultraschall.ProjectList=Projects ultraschall.ProjectCount=ultraschall.tempCount
end


function ultraschall.IsValidProjectStateChunk(ProjectStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsValidProjectStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.IsValidProjectStateChunk(string ProjectStateChunk)</functioncall>
  <description>
    Checks, whether ProjectStateChunk is a valid ProjectStateChunk
  </description>
  <parameters>
    string ProjectStateChunk - the string to check, if it's a valid ProjectStateChunk
  </parameters>
  <retvals>
    boolean retval - true, if it's a valid ProjectStateChunk; false, if not
  </retvals>
  <chapter_context>
    Project-Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>projectfiles, rpp, projectstatechunk, statechunk, check, valid</tags>
</US_DocBloc>
]]  
  if type(ProjectStateChunk)=="string" and ProjectStateChunk:match("^<REAPER_PROJECT.*>")~=nil then return true else return false end
end


ultraschall.LastProjectStateChunk_Time=reaper.time_precise()

function ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>GetProjectStateChunk</slug>
    <requires>
      Ultraschall=4.00
      Reaper=5.975
      SWS=2.10.0.1
      JS=0.972
      Lua=5.3
    </requires>
    <functioncall>string ProjectStateChunk = ultraschall.GetProjectStateChunk(optional string projectfilename_with_path, optional boolean keepqrender)</functioncall>
    <description>
      Gets the ProjectStateChunk of the current active project or a projectfile.
      
      Important: when calling it too often in a row, this might fail and result in a timeout-error. 
      I tried to circumvent this, but best practice is to wait 2-3 seconds inbetween calling this function.
      This function also eats up a lot of resources, so be sparse with it in general!
      
      returns nil if getting the ProjectStateChunk took too long
    </description>
    <retvals>
      string ProjectStateChunk - the ProjectStateChunk of the current project; nil, if getting the ProjectStateChunk took too long
    </retvals>
    <parameters>
      optional string projectfilename_with_path - the filename of an rpp-projectfile, that you want to load as ProjectStateChunk; nil, to get the ProjectStateChunk from the currently active project
      optional boolean keepqrender - true, keeps the QUEUED_RENDER_OUTFILE and QUEUED_RENDER_ORIGINAL_FILENAME entries in the ProjectStateChunk, if existing; false or nil, remove them
    </parameters>
    <chapter_context>
      Project-Files
      Helper functions
    </chapter_context>
    <target_document>US_Api_Documentation</target_document>
    <source_document>ultraschall_functions_engine.lua</source_document>
    <tags>projectmanagement, get, projectstatechunk</tags>
  </US_DocBloc>
  ]]  
    
  -- This function puts the current project into the render-queue and reads it from there.
  -- For that, 
  --    1) it gets all files in the render-queue
  --    2) it adds the current project to the renderqueue
  --    3) it waits, until Reaper has added the file to the renderqueue, reads it and deletes the file afterwards
  -- It also deals with edge-case-stuff to avoid render-dialogs/warnings popping up.
  --
  -- In Lua, this has an issue, as sometimes the filelist with EnumerateFiles isn't updated in ReaScript.
  -- Why that is is mysterious. I hope, it can be curcumvented in C++


  -- if a filename is given, read the file and check, whether it's a valid ProjectStateChunk. 
  -- If yes, return it. Otherwise error.
  local ProjectStateChunk
  if projectfilename_with_path~=nil then 
    ProjectStateChunk=ultraschall.ReadFullFile(projectfilename_with_path)
    if ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("GetProjectStateChunk", "projectfilename_with_path", "must be a valid ReaProject or nil", -1) return nil end
    return ProjectStateChunk
  end
  
  if ultraschall.LastProjectStateChunk_Time+3>=reaper.time_precise() then
    local i=0
    while l==nil do
      i=i+1
      if i==10000000
      then break end
    end
  end
  
  ultraschall.LastProjectStateChunk_Time=reaper.time_precise()
  
  -- get the currently focused hwnd; will be restored after function is done
  -- this is due Reaper changing the focused hwnd, when adding projects to the render-queue
  local oldfocushwnd = reaper.JS_Window_GetFocus()
      
  -- turn off renderqdelay temporarily, as otherwise this could display a render-queue-delay dialog
  -- old setting will be restored later
  local qretval, qlength = ultraschall.GetRender_QueueDelay()
  local retval = ultraschall.SetRender_QueueDelay(false, qlength)
      
  -- turn on auto-increment filename temporarily, to avoid the "filename already exists"-dialog popping up
  -- old setting will be restored later
  local old_autoincrement = ultraschall.GetRender_AutoIncrementFilename()
  ultraschall.SetRender_AutoIncrementFilename(true)  
  
  -- get all filenames currently in the render-queue
  local oldbounds, oldstartpos, oldendpos, prep_changes, files, files2, filecount, filecount2    
  filecount, files = ultraschall.GetAllFilenamesInPath(reaper.GetResourcePath().."\\QueuedRenders")
      
  -- if Projectlength=0 or CountofTracks==0, set render-settings for empty projects(workaround for that edgecase)
  -- old settings will be restored later
  if reaper.CountTracks()==0 or reaper.GetProjectLength()==0 then
    -- get old settings
    oldbounds   =reaper.GetSetProjectInfo(0, "RENDER_BOUNDSFLAG", 0, false)
    oldstartpos =reaper.GetSetProjectInfo(0, "RENDER_STARTPOS", 0, false)
    oldendpos   =reaper.GetSetProjectInfo(0, "RENDER_ENDPOS", 1, false)  
       
    -- set useful defaults that'll make adding the project to the render-queue possible always
    reaper.GetSetProjectInfo(0, "RENDER_BOUNDSFLAG", 0, true)
    reaper.GetSetProjectInfo(0, "RENDER_STARTPOS", 0, true)
    reaper.GetSetProjectInfo(0, "RENDER_ENDPOS", 1, true)
    
    -- set prep_changes to true, so we know, we need to reset these settings, later
    prep_changes=true
  end
      
  -- add current project to render-queue
  reaper.Main_OnCommand(41823,0)
     
  -- wait, until Reaper has added the project to the render-queue and get it's filename
  -- 
  -- there's a timeout, to avoid hanging scripts, as ReaScript doesn't always update it's filename-lists
  -- gettable using reaper.EnumerateFiles(which I'm using in GetAllFilenamesInPath)
  --
  -- other workarounds, using ls/dir in console is too slow and has possible problems with filenames 
  -- containing Unicode
  local i=0
  while l==nil do
    i=i+1
    filecount2, files2 = ultraschall.GetAllFilenamesInPath(reaper.GetResourcePath().."\\QueuedRenders")
    if filecount2~=filecount then 
      break 
    end
    if i==100000--00
      then ultraschall.AddErrorMessage("GetProjectStateChunk", "", "timeout: Getting the ProjectStateChunk took too long for some reasons, please report this as bug to me and include the projectfile with which this happened!", -2) return end
  end
  local duplicate_count, duplicate_array, originalscount_array1, originals_array1, originalscount_array2, originals_array2 = ultraschall.GetDuplicatesFromArrays(files, files2)

   -- read found render-queued-project and delete it
  local ProjectStateChunk=ultraschall.ReadFullFile(originals_array2[1])
  os.remove(originals_array2[1])
  
  -- reset temporarily changed settings in the current project, as well as in the ProjectStateChunk itself
  if prep_changes==true then
    reaper.GetSetProjectInfo(0, "RENDER_BOUNDSFLAG", oldbounds, true)
    reaper.GetSetProjectInfo(0, "RENDER_STARTPOS", oldstartpos, true)
    reaper.GetSetProjectInfo(0, "RENDER_ENDPOS", oldendpos, true)
    retval, ProjectStateChunk = ultraschall.SetProject_RenderRange(nil, math.floor(oldbounds), math.floor(oldstartpos), math.floor(oldendpos), math.floor(reaper.GetSetProjectInfo(0, "RENDER_TAILFLAG", 0, false)), math.floor(reaper.GetSetProjectInfo(0, "RENDER_TAILMS", 0, false)), ProjectStateChunk)
  end
      
  -- remove QUEUED_RENDER_ORIGINAL_FILENAME and QUEUED_RENDER_OUTFILE-entries, if keepqrender==true
  if keepqrender~=true then
    ProjectStateChunk=string.gsub(ProjectStateChunk, "  QUEUED_RENDER_OUTFILE .-%c", "")
    ProjectStateChunk=string.gsub(ProjectStateChunk, "  QUEUED_RENDER_ORIGINAL_FILENAME .-%c", "")
  end
      
  -- reset old auto-increment-checkbox-state
  ultraschall.SetRender_AutoIncrementFilename(old_autoincrement)
      
  -- reset old hwnd-focus-state 
  reaper.JS_Window_SetFocus(oldfocushwnd)
  
  -- restore old render-qdelay-setting
  retval = ultraschall.SetRender_QueueDelay(qretval, qlength)
  
  -- return the final ProjectStateChunk
  return ProjectStateChunk
end