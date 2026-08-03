--[[
  距过冷 / 过热伤害阈值还有 TEMPERATURE_WARN_OFFSET 度时全服预警。
  默认：过冷伤害 0° → 在 ≤5° 预警；过热伤害 70° → 在 ≥65° 预警。
]]

modimport("scripts/broadcasts/lib/pick_message.lua")
modimport("scripts/broadcasts/shared/get_player_display_name.lua")
modimport("scripts/broadcasts/shared/get_character_announce_line.lua")

local S = BROADCASTS_STRINGS
local C = BROADCASTS_PLAYER_VITALS
local Safe = BROADCASTS_SAFE
local PickMessage = BROADCASTS_PICK_MESSAGE
local PlayerName = BROADCASTS_GET_PLAYER_DISPLAY_NAME
local CharacterQuote = BROADCASTS_GET_QUOTED_CHARACTER_ANNOUNCE_LINE

local ANNOUNCE_KEYS = {
  cold = "ANNOUNCE_COLD",
  hot = "ANNOUNCE_HOT",
}

local FREEZE_FLAG = "_dst_broadcasts_temp_freeze_warned"
local OVERHEAT_FLAG = "_dst_broadcasts_temp_overheat_warned"

local function GetTemperature(player)
  local temperature = player.components ~= nil and player.components.temperature or nil
  if temperature == nil then
    return nil
  end
  if temperature.GetCurrent ~= nil then
    local ok, value = pcall(function()
      return temperature:GetCurrent()
    end)
    if ok and type(value) == "number" and value == value then
      return value
    end
  end
  if type(temperature.current) == "number" and temperature.current == temperature.current then
    return temperature.current
  end
  return nil
end

local function GetFreezeDamageTemp()
  local value = C.TEMPERATURE_FREEZE_DAMAGE
  if type(value) == "number" and value == value then
    return value
  end
  return 0
end

local function GetOverheatDamageTemp(player)
  local temperature = player.components ~= nil and player.components.temperature or nil
  if temperature ~= nil and type(temperature.overheattemp) == "number" and temperature.overheattemp == temperature.overheattemp then
    return temperature.overheattemp
  end
  if type(TUNING) == "table" and type(TUNING.OVERHEAT_TEMP) == "number" and TUNING.OVERHEAT_TEMP == TUNING.OVERHEAT_TEMP then
    return TUNING.OVERHEAT_TEMP
  end
  local value = C.TEMPERATURE_OVERHEAT_DAMAGE
  if type(value) == "number" and value == value then
    return value
  end
  return 70
end

local function GetWarnOffset()
  local value = C.TEMPERATURE_WARN_OFFSET
  if type(value) == "number" and value == value and value > 0 then
    return value
  end
  return 5
end

local function AnnounceTemperature(player, key)
  local messages = type(S.player_temperature) == "table" and S.player_temperature[key] or nil
  local template = PickMessage(messages)
  if template == nil then
    return
  end
  local message = string.format(template, PlayerName(player))
  local quote = CharacterQuote(player, ANNOUNCE_KEYS[key])
  if type(quote) == "string" and quote ~= "" then
    message = message .. quote
  end
  Safe.Announce(message)
end

-- allow_announce=false 时只同步 flags（进服对齐）
local function CheckTemperature(player, current, last, allow_announce)
  if player == nil or not player:IsValid() then
    return
  end
  if player:HasTag("playerghost") then
    player[FREEZE_FLAG] = nil
    player[OVERHEAT_FLAG] = nil
    return
  end
  if type(current) ~= "number" or current ~= current then
    return
  end

  local offset = GetWarnOffset()
  local freeze_warn = GetFreezeDamageTemp() + offset
  local overheat_warn = GetOverheatDamageTemp(player) - offset

  local cooling = type(last) ~= "number" or last ~= last or current < last
  local heating = type(last) ~= "number" or last ~= last or current > last

  if current <= freeze_warn then
    if not player[FREEZE_FLAG] then
      player[FREEZE_FLAG] = true
      if allow_announce and cooling then
        AnnounceTemperature(player, "cold")
      end
    end
  else
    player[FREEZE_FLAG] = nil
  end

  if current >= overheat_warn then
    if not player[OVERHEAT_FLAG] then
      player[OVERHEAT_FLAG] = true
      if allow_announce and heating then
        AnnounceTemperature(player, "hot")
      end
    end
  else
    player[OVERHEAT_FLAG] = nil
  end
end

local function OnTemperatureDelta(player, data)
  local current = (data and type(data.new) == "number" and data.new) or GetTemperature(player)
  if current == nil then
    return
  end
  local last = data and data.last
  CheckTemperature(player, current, last, true)
end

local function SyncFlags(player)
  local current = GetTemperature(player)
  if current ~= nil then
    CheckTemperature(player, current, nil, false)
  end
end

local function WatchPlayer(player)
  if player == nil or not player:IsValid() then
    return
  end
  if player._dst_broadcasts_temperature_watching then
    return
  end
  player._dst_broadcasts_temperature_watching = true

  player:ListenForEvent("temperaturedelta", Safe.Wrap("player_temp_delta", OnTemperatureDelta))
  Safe.Call("player_temp_sync", SyncFlags, player)
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
