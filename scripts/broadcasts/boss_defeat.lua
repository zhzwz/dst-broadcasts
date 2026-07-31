local N = BROADCASTS_STRINGS.bosses

local DEATH_BOSSES = {
    deerclops = N.deerclops,
    mutateddeerclops = N.mutateddeerclops,
    bearger = N.bearger,
    mutatedbearger = N.mutatedbearger,
    dragonfly = N.dragonfly,
    beequeen = N.beequeen,
    toadstool = N.toadstool,
    toadstool_dark = N.toadstool_dark,
    moose = N.moose,
    klaus = N.klaus,
    malbatross = N.malbatross,
    antlion = N.antlion,
    crabking = N.crabking,
    eyeofterror = N.eyeofterror,
    minotaur = N.minotaur,
    stalker_atrium = N.stalker_atrium,
    alterguardian_phase3 = N.alterguardian_phase3,
    alterguardian_phase4_lunarrift = N.alterguardian_phase4_lunarrift,
    worm_boss = N.worm_boss,
    wagboss_robot = {
        name = N.wagboss_robot,
        test = function(inst)
            return inst.hostile == true
        end,
    },
}

local NONLETHAL_BOSSES = {
    daywalker = N.daywalker,
    daywalker2 = N.daywalker2,
    sharkboi = N.sharkboi,
}

local TWIN_PREFABS = {
    twinofterror1 = true,
    twinofterror2 = true,
}

local function Announce(name)
    TheNet:Announce(string.format("[Broadcasts] " .. BROADCASTS_STRINGS.boss_defeated, name))
end

local function IsAlive(inst)
    return inst:IsValid() and
        inst.components.health ~= nil and
        not inst.components.health:IsDead()
end

local function HasLivingTwin()
    for _, inst in pairs(Ents) do
        if TWIN_PREFABS[inst.prefab] and IsAlive(inst) then
            return true
        end
    end
    return false
end

for prefab, boss in pairs(DEATH_BOSSES) do
    AddPrefabPostInit(prefab, function(inst)
        if not TheWorld.ismastersim then
            return
        end
        inst:ListenForEvent("death", function()
            local name = type(boss) == "table" and boss.name or boss
            local should_announce = type(boss) ~= "table" or
                boss.test == nil or
                boss.test(inst)
            if should_announce and not inst._dst_broadcasts_defeat_announced then
                inst._dst_broadcasts_defeat_announced = true
                Announce(name)
            end
        end)
    end)
end

for prefab, name in pairs(NONLETHAL_BOSSES) do
    AddPrefabPostInit(prefab, function(inst)
        if not TheWorld.ismastersim then
            return
        end
        inst:ListenForEvent("minhealth", function()
            inst:DoTaskInTime(0, function()
                local defeated = inst:IsValid() and
                    (inst.defeated or prefab == "sharkboi")
                if defeated and not inst._dst_broadcasts_defeat_announced then
                    inst._dst_broadcasts_defeat_announced = true
                    Announce(name)
                end
            end)
        end)
    end)
end

for prefab in pairs(TWIN_PREFABS) do
    AddPrefabPostInit(prefab, function(inst)
        if not TheWorld.ismastersim then
            return
        end
        TheWorld._dst_broadcasts_twins_defeated = nil
        inst:ListenForEvent("death", function()
            inst:DoTaskInTime(0, function()
                if not HasLivingTwin() and not TheWorld._dst_broadcasts_twins_defeated then
                    TheWorld._dst_broadcasts_twins_defeated = true
                    Announce(N.twins)
                end
            end)
        end)
    end)
end

AddPrefabPostInit("vault_pillar_guard", function(inst)
    if not TheWorld.ismastersim or inst.crafted then
        return
    end
    TheWorld._dst_broadcasts_guard_towers_defeated = nil
    inst:ListenForEvent("death", function()
        inst:DoTaskInTime(0, function()
            if inst._vault_death_loot and
                not TheWorld._dst_broadcasts_guard_towers_defeated then
                TheWorld._dst_broadcasts_guard_towers_defeated = true
                Announce(N.vault_pillar_guard)
            end
        end)
    end)
end)
