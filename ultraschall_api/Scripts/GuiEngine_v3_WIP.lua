dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

ultraschall.GuiE={}

function ultraschall.GuiE_NewGUI()
  ultraschall.GuiE={}
  ultraschall.GuiE["FocusedElement"]=1
end

function ultraschall.GuiE_OpenGUI(title, w, h, dock, x, y)
  return ultraschall.GFX_Init(title, w, h, dock, x, y)
end

function ultraschall.GuiE_CloseGUI()
  gfx.quit()
end

function ultraschall.GuiE_SetWindowBackground(r, g, b)
  ultraschall.GuiE["WindowBackgroundColorR"]=r
  ultraschall.GuiE["WindowBackgroundColorG"]=g
  ultraschall.GuiE["WindowBackgroundColorB"]=b
end

function ultraschall.GuiE_ManageGUI()
  for i=1, #ultraschall.GuiE do ultraschall.GuiE[i]["clicked"]=false end
  local Key=gfx.getchar()
  if Key==-1 then return end
  if gfx.mouse_cap&8==0 and Key==9 then ultraschall.GuiE["SaidSo"]=true ultraschall.GuiE["FocusedElement"]=ultraschall.GuiE["FocusedElement"]+1 end
  if gfx.mouse_cap&8==8 and Key==9 then ultraschall.GuiE["SaidSo"]=true ultraschall.GuiE["FocusedElement"]=ultraschall.GuiE["FocusedElement"]-1 end
  if Key==32 then ultraschall.GuiE[ultraschall.GuiE["FocusedElement"]]["clicked"]=true end
  local clickstate, specific_clickstate, mouse_cap, click_x, click_y, drag_x, drag_y, mouse_wheel, mouse_hwheel = ultraschall.GFX_GetMouseCap(15, 5)
  if (specific_clickstate=="FirstCLK") then
    for i=#ultraschall.GuiE, 1, -1 do
      if gfx.mouse_x>=ultraschall.GuiE[i]["x"] and
         gfx.mouse_x<=ultraschall.GuiE[i]["x"]+ultraschall.GuiE[i]["w"] and
         gfx.mouse_y>=ultraschall.GuiE[i]["y"] and
         gfx.mouse_y<=ultraschall.GuiE[i]["y"]+ultraschall.GuiE[i]["h"] then
         ultraschall.GuiE["FocusedElement"]=i
         ultraschall.GuiE["SaidSo"]=true 
         ultraschall.GuiE[i]["clicked"]=true
         break
      end
    end
  end
  ultraschall.GuiE_DrawGui()
end

function ultraschall.GuiE_DummyElement()  
  ultraschall.GuiE[#ultraschall.GuiE+1]={}
  ultraschall.GuiE[#ultraschall.GuiE]["GUI_Element_Type"]="Dummy"
  ultraschall.GuiE[#ultraschall.GuiE]["Name"]="Dummy"
  ultraschall.GuiE[#ultraschall.GuiE]["Description"]="Description"
  ultraschall.GuiE[#ultraschall.GuiE]["Tooltip"]="Tooltip"
  ultraschall.GuiE[#ultraschall.GuiE]["x"]=math.random(40)
  ultraschall.GuiE[#ultraschall.GuiE]["y"]=math.random(40)
  ultraschall.GuiE[#ultraschall.GuiE]["w"]=math.random(40)
  ultraschall.GuiE[#ultraschall.GuiE]["h"]=math.random(40)
end


function ultraschall.GuiE_DrawGui()
  -- no docs in API-docs
  local selected
  gfx.set(ultraschall.GuiE["WindowBackgroundColorR"],ultraschall.GuiE["WindowBackgroundColorG"],ultraschall.GuiE["WindowBackgroundColorB"])
  gfx.rect(0,0,gfx.w,gfx.h,1)
  for i=#ultraschall.GuiE, 1, -1 do
    if ultraschall.GuiE["FocusedElement"]==i then selected=true else selected=false end
    if ultraschall.GuiE[i]["GUI_Element_Type"]=="Dummy" then 
      ultraschall.GuiE_DrawDummyElement(selected,
        ultraschall.GuiE[i]["clicked"],
        gfx.mouse_cap,
        ultraschall.GuiE[i]["Name"],
        ultraschall.GuiE[i]["Description"], 
        ultraschall.GuiE[i]["Tooltip"], 
        ultraschall.GuiE[i]["x"], 
        ultraschall.GuiE[i]["y"],
        ultraschall.GuiE[i]["w"],
        ultraschall.GuiE[i]["h"]
      ) 
      B=i
    end
  end
end

function ultraschall.GuiE_DrawDummyElement(selected, clicked, mouse_cap, name, description, tooltip, x, y, w, h)
  -- no docs in API-docs
  gfx.set(1)
  gfx.rect(x,y,w,h,1)
  if selected==true then
    gfx.set(0.5)
    gfx.rect(x,y,w,h,0)
    if clicked~=true and ultraschall.GuiE["SaidSo"]==true and reaper.osara_outputMessage~=nil then
      reaper.osara_outputMessage("Dummy Element "..description.." focused")
      ultraschall.GuiE["SaidSo"]=nil
    end
    if mouse_cap==1 and clicked==true and reaper.osara_outputMessage~=nil then
      reaper.osara_outputMessage("Dummy Element "..description.." clicked")
    elseif mouse_cap==2 and clicked==true then
      gfx.showmenu("Huch|Tuch|Much")
    end
  end
end

ultraschall.GuiE_OpenGUI("Test")
ultraschall.GuiE_NewGUI()
ultraschall.GuiE_SetWindowBackground(0.10, 0, 0)
ultraschall.GuiE_DummyElement()
ultraschall.GuiE_DummyElement()

function main()
  ultraschall.GuiE_ManageGUI()
  reaper.defer(main)
end

main()
