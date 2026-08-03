--[[
  由 prefab 字符串查游戏 STRINGS.NAMES，返回带方括号的显示名。

  依赖全局 STRINGS（DST 命名表）。查不到或表不可用时回退为 [prefab]。

  @param prefab string prefab 名（如 "deerclops"）
  @return string|nil 例如 "[巨鹿]"；prefab 无效时为 nil
]]

local function GetPrefabDisplayName(prefab)
  if type(prefab) ~= "string" or prefab == "" then
    return nil
  end
  local names = STRINGS and STRINGS.NAMES
  local display = type(names) == "table" and names[string.upper(prefab)] or nil
  if type(display) == "string" and display ~= "" then
    return "[" .. display .. "]"
  end
  return "[" .. prefab .. "]"
end

BROADCASTS_GET_PREFAB_DISPLAY_NAME = GetPrefabDisplayName
