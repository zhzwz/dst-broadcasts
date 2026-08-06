--- 判断实体是否带有指定标签。
--- @param inst Entity|nil
--- @param tag string
--- @return boolean
core.HasTag = function(inst, tag)
  if inst == nil or type(tag) ~= "string" then
    return false
  end
  if type(inst.HasTag) ~= "function" then
    return false
  end
  return core.Call(inst.HasTag, inst, tag) == true
end
