-- 使用 `TheNet:Announce` 发送系统消息。
-- 在任一主控分片调用即可：森林与洞穴的玩家都能看到播报（全服可见，无需再向其它分片转发）。
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
