local function createAnimator(startValue, endValue, stiffness, damping, precision, callback)
  local x = startValue
  local v = 0

  local worker = coroutine.create(function (dt)
    while true do
      local Fspring = -stiffness * (x - endValue)
      local Fdamper = -damping * v
      local a = Fspring + Fdamper
      local newV = v + a * dt
      local newX = x + newV * dt
      if newV < precision and math.abs(x - newX) < precision then
        callback(endValue)
        break
      else
        x = newX
        v = newV
        callback(newX)
        dt = coroutine.yield()
      end
    end
  end)

  return function (dt)
    local ok, error = coroutine.resume(worker, dt)
    assert(ok, error)
    return coroutine.status(worker) == "dead"
  end
end

return createAnimator
