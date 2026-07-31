--[[
  袭击倒计时共用逻辑：
  - 游戏时间提前 1 天
  - 现实时间 5 分 / 2 分 / 1 分 / 30 秒 / 10 秒 / 5 秒
  文案：[Broadcasts] 距离猎犬来袭还有5秒，请做好准备！
]]

local ADVANCE_DAYS = 1
local REAL_THRESHOLDS = { 300, 120, 60, 30, 10, 5 }
local REAL_LABELS = {
    [300] = "5分钟",
    [120] = "2分钟",
    [60] = "1分钟",
    [30] = "30秒",
    [10] = "10秒",
    [5] = "5秒",
}

local function Announce(msg)
    TheNet:Announce("[Broadcasts] " .. msg)
end

-- get_seconds: 返回剩余秒数；nil 表示当前无倒计时
-- get_name: 返回袭击显示名
function WatchAttackCountdown(get_seconds, get_name)
    if not TheWorld.ismastersim then
        return
    end

    local state = {
        real_flags = {},
        last_day_key = nil,
    }

    TheWorld:DoPeriodicTask(1, function()
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
            if days <= ADVANCE_DAYS then
                local key = tostring(TheWorld.state.cycles) .. ":" .. tostring(days)
                if key ~= state.last_day_key then
                    state.last_day_key = key
                    if days <= 0 then
                        Announce(string.format("%s预计今日来袭，请提前准备！", name))
                    else
                        Announce(string.format("距离%s来袭还有1个游戏日，请提前准备！", name))
                    end
                end
            end
        end

        local lowest = nil
        for _, th in ipairs(REAL_THRESHOLDS) do
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
            Announce(string.format("距离%s来袭还有%s，请做好准备！", name, REAL_LABELS[lowest]))
        end
    end)
end
