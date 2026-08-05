--[[
  玩家湿度 10/20/40/60/80 分档播报：模组短句 + 角色内置潮湿台词。
]]

local S = i18n
local C = BROADCASTS_PLAYER_VITALS
local PlayerName = mod.Player.GetDisplayName
local CharacterQuote = mod.Character.GetQuotedAnnounceLine

local FLAG = "_dst_broadcasts_moisture_tiers"

local function GetMoistureValue(player)
  local moisture = player.components ~= nil and player.components.moisture or nil
  if moisture == nil then
    return nil
  end
  if moisture.GetMoisture ~= nil then
    local ok, value = pcall(function()
      return moisture:GetMoisture()
    end)
    if ok and type(value) == "number" and value == value then
      return value
    end
  end
  if type(moisture.moisture) == "number" and moisture.moisture == moisture.moisture then
    return moisture.moisture
  end
  return nil
end

local function AnnounceTier(player, threshold, announce_key)
  local messages = S.player_moisture
  local prefix = type(messages) == "table" and messages[threshold] or nil
  if type(prefix) ~= "string" or prefix == "" then
    return
  end
  local message = string.format(prefix, PlayerName(player))
  local quote = CharacterQuote(player, announce_key)
  if type(quote) == "string" and quote ~= "" then
    message = message .. quote
  end
  mod.Announce(message)
end

-- allow_announce=false 时只同步 flags（进服对齐）
local function CheckMoisture(player, value, allow_announce)
  if player == nil or not player:IsValid() then
    return
  end
  if player:HasTag("playerghost") then
    player[FLAG] = nil
    return
  end
  if type(value) ~= "number" or value ~= value then
    return
  end

  local tiers = C.MOISTURE_TIERS
  if type(tiers) ~= "table" then
    return
  end

  local flags = player[FLAG]
  if type(flags) ~= "table" then
    flags = {}
    player[FLAG] = flags
  end

  for _, tier in ipairs(tiers) do
    local threshold = tier.threshold
    if type(threshold) == "number" then
      if value >= threshold then
        if not flags[threshold] then
          flags[threshold] = true
          if allow_announce then
            AnnounceTier(player, threshold, tier.announce)
          end
        end
      else
        flags[threshold] = nil
      end
    end
  end
end

local function OnMoistureDelta(player, data)
  local value = (data and type(data.new) == "number" and data.new) or GetMoistureValue(player)
  if value == nil then
    return
  end

  local old = data and data.old
  local increasing = type(old) ~= "number"
      or old ~= old
      or value > old

  CheckMoisture(player, value, increasing)
end

local function SyncFlags(player)
  local value = GetMoistureValue(player)
  if value ~= nil then
    CheckMoisture(player, value, false)
  end
end

local function WatchPlayer(player)
  if player == nil or not player:IsValid() then
    return
  end
  if player._dst_broadcasts_moisture_watching then
    return
  end
  player._dst_broadcasts_moisture_watching = true

  player:ListenForEvent("moisturedelta", mod.Wrap("player_moisture_delta", OnMoistureDelta))
  mod.Call("player_moisture_sync", SyncFlags, player)
end

AddPlayerPostInit(mod.Wrap("player_moisture_init", function(player)
  if not mod.World.IsMaster() then
    return
  end
  player:DoTaskInTime(0, mod.Wrap("player_moisture_watch", function()
    if player:IsValid() then
      WatchPlayer(player)
    end
  end))
end))
