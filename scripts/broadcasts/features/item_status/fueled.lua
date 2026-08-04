--[[
  可缝补（USAGE）耐久与可补燃料（非 USAGE）的多档全服播报。
]]

modimport("scripts/broadcasts/shared/get_player_owner.lua")

local Safe = BROADCASTS_SAFE
local C = BROADCASTS_ITEM_STATUS_CONSTANTS
local H = BROADCASTS_ITEM_STATUS
local PlayerOwner = BROADCASTS_GET_PLAYER_OWNER
local S = BROADCASTS_STRINGS

local function Announce(inst, owner, percent, message)
  local item_name = inst:GetDisplayName() or inst.prefab
  local owner_name = owner:GetDisplayName() or "?"
  local pct = math.floor(percent * 100 + 0.5)

  Safe.Announce(string.format(
    message,
    owner_name,
    item_name,
    pct
  ))
end

local function CheckThresholds(inst, owner, percent, thresholds, flag_key, message, allow_announce)
  local pct = percent * 100
  local flags = inst[flag_key]
  if flags == nil then
    flags = {}
    inst[flag_key] = flags
  end

  local should_announce = false
  for _, t in ipairs(thresholds) do
    if pct <= t then
      if not flags[t] then
        flags[t] = true
        should_announce = true
      end
    else
      flags[t] = nil
    end
  end

  if allow_announce and should_announce and owner ~= nil then
    Announce(inst, owner, percent, message)
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

  inst:ListenForEvent("percentusedchange", Safe.Wrap("item_status_fueled", OnPercentUsedChange))
  Safe.Call("item_status_fueled_sync", OnPercentUsedChange, inst, nil, false)
  inst._dst_broadcasts_fueled_ready = true
end

AddComponentPostInit("fueled", Safe.Wrap("item_status_fueled_init", function(self)
  if not TheWorld.ismastersim then
    return
  end
  self.inst:DoTaskInTime(0, Safe.Wrap("item_status_fueled_watch", function(inst)
    if inst:IsValid() then
      WatchFueled(inst)
    end
  end))
end))
