--[[
  日时段门闩（无 DST 依赖）：相位切换判定。
]]

--- previous → phase 是否为 from → to（如 day → dusk）
local function IsPhaseTransition(previous, phase, from_phase, to_phase)
  return previous == from_phase and phase == to_phase
end

--- 森林用 phase，洞穴用 cavephase
local function PhaseStateKey(is_cave)
  return is_cave and "cavephase" or "phase"
end

BROADCASTS_DAY_SLOT = {
  IsPhaseTransition = IsPhaseTransition,
  PhaseStateKey = PhaseStateKey,
}
