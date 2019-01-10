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

-- This is the file for hotfixes of buggy functions.

-- If you have found buggy functions, you can submit fixes within here.
--      a) copy the function you found buggy into ultraschall_hotfixes.lua
--      b) debug the function IN HERE(!)
--      c) comment, what you've changed(this is for me to find out, what you did)
--      d) add information to the <US_DocBloc>-bloc of the function. So if the information in the
--         <US_DocBloc> isn't correct anymore after your changes, rewrite it to fit better with your fixes
--      e) add your name into it and a link to something you do(the latter, if you want), so I can credit you and your contribution properly
--      f) submit the file as PullRequest via Github: https://github.com/Ultraschall/Ultraschall-Api-for-Reaper.git (preferred !)
--         or send it via lspmp3@yahoo.de(only if you can't do it otherwise!)
--
-- As soon as these functions are in here, they can be used the usual way through the API. They overwrite the older buggy-ones.
--
-- These fixes, once I merged them into the master-branch, will become part of the current version of the Ultraschall-API, 
-- until the next version will be released. The next version will has them in the proper places added.
-- That way, you can help making it more stable without being dependend on me, while I'm busy working on new features.
--
-- If you have new functions to contribute, you can use this file as well. Keep in mind, that I will probably change them to work
-- with the error-messaging-system as well as adding information for the API-documentation.

ultraschall.hotfixdate="10_Jan_2019"

function ultraschall.GetMarkerByScreenCoordinates(xmouseposition, retina)
--returns a string with the marker(s) in the timeline at given 
--screen-x-position. No Regions!
--string will be "Markeridx\npos\nName\nMarkeridx2\npos2\nName2"

--xmouseposition - x mouseposition
--retina - if it's retina/hiDPI, set it true, else, set it false

--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetMarkerByScreenCoordinates</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string marker = ultraschall.GetMarkerByScreenCoordinates(integer xmouseposition, boolean retina)</functioncall>
  <description>
    returns the markers at a given absolute-x-pixel-position. It sees markers according their graphical representation in the arrange-view, not just their position! Returned string will be "Markeridx\npos\nName\nMarkeridx2\npos2\nName2\n...".
    Returns only markers, no time markers or regions!
    
    returns nil in case of an error
  </description>
  <retvals>
    string marker - a string with all markernumbers, markerpositions and markertitles, separated by a newline. 
    -Can contain numerous markers, if there are more markers in one position.
  </retvals>
  <parameters>
    integer xmouseposition - the absolute x-screen-position, like current mouse-position
    boolean retina - if the screen-resolution is retina or hidpi, turn this true, else false
  </parameters>
  <chapter_context>
    Markers
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>markermanagement, navigation, get marker, position, marker</tags>
</US_DocBloc>
]]
  if math.type(xmouseposition)~="integer" then ultraschall.AddErrorMessage("GetMarkerByScreenCoordinates", "xmouseposition", "must be an integer", -1) return nil end
  local one,two,three,four,five,six,seven,eight,nine,ten
  if retina==false then
    ten=84
    nine=76
    eight=68
    seven=60
    six=52
    five=44
    four=36
    three=28
    two=20
    one=12
  else
    ten=84*2
    nine=76*2
    eight=68*2
    seven=60*2
    six=52*2
    five=44*2
    four=36*2
    three=28*2
    two=20*2
    one=12*2
  end
  local retstring=""
  local temp
  
  local retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
  for i=0, retval do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3(0, i)
    if isrgn==false then
      if markrgnindexnumber>999999999 then temp=ten
      elseif markrgnindexnumber>99999999 and markrgnindexnumber<1000000000  then temp=nine
      elseif markrgnindexnumber>9999999 and markrgnindexnumber<100000000 then temp=eight
      elseif markrgnindexnumber>999999 and markrgnindexnumber<10000000 then temp=seven
      elseif markrgnindexnumber>99999 and markrgnindexnumber<1000000 then temp=six
      elseif markrgnindexnumber>9999 and markrgnindexnumber<100000 then temp=five
      elseif markrgnindexnumber>999 and markrgnindexnumber<10000 then temp=four
      elseif markrgnindexnumber>99 and markrgnindexnumber<1000 then temp=three
      elseif markrgnindexnumber>9 and markrgnindexnumber<100 then temp=two
      elseif markrgnindexnumber>-1 and markrgnindexnumber<10 then temp=one
      end
      local Ax,AAx= reaper.GetSet_ArrangeView2(0, false, xmouseposition-temp,xmouseposition) 
      local ALABAMA=xmouseposition
      if pos>=Ax and pos<=AAx then retstring=retstring..markrgnindexnumber.."\n"..pos.."\n"..name end
    end
  end
  return retstring--:match("(.-)%c.-%c")), tonumber(retstring:match(".-%c(.-)%c")), retstring:match(".-%c.-%c(.*)")
end

function ultraschall.GetMarkerByTime(position, retina)
--returns a string with the marker(s) at given timeline-position. No Regions!
--string will be "Markeridx\npos\nName\nMarkeridx2\npos2\nName2"

--position - position in time
--retina - if it's retina/hiDPI, set it true, else, set it false

--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetMarkerByTime</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    SWS=2.8.8
    Lua=5.3
  </requires>
  <functioncall>string markers = ultraschall.GetMarkerByTime(number position, boolean retina)</functioncall>
  <description>
    returns the markers at a given project-position in seconds. 
    It sees markers according their actual graphical representation in the arrange-view, not just their position. 
    If, for example, you pass to it the current playposition, the function will return the marker as long as the playcursor is behind the marker-graphics.
    
    Returned string will be "Markeridx\npos\nName\nMarkeridx2\npos2\nName2\n...".
    Returns only markers, no time markers or regions!
  </description>
  <retvals>
    string marker - a string with all markernumbers, markerpositions and markertitles, separated by a newline. 
    -Can contain numerous markers, if there are more markers in one position.
  </retvals>
  <parameters>
    number position - the time-position in seconds
    boolean retina - if the screen-resolution is retina or hidpi, turn this true, else false
  </parameters>
  <chapter_context>
    Markers
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>markermanagement, navigation, get marker, position, marker</tags>
</US_DocBloc>
]]
  if type(position)~="number" then ultraschall.AddErrorMessage("GetMarkerByTime", "position", "must be a number", -1) return nil end
  local one,two,three,four,five,six,seven,eight,nine,ten
  if retina==false then
    ten=84
    nine=76
    eight=68
    seven=60
    six=52
    five=44
    four=36
    three=28
    two=20
    one=12
  else
    ten=84*2
    nine=76*2
    eight=68*2
    seven=60*2
    six=52*2
    five=44*2
    four=36*2
    three=28*2
    two=20*2
    one=12*2
  end
  local retstring=""
  local temp
  
  local retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
  for i=0, retval do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3(0, i)
    if isrgn==false then
      if markrgnindexnumber>999999999 then temp=ten
      elseif markrgnindexnumber>99999999 and markrgnindexnumber<1000000000  then temp=nine
      elseif markrgnindexnumber>9999999 and markrgnindexnumber<100000000 then temp=eight
      elseif markrgnindexnumber>999999 and markrgnindexnumber<10000000 then temp=seven
      elseif markrgnindexnumber>99999 and markrgnindexnumber<1000000 then temp=six
      elseif markrgnindexnumber>9999 and markrgnindexnumber<100000 then temp=five
      elseif markrgnindexnumber>999 and markrgnindexnumber<10000 then temp=four
      elseif markrgnindexnumber>99 and markrgnindexnumber<1000 then temp=three
      elseif markrgnindexnumber>9 and markrgnindexnumber<100 then temp=two
      elseif markrgnindexnumber>-1 and markrgnindexnumber<10 then temp=one
      end
      local Aretval,ARetval2=reaper.BR_Win32_GetPrivateProfileString("REAPER", "leftpanewid", "", reaper.GetResourcePath()..ultraschall.Separator.."reaper.ini")
      local Ax,AAx= reaper.GetSet_ArrangeView2(0, false, ARetval2+57-temp,ARetval2+57) 
      local Bx=AAx-Ax
      if Bx+pos>=position and pos<=position then retstring=retstring..markrgnindexnumber.."\n"..pos.."\n"..name end      
    end
  end
  return retstring
end


function ultraschall.GetRegionByScreenCoordinates(xmouseposition, retina)
--returns a string with the marker(s) at given screen-x-position in the timeline. No Regions!
--string will be "Markeridx\npos\nName\nMarkeridx2\npos2\nName2"

--xmouseposition - x mouseposition
--retina - if it's retina/hiDPI, set it true, else, set it false

--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetRegionByScreenCoordinates</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string markers = ultraschall.GetRegionByScreenCoordinates(integer xmouseposition, boolean retina)</functioncall>
  <description>
    returns the regions at a given absolute-x-pixel-position. It sees regions according their graphical representation in the arrange-view, not just their position! Returned string will be "Regionidx\npos\nName\nRegionidx2\npos2\nName2\n...".
    Returns only regions, no time markers or other markers!
  </description>
  <retvals>
    string marker - a string with all regionnumbers, regionpositions and regionnames, separated by a newline. 
    -Can contain numerous regions, if there are more regions in one position.
  </retvals>
  <parameters>
    integer xmouseposition - the absolute x-screen-position, like current mouse-position
    boolean retina - if the screen-resolution is retina or hidpi, turn this true, else false
  </parameters>
  <chapter_context>
    Markers
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>markermanagement, navigation, get region, position, region</tags>
</US_DocBloc>
]]
  if math.type(xmouseposition)~="integer" then ultraschall.AddErrorMessage("GetRegionByScreenCoordinates", "xmouseposition", "must be an integer", -1) return nil end
  
  local one,two,three,four,five,six,seven,eight,nine,ten
  if retina==false then
    ten=84
    nine=76
    eight=68
    seven=60
    six=52
    five=44
    four=36
    three=28
    two=20
    one=12
  else
    ten=84*2
    nine=76*2
    eight=68*2
    seven=60*2
    six=52*2
    five=44*2
    four=36*2
    three=28*2
    two=20*2
    one=12*2
  end
  local retstring=""
  local temp
  local retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
  for i=0, retval do
    local ALABAMA=xmouseposition
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3(0, i)
    if isrgn==true then
      if markrgnindexnumber>999999999 then temp=ten
      elseif markrgnindexnumber>99999999 and markrgnindexnumber<1000000000  then temp=nine
      elseif markrgnindexnumber>9999999 and markrgnindexnumber<100000000 then temp=eight
      elseif markrgnindexnumber>999999 and markrgnindexnumber<10000000 then temp=seven
      elseif markrgnindexnumber>99999 and markrgnindexnumber<1000000 then temp=six
      elseif markrgnindexnumber>9999 and markrgnindexnumber<100000 then temp=five
      elseif markrgnindexnumber>999 and markrgnindexnumber<10000 then temp=four
      elseif markrgnindexnumber>99 and markrgnindexnumber<1000 then temp=three
      elseif markrgnindexnumber>9 and markrgnindexnumber<100 then temp=two
      elseif markrgnindexnumber>-1 and markrgnindexnumber<10 then temp=one
      end
      local Ax,AAx= reaper.GetSet_ArrangeView2(0, false, xmouseposition-temp,xmouseposition) 
      if pos>=Ax and pos<=AAx then retstring=retstring..markrgnindexnumber.."\n"..pos.."\n"..name.."\n" 
      elseif Ax>=pos and Ax<=rgnend then retstring=retstring..markrgnindexnumber.."\n"..pos.."\n"..name
      end
    end
  end
  return retstring
end

function ultraschall.GetRegionByTime(position, retina)
--returns a string with the marker(s) at given timeline-position. No Regions!
--string will be "Markeridx\npos\nName\nMarkeridx2\npos2\nName2"

--position - position in time
--retina - if it's retina/hiDPI, set it true, else, set it false

--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetRegionByTime</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    SWS=2.8.8
    Lua=5.3
  </requires>
  <functioncall>string markers = ultraschall.GetRegionByTime(number position, boolean retina)</functioncall>
  <description>
    returns the regions at a given absolute-x-pixel-position. It sees regions according their graphical representation in the arrange-view, not just their position! Returned string will be "Regionidx\npos\nName\nRegionidx2\npos2\nName2\n...".
    Returns only regions, no time markers or other markers!
  </description>
  <retvals>
    string marker - a string with all regionnumbers, regionpositions and regionnames, separated by a newline. 
    -Can contain numerous regions, if there are more regions in one position.
  </retvals>
  <parameters>
    number position - position in seconds
    boolean retina - if the screen-resolution is retina or hidpi, turn this true, else false
  </parameters>
  <chapter_context>
    Markers
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>markermanagement, navigation, get region, position, region</tags>
</US_DocBloc>
]]
  if type(position)~="number" then ultraschall.AddErrorMessage("GetRegionByTime", "position", "must be a number", -1) return nil end
  local one,two,three,four,five,six,seven,eight,nine,ten
  if retina==false then
    ten=84
    nine=76
    eight=68
    seven=60
    six=52
    five=44
    four=36
    three=28
    two=20
    one=12
  else
    ten=84*2
    nine=76*2
    eight=68*2
    seven=60*2
    six=52*2
    five=44*2
    four=36*2
    three=28*2
    two=20*2
    one=12*2
  end
  local retstring=""
  local temp
  local retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
  for i=0, retval do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3(0, i)
    if isrgn==true then
      if markrgnindexnumber>999999999 then temp=ten
      elseif markrgnindexnumber>99999999 and markrgnindexnumber<1000000000  then temp=nine
      elseif markrgnindexnumber>9999999 and markrgnindexnumber<100000000 then temp=eight
      elseif markrgnindexnumber>999999 and markrgnindexnumber<10000000 then temp=seven
      elseif markrgnindexnumber>99999 and markrgnindexnumber<1000000 then temp=six
      elseif markrgnindexnumber>9999 and markrgnindexnumber<100000 then temp=five
      elseif markrgnindexnumber>999 and markrgnindexnumber<10000 then temp=four
      elseif markrgnindexnumber>99 and markrgnindexnumber<1000 then temp=three
      elseif markrgnindexnumber>9 and markrgnindexnumber<100 then temp=two
      elseif markrgnindexnumber>-1 and markrgnindexnumber<10 then temp=one
      end
      local Aretval,ARetval2=reaper.BR_Win32_GetPrivateProfileString("REAPER", "leftpanewid", "", reaper.GetResourcePath()..ultraschall.Separator.."reaper.ini")
      local Ax,AAx= reaper.GetSet_ArrangeView2(0, false, ARetval2+57-temp,ARetval2+57) 
      local Bx=AAx-Ax
      if Bx+pos>=position and pos<=position then retstring=retstring..markrgnindexnumber.."\n"..pos.."\n"..name.."\n"
      elseif pos<=position and rgnend>=position then retstring=retstring..markrgnindexnumber.."\n"..pos.."\n"..name
      end
    end
  end
  return retstring
end

function ultraschall.GetApiVersion()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetApiVersion</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string version, string date, string beta, number versionnumber, string tagline = ultraschall.GetApiVersion()</functioncall>
  <description>
    returns the version, release-date and if it's a beta-version
  </description>
  <retvals>
    string version - the current Api-version
    string date - the release date of this api-version
    string beta - if it's a beta version, this is the beta-version-number
    number versionnumber - a number, that you can use for comparisons like, "if requestedversion>versionnumber then"
    string tagline - the tagline of the current release
  </retvals>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>version,versionmanagement</tags>
</US_DocBloc>
--]]
  return "4.00","15th of December 2018", "Beta 2.7", 400.027, "\"Frank Zappa - The Return of the Son of Monster Magnet\"", ultraschall.hotfixdate
end

function ultraschall.ConvertColor(r,g,b)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ConvertColor</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.52
    Lua=5.3
  </requires>
  <functioncall>integer colorvalue, boolean retval = ultraschall.ConvertColor(integer r, integer g, integer b)</functioncall>
  <description>
    converts r, g, b-values to native-system-color. Works like reaper's ColorToNative, but doesn't need |0x1000000 added.
    
    returns color-value 0, and retval=false in case of an error
  </description>
  <retvals>
    integer colorvalue - the native-system-color; 0 to 33554431
  </retvals>
  <parameters>
    integer r - the red colorvalue
    integer g - the green colorvalue
    integer b - the blue colorvalue
  </parameters>
  <chapter_context>
    Color Management
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, color, native, convert, red, gree, blue</tags>
</US_DocBloc>
]]
    if math.type(r)~="integer" then ultraschall.AddErrorMessage("ConvertColor","r", "only integer allowed", -1) return 0, false end
    if math.type(g)~="integer" then ultraschall.AddErrorMessage("ConvertColor","g", "only integer allowed", -2) return 0, false end
    if math.type(b)~="integer" then ultraschall.AddErrorMessage("ConvertColor","b", "only integer allowed", -3) return 0, false end
    if ultraschall.IsOS_Mac()==true then r,b=b,r end
    return reaper.ColorToNative(r,g,b)|0x1000000, true
end

function ultraschall.SetUSExternalState(section, key, value)
-- stores value into ultraschall.ini
-- returns true if successful, false if unsuccessful
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetUSExternalState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    SWS=2.8.8
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetUSExternalState(string section, string key, string value)</functioncall>
  <description>
    stores values into ultraschall.ini. Returns true if successful, false if unsuccessful.
    
    unlike other Ultraschall-API-functions, this converts the values, that you pass as parameters, into strings, regardless of their type
  </description>
  <retvals>
    boolean retval - true, if successful, false if unsuccessful.
  </retvals>
  <parameters>
    string section - section within the ini-file
    string key - key within the section
    string value - the value itself
  </parameters>
  <chapter_context>
    Configuration-Files Management
    Ultraschall.ini
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configurationmanagement, value, insert, store</tags>
</US_DocBloc>
--]]
  -- check parameters
  section=tostring(section)
  key=tostring(key)
  value=tostring(value)  
  if section:match(".*(%=).*")=="=" then ultraschall.AddErrorMessage("SetUSExternalState","section", "no = allowed in section", -4) return false end

  -- set value
  return reaper.BR_Win32_WritePrivateProfileString(section, key, value, reaper.GetResourcePath()..ultraschall.Separator.."ultraschall.ini")
end

function Msg(val)
  reaper.ShowConsoleMsg(tostring(val).."\n")
end

function runcommand(cmd)     -- run a command by its name

  start_id = reaper.NamedCommandLookup(cmd)
  reaper.Main_OnCommand(start_id,0) 

end

function GetPath(str,sep)
 
    return str:match("(.*"..sep..")")

end


function ultraschall.CreateTemporaryFileOfProjectfile(projectfilename_with_path)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CreateTemporaryFileOfProjectfile</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>string tempfile = ultraschall.CreateTemporaryFileOfProjectfile(string projectfilename_with_path)</functioncall>
  <description>
    Creates a temporary copy of an rpp-projectfile, which can be altered and rendered again.
    
    Must be deleted by hand using os.remove(tempfile) after you're finished.
    
    returns nil in case of an error
  </description>
  <retvals>
    string tempfile - the temporary-file, that is a valid copy of the projectfilename_with_path
  </retvals>
  <parameters>
    string projectfilename_with_path - the project to render; nil, for the currently opened project(needs to be saved first)
  </parameters>
  <chapter_context>
    Rendering of Project
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>projectfiles, create, tempfile, temporary, render, output, file</tags>
</US_DocBloc>
]]
  local temp
  if projectfilename_with_path==nil then 
    if reaper.IsProjectDirty(0)~=1 then
      temp, projectfilename_with_path=reaper.EnumProjects(-1, "") 
    else
      ultraschall.AddErrorMessage("CreateTemporaryFileOfProjectfile", "", "current project must be saved first", -1) return nil
    end
  end
  if type(projectfilename_with_path)~="string" then ultraschall.AddErrorMessage("CreateTemporaryFileOfProjectfile", "projectfilename_with_path", "must be a string", -2) return nil end
  if reaper.file_exists(projectfilename_with_path)==false then ultraschall.AddErrorMessage("CreateTemporaryFileOfProjectfile", "projectfilename_with_path", "no such file", -3) return nil end
  local A=ultraschall.ReadFullFile(projectfilename_with_path)
  if A==nil then ultraschall.AddErrorMessage("CreateTemporaryFileOfProjectfile", "projectfilename_with_path", "Can't read projectfile", -4) return nil end
  if ultraschall.IsValidProjectStateChunk(A)==false then ultraschall.AddErrorMessage("CreateTemporaryFileOfProjectfile", "projectfilename_with_path", "no valid project-file", -5) return nil end
  local tempfilename=ultraschall.CreateValidTempFile(projectfilename_with_path, true, "", true)
  if tempfilename==nil then ultraschall.AddErrorMessage("CreateTemporaryFileOfProjectfile", "", "Can't create tempfile", -6) return nil end
  local B=ultraschall.WriteValueToFile(tempfilename, A)
  if B==-1 then ultraschall.AddErrorMessage("CreateTemporaryFileOfProjectfile", "projectfilename_with_path", "Can't create tempfile", -7) return nil else return tempfilename end
end

function ultraschall.RenderProjectRegions_RenderCFG(projectfilename_with_path, renderfilename_with_path, region, addregionname, overwrite_without_asking, renderclosewhendone, filenameincrease, rendercfg)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>RenderProjectRegions_RenderCFG</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>integer retval, integer renderfilecount, array MediaItemStateChunkArray, array Filearray = ultraschall.RenderProjectRegions_RenderCFG(string projectfilename_with_path, string renderfilename_with_path, integer region, boolean addregionname, boolean overwrite_without_asking, boolean renderclosewhendone, boolean filenameincrease, optional string rendercfg)</functioncall>
  <description>
    Renders a region of a project, using a specific render-cfg-string.
    To get render-cfg-strings, see <a href="#CreateRenderCFG_AIFF">CreateRenderCFG_AIFF</a>, <a href="#CreateRenderCFG_DDP">CreateRenderCFG_DDP</a>, <a href="#CreateRenderCFG_FLAC">CreateRenderCFG_FLAC</a>, <a href="#CreateRenderCFG_OGG">CreateRenderCFG_OGG</a>, <a href="#CreateRenderCFG_Opus">CreateRenderCFG_Opus</a>
    
    Returns -1 in case of an error
    Returns -2 if currently opened project must be saved first(if you want to render the currently opened project).
  </description>
  <retvals>
    integer retval - -1, in case of error; 0, in case of success; -2, if you try to render the currently opened project without saving it first
    integer renderfilecount - the number of rendered files
    array MediaItemStateChunkArray - the MediaItemStateChunks of all rendered files, with the one in entry 1 being the rendered master-track(when rendering stems)
    array Filearray - the filenames of the rendered files, including their paths. The filename in entry 1 is the one of the mastered track(when rendering stems)
  </retvals>
  <parameters>
    string projectfilename_with_path - the project to render; nil, for the currently opened project(needs to be saved first)
    string renderfilename_with_path - the filename of the output-file. 
                                    - Don't add a file-extension, when using addregionname=true!
                                    - Give a path only, when you want to use only the regionname as render-filename(set addregionname=true !)
                                    - nil, use the filename/render-pattern already set in the project for the renderfilename
    integer region - the number of the region in the Projectfile to render
    boolean addregionname - add the name of the region to the renderfilename; only works, when you don't add a file-extension to renderfilename_with_path
    boolean overwrite_without_asking - true, overwrite an existing renderfile; false, don't overwrite an existing renderfile
    boolean renderclosewhendone - true, automatically close the render-window after rendering; false, keep rendering window open after rendering; nil, use current settings
    boolean filenameincrease - true, silently increase filename, if it already exists; false, ask before overwriting an already existing outputfile; nil, use current settings
    optional string rendercfg - the rendercfg-string, that contains all render-settings for an output-format
                              - To get render-cfg-strings, see <a href="#CreateRenderCFG_AIFF">CreateRenderCFG_AIFF</a>, <a href="#CreateRenderCFG_DDP">CreateRenderCFG_DDP</a>, <a href="#CreateRenderCFG_FLAC">CreateRenderCFG_FLAC</a>, <a href="#CreateRenderCFG_OGG">CreateRenderCFG_OGG</a>, <a href="#CreateRenderCFG_Opus">CreateRenderCFG_Opus</a>, <a href="#CreateRenderCFG_WAVPACK">CreateRenderCFG_WAVPACK</a>, <a href="#CreateRenderCFG_WebMVideo">CreateRenderCFG_WebMVideo</a>
                              - omit it or set to nil, if you want to use the render-string already set in the project
  </parameters>
  <chapter_context>
    Rendering of Project
    Rendering any Outputformat
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>projectfiles, render, output, file</tags>
</US_DocBloc>
]]
  local retval
  local curProj=reaper.EnumProjects(-1,"")
  if math.type(region)~="integer" then ultraschall.AddErrorMessage("RenderProjectRegions_RenderCFG", "region", "Must be an integer.", -1) return -1 end
  if projectfilename_with_path==nil and reaper.IsProjectDirty(0)==1 then ultraschall.AddErrorMessage("RenderProjectRegions_RenderCFG", "renderfilename_with_path", "To render current project, it must be saved first!", -2) return -2 end
  if type(projectfilename_with_path)~="string" then 
    -- reaper.Main_SaveProject(0, false)
    retval, projectfilename_with_path = reaper.EnumProjects(-1,"")
  end
  
  if reaper.file_exists(projectfilename_with_path)==false then ultraschall.AddErrorMessage("RenderProjectRegions_RenderCFG", "projectfilename_with_path", "File does not exist.", -3) return -1 end
  if renderfilename_with_path~=nil and type(renderfilename_with_path)~="string" then ultraschall.AddErrorMessage("RenderProjectRegions_RenderCFG", "renderfilename_with_path", "Must be a string.", -4) return -1 end  
  if rendercfg~=nil and ultraschall.GetOutputFormat_RenderCfg(rendercfg)==nil then ultraschall.AddErrorMessage("RenderProjectRegions_RenderCFG", "rendercfg", "No valid render_cfg-string.", -5) return -1 end
  if type(overwrite_without_asking)~="boolean" then ultraschall.AddErrorMessage("RenderProjectRegions_RenderCFG", "overwrite_without_asking", "Must be boolean", -6) return -1 end

  local countmarkers, nummarkers, numregions, markertable = ultraschall.GetProject_MarkersAndRegions(projectfilename_with_path)
  if region>numregions then ultraschall.AddErrorMessage("RenderProjectRegions_RenderCFG", "region", "No such region in the project.", -7) return -1 end
  local regioncount=0
  for i=1, countmarkers do
    if markertable[i][1]==true then 
      regioncount=regioncount+1
      if regioncount==region then region=i break end
    end
  end
  if addregionname==true then renderfilename_with_path=renderfilename_with_path..markertable[region][4] end

  return ultraschall.RenderProject_RenderCFG(projectfilename_with_path, renderfilename_with_path, tonumber(markertable[region][2]), tonumber(markertable[region][3]), overwrite_without_asking, renderclosewhendone, filenameincrease, rendercfg)
end

function ultraschall.RenderProject_RenderCFG(projectfilename_with_path, renderfilename_with_path, startposition, endposition, overwrite_without_asking, renderclosewhendone, filenameincrease, rendercfg)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>RenderProject_RenderCFG</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>integer retval, integer renderfilecount, array MediaItemStateChunkArray, array Filearray = ultraschall.RenderProject_RenderCFG(string projectfilename_with_path, string renderfilename_with_path, number startposition, number endposition, boolean overwrite_without_asking, boolean renderclosewhendone, boolean filenameincrease, optional string rendercfg)</functioncall>
  <description>
    Renders a project, using a specific render-cfg-string.
    To get render-cfg-strings, see <a href="#CreateRenderCFG_AIFF">CreateRenderCFG_AIFF</a>, <a href="#CreateRenderCFG_DDP">CreateRenderCFG_DDP</a>, <a href="#CreateRenderCFG_FLAC">CreateRenderCFG_FLAC</a>, <a href="#CreateRenderCFG_OGG">CreateRenderCFG_OGG</a>, <a href="#CreateRenderCFG_Opus">CreateRenderCFG_Opus</a>
    
    Returns -1 in case of an error
    Returns -2 if currently opened project must be saved first(if you want to render the currently opened project).
  </description>
  <retvals>
    integer retval - -1, in case of error; 0, in case of success; -2, if you try to render the currently opened project without saving it first
    integer renderfilecount - the number of rendered files
    array MediaItemStateChunkArray - the MediaItemStateChunks of all rendered files, with the one in entry 1 being the rendered master-track(when rendering stems)
    array Filearray - the filenames of the rendered files, including their paths. The filename in entry 1 is the one of the mastered track(when rendering stems)
  </retvals>
  <parameters>
    string projectfilename_with_path - the project to render; nil, for the currently opened project(needs to be saved first)
    string renderfilename_with_path - the filename of the output-file. If you give the wrong extension, Reaper will exchange it by the correct one.
                                    - nil, will use the render-filename/render-pattern already set in the project as renderfilename
    number startposition - the startposition of the render-area in seconds; 
                         - -1, to use the startposition set in the projectfile itself; 
                         - -2, to use the start of the time-selection
    number endposition - the endposition of the render-area in seconds; 
                       - 0, to use projectlength of the currently opened and active project(not supported with "external" projectfiles, yet)
                       - -1, to use the endposition set in the projectfile itself
                       - -2, to use the end of the time-selection
    boolean overwrite_without_asking - true, overwrite an existing renderfile; false, don't overwrite an existing renderfile
    boolean renderclosewhendone - true, automatically close the render-window after rendering; false, keep rendering window open after rendering; nil, use current settings
    boolean filenameincrease - true, silently increase filename, if it already exists; false, ask before overwriting an already existing outputfile; nil, use current settings
    optional string rendercfg - the rendercfg-string, that contains all render-settings for an output-format
                              - To get render-cfg-strings, see <a href="#CreateRenderCFG_AIFF">CreateRenderCFG_AIFF</a>, <a href="#CreateRenderCFG_DDP">CreateRenderCFG_DDP</a>, <a href="#CreateRenderCFG_FLAC">CreateRenderCFG_FLAC</a>, <a href="#CreateRenderCFG_OGG">CreateRenderCFG_OGG</a>, <a href="#CreateRenderCFG_Opus">CreateRenderCFG_Opus</a>, <a href="#CreateRenderCFG_WAVPACK">CreateRenderCFG_WAVPACK</a>, <a href="#CreateRenderCFG_WebMVideo">CreateRenderCFG_WebMVideo</a>
                              - omit it or set to nil, if you want to use the render-string already set in the project
  </parameters>
  <chapter_context>
    Rendering of Project
    Rendering any Outputformat
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>projectfiles, render, output, file</tags>
</US_DocBloc>
]]
  local retval
  local curProj=reaper.EnumProjects(-1,"")
  if type(startposition)~="number" then ultraschall.AddErrorMessage("RenderProject_RenderCFG", "startposition", "Must be a number in seconds.", -1) return -1 end
  if type(endposition)~="number" then ultraschall.AddErrorMessage("RenderProject_RenderCFG", "endposition", "Must be a number in seconds.", -2) return -1 end
  if startposition>=0 and endposition>0 and endposition<=startposition then ultraschall.AddErrorMessage("RenderProject_RenderCFG", "endposition", "Must be bigger than startposition.", -3) return -1 end
  if endposition<-2 then ultraschall.AddErrorMessage("RenderProject_RenderCFG", "endposition", "Must be bigger than 0 or -1(to retain project-file's endposition).", -4) return -1 end
  if startposition<-2 then ultraschall.AddErrorMessage("RenderProject_RenderCFG", "startposition", "Must be bigger than 0 or -1(to retain project-file's startposition).", -5) return -1 end
  if projectfilename_with_path==nil and reaper.IsProjectDirty(0)==1 then ultraschall.AddErrorMessage("RenderProject_RenderCFG", "renderfilename_with_path", "To render current project, it must be saved first!", -8) return -2 end
  if endposition==0 and projectfilename_with_path==nil then endposition=reaper.GetProjectLength(0) end
  if projectfilename_with_path==nil then 
    -- reaper.Main_SaveProject(0, false)
    retval, projectfilename_with_path = reaper.EnumProjects(-1,"")
  end  
  
  if type(projectfilename_with_path)~="string" or reaper.file_exists(projectfilename_with_path)==false then ultraschall.AddErrorMessage("RenderProject_RenderCFG", "projectfilename_with_path", "File does not exist.", -6) return -1 end
  if renderfilename_with_path~=nil and type(renderfilename_with_path)~="string" then ultraschall.AddErrorMessage("RenderProject_RenderCFG", "renderfilename_with_path", "Must be a string.", -7) return -1 end  
  if rendercfg~=nil and ultraschall.GetOutputFormat_RenderCfg(rendercfg)==nil then ultraschall.AddErrorMessage("RenderProject_RenderCFG", "rendercfg", "No valid render_cfg-string.", -9) return -1 end
  if type(overwrite_without_asking)~="boolean" then ultraschall.AddErrorMessage("RenderProject_RenderCFG", "overwrite_without_asking", "Must be boolean", -10) return -1 end

  -- Read Projectfile
  local FileContent=ultraschall.ReadFullFile(projectfilename_with_path, false)
  if ultraschall.CheckForValidFileFormats(projectfilename_with_path)~="RPP_PROJECT" then ultraschall.AddErrorMessage("RenderProject_RenderCFG", "projectfilename_with_path", "Must be a valid Reaper-Project", -14) return -1 end
  local oldrendercfg=ultraschall.GetProject_RenderCFG(nil, FileContent)
  if rendercfg==nil then rendercfg=oldrendercfg end
    
  -- create temporary-project-filename
  local tempfile = ultraschall.CreateValidTempFile(projectfilename_with_path, true, "ultraschall-temp", true) 
  
  -- Write temporary projectfile
  ultraschall.WriteValueToFile(tempfile, FileContent)
  
  -- Add the render-filename to the project 
  if renderfilename_with_path~=nil then
    ultraschall.SetProject_RenderFilename(tempfile, renderfilename_with_path)
    ultraschall.SetProject_RenderPattern(tempfile, nil)
  end
  
  -- Add render-format-settings as well as adding media to project after rendering
  ultraschall.SetProject_RenderCFG(tempfile, rendercfg)
  ultraschall.SetProject_AddMediaToProjectAfterRender(tempfile, 1)
  
  -- Add the rendertime to the temporary project-file, when 
  local bounds, time_start, time_end, tail, tail_length = ultraschall.GetProject_RenderRange(tempfile)
--  if time_end==0 then time_end = ultraschall.GetProject_Length(tempfile) end
  local timesel1_start, timesel1_end = ultraschall.GetProject_Selection(tempfile)
  --   if startposition and/or endposition are -1, retain the start/endposition from the project-file

  if startposition==-1 then startposition=time_start end
  if endposition==-1 or endposition==0 then if time_end==0 then endposition=ultraschall.GetProject_Length(tempfile) else endposition=time_end end end
  if startposition==-2 then startposition=timesel1_start end
  if endposition==-2 then endposition=timesel1_end end

  if endposition==0 and startposition==0 then ultraschall.AddErrorMessage("RenderProject_RenderCFG", "startposition or endposition in RPP-Project", "Can't render a project of length 0 seconds.", -13) os.remove (tempfile) return -1 end
  if endposition<=startposition and endposition~=0 then ultraschall.AddErrorMessage("RenderProject_RenderCFG", "startposition or endposition in RPP-Project", "Must be bigger than startposition.", -11) os.remove (tempfile) return -1 end
  local Bretval = ultraschall.SetProject_RenderRange(tempfile, 0, startposition, endposition, 0, 0)
  if Bretval==-1 then 
    os.remove (tempfile) 
    ultraschall.AddErrorMessage("RenderProject_RenderCFG", "projectfilename_with_path", "Can't set the timerange in the temporary-project "..tempfile, -12)
    return -1 
  end
  

  -- Get currently opened project
  local _temp, oldprojectname=ultraschall.EnumProjects(0)
  
  --Now the magic happens:
  
  -- delete renderfile, if already existing and overwrite_without_asking==true
  if overwrite_without_asking==true then
    if renderfilename_with_path~=nil and reaper.file_exists(renderfilename_with_path)==true then
      os.remove(renderfilename_with_path) 
    end
  end 
  
  
  reaper.Main_OnCommand(40859,0)    -- create new temporary tab
  reaper.Main_openProject(tempfile) -- load the temporary projectfile
  
  -- manage automatically closing of the render-window and filename-increasing
  local val=reaper.SNM_GetIntConfigVar("renderclosewhendone", -99)
  local oldval=val
  if renderclosewhendone==true then 
    if val&1==0 then val=val+1 end
    if val==-99 then val=1 end
  elseif renderclosewhendone==false then 
    if val&1==1 then val=val-1 end
    if val==-99 then val=0 end
  end
  
  if filenameincrease==true then 
    if val&16==0 then val=val+16 end
    if val==-99 then val=16 end
  elseif filenameincrease==false then 
    if val&16==16 then val=val-16 end
    if val==-99 then val=0 end
  end
  reaper.SNM_SetIntConfigVar("renderclosewhendone", val)
  
  -- temporarily disable building peak-caches
  local peakval=reaper.SNM_GetIntConfigVar("peakcachegenmode", -99)
  reaper.SNM_SetIntConfigVar("peakcachegenmode", 0)
  
  local AllTracks=ultraschall.CreateTrackString_AllTracks() -- get number of tracks after rendering and adding of rendered files
  
  reaper.Main_OnCommand(41824,0)    -- render using it with the last rendersettings(those, we inserted included)
  reaper.Main_SaveProject(0, false) -- save it(no use, but otherwise, Reaper would open a Save-Dialog, that we don't want and need)
  local AllTracks2=ultraschall.CreateTrackString_AllTracks() -- get number of tracks after rendering and adding of rendered files
  local retval, Trackstring = ultraschall.OnlyTracksInOneTrackstring(AllTracks, AllTracks2) -- only get the newly added tracks as trackstring
  local count, MediaItemArray, MediaItemStateChunkArray
  if Trackstring~="" then 
    count, MediaItemArray, MediaItemStateChunkArray = ultraschall.GetAllMediaItemsBetween(0, reaper.GetProjectLength(0), Trackstring, false) -- get the new MediaItems created after adding the rendered files
  else
    count=0
  end
  reaper.Main_OnCommand(40860,0)    -- close the temporary-tab again

  local Filearray={}
  for i=1, count do
    Filearray[i]=MediaItemStateChunkArray[i]:match("%<SOURCE.-FILE \"(.-)\"")
  end

  -- reset old renderclose/overwrite/Peak-cache-settings
  reaper.SNM_SetIntConfigVar("renderclosewhendone", oldval)
  reaper.SNM_SetIntConfigVar("peakcachegenmode", peakval)

  --remove the temp-file and we are done.
  os.remove (tempfile)
  os.remove (tempfile.."-bak")
  reaper.SelectProjectInstance(curProj)
  return 0, count, MediaItemStateChunkArray, Filearray
end

function ultraschall.MB(msg,title,mbtype)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>MB</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.77
    Lua=5.3
  </requires>
  <functioncall>integer retval = ultraschall.MB(string msg, optional string title, optional integer type)</functioncall>
  <description>
    Shows Messagebox with user-clickable buttons. Works like reaper.MB() but unlike reaper.MB, this function accepts omitting some parameters for quicker use.
    
    Returns -1 in case of an error
  </description>
  <parameters>
    string msg - the message, that shall be shown in messagebox
    optional string title - the title of the messagebox
    optional integer type - which buttons shall be shown in the messagebox
                            - 0, OK
                            - 1, OK CANCEL
                            - 2, ABORT RETRY IGNORE
                            - 3, YES NO CANCEL
                            - 4, YES NO
                            - 5, RETRY CANCEL
                            - nil, defaults to OK
  </parameters>
  <retvals>
    integer - the button pressed by the user
                           - -1, error while executing this function
                           - 1, OK
                           - 2, CANCEL
                           - 3, ABORT
                           - 4, RETRY
                           - 5, IGNORE
                           - 6, YES
                           - 7, NO
  </retvals>
  <chapter_context>
    User Interface
    Dialogs
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>user interface, user, interface, input, dialog, messagebox</tags>
</US_DocBloc>
--]]
--  if type(msg)~="string" then ultraschall.AddErrorMessage("MB","msg", "Must be a string!", -1) return -1 end
  msg=tostring(msg)
  if type(title)~="string" then title="" end
  if math.type(mbtype)~="integer" then mbtype=0 end
  if mbtype<0 or mbtype>5 then ultraschall.AddErrorMessage("MB","mbtype", "Must be between 0 and 5!", -2) return -1 end
  reaper.MB(msg, title, mbtype)
end

function ultraschall.GetProject_Length(projectfilename_with_path, ProjectStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetProject_Length</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>number length, number last_itemedge, number last_marker_reg_edge, number last_timesig_marker = ultraschall.GetProject_Length(string projectfilename_with_path, optional string ProjectStateChunk)</functioncall>
  <description>
    Returns the projectlength of an rpp-project-file.
    
    It's eturning the position of the overall length, as well as the position of the last itemedge/regionedge/marker/time-signature-marker of the project.
    
    Returns -1 in case of an error
  </description>
  <parameters>
    string projectfilename_with_path - the filename of the project, that you want to know it's length of; nil to use parameter ProjectStateChunk instead
    optional string ProjectStateChunk - a ProjectStateChunk to count the length of; only available when projectfilename_with_path=nil
  </parameters>
  <retvals>
    number length - the length of the project
    number last_itemedge - the postion of the last itemedge in the project
    number last_marker_reg_edge - the position of the last marker/regionedge in the project
    number last_timesig_marker - the position of the last time-signature-marker in the project
  </retvals>
  <chapter_context>
    Project-Files
    Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>project management, get, length of project, marker, region, timesignature, lengt, item, edge</tags>
</US_DocBloc>
]]

  -- check parameters and prepare variable ProjectStateChunk
  if projectfilename_with_path~=nil and type(projectfilename_with_path)~="string" then ultraschall.AddErrorMessage("GetProject_Length","projectfilename_with_path", "Must be a string or nil(the latter when using parameter ProjectStateChunk)!", -1) return -1 end
  if projectfilename_with_path==nil and ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("GetProject_Length","ProjectStateChunk", "No valid ProjectStateChunk!", -2) return -1 end
  if projectfilename_with_path~=nil then
    if reaper.file_exists(projectfilename_with_path)==true then ProjectStateChunk=ultraschall.ReadFullFile(projectfilename_with_path, false)
    else ultraschall.AddErrorMessage("GetProject_Length","projectfilename_with_path", "File does not exist!", -3) return -1
    end
    if ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("GetProject_Length", "projectfilename_with_path", "No valid RPP-Projectfile!", -4) return -1 end
  end

  local B, C, ProjectLength, Len, Pos, Offs

  -- search for the last item-edge in the project
  B=ProjectStateChunk
  B=B:match("(%<ITEM.*)<EXTENS").."\n<ITEM"
  ProjectLength=0
  local Item_Length=0
  local Marker_Length=0
  local TempoMarker_Length=0
  
  -- let's take a huge project-string apart to make patternmatching much faster
  local K={}
  local counter=0
  while B:len()>1000 do     
    K[counter]=B:sub(0, 100000)
    B=B:sub(100001,-1)
    counter=counter+1    
  end
  if counter==0 then K[0]=B end
  
  local counter2=1
  local B=K[0]
  
  local Itemscount=0
  
  
  while B~=nil and B:sub(1,5)=="<ITEM" do  
    if B:len()<10000 and counter2<counter then B=B..K[counter2] counter2=counter2+1 end
    Offs=B:match(".()<ITEM")

    local sc=B:sub(1,200)
    if sc==nil then break end

    Pos = sc:match("POSITION (.-)\n")
    Len = sc:match("LENGTH (.-)\n")

    if Pos==nil or Len==nil or Offs==nil then break end
    if ProjectLength<tonumber(Pos)+tonumber(Len) then ProjectLength=tonumber(Pos)+tonumber(Len) end
    B=B:sub(Offs,-1)  
    Itemscount=Itemscount+1
  end
  Item_Length=ProjectLength

  -- search for the last marker/regionedge in the project
  local markerregioncount, NumMarker, Numregions, Markertable = ultraschall.GetProject_MarkersAndRegions(nil, ProjectStateChunk)
  
  for i=1, markerregioncount do
    if ProjectLength<Markertable[i][2]+Markertable[i][3] then ProjectLength=Markertable[i][2]+Markertable[i][3] end
    if Marker_Length<Markertable[i][2]+Markertable[i][3] then Marker_Length=Markertable[i][2]+Markertable[i][3] end
  end
  
  -- search for the last tempo-envx-marker in the project
  B=ultraschall.GetProject_TempoEnv_ExStateChunk(nil, ProjectStateChunk)  
  C=B:match(".*PT (.-) ")
  if C~=nil and ProjectLength<tonumber(C) then ProjectLength=tonumber(C) end
  if C~=nil and TempoMarker_Length<tonumber(C) then TempoMarker_Length=tonumber(C) end
  
  return ProjectLength, Item_Length, Marker_Length, TempoMarker_Length
end


function ultraschall.GetProject_Length(projectfilename_with_path, ProjectStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetProject_Length</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>number length, number last_itemedge, number last_marker_reg_edge, number last_timesig_marker = ultraschall.GetProject_Length(string projectfilename_with_path, optional string ProjectStateChunk)</functioncall>
  <description>
    Returns the projectlength of an rpp-project-file.
    
    It's eturning the position of the overall length, as well as the position of the last itemedge/regionedge/marker/time-signature-marker of the project.
    
    Returns -1 in case of an error
  </description>
  <parameters>
    string projectfilename_with_path - the filename of the project, that you want to know it's length of; nil to use parameter ProjectStateChunk instead
    optional string ProjectStateChunk - a ProjectStateChunk to count the length of; only available when projectfilename_with_path=nil
  </parameters>
  <retvals>
    number length - the length of the project
    number last_itemedge - the postion of the last itemedge in the project
    number last_marker_reg_edge - the position of the last marker/regionedge in the project
    number last_timesig_marker - the position of the last time-signature-marker in the project
  </retvals>
  <chapter_context>
    Project-Files
    Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>project management, get, length of project, marker, region, timesignature, lengt, item, edge</tags>
</US_DocBloc>
]]

  -- check parameters and prepare variable ProjectStateChunk
  if projectfilename_with_path~=nil and type(projectfilename_with_path)~="string" then ultraschall.AddErrorMessage("GetProject_Length","projectfilename_with_path", "Must be a string or nil(the latter when using parameter ProjectStateChunk)!", -1) return -1 end
  if projectfilename_with_path==nil and ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("GetProject_Length","ProjectStateChunk", "No valid ProjectStateChunk!", -2) return -1 end
  if projectfilename_with_path~=nil then
    if reaper.file_exists(projectfilename_with_path)==true then ProjectStateChunk=ultraschall.ReadFullFile(projectfilename_with_path, false)
    else ultraschall.AddErrorMessage("GetProject_Length","projectfilename_with_path", "File does not exist!", -3) return -1
    end
    if ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("GetProject_Length", "projectfilename_with_path", "No valid RPP-Projectfile!", -4) return -1 end
  end

  local B, C, ProjectLength, Len, Pos, Offs

  -- search for the last item-edge in the project
  B=ProjectStateChunk
  B=B:match("(%<ITEM.*)<EXTENS").."\n<ITEM"
  ProjectLength=0
  local Item_Length=0
  local Marker_Length=0
  local TempoMarker_Length=0
  
  -- let's take a huge project-string apart to make patternmatching much faster
  local K={}
  local counter=0
  while B:len()>1000 do     
    K[counter]=B:sub(0, 100000)
    B=B:sub(100001,-1)
    counter=counter+1    
  end
  if counter==0 then K[0]=B end
  
  local counter2=1
  local B=K[0]
  
  local Itemscount=0
  
  
  while B~=nil and B:sub(1,5)=="<ITEM" do  
    if B:len()<10000 and counter2<counter then B=B..K[counter2] counter2=counter2+1 end
    Offs=B:match(".()<ITEM")

    local sc=B:sub(1,200)
    if sc==nil then break end

    Pos = sc:match("POSITION (.-)\n")
    Len = sc:match("LENGTH (.-)\n")

    if Pos==nil or Len==nil or Offs==nil then break end
    if ProjectLength<tonumber(Pos)+tonumber(Len) then ProjectLength=tonumber(Pos)+tonumber(Len) end
    B=B:sub(Offs,-1)  
    Itemscount=Itemscount+1
  end
  Item_Length=ProjectLength

  -- search for the last marker/regionedge in the project
  local markerregioncount, NumMarker, Numregions, Markertable = ultraschall.GetProject_MarkersAndRegions(nil, ProjectStateChunk)
  
  for i=1, markerregioncount do
    if ProjectLength<Markertable[i][2]+Markertable[i][3] then ProjectLength=Markertable[i][2]+Markertable[i][3] end
    if Marker_Length<Markertable[i][2]+Markertable[i][3] then Marker_Length=Markertable[i][2]+Markertable[i][3] end
  end
  
  -- search for the last tempo-envx-marker in the project
  B=ultraschall.GetProject_TempoEnv_ExStateChunk(nil, ProjectStateChunk)  
  C=B:match(".*PT (.-) ")
  if C~=nil and ProjectLength<tonumber(C) then ProjectLength=tonumber(C) end
  if C~=nil and TempoMarker_Length<tonumber(C) then TempoMarker_Length=tonumber(C) end
  
  return ProjectLength, Item_Length, Marker_Length, TempoMarker_Length
end

function ultraschall.SetProject_RenderPattern(projectfilename_with_path, render_pattern, ProjectStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetProject_RenderPattern</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval = ultraschall.SetProject_RenderPattern(string projectfilename_with_path, string render_pattern, optional string ProjectStateChunk)</functioncall>
  <description>
    Sets the render-filename in an rpp-projectfile or a ProjectStateChunk. Set it to "", if you want to set the render-filename with <a href="#SetProject_RenderFilename">SetProject_RenderFilename</a>.
    
    Returns -1 in case of error.
  </description>
  <parameters>
    string projectfilename_with_path - the filename of the projectfile; nil to use Parameter ProjectStateChunk instead
    string render_pattern - the pattern, with which the rendering-filename will be automatically created. Check also <a href="#GetProject_RenderFilename">GetProject_RenderFilename</a>
    -Capitalizing the first character of the wildcard will capitalize the first letter of the substitution. 
    -Capitalizing the first two characters of the wildcard will capitalize all letters.
    -
    -Directories will be created if necessary. For example if the render target is "$project/track", the directory "$project" will be created.
    -
    -$item    media item take name, if the input is a media item
    -$itemnumber  1 for the first media item on a track, 2 for the second...
    -$track    track name
    -$tracknumber  1 for the first track, 2 for the second...
    -$parenttrack  parent track name
    -$region    region name
    -$regionnumber  1 for the first region, 2 for the second...
    -$namecount  1 for the first item or region of the same name, 2 for the second...
    -$start    start time of the media item, render region, or time selection
    -$end    end time of the media item, render region, or time selection
    -$startbeats  start time in beats of the media item, render region, or time selection
    -$endbeats  end time in beats of the media item, render region, or time selection
    -$timelineorder  1 for the first item or region on the timeline, 2 for the second...
    -$project    project name
    -$tempo    project tempo at the start of the render region
    -$timesignature  project time signature at the start of the render region, formatted as 4-4
    -$filenumber  blank (optionally 1) for the first file rendered, 1 (optionally 2) for the second...
    -$filenumber[N]  N for the first file rendered, N+1 for the second...
    -$note    C0 for the first file rendered,C#0 for the second...
    -$note[X]    X (example: B2) for the first file rendered, X+1 (example: C3) for the second...
    -$natural    C0 for the first file rendered, D0 for the second...
    -$natural[X]  X (example: F2) for the first file rendered, X+1 (example: G2) for the second...
    -$format    render format (example: wav)
    -$samplerate  sample rate (example: 44100)
    -$sampleratek  sample rate (example: 44.1)
    -$year    year
    -$year2    last 2 digits of the year
    -$month    month number
    -$monthname  month name
    -$day    day of the month
    -$hour    hour of the day in 24-hour format
    -$hour12    hour of the day in 12-hour format
    -$ampm    am if before noon,pm if after noon
    -$minute    minute of the hour
    -$second    second of the minute
    -$user    user name
    -$computer  computer name
    -
    -(this description has been taken from the Render Wildcard Help within the Render-Dialog of Reaper)
    optional string ProjectStateChunk - a projectstatechunk, that you want to be changed
  </parameters>
  <retvals>
    integer retval - -1 in case of error, 1 in case of success
  </retvals>
  <chapter_context>
    Project-Files
    RPP-Files Set
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>projectfiles, rpp, state, set, recording, render pattern, filename, render</tags>
</US_DocBloc>
]]  
  if projectfilename_with_path==nil and ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("SetProject_RenderPattern", "ProjectStateChunk", "Must be a valid ProjectStateChunk", -1) return -1 end
  if projectfilename_with_path~=nil and reaper.file_exists(projectfilename_with_path)==false then ultraschall.AddErrorMessage("SetProject_RenderPattern", "projectfilename_with_path", "File does not exist", -2) return -1 end
  if projectfilename_with_path~=nil then ProjectStateChunk=ultraschall.ReadFullFile(projectfilename_with_path) end
  if projectfilename_with_path~=nil and ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("SetProject_RenderPattern", "projectfilename_with_path", "File is no valid RPP-Projectfile", -3) return -1 end
  if render_pattern~=nil and type(render_pattern)~="string" then ultraschall.AddErrorMessage("SetProject_RenderPattern", "render_pattern", "Must be a string", -4) return -1 end
  if ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("SetProject_RenderPattern", "projectfilename_with_path", "No valid RPP-Projectfile!", -5) return -1 end

  local FileStart=ProjectStateChunk:match("(<REAPER_PROJECT.-RENDER_FILE.-%c)")
  local FileEnd=ProjectStateChunk:match("<REAPER_PROJECT.-(RENDER_FMT.*)")
  local RenderPattern
  if render_pattern:match("%s")~=nil then quots="\"" else quots="" end
  if render_pattern==nil then RenderPattern="" else RenderPattern="  RENDER_PATTERN "..quots..render_pattern..quots.."\n" end
  
  ProjectStateChunk=FileStart..RenderPattern.."  "..FileEnd
  if projectfilename_with_path~=nil then return ultraschall.WriteValueToFile(projectfilename_with_path, ProjectStateChunk), ProjectStateChunk
  else return 1, ProjectStateChunk
  end  
end


--ultraschall.MB(reaper.GetTrack(0,0))

function ultraschall.InsertMediaItemFromFile(filename, track, position, endposition, editcursorpos, offset)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>InsertMediaItemFromFile</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    SWS=2.8.8
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


function ultraschall.GetProject_RenderFilename(projectfilename_with_path, ProjectStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetProject_RenderFilename</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string render_filename = ultraschall.GetProject_RenderFilename(string projectfilename_with_path, optional string ProjectStateChunk)</functioncall>
  <description>
    Returns the render-filename from an RPP-Projectfile or a ProjectStateChunk. If it contains only a path or nothing, you should check the Render_Pattern using <a href="#GetProject_RenderPattern">GetProject_RenderPattern</a>, as a render-pattern influences the rendering-filename as well.
    
    It's the entry RENDER_FILE
    
    Returns nil in case of error.
  </description>
  <parameters>
    string projectfilename_with_path - filename with path for the rpp-projectfile; nil, if you want to use parameter ProjectStateChunk
    optional string ProjectStateChunk - a ProjectStateChunk to use instead if a filename; only used, when projectfilename_with_path is nil
  </parameters>
  <retvals>
    string render_filename - the filename for rendering, check also <a href="#GetProject_RenderPattern">GetProject_RenderPattern</a>
  </retvals>
  <chapter_context>
    Project-Files
    RPP-Files Get
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>projectfiles, rpp, state, get, recording, path, render filename, filename, render</tags>
</US_DocBloc>
]]
  -- check parameters and prepare variable ProjectStateChunk
  if projectfilename_with_path~=nil and type(projectfilename_with_path)~="string" then ultraschall.AddErrorMessage("GetProject_RenderFilename","projectfilename_with_path", "Must be a string or nil(the latter when using parameter ProjectStateChunk)!", -1) return nil end
  if projectfilename_with_path==nil and ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("GetProject_RenderFilename","ProjectStateChunk", "No valid ProjectStateChunk!", -2) return nil end
  if projectfilename_with_path~=nil then
    if reaper.file_exists(projectfilename_with_path)==true then ProjectStateChunk=ultraschall.ReadFullFile(projectfilename_with_path, false)
    else ultraschall.AddErrorMessage("GetProject_RenderFilename","projectfilename_with_path", "File does not exist!", -3) return nil
    end
    if ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("GetProject_RenderFilename", "projectfilename_with_path", "No valid RPP-Projectfile!", -4) return nil end
  end
  -- get the value and return it
  local temp=ProjectStateChunk:match("<REAPER_PROJECT.-RENDER_FILE%s(.-)%c.-<RENDER_CFG")
  if temp:sub(1,1)=="\"" then temp=temp:sub(2,-1) end
  if temp:sub(-1,-1)=="\"" then temp=temp:sub(1,-2) end
  return temp
end

function ultraschall.WriteValueToFile(filename_with_path, value, binarymode, append)
  -- Writes value to filename_with_path
  -- Keep in mind, that you need to escape \ by writing \\, or it will not work
  -- binarymode
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>WriteValueToFile</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval = ultraschall.WriteValueToFile(string filename_with_path, string value, optional boolean binarymode, optional boolean append)</functioncall>
  <description>
    Writes value to filename_with_path. Will replace any previous content of the file if append is set to false. Returns -1 in case of failure, 1 in case of success.
    
    returns -1 in case of an error
  </description>
  <retvals>
    integer retval  - -1 in case of failure, 1 in case of success
  </retvals>
  <parameters>
    string filename_with_path - the filename with it's path
    string value - the value to export, can be a long string that includes newlines and stuff. nil is not allowed!
    boolean binarymode - true or nil, it will store the value as binary-file; false, will store it as textstring
    boolean append - true, add the value to the end of the file; false or nil, write value to file and erase all previous data in the file
  </parameters>
  <chapter_context>
    File Management
    Write Files
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>filemanagement,export,write,file,textfile,binary</tags>
</US_DocBloc>
--]]
  -- check parameters
  if type(filename_with_path)~="string" then ultraschall.AddErrorMessage("WriteValueToFile","filename_with_path", "invalid filename", -1) return -1 end
  --if type(value)~="string" then ultraschall.AddErrorMessage("WriteValueToFile","value", "must be string; convert with tostring(value), if necessary.", -2) return -1 end
  value=tostring(value)
  
  -- prepare variables
  local binary, appendix, file
  if binarymode==nil or binarymode==true then binary="b" else binary="" end
  if append==nil or append==false then appendix="w" else appendix="a" end
  
  -- write file
  file=io.open(filename_with_path,appendix..binary)
  if file==nil then ultraschall.AddErrorMessage("WriteValueToFile","filename_with_path", "can't create file", -3) return -1 end
  file:write(value)
  file:close()
  return 1
end

function ultraschall.WriteValueToFile_Insert(filename_with_path, linenumber, value)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>WriteValueToFile_Insert</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval = ultraschall.WriteValueToFile_Insert(string filename_with_path, integer linenumber, string value)</functioncall>
  <description>
    Inserts value into a file at linenumber. All lines, up to linenumber-1 come before value, all lines at linenumber to the end of the file will come after value.
    Will return -1, if no such line exists.
    
    Note: non-binary-files only!
  </description>
  <parameters>
    string filename_with_path - filename to write the value to
    integer linenumber - the linenumber, at where to insert the value into the file
    string value - the value to be inserted into the file
  </parameters>
  <retvals>
    integer retval - 1, in case of success, -1 in case of error
  </retvals>
  <chapter_context>
    File Management
    Write Files
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>filemanagement,export,write,file,textfile,insert</tags>
</US_DocBloc>
]]
  if filename_with_path==nil then ultraschall.AddErrorMessage("WriteValueToFile_Insert","filename_with_path", "nil not allowed as filename", -1) return -1 end
  if reaper.file_exists(filename_with_path)==false then ultraschall.AddErrorMessage("WriteValueToFile_Insert","filename_with_path", "file does not exist", -2) return -1 end
  --if value==nil then ultraschall.AddErrorMessage("WriteValueToFile_Insert","value", "nil not allowed", -3) return -1 end
  value=tostring(value)
  if tonumber(linenumber)==nil then ultraschall.AddErrorMessage("WriteValueToFile_Insert","linenumber", "invalid linenumber", -4) return -1 end
  local numberoflines=ultraschall.CountLinesInFile(filename_with_path)
  if tonumber(linenumber)<1 or tonumber(linenumber)>numberoflines then ultraschall.AddErrorMessage("WriteValueToFile_Insert","linenumber", "linenumber must be between 1 and "..numberoflines.." for this file", -5) return -1 end
  local contents, correctnumberoflines = ultraschall.ReadLinerangeFromFile(filename_with_path, 1, linenumber-1) 
  local contents2, correctnumberoflines = ultraschall.ReadLinerangeFromFile(filename_with_path, linenumber, numberoflines)
  return ultraschall.WriteValueToFile(filename_with_path, contents..value..contents2, false, false)
end


function ultraschall.WriteValueToFile_Replace(filename_with_path, startlinenumber, endlinenumber, value)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>WriteValueToFile_Replace</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval = ultraschall.WriteValueToFile_Replace(string filename_with_path, integer startlinenumber, integer endlinenumber, string value)</functioncall>
  <description>
    Replaces the linenumbers startlinenumber to endlinenumber in a file with value. All lines, up to startlinenumber-1 come before value, all lines at endlinenumber+1 to the end of the file will come after value.
    Will return -1, if no such lines exists.
    
    Note: non-binary-files only!
  </description>
  <parameters>
    string filename_with_path - filename to write the value to
    integer startlinenumber - the first linenumber, to be replaced with value in the file
    integer endlinenumber - the last linenumber, to be replaced with value in the file
    string value - the value to be inserted into the file
  </parameters>
  <retvals>
    integer retval - 1, in case of success, -1 in case of error
  </retvals>
  <chapter_context>
    File Management
    Write Files
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>filemanagement,export,write,file,textfile,replace</tags>
</US_DocBloc>
]]
  if type(filename_with_path)~="string" then ultraschall.AddErrorMessage("WriteValueToFile_Replace","filename_with_path", "must be a string", -1) return -1 end
  if filename_with_path==nil then ultraschall.AddErrorMessage("WriteValueToFile_Replace","filename_with_path", "nil not allowed as filename", -0) return -1 end
  if reaper.file_exists(filename_with_path)==false then ultraschall.AddErrorMessage("WriteValueToFile_Replace","filename_with_path", "file does not exist", -2) return -1 end
--  if value==nil then ultraschall.AddErrorMessage("WriteValueToFile_Replace","value", "nil not allowed", -3) return -1 end
  value=tostring(value)
  if tonumber(startlinenumber)==nil then ultraschall.AddErrorMessage("WriteValueToFile_Replace","startlinenumber", "invalid linenumber", -4) return -1 end
  if tonumber(endlinenumber)==nil then ultraschall.AddErrorMessage("WriteValueToFile_Replace","endlinenumber", "invalid linenumber", -5) return -1 end
  local numberoflines=ultraschall.CountLinesInFile(filename_with_path)
  if tonumber(startlinenumber)<1 or tonumber(startlinenumber)>numberoflines then ultraschall.AddErrorMessage("WriteValueToFile_Replace","startlinenumber", "linenumber must be between 1 and "..numberoflines.." for this file", -6) return -1 end
  if tonumber(endlinenumber)<tonumber(startlinenumber) or tonumber(endlinenumber)>numberoflines then ultraschall.AddErrorMessage("WriteValueToFile_Replace","endlinenumber", "linenumber must be bigger than "..startlinenumber.." for startlinenumber and max "..numberoflines.." for this file", -7) return -1 end
  local contents, correctnumberoflines = ultraschall.ReadLinerangeFromFile(filename_with_path, 1, startlinenumber-1) 
  local contents2, correctnumberoflines = ultraschall.ReadLinerangeFromFile(filename_with_path, endlinenumber+1, numberoflines)
  return ultraschall.WriteValueToFile(filename_with_path, contents..value..contents2, false, false)
end

function ultraschall.WriteValueToFile_InsertBinary(filename_with_path, byteposition, value)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>WriteValueToFile_InsertBinary</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval = ultraschall.WriteValueToFile_InsertBinary(string filename_with_path, integer byteposition, string value)</functioncall>
  <description>
    Inserts value into a file at byteposition. All bytes, up to byteposition-1 come before value, all bytes at byteposition to the end of the file will come after value.
    Will return -1, if no such line exists.
    
    Note: good for binary files
  </description>
  <parameters>
    string filename_with_path - filename to write the value to
    integer byteposition - the byteposition, at where to insert the value into the file
    string value - the value to be inserted into the file
  </parameters>
  <retvals>
    integer retval - 1, in case of success, -1 in case of error
  </retvals>
  <chapter_context>
    File Management
    Write Files
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>filemanagement,export,write,file,textfile,insert,binary</tags>
</US_DocBloc>
]]
  if filename_with_path==nil then ultraschall.AddErrorMessage("WriteValueToFile_InsertBinary","filename_with_path", "nil not allowed as filename", -1) return -1 end
  if reaper.file_exists(filename_with_path)==false then ultraschall.AddErrorMessage("WriteValueToFile_InsertBinary","filename_with_path", "file does not exist", -2) return -1 end
  --if value==nil then ultraschall.AddErrorMessage("WriteValueToFile_InsertBinary","value", "nil not allowed", -3) return -1 end
  value=tostring(value)
  if tonumber(byteposition)==nil then ultraschall.AddErrorMessage("WriteValueToFile_InsertBinary","byteposition", "invalid value. Only integer allowed", -4) return -1 end
  local filelength=ultraschall.GetLengthOfFile(filename_with_path)
  if tonumber(byteposition)<0 or tonumber(byteposition)>filelength then ultraschall.AddErrorMessage("WriteValueToFile_InsertBinary","byteposition", "must be inbetween 0 and "..filelength.." for this file", -5) return -1 end
  if byteposition==0 then byteposition=1 end
  local correctnumberofbytes, contents=ultraschall.ReadBinaryFile_Offset(filename_with_path, 0, byteposition-1)
  local correctnumberofbytes2, contents2=ultraschall.ReadBinaryFile_Offset(filename_with_path, byteposition, -1)
  return ultraschall.WriteValueToFile(filename_with_path, contents..value..contents2, true, false)
end

function ultraschall.WriteValueToFile_ReplaceBinary(filename_with_path, startbyteposition, endbyteposition, value)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>WriteValueToFile_ReplaceBinary</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval = ultraschall.WriteValueToFile_ReplaceBinary(string filename_with_path, integer startbyteposition, integer endbyteposition, string value)</functioncall>
  <description>
    Replaces content in the file from startbyteposition to endbyteposition-1 with value. All bytes, up to startbyteposition-1 come before value, all bytes from (and including)endbyteposition to the end of the file will come after value.
    Will return -1, if no such line exists.
    
    Note: good for binary files
  </description>
  <parameters>
    string filename_with_path - filename to write the value to
    integer startbyteposition - the first byte in the file to be replaced, starting with 1, if you want to replace at the beginning of the file. Everything before startposition will be kept.
    integer endbyteposition - the first byte after the replacement. Everything from endbyteposition to the end of the file will be kept.
    string value - the value to be inserted into the file
  </parameters>
  <retvals>
    integer retval - 1, in case of success, -1 in case of error
  </retvals>
  <chapter_context>
    File Management
    Write Files
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>filemanagement,export,write,file,textfile,replace,binary</tags>
</US_DocBloc>
]]
  if filename_with_path==nil then ultraschall.AddErrorMessage("WriteValueToFile_ReplaceBinary","filename_with_path", "nil not allowed as filename", -1) return -1 end
  if reaper.file_exists(filename_with_path)==false then ultraschall.AddErrorMessage("WriteValueToFile_ReplaceBinary","filename_with_path", "file does not exist", -2) return -1 end
  --if value==nil then ultraschall.AddErrorMessage("WriteValueToFile_ReplaceBinary","value", "nil not allowed", -3) return -1 end
  value=tostring(value)
  if tonumber(startbyteposition)==nil then ultraschall.AddErrorMessage("WriteValueToFile_ReplaceBinary","startbyteposition", "invalid value. Only integer allowed", -4) return -1 end
  if tonumber(endbyteposition)==nil then ultraschall.AddErrorMessage("WriteValueToFile_ReplaceBinary","endbyteposition", "invalid value. Only integer allowed", -5) return -1 end
  
  local filelength=ultraschall.GetLengthOfFile(filename_with_path)
  if tonumber(startbyteposition)<0 or tonumber(startbyteposition)>filelength then ultraschall.AddErrorMessage("WriteValueToFile_ReplaceBinary","startbyteposition", "must be inbetween 0 and "..filelength.." for this file", -6) return -1 end
  if tonumber(endbyteposition)<tonumber(startbyteposition) or tonumber(endbyteposition)>filelength then ultraschall.AddErrorMessage("WriteValueToFile_ReplaceBinary","endbyteposition", "must be inbetween "..startbyteposition.." and "..filelength.." for this file", -7) return -1 end

  if startbyteposition==0 then startbyteposition=1 end
  correctnumberofbytes, contents=ultraschall.ReadBinaryFile_Offset(filename_with_path, 0, startbyteposition-1)
  local correctnumberofbytes2, contents2=ultraschall.ReadBinaryFile_Offset(filename_with_path, endbyteposition-1, -1)
  return ultraschall.WriteValueToFile(filename_with_path, contents..value..contents2, true, false)
end
