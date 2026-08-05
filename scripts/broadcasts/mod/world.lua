--- 判断当前是否服务器模拟（不要使用 not，可能未就绪）
--- @return boolean
local function IsServer()
  return TheWorld ~= nil and TheWorld.ismastersim == true
end

--- 判断当前是否客户端（不要使用 not，可能未就绪）
--- @return boolean
local function IsClient()
  return TheWorld ~= nil and TheWorld.ismastersim == false
end

--- 判断当前分片是否洞穴世界（不要使用 not，可能未就绪，也可能是自定义世界）
--- @return boolean
local function IsCave()
  return TheWorld ~= nil and TheWorld.prefab == "cave"
end

--- 判断当前分片是否森林世界（不要使用 not，可能未就绪，也可能是自定义世界）
--- @return boolean
local function IsForest()
  return TheWorld ~= nil and TheWorld.prefab == "forest"
end

mod.World = {
  IsServer = IsServer,
  IsClient = IsClient,
  IsCave = IsCave,
  IsForest = IsForest,
}
