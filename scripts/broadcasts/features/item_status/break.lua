--[[
  武器（finiteuses）/ 护甲损坏时全服播报一次；
  白名单物品在剩余 1 次时提前提醒（由 BREAK_WARNING 开关控制）。
]]

modimport("scripts/broadcasts/shared/get_player_owner.lua")

local Safe = BROADCASTS_SAFE
local H = BROADCASTS_ITEM_STATUS
local PlayerOwner = BROADCASTS_GET_PLAYER_OWNER
local S = BROADCASTS_STRINGS
local LastUseWhitelist = BROADCASTS_ITEM_STATUS_LAST_USE_WHITELIST or {}

local function AnnounceBroke(owner, item_name)
  Safe.Announce(string.format(
    S.item_broke,
    owner:GetDisplayName() or "?",
    item_name
  ))
end

local function AnnounceLastUse(owner, item_name)
  Safe.Announce(string.format(
    S.item_last_use,
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
      S.armor
  AnnounceBroke(player, item_name)
end

local function WatchPlayer(player)
  if player._dst_broadcasts_armor_broke then
    return
  end
  player._dst_broadcasts_armor_broke = true
  player:ListenForEvent("armorbroke", Safe.Wrap("item_status_armor", OnArmorBroke))
end

if H.BREAK then
  AddPlayerPostInit(Safe.Wrap("item_status_player_init", function(player)
    if not TheWorld.ismastersim then
      return
    end
    player:DoTaskInTime(0, Safe.Wrap("item_status_player_watch", function()
      if player:IsValid() then
        WatchPlayer(player)
      end
    end))
  end))
end

local function GetCurrentUses(uses)
  local current = uses:GetUses()
  if type(current) == "number" and current == current then
    return current
  end
  current = uses.current
  if type(current) == "number" and current == current then
    return current
  end
  return nil
end

local function ResolveCurrentUses(uses, data)
  local current = GetCurrentUses(uses)
  if current ~= nil then
    return current
  end
  if data == nil or type(data.percent) ~= "number" then
    return nil
  end
  local total = uses.total
  if type(total) ~= "number" or total <= 0 then
    return nil
  end
  return math.floor(data.percent * total + 0.5)
end

-- allow_announce=false：仅对齐 flag（读档/首帧），不播报
local function TryAnnounceLastUse(inst, allow_announce)
  if not H.BREAK_WARNING then
    return
  end
  if not LastUseWhitelist[inst.prefab] then
    return
  end
  if inst._dst_broadcasts_uses_last then
    return
  end

  if not allow_announce then
    inst._dst_broadcasts_uses_last = true
    return
  end

  local owner = PlayerOwner(inst)
  if owner == nil then
    return
  end

  inst._dst_broadcasts_uses_last = true
  AnnounceLastUse(owner, inst:GetDisplayName() or inst.prefab)
end

local function TryAnnounceBroke(inst, allow_announce)
  if not H.BREAK then
    return
  end
  if inst._dst_broadcasts_uses_broke then
    return
  end

  if not allow_announce then
    inst._dst_broadcasts_uses_broke = true
    inst._dst_broadcasts_uses_last = true
    return
  end

  local owner = PlayerOwner(inst)
  if owner == nil then
    return
  end

  inst._dst_broadcasts_uses_broke = true
  inst._dst_broadcasts_uses_last = true
  AnnounceBroke(owner, inst:GetDisplayName() or inst.prefab)
end

local function ApplyFiniteUsesState(inst, current, allow_announce)
  if current > 1 then
    inst._dst_broadcasts_uses_broke = nil
    inst._dst_broadcasts_uses_last = nil
    return
  end

  if current == 1 then
    inst._dst_broadcasts_uses_broke = nil
    TryAnnounceLastUse(inst, allow_announce)
    return
  end

  TryAnnounceBroke(inst, allow_announce)
end

local function OnFiniteUsesChange(inst, data)
  if not inst._dst_broadcasts_finiteuses_ready then
    return
  end

  local uses = inst.components.finiteuses
  if uses == nil then
    return
  end

  local current = ResolveCurrentUses(uses, data)
  if current == nil then
    return
  end

  ApplyFiniteUsesState(inst, current, true)
end

local function OnPutInInventory(inst)
  if not inst._dst_broadcasts_finiteuses_ready then
    return
  end

  local uses = inst.components.finiteuses
  if uses == nil then
    return
  end

  local current = GetCurrentUses(uses)
  if current == nil then
    return
  end

  ApplyFiniteUsesState(inst, current, true)
end

local function SyncFiniteUsesFlags(inst)
  local uses = inst.components.finiteuses
  if uses == nil then
    return
  end
  local current = GetCurrentUses(uses)
  if current == nil then
    return
  end
  ApplyFiniteUsesState(inst, current, false)
end

AddComponentPostInit("finiteuses", Safe.Wrap("item_status_finiteuses_init", function(self)
  if not TheWorld.ismastersim then
    return
  end
  local inst = self.inst
  if inst._dst_broadcasts_finiteuses_watching then
    return
  end
  inst._dst_broadcasts_finiteuses_watching = true
  inst._dst_broadcasts_finiteuses_ready = false
  inst:ListenForEvent("percentusedchange", Safe.Wrap("item_status_finiteuses", OnFiniteUsesChange))
  inst:ListenForEvent("onputininventory", Safe.Wrap("item_status_finiteuses_inv", OnPutInInventory))
  inst:DoTaskInTime(0, Safe.Wrap("item_status_finiteuses_sync", function()
    if not inst:IsValid() then
      return
    end
    SyncFiniteUsesFlags(inst)
    inst._dst_broadcasts_finiteuses_ready = true
  end))
end))
