--- 读取物品当前数量；不可堆叠视为 1。
--- @param inst Entity|nil
--- @return number|nil 无效或 StackSize 非正数时为 nil
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
