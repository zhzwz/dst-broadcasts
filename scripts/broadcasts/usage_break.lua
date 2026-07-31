--[[
  可缝补（USAGE）与可补燃料（非 USAGE）的 fueled 多档全服提醒。
]]

local SEW_THRESHOLDS = { 20, 10, 5, 4, 3, 2, 1 }
local FUEL_THRESHOLDS = { 30, 20, 10 }

local function PlayerOwner(inst)
    local item = inst.components.inventoryitem
    if item == nil then
        return nil
    end
    local owner = item:GetGrandOwner()
    if owner ~= nil and owner:HasTag("player") then
        return owner
    end
    return nil
end

local function Announce(inst, percent, kind, action)
    local owner = PlayerOwner(inst)
    if owner == nil then
        return
    end

    local item_name = inst:GetDisplayName() or inst.prefab
    local owner_name = owner:GetDisplayName() or "?"
    local pct = math.floor(percent * 100 + 0.5)

    TheNet:Announce(string.format(
        "[Broadcasts] %s的%s剩余%d%%%s，请及时%s！",
        owner_name,
        item_name,
        pct,
        kind,
        action
    ))
end

local function CheckThresholds(inst, percent, thresholds, flag_key, kind, action)
    local pct = percent * 100
    local flags = inst[flag_key]
    if flags == nil then
        flags = {}
        inst[flag_key] = flags
    end

    local should_announce = false
    for _, t in ipairs(thresholds) do
        if pct <= t then
            if not flags[t] then
                flags[t] = true
                should_announce = true
            end
        else
            flags[t] = nil
        end
    end

    if should_announce then
        Announce(inst, percent, kind, action)
    end
end

local function OnPercentUsedChange(inst, data)
    local fueled = inst.components.fueled
    if fueled == nil then
        return
    end

    local percent = (data and data.percent) or fueled:GetPercent()
    if fueled.fueltype == FUELTYPE.USAGE then
        CheckThresholds(inst, percent, SEW_THRESHOLDS, "_dst_broadcasts_sew_flags", "耐久", "缝补")
    else
        CheckThresholds(inst, percent, FUEL_THRESHOLDS, "_dst_broadcasts_fuel_flags", "燃料", "补充")
    end
end

local function WatchFueled(inst)
    local fueled = inst.components.fueled
    if fueled == nil then
        return
    end
    if inst._dst_broadcasts_fueled_watching then
        return
    end
    inst._dst_broadcasts_fueled_watching = true
    inst:ListenForEvent("percentusedchange", OnPercentUsedChange)
end

AddComponentPostInit("fueled", function(self)
    if not TheWorld.ismastersim then
        return
    end
    self.inst:DoTaskInTime(0, function(inst)
        if inst:IsValid() then
            WatchFueled(inst)
        end
    end)
end)
