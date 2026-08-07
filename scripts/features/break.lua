--- 物品损坏：武器（finiteuses）/ 护甲损坏时全服播报；白名单物品剩余 1 次时提前提醒。
--- 仅主机；读档/首帧对齐 flag 不播报。

local PlayerOwner = core.GetOwner
local S = i18n

--- 有限次数、不易获得物品；剩余 1 次使用时提醒。按需增删键即可。
local LAST_USE_WHITELIST = {
  greenamulet = true, --- 建造护符
  greenstaff = true,  --- 解构魔杖
  yellowstaff = true, --- 唤星者魔杖
  opalstaff = true,   --- 唤月者魔杖
  orangestaff = true, --- 懒人魔杖
  telestaff = true,   --- 传送魔杖
  panflute = true,    --- 排箫
  ruins_bat = true,   --- 铥矿棒
}

local function AnnounceBroke(owner, item_name)
  core.Announce(string.format(
    S.item_broke,
    core.GetDisplayName(owner) or "?",
    item_name
  ))
end

local function AnnounceLastUse(owner, item_name)
  core.Announce(string.format(
    S.item_last_use,
    core.GetDisplayName(owner) or "?",
    item_name
  ))
end

local function OnArmorBroke(player, data)
  if player == nil or not player:HasTag("player") then
    return
  end
  local armor = data and data.armor
  local item_name = (armor ~= nil and (core.GetDisplayName(armor) or core.GetPrefabDisplayName(armor.prefab))) or
      S.armor
  AnnounceBroke(player, item_name)
end

local function WatchPlayer(player)
  if player._dst_broadcasts_armor_broke then
    return
  end
  player._dst_broadcasts_armor_broke = true
  player:ListenForEvent("armorbroke", core.Wrap(OnArmorBroke))
end

AddPlayerPostInit(core.Wrap(function(player)
  if not core.IsServer() then
    return
  end
  core.SetTimeout(player, function()
    if player:IsValid() then
      WatchPlayer(player)
    end
  end, 0)
end))

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

--- allow_announce=false：仅对齐 flag（读档/首帧），不播报
local function TryAnnounceLastUse(inst, allow_announce)
  if not LAST_USE_WHITELIST[inst.prefab] then
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
  AnnounceLastUse(owner, core.GetDisplayName(inst) or core.GetPrefabDisplayName(inst.prefab))
end

local function TryAnnounceBroke(inst, allow_announce)
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
  AnnounceBroke(owner, core.GetDisplayName(inst) or core.GetPrefabDisplayName(inst.prefab))
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

AddComponentPostInit("finiteuses", core.Wrap(function(self)
  if not core.IsServer() then
    return
  end
  local inst = self.inst
  if inst._dst_broadcasts_finiteuses_watching then
    return
  end
  inst._dst_broadcasts_finiteuses_watching = true
  inst._dst_broadcasts_finiteuses_ready = false
  inst:ListenForEvent("percentusedchange", core.Wrap(OnFiniteUsesChange))
  inst:ListenForEvent("onputininventory", core.Wrap(OnPutInInventory))
  core.SetTimeout(inst, function()
    if not inst:IsValid() then
      return
    end
    SyncFiniteUsesFlags(inst)
    inst._dst_broadcasts_finiteuses_ready = true
  end, 0)
end))
