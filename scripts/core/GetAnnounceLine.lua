--- 读取角色的内置台词（`ANNOUNCE_COLD` / `ANNOUNCE_WET` / ...）。
--- @param key string
--- @param character Entity|nil
--- @return string|nil
core.GetAnnounceLine = function(key, character)
  if character == nil or type(key) ~= "string" or key == "" then
    return nil
  end

  --- 优先 GetString（按实体取角色台词，含幽灵等特例）
  if type(GetString) == "function" then
    local line = core.Call(GetString, character, key)
    if type(line) == "string" and line ~= "" and line ~= key then
      return line
    end
  end

  --- 回退 STRINGS.CHARACTERS（键为角色 prefab 大写或 GENERIC）
  local line = core.Call(function()
    if type(STRINGS) ~= "table" or type(STRINGS.CHARACTERS) ~= "table" then
      return nil
    end
    local speech = nil
    if type(character.prefab) == "string" then
      speech = STRINGS.CHARACTERS[string.upper(character.prefab)]
    end
    if type(speech) ~= "table" then
      speech = STRINGS.CHARACTERS.GENERIC
    end
    if type(speech) ~= "table" then
      return nil
    end
    local text = speech[key]
    if type(text) == "string" and text ~= "" then
      return text
    end
  end)

  if type(line) == "string" and line ~= "" then
    return line
  end
end
