--- 玩家头顶气泡发言（「吹泡泡」；网络同步，附近客户端可见）。
--- 参数顺序与 core.Announce 一致：内容在前，发言人在后。
--- @param message string 发言内容
--- @param player Entity|nil 发言玩家
core.PlayerBubble = function(message, player)
  local m = core.TrimString(message)
  if m == nil or m == "" then
    return
  end
  if not core.HasTag(player, "player") then
    return
  end
  --- @cast player Entity
  local talker = player.components and player.components.talker
  if talker == nil or type(talker.Say) ~= "function" then
    return
  end
  local time = nil          --- nil：游戏默认时长
  local noanim = true       --- true：不播说话动画
  local force = true        --- true：忽略死亡/睡眠
  local nobroadcast = false --- false：网络同步，附近客户端也能看到头顶气泡
  core.Call(talker.Say, talker, m, time, noanim, force, nobroadcast)
end
