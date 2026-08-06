--- 袭击预警：猎犬 / 洞穴蠕虫、巨鹿、熊獾倒计时多档播报。
--- 现实时间档位：8 / 4 / 2 / 1 分钟，以及 30 / 10 / 5 秒。
--- 猎犬/蠕虫按当前分片世界类型自动区分；巨鹿/熊獾仅森林。
--- 现身播报见 scripts/features/appear.lua；不写持久化，重载后阈值标记重置。

local S = i18n

--- 现实时间阈值（秒）。须与 i18n.durations 的键一致
local REAL_THRESHOLDS = { 480, 240, 120, 60, 30, 10, 5 }
local POLL_SECONDS = 1
local HOUNDED_ATTACK_POLL_SECONDS = 1
local DEERCLOPS_TIMER = "deerclops_timetoattack"
local BEARGER_TIMER = "bearger_timetospawn"

--- 现实时间阈值跨越：剩余秒数落入某档时，判断本 tick 新跨越了哪些阈值。
--- flags：已播标记；seconds > th 时清除以便回升后再播；新档由调用方播报成功后再写入。
--- @return number|nil lowest 应播报的最短新跨越阈值
--- @return number[] newly_crossed
local function CrossRealThresholds(seconds, thresholds, flags)
  local lowest = nil
  local newly_crossed = {}
  for _, th in ipairs(thresholds) do
    if seconds <= th then
      if not flags[th] then
        table.insert(newly_crossed, th)
        if lowest == nil or th < lowest then
          lowest = th
        end
      end
    else
      flags[th] = nil
    end
  end
  return lowest, newly_crossed
end

--- get_seconds: 剩余秒数；false=暂停（保留档位）；nil/<=0=无有效倒计时（清空档位）
--- get_name: 袭击显示名
local function WatchAttackWarning(get_seconds, get_name)
  if not core.IsServer() then
    return
  end

  local state = {
    real_flags = {},
    missing_duration = nil,
  }

  TheWorld:DoPeriodicTask(POLL_SECONDS, core.Wrap(function()
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

    local lowest, newly_crossed = CrossRealThresholds(t, REAL_THRESHOLDS, state.real_flags)
    if lowest == nil then
      return
    end

    local duration = S.durations[lowest]
    if type(duration) ~= "string" or duration == "" then
      if state.missing_duration ~= lowest then
        state.missing_duration = lowest
        core.Print("warning: missing durations[" .. tostring(lowest) .. "]")
      end
      return
    end

    for _, th in ipairs(newly_crossed) do
      state.real_flags[th] = true
    end
    state.missing_duration = nil
    core.Announce(string.format(S.attack_time, name, duration))
  end))
end

--- 猎犬 / 洞穴蠕虫
local function HoundedAttackName()
  if core.IsCaveWorld() then
    return S.bosses.depths_worms
  end
  return S.bosses.hounds
end

AddSimPostInit(core.Wrap(function()
  if not core.IsServer() then
    return
  end
  if TheWorld.components.hounded == nil then
    return
  end

  WatchAttackWarning(function()
    local hounded = TheWorld.components.hounded
    if hounded == nil or hounded:GetAttacking() then
      return nil
    end
    return hounded:GetTimeToAttack()
  end, HoundedAttackName)

  local was_attacking = nil
  TheWorld:DoPeriodicTask(HOUNDED_ATTACK_POLL_SECONDS, core.Wrap(function()
    local hounded = TheWorld.components.hounded
    if hounded == nil then
      return
    end
    local attacking = hounded:GetAttacking()
    if was_attacking == nil then
      was_attacking = attacking
      return
    end
    if attacking and not was_attacking then
      core.Announce(string.format(S.attack_started, HoundedAttackName()))
    end
    was_attacking = attacking
  end))
end))

--- 巨鹿 / 熊獾倒计时（仅森林；现身见 appear.lua）
AddSimPostInit(core.Wrap(function()
  if not core.IsServer() or core.IsCaveWorld() then
    return
  end
  if TheWorld.components.worldsettingstimer == nil then
    return
  end

  local bosses = {
    { name = S.bosses.deerclops, timer = DEERCLOPS_TIMER },
    { name = S.bosses.bearger, timer = BEARGER_TIMER },
  }

  for _, boss in ipairs(bosses) do
    local timer = boss.timer
    local name = boss.name
    WatchAttackWarning(function()
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
