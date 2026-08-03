--[[
  取得物品当前归属的玩家（grand owner）。

  通过 inventoryitem:GetGrandOwner() 向上查找；仅当结果带 player 标签时返回。
  常用于手持/背包内物品的耐久、损毁播报。

  @param inst Entity 物品实体
  @return Entity|nil 玩家实体；无 inventoryitem 或不属于玩家时为 nil
]]

local function GetPlayerOwner(inst)
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

BROADCASTS_GET_PLAYER_OWNER = GetPlayerOwner
