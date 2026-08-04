--[[
  可缝补（USAGE）耐久与可补燃料（非 USAGE）的多档全服播报。
]]

local C = BROADCASTS_ITEM_STATUS_CONSTANTS
local H = BROADCASTS_ITEM_STATUS
local PlayerOwner = mod.Player.GetOwner
local S = BROADCASTS_STRINGS

local function Announce(inst, owner, percent, message)
  local item_name = inst:GetDisplayName() or inst.prefab
  local owner_name = owner:GetDisplayName() or "?"
  local pct = math.floor(percent * 100 + 0.5)

  mod.Announce(string.format(
    message,
    owner_name,
    item_name,
    pct
  ))
end

-- allow_announce=false：读档对齐可钉 flag；无主且允许播报时不钉，等进背包再检
-- 新跨越的每一档各播一次（与饱食一致；一次跳变跨多档会连播）
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
    if not H.DURABILITY then
      return
    end
    CheckThresholds(
      inst,
      owner,
      percent,
      C.DURABILITY_THRESHOLDS,
      "_dst_broadcasts_sew_flags",
      S.item_low_durability,
      allow_announce
    )
  else
    if not H.FUEL then
      return
    end
    CheckThresholds(
      inst,
      owner,
      percent,
      C.FUEL_THRESHOLDS,
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

  inst:ListenForEvent("percentusedchange", mod.Wrap("item_status_fueled", OnPercentUsedChange))
  inst:ListenForEvent("onputininventory", mod.Wrap("item_status_fueled_inv", OnPutInInventory))
  mod.Call("item_status_fueled_sync", OnPercentUsedChange, inst, nil, false)
  inst._dst_broadcasts_fueled_ready = true
end

AddComponentPostInit("fueled", mod.Wrap("item_status_fueled_init", function(self)
  if not mod.World.IsMaster() then
    return
  end
  self.inst:DoTaskInTime(0, mod.Wrap("item_status_fueled_watch", function(inst)
    if inst:IsValid() then
      WatchFueled(inst)
    end
  end))
end))
