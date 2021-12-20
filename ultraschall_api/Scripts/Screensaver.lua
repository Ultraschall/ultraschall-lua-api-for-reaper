-- Screensaver - Meo-Ada Mespotine 20th of December 2021
-- licensed under MIT-license

dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

gfx.init()
Stars={}

for i=1, 2220 do
  Stars[i]={}
  Stars[i]["count"]=math.random(255)/255
  Stars[i]["x"]=100000
  Stars[i]["y"]=100000
  Stars[i]["deltax"]=math.random(3)
  Stars[i]["deltay"]=math.random(3)
  Stars[i]["dirx"]=math.random(3)-1
  if Stars[i]["dirx"]==0 then Stars[i]["dirx"]=Stars[i]["dirx"]+1 end
  Stars[i]["diry"]=math.random(3)-1
  if Stars[i]["diry"]==0 then Stars[i]["diry"]=Stars[i]["diry"]+1 end
  Stars[i]["r"]=math.random(255)/255
  Stars[i]["g"]=math.random(255)/255
  Stars[i]["b"]=math.random(255)/255
  Stars[i]["a"]=math.random(255)/255
end

centerx=gfx.w/2
centery=gfx.h/2

function main()
  x,y=gfx.screentoclient(gfx.mouse_x, gfx.mouse_y)
  centerx=gfx.w/2
  centery=gfx.h/2
  gfx.mode=1
  for i=1, #Stars-1 do
    Stars[i]["count"]=Stars[i]["count"]+0.001
    gfx.set(Stars[i]["r"], Stars[i]["g"], Stars[i]["b"], Stars[i]["a"])
    gfx.rect(Stars[i]["x"]+centerx, Stars[i]["y"]+centery, 2, 2, true)
    gfx.arc(Stars[i]["x"]+centerx, Stars[i]["y"],Stars[i]["count"]*20,30,20,1)
    gfx.set(Stars[i]["r"], Stars[i]["g"], Stars[i]["b"], 0.3)
    gfx.line(Stars[i]["x"]+centerx, Stars[i]["y"]+centery, Stars[i+1]["x"]+centerx, Stars[i+1]["y"]+centery,1)
    if (Stars[i]["x"]>gfx.w+centerx and Stars[i]["y"]>gfx.h+centery) or (Stars[i]["x"]<-centerx*2 or Stars[i]["y"]<-centerx*2) then

      Stars[i]["x"]=x/2
      Stars[i]["y"]=y/2

      Stars[i]["dirx"]=math.random(3)-3
      if Stars[i]["dirx"]==0 then Stars[i]["dirx"]=Stars[i]["dirx"]+1 end
      Stars[i]["diry"]=math.random(3)-3
      if Stars[i]["diry"]==0 then Stars[i]["diry"]=Stars[i]["diry"]+1 end
      Stars[i]["count"]=math.random(255)/255
    end
    Stars[i]["x"]=Stars[i]["x"]+(Stars[i]["deltax"]*Stars[i]["dirx"])*0.8
    Stars[i]["y"]=Stars[i]["y"]+(Stars[i]["deltay"]*Stars[i]["diry"])*0.8

  end
  gfx.x=0
  gfx.y=0
  gfx.blurto(gfx.w,gfx.h)
  A=gfx.getchar()
  if A~=-1 then
    reaper.defer(main)
  end
end

main()