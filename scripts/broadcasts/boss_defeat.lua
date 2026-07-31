local DEATH_BOSSES = {
    deerclops = "巨鹿",
    mutateddeerclops = "晶体巨鹿",
    bearger = "熊獾",
    mutatedbearger = "装甲熊獾",
    dragonfly = "龙蝇",
    beequeen = "蜂王",
    toadstool = "毒菌蟾蜍",
    toadstool_dark = "悲惨的毒菌蟾蜍",
    moose = "麋鹿鹅",
    klaus = "克劳斯",
    malbatross = "邪天翁",
    antlion = "蚁狮",
    crabking = "帝王蟹",
    eyeofterror = "恐怖之眼",
    minotaur = "远古守护者",
    stalker_atrium = "远古织影者",
    alterguardian_phase3 = "天体英雄",
    alterguardian_phase4_lunarrift = "天体后裔",
    worm_boss = "巨大洞穴蠕虫",
    wagboss_robot = {
        name = "启迪战争瓦器人",
        test = function(inst)
            return inst.hostile == true
        end,
    },
}

local NONLETHAL_BOSSES = {
    daywalker = "梦魇疯猪",
    daywalker2 = "拾荒疯猪",
    sharkboi = "大霜鲨",
}

local TWIN_PREFABS = {
    twinofterror1 = true,
    twinofterror2 = true,
}

local function Announce(name)
    TheNet:Announce(string.format("[Broadcasts] %s已被击败！", name))
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
                    Announce("双子魔眼")
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
                Announce("远古守卫塔")
            end
        end)
    end)
end)
