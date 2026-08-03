--[[
  判断实体生命是否已贴到 minhealth（含等于）。

  读取 components.health.currenthealth / minhealth；无 health 或当前生命非数字时为 false。
  minhealth 非数字时按 0 处理。用于「非致命击败 / 仍存活但贴底」类判断。

  @param inst Entity
  @return boolean
]]

local function IsAtMinHealth(inst)
  local health = inst.components ~= nil and inst.components.health or nil
  if health == nil or type(health.currenthealth) ~= "number" then
    return false
  end
  local minhealth = health.minhealth
  if type(minhealth) ~= "number" then
    minhealth = 0
  end
  return health.currenthealth <= minhealth
end

BROADCASTS_IS_AT_MIN_HEALTH = IsAtMinHealth
