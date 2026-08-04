--[[
  BROADCASTS_CURRENT_WEATHER 单测。
  运行：bun run test
  或：lua scripts/broadcasts/lib/current_weather.test.lua
]]

local root = arg[0]:match("^(.*)/") or "."
dofile(root .. "/current_weather.lua")

local C = BROADCASTS_CURRENT_WEATHER
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

expect_eq(C.Classify(nil), "clear", "nil -> clear")
expect_eq(C.Classify({}), "clear", "empty -> clear")
expect_eq(C.Classify({ precipitation = "none" }), "clear", "none -> clear")

expect_eq(C.Classify({ precipitation = "acidrain" }), "acidrain", "acidrain")
expect_eq(C.Classify({ precipitation = "lunarhail" }), "lunarhail", "lunarhail")
expect_eq(C.Classify({ precipitation = "snow" }), "snow", "snow")

expect_eq(C.Classify({
  precipitation = "rain",
  precipitationrate = 0.3,
}), "rain", "light rain")

expect_eq(C.Classify({
  precipitation = "rain",
  precipitationrate = 0.7,
}), "heavy_rain", "heavy rain")

expect_eq(C.Classify({
  precipitation = "rain",
  precipitationrate = 0.55,
}), "rain", "rate == heavy stays rain")

expect_eq(C.Classify({
  precipitation = "rain",
  precipitationrate = 0.7,
  isspring = true,
  moistureceil = 3000,
}), "heavy_rain", "spring heavy rain is not frog rain")

expect_eq(C.Classify({
  precipitation = "none",
  sandstorm_active = true,
}), "sandstorm", "sandstorm when clear")

expect_eq(C.Classify({
  precipitation = "none",
  moonstorm_active = true,
}), "moonstorm", "moonstorm when clear")

expect_eq(C.Classify({
  precipitation = "none",
  sandstorm_active = true,
  moonstorm_active = true,
}), "sandstorm", "sandstorm before moonstorm")

expect_eq(C.Classify({
  precipitation = "rain",
  precipitationrate = 0.2,
  sandstorm_active = true,
}), "rain", "precip beats sandstorm")

if failed > 0 then
  os.exit(1)
end
print("current_weather: ok")
