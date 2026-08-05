--- 打印日志
--- @param tag string 日志标签
--- @param content any 日志内容
local function Print(tag, content)
  local log = string.format(
    "%s %s: %s",
    mod.CONSTANTS.LOG_PREFIX,
    mod.Trim(tag or "?"),
    mod.Trim(content)
  )
  print(log)
end

mod.Print = Print
