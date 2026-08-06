--- 读取物品当前数量；不可堆叠视为 1。
--- 实体无效、或 stackable.StackSize 无法得到正数时返回 nil。
--- @param inst Entity|nil
--- @return number|nil
core.GetCount = function(inst)
  if not core.IsValid(inst) then
    return nil
  end
  --- @cast inst Entity
  local stackable = inst.components and inst.components.stackable
  if stackable == nil or stackable.StackSize == nil then
    return 1
  end
  local size = core.Call(stackable.StackSize, stackable)
  if type(size) == "number" and size > 0 then
    return size
  end
  return nil
end
