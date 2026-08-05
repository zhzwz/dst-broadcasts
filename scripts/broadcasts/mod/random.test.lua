--[[
  mod.Random 单测。
  运行：bun run test
]]

local root = arg[0]:match("^(.*)/") or "."
mod = {}
dofile(root .. "/random.lua")

local Random = mod.Random
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

expect_eq(Random(nil), nil, "nil -> nil")
-- expect_eq(Random(""), nil, "string -> nil")
-- expect_eq(Random("hello"), nil, "non-empty string -> nil")
-- expect_eq(Random(42), nil, "number -> nil")
-- expect_eq(Random(false), nil, "false -> nil")
expect_eq(Random({}), nil, "empty table -> nil")
expect_eq(Random({ false }), false, "single false")
expect_eq(Random({ "only" }), "only", "single element")

do
  local options = { "", "only" }
  for _ = 1, 20 do
    local picked = Random(options)
    expect(picked == "" or picked == "only", "empty string is a valid choice")
  end
end

do
  local options = { "a", "b", "c" }
  local seen = {}
  for _ = 1, 40 do
    local picked = Random(options)
    expect(picked == "a" or picked == "b" or picked == "c", "random pick in set")
    if picked ~= nil then
      seen[picked] = true
    end
  end
  expect(seen.a or seen.b or seen.c, "at least one pick recorded")
end

do
  local options = { 1, true, "x" }
  for _ = 1, 20 do
    local picked = Random(options)
    expect(picked == 1 or picked == true or picked == "x", "mixed types")
  end
end

if failed > 0 then
  io.stderr:write(string.format("%d assertion(s) failed\n", failed))
  os.exit(1)
end
print("random: ok")
