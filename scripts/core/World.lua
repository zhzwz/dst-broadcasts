--- 世界类型：官方用 tag（forest / cave）区分；`TheWorld.prefab` 会被设为 `"world"`。
--- 端别：不要用 not 互推（TheWorld 可能未就绪）。
--- 世界类型也不要用 not 互推：可能未就绪，也可能是自定义世界。

core.World = {
  IsServerSide = function()
    return TheWorld ~= nil and TheWorld.ismastersim == true
  end,
  IsClientSide = function()
    return TheWorld ~= nil and TheWorld.ismastersim == false
  end,
  IsForest = function()
    return core.HasTag(TheWorld, "forest")
  end,
  IsCave = function()
    return core.HasTag(TheWorld, "cave")
  end,
}
