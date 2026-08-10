--- 取得世界时钟组件（月相 / 昼夜等）。
--- 优先 `TheWorld.net.components.clock`，否则 `TheWorld.components.clock`。
--- @return table|nil
core.GetClockComponent = function()
  local net = TheWorld ~= nil and TheWorld.net or nil
  if net ~= nil and net.components ~= nil and net.components.clock ~= nil then
    return net.components.clock
  end
  if TheWorld ~= nil and TheWorld.components ~= nil then
    return TheWorld.components.clock
  end
  return nil
end
