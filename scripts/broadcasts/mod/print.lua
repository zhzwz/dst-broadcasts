--- 打印日志
--- @param tag string|number|boolean|nil 日志标签
--- @param content any 日志内容
local function Print(tag, content)
  local prefix = mod.CONSTANTS.LOG_PREFIX
  local tag_text = mod.Trim(tag or "?")
  --- content 可能是任意值：先 tostring，再交给 Trim 去空白
  local content_text = mod.Trim(tostring(content))
  print(string.format("%s %s: %s", prefix, tag_text, content_text))
end

mod.Print = Print
