ultraschall={}
Width=942
Height=800
font_size=17

Content_Offset_X=10
Content_Offset_Y=-48
x=1
y=95
gfx.init("Ultraschall State Inspector v3", Width, Height,0,100,100)
gfx.clear=reaper.ColorToNative(20,20,20)
gfx.update()
gfx.setimgdim(3, 2048, 2048)
gfx.setimgdim(4, 2048, 2048)

-- preparing Tabs
Tabs_Count=10
Tabs={"Dashboard", "ExtStates", "ProjectStateChunk", "TrackStateChunk", "ItemStateChunk", "EnvelopeStateChunk", "Reaper_States", "Developer_Tools", "ConfigVars", "ConfigDiffs"}
Tabs_Settings={}
Tabs_Funcs={}
for i=1, Tabs_Count do
  Tabs_Funcs[Tabs[i]]="nothing yet"
  Tabs_Settings[Tabs[i]]={}
  Tabs_Settings[Tabs[i]][2]=1
  Tabs_Settings[Tabs[i]][3]=1
end
Tabs_Click={}
Current_Tab=1

-- preparing Menus
Menus={}
Menus[1]={"File","New"}
Menus[2]={"Edit","Copy"}
Menus[3]={"I am Henry the eight of China","Copy"}
Menus[4]={"Edit","Copy",">Hulubuluberg","remember the time"}
Menus[5]={"Edit","Copy"}
Menus[6]={"Edit","Copy"}
Menus[7]={"Edit","Copy"}
Menus[8]={"Edit","Copy"}
Menu_count=8
Menus_Click={}

-- preparing config-vars
  function ultraschall.GetStringFromClipboard_SWS()
    local buf = reaper.CF_GetClipboard(buf)
    local WDL_FastString=reaper.SNM_CreateFastString("HudelDudel")
    local clipboardstring=reaper.CF_GetClipboardBig(WDL_FastString)
    reaper.SNM_DeleteFastString(WDL_FastString)
    return clipboardstring
  end
  
  --L=reaper.MB("Read variable-names from clipboard?\n(Select No to use Reaper 5.80-variables.)","Query",3)
  L=6
  varsline=""
  -- all valid variables
  varsline="__numcpu\nacidimport\nactionmenu\nadjreclat\nadjrecmanlat\nadjrecmanlatin\nallstereopairs\naltpeaks\naltpeaksopathlist\naltpeakspath\nalwaysallowkb\naot\napplyfxtail\nasio_bsize\naudioasync\naudiocloseinactive\naudioclosestop\naudioprshift\naudiothreadpr\nautoclosetrackwnds\nautomute\nautomuteflags\nautomuteval\nautonbworkerthreads\nautoreturntime\nautoreturntime_action\nautosaveint\nautosavemode\nautoxfade\ncopyimpmedia\ncpuallowed\ncsurfrate\nctrlcopyitem\ncueitems\ncustommenu\ndefautomode\ndefenvs\ndeffadelen\ndeffadeshape\ndefhwvol\ndefpitchcfg\ndefrenderpath\ndefsavepath\ndefsendflag\ndefsendvol\ndefsplitxfadelen\ndeftrackrecflags\ndeftrackrecinput\ndeftrackvol\ndefvzoom\ndefxfadeshape\ndisabledxscan\ndisk_peakmmap2\ndisk_rdmodeex\ndisk_rdsizeex\ndisk_wrblks"
  varsline=varsline.."\ndisk_wrblks2\ndisk_wrmode\ndisk_wrsize\ndiskcheck\ndiskcheckmb\nedit_fontsize\nenv_autoadd\nenv_deffoc\nenv_ol_minh\nenv_options\nenv_reduce\nenvattach\nenvclicksegmode\nenvlanes\nenvtranstime\nenvtrimadjmode\nenvwritepasschg\nerrnowarn\nfadeeditflags\nfadeeditlink\nfadeeditpostsel\nfadeeditpresel\nfeedbackmode\nfullscreenRectB\nfullscreenRectL\nfullscreenRectR\nfullscreenRectT\nfxdenorm\nfxfloat_focus\nfxresize\ng_config_project\ng_markerlist_updcnt\ngriddot\ngridinbg\ngridinbg2\ngroupdispmode\nguidelines2\nhandzoom\nhelp\nhwfadex\nhwoutfx_bypass\nide_colors\ninsertmtrack\nisFullscreen\nitemclickmovecurs\nitemdblclk\nitemeditpr\nitemfade_minheight\nitemfade_minwidth\nitemfadehandle_maxwidth\nitemfxtail\nitemicons\nitemicons_minheight\nitemlabel_minheight\nitemlowerhalf_minheight"
  varsline=varsline.."\nitemmixflag\nitemprops\nitemprops_timemode\nitemsnap\nitemtexthide\nitemtimelock\nitemvolmode\nkbd_usealt\nlabelitems2\nlastthemefn5\nloadlastproj\nlocklooptotime\nloop\nloopclickmode\nloopgran\nloopgranlen\nloopnewitems\nloopselpr\nloopstopfx\nmanuallat\nmanuallatin\nmastermutesolo\nmaxitemlanes\nmaxrecent\nmaxrecentfx\nmaxrecsize\nmaxrecsize_use\nmaxsnaptrack\nmaxspeakgain\nmetronome_defout\nmetronome_flags\nmidiccdensity\nmididefcolormap\nmidieditor\nmidiins\nmidiins_cs\nmidioctoffs\nmidiouts\nmidiouts_clock\nmidiouts_clock_nospp\nmidiouts_llmode\nmidioutthread\nmidisendflags\nmiditicksperbeat\nmidivu\nmixerflag\nmixeruiflag\nmixrowflags\nmousemovemod\nmousewheelmode\nmultiprojopt\nmultitouch\nmultitouch_ignore_ms\nmultitouch_ignorewheel_ms\nmultitouch_rotate_gear"
  varsline=varsline.."\nmultitouch_swipe_gear\nmultitouch_zoom_gear\nmutefadems10\nmvu_rmsgain\nmvu_rmsmode\nmvu_rmsoffs2\nmvu_rmsred\nmvu_rmssize\nnativedrawtext\nnewfnopt\nnewprojdo\nnewtflag\nnometers\nnorunmute\nofflineinact\nopencopyprompt\nopennotes\noptimizesilence\npandispmode\npanlaw\npanmode\npeakcachegenmode\npeakcachegenrs\npeakrecbm\npeaksedges\npitchenvrange\nplaycursormode\nplayrate\nplayresamplemode\npmfol\npooledenvattach\npooledenvs\nprebufperb\npreroll\nprerollmeas\nprojalignbeatsrate\nprojbpm\nprojfrbase\nprojfrdrop\nprojgriddiv\nprojgriddivsnap\nprojgridframe\nprojgridmin\nprojgridsnapmin\nprojgridswing\nprojgroupover\nprojgroupsel\nprojintmix\nprojmasternch\nprojmastervuflags\nprojmaxlen\nprojmaxlenuse\nprojmeaslen\nprojmeasoffs\nprojmetrobeatlen\nprojmetrocountin"
  varsline=varsline.."\nprojmetroen\nprojmetrof1\nprojmetrof2\nprojmetrov1\nprojmetrov2\nprojmidieditor\nprojpeaksgain\nprojrecforopencopy\nprojrecmode\nprojrelpath\nprojrenderaddtoproj\nprojrenderdither\nprojrenderlimit\nprojrendernch\nprojrenderqdelay\nprojrenderrateinternal\nprojrenderresample\nprojrendersrate\nprojrenderstems\nprojripedit\nprojsellock\nprojshowgrid\nprojsmpteahead\nprojsmptefw_rec\nprojsmpteinput\nprojsmptemaxfree\nprojsmpteoffs\nprojsmpterate\nprojsmpterateuseproj\nprojsmpteresync\nprojsmpteresync_rec\nprojsmpteskip\nprojsmptesync\nprojsrate\nprojsrateuse\nprojtakelane\nprojtimemode\nprojtimemode2\nprojtimeoffs\nprojtrackgroupdisabled\nprojtsdenom\nprojvidflags\nprojvidh\nprojvidw\npromptendrec\npsmaxv\npsminv\nquantflag\nquantolms\nquantolms2\nquantsize2\nrbn"
  varsline=varsline.."\nreamote_maxblock\nreamote_maxlat_render\nreamote_maxpkt\nreamote_smplfmt\nreascript\nreascripttimeout\nrecaddatloop\nrecfile_wildcards\nrecopts\nrecupdatems\nrelativeedges\nrelsnap\nrenderaheadlen\nrenderaheadlen2\nrenderbsnew\nrendercfg\nrenderclosewhendone\nrenderqdelay\nrendertail\nrendertaillen\nrendertails\nresetvuplay\nrestrictcpu\nrewireslave\nrewireslavedelay\nreximport\nrfprojfirst\nrightclickemulate\nripplelockmode\nrulerlayout\nrunafterstop\nrunallonstop\nsampleedges\nsaveopts\nsaveundostatesproj\nscnameedit\nscnotes\nscoreminnotelen\nscorequant\nscreenset_as_views\nscreenset_as_win\nscreenset_autosave\nscrubloopend\nscrubloopstart\nscrubmode\nscrubrelgain\nseekmodes\nselitem_tintalpha\nselitemtop\nshowctinmix\nshowlastundo\nshowmaintrack\nshowpeaks"
  varsline=varsline.."\nshowpeaksbuild\nshowrecitems\nslidermaxv\nsliderminv\nslidershex\nsmoothseek\nsmoothseekmeas\nsnapextrad\nsnapextraden\nsolodimdb10\nsolodimen\nsoloip\nspecpeak_alpha\nspecpeak_bv\nspecpeak_ftp\nspecpeak_hueh\nspecpeak_huel\nspecpeak_lo\nspecpeak_na\nsplitautoxfade\nstopendofloop\nstopprojlen\nsyncsmpmax2\nsyncsmpuse\ntabtotransflag\ntakelanes\ntcpalign\ntemplateditcursor\ntempoenvmax\ntempoenvmin\ntempoenvtimelock\ntextflags\nthreadpr\ntimeseledge\ntinttcp\ntitlebarreghide\ntooltipdelay\ntooltips\ntrackitemgap\ntrackselonmouse\ntransflags\ntransientsensitivity\ntransientthreshold\ntrimmidionsplit\ntsmarker\nundomask\nundomaxmem\nunselitem_tintalpha\nuse_reamote\nusedxplugs\nuseinnc\nuserewire\nverchk\nvgrid\nvideo_colorspace\nvideo_decprio\nvideo_delayms\nviewadvance"
  varsline=varsline.."\nvolenvrange\nvstbr64\nvstfolder_settings\nvstfullstate\nvuclipstick\nvudecay\nvumaxvol\nvuminvol\nvuupdfreq\nvzoom2\nvzoommode\nwarnmaxram64\nworkbehvr\nworkbuffxuims\nworkbufmsex\nworkrender\nworkset_max\nworkset_min\nworkset_use\nworkthreads\nzoom\nzoommode\nzoomshowarm"
  
  -- these are rumored to work, but I couldn't verify them. I include them anyway, just in case
  varsline=varsline.."\nafxcfg\nbigwndframes\nccresettab\ndefrecpath\nlazyupds\nmidiedit\nmidilatmask\nprojmetrofn1\nprojmetrofn2\nprojmetropattern\nprojrelsnap\nreccfg\nreuseeditor\nrulerlabelmargin\nvstbr32"
  varsline=varsline.."\nhidpi_win32"

  
  -- prepare all entries and read their current values
  config_var_update_counter=0
  configvars_int={} -- variable-values
  configvars_float={}
  configvars_string={}
  configvars_names={} -- variable-names
  counter=0
  configvars_num=1 -- number of variables(for later use)
  for line in varsline:gmatch("(.-)\n") do
    configvars_names[configvars_num]=line
    configvars_int[line]=reaper.SNM_GetIntConfigVar(line,-8)
    configvars_float[line]=reaper.SNM_GetDoubleConfigVar(line,-8)
    if reaper.get_config_var_string==nil then configvars_string[line]="String variable not available in this Reaper-version, sorry." else _t,configvars_string[line]=reaper.get_config_var_string(line) end
    configvars_num=configvars_num+1
  end
  

function linenumber_layouter(stringer, number)
  number=tostring(number)
  stringer=stringer:sub(0,-number:len())
  return stringer..number
end

function ultraschall.SplitStringAtLineFeedToArray(unsplitstring)
  local array={}
  local i=1
  if unsplitstring==nil then return -1 end
  local astring=unsplitstring
  local pos
  astring=string.gsub (unsplitstring, "\r\n", "\n")
  astring=string.gsub (astring, "\n\r", "\n")
  astring=string.gsub (astring, "\r", "\n")
  astring=astring.."\n"
  while astring:match("%c") do
    array[i],pos=astring:match("(.-)\n()")
--    reaper.MB(array[i], tostring(pos),0)
    if sub~=nil then break end 
    astring=astring:sub(pos,-1)
    i=i+1
  end
  if astring~="" and astring~=nil then array[i]=astring
  else i=i-1
  end
  return i,array
end

function ultraschall.ConvertIntegerToBits(integer)
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

function GetAllFilesnamesInPath(path)
  -- check parameters
  if type(path)~="string" then return -1 end

  -- prepare variables
  local Files={}
  local count=1
  local string=""
  
  -- get all filenames in path
  while string~=nil do
    string=reaper.EnumerateFiles(path, count-1)
    if string~=nil then Files[count]=path..string end
    count=count+1
  end
  
  -- return results
  return count-2, Files
end

function StateChunkLayouter(statechunk)
  if type(statechunk)~="string" then return nil end  
  local num_tabs=0
  local newsc=""
  for k in string.gmatch(statechunk, "(.-\n)") do
    if k:sub(1,1)==">" then num_tabs=num_tabs-1 end
    for i=0, num_tabs-1 do
      newsc=newsc.."    "
    end
    if k:sub(1,1)=="<" then num_tabs=num_tabs+1 end
    newsc=newsc..k
  end
  return newsc
end

function ReadFullFile(filename_with_path, binary)
  -- Returns the whole file filename_with_path or nil in case of error
  
  -- check parameters
  if filename_with_path == nil then return nil end
  if reaper.file_exists(filename_with_path)==false then return nil end
  
  -- prepare variables
  if binary==true then binary="b" else binary="" end
  local linenumber=0
  
  -- read file
  local file=io.open(filename_with_path,"r"..binary)
  local filecontent=file:read("a")
  
  -- count lines in file, when non binary
  if binary~=true then
    for w in string.gmatch(filecontent, "\n") do
      linenumber=linenumber+1
    end
  else
    linenumber=-1
  end
  file:close()
  -- return read file, length and linenumbers
  return filecontent, filecontent:len(), linenumber
end

function GetPath(str,sep)

  -- check parameters
  if type(str)~="string" then return "", "" end
  if sep~=nil and type(sep)~="string" then return "", "" end
  
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

function GetProjectStateChunk(Project) 
  if reaper.GetPlayState()~=0 then return "No playback/recording, while updating the ProjectStateChunk.\n" end
  --if Project~=nil then return -2 end
  local currentproject=reaper.EnumProjects(-1,"")
  reaper.PreventUIRefresh(1)
  if Project~=nil then
    reaper.SelectProjectInstance(Project)
  end
  local Path=reaper.GetResourcePath().."\\QueuedRenders\\"
  local ProjectStateChunk=""
  local filecount, files = GetAllFilesnamesInPath(Path)
  local retval, item, endposition, numchannels, Samplerate, Filetype, editcursorposition, track, temp
  if reaper.GetProjectLength(0)==0 then 
    temp=true
--    retval, item, endposition, numchannels, Samplerate, Filetype, editcursorposition, track = ultraschall.InsertMediaItemFromFile(ultraschall.Api_Path.."/misc/silence.flac", 0, 0, -1, 0)
    reaper.Main_OnCommand(40214,0)
    track=reaper.GetTrack(0,0)
  end
  
  for i=1, filecount do
    local filepath,filename=GetPath(files[i])
    os.rename(files[i], filepath.."US"..filename)
  end
  
  local start, endit = reaper.GetSet_LoopTimeRange(false, false, -10, -10, false)
  if start==0 and endit==0 then reaper.GetSet_LoopTimeRange(true, false, 0, 1, false) end
  reaper.Main_OnCommand(41823,0)

  if temp==true then
    retval, sc=reaper.GetTrackStateChunk(track, "", false)
    reaper.DeleteTrackMediaItem(track, reaper.GetMediaItem(0,reaper.CountMediaItems(0)-1))
    reaper.DeleteTrack(track)
  end
  
  local filecount2, files2 = GetAllFilesnamesInPath(Path)  
  if files2[1]==nil then files2[1]="" end
  while reaper.file_exists(files2[1])==false do
    filecount2, files2 = GetAllFilesnamesInPath(Path)
    if files2[1]==nil then files2[1]="" end
  end
  
  
  for i=1, filecount2 do
    if files2[i]:match(Path.."qrender")~=nil then 
      ProjectStateChunk=ReadFullFile(files2[i]) 
      os.remove(files2[i]) break 
    end
  end
  
  for i=1, filecount do
    local filepath,filename=GetPath(files[i])
    os.rename(filepath.."US"..filename, files[i])
  end

  if Project~=nil then
    reaper.SelectProjectInstance(currentproject)
  end    
  reaper.PreventUIRefresh(-1)
  ProjectStateChunk=string.gsub(ProjectStateChunk,"  QUEUED_RENDER_OUTFILE.-\n","")
  ProjectStateChunk=string.gsub(ProjectStateChunk,"  QUEUED_RENDER_ORIGINAL_FILENAME.-\n","")
  if temp==true then
    ProjectStateChunk, ProjectStateChunk2=ProjectStateChunk:match("(.*)<TRACK.-NAME \"\".-%c%s%s>(.*)")
    ProjectStateChunk=ProjectStateChunk..ProjectStateChunk2
  end
  if start==0 and endit==0 then retval = ultraschall.SetProject_Selection(nil, 0, 0, 0, 0, ProjectStateChunk) end
  return ProjectStateChunk
end

function ultraschall.SetProject_Selection(projectfilename_with_path, starttime, endtime, starttime2, endtime2, ProjectStateChunk)

 local FileStart=ProjectStateChunk:match("(<REAPER_PROJECT.-SELECTION%s).-%c")
  local FileEnd=ProjectStateChunk:match("<REAPER_PROJECT.-SELECTION2%s.-%c(.*)")
  
  ProjectStateChunk=FileStart..starttime.." "..endtime.."\n  SELECTION2 "..starttime2.." "..endtime2.."\n"..FileEnd
  if projectfilename_with_path~=nil then return ultraschall.WriteValueToFile(projectfilename_with_path, ProjectStateChunk), ProjectStateChunk
  else return 1, ProjectStateChunk
  end
end

function DrawUltraschallLogo(x,y)
  pixtable={200.0,134.0,914,0,0,14,0,45,0,41,8,40,0,41,0,39,0,34,0,13,118,0,0,58,14,163,0,132,0,76,0,6,115,0,0,57,16,163,0,151,0,30,114,0,0,9,0,29,9,26,1,25,0,29,0,50,0,101,0,160,1,163,0,30,130,0,0,17,0,145,0,163,0,134,131,0,0,30,1,163,0,54,131,0,0,102,0,163,0,98,0,15,130,0,0,57,0,163,0,128,0,41,130,0,0,36,0,163,0,153,0,64,130,0,0,34,0,163,0,157,0,67,130,0,0,40,0,163,0,144,0,56,130,0,0,73,0,163,0,116,0,30,130,0,0,123,0,163,0,85,0,5,129,0,0,74,1,163,0,31,129,0,0,85,1,163,0,97,113,0,0,29,0,93,0,82,9,81,0,80,0,86,0,118,0,157,1,163,0,121,114,0,0,59,16,163,0,85,115,0,0,45,0,146,0,130,8,128,0,129,0,130,0,126,0,99,0,62,0,13,251,0,0,39,0,129,0,114,9,113,0,113,0,115,0,118,3,120,0,139,0,80,0,19,111,0,0,59,19,163,0,113,0,28,111,0,0,34,0,110,0,97,14,97,0,85,0,134,0,163,0,111,0,26,130,0,0,90,0,163,0,111,0,26,130,0,0,93,0,163,0,111,0,26,130,0,0,94,0,163,0,111,
  0,26,130,0,0,94,0,163,0,111,0,26,111,0,0,32,0,111,0,80,15,0,0,94,0,163,0,111,0,26,111,0,0,58,0,163,0,148,0,4,14,0,0,94,0,163,0,111,0,26,111,0,0,57,0,163,0,146,0,2,14,0,0,94,0,163,0,111,0,26,111,0,0,57,0,163,0,146,0,2,14,0,0,94,0,163,0,111,0,26,111,0,0,57,0,163,0,146,0,2,14,0,0,95,0,163,0,111,0,26,111,0,0,57,0,163,0,146,0,2,14,0,0,95,0,163,0,112,0,27,111,0,0,57,0,163,0,141,15,0,0,11,0,29,0,15,0,4,111,0,0,57,0,163,0,150,0,41,0,34,12,41,0,44,0,27,0,15,0,12,0,4,111,0,0,57,19,163,0,113,0,28,111,0,0,57,19,163,0,111,0,26,59,0,0,30,0,63,0,97,0,145,0,160,0,75,45,0,0,57,0,163,0,148,0,24,0,16,14,23,0,27,0,16,0,4,54,0,0,3,0,41,0,97,0,145,2,163,0,156,0,132,0,108,0,82,0,9,44,0,0,57,0,163,0,142,72,0,0,53,0,121,2,163,0,134,0,93,0,38,0,3,49,0,0,57,0,163,0,146,0,2,68,0,0,37,0,123,1,163,0,149,0,87,0,27,54,0,0,57,
  0,163,0,146,0,2,66,0,0,65,0,160,1,163,0,88,0,10,57,0,0,57,0,163,0,146,0,2,64,0,0,83,1,163,0,127,0,32,60,0,0,57,0,163,0,146,0,2,62,0,0,72,1,163,0,116,0,12,62,0,0,58,0,163,0,148,0,3,60,0,0,48,0,160,0,163,0,108,0,9,64,0,0,21,0,76,0,52,59,0,0,7,0,127,0,163,0,130,0,11,66,0,0,25,0,79,0,76,0,100,0,101,14,100,0,115,0,67,0,16,38,0,0,65,1,163,0,43,68,0,0,58,19,163,0,116,0,30,36,0,0,3,0,129,0,163,0,96,70,0,0,57,0,163,0,157,0,118,0,117,3,119,0,117,0,118,0,158,0,163,0,132,0,112,4,119,0,137,0,79,0,18,35,0,0,34,1,163,0,41,71,0,0,57,0,163,0,135,7,0,0,139,0,163,0,48,43,0,0,69,0,163,0,126,26,0,0,18,0,36,0,46,0,57,0,64,0,71,0,75,0,72,0,64,0,57,0,48,0,37,0,21,33,0,0,57,0,163,0,139,7,0,0,142,0,163,0,50,42,0,0,99,0,163,0,88,22,0,0,23,0,56,0,93,0,120,0,140,0,162,11,163,0,144,0,121,0,98,0,62,0,21,28,0,0,57,0,163,0,139,
  7,0,0,143,0,163,0,51,41,0,0,117,0,163,0,56,20,0,0,31,0,95,0,138,22,163,0,43,27,0,0,57,0,163,0,139,7,0,0,144,0,163,0,49,40,0,0,132,0,163,0,38,18,0,0,17,0,80,0,140,5,163,0,147,0,114,0,95,0,80,0,63,0,44,0,36,0,33,0,32,0,33,0,36,0,44,0,63,0,81,0,94,0,114,0,148,3,163,0,32,26,0,0,57,0,163,0,139,7,0,0,142,0,163,0,51,39,0,0,141,0,163,0,31,17,0,0,21,0,110,4,163,0,150,0,112,0,58,0,20,0,2,14,0,0,2,0,20,0,58,0,111,1,163,0,24,25,0,0,56,0,163,0,138,7,0,0,140,0,163,0,141,0,26,37,0,0,132,0,163,0,25,16,0,0,29,0,116,3,163,0,149,0,92,0,40,0,2,23,0,0,70,0,54,25,0,0,44,0,163,0,153,0,6,5,0,0,9,0,153,2,163,0,90,35,0,0,128,0,163,0,20,15,0,0,9,0,108,3,163,0,130,0,46,55,0,0,17,1,163,0,50,5,0,0,56,0,163,0,144,0,131,1,163,0,152,0,43,32,0,0,104,0,163,0,36,15,0,0,62,0,158,2,163,0,125,0,36,58,0,0,130,0,163,0,121,5,0,0,125,
  0,163,0,90,0,0,0,85,2,163,0,102,0,6,29,0,0,78,0,163,0,51,14,0,0,6,0,119,2,163,0,142,0,38,60,0,0,55,1,163,0,122,0,34,1,18,0,35,0,125,1,163,0,22,1,0,0,29,0,142,1,163,0,155,0,46,27,0,0,46,0,163,0,82,14,0,0,44,0,156,1,163,0,160,0,70,63,0,0,102,7,163,0,60,4,0,0,78,2,163,0,83,0,9,24,0,0,17,0,163,0,111,14,0,0,78,2,163,0,126,0,11,65,0,0,64,0,154,3,163,0,130,0,28,6,0,0,17,0,130,0,163,0,115,0,29,24,0,0,137,0,158,0,3,13,0,0,103,2,163,0,81,19,0,0,2,0,12,0,20,0,25,0,26,0,25,0,20,0,12,0,2,39,0,0,4,0,30,0,45,0,43,0,21,10,0,0,94,0,102,0,33,23,0,0,85,0,163,0,29,13,0,0,114,2,163,0,44,16,0,0,25,0,55,0,90,0,128,0,147,0,155,0,162,2,163,0,162,0,155,0,146,0,127,0,92,0,56,0,25,51,0,0,2,0,13,0,9,22,0,0,29,0,163,0,81,13,0,0,120,1,163,0,144,0,20,14,0,0,40,0,95,0,140,16,163,0,140,0,96,0,41,47,0,0,46,0,135,0,100,
  0,27,22,0,0,151,0,136,13,0,0,118,1,163,0,134,0,8,12,0,0,4,0,77,0,148,22,163,0,149,0,80,0,5,41,0,0,10,0,81,0,149,1,163,0,114,0,29,21,0,0,74,0,163,0,32,12,0,0,105,1,163,0,134,0,5,11,0,0,7,0,85,0,159,7,163,0,162,0,146,0,123,0,107,0,102,0,100,0,102,0,106,0,120,0,142,0,160,7,163,0,158,0,85,0,6,37,0,0,45,0,114,3,163,0,145,0,53,0,6,20,0,0,7,0,163,0,102,12,0,0,85,1,163,0,140,0,8,11,0,0,59,0,161,6,163,0,133,0,90,0,41,0,15,0,2,7,0,0,13,0,33,0,79,0,126,0,158,5,163,0,161,0,61,33,0,0,12,0,74,0,149,2,163,0,162,0,109,0,34,23,0,0,107,0,163,0,6,11,0,0,55,1,163,0,154,0,20,10,0,0,17,0,129,5,163,0,135,0,72,0,18,16,0,0,12,0,61,0,123,5,163,0,128,0,20,29,0,0,48,0,112,0,162,2,163,0,131,0,62,0,10,24,0,0,23,0,163,0,78,11,0,0,27,2,163,0,37,10,0,0,58,5,163,0,126,0,34,22,0,0,20,0,107,5,163,0,62,25,0,0,11,0,85,0,150,2,163,0,153,
  1,163,0,30,26,0,0,109,0,163,12,0,0,123,1,163,0,67,10,0,0,95,4,163,0,138,0,41,26,0,0,26,0,123,4,163,0,93,22,0,0,46,0,115,3,163,0,118,0,40,0,17,0,161,0,163,0,32,25,0,0,25,0,163,0,71,11,0,0,79,1,163,0,100,10,0,0,110,4,163,0,79,30,0,0,58,0,162,3,163,0,111,18,0,0,13,0,78,0,153,2,163,0,148,0,81,0,11,1,0,0,15,1,163,0,34,25,0,0,118,0,163,11,0,0,45,1,163,0,146,0,8,9,0,0,117,3,163,0,147,0,32,32,0,0,15,0,130,3,163,0,118,16,0,0,43,2,163,0,141,0,95,0,41,4,0,0,17,1,163,0,34,24,0,0,16,0,102,0,63,11,0,0,62,0,119,0,103,0,40,9,0,0,117,3,163,0,125,13,0,0,6,0,23,0,40,0,56,0,60,0,56,0,41,0,23,0,6,13,0,0,97,3,163,0,58,15,0,0,59,1,163,0,161,0,47,6,0,0,17,1,163,0,34,52,0,0,117,3,163,0,107,11,0,0,37,0,85,0,123,0,154,6,163,0,155,0,123,0,88,0,40,11,0,0,81,2,163,0,109,15,0,0,28,0,146,2,163,0,138,0,78,0,18,3,0,0,17,1,163,
  0,34,52,0,0,114,2,163,0,102,9,0,0,2,0,63,0,145,14,163,0,149,0,68,0,2,9,0,0,79,2,163,0,23,16,0,0,39,0,118,3,163,0,120,0,44,0,2,0,0,0,14,1,163,0,34,53,0,0,15,0,126,0,123,9,0,0,62,0,151,18,163,0,155,0,67,9,0,0,91,1,163,0,66,18,0,0,13,0,75,0,139,2,163,0,151,0,78,0,43,0,161,0,163,0,30,54,0,1,2,7,0,0,18,0,133,22,163,0,141,0,24,8,0,0,110,0,163,0,115,21,0,0,32,0,107,5,163,0,38,63,0,0,55,8,163,0,130,0,94,0,79,0,67,0,62,0,67,0,78,0,92,0,125,0,162,7,163,0,61,7,0,0,7,0,157,0,163,0,6,22,0,0,13,0,71,0,137,2,163,0,156,0,102,0,40,60,0,0,76,6,163,0,144,0,74,0,11,8,0,0,8,0,64,0,137,6,163,0,85,7,0,0,48,0,163,0,60,25,0,0,32,0,111,0,162,2,163,0,146,0,72,0,10,56,0,0,80,5,163,0,143,0,49,14,0,0,41,0,134,5,163,0,84,7,0,0,121,0,114,27,0,0,10,0,72,0,136,3,163,0,79,0,12,53,0,0,52,5,163,0,87,18,0,0,72,5,163,0,74,
  6,0,0,30,0,117,0,5,29,0,0,20,0,94,0,160,0,163,0,116,0,30,53,0,0,14,0,146,3,163,0,53,20,0,0,38,0,156,4,163,0,40,6,0,0,65,0,38,17,0,0,4,0,19,0,21,0,7,4,0,0,6,0,7,3,0,0,81,0,87,0,27,54,0,0,34,2,163,0,41,9,0,0,16,0,27,0,16,9,0,0,24,0,155,3,163,0,146,0,6,5,0,0,13,0,14,15,0,0,13,0,96,0,153,1,163,0,157,0,109,0,20,2,0,0,2,0,131,0,153,0,134,0,140,0,118,0,12,57,0,0,95,0,163,0,48,6,0,0,9,0,68,0,119,0,142,0,160,0,163,0,160,0,143,0,120,0,70,0,9,6,0,0,28,0,162,3,163,0,92,22,0,0,44,7,163,0,56,2,0,0,76,3,163,0,104,57,0,0,30,0,63,6,0,0,73,10,163,0,79,6,0,0,61,4,163,0,33,20,0,0,19,0,158,8,163,0,23,2,0,0,119,3,163,0,24,63,0,0,12,0,130,12,163,0,135,0,13,5,0,0,102,3,163,0,104,20,0,0,104,9,163,0,108,2,0,0,58,3,163,0,73,62,0,0,14,0,148,14,163,0,152,0,20,4,0,0,20,0,162,2,163,0,160,0,16,18,0,0,12,
  0,156,9,163,0,160,0,18,1,0,0,20,3,163,0,104,0,20,61,0,0,132,16,163,0,134,5,0,0,96,3,163,0,73,18,0,0,51,4,163,0,75,0,101,4,163,0,63,2,0,0,141,2,163,0,128,0,43,60,0,0,93,18,163,0,98,4,0,0,25,3,163,0,127,18,0,0,72,3,163,0,96,1,0,0,141,3,163,0,99,2,0,0,122,2,163,0,148,0,64,59,0,0,23,20,163,0,28,4,0,0,124,2,163,0,159,0,15,17,0,0,79,3,163,0,52,1,0,0,98,3,163,0,141,2,0,0,139,2,163,0,151,0,67,59,0,0,83,20,163,0,91,4,0,0,79,3,163,0,46,17,0,0,77,3,163,0,42,1,0,0,55,4,163,0,44,0,0,0,32,3,163,0,141,0,57,59,0,0,144,20,163,0,136,4,0,0,52,3,163,0,67,17,0,0,62,3,163,0,51,1,0,0,22,4,163,0,139,0,58,0,131,3,163,0,113,0,29,58,0,0,25,22,163,0,35,3,0,0,23,3,163,0,87,17,0,0,29,3,163,0,83,2,0,0,124,10,163,0,78,59,0,0,49,22,163,0,61,3,0,0,8,0,153,2,163,0,106,18,0,0,139,2,163,0,129,2,0,0,55,9,163,0,162,0,20,59,0,0,65,
  22,163,0,71,3,0,0,6,0,149,2,163,0,114,18,0,0,72,3,163,0,70,2,0,0,115,8,163,0,71,60,0,0,59,22,163,0,67,3,0,0,6,0,150,2,163,0,112,18,0,0,12,1,70,0,65,0,84,0,51,2,0,0,6,0,126,6,163,0,96,61,0,0,38,22,163,0,51,3,0,0,10,0,156,2,163,0,100,29,0,0,41,0,121,0,153,1,163,0,136,0,44,62,0,0,15,0,159,20,163,0,158,0,15,3,0,0,30,3,163,0,81,25,0,0,6,0,20,0,29,0,20,0,0,0,5,0,8,67,0,0,120,20,163,0,116,4,0,0,58,3,163,0,60,22,0,0,22,0,86,0,126,0,153,3,163,0,153,0,125,0,86,0,32,65,0,0,57,20,163,0,64,4,0,0,90,3,163,0,38,20,0,0,4,0,93,11,163,0,134,0,29,64,0,0,137,18,163,0,141,0,2,4,0,0,137,2,163,0,148,0,4,19,0,0,12,0,141,14,163,0,55,63,0,0,49,18,163,0,51,4,0,0,46,3,163,0,112,20,0,0,124,16,163,0,30,63,0,0,73,16,163,0,81,5,0,0,117,3,163,0,48,19,0,0,67,17,163,0,128,64,0,0,86,14,163,0,88,5,0,0,42,3,163,0,142,20,0,0,139,
  4,163,0,153,0,107,0,73,0,58,0,57,0,65,0,93,0,137,5,163,0,42,64,0,0,51,0,162,11,163,0,58,6,0,0,129,3,163,0,79,19,0,0,33,4,163,0,112,7,0,0,64,4,163,0,88,0,7,55,0,0,36,0,99,6,0,0,11,0,87,0,152,6,163,0,153,0,90,0,13,6,0,0,92,3,163,0,150,0,9,19,0,0,65,3,163,0,125,9,0,0,70,3,163,0,113,0,29,55,0,0,98,0,163,0,88,7,0,0,2,0,40,0,78,0,92,0,98,0,92,0,78,0,41,0,2,7,0,0,64,4,163,0,57,5,0,1,2,12,0,0,81,3,163,0,60,9,0,0,13,0,158,2,163,0,135,0,51,54,0,0,39,2,163,0,79,22,0,0,60,4,163,0,112,6,0,0,23,0,21,12,0,0,88,3,163,0,39,10,0,0,130,2,163,0,147,0,62,53,0,0,20,0,157,3,163,0,98,20,0,0,84,4,163,0,143,0,5,6,0,0,82,0,33,12,0,0,84,3,163,0,37,10,0,0,125,2,163,0,142,0,57,53,0,0,28,5,163,0,134,0,27,16,0,0,18,0,123,5,163,0,34,6,0,0,60,0,121,13,0,0,72,3,163,0,44,10,0,0,140,2,163,0,123,0,38,54,0,0,30,
  0,158,5,163,0,109,0,20,12,0,0,13,0,99,6,163,0,34,7,0,0,149,0,99,13,0,0,49,3,163,0,58,9,0,0,15,0,160,2,163,0,100,0,16,55,0,0,30,0,153,6,163,0,116,0,62,0,24,6,0,0,20,0,57,0,108,0,160,5,163,0,157,0,36,7,0,0,83,0,163,0,37,13,0,0,15,0,159,2,163,0,95,9,0,0,38,3,163,0,71,57,0,0,6,0,126,8,163,0,142,0,124,0,114,0,111,0,114,0,123,0,140,0,162,7,163,0,134,0,12,7,0,0,34,0,163,0,142,15,0,0,128,2,163,0,135,9,0,0,85,3,163,0,28,48,0,0,8,0,16,8,0,0,72,22,163,0,78,8,0,0,13,0,144,0,163,0,96,15,0,0,67,3,163,0,66,7,0,0,11,0,151,2,163,0,132,48,0,0,22,0,137,0,163,0,20,8,0,0,9,0,97,18,163,0,100,0,13,9,0,0,131,1,163,0,47,15,0,0,11,1,70,0,65,0,85,0,46,7,0,0,22,0,81,0,67,0,67,0,79,0,30,47,0,0,105,2,163,0,142,0,13,9,0,0,16,0,85,0,139,12,163,0,143,0,87,0,21,10,0,0,121,1,163,0,144,0,3,14,0,0,2,0,3,3,0,0,2,0,5,
  5,4,0,5,0,3,3,0,0,2,0,3,0,2,32,0,0,2,11,0,0,85,3,163,0,148,0,21,11,0,0,26,0,64,0,106,0,139,0,149,0,154,0,156,0,154,0,149,0,139,0,107,0,64,0,29,12,0,0,126,2,163,0,88,15,0,0,51,0,163,0,148,16,147,0,163,0,99,0,23,17,0,0,15,0,109,0,90,11,0,0,50,0,129,0,118,0,58,9,0,0,77,3,163,0,160,0,42,14,0,0,4,0,11,0,14,0,11,0,4,14,0,0,22,0,143,3,163,0,34,15,0,0,58,19,163,0,113,0,27,18,0,0,106,0,163,0,24,10,0,0,20,0,157,0,163,0,161,0,23,9,0,0,77,4,163,0,87,32,0,0,62,4,163,0,77,16,0,0,57,19,163,0,111,0,26,18,0,0,21,0,163,0,99,11,0,0,52,1,163,0,119,10,0,0,69,4,163,0,132,0,25,28,0,0,11,0,114,4,163,0,69,17,0,0,57,19,163,0,111,0,26,19,0,0,95,0,163,0,25,11,0,0,98,1,163,0,88,10,0,0,48,5,163,0,100,0,8,25,0,0,79,5,163,0,46,18,0,0,58,19,163,0,113,0,29,19,0,0,18,0,163,0,111,11,0,0,4,0,137,1,163,0,61,10,0,0,18,0,131,
  4,163,0,161,0,95,0,23,20,0,0,14,0,79,0,151,4,163,0,135,0,21,19,0,0,30,0,99,0,87,3,86,0,79,0,95,3,163,0,121,0,73,4,86,0,100,0,58,0,14,20,0,0,93,0,163,0,33,11,0,0,22,0,158,1,163,0,42,11,0,0,74,6,163,0,128,0,73,0,15,14,0,0,7,0,62,0,120,6,163,0,74,29,0,0,16,0,160,2,163,0,71,29,0,0,4,0,163,0,138,12,0,0,55,1,163,0,156,0,28,11,0,0,22,0,119,6,163,0,160,0,132,0,95,0,62,0,46,0,29,0,12,2,4,0,9,0,25,0,43,0,59,0,87,0,124,0,156,6,163,0,119,0,23,30,0,0,21,3,163,0,75,30,0,0,65,0,163,0,66,12,0,0,67,1,163,0,156,0,23,12,0,0,32,0,127,10,163,0,157,0,148,0,146,0,148,0,155,10,163,0,127,0,31,32,0,0,21,3,163,0,76,31,0,0,136,0,163,0,13,12,0,0,78,1,163,0,156,0,32,13,0,0,29,0,97,0,153,20,163,0,153,0,98,0,32,34,0,0,21,3,163,0,76,31,0,0,20,0,163,0,127,13,0,0,79,2,163,0,48,15,0,0,44,0,90,0,140,14,163,0,139,0,90,0,45,0,2,36,0,
  0,19,0,162,2,163,0,73,32,0,0,76,0,163,0,71,13,0,0,73,2,163,0,74,17,0,0,25,0,50,0,78,0,104,0,114,0,123,0,128,0,130,0,128,0,123,0,114,0,104,0,78,0,51,0,26,40,0,0,19,0,162,2,163,0,73,33,0,0,122,0,163,0,34,13,0,0,58,2,163,0,114,64,0,0,47,0,155,0,137,3,135,0,133,0,139,3,163,0,148,0,131,4,135,0,156,0,91,0,21,24,0,0,12,0,163,0,153,0,6,13,0,0,35,0,155,1,163,0,151,0,41,62,0,0,58,19,163,0,113,0,28,25,0,0,33,0,163,0,134,14,0,0,3,0,118,2,163,0,111,0,8,60,0,0,57,19,163,0,111,0,26,26,0,0,69,0,163,0,98,15,0,0,71,2,163,0,156,0,74,59,0,0,57,19,163,0,111,0,26,27,0,0,87,0,163,0,86,15,0,0,15,0,126,2,163,0,155,0,67,57,0,0,58,19,163,0,113,0,27,28,0,0,110,0,163,0,72,16,0,0,51,0,147,2,163,0,152,0,86,0,23,26,0,0,2,0,3,25,0,0,34,0,111,0,99,13,98,0,99,0,96,0,78,0,84,0,62,0,20,29,0,0,112,0,163,0,75,17,0,0,57,0,147,3,163,0,130,0,78,
  0,18,22,0,0,24,0,110,0,37,44,0,0,3,0,85,0,81,0,27,30,0,0,121,0,163,0,82,18,0,0,60,0,132,3,163,0,162,0,132,0,89,0,56,0,27,14,0,0,29,0,57,0,88,0,135,0,163,0,126,42,0,0,2,0,50,0,117,1,163,0,112,0,27,31,0,0,114,0,163,0,93,19,0,0,26,0,97,0,157,5,163,0,148,0,130,0,114,0,93,0,74,0,62,0,55,0,52,0,54,0,63,0,76,0,92,0,114,0,130,0,148,3,163,0,120,41,0,0,15,0,90,0,155,3,163,0,111,0,26,32,0,0,98,0,163,0,114,20,0,0,2,0,44,0,88,0,131,0,161,19,163,0,116,0,2,38,0,0,3,0,53,0,121,6,163,0,111,0,26,33,0,0,77,0,163,0,151,0,18,22,0,0,9,0,45,0,75,0,94,0,123,0,149,8,163,0,151,0,127,0,98,0,76,0,49,0,12,38,0,0,24,0,96,0,153,8,163,0,113,0,27,34,0,0,58,1,163,0,52,26,0,0,4,0,19,0,29,0,34,0,38,0,40,0,39,0,35,0,30,0,20,0,5,40,0,0,4,0,57,0,122,11,163,0,105,0,22,35,0,0,18,0,143,0,163,0,113,0,2,74,0,0,30,0,98,0,155,10,163,
  0,146,0,95,0,43,0,4,38,0,0,106,0,163,0,154,0,41,70,0,0,4,0,58,0,127,11,163,0,143,0,44,43,0,0,41,0,159,0,163,0,118,0,8,67,0,0,37,10,163,0,154,0,162,1,163,0,109,45,0,0,4,0,106,1,163,0,78,66,0,0,58,7,163,0,141,0,90,0,14,0,56,2,163,0,113,47,0,0,27,0,135,1,163,0,77,64,0,0,57,4,163,0,146,0,56,3,0,0,55,2,163,0,113,49,0,0,56,0,155,0,163,0,160,0,74,0,4,61,0,0,57,4,163,0,148,0,81,0,38,0,6,1,0,0,53,2,163,0,113,51,0,0,51,0,151,1,163,0,113,0,26,59,0,0,58,8,163,0,124,0,48,0,65,2,163,0,113,53,0,0,50,0,137,1,163,0,153,0,78,0,21,56,0,0,27,0,139,9,163,0,160,2,163,0,109,55,0,0,18,0,88,0,158,1,163,0,157,0,98,0,50,0,11,54,0,0,30,0,94,0,153,10,163,0,151,0,76,0,24,56,0,0,39,0,102,0,162,2,163,0,140,0,100,0,63,0,33,0,18,0,2,0,4,0,6,48,0,0,6,0,67,0,132,11,163,0,126,0,74,0,18,56,0,0,22,0,65,0,111,5,163,0,104,52,0,0,27,0,95,
  0,161,10,163,0,111,0,26,58,0,0,2,0,23,0,47,0,81,0,123,0,95,0,19,54,0,0,9,0,64,0,130,8,163,0,112,0,27,123,0,0,25,0,89,0,151,5,163,0,111,0,26,125,0,0,4,0,63,0,128,3,163,0,111,0,26,128,0,0,16,0,83,0,152,0,163,0,113,0,27,131,0,0,71,0,74,0,24,111,0,0,45,0,148,0,131,13,130,0,130,0,131,0,117,0,119,0,72,0,19,111,0,0,58,19,163,0,113,0,27,111,0,0,57,19,163,0,111,0,26,111,0,0,57,19,163,0,111,0,26,111,0,0,58,19,163,0,111,0,26,111,0,0,40,0,131,0,116,11,115,0,109,0,127,3,163,0,111,0,26,127,0,0,37,3,163,0,111,0,26,127,0,0,41,3,163,0,111,0,26,127,0,0,42,3,163,0,111,0,26,127,0,0,42,3,163,0,111,0,26,127,0,0,42,3,163,0,111,0,26,127,0,0,42,3,163,0,111,0,26,127,0,0,42,3,163,0,111,0,26,127,0,0,43,3,163,0,112,0,27,127,0,0,31,0,153,0,146,0,142,0,163,0,96,0,22,111,0,0,9,0,29,12,25,0,23,0,29,0,42,0,41,0,41,0,47,0,27,0,6,111,0,0,57,14,163,0,161,1,151,
  0,151,0,163,0,102,0,24,111,0,0,58,19,163,0,111,0,27,111,0,0,57,19,163,0,111,0,26,111,0,0,57,19,163,0,111,0,26,111,0,0,58,19,163,0,111,0,26,111,0,0,22,0,72,0,64,11,63,0,49,0,88,3,163,0,111,0,26,127,0,0,36,3,163,0,111,0,26,127,0,0,42,3,163,0,111,0,26,127,0,0,42,3,163,0,111,0,26,127,0,0,42,3,163,0,111,0,26,127,0,0,42,3,163,0,111,0,26,127,0,0,42,3,163,0,111,0,26,127,0,0,42,3,163,0,111,0,26,127,0,0,44,3,163,0,113,0,29,127,0,0,25,0,107,0,102,0,99,0,114,0,67,0,16}
  
  
  count=3
  count2=1
  pixtable2={}
  while pixtable[count]~=nil do
    for i=0, pixtable[count] do
      if pixtable[count+1]==0 then 
        pixtable2[count2]=-1
      else
        pixtable2[count2]=pixtable[count+1]
      end
      count2=count2+1
    end
    count=count+2
  end
  
  
  
  count=0
  scale=1
  gfx.setimgdim(2, pixtable[1], pixtable[2])
  gfx.dest=2
  for x=0, pixtable[1] do
    for y=0, pixtable[2] do
      count=count+1
      if pixtable2[count]==nil then break end
        if pixtable2[count]~=-1 then        
          gfx.set(pixtable2[count]/254)
          gfx.line(x*scale,y*scale,x*scale,y*scale)
        end
    end
  end
--  gfx.x=gfx.w-120
  gfx.x=10
  gfx.y=-75+y
  --gfx.blurto(pixtable[1]*scale,pixtable[2]*scale)
  gfx.set(1,1,1,0.8,0,3)
  gfx.blit(2,0.5,0)
end

--DrawUltraschallLogo()

function draw_tabs(offsetx, offsety, font_size)
  Relative_font=(font_size/Width)*gfx.w
  if Relative_font>15 then Relative_font=15 end
  if Relative_font<10 then Relative_font=10 end
  local oldx=0
  local oldy=0
  local x,y
  gfx.x=110
  gfx.y=71
  gfx.setfont(2, "arial", 17*0.9)
  gfx.set(0.6)
  gfx.drawstr("- State-Inspector v3.0",0,2048,2048)
  
  gfx.setfont(2, "arial", Relative_font)
  for i=1, Tabs_Count do    
    gfx.x=oldx+6+offsetx
    gfx.y=5+offsety
    x,y=gfx.measurestr(Tabs[i])
    gfx.set(0.1)
    gfx.roundrect(oldx+offsetx,3+offsety,x+12,y+7,1,true)
    gfx.set(0.4)
    gfx.rect(oldx+offsetx+1,3+offsety+1,x+12-2,y+7-2,1)
    gfx.set(0.8)
    gfx.drawstr(Tabs[i])
    Tabs_Click[i]={oldx+offsetx, 1+offsety, oldx+x+offsetx, y+offsety+10}
--    gfx.set(1,0,0)                                                                       -- debug
--    gfx.line(Tabs_Click[i][1],Tabs_Click[i][2]+1,Tabs_Click[i][3]+13,Tabs_Click[i][4],0) -- debug
    oldx=x+oldx+13
    oldy=y+oldy    
  end
  gfx.set(0.8)
  gfx.line(0,offsety+1,2048,offsety+1)
  gfx.line(0,y+10+offsety,2048,y+offsety+10)
  gfx.line(0,y+35+offsety,2048,y+offsety+35)
  gfx.set(0.5)
  gfx.line(0,y+36+offsety,2048,y+offsety+36)
  Content_Offset_Y=Content_Offset_Y+y+offsety+14
end

function draw_menus()
  gfx.set(0.8)
  gfx.rect(0,0,2048,18,1)
  gfx.set(0.6)
  gfx.line(0,18,2048,18)
  gfx.set(0)
  gfx.x=8
  gfx.y=1
  for i=1, Menu_count do
    x,y=gfx.measurestr(Menus[i][1].."   ")
    Menus_Click[i]={gfx.x, gfx.y, gfx.x+x, gfx.y+y}
    gfx.drawstr(Menus[i][1].."    ")
    --gfx.line(table.unpack(Menus_Click[i])) -- debug
  end
end

function OpenMenu(menu)
  str=""
  count=2
  while Menus[menu][count]~=nil do
    str=str..Menus[menu][count].."|"
    count=count+1
  end
  gfx.x=Menus_Click[menu][1]-10
  gfx.y=Menus_Click[menu][4]
  gfx.showmenu(str:sub(1,-2))
end

function DrawUI(x,y,font_size)
  gfx.dest=3
  gfx.clear=reaper.ColorToNative(15,15,15)
  gfx.set(15/255)
  gfx.rect(0,0,gfx.w,gfx.h,1)
  draw_tabs(x,y,font_size)
  draw_menus()
  DrawUltraschallLogo(x,y)
end

function Tabs_Funcs.TrackStateChunk()  
  Relative_font=(font_size/Width)*gfx.w
  gfx.setfont(3,"Arial",12)
  gfx.set(15/255)
  gfx.x=Content_Offset_X-Tabs_Settings["TrackStateChunk"][3]
  gfx.y=Content_Offset_Y
  gfx.rect(gfx.x-100, gfx.y, 2048, gfx.h,1)
  gfx.set(1)
  if reaper.CountSelectedTracks()>0 then
    local retval, Tsc=reaper.GetTrackStateChunk(reaper.GetLastTouchedTrack(),"",false)
    local Tsc=StateChunkLayouter(Tsc)
    local count, Tsc=ultraschall.SplitStringAtLineFeedToArray(Tsc)
    if Tabs_Settings["TrackStateChunk"][2]<1 then Tabs_Settings["TrackStateChunk"][2]=1 end
    if Tabs_Settings["TrackStateChunk"][2]>count-1 then Tabs_Settings["TrackStateChunk"][2]=count-1 end
    for i=Tabs_Settings["TrackStateChunk"][2], count do
      LOL=i
      gfx.x=Content_Offset_X
      gfx.set(0.5)
      gfx.drawstr(linenumber_layouter("     ", i)..": ")
      gfx.set(0.8)
      gfx.drawstr(Tsc[i].."\n\n",0,2048,2048)
    end
    else
      gfx.x=Content_Offset_X
      gfx.drawstr("No MediaTrack selected...")
  end
end

function Tabs_Funcs.ProjectStateChunk(update)
  if reaper.GetProjectStateChangeCount(0)~=Tabs_Settings["ProjectStateChunk"][1] then
    Tabs_Settings["ProjectStateChunk"][4]=GetProjectStateChunk(0)
    Tabs_Settings["ProjectStateChunk"][1]=reaper.GetProjectStateChangeCount(0)
  end

  Relative_font=(font_size/Width)*gfx.w
  gfx.setfont(3,"Arial",12)
  gfx.set(15/255)
  gfx.x=Content_Offset_X-Tabs_Settings["ProjectStateChunk"][3]
  gfx.y=Content_Offset_Y
  gfx.rect(gfx.x-100, gfx.y, 2048, gfx.h,1)
  gfx.set(1)
  local Psc=Tabs_Settings["ProjectStateChunk"][4]
  local count, Psc=ultraschall.SplitStringAtLineFeedToArray(Psc)
  if Tabs_Settings["ProjectStateChunk"][2]<1 then Tabs_Settings["ProjectStateChunk"][2]=1 end
  if Tabs_Settings["ProjectStateChunk"][2]>count-1 then Tabs_Settings["ProjectStateChunk"][2]=count-1 end
  for i=Tabs_Settings["ProjectStateChunk"][2], count do
    LOL=i
    gfx.x=Content_Offset_X
    gfx.set(0.5)
    gfx.drawstr(linenumber_layouter("     ", i)..": ")
    gfx.set(0.8)
    gfx.drawstr(Psc[i].."\n\n",0,2048,2048)
  end    
end

function Tabs_Funcs.ItemStateChunk()
  Relative_font=(font_size/Width)*gfx.w
  gfx.setfont(3,"Arial",12)
  gfx.set(15/255)
  gfx.x=Content_Offset_X-Tabs_Settings["ItemStateChunk"][3]
  gfx.y=Content_Offset_Y
  gfx.rect(gfx.x-100, gfx.y, 2048, gfx.h,1)
  gfx.set(1)
  if reaper.CountSelectedMediaItems()>0 then
    local retval, Isc=reaper.GetItemStateChunk(reaper.GetSelectedMediaItem(0,0),"",false)
    local Isc=StateChunkLayouter(Isc)
    local count, Tsc=ultraschall.SplitStringAtLineFeedToArray(Isc)
    if Tabs_Settings["ItemStateChunk"][2]<1 then Tabs_Settings["ItemStateChunk"][2]=1 end
    if Tabs_Settings["ItemStateChunk"][2]>count-1 then Tabs_Settings["ItemStateChunk"][2]=count-1 end
    for i=Tabs_Settings["ItemStateChunk"][2], count do
      LOL=i
      gfx.x=Content_Offset_X
      gfx.set(0.5)
      gfx.drawstr(linenumber_layouter("     ", i)..": ")
      gfx.set(0.8)
      gfx.drawstr(Tsc[i].."\n\n",0,2048,2048)
    end
    else
      gfx.x=Content_Offset_X
      gfx.drawstr("No MediaItem selected...")
  end
end

function Tabs_Funcs.EnvelopeStateChunk()
  Relative_font=(font_size/Width)*gfx.w
  gfx.setfont(3,"Arial",12)
  gfx.set(15/255)
  gfx.x=Content_Offset_X-Tabs_Settings["EnvelopeStateChunk"][3]
  gfx.y=Content_Offset_Y
  gfx.rect(gfx.x-100, gfx.y, 2048, gfx.h,1)
  gfx.set(1)
  if reaper.GetSelectedEnvelope(0)~=nil then
    local retval, Esc=reaper.GetEnvelopeStateChunk(reaper.GetSelectedEnvelope(0),"",false)
    local Esc=StateChunkLayouter(Esc)
    local count, Tsc=ultraschall.SplitStringAtLineFeedToArray(Esc)
    if Tabs_Settings["EnvelopeStateChunk"][2]<1 then Tabs_Settings["EnvelopeStateChunk"][2]=1 end
    if Tabs_Settings["EnvelopeStateChunk"][2]>count-1 then Tabs_Settings["EnvelopeStateChunk"][2]=count-1 end
    for i=Tabs_Settings["EnvelopeStateChunk"][2], count do
      LOL=i
      gfx.x=Content_Offset_X
      gfx.set(0.5)
      gfx.drawstr(linenumber_layouter("     ", i)..": ")
      gfx.set(0.8)
      gfx.drawstr(Tsc[i].."\n\n",0,2048,2048)
    end
    else
      gfx.x=Content_Offset_X
      gfx.drawstr("No Envelope selected...")
  end
end

function Tabs_Funcs.ExtStates()
  gfx.x=Content_Offset_X
  gfx.y=Content_Offset_Y
  gfx.drawstr(reaper.time_precise())
end

function Tabs_Funcs.Dashboard()
  gfx.x=Content_Offset_X
  gfx.y=Content_Offset_Y
  gfx.drawstr(reaper.time_precise())
end

function Tabs_Funcs.Reaper_States()
end

function Tabs_Funcs.Developer_Tools()
end

function Tabs_Funcs.ConfigVars()
--[[
  gfx.drawstr("Hui"..reaper.time_precise())
--]]

--if lllll==nil then return end
  gfx.x=0
  gfx.y=0
  KOL=reaper.time_precise()
  clearit=true
  config_var_update_counter=config_var_update_counter+1
  
  if config_var_update_counter>1 then
    config_var_update_counter=0
    for a=2, configvars_num-1 do
      line=configvars_names[a]
      AAA=configvars_float[line]
      AAA2=reaper.SNM_GetDoubleConfigVar(line, -8)
      AAA3=line
      if reaper.SNM_GetIntConfigVar(line, -8)~=configvars_int[line] then
        configvars_int[line]=reaper.SNM_GetIntConfigVar(line, -8)
        changed=true
      end 
      
      if tostring(reaper.SNM_GetDoubleConfigVar(line, -8))~="-1.#QNAN" and reaper.SNM_GetDoubleConfigVar(line, -8)~=configvars_float[line] then
        configvars_float[line]=reaper.SNM_GetDoubleConfigVar(line, -8)
        changed=true
      end 
  
      if reaper.get_config_var_string~=nil then
        _t,val=reaper.get_config_var_string(line)
        if val~=configvars_string[line] then
        configvars_string[line]=val
        changed=true
        end
      end 
      
      if changed==true then 
        if clearit==true then clearit=false
          Relative_font=(font_size/Width)*gfx.w
          gfx.setfont(3,"Arial",12)
          gfx.set(15/255)
          gfx.x=Content_Offset_X-Tabs_Settings["TrackStateChunk"][3]
          gfx.y=Content_Offset_Y
          gfx.rect(gfx.x-100, gfx.y, 2048, gfx.h,1)
          gfx.set(1)
        end
  --      reaper.ShowConsoleMsg(line.." "..AAA2.." "..AAA.."\n")
        gfx.x=Content_Offset_X
        gfx.setfont(3,"Arial",13,85)
        gfx.drawstr(line.."\n")
        gfx.setfont(3,"Arial",12,0)
        gfx.x=Content_Offset_X
  
        bits,bits2=ultraschall.ConvertIntegerToBits(configvars_int[line])
        bits=""
        bits_temp=0
        for i=1, 32 do
          bits=bits..bits2[i]
          bits_temp=bits_temp+1
          if bits_temp==4 then bits=bits.." " end
          if bits_temp==8 then bits=bits.." - " bits_temp=0 end
        end
        
        gfx.drawstr("\n     int: "..configvars_int[line].."\n     double: "..configvars_float[line].."\n     string: "..configvars_string[line].."\n\n     Bitfield: "..bits:sub(1,-3).."\n\n ")
      end
      changed=false
    end
  end
--[[
  for a=1, configvars_num do
      o=o+1
        line=vars2[a]
        if reaper.get_config_var_string==nil then 
        temp="String variable not available in this Reaper-version, sorry." 
        else _t,temp=reaper.get_config_var_string(line) end
        -- go through all variables and see, if their values have changed since last defer-run
        -- if they've changed, display them and update the value stored in the table vars
        if reaper.SNM_GetIntConfigVar(line,-8)==vars[line] and 
  --      reaper.SNM_GetDoubleConfigVar(line,-8)==vars_double[line] and
        temp==vars_string[line] then        
        elseif line~=nil then        
          Relative_font=(font_size/Width)*gfx.w
          gfx.setfont(3,"Arial",12)
          gfx.set(15/255)
          gfx.x=Content_Offset_X-Tabs_Settings["EnvelopeStateChunk"][3]
          gfx.y=Content_Offset_Y
          gfx.rect(gfx.x-100, gfx.y, 2048, gfx.h,1)
          gfx.set(1)
          
        KOL22=reaper.time_precise()
          vars[line]=reaper.SNM_GetIntConfigVar(line,-8) -- update value
          vars_double[line]=reaper.SNM_GetDoubleConfigVar(line,-8)
          if reaper.get_config_var_string==nil then vars_string[line]="String variable not available in this Reaper-version, sorry." else _t,vars_string[line]=reaper.get_config_var_string(line) end
          if line~=nil and line~="" then gfx.drawstr("\n"..line..": \n       int: "..vars[line].."\n       double: "..vars_double[line].."\n       string: "..vars_string[line].."\n") end -- show varname and value        
          a1=vars[line]&1 if a1~=0 then a1=1 end
          a2=vars[line]&2 if a2~=0 then a2=1 end
          a3=vars[line]&4 if a3~=0 then a3=1 end
          a4=vars[line]&8 if a4~=0 then a4=1 end
          a5=vars[line]&16 if a5~=0 then a5=1 end
          a6=vars[line]&32 if a6~=0 then a6=1 end
          a7=vars[line]&64 if a7~=0 then a7=1 end
          a8=vars[line]&128 if a8~=0 then a8=1 end
    
          a9=vars[line]&256 if a9~=0 then a9=1 end
          a10=vars[line]&512 if a10~=0 then a10=1 end
          a11=vars[line]&1024 if a11~=0 then a11=1 end
          a12=vars[line]&2048 if a12~=0 then a12=1 end
          a13=vars[line]&4096 if a13~=0 then a13=1 end
          a14=vars[line]&8192 if a14~=0 then a14=1 end
          a15=vars[line]&16384 if a15~=0 then a15=1 end
          a16=vars[line]&32768 if a16~=0 then a16=1 end
          
          a17=vars[line]&65536 if a17~=0 then a17=1 end
          a18=vars[line]&131072 if a18~=0 then a18=1 end
          a19=vars[line]&262144 if a19~=0 then a19=1 end
          a20=vars[line]&524288 if a20~=0 then a20=1 end
          a21=vars[line]&1048576 if a21~=0 then a21=1 end
          a22=vars[line]&2097152 if a22~=0 then a22=1 end
          a23=vars[line]&4194304 if a23~=0 then a23=1 end
          a24=vars[line]&8388608 if a24~=0 then a24=1 end
    
          a25=vars[line]&16777216 if a25~=0 then a25=1 end
          a26=vars[line]&33554432 if a26~=0 then a26=1 end
          a27=vars[line]&67108864 if a27~=0 then a27=1 end
          a28=vars[line]&134217728 if a28~=0 then a28=1 end
          a29=vars[line]&268435456 if a29~=0 then a29=1 end
          a30=vars[line]&536870912 if a30~=0 then a30=1 end
          a31=vars[line]&1073741824 if a31~=0 then a31=1 end
          a32=vars[line]&2147483648 if a32~=0 then a32=1 end
          
          if count==3 then 
            reaper.ShowConsoleMsg("       Bitfield, with &1 at start: "..a1.." "..a2.." "..a3.." "..a4..":"..a5.." "..a6.." "..a7.." "..a8.." - "..a9.." "..a10.." "..a11.." "..a12..":"..a13.." "..a14.." "..a15.." "..a16.." - "..a17.." "..a18.." "..a19.." "..a20..":"..a21.." "..a22.." "..a23.." "..a24.." - "..a25.." "..a26.." "..a27.." "..a28..":"..a29.." "..a30.." "..a31.." "..a32.."\n") 
            Lr,LLr=reaper.BR_Win32_GetPrivateProfileString("REAPER", line,"nothingfound",reaper.get_ini_file())
            if LLR~="nothingfound" then reaper.ShowConsoleMsg("       Entry in the reaper.ini: [REAPER] -> "..line.."   - Currently-set-ini-value: "..LLr.."\n") end
          end--]]
--        end
        --]]
--      end
 
end

function Tabs_Funcs.ConfigDiffs()
end

function CheckTheClick(x,y,x1,y1,font_size)
  L=true
  for i=1, Tabs_Count do
    if x>=Tabs_Click[i][1] and 
       x<=Tabs_Click[i][3] and
       y>=Tabs_Click[i][2] and 
       y<=Tabs_Click[i][4] then
       POLO=i
       break
    else
      POLO=-1
    end
  end
  if POLO~=-1 then old_tab=Current_Tab Current_Tab=POLO return true end

  for i=1, Menu_count do
    if x>=Menus_Click[i][1] and 
       x<=Menus_Click[i][3] and
       y>=Menus_Click[i][2] and 
       y<=Menus_Click[i][4] then
       POLO=i
       break
    else
      POLO=-1
    end
  end
  if POLO~=-1 then OpenMenu(POLO) end
end

function main()
  gfx.dest=3
  if oldgfxw~=gfx.w or oldgfxh~=gfx.h then DrawUI(x,y,font_size)  end
  oldgfxw=gfx.w
  oldgfxh=gfx.h
  A=gfx.getchar()
  if A==65 then x=x+1 DrawUI(x,y,font_size) end
  if A==66 then x=x-1 DrawUI(x,y,font_size) end
  if A==67 then y=y+1 DrawUI(x,y,font_size) end
  if A==68 then y=y-1 DrawUI(x,y,font_size) end
  if A==69 then font_size=font_size+1 DrawUI(x,y,font_size) end
  if A==70 then font_size=font_size-1 DrawUI(x,y,font_size) end
  if gfx.mouse_cap==1 then update=CheckTheClick(gfx.mouse_x, gfx.mouse_y,x,y,font_size) else L=false end
  if gfx.mouse_hwheel~=oldmousewheel_h then Tabs_Settings[Tabs[Current_Tab]][3]=math.floor(Tabs_Settings[Tabs[Current_Tab]][3]+(gfx.mouse_hwheel*-0.0446)) gfx.mouse_hwheel=0 oldmousewheel_h=gfx.mouse_hwheel update=true end
  if gfx.mouse_cap&4==4 and gfx.mouse_wheel~=oldmousewheel_h then Tabs_Settings[Tabs[Current_Tab]][3]=math.floor(Tabs_Settings[Tabs[Current_Tab]][3]+(gfx.mouse_wheel*-0.0446)) gfx.mouse_wheel=0 oldmousewheel_h=gfx.mouse_wheel update=true end
  if gfx.mouse_cap&4==0 and gfx.mouse_wheel~=oldmousewheel then Tabs_Settings[Tabs[Current_Tab]][2]=math.floor(Tabs_Settings[Tabs[Current_Tab]][2]+(gfx.mouse_wheel*-0.0028)) gfx.mouse_wheel=0 oldmousewheel=gfx.mouse_wheel update=true end
  if update==true then
    gfx.dest=4
    Tabs_Funcs[Tabs[Current_Tab]](true)
    -- LOLO=reaper.time_precise()     --debug
    old_tab=Current_Tab
    update=false
  end
  B=font_size
  LL=LL+1
  if LL==30 then
    gfx.dest=4
    LL=0
    Tabs_Funcs[Tabs[Current_Tab]]()
  end
  gfx.dest=-1
  gfx.x=0
  gfx.y=0
  gfx.blit(3,1,0)
  gfx.x=Tabs_Settings[Tabs[Current_Tab]][3]
  gfx.y=Content_Offset_Y
  gfx.blit(4,1,0)
  gfx.update()
  if A~=27.00 and A~=-1 then reaper.defer(main) else gfx.quit() end
end

LL=0
oldgfxw=gfx.w+100
oldgfxh=gfx.h+100
oldmousewheel=gfx.mouse_wheel
oldmousewheel_h=gfx.mouse_hwheel
time=reaper.time_precise()+3




main()


