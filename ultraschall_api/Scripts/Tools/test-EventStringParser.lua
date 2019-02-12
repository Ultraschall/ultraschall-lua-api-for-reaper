dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

--The ConditionString. Should it contain a guid of the caller-script as well? Probably, for deleting conditions later on or returning retvals
-- such a guid must be added by the PassConditionToEventmanager-function to the ConditionString
-- Format: Action_either_actioncommandid_or_a_scripfilenamewithpath(boolean ismidi, string midi_hwnd(0 for last MIDIEditor, ignored when idmidi==false), optional string parm1, ... optional string parmn), EventListener(string OLDSTATE,strng condition,string NEWSTATE), string combine_state(AND), Eventlistener2....)

-- How to pass primary_condition in the ConditionString? Maybe start it with a !, as ! is not allowed as eventlistener-name
ConditionString=[[_RSada1293f1d43b11624ddabadfefde672d23aa94d(true, PuddyDeluxe8765, in, a, gadda, da, vida,honey),
                  PlayState(oldstate,=,number:9), and, 
                  LetsDoItADADA(ADA, ->, DA),and,
                  Hudel(DUDEL,->,NUDEL), AND,
                  Hudel(oldstate,=,newstate)]]

--ConditionString=[[_RSada1293f1d43b11624ddabadfefde672d23aa94d(true, PuddyDeluxe8765, in, a, gadda, da, vida,honey),...........]]

function ConvertConditionStringToConditionstable(ConditionString)
  -- getting rid of tabs and spaces and checking for nested conditions, recognized by ))
  
  ActionString=ConditionString:match("(.-%),)")
  ConditionString=string.gsub(ConditionString," ", "")
  ConditionString=string.gsub(ConditionString,"\t", "")
  ConditionString=string.gsub(ConditionString,"\n", "")
  ConditionString=string.gsub(ConditionString,"\r", "")
  if ConditionString:match("%)%)")~=nil then reaper.MB("nested conditions are not supported(yet?)","parser error",0) return false end
  count, positions = ultraschall.CountCharacterInString(ConditionString, "(")
  count2, positions = ultraschall.CountCharacterInString(ConditionString, ")")
  if count~=count2 then reaper.MB("Parser Error, number of ( doesn't match the number of )","parser error",0) return false end
  -- let's take apart the ConditionString into its individual pieces
  TakeApart={}
  TakeApart_count=0
  ConditionString=ConditionString..","
  
  EventConditions={}
  EventConditions_count=0  
  
  -- now we parse the conditions
  
  -- first, we set action and actionparameters into table
  EventConditions_count=EventConditions_count+1
  EventConditions[EventConditions_count]={}
  EventConditions[EventConditions_count]["action"], EventConditions[EventConditions_count]["actionparameters"] = ActionString:match("(.-)%((.-)%)")
  EventConditions[EventConditions_count]["action_is_file"] = reaper.file_exists(EventConditions[EventConditions_count]["action"])
  EventConditions[EventConditions_count]["action_is_midi"] = toboolean(EventConditions[EventConditions_count]["actionparameters"]:match("(.-),"))
  EventConditions[EventConditions_count]["action_hwnd"] = EventConditions[EventConditions_count]["actionparameters"]:match(".-,.-(%w-)%,-")
  if EventConditions[EventConditions_count]["action_is_midi"]==nil or EventConditions[EventConditions_count]["action_hwnd"]==nil then
    EventConditions[EventConditions_count]=nil
    EventConditions_count=EventConditions_count-1
    reaper.MB("error, actionparameters must have is_midi, hwnd as first parameters. When in doubt, use false,0", "", 0)
    return
  end
  if EventConditions[EventConditions_count]["actionparameters"]==nil then 
    EventConditions[EventConditions_count]["actionparameters"] = "" 
  else
    EventConditions[EventConditions_count]["actionparameters"] = EventConditions[EventConditions_count]["actionparameters"]:match(".-,.-,(.*)")
  end
  
  
  -- now we take apart the individual conditions and store them into the table
  
  CondoState=ConditionString:match("%),(.*)")..","
  
  for k in string.gmatch(CondoState,"(.-%(.-%),.-),") do
    TakeApart_count=TakeApart_count+1
    TakeApart[TakeApart_count]=k
  end

  if TakeApart_count==0 then
    EventConditions[EventConditions_count]=nil
    EventConditions_count=EventConditions_count-1
    reaper.MB("error, no conditions given", "no conditions found", 0)
    return
  else 
    EventConditions[EventConditions_count]["condition_counter"]=TakeApart_count
  end
  
  for i=1, TakeApart_count do
    a=i-1
    tempoldstate, tempcondition, tempnewstate, tempcombinestate=TakeApart[i]:match("%((.-),(.-),(.-)%),(.*)")
--  reaper.MB(tostring(tempcombinestate),TakeApart[i],0)
--  reaper.MB(tostring(tempcombinestate),TakeApart[i],0)

  
    -- if both states are uppercase AND condition is either -> = ! then everything is fine, 
    -- otherwise throw an errormessage
    if tempcombinestate==nil then 
      reaper.MB("error, combinestate must be an and", "wrong combinestate", 0)
    elseif tempcombinestate:upper()=="AND" then
      EventConditions[EventConditions_count]["combine_state_"..i]="AND"
    elseif tempcombinestate=="" then
      EventConditions[EventConditions_count]["combine_state_"..i]=""
    else
      reaper.MB("error, combinestate must be an and", "wrong combinestate", 0)
    end
    if tempoldstate:upper() == tempoldstate and
       tempnewstate:upper() == tempnewstate then
       
      if tempcondition~="->" and tempcondition~="=" and tempcondition~="!" then
        EventConditions[EventConditions_count]=nil
        EventConditions_count=EventConditions_count-1
          reaper.MB("error, must be ->, = or ! for uppercase values","wrong_condition",0)
        break
      end
    -- if both states are lowercase and "number:" in them, a number after "number:" like (number:98.7) and have either of the following conditions < > = -> !
    -- then everything is ok, otherwise throw an errormessage
    elseif tempoldstate:match("^number:.")~=nil and
           tempnewstate:match("^number:.")~=nil and 
           tonumber(tempoldstate:match("^number:(.*)"))~=nil and
           tonumber(tempnewstate:match("^number:(.*)"))~=nil then
            if tempcondition~=">" and
               tempcondition~="<" and
               tempcondition~="=" and
               tempcondition~="->" and
               tempcondition~="!" then
                EventConditions[EventConditions_count]=nil
                EventConditions_count=EventConditions_count-1
                  reaper.MB("error, must be ->, =, <, > or ! for number states and number states must begin with number","wrong_condition",0)
                break                   
            end
            
    elseif tempoldstate:match("^oldstate$") and tempnewstate:match("^newstate$") then
      if tempcondition~=">" and
         tempcondition~="<" and
         tempcondition~="=" and
         tempcondition~="->" and
         tempcondition~="!" then
          EventConditions[EventConditions_count]=nil
          EventConditions_count=EventConditions_count-1
            reaper.MB("error, must be ->, =, <, > or ! for comparisons of oldstate to newstate","wrong_condition",0)
          break           
      end
    
    -- if oldstate starts either with oldstate or newstate and the conditions are either > < = ! then
    -- everything is ok, otherwise throw an errormessage    
    elseif (tempoldstate:match("^oldstate$")~=nil or
           tempoldstate:match("^newstate$")~=nil) then
      if tempcondition~=">" and
         tempcondition~="<" and
         tempcondition~="=" and
         tempcondition~="!" then
          EventConditions[EventConditions_count]=nil
          EventConditions_count=EventConditions_count-1
            reaper.MB("error, must be =, <, > or ! for lowercase values and lowercase-states must begin with oldstate or newstate","wrong_condition",0)
          break           
      end
    -- in any other case, throw an error message
    else
      EventConditions[EventConditions_count]=nil
      EventConditions_count=EventConditions_count-1
      reaper.MB("error, must be either uppercase, number or comparision-states", "wrong_states",0)
      break
    end
    
    EventConditions[EventConditions_count]["eventlistener_"..a]=TakeApart[i]:match("(.-)%(")
    EventConditions[EventConditions_count]["oldstate_"..a],
    EventConditions[EventConditions_count]["condition_"..a],
    EventConditions[EventConditions_count]["newstate_"..a]  
    = tempoldstate, tempcondition, tempnewstate
  end
end



ConvertConditionStringToConditionstable(ConditionString)


-- How are the conditions stored, that shall be checked against?

-- EventConditions_count - the number of conditions stored in the EventConditions-table

-- EventConditions-table
-- Eventconditions[conditionindex]["action"]= - the action to execute
-- Eventconditions[conditionindex]["action_is_file"]= - is the action a file(true -> ultraschall.Main_OnCommand) or not(false -> reaper.Main_OnCommand)
-- Eventconditions[conditionindex]["action_is_midi"]= - the action is a midi-action(true), or a normal action(false)
--                                                    - MIDI-actions are run with the last MidiEditor
-- Eventconditions[conditionindex]["action_hwnd"]= - for midi-actions, the hwnd of the MidiEditor, in which the action shall be run in
-- Eventconditions[conditionindex]["actionparameters"]= - the parameters of the action to execute, that shall be passed over to the action

-- Eventconditions[conditionindex]["action_run_already"]= - has the action been run already? True, if yes, false if not
--                                                          if the conditions are still met and action_run_already=true then don't run it again
--                                                          if the conditions aren't met and action_run_already=true then change it to false
-- Eventconditions[conditionindex]["condition_counter"]= - the number of conditions for this action

-- If, for example, you want an action to be run when PlayState=PLAY and LoopState=LOOPED and 
-- you want the action run only when PlayState changes, not when LoopState changes, even if PlayState has the right conditions
-- How to pass this in the ConditionString?
-- Eventconditions[conditionindex]["condition_primary"]= - the primary condition, means; 
--                                                          if this primary condition is set to >0 
--                                                              check if condition_primary_old and condition_primary_new are different from the current state of the eventlistener_primarycondition
--                                                              if only check the other conditions, when the primary condition changed
--                                                          if primary condition is set to 0
--                                                              if any of the conditions change, check all conditions to be met
-- Eventconditions[conditionindex]["condition_primary_old"]= 
-- Eventconditions[conditionindex]["condition_primary_new"]= - the old and new primary-eventlistener-states, that means
--                                                                if the eventlistener_primarycondition changes from condition_primary_old/new to another one, and condition_primary>0 then do all the condition-checks, and update condition_primary_old/new


-- Eventconditions[conditionindex]["condition_skip"]= - true, don't check this condition at all; false, check this condition. 
--                                                      That way, conditionchecks can be de- and reactivated if needed
-- Eventconditions[conditionindex]["eventlistener_"..idx]= - the eventlistener, whose states shall be used as basis for comparison
-- Eventconditions[conditionindex]["oldstate_"..idx]= - the oldstate of this sub-condition
-- Eventconditions[conditionindex]["newstate_"..idx]= - the newstate of this sub-condition
-- Eventconditions[conditionindex]["condition_"..idx]= - the condition for comparison of this old and newstate
-- Eventconditions[conditionindex]["combine_state_"..idx]= - the combine-state for numerous conditions. Currently only AND supported, which says, 
--                                                           that all conditions must be met or the action will not be run
--                                                           at some point, OR and XOR will be added as well, but that is futuristic music






