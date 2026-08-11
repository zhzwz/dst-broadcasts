--- 监听昼夜循环轮数变化（仅主机）。
--- cycles 从 0 起；仅 previous+1 时回调（本局内非连续跳变不触发）。
--- 回调经 SetTimeout(0) 延后到本帧末，避免与同期 WatchWorldState 打架。
--- @param fn fun(cycles: number)
core.WatchCycles = function(fn)
  AddSimPostInit(core.Wrap(function()
    if not core.World.IsServerSide() then
      return
    end
    --- 会话开始时记下的已是当前 cycles（读档/回档为重建世界）
    local cycles_old = core.Number(TheWorld.state.cycles) or 0
    TheWorld:WatchWorldState("cycles", core.Wrap(function(_, cycles)
      local cycles_new = core.Number(cycles) or 0
      local previous = cycles_old
      cycles_old = cycles_new
      if previous + 1 == cycles_new then
        core.SetTimeout(TheWorld, function()
          core.Call(fn, cycles_new)
        end, 0)
      end
    end))
  end))
end
