--- 玩家体温
--- 跌破 0 或升破过热阈值时公告；附带角色台词。

core.ListenPlayer("temperaturedelta", function(player, data)
  -- 取显示名；拿不到则不公告
  local name = core.GetDisplayName(player)
  if name == nil then return end

  -- 玩家
  if not player:HasTag("player") then return end
  -- 非幽灵
  if player:HasTag("playerghost") then return end

  local old = data.last
  local new = data.new
  local temperature = player.components.temperature
  local overheat = temperature.overheattemp

  -- 过冷：跌破 0
  if new < 0 and 0 <= old then
    DST_SERVER_SEND(string.format("[%s] COLD: %.0f", name, new))

    -- 角色特殊发言
    local line = core.GetAnnounceLine("ANNOUNCE_COLD", player)
    if line == nil then return end
    DST_SERVER_SEND(name .. i18n.symbol.colon .. line)
  end

  -- 过热：升破 overheattemp（默认 70）
  if new > overheat and overheat >= old then
    DST_SERVER_SEND(string.format("[%s] HOT: %.0f", name, new))

    -- 角色特殊发言
    local line = core.GetAnnounceLine("ANNOUNCE_HOT", player)
    if line == nil then return end
    DST_SERVER_SEND(name .. i18n.symbol.colon .. line)
  end
end)
