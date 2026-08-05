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

--- 读取实体的当前数量
--- @param inst Entity|nil
--- @return number
local function GetCount(inst)
  if not IsValid(inst) then
    return 0
  end
  --- @cast inst Entity
  local stackable = inst.components and inst.components.stackable
  if stackable == nil or stackable.StackSize == nil then
    return 1
  end
  local size = mod.Call("mod.Entity.GetCount", stackable.StackSize, stackable)
  if type(size) == "number" and size > 0 then
    return size
  end
  return 1
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
  GetCount = GetCount,
  GetDisplayName = GetDisplayName,
}
