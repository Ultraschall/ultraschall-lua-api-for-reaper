dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
Tempfile=ultraschall.Api_Path.."temp/"
ChangeLogFile="Changelog-Api.txt"
Pandoc="c:\\Program Files (x86)\\pandoc\\pandoc -f markdown -t html \""..Tempfile..ChangeLogFile.."\" -o \""..ultraschall.Api_Path.."/Documentation/ChangeLog.html\""

T=[[
<html><head><title>
Ultraschall API Changelog
</title>

</head><body>
    <div style=" position: absolute; padding-left:4%; ">
    <hr style="position:absolute; top:14%; left:4.2%; width:77%; color:#ffffff;">
    <hr style="position:absolute; top:14%; left:88.1%; width:7.0%; color:#ffffff;">
        <div style="background-color:#282828;width:95%; font-family:tahoma; font-size:16;">
           <a href="US_Introduction.html"><img style="position: absolute; left:4.2%; width:11%;" src="gfx/US_Button.png" alt="Ultraschall Internals Documentation"></a>  
           <a href="Downloads.html"><img style="position:absolute; left:74.4%; width:6.9%;" src="gfx/Downloads.png" alt="Downloads"></a>
           <a href="Changelog.html"><img style="position:absolute; left:81.3%; width:6.9%;" src="gfx/Changelog_Un.png" alt="Changelog of documentation"></a>
           <a href="Impressum.html"><img style="position:absolute; left:88.2%; width:6.9%;" src="gfx/impressum.png" alt="Impressum and Contact"></a>
           <div style="padding-top:2.5%">
           <table border="0" style="color:#aaaaaa; width:45%;">
                <tr>
                    <td style="width:30%;">
                        <a href="http://www.ultraschall.fm"><img style="width:118%;" src="gfx/US-header.png" alt="Ultraschall-logo"></a>
                    </td>
                    <td width="4%;"><u>Functions Engine</u></td>
                </tr>
                <tr>
                    <td></td>
                    <td style="background-color:#555555; color:#BBBBBB; border: 1px solid #333333; border-radius:5%/5%;"><a href="US_Api_Introduction_and_Concepts.html" style="color:#BBBBBB; text-decoration: none;">&nbsp;&nbsp;&nbsp;Introduction/Concepts&nbsp;</a></td>
                </tr>
                <tr>
                    <td></td>
                    <td style="background-color:#555555; color:#BBBBBB; border: 1px solid #333333; border-radius:5%/5%;"><a href="US_Api_Documentation.html" style="color:#BBBBBB; text-decoration: none; justify-content: center;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Functions Reference&nbsp;</a></td>
                </tr>
                <tr><td></td><tr>
                </table>
           </div>
        </div>
    </div>
    <div style="padding-left:4%; position:absolute; top:17%;">

]]

reaper.ShowConsoleMsg("Creating ChangeLog\n")

A,B,C=ultraschall.ReadFileAsLines_Array(ultraschall.Api_Path..ChangeLogFile,1,-1)

todo=nil
offset=0
string=""

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
--L="<html><head><title>Ultraschall API - Changelog</title></head><body><div style=\"padding-left:4%;\">"..L.."</div></body></html>"
L=T..L.."</div></body></html>"

ultraschall.WriteValueToFile(ultraschall.Api_Path.."/Documentation/ChangeLog.html", L)

reaper.ShowConsoleMsg("Creating Functions Reference\n")
--ALABAMA=ultraschall.CreateUSApiDocs_HTML(ultraschall.Api_Path.."/Documentation/US_Api_Documentation.html", ultraschall.Api_Path.."/ultraschall_functions_engine.lua")
ultraschall.RunCommand("_RSdd25c8bda91067981223b0efd6a4c3c07ac26a92",0)
ultraschall.RunCommand("_RSafb7013a8d8bbc8ef2b5f044da8d0fa327ac4a10")
progresscounter(false)

reaper.ShowConsoleMsg("Creating Reaper-Functions Doc\n")
if reaper.MB("Create Reaper-Docs as well?", "Reaper-Docs", 4)==6 then ultraschall.RunCommand("_RS09fa5f0d2a033e344d533043b5eeb22b7be4743c") end


--ultraschall.ShowLastErrorMessage()

--]]
