--- 判断实体生命是否已贴到 minhealth（含等于；无 health 为 false）。
--- @param inst Entity|nil
--- @return boolean
core.IsAtMinHealth = function(inst)
  if not core.IsValid(inst) then
    return false
  end
  --- @cast inst Entity
  local health = inst.components and inst.components.health
  if health == nil or type(health.currenthealth) ~= "number" then
    return false
  end
  local minhealth = health.minhealth
  if type(minhealth) ~= "number" then
    minhealth = 0
  end
  return health.currenthealth <= minhealth
end
