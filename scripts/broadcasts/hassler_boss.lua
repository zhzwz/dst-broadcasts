--[[
  会主动找玩家的季节 Boss：巨鹿、熊獾。
]]

local Safe = BROADCASTS_SAFE
local C = BROADCASTS_CONSTANTS

local BOSSES = {
    { name = BROADCASTS_STRINGS.bosses.deerclops, timer = C.DEERCLOPS_TIMER },
    { name = BROADCASTS_STRINGS.bosses.bearger, timer = C.BEARGER_TIMER },
}

local SPAWN_NAMES = {
    deerclops = BROADCASTS_STRINGS.bosses.deerclops,
    mutateddeerclops = BROADCASTS_STRINGS.bosses.mutateddeerclops,
    bearger = BROADCASTS_STRINGS.bosses.bearger,
    mutatedbearger = BROADCASTS_STRINGS.bosses.mutatedbearger,
}

AddSimPostInit(Safe.Wrap("hassler_init", function()
    if not TheWorld.ismastersim then
        return
    end
    if TheWorld:HasTag("cave") then
        return
    end
    if TheWorld.components.worldsettingstimer == nil then
        return
    end

    for _, boss in ipairs(BOSSES) do
        local timer = boss.timer
        local name = boss.name
        WatchAttackWarning(function()
            local wst = TheWorld.components.worldsettingstimer
            if wst == nil or
                not wst:ActiveTimerExists(timer) or
                wst:IsPaused(timer) then
                return nil
            end
            return wst:GetTimeLeft(timer)
        end, function()
            return name
        end)
    end
end))

for prefab, name in pairs(SPAWN_NAMES) do
    AddPrefabPostInit(prefab, Safe.Wrap("hassler_spawn:" .. prefab, function(inst)
        if not TheWorld.ismastersim then
            return
        end

        local old_on_load = inst.OnLoad
        inst.OnLoad = function(inst, data)
            inst._dst_broadcasts_loaded = true
            if old_on_load ~= nil then
                old_on_load(inst, data)
            end
        end

        inst:DoTaskInTime(0, Safe.Wrap("hassler_appear:" .. prefab, function()
            if inst:IsValid() and not inst._dst_broadcasts_loaded then
                Safe.Announce(string.format(
                    BROADCASTS_STRINGS.boss_appeared,
                    name
                ))
            end
        end))
    end))
end
