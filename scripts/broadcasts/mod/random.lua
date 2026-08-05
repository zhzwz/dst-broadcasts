--- 随机获取数组的一项
--- @param list table|nil
--- @return any
local function Random(list)
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

mod.Random = Random
