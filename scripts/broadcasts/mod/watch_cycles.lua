--- 监听昼夜循环轮数变化
--- cycles: 昼夜循环轮数，从 0 开始，进入新的循环时递增
--- @param fn fun(cycles: number)
local function Cycles(fn)
  AddSimPostInit(mod.Wrap("mod.Watch.Cycles", function()
    if not mod.World.IsServer() then
      return
    end
    local cycles_old = mod.FormatNumber(TheWorld.state.cycles)
    TheWorld:WatchWorldState("cycles", mod.Wrap("mod.Watch.Cycles.watch", function(_, cycles)
      local cycles_new = mod.FormatNumber(cycles)
      if cycles_old + 1 == cycles_new then
        TheWorld:DoTaskInTime(0, mod.Wrap("mod.Watch.Cycles.dispatch", function()
          mod.Call("mod.Watch.Cycles", fn, cycles)
        end))
      end
    end))
  end))
end

mod.Watch.Cycles = Cycles
