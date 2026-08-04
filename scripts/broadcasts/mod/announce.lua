local TAG = "mod.Announce"

local function Announce(message)
  if type(message) ~= "string" or message == "" then
    return
  end
  mod.Call(TAG, function()
    TheNet:Announce(message)
  end)
end

mod.Announce = Announce
