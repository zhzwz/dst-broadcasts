--[[
  BROADCASTS_HARVEST_ANNOUNCE 单测。
  运行：bun run test
  或：lua scripts/broadcasts/lib/harvest_announce.test.lua
]]

local root = arg[0]:match("^(.*)/") or "."
dofile(root .. "/harvest_announce.lua")

local H = BROADCASTS_HARVEST_ANNOUNCE
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

-- phase 门闩
expect(H.ShouldAnnounceOnPhase("day", "dusk"), "day -> dusk announces")
expect(not H.ShouldAnnounceOnPhase(nil, "dusk"), "nil -> dusk skips")
expect(not H.ShouldAnnounceOnPhase("dusk", "dusk"), "dusk -> dusk skips")
expect(not H.ShouldAnnounceOnPhase("night", "dusk"), "night -> dusk skips")
expect(not H.ShouldAnnounceOnPhase("day", "night"), "day -> night skips")
expect(not H.ShouldAnnounceOnPhase("day", "day"), "day -> day skips")

-- CaveMark
expect_eq(H.CaveMark(false, "（洞穴）"), "", "forest -> empty mark")
expect_eq(H.CaveMark(true, "（洞穴）"), "（洞穴）", "cave -> mark")
expect_eq(H.CaveMark(true, nil), "", "cave with nil mark -> empty")
expect_eq(H.CaveMark(true, 1), "", "cave with non-string mark -> empty")
expect_eq(H.CaveMark(false, nil), "", "forest nil mark -> empty")

-- "%s×%d" 拼接
expect_eq(H.FormatNamedCountEntry("[胡萝卜]", 8), "[胡萝卜]×8", "named entry")
expect_eq(H.FormatNamedCountEntry("[土豆]", 10.9), "[土豆]×10", "floors amount")
expect_eq(H.FormatNamedCountEntry("", 1), nil, "empty name -> nil")
expect_eq(H.FormatNamedCountEntry("[x]", 0), nil, "zero -> nil")
expect_eq(H.FormatNamedCountEntry("[x]", -1), nil, "negative -> nil")
expect_eq(H.FormatNamedCountEntry("[x]", 0 / 0), nil, "nan -> nil")
expect_eq(H.FormatNamedCountEntry(nil, 1), nil, "nil name -> nil")

expect_eq(
  H.FormatNamedCountList({ ["[土豆]"] = 10, ["[胡萝卜]"] = 8 }, "、"),
  "[土豆]×10、[胡萝卜]×8",
  "list sorted by name"
)
expect_eq(H.FormatNamedCountList({ ["[空]"] = 0 }, "、"), nil, "all zero -> nil")
expect_eq(H.FormatNamedCountList({}, "、"), nil, "empty map -> nil")
expect_eq(H.FormatNamedCountList(nil, "、"), nil, "nil map -> nil")
expect_eq(
  H.FormatNamedCountList({ ["[a]"] = 1, ["[b]"] = 2 }, nil),
  "[a]×1, [b]×2",
  "nil separator defaults to comma-space"
)

-- 0 / 空跳过 + 文案拼装
local templates = {
  marbleshrub = "大理石%s待收获：大理石灌木×%d",
  beebox = "蜂箱%s待收获：蜂蜜×%d",
  farm = "农田%s待收获：%s",
  dried = "晾晒架%s待收获：%s",
}
local enabled_all = {
  marbleshrub = true,
  beebox = true,
  farmland = true,
  dryingrack = true,
}

do
  local lines = H.BuildAnnounceLines({
    mark = "",
    marbleshrub = 0,
    honey = 0,
    farm_list = nil,
    dried_list = "",
  }, enabled_all, templates)
  expect_eq(#lines, 0, "all empty -> no lines")
end

do
  local lines = H.BuildAnnounceLines({
    mark = "",
    marbleshrub = 3,
    honey = 12,
    farm_list = "[胡萝卜]×8，[土豆]×10",
    dried_list = "[肉干]×10",
  }, enabled_all, templates)
  expect_eq(#lines, 4, "four kinds -> four lines")
  expect_eq(lines[1], "大理石待收获：大理石灌木×3", "marbleshrub forest line")
  expect_eq(lines[2], "蜂箱待收获：蜂蜜×12", "beebox forest line")
  expect_eq(lines[3], "农田待收获：[胡萝卜]×8，[土豆]×10", "farm forest line")
  expect_eq(lines[4], "晾晒架待收获：[肉干]×10", "dried forest line")
end

do
  local lines = H.BuildAnnounceLines({
    mark = "（洞穴）",
    marbleshrub = 3,
    honey = 0,
    farm_list = nil,
    dried_list = "[肉干]×2",
  }, enabled_all, templates)
  expect_eq(#lines, 2, "zeros skipped in cave")
  expect_eq(lines[1], "大理石（洞穴）待收获：大理石灌木×3", "cave mark in marbleshrub")
  expect_eq(lines[2], "晾晒架（洞穴）待收获：[肉干]×2", "cave mark in dried")
end

do
  local lines = H.BuildAnnounceLines({
    mark = "",
    marbleshrub = 9,
    honey = 9,
    farm_list = "[x]×1",
    dried_list = "[y]×1",
  }, {
    marbleshrub = false,
    beebox = true,
    farmland = false,
    dryingrack = false,
  }, templates)
  expect_eq(#lines, 1, "disabled kinds skipped")
  expect_eq(lines[1], "蜂箱待收获：蜂蜜×9", "only enabled beebox")
end

if failed > 0 then
  io.stderr:write(string.format("%d assertion(s) failed\n", failed))
  os.exit(1)
end
print("harvest_announce: ok")
