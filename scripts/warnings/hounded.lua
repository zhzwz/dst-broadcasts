--[[
  猎犬 / 洞穴蠕虫等 hounded 袭击倒计时全服提醒。
]]

local ADVANCE_DAYS = GetModConfigData("hounded_advance_days") or 1
local URGENT_SEC = GetModConfigData("hounded_urgent_sec") or 30

local function AttackName()
    if TheWorld:HasTag("cave") then
        return "蠕虫"
    end
    return "猎犬"
end

local function FormatRemain(sec)
    sec = math.max(0, math.floor(sec + 0.5))
    if sec <= 0 then
        return "即将到来"
    end

    local day = TUNING.TOTAL_DAY_TIME
    local days = math.floor(sec / day)
    local rest = sec - days * day
    local minutes = math.floor(rest / 60)
    local seconds = rest % 60

    if days > 0 then
        return string.format("%d 天 %d 分", days, minutes)
    end
    if minutes > 0 then
        return string.format("%d 分 %d 秒", minutes, seconds)
    end
    return string.format("%d 秒", seconds)
end

local function Announce(msg)
    TheNet:Announce("[Warnings] " .. msg)
end

local function DaysLeft(sec)
    return math.floor(sec / TUNING.TOTAL_DAY_TIME)
end

AddSimPostInit(function()
    if not TheWorld.ismastersim then
        return
    end
    if TheWorld.components.hounded == nil then
        return
    end

    local was_warning = false
    local was_attacking = false
    local urgent_announced = false
    local last_day_key = nil

    TheWorld:DoPeriodicTask(1, function()
        local hounded = TheWorld.components.hounded
        if hounded == nil then
            return
        end

        local warning = hounded:GetWarning()
        local attacking = hounded:GetAttacking()
        local t = hounded:GetTimeToAttack() or 0
        local name = AttackName()

        if warning and not was_warning then
            Announce(string.format("%s袭击预警：约 %s 后到达", name, FormatRemain(t)))
            urgent_announced = false
        end

        if URGENT_SEC > 0 and warning and not attacking and t <= URGENT_SEC and not urgent_announced then
            Announce(string.format("%s袭击临近：约 %s 后到达", name, FormatRemain(t)))
            urgent_announced = true
        end

        if attacking and not was_attacking then
            Announce(string.format("%s袭击开始！", name))
        end

        if not warning and not attacking then
            urgent_announced = false

            if ADVANCE_DAYS > 0 and TheWorld.state.cycles ~= 0 then
                local days = DaysLeft(t)
                if days <= ADVANCE_DAYS then
                    local key = tostring(TheWorld.state.cycles) .. ":" .. tostring(days)
                    if key ~= last_day_key then
                        last_day_key = key
                        if days <= 0 then
                            Announce(string.format("%s袭击：就在今天（约 %s）", name, FormatRemain(t)))
                        else
                            Announce(string.format("%s袭击：还剩约 %d 天（%s）", name, days, FormatRemain(t)))
                        end
                    end
                end
            end
        end

        was_warning = warning
        was_attacking = attacking
    end)
end)
