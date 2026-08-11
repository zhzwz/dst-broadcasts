--- 巨兽现身：实体新生成时播报（仅主机）。
--- 读档 / POPULATING 填充期出生不播；天体英雄仅 phase1 计为现身。
--- shared 组（双子魔眼 / 远古守卫塔）：先 claim 播一次，全灭后再释放（允许下一波）。
--- 克劳斯包装 Unchain、瓦器人包装 ConfigureHostile，状态就绪后再播。

--- shared 现身波次：先 claim，全灭后再释放。

--- @return boolean 是否首次占位（应播报）
local function TryClaim(store, key)
  if store[key] then
    return false
  end
  store[key] = true
  return true
end

--- living_count == 0 时清除占位，允许下一波再播
--- @return boolean 是否已释放
local function ReleaseIfEmpty(store, key, living_count)
  if living_count == 0 then
    store[key] = nil
    return true
  end
  return false
end

--- 正常 TryClaim；失败且 living_count <= 1 时视为残留 claim，清掉再占一次（自愈）
--- @return boolean 是否应播报
local function TryClaimOrRecover(store, key, living_count)
  if TryClaim(store, key) then
    return true
  end
  if living_count > 1 then
    return false
  end
  store[key] = nil
  return TryClaim(store, key)
end

local S = i18n
local N = S.bosses

local BOSSES = {
  { name = N.deerclops,        prefabs = { "deerclops" } },
  { name = N.mutateddeerclops, prefabs = { "mutateddeerclops" } },
  { name = N.bearger,          prefabs = { "bearger" } },
  { name = N.mutatedbearger,   prefabs = { "mutatedbearger" } },
  { name = N.dragonfly,        prefabs = { "dragonfly" } },
  { name = N.beequeen,         prefabs = { "beequeen" } },
  { name = N.toadstool,        prefabs = { "toadstool" } },
  { name = N.toadstool_dark,   prefabs = { "toadstool_dark" } },
  { name = N.moose,            prefabs = { "moose" } },
  {
    name = N.klaus,
    prefabs = { "klaus" },
    test = function(inst)
      return inst.IsUnchained ~= nil and inst:IsUnchained()
    end,
    --- 解链时原版调用 Unchain；包装后触发现身
    watch = function(inst, notify)
      local old = inst.Unchain
      if type(old) ~= "function" then
        return
      end
      inst.Unchain = function(i, ...)
        old(i, ...)
        notify()
      end
    end,
  },
  { name = N.malbatross,  prefabs = { "malbatross" } },
  { name = N.antlion,     prefabs = { "antlion" } },
  { name = N.crabking,    prefabs = { "crabking" } },
  { name = N.eyeofterror, prefabs = { "eyeofterror" } },
  {
    name = N.twins,
    prefabs = { "twinofterror1", "twinofterror2" },
    shared = "twins",
  },
  { name = N.daywalker,  prefabs = { "daywalker" } },
  { name = N.daywalker2, prefabs = { "daywalker2" } },
  { name = N.sharkboi,   prefabs = { "sharkboi" } },
  { name = N.worm_boss,  prefabs = { "worm_boss" } },
  {
    name = N.wagboss_robot,
    prefabs = { "wagboss_robot" },
    test = function(inst)
      return inst.hostile == true
    end,
    --- 进入敌对时原版调用 ConfigureHostile
    watch = function(inst, notify)
      local old = inst.ConfigureHostile
      if type(old) ~= "function" then
        return
      end
      inst.ConfigureHostile = function(i, ...)
        old(i, ...)
        notify()
      end
    end,
  },
  {
    name = N.vault_pillar_guard,
    prefabs = { "vault_pillar_guard" },
    shared = "vault_pillar_guard",
    test = function(inst)
      return not inst.crafted
    end,
  },
  { name = N.minotaur,                       prefabs = { "minotaur" } },
  { name = N.stalker_atrium,                 prefabs = { "stalker_atrium" } },
  --- 天体英雄：仅第一阶段算「现身」，避免换阶段重复播报
  { name = N.alterguardian_phase3,           prefabs = { "alterguardian_phase1" } },
  { name = N.alterguardian_phase4_lunarrift, prefabs = { "alterguardian_phase4_lunarrift" } },
}

local PREFAB_BOSS = {}
for _, boss in ipairs(BOSSES) do
  for _, prefab in ipairs(boss.prefabs) do
    PREFAB_BOSS[prefab] = boss
  end
end

local function SharedKey(shared)
  return "_dst_broadcasts_appear_" .. shared
end

--- 与 scripts/features/defeat.lua HasLivingTwin 一致：不排除 INLIMBO（避免入 limbo 未 remove 时过早 Release）
local IsAlive = core.IsAlive

local function CountLivingPrefabs(prefabs, test)
  local set = {}
  for _, prefab in ipairs(prefabs) do
    set[prefab] = true
  end
  local n = 0
  for _, ent in pairs(Ents) do
    if ent ~= nil
        and ent.prefab ~= nil
        and set[ent.prefab]
        and IsAlive(ent)
        and (test == nil or test(ent)) then
      n = n + 1
    end
  end
  return n
end

local function TryAnnounce(inst, boss)
  if not inst:IsValid() or inst._dst_broadcasts_appear_announced then
    return true
  end
  if boss.test ~= nil and not boss.test(inst) then
    return false
  end

  if boss.shared ~= nil then
    local key = SharedKey(boss.shared)
    local living = CountLivingPrefabs(boss.prefabs, boss.test)
    if not TryClaimOrRecover(TheWorld, key, living) then
      inst._dst_broadcasts_appear_announced = true
      return true
    end
  end

  inst._dst_broadcasts_appear_announced = true
  local template = S.boss_appeared
  if type(template) == "string" and template ~= "" and type(boss.name) == "string" then
    core.Announce(string.format(template, boss.name))
  end
  return true
end

local function WatchSharedRelease(inst, boss)
  local key = SharedKey(boss.shared)
  inst:ListenForEvent("onremove", core.Wrap(function()
    --- inst 任务在 onremove 后可能被清；挂到世界上延后计数
    TheWorld:DoTaskInTime(0, core.Wrap(function()
      ReleaseIfEmpty(TheWorld, key, CountLivingPrefabs(boss.prefabs, boss.test))
    end))
  end))
end

local function HookAppear(prefab, boss)
  AddPrefabPostInit(prefab, core.Wrap(function(inst)
    if not core.World.IsServerSide() then
      return
    end

    if boss.shared ~= nil and (boss.test == nil or boss.test(inst)) then
      WatchSharedRelease(inst, boss)
    end

    --- 世界生成 / 读档填充期出生：不视为「现身」
    if POPULATING then
      inst._dst_broadcasts_appear_loaded = true
    end

    local old_on_load = inst.OnLoad
    inst.OnLoad = function(inst, data)
      inst._dst_broadcasts_appear_loaded = true
      if old_on_load ~= nil then
        core.Call(old_on_load, inst, data)
      end
    end

    inst:DoTaskInTime(0, core.Wrap(function()
      if not inst:IsValid() then
        return
      end
      --- 读档 / 世界填充：跳过即时现身，但仍装 watch（Klaus 解链、瓦器人敌对等）
      if not inst._dst_broadcasts_appear_loaded then
        if TryAnnounce(inst, boss) then
          return
        end
      end
      if boss.watch ~= nil then
        boss.watch(inst, core.Wrap(function()
          TryAnnounce(inst, boss)
        end))
      end
    end))
  end))
end

for prefab, boss in pairs(PREFAB_BOSS) do
  HookAppear(prefab, boss)
end
