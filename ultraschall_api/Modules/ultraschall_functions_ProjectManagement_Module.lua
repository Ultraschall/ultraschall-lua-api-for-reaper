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

