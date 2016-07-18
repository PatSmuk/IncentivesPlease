local messages = {}

function messages.CLAIM_APPROVED(claim)
  return {
    type = "CLAIM_APPROVED",
    loggable = true,
    claim = claim
  }
end

function messages.CLAIM_DENIED(claim)
  return {
    type = "CLAIM_DENIED",
    loggable = true,
    claim = claim
  }
end

function messages.DAY_START(day)
  return {
    type = "DAY_START",
    loggable = true,
    day = day
  }
end

function messages.DAY_END()
  return {
    type = "DAY_END",
    loggable = true,
    day = day
  }
end

function messages.MOUSE_MOVE(x, y, dx, dy)
  return {
    type = "MOUSE_MOVE",
    loggable = true,
    x = x,
    y = y,
    dx = dx,
    dy = dy
  }
end

function messages.MOUSE_PRESS(x, y)
  return {
    type = "MOUSE_PRESS",
    loggable = true,
    x = x,
    y = y
  }
end

function messages.MOUSE_RELEASE(x, y)
  return {
    type = "MOUSE_RELEASE",
    loggable = true,
    x = x,
    y = y
  }
end

function messages.RENDER_BG()
  return {
    type = "RENDER_BG",
    loggable = false
  }
end

function messages.RENDER_FG()
  return {
    type = "RENDER_FG",
    loggable = false
  }
end

function messages.RENDER_UI()
  return {
    type = "RENDER_UI",
    loggable = false
  }
end

function messages.UPDATE(dt)
  return {
    type = "UPDATE",
    loggable = false,
    dt = dt
  }
end

return messages
