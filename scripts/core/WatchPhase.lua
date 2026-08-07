local NEXT_PHASE = {
  day = "dusk",
  dusk = "night",
  night = "day",
}

--- 监听昼夜相位变化（仅主机）。
--- 森林看 phase，洞穴看 cavephase；仅 previous → 下一相位时回调。
--- 回调经 SetTimeout(0) 延后到本帧末，避免与同期 WatchWorldState 打架。
--- @param fn fun(phase: string)
core.WatchPhase = function(fn)
  AddSimPostInit(core.Wrap(function()
    if not core.IsServer() then
      return
    end
    local key = core.IsCaveWorld() and "cavephase" or "phase"
    --- 会话开始时记下的已是当前相位（读档/回档为重建世界）
    local phase_old = TheWorld.state ~= nil and TheWorld.state[key] or nil
    TheWorld:WatchWorldState(key, core.Wrap(function(_, phase)
      local previous = phase_old
      phase_old = phase
      if previous == nil or NEXT_PHASE[previous] ~= phase then
        return
      end
      core.SetTimeout(TheWorld, function()
        core.Call(fn, phase)
      end, 0)
    end))
  end))
end
