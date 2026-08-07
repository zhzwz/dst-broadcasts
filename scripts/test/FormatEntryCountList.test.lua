--- core.FormatEntryCountList 单测。
--- 运行：bun run test
--- 或：lua scripts/test/FormatEntryCountList.test.lua

local here = arg[0]:match("^(.*)/") or "."
core = {}
i18n = { symbol = { enumeration = "、" } }
dofile(here .. "/../core/FormatEntryCount.lua")
dofile(here .. "/../core/FormatEntryCountList.lua")

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

expect_eq(
  core.FormatEntryCountList({ ["土豆"] = 10, ["胡萝卜"] = 8 }),
  "土豆×10、胡萝卜×8",
  "list sorted by name with i18n symbol.enumeration"
)
expect_eq(core.FormatEntryCountList({ ["空"] = 0 }), nil, "all zero -> nil")
expect_eq(core.FormatEntryCountList({}), nil, "empty map -> nil")
expect_eq(core.FormatEntryCountList(nil), nil, "nil map -> nil")

if failed > 0 then
  io.stderr:write(string.format("%d assertion(s) failed\n", failed))
  os.exit(1)
end
print("FormatEntryCountList: ok")
