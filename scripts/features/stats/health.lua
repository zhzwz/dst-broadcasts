--- 玩家生命值
--- 过线 20%/10% 时公告。

core.ListenPlayer("healthdelta", function(player, data)
  -- 取显示名；拿不到则不公告
  local name = core.GetDisplayName(player)
  if name == nil then return end

  -- 玩家
  if not player:HasTag("player") then return end
  -- 非幽灵
  if player:HasTag("playerghost") then return end

  local old = data.oldpercent
  local new = data.newpercent
  local health = player.components.health

  -- 阈值 20%、10%
  if (new <= 0.1 and 0.1 < old) or (new <= 0.2 and 0.2 < old) then
    local current = string.format("%.0f", health.currenthealth)
    local max = string.format("%.0f", health.maxhealth)
    local percent = string.format("%.2f", new * 100)
    DST_SERVER_SEND(string.format("[%s] HEALTH: %s/%s (%s%%)", name, current, max, percent))
  end
end)
