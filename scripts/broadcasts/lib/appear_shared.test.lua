--[[
  BROADCASTS_APPEAR_SHARED 单测。
]]

local root = arg[0]:match("^(.*)/") or "."
dofile(root .. "/appear_shared.lua")

local A = BROADCASTS_APPEAR_SHARED
local failed = 0

local function expect(cond, message)
  if not cond then
    failed = failed + 1
    io.stderr:write("FAIL: " .. message .. "\n")
  end
end

local store = {}
local key = "twins"

expect(A.TryClaim(store, key), "first claim announces")
expect(store[key] == true, "claimed")
expect(not A.TryClaim(store, key), "second claim skips")
expect(store[key] == true, "still claimed")

expect(not A.ReleaseIfEmpty(store, key, 2), "2 alive keeps claim")
expect(store[key] == true, "claim after 2")
expect(not A.ReleaseIfEmpty(store, key, 1), "1 alive keeps claim")
expect(store[key] == true, "claim after 1")
expect(A.ReleaseIfEmpty(store, key, 0), "0 alive releases")
expect(store[key] == nil, "released")

expect(A.TryClaim(store, key), "new wave can claim again")
expect(not A.TryClaim(store, key), "same wave second skips")

-- 同「帧」连续两次 claim：第二次必失败（单线程顺序）
local store2 = {}
expect(A.TryClaim(store2, "g"), "a claims")
expect(not A.TryClaim(store2, "g"), "b sees claim")

-- 自愈：claim 残留且场上只剩自己
local store3 = { stuck = true }
expect(A.TryClaimOrRecover(store3, "stuck", 1), "recover when alone")
expect(store3.stuck == true, "reclaimed")
expect(not A.TryClaimOrRecover(store3, "stuck", 2), "no recover when peers alive")
expect(store3.stuck == true, "peers keep claim")

local store4 = {}
expect(A.TryClaimOrRecover(store4, "k", 2), "first recover-path claim")
expect(not A.TryClaimOrRecover(store4, "k", 2), "second with peers skips")

if failed > 0 then
  os.exit(1)
end
print("appear_shared: ok")
