  --[[
  ################################################################################
  # 
  # Copyright (c) 2014-2021 Ultraschall (http://ultraschall.fm)
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
  --]]

dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
StartTime=reaper.time_precise()
-- increment build-version-numbering
local retval, string3 = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "API-Docs-ReaperApi", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
local retval, string2 = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "API-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
string2=tonumber(string2)
string2=string2+1
string3=tonumber(string3)
string3=string3+1
  
reaper.BR_Win32_WritePrivateProfileString("Ultraschall-Api-Build", "API-Docs-ReaperApi", string3, reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")    
reaper.BR_Win32_WritePrivateProfileString("Ultraschall-Api-Build", "API-Build", string2, reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")

-- init variables
Tempfile=ultraschall.Api_Path.."/temp/"

--Infilename=ultraschall.Api_Path.."/DocsSourcefiles/reaper-apidocs-test.USDocML"
Infilename=ultraschall.Api_Path.."/DocsSourcefiles/reaper-apidocs.USDocML"
Outfile=ultraschall.Api_Path.."/Documentation/Reaper_Api_Documentation-test.html"

-- Reaper-version and tagline from extstate
versionnumbering=reaper.GetExtState("ultraschall_api", "ReaperVerNr")
tagline=reaper.GetExtState("ultraschall_api", "Tagline")

Index=3


usD,usversion,usdate,usbeta,usTagline,usF,usG=ultraschall.GetApiVersion()
-- Let's create the Header
FunctionList=[[
<html>
  <head>
    <title>
      REAPER API functions
    </title>

    <link href="style.css" rel="stylesheet">
    <script type="text/javascript">
      function set_class_style(c,s) { 
        var list = document.getElementsByClassName(c);
        for (i=0;i<list.length;i++) {
          list[i].style.display = s; 
        }
      }
      function set_class_innerHTML(c,s) { 
        var list = document.getElementsByClassName(c);
        for (i=0;i<list.length;i++) {
          list[i].innerHTML = s; 
        }
      }
      function setdocview(v) {
        var list = new Array('c_doc', 'c_func', 'c_funcs',
                             'l_doc', 'l_func', 'l_funcs',
                             'e_doc', 'e_func', 'e_funcs',
                             'p_doc', 'p_func', 'p_funcs');
        var i;
        set_class_style('all_view', v == '' ? 'inline' : 'none');
        for (i=0;i<list.length;i++) {
          set_class_style(list[i], (v == '' || list[i].slice(0,1) == v) ? 'block' : 'none'); 
        }
        set_class_innerHTML('aclick', v=='' ? 'all' : "<a href=\"#\" onClick=\"setdocview('')\">all</a>");
        set_class_innerHTML('cclick', v=='c' ? 'C/C++' : "<a href=\"#c\" onClick=\"setdocview('c')\">C/C++</a>");
        set_class_innerHTML('eclick', v=='e' ? 'EEL2' : "<a href=\"#e\" onClick=\"setdocview('e')\">EEL2</a>");
        set_class_innerHTML('lclick', v=='l' ? 'Lua' : "<a href=\"#l\" onClick=\"setdocview('l')\">Lua</a>");
        set_class_innerHTML('pclick', v=='p' ? 'Python' : "<a href=\"#p\" onClick=\"setdocview('p')\">Python</a>");
      }
      function onLoad() {
        if (window.location.hash == '#c') setdocview('c');
        else if (window.location.hash == '#e') setdocview('e');
        else if (window.location.hash == '#l') setdocview('l');
        else if (window.location.hash == '#p') setdocview('p');
      }
    </script>
  </head>
    <body>
        <a class="anchor" id="This-is-the-TopOfTheWorld"></a>
        <div style="position: sticky; top:0; padding-left:4%; z-index:100;">
            <div style="background-color:#282828; width:95%; font-family:tahoma; font-size:16;">
                <a href="US_Api_Functions.html"><img style="position: absolute; left:4.2%; width:11%;" src="gfx/US_Button_Un.png" alt="Ultraschall Internals Documentation"></a>  
                <a href="Reaper_Api_Documentation.html"><img style="position: absolute; left:15.2%; width:8.7%;" src="gfx/Reaper_Button.png" alt="Reaper Internals Documentation"></a>
                <img alt="" style="width:6.9%; position: absolute; left:23.9%;" src="gfx/linedance.png"><img alt="" style="width:6.9%; position: absolute; left:30.8%;" src="gfx/linedance.png">
                <img alt="" style="width:6.9%; position: absolute; left:36.8%;" src="gfx/linedance.png"><img alt="" style="width:6.9%; position: absolute; left:42.8%;" src="gfx/linedance.png">
                <img alt="" style="width:6.9%; position: absolute; left:48.8%;" src="gfx/linedance.png"><img alt="" style="width:6.9%; position: absolute; left:54.8%;" src="gfx/linedance.png">
                <img alt="" style="width:6.9%; position: absolute; left:60.8%;" src="gfx/linedance.png"><img alt="" style="width:6.9%; position: absolute; left:66.8%;" src="gfx/linedance.png">
                <img alt="" style="width:6.9%; position: absolute; left:68.8%;" src="gfx/linedance.png">
                <a href="Downloads.html"><img style="position:absolute; left:74.4%; width:6.9%;" src="gfx/Downloads_Un.png" alt="Downloads"></a>
                <a href="ChangeLog.html"><img style="position:absolute; left:81.3%; width:6.9%;" src="gfx/Changelog_Un.png" alt="Changelog of documentation"></a>
                <a href="Impressum.html"><img style="position:absolute; left:88.2%; width:6.9%;" src="gfx/Impressum_Un.png" alt="Impressum and Contact"></a>
                <div style="padding-top:2.5%">                    
                    <table border="0" style="color:#aaaaaa; width:100%;">
                        <tr>
                            <td style="width:27.2%; padding-top:2; ">
                                <a href="http://www.reaper.fm"><img style="width:118%;" src="gfx/Reaper_Internals.png" alt="Reaper internals logo"></a>
                            </td>
                            <td style="position: absolute; padding-top:5; width:14%;"><u>Documentation:</u></td>
                            <td style="width:12.7%;"><u> </u></td>
                            <td style="width:12.7%;"><u> </u></td>
                            <td style="width:12%;"><u> </u></td>
                            <td style="width:12%;"><u> </u></td>
                            <td style="width:12%;"><u> </u></td>
                        </tr>
                        <tr>
                            <td></td>
                            <td style="background-color:#555555; color:#BBBBBB; border: 1px solid #333333; border-radius:5%/5%;"><a href="Reaper-Filetype-Descriptions.html" style="color:#BBBBBB; text-decoration: none; white-space:pre;">&nbsp;&nbsp;Filetype Descriptions&nbsp;</a></td>
                            <td style="background-color:#555555; color:#BBBBBB; border: 1px solid #333333; border-radius:5%/5%;"><a href="Reaper_Config_Variables.html" style="color:#BBBBBB; text-decoration: none; white-space:pre;">&nbsp;&nbsp;Config Variables&nbsp;</a></td>
                        </tr>
                        <tr>
                            <td></td>
                            <td style="background-color:#777777; color:#BBBBBB; border: 1px solid #333333; border-radius:5%/5%;"><a href="Reaper_Api_Documentation.html" style="color:#BBBBBB; text-decoration: none; justify-content: center;">&nbsp;&nbsp;&nbsp;ReaScript-Api-Docs&nbsp;</a></td>
                            <td style="background-color:#555555; color:#BBBBBB; border: 1px solid #333333; border-radius:5%/5%;"><a href="Reaper_API_Video_Documentation.html" style="color:#BBBBBB; text-decoration: none; justify-content: center;">&nbsp;&nbsp;&nbsp;Video-Api-Docs&nbsp;</a></td>
                            <td style="background-color:#555555; color:#BBBBBB; border: 1px solid #333333; border-radius:5%/5%;"><a href="Reaper_API_Web_Documentation.html" style="color:#BBBBBB; text-decoration: none; justify-content: center;">&nbsp;&nbsp;WebRC-Api-Docs&nbsp;</a></td>
                        </tr>
                        <tr>
                            <td></td>
                        </tr>
                    </table><hr color="#444444">
                    <div style="position:absolute; right:6%; top:80%;"><a style="color:#CCCCCC;" href="#This-is-the-TopOfTheWorld">Jump to Index</a></div>
                </div>
            </div>            
        </div>
<!---
End of Header
--->    <div class="chapterpad"><p></p>
]]

FunctionList=FunctionList..[[
    <hr>
    <table width="100%">
        <td style="width:30%;">View: [<span class='aclick'>all</span>] 
                  [<span class='cclick'><a href="#c" onClick="setdocview('c')">C/C++</a></span>] 
                  [<span class='eclick'><a href="#e" onClick="setdocview('e')">EEL2</a></span>] 
                  [<span class='lclick'><a href="#l" onClick="setdocview('l')">Lua</a></span>] 
                  [<span class='pclick'><a href="#p" onClick="setdocview('p')">Python</a></span>]
        </td>
        <td>&#160;
        </td>
    </table>
    <hr>]]

FunctionList=FunctionList.."<h2>Reaper Reascript-Api-Documentation "..versionnumbering.."<br>\""..tagline.."\"</h2><h3>The Functions Reference</h3>"

dofile(ultraschall.Api_Path.."/Scripts/Tools/DocGenerator/DocGenerator_v2.lua")