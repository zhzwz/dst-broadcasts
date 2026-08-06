--- 读取玩家的显示名称（失败返回 `?`）
--- @param player Entity|nil
--- @return string
local function GetDisplayName(player)
  return mod.Entity.GetDisplayName(player) or "?"
end

--- 玩家气泡说话
--- @param player Entity|nil
--- @param message string
local function Say(player, message)
  if not mod.Entity.HasTag(player, "player") then
    return
  end
  --- @cast player Entity
  local talker = player.components and player.components.talker
  if talker == nil or type(talker.Say) ~= "function" then
    return
  end
  local m = mod.Trim(message)
  if m == "" then
    return
  end
  local time = nil          --- nil：游戏默认时长
  local noanim = true       --- true：不播说话动画
  local force = true        --- true：忽略死亡/睡眠
  local nobroadcast = false --- false：网络同步，附近客户端也能看到头顶气泡
  mod.Call("mod.Player.Say", talker.Say, talker, m, time, noanim, force, nobroadcast)
end

mod.Player = {
  GetDisplayName = GetDisplayName,
  Say = Say,
}
