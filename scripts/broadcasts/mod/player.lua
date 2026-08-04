-- 安全读取玩家名称；失败时返回 "?"
-- @param player Entity|nil
-- @return string
local function GetDisplayName(player)
  return mod.Entity.GetDisplayName(player) or "?"
end

local OWNER_TAG = "mod.Player.GetOwner"
-- 取得物品归属的玩家（grand owner）
-- @param inst Entity|nil 物品实体
-- @return Entity|nil
local function GetOwner(inst)
  if inst == nil or not inst:IsValid() then
    return nil
  end
  local item = inst.components ~= nil and inst.components.inventoryitem or nil
  if item == nil then
    return nil
  end
  ---@type any
  local owner = mod.Call(OWNER_TAG, item.GetGrandOwner, item)
  if owner ~= nil and owner:HasTag("player") then
    return owner
  end
  return nil
end

mod.Player = {
  GetDisplayName = GetDisplayName,
  GetOwner = GetOwner,
}
