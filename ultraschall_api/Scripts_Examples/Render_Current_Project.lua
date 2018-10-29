-- Ultraschall-API demoscript by Meo Mespotine 29.10.2018
-- 
-- render the current project as a whole to numerous audio-file-formats(in this example: flac, opus, mp3, wav)
-- see Functions-Reference for more details on the parameter-settings, given to the functions,
-- as well as other formats
--
-- checks, if the project needs to be saved first(is dirty). After that, it will show an input-box, where you enter
-- the render-filename with path. file-extensions will be given by Reaper's rendering-process automatically

dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

-- Check if file needs to be saved, otherwise give script Output-filename with path
if reaper.IsProjectDirty(0)==0 then
  retval2, renderfilename_with_path=reaper.GetUserInputs("Please give filename+path of the target-render-file.", 1, "", "")
  else
  reaper.MB("Project must be save first. Quitting now.", "Project not saved", 0)
  return
end

if retval2==true then
  -- Create Renderstrings first, for Flac, Opus, MP3(Maxquality) and Wav
  render_cfg_string_Flac = ultraschall.CreateRenderCFG_FLAC(0, 5)
  render_cfg_string_Opus = ultraschall.CreateRenderCFG_Opus2(2, 128, 10, false, false)
  render_cfg_string_MP3_maxquality = ultraschall.CreateRenderCFG_MP3MaxQuality()
  render_cfg_string_Wav = ultraschall.CreateRenderCFG_WAV(1, 0, 0, 0, false)
  
  -- Render the files. Will automatically increment filenames(if already existing) and close the rendering-window after render.
  ultraschall.RenderProject_RenderCFG(projectfilename_with_path, renderfilename_with_path, 0, 0, false, true, true, render_cfg_string_Flac)
  ultraschall.RenderProject_RenderCFG(projectfilename_with_path, renderfilename_with_path, 0, 0, false, true, true, render_cfg_string_Opus)
  ultraschall.RenderProject_RenderCFG(projectfilename_with_path, renderfilename_with_path, 0, 0, false, true, true, render_cfg_string_MP3_maxquality)
  ultraschall.RenderProject_RenderCFG(projectfilename_with_path, renderfilename_with_path, 0, 0, false, true, true, render_cfg_string_Wav)
else
  reaper.MB("No outputfile Chosen. Quitting now.", "No outputfile Selected", 0)
end

ultraschall.ShowLastErrorMessage()
