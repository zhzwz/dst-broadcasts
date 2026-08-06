--- 判断实体是否存活（有 health 且 IsDead 不为 true）。
--- @param inst Entity|nil
--- @return boolean
core.IsAlive = function(inst)
  if not core.IsValid(inst) then
    return false
  end
  --- @cast inst Entity
  local health = inst.components and inst.components.health
  if health == nil then
    return false
  end
  if type(health.IsDead) ~= "function" then
    return false
  end
  return core.Call(health.IsDead, health) == false
end
