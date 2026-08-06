--- 保存 Broadcasts 的运行状态；移除模组后不会影响存档加载。

local State3774915634 = Class(function(self, inst)
  self.inst = inst
  self.data = {}
end)

function State3774915634:Get(key, default)
  local value = self.data[key]
  if value == nil then
    return default
  end
  return value
end

function State3774915634:Set(key, value)
  self.data[key] = value
end

function State3774915634:Increment(key, amount)
  local value = (self:Get(key, 0) or 0) + (amount or 1)
  self:Set(key, value)
  return value
end

function State3774915634:OnSave()
  if next(self.data) == nil then
    return
  end
  return { data = self.data }
end

function State3774915634:OnLoad(saved)
  if type(saved) == "table" and type(saved.data) == "table" then
    self.data = saved.data
  end
end

return State3774915634
