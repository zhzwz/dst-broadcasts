--- 袭击预警共用：现实时间档位过线轮询。
--- 档位：8 / 4 / 2 / 1 分钟，以及 30 / 10 / 5 秒（须与 i18n.durations 键一致）。
--- 不写持久化；重载后 cache 重置。

local THRESHOLDS = { 480, 240, 120, 60, 30, 10, 5 }
local HUGE = math.huge
local cache = { deerclops = HUGE, bearger = HUGE }

core.ATTACK_WARNING_POLL_SECONDS = 1

--- get_seconds: 剩余秒数；false=暂停（保留 cache）；nil/<=0=重置为 HUGE
core.WatchAttackWarning = function(key, get_seconds)
  if not core.World.IsServerSide() then return end
  core.SetInterval(TheWorld, function()
    local new = get_seconds()
    if new == false then return end
    if type(new) ~= "number" or new ~= new or new <= 0 then
      cache[key] = HUGE
      return
    end

    local name = core.GetPrefabDisplayName(key)
    if name == nil then return end

    local old = cache[key]
    cache[key] = new

    --- 越过的最低档（一次跳多档只公告最短那档）
    local crossed = nil
    for _, d in ipairs(THRESHOLDS) do
      if new <= d and d < old then
        if crossed == nil or d < crossed then
          crossed = d
        end
      end
    end
    if crossed == nil then return end

    local duration = i18n.durations[crossed]
    if type(duration) ~= "string" or duration == "" then
      core.Print("warning: missing durations[" .. tostring(crossed) .. "]")
      return
    end

    core.Announce(string.format(i18n.attack_time, name, duration))
  end, core.ATTACK_WARNING_POLL_SECONDS)
end

--- 世界设置定时器倒计时（巨鹿 / 熊獾等）
core.WatchWorldSettingsTimer = function(key, timer)
  core.WatchAttackWarning(key, function()
    local wst = TheWorld.components.worldsettingstimer
    if wst == nil or not wst:ActiveTimerExists(timer) then return nil end
    if wst:IsPaused(timer) then return false end
    return wst:GetTimeLeft(timer)
  end)
end
