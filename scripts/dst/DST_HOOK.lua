--- 在 object[name] 之后追加 hook；原函数仍先执行，其返回值原样传出。
--- @param object table
--- @param name string
--- @param hook function
DST_HOOK = function(object, name, hook)
  if type(object) ~= "table" then return end
  if type(name) ~= "string" then return end
  if type(hook) ~= "function" then return end

  local original = object[name]
  object[name] = function(...)
    local results = nil
    if original ~= nil then
      results = { original(...) }
    end
    local ok, err = pcall(hook, ...)
    if not ok then
      print("DST_HOOK", name, err)
    end
    if results ~= nil then
      return unpack(results)
    end
  end
end
