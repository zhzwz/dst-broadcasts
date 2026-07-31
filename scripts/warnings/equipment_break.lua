--[[
  武器（finiteuses）/ 护甲损坏时全服提醒一次。
]]

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

local function AnnounceBroke(owner, item_name)
    TheNet:Announce(string.format(
        "[Warnings] %s的%s已损毁！",
        owner:GetDisplayName() or "?",
        item_name
    ))
end

local function OnArmorBroke(player, data)
    if player == nil or not player:HasTag("player") then
        return
    end
    local armor = data and data.armor
    local item_name = (armor ~= nil and (armor:GetDisplayName() or armor.prefab)) or "护甲"
    AnnounceBroke(player, item_name)
end

local function WatchPlayer(player)
    if player._dst_warnings_armor_broke then
        return
    end
    player._dst_warnings_armor_broke = true
    player:ListenForEvent("armorbroke", OnArmorBroke)
end

AddPlayerPostInit(function(player)
    if not TheWorld.ismastersim then
        return
    end
    player:DoTaskInTime(0, function()
        if player:IsValid() then
            WatchPlayer(player)
        end
    end)
end)

local function OnFiniteUsesChange(inst, data)
    local uses = inst.components.finiteuses
    if uses == nil then
        return
    end

    local percent = (data and data.percent) or uses:GetPercent()
    if percent > 0 then
        inst._dst_warnings_uses_broke = nil
        return
    end
    if inst._dst_warnings_uses_broke then
        return
    end
    inst._dst_warnings_uses_broke = true

    local owner = PlayerOwner(inst)
    if owner == nil then
        return
    end
    AnnounceBroke(owner, inst:GetDisplayName() or inst.prefab)
end

AddComponentPostInit("finiteuses", function(self)
    if not TheWorld.ismastersim then
        return
    end
    local inst = self.inst
    if inst._dst_warnings_finiteuses_watching then
        return
    end
    inst._dst_warnings_finiteuses_watching = true
    inst:ListenForEvent("percentusedchange", OnFiniteUsesChange)
end)
