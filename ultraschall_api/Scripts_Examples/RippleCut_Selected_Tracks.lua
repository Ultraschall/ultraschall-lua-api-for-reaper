-- Ultraschall-API demoscript by Meo Mespotine 29.10.2018
-- 
-- Apply Ripple-Cut only on selected tracks and time-selection

dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

selection_start, selection_end = reaper.GetSet_LoopTimeRange(false, false, 0, 0, 0)
trackstring = ultraschall.CreateTrackString_SelectedTracks()
number_items, MediaItemArray_StateChunk = ultraschall.RippleCut(selection_start, selection_end, trackstring, false, true)
selection_start, selection_end = reaper.GetSet_LoopTimeRange(true, false, reaper.GetCursorPosition(), reaper.GetCursorPosition(), 0)
