--[[
  日时段门闩（无 DST 依赖）：跨天、相位切换判定。
]]

local function IsCyclesIncrement(previous, cycles)
  return type(cycles) == "number"
      and type(previous) == "number"
      and cycles == previous + 1
      and cycles > 0
end

--- previous → phase 是否为 from → to（如 day → dusk）
local function IsPhaseTransition(previous, phase, from_phase, to_phase)
  return previous == from_phase and phase == to_phase
end

--- 森林用 phase，洞穴用 cavephase
local function PhaseStateKey(is_cave)
  return is_cave and "cavephase" or "phase"
end

BROADCASTS_DAY_SLOT = {
  IsCyclesIncrement = IsCyclesIncrement,
  IsPhaseTransition = IsPhaseTransition,
  PhaseStateKey = PhaseStateKey,
}
