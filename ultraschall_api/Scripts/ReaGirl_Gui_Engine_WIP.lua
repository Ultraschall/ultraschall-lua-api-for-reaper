dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
--[[
TODO: 
  - jumping to ui-elements outside window(means autoscroll to them) doesn't always work
    - ui-elements might still be out of view when jumping to them(x-coordinate outside of window for instance)
  - Slider: unit must be limited to 3 digits, rounded properly
  - Slider: doubleclick on the edges doesn't revert to default-value
  - Slider: disappears when scrolling upwards/leftwards: because of the "only draw neccessary gui-elements"-code, which is buggy for some reason
  - Slider: draw a line where the default-value shall be
  - reagirl.UI_Element_NextX_Default=10 - changing it only offsets the second line ff, not the first line
--]]
--XX,YY=reaper.GetMousePosition()
--gfx.ext_retina = 0
reagirl={}
reagirl.Elements={}
reagirl.MoveItAllUp=0
reagirl.MoveItAllRight=0
reagirl.MoveItAllRight_Delta=0
reagirl.MoveItAllUp_Delta=0
-- margin between ui-elements
reagirl.UI_Element_NextX_Margin=10
reagirl.UI_Element_NextY_Margin=1

-- offset for first ui-element
reagirl.UI_Element_NextX_Default=10
reagirl.UI_Element_NextY_Default=10

reagirl.UI_Element_NextLineY=0 -- don't change
reagirl.UI_Element_NextLineX=10 -- don't change
reagirl.Font_Size=16

reagirl.OSARA=reaper.osara_outputMessage
function reaper.osara_outputMessage(message, a)
  --if message~="" then print_update(message,a) end
  reagirl.OSARA(message)
end
--]]

function reagirl.FormatNumber(n, p)
  -- by cfillion
  local p = (math.log(math.abs(n), 10) // 1) + (p or 3) + 1
  return ('%%.%dg'):format(p):format(n)
end

function reagirl.NextLine_SetDefaults(x, y)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>NextLine_SetDefaults</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.NextLine_SetDefaults(optional integer x, optional integer y)</functioncall>
  <description>
    Set the defaults for new lines in the gui-elements, when using autopositioning.
    
    Y sets the y-offset of the first ui-element in the gui, x the x-offset for each line
  </description>
  <parameters>
    optional integer x - the default-offset for the x-position of the first ui-element in a new line
    optional integer y - the default-offset for the y-position of the first ui-element in a gui
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <tags>ui-elements, set, next line, defaults</tags>
</US_DocBloc>
--]]
  if x~=nil and math.type(x)~="integer" then error("NextLine_SetDefaults: param #1 - must be either nil or an integer", -1) return end
  if y~=nil and math.type(y)~="integer" then error("NextLine_SetDefaults: param #2 - must be either nil or an integer", -1) return end
  if x<0 then error("NextLine_SetDefaults: param #1 - must be bigger or equal 0", -1) return end
  if y<0 then error("NextLine_SetDefaults: param #2 - must be bigger or equal 0", -1) return end
  if x~=nil then
    reagirl.UI_Element_NextX_Default=x
  end
  
  if y~=nil then
    reagirl.UI_Element_NextY_Default=y  
  end
end

function reagirl.NextLine_GetDefaults()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>NextLine_GetDefaults</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>integer x, integer y = reagirl.NextLine_GetDefaults()</functioncall>
  <description>
    Get the defaults for new lines in the gui-elements, when using autopositioning.
    
    Y is the y-offset of the first ui-element in the gui, x the x-offset for each line
  </description>
  <retvals>
    integer x - the default-offset for the x-position of the first ui-element in a new line
    integer y - the default-offset for the y-position of the first ui-element in a gui
  </retvals>
  <chapter_context>
    UI Elements
  </chapter_context>
  <tags>ui-elements, get, next line, defaults</tags>
</US_DocBloc>
--]]
  return reagirl.UI_Element_NextX_Default, reagirl.UI_Element_NextY_Default
end

function reagirl.Gui_ReserveImageBuffer()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ReserveImageBuffer</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>integer image_buffer_index = reagirl.Gui_ReserveImageBuffer()</functioncall>
  <description>
    Reserves a framebuffer which will not be used by ReaGirl for drawing.
    So if you want to code additional ui-elements, you can reserve an image buffer for blitting that way.
  </description>
  <retvals>
    integer image_buffer_index - the index of a framebuffer you can safely use
  </retvals>
  <chapter_context>
    Gui
  </chapter_context>
  <tags>gui, get, next line, defaults</tags>
</US_DocBloc>
--]]
  -- reserves an image buffer for custom UI elements
  -- returns -1 if no buffer can be reserved anymore
  if reagirl.MaxImage==nil then reagirl.MaxImage=1 end
  if reagirl.MaxImage>=1000 then return -1 end
  reagirl.MaxImage=reagirl.MaxImage+1
  return reagirl.MaxImage
end

function reagirl.Gui_PreventScrollingForOneCycle(keyboard, mousewheel_swipe)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_PreventScrollingForOneCycle</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>integer x, integer y = reagirl.Gui_PreventScrollingForOneCycle(optional boolean keyboard, optional boolean mousewheel_swipe)</functioncall>
  <description>
    Prevents the scrolling of the gui via keyboard/mousewheel/swiping for this defer-cycle.
  </description>
  <parameters>
    optional boolean keyboard - true, prevent the scrolling via keyboard; false, scroll; nil, don't change
    optional boolean mousewheel_swipe - true, prevent the scrolling via mousewheel/swiping; false, scroll; nil, don't change
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <tags>gui, set, override, prevent, scrolling</tags>
</US_DocBloc>
--]]
  if keyboard~=nil and type(keyboard)~="boolean" then error("Gui_PreventScrollingForOneCycle: param #1 - must be either nil or a a boolean") end
  if mousewheel_swipe~=nil and type(mousewheel_swipe)~="boolean" then error("Gui_PreventScrollingForOneCycle: param #2 - must be either nil or a a boolean") end
  if mousewheel_swipe~=nil and reagirl.Scroll_Override_MouseWheel~=true then
    reagirl.Scroll_Override_MouseWheel=mousewheel_swipe
  end
  if keyboard~=nil and reagirl.Scroll_Override~=true then 
    reagirl.Scroll_Override=keyboard
  end
end

function reagirl.Gui_PreventCloseViaEscForOneCycle()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_PreventCloseViaEscForOneCycle</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Gui_PreventScrollingForOneCycle()</functioncall>
  <description>
    Prevents the closing of the gui via esc-key for one cycle.
  </description>
  <chapter_context>
    UI Elements
  </chapter_context>
  <tags>gui, set, override, prevent, close via esc, escape</tags>
</US_DocBloc>
--]]
  reagirl.Gui_PreventCloseViaEscForOneCycle_State=true
end

function reagirl.IsValidGuid(guid, strict)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsValidGuid</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>boolean retval = reagirl.IsValidGuid(string guid, boolean strict)</functioncall>
  <description>
    Checks, if guid is a valid guid. Can also be used for strings, that contain a guid somewhere in them(strict=false)
    
    A valid guid is a string that follows the following pattern:
    {........-....-....-....-............}
    where . is a hexadecimal value(0-F)
  </description>
  <parameters>
    string guid - the guid to check for validity
    boolean strict - true, guid must only be the valid guid; false, guid must contain a valid guid somewhere in it(means, can contain trailing or preceding characters)
  </parameters>
  <retvals>
    boolean retval - true, guid is/contains a valid guid; false, guid isn't/does not contain a valid guid
  </retvals>
  <chapter_context>
    Misc
  </chapter_context>
  <tags>helper functions, guid, check</tags>
</US_DocBloc>
--]]
  if type(guid)~="string" then error("IsValidGuid: param #1 - must be a string", -1) return false end
  if type(strict)~="boolean" then error("IsValidGuid: param #2 - must be a boolean", -2) return false end
  if strict==true and guid:match("^{%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x%}$")~=nil then return true
  elseif strict==false and guid:match(".-{%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x%}.*")~=nil then return true
  else return false
  end
end

function reagirl.RoundRect(x, y, w, h, r, antialias, fill, square_top_left, square_bottom_left, square_top_right, square_bottom_right)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>RoundRect</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.RoundRect(integer x, integer y, integer w, integer h, number r, number antialias, number fill, optional boolean square_top_left, optional boolean square_bottom_left, optional boolean square_top_right, optional boolean square_bottom_right)</functioncall>
  <description>
    This draws a rectangle with rounded corners to x and y
  </description>
  <parameters>
    integer x - the x-position of the rectangle
    integer y - the y-position of the rectangle
    integer w - the width of the rectangle
    integer h - the height of the rectangle
    number r - the radius of the corners of the rectangle
    number antialias - 1, antialias; 0, no antialias
    number fill - 1, filled; 0, not filled
    optional boolean square_top_left - true, make top-left corner square; false or nil, make it round
    optional boolean square_bottom_left - true, make bottom-left corner square; false or nil, make it round
    optional boolean square_top_right - true, make top-right corner square; false or nil, make it round
    optional boolean square_bottom_right - true, make bottom-right corner square; false or nil, make it round
  </parameters>
  <chapter_context>
    Misc
  </chapter_context>
  <target_document>US_Api_GFX</target_document>
  <source_document>ultraschall_gfx_engine.lua</source_document>
  <tags>gfx, functions, round rect, draw</tags>
</US_DocBloc>
]]
  if math.type(x)~="integer" then error("RoundRect: param #1 - must be an integer", 2) end
  if math.type(y)~="integer" then error("RoundRect: param #2 - must be an integer", 2) end
  if math.type(w)~="integer" then error("RoundRect: param #3 - must be an integer", 2) end
  if math.type(h)~="integer" then error("RoundRect: param #4 - must be an integer", 2) end
  if type(r)~="number" then error("RoundRect: param #5 - must be an integer", 2) end
  --if r>12 then r=12 end
  if type(antialias)~="number" then error("RoundRect: param #6 - must be an integer", 2) end
  if type(fill)~="number" then error("RoundRect: param #7 - must be an integer", 2) end
  if square_top_left~=nil     and type(square_top_left)~="boolean"     then error("RoundRect: param #8 - must be a boolean or nil", 2)  end
  if square_bottom_left~=nil  and type(square_bottom_left)~="boolean"  then error("RoundRect: param #9 - must be a boolean or nil", 2)  end
  if square_top_right~=nil    and type(square_top_right)~="boolean"    then error("RoundRect: param #10 - must be a boolean or nil", 2) end
  if square_bottom_right~=nil and type(square_bottom_right)~="boolean" then error("RoundRect: param #11 - must be a boolean or nil", 2) end
    
  local aa = antialias or 1
  fill = fill or 0

  if fill == 0 or false then
    -- unfilled
    if h >=2*r then 
      if square_top_left~=true then
        gfx.arc(x+r, y+r, r, -1.6, 0, aa) -- top left
      else
        gfx.line(x, y, x+r,   y, aa)
        gfx.line(x, y,   x, y+r, aa)
      end
      if square_top_right~=true then
        gfx.arc(x+w-r, y+r, r, 0, 1.6, aa) -- top right
      else
        gfx.line(x+w, y, x+w-r,   y, aa)
        gfx.line(x+w, y,   x+w, y+r, aa)
      end
      if square_bottom_left~=true then
        gfx.arc(x+r, y+h-r, r, -3.2, -1.6, aa) -- bottom left
      else
        gfx.line(x, y+h, x+r,   y+h, aa)
        gfx.line(x, y+h,   x, y+h-r, aa)
      end
      if square_bottom_right~=true then
        gfx.arc(x+w-r, y+h-r, r,  1.6,  3.2, aa) -- bottom right
      else
        gfx.line(x+w, y+h-r,   x+w, y+h, aa)
        gfx.line(x+w,   y+h, x+w-r, y+h, aa)
      end
      
      gfx.line(x+r,     y, x+w-r,     y, aa) -- top line
      gfx.line(x+r,   y+h, x+w-r,   y+h, aa) -- bottom line
      gfx.line(x,     y+r,     x, y+h-r, aa) -- left edge
      gfx.line(x+w,   y+r,   x+w, y+h-r, aa) -- right edge
    end
  else
    -- filled
    
    -- Corners
    if h >=2*r then 
      local filled=1
      if 1+y+h-r*2<y then offset=y-(1+y+h-r*2) else offset=0 end
      
      -- top-left
      if square_top_left~=true then
        gfx.circle(x + r, y + r, r, 1, aa)
      else
        gfx.rect(x, y, r, r, filled)
      end
      
      -- bottom-left
      if square_bottom_left~=true then
        gfx.circle(x + r, offset+y + h - r, r, filled, aa)
      else
        gfx.rect(x, offset+y+h-r, r, r+1, filled)
      end
      
      -- top-right
      if square_top_right~=true then
        gfx.circle(x + w - r, y + r, r, filled, aa)
      else
        gfx.rect(x+w-r, y, r+1, r+1, filled)
      end
      
      -- bottom-right
      if square_bottom_right~=true then
        gfx.circle(x + w - r, y + h - r, r , filled, aa)
      else
        gfx.rect(x+w-r, y+h-r, r+1, r+1, filled)
      end
      
      -- Ends
      gfx.rect(x, y + r, r, h - r * 2, filled)
      gfx.rect(x + w - r, y + r, r + 1, h - r * 2, filled)
  
      -- Body + sides
      gfx.rect(x + r, y, w - r * 2, h + 1, filled)
    else
      local filled=1
      r = math.ceil(h / 2)-1
      local offset
      if 1+y+h-r*2<y then offset=y-(1+y+h-r*2) else offset=0 end
      -- Ends
      --gfx.set(1,0,0)
      gfx.circle(x + r,     y + r, r, filled, aa)
      --gfx.set(1)
      gfx.circle(x + w - r-1, y + r, r, filled, aa)
      if square_top_left==true then    gfx.rect(x,       y,   w/2, h/2, filled) end
      if square_top_right==true then   gfx.rect(x+w-w/2, y, w/2+1, h/2, filled) end
      
      if square_bottom_right==true then gfx.rect(x+w-w/2, y+h-(h/2), w/2+1,   h/2, filled) end
      if square_bottom_left==true  then gfx.rect(x,       y+h-(h/2), w/2, h/2, filled) end
      -- Body
      gfx.rect(x + r, y, w - ((h/2) * 2), h, filled)
    end
  end
end



function reagirl.BlitText_AdaptLineLength(text, x, y, width, height, align)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>BlitText_AdaptLineLength</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>boolean retval, integer width, integer height = reagirl.BlitText_AdaptLineLength(string text, integer x, integer y, integer width, optional integer height, optional integer align)</functioncall>
  <description>
    This draws text to x and y and adapts the line-lengths to fit into width and height.
  </description>
  <parameters>
    string text - the text to be shown
    integer x - the x-position of the text
    integer y - the y-position of the text
    integer width - the maximum width of a line in pixels; text after this will be put into the next line
    optional integer height - the maximum height the text shall be shown in pixels; everything after this will be truncated
    optional integer align - 0 or nil, left aligned text; 1, center text
  </parameters>
  <retvals>
    boolean retval - true, text-blitting was successful; false, text-blitting was unsuccessful
  </retvals>
  <chapter_context>
    Misc
  </chapter_context>
  <target_document>US_Api_GFX</target_document>
  <source_document>ultraschall_gfx_engine.lua</source_document>
  <tags>gfx, functions, blit, text, line breaks, adapt line length</tags>
</US_DocBloc>
]]
  if type(text)~="string" then error("GFX_BlitText_AdaptLineLength: #1 - must be a string", 2) end
  if math.type(x)~="integer" then error("GFX_BlitText_AdaptLineLength: #2 - must be an integer", 2) end
  if math.type(y)~="integer" then error("GFX_BlitText_AdaptLineLength: #3 - must be an integer", 2) end
  if type(width)~="number" then error("GFX_BlitText_AdaptLineLength: #4 - must be an integer", 2) end
  if height~=nil and type(height)~="number" then error("GFX_BlitText_AdaptLineLength: #5 - must be an integer", 2) end
  if align~=nil and math.type(align)~="integer" then error("GFX_BlitText_AdaptLineLength: 6 - must be an integer", 2) end
  local l=gfx.measurestr("A")
  if width<gfx.measurestr("A") then error("GFX_BlitText_AdaptLineLength: #4 - must be at least "..l.." pixels for this font.", -7) end

  if align==nil or align==0 then center=0 
  elseif align==1 then center=1 
  end
  local newtext=""

  for a=0, 100 do
    newtext=newtext..text:sub(a,a)
    local nwidth, nheight = gfx.measurestr(newtext)
    if nwidth>width then
      newtext=newtext:sub(1,a-1).."\n"..text:sub(a,a)
    end
    if height~=nil and nheight>=height then newtext=newtext:sub(1,-3) break end
  end
  local old_x, old_y=gfx.x, gfx.y
  gfx.x=x
  gfx.y=y
  local xwidth, xheight = gfx.measurestr(newtext)
  gfx.drawstr(newtext.."\n  ", center)--xwidth+3+x, xheight)
  gfx.x=old_x
  gfx.y=old_y
  local w,h=gfx.measurestr(newtext)
  return true, math.tointeger(w), math.tointeger(h)
end

function reagirl.ResizeImageKeepAspectRatio(image, neww, newh, bg_r, bg_g, bg_b)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ResizeImageKeepAspectRatio</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>boolean retval = reagirl.ResizeImageKeepAspectRatio(integer image, integer neww, integer newh, optional number r, optional number g, optional number b)</functioncall>
  <description>
    Resizes an image, keeping its aspect-ratio. You can set a background-color for non rectangular-images.
    
    Resizing upwards will probably cause artifacts!
    
    Note: this uses image 1023 as temporary buffer so don't use image 1023, when using this function!
  </description>
  <parameters>
    integer image - an image between 0 and 1022, that you want to resize
    integer neww - the new width of the image
    integer newh - the new height of the image
    optional number r - the red-value of the background-color; nil, = 0
    optional number g - the green-value of the background-color; nil, = 0
    optional number b - the blue-value of the background-color; nil, = 0
  </parameters>
  <retvals>
    boolean retval - true, blitting was successful; false, blitting was unsuccessful
  </retvals>
  <chapter_context>
    Misc
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, resize, image</tags>
</US_DocBloc>
]]
  if math.type(image)~="integer" then error("ResizeImageKeepAspectRatio: #1 - must be an integer", 2) end
  if math.type(neww)~="integer" then error("ResizeImageKeepAspectRatio: #2 - must be an integer", 2) end
  if math.type(newh)~="integer" then error("ResizeImageKeepAspectRatio: #3 - must be an integer", 2) end
  
  if bg_r~=nil and type(bg_r)~="number" then error("ResizeImageKeepAspectRatio: #4 - must be a number", 2) end
  if bg_r==nil then bg_r=0 end
  if bg_g~=nil and type(bg_g)~="number" then error("ResizeImageKeepAspectRatio: #5 - must be a number", 2) end
  if bg_g==nil then bg_g=0 end
  if bg_b~=nil and type(bg_b)~="number" then error("ResizeImageKeepAspectRatio: #6 - must be a number", 2) end
  if bg_b==nil then bg_b=0 end
  
  if image<0 or image>1022 then error("ResizeImageKeepAspectRatio: #1 - must be between 0 and 1022", 2) end
  if neww<0 or neww>8192 then error("ResizeImageKeepAspectRatio: #2 - must be between 0 and 8192", 2) end
  if newh<0 or newh>8192 then error("ResizeImageKeepAspectRatio: #3 - must be between 0 and 8192", 2) end
  
  local old_r, old_g, old_g=gfx.r, gfx.g, gfx.b  
  local old_dest=gfx.dest
  local oldx, oldy = gfx.x, gfx.y
  
  local x,y=gfx.getimgdim(image)
  local ratiox=((100/x)*neww)/100
  local ratioy=((100/y)*newh)/100
  local ratio
  if ratiox<ratioy then ratio=ratiox else ratio=ratioy end
  gfx.setimgdim(1023, neww, newh)
  gfx.dest=1023
  gfx.set(bg_r, bg_g, bg_b)
  gfx.rect(0,0,8192,8192,1)
  gfx.x=0
  gfx.y=0
  gfx.blit(image, ratio, 0)

  gfx.setimgdim(image, neww, newh)
  gfx.dest=image
  if bg_r~=nil then gfx.r=bg_r end
  if bg_g~=nil then gfx.g=bg_g end
  if bg_b~=nil then gfx.b=bg_b end
  x,y=gfx.getimgdim(image)
  gfx.rect(-1,-1,x+1,y+1,1)
  gfx.set(old_r, old_g, old_g)
  gfx.blit(1023, 1, 0)
  gfx.dest=old_dest
  gfx.x, gfx.y = oldx, oldy
  return true
end

--reagirl.ResizeImageKeepAspectRatio(1, 1, 1, 1, 1, 1)

function reagirl.Window_Open(...)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Window_Open</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    JS=0.964
    Lua=5.4
  </requires>
  <functioncall>integer retval, optional HWND hwnd = reagirl.Window_Open(string title, optional integer width, optional integer height, optional integer dockstate, optional integer xpos, optional integer ypos)</functioncall>
  <description>
    Opens a new graphics window and returns its HWND-windowhandler object.
  </description>
  <parameters>
    string title - the name of the window, which will be shown in the title of the window
    optional integer width -  the width of the window; minmum is 50
    optional integer height -  the height of the window; minimum is 16
    optional integer dockstate - &1=0, undocked; &1=1, docked
    optional integer xpos - x-position of the window in pixels; minimum is -80; nil, to center it horizontally
    optional integer ypos - y-position of the window in pixels; minimum is -15; nil, to center it vertically
  </parameters>
  <retvals>
    number retval - 1.0, if window is opened
    optional HWND hwnd - when JS-extension is installed, the window-handler of the newly created window; can be used with JS_Window_xxx-functions of the JS-extension-plugin
  </retvals>
  <chapter_context>
    Window
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, gfx, init, window, create, hwnd</tags>
</US_DocBloc>
]]
  local parms={...}
  if type(parms[1])~="string" then error("Window_Open: #1 - must be a string", 2) end
  if parms[2]~=nil and type(parms[2])~="number" then error("Window_Open: #2 - must be an integer", 2) end
  if parms[3]~=nil and type(parms[3])~="number" then error("Window_Open: #3 - must be an integer", 2) end
  if parms[4]~=nil and type(parms[4])~="number" then error("Window_Open: #4 - must be an integer", 2) end
  if parms[5]~=nil and type(parms[5])~="number" then error("Window_Open: #5 - must be an integer", 2) end
  if parms[6]~=nil and type(parms[6])~="number" then error("Window_Open: #6 - must be an integer", 2) end
  
  local AAA, AAA2=reaper.ThemeLayout_GetLayout("tcp", -3)
  local minimum_scale_for_dpi, maximum_scale_for_dpi = 1,1--ultraschall.GetScaleRangeFromDpi(tonumber(AAA2))
  maximum_scale_for_dpi = math.floor(maximum_scale_for_dpi)
  local A=gfx.getchar(65536)
  local HWND, retval
  if A&4==0 then
    reagirl.Window_RescaleIfNeeded()
    --reagirl.MoveItAllRight=0
    --reagirl.MoveItAllUp=0
    local parms={...}
    local temp=parms[1]
    if parms[2]==nil then parms[2]=640 end
    if parms[3]==nil then parms[3]=400 end
    if parms[4]==nil then parms[4]=0 end
    -- check, if the given windowtitle is a valid one, 
    -- if that's not the case, use "" as name
    if temp==nil or type(temp)~="string" then temp="" end  
    if type(parms[1])~="string" then parms[1]="" 
    end
    
    parms[2]=parms[2]*reagirl.Window_CurrentScale
    parms[3]=parms[3]*reagirl.Window_CurrentScale
    
    local A1,B,C,D=reaper.my_getViewport(0,0,0,0, 0,0,0,0, false)
    parms[2]=parms[2]*minimum_scale_for_dpi
    parms[3]=parms[3]*minimum_scale_for_dpi
    if parms[5]==nil then
      parms[5]=(C-parms[2])/2
    end
    if parms[6]==nil then
      parms[6]=(D-parms[3])/2
    end
    
    
    if reaper.JS_Window_SetTitle~=nil then 
      local B=gfx.init(table.unpack(parms)) 
      --reagirl.Window_CurrentScale=1
      --reagirl.Window_RescaleIfNeeded()
      return B 
    end
    
    -- check for a window-name not being used yet, which is 
    -- windowtitleX, where X is a number
    local freeslot=0
    for i=0, 65555 do
      if reaper.JS_Window_Find(parms[1]..i, true)==nil then freeslot=i break end
    end
    -- use that found, unused windowtitle as temporary windowtitle
    parms[1]=parms[1]..freeslot
    

    -- open window  
    retval=gfx.init(table.unpack(parms))
    
    -- find the window with the temporary windowtitle and get its HWND
    HWND=reaper.JS_Window_Find(parms[1], true)
    
    -- rename it to the original title
    if HWND~=nil then reaper.JS_Window_SetTitle(HWND, temp) end
    reagirl.GFX_WindowHWND=HWND
  else 
    retval=0.0
  end
  return retval, reagirl.GFX_WindowHWND
end

function reagirl.Window_RescaleIfNeeded()
  local scale
  
  if reagirl.Window_CurrentScale_Override==nil then
    if tonumber(reaper.GetExtState("reagirl_preferences", "scaling_override"))~=nil then
      scale=tonumber(reaper.GetExtState("reagirl_preferences", "scaling_override"))
    else
      local retval, dpi = reaper.ThemeLayout_GetLayout("tcp", -3)
      local dpi=tonumber(dpi)
      
      if dpi<384 then scale=1
      elseif dpi>=384 and dpi<512 then scale=1--.5
      elseif dpi>=512 and dpi<640 then scale=2
      elseif dpi>=640 and dpi<768 then scale=2--.5
      elseif dpi>=768 and dpi<896 then scale=3
      elseif dpi>=896 and dpi<1024 then scale=3--.5
      elseif dpi>=1024 and dpi<1152 then scale=4 
      elseif dpi>=1152 and dpi<1280 then scale=4--.5
      elseif dpi>=1280 and dpi<1408 then scale=5
      elseif dpi>=1408 and dpi<1536 then scale=5--.5
      elseif dpi>=1536 and dpi<1664 then scale=6
      elseif dpi>=1664 and dpi<1792 then scale=6--.5
      elseif dpi>=1792 and dpi<1920 then scale=7
      elseif dpi>=1920 and dpi<2048 then scale=7--.5
      else scale=8
      end
    end
  else
    scale=reagirl.Window_OldScale
    reagirl.Window_OldScale=scale
  end
  if reagirl.Window_CurrentScale==nil then reagirl.Window_CurrentScale=scale end
  
  --XXX=reagirl.Window_CurrentScale
  
  if reagirl.Window_CurrentScale~=scale then
    --print2("")
    local unscaled_w = gfx.w/reagirl.Window_CurrentScale
    local unscaled_h = gfx.h/reagirl.Window_CurrentScale
    if gfx.getchar(65536)>1 then
      local A,B,C,D,E,F,G,H=gfx.dock(-1,0,0,0,0)
      --print2(A,B)
      if A<0 then A=0 end
      if B<0 then B=0 end
      --print2(A,B)
      gfx.init("", math.floor(unscaled_w*scale), math.floor(unscaled_h*scale), 0, A, B)
    end
    reagirl.Window_CurrentScale=scale
    reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
    reagirl.MoveItAllUp=0
    reagirl.MoveItAllRight=0
    for i=1, #reagirl.Elements do 
      if reagirl.Elements[i]["GUI_Element_Type"]=="Image" then
        reagirl.Image_ReloadImage_Scaled(i)
      end
    end
    reagirl.Gui_ForceRefresh()
  end
end

function reagirl.Mouse_GetCap(doubleclick_wait, drag_wait)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Mouse_GetCap</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string clickstate, string specific_clickstate, integer mouse_cap, integer click_x, integer click_y, integer drag_x, integer drag_y, integer mouse_wheel, integer mouse_hwheel = reagirl.Mouse_GetCap(optional integer doubleclick_wait, optional integer drag_wait)</functioncall>
  <description>
    Checks clickstate and mouseclick/wheel-behavior, since last time calling this function and returns their states.
    Allows you to get click, doubleclick, dragging, including the appropriate coordinates and mousewheel-states.

    Much more convenient, than fiddling around with gfx.mouse_cap
    
    Note: After doubleclicked, this will not return mouse-clicked-states, until the mouse-button is released. So any mouse-clicks during that can be only gotten from the retval mouse_cap.
          This is to prevent automatic mouse-dragging after double-clicks.
  </description>
  <parameters>
    optional integer doubleclick_wait - the timeframe, in which a second click is recognized as double-click, in defer-cycles. 30 is approximately 1 second; nil, will use 15(default)
    optional integer drag_wait - the timeframe, after which a mouseclick without moving the mouse is recognized as dragging, in defer-cycles. 30 is approximately 1 second; nil, will use 5(default)
  </parameters>
  <retvals>
      string clickstate - "", if not clicked, "CLK" for clicked and "FirstCLK", if the click is a first-click.
      string specific_clickstate - either "" for not clicked, "CLK" for clicked, "DBLCLK" for doubleclick or "DRAG" for dragging
      integer mouse_cap - the mouse_cap, a bitfield of mouse and keyboard modifier states
                        -   1: left mouse button
                        -   2: right mouse button
                        -   4: Control key
                        -   8: Shift key
                        -   16: Alt key
                        -   32: Windows key
                        -   64: middle mouse button
      integer click_x - the x position, when the mouse has been clicked the last time
      integer click_y - the y position, when the mouse has been clicked the last time
      integer drag_x  - the x-position of the mouse-dragging-coordinate; is like click_x for non-dragging mousestates
      integer drag_y  - the y-position of the mouse-dragging-coordinate; is like click_y for non-dragging mousestates
      integer mouse_wheel - the mouse_wheel-delta, since the last time calling this function
      integer mouse_hwheel - the mouse_horizontal-wheel-delta, since the last time calling this function
  </retvals>
  <chapter_context>
    Misc
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, mouse, mouse cap, leftclick, rightclick, doubleclick, drag, wheel, mousewheel, horizontal mousewheel</tags>
</US_DocBloc>
]]
  if doubleclick_wait~=nil and math.type(doubleclick_wait)~="integer" then error("Mouse_GetCap: #1 - must be nil or an integer", 2) end
  if drag_wait~=nil and math.type(drag_wait)~="integer" then error("Mouse_GetCap: #2 - must be nil or an integer", 2) end
--HUITOO=reaper.time_precise()
  -- prepare variables
  if reagirl.MouseCap==nil then
    -- if mouse-function hasn't been used yet, initialize variables
    reagirl.MouseCap={}
    reagirl.MouseCap.mouse_last_mousecap=0         -- last mousecap when last time this function got called, including 0
    reagirl.MouseCap.mouse_last_clicked_mousecap=0 -- last mousecap, the last time a button was clicked
    reagirl.MouseCap.mouse_dragcounter=0           -- the counter for click and wait, until drag is "activated"
    reagirl.MouseCap.mouse_lastx=0                 -- last mouse-x position
    reagirl.MouseCap.mouse_lasty=0                 -- last mouse-y position
    reagirl.MouseCap.mouse_endx=0                  -- end-x-position, for dragging
    reagirl.MouseCap.mouse_endy=0                  -- end-y-position, for dragging
    reagirl.MouseCap.mouse_dblclick=0              -- double-click-counter; 1, if a possible doubleclick can happen
    reagirl.MouseCap.mouse_dblclick_counter=0      -- double-click-waiting-counter; doubleclicks are only recognized, until this is "full"
    reagirl.MouseCap.mouse_clickblock=false        -- blocks mouseclicks after double-click, until button-release
    reagirl.MouseCap.mouse_last_hwheel=0           -- last horizontal mouse-wheel-state, the last time this function got called
    reagirl.MouseCap.mouse_last_wheel=0            -- last mouse-wheel-state, the last time this function got called
  end
  if math.type(doubleclick_wait)~="integer" then doubleclick_wait=0 end
  if math.type(drag_wait)~="integer" then drag_wait=15 end
  -- if mousewheels have been changed, store the new values and reset the gfx-variables
  if reagirl.MouseCap.mouse_last_hwheel~=gfx.mouse_hwheel or reagirl.MouseCap.mouse_last_wheel~=gfx.mouse_wheel then
    reagirl.MouseCap.mouse_last_hwheel=math.floor(gfx.mouse_hwheel)
    reagirl.MouseCap.mouse_last_wheel=math.floor(gfx.mouse_wheel)
  end
  gfx.mouse_hwheel=0
  gfx.mouse_wheel=0
  
  local newmouse_cap=0
  if gfx.mouse_cap&1~=0 then newmouse_cap=newmouse_cap+1 end
  if gfx.mouse_cap&2~=0 then newmouse_cap=newmouse_cap+2 end
  if gfx.mouse_cap&64~=0 then newmouse_cap=newmouse_cap+64 end
  
  if newmouse_cap==0 then
  -- if no mouse_cap is set, reset all counting-variables and return just the basics
    reagirl.MouseCap.mouse_last_mousecap=0
    reagirl.MouseCap.mouse_dragcounter=0
    reagirl.MouseCap.mouse_dblclick_counter=reagirl.MouseCap.mouse_dblclick_counter+1
    if reagirl.MouseCap.mouse_dblclick_counter>doubleclick_wait then
      -- if the doubleclick-timer is over, the next click will be recognized as normal click
      reagirl.MouseCap.mouse_dblclick=0
      reagirl.MouseCap.mouse_dblclick_counter=doubleclick_wait
    end
    reagirl.MouseCap.mouse_clickblock=false
    return "", "", gfx.mouse_cap, gfx.mouse_x, gfx.mouse_y, gfx.mouse_x, gfx.mouse_y, reagirl.MouseCap.mouse_last_wheel, reagirl.MouseCap.mouse_last_hwheel
  end
  if reagirl.MouseCap.mouse_clickblock==false then
    
    if newmouse_cap~=reagirl.MouseCap.mouse_last_mousecap then
      -- first mouseclick
      if reagirl.MouseCap.mouse_dblclick~=1 or (reagirl.MouseCap.mouse_lastx==gfx.mouse_x and reagirl.MouseCap.mouse_lasty==gfx.mouse_y) then

        -- double-click-checks
        if reagirl.MouseCap.mouse_dblclick~=1 then
          -- the first click, activates the double-click-timer
          reagirl.MouseCap.mouse_dblclick=1
          reagirl.MouseCap.mouse_dblclick_counter=0
        elseif reagirl.MouseCap.mouse_dblclick==1 and reagirl.MouseCap.mouse_dblclick_counter<doubleclick_wait 
            and reagirl.MouseCap.mouse_last_clicked_mousecap==newmouse_cap then
          -- when doubleclick occured, gfx.mousecap is still the same as the last clicked mousecap:
          -- block further mouseclick, until mousebutton is released and return doubleclick-values
          reagirl.MouseCap.mouse_dblclick=2
          reagirl.MouseCap.mouse_dblclick_counter=doubleclick_wait
          reagirl.MouseCap.mouse_clickblock=true
          return "CLK", "DBLCLK", gfx.mouse_cap, reagirl.MouseCap.mouse_lastx, reagirl.MouseCap.mouse_lasty, reagirl.MouseCap.mouse_lastx, reagirl.MouseCap.mouse_lasty, reagirl.MouseCap.mouse_last_wheel, reagirl.MouseCap.mouse_last_hwheel
        elseif reagirl.MouseCap.mouse_dblclick_counter==doubleclick_wait then
          -- when doubleclick-timer is full, reset mouse_dblclick to 0, so the next mouseclick is 
          -- recognized as normal mouseclick
          reagirl.MouseCap.mouse_dblclick=0
          reagirl.MouseCap.mouse_dblclick_counter=doubleclick_wait
        end
      end
      -- in every other case, this is a first-click, so set the appropriate variables and return 
      -- the first-click state and values
      reagirl.MouseCap.mouse_last_mousecap=newmouse_cap
      reagirl.MouseCap.mouse_last_clicked_mousecap=newmouse_cap
      reagirl.MouseCap.mouse_lastx=gfx.mouse_x
      reagirl.MouseCap.mouse_lasty=gfx.mouse_y
      return "CLK", "FirstCLK", gfx.mouse_cap, reagirl.MouseCap.mouse_lastx, reagirl.MouseCap.mouse_lasty, reagirl.MouseCap.mouse_lastx, reagirl.MouseCap.mouse_lasty, reagirl.MouseCap.mouse_last_wheel, reagirl.MouseCap.mouse_last_hwheel
    elseif newmouse_cap==reagirl.MouseCap.mouse_last_mousecap and reagirl.MouseCap.mouse_dragcounter<drag_wait
      and (gfx.mouse_x~=reagirl.MouseCap.mouse_lastx or gfx.mouse_y~=reagirl.MouseCap.mouse_lasty) then
      -- dragging when mouse moves, sets dragcounter to full waiting-period
      reagirl.MouseCap.mouse_endx=gfx.mouse_x
      reagirl.MouseCap.mouse_endy=gfx.mouse_y
      reagirl.MouseCap.mouse_dragcounter=drag_wait
      reagirl.MouseCap.mouse_dblclick=0
      return "CLK", "DRAG", gfx.mouse_cap, reagirl.MouseCap.mouse_lastx, reagirl.MouseCap.mouse_lasty, reagirl.MouseCap.mouse_endx, reagirl.MouseCap.mouse_endy, reagirl.MouseCap.mouse_last_wheel, reagirl.MouseCap.mouse_last_hwheel
    elseif newmouse_cap==reagirl.MouseCap.mouse_last_mousecap and reagirl.MouseCap.mouse_dragcounter<drag_wait then
      -- when clicked but mouse doesn't move, count up, until we reach the countlimit for
      -- activating dragging
      reagirl.MouseCap.mouse_dragcounter=reagirl.MouseCap.mouse_dragcounter+1
      return "CLK", "CLK", gfx.mouse_cap, reagirl.MouseCap.mouse_lastx, reagirl.MouseCap.mouse_lasty, reagirl.MouseCap.mouse_endx, reagirl.MouseCap.mouse_endy, reagirl.MouseCap.mouse_last_wheel, reagirl.MouseCap.mouse_last_hwheel
    elseif newmouse_cap==reagirl.MouseCap.mouse_last_mousecap and reagirl.MouseCap.mouse_dragcounter==drag_wait then
      -- dragging, after drag-counter is set to full waiting-period
      reagirl.MouseCap.mouse_endx=gfx.mouse_x
      reagirl.MouseCap.mouse_endy=gfx.mouse_y
      reagirl.MouseCap.mouse_dblclick=0
      return "CLK", "DRAG", gfx.mouse_cap, reagirl.MouseCap.mouse_lastx, reagirl.MouseCap.mouse_lasty, reagirl.MouseCap.mouse_endx, reagirl.MouseCap.mouse_endy, reagirl.MouseCap.mouse_last_wheel, reagirl.MouseCap.mouse_last_hwheel
    end
  else
    return "", "", gfx.mouse_cap, gfx.mouse_x, gfx.mouse_y, gfx.mouse_x, gfx.mouse_y, reagirl.MouseCap.mouse_last_wheel, reagirl.MouseCap.mouse_last_hwheel
  end
end

function reagirl.Gui_AtExit(run_func)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_AtExit</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Gui_AtExit(function run_func)</functioncall>
  <description>
    Adds a function that shall be run when the gui is closed with reagirl.Gui_Close()
    
    Good to do clean up or committing of settings.
  </description>
  <parameters>
    function run_func - a function, that shall be run when the gui closes
  </parameters>
  <chapter_context>
    Gui
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, atexit, gui, function</tags>
</US_DocBloc>
]]
  if type(run_func)~="function" then error("AtExit: param #1 - must be a function", -2) return end
  reagirl.AtExit_RunFunc=run_func
end

function reagirl.Gui_New()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_New</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Gui_New()</functioncall>
  <description>
    Creates a new gui by removing all currently(if available) ui-elements.
  </description>
  <chapter_context>
    Gui
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, new, gui</tags>
</US_DocBloc>
]]
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  reagirl.NewUI=true
  reagirl.MaxImage=1
  gfx.set(reagirl["WindowBackgroundColorR"], reagirl["WindowBackgroundColorG"], reagirl["WindowBackgroundColorB"])
  gfx.rect(0,0,gfx.w,gfx.h,1)
  gfx.x=0
  gfx.y=0
  reagirl.Elements={}
  reagirl.Elements["FocusedElement"]=nil
  reagirl.ScrollButton_Left_Add() 
  reagirl.ScrollButton_Right_Add()
  reagirl.ScrollButton_Up_Add()
  reagirl.ScrollButton_Down_Add()
end

function reagirl.Window_GetCurrentScale()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Window_GetCurrentScale</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>integer current_scaling_factor, boolean scaling_factor_override, integer current_system_scaling_factor = reagirl.Window_GetCurrentScale()</functioncall>
  <description>
    Gets the current scaling-factor
  </description>
  <retvals>
    integer current_scaling_factor - the scaling factor currently used by the script; nil, if autoscaling is activated
    boolean scaling_factor_override - does the current script override auto-scaling
    integer current_system_scaling_factor - the scaling factor that would be used, if auto-scaling would be on
  </retvals>
  <chapter_context>
    Misc
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>window, get, current scale</tags>
</US_DocBloc>
]]
  local retval, dpi = reaper.ThemeLayout_GetLayout("tcp", -3)
  local scale
  local dpi=tonumber(dpi)
  
  if dpi<384 then scale=1
  elseif dpi>=384 and dpi<512 then scale=1--.5
  elseif dpi>=512 and dpi<640 then scale=2
  elseif dpi>=640 and dpi<768 then scale=2--.5
  elseif dpi>=768 and dpi<896 then scale=3
  elseif dpi>=896 and dpi<1024 then scale=3--.5
  elseif dpi>=1024 and dpi<1152 then scale=4 
  elseif dpi>=1152 and dpi<1280 then scale=4--.5
  elseif dpi>=1280 and dpi<1408 then scale=5
  elseif dpi>=1408 and dpi<1536 then scale=5--.5
  elseif dpi>=1536 and dpi<1664 then scale=6
  elseif dpi>=1664 and dpi<1792 then scale=6--.5
  elseif dpi>=1792 and dpi<1920 then scale=7
  elseif dpi>=1920 and dpi<2048 then scale=7--.5
  else scale=8
  end
  return reagirl.Window_CurrentScale, reagirl.Window_CurrentScale_Override~=nil, scale
end

function reagirl.Window_SetCurrentScale(newscale)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Window_SetCurrentScale</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Window_SetCurrentScale(optional integer newscale)</functioncall>
  <description>
    Sets a new scaling-factor that overrides auto-scaling/scaling preferences
  </description>
  <retvals>
    optional integer newscale - the scaling factor that shall be used in the script
                              - nil, autoscaling/use preference
                              - 1-8, scaling factor between 1 and 8
  </retvals>
  <chapter_context>
    Misc
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>window, get, current scale</tags>
</US_DocBloc>
]]
  if newscale~=nil and math.type(newscale)~="integer" then error("Window_SetCurrentScale: #1 - must be either nil or an integer", 2) end
  if newscale~=nil and (newscale<1 or newscale>8) then error("Window_SetCurrentScale: #1 - must be either nil or an integer between 1 and 8", 2) end
  if newscale==nil then reagirl.Window_CurrentScale_Override=nil
  else 
    reagirl.Window_OldScale=newscale
    reagirl.Window_CurrentScale_Override=true
  end
  reagirl.Window_RescaleIfNeeded()
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0, newscale)
end

--

function reagirl.SetFont(idx, fontface, size, flags, scale_override)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetFont</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>integer font_size = reagirl.SetFont(integer idx, string fontface, integer size, integer flags, optional integer scale_override)</functioncall>
  <description>
    Sets the new font-size.
  </description>
  <parameters>
    integer idx - the index of the font to set
    string fontface - the name of the font, like "arial" or "tahoma" or "times"
    integer size - the size of the font(will be adjusted correctly on Mac)
    integer flags - a multibyte character, which can include 'i' for italics, 'u' for underline, or 'b' for bold. 
                      - These flags may or may not be supported depending on the font and OS. 
                      -   66 and 98, Bold (B), (b)
                      -   73 and 105, italic (I), (i)
                      -   79 and 111, white outline (O), (o)
                      -   82 and 114, blurred (R), (r)
                      -   83 and 115, sharpen (S), (s)
                      -   85 and 117, underline (U), (u)
                      -   86 and 118, inVerse (V), (v)
                      - 
                      - To create such a multibyte-character, assume this flag-value as a 32-bit-value.
                      - The first 8 bits are the first flag, the next 8 bits are the second flag, 
                      - the next 8 bits are the third flag and the last 8 bits are the second flag.
                      - The flagvalue(each dot is a bit): .... ....   .... ....   .... ....   .... ....
                      - If you want to set it to Bold(B) and Italic(I), you use the ASCII-Codes of both(66 and 73 respectively),
                      - take them apart into bits and set them in this 32-bitfield.
                      - The first 8 bits will be set by the bits of ASCII-value 66(B), the second 8 bits will be set by the bits of ASCII-Value 73(I).
                      - The resulting flagvalue is: 0100 0010   1001 0010   0000 0000   0000 0000
                      - which is a binary representation of the integer value 18754, which combines 66 and 73 in it.
    optional integer scale_override - set the scaling-factor for the font
                                    - nil, use autoscaling
                                    - 1-8, scale between 1-8
  </parmeters>
  <retvals>
    integer font_size - the properly scaled font-size
  </retvals>
  <chapter_context>
    Misc
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, set, font</tags>
</US_DocBloc>
]]
  if math.type(idx)~="integer" then error("SetFont: #1 - must be an integer", 2) end
  if type(fontface)~="string" then error("SetFont: #2 - must be an integer", 2) end
  if math.type(size)~="integer" then error("SetFont: #3 - must be an integer", 2) end
  if math.type(flags)~="integer" then error("SetFont: #4 - must be an integer", 2) end
  if scale_override~=nil and math.type(scale_override)~="integer" then error("SetFont: #5 - must be either nil(for autoscale) or an integer", 2) end
  if scale_override~=nil and (scale_override<1 or scale_override>8) then error("SetFont: #5 - must be between 1 and 8 or nil(for autoscale)", 2) end
  if scale_override~=nil then size=size*scale_override 
  else 
    if size~=nil then size=size*reagirl.Window_CurrentScale end
  end
  
  --local font_size = size * (1+reagirl.Window_CurrentScale)*0.5
  if reaper.GetOS():match("OS")~=nil then size=math.floor(size*0.8) end
  gfx.setfont(idx, fontface, size, flags)
  return size
end

function reagirl.Gui_Open(title, description, w, h, dock, x, y)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_Open</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    JS=0.963
    Lua=5.4
  </requires>
  <functioncall>integer window_open, optional hwnd window_handler = reagirl.Gui_Open(string title, string description, optional integer w, optional integer h, optional integer dock, optional integer x, optional integer y)</functioncall>
  <description>
    Opens a gui-window. If x and/or y are not given, it will be opened centered.
  </description>
  <retvals>
    number retval - 1.0, if window is opened
    optional hwnd window_handler - a hwnd-window-handler for this window; only returned, with JS-extension installed!
  </retvals>
  <parameters>
    string title - the title of the window
    string description - a description of what this dialog does, for blind users
    optional integer w - the width of the window; nil=640
    optional integer h - the height of the window; nil=400
    optional integer dock - the dockstate of the window; 0, undocked; 1, docked; nil=undocked
    optional integer x - the x-position of the window; nil=x-centered
    optional integer y - the y-position of the window; nil=y-centered
  </parameters>
  <chapter_context>
    Gui
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, open, gui</tags>
</US_DocBloc>
]]
  if type(title)~="string" then error("Gui_Open: #1 - must be an integer", 2) end
  if type(description)~="string" then error("Gui_Open: #2 - must be an integer", 2) end
  if w~=nil and math.type(w)~="integer" then error("Gui_Open: #3 - must be an integer", 2) end
  if h~=nil and math.type(h)~="integer" then error("Gui_Open: #4 - must be an integer", 2) end
  if dock~=nil and math.type(dock)~="integer" then error("Gui_Open: #5 - must be an integer", 2) end
  if x~=nil and math.type(x)~="integer" then error("Gui_Open: #6 - must be an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("Gui_Open: #7 - must be an integer", 2) end
  local retval
  retval, reagirl.dpi = reaper.ThemeLayout_GetLayout("tcp", -3)
  if reagirl.dpi == "512" then
    reagirl.dpi_scale = 1
    --gfx.ext_retina = 1
  else
    reagirl.dpi_scale = 0
  end
  
  reagirl.IsWindowOpen_attribute=true
  reagirl.Gui_ForceRefresh(1)
  
  reagirl.Window_Title=title
  reagirl.Window_Description=description
  reagirl.Window_x=x
  reagirl.Window_y=y
  reagirl.Window_w=w
  reagirl.Window_h=h
  reagirl.Window_dock=dock
  
  if reagirl.Window_ForceMinSize_Toggle==nil then reagirl.Window_ForceMinSize_Toggle=false end
  reagirl.osara_init_message=false
  
  return reagirl.Window_Open(title, w, h, dock, x, y)
end

function reagirl.Gui_IsOpen()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_IsOpen</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>boolean retval = reagirl.Gui_IsOpen()</functioncall>
  <description>
    Checks, whether the gui-window is open.
  </description>
  <retvals>
    boolean retval - true, Gui is open; false, Gui is not open
  </retvals>
  <chapter_context>
    Gui
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, is open, gui</tags>
</US_DocBloc>
]]
  return reagirl.IsWindowOpen_attribute
end

function reagirl.Gui_Close()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_Close</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Gui_Close()</functioncall>
  <description>
    Closes the gui-window.
  </description>
  <chapter_context>
    Gui
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, close, gui</tags>
</US_DocBloc>
]]
  gfx.quit()
  reagirl.IsWindowOpen_attribute=false
  reagirl.IsWindowOpen_attribute_Old=true
end


--up 30064.0
--down 1685026670.0

function reagirl.Gui_Manage()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_Manage</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Gui_Manage()</functioncall>
  <description>
    Manages the gui-window.
    
    Put this function in a defer-loop. It will manage, draw, show the gui.
  </description>
  <chapter_context>
    Gui
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gui, functions, manage</tags>
</US_DocBloc>
]]
  -- manages the gui, including tts, mouse and keyboard-management and ui-focused-management

  -- initialize shit
  if reagirl.NewUI==true then reagirl.NewUI=false reagirl.Elements.FocusedElement=1 end
  if #reagirl.Elements==0 then error("Gui_Manage: no ui-element available", -2) end
  if #reagirl.Elements<reagirl.Elements.FocusedElement then reagirl.Elements.FocusedElement=1 end
  reagirl.UI_Element_MinX=gfx.w
  reagirl.UI_Element_MinY=gfx.h
  reagirl.UI_Element_MaxW=0
  reagirl.UI_Element_MaxH=0
  local x2, y2
  reagirl.Window_RescaleIfNeeded()
  reagirl.UI_Elements_Boundaries()
  local scale=reagirl.Window_CurrentScale
  local Window_State=gfx.getchar(65536)
  
  
  -- initialize focus of first element, if not done already
  if reagirl.Elements["FocusedElement"]==nil then reagirl.Elements["FocusedElement"]=reagirl.UI_Element_GetNext(0) end
  -- initialize osara-message
  local init_message=""
  local helptext=""
  if reagirl.osara_init_message==false then
    if reagirl.Elements["FocusedElement"]~=-1 then
      if reagirl.Elements[1]~=nil then
        reagirl.osara_init_message=reagirl.Window_Title.. "-dialog, ".. reagirl.Window_Description..". ".. reagirl.Elements[reagirl.Elements["FocusedElement"]]["Name"].." ".. reagirl.Elements[reagirl.Elements["FocusedElement"]]["GUI_Element_Type"]
        helptext=reagirl.Elements[reagirl.Elements["FocusedElement"]]["Description"]..", "..reagirl.Elements[reagirl.Elements["FocusedElement"]]["AccHint"]
      else
        reagirl.osara_init_message=reagirl.Window_Title.."-dialog, "..reagirl.Window_Description..". "
      end
    end
  end
  
  -- keine Ahnung
  reagirl.FileDropZone_CheckForDroppedFiles()
  reagirl.ContextMenuZone_ManageMenu(gfx.mouse_cap)
  
  -- reset clicked state
  for i=1, #reagirl.Elements do reagirl.Elements[i]["clicked"]=false end
  
  -- [[ Keyboard Management ]]
  local Key, Key_utf=gfx.getchar()
  
  --Debug Code - move ui-elements via arrow keys, including stopping when end of ui-elements has been reached.
  -- This can be used to build more extensive scrollcode, including smooth scroll and scrollbars
  -- see reagirl.UI_Elements_Boundaries() for the calculation of it and more information
  if reagirl.Scroll_Override_MouseWheel~=true then
    if gfx.mouse_hwheel~=0 then reagirl.UI_Element_ScrollX(-gfx.mouse_hwheel/50) end
    if gfx.mouse_wheel~=0 then reagirl.UI_Element_ScrollY(gfx.mouse_wheel/50) end
  end
  reagirl.Scroll_Override_MouseWheel=nil
  if reagirl.Elements["FocusedElement"]~=-1 and reagirl.Elements[reagirl.Elements["FocusedElement"]].GUI_Element_Type~="Edit" and reagirl.Elements[reagirl.Elements["FocusedElement"]].GUI_Element_Type~="Edit Multiline" then
  -- scroll via keys
    if reagirl.Scroll_Override~=true then
      --print_alt(reaper.time_precise(), tostring(reagirl.Scroll_Override))
      if gfx.mouse_cap&8==0 and Key==30064 then reagirl.UI_Element_ScrollY(2) end -- up
      if gfx.mouse_cap&8==0 and Key==1685026670 then reagirl.UI_Element_ScrollY(-2) end --down
      if Key==1818584692.0 then reagirl.UI_Element_ScrollX(-2) end -- left
      if Key==1919379572.0 then reagirl.UI_Element_ScrollX(2) end -- right
      if Key==1885828464.0 then reagirl.UI_Element_ScrollY(20) end -- pgdown
      if Key==1885824110.0 then reagirl.UI_Element_ScrollY(-20) end -- pgup
      if gfx.mouse_cap&8==8 and Key==1818584692.0 then reagirl.UI_Element_ScrollX(20) end -- Shift+left  - pgleft
      if gfx.mouse_cap&8==8 and Key==1919379572.0 then reagirl.UI_Element_ScrollX(-20) end --Shift+right - pgright
      if Key==1752132965.0 then reagirl.MoveItAllUp=0 reagirl.Gui_ForceRefresh(64.789) end -- home
      if Key==6647396.0 then MoveItAllUp_Delta=0 reagirl.MoveItAllUp=gfx.h-reagirl.BoundaryY_Max reagirl.Gui_ForceRefresh(64.1) end -- end
      --if Key~=0 then print3(Key) end
    end
  end
  reagirl.Scroll_Override=nil
  reagirl.UI_Element_SmoothScroll(1)
  -- End of Debug
  
  if Key==-1 then reagirl.IsWindowOpen_attribute_Old=true reagirl.IsWindowOpen_attribute=false end
  
  if reagirl.Gui_PreventCloseViaEscForOneCycle_State~=true then
    if Key==27 then 
      reagirl.Gui_Close() 
      --if reagirl.AtExit_RunFunc~=nil then reagirl.AtExit_RunFunc() end
    end -- esc closes window
  end 
  reagirl.Window_ForceMinSize() 
  reagirl.Window_ForceMaxSize() 
  -- run atexit-function when window gets closed by the close button
  
  if reagirl.IsWindowOpen_attribute_Old==true and reagirl.IsWindowOpen_attribute==false then
    reagirl.IsWindowOpen_attribute_Old=false
    if reagirl.AtExit_RunFunc~=nil then reagirl.AtExit_RunFunc() end
  end
  if Key==26161 and reaper.osara_outputMessage~=nil then reaper.osara_outputMessage(reagirl.Elements[reagirl.Elements["FocusedElement"]]["Description"],1) end -- F1 help message for osara
  
  -- if mouse has been moved, reset wait-counter for displaying tooltip
  if reagirl.OldMouseX==gfx.mouse_x and reagirl.OldMouseY==gfx.mouse_y then
    reagirl.TooltipWaitCounter=reagirl.TooltipWaitCounter+1
  else
    reagirl.TooltipWaitCounter=0
  end
  reagirl.OldMouseX=gfx.mouse_x
  reagirl.OldMouseY=gfx.mouse_y
  
  -- if window has been resized, force refresh
  if reagirl.Windows_OldH~=gfx.h then reagirl.Windows_OldH=gfx.h reagirl.Gui_ForceRefresh(2) end
  if reagirl.Windows_OldW~=gfx.w then reagirl.Windows_OldW=gfx.w reagirl.Gui_ForceRefresh(3) end
  
  -- Tab-key - next ui-element
  if gfx.mouse_cap&8==0 and Key==9 then 
    reagirl.Elements["FocusedElement"]=reagirl.UI_Element_GetNext(reagirl.Elements["FocusedElement"])
    --reagirl.Elements["FocusedElement"]=reagirl.Elements["FocusedElement"]+1 
    if reagirl.Elements["FocusedElement"]~=-1 then
      if reagirl.Elements["FocusedElement"]>#reagirl.Elements then reagirl.Elements["FocusedElement"]=1 end 
      init_message=reagirl.Elements[reagirl.Elements["FocusedElement"]]["Name"].." "..reagirl.Elements[reagirl.Elements["FocusedElement"]]["GUI_Element_Type"]..". "
      helptext=reagirl.Elements[reagirl.Elements["FocusedElement"]]["Description"]..", "..reagirl.Elements[reagirl.Elements["FocusedElement"]]["AccHint"]
      if reagirl.Elements["FocusedElement"]<=#reagirl.Elements-4 then
        reagirl.UI_Element_ScrollToUIElement(reagirl.Elements[reagirl.Elements["FocusedElement"]].Guid) -- buggy, should scroll to ui-element...
      end
      reagirl.UI_Element_SetFocusRect()
      reagirl.old_osara_message=""
      reagirl.Gui_ForceRefresh(4) 
    end
  end
  if reagirl.Elements["FocusedElement"]>#reagirl.Elements then reagirl.Elements["FocusedElement"]=1 end
  
  -- Shift+Tab-key - previous ui-element
  if gfx.mouse_cap&8==8 and Key==9 then 
    reagirl.Elements["FocusedElement"]=reagirl.UI_Element_GetPrevious(reagirl.Elements["FocusedElement"])
    if reagirl.Elements["FocusedElement"]~=-1 then
      if reagirl.Elements["FocusedElement"]<1 then reagirl.Elements["FocusedElement"]=#reagirl.Elements end
      init_message=reagirl.Elements[reagirl.Elements["FocusedElement"]]["Name"].." "..
      reagirl.Elements[reagirl.Elements["FocusedElement"]]["GUI_Element_Type"]..". "
      helptext=reagirl.Elements[reagirl.Elements["FocusedElement"]]["Description"]..", "..reagirl.Elements[reagirl.Elements["FocusedElement"]]["AccHint"]
      reagirl.old_osara_message=""
      if reagirl.Elements["FocusedElement"]<=#reagirl.Elements-4 then
        reagirl.UI_Element_ScrollToUIElement(reagirl.Elements[reagirl.Elements["FocusedElement"]].Guid) -- buggy, should scroll to ui-element...
      end
      reagirl.UI_Element_SetFocusRect()
      reagirl.Gui_ForceRefresh(5) 
    end
  end
  if reagirl.Elements["FocusedElement"]<1 then reagirl.Elements["FocusedElement"]=#reagirl.Elements end
  
  -- Space-Bar "clicks" currently focused ui-element
  if Key==32 then reagirl.Elements[reagirl.Elements["FocusedElement"]]["clicked"]=true end
  
  
  -- [[ click management-code]]
  local clickstate, specific_clickstate, mouse_cap, click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel = reagirl.Mouse_GetCap(5, 10)
  
  -- finds out also, which ui-element shall be seen as clicked(only the last ui-element within click-area will be seen as clicked)
  -- changes the selected ui-element when clicked AND shows tooltip
  reagirl.UI_Elements_HoveredElement=-1
  for i=#reagirl.Elements, 1, -1 do
    local x2, y2, w2, h2
    if reagirl.Elements[i]["x"]<0 then x2=gfx.w+(reagirl.Elements[i]["x"]*scale) else x2=reagirl.Elements[i]["x"]*scale end
    if reagirl.Elements[i]["y"]<0 then y2=gfx.h+(reagirl.Elements[i]["y"]*scale) else y2=reagirl.Elements[i]["y"]*scale end
    if reagirl.Elements[i]["w"]<0 then w2=gfx.w+(-x2+reagirl.Elements[i]["w"]*scale) else w2=reagirl.Elements[i]["w"]*scale end
    if reagirl.Elements[i]["h"]<0 then h2=gfx.h+(-y2+reagirl.Elements[i]["h"]*scale) else h2=reagirl.Elements[i]["h"]*scale end
    if reagirl.Elements[i]["GUI_Element_Type"]=="DropDownMenu" then if w2<20 then w2=20 end end
    --[[
    x2=x2*scale
    y2=y2*scale
    w2=w2*scale
    h2=h2*scale
    --]]
    -- is any gui-element outside of the window
    local MoveItAllUp=reagirl.MoveItAllUp  
    local MoveItAllRight=reagirl.MoveItAllRight
    if reagirl.Elements[i]["sticky_y"]==true then MoveItAllUp=0 end
    if reagirl.Elements[i]["sticky_x"]==true then MoveItAllRight=0 end
    
    if x2+MoveItAllRight<reagirl.UI_Element_MinX then reagirl.UI_Element_MinX=x2+MoveItAllRight end
    if y2<reagirl.UI_Element_MinY+MoveItAllUp then reagirl.UI_Element_MinY=y2+MoveItAllUp end
    
    if x2+MoveItAllRight+w2>reagirl.UI_Element_MaxW then reagirl.UI_Element_MaxW=x2+MoveItAllRight+w2 end
    if y2+MoveItAllUp+h2>reagirl.UI_Element_MaxH then reagirl.UI_Element_MaxH=y2+h2+MoveItAllUp end
  
    -- show tooltip when hovering over a ui-element
    -- also set clicked ui-element to the one at mouse-position, when specific_clickstate="FirstCLK"
    if gfx.mouse_x>=x2+MoveItAllRight and
       gfx.mouse_x<=x2+MoveItAllRight+w2 and
       gfx.mouse_y>=y2+MoveItAllUp and
       gfx.mouse_y<=y2+MoveItAllUp+h2 then
       reagirl.UI_Elements_HoveredElement=i
       -- tooltip management
       if reagirl.TooltipWaitCounter==14 then
        local XX,YY=reaper.GetMousePosition()
        if Window_State&2==2 then
          reaper.TrackCtl_SetToolTip(reagirl.Elements[i]["Description"], XX+15, YY+10, true)
        end
        reaper.osara_outputMessage(Window_State)
        --if reaper.osara_outputMessage~=nil then reaper.osara_outputMessage(reagirl.Elements[i]["Text"],2--[[:utf8_sub(1,20)]]) end
       end
       
       -- focused/clicked ui-element-management
       if (specific_clickstate=="FirstCLK") and reagirl.Elements[i]["IsDecorative"]==false then
         if i~=reagirl.Elements["FocusedElement"] then
           init_message=reagirl.Elements[i]["Name"].." "..reagirl.Elements[i]["GUI_Element_Type"]:sub(1,-1).." "
           helptext=reagirl.Elements[i]["Description"]..", "..reagirl.Elements[i]["AccHint"]
         end
         
         -- set found ui-element as focused and clicked
         reagirl.Elements["FocusedElement"]=i
         reagirl.Elements[i]["clicked"]=true
         reagirl.UI_Element_SetFocusRect()
         reagirl.Gui_ForceRefresh(6) 
       end
       found_element=i
       break
    end
  end
  
  if reagirl.UI_Elements_HoveredElement~=-1 and reagirl.UI_Elements_HoveredElement~=reagirl.UI_Elements_HoveredElement_Old then
    if reaper.osara_outputMessage~=nil then
      if reagirl.Elements[reagirl.UI_Elements_HoveredElement]["AccHoverMessage"]~=nil then
        reaper.osara_outputMessage(reagirl.Elements[reagirl.UI_Elements_HoveredElement]["AccHoverMessage"])
      else
        reaper.osara_outputMessage(reagirl.Elements[reagirl.UI_Elements_HoveredElement]["Name"])
      end
    end
  end
  reagirl.UI_Elements_HoveredElement_Old=reagirl.UI_Elements_HoveredElement
  
  -- run all gui-element-management functions once. They shall decide, if a refresh is needed, provide the osara-screenreader-message and everything
  -- this is also the code, where a clickstate of a selected ui-element is interpreted
  --reaper.ClearConsole()
  for i=#reagirl.Elements, 1, -1 do
    local x2, y2, w2, h2
    if reagirl.Elements[i]["x"]<0 then x2=gfx.w+(reagirl.Elements[i]["x"]*scale) else x2=(reagirl.Elements[i]["x"]*scale) end
    if reagirl.Elements[i]["y"]<0 then y2=gfx.h+(reagirl.Elements[i]["y"]*scale) else y2=(reagirl.Elements[i]["y"]*scale) end
    if reagirl.Elements[i]["w"]<0 then w2=gfx.w+(-x2+reagirl.Elements[i]["w"]*scale) else w2=reagirl.Elements[i]["w"]*scale end
    if reagirl.Elements[i]["h"]<0 then h2=gfx.h+(-y2+reagirl.Elements[i]["h"]*scale) else h2=reagirl.Elements[i]["h"]*scale end
    --[[
    x2=x2*scale
    y2=y2*scale
    w2=w2*scale
    h2=h2*scale
    --]]
    
    local MoveItAllUp=reagirl.MoveItAllUp   
    local MoveItAllRight=reagirl.MoveItAllRight
    if reagirl.Elements[i]["sticky_y"]==true then MoveItAllUp=0 end
    if reagirl.Elements[i]["sticky_x"]==true then MoveItAllRight=0 end
    --if (x2+MoveItAllRight>=0 and x2+MoveItAllRight<=gfx.w) or (y2+MoveItAllUp>=0 and y2+MoveItAllUp<=gfx.h) or (x2+MoveItAllRight+w2>=0 and x2+MoveItAllRight+w2<=gfx.w) or (y2+MoveItAllUp+h2>=0 and y2+MoveItAllUp+h2<=gfx.h) then
    -- uncommented code: might improve performance by running only manage-functions of UI-elements, who are visible(though might be buggy)
    --                   but seems to work without it as well
    if reagirl.Elements[i]["IsDecorative"]==false then
      if i==reagirl.Elements["FocusedElement"] or ((((x2+reagirl.MoveItAllRight>0 and x2+reagirl.MoveItAllRight<=gfx.w) 
      or (x2+w2+reagirl.MoveItAllRight>0 and x2+w2+reagirl.MoveItAllRight<=gfx.w) 
      or (x2+reagirl.MoveItAllRight<=0 and x2+w2+reagirl.MoveItAllRight>=gfx.w))
      and ((y2+reagirl.MoveItAllUp>=0 and y2+reagirl.MoveItAllUp<=gfx.h)
      or (y2+h2+reagirl.MoveItAllUp>=0 and y2+h2+reagirl.MoveItAllUp<=gfx.h)
      or (y2+reagirl.MoveItAllUp<=0 and y2+h2+reagirl.MoveItAllUp>=gfx.h))) or i>#reagirl.Elements-4)
      then--]]  
        -- run manage-function of ui-element
        local cur_message, refresh=reagirl.Elements[i]["func_manage"](i, reagirl.Elements["FocusedElement"]==i,
          reagirl.UI_Elements_HoveredElement==i,
          specific_clickstate,
          gfx.mouse_cap,
          {click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel},
          reagirl.Elements[i]["Name"],
          reagirl.Elements[i]["Description"], 
          x2+MoveItAllRight,
          y2+MoveItAllUp,
          w2,
          h2,
          Key,
          Key_utf,
          reagirl.Elements[i]
        )
        if i==reagirl.Elements.FocusedElement then message=cur_message end
        --print_update(message)
      end -- only run manage-functions of visible gui-elements
      --print_update(reaper.time_precise()-AAAA)
      
      -- output screenreader-message of ui-element
      if reagirl.Elements["FocusedElement"]==i and reagirl.Elements[reagirl.Elements["FocusedElement"]]["IsDecorative"]==false and reagirl.old_osara_message~=message and reaper.osara_outputMessage~=nil then
        --reaper.osara_outputMessage(reagirl.osara_init_message..message)
        if message==nil then message="" end
        
        reaper.osara_outputMessage(reagirl.osara_init_message..""..init_message.." "..message.." "..helptext,3)
        reagirl.old_osara_message=message
        reagirl.osara_init_message=""
      end
      if refresh==true then reagirl.Gui_ForceRefresh(7) end
    end
  end
  --]]
  --gfx.measurechar(128)
  --gfx.measurestr(128)
  -- go over to draw the ui-elements
  reagirl.Gui_Draw(Key, Key_utf, clickstate, specific_clickstate, mouse_cap, click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel)
end

function reagirl.Gui_Draw(Key, Key_utf, clickstate, specific_clickstate, mouse_cap, click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel)
  -- no docs in API-docs
  -- draw the ui-elements, if refresh-state=true
  
  local selected, x2, y2
  local scale=reagirl.Window_CurrentScale
  
  if reagirl.Gui_ForceRefreshState==true then
    -- clear background and draw bg-color/background image
    gfx.set(reagirl["WindowBackgroundColorR"],reagirl["WindowBackgroundColorG"],reagirl["WindowBackgroundColorB"])
    gfx.rect(0,0,gfx.w,gfx.h,1)
    reagirl.Background_DrawImage()

    -- draw all ui-elements
    --AAAAA=0
    for i=1, #reagirl.Elements, 1 do
      local x2, y2, w2, h2
      if reagirl.Elements[i]["x"]<0 then x2=gfx.w+(reagirl.Elements[i]["x"]*scale) else x2=reagirl.Elements[i]["x"]*scale end
      if reagirl.Elements[i]["y"]<0 then y2=gfx.h+(reagirl.Elements[i]["y"]*scale) else y2=reagirl.Elements[i]["y"]*scale end
      
      --if reagirl.Elements[i]["w"]<0 then w2=gfx.w-(x2+reagirl.Elements[i]["w"]*scale) else w2=reagirl.Elements[i]["w"]*scale end
      if reagirl.Elements[i]["w"]<0 then w2=gfx.w+(-x2+reagirl.Elements[i]["w"]*scale) else w2=reagirl.Elements[i]["w"]*scale end
      if reagirl.Elements[i]["h"]<0 then h2=gfx.h+(-y2+reagirl.Elements[i]["h"]*scale) else h2=reagirl.Elements[i]["h"]*scale end
      --[[
      x2=x2*scale
      y2=y2*scale
      w2=w2*scale
      h2=h2*scale
      --]]

      local MoveItAllUp=reagirl.MoveItAllUp  
      local MoveItAllRight=reagirl.MoveItAllRight
      if reagirl.Elements[i]["sticky_y"]==true then MoveItAllUp=0 end
      if reagirl.Elements[i]["sticky_x"]==true then MoveItAllRight=0 end
      
      -- run the draw-function of the ui-element
      
      -- the following lines shall limit drawing on only visible areas. However, when non-resized images are used, the width and height don't match and therefor the image might disappear when scrolling
      --if (x2+MoveItAllRight>=0 and x2+MoveItAllRight<=gfx.w)       and (y2+MoveItAllUp>=0    and y2+MoveItAllUp<=gfx.h) 
      --or (x2+MoveItAllRight+w2>=0 and x2+MoveItAllRight+w2<=gfx.w) and (y2+MoveItAllUp+h2>=0 and y2+MoveItAllUp+h2<=gfx.h) then
      
      --[[if (((x2+reagirl.MoveItAllRight>0 and x2+reagirl.MoveItAllRight<=gfx.w) 
      or (x2+w2+reagirl.MoveItAllRight>0 and x2+w2+reagirl.MoveItAllRight<=gfx.w) 
      or (x2+reagirl.MoveItAllRight<=0 and x2+w2+reagirl.MoveItAllRight>=gfx.w))
      and ((y2+reagirl.MoveItAllUp>=0 and y2+reagirl.MoveItAllUp<=gfx.h)
      or (y2+h2+reagirl.MoveItAllUp>=0 and y2+h2+reagirl.MoveItAllUp<=gfx.h)
      or (y2+reagirl.MoveItAllUp<=0 and y2+h2+reagirl.MoveItAllUp>=gfx.h))) or i>#reagirl.Elements-4
      then
      --]]
 --     print_update((x2+reagirl.MoveItAllRight>=0 and x2+reagirl.MoveItAllRight<=gfx.w), x2+MoveItAllRight, (x2+reagirl.MoveItAllRight+w2>=0 and x2+reagirl.MoveItAllRight+w2<=gfx.w))
      --AAAAA=AAAAA+1
        local message=reagirl.Elements[i]["func_draw"](i, reagirl.Elements["FocusedElement"]==i,
          reagirl.UI_Elements_HoveredElement==i,
          specific_clickstate,
          gfx.mouse_cap,
          {click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel},
          reagirl.Elements[i]["Name"],
          reagirl.Elements[i]["Description"], 
          math.floor(x2+MoveItAllRight),
          math.floor(y2+MoveItAllUp),
          math.floor(w2),
          math.floor(h2),
          Key,
          Key_utf,
          reagirl.Elements[i]
        )
      --end -- draw_only_necessary-elements
      if reagirl.Elements["FocusedElement"]~=-1 and reagirl.Elements["FocusedElement"]==i then
        --if reagirl.Elements[i]["GUI_Element_Type"]=="DropDownMenu" then --  if w2<20 then w2=20 end end
        local r,g,b,a=gfx.r,gfx.g,gfx.b,gfx.a
        local dest=gfx.dest
        gfx.dest=-1
        gfx.set(0.7,0.7,0.7,0.8)
        local _,_,_,_,x,y,w,h=reagirl.UI_Element_GetFocusRect()
        --print_update(scale, x, y, w, h, reagirl.Font_Size)
        if reagirl.Focused_Rect_Override==nil then
          gfx.rect((x2+MoveItAllRight-2), (y2+MoveItAllUp-2), (w2+4), (h2+3), 0)
        else
          gfx.rect(reagirl.Elements["Focused_x"], reagirl.Elements["Focused_y"], reagirl.Elements["Focused_w"], reagirl.Elements["Focused_h"], 0)
        end
        reagirl.Focused_Rect_Override=nil
        gfx.set(r,g,b,a)
        gfx.dest=dest
        
        -- if osara is installed, move mouse to hover above ui-element
        if reaper.osara_outputMessage~=nil and reagirl.oldselection~=i then
          reagirl.oldselection=i
          if reaper.JS_Mouse_SetPosition~=nil then 
            --reagirl.UI_Element_ScrollToUIElement(reagirl.Elements[reagirl.Elements["FocusedElement"]].Guid) -- buggy, should scroll to ui-element...
            if gfx.mouse_x<=x2 or gfx.mouse_x>=x2+w2 or gfx.mouse_y<=y2 or gfx.mouse_y>=y2+h2 then
              --local tempx, tempy=gfx.clienttoscreen(x2+MoveItAllRight+4,y2+MoveItAllUp+4)
              --if tempx<0 then tempx=-tempx end
              reaper.JS_Mouse_SetPosition(gfx.clienttoscreen(x2+MoveItAllRight+4,y2+MoveItAllUp+4)) 
            end
          end
        end
      end
    end
  end
  reagirl.Gui_ForceRefreshState=false
  --DebugRect()
end

function reagirl.Dummy()

end

function reagirl.UI_Element_SetFocusRect(override, x, y, w, h)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_SetFocusRect</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.UI_Element_SetFocusRect(integer x, integer y, integer w, integer h)</functioncall>
  <description>
    sets the rectangle for focused ui-element. Can be used for custom ui-element, who need to control the focus-rectangle due some of their own ui-elements incorporated, like options in radio-buttons, etc.
  </description>
  <parameters>
    integer x - the x-position of the focus-rectangle; negative, dock to the right windowborder
    integer y - the y-position of the focus-rectangle; negative, dock to the bottom windowborder
    integer w - the width of the focus-rectangle; negative, dock to the right windowborder
    integer h - the height of the focus-rectangle; negative, dock to the bottom windowborder
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, set, focus rectangle, ui-elements</tags>
</US_DocBloc>
]]
  if override==nil then override=false end
  if type(override)~="boolean" then error("UI_Element_SetFocusRect: #1 - must be either nil or a boolean", 2) end
  if override==true then
    if math.type(x)~="integer" then error("UI_Element_SetFocusRect: #2 - when override=nil then it must be an integer", 2) end
    if math.type(y)~="integer" then error("UI_Element_SetFocusRect: #3 - when override=nil then it must be an integer", 2) end
    if math.type(w)~="integer" then error("UI_Element_SetFocusRect: #4 - when override=nil then it must be an integer", 2) end
    if math.type(h)~="integer" then error("UI_Element_SetFocusRect: #5 - when override=nil then it must be an integer", 2) end
  end
  
  if override==false then 
    if reagirl.Elements[reagirl.Elements["FocusedElement"]]==nil then error("UI_Element_SetFocusRect: - no ui-elements existing", 2) end
    x=reagirl.Elements[reagirl.Elements["FocusedElement"]]["x"]
    y=reagirl.Elements[reagirl.Elements["FocusedElement"]]["y"]
    w=reagirl.Elements[reagirl.Elements["FocusedElement"]]["w"]
    h=reagirl.Elements[reagirl.Elements["FocusedElement"]]["h"]
    reagirl.Focused_Rect_Override=nil
  end
  if override==true then 
    reagirl.Focused_Rect_Override=true 
    reagirl.Elements["Focused_x"]=x
    reagirl.Elements["Focused_y"]=y
    reagirl.Elements["Focused_w"]=w
    reagirl.Elements["Focused_h"]=h
  end
end



function reagirl.UI_Element_GetFocusRect()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetFocusRect</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>integer x, integer y, integer w, integer h, integer x2, integer y2, integer w2, integer h2 = reagirl.UI_Element_GetFocusRect()</functioncall>
  <description>
    gets the rectangle for focused ui-element. Can be used for custom ui-element, who need to control the focus-rectangle due some of their own ui-elements incorporated, like options in radio-buttons, etc.
    
    the first four retvals give the set-position(including possible negative values), the second four retvals give the actual window-coordinates.
  </description>
  <parameters>
    integer x - the x-position of the focus-rectangle; negative, dock to the right windowborder
    integer y - the y-position of the focus-rectangle; negative, dock to the bottom windowborder
    integer w - the width of the focus-rectangle; negative, dock to the right windowborder
    integer h - the height of the focus-rectangle; negative, dock to the bottom windowborder
    integer x2 - the actual x-position of the focus-rectangle
    integer y2 - the actual y-position of the focus-rectangle
    integer w2 - the actual width of the focus-rectangle
    integer h2 - the actual height of the focus-rectangle
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, get, focus rectangle, ui-elements</tags>
</US_DocBloc>
]]
  if reagirl.Elements["Focused_x"]==nil then 
    if reagirl.Elements[reagirl.Elements["FocusedElement"]]~=nil then 
      local x,y,w,h
      x=reagirl.Elements[reagirl.Elements["FocusedElement"]]["x"]
      y=reagirl.Elements[reagirl.Elements["FocusedElement"]]["y"]
      w=reagirl.Elements[reagirl.Elements["FocusedElement"]]["w"]
      h=reagirl.Elements[reagirl.Elements["FocusedElement"]]["h"]
      --print(x,y,w,h)
      reagirl.UI_Element_SetFocusRect(true, x, y, w, h)
    else
      reagirl.UI_Element_SetFocusRect(true, 0,0,0,0)
    end
  end
  
  local x,y,w,h,x2,y2,w2,h2
  x=reagirl.Elements["Focused_x"]
  y=reagirl.Elements["Focused_y"]
  w=reagirl.Elements["Focused_w"]
  h=reagirl.Elements["Focused_h"]
  
  if x<0 then x2=gfx.w+x else x2=x end
  if y<0 then y2=gfx.h+y else y2=y end
  if w<0 then w2=gfx.w-x2+w else w2=w end
  if h<0 then h2=gfx.h-y2+h else h2=h end
  
  return x,y,w,h,x2,y2,w2,h2
end

function reagirl.UI_Elements_OutsideWindow()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Elements_OutsideWindow</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>integer horz_outside, integer vert_outside = reagirl.UI_Elements_OutsideWindow()</functioncall>
  <description>
    returns, if any of the gui-elements are outside of the window and by how much.
    
    Good for management of resizing window or scrollbars.
  </description>
  <retvals>
    integer horz_outside - the number of horizontal-pixels the ui-elements are outside of the window
    integer vert_outside - the number of vertical-pixels the ui-elements are outside of the window
  </retvals>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, is outside window, ui-elements</tags>
</US_DocBloc>
]]
  local vert=0
  local horz=0
  
  if reagirl.UI_Element_MinX<0 then vert=reagirl.UI_Element_MaxW-gfx.w
  elseif reagirl.UI_Element_MaxW>gfx.w then vert=reagirl.UI_Element_MaxW-gfx.w end
  
  if reagirl.UI_Element_MinY<0 then horz=gfx.h-reagirl.UI_Element_MaxH horz=-horz
  elseif reagirl.UI_Element_MaxH>gfx.h then horz=gfx.h-reagirl.UI_Element_MaxH horz=-horz end
  return horz, vert
end

function reagirl.UI_Element_GetNextOfType(ui_type, startoffset)
  -- will return the ui-element of a specific type next to the startoffset
  -- will "overflow", if the next element has a lower index
  local count=startoffset
  for i=1, #reagirl.Elements do
    count=count+1
    if count>#reagirl.Elements then count=1 end
    if reagirl.Elements[count].GUI_Element_Type==ui_type then return count, reagirl.Elements[count].Guid end
  end
  return -1, ""
end

function reagirl.UI_Element_GetPreviousOfType(ui_type, startoffset)
  -- will return the ui-element of a specific type next to the startoffset
  -- will "overflow", if the next element has a lower index
  local count=startoffset
  for i=1, #reagirl.Elements do
    count=count-1
    if count<1 then count=#reagirl.Elements end
    if reagirl.Elements[count].GUI_Element_Type==ui_type then return count, reagirl.Elements[count].Guid end
  end
  return -1, ""
end

function reagirl.UI_Element_GetNext(startoffset)
  -- will return the ui-element of a specific type next to the startoffset
  -- will "overflow", if the next element has a lower index
  local count=startoffset
  
  for i=1, #reagirl.Elements do
    count=count+1
    if count>#reagirl.Elements then count=1 end
    if reagirl.Elements[count]~=nil and reagirl.Elements[count].IsDecorative==false then 
      return count, reagirl.Elements[count].Guid 
    end
  end
  return -1, ""
end


function reagirl.UI_Element_GetPrevious(startoffset)
  -- will return the ui-element of a specific type next to the startoffset
  -- will "overflow", if the next element has a lower index
  local count=startoffset
  for i=1, #reagirl.Elements do
    count=count-1
    if count<1 then count=#reagirl.Elements end
    if reagirl.Elements[count].IsDecorative==false then return count, reagirl.Elements[count].Guid end
  end
  return -1, ""
end


function reagirl.UI_Element_GetType(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetType</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string ui_type = reagirl.UI_Element_GetType(string element_id)</functioncall>
  <description>
    returns the type of the ui-element
  </description>
  <retvals>
    string ui_type - the type of the ui-element, like "Button", "Image", "Checkbox", "DropDownMenu", etc
  </retvals>
  <parameters>
    string element_id - the id of the element, whose type you want to get
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, get, type, ui-elements</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_GetType: #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_GetType: #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetType: #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]~=nil then
    return reagirl.Elements[element_id]["GUI_Element_Type"]
  end
end

function reagirl.UI_Element_GetSetDescription(element_id, is_set, description)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSetDescription</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string ui_type = reagirl.UI_Element_GetSetDescription(string element_id, boolean is_set, string description)</functioncall>
  <description>
    gets/sets the description of the ui-element
  </description>
  <retvals>
    string description - the description of the ui-element
  </retvals>
  <parameters>
    string element_id - the id of the element, whose description you want to get/set
    boolean is_set - true, set the description; false, don't set the description
    string description - the description of the ui-element
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, set, get, description, ui-elements</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_GetSetDescription: #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_GetSetDescription: #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetSetDescription: #1 - no such ui-element", 2) end
  if type(is_set)~="boolean" then error("UI_Element_GetSetDescription: #2 - must be a boolean", 2) end
  if is_set==true and type(description)~="string" then error("UI_Element_GetSetDescription: #3 - must be a string when #2==true", 2) end
  
  if is_set==true then
    reagirl.Elements[element_id]["Description"]=description
  end
  return reagirl.Elements[element_id]["Description"]
end

function reagirl.UI_Element_GetSetName(element_id, is_set, name)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSetName</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string name = reagirl.UI_Element_GetSetName(string element_id, boolean is_set, string name)</functioncall>
  <description>
    gets/sets the name of the ui-element
  </description>
  <retvals>
    string name - the name of the ui-element
  </retvals>
  <parameters>
    string element_id - the id of the element, whose name you want to get/set
    boolean is_set - true, set the name; false, don't set the name
    string name - the name of the ui-element
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, set, get, name, ui-elements</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_GetSetName: #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_GetSetName: #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetSetName: #1 - no such ui-element", 2) end
  if type(is_set)~="boolean" then error("UI_Element_GetSetName: #2 - must be a boolean", 2) end
  if is_set==true and type(name)~="string" then error("UI_Element_GetSetName: #3 - must be a string when #2==true", 2) end
  
  if is_set==true then
    reagirl.Elements[element_id]["Name"]=name
  end
  return reagirl.Elements[element_id]["Name"]
end

function reagirl.UI_Element_GetSetSticky(element_id, is_set, sticky_x, sticky_y)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSetSticky</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>boolean sticky_x, boolean sticky_y = reagirl.UI_Element_GetSetSticky(string element_id, boolean is_set, boolean sticky_x, boolean sticky_y)</functioncall>
  <description>
    gets/sets the stickyness of the ui-element.
    
    Sticky-elements will not be moved by the global scrollbar-scrolling.
  </description>
  <retvals>
    boolean sticky_x - true, x-movement is sticky; false, x-movement isn't sticky
    boolean sticky_y - true, y-movement is sticky; false, y-movement isn't sticky
  </retvals>
  <parameters>
    string element_id - the id of the element, whose stickiness you want to get/set
    boolean is_set - true, set the name; false, don't set the stickiness
    boolean sticky_x - true, x-movement is sticky; false, x-movement isn't sticky
    boolean sticky_y - true, y-movement is sticky; false, y-movement isn't sticky
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, set, get, sticky, ui-elements</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_GetSetSticky: #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_GetSetSticky: #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetSetSticky: #1 - no such ui-element", 2) end
  if type(is_set)~="boolean" then error("UI_Element_GetSetSticky: #2 - must be a boolean", 2) end
  if type(sticky_x)~="boolean" then error("UI_Element_GetSetSticky: #3 - must be a boolean", 2) end
  if type(sticky_y)~="boolean" then error("UI_Element_GetSetSticky: #4 - must be a boolean", 2) end
  
  if is_set==true then
    reagirl.Elements[element_id]["sticky_x"]=sticky_x
    reagirl.Elements[element_id]["sticky_y"]=sticky_y
  end
  return reagirl.Elements[element_id]["sticky_x"], reagirl.Elements[element_id]["sticky_y"]
end

function reagirl.UI_Element_GetSetAccessibilityHint(element_id, is_set, accessibility_hint)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSetAccessibilityHint</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string accessibility_hint = reagirl.UI_Element_GetSetAccessibilityHint(string element_id, boolean is_set, string accessibility_hint)</functioncall>
  <description>
    gets/sets the accessibility_hint of the ui-element, which will describe, how to use the ui-element to blind persons.
  </description>
  <retvals>
    string accessibility_hint - the accessibility_hint of the ui-element
  </retvals>
  <parameters>
    string element_id - the id of the element, whose accessibility_hint you want to get/set
    boolean is_set - true, set the accessibility_hint; false, don't set the accessibility-hint
    string accessibility_hint - the accessibility_hint of the ui-element
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, set, get, accessibility_hint, ui-elements</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_GetSetAccessibilityHint: #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_GetSetAccessibilityHint: #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetSetAccessibilityHint: #1 - no such ui-element", 2) end
  if type(is_set)~="boolean" then error("UI_Element_GetSetAccessibilityHint: #2 - must be a boolean", 2) end
  if is_set==true and type(accessibility_hint)~="string" then error("UI_Element_GetSetAccessibilityHint: #3 - must be a string when #2==true", 2) end
  
  if is_set==true then
    reagirl.Elements[element_id]["AccHint"]=accessibility_hint
  end
  return reagirl.Elements[element_id]["AccHint"]
end

function reagirl.UI_Element_GetSetPosition(element_id, is_set, x, y)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSetPosition</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>integer x, integer y, integer true_x, integer true_y = reagirl.UI_Element_GetSetPosition(string element_id, boolean is_set, integer x, integer y)</functioncall>
  <description>
    gets/sets the position of the ui-element
  </description>
  <retvals>
    integer x - the x-position of the ui-element
    integer y - the y-position of the ui-element
    integer true_x - the true current x-position resolved to the anchor-position
    integer true_y - the true current y-position resolved to the anchor-position
  </retvals>
  <parameters>
    string element_id - the id of the element, whose position you want to get/set
    boolean is_set - true, set the position; false, don't set the position
    integer x - the x-position of the ui-element
    integer y - the y-position of the ui-element
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, set, get, position, ui-elements</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_GetSetPosition: #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_GetSetPosition: #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetSetPosition: #1 - no such ui-element", 2) end
  if type(is_set)~="boolean" then error("UI_Element_GetSetPosition: #2 - must be a boolean", 2) end
  if is_set==true and math.type(x)~="integer" then error("UI_Element_GetSetPosition: #3 - must be an integer when is_set==true", 2) end
  if is_set==true and math.type(y)~="integer" then error("UI_Element_GetSetPosition: #4 - must be an integer when is_set==true", 2) end
  
  if is_set==true then
    reagirl.Elements[element_id]["x"]=x
    reagirl.Elements[element_id]["y"]=y
  end
  local x2, y2
  if reagirl.Elements[element_id]["x"]<0 then x2=gfx.w+reagirl.Elements[element_id]["x"] else x2=reagirl.Elements[element_id]["x"] end
  if reagirl.Elements[element_id]["y"]<0 then y2=gfx.h+reagirl.Elements[element_id]["y"] else y2=reagirl.Elements[element_id]["y"] end
  
  return reagirl.Elements[element_id]["x"], reagirl.Elements[element_id]["y"], x2, y2
end

function reagirl.UI_Element_GetSetDimension(element_id, is_set, w, h)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSetDimension</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>integer w, integer h, integer true_w, integer true_h = reagirl.UI_Element_GetSetDimension(string element_id, boolean is_set, integer w, integer h)</functioncall>
  <description>
    gets/sets the position of the ui-element
  </description>
  <retvals>
    integer w - the w-size of the ui-element
    integer h - the h-size of the ui-element
    integer true_w - the true current w-size resolved to the anchor-position
    integer true_h - the true current h-size resolved to the anchor-position
  </retvals>
  <parameters>
    string element_id - the id of the element, whose dimension you want to get/set
    boolean is_set - true, set the dimension; false, don't set the dimension
    integer w - the w-size of the ui-element
    integer h - the h-size of the ui-element
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, set, get, dimension, ui-elements</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_GetSetDimension: #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_GetSetDimension: #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetSetDimension: #1 - no such ui-element", 2) end
  if type(is_set)~="boolean" then error("UI_Element_GetSetDimension: #2 - must be a boolean", 2) end
  if is_set==true and math.type(w)~="integer" then error("UI_Element_GetSetDimension: #3 - must be an integer when is_set==true", 2) end
  if is_set==true and math.type(h)~="integer" then error("UI_Element_GetSetDimension: #4 - must be an integer when is_set==true", 2) end
  
  local w2, h2, x2, y2
  if reagirl.Elements[element_id]["x"]<0 then x2=gfx.w+reagirl.Elements[element_id]["x"] else x2=reagirl.Elements[element_id]["x"] end
  if reagirl.Elements[element_id]["y"]<0 then y2=gfx.h+reagirl.Elements[element_id]["y"] else y2=reagirl.Elements[element_id]["y"] end
  if reagirl.Elements[element_id]["w"]<0 then w2=gfx.w-x2+reagirl.Elements[element_id]["w"] else w2=w end
  if reagirl.Elements[element_id]["h"]<0 then h2=gfx.h-y2+reagirl.Elements[element_id]["h"] else h2=h end
  
  if is_set==true then
    reagirl.Elements[element_id]["w"]=w
    reagirl.Elements[element_id]["h"]=h
  end
          
  return reagirl.Elements[element_id]["w"], reagirl.Elements[element_id]["h"], w2, h2
end


function reagirl.UI_Element_GetSetAllHorizontalOffset(is_set, x_offset)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSetAllHorizontalOffset</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>integer x_offset = reagirl.UI_Element_GetSetAllHorizontalOffset(boolean is_set, integer x_offset)</functioncall>
  <description>
    gets/sets the horizontal offset of all non-sticky ui-elements
  </description>
  <retvals>
    integer x_offset - the current horizontal offset of all ui-elements
  </retvals>
  <parameters>
    boolean is_set - true, set the horizontal-offset; false, don't set the horizontal-offset
    integer x_offset - the x-offset of all ui-elements
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, set, get, horizontal offset, ui-elements</tags>
</US_DocBloc>
]]
  if type(is_set)~="boolean" then error("UI_Element_GetSetAllHorizontalOffset: #2 - must be a boolean", 2) end
  if is_set==true and math.type(x_offset)~="integer" then error("UI_Element_GetSetAllHorizontalOffset: #3 - must be an integer when is_set==true", 2) end
  
  if is_set==true then reagirl.MoveItAllRight=x_offset end
  return reagirl.MoveItAllRight
end

function reagirl.UI_Element_GetSetAllVerticalOffset(is_set, y_offset)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSetAllVerticalOffset</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>integer y_offset = reagirl.UI_Element_GetSetAllVerticalOffset(boolean is_set, integer y_offset)</functioncall>
  <description>
    gets/sets the vertical offset of all ui-elements
  </description>
  <retvals>
    integer y_offset - the current vertical offset of all non-sticky ui-elements
  </retvals>
  <parameters>
    boolean is_set - true, set the vertical-offset; false, don't set the vertical-offset
    integer y_offset - the y-offset of all ui-elements
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, set, get, vertical offset, ui-elements</tags>
</US_DocBloc>
]]
  if type(is_set)~="boolean" then error("UI_Element_GetSetAllVerticalOffset: #2 - must be a boolean", 2) end
  if is_set==true and math.type(y_offset)~="integer" then error("UI_Element_GetSetAllVerticalOffset: #3 - must be an integer when is_set==true", 2) end
  
  if is_set==true then reagirl.MoveItAllUp=y_offset end
  return reagirl.MoveItAllUp
end

function reagirl.UI_Element_GetSetRunFunction(element_id, is_set, run_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSetRunFunction</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>func run_function = reagirl.UI_Element_GetSetRunFunction(string element_id, boolean is_set, func run_function)</functioncall>
  <description>
    gets/sets the run_function of the ui-element, which will be run, when the ui-element is toggled
  </description>
  <retvals>
    func run_function - the run_function of the ui-element
  </retvals>
  <parameters>
    string element_id - the id of the element, whose run_function you want to get/set
    boolean is_set - true, set the run_function; false, don't set the name
    func run_function - the run function of the ui-element
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, set, get, run function, ui-elements</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_GetSetRunFunction: #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_GetSetRunFunction: #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetSetRunFunction: #1 - no such ui-element", 2) end
  if type(is_set)~="boolean" then error("UI_Element_GetSetRunFunction: #2 - must be a boolean", 2) end
  if is_set==true and type(run_function)~="function" then error("UI_Element_GetSetRunFunction: #3 - must be a function, when #2==true", 2) end
  
  if is_set==true then
    reagirl.Elements[element_id]["run_function"]=run_function
  end
  return reagirl.Elements[element_id]["run_function"]
end

function reagirl.UI_Element_Move(element_id, x, y, w, h)
  if type(element_id)~="string" then error("UI_Element_Move: #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_Move: #1 - no such ui-element", 2) end
  if x~=nil and math.type(x)~="integer" then error("UI_Element_Move: param #2 - must be an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("UI_Element_Move: param #3 - must be an integer", 2) end
  if w~=nil and math.type(w)~="integer" then error("UI_Element_Move: param #4 - must be an integer", 2) end
  if h~=nil and math.type(h)~="integer" then error("UI_Element_Move: param #5 - must be an integer", 2) end
  if element_id<1 or element_id>#reagirl.Elements then error("UI_Element_Move: param #1 - no such UI-element", 2) end
  if x~=nil then reagirl.Elements[element_id]["x"]=x end
  if y~=nil then reagirl.Elements[element_id]["y"]=y end
  if w~=nil then reagirl.Elements[element_id]["w"]=w end
  if h~=nil then reagirl.Elements[element_id]["h"]=h end
  if element_id==reagirl.Elements["FocusedElement"] then
    reagirl.oldselection=-1
  end
  reagirl.Gui_ForceRefresh(8)
end

function reagirl.UI_Element_SetSelected(element_id)
  if type(element_id)~="string" then error("UI_Element_SetSelected: #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_SetSelected: #1 - no such ui-element", 2) end
  
  reagirl.Elements["FocusedElement"]=element_id
  reagirl.Gui_ForceRefresh(9)
end

function reagirl.UI_Element_Remove(element_id)
  if type(element_id)~="string" then error("UI_Element_SetSelected: #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_SetSelected: #1 - no such ui-element", 2) end
  table.remove(reagirl.Elements, element_id)
  if element_id<=reagirl.Elements["FocusedElement"] then
    reagirl.Elements["FocusedElement"]=reagirl.Elements["FocusedElement"]-1
  end
  if reagirl.Elements["FocusedElement"]>#reagirl.Elements then
    reagirl.Elements["FocusedElement"]=#reagirl.Elements
  end
  if reagirl.Elements["FocusedElement"]>0 then 
    reagirl.UI_Element_SetFocusRect(true, 
                                    reagirl.Elements[reagirl.Elements["FocusedElement"]]["x"], 
                                    reagirl.Elements[reagirl.Elements["FocusedElement"]]["y"], 
                                    reagirl.Elements[reagirl.Elements["FocusedElement"]]["w"], 
                                    reagirl.Elements[reagirl.Elements["FocusedElement"]]["h"]
                                    )
  end
  reagirl.Gui_ForceRefresh(10)
end

function reagirl.UI_Element_GetIDFromGuid(guid)
  if type(guid)~="string" then error("UI_Element_GetIDFromGuid: param #1 - must be a string", 2) end
  if guid:match("{........%-....%-....%-....%-............}")==nil then error("UI_Element_GetIDFromGuid: param #1 - must be a valid guid", 2) end
  for i=1, #reagirl.Elements do
    if guid==reagirl.Elements[i]["Guid"] then return i end
  end
  return -1
end

function reagirl.UI_Element_GetGuidFromID(id)
  if math.type(id)~="integer" then error("UI_Element_GetGuidFromID: param #1 - must be an integer", 2) end
  if id>#reagirl.Elements-4 then
    return reagirl.Elements[id]["Guid"]
  else
    error("UI_Element_GetGuidFromID: param #1 - no such ui-element", 2)
  end
end

function reagirl.AddDummyElement()  
  reagirl.Elements[#reagirl.Elements+1]={}
  reagirl.Elements[#reagirl.Elements]["Guid"]=reaper.genGuid("")
  reagirl.Elements[#reagirl.Elements]["GUI_Element_Type"]="Dummy"
  reagirl.Elements[#reagirl.Elements]["Name"]="Dummy"
  reagirl.Elements[#reagirl.Elements]["Text"]="Dummy"
  reagirl.Elements[#reagirl.Elements]["Description"]="Description"
  reagirl.Elements[#reagirl.Elements]["AccHint"]="Dummy Dummy Dummy, it's so flummy. In a rich mans world."
  reagirl.Elements[#reagirl.Elements]["x"]=math.random(140)
  reagirl.Elements[#reagirl.Elements]["y"]=math.random(140)
  reagirl.Elements[#reagirl.Elements]["w"]=math.random(40)
  reagirl.Elements[#reagirl.Elements]["h"]=math.random(40)
  reagirl.Elements[#reagirl.Elements]["func_manage"]=reagirl.ManageDummyElement
  reagirl.Elements[#reagirl.Elements]["func_draw"]=reagirl.DrawDummyElement
  
  return #reagirl.Elements
end

function reagirl.ManageDummyElement(element_id, selected, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF)
    if selected==true then
      if Key==1919379572.0 then
        --print2("")
        local x,y,w,h
        x,y,w,h=reagirl.UI_Element_GetFocusRect()
        reagirl.UI_Element_SetFocusRect(true, x+10,y,-10,-10)
      elseif Key==1818584692.0 then
        local x,y,w,h
        x,y,w,h=reagirl.UI_Element_GetFocusRect()
        reagirl.UI_Element_SetFocusRect(true, x-10,y,-10,-10)
      end
    end
  return "", true
end

function reagirl.DrawDummyElement(element_id, selected, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF)
  -- no docs in API-docs
  local message
  gfx.set(1)
  --gfx.rect(x,y,w,h,1)
  
  if selected==true then
    gfx.set(0.5)
    --gfx.rect(x,y,w,h,0)
    --reagirl.UI_Element_SetFocusRect(true, 10, 10, 20, 50)
    if selected==true then
      message="Dummy Element "..description.." focused"..element_id
      C=clicked
    else
      --message=""
    end
    if mouse_cap==1 and clicked==true then
      message="Dummy Element "..description.." clicked"..element_id
      
    elseif mouse_cap==2 and clicked==true then
      gfx.showmenu("Huch|Tuch|Much")
      --message=""
    end
  end
  
  if Key~=0 then message=Key_Utf end

  gfx.x=x
  gfx.y=y
  gfx.set(0)
  gfx.drawstr(element_id)
  
  return "HUCH", true
end

function reagirl.CheckBox_Add(x, y, caption, meaningOfUI_Element, default, run_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CheckBox_Add</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string checkbox_guid = reagirl.CheckBox_Add(integer x, integer y, integer w_margin, integer h_margin, string caption, string meaningOfUI_Element, function run_function)</functioncall>
  <description>
    Adds a checkbox to a gui.
    
    You can autoposition the checkbox by setting x and/or y to nil, which will position the new checkbox after the last ui-element.
    To autoposition into the next line, use reagirl.NextLine()
  </description>
  <parameters>
    optional integer x - the x position of the checkbox in pixels; negative anchors the checkbox to the right window-side; nil, autoposition after the last ui-element(see description)
    optional integer y - the y position of the checkbox in pixels; negative anchors the checkbox to the bottom window-side; nil, autoposition after the last ui-element(see description)
    string caption - the caption of the checkbox
    string meaningOfUI_Element - a description for accessibility users
    boolean default - true, set the checkbox checked; false, set the checkbox unchecked
    function run_function - a function that shall be run when the checkbox is clicked; will get passed over the checkbox-element_id as first and the new checkstate as second parameter
  </parameters>
  <retvals>
    string checkbox_guid - a guid that can be used for altering the checkbox-attributes
  </retvals>
  <chapter_context>
    Checkbox
  </chapter_context>
  <tags>checkbox, add</tags>
</US_DocBloc>
--]]
  if x~=nil and math.type(x)~="integer" then error("CheckBox_Add: param #1 - must be an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("CheckBox_Add: param #2 - must be an integer", 2) end
  if type(caption)~="string" then error("CheckBox_Add: param #3 - must be a string", 2) end
  if type(meaningOfUI_Element)~="string" then error("CheckBox_Add: param #4 - must be a string", 2) end
  if type(default)~="boolean" then error("CheckBox_Add: param #5 - must be a boolean", 2) end
  if run_function~=nil and type(run_function)~="function" then error("CheckBox_Add: param #6 - must be either nil or a function", 2) end
  
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  if x==nil then 
    x=reagirl.UI_Element_NextX_Default
    if slot-1==0 or reagirl.UI_Element_NextLineY>0 then
      x=reagirl.UI_Element_NextLineX
    elseif slot-1>0 then
      x=reagirl.Elements[slot-1]["x"]+reagirl.Elements[slot-1]["w"]+10
      for i=slot-1, 1, -1 do
        if reagirl.Elements[i]["IsDecorative"]==false then
          local w2=reagirl.Elements[i]["w"]
          --print2(reagirl.Elements[i]["h"], w2)
          x=reagirl.Elements[i]["x"]+w2+reagirl.UI_Element_NextX_Margin
          break
        end
      end
    end
  end
  
  if y==nil then 
    y=reagirl.UI_Element_NextY_Default
    if slot-1>0 then
      y=reagirl.Elements[slot-1]["y"]+reagirl.UI_Element_NextLineY
      reagirl.UI_Element_NextLineY=0
    end
  end  
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0, 1)
  local tx,ty=gfx.measurestr(caption)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  table.insert(reagirl.Elements, slot, {})
  reagirl.Elements[slot]["Guid"]=reaper.genGuid("")
  reagirl.Elements[slot]["GUI_Element_Type"]="Checkbox"
  reagirl.Elements[slot]["Name"]=caption
  reagirl.Elements[slot]["Text"]=caption
  reagirl.Elements[slot]["IsDecorative"]=false
  reagirl.Elements[slot]["Description"]=meaningOfUI_Element
  reagirl.Elements[slot]["AccHint"]="Change checkstate with space or left mouse-click."
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["w"]=math.tointeger(ty+tx+4)+6
  reagirl.Elements[slot]["h"]=math.tointeger(ty)+5
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false
  reagirl.Elements[slot]["top_edge"]=true
  reagirl.Elements[slot]["bottom_edge"]=true
  reagirl.Elements[slot]["checked"]=default
  reagirl.Elements[slot]["func_manage"]=reagirl.Checkbox_Manage
  reagirl.Elements[slot]["func_draw"]=reagirl.CheckBox_Draw
  reagirl.Elements[slot]["run_function"]=run_function
  reagirl.Elements[slot]["userspace"]={}
  return reagirl.Elements[slot]["Guid"]
end

function reagirl.Checkbox_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  local refresh=false

  if selected==true and ((clicked=="FirstCLK" and mouse_cap&1==1) or Key==32) then 
    if (gfx.mouse_x>=x 
      and gfx.mouse_x<=x+w 
      and gfx.mouse_y>=y 
      and gfx.mouse_y<=y+h) 
      or Key==32 then
      if reagirl.Elements[element_id]["checked"]==true then 
        reagirl.Elements[element_id]["checked"]=false 
        if element_storage["run_function"]~=nil then element_storage["run_function"](element_storage["Guid"], reagirl.Elements[element_id]["checked"]) end
        refresh=true
      else 
        reagirl.Elements[element_id]["checked"]=true 
        if element_storage["run_function"]~=nil then element_storage["run_function"](element_storage["Guid"], reagirl.Elements[element_id]["checked"]) end
        refresh=true
      end
    end
  end
  if refresh==true then reagirl.Gui_ForceRefresh() end
  if reagirl.Elements[element_id]["checked"]==true then
    return "checked. ", refresh
  else
    return " not checked. ", refresh
  end
end

function reagirl.Checkbox_SetTopBottom(element_id, top, bottom)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Checkbox_SetTopBottom</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Checkbox_SetTopBottom(string element_id, boolean state)</functioncall>
  <description>
    Sets a checkbox's top and bottom edges.
  </description>
  <parameters>
    string element_id - the guid of the checkbox, whose rounded edges-state you want to set
    boolean top - true, the top of the checkbox is rounded; false, top of the checkbox is square.
    boolean bottom - true, the bottom of the checkbox is square; false, bottom of the checkbox is rounded.
  </parameters>
  <chapter_context>
    Checkbox
  </chapter_context>
  <tags>checkbox, set, rounded edges, top, bottom</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Checkbox_SetTopBottom: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Checkbox_SetTopBottom: param #1 - must be a valid guid", 2) end
  if type(top)~="boolean" then error("Checkbox_SetTopBottom: param #2 - must be a boolean", 2) end
  if type(bottom)~="boolean" then error("Checkbox_SetTopBottom: param #3 - must be a boolean", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Checkbox_SetTopBottom: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Checkbox" then
    error("Checkbox_SetTopBottom: param #1 - ui-element is not a checkbox", 2)
  else
    reagirl.Elements[element_id]["bottom_edge"]=bottom
    reagirl.Elements[element_id]["top_edge"]=top
    reagirl.Gui_ForceRefresh()
  end
end

function reagirl.Checkbox_GetTopBottom(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Checkbox_GetTopBottom</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>boolean top, boolean bottom = reagirl.Checkbox_GetTopBottom(string element_id)</functioncall>
  <description>
    Gets a checkbox's rounded edges state.
  </description>
  <parameters>
    string element_id - the guid of the checkbox, whose rounded edges-state you want to get
  </parameters>
  <retvals>
    boolean top - true, the top of the checkbox is rounded; false, top of the checkbox is square.
    boolean bottom - true, the bottom of the checkbox is square; false, bottom of the checkbox is rounded.
  </retvals>
  <chapter_context>
    Checkbox
  </chapter_context>
  <tags>checkbox, get, rounded edges, top, bottom</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Checkbox_GetTopBottom: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Checkbox_GetTopBottom: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Checkbox" then
    error("Checkbox_GetTopBottom: param #1 - ui-element is not a checkbox", 2)
  else
    return reagirl.Elements[element_id]["top_edge"], reagirl.Elements[element_id]["bottom_edge"]
  end
end

function reagirl.Checkbox_SetDisabled(element_id, state)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Checkbox_SetDisabled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Checkbox_SetDisabled(string element_id, boolean state)</functioncall>
  <description>
    Sets a checkbox as disabled(non clickable).
  </description>
  <parameters>
    string element_id - the guid of the checkbox, whose disability-state you want to set
    boolean state - true, the checkbox is disabled; false, the checkbox is not disabled.
  </parameters>
  <chapter_context>
    Checkbox
  </chapter_context>
  <tags>checkbox, set, disabled</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Checkbox_SetDisabled: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Checkbox_SetDisabled: param #1 - must be a valid guid", 2) end
  if type(state)~="boolean" then error("Checkbox_SetDisabled: param #2 - must be a boolean", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Checkbox_SetDisabled: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Checkbox" then
    error("Checkbox_SetDisabled: param #1 - ui-element is not a checkbox", 2)
  else
    reagirl.Elements[element_id]["IsDecorative"]=state
    reagirl.Gui_ForceRefresh()
  end
end

function reagirl.Checkbox_GetDisabled(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Checkbox_GetDisabled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>boolean retval = reagirl.Checkbox_GetDisabled(string element_id)</functioncall>
  <description>
    Gets a checkbox's disabled(non clickable)-state.
  </description>
  <parameters>
    string element_id - the guid of the checkbox, whose disability-state you want to get
  </parameters>
  <retvals>
    boolean state - true, the checkbox is disabled; false, the checkbox is not disabled.
  </retvals>
  <chapter_context>
    Checkbox
  </chapter_context>
  <tags>checkbox, get, disabled</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Checkbox_GetDisabled: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Checkbox_GetDisabled: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Checkbox" then
    error("Checkbox_GetDisabled: param #1 - ui-element is not a checkbox", 2)
  else
    return reagirl.Elements[element_id]["IsDecorative"]
  end
end

function reagirl.CheckBox_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size-1, 0)
  gfx.x=x
  gfx.y=y
  h=h-5
  local scale=reagirl.Window_CurrentScale
  
  local top=element_storage["top_edge"]
  local bottom=element_storage["bottom_edge"]
  gfx.set(0.584)
  reagirl.RoundRect(x,y,h+2,h+2,5*scale, 1,1, top, bottom, true, true)
  
  gfx.set(0.2725490196078431)
  reagirl.RoundRect(x+scale,y+scale,h+2-scale*2,h+2-scale*2,5*scale, 0,1, top, bottom, true, true)
  
  if reagirl.Elements[element_id]["checked"]==true then
    if element_storage["IsDecorative"]==false then
      gfx.set(0.9843137254901961, 0.8156862745098039, 0)
    else
      gfx.set(0.5843137254901961)
    end
    reagirl.RoundRect(x+1+(scale)*3, y+1+scale*3, h-scale*6, h-scale*6, 3*scale, 1, 1, top, bottom, true, true)
  end
  
  if scale==1 then offset=0
  elseif scale==2 then offset=2
  elseif scale==3 then offset=5
  elseif scale==4 then offset=8
  elseif scale==5 then offset=11
  elseif scale==6 then offset=14
  elseif scale==7 then offset=17
  elseif scale==8 then offset=20
  end
  
  gfx.set(0.3)
  gfx.x=x+h+3+6--+12
  gfx.y=y+1+offset
  gfx.drawstr(name)
  if element_storage["IsDecorative"]==false then
    gfx.set(0.8)
  else
    gfx.set(0.6)
  end
  gfx.x=x+h+2+6--+12
  gfx.y=y+2+offset
  gfx.drawstr(name)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
end

function reagirl.UI_Element_Next_Position()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_Next_Position</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>integer next_x, integer next_y = reagirl.UI_Element_Next_Position()</functioncall>
  <description>
    Returns the next possible x and y position, for possible auto-positioning.
    
    Only needed, if the autopositioning isn't working for you.
    
    Returns the next x-position to the right of the last added ui-element and the next y-position under the last added ui-element.
  </description>
  <retvals>
    integer next_x - the x-position right of the last added ui-element
    integer next_y - the y-position underneath the last added ui-element
  </retvals>
  <chapter_context>
    UI Elements
  </chapter_context>
  <tags>ui-elements, get, next possible positions</tags>
</US_DocBloc>
--]]
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  local x
  if x==nil then 
    x=reagirl.UI_Element_NextLineX
    if slot-1>0 then
      x=x+reagirl.Elements[slot-1]["x"]+reagirl.Elements[slot-1]["w"]+10
    end
  end
  
  local y
  if y==nil then 
    y=10
    if slot-1>0 then
      y=reagirl.Elements[slot-1]["y"]+reagirl.Elements[slot-1]["h"]+10
    end
  end
  return x,y
end

function reagirl.UI_Element_Current_Position()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_Current_Position</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>integer last_x, integer last_y, integer last_w, integer last_h = reagirl.UI_Element_Current_Position()</functioncall>
  <description>
    Returns the x and y position as well as width and height of the last added ui-element.
  </description>
  <retvals>
    integer last_x - the x-position of the last added ui-element
    integer last_y - the y-position of the last added ui-element
    integer last_w - the width of the last added ui-element
    integer last_h - the height of the last added ui-element
  </retvals>
  <chapter_context>
    UI Elements
  </chapter_context>
  <tags>ui-elements, get, last position, width, height</tags>
</US_DocBloc>
--]]
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  local x
  x=reagirl.UI_Element_NextX_Default
  if slot-1>0 then
    x=x+reagirl.Elements[slot-1]["x"]
  end
  
  local y
  y=reagirl.UI_Element_NextY_Default
  if slot-1>0 then
    y=reagirl.Elements[slot-1]["y"]
  end
  
  local w, h
  w=0
  h=0
  if slot-1>0 then
    w=reagirl.Elements[slot-1]["w"]
    h=reagirl.Elements[slot-1]["h"]
  end
  return x,y
end

function reagirl.NextLine()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>NextLine</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.NextLine()</functioncall>
  <description>
    Starts a new line, when autopositioning ui-elements using the add-functions
  </description>
  <chapter_context>
    UI Elements
  </chapter_context>
  <tags>ui-elements, set, next line</tags>
</US_DocBloc>
--]]
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  if reagirl.UI_Element_NextLineY==0 then
    for i=slot-1, 1, -1 do
      if reagirl.Elements[i]["IsDecorative"]==false then
        --print2(reagirl.Elements[i]["h"])
        --reagirl.UI_Element_NextLineY=reagirl.UI_Element_NextLineY+reagirl.Elements[i]["h"]+1
        local x2, y2, w2, h2
        if reagirl.Elements[i]["y"]<0 then y2=gfx.h+(reagirl.Elements[i]["y"]) else y2=reagirl.Elements[i]["y"] end
        if reagirl.Elements[i]["h"]<0 then h2=gfx.h+(-y2+reagirl.Elements[i]["h"]) else h2=reagirl.Elements[i]["h"] end
        reagirl.UI_Element_NextLineY=reagirl.UI_Element_NextLineY+h2+1+reagirl.UI_Element_NextY_Margin
        break
      end
    end
  else
    reagirl.UI_Element_NextLineY=reagirl.UI_Element_NextLineY+reagirl.UI_Element_NextY_Margin
  end
  reagirl.UI_Element_NextLineX=reagirl.UI_Element_NextX_Default
end

function reagirl.Button_Add(x, y, w_margin, h_margin, caption, meaningOfUI_Element, run_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Button_Add</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string button_guid = reagirl.Button_Add(optional integer x, optional integer y, integer w_margin, integer h_margin, string caption, string meaningOfUI_Element, function run_function)</functioncall>
  <description>
    Adds a button to a gui.
    
    You can autoposition the button by setting x and/or y to nil, which will position the new button after the last ui-element.
    To autoposition into the next line, use reagirl.NextLine()
  </description>
  <parameters>
    optional integer x - the x position of the button in pixels; negative anchors the button to the right window-side; nil, autoposition after the last ui-element(see description)
    optional integer y - the y position of the button in pixels; negative anchors the button to the bottom window-side; nil, autoposition after the last ui-element(see description)
    integer w_margin - a margin left and right of the text
    integer h_margin - a margin top and bottom of the text
    string caption - the caption of the button
    string meaningOfUI_Element - a description for accessibility users
    function run_function - a function that shall be run when the button is clicked; will get the button-element_id passed over as first parameter
  </parameters>
  <retvals>
    string button_guid - a guid that can be used for altering the button-attributes
  </retvals>
  <chapter_context>
    Button
  </chapter_context>
  <tags>button, add</tags>
</US_DocBloc>
--]]
  if x~=nil and math.type(x)~="integer" then error("Button_Add: param #1 - must be an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("Button_Add: param #2 - must be an integer", 2) end
  if math.type(w_margin)~="integer" then error("Button_Add: param #3 - must be an integer", 2) end
  if math.type(h_margin)~="integer" then error("Button_Add: param #4 - must be an integer", 2) end
  if type(caption)~="string" then error("Button_Add: param #5 - must be a string", 2) end
  if type(meaningOfUI_Element)~="string" then error("Button_Add: param #6 - must be a string", 2) end
  if run_function~=nil and type(run_function)~="function" then error("Button_Add: param #7 - must be either nil or a function", 2) end
  
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  if x==nil then 
    x=reagirl.UI_Element_NextX_Default
    if slot-1==0 or reagirl.UI_Element_NextLineY>0 then
      x=reagirl.UI_Element_NextLineX
    elseif slot-1>0 then
      for i=slot-1, 1, -1 do
        if reagirl.Elements[i]["IsDecorative"]==false then
          x=reagirl.Elements[i]["x"]+reagirl.Elements[i]["w"]+reagirl.UI_Element_NextX_Margin
          break
        end
      end
    end
  end
  
  if y==nil then 
    y=reagirl.UI_Element_NextY_Default
    if slot-1>0 then
      y=reagirl.Elements[slot-1]["y"]+reagirl.UI_Element_NextLineY
      reagirl.UI_Element_NextLineY=0
    end
  end  
  
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0, 1)
  local tx,ty=gfx.measurestr(caption)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  
  table.insert(reagirl.Elements, slot, {})
  reagirl.Elements[slot]["Guid"]=reaper.genGuid("")
  reagirl.Elements[slot]["GUI_Element_Type"]="Button"
  reagirl.Elements[slot]["Name"]=caption
  reagirl.Elements[slot]["Text"]=caption
  reagirl.Elements[slot]["IsDecorative"]=false
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false
  reagirl.Elements[slot]["Description"]=meaningOfUI_Element
  reagirl.Elements[slot]["AccHint"]="click with space or left mouseclick"
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["w"]=math.tointeger(tx+15+w_margin)
  reagirl.Elements[slot]["h"]=math.tointeger(ty+7+h_margin)
  reagirl.Elements[slot]["w_margin"]=w_margin
  reagirl.Elements[slot]["h_margin"]=h_margin
  reagirl.Elements[slot]["radius"]=3
  reagirl.Elements[slot]["func_manage"]=reagirl.Button_Manage
  reagirl.Elements[slot]["func_draw"]=reagirl.Button_Draw
  reagirl.Elements[slot]["run_function"]=run_function
  reagirl.Elements[slot]["userspace"]={}
  return reagirl.Elements[slot]["Guid"]
end

function reagirl.Button_SetDisabled(element_id, state)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Button_SetDisabled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Button_SetDisabled(string element_id, boolean state)</functioncall>
  <description>
    Sets a button as disabled(non clickable).
  </description>
  <parameters>
    string element_id - the guid of the button, whose disability-state you want to set
    boolean state - true, the button is disabled; false, the button is not disabled.
  </parameters>
  <chapter_context>
    Button
  </chapter_context>
  <tags>button, set, disabled</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Button_SetDisabled: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Button_SetDisabled: param #1 - must be a valid guid", 2) end
  if type(state)~="boolean" then error("Button_SetDisabled: param #2 - must be a boolean", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Button_SetDisabled: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Button" then
    error("Button_SetDisabled: param #1 - ui-element is not a button", 2)
  else
    reagirl.Elements[element_id]["IsDecorative"]=state
    reagirl.Gui_ForceRefresh()
  end
end

function reagirl.Button_GetDisabled(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Button_GetDisabled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>boolean retval = reagirl.Button_GetDisabled(string element_id)</functioncall>
  <description>
    Gets a button's disabled(non clickable)-state.
  </description>
  <parameters>
    string element_id - the guid of the button, whose disability-state you want to get
  </parameters>
  <retvals>
    boolean state - true, the button is disabled; false, the button is not disabled.
  </retvals>
  <chapter_context>
    Button
  </chapter_context>
  <tags>button, get, disabled</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Button_GetDisabled: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Button_GetDisabled: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Button" then
    error("Button_GetDisabled: param #1 - ui-element is not a button", 2)
  else
    return reagirl.Elements[element_id]["IsDecorative"]
  end
end

function reagirl.Button_GetRadius(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Button_GetRadius</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>integer radius = reagirl.Button_GetRadius(string element_id)</functioncall>
  <description>
    Gets a button's radius.
  </description>
  <parameters>
    string element_id - the guid of the button, whose radius you want to get
  </parameters>
  <retvals>
    integer radius - the radius of the button
  </retvals>
  <chapter_context>
    Button
  </chapter_context>
  <tags>button, get, radius</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Button_GetRadius: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Button_GetRadius: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Button" then
    error("Button_GetRadius: param #1 - ui-element is not a button", 2)
  else
    return reagirl.Elements[element_id]["radius"]
  end
end

function reagirl.Button_SetRadius(element_id, radius)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Button_SetRadius</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Button_SetRadius(string element_id, integer radius)</functioncall>
  <description>
    Sets the radius of a button.
  </description>
  <parameters>
    string element_id - the guid of the button, whose radius you want to set
    integer radius - between 0 and 10
  </parameters>
  <chapter_context>
    Button
  </chapter_context>
  <tags>button, set, radius</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Button_SetRadius: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Button_GetDisabled: param #1 - must be a valid guid", 2) end
  if math.type(radius)~="integer" then error("Button_SetRadius: param #2 - must be a integer", 2) end
  if radius>10 then 
     radius=10 end
  if radius<0 then radius=0 end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Button_SetRadius: param #1 - no such ui-element", 2) end
  
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Button" then
    return false
  else
    reagirl.Elements[element_id]["radius"]=radius
    reagirl.Gui_ForceRefresh()
  end
  return true
end

function reagirl.Button_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  local message=" "
  if element_storage["old_selected"]~=true and selected==true then 
    message=" "
  end
  element_storage["old_selected"]=selected
  local refresh=false
  local oldpressed=element_storage["pressed"]

  if selected==true and Key==32 then 
    element_storage["pressed"]=true
    message=""
    reagirl.Gui_ForceRefresh(12347)
  elseif selected==true and mouse_cap&1~=0 and gfx.mouse_x>x and gfx.mouse_y>y and gfx.mouse_x<x+w and gfx.mouse_y<y+h then
    local oldstate=element_storage["pressed"]
    element_storage["pressed"]=true
    if oldstate~=element_storage["pressed"] then
      reagirl.Gui_ForceRefresh(12346)
    end
    message=""
  else
    local oldstate=element_storage["pressed"]
    element_storage["pressed"]=false
    if oldstate~=element_storage["pressed"] then
      reagirl.Gui_ForceRefresh(12345)
    end
  end
  if oldpressed==true and element_storage["pressed"]==false and (mouse_cap&1==0 and Key~=32) then
    if element_storage["run_function"]~=nil then element_storage["run_function"](element_storage["Guid"]) end
  end

  return message, oldpressed~=element_storage["pressed"]
end

function reagirl.Button_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  x=x+1
  y=y+1
  gfx.x=x
  gfx.y=y
  w=w-5
  h=h-5
  local dpi_scale, state
  local radius = element_storage["radius"]
  reagirl.SetFont(1, "Arial", reagirl.Font_Size-1, 0)
  
  local sw,sh=gfx.measurestr(element_storage["Name"])
  
  local dpi_scale=reagirl.Window_CurrentScale
  if reagirl.Elements[element_id]["pressed"]==true then
    local scale=reagirl.Window_CurrentScale-1
    state=1*dpi_scale-1
    
    offset=math.floor(dpi_scale)
    
    if offset==0 then offset=1 end
    
    gfx.set(0.06) -- background 1
    reagirl.RoundRect((x - 1 + offset)+scale, (y - 1 + offset)+scale, w, h, radius * dpi_scale, 1, 1)
    --reagirl.RoundRect((x+offset)+scale, (y + offset - 2) + scale, w, h, radius * dpi_scale, 1, 1)
    
    gfx.set(0.274) -- background 2
    reagirl.RoundRect((x + offset+1)+scale, (y + offset +1- 1) + scale, w, h, radius * dpi_scale, 1, 1)
    
    gfx.set(0.274) -- button-area
    reagirl.RoundRect((x + 1 + offset) + scale, (y + offset) + scale, w-scale, h, radius * dpi_scale, 1, 1)
    
    if element_storage["IsDecorative"]==false then
      gfx.x=x+(w-sw)/2+1+2+scale
    
      if reaper.GetOS():match("OS")~=nil then offset=1 end
      gfx.y=y+(h-sh)/2+1+offset+scale
      gfx.set(0.784)
      gfx.drawstr(element_storage["Name"])
    end
    reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  else
    local scale=1--reagirl.Window_CurrentScale
    state=0
    
    gfx.set(0.06) -- background 1
    --print_update(x, scale, (x-1)*scale)
    --reagirl.RoundRect((x - 1)*scale, (y - 1)*scale, w, h, radius * dpi_scale, 1, 1)
    --reagirl.RoundRect(x*scale, (y - 2) * scale, w, h, radius * dpi_scale, 1, 1)
    reagirl.RoundRect((x)*scale, (y)*scale, w, h, radius * dpi_scale, 1, 1)
    
    
    gfx.set(0.39) -- background 2
    reagirl.RoundRect(x*scale, (y - 1) * scale, w, h, radius * dpi_scale, 1, 1)
    
    gfx.set(0.274) -- button-area
    reagirl.RoundRect((x + 1) * scale, (y) * scale, w-scale, h-1, radius * dpi_scale, 1, 1)
    
    local offset=0
    if element_storage["IsDecorative"]==false then
      gfx.x=x+(w-sw)/2+1
      if reaper.GetOS():match("OS")~=nil then offset=1 end
      --gfx.y=(y*scale)+(h-element_storage["h"])/2+offset
      gfx.y=y+(h-sh)/2+offset
      gfx.set(0.784)
      gfx.drawstr(element_storage["Name"])
    else
      if reaper.GetOS():match("OS")~=nil then offset=1 end
      
      gfx.x=x+(w-sw)/2+1
      gfx.y=y+(h-sh)/2+1+offset-1
      gfx.set(0.39)
      gfx.drawstr(element_storage["Name"])
      
      gfx.x=x+(w-sw)/2+1
      gfx.y=y+(h-sh)/2+1+offset
      gfx.set(0.06)
      gfx.drawstr(element_storage["Name"])
    end
  end
  gfx.set(0.3)
  gfx.x=x+h+3
  gfx.y=y+1
  --gfx.drawstr(name)
  gfx.set(1)
  gfx.x=x+h+2
  gfx.y=y
  --gfx.drawstr(name)
end
--gfx.setfont(



function reagirl.InputBox_Add(x, y, w, Name, MeaningOfUI_Element, Default, run_function_enter, run_function_type)
  local tx,ty=gfx.measurestr(Name)
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  table.insert(reagirl.Elements, slot, {})
  reagirl.Elements[slot]["Guid"]=reaper.genGuid("")
  reagirl.Elements[slot]["GUI_Element_Type"]="Edit"
  reagirl.Elements[slot]["Name"]=""
  reagirl.Elements[slot]["Label"]=Name
  reagirl.Elements[slot]["Description"]=MeaningOfUI_Element
  reagirl.Elements[slot]["IsDecorative"]=false
  reagirl.Elements[slot]["AccHint"]="Hit Enter to type text."
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["w"]=w
  reagirl.Elements[slot]["h"]=math.tointeger(gfx.texth)
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false
  reagirl.Elements[slot]["Text"]=Default
  reagirl.Elements[slot]["draw_range_max"]=10
  reagirl.Elements[slot]["draw_offset"]=0
  reagirl.Elements[slot]["cursor_offset"]=0
  reagirl.Elements[slot]["selection_start"]=1
  reagirl.Elements[slot]["selection_end"]=1
  
  reagirl.Elements[slot]["func_manage"]=reagirl.InputBox_Manage
  reagirl.Elements[slot]["func_draw"]=reagirl.InputBox_Draw
  reagirl.Elements[slot]["run_function"]=run_function_enter
  reagirl.Elements[slot]["run_function_type"]=run_function_type
  reagirl.Elements[slot]["userspace"]={}
  return reagirl.Elements[slot]["Guid"]
end

function reagirl.InputBox_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if (selected==true and Key==13) or (gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h and clicked=="FirstCLK") then
    retval, text = reaper.GetUserInputs(element_storage["Name"].." Enter new value", 1, "", element_storage["Text"])
    if retval==true then element_storage["Text"]=text end
    reagirl.Gui_ForceRefresh(11)
  end
  return element_storage["Text"]
end

function reagirl.InputBox_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  -- Testcode
  --gfx.setfont(1,"Calibri", 20)
  --gfx.setfont(1,"Consolas", 20)
  reagirl.SetFont(2, "Consolas", reagirl.Font_Size, 0)
  --reagirl.Elements[element_id]["Text"]
  local cursor_offset=element_storage["cursor_offset"]
  local draw_offset=element_storage["draw_offset"]
  local draw_range_max=element_storage["draw_range_max"]
  local selection_start=element_storage["selection_start"]
  local selection_end=element_storage["selection_end"]
  gfx.x=x
  gfx.y=y
  --
  -- rectangle-stuff
  gfx.set(0.2)
  gfx.rect(x-2,y-3,gfx.measurechar(65)*(element_storage["draw_range_max"]+1)+4, gfx.texth+6, 1)
  gfx.set(0.6)
  gfx.rect(x-2,y-3,gfx.measurechar(65)*(element_storage["draw_range_max"]+1)+4, gfx.texth+6, 0)
  gfx.set(1)
  gfx.rect(x-1,y-2,gfx.measurechar(65)*(element_storage["draw_range_max"]+1)+4, gfx.texth+6, 0)
  --]]
  
  if draw_offset+1<0 then draw_offset=1 end
  if cursor_offset==draw_offset then
    --gfx.line(gfx.x, gfx.y, gfx.x, gfx.y+gfx.texth)
  end
  
  --CAPO=0
  if draw_offset<=0 then draw_offset=0 end
  for i=draw_offset, draw_range_max+draw_offset+2 do
  --CAPO=CAPO+1
    --print(element_storage["Text"]:utf8_sub(i,i))
    if i>=selection_start+1 and i<=selection_end then
      --gfx.setfont(1, "Consolas", 20, 86) 
      reagirl.SetFont(2, "Consolas", reagirl.Font_Size, 86)
    elseif selection_start~=selection_end and i==selection_end+1 then 
      --gfx.setfont(1, "Consolas", 20, 0) 
      reagirl.SetFont(2, "Consolas", reagirl.Font_Size, 0)
    end
    gfx.drawstr(element_storage["Text"]:utf8_sub(i,i))
    --CAP_STRING=CAP_STRING..element_storage["Text"]:utf8_sub(i,i)
    if cursor_offset==i then
      gfx.set(0.6)
      gfx.line(gfx.x, gfx.y, gfx.x, gfx.y+gfx.texth)
      if reaper.osara_outputMessage==nil then
        gfx.set(1)
        gfx.line(gfx.x+1, gfx.y+1, gfx.x+1, gfx.y+1+gfx.texth)
      end
    end
  end
  --reagirl.SetFont(1, "Arial", 16, 0)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
end

function reagirl.DropDownMenu_Add(x, y, w, caption, meaningOfUI_Element, menuItems, menuSelectedItem, run_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DropDownMenu_Add</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string dropdown-menu_guid = reagirl.DropDownMenu_Add(optional integer x, optional integer y, integer w, string caption, string meaningOfUI_Element, table menuItems, integer menuSelectedItem, function run_function)</functioncall>
  <description>
    Adds a dropdown-menu to a gui.
    
    You can autoposition the dropdown-menu by setting x and/or y to nil, which will position the new dropdown-menu after the last ui-element.
    To autoposition into the next line, use reagirl.NextLine()
  </description>
  <parameters>
    optional integer x - the x position of the dropdown-menu in pixels; negative anchors the dropdown-menu to the right window-side; nil, autoposition after the last ui-element(see description)
    optional integer y - the y position of the dropdown-menu in pixels; negative anchors the dropdown-menu to the bottom window-side; nil, autoposition after the last ui-element(see description)
    integer w - the width of the dropdown-menu; negative links width to the right-edge of the window
    string caption - the name of the dropdown-menu
    string meaningOfUI_Element - a description for accessibility users
    table menuItems - a table, where every entry is a menu-item
    integer menuSelectedItem - the index of the pre-selected menu-item
    function run_function - a function that shall be run when the menu is clicked/a new entry is selected; will get the dropdown-menu-element_id passed over as first parameter
  </parameters>
  <retvals>
    string dropdown-menu_guid - a guid that can be used for altering the dropdown-menu-attributes
  </retvals>
  <chapter_context>
    DropDown Menu
  </chapter_context>
  <tags>dropdown menu, add</tags>
</US_DocBloc>
--]]
  if x~=nil and math.type(x)~="integer" then error("DropDownMenu_Add: param #1 - must be an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("DropDownMenu_Add: param #2 - must be an integer", 2) end
  if math.type(w)~="integer" then error("DropDownMenu_Add: param #3 - must be an integer", 2) end
  if type(caption)~="string" then error("DropDownMenu_Add: param #4 - must be a string", 2) end
  if type(meaningOfUI_Element)~="string" then error("DropDownMenu_Add: param #5 - must be a string", 2) end
  if type(menuItems)~="table" then error("DropDownMenu_Add: param #6 - must be a table", 2) end
  for i=1, #menuItems do
    menuItems[i]=tostring(menuItems[i])
  end
  if math.type(menuSelectedItem)~="integer" then error("DropDownMenu_Add: param #7 - must be an integer", 2) end
  if menuSelectedItem>#menuItems or menuSelectedItem<1 then error("DropDownMenu_Add: param #7 - no such menu-item", 2) end
  if run_function~=nil and type(run_function)~="function" then error("DropDownMenu_Add: param #8 - must be either nil or a function", 2) end
  
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  if x==nil then 
    x=reagirl.UI_Element_NextX_Default
    if slot-1==0 or reagirl.UI_Element_NextLineY>0 then
      x=reagirl.UI_Element_NextLineX
    elseif slot-1>0 then
      for i=slot-1, 1, -1 do
        if reagirl.Elements[i]["IsDecorative"]==false then
          x=reagirl.Elements[i]["x"]+reagirl.Elements[i]["w"]+reagirl.UI_Element_NextX_Margin
          break
        end
      end
    end
  end
  
  if y==nil then 
    y=reagirl.UI_Element_NextY_Default
    if slot-1>0 then
      y=reagirl.Elements[slot-1]["y"]+reagirl.UI_Element_NextLineY
      reagirl.UI_Element_NextLineY=0
    end
  end  
  
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0, 1)
  local tx1, ty1 =gfx.measurestr(caption)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  
  table.insert(reagirl.Elements, slot, {})
  reagirl.Elements[slot]["Guid"]=reaper.genGuid("")
  reagirl.Elements[slot]["GUI_Element_Type"]="ComboBox"
  reagirl.Elements[slot]["Name"]=caption
  reagirl.Elements[slot]["Text"]=menuItems[menuSelectedItem]
  reagirl.Elements[slot]["Description"]=meaningOfUI_Element
  reagirl.Elements[slot]["IsDecorative"]=false
  reagirl.Elements[slot]["AccHint"]="Select via arrow-keys."
  reagirl.Elements[slot]["cap_w"]=math.tointeger(tx1)+5
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["w"]=w
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0, 1)
  local tx,ty=gfx.measurestr(menuItems[menuSelectedItem])
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  reagirl.Elements[slot]["h"]=math.tointeger(ty+7)--math.tointeger(gfx.texth)
  reagirl.Elements[slot]["radius"]=3
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false
  reagirl.Elements[slot]["menuSelectedItem"]=menuSelectedItem
  reagirl.Elements[slot]["MenuEntries"]=menuItems
  reagirl.Elements[slot]["MenuCount"]=1
  reagirl.Elements[slot]["MenuCount"]=#menuItems
  reagirl.Elements[slot]["func_manage"]=reagirl.DropDownMenu_Manage
  reagirl.Elements[slot]["func_draw"]=reagirl.DropDownMenu_Draw
  reagirl.Elements[slot]["run_function"]=run_function
  
  reagirl.Elements[slot]["userspace"]={}
  return  reagirl.Elements[slot]["Guid"]
end


function reagirl.DropDownMenu_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  local cap_w=element_storage["cap_w"]*reagirl.Window_GetCurrentScale()
  if w<50 then w=50 end
  local refresh=false
  if gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    reagirl.Scroll_Override_MouseWheel=true
    if reagirl.MoveItAllRight_Delta==0 and reagirl.MoveItAllUp_Delta==0 then
      if mouse_attributes[5]<0 then element_storage["menuSelectedItem"]=element_storage["menuSelectedItem"]+1 refresh=true end
      if mouse_attributes[5]>0 then element_storage["menuSelectedItem"]=element_storage["menuSelectedItem"]-1 refresh=true end
      
      if element_storage["menuSelectedItem"]<1 then element_storage["menuSelectedItem"]=1 refresh=false end
      if element_storage["menuSelectedItem"]>element_storage["MenuCount"] then element_storage["menuSelectedItem"]=element_storage["MenuCount"] refresh=false end
      if refresh==true and element_storage["run_function"]~=nil then reagirl.Elements[element_id]["run_function"](element_storage["Guid"], element_storage["menuSelectedItem"], element_storage["MenuEntries"][element_storage["menuSelectedItem"]]) reagirl.Gui_ForceRefresh() refresh=false end
    end
  end
  local Entries=""
  local collapsed=""
  local Default, insert

  for i=1, #element_storage["MenuEntries"] do
    if i==element_storage["menuSelectedItem"] then insert="!" else insert="" end
    Entries=Entries..insert..element_storage["MenuEntries"][i].."|"
  end
  
  if w<20 then w=20 end
  if selected==true then
    reagirl.Scroll_Override=true
  end
  
  if element_storage["pressed"]==true then
    --if (gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h) or Key==32 or Key==1685026670 or Key==30064 then
      gfx.x=x+cap_w
      gfx.y=y+h--*scale
      local selection=gfx.showmenu(Entries:sub(1,-2))
      --selection=-1
      if selection>0 then
        reagirl.Elements[element_id]["menuSelectedItem"]=math.tointeger(selection)
        reagirl.Elements[element_id]["Text"]=element_storage["MenuEntries"][math.tointeger(selection)]
      end
      refresh=true
      element_storage["pressed"]=false
      --reagirl.Gui_ForceRefresh()
    --end
  end
  if element_storage["selected_old"]~=selected then
    collapsed=""
    element_storage["selected_old"]=selected
  end

  if selected==true then
    if Key==32 or Key==13 then 
      element_storage["pressed"]=true
      collapsed=""
      refresh=true
    elseif Key==1685026670 then
      element_storage["menuSelectedItem"]=element_storage["menuSelectedItem"]+1
      refresh=true
      if element_storage["menuSelectedItem"]>element_storage["MenuCount"] then refresh=false element_storage["menuSelectedItem"]=element_storage["MenuCount"] end
      collapsed=""
      reagirl.Scroll_Override=true
      reagirl.Scroll_Override_MouseWheel=true
    elseif Key==30064 then 
      element_storage["menuSelectedItem"]=element_storage["menuSelectedItem"]-1
      refresh=true
      if element_storage["menuSelectedItem"]<1 then element_storage["menuSelectedItem"]=1 refresh=false end
      collapsed=""
      reagirl.Scroll_Override=true
    elseif Key==1752132965.0 or Key==1885828464.0 then -- home
      if element_storage["menuSelectedItem"]~=1 then
        reagirl.Scroll_Override=true
        element_storage["menuSelectedItem"]=1 
        refresh=true
      end
    elseif Key==6647396.0 or Key==1885824110.0 then -- end
      if element_storage["menuSelectedItem"]~=element_storage["MenuCount"] then
        reagirl.Scroll_Override=true
        element_storage["menuSelectedItem"]=element_storage["MenuCount"] 
        refresh=true
      end
    elseif selected==true and (clicked=="FirstCLK" and mouse_cap&1==1) and (gfx.mouse_x>=x+cap_w and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h) then
      element_storage["pressed"]=true
      collapsed=""
      --refresh=true
    else
      element_storage["pressed"]=false
    end
  end
  
  if refresh==true then 
    reagirl.Gui_ForceRefresh()
    if element_storage["run_function"]~=nil then 
      reagirl.Elements[element_id]["run_function"](element_storage["Guid"], element_storage["menuSelectedItem"], element_storage["MenuEntries"][element_storage["menuSelectedItem"]])
    end
  end
  element_storage["AccHoverMessage"]=element_storage["Name"].." "..element_storage["MenuEntries"][element_storage["menuSelectedItem"]]
  return element_storage["MenuEntries"][element_storage["menuSelectedItem"]]..". "..collapsed, refresh
end

function reagirl.DropDownMenu_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  local cap_w=element_storage["cap_w"]*reagirl.Window_GetCurrentScale()
  if w-cap_w<50 then w=50+cap_w end
  local offset=gfx.measurestr(name.." ")
  gfx.x=x+cap_w
  gfx.y=y
  local menuentry=element_storage["MenuEntries"][element_storage["menuSelectedItem"]]
  
  x=x+1
  y=y+1
  gfx.x=x+cap_w
  gfx.y=y
  w=w-5
  h=h-5
  local dpi_scale, state
  radius=element_storage["radius"]
  reagirl.SetFont(1, "Arial", reagirl.Font_Size-1, 0)
  
  local sw,sh=gfx.measurestr(menuentry)
  local scale=1
  local dpi_scale=reagirl.Window_CurrentScale
  offset=1+math.floor(dpi_scale)
  gfx.x=x
  gfx.y=y+(h-sh)/2+offset-1
  
  if element_storage["IsDecorative"]==true then gfx.set(0.6) else gfx.set(0.8) end
  gfx.drawstr(element_storage["Name"])
  
  if reagirl.Elements[element_id]["pressed"]==true then
    state=1*dpi_scale-1
    if offset==0 then offset=1 end

    gfx.set(0.274) -- background 2
    reagirl.RoundRect(cap_w+(x + offset+1)*scale, (y + offset +1- 1) * scale, w-cap_w, h, radius * dpi_scale, 1, 1)
    
    gfx.set(0.274) -- button-area
    reagirl.RoundRect(cap_w+(x + 1 + offset) * scale, (y + offset) * scale, w-scale-cap_w, h, radius * dpi_scale, 1, 1)
    
    gfx.set(0.39)
    local circ=4
    gfx.circle(x+w+offset-h/2, (y+offset+h)-dpi_scale-h/2, circ*dpi_scale, 1, 0)
    gfx.rect(cap_w+x+w-h+offset+1*(dpi_scale-1), y+offset+2+1*(dpi_scale-2), dpi_scale-cap_w, h-dpi_scale, 1)
    
    if element_storage["IsDecorative"]==false then
      gfx.x=x+7+offset+cap_w
    
      if reaper.GetOS():match("OS")~=nil then offset=1 end
      gfx.y=y+(h-sh)/2+1+offset
      gfx.set(0.784)
      gfx.drawstr(menuentry, 0, x+w-19*dpi_scale, gfx.y+gfx.texth)
    end
    reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  else
    state=0
    
    gfx.set(0.06) -- background 1
    gfx.set(0.06) -- background 1
    reagirl.RoundRect(cap_w+x*scale, (y)*scale, w-cap_w, h, radius * dpi_scale, 1, 1)
    
    gfx.set(0.39) -- background 2
    reagirl.RoundRect(cap_w+x*scale, (y - 1) * scale, w-cap_w, h, radius * dpi_scale, 1, 1)
    
    gfx.set(0.274) -- button-area
    reagirl.RoundRect(cap_w+(x + 1) * scale, (y) * scale, w-scale-cap_w, h-1, radius * dpi_scale, 1, 1)
    
    gfx.set(0.39)
    local circ=4
    gfx.circle(x+w-h/2, (y+h)-dpi_scale-h/2, circ*dpi_scale, 1, 0)
    gfx.rect(x+w-h+1*(dpi_scale-1), y+1+1*(dpi_scale-2), dpi_scale, h-dpi_scale, 1)
    
    local offset=0
    if element_storage["IsDecorative"]==false then
      gfx.x=x+7+offset+cap_w--+(w-sw)/2+1
      if reaper.GetOS():match("OS")~=nil then offset=1 end
      --gfx.y=(y*scale)+(h-element_storage["h"])/2+offset
      gfx.y=y+(h-sh)/2+offset
      gfx.set(0.784)
      gfx.drawstr(menuentry, 0, x+w-21*dpi_scale, gfx.y+gfx.texth)
    else
      if reaper.GetOS():match("OS")~=nil then offset=1 end
      
      gfx.x=x+7+offset+cap_w--+(w-sw)/2+1
      gfx.y=y+(h-sh)/2+1+offset-1
      gfx.set(0.09)
      gfx.drawstr(menuentry,0,x+w-21*dpi_scale, gfx.y+gfx.texth)
      
      gfx.x=x+7+offset+cap_w--+(w-sw)/2+1
      gfx.y=y+(h-sh)/2+offset
      gfx.set(0.55)
      gfx.drawstr(menuentry,0,x+w-21*dpi_scale, gfx.y+gfx.texth)
    end
  end
  gfx.set(0.3)
  gfx.x=x+h+3
  gfx.y=y+1
  --gfx.drawstr(name)
  gfx.set(1)
  gfx.x=x+h+2
  gfx.y=y
  --gfx.drawstr(name)
end

function reagirl.DropDownMenu_SetDisabled(element_id, state)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DropDownMenu_SetDisabled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.DropDownMenu_SetDisabled(string element_id, boolean state)</functioncall>
  <description>
    Sets a droppdown-menu as disabled(non clickable).
  </description>
  <parameters>
    string element_id - the guid of the dropdown-menu, whose disability-state you want to set
    boolean state - true, the dropdown-menu is disabled; false, the dropdown-menu is not disabled.
  </parameters>
  <chapter_context>
    DropDown Menu
  </chapter_context>
  <tags>dropdown menu, set, disabled</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("DropDownMenu_SetDisabled: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("DropDownMenu_SetDisabled: param #1 - must be a valid guid", 2) end
  if type(state)~="boolean" then error("DropDownMenu_SetDisabled: param #2 - must be a boolean", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("DropDownMenu_SetDisabled: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="ComboBox" then
    error("DropDownMenu_SetDisabled: param #1 - ui-element is not a dropdown-menu", 2)
  else
    reagirl.Elements[element_id]["IsDecorative"]=state
    reagirl.Gui_ForceRefresh()
  end
end

function reagirl.DropDownMenu_GetDisabled(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DropDownMenu_GetDisabled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>boolean retval = reagirl.DropDownMenu_GetDisabled(string element_id)</functioncall>
  <description>
    Gets a dropdown-menu's disabled(non clickable)-state.
  </description>
  <parameters>
    string element_id - the guid of the dropdown-menu, whose disability-state you want to get
  </parameters>
  <retvals>
    boolean state - true, the dropdown-menu is disabled; false, the dropdown-menu is not disabled.
  </retvals>
  <chapter_context>
    DropDown Menu
  </chapter_context>
  <tags>dropdown menu, get, disabled</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("DropDownMenu_GetDisabled: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("DropDownMenu_GetDisabled: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="ComboBox" then
    error("DropDownMenu_GetDisabled: param #1 - ui-element is not a dropdown-menu", 2)
  else
    return reagirl.Elements[element_id]["IsDecorative"]
  end
end

function reagirl.DropDownMenu_GetMenuItems(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DropDownMenu_GetMenuItems</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>table menuItems, integer menuSelectedItem = reagirl.DropDownMenu_GetMenuItems(string element_id)</functioncall>
  <description>
    Gets a dropdown-menu's menu-items and the index of the currently selected menu-item.
  </description>
  <parameters>
    string element_id - the guid of the dropdown-menu, whose menuitems/default you want to get
  </parameters>
  <retvals>
    table menuItems - a table that holds all menu-items
    integer menuSelectedItem - the index of the currently selected menu-item
  </retvals>
  <chapter_context>
    DropDown Menu
  </chapter_context>
  <tags>dropdown menu, get, menuitem, menudefault</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("DropDownMenu_GetMenuItems: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("DropDownMenu_GetMenuItems: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="ComboBox" then
    error("DropDownMenu_GetMenuItems: param #1 - ui-element is not a dropdown-menu", 2)
  else
    local newtable={}
    for i=1, #reagirl.Elements[element_id]["MenuEntries"] do
      newtable[i]=reagirl.Elements[element_id]["MenuEntries"][i]
    end
    return newtable, reagirl.Elements[element_id]["menuSelectedItem"]
  end
end

function reagirl.DropDownMenu_SetMenuItems(element_id, menuItems, menuSelectedItem)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DropDownMenu_SetMenuItems</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>table menuItems, integer menuSelectedItem = reagirl.DropDownMenu_SetMenuItems(string element_id)</functioncall>
  <description>
    Gets a dropdown-menu's menuitems and the index of the currently selected menu-item.
  </description>
  <parameters>
    string element_id - the guid of the dropdown-menu, whose menuitems/default you want to get
  </parameters>
  <retvals>
    table menuItems - 
    integer menuSelectedItem - 
  </retvals>
  <chapter_context>
    DropDown Menu
  </chapter_context>
  <tags>dropdown menu, set, menuitem, menudefault</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("DropDownMenu_SetMenuItems: param #1 - must be a string", 2) end
  if type(menuItems)~="table" then error("DropDownMenu_SetMenuItems: param #2 - must be a table", 2) end
  if math.type(menuSelectedItem)~="integer" then error("DropDownMenu_SetMenuItems: param #3 - must be an integer", 2) end
  for i=1, #menuItems do
    menuItems[i]=tostring(menuItems[i])
  end
  if menuSelectedItem>#menuItems or menuSelectedItem<1 then error("DropDownMenu_SetMenuItems: param #3 - no such menu-item", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("DropDownMenu_SetMenuItems: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="ComboBox" then
    error("DropDownMenu_GetDisabled: param #1 - ui-element is not a dropdown-menu", 2)
  else
    reagirl.Elements[element_id]["MenuEntries"]=menuItems
    reagirl.Elements[element_id]["menuSelectedItem"]=menuSelectedItem
    reagirl.Gui_ForceRefresh()
  end
end

function reagirl.Label_SetLabelText(element_id, label)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Label_SetLabelText</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Label_SetLabelText(string element_id, string label)</functioncall>
  <description>
    Sets a new label text to an already existing label.
  </description>
  <parameters>
    string element_id - the id of the element, whose label you want to set
    string label - the new text of the label
  </parameters>
  <chapter_context>
    Label
  </chapter_context>
  <tags>label, set, text</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Label_SetLabelText: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Label_SetLabelText: param #1 - must be a valid guid", 2) end
  if type(label)~="string" then error("Label_SetLabelText: param #2 - must be a boolean", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Label_SetLabelText: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]:sub(-5,-1)~="Label" then
    error("Label_SetLabelText: param #1 - ui-element is not a label", 2)
  else
    local w,h=gfx.measurestr(label)
    reagirl.Elements[element_id]["Name"]=label
    reagirl.Elements[element_id]["w"]=math.tointeger(w)
    reagirl.Elements[element_id]["h"]=math.tointeger(h)--math.tointeger(gfx.texth)
    reagirl.Gui_ForceRefresh()
  end
end

function reagirl.Label_GetLabelText(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Label_GetLabelText</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string label = reagirl.Label_GetLabelText(string element_id)</functioncall>
  <description>
    Gets the label text of a label.
  </description>
  <retvals>
    string label - the new text of the label
  </retvals>
  <parameters>
    string element_id - the id of the element, whose label you want to get
  </parameters>
  <chapter_context>
    Label
  </chapter_context>
  <tags>label, get, text</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Label_GetLabelText: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Label_GetLabelText: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Label_GetLabelText: param #1 - no such ui-element", 2) end
  --print2(reagirl.Elements[element_id]["GUI_Element_Type"]:sub(-7,-1))
  if reagirl.Elements[element_id]["GUI_Element_Type"]:sub(-5,-1)~="Label" then
    error("Label_GetLabelText: param #1 - ui-element is not a label", 2)
  else
    return reagirl.Elements[element_id]["Name"]
  end
end

function reagirl.Label_Add(x, y, label, meaningOfUI_Element, align, clickable, run_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Label_Add</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Label_Add(string label, integer x, integer y, string meaningOfUI_Element, integer align, boolean clickable, function run_function)</functioncall>
  <description>
    Adds a label to the gui.
    
    You can autoposition the label by setting x and/or y to nil, which will position the new label after the last ui-element.
    To autoposition into the next line, use reagirl.NextLine()
  </description>
  <parameters>
    optional integer x - the x position of the label in pixels; negative anchors the label to the right window-side; nil, autoposition after the last ui-element(see description)
    optional integer y - the y position of the label in pixels; negative anchors the label to the bottom window-side; nil, autoposition after the last ui-element(see description)
    string label - the text of the label
    string meaningOfUI_Element - a description of the label for accessibility users
    integer align - 0, not centered or justified
                  - flags&1: center horizontally
                  - flags&2: right justify
                  - flags&4: center vertically
                  - flags&8: bottom justify
    boolean clickable - true, the text is a clickable link-text; false or nil, the label-text is normal text
    function run_function - a function that gets run when clicking the link-text(clickable=true)
  </parameters>
  <chapter_context>
    Label
  </chapter_context>
  <tags>label, add</tags>
</US_DocBloc>
--]]
  if x~=nil and math.type(x)~="integer" then error("Label_Add: param #1 - must be either nil or an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("Label_Add: param #2 - must be either nil or an integer", 2) end
  if type(label)~="string" then error("Label_Add: param #3 - must be a string", 2) end
  if type(meaningOfUI_Element)~="string" then error("Label_Add: param #4 - must be a string", 2) end
  if math.type(align)~="integer" then error("Label_Add: param #5 - must be an integer", 2) end
  if clickable==nil then clickable=false end
  if type(clickable)~="boolean" then error("Label_Add: param #6 - must be wither nil or a boolean", 2) end
  if run_function==nil then run_function=reagirl.Dummy end
  if type(run_function)~="function" then error("Label_Add: param #6 - must be either nil or a function", 2) end
  
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  if x==nil then 
    x=reagirl.UI_Element_NextX_Default
    if slot-1==0 or reagirl.UI_Element_NextLineY>0 then
      x=reagirl.UI_Element_NextLineX
    elseif slot-1>0 then
      x=reagirl.Elements[slot-1]["x"]+reagirl.Elements[slot-1]["w"]+reagirl.UI_Element_NextX_Margin
    end
  end
  
  if y==nil then 
    y=reagirl.UI_Element_NextY_Default
    if slot-1>0 then
      y=reagirl.Elements[slot-1]["y"]+reagirl.UI_Element_NextLineY
      reagirl.UI_Element_NextLineY=0
    end
  end  
  
  local acc_clickable=""
  local clickable_text=""
  if clickable==true then clickable_text="Clickable " acc_clickable="Enter or leftclick to click link. " else acc_clickable="" end
  
  table.insert(reagirl.Elements, slot, {})
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0, 1)
  local w,h=gfx.measurestr(label)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  reagirl.Elements[slot]["Guid"]=reaper.genGuid("")
  reagirl.Elements[slot]["GUI_Element_Type"]=clickable_text.."Label"
  reagirl.Elements[slot]["Name"]=label
  reagirl.Elements[slot]["Text"]=""
  reagirl.Elements[slot]["Description"]=meaningOfUI_Element
  reagirl.Elements[slot]["IsDecorative"]=false
  reagirl.Elements[slot]["AccHint"]=acc_clickable.."Ctrl+C to copy text into clipboard"
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["clickable"]=clickable
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false
  reagirl.Elements[slot]["w"]=math.tointeger(w)+10
  reagirl.Elements[slot]["h"]=math.tointeger(h)--math.tointeger(gfx.texth)
  reagirl.Elements[slot]["align"]=align
  reagirl.Elements[slot]["func_draw"]=reagirl.Label_Draw
  reagirl.Elements[slot]["run_function"]=run_function
  reagirl.Elements[slot]["func_manage"]=reagirl.Label_Manage
  
  return reagirl.Elements[slot]["Guid"]
end

function reagirl.Label_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if Key==3 then reaper.CF_SetClipboard(name) end
  if gfx.mouse_cap&2==2 and selected==true and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    local oldx, oldy=gfx.x, gfx.y
    gfx.x=gfx.mouse_x
    gfx.y=gfx.mouse_y
    --local selection=gfx.showmenu("Copy Text to Clipboard")
    gfx.x=oldx
    gfx.y=oldy
    if selection==1 then reaper.CF_SetClipboard(name) end
  end
  if element_storage["clickable"]==true and (Key==13 or gfx.mouse_cap&1==1) and selected==true and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    if element_storage["run_function"]~=nil then reagirl.Elements[element_id]["run_function"](element_storage["Guid"]) end
  end
  return " ", false
end

function reagirl.Label_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  -- BUG: with multiline-texts, when they scroll outside the top of the window, they disappear when the first line is outside of the window
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  local olddest=gfx.dest
  local oldx, oldy = gfx.x, gfx.y
  local old_gfx_r=gfx.r
  local old_gfx_g=gfx.g
  local old_gfx_b=gfx.b
  local old_gfx_a=gfx.a
  local old_mode=gfx.mode
  gfx.setimgdim(1001, gfx.w, gfx.h)
  gfx.dest=1001
  gfx.set(0)
  gfx.rect(0, 0, gfx.w, gfx.h, 1)
  if element_storage["auto_breaks"]==true then
  --[[
    gfx.set(0.1)
    local retval, w, h = reagirl.BlitText_AdaptLineLength(name, 
                                                          math.floor(x)+1, 
                                                          math.floor(y)+2, 
                                                          gfx.w,
                                                          gfx.h,--gfx.texth,
                                                          element_storage["align"])
    
    gfx.set(1,1,1)
    reagirl.BlitText_AdaptLineLength(name, 
                                     math.floor(x), 
                                     math.floor(y)+1, 
                                     gfx.w,
                                     gfx.h,--gfx.texth,
                                     element_storage["align"])
                                     --]]
  else
    local col=0.6
    local col2=0.6
    if element_storage["clickable"]==true then 
--      reagirl.SetFont(1, "Arial", reagirl.Font_Size, 85)
      col=0.2
      col2=1
    end
    gfx.set(0.1)
    gfx.x=1
    gfx.y=1
    gfx.drawstr(name, element_storage["align"])--, w, h)
    gfx.set(col,col,col2)
    
    gfx.x=0
    gfx.y=0
    gfx.drawstr(name, element_storage["align"])--, w, h)
    reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  end
  gfx.dest=-1
  gfx.x=x
  gfx.y=y
  gfx.mode=1
  gfx.blit(1001, 1, 0)
  
  gfx.x=oldx
  gfx.y=oldy
  gfx.set(old_gfx_r, old_gfx_g, old_gfx_b, old_gfx_a)
  gfx.mode=old_mode
end

function reagirl.Rect_Add(x,y,w,h,r,g,b,a,filled)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Rect_Add</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string rect_guid = reagirl.Rect_Add(integer x, integer y, integer w, integer h, integer r, integer g, integer b, integer a, integer filled)</functioncall>
  <description>
    Adds a decorative rectangle into the gui. It can be used to make the gui prettier but also to hide ui-elements from visibility(make them disabled first before hiding them with a rectangle!).
    To do this, add the rectangle AFTER the gui-elements, that you want to hide.
    
    Don't use this as gui-element with functionality, like rectangles for drop-zones, as rectangles are NOT accessible for blind users of your gui.
    Otherwise your element disappears for blind people.
  </description>
  <parameters>
    integer x - the x position of the rectangle in pixels; negative anchors the rectangle to the right window-side
    integer y - the y position of the rectangle in pixels; negative anchors the rectangle to the bottom window-side
    integer w - the width of the rectangle in pixels
    integer h - the height of the rectangle in pixels
    integer r - the red-value of the rectangle, between 0 and 255
    integer g - the green-value of the rectangle, between 0 and 255
    integer b - the blue-value of the rectangle, between 0 and 255
    integer a - the alpha-value of the rectangle, between 0 and 255
    integer filled - 0, unfilled rectangle; 1, filled rectangle
  </parameters>
  <retvals>
    string rect_guid - a guid that can be used for altering the rectangle-attributes
  </retvals>
  <chapter_context>
    Rectangle
  </chapter_context>
  <tags>rectangle, add</tags>
</US_DocBloc>
--]]
  if math.type(x)~="integer" then error("Rect_Add: param #1 - must be an integer", 2) end
  if math.type(y)~="integer" then error("Rect_Add: param #2 - must be an integer", 2) end
  if math.type(w)~="integer" then error("Rect_Add: param #3 - must be an integer", 2) end
  if math.type(h)~="integer" then error("Rect_Add: param #4 - must be an integer", 2) end
  if math.type(r)~="integer" then error("Rect_Add: param #5 - must be an integer", 2) end
  if math.type(g)~="integer" then error("Rect_Add: param #6 - must be an integer", 2) end
  if math.type(b)~="integer" then error("Rect_Add: param #7 - must be an integer", 2) end
  if math.type(a)~="integer" then error("Rect_Add: param #8 - must be an integer", 2) end
  if math.type(filled)~="integer" then error("Rect_Add: param #9 - must be an integer", 2) end
  
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  table.insert(reagirl.Elements, slot, {})
  reagirl.Elements[slot]["Guid"]=reaper.genGuid("")
  reagirl.Elements[slot]["GUI_Element_Type"]="Rectangle"
  reagirl.Elements[slot]["IsDecorative"]=true
  reagirl.Elements[slot]["AccHint"]=""
  reagirl.Elements[slot]["Description"]=""
  reagirl.Elements[slot]["Text"]=""
  reagirl.Elements[slot]["Name"]=""
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["w"]=w
  reagirl.Elements[slot]["h"]=h
  reagirl.Elements[slot]["r"]=1/255*r
  reagirl.Elements[slot]["g"]=1/255*g
  reagirl.Elements[slot]["b"]=1/255*b
  reagirl.Elements[slot]["a"]=1/255*a
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false
  reagirl.Elements[slot]["filled"]=filled
  reagirl.Elements[slot]["func_draw"]=reagirl.Rect_Draw
  reagirl.Elements[slot]["run_function"]=reagirl.Dummy
  reagirl.Elements[slot]["func_manage"]=reagirl.Dummy
  return reagirl.Elements[slot]["Guid"]
end

function reagirl.Rect_SetColors(element_id, r, g, b, a)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Rect_SetColors</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Rect_SetColors(string element_id, integer r, integer g, integer b, integer a)</functioncall>
  <description>
    Sets the color of a rectangle.
  </description>
  <parameters>
    string element_id - the guid of the rectangle, whose colors you want to set
    integer r - the new red-value; 1-255
    integer g - the new green-value; 1-255
    integer b - the new blue-value; 1-255
    integer a - the new alpha-value; 1-255
  </parameters>
  <chapter_context>
    Rectangle
  </chapter_context>
  <tags>rectangle, set, color, alpha</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Rect_SetColors: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Rect_SetColors: param #1 - must be a valid guid", 2) end
  if math.type(r)~="integer" then error("Rect_SetColors: param #2 - must be an integer", 2) end
  if math.type(g)~="integer" then error("Rect_SetColors: param #3 - must be an integer", 2) end
  if math.type(b)~="integer" then error("Rect_SetColors: param #4 - must be an integer", 2) end
  if math.type(a)~="integer" then error("Rect_SetColors: param #5 - must be an integer", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Rect_SetColors: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Rectangle" then
    error("Rect_SetColors: param #1 - ui-element is not a rectangle", 2)
  else
    reagirl.Elements[element_id]["r"]=1/255*r
    reagirl.Elements[element_id]["g"]=1/255*g
    reagirl.Elements[element_id]["b"]=1/255*b
    reagirl.Elements[element_id]["a"]=1/255*a
    reagirl.Gui_ForceRefresh()
  end
end

function reagirl.Rect_GetColors(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Rect_GetColors</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Rect_GetColors(string element_id, integer r, integer g, integer b, integer a)</functioncall>
  <description>
    Sets the color of a rectangle.
  </description>
  <parameters>
    string element_id - the guid of the rectangle, whose color-state you want to get
  </parameters>
  <retvals>
    integer r - the new red-value; 1-255
    integer g - the new green-value; 1-255
    integer b - the new blue-value; 1-255
    integer a - the new alpha-value; 1-255
  </retvals>
  <chapter_context>
    Rectangle
  </chapter_context>
  <tags>rectangle, get, color, alpha</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Rect_GetColors: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Rect_SetColors: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Rect_GetColors: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Rectangle" then
    error("Rect_GetColors: param #1 - ui-element is not a rectangle", 2)
  else
    return reagirl.Elements[element_id]["r"]*255, reagirl.Elements[element_id]["g"]*255, reagirl.Elements[element_id]["b"]*255, reagirl.Elements[element_id]["a"]*255
  end
end

function reagirl.Rect_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  --print(w)
  old_r, old_g, old_b, old_a = gfx.r, gfx.g, gfx.b, gfx.a
  gfx.set(element_storage["r"], element_storage["g"], element_storage["b"], element_storage["a"])
  --print_update(x,y,w,h,element_storage["filled"])
  gfx.rect(x, y, w, h, element_storage["filled"])
  gfx.set(old_r, old_g, old_b, old_a)
end


function reagirl.Line_Add(x,y,x2,y2,r,g,b,a)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Line_Add</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string line_guid = reagirl.Line_Add(integer x, integer y, integer x2, integer y2, integer r, integer g, integer b, integer a, integer filled)</functioncall>
  <description>
    Adds a decorative line into the gui. It can be used to visually separate different ui-element-categories from each other.
  </description>
  <parameters>
    integer x - the x position of the line in pixels
    integer y - the y position of the line in pixels
    integer x2 - the second x-position of the line in pixels
    integer y2 - the second y-position of the line in pixels
    integer r - the red-value of the line, between 0 and 255
    integer g - the green-value of the line, between 0 and 255
    integer b - the blue-value of the line, between 0 and 255
    integer a - the alpha-value of the line, between 0 and 255
  </parameters>
  <retvals>
    string line_guid - a guid that can be used for altering the line-attributes
  </retvals>
  <chapter_context>
    Line
  </chapter_context>
  <tags>line, add</tags>
</US_DocBloc>
--]]
  if math.type(x)~="integer" then error("Line_Add: param #1 - must be an integer", 2) end
  if math.type(y)~="integer" then error("Line_Add: param #2 - must be an integer", 2) end
  if math.type(x2)~="integer" then error("Line_Add: param #3 - must be an integer", 2) end
  if math.type(y2)~="integer" then error("Line_Add: param #4 - must be an integer", 2) end
  if math.type(r)~="integer" then error("Line_Add: param #5 - must be an integer", 2) end
  if math.type(g)~="integer" then error("Line_Add: param #6 - must be an integer", 2) end
  if math.type(b)~="integer" then error("Line_Add: param #7 - must be an integer", 2) end
  if math.type(a)~="integer" then error("Line_Add: param #8 - must be an integer", 2) end
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  table.insert(reagirl.Elements, slot, {})
  reagirl.Elements[slot]["Guid"]=reaper.genGuid("")
  reagirl.Elements[slot]["GUI_Element_Type"]="Line"
  reagirl.Elements[slot]["IsDecorative"]=true
  reagirl.Elements[slot]["AccHint"]=""
  reagirl.Elements[slot]["Description"]=""
  reagirl.Elements[slot]["Text"]=""
  reagirl.Elements[slot]["Name"]=""
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["x2"]=x2
  reagirl.Elements[slot]["y2"]=y2
  reagirl.Elements[slot]["w"]=x2
  reagirl.Elements[slot]["h"]=y2
  reagirl.Elements[slot]["r"]=r
  reagirl.Elements[slot]["g"]=g
  reagirl.Elements[slot]["b"]=b
  reagirl.Elements[slot]["a"]=a
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false
  reagirl.Elements[slot]["filled"]=filled
  reagirl.Elements[slot]["func_draw"]=reagirl.Line_Draw
  reagirl.Elements[slot]["run_function"]=reagirl.Dummy
  reagirl.Elements[slot]["func_manage"]=reagirl.Label_Manage
  return reagirl.Elements[slot]["Guid"]
end

function reagirl.Line_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  --element_id=reagirl.Decorative_Element_GetIDFromGuid(element_id)
  local x2, y2, w2, h2
  local scale=reagirl.Window_CurrentScale
  gfx.set(element_storage["r"], element_storage["g"], element_storage["b"], element_storage["a"])
  MoveItAllRight=reagirl.MoveItAllRight
  local MoveItAllUp=reagirl.MoveItAllUp
  if element_storage.sticky_x==true then MoveItAllRight=0 end
  if element_storage.sticky_y==true then MoveItAllUp=0 end
  
  
  if element_storage["x2"]<0 then x2=gfx.w+element_storage["x2"] else x2=element_storage["x2"] end
  if element_storage["y2"]<0 then y2=gfx.h+element_storage["y2"] else y2=element_storage["y2"] end
  
  MoveIt={x,y,x2,y2, w2, h2}
  gfx.line(x, y, x2*scale+MoveItAllRight, y2*scale+MoveItAllUp)
end


function reagirl.Image_Add(image_filename, x, y, w, h, name, meaningOfUI_Element, run_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Image_Add</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string image_guid = reagirl.Image_Add(string image_filename, integer x, integer y, integer w, integer h, string name, string meaning of UI_Element, function run_function)</functioncall>
  <description>
    Adds an image to the gui. This image can run a function when clicked on it. 
    
    You can have different images for different scaling-ratios. You put them into the same folder and name them like:
    image-filename.png - 1x-scaling
    image-filename-2x.png - 2x-scaling
    image-filename-3x.png - 3x-scaling
    image-filename-4x.png - 4x-scaling
    image-filename-5x.png - 5x-scaling
    image-filename-6x.png - 6x-scaling
    image-filename-7x.png - 7x-scaling
    image-filename-8x.png - 8x-scaling
    
    If a filename doesn't exist, it reverts to the default one for 1x-scaling.
    
    You can autoposition the checkbox by setting x and/or y to nil, which will position the new checkbox after the last ui-element.
    To autoposition into the next line, use reagirl.NextLine()
  </description>
  <parameters>
    string image_filename - the filename of the imagefile to be shown
    integer x - the x position of the image in pixels; nil, autoposition after the last ui-element(see description)
    integer y - the y position of the image in pixels; nil, autoposition after the last ui-element(see description)
    integer w - the width of the image in pixels(might result in stretched images!)
    integer h - the height of the image in pixels(might result in stretched images!)
    string name - a descriptive name for the image
    string meaningOfUI_Element - a description of the meaning of this image for accessibility users
    function run_function - a function that is run when the image is clicked; will get the image-element-id as first parameter and the image-filename passed as second parameter
  </parameters>
  <retvals>
    string image_guid - a guid that can be used for altering the image-attributes
  </retvals>
  <chapter_context>
    Image
  </chapter_context>
  <tags>image, add</tags>
</US_DocBloc>
--]]
  if type(image_filename)~="string" then error("Image_Add: param #1 - must be a string", 2) end
  if x~=nil and math.type(x)~="integer" then error("Image_Add: param #2 - must be nil or an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("Image_Add: param #3 - must be nil or an integer", 2) end
  if math.type(w)~="integer" then error("Image_Add: param #4 - must be an integer", 2) end
  if math.type(h)~="integer" then error("Image_Add: param #5 - must be an integer", 2) end
  if type(name)~="string" then error("Image_Add: param #6 - must be a string", 2) end
  if type(meaningOfUI_Element)~="string" then error("Image_Add: param #7 - must be a string", 2) end
  if run_function==nil then run_function=reagirl.Dummy end
  if run_function~=nil and type(run_function)~="function" then error("Image_Add: param #8 - must be either nil or a function", 2) end
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  if x==nil then 
    x=reagirl.UI_Element_NextX_Default
    if slot-1==0 or reagirl.UI_Element_NextLineY>0 then
      x=reagirl.UI_Element_NextLineX
    elseif slot-1>0 then
      for i=slot-1, 1, -1 do
        if reagirl.Elements[i]["IsDecorative"]==false then
          x=reagirl.Elements[i]["x"]+reagirl.Elements[i]["w"]+reagirl.UI_Element_NextX_Margin
          break
        end
      end
    end
  end
  
  if y==nil then 
    y=reagirl.UI_Element_NextY_Default
    if slot-1>0 then
      y=reagirl.Elements[slot-1]["y"]+reagirl.UI_Element_NextLineY
      reagirl.UI_Element_NextLineY=0
    end
  end  
  
  table.insert(reagirl.Elements, slot, {})
  reagirl.Elements[slot]["Guid"]=reaper.genGuid("")
  reagirl.Elements[slot]["GUI_Element_Type"]="Image"
  reagirl.Elements[slot]["Description"]=meaningOfUI_Element
  reagirl.Elements[slot]["Name"]=name
  reagirl.Elements[slot]["Text"]=name
  reagirl.Elements[slot]["IsDecorative"]=false
  reagirl.Elements[slot]["AccHint"]="Use Space or left mouse-click to select it."
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["w"]=w
  reagirl.Elements[slot]["h"]=h
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false
  reagirl.Elements[slot]["func_manage"]=reagirl.Image_Manage
  reagirl.Elements[slot]["func_draw"]=reagirl.Image_Draw
  reagirl.Elements[slot]["run_function"]=run_function
  reagirl.Elements[slot]["func_params"]=func_params -- removed for now, since I don't know, why the run-function shall have params
  reagirl.Elements[slot]["Image_Resize"]=resize
  
  reagirl.Elements[slot]["Image_Storage"]=reagirl.Gui_ReserveImageBuffer()
  reagirl.Elements[slot]["Image_Filename"]=image_filename
  gfx.dest=reagirl.Elements[slot]["Image_Storage"]
  local r,g,b,a=gfx.r,gfx.g,gfx.b,gfx.a
  gfx.set(0)
  gfx.rect(0,0,8192,8192)
  gfx.set(r,g,b,a)
  local scale=reagirl.Window_CurrentScale
  
  if reaper.file_exists(image_filename:match("(.*)%.").."-"..scale.."x"..image_filename:match(".*(%..*)"))==true then
    image_filename=image_filename:match("(.*)%.").."-"..scale.."x"..image_filename:match(".*(%..*)")
  end
  local AImage=gfx.loadimg(reagirl.Elements[slot]["Image_Storage"], image_filename)
  
  --[[
  if resize==true then
    local retval = reagirl.ResizeImageKeepAspectRatio(reagirl.Elements[slot]["Image_Storage"], w, h, 0, 0, 0)
  else
    reagirl.Elements[slot]["w"], reagirl.Elements[slot]["h"] = gfx.getimgdim(AImage)
  end
  --]]

  gfx.dest=-1
  return reagirl.Elements[slot]["Guid"]
end

function reagirl.Image_ReloadImage_Scaled(slot)
  image_filename=reagirl.Elements[slot]["Image_Filename"]
  local scale=reagirl.Window_CurrentScale
  if reaper.file_exists(image_filename:match("(.*)%.").."-"..scale.."x"..image_filename:match(".*(%..*)"))==true then
    image_filename=image_filename:match("(.*)%.").."-"..scale.."x"..image_filename:match(".*(%..*)")
  end
  gfx.dest=reagirl.Elements[slot]["Image_Storage"]
  
  image=reagirl.Elements[slot]["Image_Storage"]
  local r,g,b,a=gfx.r,gfx.g,gfx.b,gfx.a
  gfx.set(0)
  gfx.rect(0,0,8192,8192,1)
  gfx.set(r,g,b,a)
  local AImage=gfx.loadimg(image, image_filename )

  gfx.dest=-1
  return reagirl.Elements[slot]["Guid"]
end

function reagirl.Image_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if selected==true and 
    (Key==32 or mouse_cap==1) and 
    (gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h) 
    and clicked=="FirstCLK" and
    element_storage["run_function"]~=nil then 
      element_storage["run_function"](element_storage["Guid"], element_storage["Image_Filename"]) 
  end
  if selected==true then
    message=" "
  end
  return message
end

function reagirl.Image_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if w<0 or h<0 then return end
  -- no docs in API-docs
  local scale=reagirl.Window_CurrentScale
  -- store changes
  local olddest, r, g, b, a, oldmode, oldx, oldy
  olddest=gfx.dest
  r=gfx.r
  g=gfx.g
  b=gfx.b
  a=gfx.a
  oldmode=gfx.mode
  oldx,oldy=gfx.x, gfx.y
  
  -- blit the image
  gfx.set(0)
  gfx.x=x
  gfx.y=y
  
  gfx.dest=-1
  --gfx.blit(element_storage["Image_Storage"], 1, 0, 0, 0, )
  imgw, imgh = gfx.getimgdim(element_storage["Image_Storage"])
  gfx.blit(element_storage["Image_Storage"],1,0,0,0,imgw,imgh,x,y,w,h,0,0)
  
  -- revert changes
  gfx.r,gfx.g,gfx.b,gfx.a=r,g,b,a
  gfx.mode=oldmode
  gfx.x=oldx
  gfx.y=oldy
  gfx.dest=olddest
end

function reagirl.Image_Update(element_id, image_filename)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Image_Update</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string image_guid = reagirl.Image_Update(string element_id, string image_filename)</functioncall>
  <description>
    Loads a new image-file of an existing image in the gui. 
    
    You can have different images for different scaling-ratios. You put them into the same folder and name them like:
    image-filename.png - 1x-scaling
    image-filename-2x.png - 2x-scaling
    image-filename-3x.png - 3x-scaling
    image-filename-4x.png - 4x-scaling
    image-filename-5x.png - 5x-scaling
    image-filename-6x.png - 6x-scaling
    image-filename-7x.png - 7x-scaling
    image-filename-8x.png - 8x-scaling
    
    If a filename doesn't exist, it reverts to the default one for 1x-scaling.
  </description>
  <parameters>
    string element_id - the guid of the image
    string image_filename - the filename of the imagefile to be shown
  </parameters>
  <chapter_context>
    Image
  </chapter_context>
  <tags>image, load new image</tags>
</US_DocBloc>
--]]  
  if type(element_id)~="string" then error("Image_Update: param #1 - must be a string", 2) end
  if type(image_filename)~="string" then error("Image_Add: param #2 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Image_Update: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Image_Update: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Image" then
    error("Rect_GetColors: param #1 - ui-element is not a rectangle", 2)
  else
    reagirl.Elements[element_id]["Image_Filename"]=image_filename
    reagirl.Image_ReloadImage_Scaled(element_id)
    reagirl.Gui_ForceRefresh(12)
  end
end



function reagirl.Background_GetSetColor(is_set, r, g, b)
  if type(is_set)~="boolean" then error("GetSetBackgroundColor: param #1 - must be a boolean", 2) end
  if math.type(r)~="integer" then error("GetSetBackgroundColor: param #2 - must be an integer", 2) end
  if g~=nil and math.type(g)~="integer" then error("GetSetBackgroundColor: param #3 - must be an integer", 2) end
  if b~=nil and math.type(b)~="integer" then error("GetSetBackgroundColor: param #4 - must be an integer", 2) end
  if g==nil then g=r end
  if b==nil then b=r end
  if reagirl.Elements==nil then reagirl.Elements={} end
  if is_set==true then
    reagirl["WindowBackgroundColorR"],reagirl["WindowBackgroundColorG"],reagirl["WindowBackgroundColorB"]=r/255, g/255, b/255
  else
    return math.floor(reagirl["WindowBackgroundColorR"]*255), math.floor(reagirl["WindowBackgroundColorG"]*255), math.floor(reagirl["WindowBackgroundColorB"]*255)
  end
end


function reagirl.Background_GetSetImage(filename, x, y, scaled, fixed_x, fixed_y)
  if type(filename)~="string" then error("Background_GetSetImage: param #1 - must be a boolean", 2) end
  if math.type(x)~="integer" then error("Background_GetSetImage: param #2 - must be an integer", 2) end
  if math.type(y)~="integer" then error("Background_GetSetImage: param #3 - must be an integer", 2) end
  if type(scaled)~="boolean" then error("Background_GetSetImage: param #4 - must be a boolean", 2) end
  if type(fixed_x)~="boolean" then error("Background_GetSetImage: param #5 - must be an boolean", 2) end
  if type(fixed_y)~="boolean" then error("Background_GetSetImage: param #6 - must be an boolean", 2) end
  if reagirl.MaxImage==nil then reagirl.MaxImage=1 end
  reagirl.Background_FixedX=fixed_x
  reagirl.Background_FixedY=fixed_y
  reagirl.MaxImage=reagirl.MaxImage+1
  gfx.loadimg(reagirl.MaxImage, filename)
  local se={reaper.my_getViewport(0,0,0,0, 0,0,0,0, false)}
  reagirl.ResizeImageKeepAspectRatio(reagirl.MaxImage, se[3], se[4], bg_r, bg_g, bg_b)
  if reagirl.DecorativeImages==nil then
    reagirl.DecorativeImages={}
    reagirl.DecorativeImages["Background"]=reagirl.MaxImage
    reagirl.DecorativeImages["Background_Scaled"]=scaled
    reagirl.DecorativeImages["Background_Centered"]=centered
    reagirl.DecorativeImages["Background_x"]=x
    reagirl.DecorativeImages["Background_y"]=y
  end
end

function reagirl.GetHoveredUIElement()
  for i=#reagirl.Elements, 1, -1 do
    local x2, y2, w2, h2
    if reagirl.Elements[i]["x"]<0 then x2=gfx.w+reagirl.Elements[i]["x"] else x2=reagirl.Elements[i]["x"] end
    if reagirl.Elements[i]["y"]<0 then y2=gfx.h+reagirl.Elements[i]["y"] else y2=reagirl.Elements[i]["y"] end
    if reagirl.Elements[i]["w"]<0 then w2=gfx.w-x2+reagirl.Elements[i]["w"] else w2=reagirl.Elements[i]["w"] end
    if reagirl.Elements[i]["h"]<0 then h2=gfx.h-h2+reagirl.Elements[i]["h"] else h2=reagirl.Elements[i]["h"] end
    
    if gfx.mouse_x>=x2 and gfx.mouse_y>=y2 and
       gfx.mouse_x<=x2+w2 and gfx.mouse_y<=y2+h2 then
      if i~=reagirl.Elements["old_hovered_element"] then
        --reaper.osara_outputMessage(""..reagirl.Elements[i]["Name"].." ")
        reagirl.Elements["old_hovered_element"]=i
        return i
      end
    end
  end
  
  return reagirl.Elements["old_hovered_element"]
end

function reagirl.Background_DrawImage()
  if reagirl.DecorativeImages==nil then return end
  local xoffset=0
  local yoffset=0
  if reagirl.Background_FixedX==false then xoffset=reagirl.MoveItAllRight end
  if reagirl.Background_FixedY==false then yoffset=reagirl.MoveItAllUp end
  gfx.dest=-1
  local scale=1
  local x,y=gfx.getimgdim(reagirl.DecorativeImages["Background"])
  local ratiox=((100/x)*gfx.w)/100
  local ratioy=((100/y)*gfx.h)/100
  if reagirl.DecorativeImages["Background_Scaled"]==true then
    if ratiox<ratioy then scale=ratiox else scale=ratioy end
    if x<gfx.w and y<gfx.h then scale=1 end
  end
  gfx.x=reagirl.DecorativeImages["Background_x"]+xoffset
  gfx.y=reagirl.DecorativeImages["Background_y"]+yoffset
  gfx.blit(reagirl.DecorativeImages["Background"], scale, 0)
end

function reagirl.FileDropZone_CheckForDroppedFiles()
  local x, y, w, h
  local scale=reagirl.Window_GetCurrentScale()
  local i=1
  if reagirl.DropZone~=nil then
    for i=1, #reagirl.DropZone do
      if reagirl.DropZone[i]["DropZoneX"]<0 then x=gfx.w+reagirl.DropZone[i]["DropZoneX"]+reagirl.MoveItAllRight else x=reagirl.DropZone[i]["DropZoneX"]+reagirl.MoveItAllRight end
      if reagirl.DropZone[i]["DropZoneY"]<0 then y=gfx.h+reagirl.DropZone[i]["DropZoneY"]+reagirl.MoveItAllUp else y=reagirl.DropZone[i]["DropZoneY"]+reagirl.MoveItAllUp end
      if reagirl.DropZone[i]["DropZoneW"]<0 then w=gfx.w-x+reagirl.DropZone[i]["DropZoneW"] else w=reagirl.DropZone[i]["DropZoneW"] end
      if reagirl.DropZone[i]["DropZoneH"]<0 then h=gfx.h-y+reagirl.DropZone[i]["DropZoneH"] else h=reagirl.DropZone[i]["DropZoneH"] end
      x=x*scale
      y=y*scale
      w=w*scale
      h=h*scale
      -- debug dropzone-rectangle, for checking, if it works
      --[[
        gfx.set(1)
        gfx.rect(x, y, w, h, 0)
      --]]
      local files={}
      local retval
      if gfx.mouse_x>=x and
         gfx.mouse_y>=y and
         gfx.mouse_x<=x+w and
         gfx.mouse_y<=y+h then
         for i=0, 65555 do
           retval, files[i+1]=gfx.getdropfile(i)
           if retval==false then break end
         end
         if #files>0 then
          reagirl.DropZone[i]["DropZoneFunc"](reagirl.DropZone[i]["Guid"], files)
          reagirl.Gui_ForceRefresh(14)
         end
      end
    end
    gfx.getdropfile(-1)
  end
end

function reagirl.FileDropZone_Add(x,y,w,h,func)
  if reagirl.DropZone==nil then reagirl.DropZone={} end
  reagirl.DropZone[#reagirl.DropZone+1]={}
  reagirl.DropZone[#reagirl.DropZone]["Guid"]=reaper.genGuid("")
  reagirl.DropZone[#reagirl.DropZone]["DropZoneFunc"]=func
  reagirl.DropZone[#reagirl.DropZone]["DropZoneX"]=x
  reagirl.DropZone[#reagirl.DropZone]["DropZoneY"]=y
  reagirl.DropZone[#reagirl.DropZone]["DropZoneW"]=w
  reagirl.DropZone[#reagirl.DropZone]["DropZoneH"]=h
  reagirl.DropZone[#reagirl.DropZone]["sticky_x"]=false
  reagirl.DropZone[#reagirl.DropZone]["sticky_y"]=false
  return reagirl.DropZone[#reagirl.DropZone]["Guid"]
end

function reagirl.FileDropZone_Remove(dropzone_id)
  if type(dropzone_id)~="string" then error("FileDropZone_Remove: #1 - must be a guid as string", 2) end

  for i=1, #reagirl.DropZone do
    if reagirl.DropZone[i]["Guid"]==dropzone_id then table.remove(reagirl.DropZone[i], i) return true end
  end
  
  return false
end

function reagirl.ContextMenuZone_ManageMenu(mouse_cap)
  local x, y, w, h 
  local scale=reagirl.Window_GetCurrentScale()
  if mouse_cap&2==0 then return end
  if reagirl.ContextMenu~=nil then
    for i=1, #reagirl.ContextMenu do
      if reagirl.ContextMenu[i]["ContextMenuX"]<0 then x=gfx.w+reagirl.ContextMenu[i]["ContextMenuX"]+reagirl.MoveItAllRight else x=reagirl.ContextMenu[i]["ContextMenuX"]+reagirl.MoveItAllRight end
      if reagirl.ContextMenu[i]["ContextMenuY"]<0 then y=gfx.h+reagirl.ContextMenu[i]["ContextMenuY"]+reagirl.MoveItAllUp else y=reagirl.ContextMenu[i]["ContextMenuY"]+reagirl.MoveItAllUp end
      if reagirl.ContextMenu[i]["ContextMenuW"]<0 then w=gfx.w-x+reagirl.ContextMenu[i]["ContextMenuW"] else w=reagirl.ContextMenu[i]["ContextMenuW"] end
      if reagirl.ContextMenu[i]["ContextMenuH"]<0 then h=gfx.h-y+reagirl.ContextMenu[i]["ContextMenuH"] else h=reagirl.ContextMenu[i]["ContextMenuH"] end
      x=x*scale
      y=y*scale
      w=w*scale
      h=h*scale
      -- debug dropzone-rectangle, for checking, if it works
      --[[
        gfx.set(1)
        gfx.rect(x, y, w, h, 1)
      --]]
      local files={}
      local retval
      if gfx.mouse_x>=x and
         gfx.mouse_y>=y and
         gfx.mouse_x<=x+w and
         gfx.mouse_y<=y+h then
         local oldx=gfx.x
         local oldy=gfx.y
         gfx.x=gfx.mouse_x
         gfx.y=gfx.mouse_y
        local retval=gfx.showmenu(reagirl.ContextMenu[i]["ContextMenu"])
        if retval>0 then
          reagirl.ContextMenu[i]["ContextMenuFunc"](i, retval)
        end
        gfx.x=oldx
        gfx.y=oldy
      end
      reagirl.Gui_ForceRefresh(15)
    end
  end
end

function reagirl.ContextMenuZone_Add(x,y,w,h,menu, func)
  if reagirl.ContextMenu==nil then reagirl.ContextMenu={} end
  reagirl.ContextMenu[#reagirl.ContextMenu+1]={}
  reagirl.ContextMenu[#reagirl.ContextMenu]["Guid"]=reaper.genGuid()
  reagirl.ContextMenu[#reagirl.ContextMenu]["ContextMenuFunc"]=func
  reagirl.ContextMenu[#reagirl.ContextMenu]["ContextMenuX"]=x
  reagirl.ContextMenu[#reagirl.ContextMenu]["ContextMenuY"]=y
  reagirl.ContextMenu[#reagirl.ContextMenu]["ContextMenuW"]=w
  reagirl.ContextMenu[#reagirl.ContextMenu]["ContextMenuH"]=h
  reagirl.ContextMenu[#reagirl.ContextMenu]["sticky_x"]=false
  reagirl.ContextMenu[#reagirl.ContextMenu]["sticky_y"]=false
  reagirl.ContextMenu[#reagirl.ContextMenu]["ContextMenu"]=menu
  
  return reagirl.ContextMenu[#reagirl.ContextMenu]["Guid"]
end

function reagirl.ContextMenuZone_Remove(context_menuzone_id)
  if type(context_menuzone_id)~="string" then error("ContextMenuZone_Remove: #1 - must be a guid as string", 2) end
  for i=1, #reagirl.ContextMenu do
    if reagirl.ContextMenu[i]["Guid"]==context_menuzone_id then table.remove(reagirl.ContextMenu[i], i) return true end
  end
  return false
end

function reagirl.Window_ForceMinSize()
  if reagirl.Window_ForceMinSize_Toggle~=true then return end
  local scale=reagirl.Window_CurrentScale
  local h,w
  if gfx.w<(reagirl.Window_MinW*scale)-1 then w=reagirl.Window_MinW*scale else w=gfx.w end
  if gfx.h<(reagirl.Window_MinH*scale)-1 then h=reagirl.Window_MinH*scale else h=gfx.h end
  
  if gfx.w==w and gfx.h==h then return end
  gfx.init("", w, h)
  reagirl.Gui_ForceRefresh(16)
end

function reagirl.Window_ForceMaxSize()
  if reagirl.Window_ForceMaxSize_Toggle~=true then return end
  local scale=reagirl.Window_CurrentScale
  local h,w
  if gfx.w>reagirl.Window_MaxW*scale then w=reagirl.Window_MaxW*scale else w=gfx.w end
  if gfx.h>reagirl.Window_MaxH*scale then h=reagirl.Window_MaxH*scale else h=gfx.h end
  
  if gfx.w==w and gfx.h==h then return end
  gfx.init("", w, h)
  reagirl.Gui_ForceRefresh(16)
end

function reagirl.Gui_ForceRefresh(place)
  reagirl.Gui_ForceRefreshState=true
  reagirl.Gui_ForceRefresh_place=place
  reagirl.Gui_ForceRefresh_time=reaper.time_precise()
end

function reagirl.Window_ForceSize_Minimum(MinW, MinH)
  reagirl.Window_ForceMinSize_Toggle=true
  reagirl.Window_MinW=MinW
  reagirl.Window_MinH=MinH
end

function reagirl.Window_ForceSize_Maximum(MaxW, MaxH)
  reagirl.Window_ForceMaxSize_Toggle=true
  reagirl.Window_MaxW=MaxW
  reagirl.Window_MaxH=MaxH
end

--- End of ReaGirl-functions


function DropDownList(element_id, check, name)
  --print2(element_id, check, name)
end


function UpdateImage2(element_id)
  print2("HUH", element_id)
  reagirl.Gui_ForceRefreshState=true
  --if gfx.mouse_cap==1 then
    retval, filename = reaper.GetUserFileNameForRead("", "", "")
    if retval==true then
      reagirl.Image_Update(element_id, filename)
    end
  --end
  --]]
end

function GetFileList(element_id, filelist)
  print2(element_id)
  reagirl.Image_Update(B, filelist[1])
  AFile=filelist
  list=""
  for i=1, 1000 do
    if filelist[i]~=nil then 
      list=list..i..": "..filelist[i].."\n"
    end
  end
 -- print2(list)
end

function GetFileList2(filelist)
  list=""
  for i=1, 1000 do
    if filelist[i]==nil then break end
    list=list..filelist[i].."\n"
  end
  print2("Zwo:"..list)
end

function reagirl.UI_Element_ScrollX(deltapx_x)
  if deltapx_x>0 and reagirl.MoveItAllRight_Delta<0 then reagirl.MoveItAllRight_Delta=0 end
  if deltapx_x<0 and reagirl.MoveItAllRight_Delta>0 then reagirl.MoveItAllRight_Delta=0 end
  reagirl.MoveItAllRight_Delta=reagirl.MoveItAllRight_Delta+deltapx_x
end

function reagirl.UI_Element_ScrollY(deltapx_y)
  if deltapx_y>0 and reagirl.MoveItAllUp_Delta<0 then reagirl.MoveItAllUp_Delta=0 end
  if deltapx_y<0 and reagirl.MoveItAllUp_Delta>0 then reagirl.MoveItAllUp_Delta=0 end
  reagirl.MoveItAllUp_Delta=reagirl.MoveItAllUp_Delta+deltapx_y
end

function reagirl.UI_Element_SmoothScroll(Smoothscroll) -- parameter for debugging only
  reagirl.SmoothScroll=Smoothscroll -- for debugging only
  --Boundary=reaper.time_precise() -- for debugging only
  -- scroll y position
  
  --if the boundary is bigger than screen, we need to scroll
  if reagirl.BoundaryY_Max>gfx.h then
    
    -- Scrolllimiter bottom
--    print_update(reagirl.BoundaryY_Max, reagirl.MoveItAllUp, gfx.h)
    if reagirl.MoveItAllUp_Delta<0 and reagirl.BoundaryY_Max+reagirl.MoveItAllUp-gfx.h<=0 then 
      --print_update(reagirl.BoundaryY_Max, reagirl.MoveItAllUp, gfx.h)
      reagirl.MoveItAllUp_Delta=0 
      reagirl.MoveItAllUp=gfx.h-reagirl.BoundaryY_Max
      reagirl.Gui_ForceRefresh(64) 
    end
    
    -- Scrolllimiter top
    if reagirl.MoveItAllUp_Delta>0 and reagirl.BoundaryY_Min+reagirl.MoveItAllUp>=0 then 
      reagirl.MoveItAllUp_Delta=0 
      reagirl.MoveItAllUp=0 
      reagirl.Gui_ForceRefresh(65) 
    end
    
    if reagirl.MoveItAllUp_Delta>0 then 
      reagirl.MoveItAllUp_Delta=reagirl.MoveItAllUp_Delta-1
      if reagirl.MoveItAllUp_Delta<0 then reagirl.MoveItAllUp_Delta=0 end
    elseif reagirl.MoveItAllUp_Delta<0 then 
      reagirl.MoveItAllUp_Delta=reagirl.MoveItAllUp_Delta+1
      if reagirl.MoveItAllUp_Delta>0 then reagirl.MoveItAllUp_Delta=0 end
    end
    if reagirl.BoundaryY_Max>gfx.h then
      reagirl.MoveItAllUp=math.floor(reagirl.MoveItAllUp+reagirl.MoveItAllUp_Delta)
    end
  elseif reagirl.MoveItAllUp_Delta<0 then
    reagirl.MoveItAllUp_Delta=reagirl.MoveItAllUp_Delta+1 --reagirl.MoveItAllUp_Delta=0
  end
  if reagirl.MoveItAllUp_Delta>-1 and reagirl.MoveItAllUp_Delta<1 then reagirl.MoveItAllUp_Delta=0 end
  
  -- scroll x-position
  if reagirl.BoundaryX_Max>gfx.w then
    if reagirl.MoveItAllRight_Delta<0 and reagirl.BoundaryX_Max+reagirl.MoveItAllRight-gfx.w<=0 then reagirl.MoveItAllRight_Delta=0 reagirl.MoveItAllRight=gfx.w-reagirl.BoundaryX_Max reagirl.Gui_ForceRefresh(66) end
    if reagirl.MoveItAllRight_Delta>0 and reagirl.BoundaryX_Min+reagirl.MoveItAllRight>=0 then reagirl.MoveItAllRight_Delta=0 reagirl.MoveItAllRight=0 reagirl.Gui_ForceRefresh(67) end
    if reagirl.BoundaryX_Max>gfx.w and reagirl.MoveItAllRight_Delta>0 then 
      reagirl.MoveItAllRight_Delta=reagirl.MoveItAllRight_Delta-1
      if reagirl.MoveItAllRight_Delta<0 then reagirl.MoveItAllRight_Delta=0 end
    elseif reagirl.BoundaryX_Max>gfx.w and reagirl.MoveItAllRight_Delta<0 then 
      reagirl.MoveItAllRight_Delta=reagirl.MoveItAllRight_Delta+1
      if reagirl.MoveItAllRight_Delta>0 then reagirl.MoveItAllRight_Delta=0 end
    end
    if reagirl.BoundaryX_Max>gfx.w then
      reagirl.MoveItAllRight=math.floor(reagirl.MoveItAllRight+reagirl.MoveItAllRight_Delta)
    end
  elseif reagirl.MoveItAllRight_Delta<0 then
    reagirl.MoveItAllRight_Delta=reagirl.MoveItAllRight_Delta+1 --reagirl.MoveItAllUp_Delta=0
  end
  if reagirl.MoveItAllRight_Delta>-1 and reagirl.MoveItAllRight_Delta<1 then reagirl.MoveItAllRight_Delta=0 end
  
  if reagirl.MoveItAllRight_Delta~=0 or reagirl.MoveItAllUp_Delta~=0 then reagirl.Gui_ForceRefresh(68) end
end

function reagirl.UI_Elements_Boundaries()
  -- sets the boundaries of the maximum scope of all ui-elements into reagirl.Boundary[X|Y]_[Min|Max]-variables.
  -- these can be used to calculate scrolling including stopping at the minimum, maximum position of the ui-elements,
  -- so you don't scroll forever.
  -- This function only calculates non-locked ui-element-directions
  
  --[[
  -- Democode for Gui_ Manage, that scrolls via arrow-keys including "scroll lock" when reaching end of ui-elements.
  if Key==30064 then 
    -- Up
    if reagirl.BoundaryY_Max+reagirl.MoveItAllUp>gfx.h then 
      reagirl.MoveItAllUp=reagirl.MoveItAllUp-10 
      reagirl.Gui_ForceRefresh() 
    end
  end
  if Key==1685026670 then 
    -- Down
    if reagirl.BoundaryY_Min+reagirl.MoveItAllUp<0 then 
      reagirl.MoveItAllUp=reagirl.MoveItAllUp+10 
      reagirl.Gui_ForceRefresh()   
    end
  end
  if Key==1818584692.0 then 
    -- left
    if reagirl.BoundaryX_Min+reagirl.MoveItAllRight<0 then 
      reagirl.MoveItAllRight=reagirl.MoveItAllRight+10 
      reagirl.Gui_ForceRefresh() 
    end
  end
  if Key==1919379572.0 then 
    if reagirl.BoundaryX_Max+reagirl.MoveItAllRight>gfx.w then 
      reagirl.MoveItAllRight=reagirl.MoveItAllRight-10 
      reagirl.Gui_ForceRefresh() 
    end
  end
  --]]
  --[[
  local x2, y2, w2, h2
  if reagirl.Elements[i]["x"]<0 then x2=gfx.w+reagirl.Elements[i]["x"] else x2=reagirl.Elements[i]["x"] end
  if reagirl.Elements[i]["y"]<0 then y2=gfx.h+reagirl.Elements[i]["y"] else y2=reagirl.Elements[i]["y"] end
  if reagirl.Elements[i]["w"]<0 then w2=gfx.w-x2+reagirl.Elements[i]["w"] else w2=reagirl.Elements[i]["w"] end
  if reagirl.Elements[i]["h"]<0 then h2=gfx.h-y2+reagirl.Elements[i]["h"] else h2=reagirl.Elements[i]["h"] end
  if reagirl.Elements[i]["GUI_Element_Type"]=="DropDownMenu" then
    if w2<20 then w2=20 end
  end
  --]]
  local scale=reagirl.Window_CurrentScale
  local minx, miny, maxx, maxy = 2147483648, 2147483648, -2147483648, -2147483648
  -- first the x position
  for i=1, #reagirl.Elements do
    if reagirl.Elements[i].sticky_x==false or reagirl.Elements[i].sticky_y==false then
      local x2, y2, w2, h2
      if reagirl.Elements[i]["x"]*scale<0 then x2=gfx.w+reagirl.Elements[i]["x"]*scale else x2=reagirl.Elements[i]["x"]*scale end
      if reagirl.Elements[i]["y"]*scale<0 then y2=gfx.h+reagirl.Elements[i]["y"]*scale else y2=reagirl.Elements[i]["y"]*scale end
      if reagirl.Elements[i]["w"]*scale<0 then w2=gfx.w-x2+reagirl.Elements[i]["w"]*scale else w2=reagirl.Elements[i]["w"]*scale end
      if reagirl.Elements[i]["GUI_Element_Type"]=="ComboBox" then if w2<20 then w2=20 end end -- Correct for DropDownMenu?
      if reagirl.Elements[i]["h"]*scale<0 then h2=gfx.h-y2+reagirl.Elements[i]["h"]*scale else h2=reagirl.Elements[i]["h"]*scale end
      if x2<minx then minx=x2 end
      if w2+x2>maxx then maxx=w2+x2 MaxW=w2 end
      
      if y2<miny then miny=y2 end
      if h2+y2>maxy then maxy=h2+y2 MAXH=h2 end
      --MINY=miny
      --MAXY=maxy
    end
  end
  --gfx.line(minx+reagirl.MoveItAllRight,miny+reagirl.MoveItAllUp, maxx+reagirl.MoveItAllRight, maxy+reagirl.MoveItAllUp, 1)
  --gfx.line(minx+reagirl.MoveItAllRight,miny+reagirl.MoveItAllUp, minx+reagirl.MoveItAllRight, maxy+reagirl.MoveItAllUp)
  
  local scale_offset
  if scale==1 then scale_offset=50
  elseif scale==2 then scale_offset=150
  elseif scale==3 then scale_offset=300
  elseif scale==4 then scale_offset=450
  elseif scale==5 then scale_offset=550
  elseif scale==6 then scale_offset=650
  elseif scale==7 then scale_offset=750
  elseif scale==8 then scale_offset=850
  end
  --]]
  reagirl.BoundaryX_Min=0--minx
  reagirl.BoundaryX_Max=maxx
  reagirl.BoundaryY_Min=0--miny
  reagirl.BoundaryY_Max=maxy -- +scale_offset
  --gfx.rect(reagirl.BoundaryX_Min, reagirl.BoundaryY_Min+reagirl.MoveItAllUp, 10, 10, 1)
  --gfx.rect(reagirl.BoundaryX_Max-20, reagirl.BoundaryY_Max+reagirl.MoveItAllUp-20, 10, 10, 1)
  --gfx.drawstr(reagirl.MoveItAllUp.." "..reagirl.BoundaryY_Min)
end 

function reagirl.DockState_Update(name)
  -- sets the dockstate into extstates
  local dockstate=tonumber(reaper.GetExtState("ReaGirl_"..name, "dockstate"))--gfx.dock
  if dockstate==nil then dockstate=0 end
  if dockstate~=gfx.dock(-1) then
    reaper.SetExtState("ReaGirl_"..name, "dockstate", gfx.dock(-1), true)
  end
end

function reagirl.DockState_Retrieve(name)
  -- retrieves the dockstate from the extstate and sets it
  local dockstate=tonumber(reaper.GetExtState("ReaGirl_"..name, "dockstate"))--gfx.dock
  if dockstate==nil then dockstate=0 end
  return math.tointeger(dockstate)
end

function reagirl.DockState_Update_Project(name)
  -- sets the dockstate into project extstates
  local dockstate=tonumber(reaper.GetProjExtState(0, "ReaGirl_"..name, "dockstate"))--gfx.dock
  if dockstate==nil then dockstate=0 end
  if dockstate~=gfx.dock(-1) then
    reaper.SetProjExtState(0, "ReaGirl_"..name, "dockstate", gfx.dock(-1), true)
  end
end

function reagirl.DockState_RetrieveAndSet_Project(name)
  -- retrieves the dockstate from the project extstate and sets it
  local dockstate=tonumber(reaper.GetProjExtState(0, "ReaGirl_"..name, "dockstate"))--gfx.dock
  gfx.dock(dockstate)
end

function reagirl.ScrollButton_Right_Add()
  reagirl.Elements[#reagirl.Elements+1]={}
  reagirl.Elements[#reagirl.Elements]["Guid"]=reaper.genGuid("")
  reagirl.Elements[#reagirl.Elements]["GUI_Element_Type"]="Scroll button"
  reagirl.Elements[#reagirl.Elements]["Name"]="Scroll right"
  reagirl.Elements[#reagirl.Elements]["Text"]=""
  reagirl.Elements[#reagirl.Elements]["IsDecorative"]=false
  reagirl.Elements[#reagirl.Elements]["Description"]="Scroll Right"
  reagirl.Elements[#reagirl.Elements]["AccHint"]="Scrolls the user interface to the right"
  reagirl.Elements[#reagirl.Elements]["x"]=-30
  reagirl.Elements[#reagirl.Elements]["y"]=-15
  reagirl.Elements[#reagirl.Elements]["w"]=15
  reagirl.Elements[#reagirl.Elements]["h"]=15
  reagirl.Elements[#reagirl.Elements]["sticky_x"]=true
  reagirl.Elements[#reagirl.Elements]["sticky_y"]=true
  reagirl.Elements[#reagirl.Elements]["func_manage"]=reagirl.ScrollButton_Right_Manage
  reagirl.Elements[#reagirl.Elements]["func_draw"]=reagirl.ScrollButton_Right_Draw
  reagirl.Elements[#reagirl.Elements]["userspace"]={}
  reagirl.Elements[#reagirl.Elements]["a"]=0
  return reagirl.Elements[#reagirl.Elements]["Guid"]
end

function reagirl.ScrollButton_Right_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if element_storage.IsDecorative==false and element_storage.a<=0.75 then element_storage.a=element_storage.a+.1 reagirl.Gui_ForceRefresh(99.3) end
  if mouse_cap&1==1 and selected==true and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    reagirl.UI_Element_ScrollX(-2)
  elseif selected==true and Key==32 then
    reagirl.UI_Element_ScrollX(-15)
  end
  return ""
end

function reagirl.ScrollButton_Right_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  local scale=reagirl.Window_CurrentScale
  local x_offset=-15*scale
  if reagirl.BoundaryX_Max>gfx.w then
    element_storage.IsDecorative=false
  else
    element_storage.a=0 
    if element_storage.IsDecorative==false then
      reagirl.UI_Element_SetNothingFocused()
      element_storage.IsDecorative=true
    end
  end
  local oldr, oldg, oldb, olda = gfx.r, gfx.g, gfx.b, gfx.a
  gfx.set(reagirl["WindowBackgroundColorR"], reagirl["WindowBackgroundColorG"], reagirl["WindowBackgroundColorB"], element_storage.a)
  gfx.rect(gfx.w-15*scale+x_offset, gfx.h-15*scale, 15*scale, 15*scale, 1)
  if mouse_cap==1 and selected==true then
    gfx.set(0.59, 0.59, 0.59, element_storage.a)
  else
    gfx.set(0.39, 0.39, 0.39, element_storage.a)
  end
  gfx.rect(gfx.w-15*scale+x_offset, gfx.h-15*scale, 15*scale, 15*scale, 0)
  gfx.triangle(gfx.w-10*scale+x_offset, gfx.h-3*scale,
               gfx.w-10*scale+x_offset, gfx.h-13*scale,
               gfx.w-5*scale+x_offset, gfx.h-8*scale)
  gfx.set(oldr, oldg, oldb, olda)
end

function reagirl.ScrollButton_Left_Add()
  reagirl.Elements[#reagirl.Elements+1]={}
  reagirl.Elements[#reagirl.Elements]["Guid"]=reaper.genGuid("")
  reagirl.Elements[#reagirl.Elements]["GUI_Element_Type"]="Scroll button"
  reagirl.Elements[#reagirl.Elements]["Name"]="Scroll left"
  reagirl.Elements[#reagirl.Elements]["Text"]=""
  reagirl.Elements[#reagirl.Elements]["IsDecorative"]=false
  reagirl.Elements[#reagirl.Elements]["Description"]="Scroll left"
  reagirl.Elements[#reagirl.Elements]["AccHint"]="Scrolls the user interface to the left"
  reagirl.Elements[#reagirl.Elements]["x"]=1
  reagirl.Elements[#reagirl.Elements]["y"]=-15
  reagirl.Elements[#reagirl.Elements]["w"]=15
  reagirl.Elements[#reagirl.Elements]["h"]=15
  reagirl.Elements[#reagirl.Elements]["sticky_x"]=true
  reagirl.Elements[#reagirl.Elements]["sticky_y"]=true
  reagirl.Elements[#reagirl.Elements]["func_manage"]=reagirl.ScrollButton_Left_Manage
  reagirl.Elements[#reagirl.Elements]["func_draw"]=reagirl.ScrollButton_Left_Draw
  reagirl.Elements[#reagirl.Elements]["userspace"]={}
  reagirl.Elements[#reagirl.Elements]["a"]=0
  return reagirl.Elements[#reagirl.Elements]["Guid"]
end

function reagirl.ScrollButton_Left_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if element_storage.IsDecorative==false and element_storage.a<=0.75 then element_storage.a=element_storage.a+.1 reagirl.Gui_ForceRefresh(99.2) end
  if mouse_cap&1==1 and selected==true and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    reagirl.UI_Element_ScrollX(2)
  elseif selected==true and Key==32 then
    reagirl.UI_Element_ScrollX(15)
  end
  return ""
end

function reagirl.ScrollButton_Left_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  local scale=reagirl.Window_CurrentScale
  if reagirl.BoundaryX_Max>gfx.w then
    element_storage.IsDecorative=false
  else
    element_storage.a=0 
    --reagirl.Gui_ForceRefresh(99.2) 
    if element_storage.IsDecorative==false then
      reagirl.UI_Element_SetNothingFocused()
      element_storage.IsDecorative=true
    end
  end
  local oldr, oldg, oldb, olda = gfx.r, gfx.g, gfx.b, gfx.a
  gfx.set(reagirl["WindowBackgroundColorR"], reagirl["WindowBackgroundColorG"], reagirl["WindowBackgroundColorB"], element_storage.a)
  gfx.rect(0, gfx.h-15*scale, 15*scale, 15*scale, 1)
  if mouse_cap==1 and selected==true then
    gfx.set(0.59, 0.59, 0.59, element_storage.a)
  else
    gfx.set(0.39, 0.39, 0.39, element_storage.a)
  end
  gfx.rect(0, gfx.h-15*scale, 15*scale, 15*scale, 0)
  gfx.triangle(8*scale, gfx.h-3*scale,
               8*scale, gfx.h-13*scale,
               3*scale, gfx.h-8*scale)
  gfx.set(oldr, oldg, oldb, olda)
end

function reagirl.ScrollButton_Up_Add()
  reagirl.Elements[#reagirl.Elements+1]={}
  reagirl.Elements[#reagirl.Elements]["Guid"]=reaper.genGuid("")
  reagirl.Elements[#reagirl.Elements]["GUI_Element_Type"]="Scroll button"
  reagirl.Elements[#reagirl.Elements]["Name"]="Scroll Up"
  reagirl.Elements[#reagirl.Elements]["Text"]=""
  reagirl.Elements[#reagirl.Elements]["IsDecorative"]=false
  reagirl.Elements[#reagirl.Elements]["Description"]="Scroll up"
  reagirl.Elements[#reagirl.Elements]["AccHint"]="Scrolls the user interface upwards"
  reagirl.Elements[#reagirl.Elements]["x"]=-15
  reagirl.Elements[#reagirl.Elements]["y"]=0
  reagirl.Elements[#reagirl.Elements]["w"]=15
  reagirl.Elements[#reagirl.Elements]["h"]=15
  reagirl.Elements[#reagirl.Elements]["sticky_x"]=true
  reagirl.Elements[#reagirl.Elements]["sticky_y"]=true
  reagirl.Elements[#reagirl.Elements]["func_manage"]=reagirl.ScrollButton_Up_Manage
  reagirl.Elements[#reagirl.Elements]["func_draw"]=reagirl.ScrollButton_Up_Draw
  reagirl.Elements[#reagirl.Elements]["userspace"]={}
  reagirl.Elements[#reagirl.Elements]["a"]=0
  return reagirl.Elements[#reagirl.Elements]["Guid"]
end

function reagirl.ScrollButton_Up_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if element_storage.IsDecorative==false and element_storage.a<=0.75 then element_storage.a=element_storage.a+.1 reagirl.Gui_ForceRefresh(99.5) end
  if mouse_cap&1==1 and selected==true and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    reagirl.UI_Element_ScrollY(2)
  elseif selected==true and Key==32 then
    reagirl.UI_Element_ScrollY(15)
  end
  return ""
end

function reagirl.ScrollButton_Up_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  local scale=reagirl.Window_CurrentScale
  if reagirl.BoundaryY_Max>gfx.h then
    element_storage.IsDecorative=false
  else
    element_storage.a=0 
    --reagirl.Gui_ForceRefresh(99.2) 
    if element_storage.IsDecorative==false then
      reagirl.UI_Element_SetNothingFocused()
      element_storage.IsDecorative=true
    end
  end
  local oldr, oldg, oldb, olda = gfx.r, gfx.g, gfx.b, gfx.a
  gfx.set(reagirl["WindowBackgroundColorR"], reagirl["WindowBackgroundColorG"], reagirl["WindowBackgroundColorB"], element_storage.a)
  gfx.rect(gfx.w-15*scale, 0, 15*scale, 15*scale, 1)
  if mouse_cap==1 and selected==true then
    gfx.set(0.59, 0.59, 0.59, element_storage.a)
  else
    gfx.set(0.39, 0.39, 0.39, element_storage.a)
  end
  gfx.rect(gfx.w-15*scale, 0, 15*scale, 15*scale, 0)
  gfx.triangle(gfx.w-8*scale, 4*scale,
               gfx.w-3*scale, 9*scale,
               gfx.w-13*scale, 9*scale)
  gfx.set(oldr, oldg, oldb, olda)
end

function reagirl.ScrollButton_Down_Add()
  reagirl.Elements[#reagirl.Elements+1]={}
  reagirl.Elements[#reagirl.Elements]["Guid"]=reaper.genGuid("")
  reagirl.Elements[#reagirl.Elements]["GUI_Element_Type"]="Scroll button"
  reagirl.Elements[#reagirl.Elements]["Name"]="Scroll Down"
  reagirl.Elements[#reagirl.Elements]["Text"]=""
  reagirl.Elements[#reagirl.Elements]["IsDecorative"]=false
  reagirl.Elements[#reagirl.Elements]["Description"]="Scroll Down"
  reagirl.Elements[#reagirl.Elements]["AccHint"]="Scrolls the user interface downwards"
  reagirl.Elements[#reagirl.Elements]["x"]=-15
  reagirl.Elements[#reagirl.Elements]["y"]=-30
  reagirl.Elements[#reagirl.Elements]["w"]=15
  reagirl.Elements[#reagirl.Elements]["h"]=15
  reagirl.Elements[#reagirl.Elements]["sticky_x"]=true
  reagirl.Elements[#reagirl.Elements]["sticky_y"]=true
  reagirl.Elements[#reagirl.Elements]["func_manage"]=reagirl.ScrollButton_Down_Manage
  reagirl.Elements[#reagirl.Elements]["func_draw"]=reagirl.ScrollButton_Down_Draw
  reagirl.Elements[#reagirl.Elements]["userspace"]={}
  reagirl.Elements[#reagirl.Elements]["a"]=0
  return reagirl.Elements[#reagirl.Elements]["Guid"]
end

function reagirl.ScrollButton_Down_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if element_storage.IsDecorative==false and element_storage.a<=0.75 then element_storage.a=element_storage.a+.1 reagirl.Gui_ForceRefresh(99.5) end
  refresh_1=clicked
  if mouse_cap&1==1 and selected==true and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    reagirl.UI_Element_ScrollY(-2)
  elseif selected==true and Key==32 then
    reagirl.UI_Element_ScrollY(-15)
  end
  return ""
end

function reagirl.ScrollButton_Down_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  local scale=reagirl.Window_CurrentScale
  --print_update(x,y,w,h,scale)
  if reagirl.BoundaryY_Max>gfx.h then
    element_storage.IsDecorative=false
  else
    element_storage.a=0 
    --reagirl.Gui_ForceRefresh(99.2) 
    if element_storage.IsDecorative==false then
      reagirl.UI_Element_SetNothingFocused()
      element_storage.IsDecorative=true
    end
  end
  local oldr, oldg, oldb, olda = gfx.r, gfx.g, gfx.b, gfx.a
  gfx.set(reagirl["WindowBackgroundColorR"], reagirl["WindowBackgroundColorG"], reagirl["WindowBackgroundColorB"], element_storage.a)
  gfx.rect(gfx.w-15*scale, gfx.h-30*scale, 15*scale, 15*scale, 1)
  if mouse_cap==1 and selected==true then
    gfx.set(0.59, 0.59, 0.59, element_storage.a)
  else
    gfx.set(0.39, 0.39, 0.39, element_storage.a)
  end
  gfx.rect(gfx.w-15*scale, gfx.h-30*scale, 15*scale, 15*scale, 0)
  gfx.triangle(gfx.w-8*scale, gfx.h-20*scale,
               gfx.w-3*scale, gfx.h-25*scale,
               gfx.w-13*scale, gfx.h-25*scale)
  gfx.set(oldr, oldg, oldb, olda)
end

function reagirl.UI_Element_GetNextFreeSlot()
  if #reagirl.Elements-3<1 then return #reagirl.Elements+1 end
  return #reagirl.Elements-3
end

function reagirl.UI_Element_ScrollToUIElement(element_id, x_offset, y_offset)
  if x_offset==nil then x_offset=10 end
  if y_offset==nil then y_offset=10 end
  local found=-1
  local x2,y2,w2,h2
  for i=1, #reagirl.Elements do
    if element_id==reagirl.Elements[i].Guid then
      if reagirl.Elements[i]["x"]<0 then x2=gfx.w+reagirl.Elements[i]["x"] else x2=reagirl.Elements[i]["x"] end
      if reagirl.Elements[i]["y"]<0 then y2=gfx.h+reagirl.Elements[i]["y"] else y2=reagirl.Elements[i]["y"] end
      if reagirl.Elements[i]["w"]<0 then w2=gfx.w-x2+reagirl.Elements[i]["w"] else w2=reagirl.Elements[i]["w"] end
      if reagirl.Elements[i]["h"]<0 then h2=gfx.h-y2+reagirl.Elements[i]["h"] else h2=reagirl.Elements[i]["h"] end
      
      if x2+reagirl.MoveItAllRight<0 or x2+reagirl.MoveItAllRight>gfx.w or y2+reagirl.MoveItAllUp<0 or y2+reagirl.MoveItAllUp>gfx.h or
         x2+w2+reagirl.MoveItAllRight<0 or x2+w2+reagirl.MoveItAllRight>gfx.w or y2+h2+reagirl.MoveItAllUp<0 or y2+h2+reagirl.MoveItAllUp>gfx.h 
      then
        --print2()
        reagirl.MoveItAllRight=-x2+x_offset
        reagirl.MoveItAllUp=-y2+y_offset
        reagirl.Gui_ForceRefresh(999)
      end
    end
  end
end

function reagirl.UI_Element_SetNothingFocused()
  reagirl.Elements.FocusedElement=1
end

function reagirl.UI_Element_GetHovered()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetHovered</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string element_guid = reagirl.UI_Element_GetHovered()</functioncall>
  <description>
    Get the ui-element-guid, at where the mouse is currently hovering above. 
  </description>
  <chapter_context>
    Gui
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, get, hovered, hover, gui</tags>
</US_DocBloc>
]]
  if reagirl.UI_Elements_HoveredElement==-1 then return end
  return reagirl.Elements[reagirl.UI_Elements_HoveredElement]["Guid"]
end

function reagirl.UI_Element_GetFocused()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetFocused</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string element_guid = reagirl.UI_Element_GetFocused()</functioncall>
  <description>
    Get the ui-element-guid, that is currently focused. 
  </description>
  <chapter_context>
    Gui
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, get, focused, gui</tags>
</US_DocBloc>
]]
  if reagirl.Elements.FocusedElement>=#reagirl.Elements-3 then return end
  return reagirl.Elements[reagirl.Elements.FocusedElement]["Guid"]
end

function reagirl.UI_Element_SetFocused(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_SetFocused</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.UI_Element_SetFocused(string element_id)</functioncall>
  <description>
    Set an ui-element-guid focused. 
  </description>
  <chapter_context>
    Gui
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, set, focused, gui</tags>
</US_DocBloc>
]]
  if reagirl.Elements.FocusedElement>=#reagirl.Elements-3 then return end
  local id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if id==-1 then error("UI_Element_SetFocused: param #1 - no such ui-element", -2) end

  reagirl.Elements.FocusedElement=id
  reagirl.Gui_ForceRefresh()
end

function reagirl.Slider_Add(x, y, w, caption, meaningOfUI_Element, unit, start, stop, step, default, run_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_Add</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string slider_guid = reagirl.Slider_Add(integer x, integer y, integer w, string caption, string meaningOfUI_Element, optional string unit, number start, number stop, number step, number default, function run_function)</functioncall>
  <description>
    Adds a slider to a gui.
    
    You can autoposition the slider by setting x and/or y to nil, which will position the new slider after the last ui-element.
    To autoposition into the next line, use reagirl.NextLine()
    
    The caption will be shown before, the unit will be shown after the slider.
    Note: when setting the unit to nil, no unit and number will be shown at the end of the slider.
    
    Also note: when the number of steps is too many to be shown in a narrow slider, step-values may be skipped.
  </description>
  <parameters>
    optional integer x - the x position of the slider in pixels; negative anchors the slider to the right window-side; nil, autoposition after the last ui-element(see description)
    optional integer y - the y position of the slider in pixels; negative anchors the slider to the bottom window-side; nil, autoposition after the last ui-element(see description)
    string caption - the caption of the slider
    string meaningOfUI_Element - a description for accessibility users
    optional string unit - the unit shown next to the number the slider is currently set to
    number start - the minimum value of the slider
    number stop - the maximum value of the slider
    number step - the stepsize until the next value within the slider
    number default - the default value of the slider(also the initial value)
    function run_function - a function that shall be run when the slider is clicked; will get passed over the slider-element_id as first and the new slider-value as second parameter
  </parameters>
  <retvals>
    string checkbox_guid - a guid that can be used for altering the slider-attributes
  </retvals>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, add</tags>
</US_DocBloc>
--]]

-- Parameter Unit==nil means, no number of unit shown
  if x~=nil and math.type(x)~="integer" then error("Slider_Add: param #1 - must be an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("Slider_Add: param #2 - must be an integer", 2) end
  if math.type(w)~="integer" then error("Slider_Add: param #3 - must be an integer", 2) end
  if type(caption)~="string" then error("Slider_Add: param #4 - must be a string", 2) end
  if type(meaningOfUI_Element)~="string" then error("Slider_Add: param #5 - must be a string", 2) end
  if unit~=nil and type(unit)~="string" then error("Slider_Add: param #6 - must be a number", 2) end
  if type(start)~="number" then error("Slider_Add: param #7 - must be a number", 2) end
  if type(stop)~="number" then error("Slider_Add: param #8 - must be a number", 2) end
  if type(step)~="number" then error("Slider_Add: param #9 - must be a number", 2) end
  if type(default)~="number" then error("Slider_Add: param #10 - must be a number", 2) end
  if run_function~=nil and type(run_function)~="function" then error("Slider_Add: param #11 - must be either nil or a function", 2) end
  
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  if x==nil then 
    x=reagirl.UI_Element_NextX_Default
    if slot-1==0 or reagirl.UI_Element_NextLineY>0 then
      x=reagirl.UI_Element_NextLineX
    elseif slot-1>0 then
      x=reagirl.Elements[slot-1]["x"]+reagirl.Elements[slot-1]["w"]
      for i=slot-1, 1, -1 do
        if reagirl.Elements[i]["IsDecorative"]==false then
          local w2=reagirl.Elements[i]["w"]
          --print2(reagirl.Elements[i]["h"], w2)
          x=reagirl.Elements[i]["x"]+w2+reagirl.UI_Element_NextX_Margin
          break
        end
      end
    end
  end

  if y==nil then 
    y=reagirl.UI_Element_NextY_Default
    if slot-1>0 then
      y=reagirl.Elements[slot-1]["y"]+reagirl.UI_Element_NextLineY
      reagirl.UI_Element_NextLineY=0
    end
  end  
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0, 1)
  local tx, ty =gfx.measurestr(caption.."")
  local unit2=unit
  if unit==nil then unit2="" end
  local tx1,ty1=gfx.measurestr(unit2)
  tx1=tx1+gfx.texth+gfx.texth
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  table.insert(reagirl.Elements, slot, {})
  reagirl.Elements[slot]["Guid"]=reaper.genGuid("")
  reagirl.Elements[slot]["GUI_Element_Type"]="Slider"
  reagirl.Elements[slot]["Name"]=caption
  reagirl.Elements[slot]["Text"]=caption
  reagirl.Elements[slot]["Unit"]=unit
  reagirl.Elements[slot]["Start"]=start
  reagirl.Elements[slot]["Stop"]=stop
  reagirl.Elements[slot]["Step"]=step
  reagirl.Elements[slot]["Default"]=default
  reagirl.Elements[slot]["CurValue"]=default
  reagirl.Elements[slot]["IsDecorative"]=false
  reagirl.Elements[slot]["Description"]=meaningOfUI_Element
  reagirl.Elements[slot]["AccHint"]="Change via arrowkeys, home, end, pageup, pagedown."
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["w"]=math.tointeger(w)--math.tointeger(ty+tx+4)
  reagirl.Elements[slot]["h"]=math.tointeger(ty)+5
  reagirl.Elements[slot]["cap_w"]=math.tointeger(tx)
  reagirl.Elements[slot]["unit_w"]=math.tointeger(tx1)
  reagirl.Elements[slot]["slider_w"]=math.tointeger(w-tx-tx1-10)
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false
  reagirl.Elements[slot]["checked"]=default
  reagirl.Elements[slot]["func_manage"]=reagirl.Slider_Manage
  reagirl.Elements[slot]["func_draw"]=reagirl.Slider_Draw
  reagirl.Elements[slot]["run_function"]=run_function
  reagirl.Elements[slot]["userspace"]={}
  return reagirl.Elements[slot]["Guid"]
end

function reagirl.Slider_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  local refresh=false
  if w<element_storage["cap_w"]+element_storage["unit_w"]+20 then w=element_storage["cap_w"]+element_storage["unit_w"]+20 end
  element_storage["slider_w"]=math.tointeger(w-element_storage["cap_w"]-element_storage["unit_w"]-10)
  local dpi_scale=reagirl.Window_GetCurrentScale()
  if gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    reagirl.Scroll_Override_MouseWheel=true
    if reagirl.MoveItAllRight_Delta==0 and reagirl.MoveItAllUp_Delta==0 then
      if mouse_attributes[5]<0 or mouse_attributes[6]>0 then 
        element_storage["CurValue"]=element_storage["CurValue"]+element_storage["Step"] 
        refresh=true 
      end
      if mouse_attributes[5]>0 or mouse_attributes[6]<0 then element_storage["CurValue"]=element_storage["CurValue"]-element_storage["Step"] refresh=true end
      if element_storage["CurValue"]>element_storage["Stop"] then
        --element_storage["CurValue"]=element_storage["Stop"]
        --refresh=false
      elseif element_storage["CurValue"]<element_storage["Start"] then
        --element_storage["CurValue"]=element_storage["Start"]
        --refresh=false
      end
    end
  end
  if selected==true then
    reagirl.Scroll_Override=true
    if Key==1919379572.0 or Key==1685026670.0 then element_storage["CurValue"]=element_storage["CurValue"]+element_storage["Step"] refresh=true reagirl.Scroll_Override=true end
    if Key==1818584692.0 or Key==30064.0 then element_storage["CurValue"]=element_storage["CurValue"]-element_storage["Step"] refresh=true reagirl.Scroll_Override=true end
    if Key==1752132965.0 then element_storage["CurValue"]=element_storage["Start"] refresh=true reagirl.Scroll_Override=true end
    if Key==6647396.0 then element_storage["CurValue"]=element_storage["Stop"] refresh=true reagirl.Scroll_Override=true end
    if Key==1885824110.0 then element_storage["CurValue"]=element_storage["CurValue"]+element_storage["Step"]*5 refresh=true reagirl.Scroll_Override=true end
    if Key==1885828464.0 then element_storage["CurValue"]=element_storage["CurValue"]-element_storage["Step"]*5 refresh=true reagirl.Scroll_Override=true end
    
    --if Key~=0 then ABBA3=Key end
    
    
    if Key~=0 then
      --refresh=true
    end
    if gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
      --reagirl.Scroll_Override=true
      --if mouse_attributes[5]<0 or mouse_attributes[6]>0 then element_storage["CurValue"]=element_storage["CurValue"]+element_storage["Step"] end
      --if mouse_attributes[5]>0 or mouse_attributes[6]<0 then element_storage["CurValue"]=element_storage["CurValue"]-element_storage["Step"] end
      slider_x=x+element_storage["cap_w"]
      slider_x2=x+element_storage["cap_w"]+element_storage["slider_w"]
      rect_w=slider_x2-slider_x

      slider=x--+element_storage["cap_w"]
      slider_x2=(gfx.mouse_x-slider_x-10) -- here you need to add an offset for higher scalings...but how?
      --[[
      -- debug rectangle(see end of Gui_Draw for the function)
      dx=gfx.mouse_x-slider_x
      dy=y 
      dw=10
      dh=10
      --]]
      element_storage["TempValue"]=element_storage["CurValue"]      
      if slider_x2>=0 and slider_x2<=element_storage["slider_w"] then
        if clicked=="DBLCLK" then
          element_storage["CurValue"]=element_storage["Default"]
          refresh=true
        else
          if mouse_cap==1 and clicked=="FirstCLK" or clicked=="DRAG" then
            --step_size=(rect_w/(element_storage["Stop"]+1-element_storage["Start"])/(element_storage["Step"]))
            step_size=(rect_w/(element_storage["Stop"]+1-element_storage["Start"])/1)
            slider4=slider_x2/step_size
            element_storage["CurValue"]=element_storage["Start"]+slider4
            if element_storage["Step"]~=-1 then 
              local old=element_storage["Start"]
              for i=element_storage["Start"], element_storage["Stop"], element_storage["Step"] do
                if element_storage["CurValue"]<i then
                 element_storage["CurValue"]=i
                 break
                end
                old=i
              end
            end
            element_storage["OldMouseX"]=gfx.mouse_x
            element_storage["OldMouseY"]=gfx.mouse_y 
          end
        end
      elseif slider_x2<0 and slider_x2>=-15 and mouse_cap==1 then element_storage["CurValue"]=element_storage["Start"] 
      elseif slider_x2>element_storage["slider_w"] and mouse_cap==1 then 
        element_storage["CurValue"]=element_storage["Stop"] 
      end
      if element_storage["TempValue"]~=element_storage["CurValue"] then --element_storage["OldMouseX"]~=gfx.mouse_x or element_storage["OldMouseY"]~=gfx.mouse_y then
        refresh=true
      end
      if math.type(element_storage["Step"])=="integer" and math.type(element_storage["Start"])=="integer" and math.type(element_storage["Stop"])=="integer" then
        element_storage["CurValue"]=math.floor(element_storage["CurValue"])
      end
    end
  end
  local skip_func
  if element_storage["CurValue"]<element_storage["Start"] then element_storage["CurValue"]=element_storage["Start"] skip_func=true end
  if element_storage["CurValue"]>element_storage["Stop"] then element_storage["CurValue"]=element_storage["Stop"] skip_func=true end
  
  if refresh==true then 
    reagirl.Gui_ForceRefresh() 
    if element_storage["run_function"]~=nil and skip_func~=true then 
      element_storage["run_function"](element_storage["Guid"], element_storage["CurValue"]) 
    end
  end
  element_storage["AccHoverMessage"]=element_storage["Name"].." "..element_storage["CurValue"]
  return element_storage["CurValue"], refresh
end


function reagirl.Slider_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  --if lol==nil then return end
  --gfx.rect(10,10,100,100,1)
  --print_update(y)
  --if w<element_storage["cap_w"]+element_storage["unit_w"]+20 then w=element_storage["cap_w"]+element_storage["unit_w"]+20 end
  --element_storage["IsDecorative"]=true -- debug
  
  local dpi_scale=reagirl.Window_GetCurrentScale()
  
  gfx.x=x
  gfx.y=y
  reagirl.SetFont(1, "Arial", reagirl.Font_Size-1, 0)
  local offset_cap=gfx.measurestr(name.." ")+5*dpi_scale
  local offset_unit=gfx.measurestr(element_storage["Unit"].."8888888")
  
  element_storage["cap_w"]=offset_cap--gfx.measurestr(name.." ")+5*dpi_scale
  element_storage["unit_w"]=offset_unit
  element_storage["slider_w"]=w-offset_cap-offset_unit
  
  if element_storage["IsDecorative"]==true then gfx.set(0.6) else gfx.set(0.8) end
  -- draw caption
  gfx.drawstr(element_storage["Name"])
  
  -- draw unit
  gfx.x=x+w-offset_unit+5*dpi_scale
  gfx.y=y
  local unit=reagirl.FormatNumber(element_storage["CurValue"], 3)
  if element_storage["Unit"]~=nil then gfx.set(0.8) gfx.drawstr(" "..unit..element_storage["Unit"]) end

  if element_storage["IsDecorative"]==true then gfx.set(0.5) else gfx.set(0.7) end
  -- draw slider-area
  gfx.rect(x+offset_cap, y+(gfx.texth>>1)-1, w-offset_cap-offset_unit, 4, 1)
  
  --local rect_stop=w-offset_unit
  --gfx.x=rect_stop
  rect_w=w-offset_unit-offset_cap
  step_size=(rect_w/(element_storage["Stop"]-element_storage["Start"])/1)
  step_current=step_size*(element_storage["CurValue"]-element_storage["Start"])
  --local unit=element_storage["Unit"]
  
  
  gfx.set(0.584)
  gfx.circle(x+offset_cap+step_current, gfx.y+h/3, 7*dpi_scale, 1, 1)
  --gfx.set(0.584)
  gfx.set(0.2725490196078431)
  gfx.circle(x+offset_cap+step_current, gfx.y+h/3, 6*dpi_scale, 1, 1)
  
  if element_storage["IsDecorative"]==true then
    gfx.set(0.584)
    gfx.set(0)
  else
    gfx.set(0.9843137254901961, 0.8156862745098039, 0)
  end

  gfx.circle(x+offset_cap+step_current, gfx.y+h/3, 5*dpi_scale, 1, 1)
end

function reagirl.Slider_SetValue(element_id, value)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_SetValue</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Slider_SetValue(string element_id, number value)</functioncall>
  <description>
    Sets the current value of the slider.
    
    Will not check, whether it is a valid value settable using the stepsize!
  </description>
  <parameters>
    string element_id - the guid of the slider, whose value you want to set
    number value - the new value of the slider
  </parameters>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, set, value</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_SetValue: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_SetValue: param #1 - must be a valid guid", 2) end
  if type(value)~="number" then error("Slider_SetValue: param #2 - must be a number", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_SetValue: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_SetValue: param #1 - ui-element is not a slider", 2)
  else
    if value<reagirl.Elements[element_id]["Start"] or value>reagirl.Elements[element_id]["Stop"] then
      error("Slider_SetValue: param #2 - value must be within start and stop of the slider", 2)
    end
    reagirl.Elements[element_id]["CurValue"]=value
    reagirl.Gui_ForceRefresh()
  end
end

function reagirl.Slider_GetValue(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_GetValue</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>number value = reagirl.Slider_GetValue(string element_id)</functioncall>
  <description>
    Gets the current set value of the slider.
  </description>
  <parameters>
    string element_id - the guid of the slider, whose current value you want to get
  </parameters>
  <retvals>
    number value - the current value set in the slider
  </retvals>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, get, value</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_GetValue: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_GetValue: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_GetValue: param #1 - ui-element is not a slider", 2)
  else
    return reagirl.Elements[element_id]["CurValue"]
  end
end

function reagirl.Slider_SetDisabled(element_id, state)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_SetDisabled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Slider_SetDisabled(string element_id, boolean state)</functioncall>
  <description>
    Sets a slider disabled.
  </description>
  <parameters>
    string element_id - the guid of the slider, whose disablility-state you want to set
    boolean state - true, slider is disabled; false, slider is enabled
  </parameters>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, set, disability</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_SetDisabled: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_SetDisabled: param #1 - must be a valid guid", 2) end
  if type(state)~="boolean" then error("Slider_SetDisabled: param #2 - must be a boolean", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_SetDisabled: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_SetDisabled: param #1 - ui-element is not a slider", 2)
  else
    reagirl.Elements[element_id]["IsDecorative"]=state
    reagirl.Gui_ForceRefresh()
  end
end

function reagirl.Slider_GetDisabled(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_GetDisabled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>boolean state = reagirl.Slider_GetDisabled(string element_id)</functioncall>
  <description>
    Gets the current disability state of the slider.
  </description>
  <parameters>
    string element_id - the guid of the slider, whose current disability-state you want to get
  </parameters>
  <retvals>
    boolean state - true, slider is disabled; false, slider is enabled
  </retvals>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, get, disability</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_GetValue: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_GetValue: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_GetValue: param #1 - ui-element is not a slider", 2)
  else
    return reagirl.Elements[element_id]["IsDecorative"]
  end
end

function reagirl.Slider_SetDefaultValue(element_id, default_value)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_SetDefaultValue</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Slider_SetDefaultValue(string element_id, number default_value)</functioncall>
  <description>
    Sets the default value of the slider.
    
    Will not check, whether it is a valid value settable using the stepsize!
  </description>
  <parameters>
    string element_id - the guid of the slider, whose default value you want to set
    number default_value - the new default value of the slider
  </parameters>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, set, default, value</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_SetDefaultValue: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_SetDefaultValue: param #1 - must be a valid guid", 2) end
  if type(default_value)~="number" then error("Slider_SetDefaultValue: param #2 - must be a number", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_SetDefaultValue: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_SetDefaultValue: param #1 - ui-element is not a slider", 2)
  else
    if default_value<reagirl.Elements[element_id]["Start"] or default_value>reagirl.Elements[element_id]["Stop"] then
      error("Slider_SetDefaultValue: param #2 - value must be within start and stop of the slider", 2)
    end
    reagirl.Elements[element_id]["Default"]=default_value
    reagirl.Gui_ForceRefresh()
  end
end

function reagirl.Slider_GetDefaultValue(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_GetDefaultValue</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>number value = reagirl.Slider_GetDefaultValue(string element_id)</functioncall>
  <description>
    Gets the current set value of the slider.
  </description>
  <parameters>
    string element_id - the guid of the slider, whose default value you want to get
  </parameters>
  <retvals>
    number value - the current default value set in the slider
  </retvals>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, get, default, value</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_GetDefaultValue: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_GetDefaultValue: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_GetDefaultValue: param #1 - ui-element is not a slider", 2)
  else
    return reagirl.Elements[element_id]["Default"]
  end
end

function reagirl.Slider_SetMinimum(element_id, start_value)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_SetMinimum</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Slider_SetMinimum(string element_id, number start_value)</functioncall>
  <description>
    Sets the minimum value of the slider.
    
    If current slider-value is smaller than minimum, the current slider-value will be changed to minimum.
  </description>
  <parameters>
    string element_id - the guid of the slider, whose minimum-value you want to set
    number start_value - the new minimum value of the slider
  </parameters>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, set, minimum, value</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_SetMinimum: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_SetMinimum: param #1 - must be a valid guid", 2) end
  if type(start_value)~="number" then error("Slider_SetMinimum: param #2 - must be a number", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_SetMinimum: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_SetMinimum: param #1 - ui-element is not a slider", 2)
  else
    reagirl.Elements[element_id]["Start"]=start_value
    if reagirl.Elements[element_id]["CurValue"]<start_value then
      reagirl.Elements[element_id]["CurValue"]=start_value
    end
    reagirl.Gui_ForceRefresh()
  end
end

function reagirl.Slider_GetMinimum(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_GetMinimum</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>number min_value = reagirl.Slider_GetMinimum(string element_id)</functioncall>
  <description>
    Gets the current set minimum-value of the slider.
  </description>
  <parameters>
    string element_id - the guid of the slider, whose current minimum-value you want to get
  </parameters>
  <retvals>
    number min_value - the current minimum-value set in the slider
  </retvals>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, get, minimum, value</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_GetMinimum: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_GetMinimum: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_GetMinimum: param #1 - ui-element is not a slider", 2)
  else
    return reagirl.Elements[element_id]["Start"]
  end
end

function reagirl.Slider_SetMaximum(element_id, max_value)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_SetMaximum</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Slider_SetMaximum(string element_id, number max_value)</functioncall>
  <description>
    Sets the maximum value of the slider.
    
    If current slider-value is bigger than maximum, the current slider-value will be changed to maximum.
  </description>
  <parameters>
    string element_id - the guid of the slider, whose max-value you want to set
    number max_value - the new max value of the slider
  </parameters>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, set, maximum, value</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_SetMaximum: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_SetMaximum: param #1 - must be a valid guid", 2) end
  if type(max_value)~="number" then error("Slider_SetMaximum: param #2 - must be a number", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Slider_SetMaximum: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_SetMaximum: param #1 - ui-element is not a slider", 2)
  else
    reagirl.Elements[element_id]["Stop"]=max_value
    if reagirl.Elements[element_id]["CurValue"]>max_value then
      reagirl.Elements[element_id]["CurValue"]=max_value
    end
    reagirl.Gui_ForceRefresh()
  end
end

function reagirl.Slider_GetMaximum(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_GetMaximum</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>number max_value = reagirl.Slider_GetMaximum(string element_id)</functioncall>
  <description>
    Gets the current set maximum-value of the slider.
  </description>
  <parameters>
    string element_id - the guid of the slider, whose current maximum-value you want to get
  </parameters>
  <retvals>
    number max_value - the current maximum-value set in the slider
  </retvals>
  <chapter_context>
    Checkbox
  </chapter_context>
  <tags>slider, get, maximum, value</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_GetMaximum: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_GetMaximum: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_GetMaximum: param #1 - ui-element is not a slider", 2)
  else
    return reagirl.Elements[element_id]["Stop"]
  end
end

function reagirl.Slider_ResetToDefaultValue(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_ResetToDefaultValue</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Slider_ResetToDefaultValue(string element_id)</functioncall>
  <description>
    Resets the current set value of the slider to the default one.
  </description>
  <parameters>
    string element_id - the guid of the slider, whose current value you want to reset to default
  </parameters>
  <chapter_context>
    Checkbox
  </chapter_context>
  <tags>slider, reset, value, default</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Slider_ResetToDefaultValue: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Slider_ResetToDefaultValue: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Slider" then
    error("Slider_ResetToDefaultValue: param #1 - ui-element is not a slider", 2)
  else
    reagirl.Elements[element_id]["CurValue"]=reagirl.Elements[element_id]["Default"]
    reagirl.Gui_ForceRefresh()
  end
end

function reagirl.NextLine_SetMargin(x_margin, y_margin)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>NextLine_SetMargin</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.NextLine_SetMargin(optional integer x_margin, optional integer y_margin)</functioncall>
  <description>
    Set the margin between ui-elements when using autopositioning.
    
    This way, you can set the spaces between ui-elements and lines higher or lower.
  </description>
  <parameters>
    optional integer x_margin - the margin between ui-elements on the same line
    optional integer y_margin - the margin between ui-elements between lines(as set by reagirl.NextLine())
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <tags>ui-elements, set, next line, margin</tags>
</US_DocBloc>
--]]
  if x_margin~=nil and math.type(x_margin)~="integer" then error("NextLine_SetMargin: param #1 - must be either nil or an integer", 2) end
  if y_margin~=nil and math.type(y_margin)~="integer" then error("NextLine_SetMargin: param #2 - must be either nil or an integer", 2) end
  if x_margin<0 then error("NextLine_SetMargin: param #1 - must be bigger than or equal 0", 2) end
  if y_margin<0 then error("NextLine_SetMargin: param #2 - must be bigger than or equal 0", 2) end
  if x_margin~=nil then reagirl.UI_Element_NextX_Margin=x_margin end
  if y_margin~=nil then reagirl.UI_Element_NextY_Margin=y_margin end
end

function reagirl.NextLine_GetMargin()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>NextLine_GetMargin</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>integer x_margin, integer y_margin = reagirl.NextLine_GetMargin()</functioncall>
  <description>
    Gets the margin between ui-elements when using autopositioning.
  </description>
  <retvals>
    optional integer x_margin - the margin between ui-elements on the same line
    optional integer y_margin - the margin between ui-elements between lines(as set by reagirl.NextLine())
  </retvals>
  <chapter_context>
    UI Elements
  </chapter_context>
  <tags>ui-elements, get, next line, margin</tags>
</US_DocBloc>
--]]
  return reagirl.UI_Element_NextX_Margin, reagirl.UI_Element_NextY_Margin
end

function reagirl.Tabs_Add(x, y, w, h, caption, meaningOfUI_Element, tab_names, selected_tab, run_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_Add</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string slider_guid = reagirl.Slider_Add(integer x, integer y, integer w, string caption, string meaningOfUI_Element, optional string unit, number start, number stop, number step, number default, function run_function)</functioncall>
  <description>
    Adds a slider to a gui.
    
    You can autoposition the slider by setting x and/or y to nil, which will position the new slider after the last ui-element.
    To autoposition into the next line, use reagirl.NextLine()
    
    The caption will be shown before, the unit will be shown after the slider.
    Note: when setting the unit to nil, no unit and number will be shown at the end of the slider.
    
    Also note: when the number of steps is too many to be shown in a narrow slider, step-values may be skipped.
  </description>
  <parameters>
    optional integer x - the x position of the slider in pixels; negative anchors the slider to the right window-side; nil, autoposition after the last ui-element(see description)
    optional integer y - the y position of the slider in pixels; negative anchors the slider to the bottom window-side; nil, autoposition after the last ui-element(see description)
    string caption - the caption of the slider
    string meaningOfUI_Element - a description for accessibility users
    optional string unit - the unit shown next to the number the slider is currently set to
    number start - the minimum value of the slider
    number stop - the maximum value of the slider
    number step - the stepsize until the next value within the slider
    number default - the default value of the slider(also the initial value)
    function run_function - a function that shall be run when the slider is clicked; will get passed over the slider-element_id as first and the new slider-value as second parameter
  </parameters>
  <retvals>
    string checkbox_guid - a guid that can be used for altering the slider-attributes
  </retvals>
  <chapter_context>
    Slider
  </chapter_context>
  <tags>slider, add</tags>
</US_DocBloc>
--]]

-- Parameter Unit==nil means, no number of unit shown
  if x~=nil and math.type(x)~="integer" then error("Tabs_Add: param #1 - must be an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("Tabs_Add: param #2 - must be an integer", 2) end
  if math.type(w)~="integer" then error("Tabs_Add: param #2 - must be an integer", 2) end
  if math.type(h)~="integer" then error("Tabs_Add: param #2 - must be an integer", 2) end
  if type(caption)~="string" then error("Tabs_Add: param #3 - must be a string", 2) end
  if type(meaningOfUI_Element)~="string" then error("Tabs_Add: param #4 - must be a string", 2) end
  if type(tab_names)~="table" then error("Tabs_Add: param #5 - must be a number", 2) end
  for i=1, #tab_names do
    tab_names[i]=tostring(tab_names[i])
  end
  if math.type(selected_tab)~="integer" then error("Tabs_Add: param #6 - must be an integer", 2) end
  if run_function~=nil and type(run_function)~="function" then error("Tabs_Add: param #7 - must be either nil or a function", 2) end
  
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  if x==nil then 
    x=reagirl.UI_Element_NextX_Default
    if slot-1==0 or reagirl.UI_Element_NextLineY>0 then
      x=reagirl.UI_Element_NextLineX
    elseif slot-1>0 then
      x=reagirl.Elements[slot-1]["x"]+reagirl.Elements[slot-1]["w"]
      for i=slot-1, 1, -1 do
        if reagirl.Elements[i]["IsDecorative"]==false then
          local w2=reagirl.Elements[i]["w"]
          --print2(reagirl.Elements[i]["h"], w2)
          x=reagirl.Elements[i]["x"]+w2+reagirl.UI_Element_NextX_Margin
          break
        end
      end
    end
  end

  if y==nil then 
    y=reagirl.UI_Element_NextY_Default
    if slot-1>0 then
      y=reagirl.Elements[slot-1]["y"]+reagirl.UI_Element_NextLineY
      reagirl.UI_Element_NextLineY=0
    end
  end  
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0, 1)
  local tx, ty =gfx.measurestr(caption.."")

  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  table.insert(reagirl.Elements, slot, {})
  reagirl.Elements[slot]["Guid"]=reaper.genGuid("")
  reagirl.Elements[slot]["GUI_Element_Type"]="Tabs"
  reagirl.Elements[slot]["Name"]=caption
  reagirl.Elements[slot]["Text"]=caption
  reagirl.Elements[slot]["TabNames"]=tab_names
  reagirl.Elements[slot]["TabSelected"]=selected_tab
  reagirl.Elements[slot]["IsDecorative"]=false
  reagirl.Elements[slot]["Description"]=meaningOfUI_Element
  reagirl.Elements[slot]["AccHint"]="Switch tab using left/right arrow-keys"
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["w"]=math.tointeger(ty+tx+4)
  reagirl.Elements[slot]["h"]=math.tointeger(ty)+15
  reagirl.Elements[slot]["w_background"]=w
  reagirl.Elements[slot]["h_background"]=h
  reagirl.Elements[slot]["text_offset_x"]=20
  reagirl.Elements[slot]["text_offset_y"]=5
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false

  reagirl.Elements[slot]["func_manage"]=reagirl.Tabs_Manage
  reagirl.Elements[slot]["func_draw"]=reagirl.Tabs_Draw
  reagirl.Elements[slot]["run_function"]=run_function
  reagirl.Elements[slot]["userspace"]={}
  return reagirl.Elements[slot]["Guid"]
end

function reagirl.Tabs_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if Key~=0 then ABBA=Key end
  
  if Key==1919379572.0 then 
    element_storage["TabSelected"]=element_storage["TabSelected"]+1
    if element_storage["TabSelected"]>#element_storage["TabNames"] then element_storage["TabSelected"]=#element_storage["TabNames"] end
    refresh=true
  end
  if Key==1818584692.0 then
    element_storage["TabSelected"]=element_storage["TabSelected"]-1
    if element_storage["TabSelected"]<1 then element_storage["TabSelected"]=1 end
    refresh=true
  end
  
  -- click management for the tabs
  if selected==true and element_storage["Tabs_Pos"]~=nil then
    reagirl.Gui_PreventScrollingForOneCycle(true, false)
    for i=1, #element_storage["Tabs_Pos"] do
      --if gfx.mouse_x>=x+element_storage["Tabs_Pos"]
    end
  end
  
  -- hover management for the tabs
  if hovered==true then
    -- to be done
    element_storage["AccHoverMessage"]=element_storage["Name"].." "..element_storage["TabNames"][element_storage["TabSelected"]]
  end
  if refresh==true then 
    reagirl.Gui_ForceRefresh() 
    if element_storage["run_function"]~=nil and skip_func~=true then 
      element_storage["run_function"](element_storage["Guid"], element_storage["TabSelected"], element_storage["TabNames"][element_storage["TabSelected"]]) 
    end
  end
  
  return element_storage["TabNames"][element_storage["TabSelected"]].." tab selected", refresh
end


function reagirl.Tabs_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  local dpi_scale=reagirl.Window_GetCurrentScale()
  local text_offset_x=dpi_scale*element_storage["text_offset_x"]
  local text_offset_y=dpi_scale*element_storage["text_offset_y"]
  local x_offset_factor=20
  local x_offset=dpi_scale*x_offset_factor
  local tab_height=text_offset_y+text_offset_y
  element_storage["Tabs_Pos"]={}
  local tx,ty
  
  for i=1, #element_storage["TabNames"] do
    element_storage["Tabs_Pos"][i]={}
    
    gfx.x=x+x_offset
    gfx.y=y+text_offset_y
    
    tx,ty=gfx.measurestr(element_storage["TabNames"][i])
    tx=math.tointeger(tx)
    ty=math.tointeger(ty)
    element_storage["Tabs_Pos"][i]["x"]=x+text_offset_x
    element_storage["Tabs_Pos"][i]["w"]=x_offset+text_offset_x+tx+text_offset_x

    if i==element_storage["TabSelected"] then offset=dpi_scale gfx.set(0.253921568627451) else offset=0 gfx.set(0.153921568627451) end
    reagirl.RoundRect(math.tointeger(x+x_offset-text_offset_x), y, math.tointeger(tx+text_offset_x+text_offset_x), tab_height+ty, 4*dpi_scale, 1, 1, false, true, false, true)
    
    if i==element_storage["TabSelected"] then offset=dpi_scale gfx.set(0.403921568627451) else offset=0 gfx.set(0.253921568627451) end
    gfx.set(0.403921568627451)
    reagirl.RoundRect(math.tointeger(x+x_offset-text_offset_x), y, math.tointeger(tx+text_offset_x+text_offset_x), tab_height+ty, 4*dpi_scale, 1, 0, false, true, false, true)
    if i==element_storage["TabSelected"] then offset=dpi_scale gfx.set(0.253921568627451) else offset=0 gfx.set(0.153921568627451) end
    
    --element_storage["w"]=math.tointeger(tx+text_offset_x+text_offset_x)-1-x
    gfx.rect(math.tointeger(x+x_offset-text_offset_x)+1, y+y, math.tointeger(tx+text_offset_x+text_offset_x)-1, tab_height+ty-y+offset, 4*dpi_scale, 1, 0, false, true, false, true)
    
    -- store the dimensions and positions of individual tabs for the manage-function
    element_storage["Tabs_Pos"][i]["x"]=math.tointeger(x+x_offset-text_offset_x)
    element_storage["Tabs_Pos"][i]["w"]=math.tointeger(tx+text_offset_x+text_offset_x)-1
    element_storage["Tabs_Pos"][i]["h"]=tab_height+ty
    
    x_offset=x_offset+math.tointeger(tx)+text_offset_x+text_offset_x+dpi_scale*2
    if selected==true and i==element_storage["TabSelected"] then
      reagirl.UI_Element_SetFocusRect(true, math.tointeger(gfx.x), y+text_offset_y, math.tointeger(tx), math.tointeger(ty))
    end
    
    element_storage["w"]=x_offset-dpi_scale*x_offset_factor
    
    gfx.set(1)
    gfx.drawstr(element_storage["TabNames"][i])
    
    gfx.set(1,0,0)
    gfx.rect(element_storage["Tabs_Pos"][i]["x"], y, element_storage["Tabs_Pos"][i]["w"], element_storage["Tabs_Pos"][i]["h"], 0)
    --gfx.circle(element_storage["Tabs_Pos"][i]["x"], y, 5)
  end
  if selected==true then
    --reagirl.UI_Element_SetFocusRect(true, x, y, math.tointeger(tx), math.tointeger(ty))
  end
  
  
end

function DebugRect()
  gfx.set(1,0,0)
  gfx.rect(dx,dy,dw,dh)
end

function CheckMe(tudelu, checkstate)
  --reagirl.UI_Element_SetFocused(LAB)
  --print2(tudelu, checkstate)
  if checkstate==false then
    --reagirl.Window_SetCurrentScale(1)
    reagirl.Button_SetDisabled(BBB, true)
    --reagirl.Slider_SetValue(F, 12)
    --reagirl.Slider_ResetToDefaultValue(F)
    --reagirl.Slider_SetMinimum(F, 10)
    --reagirl.Slider_SetMaximum(F, 50)
    --reagirl.Slider_SetDefaultValue(F, 10)
    reagirl.Slider_SetDisabled(F, true)
  else
    --reagirl.Window_SetCurrentScale()
    reagirl.Button_SetDisabled(BBB, false)
    reagirl.Slider_SetDisabled(F, false)
  end
end


local count=0
local count2=0


function Dummy()
end

function click_button(test)
  --print(os.date())

  if test==BT1 then
    reaper.Main_OnCommand(40015, 0)
    reagirl.UI_Element_ScrollToUIElement(BT1)
    
  elseif test==BT2 then
    reagirl.Gui_Close()
  --reagirl.UI_Element_Remove(EID)
  end
  --print(reagirl.Checkbox_GetTopBottom(A))
  if reagirl.Checkbox_GetDisabled(A)==true then
    reagirl.Checkbox_SetDisabled(A, false)
    reagirl.DropDownMenu_SetDisabled(E, false)
  else
    reagirl.Checkbox_SetDisabled(A, true)
    reagirl.DropDownMenu_SetDisabled(E, true)
  end
end

function CMenu(A,B)
  --print2(A,B)
end

function input1(text)
  --print2(text)
end

function input2()

end

function label_click(element_id)
  print2(1, element_id)
end

function sliderme(element_id, val, val2)
  --print("slider"..element_id..reaper.time_precise(), val, reagirl.Slider_GetValue(element_id))
  --print(reagirl.Slider_GetMinimum(element_id), reagirl.Slider_GetMaximum(element_id))
  --print(reagirl.Slider_GetDefaultValue(F))
  print(element_id, val, val2)
end

function UpdateUI()
  --reagirl.Window_ForceSize_Minimum(500,500)
  --reagirl.Window_ForceSize_Maximum(500,500)
  
  reagirl.Gui_New()
  reagirl.Background_GetSetColor(true, 44,44,44)
  --reagirl.Background_GetSetImage("c:\\m.png", 1, 0, true, false, false)
  if update==true then
    retval, filename = reaper.GetUserFileNameForRead("", "", "")
    if retval==true then
      Images[1]=filename
    end
  end

reagirl.Tabs_Add(10, 10, 100, 200, "TUDELU", "Tabs", {"HUCH", "TUDELU", "Dune", "Ach Gotterl", "Leileileilei"}, 1, run_function)  
reagirl.NextLine()
  --reagirl.AddDummyElement()  
  LAB=reagirl.Label_Add(nil, nil, "Export Podcast as:", "Label 1", 0, false, label_click)
  LAB2=reagirl.Label_Add(nil, nil, "Link to Docs", "clickable label", 0, true, label_click)
  reagirl.NextLine()
  A = reagirl.CheckBox_Add(nil, nil, "Under Pressure", "Under Pressure TUDELU", true, CheckMe)
  reagirl.Checkbox_SetTopBottom(A, false, true)
  A = reagirl.CheckBox_Add(nil, nil, "Under Pressure", "Under Pressure TUDELU", true, sliderme)
  reagirl.Checkbox_SetTopBottom(A, false, true)
  reagirl.NextLine()
  A1 = reagirl.CheckBox_Add(nil, nil, "People on Streets", "People on Streets TUDELU", true, CheckMe)
  reagirl.Checkbox_SetTopBottom(A1, true, true)
  reagirl.NextLine()
  --A2= reagirl.CheckBox_Add(1300, nil, "De de dep", "Export file as MP3", true, CheckMe)
  --reagirl.Checkbox_SetTopBottom(A2, true, false)
  A3 = reagirl.CheckBox_Add(nil, nil, "AAC", "AAC TUDELU", true, CheckMe)
  reagirl.Checkbox_SetTopBottom(A3, true, false)
  
  --A1=reagirl.CheckBox_Add(-280, 110, "AAC", "Export file as AAC", true, CheckMe)
  --A2=reagirl.CheckBox_Add(-280, 130, "OPUS", "Export file as OPUS", true, CheckMe)
--  xxx,yyy=reagirl.NextLine_GetMargin()
--reagirl.NextLine_SetMargin(xxx+100, yyy+100)
  --reagirl.FileDropZone_Add(-230,175,100,100, GetFileList)
  reagirl.NextLine()
  B=reagirl.Image_Add(Images[3], nil, nil, 100, 100, "Mespotine", "Mespotine: A Podcast Empress", sliderme)
  B=reagirl.Image_Add(Images[3], nil, nil, 100, 100, "Mespotine", "Mespotine: A Podcast Empress", sliderme)
  reagirl.FileDropZone_Add(100,100,100,100, GetFileList)
  
  --reagirl.Label_Add("Stonehenge\nWhere the demons dwell\nwhere the banshees live\nand they do live well:", 31, 15, 0, "everything under control")
  --reagirl.InputBox_Add(10,10,100,"Inputbox Deloxe", "Se descrizzione", "TExt", input1, input2)
  --reagirl.NextLine_SetMargin(10, 100)
  reagirl.NextLine()
  --A3 = reagirl.CheckBox_Add(nil, nil, "AAC", "Export file as MP3", true, CheckMe)
  E = reagirl.DropDownMenu_Add(nil, nil, -100, "DropDownMenu:", "Desc of DDM", {"The", "Death", "Of", "A", "Party123456789012345678Hardy Hard Scooter Hyper Hyper How Much Is The Fish",2,3,4,5}, 5, sliderme)
  --F = reagirl.Slider_Add(10, 340, 200, "Sliders Das Tor", "I am a slider", "%", 1, 100, 5.001, 1, sliderme)
  reagirl.NextLine()
  F = reagirl.Slider_Add(nil, nil, -20, "Sliders Das Tor", "I am a slider", "%", 1, 1001, 5.001, 1, sliderme)
  
  --reagirl.Elements[8].IsDecorative=true
  --reagirl.Line_Add(10, 135, 60, 150,1,1,0,1)

  
  --D=reagirl.Image_Add(reaper.GetResourcePath().."/Scripts/Ultraschall_Gfx/Headers/export_logo.png", 1, 1, 79, 79, false, "Logo", "Logo 2")  
  --D1=reagirl.Image_Add(reaper.GetResourcePath().."/Scripts/Ultraschall_Gfx/Headers/headertxt_export.png", 70, 10, 79, 79, false, "Headtertext", "See internet for more details")  
  
  
  --C=reagirl.Image_Add(Images[2], -230, 175, 100, 100, true, "Contrapoints", "Contrapoints: A Youtube-Channel")
  --Rect=reagirl.Rect_Add(10,10,-30,-30,127,127,127,127,127,1)
  --reagirl.Rect_SetColors(Rect, 100, 100, 100, 155)
  --print2(reagirl.Rect_GetColors(Rect))
  --reagirl.Line_Add(0,43,-1,43,1,1,1,0.7)
  
  reagirl.NextLine()
  BT1=reagirl.Button_Add(nil, nil, 0, 0, "Export Podcast", "Will open the Render to File-dialog, which allows you to export the file as MP3", click_button)
  
  BT2=reagirl.Button_Add(885, 550, 0, 0, "Close Gui", "Description of the button", click_button)
  --BT2=reagirl.Button_Add(285, 50, 0, 0, "✏", "Edit Marker", click_button)
  --reagirl.NextLine()
  --BBB=reagirl.Button_Add(720, 770, 20, 0, "Help1", "Description of the button", click_button)
  --reagirl.Button_SetRadius(BBB, 18)
  --BBB=reagirl.Button_Add(nil, nil, 20, 0, "Help", "Description of the button", click_button)
  BBB=reagirl.Button_Add(nil, nil, 20, 0, "Help", "Description of the button", sliderme)
  reagirl.NextLine()
  
  --BBB=reagirl.Button_Add(nil, nil, 20, 0, "Delete", "Description of the button", click_button)
  --BBB=reagirl.Button_Add(nil, nil, 20, 0, "I need somebody", "Description of the button", click_button)
  --reagirl.Button_SetRadius(BBB, 10)
  --
  
--  reagirl.Button_Add(55, 30, 0, 0, " HUCH", "Description of the button", click_button)
  
  for i=1, 0, 1 do
    --A3= reagirl.CheckBox_Add(10, i*10+135, "AAC", "Export file as MP3", true, CheckMe)
    reagirl.Button_Add(nil, nil, 0, 0, i.." HUCH", "Description of the button", click_button)
    reagirl.NextLine()
    reagirl.NextLine()
    reagirl.NextLine()
    reagirl.NextLine()
    reagirl.NextLine()
    reagirl.NextLine()
    reagirl.NextLine()
    reagirl.NextLine()
    reagirl.NextLine()
    reagirl.NextLine()
    reagirl.NextLine()
    reagirl.NextLine()
  end
  --reagirl.ContextMenuZone_Add(10,10,120,120,"Hula|Hoop", CMenu)
  reagirl.ContextMenuZone_Add(100,100,100,100,"Menu|Two|>And a|half", CMenu)
  --]]
end

Images={reaper.GetResourcePath().."/Scripts/Ultraschall_Gfx/Headers/soundcheck_logo.png","c:\\f.png","c:\\m.png"}
reagirl.Gui_Open("Faily", "A Failstate Manager", 300, 350, reagirl.DockState_Retrieve("Stonehenge"), 1, 1)

UpdateUI()
--reagirl.Window_ForceSize_Minimum(320, 200)
--reagirl.Window_ForceSize_Maximum(640, 77)
--reagirl.Gui_ForceRefreshState=true
--main()

function ExitMe()
  print2("Bye Bye")
end

reagirl.Gui_AtExit(ExitMe)

function main()
  reagirl.Gui_Manage()
  reagirl.DockState_Update("Stonehenge")
  --reagirl.Gui_PreventCloseViaEscForOneCycle()
  --ABBA={reagirl.DropDownMenu_GetMenuItems(E)}
  --ABBA[1][1]=reaper.time_precise()
  --reagirl.DropDownMenu_SetMenuItems(E, ABBA[1], 1)
  --reagirl.Gui_ForceRefresh()
  
  gfx.update()
  
  if reagirl.Gui_IsOpen()==true then reaper.defer(main) end
end

main()


--Element1={reagirl.UI_Element_GetSetRunFunction(4, true, print2)}
--Element1={reagirl.UI_Element_GetSetAllVerticalOffset(true, 100)}
--print2("Pudeldu")

--reagirl.UI_Element_GetFocusedRect()

--reagirl.Label_SetLabelText(LAB, "Prime Time Of Your\nLife")

