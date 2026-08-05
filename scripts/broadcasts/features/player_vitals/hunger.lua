--[[
  玩家饱食度过低播报（≤10 / ≤0）：随机电台短句 + 角色 ANNOUNCE_HUNGRY。
]]

modimport("scripts/broadcasts/lib/pick_message.lua")

local S = i18n
local C = BROADCASTS_PLAYER_VITALS
local PickMessage = BROADCASTS_PICK_MESSAGE
local PlayerName = mod.Player.GetDisplayName
local CharacterQuote = mod.Character.GetQuotedAnnounceLine

local FLAG = "_dst_broadcasts_low_hunger"
local ANNOUNCE_KEY = "ANNOUNCE_HUNGRY"

local function GetHunger(player)
  local hunger = player.components ~= nil and player.components.hunger or nil
  if hunger == nil then
    return nil
  end
  if type(hunger.current) == "number" and hunger.current == hunger.current then
    return hunger.current
  end
  return nil
end

local function AnnounceTier(player, threshold)
  local messages = type(S.player_hunger) == "table" and S.player_hunger[threshold] or nil
  local template = PickMessage(messages)
  if template == nil then
    return
  end
  local message = string.format(template, PlayerName(player))
  local quote = CharacterQuote(player, ANNOUNCE_KEY)
  if type(quote) == "string" and quote ~= "" then
    message = message .. quote
  end
  mod.Announce(message)
end

-- allow_announce=false 时只同步 flags（进服对齐）
local function CheckHunger(player, current, allow_announce)
  if player == nil or not player:IsValid() then
    return
  end
  if player:HasTag("playerghost") then
    player[FLAG] = nil
    return
  end
  if type(current) ~= "number" or current ~= current then
    return
  end

  local thresholds = C.HUNGER_LOW_THRESHOLDS
  if type(thresholds) ~= "table" then
    return
  end

  local flags = player[FLAG]
  if type(flags) ~= "table" then
    flags = {}
    player[FLAG] = flags
  end

  for _, threshold in ipairs(thresholds) do
    if type(threshold) == "number" then
      if current <= threshold then
        if not flags[threshold] then
          flags[threshold] = true
          if allow_announce then
            AnnounceTier(player, threshold)
          end
        end
      else
        flags[threshold] = nil
      end
    end
  end
end

local function OnHungerDelta(player)
  local current = GetHunger(player)
  if current ~= nil then
    CheckHunger(player, current, true)
  end
end

local function SyncFlags(player)
  local current = GetHunger(player)
  if current ~= nil then
    CheckHunger(player, current, false)
  end
end

local function WatchPlayer(player)
  if player == nil or not player:IsValid() then
    return
  end
  if player._dst_broadcasts_hunger_watching then
    return
  end
  player._dst_broadcasts_hunger_watching = true

  player:ListenForEvent("hungerdelta", mod.Wrap("player_hunger_delta", OnHungerDelta))
  mod.Call("player_hunger_sync", SyncFlags, player)
end

AddPlayerPostInit(mod.Wrap("player_hunger_init", function(player)
  if not mod.World.IsMaster() then
    return
  end
  player:DoTaskInTime(0, mod.Wrap("player_hunger_watch", function()
    if player:IsValid() then
      WatchPlayer(player)
    end
  end))
end))
