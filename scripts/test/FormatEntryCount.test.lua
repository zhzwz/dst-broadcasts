--- core.FormatEntryCount 单测。
--- 运行：bun run test
--- 或：lua scripts/test/FormatEntryCount.test.lua

local here = arg[0]:match("^(.*)/") or "."
core = {}
dofile(here .. "/../core/FormatEntryCount.lua")

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

expect_eq(core.FormatEntryCount("胡萝卜", 8), "胡萝卜×8", "named entry")
expect_eq(core.FormatEntryCount("土豆", 10.9), "土豆×10", "floors amount")
expect_eq(core.FormatEntryCount("", 1), nil, "empty name -> nil")
expect_eq(core.FormatEntryCount("x", 0), nil, "zero -> nil")
expect_eq(core.FormatEntryCount("x", -1), nil, "negative -> nil")
expect_eq(core.FormatEntryCount("x", 0 / 0), nil, "nan -> nil")
expect_eq(core.FormatEntryCount(nil, 1), nil, "nil name -> nil")

if failed > 0 then
  io.stderr:write(string.format("%d assertion(s) failed\n", failed))
  os.exit(1)
end
print("FormatEntryCount: ok")
