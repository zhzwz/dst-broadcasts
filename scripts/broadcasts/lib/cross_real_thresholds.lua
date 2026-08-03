--[[
  现实时间阈值跨越（纯函数）。

  用于倒计时类播报：在剩余秒数落入某一档时，判断本 tick 新跨越了哪些阈值。

  @param seconds number 当前剩余秒数（调用方保证为有效正数）
  @param thresholds number[] 阈值列表（秒），不必有序
  @param flags table 已播报标记表；键为阈值，真值表示已处理过
      - 当 seconds > th 时，会清除 flags[th]，以便计时器回升后可再次播报
      - 新跨越的档位由调用方在确认播报成功后再写入 flags

  @return lowest number|nil 本 tick 应播报的最短新跨越阈值；无则 nil
  @return newly_crossed number[] 本 tick 全部新跨越的阈值（供调用方一次性标记）
]]

local function CrossRealThresholds(seconds, thresholds, flags)
  local lowest = nil
  local newly_crossed = {}
  for _, th in ipairs(thresholds) do
    if seconds <= th then
      if not flags[th] then
        newly_crossed[#newly_crossed + 1] = th
        if lowest == nil or th < lowest then
          lowest = th
        end
      end
    else
      flags[th] = nil
    end
  end
  return lowest, newly_crossed
end

BROADCASTS_CROSS_REAL_THRESHOLDS = CrossRealThresholds
