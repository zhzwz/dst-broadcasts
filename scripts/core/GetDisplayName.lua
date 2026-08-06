--- 读取实体的显示名称；无效或为空时返回 nil。
--- @param inst Entity|nil
--- @return string|nil
core.GetDisplayName = function(inst)
  if not core.IsValid(inst) then
    return nil
  end
  --- @cast inst Entity
  if type(inst.GetDisplayName) ~= "function" then
    return nil
  end
  local name = core.Call(inst.GetDisplayName, inst)
  if type(name) == "string" and name ~= "" then
    return name
  end
  return nil
end
