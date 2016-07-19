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
      local newEndValue

      if newV < precision and math.abs(x - newX) < precision then
        x = endValue
        v = 0
        callback(endValue)
        dt, newEndValue = coroutine.yield(true)
      else
        x = newX
        v = newV
        callback(newX)
        dt, newEndValue = coroutine.yield(false)
      end

      print("newEndValue: "..tostring(newEndValue))
      if newEndValue then
        endValue = newEndValue
      end
    end
  end)

  return function (dt, newEndValue)
    local ok, errorOrDone = coroutine.resume(worker, dt, newEndValue)
    assert(ok, errorOrDone)
    return errorOrDone
  end
end

return createAnimator
