--[[
  猎犬 / 洞穴蠕虫等 hounded 袭击预警。
]]

local Safe = BROADCASTS_SAFE
local C = BROADCASTS_CONSTANTS

local function AttackName()
  if TheWorld:HasTag("cave") then
    return BROADCASTS_STRINGS.bosses.depths_worms
  end
  return BROADCASTS_STRINGS.bosses.hounds
end

AddSimPostInit(Safe.Wrap("hounded_init", function()
  if not TheWorld.ismastersim then
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
  TheWorld:DoPeriodicTask(C.HOUNDED_ATTACK_POLL_SECONDS, Safe.Wrap("hounded_attack", function()
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
      Safe.Announce(string.format(
        BROADCASTS_STRINGS.attack_started,
        AttackName()
      ))
    end
    was_attacking = attacking
  end))
end))
