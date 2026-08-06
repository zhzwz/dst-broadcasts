--- 巨鹿 / 熊獾：倒计时预警（现身见 features/appear）。

local C = BROADCASTS_ATTACK_WARNING

local BOSSES = {
  {
    name = i18n.bosses.deerclops,
    timer = C.DEERCLOPS_TIMER,
  },
  {
    name = i18n.bosses.bearger,
    timer = C.BEARGER_TIMER,
  },
}

AddSimPostInit(mod.Wrap("hassler_init", function()
  if not mod.World.IsServer() then
    return
  end
  if mod.World.IsCave() then
    return
  end
  if TheWorld.components.worldsettingstimer == nil then
    return
  end

  for _, boss in ipairs(BOSSES) do
    local timer = boss.timer
    local name = boss.name
    BROADCASTS_WATCH_ATTACK_WARNING(function()
      local wst = TheWorld.components.worldsettingstimer
      if wst == nil or not wst:ActiveTimerExists(timer) then
        return nil
      end
      if wst:IsPaused(timer) then
        return false
      end
      return wst:GetTimeLeft(timer)
    end, function()
      return name
    end)
  end
end))
