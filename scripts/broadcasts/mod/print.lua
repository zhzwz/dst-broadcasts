local function Print(tag, err)
  local p = mod.CONSTANTS.LOG_PREFIX
  local t = tostring(tag or "?")
  local e = tostring(err)
  local m = string.format("%s %s: %s", p, t, e)
  print(m)
end

mod.Print = Print
