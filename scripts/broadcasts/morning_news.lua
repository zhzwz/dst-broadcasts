local S = BROADCASTS_STRINGS
local N = S.bosses
local DAY_SECONDS = TUNING.TOTAL_DAY_TIME

local NEXT_SEASON = {
    autumn = "winter",
    winter = "spring",
    spring = "summer",
    summer = "autumn",
}

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

local function IsAliveBoss(inst, boss)
    if not inst:IsValid() or inst:HasTag("INLIMBO") then
        return false
    end
    if inst.defeated or (inst.sg ~= nil and inst.sg:HasStateTag("defeated")) then
        return false
    end
    local health = inst.components.health
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
    if seconds < 60 then
        return string.format(S.morning_duration_seconds, math.max(1, math.ceil(seconds)))
    end
    return string.format(S.morning_duration_minutes, math.ceil(seconds / 60))
end

local function AddAttack(events, name, seconds)
    if type(seconds) == "number" and seconds > 0 and seconds <= DAY_SECONDS then
        table.insert(events, string.format(S.morning_attack, name, FormatDuration(seconds)))
    end
end

local function CollectEvents()
    local events = {}
    local state = TheWorld.state
    local next_season = NEXT_SEASON[state.season]
    if state.remainingdaysinseason == 1 and next_season ~= nil then
        table.insert(events, string.format(S.morning_season_change, S.seasons[next_season]))
    end

    local hounded = TheWorld.components.hounded
    if hounded ~= nil and not hounded:GetAttacking() then
        local name = TheWorld:HasTag("cave") and N.depths_worms or N.hounds
        AddAttack(events, name, hounded:GetTimeToAttack())
    end

    if not TheWorld:HasTag("cave") then
        local timers = TheWorld.components.worldsettingstimer
        if timers ~= nil then
            local attacks = {
                { name = N.deerclops, timer = "deerclops_timetoattack" },
                { name = N.bearger, timer = "bearger_timetospawn" },
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
    local pop = math.floor(math.clamp(state.pop or 0, 0, 1) * 100 + 0.5)
    return string.format(S.weather_clear, pop)
end

local function AnnounceMorning()
    local state = TheWorld.state
    local events = CollectEvents()
    local bosses = CollectBossNames()
    local event_summary = #events > 0 and
        table.concat(events, S.list_separator) or
        S.morning_no_events
    local boss_summary = #bosses > 0 and
        table.concat(bosses, S.list_separator) or
        S.morning_no_bosses

    TheNet:Announce(string.format(
        S.morning_report,
        state.cycles + 1,
        S.seasons[state.season] or state.season,
        state.elapseddaysinseason + 1,
        WeatherSummary(),
        event_summary,
        boss_summary
    ))
end

local function OnNewDay()
    if TheWorld.state.cycles == 0 then
        return
    end
    TheWorld:DoTaskInTime(0, AnnounceMorning)
end

AddSimPostInit(function()
    if not TheWorld.ismastersim then
        return
    end
    TheWorld:WatchWorldState("cycles", OnNewDay)
end)
