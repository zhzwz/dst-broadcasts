--- @deprecated 遗弃：纯服务端模组无法让客户端执行 Networking_Say。
--- 聊天频道带玩家名发言需要 all_clients_require_mod；当前请用 PlayerBubble / Announce。
--- @param message string
--- @param player Entity|nil
core.PlayerSay = function(message, player)
end
