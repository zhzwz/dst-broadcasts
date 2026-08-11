--- 物品损毁 / 最后一次使用公告（仅主机）。
--- 入口：
---   1) 护甲：玩家事件 armorbroke（按 value=0 损毁）
---   2) finiteuses：次数变为 0 → 损毁；白名单且变为 1 → 最后一次
---
--- “威尔逊的大理石甲已损毁！”
--- “大理石甲已损毁！”
--- “威尔逊的建造护符快要损毁了！”
--- “建造护符快要损毁了！”

--- 白名单：剩余 1 次时提醒（按需增删）。
local LAST_USE_WHITELIST = {
  greenamulet = true, --- 建造护符
  greenstaff = true,  --- 解构魔杖
  yellowstaff = true, --- 唤星者魔杖
  opalstaff = true,   --- 唤月者魔杖
  orangestaff = true, --- 懒人魔杖
  telestaff = true,   --- 传送魔杖
  panflute = true,    --- 排箫
}

--- value=0 损毁；value=1 且白名单则最后一次。物品名必填。
local function Announce(player, item, value)
  if item == nil then return end

  local with_player, without_player
  if value == 1 and LAST_USE_WHITELIST[item.prefab] then
    with_player = i18n.broke.player_last_use
    without_player = i18n.broke.without_player_last_use
  elseif value == 0 then
    with_player = i18n.broke.player
    without_player = i18n.broke.without_player
  else
    return
  end

  local item_name = core.GetDisplayName(item) or core.GetPrefabDisplayName(item.prefab)
  if item_name == nil then return end

  local player_name = nil
  if player ~= nil and player:HasTag("player") then
    player_name = core.GetDisplayName(player)
  end

  if player_name ~= nil then
    DST_SERVER_SEND(string.format(with_player, player_name, item_name))
  else
    DST_SERVER_SEND(string.format(without_player, item_name))
  end
end

--- 原版护甲归零时向穿戴者 PushEvent("armorbroke", { armor = ... })。
core.ListenPlayer("armorbroke", function(player, data)
  Announce(player, data.armor, 0)
end)

--- finiteuses：实体加上该组件后挂 percentusedchange。
AddComponentPostInit("finiteuses", core.Wrap(function(self)
  if not core.World.IsServerSide() then return end
  self.inst:ListenForEvent("percentusedchange", core.Wrap(function(inst, data)
    if POPULATING then return end
    local uses = inst.components.finiteuses
    local current = uses:GetUses() or uses.current
    if current == 0 or current == 1 then
      Announce(core.GetOwner(inst), inst, current)
    end
  end))
end))
