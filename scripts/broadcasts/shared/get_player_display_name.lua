--[[
  安全读取玩家 GetDisplayName（不带方括号）。

  内部 pcall；失败或空串时返回 "?"。用于玩家状态类播报文案。

  @param player Entity|nil
  @return string
]]

local function GetPlayerDisplayName(player)
  if player == nil then
    return "?"
  end
  local ok, display_name = pcall(function()
    return player:GetDisplayName()
  end)
  if ok and type(display_name) == "string" and display_name ~= "" then
    return display_name
  end
  return "?"
end

BROADCASTS_GET_PLAYER_DISPLAY_NAME = GetPlayerDisplayName
