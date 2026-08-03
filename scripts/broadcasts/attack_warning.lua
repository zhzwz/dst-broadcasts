--[[
  袭击预警共用逻辑：
  - 游戏时间提前若干天
  - 现实时间多档阈值播报
]]

local S = BROADCASTS_STRINGS
local C = BROADCASTS_CONSTANTS
local Safe = BROADCASTS_SAFE

-- get_seconds: 返回剩余秒数；nil/<=0 表示当前没有有效倒计时
-- get_name: 返回袭击显示名
local function WatchAttackWarning(get_seconds, get_name)
  if not TheWorld.ismastersim then
    return
  end

  local state = {
    real_flags = {},
    last_day_key = nil,
  }

  TheWorld:DoPeriodicTask(C.ATTACK_WARNING_POLL_SECONDS, Safe.Wrap("attack_warning", function()
    local t = get_seconds()
    if type(t) ~= "number" or t ~= t or t <= 0 then
      state.real_flags = {}
      state.last_day_key = nil
      return
    end

    local name = get_name()
    if name == nil then
      return
    end

    local day_key = nil
    local days = math.ceil(t / TUNING.TOTAL_DAY_TIME)
    if days <= C.ATTACK_WARNING_ADVANCE_DAYS then
      local key = tostring(TheWorld.state.cycles) .. ":" .. tostring(days)
      if key ~= state.last_day_key then
        day_key = key
      end
    else
      -- 离开「提前 N 游戏日」窗口后再进入时，允许重新播报
      state.last_day_key = nil
    end

    local lowest = nil
    local newly_crossed = {}
    for _, th in ipairs(C.ATTACK_WARNING_REAL_THRESHOLDS) do
      if t <= th then
        if not state.real_flags[th] then
          newly_crossed[#newly_crossed + 1] = th
          if lowest == nil or th < lowest then
            lowest = th
          end
        end
      else
        state.real_flags[th] = nil
      end
    end

    -- 同一 tick 只播一条：优先更精确的现实时间档
    if lowest ~= nil then
      for _, th in ipairs(newly_crossed) do
        state.real_flags[th] = true
      end
      if day_key ~= nil then
        state.last_day_key = day_key
      end
      Safe.Announce(string.format(S.attack_time, name, S.durations[lowest]))
    elseif day_key ~= nil then
      state.last_day_key = day_key
      Safe.Announce(string.format(S.attack_day, name))
    end
  end))
end

BROADCASTS_WATCH_ATTACK_WARNING = WatchAttackWarning
