dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

function ultraschall.CreateReaperApiDocs_HTML(filename_with_path,LLLL)
--!!!TODO GFX-FILES müssen auch exportiert werden!!!---

--[[
<ApiDocBlocFunc>
<slug>
CreateUSApiDocs_HTML
</slug>
<requires>
Ultraschall=4.00
Reaper=5.40
SWS=2.8.8
Lua=5.3
</requires>
<functionname>
boolean retval = ultraschall.CreateUSApiDocs_HTML(string filename_with_path, string sourcefilename_with_path)
</functionname>
<description>
Creates a documentation-file for the Ultraschall-Api-Functions.
</description>
<retvals>
boolean retval - returns true, if help-creation worked; false if it failed
</retvals>
<parameters>
string filename_with_path - filename of the newly created helpfile
string sourcefilename_with_path - the name of the file, of which the docs shall be created from. nil - the Ultraschall Framework-Api
</parameters>
<semanticcontext>
Help and Documentation
Ultraschall Api-docs
</semanticcontext>
<tags>
api, docs, documentation, html, create
</tags>
</ApiDocBlocFunc>
]]
  LLL=LLLL
  functionarray={}
  local count=1
  local counter=0
  local funcindex=""
  local funclist=""
  local A,B,C,D,E,F,G,H=reaper.get_action_context()
  local L, integer
  local apiversion="5.70"
  local slug=""
  local tempparameters=""
  local scriptpath=reaper.GetResourcePath()..ultraschall.Separator.."Scripts"..ultraschall.Separator
  if LLL==nil then LLL=scriptpath.."Ultraschall_functions_api.lua" end
--  reaper.MB(LLL,"",0)
  local Path = ultraschall.GetPath(LLL, "(.*)/")
  if Path == nil then Path = ultraschall.GetPath(filename_with_path, "(.*)\\") end
  integer=reaper.RecursiveCreateDirectory(Path.."\\gfx", 0)
  
  if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx\\reaper5.40.png", Path.."gfx\\reaper5.40.png")
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx\\reaper5.50.png", Path.."gfx\\reaper5.50.png")
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx\\reaper5.52.png", Path.."gfx\\reaper5.52.png")
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx\\reaper5.62.png", Path.."gfx\\reaper5.62.png")
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx\\reaper5.70.png", Path.."gfx\\reaper5.70.png")
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx\\SWS2.8.8.png", Path.."gfx\\SWS2.8.8.png")
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx\\SWS2.9.6.png", Path.."gfx\\SWS2.9.6.png")
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx\\SWS2.9.7.png", Path.."gfx\\SWS2.9.7.png")
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx\\Lua5.3.png", Path.."gfx\\Lua5.3.png")
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx\\ultraschall4.00.png", Path.."gfx\\ultraschall4.00.png")
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx\\reaper.png", Path.."gfx\\reaper.png")
  else
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx/reaper5.40.png", Path.."gfx/reaper5.40.png")
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx/reaper5.50.png", Path.."gfx/reaper5.50.png")
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx/reaper5.52.png", Path.."gfx/reaper5.52.png")
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx/reaper5.62.png", Path.."gfx/reaper5.62.png")
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx/reaper5.70.png", Path.."gfx/reaper5.70.png")
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx/SWS2.8.8.png", Path.."gfx/SWS2.8.8.png")
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx/SWS2.9.6.png", Path.."gfx/SWS2.9.6.png")
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx/SWS2.9.7.png", Path.."gfx/SWS2.9.7.png")
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx/Lua5.3.png", Path.."gfx/Lua5.3.png")
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx/ultraschall4.00.png", Path.."gfx/ultraschall4.00.png")
    L=ultraschall.MakeCopyOfFile_Binary(scriptpath.."docgfx/reaper.png", Path.."gfx/reaper.png")
  end
    
  -- Read sourcefile and get all helpblocs
  infile=ultraschall.ReadFullFile(LLL,false)
  
--  infile=ultraschall.ReadValueFromFile(B)
--  reaper.ShowConsoleMsg(infile)
  while infile~=nil do
--    ALA=infile:match("<USDocBloc_.->")
--    reaper.ShowConsoleMsg(ALA:match(ALA:match.."\n")
    functionarray[count]=infile:match("<USDocBloc_.->.-</USDocBloc_.->")

    --if count<10 then reaper.MB(functionarray[count],"",0) end
    infile=infile:match("<USDocBloc_.->.-</USDocBloc_.->(.*)")
    if functionarray[count]==nil then infile=nil
    else
      count=count+1
    end
  end

--sort functions by semanticcontext
--  reaper.ShowConsoleMsg(functionarray[1])
  for i=1, count-1 do
--  reaper.MB(functionarray[i],i,0)
--    if tostring(functionarray[i]:match("<chapter_context>%c(.-)%c.-</chapter_context>"))~=nil then 
--    if i==196 then reaper.MB(functionarray[i],i,0) end
--      functionarray[i]=tostring(functionarray[i]:match("<chapter_context>%c(.-)%c.-</chapter_context>"))..functionarray[i]
--    end
  end

  table.sort(functionarray)

  local startfile="<html><head><title>Reaper Reascript-Api-docs "..apiversion.."</title>\n"..
  [[<script type="text/javascript">
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
  set_class_innerHTML('eclick', v=='e' ? 'EEL' : "<a href=\"#e\" onClick=\"setdocview('e')\">EEL</a>");
  set_class_innerHTML('lclick', v=='l' ? 'Lua' : "<a href=\"#l\" onClick=\"setdocview('l')\">Lua</a>");
  set_class_innerHTML('pclick', v=='p' ? 'Python' : "<a href=\"#p\" onClick=\"setdocview('p')\">Python</a>");
}
function onLoad() {
  if (window.location.hash == '#c') setdocview('c');
  else if (window.location.hash == '#e') setdocview('e');
  else if (window.location.hash == '#l') setdocview('l');
  else if (window.location.hash == '#p') setdocview('p');
  else setdocview('');
}
</script>
</head>]]

startfile=startfile.."<body onLoad='onLoad()'>\n<div style=\"padding-left:10%; width:85%;\"><img border=\"0\" src=\"gfx/reaper.png\" alt=\"\"><h2>Reaper Reascript-Api-Documentation "..apiversion.."</h2>"

--for i=1, count-1 do
--  reaper.ShowConsoleMsg(functionarray[i]:match(".-(<functionname>.-</functionname>).-"))
--end

--creating index
  local funclistarray={}
  local tingle=0
  local currentindex, currentsubindex
  funcindex="<h3>The Functions Reference</h3><table border=\"0\" style=\"font-size:10pt; width:100%;\">"
  for i=1, count-1 do
    if functionarray[i]:match("<functioncall .->(.-)</functioncall>")~=nil or functionarray[i]:match("<chapter_context>(.-)</chapter_context>") then
      funclistarray[i]=functionarray[i]:match("(<chapter_context>.-</chapter_context>)")..functionarray[i]
    end
  end
  table.sort(funclistarray)
  count=1
  local firstrun=0
  while funclistarray[count]~=nil do
  if currentindex~=funclistarray[count]:match("<chapter_context>%c(.-)%c.-</chapter_context>") then
        currentindex=funclistarray[count]:match("<chapter_context>%c(.-)%c.-</chapter_context>")
        currentsubindex=funclistarray[count]:match("<chapter_context>%c.-%c(.-)</chapter_context>")
        if firstrun==1 then funcindex=funcindex.."<tr><td>&nbsp;</td></tr>" end
        if firstrun==0 then firstrun=1 end
--        if count<20 then reaper.MB(funcindex.."LOLOLOL","",0) end
        funcindex=funcindex.."<tr><td><h3><u>"..currentindex.."</u></h3></td></tr><tr><td><strong>"..currentsubindex.."</strong></td></tr>"
        tingle=0
  elseif currentsubindex~=funclistarray[count]:match("<chapter_context>%c.-%c(.-)</chapter_context>") then
        currentsubindex=funclistarray[count]:match("<chapter_context>%c.-%c(.-)</chapter_context>")
        funcindex=funcindex.."<tr><td>&nbsp;</td></tr><tr><td><strong>"..currentsubindex.."</strong></td></tr>\n"
--        if count<20 then reaper.MB(funcindex.."ZWOLOLOLOL","",0) end
        tingle=0
  end
  tingle=tingle+1

--if count==1 then reaper.MB(funcindex.."LOLOLOL","",0) end
--  reaper.MB(count,"",0)
if funclistarray[count]:match("<slug>.-</slug>")~=nil then
  funcindex=funcindex.."<td><a href=\"#"..tostring(funclistarray[count]:match("<slug>(.-)</slug>")).."\">"..tostring(funclistarray[count]:match("<shortname>.-</shortname>")).."</a>&nbsp;&nbsp;</td>"
elseif funclistarray[count]:match("<slug>.-</slug>")~=nil then
--reaper.MB(tostring(funclistarray[count]:match("<>.-(ultraschall..-)</functionname>")),"",0)
  funcindex=funcindex.."<td><a href=\"#"..tostring(funclistarray[count]:match("<slug>(.-)</slug>")).."\">"..tostring(funclistarray[count]:match("<shortname>(.-)</shortname>")).."</a>&nbsp;&nbsp;</td>"
else
--reaper.MB("","",0)
  funcindex=funcindex.."</tr><tr><td><a href=\"#"..tostring(funclistarray[count]:match("<slug>(.-)</slug>")).."\">"..tostring(funclistarray[count]:match("<chaptername>(.-)</chaptername>")).."</a></td></tr>"
end
--  reaper.MB(tostring(funclistarray[count]:match("<slug>(.-)</slug>")),"",0)
  if tingle==4 then tingle=0 funcindex=funcindex.."</tr>\n<tr>" end
--  reaper.MB(tingle,"",0)
  count=count+1
  end

  funcindex=funcindex.."</tr></table>"

--creating entries
  for i=1, count-1 do
  local usvers,ultraschallversion,reapvers,reaperversion,swsvers,swsversion,description,luaversion,luavers
  local retvals=""  
  local parameters=""
  local tempretvals=""
  local begin=""
  tempparameters=""
    if functionarray[i]:match("<functioncall .->(.-)</functioncall>")~=nil then
      if functionarray[i]:match("<requires>(.-)</requires>")~=nil then
        if functionarray[i]:match("<requires>.-Ultraschall=(.-)%c.-</requires>")~=nil then
            usvers=functionarray[i]:match("<requires>.-Ultraschall=(.-)%c.-</requires>")
            ultraschallversion="<img style=\"width:3%;\" src=\"gfx/ultraschall"..usvers..".png\" alt=\"Ultraschall version "..usvers.."\">"
        end
        if functionarray[i]:match("<slug>(.-)</slug>")~=nil then
          slug=functionarray[i]:match("<slug>(.-)</slug>")
        else
          slug=""
        end
        if functionarray[i]:match("<requires>.-Reaper=(.-)%c.-</requires>")~=nil then
            reapvers=functionarray[i]:match("<requires>.-Reaper=(.-)%c.-</requires>")
            reaperversion="<img style=\"width:3%;\" src=\"gfx/reaper"..reapvers..".png\" alt=\"Reaper version "..reapvers.."\">"
        end
        if functionarray[i]:match("<requires>.-SWS=(.-)%c.-</requires>")~=nil then
            swsvers=functionarray[i]:match("<requires>.-SWS=(.-)%c.-</requires>")
            swsversion="<img style=\"width:3%;\" src=\"gfx/sws"..swsvers..".png\" alt=\"sws version "..swsvers.."\">"
        end
        if functionarray[i]:match("<requires>.-Lua=(.-)%c.-</requires>")~=nil then
            luavers=functionarray[i]:match("<requires>.-Lua=(.-)%c.-</requires>")
            luaversion="<img style=\"width:3%;\" src=\"gfx/Lua"..luavers..".png\" alt=\"lua version "..luavers.."\">"
        end
      end
      if functionarray[i]:match("<description.->%c.-</description>")~=nil then
          description=tostring(functionarray[i]:match("<description.->%c(.-)</description>"))        
          description=string.gsub(description, "\n", "<br>")
      elseif functionarray[i]:match("<description.->.-</description>")~=nil then
          description=tostring(functionarray[i]:match("<description.->(.-)</description>"))        
          description=string.gsub(description, "\n", "<br>")
      end      

      if functionarray[i]:match("<retvals>.-</retvals>")~=nil then
          tempretvals=functionarray[i]:match("<retvals>(.-</retvals>)")
            tempretvals=string.gsub(tempretvals, "\n\t*%s*", "\n")
            tempretvals=string.gsub(tempretvals, "\n","</i><br><i>")
            tempretvals=string.gsub(tempretvals, " %- ", "</i> - ") -- match("\t*%s*(.*)")
            tempretvals=string.gsub(tempretvals, "\n.-", "</i><br><i>")
            tempretvals=string.gsub(tempretvals, "<br><i>%-","<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")
            retvals=retvals.."<div style=\"padding-left:4%;\">"..tempretvals:sub(9,-11).."</i></div>"
      end      
      if functionarray[i]:match("<parameters.->.-</parameters>")~=nil then
          tempparameters=functionarray[i]:match("<parameters.->(.-</parameters>)")
--          if slug=="AddRemoveReaScript" then reaper.ShowConsoleMsg(tempparameters.." <<\n") end
          tempparameters=string.gsub(tempparameters, "</parameters>", "</i>")
--          if slug=="AddRemoveReaScript" then reaper.ShowConsoleMsg(tempparameters.."\n") end
          tempparameters=string.gsub(tempparameters, "\n\t*%s*", "\n")
--          if slug=="AddRemoveReaScript" then reaper.ShowConsoleMsg("PING>>\n"..tempparameters.."\n<<PING\n") end
          tempparameters=string.gsub(tempparameters, " %- ", "</i> - ")
--          if slug=="AddRemoveReaScript" then reaper.ShowConsoleMsg(tempparameters.."\n") end
          tempparameters=string.gsub(tempparameters, "\n\t*%s%-", "") 
--          if slug=="AddRemoveReaScript" then reaper.ShowConsoleMsg(tempparameters.."\n") end
          tempparameters=string.gsub(tempparameters, "\n.-", "</i><br><i>")
--          if slug=="AddRemoveReaScript" then reaper.ShowConsoleMsg(tempparameters.."\n") end
          tempparameters=string.gsub(tempparameters, "<br><i>%-", "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")
--          if slug=="AddRemoveReaScript" then reaper.ShowConsoleMsg(tempparameters.."\n") end
          tempparameters=tempparameters:sub(9,-1)
--          if slug=="AddRemoveReaScript" then reaper.ShowConsoleMsg(tempparameters.."\n") end
          parameters=parameters.."<div style=\"padding-left:4%;\">"..tempparameters.."</div>"

      end      
      slug=functionarray[i]:match("<slug>(.-)</slug>")
      if slug==nil then slug=""
--        reaper.MB(functionarray[i]:match(".-"),"",0)
      end
      slug=string.gsub(slug, "\n", "")
      if retvals~="" then retvals="<u>Returnvalues:</u><br>"..retvals end
      if parameters~="" then parameters="<u>Parameters:</u>"..parameters end
      if swsversion==nil then swsversion="" end
      if luaversion==nil then luaversion="" end
      if reaperversion==nil then reaperversion="" end
      if description==nil then description="" end
      if ultraschallversion==nil then ultraschallversion="" end
      luafunc=functionarray[i]:match("<functioncall prog_lang=\"lua\">(.-)</functioncall>")
      if luafunc==nil then 
          luafunc="" 
      else
          luafunc=" <div class=\"l_func\"><span class='all_view'><b>Lua: </b></span><i><code>"..luafunc.."</code></i></div>"
      end

      cppfunc=functionarray[i]:match("<functioncall prog_lang=\"cpp\">(.-)</functioncall>")
      if cppfunc==nil then 
          cppfunc="" 
      else
          cppfunc=" <div class=\"c_func\"><span class='all_view'><b>C/C++: </b></span><i><code>"..cppfunc.."</code></i></div>"
      end

      pyfunc=functionarray[i]:match("<functioncall prog_lang=\"python\">(.-)</functioncall>")
      if pyfunc==nil then 
          pyfunc="" 
      else
          pyfunc=" <div class=\"p_func\"><span class='all_view'><b>Python:</b> </span><i><code>"..pyfunc.."</code></i></div>"
      end

      eelfunc=functionarray[i]:match("<functioncall prog_lang=\"eel\">(.-)</functioncall>")
      if eelfunc==nil then
          eelfunc="" 
      else
          eelfunc=" <div class=\"e_func\"><span class='all_view'><b>Eel: </b></span><i><code>"..eelfunc.."</code></i></div>"
      end
      
          funclist=funclist.."<a id=\""..slug.."\"><hr><br></a>"..ultraschallversion..reaperversion..swsversion..luaversion..cppfunc..eelfunc..luafunc..pyfunc.."<br>"..description.."<p></p>"..retvals.."<p></p>"..parameters.."<p></p>Tags: "..functionarray[i]:match("<tags>(.-)</tags>").."<p></p>\n"
    end

--dok-chapters
  if functionarray[i]:match("<USDocBloc_Text.->(.-)</USDocBloc_Text>")~=nil then
    if functionarray[i]:match("<chapter_context>(.-)</chapter_context>")~=nil then
        if functionarray[i]:match("<slug>(.-)</slug>")~=nil then
          slug=functionarray[i]:match("<slug>(.-)</slug>")
          shortname=functionarray[i]:match("<shortname>(.-)</shortname>")
        else
          slug=""
          shortname=""
        end
      if functionarray[i]:match("<description.->.-</description>")~=nil then
          description=tostring(functionarray[i]:match("<description.->.-%c(.-)</description>"))
          description=string.gsub(description, "\n", "<br>")
      end      

      slug=functionarray[i]:match("<slug>(.-)</slug>")
      if slug==nil then slug=""
--        reaper.MB(functionarray[i]:match(".-"),"",0)
      end
      slug=string.gsub(slug, "\n", "")      
      if functionarray[i]:match("<begin></begin>")~=nil then
        begin="<hr>"
      else
        begin=""
      end
        startfile=startfile.."<hr><a id=\""..slug.."\">"..begin.."</a><h4>"..shortname.."</h4>"..description.."<p></p>\n"      
    end
  end
    
  end

  --assembling helpfile
  local endfile="<hr><p align=\"right\"><i>API-documentation automatically created by Ultraschall-Framework version "..ultraschall.GetApiVersion().."</i></p></div></body></html>"
  local outfile=startfile..funcindex.."<p></p>"..funclist..endfile
  return ultraschall.WriteValueToFile(filename_with_path, outfile)
end

function ultraschall.ConvertReaperDocToUSDocML(filename, targetfilename)
  functable={}
  functable[1]={} --slug
  functable[2]={} -- c_funcname
  functable[3]={} -- eel_funcname
  functable[4]={} -- lua_funcname
  functable[5]={} -- python_funcname
  functable[6]={} -- DescText
  functable[7]={} -- RetVals
  functable[8]={} -- Parameters
  
  start=1
  endof=8000
  
  A=ultraschall.ReadValueFromFile(filename)
  B=A:match("<td><a href=\"#SNM_CreateFastString\">SNM_CreateFastString</a> &nbsp; &nbsp; </td>(.*)")
  A=B
  reaper.ShowConsoleMsg("ReadFile\n")
  
  i=1
  while B~=nil and B:match("<a name=\".-\"><hr></a><br>")~=nil and i<=endof do
    if i>=start and i<=endof then
      functable[1][i]=B:match("<a name=\"(.-)\"><hr></a><br>")
      functable[2][i]=B:match("C: .-<code>(.-)</code>")
      functable[3][i]=B:match("EEL: .-<code>(.-)</code>")
      functable[4][i]=B:match("Lua:.-<code>(.-)</code>")
  --                           Lua: .-<code>(.-)</code>
    --if functable[4][i]~=nil and functable[4][i]:match("gfx.blit")~=nil then reaper.MB(tostring(functable[4][i]),"",0) end
      functable[5][i]=B:match("Python: .-<code>(.-)</code>")
      functable[6][i]=B:match("Python:.-</code><br><br></div>(.-)<a name=")
      if functable[6][i]==nil then functable[6][i]=B:match("Python:.-</code><br><br></div>(.-)<br><br>") end
      if functable[6][i]==nil then functable[6][i]=B:match("Lua:.-</code><br><br></div>(.-)<a name=") end
      if functable[6][i]==nil then functable[6][i]=B:match("Lua:.-</code><br><br>(.-)<a name=") end
      if functable[6][i]==nil then functable[6][i]="hula\n" end
      functable[6][i]=functable[6][i]:sub(1,-10)
      if functable[6][i]:match("<div")=="<div" then functable[6][i]=functable[6][i]:match("(.-)<div") end
      functable[6][i]=string.gsub (functable[6][i], "<br>", "")
      functable[6][i]=string.gsub (functable[6][i], "<div>", "")
      functable[6][i]=string.gsub (functable[6][i], "</div>", "")
          
      --RetVals
      functable[7][i]={}
      if functable[4][i]~=nil then 
  --      reaper.ShowConsoleMsg(functable[4][i].."\n")
        if functable[4][i]:match("(.-)%s-reaper")~=nil then functable[7][i][1]=functable[4][i]:match("(.-)%s-reaper").."," end
      end
  
      --Parameters
      functable[8][i]={}
      if functable[4][i]~=nil then     
        if functable[4][i]:match("(.-)%s-reaper")~=nil then functable[8][i][1]=functable[4][i]:match("%((.-)%)").."," end
      end
      
      if functable[4][i]~=nil and functable[4][i]:match(".-(=).-reaper")==nil and functable[4][i]:match("{reaper.")==nil and functable[4][i]:match("(.-)reaper")~="" then 
        temp1=functable[4][i]:match("(.-)reaper") 
        temp2=functable[4][i]:match("(reaper.*)") 
        if temp1~=nil and temp2~=nil then functable[4][i]=temp1.."= "..temp2 end
      end
    end
      
    B=B:match("<a name=\".-\"><hr></a><br>.-(<a name=.*)")
    i=i+1
  end
  
  reaper.ShowConsoleMsg("Create Retvals\n")
  --Retvals Take-A-Part
  for a=start, i-1 do
  --reaper.ShowConsoleMsg(">> "..tostring(functable[7][a][1]).."\n")
    b=2
    while functable[7][a][1]~=nil and functable[7][a][1]:match(",")~=nil do
      temp=functable[7][a][1]:match("(.-),")
      if temp:match("</i>(.*)")~="" then temp=temp:match("</i>(.*)") end
      if temp~=nil and temp:match(".-%=")~=nil then temp=temp:match("(.-)%=") end
  
  --    reaper.ShowConsoleMsg("\t"..tostring(temp).."\n")
      functable[7][a][b]=temp
      functable[7][a][1]=functable[7][a][1]:match(".-,(.*)")
      b=b+1
  --    reaper.ShowConsoleMsg(tostring(functable[7][a][1]))
    end
  end
  
  
  --Params Take-A-Part
  reaper.ShowConsoleMsg("Create Params\n")
  for a=start, i-1 do
  --reaper.ShowConsoleMsg(">> "..tostring(functable[8][a][1]).." <<\n")
    b=2
    while functable[8][a][1]~=nil and functable[8][a][1]:match(",")~=nil do
      functable[8][a][b]=functable[8][a][1]:match("</i> (.-),")
    --  reaper.ShowConsoleMsg("\t"..tostring(functable[8][a][b]).."\n")
      functable[8][a][1]=functable[8][a][1]:match(".-,(.*)")
      b=b+1
  --    reaper.ShowConsoleMsg(tostring(functable[8][a][1]))
    end
  end
  
  
  reaper.ShowConsoleMsg("Create DocBlocs\n")
  apistring=""
  for a=start, i-1 do
    -- slug
    apistring=apistring.."\t<USDocBloc_.->\n\t\t<slug>"..functable[1][a].."</slug>\n"
  
    --  a shortname for this function
    apistring=apistring.."\t\t<shortname>"..functable[1][a].."</shortname>\n"
    
    -- C-Funcname
    if functable[2][a]~=nil then apistring=apistring.."\t\t<functioncall prog_lang=\"cpp\">"..functable[2][a].."</functioncall>\n" end
    
    -- EEL-Funcname
    if functable[3][a]~=nil then apistring=apistring.."\t\t<functioncall prog_lang=\"eel\">"..functable[3][a].."</functioncall>\n" end
      
    -- Lua-Funcname
    if functable[4][a]~=nil then apistring=apistring.."\t\t<functioncall prog_lang=\"lua\">"..functable[4][a].."</functioncall>\n" 
  --  else reaper.ShowConsoleMsg(functable[1][a].."\n")
    end
  --if functable[4][a]~=nil then apistring=apistring.."<functionname>\n"..functable[4][a].."\n</functionname>\n" end
    
    -- Python-Funcname
    if functable[5][a]~=nil then apistring=apistring.."\t\t<functioncall prog_lang=\"python\">"..functable[5][a].."</functioncall>\n" end
    
    -- Description
    desc=""
    if functable[6][a]:match(".(.*)")~=nil then desc=functable[6][a]:match(".(.*)") else desc=functable[6][a] end
    if functable[6][a]~=nil then apistring=apistring.."\t\t<description prog_lang=\"*\">\n\t\t\t"..desc.."\n\t\t</description>\n" end
    
    --RetVals
    ala=2
    if functable[7][a][2]~=nil then
      apistring=apistring.."\t\t<retvals>\n"
      while functable[7][a][ala]~=nil do
        apistring=apistring.."\t\t\t"..functable[7][a][ala].." - \n"
        ala=ala+1
      end
      apistring=apistring.."\t\t</retvals>\n"  
    end
    
    --Parameters
    ala=2
    if functable[8][a][2]~=nil then
      apistring=apistring.."\t\t<parameters.->\n"
      while functable[8][a][ala]~=nil do
        apistring=apistring.."\t\t\t"..functable[8][a][ala].." - \n"
        ala=ala+1
      end
      apistring=apistring.."\t\t</parameters>\n"
    end
    
    --document to store this entry in
    apistring=apistring.."\t\t<document>ReaperApiFunctionsReference</document>\n"
    
    --chapter, within <document> to insert this entry in
    apistring=apistring.."\t\t<chapter_context>\n\t\t\tApiReference\n\t\t</chapter_context>\n"
    apistring=apistring.."\t\t<tags></tags>\n"
    
    apistring=apistring.."\t</USDocBloc_.->\n\n"
  end
  
  --reaper.MB(apistring,"",0)
  --]]
  
  
  apistring=string.gsub (apistring, "<i>", "")
  apistring=string.gsub (apistring, "</i>", "")
  apistring=string.gsub (apistring, "</ul>", "")
  apistring=string.gsub (apistring, "<ul>", "")
  apistring=string.gsub (apistring, "</li>", "")
  apistring=string.gsub (apistring, "<li>", "\n")
  apistring=string.gsub (apistring, "&", "&amp;")
  apistring=string.gsub (apistring, "  ", " ")
  
  apistring="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<USDocBloc>\n"..apistring.."</USDocBloc>"
  
  reaper.ShowConsoleMsg("Write DocBlocFile\n")
  ultraschall.WriteValueToFile(targetfilename, apistring)
end

--ultraschall.ConvertReaperDocToUSDocML("C:/Users/meo/AppData/Local/Temp/reascripthelp.html", "c:\\reaper-apihelp2.txt")

reaper.ShowConsoleMsg("Create HTML-File\n")
retval = ultraschall.CreateReaperApiDocs_HTML("c:\\reaper-apihelp14.html", "c:\\reaper-apihelp14.txt") 
--retval = ultraschall.CreateReaperApiDocs_HTML("c:\\hulabalula.html", "c:\\test1.txt") 
reaper.MB("Done","",0)

--reaper.APITest()
