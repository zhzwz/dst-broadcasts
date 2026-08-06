--- 取得物品归属的玩家（grand owner）；非玩家或不存在时返回 nil。
--- @param inst Entity|nil 物品实体
--- @return Entity|nil
core.GetOwner = function(inst)
  if not core.IsValid(inst) then
    return
  end
  --- @cast inst Entity
  local item = inst.components and inst.components.inventoryitem
  local owner = item and core.Call(item.GetGrandOwner, item)
  if core.HasTag(owner, "player") then
    return owner
  end
end
