local N = BROADCASTS_STRINGS.bosses
local Safe = BROADCASTS_SAFE

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
    Safe.Announce(string.format(BROADCASTS_STRINGS.boss_defeated, name))
end

local function IsAlive(inst)
    local components = inst.components
    local health = components ~= nil and components.health or nil
    return inst:IsValid() and health ~= nil and not health:IsDead()
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
    AddPrefabPostInit(prefab, Safe.Wrap("boss_defeat_init:" .. prefab, function(inst)
        if not TheWorld.ismastersim then
            return
        end
        inst:ListenForEvent("death", Safe.Wrap("boss_defeat:" .. prefab, function()
            local name = type(boss) == "table" and boss.name or boss
            local should_announce = type(boss) ~= "table" or
                boss.test == nil or
                boss.test(inst)
            if should_announce and not inst._dst_broadcasts_defeat_announced then
                inst._dst_broadcasts_defeat_announced = true
                Announce(name)
            end
        end))
    end))
end

for prefab, name in pairs(NONLETHAL_BOSSES) do
    AddPrefabPostInit(prefab, Safe.Wrap("boss_minhealth_init:" .. prefab, function(inst)
        if not TheWorld.ismastersim then
            return
        end
        inst:ListenForEvent("minhealth", Safe.Wrap("boss_minhealth:" .. prefab, function()
            inst:DoTaskInTime(0, Safe.Wrap("boss_minhealth_task:" .. prefab, function()
                local defeated = inst:IsValid() and
                    (inst.defeated or prefab == "sharkboi")
                if defeated and not inst._dst_broadcasts_defeat_announced then
                    inst._dst_broadcasts_defeat_announced = true
                    Announce(name)
                end
            end))
        end))
    end))
end

for prefab in pairs(TWIN_PREFABS) do
    AddPrefabPostInit(prefab, Safe.Wrap("twins_init:" .. prefab, function(inst)
        if not TheWorld.ismastersim then
            return
        end
        TheWorld._dst_broadcasts_twins_defeated = nil
        inst:ListenForEvent("death", Safe.Wrap("twins_death:" .. prefab, function()
            inst:DoTaskInTime(0, Safe.Wrap("twins_check", function()
                if not HasLivingTwin() and not TheWorld._dst_broadcasts_twins_defeated then
                    TheWorld._dst_broadcasts_twins_defeated = true
                    Announce(N.twins)
                end
            end))
        end))
    end))
end

AddPrefabPostInit("vault_pillar_guard", Safe.Wrap("guard_init", function(inst)
    if not TheWorld.ismastersim or inst.crafted then
        return
    end
    TheWorld._dst_broadcasts_guard_towers_defeated = nil
    inst:ListenForEvent("death", Safe.Wrap("guard_death", function()
        inst:DoTaskInTime(0, Safe.Wrap("guard_check", function()
            if inst._vault_death_loot and
                not TheWorld._dst_broadcasts_guard_towers_defeated then
                TheWorld._dst_broadcasts_guard_towers_defeated = true
                Announce(N.vault_pillar_guard)
            end
        end))
    end))
end))
