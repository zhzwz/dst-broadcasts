--- 玩家理智按百分比档位播报（约 50% / 10%）。
--- 各档各播一次；每档从多条文案中随机选一条。

local S = i18n

--- 约 50%：可能出现 1 只暗影；约 10%：可能出现 2 只暗影
local SANITY_LOW_TIERS = {
  { threshold = 0.50, messages = "player_low_sanity_50" },
  { threshold = 0.10, messages = "player_low_sanity_10" },
}
local function PlayerName(player)
  return core.GetDisplayName(player) or "?"
end

local FLAG = "_dst_broadcasts_low_sanity"

local function GetSanityPercent(player)
  local components = player.components
  if components == nil or components.sanity == nil then
    return nil
  end
  local ok, percent = pcall(function()
    return components.sanity:GetPercent()
  end)
  if ok and type(percent) == "number" and percent == percent then
    return percent
  end
  return nil
end

local function AnnounceTier(player, messages_key)
  local messages = S[messages_key]
  if type(messages) ~= "table" then
    return
  end
  local message = core.RandomPick(messages)
  if message == nil then
    return
  end
  core.Announce(string.format(message, PlayerName(player)))
end

local function CheckSanity(player, percent, allow_announce)
  if player == nil or not player:IsValid() then
    return
  end
  if player:HasTag("playerghost") then
    player[FLAG] = nil
    return
  end
  if type(percent) ~= "number" or percent ~= percent then
    return
  end

  local tiers = SANITY_LOW_TIERS
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
    local messages_key = tier.messages
    if type(threshold) == "number" and type(messages_key) == "string" then
      if percent <= threshold then
        if not flags[threshold] then
          flags[threshold] = true
          if allow_announce then
            AnnounceTier(player, messages_key)
          end
        end
      else
        flags[threshold] = nil
      end
    end
  end
end

local function OnSanityDelta(player, data)
  local percent = (data and type(data.newpercent) == "number" and data.newpercent) or GetSanityPercent(player)
  if percent == nil then
    return
  end

  local oldpercent = data and data.oldpercent
  local decreasing = type(oldpercent) ~= "number"
      or oldpercent ~= oldpercent
      or percent < oldpercent

  CheckSanity(player, percent, decreasing)
end

core.ListenPlayer("sanitydelta", OnSanityDelta)
