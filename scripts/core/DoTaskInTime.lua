--- 在实体上延迟执行任务（自动 core.Wrap，异常不会拖垮主机）。
--- 调用方须保证 inst 有效且支持 DoTaskInTime。
---
--- @class CoreTaskHost
--- @field DoTaskInTime fun(self: CoreTaskHost, time: number, fn: function, ...: any): PeriodicTask
---
--- @param inst CoreTaskHost|nil 挂载任务的实体（如 player / TheWorld）
--- @param fn function 到期后执行的函数
--- @param wait number 延迟秒数
--- @return PeriodicTask|nil task；inst 无效时为 nil
core.DoTaskInTime = function(inst, fn, wait)
  if inst == nil then
    return nil
  end
  if type(inst.DoTaskInTime) ~= "function" then
    return nil
  end
  return inst:DoTaskInTime(wait, core.Wrap(fn))
end
