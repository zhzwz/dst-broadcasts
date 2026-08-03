--[[
  永恒早报：跨天时播报日期、季节、天气、近期事件、存活巨兽，
  以及成熟大理石灌木、待收蜂蜜、成熟农作物与晾晒待收获物品。
]]

local S = BROADCASTS_STRINGS
local N = S.bosses
local C = BROADCASTS_CONSTANTS
local Safe = BROADCASTS_SAFE

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

local function IsAtMinHealth(inst)
  local health = inst.components ~= nil and inst.components.health or nil
  if health == nil or type(health.currenthealth) ~= "number" then
    return false
  end
  local minhealth = health.minhealth
  if type(minhealth) ~= "number" then
    minhealth = 0
  end
  return health.currenthealth <= minhealth
end

local function IsAliveBoss(inst, boss)
  if inst == nil or not inst:IsValid() or inst:HasTag("INLIMBO") then
    return false
  end
  if inst.defeated or (inst.sg ~= nil and inst.sg:HasStateTag("defeated")) then
    return false
  end
  -- 与 boss_defeat.IsNonlethalDefeated 对齐：大霜鲨贴底/可交易后实体仍在
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

local function CollectBossNamesFromFound(found)
  local names = {}
  for _, boss in ipairs(BOSSES) do
    if found[boss] then
      table.insert(names, boss.name)
    end
  end
  return names
end

local function IsMatureMarbleshrub(inst)
  if inst == nil or inst.prefab ~= "marbleshrub" or not inst:IsValid() or inst:HasTag("INLIMBO") then
    return false
  end
  local growable = inst.components ~= nil and inst.components.growable or nil
  if growable == nil or growable.GetStage == nil then
    return false
  end
  local ok, stage = pcall(function()
    return growable:GetStage()
  end)
  return ok and stage == 3
end

local function GetPlayerBeeboxHoney(inst)
  if inst == nil or inst.prefab ~= "beebox" or not inst:IsValid() then
    return 0
  end
  if inst:HasTag("INLIMBO") or inst:HasTag("burnt") then
    return 0
  end
  local harvestable = inst.components ~= nil and inst.components.harvestable or nil
  local produce = harvestable ~= nil and harvestable.produce or nil
  if type(produce) ~= "number" or produce ~= produce or produce <= 0 then
    return 0
  end
  return math.floor(produce)
end

local function IsMatureFarmPlant(inst)
  if inst == nil or not inst:IsValid() or not inst:HasTag("farm_plant") then
    return false
  end
  if inst:HasTag("INLIMBO")
      or inst:HasTag("weed")
      or inst:HasTag("farm_plant_killjoy")
      or inst:HasTag("rotten") then
    return false
  end
  local growable = inst.components ~= nil and inst.components.growable or nil
  if growable == nil or growable.GetCurrentStageData == nil then
    return false
  end
  local ok, stage = pcall(function()
    return growable:GetCurrentStageData()
  end)
  if not ok or type(stage) ~= "table" then
    return false
  end
  if stage.name == "rotten" then
    return false
  end
  return stage.name == "full" or stage.name == "oversized"
end

-- 优先用作物产物名（如 potato），便于 STRINGS.NAMES 显示
local function GetFarmPlantCountKey(inst)
  local def = inst.plant_def
  if type(def) == "table" then
    if type(def.product) == "string" and def.product ~= "" then
      return def.product
    end
    if type(def.prefab) == "string" and def.prefab ~= "" then
      return def.prefab
    end
  end
  if type(inst.prefab) == "string" and inst.prefab ~= "" then
    return inst.prefab
  end
  return nil
end

local function GetPrefabDisplayName(prefab)
  if type(prefab) ~= "string" or prefab == "" then
    return nil
  end
  local names = STRINGS and STRINGS.NAMES
  local display = type(names) == "table" and names[string.upper(prefab)] or nil
  if type(display) == "string" and display ~= "" then
    return "[" .. display .. "]"
  end
  return "[" .. prefab .. "]"
end

local function AddNamedCount(counts, prefab, amount)
  if type(prefab) ~= "string" or prefab == "" then
    return
  end
  local n = type(amount) == "number" and amount or 1
  if n ~= n or n <= 0 then
    return
  end
  counts[prefab] = (counts[prefab] or 0) + math.floor(n)
end

local function IsDryingRackItemStillDrying(info)
  if info == nil then
    return false
  end
  if type(info) == "number" then
    return info > 0
  end
  if type(info) == "table" then
    if info.task ~= nil then
      return true
    end
    if type(info.drytime) == "number" and info.drytime > 0 then
      return true
    end
  end
  return false
end

-- 多格晾晒架上「晒完待取」：
-- - dryinginfo 有记录且已无倒计时 → 成品（非默认 build 会保留 { build }）
-- - 默认 build 晒完不写 dryinginfo → 仅计可食用、非腐坏、非盐晶副产物
local function IsDoneDriedRackItem(dryingrack, item)
  if item == nil or not item:IsValid() then
    return false
  end
  local item_components = item.components
  if item_components ~= nil and item_components.dryable ~= nil then
    return false
  end
  if item.prefab == "saltrock" or item.prefab == "spoiled_food" then
    return false
  end

  local info = dryingrack.dryinginfo ~= nil and dryingrack.dryinginfo[item] or nil
  if info ~= nil then
    return not IsDryingRackItemStillDrying(info)
  end

  return item_components ~= nil and item_components.edible ~= nil
end

local function CollectDoneDriedFromRack(inst, counts)
  if inst == nil or not inst:IsValid() or inst:HasTag("INLIMBO") or inst:HasTag("burnt") then
    return
  end

  local components = inst.components
  if components == nil then
    return
  end

  local dryer = components.dryer
  if dryer ~= nil then
    local done = inst:HasTag("dried")
    if not done and dryer.IsDone ~= nil then
      local ok, result = pcall(function()
        return dryer:IsDone()
      end)
      done = ok and result == true
    end
    if done and type(dryer.product) == "string" then
      AddNamedCount(counts, dryer.product, 1)
    end
    return
  end

  -- dryingrack：普通晾肉架；wobyrack：沃比架（容器在组件内）
  local dryingrack = components.dryingrack or components.wobyrack
  if dryingrack == nil then
    return
  end
  local container = dryingrack.GetContainer ~= nil and dryingrack:GetContainer() or components.container
  if container == nil then
    return
  end

  local function consider(item)
    if not IsDoneDriedRackItem(dryingrack, item) then
      return
    end
    local stack = 1
    local stackable = item.components ~= nil and item.components.stackable or nil
    if stackable ~= nil and stackable.StackSize ~= nil then
      local ok, size = pcall(function()
        return stackable:StackSize()
      end)
      if ok and type(size) == "number" and size > 0 then
        stack = size
      end
    end
    AddNamedCount(counts, item.prefab, stack)
  end

  if container.ForEachItem ~= nil then
    Safe.Call("morning_dried_foreach", function()
      container:ForEachItem(consider)
    end)
  elseif type(container.slots) == "table" then
    for _, item in pairs(container.slots) do
      consider(item)
    end
  end
end

-- header_fmt 如「。成熟农作物：%s」；条目用 named_count_entry（%s×%d）
local function FormatNamedCountSummary(header_fmt, counts)
  local entry_fmt = S.named_count_entry or S.morning_dried_entry
  if type(header_fmt) ~= "string" or type(entry_fmt) ~= "string" then
    return nil
  end
  local list = {}
  for prefab, n in pairs(counts) do
    if type(n) == "number" and n > 0 then
      local name = GetPrefabDisplayName(prefab)
      if name ~= nil then
        list[#list + 1] = { name = name, n = n }
      end
    end
  end
  if #list == 0 then
    return nil
  end
  table.sort(list, function(a, b)
    if a.name == b.name then
      return a.n < b.n
    end
    return a.name < b.name
  end)
  local parts = {}
  for _, entry in ipairs(list) do
    parts[#parts + 1] = string.format(entry_fmt, entry.name, entry.n)
  end
  return string.format(header_fmt, table.concat(parts, S.list_separator))
end

-- 单次扫 Ents：存活巨兽 + 早报资源
local function CollectWorldScan()
  local found_bosses = {}
  local marbleshrub = 0
  local honey = 0
  local farm_counts = {}
  local dried_counts = {}
  for _, inst in pairs(Ents) do
    local boss = inst.prefab ~= nil and PREFAB_SET[inst.prefab] or nil
    if boss ~= nil and IsAliveBoss(inst, boss) then
      found_bosses[boss] = true
    end
    if IsMatureMarbleshrub(inst) then
      marbleshrub = marbleshrub + 1
    end
    if IsMatureFarmPlant(inst) then
      AddNamedCount(farm_counts, GetFarmPlantCountKey(inst), 1)
    end
    honey = honey + GetPlayerBeeboxHoney(inst)
    CollectDoneDriedFromRack(inst, dried_counts)
  end
  return CollectBossNamesFromFound(found_bosses),
      marbleshrub,
      honey,
      FormatNamedCountSummary(S.morning_farm_plant, farm_counts),
      FormatNamedCountSummary(S.morning_dried, dried_counts)
end

local function FormatDuration(seconds)
  local whole = AsInt(seconds, 0)
  if whole < 60 then
    return string.format(S.morning_duration_seconds, math.max(1, whole))
  end
  return string.format(S.morning_duration_minutes, math.max(1, math.ceil(whole / 60)))
end

local function AddAttack(events, name, seconds)
  local day_seconds = TUNING.TOTAL_DAY_TIME
  if type(seconds) == "number" and
      seconds == seconds and
      seconds > 0 and
      type(day_seconds) == "number" and
      seconds <= day_seconds then
    table.insert(events, string.format(S.morning_attack, name, FormatDuration(seconds)))
  end
end

local function CollectEvents()
  local events = {}
  local state = TheWorld.state
  local next_season = C.NEXT_SEASON[state.season]
  if state.remainingdaysinseason == C.MORNING_SEASON_CHANGE_REMAINING_DAYS and
      next_season ~= nil and
      S.seasons[next_season] ~= nil then
    table.insert(events, string.format(S.morning_season_change, S.seasons[next_season]))
  end

  local hounded = TheWorld.components.hounded
  if hounded ~= nil and hounded.GetAttacking ~= nil and hounded.GetTimeToAttack ~= nil then
    if not hounded:GetAttacking() then
      local name = TheWorld:HasTag("cave") and N.depths_worms or N.hounds
      AddAttack(events, name, hounded:GetTimeToAttack())
    end
  end

  if not TheWorld:HasTag("cave") then
    local timers = TheWorld.components.worldsettingstimer
    if timers ~= nil then
      local attacks = {
        { name = N.deerclops, timer = C.DEERCLOPS_TIMER },
        { name = N.bearger,   timer = C.BEARGER_TIMER },
      }
      for _, attack in ipairs(attacks) do
        if timers:ActiveTimerExists(attack.timer) and not timers:IsPaused(attack.timer) then
          AddAttack(events, attack.name, timers:GetTimeLeft(attack.timer))
        end
      end
    end
  end

  return events
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
  local state = TheWorld.state
  if state == nil then
    return
  end

  local day = AsInt(state.cycles, 0) + 1
  local season_name = (S.season_short and S.season_short[state.season]) or
      S.seasons[state.season] or
      tostring(state.season or "")
  local events = CollectEvents()
  local bosses, marbleshrub, honey, farm_plant, dried = CollectWorldScan()

  local message = string.format(S.morning_report, day, season_name, WeatherSummary())
  if #events > 0 then
    message = AppendFormatted(message, S.morning_events, table.concat(events, S.list_separator))
  end
  if #bosses > 0 then
    message = AppendFormatted(message, S.morning_bosses, table.concat(bosses, S.list_separator))
  end
  if marbleshrub > 0 then
    message = AppendFormatted(message, S.morning_marbleshrub, marbleshrub)
  end
  if honey > 0 then
    message = AppendFormatted(message, S.morning_honey, honey)
  end
  if type(farm_plant) == "string" and farm_plant ~= "" then
    message = message .. farm_plant
  end
  if type(dried) == "string" and dried ~= "" then
    message = message .. dried
  end

  local end_mark = type(S.morning_end) == "string" and S.morning_end or ""
  Safe.Announce(message .. end_mark)
end

AddSimPostInit(Safe.Wrap("morning_init", function()
  if not TheWorld.ismastersim then
    return
  end

  -- 读档时 cycles 会从默认 0 跳到存档天数；只在真正跨天（+1）时播报。
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
