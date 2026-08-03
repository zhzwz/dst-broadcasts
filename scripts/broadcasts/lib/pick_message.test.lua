--[[
  BROADCASTS_PICK_MESSAGE 单测。
  运行：bun run test
]]

local root = arg[0]:match("^(.*)/") or "."
dofile(root .. "/pick_message.lua")

local Pick = BROADCASTS_PICK_MESSAGE
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

expect_eq(Pick(nil), nil, "nil -> nil")
expect_eq(Pick(""), nil, "empty string -> nil")
expect_eq(Pick("hello"), "hello", "non-empty string")
expect_eq(Pick({}), nil, "empty table -> nil")
expect_eq(Pick({ "", nil, false }), nil, "no valid strings -> nil")
expect_eq(Pick({ "", "only" }), "only", "skips empty, single valid")

do
  local options = { "a", "b", "c" }
  local seen = {}
  for _ = 1, 40 do
    local picked = Pick(options)
    expect(picked == "a" or picked == "b" or picked == "c", "random pick in set")
    if picked ~= nil then
      seen[picked] = true
    end
  end
  expect(seen.a or seen.b or seen.c, "at least one pick recorded")
end

if failed > 0 then
  io.stderr:write(string.format("%d assertion(s) failed\n", failed))
  os.exit(1)
end
print("pick_message: ok")
