--[[
  玩家生命 ≤10% 时全服播报实际数值；仅在下降时播报，回升后可再次触发。
]]

local S = i18n
local C = BROADCASTS_PLAYER_VITALS
local PlayerName = mod.Player.GetDisplayName

local function CheckHealth(player, percent, allow_announce)
  if player == nil or not player:IsValid() then
    return
  end
  if player:HasTag("playerghost") then
    player._dst_broadcasts_low_health = nil
    return
  end
  if type(percent) ~= "number" or percent ~= percent then
    return
  end

  local thresholds = C.HEALTH_LOW_THRESHOLDS
  if type(thresholds) ~= "table" then
    return
  end

  local flags = player._dst_broadcasts_low_health
  if type(flags) ~= "table" then
    flags = {}
    player._dst_broadcasts_low_health = flags
  end

  local should_announce = false
  for _, threshold in ipairs(thresholds) do
    if type(threshold) == "number" and percent <= threshold then
      if not flags[threshold] then
        flags[threshold] = true
        should_announce = true
      end
    elseif type(threshold) == "number" then
      flags[threshold] = nil
    end
  end

  if not allow_announce or not should_announce then
    return
  end
  if type(S.player_low_health) ~= "string" then
    return
  end

  local health = player.components and player.components.health
  if health == nil then
    return
  end

  local current = health.current
  local max_health = nil
  local ok_max, max_value = pcall(function()
    if health.GetMaxWithPenalty ~= nil then
      return health:GetMaxWithPenalty()
    end
    return health:GetMax()
  end)
  if ok_max and type(max_value) == "number" and max_value == max_value then
    max_health = max_value
  elseif type(health.maxhealth) == "number" then
    max_health = health.maxhealth
  end

  if type(current) ~= "number" or current ~= current or type(max_health) ~= "number" then
    return
  end

  local current_display = math.floor(current + 0.5)
  if current_display < 0 then
    current_display = 0
  end
  local max_display = math.floor(max_health + 0.5)
  if max_display < 1 then
    max_display = 1
  end

  mod.Announce(string.format(
    S.player_low_health,
    PlayerName(player),
    current_display,
    max_display
  ))
end

local function GetHealthPercent(player)
  local components = player.components
  if components == nil or components.health == nil then
    return nil
  end
  local ok, percent = pcall(function()
    return components.health:GetPercent()
  end)
  if ok and type(percent) == "number" and percent == percent then
    return percent
  end
  return nil
end

local function OnHealthDelta(player, data)
  local percent = (data and type(data.newpercent) == "number" and data.newpercent) or GetHealthPercent(player)
  if percent == nil then
    return
  end

  local oldpercent = data and data.oldpercent
  -- 旧值缺失时与 sanity 一致：按下降处理，避免漏播
  local decreasing = type(oldpercent) ~= "number"
      or oldpercent ~= oldpercent
      or percent < oldpercent

  CheckHealth(player, percent, decreasing)
end

local function SyncHealthFlags(player)
  local percent = GetHealthPercent(player)
  if percent ~= nil then
    CheckHealth(player, percent, false)
  end
end

local function WatchPlayer(player)
  if player == nil or not player:IsValid() then
    return
  end
  if player._dst_broadcasts_health_watching then
    return
  end
  player._dst_broadcasts_health_watching = true

  player:ListenForEvent("healthdelta", mod.Wrap("player_health_delta", OnHealthDelta))
  mod.Call("player_health_sync", SyncHealthFlags, player)
end

AddPlayerPostInit(mod.Wrap("player_health_setup", function(player)
  if not mod.World.IsMaster() then
    return
  end
  player:DoTaskInTime(0, mod.Wrap("player_health_watch", function()
    if player:IsValid() then
      WatchPlayer(player)
    end
  end))
end))
