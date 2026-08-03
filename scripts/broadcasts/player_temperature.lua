--[[
  玩家开始过冷 / 过热时全服播报。
]]

local S = BROADCASTS_STRINGS
local Safe = BROADCASTS_SAFE

local function PlayerName(player)
  local ok, display_name = pcall(function()
    return player:GetDisplayName()
  end)
  if ok and type(display_name) == "string" and display_name ~= "" then
    return display_name
  end
  return "?"
end

local function AnnounceTemperature(player, message)
  if player == nil or not player:IsValid() then
    return
  end
  if player:HasTag("playerghost") then
    return
  end
  if type(message) ~= "string" or message == "" then
    return
  end
  Safe.Announce(string.format(message, PlayerName(player)))
end

local function OnStartFreezing(player)
  AnnounceTemperature(player, S.player_start_freezing)
end

local function OnStartOverheating(player)
  AnnounceTemperature(player, S.player_start_overheating)
end

local function WatchPlayer(player)
  if player == nil or not player:IsValid() then
    return
  end
  if player._dst_broadcasts_temperature_watching then
    return
  end
  player._dst_broadcasts_temperature_watching = true

  player:ListenForEvent("startfreezing", Safe.Wrap("player_temp_freeze", OnStartFreezing))
  player:ListenForEvent("startoverheating", Safe.Wrap("player_temp_overheat", OnStartOverheating))
end

AddPlayerPostInit(Safe.Wrap("player_temperature_init", function(player)
  if TheWorld == nil or not TheWorld.ismastersim then
    return
  end
  player:DoTaskInTime(0, Safe.Wrap("player_temperature_watch", function()
    if player:IsValid() then
      WatchPlayer(player)
    end
  end))
end))
