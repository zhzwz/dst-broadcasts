--[[
  猎犬 / 洞穴蠕虫袭击预警（含开始播报）。
  按世界分片与独立配置启用。
]]

local C = BROADCASTS_ATTACK_WARNING

local HOUNDS_ENABLED = GetModConfigData("hounds_warning_enabled")
local WORMS_ENABLED = GetModConfigData("depths_worms_warning_enabled")

local function AttackName()
  if mod.World.IsCave() then
    return BROADCASTS_STRINGS.bosses.depths_worms
  end
  return BROADCASTS_STRINGS.bosses.hounds
end

local function IsEnabledHere()
  if mod.World.IsCave() then
    return WORMS_ENABLED
  end
  return HOUNDS_ENABLED
end

AddSimPostInit(mod.Wrap("hounded_init", function()
  if not mod.World.IsMaster() then
    return
  end
  if not IsEnabledHere() then
    return
  end
  if TheWorld.components.hounded == nil then
    return
  end

  BROADCASTS_WATCH_ATTACK_WARNING(function()
    local hounded = TheWorld.components.hounded
    if hounded == nil or hounded:GetAttacking() then
      return nil
    end
    return hounded:GetTimeToAttack()
  end, AttackName)

  local was_attacking = nil
  TheWorld:DoPeriodicTask(C.HOUNDED_ATTACK_POLL_SECONDS, mod.Wrap("hounded_attack", function()
    local hounded = TheWorld.components.hounded
    if hounded == nil then
      return
    end
    local attacking = hounded:GetAttacking()
    if was_attacking == nil then
      was_attacking = attacking
      return
    end
    if attacking and not was_attacking then
      mod.Announce(string.format(
        BROADCASTS_STRINGS.attack_started,
        AttackName()
      ))
    end
    was_attacking = attacking
  end))
end))
