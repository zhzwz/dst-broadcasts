--- 日历：跨天公告永恒日与季节进度；≤5 天内临近换季 / 满月 / 新月时追加提醒。
--- 仅森林主机；洞穴不播。仅 cycles 恰 +1 时播报。
--- 季节与月相同时临近时，天数近的在前；相同则天数里季节优先。
---
--- 普通公告：
--- “永恒888日，秋季第1天。”
---
--- 月相变动小于等于5天时公告：
--- “永恒888日，秋季第8天，满月还有5天。”
--- “永恒888日，秋季第8天，满月还有4天。”
--- “永恒888日，秋季第8天，满月还有3天。”
--- “永恒888日，秋季第8天，后天满月。”
--- “永恒888日，秋季第8天，明天满月。”
--- 月相变动当天：
--- “永恒888日，秋季第8天，今夜满月。”
--- “永恒888日，秋季第8天，今夜新月。”
---
--- 季节变动小于等于5天时公告：
--- “永恒888日，秋季第8天，入冬还有5天。”
--- “永恒888日，秋季第8天，入冬还有4天。”
--- “永恒888日，秋季第8天，入冬还有3天。”
--- “永恒888日，秋季第8天，后天入冬。”
--- “永恒888日，秋季第8天，明天入冬。”
--- “永恒888日，冬季第1天。”
---
--- 同时存在季节和月相变动时，时间近的优先，时间一样优先季节：
--- “永恒888日，秋季第8天，入冬还有3天，新月还有4天。”
--- “永恒888日，秋季第8天，满月还有3天，入冬还有4天。”
--- “永恒888日，秋季第8天，入冬还有3天，新月还有3天。”

local WARN_DAYS = 5

local NEXT_SEASON = {
  autumn = "winter",
  winter = "spring",
  spring = "summer",
  summer = "autumn",
}

-- 月相：与原版 clock.lua 的 MOON_PHASE_CYCLES 一致。
-- 相位编号 1=new … 5=full；各相位持续天数见 LENGTHS。
-- 先按 new→quarter→half→threequarter→full 展开，再反向回落到 quarter（不含两端），
-- 得到长度 20 的日序列；下标即 `_mooomphasecycle`，用于推算距满月/新月还有几天。
local MOON_PHASE = { new = 1, full = 5 }
local MOON_PHASE_LENGTHS = { 1, 3, 3, 3, 1 }
local MOON_PHASE_CYCLES = {}
do
  for i = 1, #MOON_PHASE_LENGTHS do
    for _ = 1, MOON_PHASE_LENGTHS[i] do
      table.insert(MOON_PHASE_CYCLES, i)
    end
  end
  for i = #MOON_PHASE_LENGTHS - 1, 2, -1 do
    for _ = 1, MOON_PHASE_LENGTHS[i] do
      table.insert(MOON_PHASE_CYCLES, i)
    end
  end
end

local function DaysUntilMoonPhase(cycle, phase_id)
  local n = #MOON_PHASE_CYCLES
  for d = 0, n - 1 do
    local idx = ((cycle - 1 + d) % n) + 1
    if MOON_PHASE_CYCLES[idx] == phase_id then
      return d
    end
  end
  return nil
end

local function FormatMoonAlert(days, phase_key)
  local name = i18n.calendar_moon ~= nil and i18n.calendar_moon[phase_key] or nil
  if name == nil then return nil end
  if days == 0 then
    return string.format(i18n.calendar_moon_today, name)
  end
  if days == 1 then
    return string.format(i18n.calendar_moon_tomorrow, name)
  end
  if days == 2 then
    return string.format(i18n.calendar_moon_day_after, name)
  end
  return string.format(i18n.calendar_moon_days, name, days)
end

local function FormatSeasonAlert(days, next_key)
  local enter = i18n.calendar_enter ~= nil and i18n.calendar_enter[next_key] or nil
  if enter == nil then return nil end
  if days == 1 then
    return string.format(i18n.calendar_season_tomorrow, enter)
  end
  if days == 2 then
    return string.format(i18n.calendar_season_day_after, enter)
  end
  return string.format(i18n.calendar_season_days, enter, days)
end

local function BuildMoonAlert(cycle)
  if type(cycle) ~= "number" then return nil end
  local to_full = DaysUntilMoonPhase(cycle, MOON_PHASE.full)
  local to_new = DaysUntilMoonPhase(cycle, MOON_PHASE.new)
  if to_full == nil and to_new == nil then return nil end

  local days, phase_key
  if to_full ~= nil and to_full <= WARN_DAYS and (to_new == nil or to_full <= to_new) then
    days, phase_key = to_full, "full"
  elseif to_new ~= nil and to_new <= WARN_DAYS then
    days, phase_key = to_new, "new"
  else
    return nil
  end

  local text = FormatMoonAlert(days, phase_key)
  if text == nil then return nil end
  return { days = days, kind = "moon", text = text }
end

local function BuildSeasonAlert(remaining, next_key)
  if type(remaining) ~= "number" or remaining < 1 or remaining > WARN_DAYS then return nil end
  local text = FormatSeasonAlert(remaining, next_key)
  if text == nil then return nil end
  return { days = remaining, kind = "season", text = text }
end

local function AnnounceCalendar()
  -- 森林世界
  if not core.IsForestWorld() then return end

  local state = TheWorld.state
  if state == nil then return end

  local season = state.season
  local season_name = i18n.seasons ~= nil and i18n.seasons[season] or nil
  local next_key = NEXT_SEASON[season]
  if season_name == nil or next_key == nil then return end
  if type(i18n.calendar_base) ~= "string" or i18n.calendar_base == "" then return end

  local day = core.Integer(state.cycles, 0) + 1
  local day_in_season = core.Integer(state.elapseddaysinseason, 0) + 1
  local remaining = core.Integer(state.remainingdaysinseason, 0)

  local parts = { string.format(i18n.calendar_base, day, season_name, day_in_season) }

  local alerts = {}
  local season_alert = BuildSeasonAlert(remaining, next_key)
  if season_alert ~= nil then
    table.insert(alerts, season_alert)
  end

  local clock = core.GetClockComponent()
  if clock ~= nil then
    -- 月相周期下标（原版 clock 私有上值，拼写为三 o）
    local moon_alert = BuildMoonAlert(core.GetUpvalue(clock.GetDebugString, "_mooomphasecycle"))
    if moon_alert ~= nil then
      table.insert(alerts, moon_alert)
    end
  end

  -- 按天数排序，天数一样按类型排序，季节优先
  table.sort(alerts, function(a, b)
    if a.days ~= b.days then
      return a.days < b.days
    end
    return a.kind == "season" and b.kind ~= "season"
  end)

  for i = 1, #alerts do
    table.insert(parts, alerts[i].text)
  end

  core.Announce(table.concat(parts, i18n.symbol.comma) .. i18n.symbol.period)
end

core.WatchCycles(AnnounceCalendar)
