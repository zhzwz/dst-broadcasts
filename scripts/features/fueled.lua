--- 可缝补（FUELTYPE.USAGE）耐久与可补燃料（非 USAGE）的多档全服公告。
--- 仅主机；读档首帧对齐 flag 不公告；无主不钉 flag，进背包时补检；每档下降越过各公告一次。

local PlayerOwner = core.GetOwner
local S = i18n

--- 可缝补物品耐久公告阈值（百分比）
local DURABILITY_THRESHOLDS = { 20, 10, 5, 4, 3, 2, 1 }
--- 可补充燃料物品公告阈值（百分比）
local FUEL_THRESHOLDS = { 30, 20, 10 }

local function Announce(inst, owner, percent, message)
  local item_name = core.GetDisplayName(inst)
      or core.GetPrefabDisplayName(inst.prefab)
  local owner_name = core.GetDisplayName(owner) or "?"
  local pct = math.floor(percent * 100 + 0.5)

  DST_SERVER_SEND(string.format(
    message,
    owner_name,
    item_name,
    pct
  ))
end

--- 检查燃料百分比档位；新跨越的每一档各公告一次。
local function CheckThresholds(inst, owner, percent, thresholds, flag_key, message, allow_announce)
  local pct = percent * 100
  local flags = inst[flag_key]
  if flags == nil then
    flags = {}
    inst[flag_key] = flags
  end

  for _, t in ipairs(thresholds) do
    if pct <= t then
      if not flags[t] then
        --- allow_announce=false：读档对齐可钉 flag；无主且允许公告时不钉，等进背包再检
        if not allow_announce then
          flags[t] = true
        elseif owner ~= nil then
          flags[t] = true
          Announce(inst, owner, percent, message)
        end
      end
    else
      flags[t] = nil
    end
  end
end

local function OnPercentUsedChange(inst, data, allow_announce)
  if allow_announce == nil then
    allow_announce = inst._dst_broadcasts_fueled_ready == true
  end

  local fueled = inst.components.fueled
  if fueled == nil then
    return
  end

  local percent = (data and data.percent) or fueled:GetPercent()
  if type(percent) ~= "number" or percent ~= percent then
    percent = fueled:GetPercent()
  end
  if type(percent) ~= "number" or percent ~= percent then
    return
  end

  local owner = PlayerOwner(inst)
  if fueled.fueltype == FUELTYPE.USAGE then
    CheckThresholds(
      inst,
      owner,
      percent,
      DURABILITY_THRESHOLDS,
      "_dst_broadcasts_sew_flags",
      S.item_low_durability,
      allow_announce
    )
  else
    CheckThresholds(
      inst,
      owner,
      percent,
      FUEL_THRESHOLDS,
      "_dst_broadcasts_fuel_flags",
      S.item_low_fuel,
      allow_announce
    )
  end
end

local function OnPutInInventory(inst)
  if not inst._dst_broadcasts_fueled_ready then
    return
  end
  OnPercentUsedChange(inst, nil, true)
end

local function WatchFueled(inst)
  local fueled = inst.components.fueled
  if fueled == nil then
    return
  end
  if inst._dst_broadcasts_fueled_watching then
    return
  end
  inst._dst_broadcasts_fueled_watching = true
  inst._dst_broadcasts_fueled_ready = false

  inst:ListenForEvent("percentusedchange", core.Wrap(OnPercentUsedChange))
  inst:ListenForEvent("onputininventory", core.Wrap(OnPutInInventory))
  OnPercentUsedChange(inst, nil, false)
  inst._dst_broadcasts_fueled_ready = true
end

AddComponentPostInit("fueled", core.Wrap(function(self)
  if not core.World.IsServerSide() then
    return
  end
  self.inst:DoTaskInTime(0, core.Wrap(function(inst)
    if inst:IsValid() then
      WatchFueled(inst)
    end
  end))
end))
