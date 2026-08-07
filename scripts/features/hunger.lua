--- 玩家饱食度

core.ListenPlayer("hungerdelta", function(player, data)
  if player:HasTag("playerghost") then
    return
  end
  --- 不需要写很多防御代码，出现错误时最多不执行
  local old = data.oldpercent
  local new = data.newpercent
  -- 阈值 20%、10%、0%
  if (new <= 0.2 and 0.2 < old) or (new <= 0.1 and 0.1 < old) or (new <= 0 and 0 < old) then
    local line = core.GetAnnounceLine("ANNOUNCE_HUNGRY", player)
    local name = core.GetDisplayName(player) or "?"
    core.Announce(name .. i18n.symbol.colon .. line)
    local current = player.components.hunger.current
    local max = player.components.hunger.max
    core.PlayerBubble("HUNGRY: " .. current .. "/" .. max, player)
  end
end)
