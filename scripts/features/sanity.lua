--- 玩家理智

core.ListenPlayer("sanitydelta", function(player, data)
  if player:HasTag("playerghost") then return end

  local old = data.oldpercent
  local new = data.newpercent

  local messages = nil
  -- 阈值 50%、10%（一次跨过多档时取更低档）
  if new <= 0.1 and 0.1 < old then
    messages = i18n.player_low_sanity_10
  elseif new <= 0.5 and 0.5 < old then
    messages = i18n.player_low_sanity_50
  end
  if messages == nil then return end

  local line = core.RandomPick(messages)
  if line == nil then return end
  local name = core.GetDisplayName(player)
  if name == nil then return end
  core.Announce(string.format(line, name))

  local current = string.format("%.0f", player.components.sanity.current)
  local max = string.format("%.0f", player.components.sanity.max)
  local percent = string.format("%.2f", new * 100)
  core.PlayerBubble("SANITY: " .. current .. "/" .. max .. " (" .. percent .. "%)", player)
end)
