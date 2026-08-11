--- @alias WorldSide "server" | "client" | "both"


local function IsClientSide()
  return TheWorld ~= nil and TheWorld.ismastersim == false
end

local function IsServerSide()
  return TheWorld ~= nil and TheWorld.ismastersim == true
end

--- @param side WorldSide
local function IsCorrectSide(side)
  return side == "both"
      or (side == "server" and IsServerSide())
      or (side == "client" and IsClientSide())
end

local function IsForest()
  return core.HasTag(TheWorld, "forest")
end

local function IsCave()
  return core.HasTag(TheWorld, "cave")
end

--- 监听昼夜循环轮数变化。
--- @param side WorldSide
--- @param callback fun(cycles: number)
local function ListenCycles(side, callback)
  AddSimPostInit(core.Wrap(function()
    if not IsCorrectSide(side) then return end
    --- 会话开始时记下的已是当前 cycles（读档/回档为重建世界）；cycles 从 0 起
    local cycles_old = core.Number(TheWorld.state.cycles) or 0
    TheWorld:WatchWorldState("cycles", core.Wrap(function(_, cycles)
      local cycles_new = core.Number(cycles) or 0
      local previous = cycles_old
      cycles_old = cycles_new
      --- 本局内非连续跳变不触发
      if previous + 1 ~= cycles_new then return end
      --- 延后到本帧末，避免与同期 WatchWorldState 打架
      TheWorld:DoTaskInTime(0, core.Wrap(function()
        core.Call(callback, cycles_new)
      end))
    end))
  end))
end

local NEXT_PHASE = { day = "dusk", dusk = "night", night = "day" }

--- 监听昼夜相位变化。
--- @param side WorldSide
--- @param callback fun(phase: string)
local function ListenPhase(side, callback)
  AddSimPostInit(core.Wrap(function()
    if not IsCorrectSide(side) then return end
    --- 森林看 phase，洞穴看 cavephase
    local key = IsCave() and "cavephase" or "phase"
    --- 会话开始时记下的已是当前相位（读档/回档为重建世界）
    local phase_old = TheWorld.state ~= nil and TheWorld.state[key] or nil
    TheWorld:WatchWorldState(key, core.Wrap(function(_, phase)
      local previous = phase_old
      phase_old = phase
      --- 仅 previous → 下一相位时回调
      if previous == nil or NEXT_PHASE[previous] ~= phase then return end
      --- 延后到本帧末，避免与同期 WatchWorldState 打架
      TheWorld:DoTaskInTime(0, core.Wrap(function() core.Call(callback, phase) end))
    end))
  end))
end

core.World = {
  IsClientSide = IsClientSide,
  IsServerSide = IsServerSide,
  IsCorrectSide = IsCorrectSide,
  IsForest = IsForest,
  IsCave = IsCave,
  ListenCycles = ListenCycles,
  ListenPhase = ListenPhase,
}
