--[[
  巨兽击败：最终一击、伤害排行；双子/守卫塔等同组结算。
]]

modimport("scripts/broadcasts/shared/get_entity_display_name.lua")
modimport("scripts/broadcasts/shared/get_prefab_display_name.lua")
modimport("scripts/broadcasts/shared/is_at_min_health.lua")

local N = BROADCASTS_STRINGS.bosses
local GetEntityName = BROADCASTS_GET_ENTITY_DISPLAY_NAME
local GetPrefabDisplayName = BROADCASTS_GET_PREFAB_DISPLAY_NAME
local IsAtMinHealth = BROADCASTS_IS_AT_MIN_HEALTH

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
  klaus = {
    name = N.klaus,
    test = function(inst)
      return inst.IsUnchained ~= nil and inst:IsUnchained()
    end,
  },
  malbatross = N.malbatross,
  antlion = {
    name = N.antlion,
    -- 休眠态无 health；仅战斗中击杀会走 death
    test = function(inst)
      return inst.components ~= nil and inst.components.health ~= nil
    end,
  },
  crabking = N.crabking,
  eyeofterror = N.eyeofterror,
  minotaur = N.minotaur,
  stalker_atrium = N.stalker_atrium,
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

local ALTERGUARDIAN_PHASES = {
  alterguardian_phase1 = true,
  alterguardian_phase2 = true,
  alterguardian_phase3 = true,
}

local NON_WEAPON_CAUSES = {
  fire = true,
  cold = true,
  hot = true,
  hunger = true,
  drowning = true,
  lightning = true,
  acid = true,
  acidrain = true,
  file_load = true,
}

local function GetWeaponName(cause, afflicter)
  if type(cause) ~= "string" or cause == "" or NON_WEAPON_CAUSES[cause] then
    return nil
  end
  if string.sub(cause, 1, 6) == "regen_" or cause == "regen" then
    return nil
  end
  if afflicter ~= nil and afflicter:IsValid() and afflicter.prefab == cause then
    return nil
  end

  local names = STRINGS and STRINGS.NAMES
  local display = type(names) == "table" and names[string.upper(cause)] or nil
  if type(display) ~= "string" or display == "" then
    return nil
  end
  return "[" .. display .. "]"
end

local function GetSummonOwner(afflicter)
  if afflicter == nil or not afflicter:IsValid() or afflicter:HasTag("player") then
    return nil
  end

  local link = afflicter._playerlink
  if link ~= nil and link:IsValid() and link:HasTag("player") then
    return link
  end

  local components = afflicter.components
  local follower = components ~= nil and components.follower or nil
  if follower ~= nil then
    local leader = follower.GetLeader ~= nil and follower:GetLeader() or follower.leader
    if leader ~= nil and leader:IsValid() and leader:HasTag("player") then
      return leader
    end
  end

  return nil
end

local function GetPlayerKey(player)
  local key = player.userid
  if type(key) == "string" and key ~= "" then
    return key
  end
  return "player:" .. tostring(player.GUID)
end

local function GetDamageBucket(inst)
  local bucket = inst._dst_broadcasts_damage
  if bucket == nil then
    bucket = {}
    inst._dst_broadcasts_damage = bucket
  end
  return bucket
end

local function GetSharedDamageBucket(key)
  local field = "_dst_broadcasts_" .. key
  local bucket = TheWorld[field]
  if bucket == nil then
    bucket = {}
    TheWorld[field] = bucket
  end
  return bucket
end

local function ClearSharedDamageBucket(key)
  TheWorld["_dst_broadcasts_" .. key] = nil
end

local function AddDamage(bucket, key, name, amount)
  local entry = bucket[key]
  if entry == nil then
    entry = { damage = 0, name = name }
    bucket[key] = entry
  end
  entry.damage = entry.damage + amount
  if name ~= nil then
    entry.name = name
  elseif entry.name == nil then
    entry.name = BROADCASTS_STRINGS.boss_damage_other
  end
end

local function ResolveDamageSource(afflicter)
  if afflicter ~= nil and afflicter:IsValid() and afflicter:HasTag("player") then
    return GetPlayerKey(afflicter), GetEntityName(afflicter) or BROADCASTS_STRINGS.boss_damage_other
  end

  local owner = GetSummonOwner(afflicter)
  if owner ~= nil then
    local prefab = afflicter.prefab
    local summon_name = GetPrefabDisplayName(prefab) or GetEntityName(afflicter) or BROADCASTS_STRINGS.boss_damage_other
    local owner_name = GetEntityName(owner) or BROADCASTS_STRINGS.boss_damage_other
    local owner_key = GetPlayerKey(owner)
    local summon_key = type(prefab) == "string" and prefab ~= "" and prefab or tostring(afflicter.GUID)
    return "summon:" .. owner_key .. ":" .. summon_key, owner_name .. summon_name
  end

  if afflicter ~= nil and afflicter:IsValid() then
    local prefab = afflicter.prefab
    local key = type(prefab) == "string" and prefab ~= "" and ("prefab:" .. prefab) or
        ("entity:" .. tostring(afflicter.GUID))
    local name = GetEntityName(afflicter) or GetPrefabDisplayName(prefab) or BROADCASTS_STRINGS.boss_damage_other
    return key, name
  end

  return "other", BROADCASTS_STRINGS.boss_damage_other
end

local function OnBossHealthDelta(inst, data, bucket)
  -- 按本次造成的伤害数值累计；回血不冲减，总额可超过血条上限
  if data == nil or type(data.amount) ~= "number" or data.amount >= 0 then
    return
  end

  local key, name = ResolveDamageSource(data.afflicter)
  AddDamage(bucket, key, name, -data.amount)
end

local function WatchBossDamage(inst, get_bucket)
  inst:ListenForEvent("healthdelta", mod.Wrap("boss_damage:" .. tostring(inst.prefab), function(_, data)
    OnBossHealthDelta(inst, data, get_bucket())
  end))
end

local function BuildDamageRanking(bucket)
  local list = {}
  if type(bucket) ~= "table" then
    return list
  end
  for _, entry in pairs(bucket) do
    if type(entry) == "table" and type(entry.damage) == "number" and entry.damage > 0 and entry.name ~= nil then
      list[#list + 1] = entry
    end
  end
  table.sort(list, function(a, b)
    if a.damage == b.damage then
      return tostring(a.name) < tostring(b.name)
    end
    return a.damage > b.damage
  end)
  return list
end

local function AnnounceDamageRanking(bucket)
  local list = BuildDamageRanking(bucket)
  if #list == 0 then
    return
  end

  local max_entries = mod.CONSTANTS.BOSS_DAMAGE_RANKING_MAX
  if type(max_entries) ~= "number" or max_entries ~= max_entries or max_entries < 1 then
    max_entries = 10
  end
  local sep = BROADCASTS_STRINGS.list_separator
  local entry_fmt = BROADCASTS_STRINGS.boss_damage_entry
  local parts = {}
  for i = 1, math.min(#list, max_entries) do
    local entry = list[i]
    parts[#parts + 1] = string.format(entry_fmt, entry.name, math.floor(entry.damage + 0.5))
  end

  mod.Announce(string.format(BROADCASTS_STRINGS.boss_damage_ranking, table.concat(parts, sep)))
end

local function AnnounceDefeat(name, data, damage_bucket)
  local afflicter = data ~= nil and data.afflicter or nil
  local cause = data ~= nil and data.cause or nil
  local _, killer = ResolveDamageSource(afflicter)
  if afflicter == nil or not afflicter:IsValid() then
    mod.Announce(string.format(BROADCASTS_STRINGS.boss_defeated, name))
  else
    local weapon = GetWeaponName(cause, afflicter)
    if weapon ~= nil then
      mod.Announce(string.format(BROADCASTS_STRINGS.boss_defeated_by_weapon, name, killer, weapon))
    else
      mod.Announce(string.format(BROADCASTS_STRINGS.boss_defeated_by, name, killer))
    end
  end
  AnnounceDamageRanking(damage_bucket)
end

local function IsAlive(inst)
  local components = inst.components
  local health = components ~= nil and components.health or nil
  return inst:IsValid() and health ~= nil and not health:IsDead()
end

local function HasLivingTwin(exclude)
  for _, inst in pairs(Ents) do
    if inst ~= exclude and TWIN_PREFABS[inst.prefab] and IsAlive(inst) then
      return true
    end
  end
  return false
end

local function HasLivingVaultGuard(exclude)
  for _, inst in pairs(Ents) do
    if inst ~= exclude and
        inst.prefab == "vault_pillar_guard" and
        not inst.crafted and
        IsAlive(inst) then
      return true
    end
  end
  return false
end

local function IsNonlethalDefeated(inst, prefab)
  if not inst:IsValid() then
    return false
  end
  if inst.defeated then
    return true
  end
  if inst.sg ~= nil and inst.sg:HasStateTag("defeated") then
    return true
  end
  -- sharkboi 不设 defeated；贴底或已 MakeTrader 视为击败
  if prefab == "sharkboi" then
    if inst.components.trader ~= nil then
      return true
    end
    return IsAtMinHealth(inst)
  end
  -- daywalker / daywalker2：只认 defeated / SG。
  -- 出狱疲倦阶段也会贴底并反复推 minhealth，不能用 IsAtMinHealth 旁路（会误报并锁死真击败）。
  -- 真击败时原版 MakeDefeated 同步设 defeated；若偶发时序落后由重试承接。
  return false
end

-- 真击败时原版偶发时序落后；约 3s 内轮询终态，避免过短窗口漏播
local NONLETHAL_RETRY_DELAY = 0.25
local NONLETHAL_RETRY_MAX = 12

local function TryAnnounceNonlethalDefeat(inst, prefab, name, data, attempt)
  if not inst:IsValid() or inst._dst_broadcasts_defeat_announced then
    return
  end
  if IsNonlethalDefeated(inst, prefab) then
    inst._dst_broadcasts_defeat_announced = true
    AnnounceDefeat(name, data, inst._dst_broadcasts_damage)
    inst._dst_broadcasts_damage = nil
    return
  end
  if attempt < NONLETHAL_RETRY_MAX then
    inst:DoTaskInTime(NONLETHAL_RETRY_DELAY, mod.Wrap("boss_minhealth_retry:" .. prefab, function()
      TryAnnounceNonlethalDefeat(inst, prefab, name, data, attempt + 1)
    end))
  end
end

for prefab, boss in pairs(DEATH_BOSSES) do
  AddPrefabPostInit(prefab, mod.Wrap("boss_defeat_init:" .. prefab, function(inst)
    if not TheWorld.ismastersim then
      return
    end
    WatchBossDamage(inst, function()
      return GetDamageBucket(inst)
    end)
    inst:ListenForEvent("death", mod.Wrap("boss_defeat:" .. prefab, function(_, data)
      local name = type(boss) == "table" and boss.name or boss
      local should_announce = type(boss) ~= "table" or
          boss.test == nil or
          boss.test(inst)
      if should_announce and not inst._dst_broadcasts_defeat_announced then
        inst._dst_broadcasts_defeat_announced = true
        AnnounceDefeat(name, data, inst._dst_broadcasts_damage)
        inst._dst_broadcasts_damage = nil
      end
    end))
  end))
end

for prefab in pairs(ALTERGUARDIAN_PHASES) do
  AddPrefabPostInit(prefab, mod.Wrap("alterguardian_init:" .. prefab, function(inst)
    if not TheWorld.ismastersim then
      return
    end
    if prefab == "alterguardian_phase1" then
      ClearSharedDamageBucket("alterguardian_damage")
    end
    WatchBossDamage(inst, function()
      return GetSharedDamageBucket("alterguardian_damage")
    end)
    if prefab == "alterguardian_phase3" then
      inst:ListenForEvent("death", mod.Wrap("alterguardian_defeat", function(_, data)
        if inst._dst_broadcasts_defeat_announced then
          return
        end
        inst._dst_broadcasts_defeat_announced = true
        AnnounceDefeat(
          N.alterguardian_phase3,
          data,
          TheWorld._dst_broadcasts_alterguardian_damage
        )
        ClearSharedDamageBucket("alterguardian_damage")
      end))
    end
  end))
end

for prefab, name in pairs(NONLETHAL_BOSSES) do
  AddPrefabPostInit(prefab, mod.Wrap("boss_minhealth_init:" .. prefab, function(inst)
    if not TheWorld.ismastersim then
      return
    end
    WatchBossDamage(inst, function()
      return GetDamageBucket(inst)
    end)
    inst:ListenForEvent("minhealth", mod.Wrap("boss_minhealth:" .. prefab, function(_, data)
      -- 读档 SetVal(..., "file_load") / 世界填充期会推 minhealth，但不算当场击败
      if POPULATING or (data ~= nil and data.cause == "file_load") then
        return
      end
      inst:DoTaskInTime(0, mod.Wrap("boss_minhealth_task:" .. prefab, function()
        TryAnnounceNonlethalDefeat(inst, prefab, name, data, 1)
      end))
    end))
  end))
end

for prefab in pairs(TWIN_PREFABS) do
  AddPrefabPostInit(prefab, mod.Wrap("twins_init:" .. prefab, function(inst)
    if not TheWorld.ismastersim then
      return
    end
    if TheWorld._dst_broadcasts_twins_defeated then
      ClearSharedDamageBucket("twins_damage")
    end
    TheWorld._dst_broadcasts_twins_defeated = nil
    WatchBossDamage(inst, function()
      return GetSharedDamageBucket("twins_damage")
    end)
    inst:ListenForEvent("death", mod.Wrap("twins_death:" .. prefab, function(_, data)
      inst:DoTaskInTime(0, mod.Wrap("twins_check", function()
        if not HasLivingTwin() and not TheWorld._dst_broadcasts_twins_defeated then
          TheWorld._dst_broadcasts_twins_defeated = true
          AnnounceDefeat(N.twins, data, TheWorld._dst_broadcasts_twins_damage)
          ClearSharedDamageBucket("twins_damage")
        end
      end))
    end))
  end))
end

AddPrefabPostInit("vault_pillar_guard", mod.Wrap("guard_init", function(inst)
  if not TheWorld.ismastersim or inst.crafted then
    return
  end
  if TheWorld._dst_broadcasts_guard_towers_defeated then
    ClearSharedDamageBucket("guard_damage")
  end
  TheWorld._dst_broadcasts_guard_towers_defeated = nil
  WatchBossDamage(inst, function()
    return GetSharedDamageBucket("guard_damage")
  end)
  inst:ListenForEvent("death", mod.Wrap("guard_death", function(_, data)
    inst:DoTaskInTime(0, mod.Wrap("guard_check", function()
      if not HasLivingVaultGuard() and
          not TheWorld._dst_broadcasts_guard_towers_defeated then
        TheWorld._dst_broadcasts_guard_towers_defeated = true
        AnnounceDefeat(N.vault_pillar_guard, data, TheWorld._dst_broadcasts_guard_damage)
        ClearSharedDamageBucket("guard_damage")
      end
    end))
  end))
end))
