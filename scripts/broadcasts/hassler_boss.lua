--[[
  会主动找玩家的季节 Boss：巨鹿、熊獾。
]]

local BOSSES = {
    { name = "巨鹿", timer = "deerclops_timetoattack" },
    { name = "熊獾", timer = "bearger_timetospawn" },
}

local SPAWN_NAMES = {
    deerclops = "巨鹿",
    mutateddeerclops = "晶体巨鹿",
    bearger = "熊獾",
    mutatedbearger = "装甲熊獾",
}

AddSimPostInit(function()
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
        WatchAttackCountdown(function()
            local wst = TheWorld.components.worldsettingstimer
            if wst == nil or
                not wst:ActiveTimerExists(boss.timer) or
                wst:IsPaused(boss.timer) then
                return nil
            end
            return wst:GetTimeLeft(boss.timer)
        end, function()
            return boss.name
        end)
    end
end)

for prefab, name in pairs(SPAWN_NAMES) do
    AddPrefabPostInit(prefab, function(inst)
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

        inst:DoTaskInTime(0, function()
            if inst:IsValid() and not inst._dst_broadcasts_loaded then
                TheNet:Announce(string.format("[Broadcasts] %s已现身！", name))
            end
        end)
    end)
end
