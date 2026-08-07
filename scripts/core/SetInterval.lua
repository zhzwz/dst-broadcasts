--- 在实体上按间隔反复执行任务（自动 core.Wrap，异常不会拖垮主机）。
--- 对应引擎 `inst:DoPeriodicTask`；调用方须保证 inst 有效。
---
--- @param inst CoreTaskHost|nil 挂载任务的实体（如 player / TheWorld）
--- @param fn function 每次到期执行的函数
--- @param interval number 间隔秒数
--- @return PeriodicTask|nil task；inst 无效时为 nil
core.SetInterval = function(inst, fn, interval)
  if inst == nil then
    return nil
  end
  if type(inst.DoPeriodicTask) ~= "function" then
    return nil
  end
  return inst:DoPeriodicTask(interval, core.Wrap(fn))
end
