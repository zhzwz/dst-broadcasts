--- 获取预制体显示名称（查 STRINGS.NAMES；查不到时回退为 prefab）。
--- @param prefab string|nil 非空 prefab 名（如 "deerclops"）；否则返回 nil
--- @return string|nil
core.GetPrefabDisplayName = function(prefab)
  if type(prefab) ~= "string" or prefab == "" then
    return nil
  end
  local display = core.Call(function()
    local names = STRINGS and STRINGS.NAMES
    if type(names) ~= "table" then
      return nil
    end
    local name = names[string.upper(prefab)]
    if type(name) == "string" and name ~= "" then
      return name
    end
  end)
  if type(display) == "string" and display ~= "" then
    return display
  end
  return prefab
end
