--- 将 { [display_name] = amount } 格式化为排序后的「名称×数量」列表。
--- @param counts table|nil
--- @return string|nil 全空时为 nil
core.FormatEntryCountList = function(counts)
  if type(counts) ~= "table" then
    return nil
  end
  local list = {}
  for name, n in pairs(counts) do
    local entry = core.FormatEntryCount(name, n)
    if entry ~= nil then
      table.insert(list, { name = name, n = n, text = entry })
    end
  end
  if #list == 0 then
    return nil
  end
  table.sort(list, function(a, b)
    if a.name == b.name then
      return a.n < b.n
    end
    return a.name < b.name
  end)
  local parts = {}
  for _, item in ipairs(list) do
    table.insert(parts, item.text)
  end
  --- 分隔符取 i18n.symbol.enumeration
  return table.concat(parts, i18n.symbol.enumeration)
end
