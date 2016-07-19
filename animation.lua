local function createAnimator(startValue, endValue, stiffness, damping, callback)
  local x = startValue
  local v = 0

  local worker = coroutine.create(function (dt)
    while true do
      local Fspring = -stiffness * (x - endValue)
      local Fdamper = -damping * v
      local a = Fspring + Fdamper
      local newV = v + a * dt
      local newX = x + newV * dt
      if newV < 0.01 and math.abs(x - newX) < 0.01 then
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
