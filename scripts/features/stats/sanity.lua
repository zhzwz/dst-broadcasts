--- 玩家理智 / 启蒙
--- 理智模式过线 20%/10%，或启蒙模式上穿约 85% 时公告。

core.ListenPlayer("sanitydelta", function(player, data)
  -- 取显示名；拿不到则不公告
  local name = core.GetDisplayName(player)
  if name == nil then return end

  -- 玩家
  if not player:HasTag("player") then return end
  -- 非幽灵
  if player:HasTag("playerghost") then return end

  local old = data.oldpercent
  local new = data.newpercent
  local sanity = player.components.sanity

  -- 理智模式：百分比过低（阈值 20%、10%）
  if sanity:IsInsanityMode() then
    if (new <= 0.1 and 0.1 < old) or (new <= 0.2 and 0.2 < old) then
      local current = string.format("%.0f", sanity.current)
      local max = string.format("%.0f", sanity.max)
      local percent = string.format("%.2f", new * 100)
      core.Announce(string.format("[%s] INSANITY: %s/%s (%s%%)", name, current, max, percent))
    end
  end

  -- 启蒙模式：百分比过高（约 85%）
  if sanity:IsLunacyMode() then
    if new >= 0.85 and 0.85 > old then
      local current = string.format("%.0f", sanity.current)
      local max = string.format("%.0f", sanity.max)
      local percent = string.format("%.2f", new * 100)
      core.Announce(string.format("[%s] ENLIGHTENMENT: %s/%s (%s%%)", name, current, max, percent))
    end
  end
end)
