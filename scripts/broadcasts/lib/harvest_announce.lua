--[[
  收获播报纯逻辑（无 DST 依赖）：相位门闩、洞穴标记、数量拼接、空项跳过。
]]

local function ShouldAnnounceOnPhase(previous, phase)
  return phase == "dusk" and previous == "day"
end

local function CaveMark(is_cave, mark)
  if not is_cave then
    return ""
  end
  if type(mark) ~= "string" then
    return ""
  end
  return mark
end

local function FormatNamedCountEntry(name, n)
  if type(name) ~= "string" or name == "" then
    return nil
  end
  if type(n) ~= "number" or n ~= n or n <= 0 then
    return nil
  end
  return string.format("%s×%d", name, math.floor(n))
end

--- counts: { [display_name] = amount }；separator 非 string 时默认 ", "
local function FormatNamedCountList(counts, separator)
  if type(counts) ~= "table" then
    return nil
  end
  local list = {}
  for name, n in pairs(counts) do
    local entry = FormatNamedCountEntry(name, n)
    if entry ~= nil then
      list[#list + 1] = { name = name, n = n, text = entry }
    end
  end
  if #list == 0 then
    return nil
  end
  table.sort(list, function(a, b)
    if a.name == b.name then
      return a.n < b.n
    end
    return a.name < b.name
  end)
  local parts = {}
  for _, item in ipairs(list) do
    parts[#parts + 1] = item.text
  end
  if type(separator) ~= "string" then
    separator = ", "
  end
  return table.concat(parts, separator)
end

--- 按启用项与数量生成待播报行（0 / 空列表跳过）。
--- data: mark, marbleshrub, honey, farm_list, dried_list
--- enabled: marbleshrub, beebox, farmland, dryingrack (bool)
--- templates: marbleshrub, beebox, farm, dried (format strings)
local function BuildAnnounceLines(data, enabled, templates)
  if type(data) ~= "table" or type(enabled) ~= "table" or type(templates) ~= "table" then
    return {}
  end

  local mark = data.mark
  if type(mark) ~= "string" then
    mark = ""
  end

  local lines = {}

  local marbleshrub = data.marbleshrub
  if enabled.marbleshrub
      and type(marbleshrub) == "number"
      and marbleshrub == marbleshrub
      and marbleshrub > 0
      and type(templates.marbleshrub) == "string" then
    lines[#lines + 1] = string.format(templates.marbleshrub, mark, math.floor(marbleshrub))
  end

  local honey = data.honey
  if enabled.beebox
      and type(honey) == "number"
      and honey == honey
      and honey > 0
      and type(templates.beebox) == "string" then
    lines[#lines + 1] = string.format(templates.beebox, mark, math.floor(honey))
  end

  local farm_list = data.farm_list
  if enabled.farmland
      and type(farm_list) == "string"
      and farm_list ~= ""
      and type(templates.farm) == "string" then
    lines[#lines + 1] = string.format(templates.farm, mark, farm_list)
  end

  local dried_list = data.dried_list
  if enabled.dryingrack
      and type(dried_list) == "string"
      and dried_list ~= ""
      and type(templates.dried) == "string" then
    lines[#lines + 1] = string.format(templates.dried, mark, dried_list)
  end

  return lines
end

BROADCASTS_HARVEST_ANNOUNCE = {
  ShouldAnnounceOnPhase = ShouldAnnounceOnPhase,
  CaveMark = CaveMark,
  FormatNamedCountEntry = FormatNamedCountEntry,
  FormatNamedCountList = FormatNamedCountList,
  BuildAnnounceLines = BuildAnnounceLines,
}
