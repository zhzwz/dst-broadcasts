--[[
  WX-78 快递无人机（Portable Storage Unit）配送落地播报。
]]

local S = BROADCASTS_STRINGS
local Safe = BROADCASTS_SAFE

local SUCCESS_FLAG = "_dst_broadcasts_drone_delivery_ok"
local SENDER_NAME_KEY = "_dst_broadcasts_drone_sender_name"

local DRONE_PREFABS = {
    "wx78_drone_delivery",
    "wx78_drone_delivery_small",
}

local function GetPrefabDisplayName(prefab)
    if type(prefab) ~= "string" or prefab == "" then
        return nil
    end
    local names = STRINGS and STRINGS.NAMES
    local display = type(names) == "table" and names[string.upper(prefab)] or nil
    if type(display) == "string" and display ~= "" then
        return "[" .. display .. "]"
    end
    return "[" .. prefab .. "]"
end

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
        Safe.Call("drone_delivery_foreach", function()
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
    local entry_fmt = S.named_count_entry or S.morning_dried_entry
    if type(entry_fmt) ~= "string" then
        return nil
    end
    local list = {}
    for prefab, n in pairs(counts) do
        if type(n) == "number" and n > 0 then
            local name = GetPrefabDisplayName(prefab)
            if name ~= nil then
                list[#list + 1] = { name = name, n = n }
            end
        end
    end
    if #list == 0 then
        return nil
    end
    table.sort(list, function(a, b)
        if a.name == b.name then
            return a.n < b.n
        end
        return a.name < b.name
    end)
    local parts = {}
    for _, entry in ipairs(list) do
        parts[#parts + 1] = string.format(entry_fmt, entry.name, entry.n)
    end
    return table.concat(parts, S.list_separator or ", ")
end

local function BracketName(name)
    if type(name) ~= "string" or name == "" then
        return nil
    end
    return "[" .. name .. "]"
end

local function GetDroneName(inst)
    local name = Safe.Call("drone_delivery_name", function()
        return inst:GetDisplayName()
    end)
    return BracketName(name) or GetPrefabDisplayName(inst.prefab) or "[?]"
end

local function GetSenderName(inst)
    local sender = inst._sender
    if sender ~= nil and sender:IsValid() then
        local name = Safe.Call("drone_delivery_sender", function()
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
    if type(S.drone_delivery_landed) ~= "string" then
        return
    end
    local contents = FormatContents(CollectContents(inst))
    if contents == nil then
        contents = S.drone_delivery_empty
    end
    if type(contents) ~= "string" or contents == "" then
        return
    end
    local sender = inst[SENDER_NAME_KEY] or GetSenderName(inst) or ""
    inst[SENDER_NAME_KEY] = nil
    local who = sender .. GetDroneName(inst)
    Safe.Announce(string.format(S.drone_delivery_landed, who, contents))
end

local function HookDrone(inst)
    local md = inst.components.mapdeliverable
    if md == nil then
        return
    end

    local old_progress = md.ondeliveryprogressfn
    md:SetOnDeliveryProgressFn(function(drone, t, len, origin, dest)
        if old_progress ~= nil then
            old_progress(drone, t, len, origin, dest)
        end
        if type(t) == "number" and type(len) == "number" and len > 0 and t >= len then
            drone[SUCCESS_FLAG] = true
            -- 落地动画结束时原版会清掉 _sender，先记住发货玩家
            drone[SENDER_NAME_KEY] = GetSenderName(drone)
        end
    end)

    inst:ListenForEvent("on_landed", Safe.Wrap("drone_delivery_landed", function()
        if not inst[SUCCESS_FLAG] then
            return
        end
        inst[SUCCESS_FLAG] = nil
        AnnounceLanded(inst)
    end))
end

for _, prefab in ipairs(DRONE_PREFABS) do
    AddPrefabPostInit(prefab, Safe.Wrap("drone_delivery_init:" .. prefab, HookDrone))
end
