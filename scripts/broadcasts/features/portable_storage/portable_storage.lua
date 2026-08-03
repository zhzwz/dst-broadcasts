--[[
  WX-78 便携储存单元（Portable Storage Unit）配送落地播报。
]]

modimport("scripts/broadcasts/shared/get_prefab_display_name.lua")
modimport("scripts/broadcasts/lib/harvest_announce.lua")

local S = BROADCASTS_STRINGS
local Safe = BROADCASTS_SAFE
local GetPrefabDisplayName = BROADCASTS_GET_PREFAB_DISPLAY_NAME
local FormatNamedCountList = BROADCASTS_HARVEST_ANNOUNCE.FormatNamedCountList

local SUCCESS_FLAG = "_dst_broadcasts_portable_storage_ok"
local SENDER_NAME_KEY = "_dst_broadcasts_portable_storage_sender_name"

local UNIT_PREFABS = {
  "wx78_drone_delivery",
  "wx78_drone_delivery_small",
}

local function GetItemStackSize(item)
  local stack = 1
  local stackable = item.components ~= nil and item.components.stackable or nil
  if stackable ~= nil and stackable.StackSize ~= nil then
    local ok, size = pcall(function()
      return stackable:StackSize()
    end)
    if ok and type(size) == "number" and size > 0 then
      stack = size
    end
  end
  return stack
end

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
    counts[item.prefab] = (counts[item.prefab] or 0) + GetItemStackSize(item)
  end

  if container.ForEachItem ~= nil then
    Safe.Call("portable_storage_foreach", function()
      container:ForEachItem(consider)
    end)
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
      local name = GetPrefabDisplayName(prefab)
      if name ~= nil then
        named[name] = (named[name] or 0) + n
      end
    end
  end
  return FormatNamedCountList(named, S.list_separator or ", ")
end

local function BracketName(name)
  if type(name) ~= "string" or name == "" then
    return nil
  end
  return "[" .. name .. "]"
end

local function GetUnitName(inst)
  local name = Safe.Call("portable_storage_name", function()
    return inst:GetDisplayName()
  end)
  return BracketName(name) or GetPrefabDisplayName(inst.prefab) or "[?]"
end

local function GetSenderName(inst)
  local sender = inst._sender
  if sender ~= nil and sender:IsValid() then
    local name = Safe.Call("portable_storage_sender", function()
      return sender:GetDisplayName()
    end)
    local bracketed = BracketName(name)
    if bracketed ~= nil then
      return bracketed
    end
  end
  return nil
end

local function AnnounceLanded(inst)
  if type(S.portable_storage_landed) ~= "string" then
    return
  end
  local contents = FormatContents(CollectContents(inst))
  if type(contents) ~= "string" or contents == "" then
    return
  end
  local sender = inst[SENDER_NAME_KEY] or GetSenderName(inst) or ""
  inst[SENDER_NAME_KEY] = nil
  local who = sender .. GetUnitName(inst)
  Safe.Announce(string.format(S.portable_storage_landed, who, contents))
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
      -- 落地动画结束时原版会清掉 _sender，先记住发货玩家
      unit[SENDER_NAME_KEY] = GetSenderName(unit)
    end
  end)

  inst:ListenForEvent("on_landed", Safe.Wrap("portable_storage_landed", function()
    if not inst[SUCCESS_FLAG] then
      return
    end
    inst[SUCCESS_FLAG] = nil
    AnnounceLanded(inst)
  end))
end

for _, prefab in ipairs(UNIT_PREFABS) do
  AddPrefabPostInit(prefab, Safe.Wrap("portable_storage_init:" .. prefab, HookUnit))
end
