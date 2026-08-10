--- 按名读取函数闭包上值（`debug.getupvalue`）。
--- @param fn function|nil
--- @param name string 上值名
--- @return unknown|nil
core.GetUpvalue = function(fn, name)
  if type(fn) ~= "function" then
    core.Print(string.format("GetUpvalue: fn is not a function (name=%s)", tostring(name)))
    return nil
  end
  if type(name) ~= "string" or name == "" then
    core.Print(string.format("GetUpvalue: invalid name (%s)", tostring(name)))
    return nil
  end

  local i = 1
  while true do
    local upname, value = debug.getupvalue(fn, i)
    if upname == nil then
      core.Print(string.format("GetUpvalue: upvalue not found (name=%s)", name))
      return nil
    end
    if upname == name then
      return value
    end
    i = i + 1
  end
end
