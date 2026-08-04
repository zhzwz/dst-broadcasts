--[[
  安全调用：用 pcall 执行 fn，把异常关在模组内，避免拖垮主机。

  @param tag string|any  写入日志的标签，便于定位来源（如 "announce"）
  @param fn  function    要执行的函数
  @param ...             传给 fn 的参数
  @return                成功时原样返回 fn 的所有返回值；失败时打日志并返回 nil
]]
local function Call(tag, fn, ...)
  -- results[1] 为 pcall 是否成功；其后为 fn 的返回值，或失败时的错误信息
  local results = { pcall(fn, ...) }
  if not results[1] then
    mod.Print(tag, results[2])
    return
  end
  -- 去掉成功标志，把 fn 的返回值逐个传出（Lua 5.1 用 unpack）
  return unpack(results, 2)
end

mod.Call = Call
