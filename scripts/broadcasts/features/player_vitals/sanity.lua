--[[
  玩家理智按百分比档位播报（约 50% / 10%）。
  各档各播一次；每档从多条文案中随机选一条。
]]

modimport("scripts/broadcasts/lib/pick_message.lua")
modimport("scripts/broadcasts/shared/get_player_display_name.lua")

local S = BROADCASTS_STRINGS
local C = BROADCASTS_PLAYER_VITALS
local PickMessage = BROADCASTS_PICK_MESSAGE
local PlayerName = BROADCASTS_GET_PLAYER_DISPLAY_NAME

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
  local message = PickMessage(S[messages_key])
  if message == nil then
    return
  end
  mod.Announce(string.format(message, PlayerName(player)))
end

-- allow_announce=false 时只同步 flags（进服对齐）
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

  local tiers = C.SANITY_LOW_TIERS
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

local function SyncFlags(player)
  local percent = GetSanityPercent(player)
  if percent ~= nil then
    CheckSanity(player, percent, false)
  end
end

local function WatchPlayer(player)
  if player == nil or not player:IsValid() then
    return
  end
  if player._dst_broadcasts_sanity_watching then
    return
  end
  player._dst_broadcasts_sanity_watching = true

  player:ListenForEvent("sanitydelta", mod.Wrap("player_sanity_delta", OnSanityDelta))
  mod.Call("player_sanity_sync", SyncFlags, player)
end

AddPlayerPostInit(mod.Wrap("player_sanity_init", function(player)
  if TheWorld == nil or not TheWorld.ismastersim then
    return
  end
  player:DoTaskInTime(0, mod.Wrap("player_sanity_watch", function()
    if player:IsValid() then
      WatchPlayer(player)
    end
  end))
end))
