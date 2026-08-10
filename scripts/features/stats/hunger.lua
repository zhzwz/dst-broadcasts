--- 玩家饱食度
--- 过线 20%/10% 时公告；附带角色饥饿台词。

core.ListenPlayer("hungerdelta", function(player, data)
  -- 取显示名；拿不到则不公告
  local name = core.GetDisplayName(player)
  if name == nil then return end

  -- 玩家
  if not player:HasTag("player") then return end
  -- 非幽灵
  if player:HasTag("playerghost") then return end

  local old = data.oldpercent
  local new = data.newpercent
  local hunger = player.components.hunger

  -- 阈值 20%、10%
  if (new <= 0.1 and 0.1 < old) or (new <= 0.2 and 0.2 < old) then
    local current = string.format("%.0f", hunger.current)
    local max = string.format("%.0f", hunger.max)
    local percent = string.format("%.2f", new * 100)
    core.Announce(string.format("[%s] HUNGER: %s/%s (%s%%)", name, current, max, percent))

    -- 角色特殊发言
    local line = core.GetAnnounceLine("ANNOUNCE_HUNGRY", player)
    if line == nil then return end
    core.Announce(name .. i18n.symbol.colon .. line)
  end
end)
