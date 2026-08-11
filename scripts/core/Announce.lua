--- 全服系统公告（左下角公屏；森林/洞穴均可见）。
--- @param message string 公告正文
--- @param source Entity|nil 发言来源；nil 为系统；玩家实体时关联其 entity
core.Announce = function(message, source)
  local m = core.TrimString(message)
  if m == nil or m == "" or TheNet == nil or type(TheNet.Announce) ~= "function" then
    return
  end

  local ent = nil
  local flag = nil
  if source ~= nil and core.IsValid(source) and core.HasTag(source, "player") then
    --- @cast source Entity
    ent = source.entity
    flag = true
  end

  --- 引擎：TheNet:Announce(message, entity, flag, category)
  core.Call(TheNet.Announce, TheNet, m, ent, flag, nil)
end
