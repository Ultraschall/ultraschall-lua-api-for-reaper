--[[
################################################################################
# 
# Copyright (c) 2014-2018 Ultraschall (http://ultraschall.fm)
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



