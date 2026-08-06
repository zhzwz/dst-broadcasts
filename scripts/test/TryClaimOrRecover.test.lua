--- TryClaim / ReleaseIfEmpty / TryClaimOrRecover 单测（与 scripts/features/appear.lua 内逻辑一致）。
--- 运行：bun run test
--- 或：lua scripts/test/TryClaimOrRecover.test.lua

local failed = 0

local function expect(cond, message)
  if not cond then
    failed = failed + 1
    io.stderr:write("FAIL: " .. message .. "\n")
  end
end

local function TryClaim(store, key)
  if store[key] then
    return false
  end
  store[key] = true
  return true
end

local function ReleaseIfEmpty(store, key, living_count)
  if living_count == 0 then
    store[key] = nil
    return true
  end
  return false
end

local function TryClaimOrRecover(store, key, living_count)
  if TryClaim(store, key) then
    return true
  end
  if living_count > 1 then
    return false
  end
  store[key] = nil
  return TryClaim(store, key)
end

local store = {}
local key = "twins"

expect(TryClaim(store, key), "first claim announces")
expect(store[key] == true, "claimed")
expect(not TryClaim(store, key), "second claim skips")
expect(store[key] == true, "still claimed")

expect(not ReleaseIfEmpty(store, key, 2), "2 alive keeps claim")
expect(store[key] == true, "claim after 2")
expect(not ReleaseIfEmpty(store, key, 1), "1 alive keeps claim")
expect(store[key] == true, "claim after 1")
expect(ReleaseIfEmpty(store, key, 0), "0 alive releases")
expect(store[key] == nil, "released")

expect(TryClaim(store, key), "new wave can claim again")
expect(not TryClaim(store, key), "same wave second skips")

local store2 = {}
expect(TryClaim(store2, "g"), "a claims")
expect(not TryClaim(store2, "g"), "b sees claim")

local store3 = { stuck = true }
expect(TryClaimOrRecover(store3, "stuck", 1), "recover when alone")
expect(store3.stuck == true, "reclaimed")
expect(not TryClaimOrRecover(store3, "stuck", 2), "no recover when peers alive")
expect(store3.stuck == true, "peers keep claim")

local store4 = {}
expect(TryClaimOrRecover(store4, "k", 2), "first recover-path claim")
expect(not TryClaimOrRecover(store4, "k", 2), "second with peers skips")

if failed > 0 then
  os.exit(1)
end
print("TryClaimOrRecover: ok")
