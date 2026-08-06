--- 全服广播消息
--- `TheNet:Announce(message)` 是游戏引擎的网络层函数。
--- 它会将消息直接打包发送给当前服务器群组的所有客户端。
--- 因为森林和洞穴本质上是通过 Shard 通信的连通整体，所以两边的玩家都能立刻在左下角公屏看到。
--- @param message string
local function Announce(message)
  local m = mod.Trim(message)
  if m == "" or TheNet == nil or type(TheNet.Announce) ~= "function" then
    return
  end

  mod.Call("mod.Announce", TheNet.Announce, TheNet, m)
end

mod.Announce = Announce
