dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

-- DEBUG:
reaper.osara_outputMessage=nil

reagirl={}
if reaper.osara_outputMessage~=nil then
  reagirl.OSARA=reaper.osara_outputMessage
  function reaper.osara_outputMessage(message, a)
--    print_update(message)
    --if message~="" then print_update(message,a) end
    reagirl.OSARA(message)
  end
end
--]]
--[[
TODO: 
  - InputBox: if they are too small, they aren't drawn properly
  - jumping to ui-elements outside window(means autoscroll to them) doesn't always work
    - ui-elements might still be out of view when jumping to them(x-coordinate outside of window for instance)
  - Slider: disappears when scrolling upwards/leftwards: because of the "only draw neccessary gui-elements"-code, which is buggy for some reason
  - Slider: width is too big...gui might scroll because of that...(probably because of the safety margin of the unit)
  - Slider: draw a line where the default-value shall be
  - Slider: when width is too small, drawing bugs appear(i.e. autowidth plus window is too small)
  - Background_GetSetImage - check, if the background image works properly with scaling and scrolling
  - Image: reload of scaled image-override; if override==true then it loads only the image.png, not image-2x.png
  - Labels: ACCHoverMessage should hold the text of the paragraph the mouse is hovering above only
            That way, not everything is read out as message to TTS, only the hovered paragraph.
            This makes reading longer label-texts much easier.
            Needs this Osara-Issue to be done, if this is possible in the first place:
              https://github.com/jcsteh/osara/issues/961
  - Hovered-ACC-Message: when doing tabbing, the entire message will be read AND the one from hovering.
                        the one from hovering should only be read, if the mouse moved onto a ui-element
  - Images: dragging for accessibility, let the dragging-destination be chosen via Ctrl+Tab and Ctrl+Shift+Tab and Ctrl+Enter to drop it into the destination ui-element
  - General: acc-messages returned by the manage-functions are not sent to the screenreader for some reasons, like "pressed" in buttons
  - DropZones: the target should be notified, which ui-element had been dragged to it
  - InputBox:
    - Done: #1 Length of visible text isn't properly calculated for non-mono-fonts, especially when typing jjjj and iiii a lot
    - Done: #2 Fast moving the mouse over the middle of the textselection(the point, where it springs from)
               while text selection offsets the text-selection by one or more characters
    - #3 Redraw it in more pretty
    - Done #4 Caption still missing
    - Done #5 Scaling must be done
    - #6 hasfocus isn't working
    - Done #7 cursor isn't drawn when at the left edge of the boundary-box
    - #8 Ctrl+left/right only jumps to non-alphanumeric characters, not to switches between alphanumeric and non-alphanumeric characters
    - #9 Ctrl+Shift+left/Ctrl+Shift+right doesn't work yet
  
!!For 10k-UI-Elements(already been tested)!!  
  - Gui_Manage
    -- check for y-coordinates first, then for x-coordinates
    -- only run manage-function of focused and hovered ui-element
  - Gui_Draw
    -- optimize drawing of only visible ui-elements
    
    
--]]
--XX,YY=reaper.GetMousePosition()
--gfx.ext_retina = 0

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

reagirl.UI_Element_NextLineY=1 -- don't change
reagirl.UI_Element_NextLineX=10 -- don't change
reagirl.Font_Size=16

reagirl.mouse={}
reagirl.mouse.down=false
reagirl.mouse.downtime=os.clock()
reagirl.mouse.x=gfx.mouse_x
reagirl.mouse.y=gfx.mouse_y
reagirl.mouse.dragged=false


function reagirl.FormatNumber(n, p)
  -- by cfillion
  local p = (math.log(math.abs(n), 10) // 1) + (p or 3) + 1
  return ('%%.%dg'):format(p):format(n)
end

function string.has_control(String)
  if type(String)~="string" then error("bad argument #1, to 'has_control' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%c")~=nil
end

function string.has_alphanumeric_plus_underscore(String)
  if type(String)~="string" then error("bad argument #1, to 'has_control' (string expected, got "..type(source_string)..")", 2) end
  return String:match("[%w%_]")~=nil
end

function string.has_alphanumeric(String)
  if type(String)~="string" then error("bad argument #1, to 'has_alphanumeric' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%w")~=nil
end

function string.has_non_alphanumeric(String)
  if type(String)~="string" then error("bad argument #1, to 'has_non_alphanumeric' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%w")==nil
end

function string.has_letter(String)
  if type(String)~="string" then error("bad argument #1, to 'has_letter' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%a")~=nil
end

function string.has_digits(String)
  if type(String)~="string" then error("bad argument #1, to 'has_digits' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%d")~=nil
end

function string.has_printables(String)
  if type(String)~="string" then error("bad argument #1, to 'has_printables' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%g")~=nil
end

function string.has_uppercase(String)
  if type(String)~="string" then error("bad argument #1, to 'has_uppercase' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%u")~=nil
end

function string.has_lowercase(String)
  if type(String)~="string" then error("bad argument #1, to 'has_lowercase' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%l")~=nil
end

function string.has_space(String)
  if type(String)~="string" then error("bad argument #1, to 'has_space' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%s")~=nil
end

function string.has_hex(String)
  if type(String)~="string" then error("bad argument #1, to 'has_hex' (string expected, got "..type(source_string)..")", 2) end
  return String:match("%x")~=nil
end

function string.utf8_sub(source_string, startoffset, endoffset)
  -- written by CFillion for his Interactive ReaScript-Tool, available in the ReaTeam-repository(install via ReaPack)
  -- thanks for allowing me to use it :)
  startoffset = utf8.offset(source_string, startoffset)
  if not startoffset then return '' end -- i is out of bounds

  if endoffset and (endoffset > 0 or endoffset < -1) then
    endoffset = utf8.offset(source_string, endoffset + 1)
    if endoffset then endoffset = endoffset - 1 end
  end

  return string.sub(source_string, startoffset, endoffset)
end

function string.utf8_len(source_string)
  if type(source_string)~="string" then error("bad argument #1, to 'utf8_len' (string expected, got "..type(source_string)..")", 2) end
  return utf8.len(source_string)
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

function reagirl.Gui_PreventScrollingForOneCycle(keyboard, mousewheel_swipe, scroll_buttons)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_PreventScrollingForOneCycle</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Gui_PreventScrollingForOneCycle(optional boolean keyboard, optional boolean mousewheel_swipe, optional boolean scroll_buttons)</functioncall>
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
  if scroll_buttons~=nil and type(scroll_buttons)~="boolean" then error("Gui_PreventScrollingForOneCycle: param #3 - must be either nil or a a boolean") end
  
  if mousewheel_swipe~=nil and reagirl.Scroll_Override_MouseWheel~=true then
    reagirl.Scroll_Override_MouseWheel=mousewheel_swipe
  end
  if keyboard~=nil and reagirl.Scroll_Override~=true then 
    reagirl.Scroll_Override=keyboard
  end
  if scroll_buttons~=nil and reagirl.Scroll_Override_ScrollButtons~=true then 
    reagirl.Scroll_Override_ScrollButtons=scroll_buttons
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

function reagirl.Gui_PreventEnterForOneCycle()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_PreventEnterForOneCycle</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Gui_PreventEnterForOneCycle()</functioncall>
  <description>
    Prevents the user from hitting the enter-key for one cycle.
  </description>
  <chapter_context>
    UI Elements
  </chapter_context>
  <tags>gui, set, override, prevent, enter key, escape</tags>
</US_DocBloc>
--]]
  reagirl.Gui_PreventEnterForOneCycle_State=true
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
  -- rescales window and gui, if the scaling changes
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
        reagirl.Image_ReloadImage_Scaled(reagirl.Elements[i]["Guid"])
      end
    end
    reagirl.Gui_ForceRefresh(1)
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
  <functioncall>reagirl.Gui_AtExit(optional function run_func)</functioncall>
  <description>
    Adds a function that shall be run when the gui is closed with reagirl.Gui_Close()
    
    Good to do clean up or committing of settings.
  </description>
  <parameters>
    optional function run_func - a function, that shall be run when the gui closes; nil to remove the function
  </parameters>
  <chapter_context>
    Gui
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, atexit, gui, function</tags>
</US_DocBloc>
]]
  if run_func~=nil and type(run_func)~="function" then error("AtExit: param #1 - must be a function", -2) return end
  reagirl.AtExit_RunFunc=run_func
end

function reagirl.AtEnter(run_func)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AtEnter</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.AtEnter(optional function run_func)</functioncall>
  <description>
    Adds a function that shall be run when someone hits Enter while the gui is opened.
  </description>
  <parameters>
    function run_func - a function, that shall be run when the user hits enter while gui is open; nil, removes the function
  </parameters>
  <chapter_context>
    Gui
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>gfx, functions, atenter, gui, function</tags>
</US_DocBloc>
]]
  if run_func~=nil and type(run_func)~="function" then error("AtEnter: param #1 - must be a function", -2) return end
  reagirl.AtEnter_RunFunc=run_func
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
  if reagirl.Window_CurrentScale==nil then reagirl.Window_CurrentScale=scale end
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
    if size~=nil then size=size*reagirl.Window_GetCurrentScale() end
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
  reagirl.Gui_ForceRefresh(2)
  
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
  return reagirl.IsWindowOpen_attribute==true
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
  if reagirl.Gui_IsOpen()==false then return end
  if reagirl.NewUI~=false then reagirl.NewUI=false reagirl.Elements.FocusedElement=1 end
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
      if Key==1752132965.0 then reagirl.MoveItAllUp=0 reagirl.Gui_ForceRefresh(3) end -- home
      if Key==6647396.0 then MoveItAllUp_Delta=0 reagirl.MoveItAllUp=gfx.h-reagirl.BoundaryY_Max reagirl.Gui_ForceRefresh(4) end -- end
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
  
  if reagirl.Gui_PreventEnterForOneCycle_State~=true then
    if Key==13 then 
      if reagirl.AtEnter_RunFunc~=nil then reagirl.AtEnter_RunFunc() end
    end -- esc closes window
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
  if reagirl.Windows_OldH~=gfx.h then reagirl.Windows_OldH=gfx.h reagirl.Gui_ForceRefresh(5) end
  if reagirl.Windows_OldW~=gfx.w then reagirl.Windows_OldW=gfx.w reagirl.Gui_ForceRefresh(6) end
  
  if reagirl.ui_element_selected==nil then 
    reagirl.ui_element_selected="first selected"
  else
    reagirl.ui_element_selected="selected"
  end
  -- Tab-key - next ui-element
  if gfx.mouse_cap&8==0 and Key==9 then 
    local old_selection=reagirl.Elements.FocusedElement
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
      reagirl.Gui_ForceRefresh(7) 
      if old_selection~=reagirl.Elements.FocusedElement then
        reagirl.ui_element_selected="first selected"
      else
        reagirl.ui_element_selected="selected"
      end
    end
  end
  if reagirl.Elements["FocusedElement"]>#reagirl.Elements then reagirl.Elements["FocusedElement"]=1 end
  
  -- Shift+Tab-key - previous ui-element
  if gfx.mouse_cap&8==8 and Key==9 then 
    local old_selection=reagirl.Elements.FocusedElement
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
      reagirl.Gui_ForceRefresh(8) 
      if old_selection~=reagirl.Elements.FocusedElement then
        reagirl.ui_element_selected="first selected"
      else
        reagirl.ui_element_selected="selected"
      end
    end
  end
  if reagirl.Elements["FocusedElement"]<1 then reagirl.Elements["FocusedElement"]=#reagirl.Elements end
  
  -- Space-Bar "clicks" currently focused ui-element
  if Key==32 then reagirl.Elements[reagirl.Elements["FocusedElement"]]["clicked"]=true end
  
  
  -- [[ click management-code]]
  local clickstate, specific_clickstate, mouse_cap, click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel = reagirl.Mouse_GetCap(5, 10)
  
  -- finds out also, which ui-element shall be seen as clicked(only the last ui-element within click-area will be seen as clicked)
  -- changes the selected ui-element when clicked AND shows tooltip
  local Scroll_Override_ScrollButtons=0
  if reagirl.Scroll_Override_ScrollButtons==true then Scroll_Override_ScrollButtons=4 end
  reagirl.UI_Elements_HoveredElement=-1
  for i=#reagirl.Elements-Scroll_Override_ScrollButtons, 1, -1 do
    if reagirl.Elements[i]["hidden"]~=true then
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
          if Window_State&8==8 then
            reaper.TrackCtl_SetToolTip(reagirl.Elements[i]["Description"], XX+15, YY+10, true)
          end
          
          if reagirl.SetPosition_MousePositionY~=gfx.mouse_y 
          and reagirl.SetPosition_MousePositionY~=gfx.mouse_x 
          and reagirl.Elements[i]["AccHoverMessage"]~=nil then
            --reaper.osara_outputMessage(reagirl.Elements[i]["AccHoverMessage"])
            --reagirl.SetPosition_MousePositionX=-1
            --reagirl.SetPosition_MousePositionY=-1
          end
          
          --if reaper.osara_outputMessage~=nil then reaper.osara_outputMessage(reagirl.Elements[i]["Text"],2--[[:utf8_sub(1,20)]]) end
         end
         
         -- focused/clicked ui-element-management
         if (specific_clickstate=="FirstCLK") and reagirl.Elements[i]["IsDecorative"]==false then
           if i~=reagirl.Elements["FocusedElement"] then
             init_message=reagirl.Elements[i]["Name"].." "..reagirl.Elements[i]["GUI_Element_Type"]:sub(1,-1).." "
             helptext=reagirl.Elements[i]["Description"]..", "..reagirl.Elements[i]["AccHint"]
           end
           
           -- set found ui-element as focused and clicked
           local old_selection=reagirl.Elements.FocusedElement
             reagirl.Elements["FocusedElement"]=i
           if old_selection~=reagirl.Elements.FocusedElement then
             reagirl.ui_element_selected="first selected"
           else
             reagirl.ui_element_selected="selected"
           end
           reagirl.Elements[i]["clicked"]=true
           reagirl.UI_Element_SetFocusRect()
           reagirl.Gui_ForceRefresh(9) 
         end
         found_element=i
         break
      end
    end
  end
  if reagirl.SetPosition_MousePositionY~=gfx.mouse_y and reagirl.SetPosition_MousePositionY~=gfx.mouse_x then
    if reagirl.UI_Elements_HoveredElement~=-1 and reagirl.UI_Elements_HoveredElement~=reagirl.UI_Elements_HoveredElement_Old then
      if reaper.osara_outputMessage~=nil then
        if reagirl.Elements[reagirl.UI_Elements_HoveredElement]["AccHoverMessage"]~=nil then
          reaper.osara_outputMessage(reagirl.Elements[reagirl.UI_Elements_HoveredElement]["AccHoverMessage"])
        else
          reaper.osara_outputMessage(reagirl.Elements[reagirl.UI_Elements_HoveredElement]["Name"])
        end
      end
    end
  end
  
  --[[context menu]]
  -- show context-menu if the last defer-loop had a right-click onto a ui-element
  local ContextShow
  if reagirl.UI_Elements_HoveredElement~=-1 and reagirl.ContextMenuClicked==true then
    gfx.x=gfx.mouse_x
    gfx.y=gfx.mouse_y
    if reagirl.Elements[reagirl.UI_Elements_HoveredElement]["ContextMenu"]~=nil then
      local selection=gfx.showmenu(reagirl.Elements[reagirl.UI_Elements_HoveredElement]["ContextMenu"])
      
      if selection>0 then
        reagirl.Elements[reagirl.UI_Elements_HoveredElement]["ContextMenuFunction"](reagirl.Elements[reagirl.UI_Elements_HoveredElement]["Guid"], math.tointeger(selection))
      end
    end
    -- workaround to prevent, that the menu is shown twice in a row
    ContextShow=true
  end
  reagirl.ContextMenuClicked=nil
  -- if rightclicked on a ui-element, signal that the next defer-loop(after gui-refresh) shall show a context-menu
  if ContextShow~=true and reagirl.ContextMenuClicked~=true and reagirl.UI_Elements_HoveredElement~=-1 and gfx.mouse_cap==2 then
    reagirl.ContextMenuClicked=true
  end
  reagirl.UI_Elements_HoveredElement_Old=reagirl.UI_Elements_HoveredElement
  
  --[[dropdown-menu]]
  local retval=gfx.getdropfile(0)
  local count=0
  local files={}
  if retval>0 then
    while gfx.getdropfile(count)==1 do
      retval, files[count+1]=gfx.getdropfile(count)
      count=count+1
    end
    gfx.getdropfile(-1)
  end
  if #files>0 and reagirl.UI_Elements_HoveredElement~=-1 and reagirl.Elements[reagirl.UI_Elements_HoveredElement]["DropZoneFunction"]~=nil then 
    reagirl.Elements[reagirl.UI_Elements_HoveredElement]["DropZoneFunction"](reagirl.Elements[reagirl.UI_Elements_HoveredElement]["Guid"], files)
  end
  
  -- run all gui-element-management functions once. They shall decide, if a refresh is needed, provide the osara-screenreader-message and everything
  -- this is also the code, where a clickstate of a selected ui-element is interpreted
  --reaper.ClearConsole()
  for i=#reagirl.Elements, 1, -1 do
    if reagirl.Elements[i]["hidden"]~=true then
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
          local selected="not selected"
          if reagirl.Elements.FocusedElement==i then selected=reagirl.ui_element_selected end
          local cur_message, refresh=reagirl.Elements[i]["func_manage"](i, selected,
            reagirl.UI_Elements_HoveredElement==i,
            specific_clickstate,
            gfx.mouse_cap,
            {click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel},
            reagirl.Elements[i]["Name"],
            reagirl.Elements[i]["Description"], 
            math.tointeger(x2+MoveItAllRight),
            math.tointeger(y2+MoveItAllUp),
            math.tointeger(w2),
            math.tointeger(h2),
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
          --print("MASSAGE: "..message)
          reaper.osara_outputMessage(reagirl.osara_init_message..""..init_message.." "..message.." "..helptext,3)
          reagirl.old_osara_message=message
          reagirl.osara_init_message=""
        end
        if refresh==true then reagirl.Gui_ForceRefresh(10) end
      end
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
    
    for i=1, #reagirl.Elements, 1 do
      if reagirl.Elements[i]["hidden"]~=true then
        local x2, y2, w2, h2
        local w_add, h_add
        if reagirl.Elements[i]["GUI_Element_Type"]=="Tabs" then
          w_add=reagirl.Elements[i]["bg_w"]
          h_add=reagirl.Elements[i]["bg_h"]
        end
        if w_add==nil then w_add=0 end
        if h_add==nil then h_add=0 end
        if reagirl.Elements[i]["x"]<0 then x2=gfx.w+(reagirl.Elements[i]["x"]*scale) else x2=reagirl.Elements[i]["x"]*scale end
        if reagirl.Elements[i]["y"]<0 then y2=gfx.h+(reagirl.Elements[i]["y"]*scale) else y2=reagirl.Elements[i]["y"]*scale end
        
        --if reagirl.Elements[i]["w"]<0 then w2=gfx.w-(x2+reagirl.Elements[i]["w"]*scale) else w2=reagirl.Elements[i]["w"]*scale end
        --print2(w_add)
        if reagirl.Elements[i]["w"]<0 then w2=gfx.w+(-x2+(reagirl.Elements[i]["w"]+w_add)*scale) else w2=(reagirl.Elements[i]["w"]+w_add)*scale end
        if reagirl.Elements[i]["h"]<0 then h2=gfx.h+(-y2+(reagirl.Elements[i]["h"]+h_add)*scale) else h2=(reagirl.Elements[i]["h"]+h_add)*scale end

  
        local MoveItAllUp=reagirl.MoveItAllUp  
        local MoveItAllRight=reagirl.MoveItAllRight
        if reagirl.Elements[i]["sticky_y"]==true then MoveItAllUp=0 end
        if reagirl.Elements[i]["sticky_x"]==true then MoveItAllRight=0 end
        
        -- run the draw-function of the ui-element
        
        -- the following lines shall limit drawing on only visible areas. However, when non-resized images are used, the width and height don't match and therefor the image might disappear when scrolling
        --if (x2+MoveItAllRight>=0 and x2+MoveItAllRight<=gfx.w)       and (y2+MoveItAllUp>=0    and y2+MoveItAllUp<=gfx.h) 
        --or (x2+MoveItAllRight+w2>=0 and x2+MoveItAllRight+w2<=gfx.w) and (y2+MoveItAllUp+h2>=0 and y2+MoveItAllUp+h2<=gfx.h) then
        
        if (((x2+reagirl.MoveItAllRight>0 and x2+reagirl.MoveItAllRight<=gfx.w) 
        or (x2+w2+reagirl.MoveItAllRight>0 and x2+w2+reagirl.MoveItAllRight<=gfx.w) 
        or (x2+reagirl.MoveItAllRight<=0 and x2+w2+reagirl.MoveItAllRight>=gfx.w))
        and ((y2+reagirl.MoveItAllUp>=0 and y2+reagirl.MoveItAllUp<=gfx.h)
        or (y2+h2+reagirl.MoveItAllUp>=0 and y2+h2+reagirl.MoveItAllUp<=gfx.h)
        or (y2+reagirl.MoveItAllUp<=0 and y2+h2+reagirl.MoveItAllUp>=gfx.h))) or i>#reagirl.Elements-4
        then
        --]]
   --     print_update((x2+reagirl.MoveItAllRight>=0 and x2+reagirl.MoveItAllRight<=gfx.w), x2+MoveItAllRight, (x2+reagirl.MoveItAllRight+w2>=0 and x2+reagirl.MoveItAllRight+w2<=gfx.w))
        --AAAAA=AAAAA+1
          local selected="not selected"
          if reagirl.Elements.FocusedElement==i then selected=reagirl.ui_element_selected end
          local message=reagirl.Elements[i]["func_draw"](i, selected,
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
        end -- draw_only_necessary-elements
        if reagirl.Elements["FocusedElement"]~=-1 and reagirl.Elements["FocusedElement"]==i then
          --if reagirl.Elements[i]["GUI_Element_Type"]=="DropDownMenu" then --  if w2<20 then w2=20 end end
          local r,g,b,a=gfx.r,gfx.g,gfx.b,gfx.a
          local dest=gfx.dest
          gfx.dest=-1
          gfx.set(0.7,0.7,0.7,0.8)
          local _,_,_,_,x,y,w,h=reagirl.UI_Element_GetFocusRect()
          --print_update(scale, x, y, w, h, reagirl.Font_Size)
          if reagirl.Focused_Rect_Override==nil then
            local a=gfx.a
            gfx.a=0.4
            gfx.rect((x2+MoveItAllRight-3), (y2+MoveItAllUp-3), (w2+7), (h2+6), 0)
            gfx.a=a
          else
            local a=gfx.a
            gfx.a=0.4
            gfx.rect(reagirl.Elements["Focused_x"], reagirl.Elements["Focused_y"], reagirl.Elements["Focused_w"], reagirl.Elements["Focused_h"], 0)
            gfx.a=a
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
                reagirl.SetPosition_MousePositionX=gfx.mouse_x
                reagirl.SetPosition_MousePositionY=gfx.mouse_y
              end
            end
          end
        end
      end
    end
  end
  
  if reagirl.Draggable_Element~=nil then
    if gfx.mouse_x~=reagirl.Elements[reagirl.Draggable_Element]["mouse_x"] or
       gfx.mouse_y~=reagirl.Elements[reagirl.Draggable_Element]["mouse_y"] then
      local imgw, imgh = gfx.getimgdim(reagirl.Elements[reagirl.Draggable_Element]["Image_Storage"])
      local oldgfxa=gfx.a
      gfx.a=0.7
      gfx.blit(reagirl.Elements[reagirl.Draggable_Element]["Image_Storage"],1,0,0,0,imgw,imgh,gfx.mouse_x,gfx.mouse_y,50,50)
      gfx.a=oldgfxa
      reagirl.Elements[reagirl.Draggable_Element]["mouse_x"]=-1
      reagirl.Elements[reagirl.Draggable_Element]["mouse_y"]=-1
    end
  else
    reagirl.Gui_ForceRefreshState=false
  end
  
  reagirl.Scroll_Override_ScrollButtons=nil
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
  <functioncall>reagirl.UI_Element_SetFocusRect(boolean override, integer x, integer y, integer w, integer h)</functioncall>
  <description>
    sets the rectangle for focused ui-element. Can be used for custom ui-element, who need to control the focus-rectangle due some of their own ui-elements incorporated, like options in radio-buttons, etc.
  </description>
  <parameters>
    boolean override - I forgot...
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
  <tags>ui-elements, set, focus rectangle</tags>
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
  <tags>ui-elements, get, focus rectangle</tags>
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
  <tags>ui-elements, is outside window</tags>
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
    if reagirl.Elements[count]~=nil and reagirl.Elements[count].IsDecorative==false and reagirl.Elements[count]["hidden"]~=true then 
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
    if reagirl.Elements[count].IsDecorative==false and reagirl.Elements[count]["hidden"]~=true then return count, reagirl.Elements[count].Guid end
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
  <tags>ui-elements, get, type</tags>
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
  <functioncall>string description = reagirl.UI_Element_GetSetDescription(string element_id, boolean is_set, string description)</functioncall>
  <description>
    gets/sets the description of the ui-element
  </description>
  <retvals>
    string description - the description of the ui-element
  </retvals>
  <parameters>
    string element_id - the id of the element, whose description you want to get/set
    boolean is_set - true, set the description; false, only retrieve description
    string description - the description of the ui-element
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, description</tags>
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

function reagirl.UI_Element_GetSet_ContextMenu(element_id, is_set, menu, menu_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSet_ContextMenu</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string menu, function menu_function = reagirl.UI_Element_GetSet_ContextMenu(string element_id, boolean is_set, string menu, function menu_function)</functioncall>
  <description>
    gets/sets the context-menu and context-menu-run-function of a ui-element.
    
    Setting this will show a context-menu, when the user rightclicks the ui-element.
    Drop a hint in the accessibility-hint of the ui-element, so blind users know, a context-menu exists.
    
    The menu_function will be called with two parameters: 
      string element_id - the guid of the ui-element, whose context-menu has been used
      integer selection - the index of the menu-item selected by the user
  </description>
  <retvals>
    optional string menu - the currently set menu for this ui-element; nil, no menu is available
    optional function menu_function - a function that is called, after the user made a context-menu-selection; nil, no such function added to this ui-element
  </retvals>
  <parameters>
    string element_id - the id of the element, whose context-menu you want to get/set
    boolean is_set - true, set the menu; false, only retrieve the current menu
    string menu - sets a menu for this ui-element
    function menu_function - sets a function that is called, after the user made a context-menu-selection
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, context menu</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_GetSet_ContextMenu: #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_GetSet_ContextMenu: #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetSet_ContextMenu: #1 - no such ui-element", 2) end
  if type(is_set)~="boolean" then error("UI_Element_GetSet_ContextMenu: #2 - must be a boolean", 2) end
  if is_set==true and type(menu)~="string" then error("UI_Element_GetSet_ContextMenu: #3 - must be a string when #2==true", 2) end
  if is_set==true and type(menu_function)~="function" then error("UI_Element_GetSet_ContextMenu: #4 - must be a string when #2==true", 2) end
  
  if is_set==true then
    reagirl.Elements[element_id]["ContextMenu"]=menu
    reagirl.Elements[element_id]["ContextMenuFunction"]=menu_function
  end
  return reagirl.Elements[element_id]["ContextMenu"], reagirl.Elements[element_id]["ContextMenuFunction"]
end

function reagirl.UI_Element_GetSet_DropZoneFunction(element_id, is_set, dropzone_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSet_DropZoneFunction</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>function dropzone_function = reagirl.UI_Element_GetSet_DropZoneFunction(string element_id, boolean is_set, string dropzone_function)</functioncall>
  <description>
    gets/sets the dropzone-run-function of a ui-element.
    
    This will be called, when the user drag'n'drops files onto this ui-element.
    Drop a hint in the accessibility-hint of the ui-element, so blind users know, a dropzone exists.
    
    The dropzone_function will be called with two parameters: 
      string element_id - the guid of the ui-element, whose context-menu has been used
      table filenames - a table with all dropped filenames
  </description>
  <retvals>
    function dropzone_function - a function that is called, after the drag'n'dropped files onto this ui-element
  </retvals>
  <parameters>
    string element_id - the id of the element, whose description you want to get/set
    boolean is_set - true, set the dropzone-function; false, only retrieve the dropzone-function
    function dropzone_function - sets a function that is called, after the drag'n'dropped files onto this ui-element
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, dropzone</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_GetSet_DropZoneFunction: #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_GetSet_DropZoneFunction: #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetSet_DropZoneFunction: #1 - no such ui-element", 2) end
  if type(is_set)~="boolean" then error("UI_Element_GetSet_DropZoneFunction: #2 - must be a boolean", 2) end
  if is_set==true and type(dropzone_function)~="function" then error("UI_Element_GetSet_DropZoneFunction: #3 - must be a string when #2==true", 2) end
  
  if is_set==true then
    reagirl.Elements[element_id]["DropZoneFunction"]=dropzone_function
  end
  return reagirl.Elements[element_id]["DropZoneFunction"]
end

function reagirl.UI_Element_GetSetCaption(element_id, is_set, name)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSetCaption</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string caption = reagirl.UI_Element_GetSetCaption(string element_id, boolean is_set, string caption)</functioncall>
  <description>
    gets/sets the caption of the ui-element
  </description>
  <retvals>
    string caption - the caption of the ui-element
  </retvals>
  <parameters>
    string element_id - the id of the element, whose caption you want to get/set
    boolean is_set - true, set the caption; false, only retrieve the current caption
    string caption - the caption of the ui-element
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, caption</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_GetSetCaption: #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_GetSetCaption: #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetSetCaption: #1 - no such ui-element", 2) end
  if type(is_set)~="boolean" then error("UI_Element_GetSetCaption: #2 - must be a boolean", 2) end
  if is_set==true and type(name)~="string" then error("UI_Element_GetSetCaption: #3 - must be a string when #2==true", 2) end
  
  if is_set==true then
    reagirl.Elements[element_id]["Name"]=name
  end
  return reagirl.Elements[element_id]["Name"]
end

function reagirl.UI_Element_GetSetHidden(element_id, is_set, hidden)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_GetSetHidden</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>boolean hidden = reagirl.UI_Element_GetSetHidden(string element_id, boolean is_set, boolean hidden)</functioncall>
  <description>
    gets/sets the hidden-state of the ui-element
  </description>
  <retvals>
    boolean hidden - the hidden-state of the ui-element
  </retvals>
  <parameters>
    string element_id - the id of the element, whose name you want to get/set
    boolean is_set - true, set the hidden-state; false, only retrieve current hidde-state
    boolean hidden - true, set to hidden; false, set to visible
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, hidden, visibility</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_GetSetHidden: #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_GetSetHidden: #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]==nil then error("UI_Element_GetSetHidden: #1 - no such ui-element", 2) end
  if type(is_set)~="boolean" then error("UI_Element_GetSetHidden: #2 - must be a boolean", 2) end
  if is_set==true and type(hidden)~="boolean" then error("UI_Element_GetSetHidden: #3 - must be a boolean when #2==true", 2) end
  
  if is_set==true then
    if hidden==true then
      reagirl.Elements[element_id]["hidden"]=true
    else
      reagirl.Elements[element_id]["hidden"]=nil
    end
  end
  return reagirl.Elements[element_id]["hidden"]==true
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
    boolean is_set - true, set the name; false, only retrieve current stickyness of the ui-element
    boolean sticky_x - true, x-movement is sticky; false, x-movement isn't sticky
    boolean sticky_y - true, y-movement is sticky; false, y-movement isn't sticky
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, sticky</tags>
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
    boolean is_set - true, set the accessibility_hint; false, only retrieve the current accessibility-message
    string accessibility_hint - the accessibility_hint of the ui-element
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, accessibility_hint</tags>
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

function reagirl.UI_Element_IsElementAtMousePosition(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_IsElementAtMousePosition</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>boolean element_is_at_position = reagirl.UI_Element_IsElementAtMousePosition(string element_id)</functioncall>
  <description>
    returns, if ui-element with element_id is at mouse-position
  </description>
  <retvals>
    boolean element_is_at_position - true, ui-element is at mouse-position; false, ui-element is not at mouse-position
  </retvals>
  <parameters>
    string element_id - the id of the element, of which you want to know, if it's at mouse-position
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, get, is at position</tags>
</US_DocBloc>
]]
  local x, y, real_x, real_y = reagirl.UI_Element_GetSetPosition(element_id, false)
  local w, h, real_w, real_h =reagirl.UI_Element_GetSetDimension(element_id, false)
  return gfx.mouse_x>=real_x and gfx.mouse_x<=real_x+real_w and gfx.mouse_y>=real_y and gfx.mouse_y<=real_y+real_h
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
  <functioncall>integer x, integer y, integer actual_x, integer actual_y = reagirl.UI_Element_GetSetPosition(string element_id, boolean is_set, integer x, integer y)</functioncall>
  <description>
    gets/sets the position of the ui-element
  </description>
  <retvals>
    integer x - the x-position of the ui-element
    integer y - the y-position of the ui-element
    integer actual_x - the actual current x-position resolved to the anchor-position including scaling and scroll-offset
    integer actual_y - the actual current y-position resolved to the anchor-position including scaling and scroll-offset
  </retvals>
  <parameters>
    string element_id - the id of the element, whose position you want to get/set
    boolean is_set - true, set the position; false, only retrieve the current position
    integer x - the x-position of the ui-element
    integer y - the y-position of the ui-element
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, position</tags>
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
  local scale=reagirl.Window_GetCurrentScale()
  if reagirl.Elements[element_id]["x"]<0 then x2=gfx.w+reagirl.Elements[element_id]["x"]*scale else x2=reagirl.Elements[element_id]["x"]*scale end
  if reagirl.Elements[element_id]["y"]<0 then y2=gfx.h+reagirl.Elements[element_id]["y"]*scale else y2=reagirl.Elements[element_id]["y"]*scale end
  
  return reagirl.Elements[element_id]["x"], reagirl.Elements[element_id]["y"], x2+reagirl.MoveItAllRight, y2+reagirl.MoveItAllUp
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
    integer actual_w - the actual current w-size resolved to the anchor-position including scaling
    integer actual_h - the actual current h-size resolved to the anchor-position including scaling
  </retvals>
  <parameters>
    string element_id - the id of the element, whose dimension you want to get/set
    boolean is_set - true, set the dimension; false, only retrieve current dimensions
    integer w - the w-size of the ui-element
    integer h - the h-size of the ui-element
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, dimension</tags>
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
  local scale=reagirl.Window_GetCurrentScale()
  if reagirl.Elements[element_id]["x"]<0 then x2=gfx.w+reagirl.Elements[element_id]["x"]*scale else x2=reagirl.Elements[element_id]["x"]*scale end
  if reagirl.Elements[element_id]["y"]<0 then y2=gfx.h+reagirl.Elements[element_id]["y"]*scale else y2=reagirl.Elements[element_id]["y"]*scale end
  if reagirl.Elements[element_id]["w"]<0 then w2=gfx.w-x2+reagirl.Elements[element_id]["w"]*scale else w2=reagirl.Elements[element_id]["w"]*scale end
  if reagirl.Elements[element_id]["h"]<0 then h2=gfx.h-y2+reagirl.Elements[element_id]["h"]*scale else h2=reagirl.Elements[element_id]["h"]*scale end
  
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
    boolean is_set - true, set the horizontal-offset; false, only retrieve current horizontal offset
    integer x_offset - the x-offset of all ui-elements
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, horizontal offset</tags>
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
    boolean is_set - true, set the vertical-offset; false, only retrieve current vertical offset
    integer y_offset - the y-offset of all ui-elements
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, vertical offset</tags>
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
    boolean is_set - true, set the run_function; false, only retrieve the current run_function
    func run_function - the run function of the ui-element
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, get, run function</tags>
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
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_Move</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.UI_Element_Move(string element_id, optional integer x, optional integer y, optional integer w, optional integer h)</functioncall>
  <description>
    moves a ui-element to a new position
    
    You can omit the parameters, that you want to keep at the same position/dimension
  </description>
  <parameters>
    string element_id - the id of the element that you want to move
    optional integer x - the new x-position of the ui-element
    optional integer y - the new y-position of the ui-element
    optional integer w - the new width of the ui-element
    optional integer h - the new width of the ui-element
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, move</tags>
</US_DocBloc>
]]
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
  reagirl.Gui_ForceRefresh(11)
end

function reagirl.UI_Element_SetSelected(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_SetSelected</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.UI_Element_SetSelected(string element_id)</functioncall>
  <description>
    Sets a ui-element selected. It will have a focus-rectangle around it.
  </description>
  <parameters>
    string element_id - the id of the element that you want to set to selected
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, selected</tags>
</US_DocBloc>
]]
  if type(element_id)~="string" then error("UI_Element_SetSelected: #1 - must be a guid as string", 2) end
  element_id=reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==nil then error("UI_Element_SetSelected: #1 - no such ui-element", 2) end
  
  reagirl.Elements["FocusedElement"]=element_id
  reagirl.Gui_ForceRefresh(12)
end

function reagirl.UI_Element_Remove(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>UI_Element_Remove</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.UI_Element_Remove(string element_id)</functioncall>
  <description>
    Removes a ui-element.
  </description>
  <parameters>
    string element_id - the id of the element that you want to remove
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <target_document>ReaGirl_Docs</target_document>
  <source_document>reagirl_GuiEngine.lua</source_document>
  <tags>ui-elements, set, remove</tags>
</US_DocBloc>
]]
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
  reagirl.Gui_ForceRefresh(13)
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
    end
  end  
  reagirl.UI_Element_NextLineY=0
  reagirl.UI_Element_NextX_Default=x
  
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
  reagirl.Elements[slot]["z_buffer"]=128
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

  if selected~="not selected" and (((clicked=="FirstCLK" or clicked=="DBLCLK" )and mouse_cap&1==1) or Key==32) then 
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
  if refresh==true then reagirl.Gui_ForceRefresh(14) end
  local unchecked="checked"
  if element_storage["checked"]==false then unchecked="unchecked" end
  element_storage["AccHoverMessage"]=element_storage["Name"].." "..unchecked
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
  <functioncall>reagirl.Checkbox_SetTopBottom(string element_id, boolean top, boolean bottom)</functioncall>
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
    reagirl.Gui_ForceRefresh(15)
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

function reagirl.Checkbox_SetCheckState(element_id, check_state)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Checkbox_SetCheckState</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Checkbox_SetCheckState(string element_id, boolean check_state)</functioncall>
  <description>
    Sets a checkbox's state of the checkbox.
  </description>
  <parameters>
    string element_id - the guid of the checkbox, whose checkbox-state you want to set
    boolean check_state - true, set checkbox checked; false, set checkbox unchecked
  </parameters>
  <chapter_context>
    Checkbox
  </chapter_context>
  <tags>checkbox, set, check-state</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Checkbox_SetCheckState: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Checkbox_SetCheckState: param #1 - must be a valid guid", 2) end
  if type(check_state)~="boolean" then error("Checkbox_SetCheckState: param #2 - must be a boolean", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Checkbox_SetCheckState: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Checkbox" then
    error("Checkbox_SetCheckState: param #1 - ui-element is not a checkbox", 2)
  else
    reagirl.Elements[element_id]["checked"]=check_state
    reagirl.Gui_ForceRefresh(16)
  end
end

function reagirl.Checkbox_GetCheckState(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Checkbox_GetCheckState</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>boolean check_state = reagirl.Checkbox_GetCheckState(string element_id)</functioncall>
  <description>
    Gets a checkbox's rounded edges state.
  </description>
  <parameters>
    string element_id - the guid of the checkbox, whose rounded edges-state you want to get
  </parameters>
  <retvals>
    boolean check_state - true, checkbox is checked; false, the checkbox is unchecked
  </retvals>
  <chapter_context>
    Checkbox
  </chapter_context>
  <tags>checkbox, get, check-state</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Checkbox_GetCheckState: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Checkbox_GetCheckState: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Checkbox" then
    error("Checkbox_GetCheckState: param #1 - ui-element is not a checkbox", 2)
  else
    return reagirl.Elements[element_id]["checked"]
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
    reagirl.Gui_ForceRefresh(17)
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
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  gfx.x=x
  gfx.y=y
  h=h-5
  local scale=reagirl.Window_CurrentScale
  
  local top=element_storage["top_edge"]
  local bottom=element_storage["bottom_edge"]
  gfx.set(0.584)
  reagirl.RoundRect(x,y,h+2,h+2,1*scale, 1,1, false, false, false, false)
  
  gfx.set(0.2725490196078431)
  reagirl.RoundRect(x+scale,y+scale,h+2-scale*2,h+2-scale*2,scale, 0, 1, false, false, false, false)
  
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
  
  gfx.x=1+x+h+2+6
  gfx.y=1+y+2+offset
  gfx.set(0.2)
  gfx.drawstr(name)
  
  if element_storage["IsDecorative"]==false then gfx.set(0.8) else gfx.set(0.6) end
  gfx.x=x+h+2+6
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
  <tags>ui-elements, get, current position, width, height</tags>
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

function reagirl.NextLine(y_offset)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>NextLine</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.NextLine(integer y_offset)</functioncall>
  <description>
    Starts a new line, when autopositioning ui-elements using the add-functions.
  </description>
  <parameters>
    integer y_offset - an additional y-offset, by which the next line shall be moved downwards; nil, for no offset
  </parameters>
  <chapter_context>
    UI Elements
  </chapter_context>
  <tags>ui-elements, set, next line</tags>
</US_DocBloc>
--]]
  if y_offset~=nil and math.type(y_offset)~="integer" then error("Button_Add: param #1 - must be either nil or an integer", 2) end
  if y_offset==nil then y_offset=0 end
  local slot=reagirl.UI_Element_GetNextFreeSlot()
  if reagirl.UI_Element_NextLineY==0 then
    for i=slot-1, 1, -1 do
      if reagirl.Elements[i]["IsDecorative"]==false then
        --print2(reagirl.Elements[i]["h"])
        --reagirl.UI_Element_NextLineY=reagirl.UI_Element_NextLineY+reagirl.Elements[i]["h"]+1
        local x2, y2, w2, h2
        if reagirl.Elements[i]["y"]<0 then y2=gfx.h+(reagirl.Elements[i]["y"]) else y2=reagirl.Elements[i]["y"] end
        if reagirl.Elements[i]["h"]<0 then h2=gfx.h+(-y2+reagirl.Elements[i]["h"]) else h2=reagirl.Elements[i]["h"] end
        reagirl.UI_Element_NextLineY=reagirl.UI_Element_NextLineY+h2+1+reagirl.UI_Element_NextY_Margin+y_offset
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
    end
  end  
  reagirl.UI_Element_NextLineY=0
  reagirl.UI_Element_NextX_Default=x
  
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
  reagirl.Elements[slot]["z_buffer"]=128
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
    reagirl.Gui_ForceRefresh(18)
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
    reagirl.Gui_ForceRefresh(19)
  end
  return true
end

function reagirl.Button_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  local message=" "
  local refresh=false
  local oldpressed=element_storage["pressed"]
  
  if selected~="not selected" and Key==32 then 
    element_storage["pressed"]=true
    message=""
    reagirl.Gui_ForceRefresh(20)
  elseif selected~="not selected" and mouse_cap&1~=0 and gfx.mouse_x>x and gfx.mouse_y>y and gfx.mouse_x<x+w and gfx.mouse_y<y+h then
    local oldstate=element_storage["pressed"]
    element_storage["pressed"]=true
    if oldstate~=element_storage["pressed"] then
      reagirl.Gui_ForceRefresh(21)
    end
    message=""
  else
    local oldstate=element_storage["pressed"]
    element_storage["pressed"]=false
    if oldstate~=element_storage["pressed"] then
      reagirl.Gui_ForceRefresh(22)
    end
  end
  if oldpressed==true and element_storage["pressed"]==false and (mouse_cap&1==0 and Key~=32) then
    if element_storage["run_function"]~=nil then element_storage["run_function"](element_storage["Guid"]) message="pressed" end
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



function reagirl.InputBox_Add(x, y, w, caption, Cap_width, meaningOfUI_Element, Default, run_function_enter, run_function_type)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>InputBox_Add</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string inputbox_guid = reagirl.InputBox_Add(integer x, integer y, integer w, string caption, optional integer cap_width, string meaningOfUI_Element, optional string Default, function run_function_enter, function run_function_type)</functioncall>
  <description>
    Adds an inputbox to a gui.
    
    You can autoposition the inputbox by setting x and/or y to nil, which will position the new inputbox after the last ui-element.
    To autoposition into the next line, use reagirl.NextLine()
    
    The caption will be shown before the inputbox.
    
    Unlike other ui-elements, this one has the option for two run_functions, one for when the user hits enter in the inputbox and one for when the user types anything into the inputbox.
  </description>
  <parameters>
    optional integer x - the x position of the slider in pixels; negative anchors the slider to the right window-side; nil, autoposition after the last ui-element(see description)
    optional integer y - the y position of the slider in pixels; negative anchors the slider to the bottom window-side; nil, autoposition after the last ui-element(see description)
    string caption - the caption of the slider
    optional integer cap_width - the width of the caption to set the actual slider to a fixed position; nil, put slider directly after caption
    string meaningOfUI_Element - a description for accessibility users
    optional string Default - the "typed text" that the inputbox shall contain
    function run_function_enter - a function that is run when the user hits enter in the inputbox
    function run_function_type - a function that is run when the user types into the inputbox
  </parameters>
  <retvals>
    string inputbox_guid - a guid that can be used for altering the inputbox-attributes
  </retvals>
  <chapter_context>
    InputBox
  </chapter_context>
  <tags>inputbox, add</tags>
</US_DocBloc>
--]]
  if x~=nil and math.type(x)~="integer" then error("InputBox_Add: param #1 - must be an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("InputBox_Add: param #2 - must be an integer", 2) end
  if math.type(w)~="integer" then error("InputBox_Add: param #3 - must be an integer", 2) end
  if type(caption)~="string" then error("InputBox_Add: param #4 - must be a string", 2) end
  if Cap_width~=nil and math.type(Cap_width)~="integer" then error("InputBox_Add: param #5 - must be wither nil or an integer", 2) end
  if type(meaningOfUI_Element)~="string" then error("InputBox_Add: param #6 - must be a string", 2) end
  if type(Default)~="string" then error("InputBox_Add: param #7 - must be a string", 2) end
  if run_function_enter~=nil and type(run_function_enter)~="function" then error("InputBox_Add: param #8 - must be a function", 2) end
  if run_function_type~=nil and type(run_function_type)~="function" then error("InputBox_Add: param #9 - must be a function", 2) end
  
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
    end
  end  
  reagirl.UI_Element_NextLineY=0
  reagirl.UI_Element_NextX_Default=x
  
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0, 1)
  local tx,ty=gfx.measurestr(caption)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  
  table.insert(reagirl.Elements, slot, {})
  reagirl.Elements[slot]["Guid"]=reaper.genGuid("")
  reagirl.Elements[slot]["GUI_Element_Type"]="Edit"
  reagirl.Elements[slot]["Name"]=caption
  reagirl.Elements[slot]["cap_w"]=math.tointeger(tx)+10
  reagirl.Elements[slot]["Description"]=meaningOfUI_Element
  reagirl.Elements[slot]["IsDecorative"]=false
  reagirl.Elements[slot]["AccHint"]="Hit Enter to type text."
  reagirl.Elements[slot]["z_buffer"]=128
  reagirl.Elements[slot]["Cap_width"]=Cap_width
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["w"]=w
  reagirl.Elements[slot]["h"]=math.tointeger(ty)+4
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false
  Default=string.gsub(Default, "\n", "")
  Default=string.gsub(Default, "\r", "")
  reagirl.Elements[slot]["Text"]=Default
  reagirl.Elements[slot]["draw_offset"]=0
  reagirl.Elements[slot]["draw_offset_end"]=10
  reagirl.Elements[slot]["cursor_offset"]=0
  reagirl.Elements[slot]["selection_startoffset"]=1
  reagirl.Elements[slot]["selection_endoffset"]=1
  
  reagirl.Elements[slot].hasfocus=false
  reagirl.Elements[slot].hasfocus_old=false
  reagirl.Elements[slot].cursor_offset=1
  reagirl.Elements[slot].draw_offset=reagirl.Elements[slot].cursor_offset
  reagirl.Elements[slot].draw_offset_end=reagirl.Elements[slot].cursor_offset
  --reagirl.Elements[slot].draw_max=reagirl.Elements[slot].draw_offset+math.floor(reagirl.Elements[slot].w/gfx.measurechar("65")-1)-1-reagirl.Elements[slot].draw_offset
  reagirl.Elements[slot].selection_startoffset=reagirl.Elements[slot].cursor_offset
  reagirl.Elements[slot].selection_endoffset=reagirl.Elements[slot].cursor_offset
  
  reagirl.Elements[slot]["func_manage"]=reagirl.InputBox_Manage
  reagirl.Elements[slot]["func_draw"]=reagirl.InputBox_Draw
  reagirl.Elements[slot]["run_function"]=run_function_enter
  reagirl.Elements[slot]["run_function_type"]=run_function_type
  reagirl.Elements[slot]["userspace"]={}
  reagirl.InputBox_Calculate_DrawOffset(true, reagirl.Elements[slot])
  
  --print_alt(reagirl.Elements[slot-1]["Name"], reagirl.Elements[slot-1]["y"], reagirl.Elements[slot]["y"])
  
  return reagirl.Elements[slot]["Guid"]
end



function reagirl.InputBox_OnMouseDown(mouse_cap, element_storage)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  element_storage.hasfocus_old=element_storage.hasfocus
  element_storage.hasfocus=gfx.mouse_x>=element_storage.x2 and gfx.mouse_x<element_storage.x2+element_storage.w2 and
                           gfx.mouse_y>=element_storage.y2 and gfx.mouse_y<element_storage.y2+element_storage.h2
  reagirl.mouse.down=true
  reagirl.mouse.x=gfx.mouse_x
  reagirl.mouse.y=gfx.mouse_y
  
  if element_storage.hasfocus==true then
    if mouse_cap&8==0 then
      element_storage.cursor_offset=reagirl.InputBox_GetTextOffset(gfx.mouse_x,gfx.mouse_y, element_storage)
      element_storage.cursor_startoffset=element_storage.cursor_offset
      element_storage.clicked1=true
      if element_storage.cursor_offset==-2 then 
        element_storage.cursor_offset=element_storage.Text:utf8_len() 
        element_storage.selection_startoffset=element_storage.cursor_offset
        element_storage.selection_endoffset=element_storage.cursor_offset
      else
        element_storage.selection_startoffset=element_storage.cursor_offset
        element_storage.selection_endoffset=element_storage.cursor_offset
      end
    elseif mouse_cap&8==8 then
      local newoffs, startoffs, endoffs=reagirl.InputBox_GetTextOffset(gfx.mouse_x,gfx.mouse_y, element_storage)
      --print_update(newoffs, startoffs, endoffs)
      if newoffs>0 then
        if newoffs<element_storage.cursor_offset then 
          element_storage.selection_startoffset=newoffs
          element_storage.selection_endoffset=element_storage.cursor_offset
          reagirl.mouse.dragged=true
        elseif newoffs>element_storage.cursor_offset then
          element_storage.selection_startoffset=element_storage.cursor_offset
          element_storage.selection_endoffset=newoffs
          reagirl.mouse.dragged=true
        else
          element_storage.cursor_offset=newoffs
          element_storage.selection_startoffset=element_storage.cursor_offset
          element_storage.selection_endoffset=element_storage.cursor_offset
        end
      elseif newoffs==-2 then 
        element_storage.selection_startoffset=element_storage.cursor_offset
        element_storage.selection_endoffset=endoffs
        reagirl.mouse.dragged=true
      elseif newoffs==-1 then 
        element_storage.selection_startoffset=startoffs
        element_storage.selection_endoffset=element_storage.cursor_offset
        reagirl.mouse.dragged=true
      end
    end
  end
end

function reagirl.InputBox_GetTextOffset(x,y,element_storage)
  -- BUGGY!
  -- Offset is off
  local dpi_scale = reagirl.Window_GetCurrentScale()
  local cap_w
  if element_storage["Cap_width"]==nil then
    cap_w=gfx.measurestr(element_storage["Name"])
    cap_w=math.tointeger(cap_w)+dpi_scale*5+5*dpi_scale
  else
    cap_w=element_storage["Cap_width"]*dpi_scale
  end
  
  local startoffs=element_storage.x2+cap_w
  local cursoffs=element_storage.draw_offset
  
  local textw=gfx.measurechar(65)
  local x2, w2
  if element_storage["x"]<0 then x2=gfx.w+element_storage["x"]*dpi_scale else x2=element_storage["x"]*dpi_scale end
  if element_storage["w"]<0 then w2=gfx.w-x2+element_storage["w"]*dpi_scale else w2=element_storage["w"]*dpi_scale end
  w2=w2-cap_w
  
  -- if click==outside of left edge of the inputbox
  if x<startoffs then return -1, element_storage.draw_offset, element_storage.draw_offset+math.floor(element_storage.w2/textw) end
  
  local draw_offset=dpi_scale*5
  for i=element_storage.draw_offset, element_storage.Text:utf8_len() do --draw_offset+math.floor(element_storage.w2/textw) do
    --gfx.rect((i*textw),0,(i*textw),10,1)
    if draw_offset+textw>w2 then break end -- this line is buggy, it doesn't go off, when auto-width is set and the user tries to move selection outside the right edge of the boundary box
    local textw=gfx.measurestr(element_storage.Text:utf8_sub(i,i))
    
    --print_update(textw)
    if x>=startoffs and x<=startoffs+textw then
      return cursoffs, element_storage.draw_offset, element_storage.draw_offset+math.floor(element_storage.w2/textw)
    end
    cursoffs=cursoffs+1
    startoffs=startoffs+textw
    draw_offset=draw_offset+textw
  end
  --]]
  
  -- if click==outside of right edge of the inputbox
  return -2, element_storage.draw_offset, element_storage.draw_offset_end+1--element_storage.draw_offset+math.floor(element_storage.w/textw)
end

function reagirl.InputBox_OnMouseMove(mouse_cap, element_storage)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  if element_storage.hasfocus==false then return end
  local newoffs, startoffs, endoffs=reagirl.InputBox_GetTextOffset(gfx.mouse_x, gfx.mouse_y, element_storage)
  --print_update(newoffs, startoffs, endoffs)
  if newoffs>0 then -- buggy, resettet die Selection, wenn man "zurück" geht nach scrolling am Ende der Boundary Box
    if newoffs<element_storage.cursor_startoffset then
      element_storage.selection_startoffset=newoffs
      element_storage.selection_endoffset=element_storage.cursor_startoffset
    elseif newoffs>element_storage.cursor_startoffset then
      element_storage.selection_endoffset=newoffs
      element_storage.selection_startoffset=element_storage.cursor_startoffset
    elseif newoffs==element_storage.cursor_offset then
      element_storage.selection_endoffset=newoffs
      element_storage.selection_startoffset=newoffs
    end
    
    element_storage.cursor_offset=newoffs
  elseif newoffs==-1 then
    -- when dragging is outside of left edge
    element_storage.cursor_offset=startoffs-1
    if element_storage.cursor_offset<0 then element_storage.cursor_offset=0 end
    
    element_storage.draw_offset=element_storage.draw_offset-1
    if element_storage.draw_offset<0 then 
      element_storage.draw_offset=0
    end
    
    if startoffs<element_storage.cursor_startoffset then
      element_storage.selection_startoffset=element_storage.draw_offset
      element_storage.selection_endoffset=element_storage.cursor_startoffset
    end
    
    reagirl.InputBox_Calculate_DrawOffset(true, element_storage)
  elseif newoffs==-2 then
    --print_update("HUCH"..reaper.time_precise())
    -- when dragging is outside the right edge
    element_storage.cursor_offset=endoffs+1
    if element_storage.cursor_offset>element_storage.Text:utf8_len() then element_storage.cursor_offset=element_storage.Text:utf8_len() end
    
    element_storage.draw_offset_end=element_storage.draw_offset_end+1
    if element_storage.draw_offset_end>element_storage.Text:utf8_len() then 
      element_storage.draw_offset_end=element_storage.Text:utf8_len()
    end

    if endoffs>element_storage.cursor_startoffset then
      element_storage.selection_startoffset=element_storage.cursor_startoffset
      element_storage.selection_endoffset=element_storage.draw_offset_end
    end
    
    
    
    reagirl.InputBox_Calculate_DrawOffset(false, element_storage)
  end
  reagirl.mouse.dragged=true
end

function reagirl.InputBox_OnMouseUp(mouse_cap, element_storage)
  reagirl.mouse.down=false
  reagirl.mouse.downtime=os.clock()
  
  if element_storage.hasfocus==false then
    element_storage.draw_offset=1
    element_storage.selection_startoffset=element_storage.cursor_offset
    element_storage.selection_endoffset=element_storage.cursor_offset
  end
  if reagirl.mouse.dragged~=true and element_storage.hasfocus==true then
    element_storage.selection_startoffset=element_storage.cursor_offset
    element_storage.selection_endoffset=element_storage.cursor_offset
    reagirl.mouse.dragged=false
  end
end

function reagirl.InputBox_GetPreviousPOI(element_storage)
  for i=element_storage.cursor_offset-1, 0, -1 do
    if element_storage.Text:utf8_sub(i,i):has_alphanumeric_plus_underscore()==false then
      return i
    end
  end
  return 0
end

function reagirl.InputBox_GetNextPOI(element_storage)
  for i=element_storage.cursor_offset, element_storage.Text:utf8_len() do
    if element_storage.Text:utf8_sub(i,i):has_alphanumeric_plus_underscore()==false then
      return i-1
    end
  end
  return element_storage.Text:utf8_len()
end

function reagirl.InputBox_OnMouseDoubleClick(mouse_cap, element_storage)
  local newoffs, startoffs, endoffs=reagirl.InputBox_GetTextOffset(gfx.mouse_x, gfx.mouse_y, element_storage)
  if element_storage.hasfocus==true and newoffs~=-1 then
    element_storage.selection_startoffset=reagirl.InputBox_GetPreviousPOI(element_storage)
    element_storage.selection_endoffset=reagirl.InputBox_GetNextPOI(element_storage)
  else
    element_storage.selection_startoffset=0
    element_storage.selection_endoffset=element_storage.Text:utf8_len()
  end
end

function reagirl.InputBox_GetShownTextoffsets(x,y,element_storage)
  local textw=gfx.measurechar(65)
  return element_storage.draw_offset, element_storage.draw_offset+math.floor(element_storage.w/textw)
end

function reagirl.InputBox_ConsolidateCursorPos(element_storage)
  if element_storage.cursor_offset>=element_storage.draw_offset_end-3 then
    element_storage.draw_offset_end=element_storage.cursor_offset+3
    reagirl.InputBox_Calculate_DrawOffset(false, element_storage)
  elseif element_storage.cursor_offset<element_storage.draw_offset-1 then
    element_storage.draw_offset=element_storage.cursor_offset-3
    if element_storage.draw_offset<0 then element_storage.draw_offset=0 end
    reagirl.InputBox_Calculate_DrawOffset(true, element_storage)
  end
  --[[
  if element_storage.cursor_offset>element_storage.draw_offset+element_storage.draw_offset_end then
    element_storage.draw_offset=element_storage.cursor_offset-element_storage.draw_offset_end+1
    if element_storage.draw_offset<0 then element_storage.draw_offset=0 end
  elseif element_storage.cursor_offset<element_storage.draw_offset then
    element_storage.draw_offset=element_storage.cursor_offset
  end
  --]]
end

function reagirl.InputBox_OnTyping(Key, Key_UTF, mouse_cap, element_storage)
  if Key_UTF~=0 then Key=Key_UTF end
  local refresh=false
  
  if Key==-1 then
  elseif Key==13 then
    if element_storage["run_function"]~=nil then
      element_storage["run_function"](element_storage["Guid"], element_storage.Text)
    end
  elseif Key==1885824110.0 then
    -- Pg down
  elseif Key==1885828464.0 then
    -- Pg up
  elseif Key==8 then
    -- Backspace
    if element_storage.cursor_offset>=0 then
      if element_storage.selection_startoffset~=element_storage.selection_endoffset then
        element_storage.Text=element_storage.Text:utf8_sub(1, element_storage.selection_startoffset)..element_storage.Text:utf8_sub(element_storage.selection_endoffset+1, -1)
        element_storage.cursor_offset=element_storage.selection_startoffset
      else
        element_storage.Text=element_storage.Text:utf8_sub(1, element_storage.selection_startoffset-1)..element_storage.Text:utf8_sub(element_storage.selection_endoffset+1, -1)
        element_storage.cursor_offset=element_storage.selection_startoffset-1
      end
      element_storage.selection_startoffset=element_storage.cursor_offset
      element_storage.selection_endoffset=element_storage.cursor_offset
      reagirl.InputBox_ConsolidateCursorPos(element_storage)
    end
  elseif Key==1919379572.0 then
    -- right arrow key
    if mouse_cap&4==0 then
      element_storage.cursor_offset=element_storage.cursor_offset+1
      if element_storage.cursor_offset<0 then element_storage.cursor_offset=0 
      elseif element_storage.cursor_offset>element_storage.Text:utf8_len() then
        element_storage.cursor_offset=element_storage.Text:utf8_len()
      end
      if mouse_cap&8==8 then
        if element_storage.selection_endoffset<element_storage.cursor_offset then
          element_storage.selection_endoffset=element_storage.cursor_offset
        else
          element_storage.selection_startoffset=element_storage.cursor_offset
        end
      elseif element_storage.cursor_offset>0 then
        element_storage.selection_startoffset=element_storage.cursor_offset
        element_storage.selection_endoffset=element_storage.cursor_offset
      end
    elseif mouse_cap&4==4 then
      -- ctrl+right
      local found=element_storage.cursor_offset
      for i=element_storage.cursor_offset+1, element_storage.Text:utf8_len() do
        if element_storage.Text:utf8_sub(i,i):has_alphanumeric_plus_underscore()==false or element_storage.Text:utf8_sub(i,i):has_alphanumeric_plus_underscore()~=element_storage.Text:utf8_sub(i+1,i+1):has_alphanumeric_plus_underscore() then
          found=i
          break
        end
      end

      if mouse_cap&8==8 then
        if element_storage.selection_endoffset<found then
          element_storage.selection_endoffset=found
        elseif element_storage.selection_startoffset<found then
          element_storage.selection_startoffset=found
        end
      end
      element_storage.cursor_offset=found
    end

    --reagirl.InputBox_ConsolidateCursorPos(element_storage)
    if element_storage.draw_offset_end<=element_storage.cursor_offset then
      element_storage.draw_offset_end=element_storage.cursor_offset+3
      reagirl.InputBox_Calculate_DrawOffset(false, element_storage)
    end
  elseif Key==1818584692.0 then
    -- left arrow key
    if mouse_cap&4==0 then
      element_storage.cursor_offset=element_storage.cursor_offset-1
      if element_storage.cursor_offset<0 then element_storage.cursor_offset=0 
      elseif element_storage.cursor_offset>element_storage.Text:utf8_len() then
        element_storage.cursor_offset=element_storage.Text:utf8_len()
      end
      if mouse_cap&8==8 then
        if element_storage.selection_startoffset>element_storage.cursor_offset then
          element_storage.selection_startoffset=element_storage.cursor_offset
        else
          element_storage.selection_endoffset=element_storage.cursor_offset
        end
      elseif element_storage.cursor_offset>0 then
        element_storage.selection_startoffset=element_storage.cursor_offset
        element_storage.selection_endoffset=element_storage.cursor_offset
      end
    elseif mouse_cap&4==4 then
      local found=element_storage.cursor_offset
      for i=element_storage.cursor_offset-1, 0, -1 do
        if element_storage.Text:utf8_sub(i,i):has_alphanumeric_plus_underscore()==false or element_storage.Text:utf8_sub(i,i):has_alphanumeric_plus_underscore()~=element_storage.Text:utf8_sub(i+1,i+1):has_alphanumeric_plus_underscore() then
          found=i
          break
        end
      end
      if mouse_cap&8==8 then
        if element_storage.selection_startoffset>found then
          element_storage.selection_startoffset=found
        elseif element_storage.selection_endoffset>found then
          element_storage.selection_endoffset=found
        end
      end
      element_storage.cursor_offset=found
    end

    --reagirl.InputBox_ConsolidateCursorPos(element_storage)
    if element_storage.draw_offset>element_storage.cursor_offset then
      element_storage.draw_offset=element_storage.cursor_offset
      reagirl.InputBox_Calculate_DrawOffset(true, element_storage)
    end
    
  elseif Key==30064 then
    -- up arrow key
    
  elseif Key==1685026670.0 then
    -- down arrow key
    
  elseif Key>=26161 and Key<=26169 then
    -- F1 through F9
  elseif Key>=6697264.0 and Key<=6697270.0 then 
    -- F10 through F16
  elseif Key==27 then
    -- esc Key
  elseif Key==9 then
    -- Tab Key
  elseif Key==1752132965.0 then
    -- Home Key
    element_storage.cursor_offset=0
    element_storage.draw_offset=element_storage.cursor_offset+1
    if mouse_cap&8==0 then
      element_storage.selection_startoffset=0
      element_storage.selection_endoffset=0
    elseif mouse_cap&8==8 then
      element_storage.selection_endoffset=element_storage.selection_startoffset
      element_storage.selection_startoffset=0
    end
    reagirl.InputBox_Calculate_DrawOffset(true, element_storage)
  elseif Key==6647396.0 then
    -- End Key
    element_storage.cursor_offset=element_storage.Text:utf8_len()
    
    if mouse_cap&8==0 then
      element_storage.selection_startoffset=element_storage.cursor_offset
      element_storage.selection_endoffset=element_storage.Text:utf8_len()
    elseif mouse_cap&8==8 then
      element_storage.selection_startoffset=element_storage.selection_endoffset
      element_storage.selection_endoffset=element_storage.Text:utf8_len()
    end
    reagirl.InputBox_ConsolidateCursorPos(element_storage)
  elseif Key==3 then
    -- Copy
    if reaper.CF_SetClipboard~=nil then
      reaper.CF_SetClipboard(element_storage.Text:utf8_sub(element_storage.selection_startoffset+1, element_storage.selection_endoffset))
    end
  elseif Key==24 then
    -- Cut
    if reaper.CF_SetClipboard~=nil then
      reaper.CF_SetClipboard(element_storage.Text:utf8_sub(element_storage.selection_startoffset+1, element_storage.selection_endoffset))
      if element_storage.selection_startoffset~=element_storage.selection_endoffset then
         element_storage.Text=element_storage.Text:utf8_sub(1, element_storage.selection_startoffset)..element_storage.Text:utf8_sub(element_storage.selection_endoffset+1, -1)
         element_storage.cursor_offset=element_storage.selection_startoffset
         element_storage.selection_startoffset=element_storage.cursor_offset
         element_storage.selection_endoffset=element_storage.cursor_offset
      end
    end
  elseif Key==22 then
    -- Paste Cmd+V
    if reaper.CF_GetClipboard~=nil then
      local text=string.gsub(reaper.CF_GetClipboard(), "\n", "")
      text=string.gsub(text, "\r", "")
      --print2(text..1)
      element_storage.Text=element_storage.Text:utf8_sub(1, element_storage.selection_startoffset)..text..element_storage.Text:utf8_sub(element_storage.selection_endoffset+1, -1)
      element_storage.cursor_offset=element_storage.cursor_offset+text:utf8_len()
      element_storage.selection_startoffset=element_storage.cursor_offset
      element_storage.selection_endoffset=element_storage.cursor_offset
      reagirl.InputBox_ConsolidateCursorPos(element_storage)
    end
  elseif Key==6579564.0 then
    -- Del Key
    if element_storage.selection_startoffset~=element_storage.selection_endoffset then
      element_storage.Text=element_storage.Text:utf8_sub(1, element_storage.selection_startoffset)..element_storage.Text:utf8_sub(element_storage.selection_endoffset+1, -1)
      element_storage.cursor_offset=element_storage.selection_startoffset
      element_storage.selection_startoffset=element_storage.cursor_offset
      element_storage.selection_endoffset=element_storage.cursor_offset
    else
      element_storage.Text=element_storage.Text:utf8_sub(1, element_storage.selection_startoffset)..element_storage.Text:utf8_sub(element_storage.selection_endoffset+2, -1)
    end
    reagirl.InputBox_ConsolidateCursorPos(element_storage)
  elseif Key==1 then
    element_storage.cursor_offset=element_storage.Text:utf8_len()
    element_storage.selection_startoffset=0
    element_storage.selection_endoffset=element_storage.cursor_offset
    reagirl.InputBox_ConsolidateCursorPos(element_storage)
  elseif Key~=0 then
    element_storage.Text=element_storage.Text:utf8_sub(1, element_storage.selection_startoffset)..utf8.char(Key)..element_storage.Text:utf8_sub(element_storage.selection_endoffset+1, -1)
    element_storage.cursor_offset=element_storage.selection_startoffset+1
    element_storage.selection_startoffset=element_storage.cursor_offset
    element_storage.selection_endoffset=element_storage.cursor_offset
    --offset_s,offset_e=reagirl.InputBox_GetShownTextoffsets(x,y,element_storage)
    --if element_storage.cursor_offset==offset_e-1 then element_storage.draw_offset=element_storage.draw_offset+1 end
    reagirl.InputBox_ConsolidateCursorPos(element_storage)
    reagirl.InputBox_Calculate_DrawOffset(true, element_storage)
  end
  
  if Key>0 then 
    if element_storage["run_function_type"]~=nil then
      element_storage["run_function_type"](element_storage["Guid"], element_storage.Text)
    end
    refresh=true 
  end
  
  return refresh
end

function reagirl.InputBox_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  local refresh=false

  if reaper.osara_outputMessage~=nil then
    reagirl.Gui_PreventEnterForOneCycle()
    if selected~="not selected" and (Key==13 or (mouse_cap&1==1 and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h)) then
      local retval, text = reaper.GetUserInputs("Enter or edit the text", 1, ",extrawidth=150", element_storage.Text)
      if retval==true then
        refresh=true
        element_storage.Text=text
        if element_storage["run_function"]~=nil then
          element_storage["run_function"](element_storage["Guid"], element_storage.Text)
        end
      end
    end
  else
    if element_storage["run_function"]~=nil then
      reagirl.Gui_PreventEnterForOneCycle()
    end
    if selected=="not selected" then
      element_storage.hasfocus=false
    end
    if element_storage.cursor_offset==-1 and clicked~="DBLCLK" then 
      element_storage.cursor_offset=element_storage.Text:utf8_len() 
    end
    if selected=="first selected" then
      element_storage["cursor_offset"]=element_storage["Text"]:utf8_len()
      element_storage["draw_offset_end"]=element_storage["Text"]:utf8_len()
      element_storage["selection_endoffset"]=element_storage["Text"]:utf8_len()
      element_storage["selection_startoffset"]=0
      reagirl.InputBox_Calculate_DrawOffset(false, element_storage)
      element_storage.hasfocus=true
    elseif selected=="not selected" then
      element_storage["selection_endoffset"]=element_storage["cursor_offset"]
      element_storage["selection_startoffset"]=element_storage["cursor_offset"]
    end
    gfx.setfont(1, "Arial", reagirl.Font_Size, 0)
  
    
    if selected~="not selected" and (gfx.mouse_x>=x and gfx.mouse_y>=y and gfx.mouse_x<=x+w and gfx.mouse_y<=y+h) then 
      -- mousewheel scroll the text inside the input-box via hmousewheel(doesn't work properly, yet)
      reagirl.Gui_PreventScrollingForOneCycle(true, true, false)
      if mouse_attributes[6]<0 then 
        if mouse_attributes[6]<-300 then factor=10 else factor=1 end  
        element_storage["draw_offset"]=element_storage["draw_offset"]-factor
        if element_storage["draw_offset"]<1 then 
          element_storage["draw_offset"]=1 
        end 
        refresh=true 
        reagirl.InputBox_Calculate_DrawOffset(true, element_storage)
      end
      
      if mouse_attributes[6]>0 then 
        if mouse_attributes[6]>300 then factor=10 else factor=1 end
        element_storage["draw_offset"]=element_storage["draw_offset"]+factor
        if element_storage["draw_offset"]>element_storage["Text"]:utf8_len() then 
          element_storage["draw_offset"]=element_storage["Text"]:utf8_len()
        end 
        refresh=true 
        reagirl.InputBox_Calculate_DrawOffset(true, element_storage)
      end
      element_storage.x2=x
      element_storage.y2=y
      element_storage.w2=w
      element_storage.h2=h
      refreshme=clicked
      -- mouse management
      if selected~="not selected" and clicked=="FirstCLK" then 
        element_storage["hasfocus"]=true
        if reagirl.mouse.down==false then
          reagirl.InputBox_OnMouseDown(mouse_cap, element_storage) 
          refresh=true
        end
      elseif selected~="not selected" and clicked=="DBLCLK" then
        reagirl.InputBox_OnMouseDoubleClick(mouse_cap, element_storage)
        refresh=true
        element_storage["hasfocus"]=true
      elseif selected~="not selected" and reagirl.mouse.down==true then
        reagirl.InputBox_OnMouseUp(mouse_cap, element_storage)
        refresh=true
        element_storage["hasfocus"]=true
      end
    end
    -- keyboard management
    if element_storage.hasfocus==true then
      local refresh2=reagirl.InputBox_OnTyping(Key, Key_UTF, mouse_cap, element_storage)
      if refresh~=true and refresh2==true then
        refresh=true
      end
    end
  end
  if selected~="not selected" and element_storage.clicked1==true and clicked=="DRAG" then --reagirl.mouse.down==true and clicked=="DRAG" then gfx.mouse_x~=reagirl.mouse.x or gfx.mouse_y~=reagirl.mouse.y then
    reagirl.InputBox_OnMouseMove(mouse_cap, element_storage)
    refresh=true
    element_storage["hasfocus"]=true
  end
  
  if mouse_cap==0 then
    element_storage.clicked1=nil
  end
  
  if element_storage.w2_old~=w then
    --reagirl.InputBox_Calculate_DrawOffset(false, element_storage)
    if element_storage.draw_offset<element_storage.cursor_offset then
      reagirl.InputBox_Calculate_DrawOffset(false, element_storage)
    else
      --element_storage.draw_offset=element_storage.cursor_offset
      reagirl.InputBox_Calculate_DrawOffset(true, element_storage)
    end
    refresh=true
  end
  element_storage.w2_old=w
  element_storage["AccHoverMessage"]=element_storage["Name"].." "..element_storage["Text"]
  if refresh==true then
    reagirl.Gui_ForceRefresh(23)
  end
end




function reagirl.InputBox_Calculate_DrawOffset(forward, element_storage)
  -- rewrite this, it doesn't work on different scaling....for some fucking reasoninputbox_onyping(
  
  -- it's probably because of x2 and w2 calculation
  -- maybe fixed now(?)
  -- no it's not...end isn't working properly
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  local dpi_scale = reagirl.Window_GetCurrentScale()
  --local cap_w=element_storage["cap_w"]
  local cap_w
  if element_storage["Cap_width"]==nil then
    cap_w=gfx.measurestr(element_storage["Name"])+dpi_scale*5
  else
    cap_w=element_storage["Cap_width"]*dpi_scale
  end
  
  if element_storage["x"]<0 then x2=gfx.w+element_storage["x"]*dpi_scale else x2=element_storage["x"]*dpi_scale end
  if element_storage["w"]<0 then w2=gfx.w-x2+element_storage["w"]*dpi_scale else w2=element_storage["w"]*dpi_scale end
  local w2=w2-cap_w
  local offset_me=dpi_scale*2
  --print_update(cap_w)
  if forward==true then
    -- forward calculation from offset
    for i=element_storage.draw_offset, element_storage.Text:utf8_len() do
      local x,y=gfx.measurestr(element_storage.Text:utf8_sub(i,i))
      offset_me=offset_me+x
      if offset_me>w2 then break else element_storage.draw_offset_end=i end
    end
  elseif forward==false then
    -- backwards calculation from offset_end
    for i=element_storage.draw_offset_end, 1, -1 do
      --offset_me=offset_me+dpi_scale*2
      local x,y=gfx.measurestr(element_storage.Text:utf8_sub(i,i))
      offset_me=offset_me+x
      if offset_me>w2 then break else element_storage.draw_offset=i end
    end
  end
end

function reagirl.InputBox_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  local dpi_scale=reagirl.Window_GetCurrentScale()
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  
  local cap_w
  if element_storage["Cap_width"]==nil then
    cap_w=gfx.measurestr(element_storage["Name"])
    cap_w=math.tointeger(cap_w)+dpi_scale*5
  else
    cap_w=element_storage["Cap_width"]*dpi_scale
  end
  
  -- draw caption
  gfx.x=x
  gfx.y=y
  gfx.set(0.2)
  gfx.drawstr(name)
  
  if element_storage["IsDecorative"]==false then gfx.set(0.8) else gfx.set(0.6) end
  gfx.x=x
  gfx.y=y+1
  gfx.drawstr(name)
  
  local textw=gfx.measurechar("65")-1
  
  -- draw rectangle around text
  gfx.set(0.59)
  reagirl.RoundRect(x+cap_w-2*dpi_scale, y, w-cap_w, math.tointeger(gfx.texth)+dpi_scale*2, 2*dpi_scale, 0, 1)
  
  gfx.set(0.234)
  reagirl.RoundRect(x+dpi_scale+cap_w-2*dpi_scale, y+dpi_scale, w-cap_w-dpi_scale-dpi_scale, math.tointeger(gfx.texth), 2*dpi_scale, 0, 1)
  
  
  -- draw text
  if element_storage["IsDecorative"]==false then gfx.set(0.8) else gfx.set(0.6) end
  gfx.x=x+cap_w+dpi_scale
  gfx.y=y+dpi_scale
  local draw_offset=0
  for i=element_storage.draw_offset, element_storage.draw_offset_end do
    local textw=gfx.measurestr(element_storage.Text:utf8_sub(i,i))
    if draw_offset+textw>w then break end
    if i>=element_storage.selection_startoffset+1 and i<=element_storage.selection_endoffset then
      reagirl.SetFont(1, "Arial", reagirl.Font_Size, 86)
    else
      reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
    end
    gfx.drawstr(element_storage.Text:utf8_sub(i,i))
    if selected~="not selected" and element_storage.hasfocus==true and element_storage.cursor_offset==i then 
      gfx.set(0.9843137254901961, 0.8156862745098039, 0)
      gfx.line(gfx.x, y+dpi_scale, gfx.x, y+gfx.texth-dpi_scale) 
      if element_storage.hasfocus==true then gfx.set(0.8) else gfx.set(0.5) end
    end
    draw_offset=draw_offset+textw
  end
  if selected~="not selected" and element_storage.cursor_offset==element_storage.draw_offset-1 then
    gfx.set(0.9843137254901961, 0.8156862745098039, 0)
    gfx.line(x+cap_w-dpi_scale, y+dpi_scale, x+cap_w-dpi_scale, y+gfx.texth) 
  end
end

function reagirl.InputBox_SetDisabled(element_id, state)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>InputBox_SetDisabled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.InputBox_SetDisabled(string element_id, boolean state)</functioncall>
  <description>
    Sets an inputbox as disabled(non clickable).
  </description>
  <parameters>
    string element_id - the guid of the inputbox, whose disability-state you want to set
    boolean state - true, the inputbox is disabled; false, the inputbox is not disabled.
  </parameters>
  <chapter_context>
    InputBox
  </chapter_context>
  <tags>inputbox, set, disabled</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("InputBox_SetDisabled: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("InputBox_SetDisabled: param #1 - must be a valid guid", 2) end
  if type(state)~="boolean" then error("InputBox_SetDisabled: param #2 - must be a boolean", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("InputBox_SetDisabled: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Edit" then
    error("InputBox_SetDisabled: param #1 - ui-element is not an input-box", 2)
  else
    reagirl.Elements[element_id]["IsDecorative"]=state
    reagirl.Gui_ForceRefresh(24)
  end
end

function reagirl.InputBox_GetDisabled(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>InputBox_GetDisabled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>boolean retval = reagirl.InputBox_GetDisabled(string element_id)</functioncall>
  <description>
    Gets an inputbox's disabled(non clickable)-state.
  </description>
  <parameters>
    string element_id - the guid of the inputbox, whose disability-state you want to get
  </parameters>
  <retvals>
    boolean state - true, the inputbox is disabled; false, the inputbox is not disabled.
  </retvals>
  <chapter_context>
    InputBox
  </chapter_context>
  <tags>inputbox, get, disabled</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("InputBox_GetDisabled: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("InputBox_GetDisabled: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Edit" then
    error("InputBox_GetDisabled: param #1 - ui-element is not an input-box", 2)
  else
    return reagirl.Elements[element_id]["IsDecorative"]
  end
end

function reagirl.InputBox_SetText(element_id, new_text)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>InputBox_SetText</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.InputBox_SetText(string element_id, string new_text)</functioncall>
  <description>
    Sets a new text of an inputbox.
    
    Will remove newlines from it.
  </description>
  <parameters>
    string element_id - the guid of the inputbox, whose disability-state you want to set
    string new_text - the new text for the inputbox
  </parameters>
  <chapter_context>
    InputBox
  </chapter_context>
  <tags>inputbox, set, text</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("InputBox_SetText: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("InputBox_SetText: param #1 - must be a valid guid", 2) end
  if type(new_text)~="string" then error("InputBox_SetText: param #2 - must be a string", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("InputBox_SetText: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Edit" then
    error("InputBox_SetText: param #1 - ui-element is not an input-box", 2)
  else
    new_text=string.gsub(new_text, "\n", "")
    new_text=string.gsub(new_text, "\r", "")
    reagirl.Elements[element_id]["Text"]=new_text
    reagirl.Elements[element_id]["cursor_offset"]=reagirl.Elements[element_id]["Text"]:utf8_len()
    reagirl.Elements[element_id]["draw_offset_end"]=reagirl.Elements[element_id]["cursor_offset"]
    reagirl.InputBox_Calculate_DrawOffset(false, reagirl.Elements[element_id])
    
    reagirl.Elements[element_id]["selection_endoffset"]=reagirl.Elements[element_id]["cursor_offset"]
    reagirl.Elements[element_id]["selection_startoffset"]=reagirl.Elements[element_id]["cursor_offset"]
    reagirl.Gui_ForceRefresh(25)
  end
end

function reagirl.InputBox_GetText(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>InputBox_GetText</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string text = reagirl.InputBox_GetText(string element_id)</functioncall>
  <description>
    Gets an inputbox's current text.
  </description>
  <parameters>
    string element_id - the guid of the inputbox, whose text you want to get
  </parameters>
  <retvals>
    string text - the text currently in the inputbox
  </retvals>
  <chapter_context>
    InputBox
  </chapter_context>
  <tags>inputbox, get, text</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("InputBox_GetDisabled: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("InputBox_GetDisabled: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Edit" then
    error("InputBox_GetDisabled: param #1 - ui-element is not an input-box", 2)
  else
    return reagirl.Elements[element_id]["Text"]
  end
end


function reagirl.InputBox_GetSelectedText(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>InputBox_GetSelectedText</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string text = reagirl.InputBox_GetSelectedText(string element_id)</functioncall>
  <description>
    Gets an inputbox's currently selected text.
  </description>
  <parameters>
    string element_id - the guid of the inputbox, whose selected text you want to get
  </parameters>
  <retvals>
    string text - the text currently selected in the inputbox
    integer selection_startoffset - the startoffset of the text-selection; -1, no text is selected
    integer selection_endoffset - the endoffset of the text-selection; -1, no text is selected
  </retvals>
  <chapter_context>
    InputBox
  </chapter_context>
  <tags>inputbox, get, selected, text</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("InputBox_GetSelectedText: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("InputBox_GetSelectedText: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Edit" then
    error("InputBox_GetSelectedText: param #1 - ui-element is not an input-box", 2)
  else
    if reagirl.Elements[element_id]["selection_startoffset"]~=reagirl.Elements[element_id]["selection_endoffset"] then
      return reagirl.Elements[element_id]["Text"]:utf8_sub(reagirl.Elements[element_id]["selection_startoffset"]+1, reagirl.Elements[element_id]["selection_endoffset"]), reagirl.Elements[element_id]["selection_startoffset"], reagirl.Elements[element_id]["selection_endoffset"]
    else
      return "", -1, -1
    end
  end
end

function reagirl.InputBox_GetCursorOffset(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>InputBox_GetCursorOffset</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string text = reagirl.InputBox_GetCursorOffset(string element_id)</functioncall>
  <description>
    Gets an inputbox's current cursor offset.
  </description>
  <parameters>
    string element_id - the guid of the inputbox, whose cursor offset you want to get
  </parameters>
  <retvals>
    integer cursor_offset - the offset the cursor has in the current text in the inputbox
  </retvals>
  <chapter_context>
    InputBox
  </chapter_context>
  <tags>inputbox, get, selected, text</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("InputBox_GetCursorOffset: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("InputBox_GetCursorOffset: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Edit" then
    error("InputBox_GetCursorOffset: param #1 - ui-element is not an input-box", 2)
  else
    return reagirl.Elements[element_id]["cursor_offset"]
  end
end

function reagirl.DropDownMenu_Add(x, y, w, caption, Cap_width, meaningOfUI_Element, menuItems, menuSelectedItem, run_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>DropDownMenu_Add</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string dropdown-menu_guid = reagirl.DropDownMenu_Add(optional integer x, optional integer y, integer w, string caption, optional integer Cap_width, string meaningOfUI_Element, table menuItems, integer menuSelectedItem, function run_function)</functioncall>
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
    optional integer Cap_width - the width of the caption to set the actual menu to a fixed position; nil, put menu directly after caption
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
  if Cap_width~=nil and math.type(Cap_width)~="integer" then error("DropDownMenu_Add: param #5 - must be wither nil or an integer", 2) end
  if type(meaningOfUI_Element)~="string" then error("DropDownMenu_Add: param #6 - must be a string", 2) end
  if type(menuItems)~="table" then error("DropDownMenu_Add: param #7 - must be a table", 2) end
  for i=1, #menuItems do
    menuItems[i]=tostring(menuItems[i])
  end
  if math.type(menuSelectedItem)~="integer" then error("DropDownMenu_Add: param #8 - must be an integer", 2) end
  if menuSelectedItem>#menuItems or menuSelectedItem<1 then error("DropDownMenu_Add: param #9 - no such menu-item", 2) end
  if run_function~=nil and type(run_function)~="function" then error("DropDownMenu_Add: param #10 - must be either nil or a function", 2) end
  
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
    end
  end  
  reagirl.UI_Element_NextLineY=0
  reagirl.UI_Element_NextX_Default=x
  
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
  reagirl.Elements[slot]["z_buffer"]=128
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["w"]=w
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0, 1)
  local tx,ty=gfx.measurestr(menuItems[menuSelectedItem])
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  reagirl.Elements[slot]["h"]=math.tointeger(ty+7)--math.tointeger(gfx.texth)
  reagirl.Elements[slot]["radius"]=2
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false
  reagirl.Elements[slot]["menuSelectedItem"]=menuSelectedItem
  reagirl.Elements[slot]["MenuEntries"]=menuItems
  reagirl.Elements[slot]["MenuCount"]=1
  reagirl.Elements[slot]["MenuCount"]=#menuItems
  reagirl.Elements[slot]["func_manage"]=reagirl.DropDownMenu_Manage
  reagirl.Elements[slot]["func_draw"]=reagirl.DropDownMenu_Draw
  reagirl.Elements[slot]["run_function"]=run_function
  reagirl.Elements[slot]["Cap_width"]=Cap_width
  reagirl.Elements[slot]["userspace"]={}
  return  reagirl.Elements[slot]["Guid"]
end


function reagirl.DropDownMenu_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  local cap_w=element_storage["cap_w"]
  if element_storage["Cap_width"]~=nil then
    cap_w=element_storage["Cap_width"]
  end
  cap_w=cap_w*reagirl.Window_GetCurrentScale()
  if selected~="not selected" then
    reagirl.UI_Element_SetFocusRect(true, x, y, w+5, h)
  end
  if w<50 then w=50 end
  local refresh=false
  if gfx.mouse_x>=x+cap_w and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    reagirl.Scroll_Override_MouseWheel=true
    if reagirl.MoveItAllRight_Delta==0 and reagirl.MoveItAllUp_Delta==0 then
      if mouse_attributes[5]<0 then element_storage["menuSelectedItem"]=element_storage["menuSelectedItem"]+1 refresh=true end
      if mouse_attributes[5]>0 then element_storage["menuSelectedItem"]=element_storage["menuSelectedItem"]-1 refresh=true end
      
      if element_storage["menuSelectedItem"]<1 then element_storage["menuSelectedItem"]=1 refresh=false end
      if element_storage["menuSelectedItem"]>element_storage["MenuCount"] then element_storage["menuSelectedItem"]=element_storage["MenuCount"] refresh=false end
      if refresh==true and element_storage["run_function"]~=nil then reagirl.Elements[element_id]["run_function"](element_storage["Guid"], element_storage["menuSelectedItem"], element_storage["MenuEntries"][element_storage["menuSelectedItem"]]) reagirl.Gui_ForceRefresh(26) refresh=false end
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
  if selected~="not selected" then
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
      --reagirl.Gui_ForceRefresh(27)
    --end
  end

  if selected~="not selected" then
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
    elseif selected~="not selected" and (clicked=="FirstCLK" and mouse_cap&1==1) and (gfx.mouse_x>=x+cap_w and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h) then
      element_storage["pressed"]=true
      collapsed=""
      --refresh=true
    else
      element_storage["pressed"]=false
    end
  end
  
  if refresh==true then 
    reagirl.Gui_ForceRefresh(28)
    if element_storage["run_function"]~=nil then 
      reagirl.Elements[element_id]["run_function"](element_storage["Guid"], element_storage["menuSelectedItem"], element_storage["MenuEntries"][element_storage["menuSelectedItem"]])
    end
  end
  element_storage["AccHoverMessage"]=element_storage["Name"].." "..element_storage["MenuEntries"][element_storage["menuSelectedItem"]]
  return element_storage["MenuEntries"][element_storage["menuSelectedItem"]]..". "..collapsed, refresh
end

function reagirl.DropDownMenu_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  local dpi_scale, state
  local dpi_scale=reagirl.Window_CurrentScale
  local cap_w=element_storage["cap_w"]
  if element_storage["Cap_width"]~=nil then
    cap_w=element_storage["Cap_width"]
  end
  
  cap_w=cap_w*reagirl.Window_GetCurrentScale()-dpi_scale*3
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
  radius=element_storage["radius"]
  reagirl.SetFont(1, "Arial", reagirl.Font_Size-1, 0)
  
  local sw,sh=gfx.measurestr(menuentry)
  local scale=1
  
  offset=1+math.floor(dpi_scale)
  gfx.x=x+1
  gfx.y=y+1+(h-sh)/2+offset-1
  gfx.set(0.2)
  gfx.drawstr(element_storage["Name"])
  
  gfx.x=x
  gfx.y=y+(h-sh)/2+offset-1
  if element_storage["IsDecorative"]==true then gfx.set(0.6) else gfx.set(0.8) end
  gfx.drawstr(element_storage["Name"])
  
  if reagirl.Elements[element_id]["pressed"]==true then
    state=1*dpi_scale-1
    if offset==0 then offset=1 end

    gfx.set(0.06)
    reagirl.RoundRect(cap_w+(x + offset)*scale, (y + offset - 1) * scale, w-cap_w+dpi_scale*3, h, radius * dpi_scale, 1, 1)

    gfx.set(0.274) -- background 2
    reagirl.RoundRect(cap_w+(x + offset+1)*scale, (y + offset +1- 1) * scale, w-cap_w+dpi_scale*3, h, radius * dpi_scale, 1, 1)
    
    gfx.set(0.274) -- button-area
    reagirl.RoundRect(cap_w+(x + 1 + offset) * scale, (y + offset) * scale, w-scale-cap_w+dpi_scale*3, h, radius * dpi_scale, 1, 1)
    
    gfx.set(0.39)
    local circ=4
    gfx.circle(x+dpi_scale+dpi_scale+dpi_scale+dpi_scale+w-h/2, (y+dpi_scale+dpi_scale+dpi_scale+h)-dpi_scale-h/2, circ*dpi_scale, 1, 0)
    gfx.rect(x+w-h+1*(dpi_scale-1)+dpi_scale+dpi_scale, y+(dpi_scale-dpi_scale)+dpi_scale+dpi_scale, dpi_scale, h, 1)
    
    if element_storage["IsDecorative"]==false then
      gfx.x=x+(7*dpi_scale)+offset+cap_w
    
      if reaper.GetOS():match("OS")~=nil then offset=1 end
      gfx.y=y+(h-sh)/2+1+offset
      gfx.set(0.784)
      gfx.drawstr(menuentry, 0, x+w-19*dpi_scale, gfx.y+gfx.texth)
    end
    reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  else
    state=0
    gfx.set(0.06) -- background 1
    reagirl.RoundRect(cap_w+x*scale, (y)*scale, w-cap_w+dpi_scale*4, h, radius * dpi_scale, 1, 1)
    
    gfx.set(0.45) -- background 2
    reagirl.RoundRect(cap_w+x*scale, (y - 1) * scale, w-cap_w+dpi_scale*3, h, radius * dpi_scale, 1, 1)
    
    gfx.set(0.274) -- button-area
    reagirl.RoundRect(cap_w+(x + 1) * scale, (y) * scale, w-scale-cap_w+dpi_scale*3, h-1, radius * dpi_scale, 1, 1)
    
    gfx.set(0.39)
    local circ=4
    gfx.circle(x+w+dpi_scale+dpi_scale-h/2, (y+h)-dpi_scale-h/2, circ*dpi_scale, 1, 0)
    gfx.rect(x+w-h+1*(dpi_scale-1), y+1+1*(dpi_scale-2), dpi_scale, h-dpi_scale, 1)
    
    local offset=0
    if element_storage["IsDecorative"]==false then
      gfx.x=x+(7*dpi_scale)+offset+cap_w--+(w-sw)/2+1
      if reaper.GetOS():match("OS")~=nil then offset=1 end
      --gfx.y=(y*scale)+(h-element_storage["h"])/2+offset
      gfx.y=y+(h-sh)/2+offset
      gfx.set(0.784)
      gfx.drawstr(menuentry, 0, x+w-21*dpi_scale, gfx.y+gfx.texth)
    else
      if reaper.GetOS():match("OS")~=nil then offset=1 end
      
      gfx.x=x+(7*dpi_scale)+offset+cap_w--+(w-sw)/2+1
      gfx.y=y+(h-sh)/2+1+offset-1
      gfx.set(0.09)
      gfx.drawstr(menuentry,0,x+w-21*dpi_scale, gfx.y+gfx.texth)
      
      gfx.x=x+(7*dpi_scale)+offset+cap_w--+(w-sw)/2+1
      gfx.y=y+(h-sh)/2+offset
      gfx.set(0.55)
      gfx.drawstr(menuentry,0,x+w-21*dpi_scale, gfx.y+gfx.texth)
    end
  end

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
    table menuItems - an indexed table with all the menu-items
    integer menuSelectedItem - the index of the pre-selected menu-item
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
    reagirl.Gui_ForceRefresh(29)
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
    reagirl.Gui_ForceRefresh(30)
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
    string label - the text of the label
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

  if reagirl.Elements[element_id]["GUI_Element_Type"]:sub(-5,-1)~="Label" then
    error("Label_GetLabelText: param #1 - ui-element is not a label", 2)
  else
    return reagirl.Elements[element_id]["Name"]
  end
end

function reagirl.Label_SetStyle(element_id, style1, style2, style3, style4)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Label_SetStyle</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Label_SetStyle(string element_id, integer style1, optional integer style2, optional integer style3, optional integer style4)</functioncall>
  <description>
    Sets the style of a label.
    
    You can combine different styles with each other in style1 through style4.
  </description>
  <parameters>
    string element_id - the id of the element, whose label-style you want to set
    integer style1 - choose a style
                   - 0, no style
                   - 1, bold
                   - 2, italic
                   - 3, non anti-alias
                   - 4, outline
                   - 5, drop-shadow
                   - 6, underline
                   - 7, negative
                   - 8, 90° counter-clockwise
                   - 9, 90° clockwise
    optional integer style2 - nil for no style; the rest, see style1 for more details
    optional integer style3 - nil for no style; the rest, see style1 for more details
    optional integer style4 - nil for no style; the rest, see style1 for more details
  </parameters>
  <chapter_context>
    Label
  </chapter_context>
  <tags>label, set, text, style</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Label_SetStyle: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Label_SetStyle: param #1 - must be a valid guid", 2) end
  if math.type(style1)~="integer" then error("Label_SetStyle: param #2 - must be an integer", 2) end
  if style2~=nil and math.type(style2)~="integer" then error("Label_SetStyle: param #3 - must be nil or an integer", 2) end
  if style3~=nil and math.type(style3)~="integer" then error("Label_SetStyle: param #4 - must be nil or an integer", 2) end
  if style4~=nil and math.type(style4)~="integer" then error("Label_SetStyle: param #5 - must be nil or an integer", 2) end
  if style2==nil then style2=0 end
  if style3==nil then style3=0 end
  if style4==nil then style4=0 end
  if style1<0 or style1>9 then error("Label_SetStyle: param #2 - no such style", 2) end
  if style2<0 or style2>9 then error("Label_SetStyle: param #3 - no such style", 2) end
  if style3<0 or style3>9 then error("Label_SetStyle: param #4 - no such style", 2) end
  if style4<0 or style4>9 then error("Label_SetStyle: param #5 - no such style", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Label_SetStyle: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]:sub(-5,-1)~="Label" then
    error("Label_SetStyle: param #1 - ui-element is not a label", 2)
  else
    reagirl.Elements[element_id]["style1"]=style1
    reagirl.Elements[element_id]["style2"]=style2
    reagirl.Elements[element_id]["style3"]=style3
    reagirl.Elements[element_id]["style4"]=style4
    
    reagirl.Gui_ForceRefresh(30)
  end
end

function reagirl.Label_GetStyle(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Label_GetStyle</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>integer style1, integer style2, integer style3, integer style4 = reagirl.Label_GetStyle(string element_id)</functioncall>
  <description>
    Gets the style of a label.
  </description>
  <retvals>
    integer style1 - the first style used:
                   - 0, no style
                   - 1, bold
                   - 2, italic
                   - 3, non anti-alias
                   - 4, outline
                   - 5, drop-shadow
                   - 6, underline
                   - 7, negative
                   - 8, 90° counter-clockwise
                   - 9, 90° clockwise
    integer style2 - the rest, see style1 for more details
    integer style3 - the rest, see style1 for more details
    integer style4 - see style1 for more details
  </retvals>
  <parameters>
    string element_id - the id of the element, whose label-style you want to get
  </parameters>
  <chapter_context>
    Label
  </chapter_context>
  <tags>label, get, style</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Label_GetLabelText: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Label_GetLabelText: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Label_GetLabelText: param #1 - no such ui-element", 2) end

  if reagirl.Elements[element_id]["GUI_Element_Type"]:sub(-5,-1)~="Label" then
    error("Label_GetLabelText: param #1 - ui-element is not a label", 2)
  else
    return reagirl.Elements[element_id]["style1"], reagirl.Elements[element_id]["style2"], reagirl.Elements[element_id]["style3"], reagirl.Elements[element_id]["style4"]
  end
end

--[[
  reagirl.Elements[slot]["style1"]=0
  reagirl.Elements[slot]["style2"]=0
  reagirl.Elements[slot]["style3"]=0
  reagirl.Elements[slot]["style4"]=0
  --]]
  
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
    end
  end  
  reagirl.UI_Element_NextLineY=0
  reagirl.UI_Element_NextX_Default=x
  
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
  reagirl.Elements[slot]["z_buffer"]=128
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  
  reagirl.Elements[slot]["clickable"]=clickable
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false
  reagirl.Elements[slot]["w"]=math.tointeger(w)+10
  reagirl.Elements[slot]["h"]=math.tointeger(h)--math.tointeger(gfx.texth)
  reagirl.Elements[slot]["align"]=align
  reagirl.Elements[slot]["style1"]=0
  reagirl.Elements[slot]["style2"]=0
  reagirl.Elements[slot]["style3"]=0
  reagirl.Elements[slot]["style4"]=0
  reagirl.Elements[slot]["func_draw"]=reagirl.Label_Draw
  reagirl.Elements[slot]["run_function"]=run_function
  reagirl.Elements[slot]["func_manage"]=reagirl.Label_Manage
  
  return reagirl.Elements[slot]["Guid"]
end

function reagirl.Label_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  --if Key==3 and selected==true then reaper.CF_SetClipboard(name) end
  if gfx.mouse_cap&2==2 and selected~="not selected" and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    local oldx, oldy=gfx.x, gfx.y
    gfx.x=gfx.mouse_x
    gfx.y=gfx.mouse_y
    --local selection=gfx.showmenu("Copy Text to Clipboard")
    gfx.x=oldx
    gfx.y=oldy
    --if selection==1 then reaper.CF_SetClipboard(name) end
  end
  if element_storage["clickable"]==true and (Key==13 or gfx.mouse_cap&1==1) and selected~="not selected" and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    if element_storage["run_function"]~=nil then reagirl.Elements[element_id]["run_function"](element_storage["Guid"]) end
  end
  return " ", false
end

function reagirl.Label_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  -- BUG: with multiline-texts, when they scroll outside the top of the window, they disappear when the first line is outside of the window
  local styles={66,73,77,79,83,85,86,89,90}
  styles[0]=0
  local style=styles[element_storage["style1"]]<<8
  style=style+styles[element_storage["style2"]]<<8
  style=style+styles[element_storage["style3"]]<<8
  style=style+styles[element_storage["style4"]]
  --print2(style)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, style)
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
  reagirl.Elements[slot]["z_buffer"]=128
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
    reagirl.Gui_ForceRefresh(31)
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
  reagirl.Elements[slot]["z_buffer"]=128
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
    
    The run_function will get three parameters: the guid of the image, the filename of the image 
    and an optional third parameter, the element_id of the destination, whereto the image has been 
    dragged to(if dragging is enabled, see Image_GetDraggable and Image_SetDraggable for enabling 
    dragging of the image to a destination ui-element).
    
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
    end
  end  
  reagirl.UI_Element_NextLineY=0
  reagirl.UI_Element_NextX_Default=x
  
  table.insert(reagirl.Elements, slot, {})
  reagirl.Elements[slot]["Guid"]=reaper.genGuid("")
  reagirl.Elements[slot]["GUI_Element_Type"]="Image"
  reagirl.Elements[slot]["Description"]=meaningOfUI_Element
  reagirl.Elements[slot]["Name"]=name
  reagirl.Elements[slot]["Text"]=name
  reagirl.Elements[slot]["IsDecorative"]=false
  reagirl.Elements[slot]["AccHint"]="Use Space or left mouse-click to select it."
  reagirl.Elements[slot]["z_buffer"]=128
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

function reagirl.Image_GetDraggable(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Image_GetDraggable</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>boolean draggable = reagirl.Image_GetDraggable(string element_id)</functioncall>
  <description>
    Gets the current draggable state of an image.
    
    When draggable==true: if the user drags the image onto a different ui-element, the run_function of 
    the image will get a third parameter, holding the element_id of the destination-ui-element of the dragging. 
    Otherwise this third parameter will be nil.
    
    Add a note in the accessibility-hint and the name of the image/caption of the ui-element, which clarifies, which ui-element is a source 
    and which is a target for dragging operations, so blind users know, which image can be dragged and whereto.
    Otherwise, blind users will not know what to do!
  </description>
  <parameters>
    string element_id - the image-element, whose dragable state you want toe retrieve
  </parameters>
  <retvals>
    boolean draggable - true, image is draggable; false, image is not draggable
  </retvals>
  <chapter_context>
    Image
  </chapter_context>
  <tags>image, get, draggable</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Image_GetDraggable: #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==false then error("Image_GetDraggable: #1 - must be a valid guid", 2) end
  if reagirl.UI_Element_GetType(element_id)~="Image" then error("Image_GetDraggable: #1 - UI-element is not an image", 2) end
  local slot=reagirl.UI_Element_GetIDFromGuid(element_id)
  return reagirl.Elements[slot]["Draggable"]
end

function reagirl.Image_SetDraggable(element_id, draggable, destination_element_ids)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Image_SetDraggable</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Image_SetDraggable(string element_id, boolean draggable, table destination_element_ids)</functioncall>
  <description>
    Sets the current draggable state of an image.
    
    When draggable==true: if the user drags the image onto a different ui-element, the run_function of 
    the image will get a third parameter, holding the element_id of the destination-ui-element of the dragging. 
    Otherwise this third parameter will be nil.
    
    Add a note in the accessibility-hint and the name of the image/caption of the ui-element, which clarifies, which ui-element is a source 
    and which is a target for dragging operations, so blind users know, which image can be dragged and whereto.
    Otherwise, blind users will not know what to do!
  </description>
  <parameters>
    string element_id - the image-element, whose dragable state you want toe retrieve
    boolean draggable - true, image is draggable; false, image is not draggable
    table destination_element_ids - a table with all guids of the ui-elements, where the image can be dragged to
  </parameters>
  <chapter_context>
    Image
  </chapter_context>
  <tags>image, set, draggable</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Image_SetDraggable: #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==false then error("Image_SetDraggable: #1 - must be a valid guid", 2) end
  if reagirl.UI_Element_GetType(element_id)~="Image" then error("Image_SetDraggable: #1 - UI-element is not an image", 2) end
  if type(draggable)~="boolean" then error("Image_SetDraggable: #2 - must be a boolean", 2) end
  if type(destination_element_ids)~="table" then error("Image_SetDraggable: #2 - must be a table", 2) end
  for i=1, #destination_element_ids do
    if reagirl.IsValidGuid(destination_element_ids[i], true)==false then
      error("Image_SetDraggable: #2 - all entries in the table must be a valid guid", 2)
    end
  end
  local slot=reagirl.UI_Element_GetIDFromGuid(element_id)
  reagirl.Elements[slot]["Draggable"]=draggable
  reagirl.Elements[slot]["DraggableDestinations"]=destination_element_ids
end

function reagirl.Image_ReloadImage_Scaled(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Image_ReloadImage_Scaled</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>boolean loading_success = reagirl.Image_ReloadImage_Scaled(string element_id)</functioncall>
  <description>
    Realoads an image. 
  </description>
  <parameters>
    string element_id - the image-element, whose image you want to reload
  </parameters>
  <retvals>
    boolean loading_success - true, loading was successful; false, loading was unsuccessful(missing file, etc)
  </retvals>
  <chapter_context>
    Image
  </chapter_context>
  <tags>image, reload</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Image_ReloadImage_Scaled: #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==false then error("Image_ReloadImage_Scaled: #1 - must be a valid guid", 2) end
  local slot=reagirl.UI_Element_GetIDFromGuid(element_id)
  if reagirl.UI_Element_GetType(element_id)~="Image" then error("Image_ReloadImage_Scaled: #1 - UI-element is not an image", 2) end
  local image_filename=reagirl.Elements[slot]["Image_Filename"]
  local scale=reagirl.Window_CurrentScale
  if reaper.file_exists(image_filename:match("(.*)%.").."-"..scale.."x"..image_filename:match(".*(%..*)"))==true then
    image_filename=image_filename:match("(.*)%.").."-"..scale.."x"..image_filename:match(".*(%..*)")
  end
  gfx.dest=reagirl.Elements[slot]["Image_Storage"]
  
  local image=reagirl.Elements[slot]["Image_Storage"]
  local r,g,b,a=gfx.r,gfx.g,gfx.b,gfx.a
  gfx.set(0)
  gfx.rect(0,0,8192,8192,1)
  gfx.set(r,g,b,a)
  local AImage=gfx.loadimg(image, image_filename )
  if AImage==-1 then return false end

  gfx.dest=-1
  return true
end


function reagirl.Image_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if selected~="not selected" and 
    (Key==32 or mouse_cap==1) and 
    (gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h) 
    and clicked=="FirstCLK" and
    element_storage["run_function"]~=nil then 
      element_storage["clickstate"]="clicked"
      if element_storage["Draggable"]==true and hovered==true then
        reagirl.Draggable_Element=element_id
        element_storage["mouse_x"]=gfx.mouse_x
        element_storage["mouse_y"]=gfx.mouse_y
      end
  end
  if element_storage["clickstate"]=="clicked" and mouse_cap&1==0 then
    element_storage["clickstate"]=nil
    if element_storage["Draggable"]==true and (element_storage["mouse_x"]~=gfx.mouse_x or element_storage["mouse_y"]~=gfx.mouse_y) then
      for i=1, #element_storage["DraggableDestinations"] do
        if reagirl.UI_Element_IsElementAtMousePosition(element_storage["DraggableDestinations"][i])==true then
          element_storage["run_function"](element_storage["Guid"], element_storage["Image_Filename"], element_storage["DraggableDestinations"][i]) 
        end
      end
    else
      element_storage["run_function"](element_storage["Guid"], element_storage["Image_Filename"]) 
    end
    reagirl.Draggable_Element=nil
  end
  if element_storage["Draggable"]==true then
  
  end
  if selected~="not selected" then
    message=" "
  else
    message=""
  end
  local draggable
  if element_storage["Draggable"]==true then draggable="Draggable " draggable2=" Use Ctrl plus alt plus Tab and Ctrl plus alt plus Tab to select the dragging-destinations and ctrl plus alt plus enter to drop the image into the dragging-destination." else draggable="" end
  return draggable..message
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



function reagirl.Image_Load(element_id, image_filename)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Image_Load</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Image_Load(string element_id, string image_filename)</functioncall>
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
  if type(element_id)~="string" then error("Image_Load: param #1 - must be a string", 2) end
  if type(image_filename)~="string" then error("Image_Load: param #2 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Image_Load: param #1 - must be a valid guid", 2) end
  local el_id=element_id
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Image_Load: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Image" then
    error("Image_Load: param #1 - ui-element is not an image", 2)
  else
    reagirl.Elements[element_id]["Image_Filename"]=image_filename
    reagirl.Image_ReloadImage_Scaled(el_id)
    reagirl.Gui_ForceRefresh(32)
  end
end



function reagirl.Background_GetSetColor(is_set, r, g, b)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Background_GetSetColor</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>integer red, integer green, integer blue = reagirl.Background_GetSetColor(boolean is_set, integer red, integer green, integer blue)</functioncall>
  <description>
    Gets/Sets the color if the background.
  </description>
  <parameters>
    boolean is_set - true, set the new background-color; false, only retrieve the current background-color
    integer red - the new red-color; 0-255
    integer green - the new green-color; 0-255
    integer blue - the new blue-color; 0-255
  </parameters>
  <chapter_context>
    Background
  </chapter_context>
  <tags>background, set, get, color, red, gree, blue</tags>
</US_DocBloc>
--]]
  if type(is_set)~="boolean" then error("GetSetBackgroundColor: param #1 - must be a boolean", 2) end
  if r~=nil and math.type(r)~="integer" then error("GetSetBackgroundColor: param #2 - must be an integer", 2) end
  if g~=nil and math.type(g)~="integer" then error("GetSetBackgroundColor: param #3 - must be an integer", 2) end
  if b~=nil and math.type(b)~="integer" then error("GetSetBackgroundColor: param #4 - must be an integer", 2) end
  if g==nil then g=r end
  if b==nil then b=r end
  if reagirl.Elements==nil then reagirl.Elements={} end
  if is_set==true and r~=nil and g~=nil and b~=nil then
    reagirl["WindowBackgroundColorR"],reagirl["WindowBackgroundColorG"],reagirl["WindowBackgroundColorB"]=r/255, g/255, b/255
  else
    return math.floor(reagirl["WindowBackgroundColorR"]*255), math.floor(reagirl["WindowBackgroundColorG"]*255), math.floor(reagirl["WindowBackgroundColorB"]*255)
  end
end


function reagirl.Background_GetSetImage(filename, x, y, scaled, fixed_x, fixed_y)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Background_GetSetImage</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>boolean imageload_success = reagirl.Background_GetSetImage(string filename, integer x, integer y, boolean scaled, boolean fixed_x, boolean fixed_y)</functioncall>
  <description>
    Gets/Sets the background-image.
  </description>
  <parameters>
    string filename - the filename of the new background-image
    integer x - the x-position of the background-image
    integer y - the y-position of the background-image
    boolean scaled - true, scale the image to the window-size; false, don't scale image
    boolean fixed_x - true, don't scroll the image on x-axis; false, scroll background-image on x-axis
    boolean fixed_y - true, don't scroll the image on y-axix; false, scroll background-image on y-axis
  </parameters>
  <retvals>
    boolean imageload_success - true, loading of the image was successful; false, loading of the image was unsuccessful
  </retvals>
  <chapter_context>
    Background
  </chapter_context>
  <tags>background, set, background image</tags>
</US_DocBloc>
--]]
  if type(filename)~="string" then error("Background_GetSetImage: param #1 - must be a boolean", 2) end
  if math.type(x)~="integer"  then error("Background_GetSetImage: param #2 - must be an integer", 2) end
  if math.type(y)~="integer"  then error("Background_GetSetImage: param #3 - must be an integer", 2) end
  if type(scaled)~="boolean"  then error("Background_GetSetImage: param #4 - must be a boolean", 2) end
  if type(fixed_x)~="boolean" then error("Background_GetSetImage: param #5 - must be an boolean", 2) end
  if type(fixed_y)~="boolean" then error("Background_GetSetImage: param #6 - must be an boolean", 2) end
  if reagirl.MaxImage==nil then reagirl.MaxImage=1 end
  reagirl.Background_FixedX=fixed_x
  reagirl.Background_FixedY=fixed_y
  reagirl.MaxImage=reagirl.MaxImage+1
  local AImage=gfx.loadimg(reagirl.MaxImage, filename)
  if AImage==-1 then return false end
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
  return true
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

function reagirl.Window_ForceMinSize()
  if reagirl.Window_ForceMinSize_Toggle~=true then return end
  local scale=reagirl.Window_CurrentScale
  local h,w
  if gfx.w<(reagirl.Window_MinW*scale)-1 then w=reagirl.Window_MinW*scale else w=gfx.w end
  if gfx.h<(reagirl.Window_MinH*scale)-1 then h=reagirl.Window_MinH*scale else h=gfx.h end
  
  if gfx.w==w and gfx.h==h then return end
  gfx.init("", w, h)
  reagirl.Gui_ForceRefresh(33)
end

function reagirl.Window_ForceMaxSize()
  if reagirl.Window_ForceMaxSize_Toggle~=true then return end
  local scale=reagirl.Window_CurrentScale
  local h,w
  if gfx.w>reagirl.Window_MaxW*scale then w=reagirl.Window_MaxW*scale else w=gfx.w end
  if gfx.h>reagirl.Window_MaxH*scale then h=reagirl.Window_MaxH*scale else h=gfx.h end
  
  if gfx.w==w and gfx.h==h then return end
  gfx.init("", w, h)
  reagirl.Gui_ForceRefresh(34)
end

function reagirl.Gui_ForceRefresh(place)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Gui_ForceRefresh</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Gui_ForceRefresh()</functioncall>
  <description>
    Forces a refresh of the gui.
  </description>
  <chapter_context>
    Gui
  </chapter_context>
  <tags>gui, force, refresh</tags>
</US_DocBloc>
--]]
  reagirl.Gui_ForceRefreshState=true
  reagirl.Gui_ForceRefresh_place=place
  reagirl.Gui_ForceRefresh_time=reaper.time_precise()
end

function reagirl.Window_ForceSize_Minimum(MinW, MinH)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Window_ForceSize_Minimum</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Window_ForceSize_Minimum(integer MinW, integer MinH)</functioncall>
  <description>
    Sets a minimum window size that will be enforced by ReaGirl.
  </description>
  <parameters>
    integer MinW - the minimum window-width in pixels
    integer MinH - the minimum window-height in pixels
  </parameters>
  <chapter_context>
    Window
  </chapter_context>
  <tags>window, set, force size, minimum</tags>
</US_DocBloc>
--]]
  if math.type(MinW)~="integer" then error("Window_ForceSize_Minimum: MinW - must be an integer", 2) end
  if math.type(MinH)~="integer" then error("Window_ForceSize_Minimum: MinH - must be an integer", 2) end
  reagirl.Window_ForceMinSize_Toggle=true
  reagirl.Window_MinW=MinW
  reagirl.Window_MinH=MinH
end

function reagirl.Window_ForceSize_Maximum(MaxW, MaxH)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Window_ForceSize_Maximum</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Window_ForceSize_Maximum(integer MaxW, integer MaxH)</functioncall>
  <description>
    Sets a maximum window size that will be enforced by ReaGirl.
  </description>
  <parameters>
    integer MaxW - the maximum window-width in pixels
    integer MaxH - the maximum window-height in pixels
  </parameters>
  <chapter_context>
    Window
  </chapter_context>
  <tags>window, set, force size, minimum</tags>
</US_DocBloc>
--]]
  if math.type(MaxW)~="integer" then error("Window_ForceSize_Maximum: MinW - must be an integer", 2) end
  if math.type(MaxH)~="integer" then error("Window_ForceSize_Maximum: MinH - must be an integer", 2) end
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
      reagirl.Image_Load(element_id, filename)
    end
  --end
  --]]
end

function GetFileList(element_id, filelist)
  print2(element_id)
  reagirl.Image_Load(B, filelist[1])
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
      reagirl.Gui_ForceRefresh(35) 
    end
    
    -- Scrolllimiter top
    if reagirl.MoveItAllUp_Delta>0 and reagirl.BoundaryY_Min+reagirl.MoveItAllUp>=0 then 
      reagirl.MoveItAllUp_Delta=0 
      reagirl.MoveItAllUp=0 
      reagirl.Gui_ForceRefresh(36) 
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
    if reagirl.MoveItAllRight_Delta<0 and reagirl.BoundaryX_Max+reagirl.MoveItAllRight-gfx.w<=0 then reagirl.MoveItAllRight_Delta=0 reagirl.MoveItAllRight=gfx.w-reagirl.BoundaryX_Max reagirl.Gui_ForceRefresh(37) end
    if reagirl.MoveItAllRight_Delta>0 and reagirl.BoundaryX_Min+reagirl.MoveItAllRight>=0 then reagirl.MoveItAllRight_Delta=0 reagirl.MoveItAllRight=0 reagirl.Gui_ForceRefresh(38) end
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
  
  if reagirl.MoveItAllRight_Delta~=0 or reagirl.MoveItAllUp_Delta~=0 then reagirl.Gui_ForceRefresh(39) end
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
      reagirl.Gui_ForceRefresh(40) 
    end
  end
  if Key==1685026670 then 
    -- Down
    if reagirl.BoundaryY_Min+reagirl.MoveItAllUp<0 then 
      reagirl.MoveItAllUp=reagirl.MoveItAllUp+10 
      reagirl.Gui_ForceRefresh(41)   
    end
  end
  if Key==1818584692.0 then 
    -- left
    if reagirl.BoundaryX_Min+reagirl.MoveItAllRight<0 then 
      reagirl.MoveItAllRight=reagirl.MoveItAllRight+10 
      reagirl.Gui_ForceRefresh(42) 
    end
  end
  if Key==1919379572.0 then 
    if reagirl.BoundaryX_Max+reagirl.MoveItAllRight>gfx.w then 
      reagirl.MoveItAllRight=reagirl.MoveItAllRight-10 
      reagirl.Gui_ForceRefresh(43) 
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
    if reagirl.Elements[i].hidden~=true then
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
  reagirl.BoundaryX_Max=maxx+15*scale
  reagirl.BoundaryY_Min=0--miny
  reagirl.BoundaryY_Max=maxy+15*scale -- +scale_offset
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
  reagirl.Elements[#reagirl.Elements]["z_buffer"]=256
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
  if reagirl.Scroll_Override_ScrollButtons==true then return "" end
  if element_storage.IsDecorative==false and element_storage.a<=0.75 then element_storage.a=element_storage.a+.1 reagirl.Gui_ForceRefresh(44) end
  if mouse_cap&1==1 and selected~="not selected" and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    reagirl.UI_Element_ScrollX(-2)
  elseif selected~="not selected" and Key==32 then
    reagirl.UI_Element_ScrollX(-15)
  end
  return ""
end

function reagirl.ScrollButton_Right_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if reagirl.Scroll_Override_ScrollButtons==true then return "" end
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
  if mouse_cap==1 and selected~="not selected" then
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
  reagirl.Elements[#reagirl.Elements]["z_buffer"]=256
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
  if reagirl.Scroll_Override_ScrollButtons==true then return "" end
  if element_storage.IsDecorative==false and element_storage.a<=0.75 then element_storage.a=element_storage.a+.1 reagirl.Gui_ForceRefresh(45) end
  if mouse_cap&1==1 and selected~="not selected" and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    reagirl.UI_Element_ScrollX(2)
  elseif selected~="not selected" and Key==32 then
    reagirl.UI_Element_ScrollX(15)
  end
  return ""
end

function reagirl.ScrollButton_Left_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if reagirl.Scroll_Override_ScrollButtons==true then return "" end
  local scale=reagirl.Window_CurrentScale
  if reagirl.BoundaryX_Max>gfx.w then
    element_storage.IsDecorative=false
  else
    element_storage.a=0 
    --reagirl.Gui_ForceRefresh(46) 
    if element_storage.IsDecorative==false then
      reagirl.UI_Element_SetNothingFocused()
      element_storage.IsDecorative=true
    end
  end
  local oldr, oldg, oldb, olda = gfx.r, gfx.g, gfx.b, gfx.a
  gfx.set(reagirl["WindowBackgroundColorR"], reagirl["WindowBackgroundColorG"], reagirl["WindowBackgroundColorB"], element_storage.a)
  gfx.rect(0, gfx.h-15*scale, 15*scale, 15*scale, 1)
  if mouse_cap==1 and selected~="not selected" then
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
  reagirl.Elements[#reagirl.Elements]["z_buffer"]=256
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
  if reagirl.Scroll_Override_ScrollButtons==true then return "" end
  if element_storage.IsDecorative==false and element_storage.a<=0.75 then element_storage.a=element_storage.a+.1 reagirl.Gui_ForceRefresh(47) end
  if mouse_cap&1==1 and selected~="not selected" and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    reagirl.UI_Element_ScrollY(2)
  elseif selected~="not selected" and Key==32 then
    reagirl.UI_Element_ScrollY(15)
  end
  return ""
end

function reagirl.ScrollButton_Up_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if reagirl.Scroll_Override_ScrollButtons==true then return "" end
  local scale=reagirl.Window_CurrentScale
  if reagirl.BoundaryY_Max>gfx.h then
    element_storage.IsDecorative=false
  else
    element_storage.a=0 
    --reagirl.Gui_ForceRefresh(48) 
    if element_storage.IsDecorative==false then
      reagirl.UI_Element_SetNothingFocused()
      element_storage.IsDecorative=true
    end
  end
  local oldr, oldg, oldb, olda = gfx.r, gfx.g, gfx.b, gfx.a
  gfx.set(reagirl["WindowBackgroundColorR"], reagirl["WindowBackgroundColorG"], reagirl["WindowBackgroundColorB"], element_storage.a)
  gfx.rect(gfx.w-15*scale, 0, 15*scale, 15*scale, 1)
  if mouse_cap==1 and selected~="not selected" then
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
  reagirl.Elements[#reagirl.Elements]["z_buffer"]=256
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
  if reagirl.Scroll_Override_ScrollButtons==true then return "" end
  
  if element_storage.IsDecorative==false and element_storage.a<=0.75 then element_storage.a=element_storage.a+.1 reagirl.Gui_ForceRefresh(49) end
  if mouse_cap&1==1 and selected~="not selected" and gfx.mouse_x>=x and gfx.mouse_x<=x+w and gfx.mouse_y>=y and gfx.mouse_y<=y+h then
    reagirl.UI_Element_ScrollY(-2)
  elseif selected~="not selected" and Key==32 then
    reagirl.UI_Element_ScrollY(-15)
  end
  return ""
end

function reagirl.ScrollButton_Down_Draw(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if reagirl.Scroll_Override_ScrollButtons==true then return "" end
  local scale=reagirl.Window_CurrentScale
  --print_update(x,y,w,h,scale)
  if reagirl.BoundaryY_Max>gfx.h then
    element_storage.IsDecorative=false
  else
    element_storage.a=0 
    --reagirl.Gui_ForceRefresh(50) 
    if element_storage.IsDecorative==false then
      reagirl.UI_Element_SetNothingFocused()
      element_storage.IsDecorative=true
    end
  end
  local oldr, oldg, oldb, olda = gfx.r, gfx.g, gfx.b, gfx.a
  gfx.set(reagirl["WindowBackgroundColorR"], reagirl["WindowBackgroundColorG"], reagirl["WindowBackgroundColorB"], element_storage.a)
  gfx.rect(gfx.w-15*scale, gfx.h-30*scale, 15*scale, 15*scale, 1)
  if mouse_cap==1 and selected~="not selected" then
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
  local scale=reagirl.Window_GetCurrentScale()
  for i=1, #reagirl.Elements do
    if element_id==reagirl.Elements[i].Guid then
      if reagirl.Elements[i]["x"]<0 then x2=gfx.w+reagirl.Elements[i]["x"]*scale else x2=reagirl.Elements[i]["x"]*scale end
      if reagirl.Elements[i]["y"]<0 then y2=gfx.h+reagirl.Elements[i]["y"]*scale else y2=reagirl.Elements[i]["y"]*scale end
      if reagirl.Elements[i]["w"]<0 then w2=gfx.w-x2+reagirl.Elements[i]["w"]*scale else w2=reagirl.Elements[i]["w"]*scale end
      if reagirl.Elements[i]["h"]<0 then h2=gfx.h-y2+reagirl.Elements[i]["h"]*scale else h2=reagirl.Elements[i]["h"]*scale end
      
      if x2+reagirl.MoveItAllRight<0 or x2+reagirl.MoveItAllRight>gfx.w or y2+reagirl.MoveItAllUp<0 or y2+reagirl.MoveItAllUp>gfx.h or
         x2+w2+reagirl.MoveItAllRight<0 or x2+w2+reagirl.MoveItAllRight>gfx.w or y2+h2+reagirl.MoveItAllUp<0 or y2+h2+reagirl.MoveItAllUp>gfx.h 
      then
        --print2()
        reagirl.MoveItAllRight=-x2+x_offset
        reagirl.MoveItAllUp=-y2+y_offset
        reagirl.Gui_ForceRefresh(51)
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
  reagirl.Gui_ForceRefresh(52)
end

function reagirl.Slider_Add(x, y, w, caption, Cap_width, meaningOfUI_Element, unit, start, stop, step, default, run_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Slider_Add</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string slider_guid = reagirl.Slider_Add(integer x, integer y, integer w, string caption, optional integer cap_width, string meaningOfUI_Element, optional string unit, number start, number stop, number step, number default, function run_function)</functioncall>
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
    optional integer cap_width - the width of the caption to set the actual slider to a fixed position; nil, put slider directly after caption
    string meaningOfUI_Element - a description for accessibility users
    optional string unit - the unit shown next to the number the slider is currently set to
    number start - the minimum value of the slider
    number stop - the maximum value of the slider
    number step - the stepsize until the next value within the slider
    number default - the default value of the slider(also the initial value)
    function run_function - a function that shall be run when the slider is clicked; will get passed over the slider-element_id as first and the new slider-value as second parameter
  </parameters>
  <retvals>
    string slider_guid - a guid that can be used for altering the slider-attributes
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
  if Cap_width~=nil and math.type(Cap_width)~="integer" then error("Slider_Add: param #5 - must be wither nil or an integer", 2) end
  if type(meaningOfUI_Element)~="string" then error("Slider_Add: param #6 - must be a string", 2) end
  if unit~=nil and type(unit)~="string" then error("Slider_Add: param #7 - must be a number", 2) end
  if type(start)~="number" then error("Slider_Add: param #8 - must be a number", 2) end
  if type(stop)~="number" then error("Slider_Add: param #9 - must be a number", 2) end
  if type(step)~="number" then error("Slider_Add: param #10 - must be a number", 2) end
  if type(default)~="number" then error("Slider_Add: param #11 - must be a number", 2) end
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
    end
  end  
  reagirl.UI_Element_NextLineY=0
  reagirl.UI_Element_NextX_Default=x
  
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
  reagirl.Elements[slot]["z_buffer"]=128
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["w"]=math.tointeger(w)--math.tointeger(ty+tx+4)
  reagirl.Elements[slot]["h"]=math.tointeger(ty)+5
  reagirl.Elements[slot]["cap_w"]=math.tointeger(tx)
  reagirl.Elements[slot]["Cap_width"]=Cap_width
  
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
  local dpi_scale=reagirl.Window_GetCurrentScale()
  local slider, slider4, slider_x, slider_x2
  if w<element_storage["cap_w"]+element_storage["unit_w"]+20 then w=element_storage["cap_w"]+element_storage["unit_w"]+20 end
  local offset_cap=element_storage["cap_w"]
  if element_storage["Cap_width"]~=nil then
    offset_cap=element_storage["Cap_width"]*dpi_scale
  end
  if selected~="not selected" then
    --reagirl.UI_Element_SetFocusRect(true, x, y, w-20, h-5)
  end
  local offset_unit=element_storage["unit_w"]
  element_storage["slider_w"]=math.tointeger(w-element_storage["cap_w"]-element_storage["unit_w"]-10)
  
  if selected~="not selected" then
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
      
      if (clicked=="FirstCLK" or clicked=="DRAG") and gfx.mouse_x>=x+offset_cap-10*dpi_scale and gfx.mouse_x<=x+offset_cap then
        element_storage["CurValue"]=element_storage["Start"]
      elseif (clicked=="FirstCLK" or clicked=="DRAG") and gfx.mouse_x>=x+w-offset_unit and gfx.mouse_x<=x+w-offset_unit+10*dpi_scale then
        element_storage["CurValue"]=element_storage["Stop"]
        
      else
      
        element_storage["TempValue"]=element_storage["CurValue"]     
        if slider_x2>=0 and slider_x2<=element_storage["slider_w"] then
          if clicked=="DBLCLK" then
          --  element_storage["CurValue"]=element_storage["Default"]
          --  refresh=true
          else
            if clicked=="FirstCLK" or clicked=="DRAG" then
              step_size=(rect_w/(element_storage["Stop"]+1-element_storage["Start"])/1)
              slider4=slider_x2/step_size
              element_storage["CurValue"]=element_storage["Start"]+slider4
              if element_storage["Step"]~=-1 then 
                local old=element_storage["Start"]
                for i=element_storage["Start"]-1, element_storage["Stop"]+1, element_storage["Step"] do
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
        elseif slider_x2<0 and slider_x2>=-15 and clicked=="FirstCLK" then element_storage["CurValue"]=element_storage["Start"] 
        elseif slider_x2>element_storage["slider_w"] and clicked=="FirstCLK" then 
          element_storage["CurValue"]=element_storage["Stop"] 
        end
      end
      if element_storage["TempValue"]~=element_storage["CurValue"] then --element_storage["OldMouseX"]~=gfx.mouse_x or element_storage["OldMouseY"]~=gfx.mouse_y then
        refresh=true
      end
      if math.type(element_storage["Step"])=="integer" and math.type(element_storage["Start"])=="integer" and math.type(element_storage["Stop"])=="integer" then
        element_storage["CurValue"]=math.floor(element_storage["CurValue"])
      end
    end
  end
  if gfx.mouse_x>=x+offset_cap-5*dpi_scale and 
     gfx.mouse_x<=x+w-offset_unit+5*dpi_scale and --x+w and 
     gfx.mouse_y>=y and 
     gfx.mouse_y<=y+h then
    if clicked=="DBLCLK" then
      element_storage["CurValue"]=element_storage["Default"]
      refresh=true
    end
    reagirl.Scroll_Override_MouseWheel=true
    if reagirl.MoveItAllRight_Delta==0 and reagirl.MoveItAllUp_Delta==0 then
      if mouse_attributes[5]<0 or mouse_attributes[6]>0 then 
        local stepme
        if mouse_attributes[5]<0 then stepme=math.tointeger(-mouse_attributes[5]) else stepme=math.tointeger(mouse_attributes[6]) end
        if stepme<120 then stepme=1
        elseif stepme<500 then stepme=2
        elseif stepme<1000 then stepme=8
        elseif stepme<2000 then stepme=16
        elseif stepme<4000 then stepme=64
        end
        element_storage["CurValue"]=element_storage["CurValue"]+element_storage["Step"]*(stepme)
        refresh=true 
      end
      if mouse_attributes[5]>0 or mouse_attributes[6]<0 then 
        local stepme
        if mouse_attributes[5]>0 then stepme=math.tointeger(mouse_attributes[5]) else stepme=math.tointeger(-mouse_attributes[6]) end
        if stepme<120 then stepme=1
        elseif stepme<500 then stepme=2
        elseif stepme<1000 then stepme=8
        elseif stepme<2000 then stepme=16
        elseif stepme<4000 then stepme=64
        end
        element_storage["CurValue"]=element_storage["CurValue"]-element_storage["Step"]*(stepme)
        refresh=true 
      end
      if element_storage["CurValue"]>element_storage["Stop"] then
        --element_storage["CurValue"]=element_storage["Stop"]
        --refresh=false
      elseif element_storage["CurValue"]<element_storage["Start"] then
        --element_storage["CurValue"]=element_storage["Start"]
        --refresh=false
      end
    end
  end
  
  local skip_func
  if element_storage["CurValue"]<element_storage["Start"] then element_storage["CurValue"]=element_storage["Start"] skip_func=true end
  if element_storage["CurValue"]>element_storage["Stop"] then element_storage["CurValue"]=element_storage["Stop"] skip_func=true end
  
  if refresh==true then 
    reagirl.Gui_ForceRefresh(53) 
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
  
  reagirl.SetFont(1, "Arial", reagirl.Font_Size-1, 0)
  local offset_cap=gfx.measurestr(name.." ")+5
  if element_storage["Cap_width"]~=nil then
    offset_cap=element_storage["Cap_width"]
  end
  offset_cap=offset_cap*dpi_scale
  local offset_unit=gfx.measurestr(element_storage["Unit"].."8888")
  
  element_storage["cap_w"]=offset_cap--gfx.measurestr(name.." ")+5*dpi_scale
  --print_update(offset_cap)
  element_storage["unit_w"]=offset_unit
  element_storage["slider_w"]=w-offset_cap-offset_unit
  gfx.x=x+1
  gfx.y=y+1
  gfx.set(0.2)
  gfx.drawstr(element_storage["Name"])
  
  gfx.x=x
  gfx.y=y
  if element_storage["IsDecorative"]==true then gfx.set(0.6) else gfx.set(0.8) end
  -- draw caption
  gfx.drawstr(element_storage["Name"])
  
  -- draw unit
  local unit=reagirl.FormatNumber(element_storage["CurValue"], 3)
  if element_storage["Unit"]~=nil then 
    gfx.x=x+1+w-offset_unit+5*dpi_scale
    gfx.y=y+1
    gfx.set(0.2)
    gfx.drawstr(" "..unit..element_storage["Unit"])
    
    gfx.x=x+w-offset_unit+5*dpi_scale
    gfx.y=y
  
    gfx.set(0.8) 
    gfx.drawstr(" "..unit..element_storage["Unit"]) 
  end

  if element_storage["IsDecorative"]==true then gfx.set(0.5) else gfx.set(0.7) end
  -- draw slider-area
  gfx.set(0.5)
  --gfx.rect(x+offset_cap-dpi_scale, y-dpi_scale-dpi_scale+(gfx.texth>>1), w-offset_cap-offset_unit+dpi_scale+dpi_scale, dpi_scale*5, 1)
  reagirl.RoundRect(math.tointeger(x+offset_cap-dpi_scale), y-dpi_scale-dpi_scale+(math.tointeger(gfx.texth)>>1), math.tointeger(w-offset_cap-offset_unit+dpi_scale+dpi_scale), math.tointeger(dpi_scale)*5, 2*math.tointeger(dpi_scale), 1, 1)
  
  if element_storage["IsDecorative"]==true then gfx.set(0.6) else gfx.set(0.8) end
  reagirl.RoundRect(math.tointeger(x+offset_cap),y+(math.tointeger(gfx.texth)>>1)-dpi_scale, math.tointeger(w-offset_cap-offset_unit), math.tointeger(dpi_scale)*3, 1, 1, 1)
  --gfx.rect                      (x+offset_cap, y+(gfx.texth>>1)-dpi_scale,                                w-offset_cap-offset_unit,                 dpi_scale*3, 1)
  
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
    reagirl.Gui_ForceRefresh(54)
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
    reagirl.Gui_ForceRefresh(55)
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
    reagirl.Gui_ForceRefresh(56)
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
    reagirl.Gui_ForceRefresh(57)
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
    reagirl.Gui_ForceRefresh(58)
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
    reagirl.Gui_ForceRefresh(59)
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

function reagirl.Tabs_Add(x, y, w_backdrop, h_backdrop, caption, meaningOfUI_Element, tab_names, selected_tab, run_function)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Tabs_Add</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>string tabs_guid = reagirl.Tabs_Add(integer x, integer y, integer w, integer w_backdrop, integer h_backdrop, string caption, string meaningOfUI_Element, table tab_names, integer selected_tab, function run_function)</functioncall>
  <description>
    Adds a tab to a gui.
    
    You can autoposition the tab by setting x and/or y to nil, which will position the new tab after the last ui-element.
    To autoposition into the next line, use reagirl.NextLine()
    
    You can also have a background drawn by the tab, which could be set to a specific size or set to autosize.
    When set to autosize, it will enclose ui-elements currently visible in the gui.
    If you don't want a background, set w_background or h_background to 0.
    
    Keep in mind, that using auto-sizing of the background might lead to smaller backgrounds than the tabs themselves!
  </description>
  <parameters>
    optional integer x - the x position of the tab in pixels; negative anchors the tab to the right window-side; nil, autoposition after the last ui-element(see description)
    optional integer y - the y position of the tab in pixels; negative anchors the tab to the bottom window-side; nil, autoposition after the last ui-element(see description)
    optional integer w_backdrop - the width of the tab's backdrop; negative, anchor it to the right window-edge; nil, autosize the backdrop to the gui-elements currently shown
    optional integer h_backdrop - the height of the tab's backdrop; negative, anchor it to the bottom window-edge; nil, autosize the backdrop to the gui-elements currently shown
    string caption - the caption of the tab
    string meaningOfUI_Element - a description for accessibility users
    table tab_names - an indexed table with all tab-names 
    integer selected_tab - the index of the currently selected tab; 1-based
    function run_function - a function that shall be run when a tab is clicked/selected via keys; 
                          - will get passed over the tab-element_id as first and 
                          - the new selected tab as second parameter as well as 
                          - the selected tab-name as third parameter
  </parameters>
  <retvals>
    string tabs_guid - a guid that can be used for altering the tab-attributes
  </retvals>
  <chapter_context>
    Tabs
  </chapter_context>
  <tags>tabs, add</tags>
</US_DocBloc>
--]]

-- Parameter Unit==nil means, no number of unit shown
  if x~=nil and math.type(x)~="integer" then error("Tabs_Add: param #1 - must be an integer", 2) end
  if y~=nil and math.type(y)~="integer" then error("Tabs_Add: param #2 - must be an integer", 2) end
  if w_backdrop~=nil and math.type(w_backdrop)~="integer" then error("Tabs_Add: param #4 - must be an integer", 2) end
  if h_backdrop~=nil and math.type(h_backdrop)~="integer" then error("Tabs_Add: param #5 - must be an integer", 2) end
  if type(caption)~="string" then error("Tabs_Add: param #6 - must be a string", 2) end
  if type(meaningOfUI_Element)~="string" then error("Tabs_Add: param #7 - must be a string", 2) end
  if type(tab_names)~="table" then error("Tabs_Add: param #8 - must be a number", 2) end
  for i=1, #tab_names do
    tab_names[i]=tostring(tab_names[i])
  end
  if math.type(selected_tab)~="integer" then error("Tabs_Add: param #9 - must be an integer", 2) end
  if run_function~=nil and type(run_function)~="function" then error("Tabs_Add: param #10 - must be either nil or a function", 2) end
  
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
    end
  end  
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0, 1)
  local tx, ty =gfx.measurestr(caption.."")

  reagirl.UI_Element_NextX_Default=x
  reagirl.UI_Element_NextLineY=0
  
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
  reagirl.Elements[slot]["z_buffer"]=128
  reagirl.Elements[slot]["x"]=x
  reagirl.Elements[slot]["y"]=y
  reagirl.Elements[slot]["text_offset_x"]=20
  reagirl.Elements[slot]["text_offset_y"]=5
  local width=0
  for i=1, #tab_names do
    width=width+gfx.measurestr(tab_names[i])
  end
  width=width+(#tab_names*(reagirl.Window_GetCurrentScale()+reagirl.Elements[slot]["text_offset_x"])*2)
  reagirl.SetFont(1, "Arial", reagirl.Font_Size, 0)
  reagirl.Elements[slot]["w"]=math.tointeger(width)
  reagirl.Elements[slot]["h"]=math.tointeger(ty)+15
  --if w_backdrop==0 then reagirl.Elements[slot]["w_background"]="zero" else reagirl.Elements[slot]["w_background"]=w_backdrop-x end
  --if h_backdrop==0 then reagirl.Elements[slot]["h_background"]="zero" else reagirl.Elements[slot]["h_background"]=h_backdrop-reagirl.Elements[slot]["h"] end
  
  if w_backdrop==0 then 
    reagirl.Elements[slot]["w_background"]="zero" 
    reagirl.Elements[slot]["bg_w"]=0
  else 
    reagirl.Elements[slot]["w_background"]=w_backdrop 
    reagirl.Elements[slot]["bg_w"]=w_backdrop 
  end
  if h_backdrop==0 then 
    reagirl.Elements[slot]["h_background"]="zero" 
    reagirl.Elements[slot]["bg_h"]=0
  else 
    reagirl.Elements[slot]["h_background"]=h_backdrop 
    reagirl.Elements[slot]["bg_h"]=h_backdrop 
  end
  
  reagirl.Elements[slot]["sticky_x"]=false
  reagirl.Elements[slot]["sticky_y"]=false

  reagirl.Elements[slot]["func_manage"]=reagirl.Tabs_Manage
  reagirl.Elements[slot]["func_draw"]=reagirl.Tabs_Draw
  reagirl.Elements[slot]["run_function"]=run_function
  reagirl.Elements[slot]["userspace"]={}
  reagirl.UI_Element_NextX_Default=reagirl.UI_Element_NextX_Default+10
  return reagirl.Elements[slot]["Guid"]
end

function reagirl.Tabs_SetValue(element_id, selected_tab)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Tabs_SetValue</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>reagirl.Tabs_SetValue(string element_id, integer selected_tab)</functioncall>
  <description>
    Sets the selected tab of a tabs-element.
  </description>
  <parameters>
    string element_id - the guid of the tabs, whose selected tab you want to set
    integer selected_tab - the new selected tab
  </parameters>
  <chapter_context>
    Tabs
  </chapter_context>
  <tags>tabs, set, selected tab</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Tabs_SetValue: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Tabs_SetValue: param #1 - must be a valid guid", 2) end
  if math.type(selected_tab)~="integer" then error("Tabs_SetValue: param #2 - must be a number", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if element_id==-1 then error("Tabs_SetValue: param #1 - no such ui-element", 2) end
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Tabs" then
    error("Tabs_SetValue: param #1 - ui-element is not a tab", 2)
  else
    if selected_tab<1 or selected_tab>#reagirl.Elements[element_id]["TabNames"] then error("Tabs_SetValue: param #2 - no such tab", 2) end
    reagirl.Elements[element_id]["TabSelected"]=selected_tab
    reagirl.Gui_ForceRefresh(60)
  end
end

function reagirl.Tabs_GetValue(element_id)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Tabs_GetValue</slug>
  <requires>
    ReaGirl=1.0
    Reaper=7
    Lua=5.4
  </requires>
  <functioncall>number value = reagirl.Tabs_GetValue(string element_id)</functioncall>
  <description>
    Gets the selected tab of a tabs-element.
  </description>
  <parameters>
    string element_id - the guid of the tabs, whose selected tab you want to set
  </parameters>
  <retvals>
    integer selected_tab - the selected tab
  </retvals>
  <chapter_context>
    Tabs
  </chapter_context>
  <tags>tabs, get, selected tab</tags>
</US_DocBloc>
--]]
  if type(element_id)~="string" then error("Tabs_GetValue: param #1 - must be a string", 2) end
  if reagirl.IsValidGuid(element_id, true)==nil then error("Tabs_GetValue: param #1 - must be a valid guid", 2) end
  element_id = reagirl.UI_Element_GetIDFromGuid(element_id)
  if reagirl.Elements[element_id]["GUI_Element_Type"]~="Tabs" then
    error("Tabs_GetValue: param #1 - ui-element is not tabs", 2)
  else
    return reagirl.Elements[element_id]["TabSelected"]
  end
end


function reagirl.Tabs_Manage(element_id, selected, hovered, clicked, mouse_cap, mouse_attributes, name, description, x, y, w, h, Key, Key_UTF, element_storage)
  if Key~=0 then ABBA=Key end
  local refresh
  if element_storage["Tabs_Pos"]==nil then reagirl.Gui_ForceRefresh(61) end
  if element_storage["Tabs_Pos"]~=nil and clicked=="FirstCLK" then 
    for i=1, #element_storage["Tabs_Pos"] do
      if gfx.mouse_y>=y and gfx.mouse_y<=element_storage["Tabs_Pos"][i]["h"]+y then
        if gfx.mouse_x>=element_storage["Tabs_Pos"][i]["x"] and gfx.mouse_x<=element_storage["Tabs_Pos"][i]["x"]+element_storage["Tabs_Pos"][i]["w"] then
          if element_storage["TabSelected"]~=i then
            element_storage["TabSelected"]=i
            refresh=true
          end
          break
        end
      end
    end
  end
  
  if selected~="not selected" and Key==1919379572.0 then 
    if element_storage["TabSelected"]+1~=#element_storage["TabNames"]+1 then
      element_storage["TabSelected"]=element_storage["TabSelected"]+1
      refresh=true
    end
  end
  if selected~="not selected" and Key==1818584692.0 then
    if element_storage["TabSelected"]-1~=0 then
      element_storage["TabSelected"]=element_storage["TabSelected"]-1
      refresh=true
    end
  end
  
  -- click management for the tabs
  if selected~="not selected" and element_storage["Tabs_Pos"]~=nil then
    reagirl.Gui_PreventScrollingForOneCycle(true, false)
    for i=1, #element_storage["Tabs_Pos"] do
      --if gfx.mouse_x>=x+element_storage["Tabs_Pos"]
    end
  end
  
  -- hover management for the tabs
  if hovered==true then
    if element_storage["Tabs_Pos"]~=nil then
      for i=1, #element_storage["Tabs_Pos"] do
        if gfx.mouse_y>=y and gfx.mouse_y<=element_storage["Tabs_Pos"][i]["h"]+y then
          if gfx.mouse_x>=element_storage["Tabs_Pos"][i]["x"] and gfx.mouse_x<=element_storage["Tabs_Pos"][i]["x"]+element_storage["Tabs_Pos"][i]["w"] then
            element_storage["AccHoverMessage"]=element_storage["TabNames"][i]
          end
        end
      end
    end
    --element_storage["AccHoverMessage"]=element_storage["Name"].." "..element_storage["TabNames"][element_storage["TabSelected"]]
  end
  if refresh==true then 
    reagirl.Gui_ForceRefresh(62) 
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
    gfx.rect(math.tointeger(x+x_offset-text_offset_x)+1, y+text_offset_y, math.tointeger(tx+text_offset_x+text_offset_x)-1, tab_height+ty-y+offset, 4*dpi_scale, 1, 0, false, true, false, true)
    
    -- store the dimensions and positions of individual tabs for the manage-function
    element_storage["Tabs_Pos"][i]["x"]=math.tointeger(x+x_offset-text_offset_x)
    element_storage["Tabs_Pos"][i]["w"]=math.tointeger(tx+text_offset_x+text_offset_x)-1
    element_storage["Tabs_Pos"][i]["h"]=tab_height+ty
    
    x_offset=x_offset+math.tointeger(tx)+text_offset_x+text_offset_x+dpi_scale*2
    if selected~="not selected" and i==element_storage["TabSelected"] then
      reagirl.UI_Element_SetFocusRect(true, math.tointeger(gfx.x), y+text_offset_y, math.tointeger(tx), math.tointeger(ty))
    end
    
    gfx.set(1)
    gfx.drawstr(element_storage["TabNames"][i])
  end
  --element_storage["w"]=x_offset-x_offset_factor
  -- backdrop
  if element_storage["w_background"]~="zero" and element_storage["h_background"]~="zero" then
    local offset_x=0
    local offset_y=0
    if x>0 then offset_x=x end
    if y>0 then offset_y=element_storage["Tabs_Pos"][element_storage["TabSelected"] ]["h"]+y end
    
    if element_storage["w_background"]==nil then 
      bg_w=reagirl.BoundaryX_Max-20*dpi_scale 
      element_storage["bg_w"]=bg_w
    else 
      if element_storage["w_background"]>0 then bg_w=element_storage["w_background"]*dpi_scale else bg_w=gfx.w+element_storage["w_background"]*dpi_scale-offset_x end
    end
    
    if element_storage["h_background"]==nil then 
      bg_h=reagirl.BoundaryY_Max-20*dpi_scale 
      element_storage["bg_h"]=bg_h
    else 
      if element_storage["h_background"]>0 then bg_h=element_storage["h_background"]*dpi_scale else bg_h=gfx.h+element_storage["h_background"]*dpi_scale-offset_y end
    end
  
    gfx.set(0.253921568627451)
    --gfx.rect(x,y+element_storage["Tabs_Pos"][element_storage["TabSelected"] ]["h"],reagirl.BoundaryX_Max-20*dpi_scale, reagirl.BoundaryY_Max-45*dpi_scale, 1)
    gfx.rect(x, y+element_storage["Tabs_Pos"][element_storage["TabSelected"] ]["h"], bg_w, bg_h, 1)
    gfx.set(0.403921568627451)
    --gfx.rect(x,y+element_storage["Tabs_Pos"][element_storage["TabSelected"] ]["h"],reagirl.BoundaryX_Max-20*dpi_scale, reagirl.BoundaryY_Max-45*dpi_scale, 0)
    gfx.rect(x, y+element_storage["Tabs_Pos"][element_storage["TabSelected"] ]["h"], bg_w, bg_h, 0)
  end
  gfx.set(0.253921568627451)
  gfx.rect(element_storage["Tabs_Pos"][element_storage["TabSelected"] ]["x"]+1, 
           y+element_storage["Tabs_Pos"][element_storage["TabSelected"] ]["h"],
           element_storage["Tabs_Pos"][element_storage["TabSelected"] ]["w"],--+element_storage["Tabs_Pos"][element_storage["TabSelected"] ]["w"], 
           dpi_scale, 0)
  
  if selected~="not selected" then
    --reagirl.UI_Element_SetFocusRect(true, x, y, math.tointeger(tx), math.tointeger(ty))
  end
  
  
end

reagirl.Gui_New()


--- End of ReaGirl-Functions


function ABBALA2(A,B,C)
  print2("Mister Ed HUCH", A, B, C)
end

function ABBALA3(A,B,C)
  print_update(os.date(), A,B,C)
end

local count=0
local count2=0



function UpdateUI()
  reagirl.Background_GetSetColor(true, 44,44,44)
  reagirl.Tabs_Add(nil, nil, -10, 380, "Add Shownote", "", {"General", "Advanced", "Smoke", "On The"}, 1, tabme)
  reagirl.NextLine()
  Lab1=reagirl.Label_Add(25, nil, "General Attributes:", "", 0, false, nil)
  reagirl.Label_SetStyle(Lab1, 6)
  
  reagirl.NextLine()
  reagirl.InputBox_Add(40, nil, -20, "Title:", 100, "", "Malik testet Hackintoshis", ABBALA2, ABBALA3)
  reagirl.NextLine()
  reagirl.InputBox_Add(40, nil, -20, "Description:", 100, "","Neue Hackintoshs braucht das Land", nil, nil)
  reagirl.NextLine()
  reagirl.InputBox_Add(40, nil, -20, "Tags:", 100, "", "Hackies, und, so", nil, nil)
  
  reagirl.NextLine()
  reagirl.CheckBox_Add(138, nil, "Spoiler Warning", "", true, tabme)
  reagirl.NextLine()
  reagirl.CheckBox_Add(138, nil, "Is Advertisement", "", true, tabme)
  reagirl.NextLine()
  reagirl.InputBox_Add(40, nil, -20, "Content Note:", 100, "", "Hackies, und, so", nil, nil)
  
  reagirl.NextLine(10)
  Lab2=reagirl.Label_Add(25, nil, "URL-Attributes:", "", 0, false, nil)
  reagirl.Label_SetStyle(Lab2, 6)
  reagirl.NextLine()
  reagirl.InputBox_Add(40, nil, -20, "Url:", 100, "", "hbbs:/audiodump.de", nil, nil)
  reagirl.NextLine()
  reagirl.InputBox_Add(40, nil, -20, "Url description:", 100, "", "Der besteste Audiodnmps auf se welt", nil, nil)
  --]]
  reagirl.NextLine(10)
  Lab3=reagirl.Label_Add(25, nil, "Chapter Image:", "HELP", 0, false, nil)
  reagirl.Label_SetStyle(Lab3, 6)
  reagirl.NextLine(3)
  Img=reagirl.Image_Add("c:\\c.png", 40, nil, 100, 100, "Chapter Image", "", ABBALA3)
  reagirl.Image_SetDraggable(Img, true, {Lab3})
  --reagirl.NextLine()
  reagirl.InputBox_Add(150, nil, -20, "Description: ", 80, "", "Cover \nof DFVA", nil, nil)
  reagirl.NextLine()
  reagirl.Slider_Add(nil, nil, -20, "Slide Me", 80, "Loo", "%", 1, 100, 1, 100, tabme)
  reagirl.NextLine(-4)
  reagirl.DropDownMenu_Add(nil, nil, -20, "Menu", 80, "Loo", {"eins", "zwo", "drei"}, 2, tabme)
  reagirl.NextLine()
  reagirl.InputBox_Add(nil, nil, -20, "License:      ", 80, "", "CC-By-NC", nil, nil)
  reagirl.NextLine()
  reagirl.InputBox_Add(nil, nil, -20, "Origin:         ", 80, "", "Wikipedia", nil, nil)
  reagirl.NextLine()
  --reagirl.InputBox_Add(nil, nil, -20, "Origin-URL:  ", 100, "", "https://www.wikipedia.com/dfva", nil, nil)
  
  
end


Images={reaper.GetResourcePath().."/Scripts/Ultraschall_Gfx/Headers/soundcheck_logo.png","c:\\f.png","c:\\m.png"}
reagirl.Gui_Open("Edit Chapter Marker Attributes", "Edit Chapter marker", 370, 425, reagirl.DockState_Retrieve("Stonehenge"), 1, 1)

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
  --reagirl.FileDropZone_SetVisibility(dropzone_id, true)
  --reagirl.Gui_PreventScrollingForOneCycle(false, false, reagirl.Checkbox_GetCheckState)
  --reagirl.Gui_PreventCloseViaEscForOneCycle()
  --ABBA={reagirl.DropDownMenu_GetMenuItems(E)}
  --ABBA[1][1]=reaper.time_precise()
  --reagirl.DropDownMenu_SetMenuItems(E, ABBA[1], 1)
  --reagirl.Gui_ForceRefresh()
  --reagirl.Elements[2]["hidden"]=true
  --reagirl.ContextMenu[1]["hidden"]=true
  --print_update(reagirl.ContextMenuZone_GetVisibility(contextmenu_id))
  --print(reagirl.FileDropZone_GetVisibility(dropzone_id))
  --gfx.update()
  --print_update(reagirl.UI_Element_IsElementAtMousePosition(LAB2))
 -- print_update(reagirl.UI_Element_GetHovered())
  --reagirl.Gui_PreventEnterForOneCycle()
  --print_update(reagirl.UI_Element_GetSetPosition(LAB, false, x, y))
--print_update(reagirl.InputBox_GetSelectedText(E))
--print_update(reagirl.Label_GetStyle(Lab1))
  if reagirl.Gui_IsOpen()==true then reaper.defer(main) end
end

main()

function ABBALA()
  print2("Mister Ed")
end

reagirl.AtEnter(ABBALA)
--Element1={reagirl.UI_Element_GetSetRunFunction(4, true, print2)}
--Element1={reagirl.UI_Element_GetSetAllVerticalOffset(true, 100)}
--print2("Pudeldu")

--reagirl.UI_Element_GetFocusedRect()

--reagirl.Label_SetLabelText(LAB, "Prime Time Of Your\nLife")



