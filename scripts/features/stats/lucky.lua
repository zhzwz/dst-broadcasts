--- 玩家幸运值（Lucky）
--- 无阈值，数值变动即公告；原版无公开事件，挂钩 luckuser 的 Set/RemoveLuckSource。

local hooked = false

local function Announce(self, luck)
  local player = self.inst
  -- 取显示名；拿不到则不公告
  local name = core.GetDisplayName(player)
  if name == nil then return end

  -- 玩家
  if not player:HasTag("player") then return end
  -- 非幽灵
  if player:HasTag("playerghost") then return end

  core.Announce(string.format("[%s] LUCKY: %.0f", name, luck))
end

local function WrapOnLuckChange(original)
  return function(component, ...)
    -- 调用原方法前后对比幸运值
    local before = component:GetLuck()
    original(component, ...)
    -- 读档填充期不公告
    if POPULATING then return end
    -- 未变化则不公告
    local after = component:GetLuck()
    if after == before then return end
    -- 公告异常不回灌原版调用栈
    core.Call(Announce, component, after)
  end
end

AddComponentPostInit("luckuser", core.Wrap(function(self)
  -- 仅服务端
  if not core.World.IsServerSide() then return end
  -- 挂钩增减幸运源，数值变化时公告
  self.SetLuckSource = WrapOnLuckChange(self.SetLuckSource)
  self.RemoveLuckSource = WrapOnLuckChange(self.RemoveLuckSource)
  if not hooked then
    hooked = true
    core.Print("lucky: luckuser hooked")
  end
end))
