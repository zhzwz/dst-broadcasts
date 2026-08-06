--- 判断当前是否客户端（不要用 not：TheWorld 可能未就绪）。
--- @return boolean
core.IsClient = function()
  return TheWorld ~= nil and TheWorld.ismastersim == false
end
