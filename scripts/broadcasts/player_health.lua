--[[
  玩家生命值降至百分比阈值时全服播报；仅在下降时播报，回升后可再次触发。
]]

local S = BROADCASTS_STRINGS
local C = BROADCASTS_CONSTANTS
local Safe = BROADCASTS_SAFE

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

    local thresholds = C.PLAYER_HEALTH_LOW_THRESHOLDS
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

    local value = math.floor(percent * 100 + 0.5)
    if value < 0 then
        value = 0
    elseif value > 100 then
        value = 100
    end

    local current_display = math.floor(current + 0.5)
    if current_display < 0 then
        current_display = 0
    end
    local max_display = math.floor(max_health + 0.5)
    if max_display < 1 then
        max_display = 1
    end

    local name = "?"
    local ok, display_name = pcall(function()
        return player:GetDisplayName()
    end)
    if ok and type(display_name) == "string" and display_name ~= "" then
        name = display_name
    end

    Safe.Announce(string.format(
        S.player_low_health,
        name,
        current_display,
        max_display,
        value
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
    local decreasing = type(oldpercent) == "number"
        and oldpercent == oldpercent
        and percent < oldpercent

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

    player:ListenForEvent("healthdelta", Safe.Wrap("player_health_delta", OnHealthDelta))
    Safe.Call("player_health_sync", SyncHealthFlags, player)
end

AddPlayerPostInit(Safe.Wrap("player_health_setup", function(player)
    if TheWorld == nil or not TheWorld.ismastersim then
        return
    end
    player:DoTaskInTime(0, Safe.Wrap("player_health_watch", function()
        if player:IsValid() then
            WatchPlayer(player)
        end
    end))
end))
