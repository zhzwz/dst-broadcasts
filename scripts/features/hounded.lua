--- 猎犬 / 洞穴蠕虫袭击预警（hounded）。
--- 倒计时多档 + 袭击开始边沿；单文件自包含，不依赖 WatchAttackWarning。

local THRESHOLDS = { 480, 240, 120, 60, 30, 10, 5 }

local function GetName()
  if core.IsForestWorld() then
    return core.GetPrefabDisplayName("hound")
  elseif core.IsCaveWorld() then
    return core.GetPrefabDisplayName("worm")
  end
end

AddSimPostInit(core.Wrap(function()
  if not core.IsServer() then return end
  local attacking = false
  local time_cache = math.huge
  core.SetInterval(TheWorld, function()
    --- 来袭公告，读档触发
    if TheWorld.components.hounded:GetAttacking() == true then
      time_cache = math.huge
      if attacking == false then
        core.Announce(string.format(i18n.attack_started, GetName()))
      end
      attacking = true
      return
    end
    attacking = false

    --- 来袭倒计时公告
    local t = TheWorld.components.hounded:GetTimeToAttack()
    local description = core.GetTimeDescription(t)
    for _, duration in ipairs(THRESHOLDS) do
      if t <= duration and duration < time_cache then
        core.Announce(string.format(i18n.attack_time, GetName(), description))
        time_cache = t
        return
      end
    end
    time_cache = t
  end, 1)
end))
