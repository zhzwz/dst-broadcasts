core = {}

core.LOG_PREFIX = "[Broadcasts]"

--- 输出日志，支持多参数；自动加模组前缀。
core.Print = function(...)
  local n = select("#", ...)
  local parts = { core.LOG_PREFIX }
  for i = 1, n do
    table.insert(parts, tostring(select(i, ...)))
  end
  print(table.concat(parts, " "))
end


--- 安全调用函数，异常关在内部，避免拖垮游戏。
--- @param fn function 要执行的函数
--- @param ... unknown 传给 fn 的参数
--- @return unknown ... 成功时原样返回 fn 的返回值；失败时无返回值
core.Call = function(fn, ...)
  local results = { pcall(fn, ...) }
  local ok = results[1]
  if ok then
    return unpack(results, 2)
  end
  local errorMessage = results[2]
  core.Print(errorMessage)
end


--- 包装函数
--- @param fn function 原函数
--- @return function
core.Wrap = function(fn)
  return function(...)
    return core.Call(fn, ...)
  end
end

--- 将值转为 string；无法转换时返回 nil。
--- string 原样返回；number / boolean 用 tostring；其余类型为 nil。
--- @param value unknown
--- @return string|nil
core.String = function(value)
  local t = type(value)
  if t == "string" then
    return value
  end
  if t == "number" or t == "boolean" then
    return tostring(value)
  end
  return nil
end

--- 移除字符串首尾空白。
--- 先经 core.String 转换；无法转为 string 时返回 nil。
--- @param value unknown
--- @return string|nil
core.TrimString = function(value)
  local s = core.String(value)
  if s == nil then
    return nil
  end
  return (s:match("^%s*(.-)%s*$"))
end

--- 将字符串转为大写（ASCII；非字母字符不变）。
--- 先经 core.String 转换；无法转为 string 时返回 nil。
--- @param value unknown
--- @return string|nil
core.UpperString = function(value)
  local s = core.String(value)
  if s == nil then
    return nil
  end
  return string.upper(s)
end


--- 将值转为 number；无法转换时返回 nil。
--- number 原样返回；string 用 tonumber 解析（失败为 nil）；其余类型为 nil。
--- @param value unknown
--- @return number|nil
core.Number = function(value)
  local t = type(value)
  if t == "number" then
    return value
  end
  if t == "string" then
    return tonumber(value)
  end
  return nil
end

--- 从数组（ipairs）中随机取一项；非表或空数组返回 nil。
--- @param list table|nil
--- @return any
core.RandomPick = function(list)
  if type(list) ~= "table" then
    return nil
  end
  local choices = {}
  for _, item in ipairs(list) do
    table.insert(choices, item)
  end
  if #choices == 0 then
    return nil
  end
  return choices[math.random(#choices)]
end


modimport("scripts/core/DoTaskInTime.lua")
modimport("scripts/core/IsValid.lua")
modimport("scripts/core/HasTag.lua")
modimport("scripts/core/IsAlive.lua")
modimport("scripts/core/IsAtMinHealth.lua")
modimport("scripts/core/GetDisplayName.lua")
modimport("scripts/core/GetPrefabDisplayName.lua")
modimport("scripts/core/GetOwner.lua")
modimport("scripts/core/GetCount.lua")
modimport("scripts/core/FormatEntryCount.lua")
modimport("scripts/core/FormatEntryCountList.lua")
modimport("scripts/core/GetAnnounceLine.lua")
modimport("scripts/core/Bubble.lua")
modimport("scripts/core/Announce.lua")
modimport("scripts/core/IsServer.lua")
modimport("scripts/core/IsClient.lua")
modimport("scripts/core/IsCaveWorld.lua")
modimport("scripts/core/IsForestWorld.lua")
modimport("scripts/core/WatchCycles.lua")
modimport("scripts/core/WatchPhase.lua")
modimport("scripts/core/ListenSay.lua")
modimport("scripts/core/Shard.lua")
