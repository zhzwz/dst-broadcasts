--- WX-78 相关播报（后续可继续往此文件追加）。
--- 便携储存单元（Portable Storage Unit）配送落地：发货玩家 + 单元名 + 内容物汇总。
--- 仅主机；进度完成后等 on_landed；内容物为空不播。

local S = i18n

local SUCCESS_FLAG = "_dst_broadcasts_portable_storage_ok"
local SENDER_NAME_KEY = "_dst_broadcasts_portable_storage_sender_name"

local UNIT_PREFABS = {
  "wx78_drone_delivery",
  "wx78_drone_delivery_small",
}

local function CollectContents(inst)
  local counts = {}
  local container = inst.components ~= nil and inst.components.container or nil
  if container == nil then
    return counts
  end

  local function consider(item)
    if item == nil or not item:IsValid() or type(item.prefab) ~= "string" then
      return
    end
    local n = core.GetCount(item)
    if n == nil then
      return
    end
    counts[item.prefab] = (counts[item.prefab] or 0) + n
  end

  if container.ForEachItem ~= nil then
    container:ForEachItem(consider)
  elseif type(container.slots) == "table" then
    for _, item in pairs(container.slots) do
      consider(item)
    end
  end

  return counts
end

local function FormatContents(counts)
  local named = {}
  for prefab, n in pairs(counts) do
    if type(n) == "number" and n > 0 then
      local name = core.GetPrefabDisplayName(prefab)
      if name ~= nil then
        named[name] = (named[name] or 0) + n
      end
    end
  end
  return core.FormatEntryCountList(named)
end

local function GetUnitName(inst)
  return core.GetDisplayName(inst)
      or core.GetPrefabDisplayName(inst.prefab)
      or "?"
end

local function GetSenderName(inst)
  local sender = inst._sender
  if sender ~= nil and sender:IsValid() then
    return core.GetDisplayName(sender)
  end
  return nil
end

local function AnnounceLanded(inst)
  if type(S.portable_storage_landed) ~= "string" then
    inst[SENDER_NAME_KEY] = nil
    return
  end
  local contents = FormatContents(CollectContents(inst))
  local sender = inst[SENDER_NAME_KEY] or GetSenderName(inst) or ""
  inst[SENDER_NAME_KEY] = nil
  if type(contents) ~= "string" or contents == "" then
    return
  end
  local who = sender .. GetUnitName(inst)
  core.Announce(string.format(S.portable_storage_landed, who, contents))
end

local function HookUnit(inst)
  local md = inst.components.mapdeliverable
  if md == nil then
    return
  end

  local old_progress = md.ondeliveryprogressfn
  md:SetOnDeliveryProgressFn(function(unit, t, len, origin, dest)
    if old_progress ~= nil then
      old_progress(unit, t, len, origin, dest)
    end
    if type(t) == "number" and type(len) == "number" and len > 0 and t >= len then
      unit[SUCCESS_FLAG] = true
      --- 落地动画结束时原版会清掉 _sender，先记住发货玩家
      unit[SENDER_NAME_KEY] = GetSenderName(unit)
    end
  end)

  inst:ListenForEvent("on_landed", core.Wrap(function()
    if not inst[SUCCESS_FLAG] then
      return
    end
    inst[SUCCESS_FLAG] = nil
    AnnounceLanded(inst)
  end))
end

for _, prefab in ipairs(UNIT_PREFABS) do
  AddPrefabPostInit(prefab, core.Wrap(HookUnit))
end
