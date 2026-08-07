--- 真正过冷 / 过热时全服播报（与游戏伤害判定一致：current < 0 / current > overheattemp）。
--- 若 mintemp / maxtemp 或伤害速率已使角色无法真正受伤（如 WX-78 加热 / 制冷电路），则跳过。

local S = i18n

--- 与游戏伤害判定一致（过冷 current < 0；过热默认 70）
local TEMPERATURE_FREEZE_DAMAGE = 0
local TEMPERATURE_OVERHEAT_DAMAGE = 70
local function PlayerName(player)
  return core.GetDisplayName(player) or "?"
end

local ANNOUNCE_KEYS = {
  cold = "ANNOUNCE_COLD",
  hot = "ANNOUNCE_HOT",
}

local FREEZE_FLAG = "_dst_broadcasts_temp_freeze_warned"
local OVERHEAT_FLAG = "_dst_broadcasts_temp_overheat_warned"

local function GetTemperatureComponent(player)
  return player ~= nil and player.components ~= nil and player.components.temperature or nil
end

local function GetTemperature(player)
  local temperature = GetTemperatureComponent(player)
  if temperature == nil then
    return nil
  end
  if temperature.GetCurrent ~= nil then
    local ok, value = pcall(function()
      return temperature:GetCurrent()
    end)
    if ok and type(value) == "number" and value == value then
      return value
    end
  end
  if type(temperature.current) == "number" and temperature.current == temperature.current then
    return temperature.current
  end
  return nil
end

local function GetFreezeDamageTemp()
  local value = TEMPERATURE_FREEZE_DAMAGE
  if type(value) == "number" and value == value then
    return value
  end
  return 0
end

local function GetOverheatDamageTemp(player)
  local temperature = GetTemperatureComponent(player)
  if temperature ~= nil and type(temperature.overheattemp) == "number" and temperature.overheattemp == temperature.overheattemp then
    return temperature.overheattemp
  end
  if type(TUNING) == "table" and type(TUNING.OVERHEAT_TEMP) == "number" and TUNING.OVERHEAT_TEMP == TUNING.OVERHEAT_TEMP then
    return TUNING.OVERHEAT_TEMP
  end
  local value = TEMPERATURE_OVERHEAT_DAMAGE
  if type(value) == "number" and value == value then
    return value
  end
  return 70
end

--- 游戏过冷判定为 current < freeze；mintemp 已不低于该值时体温无法进入过冷
--- 加热电路（WX-78）会抬高 mintemp；hurtrate ≤ 0 表示完全免疫过冷伤害
local function CanTakeFreezeDamage(player)
  local temperature = GetTemperatureComponent(player)
  if temperature == nil then
    return true
  end
  local freeze = GetFreezeDamageTemp()
  if type(temperature.mintemp) == "number" and temperature.mintemp >= freeze then
    return false
  end
  if type(temperature.hurtrate) == "number" and temperature.hurtrate <= 0 then
    return false
  end
  return true
end

--- 游戏过热判定为 current > overheattemp；maxtemp 已不高于该值时体温无法进入过热
--- 制冷电路（WX-78）会压低 maxtemp；overheathurtrate / hurtrate ≤ 0 表示完全免疫过热伤害
local function CanTakeOverheatDamage(player)
  local temperature = GetTemperatureComponent(player)
  if temperature == nil then
    return true
  end
  local overheat = GetOverheatDamageTemp(player)
  local maxtemp = temperature.maxtemp
  if temperature.GetMax ~= nil then
    local ok, value = pcall(function()
      return temperature:GetMax()
    end)
    if ok and type(value) == "number" and value == value then
      maxtemp = value
    end
  end
  if type(maxtemp) == "number" and maxtemp <= overheat then
    return false
  end
  local rate = temperature.overheathurtrate
  if type(rate) ~= "number" then
    rate = temperature.hurtrate
  end
  if type(rate) == "number" and rate <= 0 then
    return false
  end
  return true
end

local function IsFreezingNow(player, current)
  local temperature = GetTemperatureComponent(player)
  if temperature ~= nil and temperature.IsFreezing ~= nil then
    local ok, value = pcall(function()
      return temperature:IsFreezing()
    end)
    if ok and type(value) == "boolean" then
      return value
    end
  end
  return current < GetFreezeDamageTemp()
end

local function IsOverheatingNow(player, current)
  local temperature = GetTemperatureComponent(player)
  if temperature ~= nil and temperature.IsOverheating ~= nil then
    local ok, value = pcall(function()
      return temperature:IsOverheating()
    end)
    if ok and type(value) == "boolean" then
      return value
    end
  end
  return current > GetOverheatDamageTemp(player)
end

local function AnnounceTemperature(player, key)
  local messages = type(S.player_temperature) == "table" and S.player_temperature[key] or nil
  local template = core.RandomPick(messages)
  if template == nil then
    return
  end
  core.Announce(string.format(template, PlayerName(player)))
  local line = core.GetAnnounceLine(ANNOUNCE_KEYS[key], player)
  if line ~= nil then
    core.PlayerBubble(line, player)
  end
end

local function CheckTemperature(player, current, last)
  if player == nil or not player:IsValid() then
    return
  end
  if player:HasTag("playerghost") then
    player[FREEZE_FLAG] = nil
    player[OVERHEAT_FLAG] = nil
    return
  end
  if type(current) ~= "number" or current ~= current then
    return
  end

  local freezing = CanTakeFreezeDamage(player) and IsFreezingNow(player, current)
  local overheating = CanTakeOverheatDamage(player) and IsOverheatingNow(player, current)

  local cooling = type(last) ~= "number" or last ~= last or current < last
  local heating = type(last) ~= "number" or last ~= last or current > last

  if freezing then
    if not player[FREEZE_FLAG] then
      player[FREEZE_FLAG] = true
      if cooling then
        AnnounceTemperature(player, "cold")
      end
    end
  else
    player[FREEZE_FLAG] = nil
  end

  if overheating then
    if not player[OVERHEAT_FLAG] then
      player[OVERHEAT_FLAG] = true
      if heating then
        AnnounceTemperature(player, "hot")
      end
    end
  else
    player[OVERHEAT_FLAG] = nil
  end
end

local function OnTemperatureDelta(player, data)
  local current = (data and type(data.new) == "number" and data.new) or GetTemperature(player)
  if current == nil then
    return
  end
  local last = data and data.last
  CheckTemperature(player, current, last)
end

core.ListenPlayer("temperaturedelta", OnTemperatureDelta)
