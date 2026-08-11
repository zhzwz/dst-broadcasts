--- 电台：按时段在系统频道开播（后续对接大模型生成节目文案）。
--- 时段：morning（cycles +1）/ dusk（day→dusk）/ midnight（dusk→night）。
--- 仅森林主机，避免洞穴分片重复请求与重复 Announce。

--- @alias RadioSlot "morning" | "dusk" | "midnight"

--- 开播入口。后续在此请求大模型，拿到文案后 core.Announce。
--- @param slot RadioSlot
local function OnAir(slot)
  --- TODO: 对接大模型服务，按 slot 生成系统频道节目并播报
  --- core.Announce(message)
end

--- 早间：每个游戏日开始（cycles 恰 +1）
core.World.ListenCycles("server", function()
  if not core.World.IsForest() then
    return
  end
  OnAir("morning")
end)

--- 黄昏 / 午夜：day→dusk / dusk→night（由 ListenPhase 过滤顺序跳转）
core.World.ListenPhase("server", function(phase)
  if not core.World.IsForest() then
    return
  end
  if phase == "dusk" then
    OnAir("dusk")
  elseif phase == "night" then
    OnAir("midnight")
  end
end)
