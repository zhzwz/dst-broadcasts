--[[
  统一错误隔离：游戏回调 / API 读取失败时只记日志，不拖垮服务器。
]]

local C = BROADCASTS_CONSTANTS

local function Report(tag, err)
  print(string.format("%s %s: %s", C.LOG_PREFIX, tostring(tag or "?"), tostring(err)))
end

local function Call(tag, fn, ...)
  local results = { pcall(fn, ...) }
  if not results[1] then
    Report(tag, results[2])
    return
  end
  return unpack(results, 2)
end

local function Wrap(tag, fn)
  return function(...)
    return Call(tag, fn, ...)
  end
end

local function Announce(message)
  if type(message) ~= "string" or message == "" then
    return
  end
  Call("announce", function()
    TheNet:Announce(message)
  end)
end

BROADCASTS_SAFE = {
  Call = Call,
  Wrap = Wrap,
  Announce = Announce,
}
