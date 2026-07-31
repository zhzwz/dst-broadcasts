--[[
  USAGE 型 fueled（可用缝纫包修复；归零通常会消失）低耐久全服提醒。
  不覆盖矿工帽等「耗尽只熄灭、物品仍在」的燃料装备。
]]

local THRESHOLD = (GetModConfigData("usage_break_percent") or 20) / 100

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

local function AnnounceLow(inst, percent)
    local owner = PlayerOwner(inst)
    if owner == nil then
        return
    end

    local item_name = inst:GetDisplayName() or inst.prefab
    local owner_name = owner:GetDisplayName() or "?"
    local pct = math.floor(percent * 100 + 0.5)

    TheNet:Announce(string.format(
        "[Warnings] %s 的 %s 耐久仅剩 %d%%，请及时缝补！",
        owner_name,
        item_name,
        pct
    ))
end

local function OnPercentUsedChange(inst, data)
    local fueled = inst.components.fueled
    if fueled == nil then
        return
    end

    local percent = (data and data.percent) or fueled:GetPercent()
    if percent <= THRESHOLD then
        if not inst._dst_warnings_usage_warned then
            inst._dst_warnings_usage_warned = true
            AnnounceLow(inst, percent)
        end
    else
        inst._dst_warnings_usage_warned = false
    end
end

local function WatchFueled(inst)
    local fueled = inst.components.fueled
    if fueled == nil or fueled.fueltype ~= FUELTYPE.USAGE then
        return
    end
    if inst._dst_warnings_usage_watching then
        return
    end
    inst._dst_warnings_usage_watching = true
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
