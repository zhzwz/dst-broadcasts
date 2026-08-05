--- 读取玩家的显示名称（失败返回 `?`）
--- @param player Entity|nil
--- @return string
local function GetDisplayName(player)
  return mod.Entity.GetDisplayName(player) or "?"
end

--- 取得物品归属的玩家（grand owner）
--- @param inst Entity|nil 物品实体
--- @return Entity|nil
local function GetOwner(inst)
  if not mod.Entity.IsValid(inst) then
    return
  end
  --- @cast inst Entity
  local item = inst.components and inst.components.inventoryitem
  local owner = item and mod.Call("mod.Player.GetOwner", item.GetGrandOwner, item)
  if mod.Entity.HasTag(owner, "player") then
    return owner
  end
end

mod.Player = {
  GetDisplayName = GetDisplayName,
  GetOwner = GetOwner,
}
