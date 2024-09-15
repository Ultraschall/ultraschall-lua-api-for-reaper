# Ultraschall Lua API for REAPER

## Concept

The Ultraschall-Extension is intended to be an extension for the DAW Reaper, that enhances it with podcast functionalities.

More infos on [Ultraschall API website](https://mespotin.uber.space/Ultraschall/US_Api_Introduction_and_Concepts.html#Introduction_001_Api).

Discussion on the dedicated [Cockos Forum thread](https://forum.cockos.com/showthread.php?t=214539).

## Install

### Reapack

Use the following link to install via [Reapack](https://www.reapack.com) extension.

`https://github.com/Ultraschall/ultraschall-lua-api-for-reaper/raw/master/ultraschall_api_index.xml`

### Manual Install

You can download ultraschall releases manually on the [release](https://github.com/Ultraschall/ultraschall-lua-api-for-reaper/releases) page.

## Github
Don't work with the branches on GitHub, not even for single files, as they cause confusion when you report bugs and issues.
Always work from a regularly installed installation.

## Usage

In your ReaScript, add the following lines. You can tweek them if needed:

```lua
ultraschall_path = reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua"
if reaper.file_exists( ultraschall_path ) then
  dofile( ultraschall_path )
end

if not ultraschall or not ultraschall.GetApiVersion then -- If ultraschall loading failed of if it doesn't have the functions you want to use
  reaper.MB("Please install Ultraschall API, available via Reapack. Check online doc of the script for more infos.\nhttps://github.com/Ultraschall/ultraschall-lua-api-for-reaper", "Error", 0)
  return
end
```

## Found Issues?
Please open up a dedicated issue where you explain, what is wrong including detailed steps on how to recreate the problem. 

Don't provide a PullRequest, as this is difficult for me to merge with my approach in rapid development.

## Donation

If you want to donate to our project, head over to [ultraschall.fm/danke](ultraschall.fm/danke).
