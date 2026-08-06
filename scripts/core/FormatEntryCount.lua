--- 格式化为「名称×数量」；名称无效或数量 ≤0 时返回 nil。
--- @param name string|nil
--- @param n number|nil
--- @return string|nil
core.FormatEntryCount = function(name, n)
  if type(name) ~= "string" or name == "" then
    return nil
  end
  if type(n) ~= "number" or n ~= n or n <= 0 then
    return nil
  end
  return string.format("%s×%d", name, math.floor(n))
end
