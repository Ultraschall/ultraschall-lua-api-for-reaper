-- Event Manager - Prototype
-- Meo Mespotine
--
-- ToDo: SetEvent, PauseEvent
--       Managen, dass nur ein Eventmanager gestartet wird
--       Es sollte möglich sein Actions in verschiedenen Sections zu starten, zumindest Main und MediaExplorer(beide drin), Midi wäre auch nice
--
-- Api eigene Funktionen:
--      StartEventManager, StopEventManager, AddEvent, SetEvent, DeleteEvent, GetEventManagerParameters(Funktion außerhalb des Eventmanagers, eher in der API selbst beheimatet)
--      GetEventStateChunk, PauseEvent

--[[
EventStateChunk-specs:

  Eventname: Textoneliner; 
      a name for this event for better identification later on
  EventIdentifier: identifier-oneliner-guid; 
      a unique identifier for this event
  SourceScriptIdentifier: identifier-guid; 
      the Scriptidentifier of the script, which added the event
  CheckAllXSeconds: number; 
      the number of seconds inbetween checks; -1, check every defercycle
  CheckForXSeconds: number; 
      the number of seconds to check for this event; -1, until stopped
  StartActionsOnceDuringTrue: boolean;  
      true, run the actions only once when event occured(checkfunction=true); false, run the actions again and again until eventcheck returns false
  Paused: boolean, 
      if the eventcheck is currently paused or not
  Function: Base64string-oneliner
      the Lua-binary-function as BASE64-encoded string
  CountOfActions: number; 
      number of actions to run if event happens

The following as often as CountOfActions says
  Action: number; 
      the action command number of the action to run
  Section: number; 
      the section of the action to run

Example:

Eventname: Tudelu
EventIdentifier: {D0FB8CE2-FFFD-40CB-9AF6-8C6FE121330B}
SourceScriptIdentifier: ScriptIdentifier-{C47C1F6A-5CAC-4B48-A0DD-760A62246D6B}
CheckAllXSeconds: 1
CheckForXSeconds: 10
StartActionsOnceDuringTrue: true
Paused: false
Function: G0x1YVMAGZMNChoKBAgECAh4VgAAAAAAAAAAAAAAKHdAAXpAQzpcVWx0cmFzY2hhbGwtSGFja3ZlcnNpb25fMy4yX1VTX2JldGFfMl83N1xTY3JpcHRzXC4uXFVzZXJQbHVnaW5zXHVsdHJhc2NoYWxsX2FwaVxcU2NyaXB0c1x1bHRyYXNjaGFsbF9FdmVudE1hbmFnZXIubHVhDAAAABIAAAAAAAILAAAABgBAAAdAQAAkgIAAH4BAAB6AAIADAIAAJgAAAR5AAIADAAAAJgAAASYAgAADAAAABAdyZWFwZXIEDUdldFBsYXlTdGF0ZRMBAAAAAAAAAAEAAAAAAAAAAAALAAAADQAAAA0AAAANAAAADQAAAA0AAAAOAAAADgAAAA4AAAAQAAAAEAAAABIAAAAAAAAAAQAAAAVfRU4=
CountOfActions: 2
Action: 40105
Section: 0
Action: 40105
Section: 0
--]]
deferoffset=0.130 -- the offset of delay, introduced by the defer-management of Reaper. Maybe useless?

dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

-- testfunction
function IsPlayStatePlay(UserSpace)
  if reaper.GetPlayState()==1 then 
    return true
  else
    return false
  end
end

EventTable={}
CountOfEvents=0

--[[
-- testevents
EventTable[1]={}
  -- Attributes
  EventTable[1]["EventName"]="Event1"                         -- drin
  EventTable[1]["Function"]=IsPlayStatePlay                   -- drin
  EventTable[1]["CheckAllXSeconds"]=2                         -- drin, kann nicht 100% präzise angegeben werden, wegen defer-Management-lag; -1, checke jeden defer-cycle(~30 times per second)
  EventTable[1]["CheckAllXSeconds_current"]=nil               -- CheckZeit an dem Event gecheckt wird; wird gesetzt durch EventManager
  EventTable[1]["CheckForXSeconds"]=-1                        -- drin, kann nicht 100% präzise angegeben werden, wegen defer-Management-lag; -1, checke bis auf Widerruf
  EventTable[1]["CheckForXSeconds_current"]=nil               -- StopZeit ab wann Event nicht mehr gecheckt wird; wird gesetzt durch EventManager
  EventTable[1]["StartActionsOnceDuringTrue"]=false           -- drin
  EventTable[1]["StartActionsOnceDuringTrue_laststate"]=false -- drin
  EventTable[1]["ScriptIdentifier"]=""                        -- script-identifier, damit alle events des scripts beendet werden können
  EventTable[1]["EventIdentifier"]=""                              -- eindeutiger identifier für dieses Event
  EventTable[1]["CountOfActions"]=5                           -- drin
  EventTable[1]["Paused"]==false                              -- true, wenn der Event temporär nicht gecheckt werden soll(pausiert), sonst checken
  EventTable[1]["UserSpace"]                                  -- eine Table, in der sich die Checkfunktion Sachen zwischenspeichern kann. Jedes Event hat seine eigene UserSpace-Table.

  -- Actions
  EventTable[1][1]=40105                                      -- drin
  EventTable[1]["sec"..1]=0                                   -- section
  EventTable[1][2]=40105                                      -- drin
  EventTable[1]["sec"..2]=0                                   -- section
  EventTable[1][3]=40105                                      -- drin
  EventTable[1]["sec"..3]=0                                   -- section
  EventTable[1][4]=40105                                      -- drin
  EventTable[1]["sec"..4]=0                                   -- section
  EventTable[1][5]=40105                                      -- drin
  EventTable[1]["sec"..5]=0                                   -- section
  EventTable[1][6]=40105                                      -- drin
  EventTable[1]["sec"..6]=0                                   -- section
  EventTable[1][7]=40105                                      -- drin
  EventTable[1]["sec"..7]=0                                   -- section
  EventTable[1][8]=40105                                      -- drin
  EventTable[1]["sec"..8]=0                                   -- section
  EventTable[1][9]=40105--40016                               -- drin
  EventTable[1]["sec"..9]=0                                   -- sections

  
  EventTable[2]={}
  EventTable[2]["EventName"]="Event2"                         -- drin
  EventTable[2]["Function"]=IsPlayStatePlay                   -- drin
  EventTable[2]["CheckAllXSeconds"]=1                         -- drin, kann nicht 100% präzise angegeben werden, wegen defer-Management-lag; -1, checke jeden defer-cycle(~30 times per second)
  EventTable[2]["CheckAllXSeconds_current"]=nil               -- CheckZeit an dem Event gecheckt wird; wird gesetzt durch EventManager
  EventTable[2]["CheckForXSeconds"]=-1                        -- drin, kann nicht 100% präzise angegeben werden, wegen defer-Management-lag; -1, checke bis auf Widerruf
  EventTable[2]["CheckForXSeconds_current"]=nil               -- StopZeit ab wann Event nicht mehr gecheckt wird; wird gesetzt durch EventManager
  EventTable[2]["StartActionsOnceDuringTrue"]=false           -- drin
  EventTable[2]["StartActionsOnceDuringTrue_laststate"]=false -- drin
  EventTable[2]["ScriptIdentifier"]=""                        -- script-identifier, damit alle events des scripts beendet werden können
  EventTable[2]["EventIdentifier"]=""                              -- eindeutiger identifier für dieses Event
  EventTable[2]["CountOfActions"]=1                           -- drin
  EventTable[2]["Paused"]==false                              -- true, wenn der Event temporär nicht gecheckt werden soll(pausiert), sonst checken
  EventTable[2]["UserSpace"]                                  -- eine Table, in der sich die Checkfunktion Sachen zwischenspeichern kann. Jedes Event hat seine eigene UserSpace-Table.
  
  EventTable[2][1]=41666                                      -- drin
  EventTable[2]["sec"..1]=0                                   -- sections
  EventTable[2][2]=41666                                      -- drin
  EventTable[2]["sec"..2]=0                                   -- sections
  EventTable[2][3]=41666                                      -- drin
  EventTable[2]["sec"..3]=0                                   -- sections
  EventTable[2][4]=40105                                      -- drin
  EventTable[2]["sec"..4]=0                                   -- sections
  EventTable[2][5]=40105                                      -- drin
  EventTable[2]["sec"..5]=0                                   -- sections
  EventTable[2][6]=40105                                      -- drin
  EventTable[2]["sec"..6]=0                                   -- sections
  EventTable[2][7]=40105                                      -- drin
  EventTable[2]["sec"..7]=0                                   -- sections
  EventTable[2][8]=40105                                      -- drin
  EventTable[2]["sec"..8]=0                                   -- sections
  EventTable[2][9]=40105--40016                               -- drin
  EventTable[2]["sec"..9]=0                                   -- sections
  
  
  EventTable[3]={}
  EventTable[3]["EventName"]="Event3"                         -- drin
  EventTable[3]["Function"]=IsPlayStatePlay                   -- drin
  EventTable[3]["CheckAllXSeconds"]=1                         -- drin, kann nicht 100% präzise angegeben werden, wegen defer-Management-lag; -1, checke jeden defer-cycle(~30 times per second)
  EventTable[3]["CheckAllXSeconds_current"]=nil               -- CheckZeit an dem Event gecheckt wird; wird gesetzt durch EventManager
  EventTable[3]["CheckForXSeconds"]=10                        -- drin, kann nicht 100% präzise angegeben werden, wegen defer-Management-lag; -1, checke bis auf Widerruf
  EventTable[3]["CheckForXSeconds_current"]=nil               -- StopZeit ab wann Event nicht mehr gecheckt wird; wird gesetzt durch EventManager
  EventTable[3]["StartActionsOnceDuringTrue"]=false           -- drin
  EventTable[3]["StartActionsOnceDuringTrue_laststate"]=false -- drin
  EventTable[3]["ScriptIdentifier"]=""                        -- script-identifier, damit alle events des scripts beendet werden können
  EventTable[3]["EventIdentifier"]=""                              -- eindeutiger identifier für dieses Event
  EventTable[3]["Paused"]==false                              -- true, wenn der Event temporär nicht gecheckt werden soll(pausiert), sonst checken
  EventTable[3]["CountOfActions"]=3                           -- drin
  EventTable[3]["UserSpace"]                                  -- eine Table, in der sich die Checkfunktion Sachen zwischenspeichern kann. Jedes Event hat seine eigene UserSpace-Table.
  
  EventTable[3][1]=1068                                       -- drin
  EventTable[3]["sec"..1]=0                                   -- sections
  EventTable[3][2]=41666                                      -- drin
  EventTable[3]["sec"..2]=0                                   -- sections
  EventTable[3][3]=41666                                      -- drin
  EventTable[3]["sec"..3]=0                                   -- sections
  EventTable[3][4]=40105                                      -- drin
  EventTable[3]["sec"..4]=0                                   -- sections
  EventTable[3][5]=40105                                      -- drin
  EventTable[3]["sec"..5]=0                                   -- sections
  EventTable[3][6]=40105                                      -- drin
  EventTable[3]["sec"..6]=0                                   -- sections
  EventTable[3][7]=40105                                      -- drin
  EventTable[3]["sec"..7]=0                                   -- sections
  EventTable[3][8]=40105                                      -- drin
  EventTable[3]["sec"..8]=0                                   -- sections
  EventTable[3][9]=40016                                      -- drin
  EventTable[3]["sec"..9]=0                                   -- sections

--]]

function GetIDFromEventIdentifier(EventIdentifier)
  for i=1, CountOfEvents do
    if EventTable[i]["EventIdentifier"]==EventIdentifier then
      return i
    end
  end
  return -1
end

function AddEvent(EventStateChunk)
--  print2(EventStateChunk)
  local EventName=EventStateChunk:match("Eventname: (.-)\n")
  local EventIdentifier=EventStateChunk:match("EventIdentifier: (.-)\n")
  local SourceScriptIdentifier=EventStateChunk:match("SourceScriptIdentifier: (.-)\n")
  local CheckAllXSeconds=tonumber(EventStateChunk:match("CheckAllXSeconds: (.-)\n"))
  local CheckForXSeconds=tonumber(EventStateChunk:match("CheckForXSeconds: (.-)\n"))
  local StartActionsOnceDuringTrue=toboolean(EventStateChunk:match("StartActionsOnceDuringTrue: (.-)\n"))
  local Function=EventStateChunk:match("Function: (.-)\n")
  local Paused=toboolean(EventStateChunk:match("Paused: (.-)\n()"))
  --print(Paused)
  local CountOfActions,offset=EventStateChunk:match("CountOfActions: (.-)\n()")  
  local CountOfActions=tonumber(CountOfActions)
  
  if EventName==nil or
     EventIdentifier==nil or
     SourceScriptIdentifier==nil or
     CheckAllXSeconds==nil or
     CheckForXSeconds==nil or
     StartActionsOnceDuringTrue==nil or
     Function==nil or
     CountOfActions==nil then
      print2("An error happened, while adding the event to the eventmanager. Please report this as a bug to me: \n\n\t\tultraschall.fm/api \n\nPlease include the following lines in your bugreport(screenshot is sufficient): \n\n"..EventStateChunk)
      return
  end
  local actions=EventStateChunk:sub(offset,-1)
  
  local ActionsTable={}
  for i=1, CountOfActions do
    ActionsTable[i]={}
    ActionsTable[i]["action"], ActionsTable[i]["section"], offset=actions:match("Action: (.-)\nSection: (.-)\n()")
    ActionsTable[i]["action"]=tonumber(ActionsTable[i]["action"])
    ActionsTable[i]["section"]=tonumber(ActionsTable[i]["section"])
    if ActionsTable[i]["section"]==nil or ActionsTable[i]["action"]==nil then
      print2(ActionsTable[i]["section"], ActionsTable[i]["action"])
      print2("An error happened, while adding the event to the eventmanager. Please report this as a bug to me: \n\n\t\tultraschall.fm/api \n\nPlease include the following lines in your bugreport(screenshot is sufficient): \n\n"..EventStateChunk)
    end
    actions=actions:sub(offset,-1)
  end
  
  CountOfEvents=CountOfEvents+1
  EventTable[CountOfEvents]={}
  -- Attributes
  EventTable[CountOfEvents]["EventName"]=EventName
  EventTable[CountOfEvents]["Function"]=load(ultraschall.Base64_Decoder(Function))
  EventTable[CountOfEvents]["FunctionOrg"]=Function
  EventTable[CountOfEvents]["CheckAllXSeconds"]=CheckAllXSeconds                         -- drin, kann nicht 100% präzise angegeben werden, wegen defer-Management-lag; -1, checke jeden defer-cycle(~30 times per second)
  EventTable[CountOfEvents]["CheckAllXSeconds_current"]=nil               -- CheckZeit an dem Event gecheckt wird; wird gesetzt durch EventManager
  EventTable[CountOfEvents]["CheckForXSeconds"]=CheckForXSeconds                        -- drin, kann nicht 100% präzise angegeben werden, wegen defer-Management-lag; -1, checke bis auf Widerruf
  EventTable[CountOfEvents]["CheckForXSeconds_current"]=nil               -- StopZeit ab wann Event nicht mehr gecheckt wird; wird gesetzt durch EventManager
  EventTable[CountOfEvents]["StartActionsOnceDuringTrue"]=StartActionsOnceDuringTrue           -- drin
  EventTable[CountOfEvents]["StartActionsOnceDuringTrue_laststate"]=false -- drin
  EventTable[CountOfEvents]["ScriptIdentifier"]=SourceScriptIdentifier                        -- script-identifier, damit alle events des scripts beendet werden können
  EventTable[CountOfEvents]["EventIdentifier"]=EventIdentifier                              -- eindeutiger identifier für dieses Event
  EventTable[CountOfEvents]["CountOfActions"]=CountOfActions                           -- drin
  EventTable[CountOfEvents]["Paused"]=Paused
  EventTable[CountOfEvents]["UserSpace"]={}
  
  
  for i=1, CountOfActions do
    EventTable[CountOfEvents][i]=ActionsTable[i]["action"]
    EventTable[CountOfEvents]["sec"..i]=ActionsTable[i]["section"]
  end
  UpdateEventList_ExtState()
end

function SetEvent(EventStateChunk)
--  print2(EventStateChunk)
  local EventName=EventStateChunk:match("Eventname: (.-)\n")
  local EventIdentifier=EventStateChunk:match("EventIdentifier: (.-)\n")
  local SourceScriptIdentifier=EventStateChunk:match("SourceScriptIdentifier: (.-)\n")
  local CheckAllXSeconds=tonumber(EventStateChunk:match("CheckAllXSeconds: (.-)\n"))
  local CheckForXSeconds=tonumber(EventStateChunk:match("CheckForXSeconds: (.-)\n"))
  local StartActionsOnceDuringTrue=toboolean(EventStateChunk:match("StartActionsOnceDuringTrue: (.-)\n"))
  local Function=EventStateChunk:match("Function: (.-)\n")
  local Paused=toboolean(EventStateChunk:match("Paused: (.-)\n()"))
  local CountOfActions,offset=EventStateChunk:match("CountOfActions: (.-)\n()")  
  local CountOfActions=tonumber(CountOfActions)
  
  if EventName==nil or
     EventIdentifier==nil or
     SourceScriptIdentifier==nil or
     CheckAllXSeconds==nil or
     CheckForXSeconds==nil or
     StartActionsOnceDuringTrue==nil or
     Function==nil or
     CountOfActions==nil then
      print2("An error happened, while setting the event in the eventmanager. Please report this as a bug to me: \n\n\t\tultraschall.fm/api \n\nPlease include the following lines in your bugreport(screenshot is sufficient): \n\n"..EventStateChunk)
      return
  end
  local actions=EventStateChunk:sub(offset,-1)
  
  local ActionsTable={}
  for i=1, CountOfActions do
    ActionsTable[i]={}
    ActionsTable[i]["action"], ActionsTable[i]["section"], offset=actions:match("Action: (.-)\nSection: (.-)\n()")
    ActionsTable[i]["action"]=tonumber(ActionsTable[i]["action"])
    ActionsTable[i]["section"]=tonumber(ActionsTable[i]["section"])
    if ActionsTable[i]["section"]==nil or ActionsTable[i]["action"]==nil then
      print2(ActionsTable[i]["section"], ActionsTable[i]["action"])
      print2("An error happened, while setting the event in the eventmanager. Please report this as a bug to me: \n\n\t\tultraschall.fm/api \n\nPlease include the following lines in your bugreport(screenshot is sufficient): \n\n"..EventStateChunk)
    end
    actions=actions:sub(offset,-1)
  end

  
  EventID=GetIDFromEventIdentifier(EventIdentifier)
  if EventID==-1 then return end
  -- Attributes
  EventTable[EventID]["EventName"]=EventName
  EventTable[EventID]["Function"]=load(ultraschall.Base64_Decoder(Function))
  EventTable[EventID]["CheckAllXSeconds"]=CheckAllXSeconds                         -- drin, kann nicht 100% präzise angegeben werden, wegen defer-Management-lag; -1, checke jeden defer-cycle(~30 times per second)
  EventTable[EventID]["CheckAllXSeconds_current"]=nil               -- CheckZeit an dem Event gecheckt wird; wird gesetzt durch EventManager
  EventTable[EventID]["CheckForXSeconds"]=CheckForXSeconds                        -- drin, kann nicht 100% präzise angegeben werden, wegen defer-Management-lag; -1, checke bis auf Widerruf
  EventTable[EventID]["CheckForXSeconds_current"]=nil               -- StopZeit ab wann Event nicht mehr gecheckt wird; wird gesetzt durch EventManager
  EventTable[EventID]["StartActionsOnceDuringTrue"]=StartActionsOnceDuringTrue           -- drin
  EventTable[EventID]["StartActionsOnceDuringTrue_laststate"]=false -- drin
  EventTable[EventID]["ScriptIdentifier"]=SourceScriptIdentifier                        -- script-identifier, damit alle events des scripts beendet werden können
  EventTable[EventID]["CountOfActions"]=CountOfActions                           -- drin
  EventTable[EventID]["Paused"]=Paused
  EventTable[EventID]["UserSpace"]={}
  
  
  for i=1, CountOfActions do
    EventTable[EventID][i]=ActionsTable[i]["action"]
    EventTable[EventID]["sec"..i]=ActionsTable[i]["section"]
  end
  UpdateEventList_ExtState()
end

function RemoveEvent_ID(id)
-- remove event by id
  table.remove(EventTable, id)
  CountOfEvents=CountOfEvents-1
  UpdateEventList_ExtState()
end

function RemoveEvent_Identifier(identifier)
-- remove event by identifier
  for i=1, CountOfEvents do
    if EventTable[i]["EventIdentifier"]==identifier then
      table.remove(EventTable,i)
      CountOfEvents=CountOfEvents-1
      break
    end
  end
  UpdateEventList_ExtState()
end

function RemoveEvent_ScriptIdentifier(script_identifier)
-- remove event by script_identifier
  for i=1, CountOfEvents do
    if EventTable[i]["ScriptIdentifier"]==script_identifier then
      table.remove(EventTable,i)
      CountOfEvents=CountOfEvents-1
    end
  end
  UpdateEventList_ExtState()
end


function GetNewEventsFromEventRegisterExtstate()
  -- Add Events
  if reaper.GetExtState("ultraschall_eventmanager", "eventregister")~="" then
    StateRegister=reaper.GetExtState("ultraschall_eventmanager", "eventregister")
    for k in string.gmatch(StateRegister, "(.-\n)EndEvent\n") do
      AddEvent(k)
    end
    reaper.SetExtState("ultraschall_eventmanager", "eventregister", "", false)
  end
  
  
  -- Delete Events
  if reaper.GetExtState("ultraschall_eventmanager", "eventremove")~="" then
    StateRegister=reaper.GetExtState("ultraschall_eventmanager", "eventremove")
    for k in string.gmatch(StateRegister, "(.-)\n") do
      RemoveEvent_Identifier(k)
    end
    reaper.SetExtState("ultraschall_eventmanager", "eventremove", "", false)
  end

  -- Set Events
  if reaper.GetExtState("ultraschall_eventmanager", "eventset")~="" then
    StateRegister=reaper.GetExtState("ultraschall_eventmanager", "eventset")
    for k in string.gmatch(StateRegister, "(.-\n)EndEvent\n") do
      SetEvent(k)
    end
    reaper.SetExtState("ultraschall_eventmanager", "eventset", "", false)
  end
end


function main()
  current_state=nil  
  
  for i=1, CountOfEvents do
    if EventTable[i]["Paused"]==false then
    --print2(i, EventTable[i]["Paused"])
      current_state=EventTable[i]["Function"](EventTable[i]["UserSpace"])
      doit=false
      -- check every x second
      if EventTable[i]["CheckAllXSeconds"]~=-1 and EventTable[i]["CheckAllXSeconds_current"]==nil then
        -- set timer to the time, when the check shall be done
        EventTable[i]["CheckAllXSeconds_current"]=reaper.time_precise()+EventTable[i]["CheckAllXSeconds"]
        doit=false
      elseif EventTable[i]["CheckAllXSeconds_current"]~=nil 
            and EventTable[i]["CheckAllXSeconds"]~=-1 and 
            EventTable[i]["CheckAllXSeconds_current"]<reaper.time_precise()-deferoffset then
        -- if timer is up, start the check
        EventTable[i]["CheckAllXSeconds_current"]=nil
        doit=true
      elseif EventTable[i]["CheckAllXSeconds"]==-1 then
        -- if no timer is set at all for this event, run all actions
        doit=true
      end
  
      -- let's run the actions, if requested
      if current_state==true and doit==true then
          if EventTable[i]["StartActionsOnceDuringTrue"]==false then
            -- if actions shall be only run as long as the event happens
            for a=1, EventTable[i]["CountOfActions"] do
              A=reaper.time_precise()
              if EventTable[i]["sec"..a]==0 then
                reaper.Main_OnCommand(EventTable[i][a],0)
              elseif EventTable[i]["sec"..a]==32063 then
                retval = ultraschall.MediaExplorer_OnCommand(EventTable[i][a])
              end
            end
          elseif EventTable[i]["StartActionsOnceDuringTrue"]==true and EventTable[i]["StartActionsOnceDuringTrue_laststate"]==false then
            -- if actions shall be only run once, when event-statechange happens
            for a=1, EventTable[i]["CountOfActions"] do
              A=reaper.time_precise()
              if EventTable[i]["sec"..a]==0 then
                reaper.Main_OnCommand(EventTable[i][a],0)
              elseif EventTable[i]["sec"..a]==32063 then
                retval = ultraschall.MediaExplorer_OnCommand(EventTable[i][a])
              end
            end
          end
          EventTable[i]["StartActionsOnceDuringTrue_laststate"]=true        
      else
        -- if no event shall be run, set laststate of StartActionsOnceDuringTrue_laststate to false
        EventTable[i]["StartActionsOnceDuringTrue_laststate"]=false
      end    
      
      -- check for x seconds, then remove the event from the list
      if EventTable[i]["CheckForXSeconds"]~=-1 and EventTable[i]["CheckForXSeconds_current"]==nil then
        -- set timer, for when the checking shall be finished and the event being removed
        EventTable[i]["CheckForXSeconds_current"]=reaper.time_precise()+EventTable[i]["CheckForXSeconds"]
      elseif EventTable[i]["CheckForXSeconds_current"]~=nil and EventTable[i]["CheckForXSeconds"]~=-1 and EventTable[i]["CheckForXSeconds_current"]<=reaper.time_precise()-deferoffset then
        -- if the timer for checking for this event is up, remove the event
        RemoveEvent_ID(i)
      end
    end
  end
  
  GetNewEventsFromEventRegisterExtstate()

  if enditall~=true then 
    -- if StopEvent hasn't been called yet, keep the eventmanager going
    reaper.defer(main) 
    --UpdateEventList_ExtState() 
  end
end

function UpdateEventList_ExtState()
  -- puts all current events and their attributes into an extstate, which can be read from other scripts
  local String="EventManager State\nLast update: "..os.date().."\nNumber of Events: "..CountOfEvents.."\n\n"
  for i=1, CountOfEvents do
    String=String.."Event #:"..i..
        "\nEventName: "..EventTable[i]["EventName"]..
        "\nEventIdentifier: "..EventTable[i]["EventIdentifier"]..
        "\nStartedByScript: "..EventTable[i]["ScriptIdentifier"]..
        "\nCheckAllXSeconds: "..EventTable[i]["CheckAllXSeconds"]..
        "\nCheckForXSeconds: "..EventTable[i]["CheckForXSeconds"]..
        "\nEventPaused: "..tostring(EventTable[i]["Paused"])..
        "\nStartActionsOnlyOnceDuringTrue: "..tostring(EventTable[i]["StartActionsOnceDuringTrue"])..
        "\nFunction: ".. EventTable[CountOfEvents]["FunctionOrg"]..
        "\nNumber of Actions: "..EventTable[i]["CountOfActions"].."\n"
        for a=1, EventTable[i]["CountOfActions"] do
          String=String..a.." - ".." section: "..EventTable[i]["sec"..a].." action: "..EventTable[i][a].."\n"
        end
        String=String.."EndEvent".."\n"
  end
  reaper.SetExtState("ultraschall_eventmanager", "state", String, false)
end

function StopAction()
  -- stops the eventmanager and clears up behind it

  EventTable=""
  reaper.SetExtState("ultraschall_eventmanager", "state", "", false)
  enditall=true
end


UpdateEventList_ExtState() -- debugline, shall be put into add/setevents-functions later
main()




local EventStateChunk=[[
Eventname: Tudelu
EventIdentifier: ]]..reaper.genGuid()..[[

SourceScriptIdentifier: ScriptIdentifier-]]..reaper.genGuid()..[[

CheckAllXSeconds: 1
CheckForXSeconds: -1
StartActionsOnceDuringTrue: true
Paused: false
Function: ]]..ultraschall.Base64_Encoder(string.dump(IsPlayStatePlay))..[[

CountOfActions: 1
Action: 40105
Section: 0
]]

local EventStateChunk2=[[
Eventname: Tudelu2
EventIdentifier: ]]..reaper.genGuid()..[[

SourceScriptIdentifier: ScriptIdentifier-]]..reaper.genGuid()..[[

CheckAllXSeconds: 1
CheckForXSeconds: -1
StartActionsOnceDuringTrue: true
Paused: false
Function: ]]..ultraschall.Base64_Encoder(string.dump(IsPlayStatePlay))..[[

CountOfActions: 1
Action: 1011
Section: 32063
]]


--A=ultraschall.Base64_Encoder(string.dump(IsPlayStatePlay))
--print3(A)
--print3(EventStateChunk)
--AddEvent(EventStateChunk)
--AddEvent(EventStateChunk2)

