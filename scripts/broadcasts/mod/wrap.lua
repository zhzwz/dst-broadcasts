--- 包装函数，内部走 `mod.Call`
--- @param tag string 写入日志的标签
--- @param fn function 原函数
--- @return function
local function Wrap(tag, fn)
  return function(...)
    return mod.Call(tag, fn, ...)
  end
end

mod.Wrap = Wrap
