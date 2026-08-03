--[[
  安全读取实体 GetDisplayName，返回带方括号的显示名。

  内部 pcall，避免异常显示名拖垮回调。实体无效或取名失败时返回 nil。

  @param inst Entity|nil
  @return string|nil 例如 "[Wilson]"
]]

local function GetEntityDisplayName(inst)
  if inst == nil or not inst:IsValid() then
    return nil
  end
  local ok, name = pcall(function()
    return inst:GetDisplayName()
  end)
  if ok and type(name) == "string" and name ~= "" then
    return "[" .. name .. "]"
  end
  return nil
end

BROADCASTS_GET_ENTITY_DISPLAY_NAME = GetEntityDisplayName
