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


FileA={}
FileA[#FileA+1]="Ultraschall_Doc_VID_Converter_v2.lua"
FileA[#FileA+1]="Ultraschall_ConceptsDocConverter_VID_v2.lua"
FileA[#FileA+1]="Ultraschall_Doc_DOC_Converter_v2.lua"
FileA[#FileA+1]="Ultraschall_Doc_GFX_Converter_v2.lua"
FileA[#FileA+1]="Ultraschall_ConceptsDocConverter_GFX_v2.lua"
FileA[#FileA+1]="Ultraschall_ConceptsDocConverter_DOC_v2.lua"
FileA[#FileA+1]="Ultraschall_ApiDownloads_Generator.lua"
FileA[#FileA+1]="Ultraschall_Doc_Func_Converter_v2.lua"
FileA[#FileA+1]="Ultraschall_ConceptsDocConverter_v2.lua"
FileA[#FileA+1]="Reaper_ReaScriptConverter_v2.lua"
FileA[#FileA+1]="Reaper_VideoProcessorDocConverter_v2.lua"
FileA[#FileA+1]="Reaper_ConfigVarDocConverter_v2.lua"

Starterkit=reaper.time_precise()

for i=1, #FileA do
  CurrentDocs=FileA[i].."\n"
  dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api/Scripts/Tools/Docgenerator/"..FileA[i])
end


print2(reaper.format_timestr(reaper.time_precise()-Starterkit, ""))