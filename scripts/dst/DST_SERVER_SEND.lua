--- 主机向全服发送公屏消息（Announce 或 SystemMessage）。
--- @param message string 正文
--- @param system boolean|nil true 走 SystemMessage，否则 Announce
DST_SERVER_SEND = function(message, system)
  if type(message) ~= "string" then
    return
  end
  message = message:match("^%s*(.-)%s*$")
  if message == nil or message == "" or TheNet == nil then
    return
  end

  if system then
    if type(TheNet.SystemMessage) ~= "function" then
      return
    end
    local ok, err = pcall(TheNet.SystemMessage, TheNet, message)
    if not ok then
      print(err)
    end
    return
  end

  if type(TheNet.Announce) ~= "function" then
    return
  end
  local ok, err = pcall(TheNet.Announce, TheNet, message)
  if not ok then
    print(err)
  end
end
