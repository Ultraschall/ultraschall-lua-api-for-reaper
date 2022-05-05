-- Version 1.0 written by Meo-Ada Mespotine - licensed under MIT-license
-- Creates new temporary Lua-script using filename temporary_[$date].lua
-- the script will NOT be added to the actionlist, but can be edited and run anyway.

dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

date=string.gsub(os.date(), "[%s%.:]", "_")
retval, retval2 = ultraschall.EditReaScript("temporary_"..date..".lua", true)

SLEM()
