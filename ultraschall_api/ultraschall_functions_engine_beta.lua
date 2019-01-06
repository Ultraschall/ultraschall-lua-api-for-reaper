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

function ultraschall.SplitStringAtNULLBytes(splitstring)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SplitStringAtNULLBytes</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.941
    Lua=5.3
  </requires>
  <functioncall>integer count, array split_strings = ultraschall.SplitStringAtNULLBytes(string splitstring)</functioncall>
  <description>
    Splits splitstring into individual string at NULL-Bytes.
  </description>
  <retvals>
    integer count - the number of found strings
    array split_strings - the found strings put into an array
  </retvals>
  <parameters>
    string splitstring - the string with NULL-Bytes(\0) into it, that you want to split
  </parameters>
  <chapter_context>
    API-Helper functions
    Data Manipulation
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, split, string, nullbytes</tags>
</US_DocBloc>
]]
  if type(splitstring)~="string" then ultraschall.AddErrorMessage("SplitStringAtNULLBytes", "splitstring", "Must be a string.", -1) return -1 end
  -- add a NULL-Byte at the end, helps us finding the end of the string later
  splitstring=splitstring.."\0"
  local count=0
  local strings={}
  local temp, offset
  
  -- let's split the string
  while splitstring~=nil do
    -- find the next string-part
    temp,offset=splitstring:match("(.-)()\0")    
    if temp~=nil then 
      -- if the next found string isn't nil, then add it fo strings-array and count+1
      count=count+1 
      strings[count]=temp
      splitstring=splitstring:sub(offset+1,-1)
      --reaper.MB(splitstring:len(),"",0)
    else 
      -- if temp is nil, the string is probably finished splitting
      break 
    end
  end
  return count, strings
end

--A2,B2=ultraschall.SplitStringAtNULLBytes("splitstrin\0g\0\0\0\0")

function ultraschall.GetLastPlayState()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetLastPlayState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>number last_play_state = ultraschall.GetLastPlayState()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the last playstate before the current one. Needs Ultraschall-API-background-scripts started first, see [RunBackgroundHelperFeatures()](#RunBackgroundHelperFeatures).
    
    returns -1, if Ultraschall-API-backgroundscripts weren't started yet.
  </description>
  <retvals>
    number last_play_state - the last playstate before the current one; -1, in case of an error
                           - Either bitwise: 
                           -    &1=playing
                           -    &2=pause
                           -    &=4 is recording
                           - or 
                           -    0, stop 
                           -    1, play 
                           -    2, paused play 
                           -    5, recording 
                           -    6, paused recording
  </retvals>
  <chapter_context>
    Navigation
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>navigation, last playstate, editcursor</tags>
</US_DocBloc>
]]
  if reaper.GetExtState("Ultraschall", "defer_scripts_ultraschall_track_old_playstate.lua")~="true" then return -1 end
  return tonumber(reaper.GetExtState("ultraschall", "last_playstate"))
end
--ultraschall.RunBackgroundHelperFeatures()
--A=ultraschall.GetLastPlayState()

function ultraschall.Main_OnCommandByFilename(filename)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Main_OnCommandByFilename</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.Main_OnCommandByFilename(string filename)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Runs a command by a filename. It internally registers the file temporarily as command, runs it and unregisters it again.
    This is especially helpful, when you want to run a command for sure without possible command-id-number-problems.
    
    Returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, if running it was successful; false, if not
  </retvals>
  <parameters>
    string filename - the name of the scriptfile to run
  </parameters>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, run command, filename</tags>
</US_DocBloc>
]]
  if type(filename)~="string" then ultraschall.AddErrorMessage("Main_OnCommandByFilename", "filename", "Must be a string.", -1) return false end
  if reaper.file_exists(filename)==false then ultraschall.AddErrorMessage("Main_OnCommandByFilename", "filename", "File does not exist.", -2) return false end
  
  local commandid=reaper.AddRemoveReaScript(true, 0, filename, true)
  if commandid==0 then ultraschall.AddErrorMessage("Main_OnCommandByFilename", "filename", "Couldn't register filename. Is it a valid ReaScript?.", -3) return false end
  reaper.Main_OnCommand(commandid, 0)
  local commandid2=reaper.AddRemoveReaScript(false, 0, filename, true)
  return true
end

--A=ultraschall.GetReaperScriptPath().."/testscript_that_displays_stuff.lua"
--A=ultraschall.GetReaperScriptPath().."/us.png"
--ultraschall.Main_OnCommandByFilename(A)


function ultraschall.MIDI_OnCommandByFilename(filename, MIDIEditor_HWND)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>MIDI_OnCommandByFilename</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.MIDI_OnCommandByFilename(string filename, optional HWND Midi_EditorHWND)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Runs a command by a filename in the MIDI-editor-context. It internally registers the file temporarily as command, runs it and unregisters it again.
    This is especially helpful, when you want to run a command for sure without possible command-id-number-problems.
    
    Returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, if running it was successful; false, if not
  </retvals>
  <parameters>
    HWND Midi_EditorHWND - the window-handler of the MIDI-editor, in which to run the script; nil, for the last active MIDI-editor
    string filename - the name of the scriptfile to run
  </parameters>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, run command, filename, midi, midieditor</tags>
</US_DocBloc>
]]
  if type(filename)~="string" then ultraschall.AddErrorMessage("MIDI_OnCommandByFilename", "filename", "Must be a string.", -1) return false end
  if reaper.file_exists(filename)==false then ultraschall.AddErrorMessage("MIDI_OnCommandByFilename", "filename", "File does not exist.", -2) return false end
  if MIDIEditor_HWND~=nil then
    if pcall(reaper.JS_Window_GetTitle, MIDIEditor_HWND, "")==false then ultraschall.AddErrorMessage("MIDI_OnCommandByFilename", "MIDIEditor_HWND", "Not a valid HWND.", -3) return false end
    if reaper.JS_Window_GetTitle(MIDIEditor_HWND, ""):match("MIDI")==nil then ultraschall.AddErrorMessage("MIDI_OnCommandByFilename", "MIDIEditor_HWND", "Not a valid MIDI-Editor-HWND.", -4) return false end
  end
  
  local commandid =reaper.AddRemoveReaScript(true, 32060, filename, true)
  local commandid2=reaper.AddRemoveReaScript(true, 32061, filename, true)
  local commandid3=reaper.AddRemoveReaScript(true, 32062, filename, true)
  if commandid==0 then ultraschall.AddErrorMessage("MIDI_OnCommandByFilename", "filename", "Couldn't register filename. Is it a valid ReaScript?.", -5) return false end
  if MIDIEditor_HWND==nil then 
    local A2=reaper.MIDIEditor_LastFocused_OnCommand(commandid, true)
    if A2==false then A2=reaper.MIDIEditor_LastFocused_OnCommand(commandid, false) end
    if A2==false then ultraschall.AddErrorMessage("MIDI_OnCommandByFilename", "MIDIEditor_HWND", "No last focused MIDI-Editor open.", -6) return false end
  end
  local L=reaper.MIDIEditor_OnCommand(MIDIEditor_HWND, commandid)
  local commandid_2=reaper.AddRemoveReaScript(false, 32060, filename, true)
  local commandid_3=reaper.AddRemoveReaScript(false, 32061, filename, true)
  local commandid_4=reaper.AddRemoveReaScript(false, 32062, filename, true)
  return true
end

--A=ultraschall.GetReaperScriptPath().."/testscript_that_displays_stuff.lua"
--AAA=ultraschall.MIDI_OnCommandByFilename(reaper.MIDIEditor_GetActive(), A)
--AAA=ultraschall.MIDI_OnCommandByFilename(A, reaper.MIDIEditor_GetActive())
--AAA=ultraschall.MIDI_OnCommandByFilename(reaper.GetMainHwnd(), A)

function ultraschall.IsValidHWND(HWND)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsValidHWND</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.IsValidHWND(HWND hwnd)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Checks, if a HWND-handler is a valid one.
    
    Returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, if running it was successful; false, if not
  </retvals>
  <parameters>
    HWND hwnd - the HWND-handler to check for
  </parameters>
  <chapter_context>
    User Interface
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>user interface, hwnd, is valid, check</tags>
</US_DocBloc>
]]
  if pcall(reaper.JS_Window_GetTitle, HWND, "")==false then ultraschall.AddErrorMessage("IsValidHWND", "HWND", "Not a valid HWND.", -1) return false end
  return true
end

--AAA=ultraschall.IsValidHWND(reaper.Splash_GetWnd("tudelu",nil))

--AAAAA=reaper.MIDIEditor_LastFocused_OnCommand(1)

function ultraschall.GetPath(str,sep)
-- return the path of a filename-string
-- -1 if it doesn't work
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetPath</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string path, string filename = ultraschall.GetPath(string str, optional string sep)</functioncall>
  <description>
    returns the path of a filename-string
    
    returns "", "" in case of error 
  </description>
  <retvals>
    string path  - the path as a string
    string filename - the filename, without the path
  </retvals>
  <parameters>
    string str - the path with filename you want to process
    string sep - a separator, with which the function knows, how to separate filename from path; nil to use the last useful separator in the string, which is either / or \\
  </parameters>
  <chapter_context>
    File Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>filemanagement,path,separator</tags>
</US_DocBloc>
--]]

  -- check parameters
  if type(str)~="string" then ultraschall.AddErrorMessage("GetPath","str", "only a string allowed", -1) return "", "" end
  if sep~=nil and type(sep)~="string" then ultraschall.AddErrorMessage("GetPath","sep", "only a string allowed", -2) return "", "" end
  
  -- do the patternmatching
  local result, file

--  if result==nil then ultraschall.AddErrorMessage("GetPath","", "separator not found", -3) return "", "" end
--  if file==nil then file="" end
  if sep~=nil then 
    result=str:match("(.*"..sep..")")
    file=str:match(".*"..sep.."(.*)")
    if result==nil then ultraschall.AddErrorMessage("GetPath","", "separator not found", -3) return "", "" end
  else
    result=str:match("(.*".."[\\/]"..")")
    file=str:match(".*".."[\\/]".."(.*)")
  end
  return result, file
end

--B1,B2=ultraschall.GetPath("c:\\nillimul/\\test.kl", "\\")


function ultraschall.BrowseForOpenFiles(windowTitle, initialFolder, initialFile, extensionList, allowMultiple)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>BrowseForOpenFiles</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    JS=0.962
    Lua=5.3
  </requires>
  <functioncall>string path, integer number_of_files, array filearray = ultraschall.BrowseForOpenFiles(string windowTitle, string initialFolder, string initialFile, string extensionList, boolean allowMultiple)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Opens a filechooser-dialog which optionally allows selection of multiple files.
    Unlike Reaper's own GetUserFileNameForRead, this dialog allows giving non-existant files as well(for saving operations).
    
    Returns nil in case of an error
  </description>
  <retvals>
    string path - the path, in which the selected file(s) lie; nil, in case of an error; "" if no file was selected
    integer number_of_files - the number of files selected; 0, if no file was selected
    array filearray - an array with all the selected files
  </retvals>
  <parameters>
    string windowTitle - the title shown in the filechooser-dialog
    string initialFolder - the initial-folder opened in the filechooser-dialog
    string initialFile - the initial-file selected in the filechooser-dialog, good for giving default filenames
    string extensionList - a list of the extensions shown
    boolean allowMultiple - true, allows selection of multiple files; false, only allows selection of single files
  </parameters>
  <chapter_context>
    User Interface
    Dialogs
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>user interface, dialog, file, chooser, multiple</tags>
</US_DocBloc>
]]
  if type(windowTitle)~="string"  then ultraschall.AddErrorMessage("BrowseForOpenFiles", "windowTitle",   "Must be a string.",  -1) return nil end  
  if type(initialFolder)~="string"  then ultraschall.AddErrorMessage("BrowseForOpenFiles", "initialFolder", "Must be a string.",  -2) return nil end  
  if type(initialFile)~="string"  then ultraschall.AddErrorMessage("BrowseForOpenFiles", "initialFile",   "Must be a string.",  -3) return nil end  
  if type(extensionList)~="string"  then ultraschall.AddErrorMessage("BrowseForOpenFiles", "extensionList", "Must be a string.",  -4) return nil end  
  if type(allowMultiple)~="boolean" then ultraschall.AddErrorMessage("BrowseForOpenFiles", "allowMultiple", "Must be a boolean.", -5) return nil end  
  
  local retval, fileNames = reaper.JS_Dialog_BrowseForOpenFiles(windowTitle, initialFolder, initialFile, extensionList, allowMultiple)
  local path, filenames, count
  if allowMultiple==true then
    count, filenames = ultraschall.SplitStringAtNULLBytes(fileNames)
    path = filenames[1]
    table.remove(filenames,1)
  else
    filenames={}
    path, filenames[1]=ultraschall.GetPath(fileNames)
    count=2
  end
  if retval==0 then path="" count=1 filenames={} end
  return path, count-1, filenames
end

--A,B,C=ultraschall.BrowseForOpenFiles("Tudelu", "c:\\", "", "", true)

--A,B,C=reaper.JS_Dialog_BrowseForOpenFiles("Tudelu", "", "", "", false)

function ultraschall.CloseReaConsole()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CloseReaConsole</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    JS=0.962
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.CloseReaConsole()</functioncall>
  <description>
    Closes the ReaConsole-window, if opened.
    
    Note for Mac-users: does not work currently on MacOS.
    
    Returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, if there is a mute-point; false, if there isn't one
  </retvals>
  <chapter_context>
    User Interface
    Screen and Windowmanagement
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>window, reaconsole, close</tags>
</US_DocBloc>
]]
  local retval,Adr=reaper.JS_Window_ListFind("ReaScript console output", true)

  if retval>1 then ultraschall.AddErrorMessage("CloseReaConsole", "", "Multiple windows are open, that are named \"ReaScript console output\". Can't find the right one, sorry.", -1) return false end
  if retval==0 then ultraschall.AddErrorMessage("CloseReaConsole", "", "ReaConsole-window not opened", -2) return false end
  local B=reaper.JS_Window_HandleFromAddress(Adr)
  reaper.JS_Window_Destroy(B)
  return true
end

--reaper.ShowConsoleMsg("Tudelu")
--LL,LL=ultraschall.CloseReaConsole()

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
  return "4.00","15th of May 2019", "Beta 2.8", 400.028,  "\"Mike Oldfield - Taurus II\""
end

ultraschall.ShowLastErrorMessage()
