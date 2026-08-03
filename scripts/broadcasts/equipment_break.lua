--[[
  武器（finiteuses）/ 护甲损坏时全服播报一次。
]]

modimport("scripts/broadcasts/shared/get_player_owner.lua")

local Safe = BROADCASTS_SAFE
local PlayerOwner = BROADCASTS_GET_PLAYER_OWNER

local function AnnounceBroke(owner, item_name)
  Safe.Announce(string.format(
    BROADCASTS_STRINGS.item_broke,
    owner:GetDisplayName() or "?",
    item_name
  ))
end

local function OnArmorBroke(player, data)
  if player == nil or not player:HasTag("player") then
    return
  end
  local armor = data and data.armor
  local item_name = (armor ~= nil and (armor:GetDisplayName() or armor.prefab)) or
      BROADCASTS_STRINGS.armor
  AnnounceBroke(player, item_name)
end

local function WatchPlayer(player)
  if player._dst_broadcasts_armor_broke then
    return
  end
  player._dst_broadcasts_armor_broke = true
  player:ListenForEvent("armorbroke", Safe.Wrap("equipment_armor", OnArmorBroke))
end

AddPlayerPostInit(Safe.Wrap("equipment_player_init", function(player)
  if not TheWorld.ismastersim then
    return
  end
  player:DoTaskInTime(0, Safe.Wrap("equipment_player_watch", function()
    if player:IsValid() then
      WatchPlayer(player)
    end
  end))
end))

local function SyncFiniteUsesFlags(inst)
  local uses = inst.components.finiteuses
  if uses == nil then
    return
  end
  local percent = uses:GetPercent()
  if type(percent) ~= "number" or percent ~= percent then
    return
  end
  if percent > 0 then
    inst._dst_broadcasts_uses_broke = nil
  else
    inst._dst_broadcasts_uses_broke = true
  end
end

local function OnFiniteUsesChange(inst, data)
  local uses = inst.components.finiteuses
  if uses == nil then
    return
  end

  local percent = (data and data.percent) or uses:GetPercent()
  if type(percent) ~= "number" or percent ~= percent then
    percent = uses:GetPercent()
  end
  if type(percent) ~= "number" or percent ~= percent then
    return
  end
  if percent > 0 then
    inst._dst_broadcasts_uses_broke = nil
    return
  end
  if inst._dst_broadcasts_uses_broke then
    return
  end
  inst._dst_broadcasts_uses_broke = true

  if not inst._dst_broadcasts_finiteuses_ready then
    return
  end

  local owner = PlayerOwner(inst)
  if owner == nil then
    return
  end
  AnnounceBroke(owner, inst:GetDisplayName() or inst.prefab)
end

AddComponentPostInit("finiteuses", Safe.Wrap("equipment_finiteuses_init", function(self)
  if not TheWorld.ismastersim then
    return
  end
  local inst = self.inst
  if inst._dst_broadcasts_finiteuses_watching then
    return
  end
  inst._dst_broadcasts_finiteuses_watching = true
  inst._dst_broadcasts_finiteuses_ready = false
  inst:ListenForEvent("percentusedchange", Safe.Wrap("equipment_finiteuses", OnFiniteUsesChange))
  inst:DoTaskInTime(0, Safe.Wrap("equipment_finiteuses_sync", function()
    if not inst:IsValid() then
      return
    end
    SyncFiniteUsesFlags(inst)
    inst._dst_broadcasts_finiteuses_ready = true
  end))
end))
