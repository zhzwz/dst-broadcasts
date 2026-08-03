--[[
  从字符串或字符串数组中选取一条文案。
  - string：非空则原样返回，否则 nil
  - table：在 ipairs 的非空字符串中 math.random 取一条；无可选项则 nil
  - 其他类型：nil
]]

local function PickMessage(messages)
  if type(messages) == "string" then
    if messages ~= "" then
      return messages
    end
    return nil
  end
  if type(messages) ~= "table" then
    return nil
  end

  local choices = {}
  for _, message in ipairs(messages) do
    if type(message) == "string" and message ~= "" then
      choices[#choices + 1] = message
    end
  end
  if #choices == 0 then
    return nil
  end
  return choices[math.random(#choices)]
end

BROADCASTS_PICK_MESSAGE = PickMessage
