--[[
  永恒早报：跨天时播报天气与存活巨兽。
  日期见 features/calendar；收获见 features/harvest。
]]

modimport("scripts/broadcasts/shared/is_at_min_health.lua")

local S = BROADCASTS_STRINGS
local N = S.bosses
local Safe = BROADCASTS_SAFE
local IsAtMinHealth = BROADCASTS_IS_AT_MIN_HEALTH

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
  },
  { name = N.malbatross,  prefabs = { "malbatross" } },
  { name = N.antlion,     prefabs = { "antlion" } },
  { name = N.crabking,    prefabs = { "crabking" } },
  { name = N.eyeofterror, prefabs = { "eyeofterror" } },
  { name = N.twins,       prefabs = { "twinofterror1", "twinofterror2" } },
  { name = N.daywalker,   prefabs = { "daywalker" } },
  { name = N.daywalker2,  prefabs = { "daywalker2" } },
  { name = N.sharkboi,    prefabs = { "sharkboi" } },
  { name = N.worm_boss,   prefabs = { "worm_boss" } },
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
  { name = N.minotaur,                       prefabs = { "minotaur" } },
  { name = N.stalker_atrium,                 prefabs = { "stalker_atrium" } },
  { name = N.alterguardian_phase3,           prefabs = { "alterguardian_phase1", "alterguardian_phase2", "alterguardian_phase3" } },
  { name = N.alterguardian_phase4_lunarrift, prefabs = { "alterguardian_phase4_lunarrift" } },
}

local PREFAB_SET = {}
for _, boss in ipairs(BOSSES) do
  for _, prefab in ipairs(boss.prefabs) do
    PREFAB_SET[prefab] = boss
  end
end

local function AsInt(value, fallback)
  if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
    return fallback
  end
  return math.floor(value + 0.5)
end

local function Clamp01(value)
  if type(value) ~= "number" or value ~= value then
    return 0
  end
  if value < 0 then
    return 0
  end
  if value > 1 then
    return 1
  end
  return value
end

local function AppendFormatted(message, fmt, ...)
  if type(fmt) ~= "string" or fmt == "" then
    return message
  end
  return message .. string.format(fmt, ...)
end

local function IsAliveBoss(inst, boss)
  if inst == nil or not inst:IsValid() or inst:HasTag("INLIMBO") then
    return false
  end
  if inst.defeated or (inst.sg ~= nil and inst.sg:HasStateTag("defeated")) then
    return false
  end
  if inst.prefab == "sharkboi" then
    local components = inst.components
    if components ~= nil and components.trader ~= nil then
      return false
    end
    if IsAtMinHealth(inst) then
      return false
    end
  end
  local components = inst.components
  local health = components ~= nil and components.health or nil
  if health ~= nil and health:IsDead() then
    return false
  end
  return boss.test == nil or boss.test(inst)
end

local function CollectBossNames()
  local found = {}
  for _, inst in pairs(Ents) do
    local boss = inst.prefab ~= nil and PREFAB_SET[inst.prefab] or nil
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

local function WeatherSummary()
  local state = TheWorld.state
  local current = S.weather[state.precipitation]
  if current ~= nil then
    return current
  end
  local pop = AsInt(Clamp01(state.pop) * 100, 0)
  return string.format(S.weather_clear, pop)
end

local function AnnounceMorning()
  if TheWorld.state == nil then
    return
  end

  local bosses = CollectBossNames()
  local message = WeatherSummary()
  if #bosses > 0 then
    message = AppendFormatted(message, S.morning_bosses, table.concat(bosses, S.list_separator))
  end

  local end_mark = type(S.morning_end) == "string" and S.morning_end or ""
  Safe.Announce(message .. end_mark)
end

AddSimPostInit(Safe.Wrap("morning_init", function()
  if not TheWorld.ismastersim then
    return
  end

  local prev_cycles = TheWorld.state.cycles
  TheWorld:WatchWorldState("cycles", Safe.Wrap("morning_cycles", function(_, cycles)
    local previous = prev_cycles
    prev_cycles = cycles
    if type(cycles) ~= "number" or type(previous) ~= "number" then
      return
    end
    if cycles ~= previous + 1 or cycles <= 0 then
      return
    end
    TheWorld:DoTaskInTime(0, Safe.Wrap("morning_report", AnnounceMorning))
  end))
end))
