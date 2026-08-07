--- 玩家湿度 10/20/40/60/80 分档播报：系统短句 + 玩家角色潮湿台词。

local S = i18n

local MOISTURE_TIERS = {
  { threshold = 10, announce = "ANNOUNCE_DAMP" },
  { threshold = 20, announce = "ANNOUNCE_DAMP" },
  { threshold = 40, announce = "ANNOUNCE_WET" },
  { threshold = 60, announce = "ANNOUNCE_WETTER" },
  { threshold = 80, announce = "ANNOUNCE_SOAKED" },
}
local function PlayerName(player)
  return core.GetDisplayName(player) or "?"
end

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
  core.Announce(string.format(prefix, PlayerName(player)))
  local line = core.GetAnnounceLine(announce_key, player)
  if line ~= nil then
    core.PlayerBubble(line, player)
  end
end

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

  local tiers = MOISTURE_TIERS
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

core.ListenPlayer("moisturedelta", OnMoistureDelta)
