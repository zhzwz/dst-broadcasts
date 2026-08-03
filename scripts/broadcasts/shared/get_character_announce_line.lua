--[[
  读取角色内置播报台词（如 ANNOUNCE_COLD / ANNOUNCE_WET）。
  优先 GetString(player, key)，失败则回退 STRINGS.CHARACTERS。
  FormatCharacterQuote 按当前语言的 character_quote 加引号（缺省为 ASCII "..."）。
]]

local function GetCharacterAnnounceLine(player, announce_key)
  if player == nil or type(announce_key) ~= "string" or announce_key == "" then
    return nil
  end
  if type(GetString) == "function" then
    local ok, line = pcall(GetString, player, announce_key)
    if ok and type(line) == "string" and line ~= "" and line ~= announce_key then
      return line
    end
  end
  if type(STRINGS) ~= "table" or type(STRINGS.CHARACTERS) ~= "table" then
    return nil
  end
  local prefab = player.prefab
  local speech = nil
  if type(prefab) == "string" then
    speech = STRINGS.CHARACTERS[string.upper(prefab)]
  end
  if type(speech) ~= "table" then
    speech = STRINGS.CHARACTERS.GENERIC
  end
  if type(speech) ~= "table" then
    return nil
  end
  local line = speech[announce_key]
  if type(line) == "string" and line ~= "" then
    return line
  end
  return nil
end

-- S.character_quote 为 string.format 模板，宜含前导空格（西文）或紧贴前句（中日韩）
local function FormatCharacterQuote(line)
  if type(line) ~= "string" or line == "" then
    return nil
  end
  local fmt = type(BROADCASTS_STRINGS) == "table" and BROADCASTS_STRINGS.character_quote or nil
  if type(fmt) == "string" and fmt ~= "" then
    local ok, wrapped = pcall(string.format, fmt, line)
    if ok and type(wrapped) == "string" and wrapped ~= "" then
      return wrapped
    end
  end
  return ' "' .. line .. '"'
end

local function GetQuotedCharacterAnnounceLine(player, announce_key)
  local line = GetCharacterAnnounceLine(player, announce_key)
  if line == nil then
    return nil
  end
  return FormatCharacterQuote(line)
end

BROADCASTS_GET_CHARACTER_ANNOUNCE_LINE = GetCharacterAnnounceLine
BROADCASTS_FORMAT_CHARACTER_QUOTE = FormatCharacterQuote
BROADCASTS_GET_QUOTED_CHARACTER_ANNOUNCE_LINE = GetQuotedCharacterAnnounceLine
