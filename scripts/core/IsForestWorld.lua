--- 判断当前分片是否森林世界（不要用 not：可能未就绪，也可能是自定义世界）。
--- @return boolean
core.IsForestWorld = function()
  return TheWorld ~= nil and TheWorld.prefab == "forest"
end
