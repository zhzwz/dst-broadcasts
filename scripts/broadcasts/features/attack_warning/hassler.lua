--[[
  巨鹿 / 熊獾：倒计时预警与现身播报（含变异形态）。
]]

local Safe = BROADCASTS_SAFE
local C = BROADCASTS_ATTACK_WARNING

local DEERCLOPS_ENABLED = GetModConfigData("deerclops_warning_enabled")
local BEARGER_ENABLED = GetModConfigData("bearger_warning_enabled")

local BOSSES = {}
if DEERCLOPS_ENABLED then
  BOSSES[#BOSSES + 1] = {
    name = BROADCASTS_STRINGS.bosses.deerclops,
    timer = C.DEERCLOPS_TIMER,
  }
end
if BEARGER_ENABLED then
  BOSSES[#BOSSES + 1] = {
    name = BROADCASTS_STRINGS.bosses.bearger,
    timer = C.BEARGER_TIMER,
  }
end

local SPAWN_NAMES = {}
if DEERCLOPS_ENABLED then
  SPAWN_NAMES.deerclops = BROADCASTS_STRINGS.bosses.deerclops
  SPAWN_NAMES.mutateddeerclops = BROADCASTS_STRINGS.bosses.mutateddeerclops
end
if BEARGER_ENABLED then
  SPAWN_NAMES.bearger = BROADCASTS_STRINGS.bosses.bearger
  SPAWN_NAMES.mutatedbearger = BROADCASTS_STRINGS.bosses.mutatedbearger
end

if #BOSSES > 0 then
  AddSimPostInit(Safe.Wrap("hassler_init", function()
    if not TheWorld.ismastersim then
      return
    end
    if TheWorld:HasTag("cave") then
      return
    end
    if TheWorld.components.worldsettingstimer == nil then
      return
    end

    for _, boss in ipairs(BOSSES) do
      local timer = boss.timer
      local name = boss.name
      BROADCASTS_WATCH_ATTACK_WARNING(function()
        local wst = TheWorld.components.worldsettingstimer
        if wst == nil or
            not wst:ActiveTimerExists(timer) or
            wst:IsPaused(timer) then
          return nil
        end
        return wst:GetTimeLeft(timer)
      end, function()
        return name
      end)
    end
  end))
end

for prefab, name in pairs(SPAWN_NAMES) do
  AddPrefabPostInit(prefab, Safe.Wrap("hassler_spawn:" .. prefab, function(inst)
    if not TheWorld.ismastersim then
      return
    end

    local old_on_load = inst.OnLoad
    inst.OnLoad = function(inst, data)
      inst._dst_broadcasts_loaded = true
      if old_on_load ~= nil then
        Safe.Call("hassler_onload:" .. prefab, old_on_load, inst, data)
      end
    end

    inst:DoTaskInTime(0, Safe.Wrap("hassler_appear:" .. prefab, function()
      if inst:IsValid() and not inst._dst_broadcasts_loaded then
        Safe.Announce(string.format(
          BROADCASTS_STRINGS.boss_appeared,
          name
        ))
      end
    end))
  end))
end
