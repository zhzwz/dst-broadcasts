-- 使用 `TheNet:Announce` 发送系统消息
--- @param message string
local function Announce(message)
  if type(message) ~= "string" then
    return
  end

  local m = mod.Trim(message)
  if m == "" or TheNet == nil or type(TheNet.Announce) ~= "function" then
    return
  end

  mod.Call("mod.Announce", TheNet.Announce, TheNet, m)
end

mod.Announce = Announce
