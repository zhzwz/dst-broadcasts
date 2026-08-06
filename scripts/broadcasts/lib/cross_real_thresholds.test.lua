--- BROADCASTS_CROSS_REAL_THRESHOLDS 单测。
--- 运行：bun run test
--- 或：lua scripts/broadcasts/lib/cross_real_thresholds.test.lua

local root = arg[0]:match("^(.*)/") or "."
dofile(root .. "/cross_real_thresholds.lua")

local Cross = BROADCASTS_CROSS_REAL_THRESHOLDS
local THRESHOLDS = { 480, 240, 120, 60, 30, 10, 5 }

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

do
  local flags = {}
  local lowest, crossed = Cross(500, THRESHOLDS, flags)
  expect_eq(lowest, nil, "above all thresholds -> nil")
  expect_eq(#crossed, 0, "above all thresholds -> no crosses")
end

do
  local flags = {}
  local lowest, crossed = Cross(480, THRESHOLDS, flags)
  expect_eq(lowest, 480, "exact 480 -> announce 480")
  expect_eq(#crossed, 1, "exact 480 -> one cross")
  for _, th in ipairs(crossed) do
    flags[th] = true
  end
  lowest = Cross(479, THRESHOLDS, flags)
  expect_eq(lowest, nil, "still in 480 window after mark -> nil")
end

do
  local flags = {}
  local lowest, crossed = Cross(25, THRESHOLDS, flags)
  expect_eq(lowest, 30, "jump to 25s -> announce shortest 30")
  expect_eq(#crossed, 5, "jump to 25s crosses 480..30")
  for _, th in ipairs(crossed) do
    flags[th] = true
  end
  lowest = Cross(25, THRESHOLDS, flags)
  expect_eq(lowest, nil, "same window after mark -> nil")
  lowest, crossed = Cross(5, THRESHOLDS, flags)
  expect_eq(lowest, 5, "reach 5s -> announce 5")
  expect_eq(#crossed, 2, "reach 5s crosses 10 and 5")
end

do
  local flags = { [480] = true, [240] = true, [120] = true, [60] = true, [30] = true, [10] = true, [5] = true }
  local lowest = Cross(500, THRESHOLDS, flags)
  expect_eq(lowest, nil, "extend above 480 clears and stays nil")
  expect(flags[480] == nil, "flag 480 cleared when seconds > 480")
  expect(flags[5] == nil, "flag 5 cleared when seconds > 5")
  lowest = Cross(480, THRESHOLDS, flags)
  expect_eq(lowest, 480, "re-enter 480 after extend -> announce again")
end

if failed > 0 then
  io.stderr:write(string.format("%d test(s) failed\n", failed))
  os.exit(1)
end
print("cross_real_thresholds: ok")
