-- 当前分片是否主机（ismastersim）；TheWorld 未就绪时为 false
-- @return boolean
local function IsMaster()
  return TheWorld ~= nil and TheWorld.ismastersim == true
end

-- 当前分片是否洞穴世界；TheWorld 未就绪时为 false
-- @return boolean
local function IsCave()
  return TheWorld ~= nil and TheWorld:HasTag("cave")
end

mod.World = {
  IsMaster = IsMaster,
  IsCave = IsCave,
}
