--- 玩家饱食度过低播报（≤10 / ≤0）：系统短句 + 玩家 ANNOUNCE_HUNGRY。

local S = i18n

--- 饱食度过低阈值（current；各档各播一次）
local HUNGER_LOW_THRESHOLDS = { 10, 0 }
local function PlayerName(player)
  return core.GetDisplayName(player) or "?"
end

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
  local template = core.RandomPick(messages)
  if template == nil then
    return
  end
  core.Announce(string.format(template, PlayerName(player)))
  local line = core.GetAnnounceLine(ANNOUNCE_KEY, player)
  if line ~= nil then
    core.Announce(line, player)
  end
end

--- allow_announce=false 时只同步 flags（进服对齐）
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

  local thresholds = HUNGER_LOW_THRESHOLDS
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

  player:ListenForEvent("hungerdelta", core.Wrap(OnHungerDelta))
  core.Call(SyncFlags, player)
end

AddPlayerPostInit(core.Wrap(function(player)
  if not core.IsServer() then
    return
  end
  core.SetTimeout(player, function()
    if player:IsValid() then
      WatchPlayer(player)
    end
  end, 0)
end))
