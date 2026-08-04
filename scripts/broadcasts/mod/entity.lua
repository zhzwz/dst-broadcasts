-- 是否存活：有效且带 health、未死；不排除 INLIMBO
-- @param inst Entity|nil
-- @return boolean
local function IsAlive(inst)
  if inst == nil or not inst:IsValid() then
    return false
  end
  local health = inst.components ~= nil and inst.components.health or nil
  return health ~= nil and not health:IsDead()
end

local STACK_TAG = "mod.Entity.GetStackSize"
-- 安全读取堆叠数量；非堆叠或失败时为 1
-- @param inst Entity|nil
-- @return number
local function GetStackSize(inst)
  if inst == nil or not inst:IsValid() then
    return 1
  end
  local stackable = inst.components ~= nil and inst.components.stackable or nil
  if stackable == nil or stackable.StackSize == nil then
    return 1
  end
  local size = mod.Call(STACK_TAG, stackable.StackSize, stackable)
  if type(size) == "number" and size > 0 then
    return size
  end
  return 1
end

local TAG = "mod.Entity.GetDisplayName"

-- 安全读取实体名称
-- @param inst Entity|nil
-- @return string|nil 例如 "Wilson"
local function GetDisplayName(inst)
  if inst == nil or not inst:IsValid() then
    return nil
  end
  local name = mod.Call(TAG, inst.GetDisplayName, inst)
  if type(name) == "string" and name ~= "" then
    return name
  end
  return nil
end

mod.Entity = {
  IsAlive = IsAlive,
  GetStackSize = GetStackSize,
  GetDisplayName = GetDisplayName,
}
