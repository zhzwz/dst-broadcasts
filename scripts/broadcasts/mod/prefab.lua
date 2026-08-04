-- 由 prefab 查 STRINGS.NAMES 显示名；查不到时回退为 prefab 本身
-- @param prefab string|nil prefab 名（如 "deerclops"）
-- @return string|nil 例如 "巨鹿"；无效输入时为 nil
local function GetDisplayName(prefab)
  if type(prefab) ~= "string" or prefab == "" then
    return nil
  end
  local names = STRINGS and STRINGS.NAMES
  if type(names) == "table" then
    local display = names[string.upper(prefab)]
    if type(display) == "string" and display ~= "" then
      return display
    end
  end
  return prefab
end

mod.Prefab = {
  GetDisplayName = GetDisplayName,
}
