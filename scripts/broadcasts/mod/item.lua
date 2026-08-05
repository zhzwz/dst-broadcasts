--- 取得物品归属的玩家（grand owner）
--- @param inst Entity|nil 物品实体
--- @return Entity|nil
local function GetOwner(inst)
  if not mod.Entity.IsValid(inst) then
    return
  end
  --- @cast inst Entity
  local item = inst.components and inst.components.inventoryitem
  local owner = item and mod.Call("mod.Item.GetOwner", item.GetGrandOwner, item)
  if mod.Entity.HasTag(owner, "player") then
    return owner
  end
end

--- 读取物品的当前数量（不可堆叠视为 1；无效实体为 0）
--- @param inst Entity|nil
--- @return number
local function GetCount(inst)
  if not mod.Entity.IsValid(inst) then
    return 0
  end
  --- @cast inst Entity
  local stackable = inst.components and inst.components.stackable
  if stackable == nil or stackable.StackSize == nil then
    return 1
  end
  local size = mod.Call("mod.Item.GetCount", stackable.StackSize, stackable)
  if type(size) == "number" and size > 0 then
    return size
  end
  return 1
end

mod.Item = {
  GetOwner = GetOwner,
  GetCount = GetCount,
}
