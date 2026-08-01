local S = BROADCASTS_STRINGS
local Safe = BROADCASTS_SAFE

local ACTIVE_KEY = "frog_rain_active"
local COUNT_KEY = "frog_rain_count"
local LAST_COUNT_KEY = "frog_rain_last_count"

local function GetState(world)
    return world.components.state_3774915634
end

local function CountFrog(world)
    local state = GetState(world)
    if state == nil then
        return
    end

    state:Set(ACTIVE_KEY, true)
    state:Increment(COUNT_KEY)
end

local function FinishFrogRain(world)
    local state = GetState(world)
    if state == nil or not state:Get(ACTIVE_KEY, false) then
        return
    end

    local count = state:Get(COUNT_KEY, 0)
    state:Set(ACTIVE_KEY, false)
    state:Set(COUNT_KEY, 0)
    state:Set(LAST_COUNT_KEY, count)

    if count > 0 then
        Safe.Announce(string.format(S.frog_rain_ended, count))
    end
end

AddComponentPostInit("frograin", function(self)
    local old_start_tracking = self.StartTracking
    self.StartTracking = function(component, target)
        old_start_tracking(component, target)
        CountFrog(component.inst)
    end
end)

AddSimPostInit(Safe.Wrap("frog_rain_init", function()
    if not TheWorld.ismastersim or TheWorld:HasTag("cave") then
        return
    end

    TheWorld:WatchWorldState("israining", Safe.Wrap("frog_rain_finished", function(_, is_raining)
        if not is_raining then
            FinishFrogRain(TheWorld)
        end
    end))

    if not TheWorld.state.israining then
        FinishFrogRain(TheWorld)
    end
end))
