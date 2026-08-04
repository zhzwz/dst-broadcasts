local function Wrap(tag, fn)
  return function(...)
    return mod.Call(tag, fn, ...)
  end
end

mod.Wrap = Wrap
