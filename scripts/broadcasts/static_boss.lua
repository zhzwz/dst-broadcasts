--[[
  不主动追人的 Boss：每天刷新时扫描是否已在世界中，有则全服提示。
  巨鹿/熊獾由 hassler_boss 负责，不在此重复。
]]

-- name 显示名；prefabs 任一存活即算存在（多阶段 Boss 合并）
local N = BROADCASTS_STRINGS.bosses
local BOSSES = {
    { name = N.dragonfly, prefabs = { "dragonfly" } },
    { name = N.beequeen, prefabs = { "beequeen" } },
    { name = N.toadstool, prefabs = { "toadstool" } },
    { name = N.toadstool_dark, prefabs = { "toadstool_dark" } },
    { name = N.moose, prefabs = { "moose" } },
    { name = N.klaus, prefabs = { "klaus" } },
    { name = N.malbatross, prefabs = { "malbatross" } },
    { name = N.antlion, prefabs = { "antlion" } },
    { name = N.crabking, prefabs = { "crabking" } },
    { name = N.eyeofterror, prefabs = { "eyeofterror" } },
    { name = N.twins, prefabs = { "twinofterror1", "twinofterror2" } },
    { name = N.daywalker, prefabs = { "daywalker" } },
    { name = N.daywalker2, prefabs = { "daywalker2" } },
    { name = N.sharkboi, prefabs = { "sharkboi" } },
    { name = N.worm_boss, prefabs = { "worm_boss" } },
    {
        name = N.wagboss_robot,
        prefabs = { "wagboss_robot" },
        test = function(inst)
            return inst.hostile == true
        end,
    },
    {
        name = N.vault_pillar_guard,
        prefabs = { "vault_pillar_guard" },
        test = function(inst)
            return not inst.crafted
        end,
    },
    { name = N.minotaur, prefabs = { "minotaur" } },
    { name = N.stalker_atrium, prefabs = { "stalker_atrium" } },
    { name = N.alterguardian_phase3, prefabs = { "alterguardian_phase1", "alterguardian_phase2", "alterguardian_phase3" } },
    { name = N.alterguardian_phase4_lunarrift, prefabs = { "alterguardian_phase4_lunarrift" } },
}

local PREFAB_SET = {}
for _, boss in ipairs(BOSSES) do
    for _, prefab in ipairs(boss.prefabs) do
        PREFAB_SET[prefab] = boss
    end
end

local function IsAliveBoss(inst, boss)
    if not inst:IsValid() then
        return false
    end
    if inst:HasTag("INLIMBO") then
        return false
    end
    if inst.defeated or (inst.sg ~= nil and inst.sg:HasStateTag("defeated")) then
        return false
    end
    local health = inst.components.health
    if health ~= nil and health:IsDead() then
        return false
    end
    return boss.test == nil or boss.test(inst)
end

local function CollectPresent()
    local found = {}
    for _, inst in pairs(Ents) do
        local prefab = inst.prefab
        local boss = prefab ~= nil and PREFAB_SET[prefab] or nil
        if boss ~= nil and IsAliveBoss(inst, boss) then
            found[boss] = true
        end
    end

    local names = {}
    for _, boss in ipairs(BOSSES) do
        if found[boss] then
            table.insert(names, boss.name)
        end
    end
    return names
end

local function OnNewDay()
    if TheWorld.state.cycles == 0 then
        return
    end

    local names = CollectPresent()
    if #names == 0 then
        return
    end

    TheNet:Announce(string.format(
        BROADCASTS_STRINGS.daily_boss_report,
        TheWorld.state.cycles + 1,
        table.concat(names, BROADCASTS_STRINGS.list_separator)
    ))
end

AddSimPostInit(function()
    if not TheWorld.ismastersim then
        return
    end
    TheWorld:WatchWorldState("cycles", OnNewDay)
end)
