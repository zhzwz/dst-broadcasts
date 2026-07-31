--[[
  不主动追人的 Boss：每天刷新时扫描是否已在世界中，有则全服提示。
  巨鹿/熊獾由 hassler_boss 负责，不在此重复。
]]

-- name 显示名；prefabs 任一存活即算存在（多阶段 Boss 合并）
local BOSSES = {
    { name = "龙蝇", prefabs = { "dragonfly" } },
    { name = "蜂王", prefabs = { "beequeen" } },
    { name = "毒菌蟾蜍", prefabs = { "toadstool" } },
    { name = "悲惨的毒菌蟾蜍", prefabs = { "toadstool_dark" } },
    { name = "麋鹿鹅", prefabs = { "moose" } },
    { name = "克劳斯", prefabs = { "klaus" } },
    { name = "邪天翁", prefabs = { "malbatross" } },
    { name = "蚁狮", prefabs = { "antlion" } },
    { name = "帝王蟹", prefabs = { "crabking" } },
    { name = "恐怖之眼", prefabs = { "eyeofterror" } },
    { name = "双子魔眼", prefabs = { "twinofterror1", "twinofterror2" } },
    { name = "梦魇疯猪", prefabs = { "daywalker" } },
    { name = "拾荒疯猪", prefabs = { "daywalker2" } },
    { name = "大霜鲨", prefabs = { "sharkboi" } },
    { name = "巨大洞穴蠕虫", prefabs = { "worm_boss" } },
    {
        name = "启迪战争瓦器人",
        prefabs = { "wagboss_robot" },
        test = function(inst)
            return inst.hostile == true
        end,
    },
    {
        name = "远古守卫塔",
        prefabs = { "vault_pillar_guard" },
        test = function(inst)
            return not inst.crafted
        end,
    },
    { name = "远古守护者", prefabs = { "minotaur" } },
    { name = "远古织影者", prefabs = { "stalker_atrium" } },
    { name = "天体英雄", prefabs = { "alterguardian_phase1", "alterguardian_phase2", "alterguardian_phase3" } },
    { name = "天体后裔", prefabs = { "alterguardian_phase4_lunarrift" } },
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
        "[Broadcasts] 第 %d 天：当前存在 %s",
        TheWorld.state.cycles + 1,
        table.concat(names, "、")
    ))
end

AddSimPostInit(function()
    if not TheWorld.ismastersim then
        return
    end
    TheWorld:WatchWorldState("cycles", OnNewDay)
end)
