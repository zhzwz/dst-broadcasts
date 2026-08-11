--- 世界类型：官方用 tag（forest / cave）区分；`TheWorld.prefab` 会被设为 `"world"`。
--- 不要用 not 互推：可能未就绪，也可能是自定义世界。

core.World = {
  IsForest = function()
    return core.HasTag(TheWorld, "forest")
  end,
  IsCave = function()
    return core.HasTag(TheWorld, "cave")
  end,
}
