--- 天气播报：ListenWeather 编码变化时原地播报（非每天早上）。

core.ListenWeather(function(event)
  local labels = i18n.weather
  local parts = {}
  for _, key in ipairs(event.keys) do
    local label = labels[key]
    if label ~= nil and label ~= "" then
      table.insert(parts, label)
    end
  end
  if #parts == 0 then
    return
  end

  local template
  if core.World.IsCave() then
    template = labels.report_cave
  elseif core.World.IsForest() then
    template = labels.report_forest
  else
    return
  end

  core.Announce(string.format(template, table.concat(parts, i18n.symbol.comma)))
end)

--- 月雹
--- 在森林世界，当裂隙（月亮）存在时，每隔 10 天将会降下一场月雹，每次持续 90 秒。
--- 月雹发生时，如果当前正在发生降水，将会打断正在发生的降水。
--- 月雹期间，水分值持续消耗，因此在月雹结束时不会恢复之前的降水。
