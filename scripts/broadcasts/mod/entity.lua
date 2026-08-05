--- 判断实体是否有效
--- @param inst Entity|nil
--- @return boolean
local function IsValid(inst)
  if inst == nil then
    return false
  end
  if type(inst.IsValid) ~= "function" then
    return false
  end
  return mod.Call("mod.Entity.IsValid", inst.IsValid, inst) == true
end

--- 判断实体是否带有指定标签
--- @param inst Entity|nil
--- @param tag string
--- @return boolean
local function HasTag(inst, tag)
  if inst == nil or type(tag) ~= "string" then
    return false
  end
  if type(inst.HasTag) ~= "function" then
    return false
  end
  return mod.Call("mod.Entity.HasTag", inst.HasTag, inst, tag) == true
end

--- 判断实体是否存活
--- @param inst Entity|nil
--- @return boolean
local function IsAlive(inst)
  if not IsValid(inst) then
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
  return mod.Call("mod.Entity.IsAlive(health.IsDead)", health.IsDead, health) == false
end

--- 判断实体生命是否已贴到 minhealth（含等于；无 health 为 false）
--- @param inst Entity|nil
--- @return boolean
local function IsAtMinHealth(inst)
  if not IsValid(inst) then
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

--- 读取实体的显示名称
--- @param inst Entity|nil
--- @return string|nil
local function GetDisplayName(inst)
  if not IsValid(inst) then
    return nil
  end
  --- @cast inst Entity
  if type(inst.GetDisplayName) ~= "function" then
    return nil
  end
  local name = mod.Call("mod.Entity.GetDisplayName", inst.GetDisplayName, inst)
  if type(name) == "string" and name ~= "" then
    return name
  end
  return nil
end

mod.Entity = {
  IsValid = IsValid,
  HasTag = HasTag,
  IsAlive = IsAlive,
  IsAtMinHealth = IsAtMinHealth,
  GetDisplayName = GetDisplayName,
}
