--- 获取预制体的显示名称（查不到时回退为预制体字符串）
--- @param prefab string|nil prefab 名（如 "deerclops"）
--- @return string|nil
local function GetDisplayName(prefab)
  if type(prefab) ~= "string" or prefab == "" then
    return nil
  end
  local display = mod.Call("mod.Prefab.GetDisplayName", function()
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

mod.Prefab = {
  GetDisplayName = GetDisplayName,
}
