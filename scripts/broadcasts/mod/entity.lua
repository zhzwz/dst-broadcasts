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
  GetDisplayName = GetDisplayName,
}
