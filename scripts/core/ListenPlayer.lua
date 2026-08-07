--- 主机上为玩家挂 ListenForEvent（AddPlayerPostInit + 仅 ismastersim）。

local listeners = {}

--- @alias ListenPlayerEvent "hungerdelta"|"healthdelta"|"sanitydelta"|"moisturedelta"|"temperaturedelta"|"armorbroke"
--- @param event ListenPlayerEvent
--- @param fn function
core.ListenPlayer = function(event, fn)
  table.insert(listeners, { event = event, fn = fn })
  if #listeners > 1 then
    return
  end
  AddPlayerPostInit(core.Wrap(function(player)
    if not core.IsServer() then
      return
    end
    for i = 1, #listeners do
      local entry = listeners[i]
      player:ListenForEvent(entry.event, core.Wrap(entry.fn))
    end
  end))
end
