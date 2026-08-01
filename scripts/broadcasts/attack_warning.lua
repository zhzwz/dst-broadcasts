--[[
  袭击预警共用逻辑：
  - 游戏时间提前若干天
  - 现实时间多档阈值提醒
]]

local S = BROADCASTS_STRINGS
local C = BROADCASTS_CONSTANTS
local Safe = BROADCASTS_SAFE

-- get_seconds: 返回剩余秒数；nil 表示当前没有袭击预警
-- get_name: 返回袭击显示名
function WatchAttackWarning(get_seconds, get_name)
    if not TheWorld.ismastersim then
        return
    end

    local state = {
        real_flags = {},
        last_day_key = nil,
    }

    TheWorld:DoPeriodicTask(C.ATTACK_WARNING_POLL_SECONDS, Safe.Wrap("attack_warning", function()
        local t = get_seconds()
        if type(t) ~= "number" or t ~= t or t < 0 then
            state.real_flags = {}
            return
        end

        local name = get_name()
        if name == nil then
            return
        end

        if TheWorld.state.cycles ~= 0 then
            local days = math.ceil(t / TUNING.TOTAL_DAY_TIME)
            if days <= C.ATTACK_WARNING_ADVANCE_DAYS then
                local key = tostring(TheWorld.state.cycles) .. ":" .. tostring(days)
                if key ~= state.last_day_key then
                    state.last_day_key = key
                    if days <= 0 then
                        Safe.Announce(string.format(S.attack_today, name))
                    else
                        Safe.Announce(string.format(S.attack_day, name))
                    end
                end
            end
        end

        local lowest = nil
        for _, th in ipairs(C.ATTACK_WARNING_REAL_THRESHOLDS) do
            if t <= th then
                if not state.real_flags[th] then
                    state.real_flags[th] = true
                    if lowest == nil or th < lowest then
                        lowest = th
                    end
                end
            else
                state.real_flags[th] = nil
            end
        end

        if lowest ~= nil then
            Safe.Announce(string.format(S.attack_time, name, S.durations[lowest]))
        end
    end))
end
