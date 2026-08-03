--[[
  玩家饱食度 / 理智降至阈值时全服播报；回升越过阈值后可再次触发。
]]

local S = BROADCASTS_STRINGS
local C = BROADCASTS_CONSTANTS
local Safe = BROADCASTS_SAFE

local function CheckStat(player, component_name, flag_key, message, allow_announce)
  if player == nil or not player:IsValid() then
    return
  end
  if player:HasTag("playerghost") then
    player[flag_key] = nil
    return
  end

  local components = player.components
  if components == nil then
    return
  end

  local component = components[component_name]
  if component == nil then
    return
  end

  local current = component.current
  if type(current) ~= "number" or current ~= current then
    return
  end

  local thresholds = C.PLAYER_STAT_LOW_THRESHOLDS
  if type(thresholds) ~= "table" then
    return
  end

  local flags = player[flag_key]
  if type(flags) ~= "table" then
    flags = {}
    player[flag_key] = flags
  end

  local should_announce = false
  for _, threshold in ipairs(thresholds) do
    if type(threshold) == "number" and current <= threshold then
      if not flags[threshold] then
        flags[threshold] = true
        should_announce = true
      end
    elseif type(threshold) == "number" then
      flags[threshold] = nil
    end
  end

  if not allow_announce or not should_announce or type(message) ~= "string" then
    return
  end

  local value = math.floor(current + 0.5)
  if value < 0 then
    value = 0
  end

  local name = "?"
  local ok, display_name = pcall(function()
    return player:GetDisplayName()
  end)
  if ok and type(display_name) == "string" and display_name ~= "" then
    name = display_name
  end

  Safe.Announce(string.format(message, name, value))
end

local function OnHungerDelta(player)
  CheckStat(player, "hunger", "_dst_broadcasts_low_hunger", S.player_low_hunger, true)
end

local function OnSanityDelta(player)
  CheckStat(player, "sanity", "_dst_broadcasts_low_sanity", S.player_low_sanity, true)
end

local function SyncVitalsFlags(player)
  CheckStat(player, "hunger", "_dst_broadcasts_low_hunger", S.player_low_hunger, false)
  CheckStat(player, "sanity", "_dst_broadcasts_low_sanity", S.player_low_sanity, false)
end

local function WatchPlayer(player)
  if player == nil or not player:IsValid() then
    return
  end
  if player._dst_broadcasts_vitals_watching then
    return
  end
  player._dst_broadcasts_vitals_watching = true

  player:ListenForEvent("hungerdelta", Safe.Wrap("player_vitals_hunger", OnHungerDelta))
  player:ListenForEvent("sanitydelta", Safe.Wrap("player_vitals_sanity", OnSanityDelta))

  Safe.Call("player_vitals_sync", SyncVitalsFlags, player)
end

AddPlayerPostInit(Safe.Wrap("player_vitals_init", function(player)
  if TheWorld == nil or not TheWorld.ismastersim then
    return
  end
  player:DoTaskInTime(0, Safe.Wrap("player_vitals_watch", function()
    if player:IsValid() then
      WatchPlayer(player)
    end
  end))
end))
