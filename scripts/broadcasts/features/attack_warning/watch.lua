--[[
  袭击预警共用倒计时：现实时间多档阈值播报。
]]

local S = i18n
local C = BROADCASTS_ATTACK_WARNING
local Cross = BROADCASTS_CROSS_REAL_THRESHOLDS

-- get_seconds: 返回剩余秒数；false 表示暂停（保留已播档位）；nil/<=0 表示无有效倒计时（清空档位）
-- get_name: 返回袭击显示名
local function WatchAttackWarning(get_seconds, get_name)
  if not mod.World.IsServer() then
    return
  end

  local state = {
    real_flags = {},
    missing_duration = nil,
  }

  TheWorld:DoPeriodicTask(C.POLL_SECONDS, mod.Wrap("attack_warning", function()
    local t = get_seconds()
    if t == false then
      return
    end
    if type(t) ~= "number" or t ~= t or t <= 0 then
      state.real_flags = {}
      state.missing_duration = nil
      return
    end

    local name = get_name()
    if name == nil then
      return
    end

    local lowest, newly_crossed = Cross(t, C.REAL_THRESHOLDS, state.real_flags)
    if lowest == nil then
      return
    end

    local duration = S.durations[lowest]
    if type(duration) ~= "string" or duration == "" then
      if state.missing_duration ~= lowest then
        state.missing_duration = lowest
        print(string.format(
          "%s attack_warning: missing durations[%s]",
          mod.CONSTANTS.LOG_PREFIX,
          tostring(lowest)
        ))
      end
      return
    end

    for _, th in ipairs(newly_crossed) do
      state.real_flags[th] = true
    end
    state.missing_duration = nil
    mod.Announce(string.format(S.attack_time, name, duration))
  end))
end

BROADCASTS_WATCH_ATTACK_WARNING = WatchAttackWarning
