--[[
  统一错误隔离：游戏回调 / API 读取失败时只记日志，不拖垮服务器。
  debug_enabled 开启时，同步公告到当前分片。
]]

local C = BROADCASTS_CONSTANTS

local function Report(tag, err)
    local message = string.format("%s %s: %s", C.LOG_PREFIX, tostring(tag or "?"), tostring(err))
    print(message)

    if not GetModConfigData("debug_enabled") then
        return
    end

    local chat = message
    local max_len = C.DEBUG_CHAT_MAX
    if #chat > max_len then
        chat = string.sub(chat, 1, max_len - 3) .. "..."
    end
    -- 直接 Announce，避免经 Call/Announce 形成递归
    pcall(function()
        TheNet:Announce(chat)
    end)
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
