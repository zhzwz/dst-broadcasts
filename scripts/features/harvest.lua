--- 收获：进入黄昏时按物资种类分别公告本分片待收（大理石灌木 / 蜂箱 / 农田 / 晾晒架）。
--- 仅主机；day→dusk 时公告（森林 / 洞穴各自扫描）；洞穴类别后加括号标记。
--- 数量为 0 或列表为空时跳过；每种物资单独 Announce。

local S = i18n

local ENABLE = {
  MARBLESHRUB = true,
  BEEBOX = true,
  FARMLAND = true,
  DRYINGRACK = true,
}

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

local function AddNamedCount(counts, prefab, amount)
  if type(prefab) ~= "string" or prefab == "" then
    return
  end
  if type(amount) ~= "number" or amount ~= amount or amount <= 0 then
    return
  end
  counts[prefab] = (counts[prefab] or 0) + math.floor(amount)
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
  if info == nil then
    return false
  end
  return not IsDryingRackItemStillDrying(info)
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
    AddNamedCount(counts, item.prefab, core.GetCount(item))
  end

  if container.ForEachItem ~= nil then
    core.Call(function()
      container:ForEachItem(consider)
    end)
  elseif type(container.slots) == "table" then
    for _, item in pairs(container.slots) do
      consider(item)
    end
  end
end

local function FormatPrefabCountList(counts)
  local named = {}
  for prefab, n in pairs(counts) do
    if type(n) == "number" and n > 0 then
      local name = core.GetPrefabDisplayName(prefab)
      if name ~= nil then
        named[name] = (named[name] or 0) + n
      end
    end
  end
  return core.FormatEntryCountList(named)
end

local function CollectHarvest()
  local marbleshrub = 0
  local honey = 0
  local farm_counts = {}
  local dried_counts = {}

  for _, inst in pairs(Ents) do
    if ENABLE.MARBLESHRUB and IsMatureMarbleshrub(inst) then
      marbleshrub = marbleshrub + 1
    end
    if ENABLE.BEEBOX then
      honey = honey + GetPlayerBeeboxHoney(inst)
    end
    if ENABLE.FARMLAND and IsMatureFarmPlant(inst) then
      AddNamedCount(farm_counts, GetFarmPlantCountKey(inst), 1)
    end
    if ENABLE.DRYINGRACK then
      CollectDoneDriedFromRack(inst, dried_counts)
    end
  end

  return marbleshrub, honey, FormatPrefabCountList(farm_counts), FormatPrefabCountList(dried_counts)
end

local function BuildAnnounceLines(data)
  local mark = ""
  if core.World.IsCave() and type(S.harvest_cave_mark) == "string" then
    mark = S.harvest_cave_mark
  end

  local lines = {}
  if ENABLE.MARBLESHRUB and type(data.marbleshrub) == "number" and data.marbleshrub > 0 then
    table.insert(lines, string.format(S.harvest_marbleshrub, mark, data.marbleshrub))
  end
  if ENABLE.BEEBOX and type(data.honey) == "number" and data.honey > 0 then
    table.insert(lines, string.format(S.harvest_beebox, mark, data.honey))
  end
  if ENABLE.FARMLAND and type(data.farm_list) == "string" and data.farm_list ~= "" then
    table.insert(lines, string.format(S.harvest_farm, mark, data.farm_list))
  end
  if ENABLE.DRYINGRACK and type(data.dried_list) == "string" and data.dried_list ~= "" then
    table.insert(lines, string.format(S.harvest_dried, mark, data.dried_list))
  end
  return lines
end

local function AnnounceHarvest()
  local marbleshrub, honey, farm_list, dried_list = CollectHarvest()
  local lines = BuildAnnounceLines({
    marbleshrub = marbleshrub,
    honey = honey,
    farm_list = farm_list,
    dried_list = dried_list,
  })

  for _, line in ipairs(lines) do
    DST_SERVER_SEND(line)
  end
end

--- day→dusk 时公告
core.World.ListenPhase("server", function(phase)
  if phase ~= "dusk" then
    return
  end
  AnnounceHarvest()
end)
