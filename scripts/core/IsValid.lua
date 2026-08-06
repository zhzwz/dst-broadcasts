--- 判断实体是否有效。
--- @param inst Entity|nil
--- @return boolean
core.IsValid = function(inst)
  if inst == nil then
    return false
  end
  if type(inst.IsValid) ~= "function" then
    return false
  end
  return core.Call(inst.IsValid, inst) == true
end
