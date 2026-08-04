--[[
  shared 现身波次（无 DST 依赖）：先 claim，全灭后再释放。
]]

--- @return boolean 是否首次占位（应播报）
local function TryClaim(store, key)
  if store[key] then
    return false
  end
  store[key] = true
  return true
end

--- living_count == 0 时清除占位，允许下一波再播
--- @return boolean 是否已释放
local function ReleaseIfEmpty(store, key, living_count)
  if living_count == 0 then
    store[key] = nil
    return true
  end
  return false
end

--- 正常 TryClaim；失败且 living_count <= 1 时视为残留 claim，清掉再占一次（自愈）
--- @return boolean 是否应播报
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

BROADCASTS_APPEAR_SHARED = {
  TryClaim = TryClaim,
  ReleaseIfEmpty = ReleaseIfEmpty,
  TryClaimOrRecover = TryClaimOrRecover,
}
