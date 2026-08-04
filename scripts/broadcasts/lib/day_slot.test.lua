--[[
  BROADCASTS_DAY_SLOT 单测。
]]

local root = arg[0]:match("^(.*)/") or "."
dofile(root .. "/day_slot.lua")

local D = BROADCASTS_DAY_SLOT
local failed = 0

local function expect(cond, message)
  if not cond then
    failed = failed + 1
    io.stderr:write("FAIL: " .. message .. "\n")
  end
end

local function expect_eq(actual, expected, message)
  expect(actual == expected, string.format("%s (got %s, want %s)", message, tostring(actual), tostring(expected)))
end

expect(D.IsCyclesIncrement(10, 11), "10 -> 11 day start")
expect(not D.IsCyclesIncrement(10, 12), "skip jump")
expect(not D.IsCyclesIncrement(10, 10), "skip same")
expect(D.IsCyclesIncrement(0, 1), "0 -> 1 first morning")
expect(not D.IsCyclesIncrement(nil, 1), "nil previous")
expect(not D.IsCyclesIncrement(5, nil), "nil cycles")

expect(D.IsPhaseTransition("day", "dusk", "day", "dusk"), "day -> dusk")
expect(not D.IsPhaseTransition("dusk", "dusk", "day", "dusk"), "dusk stay")
expect(not D.IsPhaseTransition(nil, "dusk", "day", "dusk"), "nil previous")
expect(D.IsPhaseTransition("dusk", "night", "dusk", "night"), "dusk -> night")
expect(not D.IsPhaseTransition("day", "night", "dusk", "night"), "day -> night skip")

expect_eq(D.PhaseStateKey(false), "phase", "forest phase key")
expect_eq(D.PhaseStateKey(true), "cavephase", "cave phase key")
expect_eq(D.PhaseStateKey(nil), "phase", "nil is_cave -> phase")

if failed > 0 then
  os.exit(1)
end
print("day_slot: ok")
