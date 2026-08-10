--- 玩家潮湿度
--- 上穿 20/40/60/80 时公告；一次跨多档取最高档，附带角色台词。

core.ListenPlayer("moisturedelta", function(player, data)
  -- 取显示名；拿不到则不公告
  local name = core.GetDisplayName(player)
  if name == nil then return end

  -- 玩家
  if not player:HasTag("player") then return end
  -- 非幽灵
  if player:HasTag("playerghost") then return end

  local old = data.old
  local new = data.new

  -- 阈值 20 / 40 / 60 / 80（一次跨过多档时取最高档）
  local announce_key = nil
  if new >= 80 and 80 > old then
    announce_key = "ANNOUNCE_SOAKED"
  elseif new >= 60 and 60 > old then
    announce_key = "ANNOUNCE_WETTER"
  elseif new >= 40 and 40 > old then
    announce_key = "ANNOUNCE_WET"
  elseif new >= 20 and 20 > old then
    announce_key = "ANNOUNCE_DAMP"
  end
  if announce_key == nil then return end

  core.Announce(string.format("[%s] MOISTURE: %.0f", name, new))

  -- 角色特殊发言
  local line = core.GetAnnounceLine(announce_key, player)
  if line == nil then return end
  core.Announce(name .. i18n.symbol.colon .. line)
end)
