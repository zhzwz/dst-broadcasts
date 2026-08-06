--- 跨天总线：全模组共用一次 WatchWorldState("cycles")。
--- 仅在 cycles 刚好 +1 时，于下一帧回调已注册的监听。
--- 新档第 1 天早上不会触发（需 0→1 才算跨天），属预期行为。

--- @type function[]
local listeners = {}
local started = false

local function IsCyclesIncrement(previous, cycles)
  return type(cycles) == "number"
      and type(previous) == "number"
      and cycles == previous + 1
      and cycles > 0
end

local function Dispatch(cycles)
  for i = 1, #listeners do
    local fn = listeners[i]
    if type(fn) == "function" then
      mod.Call("mod.Watch.Cycles:" .. i, fn, cycles)
    end
  end
end

local function EnsureStarted()
  if started or not mod.World.IsServer() then
    return
  end
  if TheWorld == nil or TheWorld.state == nil then
    return
  end

  started = true
  local prev_cycles = TheWorld.state.cycles
  TheWorld:WatchWorldState("cycles", mod.Wrap("mod.Watch.Cycles", function(_, cycles)
    local previous = prev_cycles
    prev_cycles = cycles
    if not IsCyclesIncrement(previous, cycles) then
      return
    end
    TheWorld:DoTaskInTime(0, mod.Wrap("mod.Watch.Cycles.dispatch", function()
      Dispatch(cycles)
    end))
  end))
end

--- 注册跨天回调（cycles 刚好 +1；读档跳变不会触发）
--- @param fn fun(cycles: number)
local function Cycles(fn)
  table.insert(listeners, fn)
  EnsureStarted()
end

AddSimPostInit(mod.Wrap("mod.Watch.Cycles.init", function()
  EnsureStarted()
end))

mod.Watch.Cycles = Cycles
