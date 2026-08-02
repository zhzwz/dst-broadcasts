local S = BROADCASTS_STRINGS
local N = S.bosses
local C = BROADCASTS_CONSTANTS
local Safe = BROADCASTS_SAFE

local BOSSES = {
    { name = N.dragonfly, prefabs = { "dragonfly" } },
    { name = N.beequeen, prefabs = { "beequeen" } },
    { name = N.toadstool, prefabs = { "toadstool" } },
    { name = N.toadstool_dark, prefabs = { "toadstool_dark" } },
    { name = N.moose, prefabs = { "moose" } },
    { name = N.klaus, prefabs = { "klaus" } },
    { name = N.malbatross, prefabs = { "malbatross" } },
    { name = N.antlion, prefabs = { "antlion" } },
    { name = N.crabking, prefabs = { "crabking" } },
    { name = N.eyeofterror, prefabs = { "eyeofterror" } },
    { name = N.twins, prefabs = { "twinofterror1", "twinofterror2" } },
    { name = N.daywalker, prefabs = { "daywalker" } },
    { name = N.daywalker2, prefabs = { "daywalker2" } },
    { name = N.sharkboi, prefabs = { "sharkboi" } },
    { name = N.worm_boss, prefabs = { "worm_boss" } },
    {
        name = N.wagboss_robot,
        prefabs = { "wagboss_robot" },
        test = function(inst)
            return inst.hostile == true
        end,
    },
    {
        name = N.vault_pillar_guard,
        prefabs = { "vault_pillar_guard" },
        test = function(inst)
            return not inst.crafted
        end,
    },
    { name = N.minotaur, prefabs = { "minotaur" } },
    { name = N.stalker_atrium, prefabs = { "stalker_atrium" } },
    { name = N.alterguardian_phase3, prefabs = { "alterguardian_phase1", "alterguardian_phase2", "alterguardian_phase3" } },
    { name = N.alterguardian_phase4_lunarrift, prefabs = { "alterguardian_phase4_lunarrift" } },
}

local PREFAB_SET = {}
for _, boss in ipairs(BOSSES) do
    for _, prefab in ipairs(boss.prefabs) do
        PREFAB_SET[prefab] = boss
    end
end

local function AsInt(value, fallback)
    if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
        return fallback
    end
    return math.floor(value + 0.5)
end

local function Clamp01(value)
    if type(value) ~= "number" or value ~= value then
        return 0
    end
    if value < 0 then
        return 0
    end
    if value > 1 then
        return 1
    end
    return value
end

local function IsAliveBoss(inst, boss)
    if inst == nil or not inst:IsValid() or inst:HasTag("INLIMBO") then
        return false
    end
    if inst.defeated or (inst.sg ~= nil and inst.sg:HasStateTag("defeated")) then
        return false
    end
    local components = inst.components
    local health = components ~= nil and components.health or nil
    if health ~= nil and health:IsDead() then
        return false
    end
    return boss.test == nil or boss.test(inst)
end

local function CollectBossNames()
    local found = {}
    for _, inst in pairs(Ents) do
        local boss = inst.prefab ~= nil and PREFAB_SET[inst.prefab] or nil
        if boss ~= nil and IsAliveBoss(inst, boss) then
            found[boss] = true
        end
    end

    local names = {}
    for _, boss in ipairs(BOSSES) do
        if found[boss] then
            table.insert(names, boss.name)
        end
    end
    return names
end

local function FormatDuration(seconds)
    local whole = AsInt(seconds, 0)
    if whole < 60 then
        return string.format(S.morning_duration_seconds, math.max(1, whole))
    end
    return string.format(S.morning_duration_minutes, math.max(1, math.ceil(whole / 60)))
end

local function AddAttack(events, name, seconds)
    local day_seconds = TUNING.TOTAL_DAY_TIME
    if type(seconds) == "number" and
        seconds == seconds and
        seconds > 0 and
        type(day_seconds) == "number" and
        seconds <= day_seconds then
        table.insert(events, string.format(S.morning_attack, name, FormatDuration(seconds)))
    end
end

local function CollectEvents()
    local events = {}
    local state = TheWorld.state
    local next_season = C.NEXT_SEASON[state.season]
    if state.remainingdaysinseason == C.MORNING_SEASON_CHANGE_REMAINING_DAYS and
        next_season ~= nil and
        S.seasons[next_season] ~= nil then
        table.insert(events, string.format(S.morning_season_change, S.seasons[next_season]))
    end

    local hounded = TheWorld.components.hounded
    if hounded ~= nil and hounded.GetAttacking ~= nil and hounded.GetTimeToAttack ~= nil then
        if not hounded:GetAttacking() then
            local name = TheWorld:HasTag("cave") and N.depths_worms or N.hounds
            AddAttack(events, name, hounded:GetTimeToAttack())
        end
    end

    if not TheWorld:HasTag("cave") then
        local timers = TheWorld.components.worldsettingstimer
        if timers ~= nil then
            local attacks = {
                { name = N.deerclops, timer = C.DEERCLOPS_TIMER },
                { name = N.bearger, timer = C.BEARGER_TIMER },
            }
            for _, attack in ipairs(attacks) do
                if timers:ActiveTimerExists(attack.timer) and not timers:IsPaused(attack.timer) then
                    AddAttack(events, attack.name, timers:GetTimeLeft(attack.timer))
                end
            end
        end
    end

    return events
end

local function WeatherSummary()
    local state = TheWorld.state
    local current = S.weather[state.precipitation]
    if current ~= nil then
        return current
    end
    local pop = AsInt(Clamp01(state.pop) * 100, 0)
    return string.format(S.weather_clear, pop)
end

local function AnnounceMorning()
    local state = TheWorld.state
    if state == nil then
        return
    end

    local day = AsInt(state.cycles, 0) + 1
    local season_name = (S.season_short and S.season_short[state.season]) or
        S.seasons[state.season] or
        tostring(state.season or "")
    local events = CollectEvents()
    local bosses = CollectBossNames()
    local message = string.format(S.morning_report, day, season_name, WeatherSummary())
    if #events > 0 then
        message = message .. string.format(S.morning_events, table.concat(events, S.list_separator))
    end
    if #bosses > 0 then
        message = message .. string.format(S.morning_bosses, table.concat(bosses, S.list_separator))
    end
    Safe.Announce(message .. S.morning_end)
end

AddSimPostInit(Safe.Wrap("morning_init", function()
    if not TheWorld.ismastersim then
        return
    end

    -- 读档时 cycles 会从默认 0 跳到存档天数；只在真正跨天（+1）时播报。
    local prev_cycles = TheWorld.state.cycles
    TheWorld:WatchWorldState("cycles", Safe.Wrap("morning_cycles", function(_, cycles)
        local previous = prev_cycles
        prev_cycles = cycles
        if type(cycles) ~= "number" or type(previous) ~= "number" then
            return
        end
        if cycles ~= previous + 1 or cycles <= 0 then
            return
        end
        TheWorld:DoTaskInTime(0, Safe.Wrap("morning_report", AnnounceMorning))
    end))
end))
