--- 判断当前分片是否主机（未就绪时为否）
--- @return boolean
local function IsMaster()
  return TheWorld ~= nil and TheWorld.ismastersim == true
end

--- 判断当前分片是否洞穴世界（未就绪时为否，避开自定义模组世界）
--- @return boolean
local function IsCave()
  return TheWorld ~= nil and TheWorld.prefab == "cave"
end

--- 判断当前分片是否森林世界（未就绪时为否，避开自定义模组世界）
--- @return boolean
local function IsForest()
  return TheWorld ~= nil and TheWorld.prefab == "forest"
end

mod.World = {
  IsMaster = IsMaster,
  IsCave = IsCave,
  IsForest = IsForest,
}
