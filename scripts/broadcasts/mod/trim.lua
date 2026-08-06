--- 移除首尾空白。
--- `string` / `number` / `boolean` 会先转为字符串再处理；其余类型返回 `""`。
--- @param value string|number|boolean|nil
--- @return string
local function Trim(value)
  local t = type(value)
  if t == "number" or t == "boolean" then
    value = tostring(value)
    t = "string"
  end
  if t ~= "string" then
    return ""
  end
  return (value:match("^%s*(.-)%s*$"))
end

mod.Trim = Trim
