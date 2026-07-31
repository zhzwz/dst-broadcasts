local S = BROADCASTS_STRINGS

local function Announce(message)
    TheNet:Announce(message)
end

local function OnNightmarePhase(_, phase)
    local message = S.nightmare_phases[phase]
    if message ~= nil then
        Announce(message)
    end
end

local function OnAcidRain(_, is_raining)
    Announce(is_raining and S.acid_rain_started or S.acid_rain_ended)
end

AddSimPostInit(function()
    if not TheWorld.ismastersim or not TheWorld:HasTag("cave") then
        return
    end

    TheWorld:WatchWorldState("nightmarephase", OnNightmarePhase)
    TheWorld:WatchWorldState("isacidraining", OnAcidRain)
    TheWorld:ListenForEvent("resetruins", function()
        Announce(S.ruins_reset)
    end)

    if TheWorld.net ~= nil and TheWorld.net.components.quaker ~= nil then
        TheWorld.net:ListenForEvent("warnquake", function()
            Announce(S.quake_warning)
        end)
    end
end)
