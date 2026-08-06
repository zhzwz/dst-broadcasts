--- 判断当前分片是否洞穴世界（不要用 not：可能未就绪，也可能是自定义世界）。
--- @return boolean
core.IsCaveWorld = function()
  return TheWorld ~= nil and TheWorld.prefab == "cave"
end
