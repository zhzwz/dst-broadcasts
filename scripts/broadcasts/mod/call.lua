--- 安全调用：pcall 执行 fn，异常关在模组内，避免拖垮主机
--- @param tag string 写入日志的标签（如 "announce"）
--- @param fn function 要执行的函数
--- @param ... any 传给 fn 的参数
--- @return any ... 成功时原样返回 fn 的返回值；失败时无返回值
local function Call(tag, fn, ...)
  local results = { pcall(fn, ...) }

  local ok = results[1]
  if not ok then
    local errorMessage = results[2]
    mod.Print(tag, errorMessage)
    return
  end

  return unpack(results, 2)
end

mod.Call = Call
