-- Event Manager - Alpha
-- Meo Mespotine
--
-- Issues: Api functions don't recognize registered EventIdentifiers who weren't processed yet by the EventManager.
--         Must be fixed
-- ToDo: Managen, dass nur ein Eventmanager gestartet wird
--       Es sollte möglich sein Actions in verschiedenen Sections zu starten, zumindest Main und MediaExplorer(beide drin), Midi wäre auch nice
--
-- Api eigene Funktionen:
--      StartEventManager, StopEventManager, GetEventStateChunk, PauseEvent

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
                              true, run the actions only once when event occured(checkfunction=true); 
                              false, run the actions again and again until eventcheck returns false
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

EventTable={}
CountOfEvents=0

function atexit()
  reaper.DeleteExtState("ultraschall_eventmanager", "running", false)
  reaper.DeleteExtState("ultraschall_eventmanager", "eventregister", false)
  reaper.DeleteExtState("ultraschall_eventmanager", "eventremove", false)
  reaper.DeleteExtState("ultraschall_eventmanager", "eventset", false)
  reaper.DeleteExtState("ultraschall_eventmanager", "eventpause", false)
  reaper.DeleteExtState("ultraschall_eventmanager", "eventresume", false)
  reaper.DeleteExtState("ultraschall_eventmanager", "state", false)
  reaper.DeleteExtState("ultraschall_eventmanager", "registered_scripts", false)
  
end

reaper.atexit(atexit)

OPO = reaper.SetExtState("ultraschall_eventmanager", "running", "true", false)

function GetIDFromEventIdentifier(EventIdentifier)
  for i=1, CountOfEvents do
    if EventTable[i]["EventIdentifier"]==EventIdentifier then
      return i
    end
  end
  return -1
end

function PauseEvent(id)
  EventTable[id]["Paused"]=true
  UpdateEventList_ExtState()
end

function ResumeEvent(id)
  EventTable[id]["Paused"]=false
  UpdateEventList_ExtState()
end

function PauseEvent_Identifier(identifier)
-- pause event by identifier
  for i=1, CountOfEvents do
    if EventTable[i]["EventIdentifier"]==identifier then
      PauseEvent(i)
      break
    end
  end
end

function ResumeEvent_Identifier(identifier)
-- remove event by identifier
  for i=1, CountOfEvents do
    if EventTable[i]["EventIdentifier"]==identifier then
      ResumeEvent(i)
      break
    end
  end
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
      print("An error happened, while adding the event to the eventmanager. Please report this as a bug to me: \n\n\t\tultraschall.fm/api \n\nPlease include the following lines in your bugreport(screenshot is sufficient): \n\n"..EventStateChunk)
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
      print(ActionsTable[i]["section"], ActionsTable[i]["action"])
      print("An error happened, while adding the event to the eventmanager. Please report this as a bug to me: \n\n\t\tultraschall.fm/api \n\nPlease include the following lines in your bugreport(screenshot is sufficient): \n\n"..EventStateChunk)
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
      print("An error happened, while setting the event in the eventmanager. Please report this as a bug to me: \n\n\t\tultraschall.fm/api \n\nPlease include the following lines in your bugreport(screenshot is sufficient): \n\n"..EventStateChunk)
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
      print(ActionsTable[i]["section"], ActionsTable[i]["action"])
      print("An error happened, while setting the event in the eventmanager. Please report this as a bug to me: \n\n\t\tultraschall.fm/api \n\nPlease include the following lines in your bugreport(screenshot is sufficient): \n\n"..EventStateChunk)
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
  
  -- Pause Events
  if reaper.GetExtState("ultraschall_eventmanager", "eventpause")~="" then
    StateRegister=reaper.GetExtState("ultraschall_eventmanager", "eventpause")
    for k in string.gmatch(StateRegister, "(.-)\n") do
      PauseEvent_Identifier(k)
    end
    reaper.SetExtState("ultraschall_eventmanager", "eventpause", "", false)
  end
  
  -- Resume Events
  if reaper.GetExtState("ultraschall_eventmanager", "eventresume")~="" then
    StateRegister=reaper.GetExtState("ultraschall_eventmanager", "eventresume")
    for k in string.gmatch(StateRegister, "(.-)\n") do
      ResumeEvent_Identifier(k)
    end
    reaper.SetExtState("ultraschall_eventmanager", "eventresume", "", false)
  end  
  
end


function main()
  current_state=nil  
  
  for i=1, CountOfEvents do
    if EventTable[i]["Paused"]==false then
    --print2(i, EventTable[i]["Paused"])
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
      if doit==true then
        state_retval, current_state=pcall(EventTable[i]["Function"], EventTable[i]["UserSpace"])
        if state_retval==false then 
          PauseEvent(i)
          print("Error in eventchecking-function", "Event: "..EventTable[i]["EventName"], EventTable[i]["EventIdentifier"], "Error: "..current_state, "Eventchecking for this event paused", " ")
        else     
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
    end
  end
  
  GetNewEventsFromEventRegisterExtstate()

  if enditall~=true then 
    -- if StopEvent hasn't been called yet, keep the eventmanager going
    if reaper.HasExtState("ultraschall_eventmanager", "running")==true then reaper.defer(main) end
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

