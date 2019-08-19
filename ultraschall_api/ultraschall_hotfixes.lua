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
ultraschall.hotfixdate="14th_August_2019"

--ultraschall.ShowLastErrorMessage()

function ultraschall.GetUserInputs(title, caption_names, default_retvals, values_length, caption_length, x_pos, y_pos)
--TODO: when there are newlines in captions, count them and resize these captions automatically, as well as move down the following captions and inputfields, so they
--      match the captionheights, without interfering into each other.
--      will need resizing of the window as well and moving OK and Cancel-buttons
--      if a caption ends with a newline, it will get the full width of the window, with the input-field moving one down, getting full length as well

--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetUserInputs</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.980
    JS=0.986
    Lua=5.3
  </requires>
  <functioncall>boolean retval, integer number_of_inputfields, table returnvalues = ultraschall.GetUserInputs(string title, table caption_names, table default_retvals, optional integer values_length, optional integer caption_length, optional integer x_pos, optional integer y_pos)</functioncall>
  <description>
    Gets inputs from the user.
    
    The captions and the default-returnvalues must be passed as an integer-index table.
    e.g.
      caption_names[1]="first caption name"
      caption_names[2]="second caption name"
      caption_names[1]="*third caption name, which creates an inputfield for passwords, due the * at the beginning"
      
   The number of entries in the tables "caption_names" and "default_retvals" decide, how many inputfields are shown. Maximum is 16 inputfields.
   You can safely pass "" as entry for a name, if you don't want to set it.
      
      The following example shows an input-dialog with three fields, where the first two the have default-values:
      
        retval, number_of_inputfields, returnvalues = ultraschall.GetUserInputs("I am the title", {"first", "second", "third"}, {1,"two"})   
     
   Note: Don't use this function within defer-scripts or scripts that are started by defer-scripts, as this produces errors.
         This is due limitations in Reaper, sorry.

   returns false in case of an error.
  </description>
  <retvals>
    boolean retval - true, the user clicked ok on the userinput-window; false, the user clicked cancel or an error occured
    integer number_of_inputfields - the number of returned values; nil, in case of an error
    table returnvalues - the returnvalues input by the user as a table; nil, in case of an error
  </retvals>
  <parameters>
    string title - the title of the inputwindow
    table caption_names - a table with all inputfield-captions. All non-string-entries will be converted to string-entries. Begin an entry with a * for password-entry-fields.
                        - it can be up to 16 fields
                        - This dialog only allows limited caption-field-length, about 19-30 characters, depending on the size of the used characters.
                        - Don't enter nil as captionname, as this will be seen as end of the table by this function, omitting possible following captionnames!
    table default_retvals - a table with all default retvals. All non-string-entries will be converted to string-entries.
                          - it can be up to 16 fields
                          - Only enter nil as default-retval, if no further default-retvals are existing, otherwise use "" for empty retvals.
    optional integer values_length - the extralength of the values-inputfield. With that, you can enhance the length of the inputfields. 
                            - 1-500
    optional integer caption_length - the length of the caption in pixels; inputfields and OK, Cancel-buttons will be moved accordingly.
    optional integer x_pos - the x-position of the GetUserInputs-dialog; nil, to keep default position
    optional integer y_pos - the y-position of the GetUserInputs-dialog; nil, to keep default position
                           - keep in mind: on Mac, the y-position starts with 0 at the bottom, while on Windows and Linux, 0 starts at the top of the screen!
                           -               this is the standard-behavior of the operating-systems themselves.
  </parameters>
  <chapter_context>
    User Interface
    Dialogs
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>userinterface, dialog, get, user input</tags>
</US_DocBloc>
--]]
  local count33, autolength
  if type(title)~="string" then ultraschall.AddErrorMessage("GetUserInputs", "title", "must be a string", -1) return false end
  if type(caption_names)~="table" then ultraschall.AddErrorMessage("GetUserInputs", "caption_names", "must be a table", -2) return false end
  if type(default_retvals)~="table" then ultraschall.AddErrorMessage("GetUserInputs", "default_retvals", "must be a table", -3) return false end
  if values_length~=nil and math.type(values_length)~="integer" then ultraschall.AddErrorMessage("GetUserInputs", "values_length", "must be an integer", -4) return false end
  if values_length==nil then values_length=10 end
  if (values_length>500 or values_length<1) and values_length~=-1 then ultraschall.AddErrorMessage("GetUserInputs", "values_length", "must be between 1 and 500, or -1 for autolength", -5) return false end
  if values_length==-1 then values_length=1 autolength=true end
  local count = ultraschall.CountEntriesInTable_Main(caption_names)
  local count2 = ultraschall.CountEntriesInTable_Main(default_retvals)
  if count>16 then ultraschall.AddErrorMessage("GetUserInputs", "caption_names", "must be no more than 16 caption-names!", -5) return false end
  if count2>16 then ultraschall.AddErrorMessage("GetUserInputs", "default_retvals", "must be no more than 16 default-retvals!", -6) return false end
  if count2>count then count33=count2 else count33=count end
  values_length=(values_length*2)+18
 
  if x_pos~=nil and math.type(x_pos)~="integer" then ultraschall.AddErrorMessage("GetUserInputs", "x_pos", "must be an integer or nil!", -7) return false end
  if y_pos~=nil and math.type(y_pos)~="integer" then ultraschall.AddErrorMessage("GetUserInputs", "y_pos", "must be an integer or nil!", -8) return false end
  if x_pos==nil then x_pos="keep" end
  if y_pos==nil then y_pos="keep" end
  
  if caption_length~=nil and math.type(caption_length)~="integer" then ultraschall.AddErrorMessage("GetUserInputs", "caption_length", "must be an integer or nil!", -9) return false end
  if caption_length==nil then caption_length="keep" end
  
  local captions=""
  local retvals=""  
  
  for i=1, count2 do
    if default_retvals[i]==nil then default_retvals[i]="" end
    retvals=retvals..tostring(default_retvals[i])..","
    if autolength==true and values_length<tostring(default_retvals[i]):len() then values_length=(tostring(default_retvals[i]):len()*6.6)+18 end
  end
  retvals=retvals:sub(1,-2)  
  
  for i=1, count do
    if caption_names[i]==nil then caption_names[i]="" end
    captions=captions..tostring(caption_names[i])..","
    --if autolength==true and length<tostring(caption_names[i]):len()+length then length=(tostring(caption_names[i]):len()*16.6)+18+length end
  end
  captions=captions:sub(1,-2)
  if count<count2 then
    for i=count, count2 do
      captions=captions..","
    end
  end
  captions=captions..",extrawidth="..values_length
  
  --print2(captions)
  -- fill up empty caption-names, so the passed parameters are 16 in count
  for i=1, 16 do
    if caption_names[i]==nil then
      caption_names[i]=""
    end
  end
  caption_names[17]=nil

  -- fill up empty default-values, so the passed parameters are 16 in count  
  local default_retvals2={}
  for i=1, 16 do
    if default_retvals[i]==nil then
      default_retvals2[i]=""
    else
      default_retvals2[i]=default_retvals[i]
    end
  end
  default_retvals2[17]=nil

  local numentries, concatenated_table = ultraschall.ConcatIntegerIndexedTables(caption_names, default_retvals2)
  
  local temptitle="Tudelu"..reaper.genGuid()
  
  ultraschall.Main_OnCommandByFilename(ultraschall.Api_Path.."/Scripts/GetUserInputValues_Helper_Script.lua", temptitle, title, 3, x_pos, y_pos, caption_length, "Tudelu", table.unpack(concatenated_table))

  local retval, retvalcsv = reaper.GetUserInputs(temptitle, count33, captions, "")
  if retval==false then reaper.DeleteExtState(ultraschall.ScriptIdentifier, "values", false) return false end
  local Values=reaper.GetExtState(ultraschall.ScriptIdentifier, "values")
  --print2(Values)
  reaper.DeleteExtState(ultraschall.ScriptIdentifier, "values", false)
  local count2,Values=ultraschall.CSV2IndividualLinesAsArray(Values ,"\n")
  for i=count+1, 17 do
    Values[i]=nil
  end
  return retval, count33, Values
end

--A,B,C,D=ultraschall.GetUserInputs("I got you", {"ShalalalaOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOHAH"}, {"HHHAAAAHHHHHHHHHHHHHHHHHHHHHHHHAHHHHHHHA"}, -1)

function ultraschall.CountUSExternalState_sec()
--count number of sections in the ultraschall.ini
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CountUSExternalState_sec</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer section_count = ultraschall.CountUSExternalState_sec()</functioncall>
  <description>
    returns the number of [sections] in the ultraschall.ini
  </description>
  <retvals>
    integer section_count  - the number of section in the ultraschall.ini
  </retvals>
  <chapter_context>
    Ultraschall Specific
    Ultraschall.ini
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configurationmanagement, count, section</tags>
</US_DocBloc>

--]]
  -- check existence of ultraschall.ini
  if reaper.file_exists(reaper.GetResourcePath()..ultraschall.Separator.."ultraschall.ini")==false then ultraschall.AddErrorMessage("CountUSExternalState_sec","", "ultraschall.ini does not exist", -1) return -1 end
  
  -- count external-states
  local count=0
  for line in io.lines(reaper.GetResourcePath()..ultraschall.Separator.."ultraschall.ini") do
    --local check=line:match(".*=.*")
    check=line:match("%[.*.%]")
    if check~=nil then check="" count=count+1 end
  end
  return count
end

function ultraschall.CountIniFileExternalState_sec(ini_filename_with_path)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CountIniFileExternalState_sec</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    SWS=2.8.8
    Lua=5.3
  </requires>
  <functioncall>integer sectioncount = ultraschall.CountIniFileExternalState_sec(string ini_filename_with_path)</functioncall>
  <description>
    Count external-state-[sections] from an ini-configurationsfile.
    
    Returns -1, if the file does not exist.
  </description>
  <retvals>
    integer sectioncount - number of sections within an ini-configuration-file
  </retvals>
  <parameters>
    string ini_filename_with_path - filename of the ini-file
  </parameters>
  <chapter_context>
    Configuration-Files Management
    Ini-Files
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configurationmanagement, count, sections, ini-files</tags>
</US_DocBloc>
]]
  if reaper.file_exists(ini_filename_with_path)==false then ultraschall.AddErrorMessage("CountIniFileExternalState_sec", "ini_filename_with_path", "File does not exist.", -1) return -1 end
  local count=0
  
  for line in io.lines(ini_filename_with_path) do
    --local check=line:match(".*=.*")
    check=line:match("%[.*.%]")
    if check~=nil then check="" count=count+1 end
  end
  return count
end

function ultraschall.EnumerateIniFileExternalState_sec(number_of_section, ini_filename_with_path)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>EnumerateIniFileExternalState_sec</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    SWS=2.8.8
    Lua=5.3
  </requires>
  <functioncall>string sectionname = ultraschall.EnumerateIniFileExternalState_sec(integer number_of_section, string ini_filename_with_path)</functioncall>
  <description>
    Returns the numberth section in an ini_filename_with_path.
    
    Returns nil, in case of an error.
  </description>
  <retvals>
    string sectionname - the name of the numberth section in the ini-file
  </retvals>
  <parameters>
    integer number_of_section - the section within the ini-filename; 1, for the first section
    string ini_filename_with_path - filename of the ini-file
  </parameters>
  <chapter_context>
    Configuration-Files Management
    Ini-Files
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configurationmanagement, get, section, enumerate, ini-files</tags>
</US_DocBloc>
]]
  if math.type(number_of_section)~="integer" then ultraschall.AddErrorMessage("EnumerateIniFileExternalState_sec", "number_of_section", "Must be an integer.", -1) return nil end
  if type(ini_filename_with_path)~="string" then ultraschall.AddErrorMessage("EnumerateIniFileExternalState_sec", "ini_filename_with_path", "Must be a string.", -2) return nil end

  if reaper.file_exists(ini_filename_with_path)==false then ultraschall.AddErrorMessage("EnumerateIniFileExternalState_sec", "ini_filename_with_path", "File does not exist.", -3) return nil end
  
  if number_of_section<=0 then ultraschall.AddErrorMessage("EnumerateIniFileExternalState_sec", "ini_filename_with_path", "No such section.", -4) return nil end
  if number_of_section>ultraschall.CountIniFileExternalState_sec(ini_filename_with_path) then ultraschall.AddErrorMessage("EnumerateIniFileExternalState_sec", "ini_filename_with_path", "No such section.", -5) return nil end
  
  local count=0
  for line in io.lines(ini_filename_with_path) do
    --local check=line:match(".*=.*")
    check=line:match("%[.*.%]")
    if check==nil then count=count+1 end
    if count==number_of_section then return line:sub(2,-2) end
  end
end


function ultraschall.CountUSExternalState_key(section)
--count number of keys in the section in ultraschall.ini
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CountUSExternalState_key</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer key_count = ultraschall.CountUSExternalState_key(string section)</functioncall>
  <description>
    returns the number of keys in the given [section] in ultraschall.ini
    
    returns -1 in case of an error
  </description>
  <retvals>
    integer key_count  - the number of keys within an ultraschall.ini-section
  </retvals>
  <parameters>
    string section - the section of the ultraschall.ini, of which you want the number of keys.
  </parameters>
  <chapter_context>
    Ultraschall Specific
    Ultraschall.ini
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configurationmanagement, count, key</tags>
</US_DocBloc>
--]]
  -- check parameter and existence of ultraschall.ini
  if type(section)~="string" then ultraschall.AddErrorMessage("CountUSExternalState_key","section", "only string allowed", -1) return -1 end
  if reaper.file_exists(reaper.GetResourcePath()..ultraschall.Separator.."ultraschall.ini")==false then ultraschall.AddErrorMessage("CountUSExternalState_key","", "ultraschall.ini does not exist", -2) return -1 end

  -- prepare variables
  local count=0
  local startcount=0
  
  -- count keys
  for line in io.lines(reaper.GetResourcePath()..ultraschall.Separator.."ultraschall.ini") do
   local check=line:match("%[.*.%]")
    if startcount==1 and line:match(".*=.*") then
      count=count+1
    else
      startcount=0
    if "["..section.."]" == check then startcount=1 end
    if check==nil then check="" end
    end
  end
  
  return count
end

--A=ultraschall.CountUSExternalState_key("view")

function ultraschall.EnumerateUSExternalState_sec(number)
-- returns name of the numberth section in ultraschall.ini or nil, if invalid
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>EnumerateUSExternalState_sec</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string section_name = ultraschall.EnumerateUSExternalState_sec(integer number)</functioncall>
  <description>
    returns name of the numberth section in ultraschall.ini or nil if invalid
  </description>
  <retvals>
    string section_name  - the name of the numberth section within ultraschall.ini
  </retvals>
  <parameters>
    integer number - the number of section, whose name you want to know
  </parameters>
  <chapter_context>
    Ultraschall Specific
    Ultraschall.ini
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configurationmanagement, enumerate, section</tags>
</US_DocBloc>
--]]
  -- check parameter and existence of ultraschall.ini
  if math.type(number)~="integer" then ultraschall.AddErrorMessage("EnumerateUSExternalState_sec", "number", "only integer allowed", -1) return nil end
  if reaper.file_exists(reaper.GetResourcePath()..ultraschall.Separator.."ultraschall.ini")==false then ultraschall.AddErrorMessage("EnumerateUSExternalState_sec", "", "ultraschall.ini does not exist", -2) return nil end

  if number<=0 then ultraschall.AddErrorMessage("EnumerateUSExternalState_sec","number", "no negative number allowed", -3) return nil end
  if number>ultraschall.CountUSExternalState_sec() then ultraschall.AddErrorMessage("EnumerateUSExternalState_sec","number", "only "..ultraschall.CountUSExternalState_sec().." sections available", -4) return nil end

  -- look for and return the requested line
  local count=0
  for line in io.lines(reaper.GetResourcePath()..ultraschall.Separator.."ultraschall.ini") do
    check=line:match("%[.-%]")
    if check~=nil then count=count+1 end
    if count==number then return line end
  end
end

--A=ultraschall.EnumerateUSExternalState_sec(10)

function ultraschall.EnumerateUSExternalState_key(section, number)
-- returns name of a numberth key within a section in ultraschall.ini or nil if invalid or not existing
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>EnumerateUSExternalState_key</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string key_name = ultraschall.EnumerateUSExternalState_key(string section, integer number)</functioncall>
  <description>
    returns name of a numberth key within a section in ultraschall.ini or nil if invalid or not existing
  </description>
  <retvals>
    string key_name  - the name ob the numberth key in ultraschall.ini.
  </retvals>
  <parameters>
    string section - the section within ultraschall.ini, where the key is stored.
    integer number - the number of the key, whose name you want to know; 1 for the first one
  </parameters>
  <chapter_context>
    Ultraschall Specific
    Ultraschall.ini
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configurationmanagement, enumerate, key</tags>
</US_DocBloc>
--]]
  -- check parameter
  if type(section)~="string" then ultraschall.AddErrorMessage("EnumerateUSExternalState_key", "section", "only string allowed", -1) return nil end
  if math.type(number)~="integer" then ultraschall.AddErrorMessage("EnumerateUSExternalState_key", "number", "only integer allowed", -2) return nil end

  -- prepare variables
  local count=0
  local startcount=0
  
  -- find and return the proper line
  for line in io.lines(reaper.GetResourcePath()..ultraschall.Separator.."ultraschall.ini") do
    local check=line:match("%[.*.%]")
    if startcount==1 and line:match(".*=.*") then
      count=count+1
      if count==number then local temp=line:match(".*=") return temp:sub(1,-2) end
    else
      startcount=0
      if "["..section.."]" == check then startcount=1 end
      if check==nil then check="" end
    end
  end
  return nil
end

function ultraschall.SetIniFileExternalState(section, key, value, ini_filename_with_path)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetIniFileExternalState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetIniFileExternalState(string section, string key, string value, string ini_filename_with_path)</functioncall>
  <description>
    Sets an external state into ini_filename_with_path. Returns false, if it doesn't work.
  </description>
  <retvals>
    boolean retval - true, if setting the state was successful; false, if setting was unsuccessful
  </retvals>
  <parameters>
    string section - section of the external state. No = allowed!
    string key - key of the external state. No = allowed!
    string value - value for the key
    string filename_with_path - filename of the ini-file
  </parameters>
  <chapter_context>
    Configuration-Files Management
    Ini-Files
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configurationmanagement, set, external state, value, ini-files</tags>
</US_DocBloc>
]]
  if type(section)~="string" then ultraschall.AddErrorMessage("SetIniFileExternalState", "section", "must be a string.", -1) return false end
  if type(key)~="string" then ultraschall.AddErrorMessage("SetIniFileExternalState", "key", "must be a string.", -2) return false end
  if type(value)~="string" then ultraschall.AddErrorMessage("SetIniFileExternalState", "value", "must be a string.", -3) return false end
  if type(ini_filename_with_path)~="string" then ultraschall.AddErrorMessage("SetIniFileExternalState", "ini_filename_with_path", "must be a string.", -4) return false end
  if reaper.file_exists(ini_filename_with_path)==false then ultraschall.AddErrorMessage("SetIniFileExternalState", "ini_filename_with_path", "file can't be accessed.", -5) return false end
  if section:match(".*%=.*") then ultraschall.AddErrorMessage("SetIniFileExternalState", "section", "= is not allowed in section", -6) return false end
  if key:match(".*%=.*") then ultraschall.AddErrorMessage("SetIniFileExternalState", "key", "= is not allowed in key.", -7) return false end

  return ultraschall.SetIniFileValue(section, key, value, ini_filename_with_path)
end

function ultraschall.EnumerateSectionsByPattern(pattern, id, ini_filename_with_path)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>EnumerateSectionsByPattern</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    SWS=2.8.8
    Lua=5.3
  </requires>
  <functioncall>string sectionname = ultraschall.EnumerateSectionsByPattern(string pattern, integer id, string ini_filename_with_path)</functioncall>
  <description>
    Returns the numberth section within an ini-file, that fits the pattern, e.g. the third section containing "hawaii" in it.
    
    Uses "pattern"-string to determine if a section contains a certain pattern. Good for sections, that have a number in them, like section1, section2, section3
    Returns the section that includes that pattern as a string, numbered by id.
    
    Pattern can also contain patterns for pattern matching. Refer the LUA-docs for pattern matching.
    i.e. characters like ^$()%.[]*+-? must be escaped with a %, means: %[%]%(%) etc
    
    Returns nil, in case of an error.
  </description>
  <retvals>
    string sectionname - a string, that contains the sectionname
  </retvals>
  <parameters>
    string pattern - the pattern itself. Case sensitive.
    integer id - the number of section, that contains pattern
    string ini_filename_with_path - filename of the ini-file
  </parameters>
  <chapter_context>
    Configuration-Files Management
    Ini-Files
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configurationmanagement, enumerate, section, pattern, get, ini-files</tags>
</US_DocBloc>
]]
  if type(pattern)~="string" then ultraschall.AddErrorMessage("EnumerateSectionsByPattern", "pattern", "must be a string", -1) return end
  if ini_filename_with_path==nil then ultraschall.AddErrorMessage("EnumerateSectionsByPattern", "ini_filename_with_path", "must be a string", -2) return end
  if reaper.file_exists(ini_filename_with_path)==false then ultraschall.AddErrorMessage("EnumerateSectionsByPattern", "ini_filename_with_path", "file does not exist", -3) return end
  if math.type(id)~="integer" then ultraschall.AddErrorMessage("EnumerateSectionsByPattern", "id", "must be an integer", -4) return end
  if ultraschall.IsValidMatchingPattern(pattern)==false then ultraschall.AddErrorMessage("EnumerateSectionsByPattern", "pattern", "malformed pattern", -5) return end
  
  local count=0
  for line in io.lines(ini_filename_with_path) do
    if line:match("%[.*"..pattern..".*%]") then count=count+1 end
    if count==id then return line:match("%[(.*"..pattern..".*)%]") end
  end
  return nil
end

function ultraschall.EnumerateKeysByPattern(pattern, section, id, ini_filename_with_path)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>EnumerateKeysByPattern</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    SWS=2.8.8
    Lua=5.3
  </requires>
  <functioncall>string keyname = ultraschall.EnumerateKeysByPattern(string pattern, string section, integer id, string ini_filename_with_path)</functioncall>
  <description>
    Returns the numberth key within a section in an ini-file, that fits the pattern, e.g. the third key containing "hawaii" in it.
    
    Uses "pattern"-string to determine if a key contains a certain pattern. Good for keys, that have a number in them, like key1=, key2=, key3=
    Returns the key that includes that pattern as a string, numbered by id.
    
    Pattern can also contain patterns for pattern matching. Refer the LUA-docs for pattern matching.
    i.e. characters like ^$()%.[]*+-? must be escaped with a %, means: %[%]%(%) etc
    
    Returns nil, in case of an error.
  </description>
  <retvals>
    string keyname - a string, that contains the keyname
  </retvals>
  <parameters>
    string pattern - the pattern itself. Case sensitive.
    string section - the section, in which to look for the key
    integer id - the number of key, that contains pattern
    string ini_filename_with_path - filename of the ini-file
  </parameters>
  <chapter_context>
    Configuration-Files Management
    Ini-Files
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configurationmanagement, ini-files, enumerate, section, key, pattern, get</tags>
</US_DocBloc>
]]
  if type(pattern)~="string" then ultraschall.AddErrorMessage("EnumerateKeysByPattern", "pattern", "must be a string", -1) return end
  if ini_filename_with_path==nil then ultraschall.AddErrorMessage("EnumerateKeysByPattern", "ini_filename_with_path", "must be a string", -2) return end
  if reaper.file_exists(ini_filename_with_path)==false then ultraschall.AddErrorMessage("EnumerateKeysByPattern", "ini_filename_with_path", "file does not exist", -3) return end
  if math.type(id)~="integer" then ultraschall.AddErrorMessage("EnumerateKeysByPattern", "id", "must be an integer", -4) return end
  if ultraschall.IsValidMatchingPattern(pattern)==false then ultraschall.AddErrorMessage("EnumerateKeysByPattern", "pattern", "malformed pattern", -5) return end
  
  local count=0
  local tiff=0
  local temppattern=nil
  for line in io.lines(ini_filename_with_path) do
    if tiff==1 and line:match("%[.*%]")~=nil then return nil end
    if line:match(section) then temppattern=line tiff=1 end
    if tiff==1 and line:match(pattern..".*=") then count=count+1 
        if count==id then return line:match("(.*"..pattern..".*)=") end
    end
  end
end

function ultraschall.EnumerateValuesByPattern(pattern, section, id, ini_filename_with_path)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>EnumerateValuesByPattern</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    SWS=2.8.8
    Lua=5.3
  </requires>
  <functioncall>string value, string keyname = ultraschall.EnumerateValuesByPattern(string pattern, string section, string id, string ini_filename_with_path)</functioncall>
  <description>
    Returns the numberth value(and it's accompanying key) within a section in an ini-file, that fits the pattern, e.g. the third value containing "hawaii" in it.
    
    Uses "pattern"-string to determine if a value contains a certain pattern. Good for values, that have a number in them, like value1, value2, value3
    Returns the value that includes that pattern as a string, numbered by id, as well as it's accompanying key.
    
    Pattern can also contain patterns for pattern matching. Refer the LUA-docs for pattern matching.
    i.e. characters like ^$()%.[]*+-? must be escaped with a %, means: %[%]%(%) etc
    
    Returns nil, in case of an error.
  </description>
  <retvals>
    string value - the value that contains the pattern
    string keyname - a string, that contains the keyname
  </retvals>
  <parameters>
    string pattern - the pattern itself. Case sensitive.
    string section - the section, in which to look for the key
    integer id - the number of key, that contains pattern
    string ini_filename_with_path - filename of the ini-file
  </parameters>
  <chapter_context>
    Configuration-Files Management
    Ini-Files
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configurationmanagement, ini-files, enumerate, section, key, value, pattern, get</tags>
</US_DocBloc>
]]
  if type(pattern)~="string" then ultraschall.AddErrorMessage("EnumerateValuesByPattern", "pattern", "must be a string", -1) return end
  if ini_filename_with_path==nil then ultraschall.AddErrorMessage("EnumerateValuesByPattern", "ini_filename_with_path", "must be a string", -2) return end
  if reaper.file_exists(ini_filename_with_path)==false then ultraschall.AddErrorMessage("EnumerateValuesByPattern", "ini_filename_with_path", "file does not exist", -3) return end
  if math.type(id)~="integer" then ultraschall.AddErrorMessage("EnumerateValuesByPattern", "id", "must be an integer", -4) return end
  if ultraschall.IsValidMatchingPattern(pattern)==false then ultraschall.AddErrorMessage("EnumerateValuesByPattern", "pattern", "malformed pattern", -5) return end
  
  local count=0
  local tiff=0
  local temppattern=nil
  for line in io.lines(ini_filename_with_path) do
    if tiff==1 and line:match("%[.*%]")~=nil then return nil end
    if line:match(section) then temppattern=line tiff=1 end
    if tiff==1 and line:match("=.*"..pattern..".*") then count=count+1 
        if count==id then return line:match("=(.*"..pattern..".*)"), line:match("(.*)=.*"..pattern..".*") end
    end
  end
end

function ultraschall.DeleteKBIniActions(filename_with_path, idx)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DeleteKBIniActions</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.DeleteKBIniActions(string filename_with_path, integer idx)</functioncall>
  <description>
    Deletes an "ACT"-action of a reaper-kb.ini.
    Returns true/false when deleting worked/didn't work.
    
    Needs a restart of Reaper for this change to take effect!
  </description>
  <parameters>
    string filename_with_path - filename with path for the reaper-kb.ini
    integer idx - indexnumber of the action within the reaper-kb.ini
  </parameters>
  <retvals>
    boolean retval - true, if deleting worked, false if it didn't
  </retvals>
  <chapter_context>
    Configuration-Files Management
    Reaper-kb.ini
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configurationmanagement, reaper-kb.ini, kb.ini, keybindings, delete, action, actions</tags>
</US_DocBloc>
]]  
  if type(filename_with_path)~="string" then ultraschall.AddErrorMessage("DeleteKBIniActions", "filename_with_path", "must be a string", -1) return false end
  if reaper.file_exists(filename_with_path)==false then ultraschall.AddErrorMessage("DeleteKBIniActions", "filename_with_path", "file does not exist", -2) return false end
  if math.type(idx)~="integer" then ultraschall.AddErrorMessage("DeleteKBIniActions", "idx", "must be an integer", -3) return false end
  
  local count=0
  local linecount=0
  local finallinecount=-1
  if reaper.file_exists(filename_with_path)==false then return false end
  for line in io.lines(filename_with_path) do 
    linecount=linecount+1
    if line:sub(1,3)=="ACT" then 
      count=count+1
      if count==idx then finallinecount=linecount end
    end
  end
  if finallinecount>-1 then 
    local FirstPart=ultraschall.ReadLinerangeFromFile(filename_with_path, 1, finallinecount-1)
    local LastPart=ultraschall.ReadLinerangeFromFile(filename_with_path, finallinecount+1,  ultraschall.CountLinesInFile(filename_with_path))
    ultraschall.WriteValueToFile(filename_with_path,FirstPart..LastPart)
    return true
  else 
    return false
  end
end

function ultraschall.DeleteKBIniScripts(filename_with_path, idx)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DeleteKBIniScripts</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.DeleteKBIniScripts(string filename_with_path, integer idx)</functioncall>
  <description>
    Deletes an "SCR"-script of a reaper-kb.ini.
    Returns true/false when deleting worked/didn't work.
    
    Needs a restart of Reaper for this change to take effect!
  </description>
  <parameters>
    string filename_with_path - filename with path for the reaper-kb.ini
    integer idx - indexnumber of the script within the reaper-kb.ini
  </parameters>
  <retvals>
    boolean retval - true, if deleting worked, false if it didn't
  </retvals>
  <chapter_context>
    Configuration-Files Management
    Reaper-kb.ini
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>configurationmanagement, reaper-kb.ini, kb.ini, keybindings, delete, script, scripts</tags>
</US_DocBloc>
]]
  if type(filename_with_path)~="string" then ultraschall.AddErrorMessage("DeleteKBIniScripts", "filename_with_path", "must be a string", -1) return false end
  if reaper.file_exists(filename_with_path)==false then ultraschall.AddErrorMessage("DeleteKBIniScripts", "filename_with_path", "file does not exist", -2) return false end
  if math.type(idx)~="integer" then ultraschall.AddErrorMessage("DeleteKBIniScripts", "idx", "must be an integer", -3) return false end
  
  local count=0
  local linecount=0
  local finallinecount=-1
  if reaper.file_exists(filename_with_path)==false then return false end
  for line in io.lines(filename_with_path) do 
  linecount=linecount+1
    if line:sub(1,3)=="SCR" then 
      count=count+1
      if count==idx then finallinecount=linecount end
    end
  end
  if finallinecount>-1 then 
    local FirstPart=ultraschall.ReadLinerangeFromFile(filename_with_path, 1, finallinecount-1)
    local LastPart=ultraschall.ReadLinerangeFromFile(filename_with_path, finallinecount+1,  ultraschall.CountLinesInFile(filename_with_path))
    ultraschall.WriteValueToFile(filename_with_path,FirstPart..LastPart)
    return true
  else 
    return false
  end
end


function ultraschall.IsItemInTrack(tracknumber, itemIDX)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsItemInTrack</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.IsItemInTrack(integer tracknumber, integer itemIDX)</functioncall>
  <description>
    checks, whether a given item is part of the track tracknumber
    
    returns true, if the itemIDX is part of track tracknumber, false if not, nil if no such itemIDX or Tracknumber available
  </description>
  <retvals>
    boolean retval - true, if item is in track, false if item isn't in track
  </retvals>
  <parameters>
    integer itemIDX - the number of the item to check of
    integer tracknumber - the number of the track to check in, with 1 for track 1, 2 for track 2, etc.
  </parameters>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>itemmanagement,item,track,existence</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("IsItemInTrack","tracknumber", "only integer is allowed", -1) return nil end
  if math.type(itemIDX)~="integer" then ultraschall.AddErrorMessage("IsItemInTrack","itemIDX", "only integer is allowed", -2) return nil end
  
  if tracknumber>reaper.CountTracks(0) or tracknumber<0 then ultraschall.AddErrorMessage("IsItemInTrack","tracknumber", "no such track in this project", -3) return nil end
  if itemIDX>reaper.CountMediaItems(0)-1 or itemIDX<0 then ultraschall.AddErrorMessage("IsItemInTrack","itemIDX", "no such item in this project", -4) return nil end
  
  -- Get the tracks and items
  local MediaTrack=reaper.GetTrack(0, tracknumber-1) 
  local MediaItem=reaper.GetMediaItem(0, itemIDX)
  local MediaTrack2=reaper.GetMediaItem_Track(MediaItem)
  
  -- check and return
  if MediaTrack==MediaTrack2 then return true 
  else return false
  end  
end


function ultraschall.ToggleStateAction(section, actioncommand_id, state)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ToggleStateAction</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval = ultraschall.ToggleStateAction(integer section, string actioncommand_id, integer state)</functioncall>
  <description>
    Toggles state of an action using the actioncommand_id(instead of the CommandID-number)
    
    returns current state of the action after toggling or -1 in case of error.
  </description>
  <retvals>
    integer retval  - state if the action, after it has been toggled
  </retvals>
  <parameters>
    integer section - the section of the action(see ShowActionlist-dialog)
                            -0 - Main
                            -100 - Main (alt recording)
                            -32060 - MIDI Editor
                            -32061 - MIDI Event List Editor
                            -32062 - MIDI Inline Editor
                            -32063 - Media Explorer
    string actioncommand_id - the ActionCommandID of the action to toggle
    integer state - 1 or 0
  </parameters>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>command,commandid,actioncommandid,action,run,state,section</tags>
</US_DocBloc>
--]]
  -- check parameters
  if actioncommand_id==nil then ultraschall.AddErrorMessage("ToggleStateAction", "action_command_id", "must be a number or a string", -1) return -1 end
  if math.type(state)~="integer" then ultraschall.AddErrorMessage("ToggleStateAction", "state", "must be an integer", -2) return -1 end
  if math.type(section)~="integer" then ultraschall.AddErrorMessage("ToggleStateAction", "section", "must be an integer", -3) return -1 end
  
  -- do the toggling
  local command_id = reaper.NamedCommandLookup(actioncommand_id)
  reaper.SetToggleCommandState(section, command_id, state)
  return reaper.GetToggleCommandState(command_id)
end


function ultraschall.SetIntConfigVar_Bitfield(configvar, set_to, ...)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetIntConfigVar_Bitfield</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    SWS=2.9.7
    Lua=5.3
  </requires>
  <functioncall>boolean retval, integer new_integer_bitfield = ultraschall.SetIntConfigVar_Bitfield(string configvar, boolean set_to, integer bit_1, integer bit_2, ... integer bit_n)</functioncall>
  <description>
    Alters an integer-bitfield stored by a ConfigVariable.
    
    Returns false in case of error, like invalid bit-values, etc
  </description>
  <parameters>
    string configvar - the config-variable, that is stored as an integer-bitfield, that you want to alter.
    boolean set_to - true, set the bits to 1; false, set the bits to 0; nil, toggle the bits
    integer bit1..n - one or more parameters, that include the bitvalues toset/unset/toggle with 1 for the first bit; 2 for the second, 4 for the third, 8 for the fourth, etc
  </parameters>
  <retvals>
    boolean retval - true, if altering was successful; false, if not successful
    integer new_integer_bitfield - the newly altered bitfield
  </retvals>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, bitfield, set, unset, toggle, configvar</tags>
</US_DocBloc>
--]]
  local integer_bitfield=reaper.SNM_GetIntConfigVar(configvar, -22)
  local integer_bitfield2=reaper.SNM_GetIntConfigVar(configvar, -23)
  if type(configvar)~="string" then ultraschall.AddErrorMessage("SetIntConfigVar_Bitfield","configvar", "Must be a string!", -1) return false end
  if integer_bitfield==-22 and integer_bitfield2==-23 then ultraschall.AddErrorMessage("SetIntConfigVar_Bitfield","configvar", "No valid config-variable!", -2) return false end
  
  -- check parameters
  if set_to~=nil and type(set_to)~="boolean" then ultraschall.AddErrorMessage("SetIntConfigVar_Bitfield","set_to", "Must be a boolean!", -3) return false end
  local Parameters={...}
  local count=1
  while Parameters[count]~=nil do
    -- check the bit-parameters
    if math.log(Parameters[count],2)~=math.floor(math.log(Parameters[count],2)) then ultraschall.AddErrorMessage("SetIntConfigVar_Bitfield","bit", "Bit_"..count.."="..Parameters[count].." isn't a valid bitvalue!", -4) return false end
    count=count+1
  end
  
  -- Now let's set or unset the bitvalues
  count=1
  while Parameters[count]~=nil do
    if set_to==true and integer_bitfield&Parameters[count]==0 then 
      -- setting the bits
      integer_bitfield=integer_bitfield+Parameters[count] 
    elseif set_to==false and integer_bitfield&Parameters[count]~=0 then 
      -- unsetting the bits
      integer_bitfield=integer_bitfield-Parameters[count]
    elseif set_to==nil then
      -- toggling the bits
      if integer_bitfield&Parameters[count]==0 then 
        integer_bitfield=integer_bitfield+Parameters[count] 
      elseif integer_bitfield&Parameters[count]~=0 then 
        integer_bitfield=integer_bitfield-Parameters[count] 
      end
    end
    count=count+1
  end
  return reaper.SNM_SetIntConfigVar(configvar, integer_bitfield), integer_bitfield
end


function ultraschall.CompareStringWithAsciiValues(string,...)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CompareStringWithAsciiValues</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, integer errorposition = ultraschall.CompareStringWithAsciiValues(string string, integer bytevalue_1, integer bytevalue_2, ... integer bytevalue_n)</functioncall>
  <description>
    Compares a string with a number of byte-values(like ASCII-values).
    Bytevalues can be either decimal and hexadecimal.
    -1, if you want to skip checking of a specific position in string.
    
    Returns false in case of error
  </description>
  <parameters>
    string string - the string to check against the bytevalues
    integer bytevalue_1..n - one or more parameters, that include the bytevalues to check against the accompanying byte in string; -1, if you want to skip check for that position
  </parameters>
  <retvals>
    boolean retval - true, if check was successful; false, if not successful
    integer errorposition - if retval is false, this will contain the position in string, where the checking failed; nil, if retval is true
  </retvals>
  <chapter_context>
    API-Helper functions
    Data Manipulation
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, check, compare, string, byte, bytevalues</tags>
</US_DocBloc>
--]]
  if type(string)~="string" then ultraschall.AddErrorMessage("CompareStringWithAsciiValues","string", "Must be a string!", -1) return false end  
  local length, Table=ultraschall.ConvertStringToAscii_Array(string)
  local AsciiValues={...}
  local NumEntries=ultraschall.CountEntriesInTable_Main(AsciiValues)
  local count=1  
  local retval=true
  while AsciiValues[count]~=nil do
    if AsciiValues[count]==-1 then 
    elseif Table[count][2]~=AsciiValues[count] then retval=false break end
    count=count+1
  end
  if count-1==NumEntries then count=nil end
  return retval, count
end

function ultraschall.GetScriptFilenameFromActionCommandID(action_command_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetScriptFilenameFromActionCommandID</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    SWS=2.9.7
    Lua=5.3
  </requires>
  <functioncall>string scriptfilename_with_path = ultraschall.GetScriptFilenameFromActionCommandID(string action_command_id)</functioncall>
  <description>
    returns the filename with path of a script, associated to a ReaScript.
    Command-ID-numbers do not work!
                            
    returns false in case of an error
  </description>
  <parameters>
    string Path - the path to set as new current working directory
  </parameters>
  <retvals>
    string scriptfilename_with_path - the scriptfilename with path associated with this ActionCommandID
  </retvals>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>filemanagement, get, scriptfilename, actioncommandid</tags>
</US_DocBloc>
]]
  if ultraschall.type(action_command_id)~="string" then ultraschall.AddErrorMessage("GetScriptFilenameFromActionCommandID", "action_command_id", "must be a string", -1) return false end
  if ultraschall.CheckActionCommandIDFormat2(action_command_id)==false then ultraschall.AddErrorMessage("GetScriptFilenameFromActionCommandID", "action_command_id", "no such action-command-id", -2) return false end
  local kb_ini_path = ultraschall.GetKBIniFilepath()
  local kb_ini_file = ultraschall.ReadFullFile(kb_ini_path)
  if action_command_id:sub(1,1)=="_" then action_command_id=action_command_id:sub(2,-1) end
  local L=kb_ini_file:match("( "..action_command_id..".-)\n")
  if L==nil then ultraschall.AddErrorMessage("GetScriptFilenameFromActionCommandID", "action_command_id", "no such action_command_id associated to a script", -1) return false end
  L=L:match(".*%s(.*)")
  if L:sub(1,2)==".." then return reaper.GetResourcePath().."/"..L end
  return L
end

function ultraschall.ConvertIntegerIntoString2(Size, ...)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ConvertIntegerIntoString2</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>string converted_value = ultraschall.ConvertIntegerIntoString2(integer Size, integer integervalue_1, ..., integer integervalue_n)</functioncall>
  <description>
    Splits numerous integers into its individual bytes and converts them into a string-representation.
    Maximum 32bit-integers are supported.
    
    Returns nil in case of an error.
  </description>
  <parameters>
    integer Size - the maximum size of the integer to convert, 1(8 bit) to 4(32 bit)
    integer integervalue_1 - the first integer value to convert from
    ... - 
    integer integervalue_n - the last integer value to convert from
  </parameters>
  <retvals>
    string converted_value - the string-representation of the integer
  </retvals>
  <chapter_context>
    API-Helper functions
    Data Manipulation
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, convert, integer, string</tags>
</US_DocBloc>
]]
  if math.type(Size)~="integer" then ultraschall.AddErrorMessage("ConvertIntegerIntoString2", "Size", "must be an integer", -1) return nil end
  if Size<1 or Size>4 then ultraschall.AddErrorMessage("ConvertIntegerIntoString2", "Size", "must be between 1(for 8 bit) and 4(for 32 bit)", -2) return nil end
  local Table={...}
  local String=""
  local count=1
  while Table[count]~=nil do
    if math.type(Table[count])~="integer" then ultraschall.AddErrorMessage("ConvertIntegerIntoString2", "parameter "..count, "must be an integer", -3) return end
    if Table[count]>2^32 then ultraschall.AddErrorMessage("ConvertIntegerIntoString2", "parameter "..count, "must be between 0 and 2^32", -4) return end
    local Byte1, Byte2, Byte3, Byte4 = ultraschall.SplitIntegerIntoBytes(Table[count])
    String=String..string.char(Byte1)
    if Size>1 then String=String..string.char(Byte2) end
    if Size>2 then String=String..string.char(Byte3) end
    if Size>3 then String=String..string.char(Byte4) end
    count=count+1
  end
  return String
end

function ultraschall.LoadFunctionFromExtState(section, key)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>LoadFunctionFromExtState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.975
    Lua=5.3
  </requires>
  <functioncall>function function = ultraschall.LoadFunctionFromExtState(string section, string key)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Loads a function from an extstate, if it has been stored in there before.
    The extstate must contain a valid function. If something else is stored, the loaded "function" might crash Lua!
    
    To store the function, use [StoreFunctionInExtState](#StoreFunctionInExtState)
    
    Returns false in case of an error
  </description>
  <retvals>
    function func - the stored function, that you want to (re-)load
  </retvals>
  <parameters>
    string section - the sectionname of the extstate
    string key - the keyname of the extstate
  </parameters>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, load, function, extstate</tags>
</US_DocBloc>
]]
  if type(section)~="string" then ultraschall.AddErrorMessage("LoadFunctionFromExtState", "section", "must be a string", -1) return false end
  if type(key)~="string" then ultraschall.AddErrorMessage("LoadFunctionFromExtState", "key", "must be a string", -2) return false end
  local DumpBase64 = reaper.GetExtState(section, key)
  if DumpBase64=="" or DumpBase64:match("LuaFunc:")==nil then ultraschall.AddErrorMessage("LoadFunctionFromExtState", "", "no function stored in extstate", -3) return false end
  local Dump = ultraschall.Base64_Decoder(DumpBase64:sub(9,-1))
  return load(Dump)
end

function ultraschall.CompareStringWithAsciiValues(string,...)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CompareStringWithAsciiValues</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, integer errorposition = ultraschall.CompareStringWithAsciiValues(string string, integer bytevalue_1, integer bytevalue_2, ... integer bytevalue_n)</functioncall>
  <description>
    Compares a string with a number of byte-values(like ASCII-values).
    Bytevalues can be either decimal and hexadecimal.
    -1, if you want to skip checking of a specific position in string.
    
    Returns false in case of error
  </description>
  <parameters>
    string string - the string to check against the bytevalues
    integer bytevalue_1..n - one or more parameters, that include the bytevalues to check against the accompanying byte in string; -1, if you want to skip check for that position
  </parameters>
  <retvals>
    boolean retval - true, if check was successful; false, if not successful
    integer errorposition - if retval is false, this will contain the position in string, where the checking failed; nil, if retval is true
  </retvals>
  <chapter_context>
    API-Helper functions
    Data Manipulation
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, check, compare, string, byte, bytevalues</tags>
</US_DocBloc>
--]]
  if type(string)~="string" then ultraschall.AddErrorMessage("CompareStringWithAsciiValues","string", "Must be a string!", -1) return false end  
  local length, Table=ultraschall.ConvertStringToAscii_Array(string)
  local AsciiValues={...}
  local NumEntries=ultraschall.CountEntriesInTable_Main(AsciiValues)
  local count=1  
  local retval=true
  while AsciiValues[count]~=nil do
    if AsciiValues[count]==-1 then 
    elseif Table[count][2]~=AsciiValues[count] then retval=false break end
    count=count+1
  end
  if count-1==NumEntries then count=nil end
  return retval, count
end

function ultraschall.ConvertIntegerIntoString2(Size, ...)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ConvertIntegerIntoString2</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>string converted_value = ultraschall.ConvertIntegerIntoString2(integer Size, integer integervalue_1, ..., integer integervalue_n)</functioncall>
  <description>
    Splits numerous integers into its individual bytes and converts them into a string-representation.
    Maximum 32bit-integers are supported.
    
    Returns nil in case of an error.
  </description>
  <parameters>
    integer Size - the maximum size of the integer to convert, 1(8 bit) to 4(32 bit)
    integer integervalue_1 - the first integer value to convert from
    ... - 
    integer integervalue_n - the last integer value to convert from
  </parameters>
  <retvals>
    string converted_value - the string-representation of the integer
  </retvals>
  <chapter_context>
    API-Helper functions
    Data Manipulation
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, convert, integer, string</tags>
</US_DocBloc>
]]
  if math.type(Size)~="integer" then ultraschall.AddErrorMessage("ConvertIntegerIntoString2", "Size", "must be an integer", -1) return nil end
  if Size<1 or Size>4 then ultraschall.AddErrorMessage("ConvertIntegerIntoString2", "Size", "must be between 1(for 8 bit) and 4(for 32 bit)", -2) return nil end
  local Table={...}
  local String=""
  local count=1
  while Table[count]~=nil do
    if math.type(Table[count])~="integer" then ultraschall.AddErrorMessage("ConvertIntegerIntoString2", "parameter "..count, "must be an integer", -3) return end
    if Table[count]>2^32 then ultraschall.AddErrorMessage("ConvertIntegerIntoString2", "parameter "..count, "must be between 0 and 2^32", -4) return end
    local Byte1, Byte2, Byte3, Byte4 = ultraschall.SplitIntegerIntoBytes(Table[count])
    String=String..string.char(Byte1)
    if Size>1 then String=String..string.char(Byte2) end
    if Size>2 then String=String..string.char(Byte3) end
    if Size>3 then String=String..string.char(Byte4) end
    count=count+1
  end
  return String
end


function ultraschall.GetScriptFilenameFromActionCommandID(action_command_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetScriptFilenameFromActionCommandID</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    SWS=2.9.7
    Lua=5.3
  </requires>
  <functioncall>string scriptfilename_with_path = ultraschall.GetScriptFilenameFromActionCommandID(string action_command_id)</functioncall>
  <description>
    returns the filename with path of a script, associated to a ReaScript.
    Command-ID-numbers do not work!
                            
    returns false in case of an error
  </description>
  <parameters>
    string Path - the path to set as new current working directory
  </parameters>
  <retvals>
    string scriptfilename_with_path - the scriptfilename with path associated with this ActionCommandID
  </retvals>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>filemanagement, get, scriptfilename, actioncommandid</tags>
</US_DocBloc>
]]
  if ultraschall.type(action_command_id)~="string" then ultraschall.AddErrorMessage("GetScriptFilenameFromActionCommandID", "action_command_id", "must be a string", -1) return false end
  if ultraschall.CheckActionCommandIDFormat2(action_command_id)==false then ultraschall.AddErrorMessage("GetScriptFilenameFromActionCommandID", "action_command_id", "no such action-command-id", -2) return false end
  local kb_ini_path = ultraschall.GetKBIniFilepath()
  local kb_ini_file = ultraschall.ReadFullFile(kb_ini_path)
  if action_command_id:sub(1,1)=="_" then action_command_id=action_command_id:sub(2,-1) end
  local L=kb_ini_file:match("( "..action_command_id..".-)\n")
  if L==nil then ultraschall.AddErrorMessage("GetScriptFilenameFromActionCommandID", "action_command_id", "no such action_command_id associated to a script", -1) return false end
  L=L:match(".*%s(.*)")
  if L:sub(1,2)==".." then return reaper.GetResourcePath().."/"..L end
  return L
end

function ultraschall.IsItemInTrack(tracknumber, itemIDX)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsItemInTrack</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.IsItemInTrack(integer tracknumber, integer itemIDX)</functioncall>
  <description>
    checks, whether a given item is part of the track tracknumber
    
    returns true, if the itemIDX is part of track tracknumber, false if not, nil if no such itemIDX or Tracknumber available
  </description>
  <retvals>
    boolean retval - true, if item is in track, false if item isn't in track
  </retvals>
  <parameters>
    integer itemIDX - the number of the item to check of
    integer tracknumber - the number of the track to check in, with 1 for track 1, 2 for track 2, etc.
  </parameters>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>itemmanagement,item,track,existence</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("IsItemInTrack","tracknumber", "only integer is allowed", -1) return nil end
  if math.type(itemIDX)~="integer" then ultraschall.AddErrorMessage("IsItemInTrack","itemIDX", "only integer is allowed", -2) return nil end
  
  if tracknumber>reaper.CountTracks(0) or tracknumber<0 then ultraschall.AddErrorMessage("IsItemInTrack","tracknumber", "no such track in this project", -3) return nil end
  if itemIDX>reaper.CountMediaItems(0)-1 or itemIDX<0 then ultraschall.AddErrorMessage("IsItemInTrack","itemIDX", "no such item in this project", -4) return nil end
  
  -- Get the tracks and items
  local MediaTrack=reaper.GetTrack(0, tracknumber-1) 
  local MediaItem=reaper.GetMediaItem(0, itemIDX)
  local MediaTrack2=reaper.GetMediaItem_Track(MediaItem)
  
  -- check and return
  if MediaTrack==MediaTrack2 then return true 
  else return false
  end  
end

function ultraschall.LoadFunctionFromExtState(section, key)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>LoadFunctionFromExtState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.975
    Lua=5.3
  </requires>
  <functioncall>function function = ultraschall.LoadFunctionFromExtState(string section, string key)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Loads a function from an extstate, if it has been stored in there before.
    The extstate must contain a valid function. If something else is stored, the loaded "function" might crash Lua!
    
    To store the function, use [StoreFunctionInExtState](#StoreFunctionInExtState)
    
    Returns false in case of an error
  </description>
  <retvals>
    function func - the stored function, that you want to (re-)load
  </retvals>
  <parameters>
    string section - the sectionname of the extstate
    string key - the keyname of the extstate
  </parameters>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, load, function, extstate</tags>
</US_DocBloc>
]]
  if type(section)~="string" then ultraschall.AddErrorMessage("LoadFunctionFromExtState", "section", "must be a string", -1) return false end
  if type(key)~="string" then ultraschall.AddErrorMessage("LoadFunctionFromExtState", "key", "must be a string", -2) return false end
  local DumpBase64 = reaper.GetExtState(section, key)
  if DumpBase64=="" or DumpBase64:match("LuaFunc:")==nil then ultraschall.AddErrorMessage("LoadFunctionFromExtState", "", "no function stored in extstate", -3) return false end
  local Dump = ultraschall.Base64_Decoder(DumpBase64:sub(9,-1))
  return load(Dump)
end


function ultraschall.SetIntConfigVar_Bitfield(configvar, set_to, ...)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetIntConfigVar_Bitfield</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    SWS=2.9.7
    Lua=5.3
  </requires>
  <functioncall>boolean retval, integer new_integer_bitfield = ultraschall.SetIntConfigVar_Bitfield(string configvar, boolean set_to, integer bit_1, integer bit_2, ... integer bit_n)</functioncall>
  <description>
    Alters an integer-bitfield stored by a ConfigVariable.
    
    Returns false in case of error, like invalid bit-values, etc
  </description>
  <parameters>
    string configvar - the config-variable, that is stored as an integer-bitfield, that you want to alter.
    boolean set_to - true, set the bits to 1; false, set the bits to 0; nil, toggle the bits
    integer bit1..n - one or more parameters, that include the bitvalues toset/unset/toggle with 1 for the first bit; 2 for the second, 4 for the third, 8 for the fourth, etc
  </parameters>
  <retvals>
    boolean retval - true, if altering was successful; false, if not successful
    integer new_integer_bitfield - the newly altered bitfield
  </retvals>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, bitfield, set, unset, toggle, configvar</tags>
</US_DocBloc>
--]]
  local integer_bitfield=reaper.SNM_GetIntConfigVar(configvar, -22)
  local integer_bitfield2=reaper.SNM_GetIntConfigVar(configvar, -23)
  if type(configvar)~="string" then ultraschall.AddErrorMessage("SetIntConfigVar_Bitfield","configvar", "Must be a string!", -1) return false end
  if integer_bitfield==-22 and integer_bitfield2==-23 then ultraschall.AddErrorMessage("SetIntConfigVar_Bitfield","configvar", "No valid config-variable!", -2) return false end
  
  -- check parameters
  if set_to~=nil and type(set_to)~="boolean" then ultraschall.AddErrorMessage("SetIntConfigVar_Bitfield","set_to", "Must be a boolean!", -3) return false end
  local Parameters={...}
  local count=1
  while Parameters[count]~=nil do
    -- check the bit-parameters
    if math.log(Parameters[count],2)~=math.floor(math.log(Parameters[count],2)) then ultraschall.AddErrorMessage("SetIntConfigVar_Bitfield","bit", "Bit_"..count.."="..Parameters[count].." isn't a valid bitvalue!", -4) return false end
    count=count+1
  end
  
  -- Now let's set or unset the bitvalues
  count=1
  while Parameters[count]~=nil do
    if set_to==true and integer_bitfield&Parameters[count]==0 then 
      -- setting the bits
      integer_bitfield=integer_bitfield+Parameters[count] 
    elseif set_to==false and integer_bitfield&Parameters[count]~=0 then 
      -- unsetting the bits
      integer_bitfield=integer_bitfield-Parameters[count]
    elseif set_to==nil then
      -- toggling the bits
      if integer_bitfield&Parameters[count]==0 then 
        integer_bitfield=integer_bitfield+Parameters[count] 
      elseif integer_bitfield&Parameters[count]~=0 then 
        integer_bitfield=integer_bitfield-Parameters[count] 
      end
    end
    count=count+1
  end
  return reaper.SNM_SetIntConfigVar(configvar, integer_bitfield), integer_bitfield
end

function ultraschall.ToggleStateAction(section, actioncommand_id, state)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ToggleStateAction</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval = ultraschall.ToggleStateAction(integer section, string actioncommand_id, integer state)</functioncall>
  <description>
    Toggles state of an action using the actioncommand_id(instead of the CommandID-number)
    
    returns current state of the action after toggling or -1 in case of error.
  </description>
  <retvals>
    integer retval  - state if the action, after it has been toggled
  </retvals>
  <parameters>
    integer section - the section of the action(see ShowActionlist-dialog)
                            -0 - Main
                            -100 - Main (alt recording)
                            -32060 - MIDI Editor
                            -32061 - MIDI Event List Editor
                            -32062 - MIDI Inline Editor
                            -32063 - Media Explorer
    string actioncommand_id - the ActionCommandID of the action to toggle
    integer state - 1 or 0
  </parameters>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>command,commandid,actioncommandid,action,run,state,section</tags>
</US_DocBloc>
--]]
  -- check parameters
  if actioncommand_id==nil then ultraschall.AddErrorMessage("ToggleStateAction", "action_command_id", "must be a number or a string", -1) return -1 end
  if math.type(state)~="integer" then ultraschall.AddErrorMessage("ToggleStateAction", "state", "must be an integer", -2) return -1 end
  if math.type(section)~="integer" then ultraschall.AddErrorMessage("ToggleStateAction", "section", "must be an integer", -3) return -1 end
  
  -- do the toggling
  local command_id = reaper.NamedCommandLookup(actioncommand_id)
  reaper.SetToggleCommandState(section, command_id, state)
  return reaper.GetToggleCommandState(command_id)
end

function ultraschall.ToggleStateButton(section, actioncommand_id, state)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ToggleStateButton</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval = ultraschall.ToggleStateButton(integer section, string actioncommand_id, integer state)</functioncall>
  <description>
    Toggles state and refreshes the button of an actioncommand_id
    
    returns false in case of error
  </description>
  <retvals>
    integer retval  - true, toggling worked; false, toggling didn't work
  </retvals>
  <parameters>
    integer section - the section of the action(see ShowActionlist-dialog)
                            -0 - Main
                            -100 - Main (alt recording)
                            -32060 - MIDI Editor
                            -32061 - MIDI Event List Editor
                            -32062 - MIDI Inline Editor
                            -32063 - Media Explorer
    string actioncommand_id - the ActionCommandID of the action to toggle
    integer state - 1 or 0
  </parameters>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>command,commandid,actioncommandid,action,run,toolbar,toggle,button</tags>
</US_DocBloc>
--]]
  if actioncommand_id==nil then ultraschall.AddErrorMessage("ToggleStateButton", "action_command_id", "must be a string or a number", -1) return false end
  if math.type(state)~="integer" then ultraschall.AddErrorMessage("ToggleStateButton", "state", "must be an integer", -2) return false end
  if math.type(section)~="integer" then ultraschall.AddErrorMessage("ToggleStateButton", "section", "must be an integer", -3) return false end

  local command_id = reaper.NamedCommandLookup(actioncommand_id)
  local stater=reaper.SetToggleCommandState(section, command_id, state)
  reaper.RefreshToolbar(command_id)
  if stater==false then ultraschall.AddErrorMessage("ToggleStateButton", "action_command_id", "doesn't exist", -4) return false end
  return stater
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
  if type(position)~="number" then ultraschall.AddErrorMessage("SplitMediaItems_Position","position", "must be a number", -1) return false end
  if ultraschall.IsValidTrackString(trackstring)==false then ultraschall.AddErrorMessage("SplitMediaItems_Position","trackstring", "must be valid trackstring", -2) return false end

  local A,trackstring,AA,AAA=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if trackstring==-1 or trackstring=="" then ultraschall.AddErrorMessage("SplitMediaItems_Position","trackstring", "must be valid trackstring", -2) return false end

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
          local retval = ultraschall.MoveTrackEnvelopePointsBy(position, reaper.GetProjectLength()+(ItemEnd-ItemStart), ItemEnd-ItemStart, MediaTrack, true) 
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
    
    returns -1 in case of error or nil if no spectral-config exists(e.g. when no spectral-edit is applied to this item)
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
  if itemidx==-1 and tostring(MediaItemStateChunk):match("<ITEM.*>")==nil then ultraschall.AddErrorMessage("GetItemSpectralConfig","MediaItemStateChunk", "must be a valid MediaItemStateChunk", -5) return -1 end

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
  if itemidx==-1 and tostring(MediaItemStateChunk):match("<ITEM.*>")==nil then ultraschall.AddErrorMessage("GetItemSpectralVisibilityState","MediaItemStateChunk", "must be a valid MediaItemStateChunk", -5) return -1 end

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
  if TakeNr<0 or TakeNr>reaper.CountTakes(MediaItem) then ultraschall.AddErrorMessage("GetMediaItemTake", "TakeNr", "No such take in MediaItem", -3) return nil end
  
  if TakeNr==0 then return reaper.GetActiveTake(MediaItem), reaper.CountTakes(MediaItem)
  else return reaper.GetMediaItemTake(MediaItem, TakeNr-1), reaper.CountTakes(MediaItem) end
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
  if math.type(tracknumber)~="integer" then ultraschall.AddErrorMessage("SetItemUSTrackNumber_StateChunk","tracknumber", "must be an integer.", -2) return -1 end
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
  elseif ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("SetItemPosition", "statechunk", "Must be a valid statechunk.", -1) return -1
  end
  if type(position)~="number" then ultraschall.AddErrorMessage("SetItemPosition", "position", "Must be a number.", -2) return -1 end  
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
  elseif ultraschall.IsValidItemStateChunk(statechunk)==false then ultraschall.AddErrorMessage("SetItemLength", "statechunk", "Must be a valid statechunk.", -1) return -1
  end
--  reaper.MB(type(length),length,0)
  if type(length)~="number" then ultraschall.AddErrorMessage("SetItemLength", "length", "Must be a number.", -2) return -1 end  
  if length<0 then ultraschall.AddErrorMessage("SetItemLength", "length", "Must bigger than or equal 0.", -3) return -1 end
  
  -- do the magic
  statechunk=statechunk:match("(<ITEM.-)LENGTH").."LENGTH "..length.."\n"..statechunk:match("LENGTH.-%c(.*)")
  
  -- set statechunk, if MediaItem is provided, otherwise don't set it
  if reaper.ValidatePtr2(0, MediaItem, "MediaItem*")==true then reaper.SetItemStateChunk(MediaItem, statechunk, false) end
  
  -- return
  return statechunk
end

function ultraschall.GetProject_CountAutomationItems(projectfilename_with_path, ProjectStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetProject_CountAutomationItems</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>integer automation_items_count = ultraschall.GetProject_CountAutomationItems(string projectfilename_with_path, optional string ProjectStateChunk)</functioncall>
  <description>
    returns the number of automation-items available in a ProjectStateChunk.

    It's the entry &lt;POOLEDENV
                            
    returns -1 in case of an error
  </description>
  <parameters>
    string projectfilename_with_path - the projectfile+path, from which to get the automation-item-count; nil to use ProjectStateChunk
    optional string ProjectStateChunk - a statechunk of a project, usually the contents of a rpp-project-file; only used, when projectfilename_with_path=nil
  </parameters>
  <retvals>
    integer automation_items_count - the number of automation-items
  </retvals>
  <chapter_context>
    Automation Items
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>automationitems, count, automation, statechunk, projectstatechunk</tags>
</US_DocBloc>
]]
  -- check parameters and prepare variable ProjectStateChunk
  if projectfilename_with_path~=nil and type(projectfilename_with_path)~="string" then ultraschall.AddErrorMessage("GetProject_CountAutomationItems","projectfilename_with_path", "Must be a string or nil(the latter when using parameter ProjectStateChunk)!", -1) return -1 end
  if projectfilename_with_path==nil and ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("GetProject_CountAutomationItems","ProjectStateChunk", "No valid ProjectStateChunk!", -2) return -1 end
  if projectfilename_with_path~=nil then
    if reaper.file_exists(projectfilename_with_path)==true then ProjectStateChunk=ultraschall.ReadFullFile(projectfilename_with_path, false)
    else ultraschall.AddErrorMessage("GetProject_CountAutomationItems","projectfilename_with_path", "File does not exist!", -3) return -1
    end
    if ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("GetProject_CountAutomationItems", "projectfilename_with_path", "No valid RPP-Projectfile!", -4) return -1 end
  end
  
  local count=0
  while ProjectStateChunk:find("  <POOLEDENV")~=nil do
    count=count+1    
    ProjectStateChunk=ProjectStateChunk:match("  <POOLEDENV(.*)")
  end
  return count
end

function ultraschall.RGB2Grayscale(red,green,blue)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>RGB2Grayscale</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer graycolor = ultraschall.RGB2Grayscale(integer red, integer green, integer blue)</functioncall>
  <description>
    converts rgb to a grayscale value. Works native on Mac as well on Windows, no color conversion needed.
    
    returns nil in case of an error
  </description>
  <parameters>
    integer red - red-value between 0 and 255.
    integer green - red-value between 0 and 255.
    integer blue - red-value between 0 and 255.
  </parameters>
  <retvals>
    integer graycolor  - the gray color-value, generated from red,blue and green.
  </retvals>
  <chapter_context>
    Color Management
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>colorvalues,rgb,gray,grayscale,grey,greyscale</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(red)~="integer" then ultraschall.AddErrorMessage("RGB2Grayscale","red".."only integer is allowed", -1) return nil end
  if math.type(green)~="integer" then ultraschall.AddErrorMessage("RGB2Grayscale","green".."only integer is allowed", -2) return nil end
  if math.type(blue)~="integer" then ultraschall.AddErrorMessage("RGB2Grayscale","blue".."only integer is allowed", -3) return nil end

  if red<0 or red>255 then ultraschall.AddErrorMessage("RGB2Grayscale","red", "must be between 0 and 255", -4) return nil end
  if green<0 or green>255 then ultraschall.AddErrorMessage("RGB2Grayscale","green", "must be between 0 and 255", -5) return nil end
  if blue<0 or blue>255 then ultraschall.AddErrorMessage("RGB2Grayscale","blue", "must be between 0 and 255", -6) return nil end

  -- do the legend of the grayscale and return it's resulting colorvalue
  local gray=red+green+blue
  gray=ultraschall.RoundNumber(gray/3)
  local gray_color=reaper.ColorToNative(gray,gray,gray)
  return ultraschall.RoundNumber(gray_color)
end

function ultraschall.ReadValueFromFile(filename_with_path, value)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ReadValueFromFile</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string contents, string linenumbers, integer numberoflines, integer number_of_foundlines = ultraschall.ReadValueFromFile(string filename_with_path, string value)</functioncall>
  <description>
    Return contents of filename_with_path. 
    
    If "value" is given, it will return all lines, containing the value in the file "filename_with_path". 
    The second line-numbers return-value is very valuable when giving a "value". "Value" is not case-sensitive.
    The value can also contain patterns for pattern matching. Refer the LUA-docs for pattern matching.
    i.e. characters like ^$()%.[]*+-? must be escaped with a %, means: %[%]%(%) etc
  </description>
  <retvals>
    string contents - the contents of the file, or the lines that contain parameter value in it, separated by a newline
    string linenumbers - a string, that contains the linenumbers returned as a , separated csv-string
    integer numberoflines_in_file - the total number of lines in the file
    integer number_of_foundlines - the number of found lines
  </retvals>
  <parameters>
    string filename_with_path - filename of the file to be read
    string value - the value to look in the file for. Not case-sensitive.
  </parameters>
  <chapter_context>
    File Management
    Read Files
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>filemanagement, read file, value, pattern, lines</tags>
</US_DocBloc>
]]
  -- check parameters
  if type(filename_with_path) ~= "string" then ultraschall.AddErrorMessage("ReadValueFromFile", "filename_with_path", "must be a string", -1) return nil end
  if value==nil then value="" end
  if reaper.file_exists(filename_with_path)==false then ultraschall.AddErrorMessage("ReadValueFromFile", "filename_with_path", "file "..filename_with_path.." does not exist", -2) return nil end
  if ultraschall.IsValidMatchingPattern(value)==false then ultraschall.AddErrorMessage("ReadValueFromFile", "value", "malformed pattern", -3) return nil end

  -- prepare variables
  local contents=""
  local b=0 -- temporary line-counting-variable
  local linenumbers="" -- the linenumbers of lines, where value has been found in the file, separated by a ,
  local number_of_lines=0 -- the number of lines in the file/number of lines, where value has been found
  local foundlines={} -- the found-lines throw into an array, with each entry being one line
  local countlines=0
  
  -- read file and find lines
  if value=="" then -- if no search-value is given
    for line in io.lines(filename_with_path) do 
      contents=contents..line.."\n"
      b=b+1
      linenumbers=linenumbers..tostring(b)..","
      number_of_lines=b
      countlines=countlines+1
    end
  else -- if a search-value is given
    for line in io.lines(filename_with_path) do
      local temp=line:lower()
      local valtemp=value:lower()
      b=b+1
      if temp:match(valtemp)~=nil then
        contents=contents..line.."\n"          
        linenumbers=linenumbers..tostring(b)..","
        number_of_lines=number_of_lines+1
        countlines=countlines+1
      end
      number_of_lines=b
    end
  end
  -- return found lines and values
  if return_lines_as_array==false then countlines=nil foundlines=nil end

  --string contents, string linenumbers, integer numberoflines
  return contents,linenumbers:sub(1,-2), number_of_lines, countlines
end

function ultraschall.MakeCopyOfFile_Binary(input_filename_with_path, output_filename_with_path)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>MakeCopyOfFile_Binary</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.MakeCopyOfFile_Binary(string input_filename_with_path, string output_filename_with_path)</functioncall>
  <description>
    Copies input_filename_with_path to output_filename_with_path as binary-file.
  </description>
  <retvals>
    boolean retval - returns true, if copy worked; false if it didn't
  </retvals>
  <parameters>
    string input_filename_with_path - filename of the file to copy
    string output_filename_with_path - filename of the copied file, that shall be created
  </parameters>
  <chapter_context>
    File Management
    Manipulate Files
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>filemanagement, read file, binary</tags>
</US_DocBloc>
]]
  if type(input_filename_with_path)~="string" then ultraschall.AddErrorMessage("MakeCopyOfFile_Binary", "input_filename_with_path", "must be a string", -1) return false end
  if type(output_filename_with_path)~="string" then ultraschall.AddErrorMessage("MakeCopyOfFile_Binary", "output_filename_with_path", "must be a string", -2) return false end
  
  if reaper.file_exists(input_filename_with_path)==true then
    local fileread=io.open(input_filename_with_path,"rb")
    if fileread==nil then ultraschall.AddErrorMessage("MakeCopyOfFile_Binary", "input_filename_with_path", "could not read file "..input_filename_with_path..", probably due another application accessing it.", -5) return false end
    local file=io.open(output_filename_with_path,"wb")
    if file==nil then ultraschall.AddErrorMessage("MakeCopyOfFile_Binary", "output_filename_with_path", "can't create file "..output_filename_with_path, -3) return false end
    file:write(fileread:read("*a"))
    fileread:close()
    file:close()
  else ultraschall.AddErrorMessage("MakeCopyOfFile_Binary", "input_filename_with_path", "file does not exist "..input_filename_with_path, -4) return false
  end
  return true
end

function ultraschall.ReadBinaryFileUntilPattern(input_filename_with_path, pattern)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ReadBinaryFileUntilPattern</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer length, string content = ultraschall.ReadBinaryFileUntilPattern(string input_filename_with_path, string pattern)</functioncall>
  <description>
    Returns a binary file, up until a pattern. The pattern is not case-sensitive.
    
    Pattern can also contain patterns for pattern matching. Refer the LUA-docs for pattern matching.
    i.e. characters like ^$()%.[]*+-? must be escaped with a %, means: %[%]%(%) etc
    
    returns false in case of an error
  </description>
  <retvals>
    integer length - the length of the returned data
    string content - the content of the file, that has been read until pattern
  </retvals>
  <parameters>
    string filename_with_path - filename of the file to be read
    string pattern - a pattern to search for. Case-sensitive.
  </parameters>
  <chapter_context>
    File Management
    Read Files
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>filemanagement, read file, pattern, binary</tags>
</US_DocBloc>
]]
  local temp=""
  local temp2
  if type(input_filename_with_path)~="string" then ultraschall.AddErrorMessage("ReadBinaryFileUntilPattern", "input_filename_with_path", "must be a string", -1) return false end
  if type(pattern)~="string" then ultraschall.AddErrorMessage("ReadBinaryFileUntilPattern", "pattern", "must be a string", -2) return false end
  if ultraschall.IsValidMatchingPattern(pattern)==false then ultraschall.AddErrorMessage("ReadBinaryFileUntilPattern", "pattern", "malformed pattern", -3) return false end
  
  if reaper.file_exists(input_filename_with_path)==true then
    local fileread=io.open(input_filename_with_path,"rb")
    if fileread==nil then ultraschall.AddErrorMessage("ReadBinaryFileUntilPattern", "input_filename_with_path", "could not read file "..input_filename_with_path..", probably due another application accessing it.", -6) return false end
    temp=fileread:read("*a")
    temp2=temp:match("(.-"..pattern..")")
    if temp2==nil then fileread:close() ultraschall.AddErrorMessage("ReadBinaryFileUntilPattern", "pattern", "pattern not found in file", -4) return false end
    fileread:close()
  else
    ultraschall.AddErrorMessage("ReadBinaryFileUntilPattern", "input_filename_with_path", "file "..input_filename_with_path.." does not exist", -5) return false
  end
  return temp2:len(), temp2
end

function ultraschall.ReadBinaryFileFromPattern(input_filename_with_path, pattern)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ReadBinaryFileFromPattern</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer length, string content = ultraschall.ReadBinaryFileFromPattern(string input_filename_with_path, string pattern)</functioncall>
  <description>
    Returns a binary file, from pattern onwards. The pattern is not case-sensitive.
    
    The pattern can also contain patterns for pattern matching. Refer the LUA-docs for pattern matching.
    i.e. characters like ^$()%.[]*+-? must be escaped with a %, means: %[%]%(%) etc
    
    returns false in case of an error
  </description>
  <retvals>
    integer length - the length of the returned data
    string content - the content of the file, that has been read from pattern to the end
  </retvals>
  <parameters>
    string filename_with_path - filename of the file to be read
    string pattern - a pattern to search for. Case-sensitive.
  </parameters>
  <chapter_context>
    File Management
    Read Files
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>filemanagement, read file, pattern, binary</tags>
</US_DocBloc>
]]
  local temp=""
  local temp2
  if type(input_filename_with_path)~="string" then ultraschall.AddErrorMessage("ReadBinaryFileFromPattern", "input_filename_with_path", "must be a string", -1) return false end
  if type(pattern)~="string" then ultraschall.AddErrorMessage("ReadBinaryFileFromPattern", "pattern", "must be a string", -2) return false end
  if ultraschall.IsValidMatchingPattern(pattern)==false then ultraschall.AddErrorMessage("ReadBinaryFileFromPattern", "pattern", "malformed pattern", -3) return false end
  
  if reaper.file_exists(input_filename_with_path)==true then
    local fileread=io.open(input_filename_with_path,"rb")
    if fileread==nil then ultraschall.AddErrorMessage("ReadBinaryFileFromPattern", "input_filename_with_path", "could not read file "..input_filename_with_path..", probably due another application accessing it.", -6) return false end
    temp=fileread:read("*a")
    temp2=temp:match("("..pattern..".*)")
    if temp2==nil then fileread:close() ultraschall.AddErrorMessage("ReadBinaryFileFromPattern", "pattern", "pattern not found in file", -4) return false end
    fileread:close()
  else
    ultraschall.AddErrorMessage("ReadBinaryFileFromPattern", "input_filename_with_path", "file "..input_filename_with_path.." does not exist", -5) return false
  end
  return temp2:len(), temp2
end

function ultraschall.CountLinesInFile(filename_with_path)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CountLinesInFile</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer linesinfile = ultraschall.CountLinesInFile(string filename_with_path)</functioncall>
  <description>
    Counts lines in a textfile. In binary files, the number of lines may be weird and unexpected!
    Returns -1, if no such file exists.
  </description>
  <retvals>
    integer linesinfile - number of lines in a textfile; -1 in case of error
  </retvals>
  <parameters>
    string filename_with_path - filename of the file to be read
  </parameters>
  <chapter_context>
    File Management
    File Analysis
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>filemanagement, count</tags>
</US_DocBloc>
]]
  -- check parameters  
  if type(filename_with_path) ~= "string" then ultraschall.AddErrorMessage("CountLinesInFile", "filename_with_path", "must be a string", -1) return -1 end
  if reaper.file_exists(filename_with_path)==false then ultraschall.AddErrorMessage("CountLinesInFile", "filename_with_path", "no such file "..filename_with_path, -2) return -1 end

  -- prepare variable
  local b=0
  
  -- count the lines
  for line in io.lines(filename_with_path) do 
      b=b+1
  end
  
  return b
end

function ultraschall.GetLengthOfFile(filename_with_path)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetLengthOfFile</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer lengthoffile = ultraschall.GetLengthOfFile(string filename_with_path)</functioncall>
  <description>
    Returns the length of the file filename_with_path in bytes.
    Will return -1, if no such file exists.
  </description>
  <parameters>
    string filename_with_path - filename to write the value to
  </parameters>
  <retvals>
    integer lengthoffile - the length of the file in bytes. -1 in case of error
  </retvals>
  <chapter_context>
    File Management
    File Analysis
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>filemanagement,file,length,bytes,count</tags>
</US_DocBloc>
]]
  if filename_with_path==nil then ultraschall.AddErrorMessage("GetLengthOfFile", "filename_with_path", "nil not allowed as filename", -1) return -1 end
  local numberofbytes
  if reaper.file_exists(filename_with_path)==true then
    local fileread=io.open(filename_with_path,"rb")
    numberofbytes=fileread:seek ("end" , 0)
    fileread:close()
  else
    ultraschall.AddErrorMessage("GetLengthOfFile", "filename_with_path", "file does not exist: ".. filename_with_path, -2)
    return -1
  end
  return numberofbytes  
end

function ultraschall.SetFXStateChunk(StateChunk, FXStateChunk, TakeFXChain_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetFXStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.979
    Lua=5.3
  </requires>
  <functioncall>boolean retval, optional string alteredStateChunk = ultraschall.SetFXStateChunk(string StateChunk, string FXStateChunk)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Sets an FXStateChunk into a TrackStateChunk or a MediaItemStateChunk.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, if setting new values was successful; false, if setting was unsuccessful
    optional string alteredStateChunk - the altered StateChunk
  </retvals>
  <parameters>
    string StateChunk - the TrackStateChunk, into which you want to set the FXChain
    string FXStateChunk - the FXStateChunk, which you want to set into the TrackStateChunk
    optional integer TakeFXChain_id - when using MediaItemStateChunks, this allows you to choose the take of which you want the FXChain; default is 1
  </parameters>
  <chapter_context>
    FX-Management
    Parameter Mapping
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>fx management, set, trackstatechunk, mediaitemstatechunk, fxstatechunk</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("SetFXStateChunk", "FXStateChunk", "no valid FXStateChunk", -1) return false end
  if ultraschall.IsValidTrackStateChunk(StateChunk)==false and ultraschall.IsValidMediaItemStateChunk(StateChunk)==false then ultraschall.AddErrorMessage("SetFXStateChunk", "StateChunk", "no valid Track/ItemStateChunk", -1) return false end
  if TakeFXChain_id~=nil and math.type(TakeFXChain_id)~="integer" then ultraschall.AddErrorMessage("SetFXStateChunk", "TakeFXChain_id", "must be an integer", -3) return false end
  if TakeFXChain_id==nil then TakeFXChain_id=1 end
  local OldFXStateChunk=ultraschall.GetFXStateChunk(StateChunk, TakeFXChain_id)
  OldFXStateChunk=string.gsub(OldFXStateChunk, "\n%s*", "\n")  
  OldFXStateChunk=string.gsub(OldFXStateChunk, "^%s*", "")
  
  local Start, Stop = string.find(StateChunk, OldFXStateChunk, 0, true)
  StateChunk=StateChunk:sub(1,Start-1)..FXStateChunk:sub(2,-1)..StateChunk:sub(Stop+1,-1)
  StateChunk=string.gsub(StateChunk, "\n%s*", "\n")
  --print3(StateChunk)
  return true, StateChunk
end

function ultraschall.CountParmAlias_FXStateChunk(FXStateChunk, fxid)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CountParmAlias_FXStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.979
    Lua=5.3
  </requires>
  <functioncall>integer count = ultraschall.CountParmAlias_FXStateChunk(string FXStateChunk, integer fxid)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Counts already existing Parm-Alias-entries of an FX-plugin from an FXStateChunk.
    
    returns -1 in case of an error
  </description>
  <retvals>
    integer count - the number of ParmAliases found
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, in which you want to count a Parm-Learn-entry
    integer fxid - the id of the fx, which holds the to-count-Parm-Learn-entry; beginning with 1
  </parameters>
  <chapter_context>
    FX-Management
    Parameter Mapping
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>fx management, count, parm, aliasname</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("CountParmAlias_FXStateChunk", "FXStateChunk", "no valid FXStateChunk", -1) return -1 end
  if math.type(fxid)~="integer" then ultraschall.AddErrorMessage("CountParmAlias_FXStateChunk", "fxid", "must be an integer", -2) return -1 end
    
  local count=0
  local FX, UseFX2, start, stop, UseFX
  for k in string.gmatch(FXStateChunk, "    BYPASS.-WAK.-\n") do
    count=count+1
    if count==fxid then UseFX=k end
  end
  
  count=0
  if UseFX~=nil then
    for k in string.gmatch(UseFX, "    PARMALIAS.-\n") do
      count=count+1
    end
  end  
  return count
end

function ultraschall.CountParmLearn_FXStateChunk(FXStateChunk, fxid)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CountParmLearn_FXStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.979
    Lua=5.3
  </requires>
  <functioncall>integer count = ultraschall.CountParmLearn_FXStateChunk(string FXStateChunk, integer fxid)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Counts already existing Parm-Learn-entries of an FX-plugin from an FXStateChunk.
    
    returns -1 in case of an error
  </description>
  <retvals>
    integer count - the number of ParmLearn-entried found
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, in which you want to count a Parm-Learn-entry
    integer fxid - the id of the fx, which holds the to-count-Parm-Learn-entry; beginning with 1
  </parameters>
  <chapter_context>
    FX-Management
    Parameter Mapping
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>fx management, count, parm, learn</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("CountParmLearn_FXStateChunk", "FXStateChunk", "no valid FXStateChunk", -1) return -1 end
  if math.type(fxid)~="integer" then ultraschall.AddErrorMessage("CountParmLearn_FXStateChunk", "fxid", "must be an integer", -2) return -1 end
    
  local count=0
  local FX, UseFX2, start, stop, UseFX
  for k in string.gmatch(FXStateChunk, "    BYPASS.-WAK.-\n") do
    count=count+1
    if count==fxid then UseFX=k end
  end
  
  count=0
  if UseFX~=nil then
    for k in string.gmatch(UseFX, "    PARMLEARN.-\n") do
      count=count+1
    end
  end  
  return count
end

function ultraschall.CountParmLFOLearn_FXStateChunk(FXStateChunk, fxid)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CountParmLFOLearn_FXStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.979
    Lua=5.3
  </requires>
  <functioncall>integer count = ultraschall.CountParmLFOLearn_FXStateChunk(string FXStateChunk, integer fxid)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Counts already existing Parm-LFOLearn-entries of an FX-plugin from an FXStateChunk.
    
    returns -1 in case of an error
  </description>
  <retvals>
    integer count - the number of LFOLearn-entried found
  </retvals>
  <parameters>
    string FXStateChunk - the FXStateChunk, in which you want to count a Parm-LFOLearn-entry
    integer fxid - the id of the fx, which holds the to-count-Parm-LFOLearn-entry; beginning with 1
  </parameters>
  <chapter_context>
    FX-Management
    Parameter Mapping
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>fx management, count, parm, lfo, learn</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidFXStateChunk(FXStateChunk)==false then ultraschall.AddErrorMessage("CountParmLFOLearn_FXStateChunk", "FXStateChunk", "no valid FXStateChunk", -1) return -1 end
  if math.type(fxid)~="integer" then ultraschall.AddErrorMessage("CountParmLFOLearn_FXStateChunk", "fxid", "must be an integer", -2) return -1 end
    
  local count=0
  local FX, UseFX2, start, stop, UseFX
  for k in string.gmatch(FXStateChunk, "    BYPASS.-WAK.-\n") do
    count=count+1
    if count==fxid then UseFX=k end
  end
  
  count=0
  if UseFX~=nil then
    for k in string.gmatch(UseFX, "    LFOLEARN.-\n") do
      count=count+1
    end
  end  
  return count
end

function ultraschall.SetArmState_Envelope(TrackEnvelope, state, EnvelopeStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetArmState_Envelope</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>boolean retval, optional string EnvelopeStateChunk = ultraschall.SetArmState_Envelope(TrackEnvelope TrackEnvelope, integer state, optional string EnvelopeStateChunk)</functioncall>
  <description>
    Sets the new armed-state of a TrackEnvelope-object.
    
    returns false in case of error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
    optional string EnvelopeStateChunk - the altered EnvelopeStateChunk, when parameter TrackEnvelope is set to nil
  </retvals>
  <parameters>
    TrackEnvelope TrackEnvelope - the TrackEnvelope, whose armed-state you want to change
    integer state - 0, unarmed; 1, armed
    optional string EnvelopeStateChunk - if parameter TrackEnvelope is set to nil, you can pass an EnvelopeStateChunk into this parameters and change its arm-state
  </parameters>
  <chapter_context>
    Envelope Management
    Set Envelope States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>envelope states, set, arm, envelopestatechunk</tags>
</US_DocBloc>
]]  
  if TrackEnvelope~=nil and ultraschall.type(TrackEnvelope)~="TrackEnvelope" then ultraschall.AddErrorMessage("SetArmState_Envelope", "TrackEnvelope", "Must be a valid TrackEnvelope-object", -1) return false end
  if math.type(state)~="integer" then ultraschall.AddErrorMessage("SetArmState_Envelope", "state", "Must be an integer, either 1 or 0", -2) return false end
  if TrackEnvelope==nil and ultraschall.IsValidEnvStateChunk(EnvelopeStateChunk)==false then ultraschall.AddErrorMessage("SetArmState_Envelope", "EnvelopeStateChunk", "Must be a valid EnvelopeStateChunk", -3) return false end
  if TrackEnvelope~=nil then
    local retval, str = reaper.GetEnvelopeStateChunk(TrackEnvelope, "", false)
    return reaper.SetEnvelopeStateChunk(TrackEnvelope, string.gsub(str, "ARM %d*%c", "ARM "..state.."\n"), false)
  else
    return true, string.gsub(EnvelopeStateChunk, "ARM %d*%c", "ARM "..state.."\n")
  end
end

function ultraschall.RemoveMediaItem_TrackStateChunk(trackstatechunk, idx)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>RemoveMediaItem_TrackStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string trackstatechunk = ultraschall.RemoveMediaItem_TrackStateChunk(string trackstatechunk, integer idx)</functioncall>
  <description>
    Deletes the idx'th item from trackstatechunk and returns this altered trackstatechunk.
    
    returns false in case of error
  </description>
  <parameters>
    string trackstatechunk - a trackstatechunk, as returned by reaper's api function reaper.GetTrackStateChunk
    integer idx - the number of the item you want to delete
  </parameters>
  <retvals>
    boolean retval - true in case of success, false in case of error
    string trackstatechunk - the new trackstatechunk with the idx'th item deleted
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, tracks, media, item, statechunk, chunk, delete</tags>
</US_DocBloc>
]]
  if type(trackstatechunk)~="string" then ultraschall.AddErrorMessage("RemoveMediaItem_TrackStateChunk", "trackstatechunk", "only trackstatechunk is allowed", -1) return false end
  local nums=ultraschall.CountItemsInTrackStateChunk(trackstatechunk)
  if nums==-1 then ultraschall.AddErrorMessage("RemoveMediaItem_TrackStateChunk", "trackstatechunk", "only trackstatechunk is allowed", -2) return false end
  if nums<idx then ultraschall.AddErrorMessage("RemoveMediaItem_TrackStateChunk", "idx", "only "..nums.." items in trackstatechunk", -3) return false end
  if idx<1 then ultraschall.AddErrorMessage("RemoveMediaItem_TrackStateChunk", "idx", "only positive values allowed, beginning with 1", -4) return false end
  local begin=trackstatechunk:match("(.-)<ITEM.*")
  trackstatechunk=trackstatechunk:match("<ITEM.*")
  if trackstatechunk==nil then ultraschall.AddErrorMessage("RemoveMediaItem_TrackStateChunk", "trackstatechunk", "no valid trackstatechunk", -5) return false end
  local count=0
  local temptrackstatechunk=""
  while trackstatechunk:match("<ITEM")~=nil do
    count=count+1
    if count~=idx then
      local temptrackstatechunk2=trackstatechunk:match("(<ITEM.-)<ITEM")
      if temptrackstatechunk2==nil then temptrackstatechunk2=trackstatechunk:match("(<ITEM.*)") end
      temptrackstatechunk=temptrackstatechunk..temptrackstatechunk2
    end
    trackstatechunk=trackstatechunk:match("<ITEM.-(<ITEM.*)")
    if trackstatechunk==nil then break end 
  end
  return true, begin..temptrackstatechunk
end

function ultraschall.RemoveMediaItemByIGUID_TrackStateChunk(trackstatechunk, IGUID)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>RemoveMediaItemByIGUID_TrackStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string trackstatechunk = ultraschall.RemoveMediaItemByIGUID_TrackStateChunk(string trackstatechunk, string IGUID)</functioncall>
  <description>
    Deletes the item with the iguid IGUID from trackstatechunk and returns this altered trackstatechunk.
    
    returns false in case of error
  </description>
  <parameters>
    string trackstatechunk - a trackstatechunk, as returned by reaper's api function reaper.GetTrackStateChunk
    string IGUID - the IGUID of the item you want to delete
  </parameters>
  <retvals>
    boolean retval - true in case of success, false in case of error
    string trackstatechunk - the new trackstatechunk with the IGUID-item deleted
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, tracks, media, item, statechunk, chunk, delete, iguid</tags>
</US_DocBloc>
]]
  if type(trackstatechunk)~="string" then ultraschall.AddErrorMessage("RemoveMediaItemByIGUID_TrackStateChunk", "trackstatechunk", "only trackstatechunk is allowed", -1) return false end
  if trackstatechunk:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("RemoveMediaItemByIGUID_TrackStateChunk", "trackstatechunk", "no valid trackstatechunk", -2) return false end
  local nums=ultraschall.CountItemsInTrackStateChunk(trackstatechunk)
  local begin=trackstatechunk:match("(.-)<ITEM.*")
  trackstatechunk=trackstatechunk:match("<ITEM.*")
  if trackstatechunk==nil then ultraschall.AddErrorMessage("RemoveMediaItemByIGUID_TrackStateChunk", "trackstatechunk", "no items in trackstatechunk", -3) return false end
  local count=0
  local temptrackstatechunk=""
  local dada
  for i=1,nums do
    local L,M=ultraschall.GetItemStateChunkFromTrackStateChunk(trackstatechunk, i)
    if ultraschall.GetItemIGUID(M)~=IGUID then temptrackstatechunk=temptrackstatechunk..M end
  end
  local lt=ultraschall.CountCharacterInString(begin..temptrackstatechunk,"<")
  local gt=ultraschall.CountCharacterInString(begin..temptrackstatechunk,">")
  if gt<lt then dada=">\n" else dada="" end
  return true, begin..temptrackstatechunk..dada
end


function ultraschall.RemoveMediaItemByGUID_TrackStateChunk(trackstatechunk, GUID)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>RemoveMediaItemByGUID_TrackStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string trackstatechunk = ultraschall.RemoveMediaItemByGUID_TrackStateChunk(string trackstatechunk, string GUID)</functioncall>
  <description>
    Deletes the item with the guid GUID from trackstatechunk and returns this altered trackstatechunk.
    
    returns false in case of error
  </description>
  <parameters>
    string trackstatechunk - a trackstatechunk, as returned by reaper's api function reaper.GetTrackStateChunk
    string GUID - the GUID of the item you want to delete
  </parameters>
  <retvals>
    boolean retval - true in case of success, false in case of error
    string trackstatechunk - the new trackstatechunk with the GUID-item deleted
  </retvals>
  <chapter_context>
    Track Management
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>trackmanagement, tracks, media, item, statechunk, chunk, delete, guid</tags>
</US_DocBloc>
]]
  if type(trackstatechunk)~="string" then ultraschall.AddErrorMessage("RemoveMediaItemByGUID_TrackStateChunk", "trackstatechunk", "only trackstatechunk is allowed", -1) return false end
  if trackstatechunk:match("<TRACK.*>")==nil then ultraschall.AddErrorMessage("RemoveMediaItemByGUID_TrackStateChunk", "trackstatechunk", "no valid trackstatechunk", -2) return false end
  local nums=ultraschall.CountItemsInTrackStateChunk(trackstatechunk)
  local begin=trackstatechunk:match("(.-)<ITEM.*")
  trackstatechunk=trackstatechunk:match("<ITEM.*")
  if trackstatechunk==nil then ultraschall.AddErrorMessage("RemoveMediaItemByGUID_TrackStateChunk", "trackstatechunk", "no items in trackstatechunk", -3) return false end
  local count=0
  local temptrackstatechunk=""
  local dada
  for i=1,nums do
    local L,M=ultraschall.GetItemStateChunkFromTrackStateChunk(trackstatechunk, i)
    if ultraschall.GetItemGUID(M)~=GUID then temptrackstatechunk=temptrackstatechunk..M 
    else 
    end
  end
  local lt=ultraschall.CountCharacterInString(begin..temptrackstatechunk,"<")
  local gt=ultraschall.CountCharacterInString(begin..temptrackstatechunk,">")
  if gt<lt then dada=">\n" else dada="" end
  return true, begin..temptrackstatechunk..dada
end

function ultraschall.SetMediaItemStateChunk_in_TrackStateChunk(trackstatechunk, idx, mediaitemstatechunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetMediaItemStateChunk_in_TrackStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string trackstatechunk = ultraschall.SetMediaItemStateChunk_in_TrackStateChunk(string trackstatechunk, integer idx, string mediaitemstatechunk)</functioncall>
  <description>
    Overwrites the idx'th item from trackstatechunk with mediaitemstatechunk and returns this altered trackstatechunk.
    
    returns false in case of error
  </description>
  <parameters>
    string trackstatechunk - a trackstatechunk, as returned by reaper's api function reaper.GetTrackStateChunk
    integer idx - the number of the item you want to delete
    string mediaitemstatechunk - a mediaitemstatechunk, as returned by reaper's api function reaper.GetItemStateChunk
  </parameters>
  <retvals>
    boolean retval - true in case of success, false in case of error
    string trackstatechunk - the new trackstatechunk with the idx'th item replaced
  </retvals>
  <chapter_context>
    MediaItem Management
    Set MediaItem States
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>mediaitemmanagement, tracks, media, item, statechunk, chunk, set</tags>
</US_DocBloc>
]]
  if type(trackstatechunk)~="string" then ultraschall.AddErrorMessage("SetMediaItemStateChunk_in_TrackStateChunk", "trackstatechunk", "only trackstatechunk is allowed, not "..type(trackstatechunk), -1) return false end
  if type(mediaitemstatechunk)~="string" then ultraschall.AddErrorMessage("SetMediaItemStateChunk_in_TrackStateChunk", "mediaitemstatechunk", "only mediaitemstatechunk is allowed, not "..type(mediaitemstatechunk), -2) return false end
  local nums=ultraschall.CountItemsInTrackStateChunk(trackstatechunk)
  if nums==-1 then ultraschall.AddErrorMessage("SetMediaItemStateChunk_in_TrackStateChunk", "trackstatechunk", "only trackstatechunk is allowed", -3) return false end
  if nums<idx then ultraschall.AddErrorMessage("SetMediaItemStateChunk_in_TrackStateChunk", "idx", "only "..nums.." items in trackstatechunk", -4) return false end
  if idx<1 then ultraschall.AddErrorMessage("SetMediaItemStateChunk_in_TrackStateChunk", "idx", "only positive values allowed, beginning with 1", -5) return false end
  if mediaitemstatechunk:match("<ITEM.*>")==nil then ultraschall.AddErrorMessage("SetMediaItemStateChunk_in_TrackStateChunk", "mediaitemstatechunk", "not a valid mediaitemstatechunk", -6) return false end
  local begin=trackstatechunk:match("(.-)<ITEM.*")
  trackstatechunk=trackstatechunk:match("<ITEM.*")
  if trackstatechunk==nil then ultraschall.AddErrorMessage("SetMediaItemStateChunk_in_TrackStateChunk", "trackstatechunk", "no valid trackstatechunk", -7) return false end
  local count=0
  local add
  local temptrackstatechunk=""
  while trackstatechunk:match("<ITEM")~=nil do
    count=count+1
    if count~=idx then
      local temptrackstatechunk2=trackstatechunk:match("(<ITEM.-)<ITEM")
      if temptrackstatechunk2==nil then temptrackstatechunk2=trackstatechunk:match("(<ITEM.*)") end
      temptrackstatechunk=temptrackstatechunk..temptrackstatechunk2
    else
      temptrackstatechunk=temptrackstatechunk..mediaitemstatechunk
    end
    trackstatechunk=trackstatechunk:match("<ITEM.-(<ITEM.*)")
    if trackstatechunk==nil then break end 
  end
  if idx==nums then add=">" 
  else add=""
  end
  return true, begin..temptrackstatechunk..add
end


function ultraschall.GetVideoHWND()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetVideoHWND</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.965
    JS=0.963
    Lua=5.3
  </requires>
  <functioncall>HWND hwnd = ultraschall.GetVideoHWND()</functioncall>
  <description>
    returns the HWND of the Video window, if the window is opened.
    
    due API-limitations on Mac and Linux: if more than one window called "Video Window" is opened, it will return -1
    I hope to find a workaround for that problem at some point...
    
    returns nil if the Video Window is closed or can't be determined
  </description>
  <retvals>
    HWND hwnd - the window-handler of the Video Window
  </retvals>
  <chapter_context>
    User Interface
    Reaper-Windowhandler
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>user interface, window, hwnd, video, get</tags>
</US_DocBloc>
--]]
  local translation=reaper.JS_Localize("Video Window", "common")
  local count_hwnds, hwnd_array, hwnd_adresses = ultraschall.Windows_Find(translation, true)
  if count_hwnds==0 then return nil
  elseif reaper.GetOS():match("Win")~=nil then
    for i=count_hwnds, 1, -1 do
      if reaper.JS_Window_GetClassName(hwnd_array[i], "")=="REAPERVideoMainwnd" then 
        local retval, left, top, right, bottom = reaper.JS_Window_GetClientRect(hwnd_array[i])
        return hwnd_array[i], left, top, right, bottom
      end
    end
  else 
    if count_hwnds==1 then
      return hwnd_array[1]
    else
      ultraschall.AddErrorMessage("GetVideoHWND", "", "more than one window called Video Window opened. Can't determine the right one...sorry", -1)
      return nil
    end
  end
  return nil
end

function ultraschall.SetMarkerByIndex(idx, searchisrgn, shown_number, pos, rgnend, name, color, flags)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetMarkerByIndex</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.77
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetMarkerByIndex(integer idx, boolean searchisrgn, integer shown_number, number position, position rgnend, string name, integer color, integer flags)</functioncall>
  <description>
    Sets the values of a certain marker/region. The numbering of idx is either only for the markers or for regions, depending on what you set with parameter searchisrgn.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, setting the marker/region was successful; false, setting of the marker/region was unsuccessful.
  </retvals>
  <parameters>
    integer idx - the number of the requested marker/region; counts only within either markers or regions, depending on what you've set searchisrgn to
    boolean searchisrgn - true, search only within regions; false, search only within markers
    integer shown_number - the shown-number of the region/marker; no duplicate numbers for regions allowed; nil to keep previous shown_number
    number position - the position of the marker/region in seconds; nil to keep previous position
    position rgnend - the end of the region in seconds; nil to keep previous region-end
    string name - the name of the marker/region; nil to keep the previous name
    integer color - color should be 0 to not change, or ColorToNative(r,g,b)|0x1000000; nil to keep the previous color
    integer flags - flags&1 to clear name; 0, keep it; nil to use the previous setting
  </parameters>
  <chapter_context>
    Markers
    General Markers and Regions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>markermanagement, set, marker, region, index, color, name, position, regionend, shownnumber, shown</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(idx)~="integer" then ultraschall.AddErrorMessage("SetMarkerByIndex", "idx", "must be an integer", -1) return false end
  if type(searchisrgn)~="boolean" then ultraschall.AddErrorMessage("SetMarkerByIndex", "searchisrgn", "must be boolean", -2) return false end
  if math.type(shown_number)~="integer" then ultraschall.AddErrorMessage("SetMarkerByIndex", "shown_number", "must be an integer", -3) return false end
  if type(pos)~="number" then ultraschall.AddErrorMessage("SetMarkerByIndex", "pos", "must be a number", -4) return false end
  if type(rgnend)~="number" then ultraschall.AddErrorMessage("SetMarkerByIndex", "rgnend", "must be a number", -5) return false end
  if type(name)~="string" then ultraschall.AddErrorMessage("SetMarkerByIndex", "name", "must be a string", -5) return false end
  if math.type(color)~="integer" then ultraschall.AddErrorMessage("SetMarkerByIndex", "color", "must be an integer", -6) return false end
  if math.type(flags)~="integer" then ultraschall.AddErrorMessage("SetMarkerByIndex", "flags", "must be an integer", -7) return false end

  -- prepare variable
  local markercount=0
  
  -- search and set marker/region
  for i=0, reaper.CountProjectMarkers(0)-1 do
    local retval2, isrgn, pos2, rgnend2, name2, markrgnindexnumber2, color2 = reaper.EnumProjectMarkers3(0,i)
    
    -- count marker/region
    if searchisrgn==isrgn then markercount=markercount+1 end
    if searchisrgn==isrgn and isrgn==true and markercount==idx then
      -- if the correct region has been found, change it
      if shown_number==nil then shown_number=markrgnindexnumber2 end
      if pos==nil then pos=pos2 end
      if rgnend==nil then rgnend=rgnend2 end
      if name==nil then name=name2 end
      if color==nil then color=color2 end
      return reaper.SetProjectMarkerByIndex2(0, i, true, pos, rgnend, shown_number, name, color, 0)
    end
    if searchisrgn==isrgn and isrgn==false and markercount==idx then 
      -- if the correct marker has been found, change it
      if shown_number==nil then shown_number=markrgnindexnumber2 end
      if pos==nil then pos=pos2 end
      if rgnend==nil then rgnend=rgnend2 end
      if name==nil then name=name2 end
      if color==nil then color=color2 end
      return reaper.SetProjectMarker4(0, i, false, pos, rgnend, name, color, flags) 
    end
  end
  
  -- if no such marker/region has been found
  if searchisrgn==true then ultraschall.AddErrorMessage("SetMarkerByIndex", "idx", "no such region", -8) return false end
  if searchisrgn==false then ultraschall.AddErrorMessage("SetMarkerByIndex", "idx", "no such marker", -9) return false end
  return false
end

function ultraschall.DeleteNormalMarker(number)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DeleteNormalMarker</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall> boolean retval = ultraschall.DeleteNormalMarker(integer number)</functioncall>
  <description>
    Deletes a Normal-Marker. Returns true if successful and false if not(i.e. marker doesn't exist) Use <a href="#EnumerateNormalMarkers">ultraschall.EnumerateNormalMarkers</a> to get the correct number.
    
    Normal markers are all markers, that don't include "_Shownote:" or "_Edit" in the beginning of their name, as well as markers with the color 100,255,0(planned chapter).
    
    returns -1 in case of an error
  </description>
  <parameters>
    integer number - number of a normal marker
  </parameters>
  <retvals>
     boolean retval  - true, if successful, false if not
  </retvals>
  <chapter_context>
    Markers
    Normal Markers
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>markermanagement, marker, delete, normal marker, normal</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(number)~="integer" then ultraschall.AddErrorMessage("DeleteNormalMarker", "number", "must be a number", -1) return false end

  -- prepare variables
  local c,nummarkers,b=reaper.CountProjectMarkers(0)
  local number=number-1
  local wentfine=0
  local count=-1
  local retnumber=0
  
  -- look for the right normal marker
  for i=1, c-1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if isrgn==false then
      if name:sub(1,10)~="_Shownote:" and name:sub(1,5)~="_Edit" and color~=ultraschall.ConvertColor(100,255,0) then count=count+1 end
    end
    if number>=0 and wentfine==0 and count==number then
        retnumber=i
        wentfine=1
    end
  end
  
  -- remove the found normal-marker, if existing
  if wentfine==1 then return reaper.DeleteProjectMarkerByIndex(0, retnumber)
  else ultraschall.AddErrorMessage("DeleteNormalMarker", "number", "no such normal-marker found", -2) return false
  end
end

function ultraschall.DeleteEditMarker(number)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DeleteEditMarker</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall> boolean retval = ultraschall.DeleteEditMarker(integer edit_index)</functioncall>
  <description>
    Deletes an _Edit:-Marker. Returns true if successful and false if not(i.e. marker doesn't exist) Use <a href="#EnumerateEditMarkers">ultraschall.EnumerateEditMarkers</a> to get the correct number.
  </description>
  <parameters>
    integer edit_index - number of an edit marker
  </parameters>
  <retvals>
     boolean retval  - true, if successful, false if not
  </retvals>
  <chapter_context>
    Markers
    Edit Markers and Regions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>markermanagement, marker, delete, edit marker, edit</tags>
</US_DocBloc>
--]]
  -- check parameters
  if math.type(number)~="integer" then ultraschall.AddErrorMessage("DeleteEditMarker", "edit_index", "must be integer", -1) return false end
  
  -- prepare variables
  number=number-1
  local wentfine=0
  local count=-1
  local retnumber=0
  local c,nummarkers,b=reaper.CountProjectMarkers(0)
  
  -- look for correct _Edit-marker
  for i=0, c-1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if name:sub(1,5)=="_Edit" then count=count+1 end 
    if number>=0 and wentfine==0 and count==number then 
        retnumber=i
        wentfine=1
    end
  end
  
  -- remove found _Edit-marker, if any
  if wentfine==1 then return reaper.DeleteProjectMarkerByIndex(0, retnumber)
  else ultraschall.AddErrorMessage("DeleteEditMarker", "edit_index", "no such _Edit-marker found", -2) return false
  end
end

function ultraschall.EnumerateEditRegion(number)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>EnumerateEditRegion</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval, number position, number endposition, string title, integer rgnindexnumber = ultraschall.EnumerateEditRegion(integer number)</functioncall>
  <description>
    Returns the values of an edit-region.
    
    returns -1 in case of an error
  </description>
  <retvals>
    integer retval - the overall marker-index-number of all markers in the project, -1 in case of error
    number position - position in seconds
    number endposition - endposition in seconds
    string title - the title of the region
    integer rgnindexnumber - the overall region index number, as used by other of Reaper's own marker-functions
  </retvals>
  <parameters>
    integer number - the number of the edit-region, beginning with 1 for the first edit-region
  </parameters>
  <chapter_context>
    Markers
    Edit Markers and Regions
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>markermanagement, navigation, get, enumerate, edit region, edit, region</tags>
</US_DocBloc>
]]   
  if math.type(number)~="integer" then ultraschall.AddErrorMessage("EnumerateEditRegion","number", "must be an integer", -1) return -1 end
  
  local c,nummarkers,b=reaper.CountProjectMarkers(0)
  number=tonumber(number)-1
  local wentfine=-1
  local count=-1
  local retnumber=0
  for i=0, c-1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if isrgn==true then
      if name:sub(1,5)=="_Edit" then count=count+1  
        if count==number then wentfine=i end
      end
    end
  end
  local retval, isrgn, pos, rgnend, name, markrgnindexnumber=reaper.EnumProjectMarkers(wentfine)
  if wentfine~=-1 then return retval, pos, rgnend, name, markrgnindexnumber
  else return -1
  end
end

function ultraschall.ApplyRenderTable_Project(RenderTable, apply_rendercfg_string)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ApplyRenderTable_Project</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.975
    SWS=2.10.0.1
    JS=0.972
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ApplyRenderTable_Project(RenderTable RenderTable, optional boolean apply_rendercfg_string)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Sets all stored render-settings from a RenderTable as the current project-settings.
            
    Expected table is of the following structure:
            RenderTable["AddToProj"] - Add rendered items to new tracks in project-checkbox; true, checked; false, unchecked
            RenderTable["Bounds"] - 0, Custom time range; 1, Entire project; 2, Time selection; 3, Project regions; 4, Selected Media Items(in combination with Source 32); 5, Selected regions
            RenderTable["Channels"] - the number of channels in the rendered file; 1, mono; 2, stereo; higher, the number of channels
            RenderTable["CloseAfterRender"] - true, close rendering to file-dialog after render; false, don't close it
            RenderTable["Dither"] - &1, dither master mix; &2, noise shaping master mix; &4, dither stems; &8, dither noise shaping
            RenderTable["Endposition"] - the endposition of the rendering selection in seconds
            RenderTable["MultiChannelFiles"] - Multichannel tracks to multichannel files-checkbox; true, checked; false, unchecked
            RenderTable["OfflineOnlineRendering"] - Offline/Online rendering-dropdownlist; 0, Full-speed Offline; 1, 1x Offline; 2, Online Render; 3, Online Render(Idle); 4, Offline Render(Idle)
            RenderTable["OnlyMonoMedia"] - Tracks with only mono media to mono files-checkbox; true, checked; false, unchecked
            RenderTable["ProjectSampleRateFXProcessing"] - Use project sample rate for mixing and FX/synth processing-checkbox; true, checked; false, unchecked
            RenderTable["RenderFile"] - the contents of the Directory-inputbox of the Render to File-dialog
            RenderTable["RenderPattern"] - the render pattern as input into the File name-inputbox of the Render to File-dialog
            RenderTable["RenderQueueDelay"] - Delay queued render to allow samples to load-checkbox; true, checked; false, unchecked
            RenderTable["RenderQueueDelaySeconds"] - the amount of seconds for the render-queue-delay
            RenderTable["RenderResample"] - Resample mode-dropdownlist; 0, Medium (64pt Sinc); 1, Low (Linear Interpolation); 2, Lowest (Point Sampling); 3, Good (192pt Sinc); 4, Better (348 pt Sinc); 5, Fast (IIR + Linear Interpolation); 6, Fast (IIRx2 + Linear Interpolation); 7, Fast (16pt Sinc); 8, HQ (512 pt); 9, Extreme HQ(768pt HQ Sinc)
            RenderTable["RenderString"] - the render-cfg-string, that holds all settings of the currently set render-ouput-format as BASE64 string
            RenderTable["RenderTable"]=true - signals, this is a valid render-table
            RenderTable["SampleRate"] - the samplerate of the rendered file(s)
            RenderTable["SaveCopyOfProject"] - the "Save copy of project to outfile.wav.RPP"-checkbox; true, checked; false, unchecked
            RenderTable["SilentlyIncrementFilename"] - Silently increment filenames to avoid overwriting-checkbox; true, checked; false, unchecked
            RenderTable["Source"] - 0, Master mix; 1, Master mix + stems; 3, Stems (selected tracks); 8, Region render matrix; 16, Tracks with only Mono-Media to Mono Files; 32, Selected media items
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
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>projectfiles, set, project, rendertable</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidRenderTable(RenderTable)==false then ultraschall.AddErrorMessage("ApplyRenderTable_Project", "RenderTable", "not a valid RenderTable", -1) return false end
  if apply_rendercfg_string~=nil and type(apply_rendercfg_string)~="boolean" then ultraschall.AddErrorMessage("ApplyRenderTable_Project", "apply_rendercfg_string", "must be boolean", -2) return false end
  local _temp, retval, hwnd, AddToProj, ProjectSampleRateFXProcessing, ReaProject, SaveCopyOfProject, retval
  if ReaProject==nil then ReaProject=0 end
  --[[
  if ultraschall.type(ReaProject)~="ReaProject" and math.type(ReaProject)~="integer" then ultraschall.AddErrorMessage("ApplyRenderTable_Project", "ReaProject", "no such project available, must be either a ReaProject-object or the projecttab-number(1-based)", -1) return nil end
  if ReaProject==-1 then ReaProject=0x40000000 _temp=true 
  elseif ReaProject<-2 then 
    ultraschall.AddErrorMessage("GetRenderTable_Project", "ReaProject", "no such project-tab available, must be 0, for the current; 1, for the first, etc; -1, for the currently rendering project", -3) return nil 
  end
  
  if math.type(ReaProject)=="integer" then ReaProject=reaper.EnumProjects(ReaProject-1, "") end
  if ReaProject==nil and _temp~=true then 
    ultraschall.AddErrorMessage("GetRenderTable_Project", "ReaProject", "no such project available, must be either a ReaProject-object or the projecttab-number(1-based)", -4) return nil 
  elseif _temp==true then
    ultraschall.AddErrorMessage("GetRenderTable_Project", "ReaProject", "no project currently rendering", -5) return nil 
  end
  --]]
  if RenderTable["MultiChannelFiles"]==true then RenderTable["Source"]=RenderTable["Source"]+4 end
  if RenderTable["OnlyMonoMedia"]==true then RenderTable["Source"]=RenderTable["Source"]+16 end
  reaper.GetSetProjectInfo(ReaProject, "RENDER_SETTINGS", RenderTable["Source"], true)

  reaper.GetSetProjectInfo(ReaProject, "RENDER_BOUNDSFLAG", RenderTable["Bounds"], true)
  reaper.GetSetProjectInfo(ReaProject, "RENDER_CHANNELS", RenderTable["Channels"], true)
  reaper.GetSetProjectInfo(ReaProject, "RENDER_SRATE", RenderTable["SampleRate"], true)
  
  reaper.GetSetProjectInfo(ReaProject, "RENDER_STARTPOS", RenderTable["Startposition"], true)
  reaper.GetSetProjectInfo(ReaProject, "RENDER_ENDPOS", RenderTable["Endposition"], true)
  reaper.GetSetProjectInfo(ReaProject, "RENDER_TAILFLAG", RenderTable["TailFlag"], true)
  reaper.GetSetProjectInfo(ReaProject, "RENDER_TAILMS", RenderTable["TailMS"], true)
  
  if RenderTable["AddToProj"]==true then AddToProj=1 else AddToProj=0 end
  --print2(AddToProj)
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
    Ultraschall=4.00
    Reaper=5.975
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
            RenderTable["Dither"] - &1, dither master mix; &2, noise shaping master mix; &4, dither stems; &8, dither noise shaping
            RenderTable["Endposition"] - the endposition of the rendering selection in seconds
            RenderTable["MultiChannelFiles"] - Multichannel tracks to multichannel files-checkbox; true, checked; false, unchecked
            RenderTable["OfflineOnlineRendering"] - Offline/Online rendering-dropdownlist; 0, Full-speed Offline; 1, 1x Offline; 2, Online Render; 3, Online Render(Idle); 4, Offline Render(Idle);  
            RenderTable["OnlyMonoMedia"] - Tracks with only mono media to mono files-checkbox; true, checked; false, unchecked
            RenderTable["ProjectSampleRateFXProcessing"] - Use project sample rate for mixing and FX/synth processing-checkbox; true, checked; false, unchecked
            RenderTable["RenderFile"] - the contents of the Directory-inputbox of the Render to File-dialog
            RenderTable["RenderPattern"] - the render pattern as input into the File name-inputbox of the Render to File-dialog
            RenderTable["RenderQueueDelay"] - Delay queued render to allow samples to load-checkbox
            RenderTable["RenderQueueDelaySeconds"] - the amount of seconds for the render-queue-delay
            RenderTable["RenderResample"] - Resample mode-dropdownlist; 0, Medium (64pt Sinc); 1, Low (Linear Interpolation); 2, Lowest (Point Sampling); 3, Good (192pt Sinc); 4, Better (348 pt Sinc); 5, Fast (IIR + Linear Interpolation); 6, Fast (IIRx2 + Linear Interpolation); 7, Fast (16pt Sinc); 8, HQ (512 pt); 9, Extreme HQ(768pt HQ Sinc)
            RenderTable["RenderString"] - the render-cfg-string, that holds all settings of the currently set render-ouput-format as BASE64 string
            RenderTable["RenderTable"]=true - signals, this is a valid render-table
            RenderTable["SampleRate"] - the samplerate of the rendered file(s)
            RenderTable["SaveCopyOfProject"] - the "Save copy of project to outfile.wav.RPP"-checkbox; ignored, as this can't be stored in projectfiles
            RenderTable["SilentlyIncrementFilename"] - Silently increment filenames to avoid overwriting-checkbox; ignored, as this can't be stored in projectfiles
            RenderTable["Source"] - 0, Master mix; 1, Master mix + stems; 3, Stems (selected tracks); 8, Region render matrix; 16, Tracks with only Mono-Media to Mono Files; 32, Selected media items
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
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
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
  
  if RenderTable["MultiChannelFiles"]==true then RenderTable["Source"]=RenderTable["Source"]+4 end
  if RenderTable["OnlyMonoMedia"]==true then RenderTable["Source"]=RenderTable["Source"]+16 end
  retval, ProjectStateChunk = ultraschall.SetProject_RenderStems(nil, RenderTable["Source"], ProjectStateChunk)
  retval, ProjectStateChunk = ultraschall.SetProject_RenderRange(nil, RenderTable["Bounds"], RenderTable["Startposition"], RenderTable["Endposition"], RenderTable["TailFlag"], RenderTable["TailMS"], ProjectStateChunk)  
  retval, ProjectStateChunk = ultraschall.SetProject_RenderFreqNChans(nil, 0, RenderTable["Channels"], RenderTable["SampleRate"], ProjectStateChunk)

  if RenderTable["AddToProj"]==true then AddToProj=1 else AddToProj=0 end  
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
    retval, ProjectStateChunk = ultraschall.SetProject_RenderCFG(nil, RenderTable["RenderString"], ProjectStateChunk)
  end
  
  if projectfilename_with_path~=nil then ultraschall.WriteValueToFile(projectfilename_with_path, ProjectStateChunk) return true, ProjectStateChunk
  else return true, ProjectStateChunk
  end
end

function ultraschall.GetRenderPreset_RenderTable(Bounds_Name, Options_and_Format_Name)
 --[[
 <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
   <slug>GetRenderPreset_RenderTable</slug>
   <requires>
     Ultraschall=4.00
     Reaper=5.975
     Lua=5.3
   </requires>
   <functioncall>RenderTable RenderTable = ultraschall.GetRenderPreset_RenderTable(string Bounds_Name, string Options_and_Format_Name)</functioncall>
   <description markup_type="markdown" markup_version="1.0.1" indent="default">
     returns a rendertable, that contains all settings of a specific render-preset.
    
     use [GetRenderPreset_Names](#GetRenderPreset_Names) to get the available render-preset-names.
     
     Some settings aren't stored in Presets and will get default values:
     TailMS=0, SilentlyIncrementFilename=false, AddToProj=false, SaveCopyOfProject=false, RenderQueueDelay=false, RenderQueueDelaySeconds=false
     
     returned table if of the following format:
     
     RenderTable["AddToProj"] - Add rendered items to new tracks in project-checkbox; always false, as this isn't stored in render-presets
     RenderTable["Bounds"] - 0, Custom time range; 1, Entire project; 2, Time selection; 3, Project regions; 4, Selected Media Items(in combination with Source 32); 5, Selected regions
     RenderTable["Channels"] - the number of channels in the rendered file; 1, mono; 2, stereo; higher, the number of channels
     RenderTable["CloseAfterRender"] - close rendering to file-dialog after rendering; always true, as this isn't stored in render-presets
     RenderTable["Dither"] - &1, dither master mix; &2, noise shaping master mix; &4, dither stems; &8, dither noise shaping
     RenderTable["Endposition"] - the endposition of the rendering selection in seconds
     RenderTable["MultiChannelFiles"] - Multichannel tracks to multichannel files-checkbox; true, checked; false, unchecked
     RenderTable["OfflineOnlineRendering"] - Offline/Online rendering-dropdownlist; 0, Full-speed Offline; 1, 1x Offline; 2, Online Render; 3, Online Render(Idle); 4, Offline Render(Idle)
     RenderTable["OnlyMonoMedia"] - Tracks with only mono media to mono files-checkbox; true, checked; false, unchecked
     RenderTable["ProjectSampleRateFXProcessing"] - Use project sample rate for mixing and FX/synth processing-checkbox; true, checked; false, unchecked
     RenderTable["RenderFile"] - the contents of the Directory-inputbox of the Render to File-dialog
     RenderTable["RenderPattern"] - the render pattern as input into the File name-inputbox of the Render to File-dialog
     RenderTable["RenderQueueDelay"] - Delay queued render to allow samples to load-checkbox; always false, as this isn't stored in render-presets
     RenderTable["RenderQueueDelaySeconds"] - the amount of seconds for the render-queue-delay; always 0, as this isn't stored in render-presets
     RenderTable["RenderResample"] - Resample mode-dropdownlist; 0, Medium (64pt Sinc); 1, Low (Linear Interpolation); 2, Lowest (Point Sampling); 3, Good (192pt Sinc); 4, Better (348 pt Sinc); 5, Fast (IIR + Linear Interpolation); 6, Fast (IIRx2 + Linear Interpolation); 7, Fast (16pt Sinc); 8, HQ (512 pt); 9, Extreme HQ(768pt HQ Sinc)
     RenderTable["RenderString"] - the render-cfg-string, that holds all settings of the currently set render-ouput-format as BASE64 string
     RenderTable["RenderTable"]=true - signals, this is a valid render-table
     RenderTable["SampleRate"] - the samplerate of the rendered file(s)
     RenderTable["SaveCopyOfProject"] - the "Save copy of project to outfile.wav.RPP"-checkbox; always false, as this isn't stored in render-presets
     RenderTable["SilentlyIncrementFilename"] - Silently increment filenames to avoid overwriting-checkbox; always true, as this isn't stored in Presets
     RenderTable["Source"] - 0, Master mix; 1, Master mix + stems; 3, Stems (selected tracks); 8, Region render matrix; 16, Tracks with only Mono-Media to Mono Files; 32, Selected media items
     RenderTable["Startposition"] - the startposition of the rendering selection in seconds
     RenderTable["TailFlag"] - in which bounds is the Tail-checkbox checked? &1, custom time bounds; &2, entire project; &4, time selection; &8, all project regions; &16, selected media items; &32, selected project regions
     RenderTable["TailMS"] - the amount of milliseconds of the tail; always 0, as this isn't stored in render-presets
     
     
     Returns nil in case of an error
   </description>
   <parameters>
     string Bounds_Name - the name of the Bounds-render-preset you want to get
     string Options_and_Format_Name - the name of the Renderformat-options-render-preset you want to get
   </parameters>
   <retvals>
     RenderTable RenderTable - a render-table, which contains all settings from a render-preset
   </retvals>
   <chapter_context>
      Rendering Projects
      Render Presets
   </chapter_context>
   <target_document>US_Api_Documentation</target_document>
   <source_document>ultraschall_functions_engine.lua</source_document>
   <tags>render management, get, render preset, names</tags>
 </US_DocBloc>
 ]]
  if type(Bounds_Name)~="string" then ultraschall.AddErrorMessage("GetRenderPreset_RenderTable", "Bounds_Name", "must be a string", -1) return end
  if type(Options_and_Format_Name)~="string" then ultraschall.AddErrorMessage("GetRenderPreset_RenderTable", "Options_and_Format_Name", "must be a string", -2) return end
  local A=ultraschall.ReadFullFile(reaper.GetResourcePath().."/reaper-render.ini")
  if A==nil then A="" end
  if Bounds_Name:match("%s")~=nil then Bounds_Name="\""..Bounds_Name.."\"" end
  if Options_and_Format_Name:match("%s")~=nil then Options_and_Format_Name="\""..Options_and_Format_Name.."\"" end
  
  local Bounds=A:match("RENDERPRESET_OUTPUT "..Bounds_Name.." (.-)\n")
  if Bounds==nil then ultraschall.AddErrorMessage("GetRenderPreset_RenderTable", "Bounds_Name", "no such Bounds-preset available", -3) return end
  
  local RenderFormatOptions=A:match("<RENDERPRESET "..Options_and_Format_Name.." (.-\n>)\n")
  if RenderFormatOptions==nil then ultraschall.AddErrorMessage("GetRenderPreset_RenderTable", "Options_and_Format_Name", "no such Render-Format-preset available", -4) return end
  
  local SampleRate, channels, offline_online_dropdownlist, 
  useprojectsamplerate_checkbox, resamplemode_dropdownlist, 
  dither, rendercfg = RenderFormatOptions:match("(.-) (.-) (.-) (.-) (.-) (.-) (.-) (.-)")
  rendercfg = RenderFormatOptions:match("\n%s*(.*)\n")

  local bounds_dropdownlist, start_position, endposition, source_dropdownlist_and_checkboxes, 
  unknown, outputfilename_renderpattern, tails_checkbox = Bounds:match("(.-) (.-) (.-) (.-) (.-) (.-) (.*)")
  
  local MultiChannel, MonoMedia
  
  if source_dropdownlist_and_checkboxes&4==0 then 
    MultiChannel=false 
  else 
    MultiChannel=true 
    source_dropdownlist_and_checkboxes=source_dropdownlist_and_checkboxes-4
  end
  if source_dropdownlist_and_checkboxes&16==0 then 
    MonoMedia=false 
  else 
    MonoMedia=true 
    source_dropdownlist_and_checkboxes=math.floor(source_dropdownlist_and_checkboxes-16)
  end
  
  if useprojectsamplerate_checkbox==0 then useprojectsamplerate_checkbox=false else useprojectsamplerate_checkbox=true end

  local RenderTable=ultraschall.CreateNewRenderTable(source_dropdownlist_and_checkboxes, tonumber(bounds_dropdownlist), tonumber(start_position),
                                               tonumber(endposition), tonumber(tails_checkbox), 0, "", outputfilename_renderpattern, 
                                               tonumber(SampleRate), tonumber(channels), tonumber(offline_online_dropdownlist), 
                                               useprojectsamplerate_checkbox, 
                                               tonumber(resamplemode_dropdownlist), MonoMedia, MultiChannel, tonumber(dither), rendercfg, 
                                               true, false, false, false, 0, true)
  return RenderTable
end

function ultraschall.VID_VideoUIStateCoords2Pixels(uistate_x, uistate_y, videowindow_width, videowindow_height)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>VID_VideoUIStateCoords2Pixels</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.97
    Lua=5.3
  </requires>
  <functioncall>integer x_coordinate, integer y_coordinate = ultraschall.VID_VideoUIStateCoords2Pixels(number uistate_x, number uistate_y, integer videowindow_width, integer videowindow_height)</functioncall>
  <description>
    converts the ui_state-coordinates of the Video-Processor into pixel-coordinates within the Video Window
    
    You should add x and y-position of the Video-Processor-window, to get the actual screen-coordinates.
    
    returns nil in case of an error
  </description>
  <retvals>
    integer x_coordinate - the converted x-coordinate
    integer y_coordinate - the converted y-coordinate
  </retvals>
  <parameters>
    number uistate_x - the x-coordinate, that the function ui_get_state within the videoprocessor returns
    number uistate_y - the y-coordinate, that the function ui_get_state within the videoprocessor returns
    integer videowindow_width - the current width of the Video Window
    integer videowindow_height - the current height of the Video Window
  </parameters>
  <chapter_context>
    User Interface
    Coordinates
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>user interface, window, coordinates, pixel, ui_get_state, video-processor, convert</tags>
</US_DocBloc>
--]]
  if type(uistate_x)~="number" or (uistate_x<0 or uistate_x>1) then ultraschall.AddErrorMessage("VID_VideoUIStateCoords2Pixels", "uistate_x", "must be a number between 0 and 1", -1) return end
  if type(uistate_y)~="number" or (uistate_y<0 or uistate_y>1) then ultraschall.AddErrorMessage("VID_VideoUIStateCoords2Pixels", "uistate_y", "must be a number between 0 and 1", -2) return end
  if math.type(videowindow_width)~="integer" or videowindow_width<0 then ultraschall.AddErrorMessage("VID_VideoUIStateCoords2Pixels", "videowindow_width", "must be an integer>0", -3) return end
  if math.type(videowindow_height)~="integer" or videowindow_height<0 then ultraschall.AddErrorMessage("VID_VideoUIStateCoords2Pixels", "videowindow_height", "must be an integer>0", -4) return end
  
  return uistate_x*videowindow_width, uistate_y*videowindow_height
end

function ultraschall.VID_Pixels2VideoUIStateCoords(x, y, videowindow_width, videowindow_height)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>VID_Pixels2VideoUIStateCoords</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.97
    Lua=5.3
  </requires>
  <functioncall>number uistate_x, number uistate_y = ultraschall.VID_Pixels2VideoUIStateCoords(integer x, integer y, integer videowindow_width, integer videowindow_height)</functioncall>
  <description>
    converts the ui_state-coordinates of the Video-Processor into pixel-coordinates within the Video Window
    
    You should add x and y-position of the Video-Processor-window, to get the actual screen-coordinates.
    
    returns nil in case of an error
  </description>
  <retvals>
    number x_coordinate - the converted x-coordinate, that reflects the values within the video-processor function ui_get_state
    number y_coordinate - the converted y-coordinate, that reflects the values within the video-processor function ui_get_state
  </retvals>
  <parameters>
    integer x - the x-coordinate within the Video-Window
    integer y - the y-coordinate within the Video-Window
    integer videowindow_width - the current width of the Video Window
    integer videowindow_height - the current height of the Video Window
  </parameters>
  <chapter_context>
    User Interface
    Coordinates
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>user interface, window, coordinates, pixel, ui_get_state, video-processor, convert</tags>
</US_DocBloc>
--]]
  if math.type(x)~="integer" or x<0 then ultraschall.AddErrorMessage("VID_VideoUIStateCoords2Pixels", "x", "must be an integer>0", -1) return end
  if math.type(y)~="integer" or y<0 then ultraschall.AddErrorMessage("VID_VideoUIStateCoords2Pixels", "y", "must be an integer>0", -2) return end
  if math.type(videowindow_width)~="integer" or videowindow_width<0 then ultraschall.AddErrorMessage("VID_VideoUIStateCoords2Pixels", "videowindow_width", "must be an integer>0", -3) return end
  if math.type(videowindow_height)~="integer" or videowindow_height<0 then ultraschall.AddErrorMessage("VID_VideoUIStateCoords2Pixels", "videowindow_height", "must be an integer>0", -4) return end
  
  return x/videowindow_width, x/videowindow_height
end

function ultraschall.GetProject_GetRegion(projectfilenamewithpath, idx)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetProject_GetRegion</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, integer shownnumber, number start_of_region, number end_of_region, string regionname, integer regioncolor = ultraschall.GetProject_GetRegion(string projectfilename_with_path, integer idx)</functioncall>
  <description>
    returns the information of the region idx in a projectfile.
    
    It's the entry MARKER
    
    returns false in case of error
  </description>
  <parameters>
    string projectfilename_with_path - the projectfilename from where to get the region
    integer idx - the number of the marker, you want to have the information of
  </parameters>
  <retvals>
    boolean retval - true, in case of success; false in case of failure
    integer shownnumber - the number that is shown with the region in the arrange-view
    number start_of_region - the startposition of the region in seconds
    number end_of_region - the endposition of the region in seconds
    string regionname - the name of the region. "" if no name is given.
    integer regioncolor - the colorvalue of the region
  </retvals>
  <chapter_context>
    Project-Management
    RPP-Files Get
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>projectfiles, rpp, state, get, region, shown number, name, color, position</tags>
</US_DocBloc>
]]
  if projectfilenamewithpath==nil or type(projectfilenamewithpath)~="string" then ultraschall.AddErrorMessage("GetProject_GetRegion", "projectfilename_with_path", "Must be a string", -5)  return false end
  if reaper.file_exists(projectfilenamewithpath)==false then ultraschall.AddErrorMessage("GetProject_GetRegion", "projectfilenamewithpath", "Projectfile does not exist", -1)  return false end
  idx=tonumber(idx)
  if idx==nil then ultraschall.AddErrorMessage("GetProject_GetRegion", "idx", "No valid value given. Only integer numbers are allowed.", -2)  return false end
  local A,B,C=ultraschall.GetProject_CountMarkersAndRegions(projectfilenamewithpath)
  if tonumber(idx)>B then ultraschall.AddErrorMessage("GetProject_GetRegion", "idx", "Only "..B.." regions available.", -3)  return false end
  if tonumber(idx)<1 then ultraschall.AddErrorMessage("GetProject_GetRegion", "idx", "Only positive values allowed.", -4)  return false end
  local A=ultraschall.ReadValueFromFile(projectfilenamewithpath,"MARKER", false)
  local L,LL=ultraschall.SplitStringAtLineFeedToArray(A)
  
  local regions=0
  local marker=0
  local marktemp, marktemp2
  local count=0
  for i=L,1,-1 do
    if LL[i]:match("MARKER .* (.) .- 1 .")=="0" then table.remove(LL,i) end
  end
  
  for i=1,B*2,2 do
    count=count+1
    if count==idx then
      marktemp=LL[i]
      marktemp2=LL[i+1]
    end
  end
    
  local markname
  local markid=marktemp:match("MARKER (.-) ")
  local markpos=marktemp:match("MARKER .- (.-) ")
  local markendpos=marktemp2:match("MARKER .- (.-) ")
  local marktemp=marktemp:match("MARKER .- .- (.*)")
  if marktemp:sub(1,1)=="\"" then markname=marktemp:match("\"(.-)\"") marktemp=marktemp:match("\".-\" (.*)")
  else markname=marktemp:match("(.-) ") marktemp=marktemp:match(".- (.*)")
  end
  local markcolor=marktemp:match(".- (.-) ")

  return true, markid, markpos, markendpos, markname, markcolor
end

function ultraschall.GetProject_CountMasterHWOuts(projectfilename_with_path, ProjectStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetProject_CountMasterHWOuts</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>integer count_of_hwouts = ultraschall.GetProject_CountMasterHWOuts(string projectfilename_with_path, optional string ProjectStateChunk)</functioncall>
  <description>
    returns the number of available hwouts in an rpp-project or ProjectStateChunk
    
    It's the entry MASTERHWOUT
    
    returns nil in case of an error
  </description>
  <parameters>
    string projectfilename_with_path - the projectfile+path, from which to count the master-hwouts; nil to use ProjectStateChunk
    optional string ProjectStateChunk - a statechunk of a project, usually the contents of a rpp-project-file
  </parameters>
  <retvals>
    integer count_of_hwouts - the number of available hwouts in an rpp-project or ProjectStateChunk
  </retvals>
  <chapter_context>
    Project-Management
    RPP-Files Get
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>projectmanagement, count, hwout, projectstatechunk</tags>
</US_DocBloc>
]]
  -- check parameters and prepare variable ProjectStateChunk
  if projectfilename_with_path~=nil and type(projectfilename_with_path)~="string" then ultraschall.AddErrorMessage("GetProject_CountMasterHWOuts","projectfilename_with_path", "Must be a string or nil(the latter when using parameter ProjectStateChunk)!", -1) return nil end
  if projectfilename_with_path==nil and ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("GetProject_CountMasterHWOuts","ProjectStateChunk", "No valid ProjectStateChunk!", -2) return nil end
  if projectfilename_with_path~=nil then
    if reaper.file_exists(projectfilename_with_path)==true then ProjectStateChunk=ultraschall.ReadFullFile(projectfilename_with_path, false)
    else ultraschall.AddErrorMessage("GetProject_CountMasterHWOuts","projectfilename_with_path", "File does not exist!", -3) return nil
    end
    if ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("GetProject_CountMasterHWOuts", "projectfilename_with_path", "No valid RPP-Projectfile!", -4) return nil end
  end
  local offset=""
  local count=0
  while offset~=nil do
    offset,ProjectStateChunk=ProjectStateChunk:match("MASTERHWOUT .-\n()(.*)")
    if offset~=nil then count=count+1 end
  end

  return count
end

function ultraschall.GetProject_MasterGroupFlagsState(projectfilename_with_path, ProjectStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetProject_MasterGroupFlagsState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer GroupState_as_Flags, array IndividualGroupState_Flags = ultraschall.GetProject_MasterGroupFlagsState(string projectfilename_with_path, optional stirng ProjectStateChunk)</functioncall>
  <description>
    returns the state of the group-flags for the Master-Track, as set in the menu Track Grouping Parameters; from an rpp-projectfile or a ProjectStateChunk. 
    
    Returns a 23bit flagvalue as well as an array with 32 individual 23bit-flagvalues. You must use bitoperations to get the individual values.
    
    You can reach the Group-Flag-Settings in the context-menu of a track.
    
    The groups_bitfield_table contains up to 23 entries. Every entry represents one of the checkboxes in the Track grouping parameters-dialog
    
    Each entry is a bitfield, that represents the groups, in which this flag is set to checked or unchecked.
    
    So if you want to get Volume Master(table entry 1) to check if it's set in Group 1(2^0=1) and 3(2^2=4):
      group1=groups_bitfield_table[1]&1
      group2=groups_bitfield_table[1]&4
    
    The following flags(and their accompanying array-entry-index) are available:
                           1 - Volume Master
                           2 - Volume Slave
                           3 - Pan Master
                           4 - Pan Slave
                           5 - Mute Master
                           6 - Mute Slave
                           7 - Solo Master
                           8 - Solo Slave
                           9 - Record Arm Master
                           10 - Record Arm Slave
                           11 - Polarity/Phase Master
                           12 - Polarity/Phase Slave
                           13 - Automation Mode Master
                           14 - Automation Mode Slave
                           15 - Reverse Volume
                           16 - Reverse Pan
                           17 - Do not master when slaving
                           18 - Reverse Width
                           19 - Width Master
                           20 - Width Slave
                           21 - VCA Master
                           22 - VCA Slave
                           23 - VCA pre-FX slave
    
    The GroupState_as_Flags-bitfield is a hint, if a certain flag is set in any of the groups. So, if you want to know, if VCA Master is set in any group, check if flag &1048576 (2^20) is set to 1048576.
    
    This function will work only for Groups 1 to 32. To get Groups 33 to 64, use <a href="#GetTrackGroupFlags_HighState">GetTrackGroupFlags_HighState</a> instead!
    
    It's the entry MASTER_GROUP_FLAGS
    
    returns -1 in case of failure
  </description>
  <retvals>
    integer GroupState_as_Flags - returns a flagvalue with 23 bits, that tells you, which grouping-flag is set in at least one of the 32 groups available.
    -returns -1 in case of failure
    -
    -the following flags are available:
    -2^0 - Volume Master
    -2^1 - Volume Slave
    -2^2 - Pan Master
    -2^3 - Pan Slave
    -2^4 - Mute Master
    -2^5 - Mute Slave
    -2^6 - Solo Master
    -2^7 - Solo Slave
    -2^8 - Record Arm Master
    -2^9 - Record Arm Slave
    -2^10 - Polarity/Phase Master
    -2^11 - Polarity/Phase Slave
    -2^12 - Automation Mode Master
    -2^13 - Automation Mode Slave
    -2^14 - Reverse Volume
    -2^15 - Reverse Pan
    -2^16 - Do not master when slaving
    -2^17 - Reverse Width
    -2^18 - Width Master
    -2^19 - Width Slave
    -2^20 - VCA Master
    -2^21 - VCA Slave
    -2^22 - VCA pre-FX slave
    
     array IndividualGroupState_Flags  - returns an array with 23 entries. Every entry represents one of the GroupState_as_Flags, but it's value is a flag, that describes, in which of the 32 Groups a certain flag is set.
    -e.g. If Volume Master is set only in Group 1, entry 1 in the array will be set to 1. If Volume Master is set on Group 2 and Group 4, the first entry in the array will be set to 10.
    -refer to the upper GroupState_as_Flags list to see, which entry in the array is for which set flag, e.g. array[22] is VCA pre-F slave, array[16] is Do not master when slaving, etc
    -As said before, the values in each entry is a flag, that tells you, which of the groups is set with a certain flag. The following flags determine, in which group a certain flag is set:
    -2^0 - Group 1
    -2^1 - Group 2
    -2^2 - Group 3
    -2^3 - Group 4
    -...
    -2^30 - Group 31
    -2^31 - Group 32
  </retvals>
  <parameters>
    string projectfilename_with_path - the projectfile+path, from which to get the groups-state-state; nil to use ProjectStateChunk
    optional string ProjectStateChunk - a statechunk of a project, usually the contents of a rpp-project-file
  </parameters>
  <chapter_context>
    Project-Management
    RPP-Files Get
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>projectmanagement, get, groupflags, projectstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters and prepare variable ProjectStateChunk
  if projectfilename_with_path~=nil and type(projectfilename_with_path)~="string" then ultraschall.AddErrorMessage("GetProject_MasterGroupFlagsState","projectfilename_with_path", "Must be a string or nil(the latter when using parameter ProjectStateChunk)!", -1) return -1 end
  if projectfilename_with_path==nil and ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("GetProject_MasterGroupFlagsState","ProjectStateChunk", "No valid ProjectStateChunk!", -2) return -1 end
  if projectfilename_with_path~=nil then
    if reaper.file_exists(projectfilename_with_path)==true then ProjectStateChunk=ultraschall.ReadFullFile(projectfilename_with_path, false)
    else ultraschall.AddErrorMessage("GetProject_MasterGroupFlagsState","projectfilename_with_path", "File does not exist!", -3) return -1
    end
    if ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("GetProject_MasterGroupFlagsState", "projectfilename_with_path", "No valid RPP-Projectfile!", -4) return -1 end
  end

  local Project_TrackGroupFlags=ProjectStateChunk:match("MASTER_GROUP_FLAGS.-%c") 
  if Project_TrackGroupFlags==nil then ultraschall.AddErrorMessage("GetProject_MasterGroupFlagsState", "", "no trackgroupflags available", -5) return -1 end
  
  
  -- get groupflags-state
  local retval=0  
  local GroupflagString = Project_TrackGroupFlags:match("MASTER_GROUP_FLAGS (.-)%c")
  local count, Tracktable=ultraschall.CSV2IndividualLinesAsArray(GroupflagString, " ")

  for i=1,23 do
    Tracktable[i]=tonumber(Tracktable[i])
    if Tracktable[i]~=nil and Tracktable[i]>=1 then retval=retval+2^(i-1) end
  end
  
  return retval, Tracktable
end

function ultraschall.GetProject_MasterGroupFlagsHighState(projectfilename_with_path, ProjectStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetProject_MasterGroupFlagsHighState</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer GroupState_as_Flags, array IndividualGroupState_Flags = ultraschall.GetProject_MasterGroupFlagsHighState(string projectfilename_with_path, optional stirng ProjectStateChunk)</functioncall>
  <description>
    returns the state of the group-high-flags for the Master-Track, as set in the menu Track Grouping Parameters; from an rpp-projectfile or a ProjectStateChunk. 
    
    Returns a 23bit flagvalue as well as an array with 32 individual 23bit-flagvalues. You must use bitoperations to get the individual values.
    
    You can reach the Group-Flag-Settings in the context-menu of a track.
    
    The groups_bitfield_table contains up to 23 entries. Every entry represents one of the checkboxes in the Track grouping parameters-dialog
    
    Each entry is a bitfield, that represents the groups, in which this flag is set to checked or unchecked.
    
    So if you want to get Volume Master(table entry 1) to check if it's set in Group 1(2^0=1) and 3(2^2=4):
      group1=groups_bitfield_table[1]&1
      group2=groups_bitfield_table[1]&4
    
    The following flags(and their accompanying array-entry-index) are available:
                           1 - Volume Master
                           2 - Volume Slave
                           3 - Pan Master
                           4 - Pan Slave
                           5 - Mute Master
                           6 - Mute Slave
                           7 - Solo Master
                           8 - Solo Slave
                           9 - Record Arm Master
                           10 - Record Arm Slave
                           11 - Polarity/Phase Master
                           12 - Polarity/Phase Slave
                           13 - Automation Mode Master
                           14 - Automation Mode Slave
                           15 - Reverse Volume
                           16 - Reverse Pan
                           17 - Do not master when slaving
                           18 - Reverse Width
                           19 - Width Master
                           20 - Width Slave
                           21 - VCA Master
                           22 - VCA Slave
                           23 - VCA pre-FX slave
    
    The GroupState_as_Flags-bitfield is a hint, if a certain flag is set in any of the groups. So, if you want to know, if VCA Master is set in any group, check if flag &1048576 (2^20) is set to 1048576.
    
    This function will work only for Groups 1 to 32. To get Groups 33 to 64, use <a href="#GetTrackGroupFlags_HighState">GetTrackGroupFlags_HighState</a> instead!
    
    It's the entry MASTER_GROUP_FLAGS_HIGH
    
    returns -1 in case of failure
  </description>
  <retvals>
    integer GroupState_as_Flags - returns a flagvalue with 23 bits, that tells you, which grouping-flag is set in at least one of the 32 groups available.
    -returns -1 in case of failure
    -
    -the following flags are available:
    -2^0 - Volume Master
    -2^1 - Volume Slave
    -2^2 - Pan Master
    -2^3 - Pan Slave
    -2^4 - Mute Master
    -2^5 - Mute Slave
    -2^6 - Solo Master
    -2^7 - Solo Slave
    -2^8 - Record Arm Master
    -2^9 - Record Arm Slave
    -2^10 - Polarity/Phase Master
    -2^11 - Polarity/Phase Slave
    -2^12 - Automation Mode Master
    -2^13 - Automation Mode Slave
    -2^14 - Reverse Volume
    -2^15 - Reverse Pan
    -2^16 - Do not master when slaving
    -2^17 - Reverse Width
    -2^18 - Width Master
    -2^19 - Width Slave
    -2^20 - VCA Master
    -2^21 - VCA Slave
    -2^22 - VCA pre-FX slave
    
     array IndividualGroupState_Flags  - returns an array with 23 entries. Every entry represents one of the GroupState_as_Flags, but it's value is a flag, that describes, in which of the 32 Groups a certain flag is set.
    -e.g. If Volume Master is set only in Group 1, entry 1 in the array will be set to 1. If Volume Master is set on Group 2 and Group 4, the first entry in the array will be set to 10.
    -refer to the upper GroupState_as_Flags list to see, which entry in the array is for which set flag, e.g. array[22] is VCA pre-F slave, array[16] is Do not master when slaving, etc
    -As said before, the values in each entry is a flag, that tells you, which of the groups is set with a certain flag. The following flags determine, in which group a certain flag is set:
    -2^0 - Group 1
    -2^1 - Group 2
    -2^2 - Group 3
    -2^3 - Group 4
    -...
    -2^30 - Group 31
    -2^31 - Group 32
  </retvals>
  <parameters>
    string projectfilename_with_path - the projectfile+path, from which to get the groupshigh-state-state; nil to use ProjectStateChunk
    optional string ProjectStateChunk - a statechunk of a project, usually the contents of a rpp-project-file
  </parameters>
  <chapter_context>
    Project-Management
    RPP-Files Get
  </chapter_context>
  <target_document>US_Api_Documentation</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>projectmanagement, get, groupflags, projectstatechunk</tags>
</US_DocBloc>
--]]
  -- check parameters and prepare variable ProjectStateChunk
  if projectfilename_with_path~=nil and type(projectfilename_with_path)~="string" then ultraschall.AddErrorMessage("GetProject_MasterGroupFlagsHighState","projectfilename_with_path", "Must be a string or nil(the latter when using parameter ProjectStateChunk)!", -1) return -1 end
  if projectfilename_with_path==nil and ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("GetProject_MasterGroupFlagsHighState","ProjectStateChunk", "No valid ProjectStateChunk!", -2) return -1 end
  if projectfilename_with_path~=nil then
    if reaper.file_exists(projectfilename_with_path)==true then ProjectStateChunk=ultraschall.ReadFullFile(projectfilename_with_path, false)
    else ultraschall.AddErrorMessage("GetProject_MasterGroupFlagsHighState","projectfilename_with_path", "File does not exist!", -3) return -1
    end
    if ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("GetProject_MasterGroupFlagsHighState", "projectfilename_with_path", "No valid RPP-Projectfile!", -4) return -1 end
  end

  local Project_TrackGroupFlags=ProjectStateChunk:match("MASTER_GROUP_FLAGS_HIGH.-%c") 
  if Project_TrackGroupFlags==nil then ultraschall.AddErrorMessage("GetProject_MasterGroupFlagsHighState", "", "no trackgroupflags available", -5) return -1 end
  
  
  -- get groupflags-state
  local retval=0  
  local GroupflagString = Project_TrackGroupFlags:match("MASTER_GROUP_FLAGS_HIGH (.-)%c")
  local count, Tracktable=ultraschall.CSV2IndividualLinesAsArray(GroupflagString, " ")

  for i=1,23 do
    Tracktable[i]=tonumber(Tracktable[i])
    if Tracktable[i]~=nil and Tracktable[i]>=1 then retval=retval+2^(i-1) end
  end
  
  return retval, Tracktable
end