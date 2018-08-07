dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
Tempfile=ultraschall.Api_Path.."temp/"
ChangeLogFile="Changelog-Api.txt"
Pandoc="c:\\Program Files (x86)\\pandoc\\pandoc -f markdown -t html \""..Tempfile..ChangeLogFile.."\" -o \""..ultraschall.Api_Path.."/Documentation/ChangeLog.html\""


reaper.ShowConsoleMsg("Creating ChangeLog\n")

A,B,C=ultraschall.ReadFileAsLines_Array(ultraschall.Api_Path..ChangeLogFile,1,-1)
string=""
todo=nil
offset=0

for i=1, C do
    if i>C then break end
    if A[i-offset]:match("<TODO>")~=nil then todo=true end
    if A[i-offset]:match("</TODO>")~=nil then todo=false end
    
    if todo==true then 
          table.remove(A,i-offset) 
          offset=offset+1 
          C=C-1 
    elseif todo==false then
          table.remove(A,i-offset) 
          offset=offset+1 
          C=C-1
          todo=nil
    end
end

for i=1, C do
  string=string..A[i].."\n"
end
  

--os.remove(ultraschall.Api_Path.."/Documentation/ChangeLog.html")
D=ultraschall.WriteValueToFile(Tempfile..ChangeLogFile, string)
LLL,L=reaper.ExecProcess(Pandoc,0)

L=ultraschall.ReadFullFile(ultraschall.Api_Path.."/Documentation/ChangeLog.html")
L="<html><head><title>Ultraschall API - Changelog</title></head><body><div style=\"padding-left:4%;\">"..L.."</div></body></html>"

ultraschall.WriteValueToFile(ultraschall.Api_Path.."/Documentation/ChangeLog.html", L)

reaper.ShowConsoleMsg("Creating Functions Reference\n")
ALABAMA=ultraschall.CreateUSApiDocs_HTML(ultraschall.Api_Path.."/Documentation/US_Api_Documentation.html", ultraschall.Api_Path.."/ultraschall_functions_engine.lua")
progresscounter(false)

reaper.ShowConsoleMsg("Creating Reaper-Functions Doc\n")
if reaper.MB("Create Reaper-Docs as well?", "Reaper-Docs", 4)==6 then ultraschall.RunCommand("_RS611ffaa6aa18691258f60e35ea3a5188a21747c0") end


--ultraschall.ShowLastErrorMessage()

--]]
