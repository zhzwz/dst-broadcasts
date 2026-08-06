--- 判断当前是否服务器模拟（不要用 not：TheWorld 可能未就绪）。
--- @return boolean
core.IsServer = function()
  return TheWorld ~= nil and TheWorld.ismastersim == true
end
