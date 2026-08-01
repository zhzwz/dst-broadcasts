local S = BROADCASTS_STRINGS
local Safe = BROADCASTS_SAFE

local function OnNightmarePhase(_, phase)
    local message = S.nightmare_phases[phase]
    if message ~= nil then
        Safe.Announce(message)
    end
end

local function OnAcidRain(_, is_raining)
    Safe.Announce(is_raining and S.acid_rain_started or S.acid_rain_ended)
end

AddSimPostInit(Safe.Wrap("cave_events_init", function()
    if not TheWorld.ismastersim or not TheWorld:HasTag("cave") then
        return
    end

    TheWorld:WatchWorldState("nightmarephase", Safe.Wrap("cave_nightmare", OnNightmarePhase))
    TheWorld:WatchWorldState("isacidraining", Safe.Wrap("cave_acidrain", OnAcidRain))
    TheWorld:ListenForEvent("resetruins", Safe.Wrap("cave_ruins", function()
        Safe.Announce(S.ruins_reset)
    end))

    if TheWorld.net ~= nil and TheWorld.net.components.quaker ~= nil then
        TheWorld.net:ListenForEvent("warnquake", Safe.Wrap("cave_quake", function()
            Safe.Announce(S.quake_warning)
        end))
    end
end))
