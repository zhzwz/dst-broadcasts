--- 移除字符串首尾空白
--- @param value any
--- @return string
local function Trim(value)
  return (tostring(value):match("^%s*(.-)%s*$"))
end

mod.Trim = Trim
