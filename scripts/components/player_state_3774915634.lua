--- 玩家级模组状态（挂玩家实体；随玩家跨分片与读档）。移除模组后不影响存档加载。

local State = Class(function(self, inst)
  self.inst = inst
  self.data = {}
end)

function State:Set(key, value)
  self.data[key] = value
end

function State:Get(key, default)
  local value = self.data[key]
  if value == nil then
    return default
  end
  return value
end

function State:OnSave()
  if next(self.data) == nil then
    return
  end
  return { data = self.data }
end

function State:OnLoad(saved)
  if type(saved) == "table" and type(saved.data) == "table" then
    self.data = saved.data
  end
end

return State
