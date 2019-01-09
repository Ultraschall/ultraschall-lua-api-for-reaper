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
    Reaper=5.965
    JS=0.962
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
    Reaper=5.965
    JS=0.962
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
    Reaper=5.965
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
    Reaper=5.965
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
    returns the version, release-date and if it's a beta-version plus the currently installed hotfix
  </description>
  <retvals>
    string version - the current Api-version
    string date - the release date of this api-version
    string beta - if it's a beta version, this is the beta-version-number
    number versionnumber - a number, that you can use for comparisons like, "if requestedversion>versionnumber then"
    string tagline - the tagline of the current release
    string hotfix_date - the release-date of the currently installed hotfix ($ResourceFolder/ultraschall_api/ultraschall_hotfixes.lua)
  </retvals>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>version,versionmanagement</tags>
</US_DocBloc>
--]]
  return "4.00","15th of May 2019", "Beta 2.8", 400.028,  "\"Mike Oldfield - Taurus II\"", ultraschall.hotfixdate
end

--A,B,C,D,E,F,G,H,I=ultraschall.GetApiVersion()

function ultraschall.Base64_Encoder(source_string, base64_type, remove_newlines, remove_tabs)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Base64_Encoder</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>string encoded_string = ultraschall.Base64_Encoder(string source_string, optional integer base64_type, optional integer remove_newlines, optional integer remove_tabs)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Converts a string into a Base64-Encoded string. 
    Currently, only standard Base64-encoding is supported.
    
    Returns nil in case of an error
  </description>
  <retvals>
    string encoded_string - the encoded string
  </retvals>
  <parameters>
    string source_string - the string that you want to convert into Base64
    optional integer base64_type - the Base64-decoding-style
                                 - nil or 0, for standard default Base64-encoding
    optional integer remove_newlines - 1, removes \n-newlines(including \r-carriage return) from the string
                                     - 2, replaces \n-newlines(including \r-carriage return) from the string with a single space
    optional integer remove_tabs     - 1, removes \t-tabs from the string
                                     - 2, replaces \t-tabs from the string with a single space
  </parameters>
  <chapter_context>
    API-Helper functions
    Data Manipulation
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, convert, encode, base64, string</tags>
</US_DocBloc>
]]
  -- Not to myself:
  -- When you do the decoder, you need to take care, that the bitorder must be changed first, before creating the final-decoded characters
  -- that means: reverse the process of the "tear apart the source-string into bits"-code-passage
  
  -- check parameters and prepare variables
  if type(source_string)~="string" then ultraschall.AddErrorMessage("Base64_Encoder", "source_string", "must be a string", -1) return nil end
  if remove_newlines~=nil and math.type(remove_newlines)~="integer" then ultraschall.AddErrorMessage("Base64_Encoder", "remove_newlines", "must be an integer", -2) return nil end
  if remove_tabs~=nil and math.type(remove_tabs)~="integer" then ultraschall.AddErrorMessage("Base64_Encoder", "remove_tabs", "must be an integer", -3) return nil end
  if base64_type~=nil and math.type(base64_type)~="integer" then ultraschall.AddErrorMessage("Base64_Encoder", "base64_type", "must be an integer", -4) return nil end
  
  local tempstring={}
  local a=1
  local temp
  
  -- this is probably the future space for more base64-encoding-schemes
  local base64_string="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    
  -- if source_string is multiline, get rid of \r and replace \t and \n with a single whitespace
  if remove_newlines==1 then
    source_string=string.gsub(source_string, "\n", "")
    source_string=string.gsub(source_string, "\r", "")
  elseif remove_newlines==2 then
    source_string=string.gsub(source_string, "\n", " ")
    source_string=string.gsub(source_string, "\r", "")  
  end

  if remove_tabs==1 then
    source_string=string.gsub(source_string, "\t", "")
  elseif remove_tabs==2 then 
    source_string=string.gsub(source_string, "\t", " ")
  end
  
  
  -- tear apart the source-string into bits
  -- bitorder of bytes will be reversed for the later parts of the conversion!
  for i=1, source_string:len() do
    temp=string.byte(source_string:sub(i,i))
    temp=temp
    if temp&1==0 then tempstring[a+7]=0 else tempstring[a+7]=1 end
    if temp&2==0 then tempstring[a+6]=0 else tempstring[a+6]=1 end
    if temp&4==0 then tempstring[a+5]=0 else tempstring[a+5]=1 end
    if temp&8==0 then tempstring[a+4]=0 else tempstring[a+4]=1 end
    if temp&16==0 then tempstring[a+3]=0 else tempstring[a+3]=1 end
    if temp&32==0 then tempstring[a+2]=0 else tempstring[a+2]=1 end
    if temp&64==0 then tempstring[a+1]=0 else tempstring[a+1]=1 end
    if temp&128==0 then tempstring[a]=0 else tempstring[a]=1 end
    a=a+8
  end
  
  -- now do the encoding
  local encoded_string=""
  local temp2=0
  
  -- take six bits and make a single integer-value off of it
  -- after that, use this integer to know, which place in the base64_string must
  -- be read and included into the final string "encoded_string"
  for i=0, a-2, 6 do
    temp2=0
    if tempstring[i+1]==1 then temp2=temp2+32 end
    if tempstring[i+2]==1 then temp2=temp2+16 end
    if tempstring[i+3]==1 then temp2=temp2+8 end
    if tempstring[i+4]==1 then temp2=temp2+4 end
    if tempstring[i+5]==1 then temp2=temp2+2 end
    if tempstring[i+6]==1 then temp2=temp2+1 end
    encoded_string=encoded_string..base64_string:sub(temp2+1,temp2+1)
  end

  -- if the number of characters in the encoded_string isn't exactly divideable 
  -- by 3, add = to fill up missing bytes
  if encoded_string:len()%3==1 then encoded_string=encoded_string.."=="
  elseif encoded_string:len()%3==2 then encoded_string=encoded_string.."="
  end
  
  return encoded_string
end


--A=ultraschall.Base64_Encoder("Man is", 9, 9, 9)

function ultraschall.Base64_Decoder(source_string, base64_type)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Base64_Decoder</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>string decoded_string = ultraschall.Base64_Decoder(string source_string, optional integer base64_type)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Converts a Base64-encoded string into a normal string. 
    Currently, only standard Base64-encoding is supported.
    
    Returns nil in case of an error
  </description>
  <retvals>
    string decoded_string - the decoded string
  </retvals>
  <parameters>
    string source_string - the Base64-encoded string
    optional integer base64_type - the Base64-decoding-style
                                 - nil or 0, for standard default Base64-encoding
  </parameters>
  <chapter_context>
    API-Helper functions
    Data Manipulation
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, convert, decode, base64, string</tags>
</US_DocBloc>
]]
  if type(source_string)~="string" then ultraschall.AddErrorMessage("Base64_Decoder", "source_string", "must be a string", -1) return nil end
  if base64_type~=nil and math.type(base64_type)~="integer" then ultraschall.AddErrorMessage("Base64_Decoder", "base64_type", "must be an integer", -2) return nil end
  
  -- this is probably the place for other types of base64-decoding-stuff  
  local base64_string="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  
  
  -- remove =
  source_string=string.gsub(source_string,"=","")

  local L=source_string:match("[^"..base64_string.."]")
  if L~=nil then ultraschall.AddErrorMessage("Base64_Decoder", "source_string", "no valid Base64-string: invalid characters", -3) return nil end
  
  -- split the string into bits
  local bitarray={}
  local count=1
  local temp
  for i=1, source_string:len() do
    temp=base64_string:match(source_string:sub(i,i).."()")-2
    if temp&32~=0 then bitarray[count]=1 else bitarray[count]=0 end
    if temp&16~=0 then bitarray[count+1]=1 else bitarray[count+1]=0 end
    if temp&8~=0 then bitarray[count+2]=1 else bitarray[count+2]=0 end
    if temp&4~=0 then bitarray[count+3]=1 else bitarray[count+3]=0 end
    if temp&2~=0 then bitarray[count+4]=1 else bitarray[count+4]=0 end
    if temp&1~=0 then bitarray[count+5]=1 else bitarray[count+5]=0 end
    count=count+6
  end
  
  -- combine the bits into the original bytes and put them into decoded_string
  local decoded_string=""
  local temp2=0
  for i=0, count-1, 8 do
    temp2=0
    if bitarray[i+1]==1 then temp2=temp2+128 end
    if bitarray[i+2]==1 then temp2=temp2+64 end
    if bitarray[i+3]==1 then temp2=temp2+32 end
    if bitarray[i+4]==1 then temp2=temp2+16 end
    if bitarray[i+5]==1 then temp2=temp2+8 end
    if bitarray[i+6]==1 then temp2=temp2+4 end
    if bitarray[i+7]==1 then temp2=temp2+2 end
    if bitarray[i+8]==1 then temp2=temp2+1 end
    decoded_string=decoded_string..string.char(temp2)
  end
  return decoded_string
end

--O=ultraschall.Base64_Decoder("VHV0YXNzc0z=")

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
--ultraschall.MB(reaper.GetTrack(0,0))

function ultraschall.CreateValidTempFile(filename_with_path, create, suffix, retainextension)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CreateValidTempFile</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string tempfilename = ultraschall.CreateValidTempFile(string filename_with_path, boolean create, string suffix, boolean retainextension)</functioncall>
  <description>
    Tries to determine a valid temporary filename. Will check filename_with_path with an included number between 0 and 16384 to create such a filename.
    You can also add your own suffix to the filename.
    
    The pattern is: filename_with_path$Suffix~$number.ext (when retainextension is set to true!)
    
    If you wish, you can also create this temporary-file as an empty file.
    
    The path of the tempfile is always the same as the original file.
    
    Returns nil in case of failure.
  </description>
  <retvals>
    string tempfilename - the valid temporary filename found
  </retvals>
  <parameters>
    string filename_with_path - the original filename
    boolean create - true, if you want to create that temporary file as an empty file; false, just return the filename
    string suffix - if you want to alter the temporary filename with an additional suffix, use this parameter
    boolean retainextension - true, keep the extension(if existing) at the end of the tempfile; false, just add the suffix~number at the end.
  </parameters>
  <chapter_context>
    File Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>filemanagement, create, temporary, file, filename</tags>
</US_DocBloc>
]]
  if type(filename_with_path)~="string" then ultraschall.AddErrorMessage("CreateValidTempFile","filename_with_path", "Must be a string!", -2) return nil end
  if type(create)~="boolean" then ultraschall.AddErrorMessage("CreateValidTempFile","create", "Must be boolean!", -3) return nil end
  if type(suffix)~="string" then ultraschall.AddErrorMessage("CreateValidTempFile","suffix", "Must be a string!", -4) return nil end
  if type(retainextension)~="boolean" then ultraschall.AddErrorMessage("CreateValidTempFile","retainextension", "Must be boolean!", -5) return nil end
  local extension, tempfilename, A
  if retainextension==true then extension=filename_with_path:match(".*(%..*)") end
  if extension==nil then extension="" end
  for i=0, 16384 do
    tempfilename=filename_with_path..suffix.."~"..i..extension
    if reaper.file_exists(tempfilename)==false then
      if create==true then 
        A=ultraschall.WriteValueToFile(tempfilename,"")
        if A==1 then return tempfilename end
      elseif create==false then 
        return tempfilename
      end
    end
  end
  ultraschall.AddErrorMessage("CreateValidTempFile","filename_with_path", "Couldn't create a valid temp-file!", -1)
  return nil
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

--A,B,C,D=ultraschall.RenderProject_RenderCFG(nil, nil, 0, 100, true, true, true)

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

--length, numchannels, Samplerate, Filetype = ultraschall.GetMediafileAttributes("c:\\Users\\meo\\Desktop\\tudelu\\tudelu.RPP")
--A,B,C,D,E = ultraschall.CreateTemporaryFileOfProjectfile("c:\\Users\\meo\\Desktop\\tudelu\\tudelu.RPP")
--A,B,C,D,E = ultraschall.CreateTemporaryFileOfProjectfile()

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

function ultraschall.GetProjectStateChunk(Project)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetProjectStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string ProjectStateChunk = ultraschall.GetProjectStateChunk(ReaProject project)</functioncall>
  <description>
    Gets a ProjectStateChunk of a ReaProject-object.
    
    Returns nil in case of error.
  </description>
  <parameters>
    ReaProject project - the ReaProject, whose ProjectStateChunk you want; nil, for the currently opened project
  </parameters>
  <retvals>
    string ProjectStateChunk - the ProjectStateChunk of the a specific ReaProject-object; nil, in case of an error
  </retvals>
  <chapter_context>
    Project-Files
    RPP-Files Get
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>projectfiles, get, projectstatechunk</tags>
</US_DocBloc>
]]  
  if Project~=nil and ultraschall.IsValidReaProject(Project)==false then ultraschall.AddErrorMessage("GetProjectStateChunk", "Project", "must be a valid ReaProject", -1) return nil end
  local currentproject=reaper.EnumProjects(-1,"")
  if Project~=nil then
    reaper.PreventUIRefresh(1)
    reaper.SelectProjectInstance(Project)
  end
  local Path=reaper.GetResourcePath().."\\QueuedRenders\\"
  local ProjectStateChunk=""
  local filecount, files = ultraschall.GetAllFilesnamesInPath(Path)
  
  for i=1, filecount do
    local filepath,filename=ultraschall.GetPath(files[i])
    os.rename(files[i], filepath.."US"..filename)
  end
  

  reaper.Main_OnCommand(41823,0)

  local filecount2, files2 = ultraschall.GetAllFilesnamesInPath(Path)  
  if files2[1]==nil then files2[1]="" end
  while reaper.file_exists(files2[1])==false do
    filecount2, files2 = ultraschall.GetAllFilesnamesInPath(Path)
    if files2[1]==nil then files2[1]="" end
  end
  
  
  for i=1, filecount2 do
    if files2[i]:match(Path.."qrender")~=nil then 
      ProjectStateChunk=ultraschall.ReadFullFile(files2[i]) 
      os.remove(files2[i]) break 
    end
  end
  
  for i=1, filecount do
    local filepath,filename=ultraschall.GetPath(files[i])
    os.rename(filepath.."US"..filename, files[i])
  end

  if Project~=nil then
    reaper.PreventUIRefresh(-1)
    reaper.SelectProjectInstance(currentproject)
  end  
  ProjectStateChunk=string.gsub(ProjectStateChunk,"  QUEUED_RENDER_OUTFILE.-\n","")
  ProjectStateChunk=string.gsub(ProjectStateChunk,"  QUEUED_RENDER_ORIGINAL_FILENAME.-\n","")
  return ProjectStateChunk
end

--A=ultraschall.GetProjectStateChunk()


ultraschall.ShowLastErrorMessage()
