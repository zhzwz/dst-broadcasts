--- 猎犬 / 洞穴蠕虫袭击预警（含开始播报）。
--- 按当前分片世界类型启用对应袭击名。

local C = BROADCASTS_ATTACK_WARNING

local function AttackName()
  if mod.World.IsCave() then
    return i18n.bosses.depths_worms
  end
  return i18n.bosses.hounds
end

AddSimPostInit(mod.Wrap("hounded_init", function()
  if not mod.World.IsServer() then
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
        i18n.attack_started,
        AttackName()
      ))
    end
    was_attacking = attacking
  end))
end))
