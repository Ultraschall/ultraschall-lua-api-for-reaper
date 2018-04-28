--ultraschall={}
--ultraschall.US_DataStructures="OFF"
--require("ultraschall_api")

function ultraschall.DocGetSpokenLanguages(Docbloc)
  Spoken_languages=""
  count=0
  if Docbloc:match("spok_lang")==nil then return 0, "" end
  
  while Docbloc~=nil do
    Lang=Docbloc:match("spok_lang=\"(.-)\".-\n")
    if Lang~=nil and Spoken_languages:match(Lang)==nil then Spoken_languages=Spoken_languages..","..Lang count=count+1 end
    Docbloc=Docbloc:match("\n(.*)")
  end
  return count, Spoken_languages:sub(2,-1)
end

function ultraschall.DocGetProgrammingLanguages(Docbloc)
  Progr_languages=""
  count=0
  if Docbloc:match("prog_lang")==nil then return 0, "" end
  
  while Docbloc~=nil do
    Lang=Docbloc:match("prog_lang=\"(.-)\".-\n")
    if Lang~=nil and Progr_languages:match(Lang)==nil then Progr_languages=Progr_languages..","..Lang count=count+1 end
    Docbloc=Docbloc:match("\n(.*)")
  end
  return count, Progr_languages:sub(2,-1)
end

function ultraschall.DocGetTags(Docbloc)
  local Tags={}
  local count=1
  if Docbloc:match("<tags>.-</tags>")==nil or 
     Docbloc:match("<tags>(.-)</tags>")=="" or 
     Docbloc:match("<tags>(\t*%s*)</tags>")~=nil then return 0, nil end
  
  Temptags=Docbloc:match("<tags>(.-)</tags>")


  while Temptags~=nil do
    Tags[count]=Temptags:match("\t*%s*(.-),")
      if Tags[count]==nil then Tags[count]=Temptags:match("\t*%s*(.*)") end
    Temptags=Temptags:match(",(.*)")
    count=count+1
  end
  return count-1, Tags
end


function ultraschall.DocCleanUpDescription(descriptionstring, cut_first_minus)
    local newstring=""
    local A,Splitstringarray=ultraschall.SplitStringAtLineFeedToArray(descriptionstring)
    markuptype=descriptionstring:match("<description .-markup_type=\"(.-)\"")
    markupversion=descriptionstring:match("<description .-markup_version=\"(.-)\"")
    for i=1, A do
      if Splitstringarray[i]=="\n" then
        newstring=newstring..Splitstringarray[i]
      else --string.gsub (FinalDocs[count][content], "\n\t*%s*\n", "\n\n")
        if cut_first_minus==true then
          if Splitstringarray[i]:match("^\t*%s*%-(.*)")~=nil then
              newstring=newstring..Splitstringarray[i]:match("^\t*%s*%-(.*)")
          else
              newstring=newstring..Splitstringarray[i]:match("^\t*%s*(.*)")
          end
        else
          newstring=newstring..Splitstringarray[i]:match("^\t*%s*(.*)")
        end
      end
    end
    --reaper.ShowConsoleMsg(descriptionstring,"",0)
    return newstring, markuptype, markupversion
end

function ultraschall.DocGetDescriptions(DocBloc)
  local FinalDocs={}
  local markup=1
  local content=2
  local spok_lang=3
  local prog_lang=4
  local pretabs=5
  local count=1
  local globalprog=DocBloc:match("<USDocBloc_.-prog_lang=\"(.-)\"")
  local globalspok=DocBloc:match("<USDocBloc_.-spok_lang=\"(.-)\"")

  while DocBloc~=nil do
    if DocBloc:match("<description.->")==nil then break end
    FinalDocs[count]={}
    FinalDocs[count][markup]={}
    FinalDocs[count][content]={}
    FinalDocs[count][spok_lang]={}
    FinalDocs[count][prog_lang]={}
    pretabs=""
    
    FinalDocs[count][markup]=DocBloc:match("<description.-markuptype=\"(.-)\".->")
      if FinalDocs[count][markup]==nil then FinalDocs[count][markup]=DocBloc:match("<USDocBloc_.-markuptype=\"(.-)\"") end
      if FinalDocs[count][markup]==nil then FinalDocs[count][markup]="none" end
    FinalDocs[count][spok_lang]=DocBloc:match("<description.-spok_lang=\"(.-)\".->")
      if globalspok~=nil and FinalDocs[count][spok_lang]==nil then FinalDocs[count][spok_lang]=globalspok end
      if FinalDocs[count][spok_lang]==nil then FinalDocs[count][spok_lang]="default-en" end
    FinalDocs[count][prog_lang]=DocBloc:match("<description.-prog_lang=\"(.-)\".->")
      if FinalDocs[count][prog_lang]==nil then FinalDocs[count][prog_lang]=globalprog end
      if FinalDocs[count][prog_lang]==nil then FinalDocs[count][prog_lang]="*" end
    pretabs=DocBloc:match("<description.-skip_preced_spacetabs=\"(.-)\".->")
            
    FinalDocs[count][content]=DocBloc:match("<description.->(.-)</description>")


    if pretabs=="inclfirstminus" or pretabs==nil then
        FinalDocs[count][content]=ultraschall.DocCleanUpDescription(FinalDocs[count][content], true)
    elseif pretabs=="exclminus" then
        FinalDocs[count][content]=ultraschall.DocCleanUpDescription(FinalDocs[count][content], false)
    elseif pretabs=="untouched" then
    end

    DocBloc=DocBloc:match("</description>(.*)")
    count=count+1
  end

  return count, FinalDocs
end

function ultraschall.DocGetChapterContext(DocBloc)
  chapters=DocBloc:match("<chapter_context>\n*(.-)</chapter_context>")
  chapters=ultraschall.DocCleanUpDescription(chapters, false)
  count, individual_chapters=ultraschall.SplitStringAtLineFeedToArray(chapters) 
  return count, individual_chapters
end

function ultraschall.DocGetVersion(DocBloc)
  return DocBloc:match("USDocBloc_.-version=\"(.-)\"")
end

function ultraschall.DocGetTargetDocument(DocBloc)
  return DocBloc:match("<target_document>(.-)</target_document>")
end

function ultraschall.DocGetSourceDocument(DocBloc)
  return DocBloc:match("<source_document>(.-)</source_document>")
end

function ultraschall.DocSeparateDocBlocs(infile)
  local DocBlocArray={}
  local count=1
  local spoken_langs=""
  local prog_langs=""
  local markuptype_usage=false
  while infile~=nil do
    DocBlocArray[count]=infile:match("<USDocBloc_.-</USDocBloc_.->")
    infile=infile:match("</USDocBloc_.->(.*)")
    count=count+1
  end
  return count, DocBlocArray, spoken_langs, prog_langs, markuptype_usage
end

function ultraschall.DocInterpretDocBloc(docbloc, spoklang, proglang)
  --type
  docbloc_type=docbloc:match("<USDocBloc_(.-) .-_lang.-<slug>")
    if docbloc_type==nil then docbloc_type=docbloc:match("<USDocBloc_(.-)>") end
  --programming_language_global for this specific docbloc
  docbloc_proglangG=docbloc:match("prog_lang=\"(.-)\".-<slug>")
    if docbloc_proglangG==nil then docbloc_proglangG="*" end
  --spoken language_global for this specific docbloc
  docbloc_spoklangG=docbloc:match("spok_lang=\"(.-)\".-<slug>")
    if docbloc_spoklangG==nil then docbloc_spoklangG="*" end
    
  --slug
  docbloc_slug=docbloc:match("<slug>(.-)</slug>")
  --shortname
  docbloc_shortname=docbloc:match("<shortname>(.-)</shortname>")
    if docbloc_shortname==nil then docbloc_shortname="" end
  -- description -> do an external function to interpret the description-blocs!
  docbloc_description=docbloc:match("<description.->(.-)</description>")
  docbloc_description=string.gsub (docbloc_description, "\n\t*%s*", "\n")
  if docbloc:match("<description.-skip_prec_spacetabs=\"(.-)\"")=="true" then
    docbloc_description=string.gsub (docbloc_description, "^\t*%s*%-", "")
  end
  docbloc_description_markuptype=docbloc:match("<description.-markuptype=\"(.-)\"")
    if docbloc_description_markuptype==nil then docbloc_description_markuptype="none" end
  
  --requires -> do an external function to interpret the requirements for programminglanguage, markuptype and spoken language
  docbloc_requires=docbloc:match("<requires>(.-)</requires>")
    if docbloc_requires==nil then docbloc_requires="" end
  
  --retvals -> do an external function to interpret the retvals for programminglanguage, markuptype and spoken language
  docbloc_retvals=docbloc:match("<retvals.->(.-)</retvals>")
    if docbloc_retvals==nil then docbloc_retvals=""end  
  docbloc_retvals_markuptype=docbloc:match("<retvals.-markuptype=\"(.-)\">")
    if docbloc_retvals_markuptype==nil then docbloc_retvals_markuptype="none" end
  
  --parameters -> do an external function to interpret the parameters for programminglanguage, markuptype and spoken language
  docbloc_parameters=docbloc:match("<parameters.->(.-)</parameters>")
    if docbloc_parameters==nil then docbloc_parameters="" end  
  docbloc_parameters_markuptype=docbloc:match("<retvals.-markuptype=\"(.-)\">")
    if docbloc_parameters_markuptype==nil then docbloc_parameters_markuptype="none" end

  --target document
  docbloc_targdocument=docbloc:match("<target_document>(.-)</target_document>")
    if docbloc_targdocument==nil then docbloc_targdocument="" end  
  --chapter context, the chapter/subchapter(s) of where this docbloc belongs to -> do an external function to interpret this
  docbloc_chaptercontext=docbloc:match("<chapter_context>(.-)</chapter_context>")
    if docbloc_chaptercontext==nil then docbloc_chaptercontext="" end
  --tags -> do an external function to interpret this
  docbloc_tags=docbloc:match("<tags>(.-)</tags>")
    if docbloc_tags==nil then docbloc_tags="" end
  --functioncalls -> do an external function to interpret this functioncalls, by programming languages
  docbloc_function=docbloc:match("(<functioncall.->.-</functioncall>)")
    if docbloc_function==nil then docbloc_function="" end
  

  return docbloc_type,
         docbloc_proglangG,
         docbloc_spoklangG,
         docbloc_slug,
         docbloc_shortname,
         docbloc_description,
         docbloc_description_markuptype,
         docbloc_requires,
         docbloc_retvals,
         docbloc_retvals_markuptype,
         docbloc_parameters,
         docbloc_parameters_markuptype,
         docbloc_targdocument,
         docbloc_sourcedocument,
         docbloc_namespace,
         docbloc_class,
         docbloc_function,
         docbloc_dependencies,
         docbloc_chaptercontext,
         docbloc_tags       
end


function ultraschall.DocGetFunctions(DocBloc)
  local functionsarray={}
  local globalprog=DocBloc:match("<USDocBloc_.-prog_lang=\"(.-)\"")
  local count=1
  while DocBloc:match("<functioncall.->(.-)</functioncall>")~=nil do
    functionsarray[count]={}
    functionsarray[count][1]=DocBloc:match("<functioncall.->(.-)</functioncall>")
    functionsarray[count][2]=DocBloc:match("<functioncall.-prog_lang=\"(.-)\".->.-</functioncall>")
    if functionsarray[count][2]==nil then functionsarray[count][2]=globalprog end
    if functionsarray[count][2]==nil then functionsarray[count][2]="none" end
    DocBloc=DocBloc:match("<functioncall.->.-</functioncall>(.*)")
    count=count+1
  end
  return count-1, functionsarray
end

function ultraschall.DocGetSlug(DocBloc)
  return DocBloc:match("<slug>(.-)</slug>")
end

function ultraschall.DocGetShortname(DocBloc)
  return DocBloc:match("<shortname>(.-)</shortname>")
end

function ultraschall.DocGetRetvals(DocBloc)
  local retvalarray={}
  local globalprog=DocBloc:match("<USDocBloc_.-prog_lang=\"(.-)\"")
  local count=0
  while DocBloc:match("<retvals.->.-</retvals>")~=nil do    
    retvalbloc=DocBloc:match("<retvals.->\n*(.-)</retvals>")
    retvalbloc=ultraschall.DocCleanUpDescription(retvalbloc, false)
    localprog_lang=DocBloc:match("<retvals.->.-</retvals>")
    localprog_lang=localprog_lang:match("<retvals.-prog_lang=\"(.-)\".->.-</retvals>")
    markuptype=DocBloc:match("<retvals.-markup_type=\"(.-)\".->.-</retvals>")
    if markuptype==nil then markuptype="none" end
    markupversion=DocBloc:match("<retvals.-markup_version=\"(.-)\".->.-</retvals>")
    if markupversion==nil then markupversion="" end
    
    while retvalbloc~=nil and retvalbloc~="" do
      if retvalbloc:match("^%-")==nil then 
          count=count+1
          retvalarray[count]={}
          retvalarray[count][1]=""
          retvalarray[count][2]=""
          retvalarray[count][1]=retvalbloc:match("(.-)%-")
          if localprog_lang~=nil then retvalarray[count][3]=localprog_lang
          elseif globalprog~=nil then retvalarray[count][3]=globalprog        
          else retvalarray[count][3]="*"
          end
          retvalarray[count][4]=markuptype
          retvalarray[count][5]=markupversion
          retvalbloc=retvalbloc:match("(%-.*)") 
      else 
          retvalarray[count][2]=retvalarray[count][2]..retvalbloc:match("%-(.-)\n").."\n"
          retvalarray[count][2]=retvalarray[count][2]:match("\t*%s*(.*)")
          retvalbloc=retvalbloc:match("\n(.*)") 
      end

    end
    DocBloc=DocBloc:match("<retvals.->.-</retvals>(.*)")
  end
  return count, retvalarray  
end

function ultraschall.DocGetParameters(DocBloc)
  local parametersarray={}
  local globalprog=DocBloc:match("<USDocBloc_.-prog_lang=\"(.-)\"")
  local count=0
  while DocBloc:match("<parameters.->.-</parameters>")~=nil do    
    parametersbloc=DocBloc:match("<parameters.->\n*(.-)</parameters>")
    parametersbloc=ultraschall.DocCleanUpDescription(parametersbloc, false)
    localprog_lang=DocBloc:match("<parameters.->.-</parameters>")
    localprog_lang=localprog_lang:match("<parameters.-prog_lang=\"(.-)\".->.-</parameters>")
    markuptype=DocBloc:match("<parameters.-markup_type=\"(.-)\".->.-</parameters>")
    if markuptype==nil then markuptype="none" end
    markupversion=DocBloc:match("<parameters.-markup_version=\"(.-)\".->.-</parameters>")
    if markupversion==nil then markupversion="" end
    
    while parametersbloc~=nil and parametersbloc~="" do
      if parametersbloc:match("^%-")==nil then 
          count=count+1
          parametersarray[count]={}
          parametersarray[count][1]=""
          parametersarray[count][2]=""
          parametersarray[count][1]=parametersbloc:match("(.-)%-")
          if localprog_lang~=nil then parametersarray[count][3]=localprog_lang
          elseif globalprog~=nil then parametersarray[count][3]=globalprog        
          else parametersarray[count][3]="*"
          end
          parametersarray[count][4]=markuptype
          parametersarray[count][5]=markupversion
          parametersbloc=parametersbloc:match("(%-.*)") 
      else 
          parametersarray[count][2]=parametersarray[count][2]..parametersbloc:match("%-(.-)\n").."\n"
          parametersarray[count][2]=parametersarray[count][2]:match("\t*%s*(.*)")
          parametersbloc=parametersbloc:match("\n(.*)") 
      end

    end
    DocBloc=DocBloc:match("<parameters.->.-</parameters>(.*)")
  end
  return count, parametersarray  
end

function ultraschall.DocGetRequires(DocBlock)

-- To Be done !!!

end

--_Infile=ultraschall.ReadFullFile("c:\\reaper-apihelp8.txt",false)
local _Count,_DocBlocArray=ultraschall.DocSeparateDocBlocs(_Infile)


--A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T=ultraschall.DocInterpretDocBloc(_DocBlocArray[30])

local AAaehler=1
function main()
  valueA,valueB,valueC=ultraschall.DocGetRetvals(_DocBlocArray[AAaehler])
  value0=_DocBlocArray[AAaehler]:match("<slug>.-</slug>")
  AAaehler=AAaehler+1
  if AAaehler<_Count-1 then reaper.defer(main) end
end

--main()
local temp=100
--reaper.MB(_DocBlocArray[temp],"",0)
--  Avalue0=_DocBlocArray[temp]:match("<slug>.-</slug>")
--A,B,C=ultraschall.DocGetParameters(_DocBlocArray[temp])
