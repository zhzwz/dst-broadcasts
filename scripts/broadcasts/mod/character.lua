--- 读取角色的内置台词
--- @param player Entity|nil
--- @param announce_key string `ANNOUNCE_COLD` / `ANNOUNCE_WET` / ...
--- @return string|nil
local function GetAnnounceLine(player, announce_key)
  if player == nil or type(announce_key) ~= "string" or announce_key == "" then
    return nil
  end

  --- 优先 GetString
  --- 游戏 stringutil 提供的查词函数，按玩家实体取角色台词（含幽灵等特例）
  if type(GetString) == "function" then
    local line = mod.Call("mod.Character.GetAnnounceLine.GetString", GetString, player, announce_key)
    if type(line) == "string" and line ~= "" and line ~= announce_key then
      return line
    end
  end

  --- 回退 STRINGS.CHARACTERS
  --- 全局本地化表，键为角色 prefab 大写（如 WILSON）或 GENERIC
  local line = mod.Call("mod.Character.GetAnnounceLine.STRINGS", function()
    if type(STRINGS) ~= "table" or type(STRINGS.CHARACTERS) ~= "table" then
      return nil
    end
    local speech = nil
    if type(player.prefab) == "string" then
      speech = STRINGS.CHARACTERS[string.upper(player.prefab)]
    end
    if type(speech) ~= "table" then
      speech = STRINGS.CHARACTERS.GENERIC
    end
    if type(speech) ~= "table" then
      return nil
    end
    local text = speech[announce_key]
    if type(text) == "string" and text ~= "" then
      return text
    end
  end)

  if type(line) == "string" and line ~= "" then
    return line
  end
end

--- 读取角色内置台词并按当前语言加引号
--- @param player Entity|nil
--- @param announce_key string
--- @return string|nil
local function GetQuotedAnnounceLine(player, announce_key)
  local line = GetAnnounceLine(player, announce_key)
  if type(line) ~= "string" or line == "" then
    return nil
  end
  local fmt = i18n.character_quote or ' "%s"'
  return mod.Call("mod.Character.GetQuotedAnnounceLine", string.format, fmt, line)
end

mod.Character = {
  GetAnnounceLine = GetAnnounceLine,
  GetQuotedAnnounceLine = GetQuotedAnnounceLine,
}
