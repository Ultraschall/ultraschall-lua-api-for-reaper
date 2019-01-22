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
  return "4.00","15th of March 2019", "Beta 2.75", 400.0275,  "\"Blue Oyster Cult - Don't fear the Reaper\"", ultraschall.hotfixdate
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

--A,B,C,D,E,F,G,H,I,J=ultraschall.InsertMediaItemFromFile(ultraschall.Api_Path.."/misc/silence.flac", 0, 0, -1, 0)

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
  reaper.PreventUIRefresh(1)
  if Project~=nil then
    reaper.SelectProjectInstance(Project)
  end
  local Path=reaper.GetResourcePath().."\\QueuedRenders\\"
  local ProjectStateChunk=""
  local filecount, files = ultraschall.GetAllFilesnamesInPath(Path)
  local retval, item, endposition, numchannels, Samplerate, Filetype, editcursorposition, track, temp
  if reaper.GetProjectLength(0)==0 then 
    temp=true
    retval, item, endposition, numchannels, Samplerate, Filetype, editcursorposition, track = ultraschall.InsertMediaItemFromFile(ultraschall.Api_Path.."/misc/silence.flac", 0, 0, -1, 0)
  end
  
  for i=1, filecount do
    local filepath,filename=ultraschall.GetPath(files[i])
    os.rename(files[i], filepath.."US"..filename)
  end
  
  local start, endit = reaper.GetSet_LoopTimeRange(false, false, -10, -10, false)
  if start==0 and endit==0 then reaper.GetSet_LoopTimeRange(true, false, 0, 1, false) end
  reaper.Main_OnCommand(41823,0)

  if temp==true then
    retval, sc=reaper.GetTrackStateChunk(track, "", false)
    reaper.DeleteTrack(track)
  end
  
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
    reaper.SelectProjectInstance(currentproject)
  end    
  reaper.PreventUIRefresh(-1)
  ProjectStateChunk=string.gsub(ProjectStateChunk,"  QUEUED_RENDER_OUTFILE.-\n","")
  ProjectStateChunk=string.gsub(ProjectStateChunk,"  QUEUED_RENDER_ORIGINAL_FILENAME.-\n","")
  if temp==true then
    ProjectStateChunk=string.gsub(ProjectStateChunk, "<TRACK.-NAME silence.-%c%s%s>", "")
  end
  if start==0 and endit==0 then retval = ultraschall.SetProject_Selection(nil, 0, 0, 0, 0, ProjectStatechunk) end
  return ProjectStateChunk
end

--A=ultraschall.GetProjectStateChunk()
--reaper.MB(A:sub(-3500,-1),"",0)
--reaper.CF_SetClipboard(A)


--ultraschall.RenderProject_RenderCFG(nil, nil, 1, 10, false, false, false, nil)

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

function ultraschall.StateChunkLayouter(statechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>StateChunkLayouter</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>string layouted_statechunk = ultraschall.StateChunkLayouter(string statechunk)</functioncall>
  <description>
    Layouts StateChunks as returned by <a href="Reaper_Api_Documentation.html#GetTrackStateChunk">GetTrackStateChunk</a> or <a href="Reaper_Api_Documentation.html#GetItemStateChunk">GetItemStateChunk</a> into a format that resembles the formatting-rules of an rpp-file.
    This is very helpful, when parsing such a statechunk, as you can now use the number of spaces used for intendation as help parsing.
    Usually, every new element, that starts with &lt; will be followed by none or more lines, that have two spaces added in the beginning.
    Example of a MediaItemStateChunk(I use . to display the needed spaces in the beginning of each line):
    <pre><code>
    &lt;ITEM
    ..POSITION 6.96537864205337
    ..SNAPOFFS 0
    ..LENGTH 1745.2745
    ..LOOP 0
    ..ALLTAKES 0
    ..FADEIN 1 0.01 0 1 0 0
    ..FADEOUT 1 0.01 0 1 0 0
    ..MUTE 0
    ..SEL 1
    ..IGUID {020E6372-97E6-4066-9010-B044F67F2772}
    ..IID 1
    ..NAME myaudio.flac
    ..VOLPAN 1 0 1 -1
    ..SOFFS 0
    ..PLAYRATE 1 1 0 -1 0 0.0025
    ..CHANMODE 0
    ..GUID {79F087CE-49E8-4212-91F5-8487FBCF10B1}
    ..&lt;SOURCE FLAC
    ....FILE "C:\Users\meo\Desktop\X_Karo_Lynn-Interview.flac"
    ..&gt;
    &gt;
    </code></pre>
    
    This function will not check, if you've passed a valid statechunk!
    
    returns nil in case of an error
  </description>
  <parameters>
    string statechunk - a statechunk, that you want to layout properly
  </parameters>
  <retvals>
    string layouted_statechunk - the statechunk, that is now layouted to the rules of rpp-projectfiles
  </retvals>
  <chapter_context>
    API-Helper functions
    Data Manipulation
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, layout, statechunk</tags>
</US_DocBloc>
]]

  if type(statechunk)~="string" then ultraschall.AddErrorMessage("StateChunkLayouter","statechunk", "must be a string", -1) return nil end  
  local num_tabs=0
  local newsc=""
  for k in string.gmatch(statechunk, "(.-\n)") do
    if k:sub(1,1)==">" then num_tabs=num_tabs-1 end
    for i=0, num_tabs-1 do
      newsc=newsc.."  "
    end
    if k:sub(1,1)=="<" then num_tabs=num_tabs+1 end
    newsc=newsc..k
  end
  return newsc
end


function ultraschall.CountUltraschallEffectPlugins(track)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CountUltraschallEffectPlugins</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>integer num_studiolink, table studiolink_bypass_state, integer num_studiolink_onair, table studiolink_onair_bypass_state, integer num_soundboard, table soundboard_bypass_state, integer num_usdynamics, table usdynamics_bypass_state = ultraschall.CountUltraschallEffectPlugins(integer track)</functioncall>
  <description>
    Counts the number of loaded StudioLink-plugins, StudioLink_OnAir-plugins, Ultraschall-Soundboards and Ultraschall_Dynamics-instances in this track.
    It also returns the bypass/offline-states of each plugin as a table, of the following format:    
      <pre><code>
        bypass_state_table[plugin_index][1]=bypass state; 1, plugin-instance is bypassed; 0, plugin-instance is normal
        bypass_state_table[plugin_index][2]=offline state; 1, plugin-instance is offline; 0, plugin-instance is online
        bypass_state_table[plugin_index][3]=unknown state(needs documentation first); 0, default setting
      </code></pre>
    Probably only helpful, if you've installed these plugins or using Ultraschall.
    
    returns -1 in case of an error
  </description>
  <parameters>
    integer track - the tracknumber, whose plugin-counts/bypass-states you want to get; 0, Master Track; 1 and higher, Track 1 an higher
  </parameters>
  <retvals>
    integer num_studiolink - the number of loaded StudioLink-plugins in this track
    table studiolink_bypass_state - the bypass-states of StudioLink in this track
    integer num_studiolink_onair - the number of loaded StudioLink_OnAir-plugins in this track
    table studiolink_onair_bypass_state - the bypass-states of StudioLink_OnAir in this track
    integer num_soundboard - the number of loaded Ultraschall Soundboard-plugins in this track
    table soundboard_bypass_state - the bypass-states of the Ultraschall Soundboard in this track
    integer num_usdynamics - the number of loaded Ultraschall_Dynamics-plugins in this track
    table usdynamics_bypass_state - the bypass-states of Ultraschall_Dynamics in this track
  </retvals>
  <chapter_context>
    FX/Plugin Management
    Ultraschall-related
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>fx_pluginmanagement, count, get, studiolink, studiolinkonair, soundboard, ultraschall_dynamics, bypass-state, offline-state</tags>
</US_DocBloc>
]]
  local MediaTrack
  if math.type(track)~="integer" then ultraschall.AddErrorMessage("CountUltraschallEffectPlugins", "track", "must be an integer", -1) return -1 end
  if track==0 then MediaTrack=reaper.GetMasterTrack(0) else MediaTrack=reaper.GetTrack(0, track-1) end
  if MediaTrack==nil then ultraschall.AddErrorMessage("CountUltraschallEffectPlugins", "track", "no such track", -2) return -1 end
  local num_sl=0
  local sl_byp={}
  local num_slonair=0
  local slonair_byp={}
  local num_soundboard=0
  local soundboard_byp={}
  local num_usdynamics=0
  local usdynamics_byp={}
  local lastbypassline=""

  local A,B=reaper.GetTrackStateChunk(MediaTrack,"",false)
  
  for k in string.gmatch(B,"(.-\n)") do
    if k:match("<.-StudioLinkOnAir ")~=nil then 
      num_slonair=num_slonair+1 
      slonair_byp[num_slonair]={lastbypassline:match(" (%d) (%d) (%d)")} 
      slonair_byp[num_slonair][1]=tonumber(slonair_byp[num_slonair][1]) 
      slonair_byp[num_slonair][2]=tonumber(slonair_byp[num_slonair][2]) 
      slonair_byp[num_slonair][3]=tonumber(slonair_byp[num_slonair][3]) 
    elseif k:match("<.-StudioLink ")~=nil then 
      num_sl=num_sl+1 
      sl_byp[num_sl]={lastbypassline:match(" (%d) (%d) (%d)")} 
      sl_byp[num_sl][1]=tonumber(sl_byp[num_sl][1]) 
      sl_byp[num_sl][2]=tonumber(sl_byp[num_sl][2]) 
      sl_byp[num_sl][3]=tonumber(sl_byp[num_sl][3])
    elseif k:match("<.-Soundboard %(Ultraschall%)")~=nil then 
      num_soundboard=num_soundboard+1
      soundboard_byp[num_soundboard]={lastbypassline:match(" (%d) (%d) (%d)")} 
      soundboard_byp[num_soundboard][1]=tonumber(soundboard_byp[num_soundboard][1]) 
      soundboard_byp[num_soundboard][2]=tonumber(soundboard_byp[num_soundboard][2]) 
      soundboard_byp[num_soundboard][3]=tonumber(soundboard_byp[num_soundboard][3]) 
    elseif k:match("<.-Ultraschall_Dynamics")~=nil then 
      num_usdynamics=num_usdynamics+1 
      usdynamics_byp[num_usdynamics]={lastbypassline:match(" (%d) (%d) (%d)")} 
      usdynamics_byp[num_usdynamics][1]=tonumber(usdynamics_byp[num_usdynamics][1]) 
      usdynamics_byp[num_usdynamics][2]=tonumber(usdynamics_byp[num_usdynamics][2]) 
      usdynamics_byp[num_usdynamics][3]=tonumber(usdynamics_byp[num_usdynamics][3]) 
    elseif k:match("BYPASS %d %d %d%c")~=nil then lastbypassline=k
    end
  end
  return num_sl, sl_byp, num_slonair, slonair_byp, num_soundboard, soundboard_byp, num_usdynamics, usdynamics_byp
end

function print(...)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>print</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>print(parameter_1 to parameter_n)</functioncall>
  <description>
    replaces Lua's own print-function. Converts all parametes given into string using tostring() and displays them as a MessageBox, separated by two spaces.
  </description>
  <parameters>
    parameter_1 to parameter_n - the parameters, that you want to have printed out
  </parameters>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helperfunctions, print, messagebox</tags>
</US_DocBloc>
]]

  local string=""
  local count=1
  local temp={...}
  while temp[count]~=nil do
    string=string.."  "..tostring(temp[count])
    count=count+1
  end
  reaper.MB(string:sub(3,-1),"Print",0)
end

--print("Hula","Hoop",reaper.GetTrack(0,0))
--print("tudel")

function print2(...)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>print2</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>print2(parameter_1 to parameter_n)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    like the [print](#print)-replacement-function, but outputs the parameters to the ReaScript-console instead. 
    
    Converts all parametes given into string using tostring() and displays them in the ReaScript-console, separated by two spaces, ending with a newline.
  </description>
  <parameters>
    parameter_1 to parameter_n - the parameters, that you want to have printed out
  </parameters>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helperfunctions, print, console</tags>
</US_DocBloc>
]]

  local string=""
  local count=1
  local temp={...}
  while temp[count]~=nil do
    string=string.."  "..tostring(temp[count])
    count=count+1
  end
  reaper.ShowConsoleMsg(string:sub(3,-1).."\n","Print",0)
end

--print2("Hula","Hoop",reaper.GetTrack(0,0))
--print("tudel")


function ultraschall.GetTopmostHWND(hwnd)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTopmostHWND</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    JS=0.962
    Lua=5.3
  </requires>
  <functioncall>HWND topmost_hwnd, integer number_of_parent_hwnd, table all_parent_hwnds = ultraschall.GetTopmostHWND(HWND hwnd)</functioncall>
  <description>
    returns the topmost-parent hwnd of a hwnd, as sometimes, hwnds are children of a higher hwnd. It also returns the number of parent hwnds available and a list of all parent hwnds for this hwnd.
    
    A hwnd is a window-handler, which contains all attributes of a certain window.
    
    returns nil in case of an error
  </description>
  <parameters>
    HWND hwnd - the HWND, whose topmost parent-HWND you want to have
  </parameters>
  <retvals>
    HWND hwnd - the top-most parent hwnd available
    integer number_of_parent_hwnd - the number of parent hwnds, that are above the parameter hwnd
    table all_parent_hwnds - all available parent hwnds, above the parameter hwnd, including the topmost-hwnd
  </retvals>
  <chapter_context>
    User Interface
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>user interface, hwnd, topmost, parent hwnd, get, count</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidHWND(hwnd)==false then ultraschall.AddErrorMessage("GetTopmostHWND", "hwnd", "not a valid hwnd", -1) return nil end
  local count=1
  local other_hwnds={}
  while reaper.JS_Window_GetParent(hwnd)~=nil do  
     hwnd=reaper.JS_Window_GetParent(hwnd)
     other_hwnds[count]=hwnd
     count=count+1
  end
  return hwnd, count-1, other_hwnds
end

--A,B,C,D=ultraschall.GetTopmostHWND(reaper.JS_Window_GetFocus())

--reaper.MB(tostring(A).."\n"..tostring(B).."\n"..reaper.JS_Window_GetTitle(C[1])..                                                reaper.JS_Window_GetTitle(C[2]).."\n","",0)
--                                              ..reaper.JS_Window_GetTitle(C[3]),"",0)


function ultraschall.GetReaperWindowAttributes()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetReaperWindowAttributes</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    JS=0.962
    Lua=5.3
  </requires>
  <functioncall>integer left, integer top, integer right, integer bottom, boolean active, boolean visible, string title, integer number_of_childhwnds, table childhwnds = ultraschall.GetReaperWindowAttributes()</functioncall>
  <description>
    returns many attributes of the Reaper Main-window, like position, size, active, visibility, childwindows
    
    A hwnd is a window-handler, which contains all attributes of a certain window.
    
    returns nil in case of an error
  </description>
  <parameters>
    HWND hwnd - the HWND, whose topmost parent-HWND you want to have
  </parameters>
  <retvals>
    integer left - the left position of the Reaper-window in pixels
    integer top - the top position of the Reaper-window in pixels
    integer right - the right position of the Reaper-window in pixels
    integer bottom - the bottom position of the Reaper-window in pixels
    boolean active - true, if the window is active(any child-hwnd of the Reaper-window has focus currently); false, if not
    boolean visible - true, Reaper-window is visible; false, Reaper-window is not visible
    string title - the current title of the Reaper-window
    integer number_of_childhwnds - the number of available child-hwnds that the Reaper-window currently has
    table childhwnds - a table with all child-hwnds in the following format:
                     -      childhwnds[index][1]=hwnd
                     -      childhwnds[index][2]=title
  </retvals>
  <chapter_context>
    User Interface
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>user interface, hwnd, reaper, main window, position, active, visible, child-hwnds</tags>
</US_DocBloc>
]]
  local hwnd=reaper.GetMainHwnd()
  local title = reaper.JS_Window_GetTitle(hwnd)
  local visible=reaper.JS_Window_IsVisible(hwnd)
  local num_child_windows, child_window_list = reaper.JS_Window_ListAllChild(hwnd)
  local childwindows={}
  local count, individual_values = ultraschall.CSV2IndividualLinesAsArray(child_window_list)
  for i=1, count do
    childwindows[i]={}
    childwindows[i][1]=reaper.JS_Window_HandleFromAddress(individual_values[i])
    childwindows[i][2]=reaper.JS_Window_GetTitle(childwindows[i][1])
  end
  
  local retval, left, top, right, bottom = reaper.JS_Window_GetRect(hwnd)

  local hwnd_temp=ultraschall.GetTopmostHWND(reaper.JS_Window_GetFocus())
  if hwnd_temp==hwnd then active=true else active=false end
  
  return left, top, right, bottom, active, visible, title, count, childwindows
end



--retval, number position, number pageSize, number min, number max, number trackPos = reaper.JS_Window_GetScrollInfo(identifier windowHWND, string scrollbar)

--A,B,C,D,E,F,G,H,I,J=ultraschall.GetReaperWindowAttributes()
--reaper.MB(tostring(A).." "..tostring(B).." "..tostring(C).." "..tostring(D).." "..tostring(E).." "..tostring(F).." "..tostring(G).." "..tostring(H).." "..tostring(I),"",0)

function ultraschall.ConvertIntegerToBits(integer)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ConvertIntegerToBits</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>string bitvals_csv, table bitvalues = ultraschall.ConvertIntegerToBits(integer integer)</functioncall>
  <description>
    converts an integer-value(up to 32 bits) into it's individual bits and returns it as comma-separated csv-string as well as a table with 32 entries.
    
    returns nil in case of an error
  </description>
  <parameters>
    integer integer - the integer-number to separated into it's individual bits
  </parameters>
  <retvals>
    string bitvals_csv - a comma-separated csv-string of all bitvalues, with bit 1 coming first and bit 32 coming last
    table bitvalues - a 32-entry table, where each entry contains the bit-value of integer; first entry for bit 1, 32th entry for bit 32
  </retvals>
  <chapter_context>
    API-Helper functions
    Data Manipulation
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, convert, integer, bit, bitfield</tags>
</US_DocBloc>
]]
  if math.type(integer)~="integer" then ultraschall.AddErrorMessage("ConvertIntegerToBits", "integer", "must be an integer-value up to 32 bits", -1) return nil end
  local bitarray={}
  local bitstring=""
  for i=0, 31 do
    O=i
    if integer&2^i==0 then bitarray[i+1]=0 else bitarray[i+1]=1 end
    bitstring=bitstring..bitarray[i+1]..","
  end
  return bitstring:sub(1,-1), bitarray
end

function ultraschall.ReverseEndianess_Byte(byte)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ReverseEndianess_Byte</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>integer newbyte = ultraschall.ReverseEndianess_Byte(integer byte)</functioncall>
  <description>
    reverses the endianess of a byte and returns this as value.
    The parameter byte must be between 0 and 255!
    
    returns nil in case of an error
  </description>
  <parameters>
    integer byte - the integer whose endianess you want to reverse
  </parameters>
  <retvals>
    integer newbyte - the endianess-reversed byte
  </retvals>
  <chapter_context>
    API-Helper functions
    Data Manipulation
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, convert, integer, endianess</tags>
</US_DocBloc>
]]
  if math.type(byte)~="integer" then ultraschall.AddErrorMessage("ReverseEndianess_Byte", "byte", "must be an integer", -1) return end
  if byte<0 or byte>255 then ultraschall.AddErrorMessage("ReverseEndianess_Byte", "byte", "must be between 0 and 255", -2) return end
  
  local newbyte=0
  if byte&1~=0 then newbyte=newbyte+128 end
  if byte&2~=0 then newbyte=newbyte+64 end
  if byte&4~=0 then newbyte=newbyte+32 end
  if byte&8~=0 then newbyte=newbyte+16 end
  if byte&16~=0 then newbyte=newbyte+8 end
  if byte&32~=0 then newbyte=newbyte+4 end
  if byte&64~=0 then newbyte=newbyte+2 end
  if byte&128~=0 then newbyte=newbyte+1 end
  return newbyte
end

ultraschall.ShowLastErrorMessage()



