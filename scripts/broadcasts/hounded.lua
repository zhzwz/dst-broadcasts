--[[
  猎犬 / 洞穴蠕虫等 hounded 袭击倒计时。
]]

local function AttackName()
    if TheWorld:HasTag("cave") then
        return "蠕虫"
    end
    return "猎犬"
end

AddSimPostInit(function()
    if not TheWorld.ismastersim then
        return
    end
    if TheWorld.components.hounded == nil then
        return
    end

    WatchAttackCountdown(function()
        local hounded = TheWorld.components.hounded
        if hounded == nil or hounded:GetAttacking() then
            return nil
        end
        return hounded:GetTimeToAttack()
    end, AttackName)

    local was_attacking = nil
    TheWorld:DoPeriodicTask(1, function()
        local hounded = TheWorld.components.hounded
        if hounded == nil then
            return
        end
        local attacking = hounded:GetAttacking()
        if was_attacking == nil then
            was_attacking = attacking
            return
        end
        if attacking and not was_attacking then
            TheNet:Announce(string.format("[Broadcasts] %s来袭！", AttackName()))
        end
        was_attacking = attacking
    end)
end)
